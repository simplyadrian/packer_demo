#!/bin/bash
/restore.sh
chown -R jenkins:jenkins /usr/share/jenkins/ref
cp -Rp /usr/share/jenkins/ref/jobs $JENKINS_HOME
/fixup_backup.sh
groupmod -g $(stat -c "%g" "$JENKINS_HOME") jenkins
usermod -u $(stat -c "%u" "$JENKINS_HOME") jenkins
/usr/local/bin/jenkins.sh
