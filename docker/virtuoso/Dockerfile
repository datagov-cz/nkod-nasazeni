FROM openlink/virtuoso-opensource-7:7.2.15

# Copy and set new database init file.
COPY --chmod=544 --chown=virtuoso:virtuoso ./virtuoso.ini /opt/
ENV VIRTUOSO_INI_FILE=/opt/virtuoso.ini

# By default the image would use root, which we do not want.
USER virtuoso

# TODO
#  ./configure --prefix=/usr/local/ --with-readline --program-transform-name="s/isql/isql-v/" --with-layout=Debian --enable-fct-vad`
