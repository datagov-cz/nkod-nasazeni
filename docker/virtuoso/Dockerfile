FROM openlink/virtuoso-opensource-7:7.2.15

# Copy database configuration file.
WORKDIR /opt/nkod/
COPY --owner virtuoso:virtuoso ./virtuoso.ini ./

# Copy runtime script.
COPY --owner virtuoso:virtuoso ./initdb.d/* /initdb.d/

# Go back to the original working directory.
WORKDIR /opt/virtuoso-opensource/database
