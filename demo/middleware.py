# custom_middleware.py
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
