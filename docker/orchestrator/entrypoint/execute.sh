#!/bin/bash

set -e

echo "New execution run started: $(date)"

# Execute a POST to given URL to start the execution.
echo "Start pipeline"
curl -X POST "$FRONTEND_URL/api/v1/executions?pipeline=$PIPELINE_URL"
