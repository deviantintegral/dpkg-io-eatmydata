#!/bin/bash

# Create an image with downloads committed so we aren't benchmarking the
# network connection.
docker build -t emd-test:latest -f Dockerfile.warmup .

hyperfine -- \
  'docker build --no-cache -f Dockerfile -t emd-temp:latest . && docker rmi emd-temp:latest' \
  'docker build --no-cache -f Dockerfile.fsync -t emd-temp:latest . && docker rmi emd-temp:latest' \
  'docker build --no-cache -f Dockerfile.emd -t emd-temp:latest . && docker rmi emd-temp:latest'
