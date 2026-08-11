SELECT * FROM users;

UPDATE accounts
SET role = 'admin';

DELETE FROM audit_log;

SELECT id, email
FROM customers
WHERE id = id;

SELECT id
FROM users
WHERE deleted_at = NULL;

CREATE TABLE invoices (
  invoice_date VARCHAR(20),
  amount VARCHAR(20)
);
