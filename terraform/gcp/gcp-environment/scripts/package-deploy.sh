#!/bin/bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Define variables
FUNCTION_NAME="scheduler.py"
REQUIREMENTS="requirements.txt"

# Check if required files exist
if [ ! -f "$FUNCTION_NAME" ]; then
    echo "Error: $FUNCTION_NAME not found"
    exit 1
fi

if [ ! -f "$REQUIREMENTS" ]; then
    echo "Error: $REQUIREMENTS not found"
    exit 1
fi

echo "All required files present for Cloud Function"