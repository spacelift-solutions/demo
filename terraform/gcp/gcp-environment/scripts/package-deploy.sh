#!/bin/bash

# Exit on any error
set -e

# Set correct working directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Define variables
FUNCTION_NAME="scheduler.py"
REQUIREMENTS="requirements.txt"
ZIP_FILE="function.zip"

# Check if required files exist
if [ ! -f "$FUNCTION_NAME" ]; then
    echo "Error: $FUNCTION_NAME not found"
    exit 1
fi

if [ ! -f "$REQUIREMENTS" ]; then
    echo "Error: $REQUIREMENTS not found"
    exit 1
fi

echo "Packaging Cloud Function code..."

# Create zip with correct paths
zip -j "$ZIP_FILE" "$FUNCTION_NAME" "$REQUIREMENTS"

if [ $? -ne 0 ]; then
    echo "Error: Failed to create zip file"
    exit 1
fi

echo "Function code packaged successfully"