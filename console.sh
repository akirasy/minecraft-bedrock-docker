#!/bin/bash

CONTAINER_NAME="minecraft-bedrock"

# Check if the container is running first
if [ "$(docker container inspect -f '{{.State.Running}}' $CONTAINER_NAME 2>/dev/null)" != "true" ]; then
    echo "Error: Container '$CONTAINER_NAME' is not running!"
    exit 1
fi

echo "========================================================="
echo " Connecting to Bedrock Server Console..."
echo "---------------------------------------------------------"
echo " To exit SAFELY without stopping the server:"
echo " Press: Ctrl + Q"
echo "========================================================="
echo ""

# Attach to the container using the native detach keys override
docker attach --detach-keys="ctrl-q" $CONTAINER_NAME

echo ""
echo "=> Safely detached from console."
