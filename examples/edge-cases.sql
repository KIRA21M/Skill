DELETE FROM users WHERE 1 = 1;

SELECT *
FROM audit_log
LIMIT 1000000000;

SELECT
  customer_id,
  SUM(total_amount)
FROM orders
WHERE created_at >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY customer_id;
