---
name: local-db
description: 'Manages local PostgreSQL database instances running in Docker for development and testing. Use when asked to "start my database", "refresh the database", "spin up a test database", "load a dump", "stop the database", "what databases are running", or when another skill needs a ready database instance. Handles the default persistent-ish instance and ephemeral test instances seeded from dump files.'
lastReviewed: "2026-07-31"
---

# Local DB Skill

<Purpose>
Manage local PostgreSQL instances in Docker for development and testing. Covers the long-lived
default instance and short-lived ephemeral instances seeded from dump files for parallel test
scenarios.
</Purpose>

<Constraints>
- **Image**: Always use `postgres:17-alpine`. Major version `17` is pinned — do not change it
  without explicit user instruction. See `<VersionUpdate>` for the upgrade procedure.
- **No volumes**: Never mount a Docker volume on any instance managed by this skill. All data is
  ephemeral and dies with the container. This is intentional — it prevents stale state from
  persisting across restarts.
- **Default credentials**: `POSTGRES_USER=test`, `POSTGRES_PASSWORD=test`, `POSTGRES_DB=test`.
  Use these for all instances unless the caller explicitly overrides them.
- **Do not start a new instance if one already satisfies the need.** Check running containers
  first. Prefer the default `database` instance for anything that does not require isolated seed
  data or strict parallelism.
- **Never prompt to persist data.** Do not suggest volumes or bind mounts. The ephemeral nature
  is a design requirement, not an oversight.
</Constraints>

<Defaults>
| Setting | Value |
|---------|-------|
| Image | `postgres:17-alpine` |
| Container name | `database` |
| Host port | `5432` |
| User | `test` |
| Password | `test` |
| Database | `test` |
| DSN | `postgres://test:test@localhost:5432/test` |
</Defaults>

<TriggerPhrases>
- User asks to start, stop, refresh, or restart the database
- User asks to spin up a test database or load a dump file
- User wants to know what database instances are running
- Another skill needs a ready database instance (see `<ForCallingSkills>`)
- User asks to drop into a psql session
- User asks to update the Postgres version
</TriggerPhrases>

<Workflow>
<StartDefault>
**Start the default instance**

Check if the `database` container is already running before doing anything:

```bash
docker ps --filter "name=^database$" --format "{{.Names}}"
```

- If running: report the status and DSN — do nothing else.
- If stopped (exists but not running): `docker start database`
- If not found: create and start it:

```bash
docker run -d \
  --name database \
  -p 5432:5432 \
  -e POSTGRES_USER=test \
  -e POSTGRES_PASSWORD=test \
  -e POSTGRES_DB=test \
  postgres:17-alpine
```

After starting, wait for readiness (see `<HealthCheck>`), then print the DSN.
</StartDefault>

<StopDefault>
**Stop and remove the default instance**

```bash
docker stop database && docker rm database
```

Confirm the container is gone. Do not attempt to stop if it isn't running — check first and
report its state.
</StopDefault>

<Refresh>
**Refresh/cycle the default instance**

Stop, remove, and immediately restart:

```bash
docker stop database && docker rm database
```

Then follow `<StartDefault>` to recreate it. This guarantees a clean slate. Report the new DSN
when ready.
</Refresh>

<StartEphemeral>
**Start an ephemeral test instance**

Use when a caller needs an isolated instance — typically for parallel tests or a specific seed
dataset. Parameters:

| Parameter | Default | Notes |
|-----------|---------|-------|
| `name` | see naming below | Container name |
| `port` | caller-provided | Required; must not conflict with running containers |
| `user` | `test` | |
| `password` | `test` | |
| `db` | `test` | |
| `dump` | none | Path to a `.sql` or `.dump` file to restore after startup |

**Name resolution** (apply in order, use first that produces a clean, short identifier):
1. Explicit name provided by the caller
2. Inferred purpose from the caller's context (e.g., `database-accounts`, `database-orders`)
3. Stem of the dump filename, lowercased with hyphens (e.g., `prod-accounts-2026.dump` → `database-accounts-2026`)
4. Port (e.g., `database-5433`)

**Check for conflicts** before starting:
```bash
docker ps -a --filter "name=^<name>$" --format "{{.Names}}"
docker ps --format "{{.Ports}}" | grep "0.0.0.0:<port>->"
```

