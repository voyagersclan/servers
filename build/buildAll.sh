#!/bin/bash

for f in build/build_*; do
    ./$f
done

docker builder prune