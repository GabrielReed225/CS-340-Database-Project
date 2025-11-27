CS340 project specifications
This document outlines the requirements for your final database project submission, including schema, web interface behavior, query usage, stored procedures, and minimum deliverables.

Database requirements
Pre-populated data: Include at least 3 rows per table.

Illustrative samples: Seed data must demonstrate functionality, especially for many-to-many (M:M) relationships.

Minimum schema: At least 4 entities and at least 4 relationships, with at least one M:M.

Web interface guidelines
Audience: Admin-only interface; not customer-facing.

No auth features: No login, sessions, registration/password, shopping cart, etc.

Page count expectation: If 4 entities are implemented as 5 tables, expect about 5 pages.

M:M page: A single page may be used to manage the relationship between 2 tables.

Optional home: You may include a simple home/landing page.

Query requirements
Per-table SELECT: Each table must be used in at least one SELECT query.

Display content: SELECTs should show table contents; do not join all tables in a single query.

Stored procedures and injection prevention
Required stored procedures: Use stored procedures for INSERT, DELETE, and UPDATE.

Security goal: Procedures must be used to guard against SQL injection.

CUD functionality (create, update, delete)
Scope: Implement INSERT, UPDATE, and DELETE for at least one entity, preferably within an M:M relationship.

Distribution: CUD can be split across multiple pages or consolidated on one page.

Key selection UX
No manual IDs: Do not type IDs directly.

Use controls: Provide drop-down lists or search inputs to select foreign keys.

Examples
INSERT (M:M): Add Products to OrderItems (OrderItems is the intersection between Products and Orders).

DELETE (M:M): Remove a record from an M:M relationship without affecting related tables.

For example, delete Orders made by a Customer.

Approaches include setting CustomerID to NULL or deleting Orders associated with that Customer.

Consider referential actions (e.g., MySQL CASCADE) as appropriate to your design.

UPDATE (M:M): Change a foreign key in an intersection table (e.g., update ProductID in OrderItems).

DDL and reset functionality
DDL script: Create the database using a DDL script (as covered in modules 3–5).

Reset support: Provide a RESET capability so changes can be reverted.

Minimum implementation checklist
SELECTs: 5

INSERT (PL/SQL on M:M): 1

UPDATE (PL/SQL on M:M): 1

DELETE (PL/SQL on M:M): 1

Dynamic selection: Drop-down or search for keys

Reset or PL/SQL utility: At least 1

Total functions: Minimum of 10
