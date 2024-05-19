#!/usr/bin/env python3

import argparse
import collector
import logging
import prometheus_client
import time

if __name__ == '__main__':
  parser = argparse.ArgumentParser()

  parser.add_argument(
    'listen_port',
    help = 'Port on which to listen to requests.',
    type = int,
    default = 51423,
  )

  group = parser.add_mutually_exclusive_group()
  group.add_argument("-v", "--verbose", action = "store_true")
  group.add_argument("-q", "--quiet", action = "store_true")

  args = parser.parse_args()

  log_level = logging.INFO
  if args.quiet:
    log_level = logging.WARNING
  elif args.verbose:
    log_level = logging.DEBUG

  logging.basicConfig(
    format = '%(asctime)s | %(levelname)s | %(name)s | %(message)s',
    datefmt = '%Y-%m-%dT%H:%M:%S%z',
  )

  logger = logging.getLogger('librespeed')
  logger.setLevel(log_level)

  logger.info('Listening on port {}'.format(args.listen_port))
  prometheus_client.start_http_server(args.listen_port)

  logger.debug('Initing collector')
  collector = collector.LibrespeedCollector(logger)

  logger.debug('Registering collector')
  prometheus_client.REGISTRY.register(collector)

  while True:
    time.sleep(1)
