#!/bin/bash

docker run -it --name kingpin-runner --rm \
    --network public-kingpin \
    --volume $PWD/local:/local:ro \
    --env NOMAD_ADDR=http://nomad-server:4646 \
    kingpin-runner:1.0.0 \
    nomad $@
