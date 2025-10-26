FROM python:3.11-slim

WORKDIR /app

# Install nginx, supervisor, and curl (for healthchecks)
RUN apt-get update && \
    apt-get install -y nginx supervisor curl && \
    rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Copy auth application
COPY app.py /app/

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Create supervisor configuration
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Create non-root user
RUN useradd -m -u 1000 vibevm && \
    chown -R vibevm:vibevm /app && \
    # Nginx needs to run as root to bind port 80, but we'll configure it safely
    mkdir -p /var/log/nginx /var/lib/nginx /run && \
    chown -R www-data:www-data /var/log/nginx /var/lib/nginx

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
