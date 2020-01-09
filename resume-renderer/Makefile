all: build

build:
	docker run \
		-w /home/node \
		--mount type=bind,src=$$(pwd)/src,dst=/home/node/ \
		$$(docker build -q .) \
		sh -c "npm ci && tsc && npm pack"
