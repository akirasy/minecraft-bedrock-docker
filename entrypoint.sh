#!/bin/sh
set -e

# Default to 'service' if SERVER_MODE is not explicitly provided
MODE="${SERVER_MODE:-service}"

echo "========================================================="
echo " 🎮 Minecraft Bedrock Docker Bootstrap Controller"
echo " Current Selection (SERVER_MODE): $MODE"
echo "========================================================="

case "$MODE" in
    "interactive")
        echo "⚡ Launching interactive-server.sh (Direct TTY Control Mode)..."
        echo "👉 Use './console.sh' to control the engine natively."
        echo "⚠️ Note: Host shutdown traps are disabled in this mode; stop via console."
        echo "---------------------------------------------------------"
        exec /interactive-server.sh
        ;;
        
    "service")
        echo "🛡️ Launching run-server.sh (Graceful Daemon Service Mode)..."
        echo "👉 Safe system shutdowns and backups are fully enabled."
        echo "⚠️ Note: Live console attachment typing is restricted."
        echo "---------------------------------------------------------"
        exec /run-server.sh
        ;;
        
    *)
        echo "❌ Error: Unknown SERVER_MODE value: '$MODE'"
        echo "Valid choices are: 'interactive' or 'service'"
        exit 1
        ;;
esac