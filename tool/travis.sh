#!/bin/bash

# Fast fail the script on failures
set -e

# Run the tests
echo "Running tests..."
pub run test