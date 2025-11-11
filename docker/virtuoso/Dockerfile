FROM openlink/virtuoso-opensource-7:7.2.15

# Copy and set new database init file.
COPY --chmod=544 --chown=virtuoso:virtuoso ./virtuoso.ini /opt/
ENV VIRTUOSO_INI_FILE=/opt/virtuoso.ini

# Update ownership of /database.
RUN chown virtuoso:virtuoso /database

# By default the image would use root, which we do not want.
USER virtuoso
