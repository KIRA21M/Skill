# Test 05

## Input
```sql
DECLARE @sql NVARCHAR(MAX) =
  'DELETE FROM ' + @tableName + ' WHERE id = ' + CAST(@id AS NVARCHAR(20));

EXEC(@sql);
```

## Expected behavior
The skill should flag dynamic SQL concatenation as `HIGH`, identify the injection boundary, and avoid recommending execution.

## Actual behavior
The review marks the concatenation as `HIGH`, points out the untrusted boundary, and does not suggest running the statement.

## Pass / Fail
Pass

## Problem detected
Dynamic SQL can hide the destructive target table and the injected identifier value.

## Modification made to the skill
Added an explicit rule for string concatenation and interpolation that can inject untrusted values into SQL.
