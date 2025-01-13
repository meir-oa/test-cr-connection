FROM python:3.9-slim

WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the app directory
COPY app/ ./app/

# Set Python path to recognize the app module
ENV PYTHONPATH=/app

# Run the application
CMD ["python", "app/main.py"]