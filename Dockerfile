# Stage 1: Build the PDF
FROM texlive/texlive:latest AS builder

WORKDIR /app

# Copy LaTeX file(s)
COPY ./src .

# Compile the PDF
RUN latexmk -pdf -jobname=Ashish_Kushwaha main.tex

# Stage 2: Minimal image for S3 upload
FROM amazon/aws-cli:latest

WORKDIR /app

# installing python3 and pip
RUN yum install -y python3 python3-pip
# Copy requirements before installing dependencies
COPY requirements.txt .

# Install dependencies
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy the PDF from builder
COPY --from=builder /app/Ashish_Kushwaha.pdf ./Ashish_Kushwaha.pdf

COPY entrypoint.sh ./entrypoint.sh

# COPY push_s3.sh ./push_s3.sh
COPY ingest_pc.py ./ingest_pc.py

RUN chmod +x entrypoint.sh
# RUN chmod +x push_s3.sh

ENTRYPOINT ["./entrypoint.sh"]

