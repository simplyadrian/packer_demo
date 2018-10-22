IMAGE_NAME="jenkins-dood"
VERSION=`cat VERSION`

build:
	docker build -t $(IMAGE_NAME):latest -t $(IMAGE_NAME):$(VERSION) .
run:
	docker run -d -v /var/run/docker.sock:/var/run/docker.sock -p 8080:8080 -t $(IMAGE_NAME):$(VERSION)
ssh:
	docker exec -it `docker ps -f ancestor=$(IMAGE_NAME) -q` bash
init-password:
	docker exec `docker ps -f ancestor=$(IMAGE_NAME) -q` cat /var/jenkins_home/secrets/initialAdminPassword
