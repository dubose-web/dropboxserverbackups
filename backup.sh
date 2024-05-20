#!/usr/bin/env bash

set -e;

source env.sh

# CD Here
cd "$(dirname "$0")";

################################################################################
# Vars
################################################################################

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
for dbName in "${DATABASES[@]}"; do
    containerIdVarName="${dbName}_DB_CONTAINER_ID";
    mysqlUserVarName="${dbName}_MYSQL_USER";
    mysqlPasswordVarName="${dbName}_MYSQL_PASSWORD";

    containerId="${!containerIdVarName}";
    mysqlUser="${!mysqlUserVarName}";
    mysqlPassword="${!mysqlPasswordVarName}";

    /usr/bin/docker exec --user root "${containerId}" bash -c "mysqldump -u"${mysqlUser}" -p"${mysqlPassword}" "${dbName}" > /"${dbName}".sql";
    /usr/bin/docker cp "${containerId}":/"${dbName}".sql backups/${date}/"${dbName}".sql;
    /usr/bin/docker exec --user root "${containerId}" bash -c "rm /"${dbName}".sql";
    gzip -9 backups/${date}/"${dbName}".sql;
done;







################################################################################
# Upload to Dropbox
################################################################################

docker run --rm \
    -v ${PWD}:/app \
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
