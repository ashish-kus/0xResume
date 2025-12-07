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

# Installing python3 and pip
RUN yum install -y python3 python3-pip && yum clean all

# Copy requirements before installing dependencies
COPY requirements.txt .

# Install Python dependencies
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy the PDF from builder stage
COPY --from=builder /app/Ashish_Kushwaha.pdf /app/Ashish_Kushwaha.pdf

# Copy scripts
COPY entrypoint.sh /app/entrypoint.sh
COPY ingest_pc.py /app/ingest_pc.py

# Make entrypoint executable
RUN chmod +x /app/entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]
