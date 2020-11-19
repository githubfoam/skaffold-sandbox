#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace
# set -eox pipefail #safety for script

# https://skaffold.dev/docs/install/
echo "=============================deploy skaffold app============================================================="

#cleanup skaffold deployment
rm -rf skaffold

# Clone the Skaffold repository
git clone --depth 1 https://github.com/GoogleContainerTools/skaffold
# Change to the examples/getting-started in skaffold directory
cd skaffold/examples/getting-started

# Run skaffold dev to build and deploy your app
# skaffold dev
timeout 50s skaffold dev

# If you are deploying to a remote cluster, you must run skaffold dev --default-repo=<my_registry> where <my_registry> is an image registry that you have write-access to
# skaffold dev --default-repo=<my_registry>

echo "=============================deploy skaffold app============================================================="
