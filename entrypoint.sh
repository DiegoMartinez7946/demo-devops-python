#!/bin/sh

# Wait for the database to be ready (if you are using a database server)
# Example for PostgreSQL:
# while ! nc -z $DB_HOST $DB_PORT; do
#   echo "Waiting for the PostgreSQL database to start"
#   sleep 1
# done

# Apply database migrations
echo "Apply database migrations"
python manage.py makemigrations
python manage.py migrate

# Start the Django application
echo "Starting Django server"
python manage.py runserver 0.0.0.0:8000
