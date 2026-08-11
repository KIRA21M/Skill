# Test 02

## Input
```sql
SELECT * FROM users;

UPDATE accounts
SET role = 'admin';

DELETE FROM audit_log;
```

## Expected behavior
La skill debe marcar `SELECT *` como un tema de rendimiento y tanto `UPDATE` como `DELETE` sin `WHERE` como `CRITICAL`.

## Actual behavior
La revision reporta un hallazgo `MEDIUM` por `SELECT *` y dos hallazgos `CRITICAL` por las sentencias de modificacion sin filtro.

## Pass / Fail
Aprobado

## Problem detected
Varias violaciones claras en un solo script.

## Modification made to the skill
Ninguna.
