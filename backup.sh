#!/bin/bash
set -e

CONTAINER_NAME="minecraft-bedrock"
BACKUP_DIR="./backup"
DATA_DIR="./data"

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

# Check if the container is actually running
if [ "$(docker container inspect -f '{{.State.Running}}' $CONTAINER_NAME 2>/dev/null)" != "true" ]; then
    echo "Server is not running. Performing a cold copy of the world files..."
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    BACKUP_FILE="$BACKUP_DIR/bedrock_world_backup_$TIMESTAMP.tar.gz"
    
    tar -czf "$BACKUP_FILE" -C "$DATA_DIR" worlds
    echo "✅ Cold backup completed successfully: $BACKUP_FILE"
    exit 0
fi

echo "🔄 Initiating safe live backup sequence..."

# Safely inject the 'save hold' command into the active server container's main stdin channel
echo "save hold" | docker exec -i $CONTAINER_NAME tee /proc/1/fd/0 > /dev/null
sleep 2

# Create the timestamped archive of the worlds directory
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/bedrock_world_backup_$TIMESTAMP.tar.gz"

echo "📦 Archiving world data..."
tar -czf "$BACKUP_FILE" -C "$DATA_DIR" worlds

# Inject the 'save resume' command to unlock disk operations
echo "save resume" | docker exec -i $CONTAINER_NAME tee /proc/1/fd/0 > /dev/null
echo "✅ Hot backup completed successfully: $BACKUP_FILE"