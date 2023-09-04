# dpkg IO performance benchmarks with no fsync, eatmydata

[This HN comment](https://news.ycombinator.com/item?id=36937358) pointed out eatmydata as a way to improve docker build times for Debian containers. Further notes detailed how Debian images already disable some fsync calls to improve performance. So, is adding eatmydata on top worth it?

`bench.sh` requires a working docker environment and hyperfine.

## MacBook Pro M2 Max / macOS 13 / colima / 8 cores / 16GB RAM

`eatmydata` improves apt install time by 1.17x:

```
caffeinate -du ./bench.sh
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
