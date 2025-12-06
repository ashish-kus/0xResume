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

# Copy the PDF from builder
COPY --from=builder /app/Ashish_Kushwaha.pdf ./Ashish_Kushwaha.pdf

COPY entrypoint.sh ./entrypoint.sh

RUN chmod +x entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]

