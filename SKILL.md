# SQL Reviewer

## Purpose
Review SQL statements and scripts as a deterministic technical reviewer.
The skill must identify correctness, security, performance, and naming issues without executing SQL or inventing missing context.

## When to activate
Activate when the input contains SQL statements, SQL scripts, stored procedures, database migration snippets, query fragments, or embedded SQL that needs a technical review.

## When NOT to activate
Do not activate when:
- The input is not SQL and has no embedded SQL.
- The user asks to run, execute, or benchmark a query instead of reviewing it.
- The request requires schema, row counts, indexes, or business rules that are not provided and cannot be inferred safely.
- The user wants a generic SQL lesson instead of a review of specific SQL text.

## Inputs
The skill accepts:
- One or more SQL statements or scripts.
- Optional dialect information such as PostgreSQL, MySQL, SQL Server, SQLite, or ANSI SQL.
- Optional schema metadata, index metadata, and table cardinality hints.
- Optional business rules, safety policies, or performance goals.

If dialect, schema, or workload details are absent, the skill must not invent them.

## Procedure
1. Split the input into statements and classify each statement by type.
2. Normalize superficial formatting changes without changing meaning.
3. Inspect security risks first, then correctness, then performance, then conventions.
4. Apply the explicit rules in this file and in `rules/*.md`.
5. If a rule depends on missing schema or workload information, report the uncertainty instead of guessing.
6. Sort findings by severity from highest to lowest.
7. If there are no findings, say that the SQL is acceptable under the provided context.

## Rules
The skill must use explicit decision rules.

IF statement = DELETE
AND WHERE is absent
THEN severity = CRITICAL
AND do not recommend executing the statement.

IF statement = UPDATE
AND WHERE is absent
THEN severity = CRITICAL
AND do not recommend executing the statement.

IF WHERE clause is present
AND the predicate is a tautology such as `1 = 1`, `TRUE`, `col = col`, or another always-true filter
THEN severity = CRITICAL
AND treat the statement as effectively unbounded.

IF statement contains destructive operations such as `DROP`, `TRUNCATE`, `ALTER TABLE ... DROP`, or equivalent data-loss actions
THEN severity = CRITICAL.

IF SQL text shows concatenation or string interpolation that can inject untrusted values into SQL
THEN severity = HIGH
AND mention the injection boundary explicitly.

IF NULL is compared with `=`, `!=`, or `<>` instead of `IS NULL` or `IS NOT NULL`
THEN severity = HIGH
AND explain the null-comparison bug.

IF a DDL statement stores an obviously numeric, monetary, or date value in a text type without justification in the input
THEN severity = MEDIUM
AND explain the type mismatch.

IF a predicate matches all rows through wildcard logic such as `LIKE '%'` or `ILIKE '%'`
THEN treat the statement as effectively unbounded
AND apply `CRITICAL` to destructive DML or `HIGH` to read-only queries.

IF LIMIT is extremely large, such as `1000000` or more
THEN severity = HIGH
AND explain that the cap is not meaningfully restrictive.

IF the issue depends on schema facts that are not provided
THEN severity = INFO
AND state that the conclusion cannot be confirmed.

IF multiple rules match
THEN use the highest severity that applies.

## Severity levels
- CRITICAL: Immediate risk of destructive or unsafe behavior.
- HIGH: Strong security, correctness, or performance risk that should be fixed before use.
- MEDIUM: Important maintainability or efficiency issue with moderate impact.
- LOW: Style, naming, or clarity issue with limited direct risk.
- INFO: Uncertain issue, missing context, or advisory note that cannot be confirmed.

## Expected output
The skill should produce:
- A short overall assessment.
- A list of findings, each with:
  - Severity
  - Statement or fragment
  - Evidence
  - Why it matters
  - Recommended fix

If context is insufficient, the output must say what is missing and what cannot be concluded.
The skill must never claim certainty about indexes, row counts, or constraints when those facts were not provided.

## Validation
Before finalizing a review, verify that:
- Every finding points to concrete SQL text.
- No finding depends on invented schema or workload data.
- Severity matches the explicit rules.
- Recommendations do not tell the user to run unsafe SQL.
- The review remains reproducible when the same input is provided again.

## Failure handling
If the input is ambiguous, parse each possible statement boundary and say where the ambiguity is.
If the dialect is unknown, use conservative ANSI SQL assumptions and note dialect-specific uncertainty.
If schema data is missing, downgrade schema-dependent conclusions to INFO.
If the input is malformed, report the parse problem and review only the parts that are still readable.
If the content is not SQL, explain that the skill is inactive for that input.
