SELECT 
	"mp table", 
    DATE_FORMAT(updated_at, '%Y-%m-%d'), 
    SUM(CASE WHEN DATE_FORMAT(updated_at, '%Y') = 2025 THEN 1 ELSE 0 END) AS "2025",
    SUM(CASE WHEN DATE_FORMAT(updated_at, '%Y') < 2025 THEN 1 ELSE 0 END) AS "<_2024",
    COUNT(*) 
FROM vapor.membership_periods 
GROUP BY 2 ORDER BY 2 
DESC LIMIT 10000
;