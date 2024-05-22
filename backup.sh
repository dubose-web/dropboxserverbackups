#!/usr/bin/env bash

# CD Here
SCRIPT_DIR=$(dirname "$0");
cd "${SCRIPT_DIR}";

################################################################################
# Vars
################################################################################

# Get env file
source env.sh;

# Set the current date
date=$(date +"%Y-%m-%d__%H-%M-%S");






################################################################################
# File backup
################################################################################

# Create the backup directory
mkdir backups/${date};

# Iterate through specified directories and back up
for dir in "${DIRS[@]}"; do
    # Replace all forward slashes in path with underscores
    dirNameSafe=${dir//\//_};

    # Create gzipped tarball of specified directory
    tar -czf backups/${date}/${dirNameSafe}.tar.gz ${dir};
done;






################################################################################
# MySQL backup
################################################################################

# Iterate through specified databases and back up
for dbConfig in "${DATABASES[@]}"; do
    containerIdVarName="${dbConfig}_DB_CONTAINER_ID";
    mysqlDbNameVarName="${dbConfig}_MYSQL_DB_NAME";
    mysqlUserVarName="${dbConfig}_MYSQL_USER";
    mysqlPasswordVarName="${dbConfig}_MYSQL_PASSWORD";

    containerId="${!containerIdVarName}";
    mysqlDbName="${!mysqlDbNameVarName}";
    mysqlUser="${!mysqlUserVarName}";
    mysqlPassword="${!mysqlPasswordVarName}";

    /usr/bin/docker exec --user root "${containerId}" bash -c "mysqldump -u"${mysqlUser}" -p"${mysqlPassword}" "${mysqlDbName}" > /"${dbConfig}".sql";
    /usr/bin/docker cp "${containerId}":/"${dbConfig}".sql backups/${date}/"${dbConfig}".sql;
    /usr/bin/docker exec --user root "${containerId}" bash -c "rm /"${dbConfig}".sql";
    gzip -9 backups/${date}/"${dbConfig}".sql;
done;







################################################################################
# Upload to Dropbox
################################################################################

# While we might get erroneous errors from the tar process (file changed as we
# read it, grr), we DO need to stop on error from the upload process so that an
# `&&` bash command that may ping a healthcheck won't get hit when something has
# gone wrong
set -e;

docker run --rm \
    -v ${SCRIPT_DIR}:/app \
    -w /app \
    --security-opt seccomp=unconfined \
    php:8.3.7-cli bash -c "php upload.php --dropboxRefreshToken="${DROPBOX_REFRESH_TOKEN}" --dropboxAppKey="${DROPBOX_APP_KEY}" --dropboxAppSecret="${DROPBOX_APP_SECRET}" --dropboxBackupDirName="${DROPBOX_BACKUP_DIR_NAME}" --date=${date}";






################################################################################
# Cleanup
################################################################################

# Get count of files in directory
count=0;
for dir in backups/*; do
    count=$((count+1));
done;

# Set the cuttoff
cuttoff=$((count-${LOCAL_ROTATE}));

echo ${cuttoff};

# Delete older backups if applicable
if [ ${cuttoff} -gt 0 ]; then

    # Iterate through backup directories
    i=0;
    for dir in backups/*; do

        # Increment var
        i=$((i+1));

        # If we're past the cuttoff, get out of loop
        if [ ${i} -gt ${cuttoff} ]; then
            break;
        fi;

        # Remove directory and contents
        rm -rf ${dir};

    done;

fi;
