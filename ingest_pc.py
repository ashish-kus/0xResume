import os
from pinecone import Pinecone, ServerlessSpec
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_openai import OpenAIEmbeddings
from PyPDF2 import PdfReader

PINECONE_API_KEY = os.getenv("PINECONE_API_KEY")
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
# INDEX_NAME = os.getenv("PINECONE_INDEX", "resume-index")
# RESUME_URL = os.environ.get("RESUME_URL", "https://ashishkus-resume.s3.ap-south-1.amazonaws.com/Ashish_Kushwaha.pdf")

INDEX_NAME = "my-resume-vector"
PDF_PATH = "./Ashish_Kushwaha.pdf"  # PDF already inside Docker container


def load_pdf_text(pdf_path):
    """Extract raw text from a PDF."""
    reader = PdfReader(pdf_path)
    text = ""
    for page in reader.pages:
        text += page.extract_text() + "\n"
    return text


def build_pinecone_vector_index():
    # Initialize Pinecone
    pc = Pinecone(api_key=PINECONE_API_KEY)

    # Create index if missing
    if INDEX_NAME not in pc.list_indexes().names():
        print(f"Creating Pinecone index: {INDEX_NAME}")
        pc.create_index(
            name=INDEX_NAME,
            dimension=1536,  # text-embedding-3-small dimension
            metric="cosine",
            spec=ServerlessSpec(cloud="aws", region="us-east-1"),
        )

    index = pc.Index(INDEX_NAME)

    # Load resume text
    if not os.path.exists(PDF_PATH):
        raise FileNotFoundError(f"PDF not found at {PDF_PATH}")

    print("Loading PDF text...")
    pdf_text = load_pdf_text(PDF_PATH)

    # Split into chunks
    print("Splitting text into chunks...")
    splitter = RecursiveCharacterTextSplitter(chunk_size=400, chunk_overlap=60)
    chunks = splitter.create_documents([pdf_text])

    print(f"Created {len(chunks)} chunks.")

    # Embeddings
    embedder = OpenAIEmbeddings(
        model="text-embedding-3-small", openai_api_key=OPENAI_API_KEY
    )

    vectors = []
    print("Generating embeddings...")

    for i, chunk in enumerate(chunks):
        embedding = embedder.embed_query(chunk.page_content)
        vectors.append(
            {
                "id": f"chunk-{i}",
                "values": embedding,
                "metadata": {"text": chunk.page_content},
            }
        )

    # Upload to Pinecone
    print("Uploading vectors to Pinecone...")
    index.upsert(vectors=vectors)

    print("Upload complete!")
    return True


if __name__ == "__main__":
    print("Starting PDF → Pinecone vector build...")
    build_pinecone_vector_index()
    print("Done")
