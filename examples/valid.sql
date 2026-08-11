SELECT
  u.user_id,
  u.email,
  u.created_at
FROM users AS u
WHERE u.is_active = 1
ORDER BY u.created_at DESC
LIMIT 20;

SELECT
  o.order_id,
  o.customer_id,
  o.total_amount
FROM orders AS o
WHERE o.status = 'paid'
  AND o.created_at >= DATE '2026-01-01';
