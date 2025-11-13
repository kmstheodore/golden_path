#!/usr/bin/env bash

# Exit on error
set -o errexit

# Install dependencies
bundle install

# Build the assets
bin/rails assets:precompile
bin/rails assets:clean
