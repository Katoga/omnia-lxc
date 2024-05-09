#!/usr/bin/env sh

set -eu

influx -execute 'CREATE DATABASE "prometheus"'
