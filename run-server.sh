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

# Finalize setup
chmod +x /data/bedrock_server
export LD_LIBRARY_PATH=/data

# --- ADVANCED GRACEFUL SHUTDOWN & INTERACTIVE CONSOLE LOGIC ---

# Create a named pipe for server input if it doesn't exist
PIPE="/tmp/minecraft_stdin"
rm -f "$PIPE"
mkfifo "$PIPE"

# Define the shutdown trap behavior
graceful_shutdown() {
    echo "🛑 Shutdown signal received! Sending 'stop' to Minecraft server..."
    echo "stop" > "$PIPE"
    
    wait "$SERVER_PID"
    echo "✅ Minecraft server has stopped gracefully."
    exit 0
}

# Catch container termination signals
trap 'graceful_shutdown' TERM INT

# Keep the named pipe continuously open and feed it directly into the server
# Running this background loop ensures the server listens to our pipe
tail -f "$PIPE" | /data/bedrock_server &
SERVER_PID=$!

# Forward the container's native stdin (used by docker attach) straight into our pipe
cat > "$PIPE" &
CAT_PID=$!

# Wait on the main server process to keep the container alive
wait "$SERVER_PID"