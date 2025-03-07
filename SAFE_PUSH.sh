#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "❌ .env file not found! Please create it with GITHUB_TOKEN."
    exit 1
fi

# Define variables
GITHUB_REPO="M-Umar-949/MLOPS-CICD"
GITHUB_BRANCH=$(git rev-parse --abbrev-ref HEAD)
WORKFLOW_NAME="Flake8 Linting on dev push"
MAX_RETRIES=20
SLEEP_INTERVAL=10

# Ensure GITHUB_TOKEN is set
if [[ -z "$GITHUB_TOKEN" ]]; then
    echo "❌ GITHUB_TOKEN is missing! Check your .env file ."
    exit 1
fi

# Trigger GitHub Actions Workflow
echo "🚀 Triggering GitHub Actions workflow for branch: $GITHUB_BRANCH"

response=$(curl -X POST -H "Authorization: token $GITHUB_TOKEN" \
     -H "Accept: application/vnd.github.v3+json" \
     https://api.github.com/repos/$GITHUB_REPO/actions/workflows/$WORKFLOW_NAME/dispatches \
     -d "{\"ref\":\"$GITHUB_BRANCH\"}")

# Check if workflow dispatch was successful
if [[ $? -ne 0 ]]; then
    echo "❌ Failed to trigger workflow."
    exit 1
fi

# Poll for job status
echo "⏳ Waiting for GitHub Actions job to complete..."
for ((i=1; i<=MAX_RETRIES; i++))
do
    status=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        https://api.github.com/repos/$GITHUB_REPO/actions/runs | jq -r '.workflow_runs[0].conclusion')

    echo "🔍 Job Status: $status"

    if [[ "$status" == "success" ]]; then
        echo "✅ Flake8 passed! Proceeding with git push..."
        git push
        exit 0
    elif [[ "$status" == "failure" || "$status" == "cancelled" ]]; then
        echo "❌ Flake8 failed! Push aborted. "
        exit 1
    fi

    echo "⏳ Waiting for GitHub Actions to complete... ($i/$MAX_RETRIES)"
    sleep $SLEEP_INTERVAL
done

echo "⏰ Timeout reached. Push aborted."
exit 1
