FROM nginx:1.29.2

# Install dependencies.
RUN apt update && apt install wget unzip

# Setup plugins.
COPY 40-download-design-system.sh /docker-entrypoint.d/
RUN chmod u+x /docker-entrypoint.d/40-download-design-system.sh
