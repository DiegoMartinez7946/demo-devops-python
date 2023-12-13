# Project Documentation

This document provides an overview of the key configurations and steps taken in setting up the Python/Django application, Dockerizing the application, Kubernetes deployment, and setting up the CI/CD pipeline using GitHub Actions.

## Table of Contents

- [Python/Django Application](#python-django-application)
- [Docker Configuration](#docker-configuration)
- [Kubernetes Deployment](#kubernetes-deployment)
- [GitHub Actions CI/CD Pipeline](#github-actions-ci-cd-pipeline)

## Python/Django Application

### Custom Middleware for ALLOWED_HOSTS Configuration

In order to dynamically handle internal IP addresses in Django's `ALLOWED_HOSTS`, i implemented a custom middleware, `AllowInternalIPsMiddleware`. This middleware facilitates the application to accept requests from internal IP addresses, which is particularly useful in a Kubernetes environment.

#### Middleware Implementation

The custom middleware is defined in `middleware.py` (or your custom file name) and is responsible for checking the incoming request's host. If the host is an internal IP, it sets the `HTTP_HOST` header to 'localhost', effectively allowing the request under the `ALLOWED_HOSTS` policy.

##### `middleware.py`

```python
import ipaddress
from django.http import HttpRequest

class AllowInternalIPsMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request: HttpRequest):
        host = request.get_host().split(':')[0]
        try:
            # Validate if the host is an internal IP
            ip = ipaddress.ip_address(host)
            if ip.is_private:
                request.META['HTTP_HOST'] = 'localhost'
        except ValueError:
            pass  # Not an IP address

        return self.get_response(request)
```
##### `settings.py`

Added the middleware to the Django settings.py:
```python
MIDDLEWARE = [
    # ... other middleware ...
    'demo.middleware.AllowInternalIPsMiddleware',
    # ... other middleware ...
]

```

### Other Modifications

- **Health Check Endpoint**: Added a `/health` endpoint in the Django application for health checking purposes.
    ```python
    def health_check(request):
        return JsonResponse({"status": "healthy"}, status=200)
    ```
- **Database Configuration**: Configured Django to use an SQLite database stored in a specific path (`/data/db.sqlite3`), which is compatible with Kubernetes persistent volumes.
    ```python
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.sqlite3',
            'NAME': str(Path('/data') / os.environ.get('DATABASE_NAME', 'db.sqlite3')),
        }
    }
    ```

## Docker Configuration

### Dockerfile

- Created a `Dockerfile` to containerize the Django application.
- Configured the Dockerfile to install necessary dependencies, copy the application code, and set the command to run the Django server.

    ```dockerfile
    FROM python:3.11.3
    # ... (rest of Dockerfile) ...
    CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
    ```

## Kubernetes Deployment

### Kubernetes Manifests

- **Deployment**: Created a Kubernetes deployment manifest.
    - Added liveness and readiness probes to check the `/health` endpoint.
    - Configured resource requests and limits.
- **Persistent Volume (PV) and Persistent Volume Claim (PVC)**: Set up PV and PVC for persistent storage of the SQLite database.
- **ConfigMap and Secret**: Used ConfigMap for environment variable configuration and Secret for sensitive data like `DJANGO_SECRET_KEY`.

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    # ... (rest of the deployment manifest) ...
    ```

## GitHub Actions CI/CD Pipeline

### Workflow Configuration

- **Build and Push Docker Image**: Configured a job to build the Docker image and push it to a Docker registry.
- **Run Tests and Analysis**:
    - Added steps to run unit tests using Django's testing framework.
    - Included static code analysis and code coverage.
    - Added a vulnerability scan of the Docker image.
- **Deploy to Kubernetes**: Added steps to update the Kubernetes manifests and deploy them to an EKS cluster.

    ```yaml
    name: CI/CD Pipeline
    on: [push]
    jobs:
      build-and-push:
        # ... (rest of the workflow) ...
    ```
