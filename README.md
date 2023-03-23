# crystal-db-concurrency-showcase

Reproducing an issue with multiple concurrent queries to a database as described in:
- [forum.crystal-lang.org theme 5482](https://forum.crystal-lang.org/t/concurrency-issues-with-an-api-server/5482)

## Prerequisites

- [Crystal](crystal-lang.org) (known to work with v.1.7)
- [Postgres](https://www.postgresql.org/) server (known to work with v.14.7)
- Optional: [MySQL](https://www.mysql.com/) server (known to work with MariaDB v.10.6)
- GNU make

## Setup

### TL;DR

```
make deps
make dotenv

# Now:
#  1. Tune your `.env` and `.env.test` files;
#  2. Create a database on Postgres (optionally, on MySQL).

make spec # optional sanity check
make
make db-seed
```

### 1. Install the dependencies

```
make deps
```

### 2. Create and tune `.env*` files

Create a `.env` (will also create a `.env.test`):
```
make dotenv
```
Tune the `SHOWCASE_DB_URI` variable in `.env` and `.env.test` to suite your environment.

Supported backends:
- _Postgres_ -- the default;
- _MySQL_ -- optional;
- _SQLite_.

### 3. Create databases

For running on _Postgres_ or _MySQL_, you need to create the development database (and
optionally, the test database for running the specs).

**Postgres:**

On Debian-based Linux OS this should do it:
```
sudo -iu postgres
psql
# The Postgres prompt (postgres=#) should be seen
create database showcase_development;
create database showcase_test;
exit
exit
```

**MySQL:**

On Debian-based Linux OS this should do it:
```
mysql -u <dbuser> -p
> create database showcase_development;
> create database showcase_test;
> exit
```

`<dbuser>` is a MySQL user having the CREATE privilege (e.g. `root`).

**SQLite:**

No need to do anything, the database files would appear in `./db/` automatically. To drop a
database, just delete the corresponding file.

### 4. Run the specs
This step is optional.

Doublecheck your `.env.test` settings. If you want to run the specs against more than one
backend, you need to execute this step more than once, each time tuning you `.env.test` to
point to a different database backend.

Run the specs:
```
make spec
```

### 5. Build the binaries
```
make
```

There are two binaries needed; this is going to build both:

- `bin/seed-tool` -- used to seed the database;
- `bin/showcase` -- the showcase app sending multiple concurrent requests to the database.

They both have a help screen shown with `-h`.

### 6. Seed the database

Doublecheck your `.env` settings. If you want to run the specs against more than one backend,
you need to execute this step more than once, each time tuning you `.env.test` to point to a
different database backend.

On decent hardware seeding takes:
- ~3 min for Postgres;
- ~2 min for MySQL/MariaDB;
- ~15 min for SQLite;

To do the seeding:
```
make db-seed
```

## Run the showcase app

You should have completed the Setup procedure explained above to run the showcase app. Doublecheck
your `.env` file.

Running the showcase app against a Postgres db backend prepared as explained above should reveal
the issue with the linearly growing query round trip times. A hundred concurrent queries should
demonstrate it:

```
bin/showcase -c100 # 100 almost simultaneous queries
```

The available options are explained in the help page:

```
bin/showcase -h
```

### Review the output

The issue we want to resolve is described [here](https://forum.crystal-lang.org/t/concurrency-issues-with-an-api-server/5482).

For Postgres, a typical 100 queries run would look like
```
I: Spawning 100 requests...
I: Received 1 (idx=46) team_id=1 size=44000 time=0.3s
I: Received 2 (idx=84) team_id=2 size=33000 time=0.32s
I: Received 3 (idx=87) team_id=3 size=33000 time=0.34s
.
.
I: Received 98 (idx=3) team_id=2 size=33000 time=6.47s
I: Received 99 (idx=39) team_id=3 size=33000 time=6.54s
I: Received 100 (idx=23) team_id=1 size=44000 time=6.63s
I: Total time: 7.7s
```

Sometimes fibers seem to get lost and the routine collecting the results hangs while waiting
for all of them to come back:
```
.
.
I: Received 96 (idx=38) team_id=1 size=44000 time=5.93s
I: Received 97 (idx=85) team_id=1 size=44000 time=6.01s
I: Received 98 (idx=11) team_id=3 size=33000 time=6.84s
[hanging here...]
```
and you need to interrupt this with `<Ctrl-C>`.

The same run against the SQLite backend would look different:

```
.
.
I: Received 98 (idx=99) team_id=3 size=33000 time=0.03s
I: Received 99 (idx=70) team_id=3 size=33000 time=0.03s
I: Received 100 (idx=59) team_id=2 size=33000 time=0.03s
I: Total time: 3.0s
```
The times per query processing do not grow and all fibers eventually come back.

Experiment show that on MySQL the times grow similarly to the Postgres backend and often some
fibers get lost as well.

## Development

Changes helping solve the issue are more than welcome, see "Contributing".

## Contributing

1. Fork it (<https://github.com/dext/crystal-db-concurrency-showcase/fork>);
2. Create your feature branch -- `git checkout -b my-change`
3. Commit your changes -- `git commit -am 'Add the change'`
4. Push to the branch -- `git push origin my-change`
5. Create a new Pull Request.

## Contact us

- yassen.damyanov -AT- dext.com
