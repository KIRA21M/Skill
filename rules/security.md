# Security Rules

1. `DELETE` without `WHERE` is `CRITICAL`.
2. `UPDATE` without `WHERE` is `CRITICAL`.
3. `WHERE` clauses that are tautologies, such as `1 = 1`, `TRUE`, or `col = col`, are `CRITICAL`.
4. `DROP`, `TRUNCATE`, and destructive `ALTER TABLE` operations are `CRITICAL`.
5. Dynamic SQL built with string concatenation or interpolation from untrusted values is `HIGH`.
6. If the SQL text exposes an obvious injection boundary, name the boundary in the finding.
7. If the query depends on permissions, row-level policies, or constraints that are not provided, report the uncertainty as `INFO`.
