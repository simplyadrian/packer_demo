build:
	cd ansible-pb-deploy-jaas/
	ansible-playbook -i inventory deploy.yml -e org=ids
