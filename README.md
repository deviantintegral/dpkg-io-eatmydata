# dpkg IO performance benchmarks with no fsync, eatmydata

[This HN comment](https://news.ycombinator.com/item?id=36937358) pointed out [`eatmydata`](https://manpages.debian.org/testing/eatmydata/eatmydata.1.en.html) as a way to improve docker build times for Debian containers. Further notes detailed how Debian images already disable some fsync calls to improve performance. So, is adding eatmydata on top worth it?

`bench.sh` requires a working docker environment and [`hyperfine`](https://github.com/sharkdp/hyperfine). It will also **prune your docker build cache**, so be aware of that if doing other work on the same docker host!

## MacBook Pro M2 Max / macOS 13 / colima / 8 cores / 16GB RAM

`eatmydata` improves apt install time by 1.17x:

```
$ caffeinate -du ./bench.sh
[+] Building 0.0s (7/7) FINISHED
 => [internal] load .dockerignore                                                                    0.0s
 => => transferring context: 2B                                                                      0.0s
 => [internal] load build definition from Dockerfile.warmup                                          0.0s
 => => transferring dockerfile: 317B                                                                 0.0s
 => [internal] load metadata for docker.io/library/debian:stable-slim                                0.0s
 => [1/3] FROM docker.io/library/debian:stable-slim                                                  0.0s
 => CACHED [2/3] RUN mv /etc/apt/apt.conf.d/docker-clean /etc/apt/docker-clean-disabled              0.0s
 => CACHED [3/3] RUN apt update && env DEBIAN_FRONTEND=noninteractive apt-get install --yes --downl  0.0s
 => exporting to image                                                                               0.0s
 => => exporting layers                                                                              0.0s
 => => writing image sha256:1f285c59007d61cb3698d534c91a1cab6ee50105c88a2c234522290cf0040836         0.0s
 => => naming to docker.io/library/emd-test:latest                                                   0.0s
Benchmark 1: docker build --no-cache -f Dockerfile .
  Time (mean ± σ):     19.259 s ±  0.159 s    [User: 0.094 s, System: 0.098 s]
  Range (min … max):   19.030 s … 19.475 s    10 runs

Benchmark 2: docker build --no-cache -f Dockerfile.fsync .
  Time (mean ± σ):     25.285 s ±  0.308 s    [User: 0.098 s, System: 0.099 s]
  Range (min … max):   24.797 s … 25.817 s    10 runs

Benchmark 3: docker build --no-cache -f Dockerfile.emd .
  Time (mean ± σ):     16.502 s ±  0.190 s    [User: 0.092 s, System: 0.093 s]
  Range (min … max):   16.186 s … 16.848 s    10 runs

Summary
  docker build --no-cache -f Dockerfile.emd . ran
    1.17 ± 0.02 times faster than docker build --no-cache -f Dockerfile .
    1.53 ± 0.03 times faster than docker build --no-cache -f Dockerfile.fsync .
```

## Linode 1 CPU Core / 1 GB RAM

`eatmydata` improves apt install time by 1.02x:

```
$ ./bench.sh
[+] Building 0.8s (7/7) FINISHED
 => [internal] load build definition from Dockerfile.warmup                                                                                              0.3s
 => => transferring dockerfile: 317B                                                                                                                     0.0s
 => [internal] load .dockerignore                                                                                                                        0.3s
 => => transferring context: 2B                                                                                                                          0.0s
 => [internal] load metadata for docker.io/library/debian:stable-slim                                                                                    0.4s
 => [1/3] FROM docker.io/library/debian:stable-slim@sha256:6fe30b9cb71d604a872557be086c74f95451fecd939d72afe3cffca3d9e60607                              0.0s
 => CACHED [2/3] RUN mv /etc/apt/apt.conf.d/docker-clean /etc/apt/docker-clean-disabled                                                                  0.0s
 => CACHED [3/3] RUN apt update && env DEBIAN_FRONTEND=noninteractive apt-get install --yes --download-only build-essential ca-certificates libssl-dev   0.0s
 => exporting to image                                                                                                                                   0.0s
 => => exporting layers                                                                                                                                  0.0s
 => => writing image sha256:f4887f99e7c3e53d1e805dc57f6cd2dc737c395673d9115ef78a1f5d0be54656                                                             0.0s
 => => naming to docker.io/library/emd-test:latest                                                                                                       0.0s
Benchmark 1: docker build --no-cache -f Dockerfile -t emd-temp:latest . && docker rmi emd-temp:latest && docker buildx prune -f
  Time (mean ± σ):     49.400 s ±  2.047 s    [User: 0.286 s, System: 0.201 s]
  Range (min … max):   45.946 s … 51.954 s    10 runs

Benchmark 2: docker build --no-cache -f Dockerfile.fsync -t emd-temp:latest . && docker rmi emd-temp:latest && docker buildx prune -f
  Time (mean ± σ):     53.075 s ±  4.533 s    [User: 0.298 s, System: 0.204 s]
  Range (min … max):   48.424 s … 59.893 s    10 runs

Benchmark 3: docker build --no-cache -f Dockerfile.emd -t emd-temp:latest . && docker rmi emd-temp:latest && docker buildx prune -f
  Time (mean ± σ):     48.263 s ±  1.668 s    [User: 0.304 s, System: 0.202 s]
  Range (min … max):   47.069 s … 52.809 s    10 runs

Summary
  docker build --no-cache -f Dockerfile.emd -t emd-temp:latest . && docker rmi emd-temp:latest && docker buildx prune -f ran
    1.02 ± 0.06 times faster than docker build --no-cache -f Dockerfile -t emd-temp:latest . && docker rmi emd-temp:latest && docker buildx prune -f
    1.10 ± 0.10 times faster than docker build --no-cache -f Dockerfile.fsync -t emd-temp:latest . && docker rmi emd-temp:latest && docker buildx prune -f
```

## Franken-NAS, 2x SSD ZFS mirror, Quad-core Intel i5-3570K, 24GB RAM, lots of other apps running

`eatmydata` improves apt install time by 1.22x:

```
$ ./bench.sh
[+] Building 1.0s (7/7) FINISHED                                                                                                               docker:default
 => [internal] load build definition from Dockerfile.warmup                                                                                              0.5s
 => => transferring dockerfile: 317B                                                                                                                     0.0s
 => [internal] load .dockerignore                                                                                                                        0.5s
 => => transferring context: 2B                                                                                                                          0.0s
 => [internal] load metadata for docker.io/library/debian:stable-slim                                                                                    0.3s
 => [1/3] FROM docker.io/library/debian:stable-slim@sha256:6fe30b9cb71d604a872557be086c74f95451fecd939d72afe3cffca3d9e60607                              0.0s
 => CACHED [2/3] RUN mv /etc/apt/apt.conf.d/docker-clean /etc/apt/docker-clean-disabled                                                                  0.0s
 => CACHED [3/3] RUN apt update && env DEBIAN_FRONTEND=noninteractive apt-get install --yes --download-only build-essential ca-certificates libssl-dev   0.0s
 => exporting to image                                                                                                                                   0.0s
 => => exporting layers                                                                                                                                  0.0s
 => => writing image sha256:22db7986cc8d4fc02cc62a60cea848dffcb8ce432d0f8379ad7af5b19f02fe97                                                             0.0s
 => => naming to docker.io/library/emd-test:latest                                                                                                       0.0s
Benchmark 1: docker build --no-cache -f Dockerfile .
  Time (mean ± σ):     57.009 s ±  1.187 s    [User: 0.312 s, System: 0.177 s]
  Range (min … max):   55.114 s … 58.467 s    10 runs

Benchmark 2: docker build --no-cache -f Dockerfile.fsync .
  Time (mean ± σ):     69.916 s ±  2.071 s    [User: 0.338 s, System: 0.178 s]
  Range (min … max):   66.856 s … 74.289 s    10 runs

Benchmark 3: docker build --no-cache -f Dockerfile.emd .
  Time (mean ± σ):     46.618 s ±  0.795 s    [User: 0.257 s, System: 0.135 s]
  Range (min … max):   44.855 s … 47.699 s    10 runs

Summary
  docker build --no-cache -f Dockerfile.emd . ran
    1.22 ± 0.03 times faster than docker build --no-cache -f Dockerfile .
    1.50 ± 0.05 times faster than docker build --no-cache -f Dockerfile.fsync .
```
