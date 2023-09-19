#/bin/bash

# first-stage build
echo "first-stage building..."

# build infra container
container=$(buildah from --pull-never docker.io/library/golang:1.21.0)

# set metadata
buildah config --label stage=gobuilder $container
buildah config --author "shyunn" $container

# set env
buildah config --env TZ=Asia/Shanghai $container
buildah config --env CGO_ENABLED=0 $container
buildah config --env GOPROXY=https://goproxy.cn,direct $container

# set working dir
buildah config --workingdir /build $container

# set expose
buildah config --port=4000 $container

# set command
buildah run $container ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# copy file
buildah copy $container . .

# build binary
buildah run $container go mod download
buildah run $container go build -ldflags="-s -w" -o /app/main .



# second-stage build
echo "second-stage building..."

# you can also use mount/unmount do multi-stage build
# this using copy-from container do multi-stage build
image=$(buildah from scratch)

buildah copy --from $container $image /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
buildah copy --from $container $image /usr/share/zoneinfo/Asia/Shanghai /usr/share/zoneinfo/Asia/Shanghai
buildah config --env TZ=Asia/Shanghai $image

buildah config --workingdir /app $image
buildah copy --from $container $image /app/main /app/main

buildah config --cmd '["./main"]' $image

# commit become image(--rm: clear infra container)
buildah commit --rm $image shyunn.io/app:0.2
buildah rm $container


