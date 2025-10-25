FROM nginx:1.29.2
# Install dependencies and the setup plugin
RUN apt update && apt install wget unzip
COPY 40-download-design-system.sh /docker-entrypoint.d/
