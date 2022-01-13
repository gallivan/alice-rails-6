#!/usr/bin/env bash
dropdb -U postgres quickfix
createdb -U postgres quickfix
psql -U postgres -d quickfix -f postgresql.sql
