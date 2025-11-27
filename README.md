CS340 Project Specifications
This document outlines the requirements for your final database project submission.

Database Requirements
The database must be pre-populated with sample data.

Include at least 3 rows per table.

Sample data should illustrate table functionality, especially for many-to-many (M:M) relationships.

The schema must include:

At least 4 entities

At least 4 relationships, with at least one M:M relationship

Web Interface Guidelines
The interface is admin-facing only.

No login, sessions, registration, password, or shopping cart features are required.

If 4 entities are implemented as 5 tables, expect roughly 5 web app pages.

A single page may be used for M:M relationships between 2 tables.

Optionally, a home page may be added.

Query Requirements
Each table must be used in at least one SELECT query.

SELECT queries should display table contents.

Do not join all tables in one query.

Stored Procedures & SQL Injection Prevention
Use stored procedures for:

INSERT

DELETE

UPDATE

These procedures help prevent SQL injection.

CUD Functionality (Create, Update, Delete)
Your site must implement:

INSERT, UPDATE, and DELETE for at least one entity

Preferably within a M:M relationship

CUD operations may be:

Distributed across multiple entity pages

Combined on a single page

Key Selection UX
User IDs should not be entered manually

Use drop-down lists or search text for foreign key selection

Examples
INSERT: Add Products to OrderItems (intersection table between Products and Orders)

DELETE: Remove a record from M:M without affecting related tables

e.g., delete Orders made by a Customer

Can be done by setting CustomerID to NULL or deleting associated Orders

Reference: MySQL CASCADE

UPDATE: Change a foreign key in an intersection table

e.g., update ProductID in OrderItems

DDL Script & Reset Functionality
Create the database using a DDL script

Covered in Modules 3, 4, and 5

Changes should be reversible using a RESET function
