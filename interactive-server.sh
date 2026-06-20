#!/bin/sh
set -e

# Unpack the raw minecraft-server-zip-file if not already present
if [ ! -f /data/bedrock_server ]; then
    ZIP_FILE=$(find /source -name "bedrock-server-*.zip" | head -n 1)

    if [ -z "$ZIP_FILE" ]; then
        echo "Error: No Bedrock server zip found in source-minecraft-zip folder!"
        exit 1
    fi

    echo "Unpacking server engine from $ZIP_FILE..."
    unzip -q "$ZIP_FILE" -d /data
fi

# Sync custom configurations and folders (like shaders/resource packs) from /config
if [ -d /config ]; then
    echo "Syncing custom configuration and asset files..."

    # Copy configuration files if they exist in the config folder
    [ -f /config/server.properties ] && cp /config/server.properties /data/
    [ -f /config/allowlist.json ]     && cp /config/allowlist.json /data/
    [ -f /config/permissions.json ]   && cp /config/permissions.json /data/

    # Sync structural subdirectories like resource_packs (shaders, textures)
    if [ -d /config/resource_packs ]; then
        echo "Loading custom resource/shader packs..."
        mkdir -p /data/resource_packs
        cp -R /config/resource_packs/* /data/resource_packs/
    fi
fi

# Set file permissions and shared library variables and start server
chmod +x /data/bedrock_server
export LD_LIBRARY_PATH=/data
echo "🚀 Starting Minecraft Bedrock Server..."
exec /data/bedrock_server