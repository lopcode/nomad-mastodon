#!/usr/bin/env bash
set -eou pipefail

NOMAD_TARGET_TASK="mastodon-sidekiq"

echo "Discovering alloc of \"$NOMAD_TARGET_TASK\" to run tootctl in..."
export NOMAD_ADDR=http://localhost:4647
NOMAD_OUTPUT=$(nomad job allocs -json $NOMAD_TARGET_TASK)
SIDEKIQ_ALLOCATION_ID=$(jq --raw-output .[0].ID <<< "$NOMAD_OUTPUT")
echo "Found alloc with ID: $SIDEKIQ_ALLOCATION_ID"

echo "Executing: \"tootctl $*\""
nomad alloc exec -task sidekiq "$SIDEKIQ_ALLOCATION_ID" /bin/bash -c "tootctl $*"