If the name or port is already in use, surface the conflict and ask how to proceed.

**Start the container:**
```bash
docker run -d \
  --name <name> \
  -p <port>:5432 \
  -e POSTGRES_USER=<user> \
  -e POSTGRES_PASSWORD=<password> \
  -e POSTGRES_DB=<db> \
  postgres:17-alpine
```

After readiness (see `<HealthCheck>`), load the dump file if one was provided (see `<LoadDump>`).

Report the container name and DSN when ready.
</StartEphemeral>

<HealthCheck>
**Wait for the instance to be ready**

Poll `pg_isready` until Postgres accepts connections. Do not declare the instance "ready" until
this succeeds:

```bash
until docker exec <name> pg_isready -U test -q; do sleep 0.5; done
```

Time out after 30 seconds and report failure if the container never becomes healthy.
</HealthCheck>

<LoadDump>
**Load a dump file into a running instance**

Determine the dump format from the file extension or by running `file <path>`:

- `.sql` or plain text → restore with `psql`:
  ```bash
  psql postgres://<user>:<password>@localhost:<port>/<db> < <dump-file>
  ```
- `.dump` or custom-format → restore with `pg_restore`:
  ```bash
  pg_restore -d postgres://<user>:<password>@localhost:<port>/<db> \
    --no-owner --no-privileges <dump-file>
  ```

The instance is not "ready" until the restore command exits with code `0`. Report any restore
errors verbatim — do not silently ignore them.
</LoadDump>

<StopInstance>
**Stop and remove any named instance**

```bash
docker stop <name> && docker rm <name>
```

Verify the container is gone after removal. If the container doesn't exist, report that and exit
cleanly.
</StopInstance>

<ListInstances>
**List all running database instances managed by this skill**

```bash
docker ps --filter "name=database" --format "table {{.Names}}\t{{.Ports}}\t{{.Status}}"
```

Print the name, host port (extracted from the port mapping), and status. Include the DSN for
each instance.
</ListInstances>

<PsqlSession>
**Drop into an interactive psql session**

Against the default instance:
```bash
docker exec -it database psql -U test -d test
```

Against a named instance (user specifies the name):
```bash
docker exec -it <name> psql -U <user> -d <db>
```
</PsqlSession>
</Workflow>

<ForCallingSkills>
When another skill needs a database, apply this decision tree:

1. **Does the caller need a specific dump loaded or strict isolation?** → Use `<StartEphemeral>`
   on a non-conflicting port. The caller is responsible for cleanup via `<StopInstance>`.
2. **Otherwise** → Start or confirm the default `database` instance via `<StartDefault>` and
   return `postgres://test:test@localhost:5432/test`.

Never spin up a new container when the default instance satisfies the need. The default instance
is expected to be long-lived; tests are expected to clean up their own data between runs.

**What to hand back to the calling skill:**
- Container name
- DSN string (`postgres://<user>:<password>@localhost:<port>/<db>`)
- Whether the instance was freshly created or already running
</ForCallingSkills>

<VersionUpdate>
The image is pinned to `postgres:17-alpine`. To update the major version:

1. User must explicitly request the upgrade (e.g., "upgrade postgres to 18")
2. Update the image tag in this `SKILL.md` in every place it appears (search for `17-alpine`)
3. Stop and remove the current `database` container — old data is ephemeral, so this is safe
4. The next `<StartDefault>` call will pull the new image
5. Tell the user to commit the change to `~/dotfiles` and run `skills-sync`

**Never** change the major version automatically or as a side effect of any other operation.
</VersionUpdate>

<UpdateProtocol>
If at any point the user says something like:
- "always use X credential default"
- "change the default port"
- "add support for Y database engine"
- "the default container should be named Z"

**Do not update `SKILL.md` immediately.** Instead:

1. Acknowledge the suggestion
2. Propose the exact change: show what it would look like in `SKILL.md`
3. Note whether it affects `<Defaults>`, `<Constraints>`, or both
4. Wait for explicit confirmation before modifying
5. After confirmation, update `SKILL.md` at `~/dotfiles/copilot/skills/local-db/SKILL.md`
6. Tell the user to commit the change to `~/dotfiles` and run `skills-sync` to persist it
</UpdateProtocol>
