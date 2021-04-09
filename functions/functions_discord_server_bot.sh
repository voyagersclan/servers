#!/bin/bash

function getLatestServerUrl()
{
    PYTHON_SCRIPT="
import json, requests; 

version_manifest_url='https://launchermeta.mojang.com/mc/game/version_manifest.json';
version_manifest_response = requests.get(version_manifest_url); 
version_manifest_json = json.loads(version_manifest_response.text); 

latest_version_id = version_manifest_json.get('latest').get('release');

for version in version_manifest_json.get('versions'):
    if version.get('id') == latest_version_id and version.get('type') == 'release':
        version_manifest_url = version.get('url');

version_manifest_response = requests.get(version_manifest_url);
version_manifest_json = json.loads(version_manifest_response.text); 

latest_server_download_url = version_manifest_json.get('downloads').get('server').get('url')

print(latest_server_download_url)"

    SERVER_URL=$(python3 -c "$PYTHON_SCRIPT")

    echo "$SERVER_URL"
}

function getLatestServerJar()
{
    DESTINATION_FILE_PATH="$1"

    LATEST_SERVER_URL=$(getLatestServerUrl)

    curl -o "$DESTINATION_FILE_PATH" "$LATEST_SERVER_URL"
}