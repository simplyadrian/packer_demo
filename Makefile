jenkins:
	cd ./ansible-pb-deploy-jaas/
	ansible-playbook -i inventory deploy.yml -e org=ids
mmmbot:
	cd ./ansible-pb-ecs-mmmbot/
	ansible-playbook -i inventory deploy.yml
