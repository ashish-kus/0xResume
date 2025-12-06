#!/bin/sh
set -e

PDF_NAME="Ashish_Kushwaha.pdf"

# Upload to S3 (requires environment variables)
if [ -n "$S3_BUCKET" ]; then
  aws s3 cp $PDF_NAME s3://$S3_BUCKET/$PDF_NAME
  echo "PDF uploaded to S3 Bucker. "
fi

python ingest_pc.py || {
  echo "Pinecone ingestion failed"
  exit 1
}
