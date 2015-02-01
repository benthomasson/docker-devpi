#!/bin/bash

function defaults {
    : ${DEVPI_SERVERDIR="/data/server"}
    : ${DEVPI_CLIENTDIR="/data/client"}

    echo "DEVPI_SERVERDIR is ${DEVPI_SERVERDIR}"
    echo "DEVPI_CLIENTDIR is ${DEVPI_CLIENTDIR}"

    export DEVPI_SERVERDIR DEVPI_CLIENTDIR
}

function initialise_devpi {
    echo "[RUN]: Initialise devpi-server"
    devpi-server --start --host 127.0.0.1 --port 3141
    devpi-server --status
    devpi use http://localhost:3141
    devpi login root --password=''
    devpi user -m root password="${DEVPI_PASSWORD}"
    devpi index -y -c public pypi_whitelist='*'
    devpi-server --stop
    devpi-server --status
}


if [ "$1" = 'devpi' ]; then
    [[ -f $DEVPI_SERVERDIR/.serverversion ]] || initialize=yes

    defaults

    if [[ $initialize = yes ]]; then
        initialise_devpi
    fi

    echo "[RUN]: Launching devpi-server"
    devpi-server --host 0.0.0.0 --port 3141 2>&1 | tee /data/server/devpi.log
    exit $?
fi

echo "[RUN]: Builtin command not provided [devpi]"
echo "[RUN]: $@"

exec "$@"