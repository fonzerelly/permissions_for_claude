#!/bin/bash

for permission in "$@"; do
    visudo -c -f "/app/permissions/$permission" || exit 1
done
