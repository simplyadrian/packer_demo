#!/bin/bash
export DO_DB_SETUP=${DO_DB_SETUP:-true}
if [[ -n "$APP_API_SECRET_KEY_BASE" ]] && [[ -n "$CREDSTASH_TABLE" ]] && [[ -n "$ENVIRON" ]]
then
  echo "Setting application secret..."
  export PAY_API_SECRET_KEY=$(credstash -r $CREDSTASH_REGION -t $CREDSTASH_TABLE get -n $APP_API_SECRET_KEY_BASE env=$ENVIRON)
fi
if [[ -n "$APP_SECRET_KEY_BASE" ]] && [[ -n "$CREDSTASH_TABLE" ]] && [[ -n "$ENVIRON" ]]
then
  echo "Setting application secret..."
  export SECRET_KEY_BASE=$(credstash -r $CREDSTASH_REGION -t $CREDSTASH_TABLE get -n $APP_SECRET_KEY_BASE env=$ENVIRON)
fi

if [[ -n "$RDS_PASSWORD" ]] && [[ -n "$ENVIRON" ]] && [[ -n "$CREDSTASH_TABLE" ]]
then
  echo "Setting database username in the environment"
  export DATABASE_PASSWORD=$(credstash -r $CREDSTASH_REGION -t $CREDSTASH_TABLE get -n $RDS_PASSWORD env=$ENVIRON)
fi

if [[ -n "$RDS_USERNAME" ]] && [[ -n "$ENVIRON" ]] && [[ -n "$CREDSTASH_TABLE" ]]
then
  echo "Setting the database password in the environment"
  export DATABASE_USERNAME=$(credstash -r $CREDSTASH_REGION -t $CREDSTASH_TABLE get -n $RDS_USERNAME env=$ENVIRON)
fi

if [ "$APP_NAME" == "pay-nl" ]
then
  if [[ -n "$RDS_PASSWORD" ]] && [[ -n "$ENVIRON" ]] && [[ -n "$CREDSTASH_TABLE" ]]
  then
    echo "Setting database username in the environment"
    export PGPASSWORD=$(credstash -r $CREDSTASH_REGION -t $CREDSTASH_TABLE get -n $RDS_PASSWORD env=$ENVIRON)
  fi

  if [[ -n "$RDS_USERNAME" ]] && [[ -n "$ENVIRON" ]] && [[ -n "$CREDSTASH_TABLE" ]]
  then
    echo "Setting the database password in the environment"
    export PGUSER=$(credstash -r $CREDSTASH_REGION -t $CREDSTASH_TABLE get -n $RDS_USERNAME env=$ENVIRON)
  fi

  export PGHOST=$DATABASE_HOST
  export PGPORT=5432
  export PGDATABASE=$DATABASE_NAME

  if [ "$DO_DB_SETUP" = true ]; then
    echo "Attempting to verify that the database is available..."
    psql -q -c 'select 1 from schema_migrations'
    if [[ $? -ne 0 ]]; then
      echo "$DATABASE_NAME doesn't exist. This must be the first time this app has been deployed. Setting up the db..."
      bin/rails db:setup RAILS_ENV=$RAILS_ENV
    else
      echo "$DATABASE_NAME exists. Lets run the migrate process to check for schema updates."
      bin/rails db:migrate RAILS_ENV=$RAILS_ENV
    fi
  else
    echo "Proceeding without setting up the database to allow for an external process to handle the deployment"
  fi
  echo "Running rails server..."
  bin/rails server
elif [ "$APP_NAME" == "sidekiq" ]
then
  bin/bundle exec sidekiq -q default -c 1 &
  bin/bundle exec sidekiq -q high_priority -q purchase -q merchant_notification -q sms -q verification_code_sms -q low_priority -c 25 &
  cd ../sidecheq
  bundle exec rackup -o 0.0.0.0
else
  echo "Invalid app name: $APP_NAME"
fi
