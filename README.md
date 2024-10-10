
<img width="586" alt="image" src="https://github.com/user-attachments/assets/99e1cdb5-5e49-40e9-bbed-44465bed262a">


# Artifactory: Centralizing Artifact Management for DevOps Succes

## Introduction
In today's fast-paced software development environment, the need for efficient artifact management is paramount. As a DevOps Engineer, I recognized the necessity of streamlining the deployment process and ensuring a reliable artifact repository for my Java applications. To achieve this, I embarked on a journey to set up Artifactory on cloud server. In this blog, I will share the steps I took to accomplish this, detailing the installation and configuration processes along the way.

## Purpose
Artifactory management serve as vital components in a DevOps pipeline. They provide a centralized location to store and manage artifacts produced during the software development lifecycle.It is known for its rich feature set, including support for various package types, advanced search capabilities, and user management features. 

## The Situation: Why I harnessed Artifactory for Efficient Dependency and Artifact Management
As a DevOps Engineer, I once faced challenges with a team concerning dependency management and artifact storage, ultimately leading to delays in deployment. The absence of a centralized repository made it difficult to track versions and manage dependencies effectively. Additionally, frequent manual uploads and downloads of artifacts were error-prone and time-consuming. To overcome these challenges, I decided to deploy Nexus to manage the artifacts and maven to ensure that the Java applications could be built, stored, and deployed seamlessly.


## First, lets have a feel of the application what it works by deploying to apache Tomcat for web application hosting.

### 1. Installing Tomcat

**Create a Tomcat User**
```bash
sudo useradd -m -d /opt/tomcat -U -s /bin/false tomcat
```

**Update the Package Manager Cache**
```bash
sudo apt update
```

**Install Java**
```bash
sudo apt install openjdk-17-jdk
java -version
```

