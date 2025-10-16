#!/bin/bash
set -e

# Deploy Airbyte Frontend to Firebase Hosting
# This script builds the frontend and deploys to Firebase

ENV=${1:-stage}
PROJECT_ROOT="/Users/philliploacker/Documents/GitHub/airbyte-platform"

echo "🚀 Deploying Airbyte Frontend to Firebase ($ENV environment)"

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not installed. Installing..."
    npm install -g firebase-tools
fi

# Navigate to webapp directory
cd "$PROJECT_ROOT/airbyte-webapp"

# Install dependencies
echo "📦 Installing dependencies..."
pnpm install --engine-strict=false

# Build for production
echo "🔨 Building frontend for $ENV..."
export NODE_ENV=production
pnpm build --mode $ENV

# Deploy to Firebase
echo "🚢 Deploying to Firebase Hosting..."
cd ../
firebase deploy --only hosting:$ENV

echo "✅ Frontend deployed successfully!"

