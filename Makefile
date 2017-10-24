


IMAGE = docker-micall

default: help

# NOTE: this code taken from https://gist.github.com/rcmachado/af3db315e31383502660
help: 
	$(info Available targets:)
	@awk '/^[a-zA-Z\-\_0-9]+:/ {                                   \
          nb = sub( /^## /, "", helpMsg );                             \
          if(nb == 0) {                                                \
            helpMsg = $$0;                                             \
            nb = sub( /^[^:]*:.* ## /, "", helpMsg );                  \
          }                                                            \
          if (nb)                                                      \
            printf "\033[1;31m%-" width "s\033[0m %s\n", $$1, helpMsg; \
        }                                                              \
        { helpMsg = $$0 }'                                             \
        width=$$(grep -o '^[a-zA-Z_0-9]\+:' $(MAKEFILE_LIST) | wc -L)  \
	$(MAKEFILE_LIST)

build: ## build the docker-micall image from the provided docker file
	docker build -t ${IMAGE} .

save: ## save the docker-micall image to a file 'docker-micall-image.tar'
	docker save ${IMAGE} > ${IMAGE}-image.tar
runtest: ## run the docker-micall image and run its hello-world.sh script
	docker run --rm -it ${IMAGE}
run: ## run the beast1.8.4 image interactively
	docker run --rm -it ${IMAGE} bash
