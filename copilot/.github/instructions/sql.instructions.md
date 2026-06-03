---
applyTo: "**/*.sql"
---

# SQL Instructions

## Goose Migrations

SQL files in `ext/db/` are [goose](https://github.com/pressly/goose) migration files. Every
migration must satisfy all of the following:

- **File naming**: zero-padded sequential number followed by a short `snake_case` description
  — e.g., `00001_outbox.sql`, `00002_psm.sql`. Follow the existing numeric width used in the
  service (some use 4 digits, some 5 or 6).
- **Required sections**: every file must have both a `-- +goose Up` and a `-- +goose Down`
  section, in that order, separated by a blank line.
- **Multi-statement blocks**: PL/pgSQL functions, triggers, and any `DO $$` block that spans
  multiple statements must be wrapped with `-- +goose StatementBegin` / `-- +goose StatementEnd`.
  Plain DDL statements (single `CREATE TABLE`, `ALTER TABLE`, etc.) do not need this wrapper.
- **Irreversible Down sections**: if a migration cannot be safely rolled back (e.g., a data
  backfill, a destructive drop, or a transformation with no inverse), write `-- cannot roll back`
  as the entire body of the `-- +goose Down` section rather than omitting the section or leaving
  it empty.
- **Ordering and immutability**: migrations are append-only. Never modify or renumber an existing
  migration once it has been applied to any environment. Add a new migration to fix or extend
  previous ones.

### Example skeleton

```sql
-- +goose Up

CREATE TABLE foo (
  foo_id char(22),
  CONSTRAINT foo_pk PRIMARY KEY (foo_id)
);

-- +goose Down

DROP TABLE foo;
```

### Example with StatementBegin

```sql
-- +goose Up

-- +goose StatementBegin
CREATE OR REPLACE FUNCTION outbox_notify() RETURNS trigger AS $$
BEGIN
  PERFORM pg_notify('outbox', NEW.id::text);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- +goose StatementEnd

CREATE TRIGGER outbox_notify_trigger
  AFTER INSERT ON outbox
  FOR EACH ROW EXECUTE FUNCTION outbox_notify();

-- +goose Down

DROP TRIGGER outbox_notify_trigger ON outbox;
DROP FUNCTION outbox_notify();
```

## Schema Conventions

### Naming

- Table and column names are `snake_case`.
- Primary key constraint: `<table>_pk`
- Foreign key constraint: `<table>_fk_<referenced_table_or_column>`
- Unique constraint: `<table>_uq_<columns>` (join multiple columns with `_`)
- Index names follow the same snake_case convention; generated tsvector indexes use a suffix that
  matches the column name.

### Column Types

- **All timestamps** use `timestamptz` (i.e., `timestamp with time zone`). Never use bare
  `timestamp` without a time zone.
- **Structured / semi-structured data** uses `jsonb NOT NULL`. Avoid nullable `jsonb` columns;
  prefer an empty object `'{}'::jsonb` default when no value is present.
- **Primary and foreign key IDs** use `char(22)` for platform entity IDs (base-62 encoded), or
  `uuid` for event/log IDs.
- **Full-text search columns** are `tsvector GENERATED ALWAYS AS (...) STORED`. Never write to
  these columns directly.

### DDL Hygiene

- Wrap related DDL (a table plus its constraints and indexes) together without blank lines between
  logically coupled statements.
- Always define constraints inline with `CONSTRAINT <name> ...` — do not use unnamed constraints.
- Prefer `ALTER TABLE ... ADD COLUMN IF NOT EXISTS` when adding columns to a table that may
  already exist in some environments.
- Prefer `CREATE INDEX IF NOT EXISTS` when adding indexes.

## Safety

- **Never run SQL directly against a live or production database.** If production data is needed
  for local testing or investigation, restore a snapshot or dump of that database to a local
  instance first and run all queries and tests against the local copy.
- Wrap destructive or multi-step DDL in explicit transactions (`BEGIN` / `COMMIT`) when running
  ad-hoc. Goose handles transactions for migration files automatically.
- `DROP TABLE`, `DROP COLUMN`, and other destructive DDL belong only in migration files under
  source control — never in ad-hoc scripts applied directly to any environment.

## Backfill Migrations

Migrations that backfill or transform existing data require additional care:

- Add a comment block at the top of the `-- +goose Up` section explaining what data is being
  modified, why the backfill is needed, and what the expected impact is.
- Backfills on large tables should use batched `UPDATE` statements or a `DO $$ BEGIN ... END $$`
  loop with explicit batch sizing to avoid long-running locks.
- The `-- +goose Down` section must contain `-- cannot roll back` with a brief explanation of
  why the transformation is not reversible.
