#!/bin/bash

# Set correct working directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

export DB_NAME_SUFFIX="${TF_VAR_db_name_suffix}"
export PROJECT_ID="${TF_VAR_project_id}"

FUNCTION_NAME="./scheduler.py"
ZIP_FILE="function.zip"
GCS_BUCKET="${PROJECT_ID}-scheduler-scr-${DB_NAME_SUFFIX}"

echo "Packaging Cloud Function code..."

# Create zip with correct paths
zip -j $ZIP_FILE ./scheduler.py ./requirements.txt

echo "Uploading to Google Cloud Storage..."
gsutil cp $ZIP_FILE gs://$GCS_BUCKET/

echo "Cleaning up local artifacts..."
rm -f $ZIP_FILE

echo "Package uploaded successfully"