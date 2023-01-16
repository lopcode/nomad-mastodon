#!/usr/bin/env bash

set -eou pipefail

brew tap hashicorp/tap
brew install hashicorp/tap/nomad
brew install jq