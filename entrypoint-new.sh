#!/bin/sh

# Exit the script as soon as any command fails
set -euo pipefail

# chown the mount to allow the elasticsearch user read and write access
sudo chown -R 1000 /esdata

# Start Elasticsearch in the background
/bin/tini -- /usr/local/bin/docker-entrypoint.sh eswrapper &

# Wait for Elasticsearch to be ready
until curl -s http://localhost:9200 > /dev/null; do
    echo 'Waiting for Elasticsearch to start...'
    sleep 5
done

# Generate and display the Kibana service token
echo "Generating Kibana service token..."
TOKEN=$(/usr/share/elasticsearch/bin/elasticsearch-service-tokens create elastic/kibana kibana-token)
echo "================================================================="
echo "KIBANA SERVICE TOKEN (copy this):"
echo "$TOKEN"
echo "================================================================="

# Wait for the Elasticsearch process
wait