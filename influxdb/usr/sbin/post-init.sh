#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# configure Prometheus storage
influx -host localhost -port 8086 -execute 'CREATE DATABASE "prometheus"'
