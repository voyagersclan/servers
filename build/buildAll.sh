for f in build/build_*; do
    ./$f
done

docker system prune --force
docker system prune --volumes --force