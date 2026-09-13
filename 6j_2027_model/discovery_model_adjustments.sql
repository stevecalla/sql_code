-- FIND MISSING / NEW ACTUAL CATEGORIES
WITH sales_actuals AS (
    SELECT
        MONTH(common_purchased_on_date_adjusted) AS month_actual,
        real_membership_types_sa AS type_actual,
        new_member_category_6_sa AS category_actual,
        SUM(revenue_current) AS sales_rev_2026_actual
    FROM sales_data_year_over_year_2026
    GROUP BY 1, 2, 3
),

sales_goals AS (
    SELECT DISTINCT
        purchased_on_month_adjusted_mp AS month_goal,
        real_membership_types_sa AS type_goal,
        new_member_category_6_sa AS category_goal
    FROM sales_goal_data
    WHERE purchased_on_year_adjusted_mp = 2026
)

SELECT
    sa.month_actual,
    sa.type_actual,
    sa.category_actual,
    FORMAT(sa.sales_rev_2026_actual, 0) AS missing_revenue
FROM sales_actuals sa
LEFT JOIN sales_goals sg
    ON sa.month_actual = sg.month_goal
    AND sa.type_actual = sg.type_goal
    AND sa.category_actual = sg.category_goal
WHERE sg.month_goal IS NULL
ORDER BY sa.month_actual, sa.type_actual, sa.category_actual;

-- FIND MISSING GOAL REVENUE
WITH sales_actuals AS (
    SELECT
        MONTH(common_purchased_on_date_adjusted) AS month_actual,
        real_membership_types_sa AS type_actual,
        new_member_category_6_sa AS category_actual,

        SUM(revenue_current) AS sales_rev_2026_actual,
        SUM(units_current_year) AS sales_units_2026_actual

    FROM sales_data_year_over_year_2026

    GROUP BY 1, 2, 3
),

sales_goals AS (
    SELECT
        purchased_on_month_adjusted_mp AS month_goal,
        real_membership_types_sa AS type_goal,
        new_member_category_6_sa AS category_goal,

        SUM(sales_revenue) AS sales_rev_2026_goal,
        SUM(sales_units) AS sales_units_2026_goal

    FROM sales_goal_data

    WHERE purchased_on_year_adjusted_mp = 2026

    GROUP BY 1, 2, 3
)

SELECT
    sg.month_goal,
    sg.type_goal,
    sg.category_goal,

    sg.sales_rev_2026_goal,
    sg.sales_units_2026_goal,

    sa.sales_rev_2026_actual,
    sa.sales_units_2026_actual

FROM sales_goals AS sg

LEFT JOIN sales_actuals AS sa
    ON sg.month_goal = sa.month_actual
    AND sg.type_goal = sa.type_actual
    AND sg.category_goal = sa.category_actual

WHERE
    sg.category_goal = 'Unknown'
    AND IFNULL(sa.sales_rev_2026_actual, 0) = 0
    AND IFNULL(sa.sales_units_2026_actual, 0) = 0

ORDER BY sg.month_goal, sg.type_goal;