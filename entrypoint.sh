#!/bin/sh
set -e

PDF_PATH="/app/Ashish_Kushwaha.pdf"
PDF_NAME="Ashish_Kushwaha.pdf"

# Upload to S3 (requires environment variables)
if [ -n "$S3_BUCKET" ]; then
  echo "Uploading PDF to S3 bucket: $S3_BUCKET"
  aws s3 cp "$PDF_PATH" "s3://$S3_BUCKET/$PDF_NAME" \
    --acl public-read \
    --content-type "application/pdf"
  echo "PDF uploaded to S3 bucket successfully."
else
  echo "Warning: S3_BUCKET not set. Skipping S3 upload."
fi

# Run Pinecone ingestion
echo "Starting Pinecone ingestion..."
python3 ingest_pc.py || {
  echo "Pinecone ingestion failed"
  exit 1
}

echo "All tasks completed successfully!"
