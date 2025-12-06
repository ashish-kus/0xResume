#!/bin/sh
set -e

PDF_NAME="Ashish_Kushwaha.pdf"
PDF_PATH="/app/output/$PDF_NAME"

echo "🔍 Checking for PDF..."

# Check if PDF exists
if [ ! -f "$PDF_PATH" ]; then
  echo "❌ Error: PDF not found at $PDF_PATH"
  exit 1
fi

echo "✅ PDF found at $PDF_PATH"

# Upload to S3 (requires environment variables)
if [ -z "$S3_BUCKET" ]; then
  echo "⚠️  Warning: S3_BUCKET environment variable not set. Skipping S3 upload."
  exit 0
fi

if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "❌ Error: AWS credentials not set"
  exit 1
fi

echo "☁️  Uploading to S3 bucket: $S3_BUCKET..."

aws s3 cp "$PDF_PATH" "s3://$S3_BUCKET/$PDF_NAME" \
  --acl public-read \
  --content-type "application/pdf" \
  --metadata "uploaded=$(date -u +%Y-%m-%dT%H:%M:%SZ)"

echo "✅ PDF uploaded successfully to s3://$S3_BUCKET/$PDF_NAME"
