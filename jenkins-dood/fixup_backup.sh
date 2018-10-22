if [[ -n "$PRODUCT" ]] && [[ -n "$ROOT_BUCKET" ]]
then
  sed -i.bak "s/REPLACEME1/$ROOT_BUCKET/g" $JENKINS_HOME/jobs/Management\ Jobs/jobs/backup_jenkins/config.xml
  sed -i.bak "s/REPLACEME2/$PRODUCT/g" $JENKINS_HOME/jobs/Management\ Jobs/jobs/backup_jenkins/config.xml
  sed -i.bak "s/REPLACEME3/$REGION/g" $JENKINS_HOME/jobs/Management\ Jobs/jobs/backup_jenkins/config.xml
fi
