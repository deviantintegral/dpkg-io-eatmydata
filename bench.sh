#!/bin/bash

docker build -t emd-test:latest -f Dockerfile.warmup .

hyperfine -- \
  'docker build --no-cache -f Dockerfile .' \
  'docker build --no-cache -f Dockerfile.fsync .' \
  'docker build --no-cache -f Dockerfile.emd .'
