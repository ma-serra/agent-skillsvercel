#!/bin/bash

# Vercel Deployment Script for Codex (via claimable deploy endpoint)
# Usage: ./deploy-codex.sh [project-path]
# Returns: JSON with previewUrl, claimUrl, deploymentId, projectId

set -euo pipefail

DEPLOY_ENDPOINT="${DEPLOY_ENDPOINT:-https://codex-deploy-skills.vercel.sh/api/deploy}"

# Detect framework from package.json
detect_framework() {
    local pkg_json="$1"

    if [ ! -f "$pkg_json" ]; then
        echo "null"
        return
    fi

    has_dep_exact() {
        python3 -c "
import json, sys
try:
    pkg = json.load(open(sys.argv[1]))
    deps = {**pkg.get('dependencies', {}), **pkg.get('devDependencies', {})}
    sys.exit(0 if sys.argv[2] in deps else 1)
except: sys.exit(1)
" "$pkg_json" "$1" 2>/dev/null
    }

    has_dep_prefix() {
        python3 -c "
import json, sys
try:
    pkg = json.load(open(sys.argv[1]))
    deps = {**pkg.get('dependencies', {}), **pkg.get('devDependencies', {})}
    sys.exit(0 if any(k.startswith(sys.argv[2]) for k in deps) else 1)
except: sys.exit(1)
" "$pkg_json" "$1" 2>/dev/null
    }

    # Order matters - check more specific frameworks first

    # Blitz
    if has_dep_exact "blitz"; then echo "blitzjs"; return; fi

    # Next.js
    if has_dep_exact "next"; then echo "nextjs"; return; fi

    # Gatsby
    if has_dep_exact "gatsby"; then echo "gatsby"; return; fi

    # Remix
    if has_dep_prefix "@remix-run/"; then echo "remix"; return; fi

    # React Router (v7 framework mode)
    if has_dep_prefix "@react-router/"; then echo "react-router"; return; fi

    # TanStack Start
    if has_dep_exact "@tanstack/start"; then echo "tanstack-start"; return; fi

    # Astro
    if has_dep_exact "astro"; then echo "astro"; return; fi

    # Hydrogen (Shopify)
    if has_dep_exact "@shopify/hydrogen"; then echo "hydrogen"; return; fi

    # SvelteKit
    if has_dep_exact "@sveltejs/kit"; then echo "sveltekit-1"; return; fi

    # Svelte (standalone)
    if has_dep_exact "svelte"; then echo "svelte"; return; fi

    # Nuxt
    if has_dep_exact "nuxt"; then echo "nuxtjs"; return; fi

    # Vue with Vitepress
    if has_dep_exact "vitepress"; then echo "vitepress"; return; fi

    # Vue with Vuepress
    if has_dep_exact "vuepress"; then echo "vuepress"; return; fi

    # Gridsome
    if has_dep_exact "gridsome"; then echo "gridsome"; return; fi

    # SolidStart
    if has_dep_exact "@solidjs/start"; then echo "solidstart-1"; return; fi

    # Docusaurus
    if has_dep_exact "@docusaurus/core"; then echo "docusaurus-2"; return; fi

    # RedwoodJS
    if has_dep_prefix "@redwoodjs/"; then echo "redwoodjs"; return; fi

    # Hexo
    if has_dep_exact "hexo"; then echo "hexo"; return; fi

    # Eleventy
    if has_dep_exact "@11ty/eleventy"; then echo "eleventy"; return; fi

    # Angular / Ionic Angular
    if has_dep_exact "@ionic/angular"; then echo "ionic-angular"; return; fi
    if has_dep_exact "@angular/core"; then echo "angular"; return; fi

    # Ionic React
    if has_dep_exact "@ionic/react"; then echo "ionic-react"; return; fi

    # Create React App
    if has_dep_exact "react-scripts"; then echo "create-react-app"; return; fi

    # Ember
    if has_dep_exact "ember-cli" || has_dep_exact "ember-source"; then echo "ember"; return; fi

    # Dojo
    if has_dep_exact "@dojo/framework"; then echo "dojo"; return; fi

    # Polymer
    if has_dep_prefix "@polymer/"; then echo "polymer"; return; fi

    # Preact
    if has_dep_exact "preact"; then echo "preact"; return; fi

    # Stencil
    if has_dep_exact "@stencil/core"; then echo "stencil"; return; fi

    # UmiJS
    if has_dep_exact "umi"; then echo "umijs"; return; fi

    # Sapper (legacy Svelte)
    if has_dep_exact "sapper"; then echo "sapper"; return; fi

    # Saber
    if has_dep_exact "saber"; then echo "saber"; return; fi

    # Sanity
    if has_dep_exact "sanity"; then echo "sanity-v3"; return; fi
    if has_dep_prefix "@sanity/"; then echo "sanity"; return; fi

    # Storybook
    if has_dep_prefix "@storybook/"; then echo "storybook"; return; fi

    # NestJS
    if has_dep_exact "@nestjs/core"; then echo "nestjs"; return; fi

    # Elysia
    if has_dep_exact "elysia"; then echo "elysia"; return; fi

    # Hono
    if has_dep_exact "hono"; then echo "hono"; return; fi

    # Fastify
    if has_dep_exact "fastify"; then echo "fastify"; return; fi

    # h3
    if has_dep_exact "h3"; then echo "h3"; return; fi

    # Nitro
    if has_dep_exact "nitropack"; then echo "nitro"; return; fi

    # Express
    if has_dep_exact "express"; then echo "express"; return; fi

    # Vite (generic - check last among JS frameworks)
    if has_dep_exact "vite"; then echo "vite"; return; fi

    # Parcel
    if has_dep_exact "parcel"; then echo "parcel"; return; fi

    # No framework detected
    echo "null"
}

