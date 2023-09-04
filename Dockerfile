FROM emd-test:latest

RUN apt update && env DEBIAN_FRONTEND=noninteractive apt-get install --yes build-essential ca-certificates libssl-dev software-properties-common wget curl git
