#!/bin/bash

set -e

# Execute Athena queries for cost analysis
# This script is called as a hook from Spacelift on a scheduled basis

echo "========================================="
echo "Running Athena Cost Analysis Queries"
echo "========================================="

# Configuration
AWS_REGION="${TF_VAR_aws_region:-us-east-1}"
WORKGROUP="${TF_OUTPUT_athena_workgroup_name:-cost-analysis-workgroup}"
DATABASE="${TF_OUTPUT_glue_database_name:-cur_database}"
RESULTS_BUCKET="${TF_OUTPUT_athena_results_bucket}"
GLUE_CRAWLER="${TF_OUTPUT_glue_crawler_name}"

# Script runs from /mnt/workspace in Spacelift
QUERIES_DIR="/mnt/workspace/athena-queries"

echo "Configuration:"
echo "  Region: ${AWS_REGION}"
echo "  Workgroup: ${WORKGROUP}"
echo "  Database: ${DATABASE}"
echo "  Results Bucket: ${RESULTS_BUCKET}"

# Function to execute Athena query
execute_query() {
    local query_file=$1
    local query_name=$(basename "${query_file}" .sql)
    local table_name=$2

    echo ""
    echo "Executing query: ${query_name}"

    # Read the query from file and substitute table name
    local query=$(cat "${query_file}" | sed "s/cost_and_usage_report/${table_name}/g")

    # Start query execution
    local execution_id=$(aws athena start-query-execution \
        --region "${AWS_REGION}" \
        --query-string "${query}" \
        --query-execution-context "Database=${DATABASE}" \
        --work-group "${WORKGROUP}" \
        --output text \
        --query 'QueryExecutionId')

    echo "  Execution ID: ${execution_id}"

    # Wait for query to complete
    local status="RUNNING"
    while [ "${status}" == "RUNNING" ] || [ "${status}" == "QUEUED" ]; do
        sleep 2
        status=$(aws athena get-query-execution \
            --region "${AWS_REGION}" \
            --query-execution-id "${execution_id}" \
            --output text \
            --query 'QueryExecution.Status.State')
        echo "  Status: ${status}"
    done

    if [ "${status}" == "SUCCEEDED" ]; then
        echo "  ✓ Query completed successfully"

        # Get results location
        local results_location=$(aws athena get-query-execution \
            --region "${AWS_REGION}" \
            --query-execution-id "${execution_id}" \
            --output text \
            --query 'QueryExecution.ResultConfiguration.OutputLocation')

        echo "  Results: ${results_location}"

        # Optionally download and display results
        if [ ! -z "${DISPLAY_RESULTS}" ]; then
            echo "  --- Results Preview ---"
            aws s3 cp "${results_location}" - | head -20
            echo "  --- End Preview ---"
        fi
    else
        echo "  ✗ Query failed with status: ${status}"

        # Get error message
        local error_msg=$(aws athena get-query-execution \
            --region "${AWS_REGION}" \
            --query-execution-id "${execution_id}" \
            --output text \
            --query 'QueryExecution.Status.StateChangeReason' 2>/dev/null || echo "Unknown error")

        echo "  Error: ${error_msg}"
    fi
}

# Step 1: Run Glue Crawler to update schema
echo ""
echo "[1/4] Running Glue Crawler to update CUR data schema..."
aws glue start-crawler \
    --region "${AWS_REGION}" \
    --name "${GLUE_CRAWLER}" 2>/dev/null || echo "  Crawler already running or recently completed"

echo "  Waiting for crawler to complete (this may take a few minutes)..."
crawler_state="RUNNING"
max_wait=300
elapsed=0

while [ "${crawler_state}" == "RUNNING" ] && [ ${elapsed} -lt ${max_wait} ]; do
    sleep 10
    elapsed=$((elapsed + 10))

    crawler_state=$(aws glue get-crawler \
        --region "${AWS_REGION}" \
        --name "${GLUE_CRAWLER}" \
        --output text \
        --query 'Crawler.State' 2>/dev/null || echo "UNKNOWN")

    echo "  Crawler state: ${crawler_state} (${elapsed}s elapsed)"
done

if [ "${crawler_state}" == "READY" ]; then
    echo "  ✓ Crawler completed successfully"
else
    echo "  ⚠ Crawler state: ${crawler_state} (continuing anyway)"
fi

# Discover the actual table name created by Glue Crawler
echo ""
echo "Discovering CUR table name..."
TABLE_NAME=$(aws glue get-tables \
    --database-name "${DATABASE}" \
    --region "${AWS_REGION}" \
    --query 'TableList[0].Name' \
    --output text 2>/dev/null || echo "")

if [ -z "${TABLE_NAME}" ] || [ "${TABLE_NAME}" == "None" ]; then
    echo "  ✗ No CUR table found in database ${DATABASE}"
    echo "  Make sure CUR data has been generated and Glue Crawler has run successfully"
    exit 1
fi

echo "  Found table: ${TABLE_NAME}"

# Step 2: Execute daily costs query
echo ""
echo "[2/4] Executing daily costs analysis..."
execute_query "${QUERIES_DIR}/daily-costs.sql" "${TABLE_NAME}"

# Step 3: Execute service breakdown query
echo ""
echo "[3/4] Executing service cost breakdown..."
execute_query "${QUERIES_DIR}/service-breakdown.sql" "${TABLE_NAME}"

# Step 4: Execute optimization opportunities query
echo ""
echo "[4/4] Executing optimization opportunities analysis..."
execute_query "${QUERIES_DIR}/optimization-opportunities.sql" "${TABLE_NAME}"

echo ""
echo "========================================="
echo "Athena Cost Analysis Complete!"
echo "========================================="
echo ""
echo "All results are stored in: s3://${RESULTS_BUCKET}/output/"
echo ""
echo "To view results in Athena Console:"
echo "  https://console.aws.amazon.com/athena/home?region=${AWS_REGION}#/query-editor"
echo ""
