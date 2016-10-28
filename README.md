# **jenkins-docker**
##### **Jenkins inside Docker Container with DinD functionality.**

This project creates Jenkins inside the Docker along with functionality of Docker in Docker.

* Once the Image build process is done using `docker build ` we can start the container using following command :
	
	`docker run --privileged --dns 8.8.8.8 -d --name <ContainerName> -v <your local folder>:/var/jenkins_home -p 8080:8080 -p 80:80 -p 90:90-u root <image-name>`

The reason for using `--privileged` flag is. if we’re going to use Docker in Docker we need to run the container in called privileged mode.

Also, we need to add DNS provider than our default one. This is because mostly /etc/resolv.conf points to 127.0.0.1 on our host but this doesn’t work from the Docker container. 
Hence, as a workaround we can use the `--dns` flag and point to, for example, Google's public DNS service using `8.8.8.8`

Once the container is started, login to Jenkins Webpage. 
Create a parent job which will act as job-generator and add the dsl scripts which are available within dsl_scripts directory in the Build section, select the Process Job DSLs from the dropdown options in Build section. 

There are two dsl scripts:
- docker_deploy_job.groovy : which pulls a html installed docker image and deploys a simple HTML file on it and through curl will show the output.
- manual_deploy_job.groovy : which deploys a simple html file on apache server and shows the output using curl.