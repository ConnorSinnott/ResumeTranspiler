all: build

build:
	./run.bash sh -c "npm ci && tsc"

	mkdir package
	cp src/package.json package
	cp src/index.js package
	cp src/index.d.ts package
	tar -czvf resume-renderer.tgz package
	rm -r package
