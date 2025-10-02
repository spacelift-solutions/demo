-- Daily cost breakdown by service
-- This query aggregates costs by AWS service on a daily basis

SELECT
    line_item_usage_start_date AS usage_date,
    line_item_product_code AS service,
    SUM(line_item_unblended_cost) AS daily_cost,
    SUM(line_item_usage_amount) AS usage_amount,
    line_item_usage_type AS usage_type,
    pricing_unit AS unit
FROM
    cur_database.cost_and_usage_report
WHERE
    line_item_usage_start_date >= DATE_ADD('day', -30, CURRENT_DATE)
    AND line_item_line_item_type = 'Usage'
GROUP BY
    line_item_usage_start_date,
    line_item_product_code,
    line_item_usage_type,
    pricing_unit
ORDER BY
    usage_date DESC,
    daily_cost DESC
LIMIT 1000;
