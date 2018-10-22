![](http://i.imgur.com/KC6TAD3.png)

# Jenkins with DooD (Docker outside of Docker)

A [Jenkins container](https://registry.hub.docker.com/_/jenkins/) capable of using [Docker](http://docker.com), so you can Docker while you Docker.

* [How to use it](#how-to-use-it)
* [Backup](#backup)
* [Restore](#restore)
* [Advantages](#advantages)
* [Disadvantages](#disavantages)
* [Copyright and Licensing](#copyright-and-licensing)

---

## First of all, WTF is *DooD* supposed to mean?

Long story short, *DooD* (as in *dude*) is the opposite of *[DinD](https://blog.docker.com/2013/09/docker-can-now-run-within-docker/)* and whereas the latter includes a whole Docker installation inside of it, the former just uses its underlying host's Docker installation.

This Docker container is highly based on the one explained at the [article by Adrian Mouat](http://container-solutions.com/2015/03/running-docker-in-jenkins-in-docker/) which explains the *DooD* approach in order to have a Jenkins container that is able to use [Docker](http://docker.com). Don't thank me, thank Mouat for his contribution on this matter.

## <a name="how-to-use-it"></a> How to use it

### Environment Variables

* `ROOT_BUCKET`: the s3 bucket that you wish to store your archives too.
* `PRODUCT`: the project name or product name. to set distinct locations for
  backing up multiple jenkins servers to the same location (s3 bucket subfolder).
* `REGION`: the region in AWS that the s3 bucket is located in.
* `docker_version`: [DOCKER_VERSION](#docker_version)

### Build it

```bash
git clone https://github.com/intuitivetechnologygroup/jenkins-dood.git
cd jenkins-dood
docker build -t jenkins-dood .
# or use make
make build
```

#### <a name="docker_version"></a> You can optionally set `docker-engine` version at build time through the use of the `docker_version` build argument, like so:

```bash
# Default docker_version is 1.11.2
docker build --build-arg docker_version=1.12.0 -t jenkins-dood .
```

### You can easily test it as well with docker-compose

```bash
docker-compose up
```

### Now, time to have fun with it...

```bash
docker run -d -v /var/run/docker.sock:/var/run/docker.sock -p 8080:8080 -t jenkins-dood
# or use make
make run
```

### If you want to have fun with permissions...

```bash
docker run -d -v /var/run/docker.sock:/var/run/docker.sock \
              -v /path/to/your/jenkins/home:/var/jenkins_home \
              -p 8080:8080 \
              jenkins-dood
```

### Use it...

Open your browser and go to `localhost:8080`

#### Get initial admin password

```bash
make init-password
```

## <a name="backups"></a> Backup

The image ships with a management job that will run every day at 4 o'clock. This job
backs up $JENKINS_HOME to a s3 bucket of your choosing.

#### Requirements:
* Create a [s3 bucket](http://docs.aws.amazon.com/AmazonS3/latest/gsg/CreatingABucket.html) in AWS for the purposes of storing backups.

* Override the `$ROOT_BUCKET` environment variable with your s3 buckets name

* Override the `$PRODUCT` environment variable with the product/project name you
  are managing. This value allows for multiple jenkins to be backed up to the
  same location. *We prefer to have distinct jenkins for each project rather
  than one global jenkins.*

* Override the `$REGION` environment variable with the region of the s3 bucket of
  your choosing.

* The container will need to have the permissions to write to the s3 bucket of
  your choosing. For instance you could put these permissions in the task role
  of your ECS deployment.

## <a name="backups"></a> Restore

The image upon launch will attempt to restore itself based on where the jenkins
backups are being archived in s3. It will check by default in:

```bash
s3://$ROOT_BUCKET/$PRODUCT/
```
#### Requirements:
* See above about overriding environment variables for backups.

* The container will need to have the permissions to read from the s3 bucker of
  your choosing. For instance you could put these permissions in the task role
  of your ECS deployment.

### <a name="advantages"></a> Advantages

* No `privileged` mode needed
* Simpler, Jenkins will use it underlying host's Docker installation
* Ability to reuse the image cache from the host
* Any settings in the host's Docker daemon will apply to Jenkins container as well
* Easier to set up, you just need to map the host's Docker executable and daemon socket onto the container
* Your host and your container will use the same version of Docker, always.

### <a name="disavantages"></a> Disadvantages

* Although this image does not require `privileged` mode, it does not make it any safer because it can do `docker` things directly on the host, so you have to be aware of this
* If you want to manage a complete clean Docker environment inside your Jenkins, this one's not for you, you're looking for *DinD*

---

![](http://i.imgur.com/MEFY0F5.gif)

> What is the most resilient parasite? Bacteria? A virus? An intestinal worm?
> An idea. Resilient... highly contagious. Once an idea has taken hold of the
> brain it's almost impossible to eradicate. An idea that is fully formed -
> fully understood - that sticks; right in there somewhere.

*Cobb ("Inception" by Mr. Christopher Nolan), 2010*


## <a name="copyright-and-licensing"></a> Copyright and Licensing

Copyright (c) 2015 Alejandro Ricoveri

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
