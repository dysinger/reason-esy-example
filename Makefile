.PHONY: docker docker-builder docker-cross

docker: docker-esy-builder docker-builder docker-cross

# temporarily running with no-cache to test full build time
docker-opam:
	docker build --no-cache -t reason-server -t reason-server-opam .

docker-esy:
	docker build -t reason-server-esy -f Dockerfile-esy .

docker-esy-builder:
	docker build -t esy-builder -f Dockerfile-esy-builder .

# NOTE: library and executable are not readonly ('ro') because .merlin files are generated by the build and dune hasn't
# made them disableable https://github.com/ocaml/dune/issues/257
docker-builder:
	docker run \
		--entrypoint bash \
		-v `pwd`/../docker-esy:/home/opam/.esy \
		-v `pwd`/docker.json:/data/docker.json:ro \
		-v `pwd`/executable:/data/executable \
		-v `pwd`/library:/data/library \
		-v `pwd`/docker.esy.lock.json:/data/docker.esy.lock.json \
		-v `pwd`/dune:/data/dune:ro \
		-v `pwd`/dune-project:/data/dune-project:ro \
		-v `pwd`/reason-server.opam:/data/reason-server.opam:ro \
		-v `pwd`/docker-build:/data/output \
		--rm -it esy-builder \
		-c 'set +eux; esy @docker install && esy @docker build && cp `esy @docker x which ReasonServerApp.exe` /data/output/server'

docker-cross: 
	docker build -t reason-server-cross -f Dockerfile-cross .

docker-run:
	docker run --rm -it -p 8080:8080 reason-server-cross:latest

