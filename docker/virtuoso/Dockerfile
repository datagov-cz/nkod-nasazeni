FROM openlink/virtuoso-opensource-7:7.2.15

# Copy and set new database init file.
COPY --chmod=544 ./virtuoso.ini /opt/nkod/
ENV VIRTUOSO_INI_FILE=/opt/nkod/virtuoso.ini
