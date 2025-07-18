#!/bin/bash

if [ ! -d "$DATA_DIR/$NAME" ]; then
  echo "Creating new database."
  cp /opt/virtuoso-opensource/database
fi
