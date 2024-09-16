#!/bin/bash


PG_USER="your_postgres_user"
PG_PASSWORD="your_postgres_password"
HOST="localhost"
PORT="5432"


export PGPASSWORD="$PG_PASSWORD"


databases=$(psql -h $HOST -U $PG_USER -p $PORT -d postgres -t -c "SELECT datname FROM pg_database WHERE datistemplate = false;")


for db in $databases; do
    echo "Starting VACUUM FULL for database: $db" >> /var/log/vacuum_reindex.log
    psql -h $HOST -U $PG_USER -p $PORT -d $db -c "VACUUM FULL;" >> /var/log/vacuum_reindex.log 2>&1
    if [ $? -eq 0 ]; then
        echo "VACUUM FULL completed for database: $db" >> /var/log/vacuum_reindex.log
    else
        echo "VACUUM FULL failed for database: $db" >> /var/log/vacuum_reindex.log
    fi
    
    echo "Starting REINDEX for database: $db" >> /var/log/vacuum_reindex.log
    psql -h $HOST -U $PG_USER -p $PORT -d $db -c "REINDEX DATABASE \"$db\";" >> /var/log/vacuum_reindex.log 2>&1
    if [ $? -eq 0 ]; then
        echo "REINDEX completed for database: $db" >> /var/log/vacuum_reindex.log
    else
        echo "REINDEX failed for database: $db" >> /var/log/vacuum_reindex.log
    fi
    
    echo "---------------------------------------------" >> /var/log/vacuum_reindex.log
done

echo "All operations completed on $(date)." >> /var/log/vacuum_reindex.log
