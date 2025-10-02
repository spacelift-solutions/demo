-- Service cost breakdown for the current month
-- Groups costs by AWS service with percentage of total

WITH monthly_costs AS (
    SELECT
        line_item_product_code AS service,
        SUM(line_item_unblended_cost) AS total_cost
    FROM
        cur_database.cost_and_usage_report
    WHERE
        line_item_usage_start_date >= DATE_TRUNC('month', CURRENT_DATE)
        AND line_item_line_item_type IN ('Usage', 'Fee')
    GROUP BY
        line_item_product_code
),
total AS (
    SELECT SUM(total_cost) AS overall_total
    FROM monthly_costs
)
SELECT
    mc.service,
    mc.total_cost,
    ROUND((mc.total_cost / t.overall_total) * 100, 2) AS percentage_of_total,
    t.overall_total AS total_monthly_cost
FROM
    monthly_costs mc
CROSS JOIN
    total t
WHERE
    mc.total_cost > 0
ORDER BY
    mc.total_cost DESC
LIMIT 50;
