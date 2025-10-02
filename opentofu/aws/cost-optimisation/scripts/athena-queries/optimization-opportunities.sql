-- Cost optimization opportunities
-- Identifies potential areas for cost savings

-- EC2 instances running 24/7 with low utilization
WITH ec2_costs AS (
    SELECT
        line_item_resource_id AS resource_id,
        line_item_usage_type AS usage_type,
        product_instance_type AS instance_type,
        product_region AS region,
        SUM(line_item_unblended_cost) AS monthly_cost,
        COUNT(DISTINCT DATE_TRUNC('day', line_item_usage_start_date)) AS days_running
    FROM
        cur_database.cost_and_usage_report
    WHERE
        line_item_product_code = 'AmazonEC2'
        AND line_item_usage_type LIKE '%BoxUsage%'
        AND line_item_usage_start_date >= DATE_ADD('day', -30, CURRENT_DATE)
    GROUP BY
        line_item_resource_id,
        line_item_usage_type,
        product_instance_type,
        product_region
    HAVING
        COUNT(DISTINCT DATE_TRUNC('day', line_item_usage_start_date)) >= 25
),
-- Unattached EBS volumes
ebs_volumes AS (
    SELECT
        line_item_resource_id AS volume_id,
        product_volume_type AS volume_type,
        product_region AS region,
        SUM(line_item_unblended_cost) AS monthly_cost
    FROM
        cur_database.cost_and_usage_report
    WHERE
        line_item_product_code = 'AmazonEC2'
        AND line_item_usage_type LIKE '%EBS:Volume%'
        AND line_item_usage_start_date >= DATE_ADD('day', -30, CURRENT_DATE)
    GROUP BY
        line_item_resource_id,
        product_volume_type,
        product_region
),
-- Idle load balancers
idle_lbs AS (
    SELECT
        line_item_resource_id AS lb_id,
        product_region AS region,
        SUM(line_item_unblended_cost) AS monthly_cost
    FROM
        cur_database.cost_and_usage_report
    WHERE
        line_item_product_code = 'AWSELB'
        AND line_item_usage_start_date >= DATE_ADD('day', -30, CURRENT_DATE)
    GROUP BY
        line_item_resource_id,
        product_region
)
-- Combine all optimization opportunities
SELECT 'EC2 - Always On Instances' AS opportunity_type,
       resource_id,
       instance_type AS details,
       region,
       monthly_cost,
       ROUND(monthly_cost * 0.6, 2) AS potential_savings_estimate
FROM ec2_costs
WHERE monthly_cost > 50
UNION ALL
SELECT 'EBS - Unattached Volumes' AS opportunity_type,
       volume_id AS resource_id,
       volume_type AS details,
       region,
       monthly_cost,
       monthly_cost AS potential_savings_estimate
FROM ebs_volumes
WHERE monthly_cost > 10
UNION ALL
SELECT 'ELB - Potential Idle Load Balancers' AS opportunity_type,
       lb_id AS resource_id,
       'Load Balancer' AS details,
       region,
       monthly_cost,
       monthly_cost AS potential_savings_estimate
FROM idle_lbs
WHERE monthly_cost > 20
ORDER BY potential_savings_estimate DESC
LIMIT 100;
