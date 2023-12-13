# Use the official Python 3.11.3 image as a base image
FROM python:3.11.3


# Set the working directory in the container to /app
WORKDIR /app

# Install system dependencies
RUN apt-get update \
  && apt-get -y install netcat gcc \
  && apt-get clean

# Add the current directory contents into the container at /app
COPY requirements.txt manage.py /app/
COPY demo /app/demo/
COPY api /app/api/

# Install Python dependencies
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Add entrypoint script
COPY entrypoint.sh /usr/src/app/entrypoint.sh
RUN chmod +x /usr/src/app/entrypoint.sh

# Healthcheck instruction
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/health/ || exit 1

# Create a user for running the application (non-root user)
RUN groupadd -r django && useradd -r -g django django
USER django

# Expose port 8000 to be accessible from the host
EXPOSE 8000

# Run the Django development server
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
