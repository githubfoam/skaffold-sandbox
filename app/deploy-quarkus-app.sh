#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace
# set -eox pipefail #safety for script

https://skaffold.dev/docs/install/
echo "=============================Quarkus - Creating Your First Application============================================================="

#create a straightforward application serving a hello endpoint. 
#  To demonstrate dependency injection, this endpoint uses a greeting bean.
# Download an archive or clone the git repository
git clone https://github.com/quarkusio/quarkus-quickstarts.git


# The solution is located in the getting-started directory
ls -lai
cd quarkus-quickstarts/getting-started

# Running the application
./mvnw compile quarkus:dev

# request the provided endpoint
curl -w "\n" http://localhost:8080/hello

# Testing
./mvnw test
