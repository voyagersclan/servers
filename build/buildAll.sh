#!/bin/bash

docker system prune --force

for f in build/build_*; do
    ./$f
done