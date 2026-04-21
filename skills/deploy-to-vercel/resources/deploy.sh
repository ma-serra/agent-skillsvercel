#!/bin/bash

# Vercel Deployment Script (via claimable deploy endpoint)
# Usage: ./deploy.sh [project-path]
# Returns: JSON with previewUrl, claimUrl, deploymentId, projectId

exec env DEPLOY_ENDPOINT="https://claude-skills-deploy.vercel.com/api/deploy" \
    bash "$(dirname "$0")/deploy-codex.sh" "$@"
