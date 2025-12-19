#!/bin/sh
set -e

PDF_PATH="/app/Ashish_Kushwaha.pdf"
PDF_NAME="Ashish_Kushwaha.pdf"

# Upload to S3 (requires environment variables)
# Upload to S3 (requires environment variables)
if [ -n "$S3_BUCKET" ]; then
  aws s3 cp $PDF_PATH s3://$S3_BUCKET/$PDF_NAME
  echo "PDF uploaded to S3 Bucker. "
fi

# Run Pinecone ingestion
echo "Starting Pinecone ingestion..."
python3 ingest_pc.py || {
  echo "Pinecone ingestion failed"
  exit 1
}

echo "All tasks completed successfully!"
