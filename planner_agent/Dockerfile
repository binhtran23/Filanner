FROM python:3.10.12-slim

WORKDIR /planner_agent

# Install system dependencies
RUN apt-get update && apt-get install -y \
    postgresql-client \
    libatomic1 \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . .

# Generate Prisma client
RUN prisma generate

EXPOSE 6969

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "6969"]