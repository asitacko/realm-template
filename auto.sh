#!/usr/bin/env bash

export PROJDIR=${PROJDIR:-`git rev-parse --show-toplevel`}
export PYTHONPATH=${PROJDIR}/dj

export PATH=${PROJDIR}/venv/bin:${PROJDIR}/.cargo/bin:$PATH

export DATABASE_URL=postgres://root@localhost/foo_db
export CARGO_HOME=".cargo";

export REALM_WATCHER_DIR="./frontend/"
export REALM_WATCHER_DOIT_CMD="doit elm"

nn() {
    echo "in_nix:" ${IN_NIX_SHELL:-nopes}
}

setup() {
    pushd2 /

    test -f venv/bin/python || python -m venv venv
    test -f venv/bin/doit || pip install -r requirements.txt
    test -f .git/hooks/pre-commit || pre-commit install
    test -d realm || gsub update
    mkdir -p .cargo;
    test -f .cargo/bin/diesel || cargo install diesel_cli --no-default-features --features postgres
    test -f .cargo/bin/aa || cargo install alert-after

    doit
    popd2
}

pushd2() {
    PUSHED=`pwd`
    cd ${PROJDIR}$1 >> /dev/null
}

popd2() {
    cd ${PUSHED:-$PROJDIR} >> /dev/null
    unset PUSHED
}

o() {
    cd ${PROJDIR}
}

ctest() {
    pushd2 /
    cargo test --all -- --test --test-threads 4 $*
    r=$?
    popd2
    return $r
}

cctest() {
    pushd2 /
    RUST_BACKTRACE=1 cargo test --all -- --test --test-threads 4 $*
    r=$?
    popd2
    return $r
}

manage() {
    pushd2 /dj
    python manage.py $*
    r=$?
    popd2
    return $r
}

migrate() {
    pushd2 /dj
    python manage.py migrate $*
    r=$?
    popd2
    return $r
}

dodo() {
    pushd2 /
    doit $*
    r=$?
    popd2
    return $r
}

recreatedb() {
    pushd2 /
    psql -U postgres -c "CREATE USER root;"
    psql -U postgres -c "ALTER USER root WITH SUPERUSER;"
    psql -c "DROP DATABASE IF EXISTS foo_db;" template1
    psql -c "CREATE DATABASE foo_db" template1
    psql -c "CREATE EXTENSION IF NOT EXISTS citext;" foo_db
    psql -c "CREATE SCHEMA test;" foo_db

    echo "    -> running django migration"
    migrate

    pg_dump foo_db --schema='public' --schema-only -f schema.sql
    # TODO: following can change column and table names too, do something better
    sed -i -e 's/public/test/g' schema.sql
    sed -i -e 's/test.citext/public.citext/g' schema.sql
    psql -d foo_db -f schema.sql  # create initial test schema

    echo "    -> updating schema.rs"
    rust_schema

    echo "    -> all done"
    popd2
}

check() {
    pushd2 /
    sh scripts/clippy.sh
    sh scripts/django-check.sh
    flake8 --ignore=E501,W503 --max-line-length=88
    black --check dj
    popd2
}

djshell() {
    manage shell_plus --ipython
}

dbshell() {
    manage dbshell
}

rust_schema() {
    pushd2 /foo_bl
    diesel print-schema > src/schema.rs
    sed -i -e 's/Citext/amitu_base::sql_types::Citext/g' src/schema.rs
    popd2
}

setup