**Download and Install Tomcat**
Before downloading, confirm the latest Tomcat build package from the [official website](https://tomcat.apache.org/).

```bash
# Download Tomcat 10 and 11
wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.7/bin/apache-tomcat-10.1.7.tar.gz
wget https://dlcdn.apache.org/tomcat/tomcat-11/v11.0.0-M26/bin/apache-tomcat-11.0.0-M26.tar.gz

# Extract Tomcat files
cd /tmp
sudo tar xzvf apache-tomcat-10*tar.gz -C /opt/tomcat --strip-components=1
sudo tar xzvf apache-tomcat-11*tar.gz -C /opt/tomcat --strip-components=1

# Set ownership and permissions
sudo chown -R tomcat:tomcat /opt/tomcat/
sudo chmod -R u+x /opt/tomcat/bin
```

**Configure Users for Tomcat**
Edit the `tomcat-users.xml` file to define user roles and access:
```bash
sudo nano /opt/tomcat/conf/tomcat-users.xml
```
Add the following lines before the closing `</tomcat-users>` tag:
```xml
<role rolename="manager-gui" />
<user username="manager" password="P@ssw0rd" roles="manager-gui" />

<role rolename="admin-gui" />
<user username="admin" password="P@ssw0rd" roles="manager-gui,admin-gui" />
```

**Allow Remote Access**
To enable access to the Manager and Host Manager pages, edit the context.xml files:
```bash
# Edit Manager context file
sudo nano /opt/tomcat/webapps/manager/META-INF/context.xml
```
Comment out the Valve definition in this file. Repeat the same for the Host Manager context file:
```bash
# Edit Host Manager context file
sudo nano /opt/tomcat/webapps/host-manager/META-INF/context.xml
```

**Setup Systemd for Tomcat**
Find the Java location:
```bash
sudo update-java-alternatives -l
```

Create the `java.sh` profile:
```bash
sudo nano /etc/profile.d/java.sh
# Add the following lines
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH
```

Create the `setenv.sh` file for Tomcat:
```bash
sudo nano /opt/tomcat/bin/setenv.sh
# Add the following lines
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export JRE_HOME=/usr/lib/jvm/java-17-openjdk-amd64
```

**Create the Tomcat Service File**
```bash
sudo nano /etc/systemd/system/tomcat.service
```
Add the following configuration:
```ini
[Unit]
Description=Tomcat
After=network.target

[Service]
Type=forking
User=tomcat
Group=tomcat

Environment="JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64"
Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom"
Environment="CATALINA_BASE=/opt/tomcat"
Environment="CATALINA_HOME=/opt/tomcat"
Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
```

**Start Tomcat**
```bash
sudo systemctl daemon-reload
sudo systemctl start tomcat
sudo systemctl enable tomcat
```
Allow access to Tomcat on port 8080:
```bash
sudo ufw allow 8080
```

**Test Tomcat**
Access the Tomcat web interface by navigating to `http://<your-server-ip>:8080` in your web browser.

### 2. Downloading and Building Your Java Application with Maven

**Install Maven**
```bash
sudo apt update
sudo apt install maven
mvn -version
```

**Clone Your Application from GitHub**
```bash
cd /home/ubuntu
git clone https://github.com/slimprepdevops/maven-java.git
cd maven-java
```

**Edit the `pom.xml` File**
Change the `<finalName>` tag in your `pom.xml`:
```xml
<finalName>DevOps_Maven_Webapp</finalName>
```

**Build Your Application**
```bash
mvn package
```

**Deploy the WAR File to Tomcat**
```bash
sudo cp /home/ubuntu/maven-java/target/DevOps_Maven_Webapp.war /opt/tomcat/webapps
```
Access your application at `http://<your-server-ip>:8080/DevOps_Maven_Webapp`.

### 3. Installing Nexus Repository Manager

**Download and Install Nexus Repository**
```bash
cd /opt
sudo wget https://download.sonatype.com/nexus/3/latest-unix.tar.gz
sudo tar -zxvf latest-unix.tar.gz
sudo mv nexus-3.* nexus
```

**Create Nexus User**
```bash
sudo adduser nexus
sudo visudo
```
Add the following line to the sudoers file:
```bash
nexus ALL=(ALL) NOPASSWD: ALL
```

**Change Ownership**
```bash
sudo chown -R nexus:nexus /opt/nexus
sudo chown -R nexus:nexus /opt/sonatype-work
```

**Configure Nexus to Run as a Service**
Edit the `nexus.rc` file:
```bash
sudo nano /opt/nexus/bin/nexus.rc
# Add the following line
run_as_user="nexus"
```

**Create a Systemd Service for Nexus**
```bash
sudo nano /etc/systemd/system/nexus.service
```
Add the following configuration:
```ini
[Unit]
Description=nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
User=nexus
Restart=on-abort

[Install]
WantedBy=multi-user.target
```

**Start Nexus**
```bash
sudo systemctl start nexus
sudo systemctl enable nexus
sudo systemctl status nexus
```
Allow access to Nexus on port 8081:
```bash
sudo ufw allow 8081/tcp
```

**Access Nexus Web Interface**
Navigate to `http://<your-server-ip>:8081` in your web browser.

**Login to Nexus**
1. Use the default credentials:
   - Username: `admin`
   - Password: `admin123` (this password is generated during the installation; find it in the file `/opt/sonatype-work/nexus3/admin.password`).

**Change the Admin Password**
1. After logging in, go to **Administration** in the left sidebar.
2. Click on **Administration -> Security -> Users**.
3. Click on the **admin** user.
4. Under the **Password

** field, enter your new password and save the changes.

### 4. Creating Repositories in Nexus

**Create a Maven Hosted Repository**
1. In the Nexus web interface, click on **Repositories** in the left sidebar.
2. Click on **Create repository**.
3. Select **maven2 (hosted)** and click **Next**.
4. Configure the repository settings (like name, version policy, etc.), and click **Create repository**.

**Create a Maven Proxy Repository**
1. Click on **Create repository**.
2. Select **maven2 (proxy)** and click **Next**.
3. Configure the repository settings, including the remote storage URL (for example, Maven Central: `https://repo1.maven.org/maven2/`), and click **Create repository**.

### 5. Deploying Your Application to Nexus

**Configure Maven Settings for Nexus**
Edit the `settings.xml` file for Maven:
```bash
mkdir -p ~/.m2
nano ~/.m2/settings.xml
```
Add the following configuration:
```xml
<settings>
  <servers>
    <server>
      <id>nexus</id>
      <username>admin</username>
      <password>your_new_password_here</password>
    </server>
  </servers>
</settings>
```

**Deploy Your Application to Nexus**
```bash
cd /home/ubuntu/maven-java
mvn clean deploy
```

## Conclusion
By following these detailed steps, I successfully set up Tomcat, deployed a Java application, and integrated Nexus Repository into my workflow. This deployment not only streamlined my development process but also enhanced collaboration within my team. With the ability to manage dependencies efficiently and deploy applications reliably, you will feel more confident in delivering quality software in a timely manner.
