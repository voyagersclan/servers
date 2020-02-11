for f in build/build_*; do
    sh $f
done

docker system prune --force
docker system prune --volumes --force