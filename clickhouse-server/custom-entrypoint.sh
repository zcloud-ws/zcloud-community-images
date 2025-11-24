#!/usr/bin/env bash

# Check if CUSTOM_CONFIG environment variable is set
if [ -n "$CUSTOM_CONFIG" ]; then
    CONFIG_FILE="/etc/clickhouse-server/config.d/custom.xml"

    echo "CUSTOM_CONFIG detected, saving to $CONFIG_FILE"

    # Create the directory if it doesn't exist
    mkdir -p "$(dirname "$CONFIG_FILE")"

    # Save the custom configuration to the file
    echo "$CUSTOM_CONFIG" > "$CONFIG_FILE"

    # Validate the XML file
    if command -v xmllint &> /dev/null; then
        if xmllint --noout "$CONFIG_FILE" 2>&1; then
            echo "XML validation successful"
        else
            echo "ERROR: XML validation failed for $CONFIG_FILE"
            exit 1
        fi
    else
        echo "WARNING: xmllint not found, skipping XML validation"
    fi
else
    echo "CUSTOM_CONFIG not set, skipping custom configuration"
fi

# Start the original entrypoint
/entrypoint.sh