# Parse arguments
INPUT_PATH="${1:-.}"

TEMP_DIR=""
TARBALL=""
STAGING_DIR=""

cleanup() {
    if [ -n "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}
trap cleanup EXIT

echo "Preparing deployment..." >&2

# Check if input is a .tgz file or a directory
FRAMEWORK="null"

if [ -f "$INPUT_PATH" ] && [[ "$INPUT_PATH" == *.tgz ]]; then
    # Input is already a tarball, use it directly
    echo "Using provided tarball..." >&2
    TARBALL="$INPUT_PATH"
    # Can't detect framework from tarball, leave as null
elif [ -d "$INPUT_PATH" ]; then
    # Input is a directory, need to tar it
    TEMP_DIR=$(mktemp -d)
    TARBALL="$TEMP_DIR/project.tgz"
    STAGING_DIR="$TEMP_DIR/staging"
    PROJECT_PATH=$(cd "$INPUT_PATH" && pwd)

    # Detect framework from package.json
    FRAMEWORK=$(detect_framework "$PROJECT_PATH/package.json")

    # Stage files into a temporary directory to avoid mutating the source tree.
    mkdir -p "$STAGING_DIR"
    echo "Staging project files..." >&2
    tar -C "$PROJECT_PATH" \
        --exclude='node_modules' \
        --exclude='.git' \
        --exclude='.env' \
        --exclude='.env.*' \
        -cf - . | tar -C "$STAGING_DIR" -xf -

    # Check if this is a static HTML project (no package.json)
    if [ ! -f "$PROJECT_PATH/package.json" ]; then
        # Find HTML files in root
        HTML_FILES=$(find "$STAGING_DIR" -maxdepth 1 -name "*.html" -type f)
        HTML_COUNT=$(printf '%s\n' "$HTML_FILES" | sed '/^$/d' | wc -l | tr -d '[:space:]')

        # If there's exactly one HTML file and it's not index.html, rename it
        if [ "$HTML_COUNT" -eq 1 ]; then
            HTML_FILE=$(echo "$HTML_FILES" | head -1)
            BASENAME=$(basename "$HTML_FILE")
            if [ "$BASENAME" != "index.html" ]; then
                echo "Renaming $BASENAME to index.html..." >&2
                mv "$HTML_FILE" "$STAGING_DIR/index.html"
            fi
        fi
    fi

    # Create tarball from the staging directory
    echo "Creating deployment package..." >&2
    tar -czf "$TARBALL" -C "$STAGING_DIR" .
else
    echo "Error: Input must be a directory or a .tgz file" >&2
    exit 1
fi

if [ "$FRAMEWORK" != "null" ]; then
    echo "Detected framework: $FRAMEWORK" >&2
fi

# Deploy
echo "Deploying..." >&2
RESPONSE=$(curl -s -X POST "$DEPLOY_ENDPOINT" -F "file=@$TARBALL" -F "framework=$FRAMEWORK")

# Check for error in response
ERROR_MSG=$(echo "$RESPONSE" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('error',''))" 2>/dev/null) || true
if [ -n "$ERROR_MSG" ]; then
    echo "Error: $ERROR_MSG" >&2
    exit 1
fi

# Extract URLs from response
PREVIEW_URL=$(echo "$RESPONSE" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('previewUrl',''))" 2>/dev/null) || true
CLAIM_URL=$(echo "$RESPONSE" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('claimUrl',''))" 2>/dev/null) || true

if [ -z "$PREVIEW_URL" ]; then
    echo "Error: Could not extract preview URL from response" >&2
    echo "$RESPONSE" >&2
    exit 1
fi

echo "Deployment started. Waiting for build to complete..." >&2
echo "Preview URL: $PREVIEW_URL" >&2

# Poll the preview URL until it returns a non-5xx response (5xx = still building)
MAX_ATTEMPTS=60  # 5 minutes max (60 * 5 seconds)
ATTEMPT=0

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$PREVIEW_URL")

    if [ "$HTTP_STATUS" -eq 200 ]; then
        echo "" >&2
        echo "Deployment ready!" >&2
        break
    elif [ "$HTTP_STATUS" -ge 500 ]; then
        # 5xx means still building/deploying
        echo "Building... (attempt $((ATTEMPT + 1))/$MAX_ATTEMPTS)" >&2
        sleep 5
        ATTEMPT=$((ATTEMPT + 1))
    elif [ "$HTTP_STATUS" -ge 400 ] && [ "$HTTP_STATUS" -lt 500 ]; then
        # 4xx might be an error or the app itself returns 4xx - it's responding
        echo "" >&2
        echo "Deployment ready (returned $HTTP_STATUS)!" >&2
        break
    else
        # Any other status, assume it's ready
        echo "" >&2
        echo "Deployment ready!" >&2
        break
    fi
done

if [ $ATTEMPT -eq $MAX_ATTEMPTS ]; then
    echo "" >&2
    echo "Warning: Timed out waiting for deployment, but it may still be building." >&2
fi

echo "" >&2
echo "Preview URL: $PREVIEW_URL" >&2
echo "Claim URL:   $CLAIM_URL" >&2
echo "" >&2

# Output JSON for programmatic use
echo "$RESPONSE"
