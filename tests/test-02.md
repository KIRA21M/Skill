# Test 02

## Input
```sql
SELECT * FROM users;

UPDATE accounts
SET role = 'admin';

DELETE FROM audit_log;
```

## Expected behavior
The skill should flag `SELECT *` as a performance concern and both `UPDATE` and `DELETE` without `WHERE` as `CRITICAL`.

## Actual behavior
The review reports one `MEDIUM` finding for `SELECT *` and two `CRITICAL` findings for the unfiltered modification statements.

## Pass / Fail
Pass

## Problem detected
Multiple clear violations in a single script.

## Modification made to the skill
None.
