
<img width="586" alt="image" src="https://github.com/user-attachments/assets/99e1cdb5-5e49-40e9-bbed-44465bed262a">


# Artifactory: Centralizing Artifact Management for DevOps Success

## Introduction
In today's fast-paced software development environment, the need for efficient artifact management is paramount. As a DevOps Engineer, I recognized the necessity of streamlining the deployment process and ensuring a reliable artifact repository for my Java applications. To achieve this, I embarked on a journey to set up Artifactory on cloud server. In this blog, I will share the steps I took to accomplish this, detailing the installation and configuration processes along the way.

## Purpose
Artifactory management serve as vital components in a DevOps pipeline. They provide a centralized location to store and manage artifacts produced during the software development lifecycle.It is known for its rich feature set, including support for various package types, advanced search capabilities, and user management features. 

## The Situation: Why I harnessed Artifactory for Efficient Dependency and Artifact Management
As a DevOps Engineer, I once faced challenges with a team concerning dependency management and artifact storage, ultimately leading to delays in deployment. The absence of a centralized repository made it difficult to track versions and manage dependencies effectively. Additionally, frequent manual uploads and downloads of artifacts were error-prone and time-consuming. To overcome these challenges, I decided to deploy Nexus to manage the artifacts and maven to ensure that the Java applications could be built, stored, and deployed seamlessly.


## First, lets have a feel of the application that it works by deploying to apache Tomcat for web application hosting.

### 1. Pre-requisites: Ubuntu Server or any other Linux server

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
# Download Tomcat
cd /tmp
wget https://dlcdn.apache.org/tomcat/tomcat-11/v11.0.0-M26/bin/apache-tomcat-11.0.0-M26.tar.gz

# Extract Tomcat files
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
<user username="manager" password="xxxxxxxd" roles="manager-gui" />

<role rolename="admin-gui" />
<user username="admin" password="xxxxxxxd" roles="manager-gui,admin-gui" />
```
**Replace with your chosen password**

**Allow Remote Access**
To enable access to the Manager and Host Manager pages, edit the context.xml files:
```bash
# Edit Manager context file
sudo nano /opt/tomcat/webapps/manager/META-INF/context.xml
```
Comment out the Valve definition in this file by adding arrows to the beginning and end of line. Repeat the same for the Host Manager context file:
```bash
# Edit Host Manager context file
sudo nano /opt/tomcat/webapps/host-manager/META-INF/context.xml
```
<img width="571" alt="image" src="https://github.com/user-attachments/assets/efec82b6-3dfe-4f9f-920a-40eecc230054">

**Setup Systemd for Tomcat**
Find the Java location:
```bash
sudo update-java-alternatives -l
```
<img width="511" alt="image" src="https://github.com/user-attachments/assets/cc9d2168-860a-4351-9633-32832d4a8987">

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

**Create the Tomcat Service File** (to automatically start on every system reboot)
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
<img width="559" alt="image" src="https://github.com/user-attachments/assets/db62b67c-edf8-4445-b562-4fe15a95c29a">

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

**Clone A sample Application from GitHub**
```bash
cd /home/ubuntu
git clone https://github.com/balogsun/maven-java-builds.git

```

**Edit the `pom.xml` File**
```
cd maven-java-builds
```
Change the `<finalName>` tag in your `pom.xml` to a name of your choice and save:
```xml
<finalName>My_Maven_Webapp</finalName>
```
<img width="454" alt="image" src="https://github.com/user-attachments/assets/964341cf-f658-4e10-b2c9-62be1421bbe5">

**Build Your Application**
```bash
mvn package
```

**Deploy the WAR File to Tomcat**
```bash
sudo cp /home/ubuntu/maven-java/target/My_Maven_Webapp.war /opt/tomcat/webapps
```
Access your application at `http://<your-server-ip>:8080/My_Maven_Webapp`.

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
sudo echo 'nexus ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
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

**To modify config options, open the /opt/nexus/bin/nexus.vmoptions file, you can modify the config path as shown below**
```
sudo nano /opt/nexus/bin/nexus.vmoptions
In the below settings, the directory is changed from ../sonatype-work to /opt/sonatype-work
-Xms1024m
-Xmx1024m
-XX:MaxDirectMemorySize=1024m

-XX:LogFile=/opt/sonatype-work/nexus3/log/jvm.log
-XX:-OmitStackTraceInFastThrow
-Djava.net.preferIPv4Stack=true
-Dkaraf.home=.
-Dkaraf.base=.
-Dkaraf.etc=etc/karaf
-Djava.util.logging.config.file=/etc/karaf/java.util.logging.properties
-Dkaraf.data=/opt/sonatype-work/nexus3
-Dkaraf.log=/opt/sonatype-work/nexus3/log
-Djava.io.tmpdir=/opt/sonatype-work/nexus3/tmp
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
   - Password: (this password is generated during the installation; find it in the file `/opt/nexus/sonatype-work/nexus3/admin.password`).

<img width="775" alt="image" src="https://github.com/user-attachments/assets/19ea0fe1-67a4-4259-82a9-0c6dc6e8a237">

**Change the Admin Password**

You will be prompted to change the password upon first login.

### 4. Creating Repositories in Nexus

**Create a Maven Hosted Repository**
1. In the Nexus web interface, click on **wheel-like icon**.
2. Click on `repository` and **Create repository**.
3. Select **maven2 (hosted)** and click **Next**.
4. Configure the repository settings (like name, version policy, etc.), and click **Create repository**.

**Create a Maven Proxy Repository**
1. Click on **Create repository**.
   <img width="770" alt="image" src="https://github.com/user-attachments/assets/a6539e76-0525-4fc3-afc9-cdd15f641d52">

3. Select **maven2 (hosted)** and click **Next**.
   <img width="575" alt="image" src="https://github.com/user-attachments/assets/cd16b958-8de4-43d3-bb26-fbe342c9b5b6">

5. Configure the repository settings,  and click **Create repository**.
   <img width="548" alt="image" src="https://github.com/user-attachments/assets/13207581-4be9-4ad7-aafd-de723c1340a1">

### 5. Test a manual upload to artifactory.

First get the url of your repository and copy it out for the next coomand below

<img width="494" alt="image" src="https://github.com/user-attachments/assets/42dea90b-2fab-4cb0-9fe5-63fd8860c5ad">

```
cd /home/ubuntu/maven-java/target
curl -v -u admin:pass --upload-file /root/maven-java/target/My_Maven_Webapp.war http://<server-ip-address>:8081/repository/My_Maven_Webapp/  
```
<img width="610" alt="image" src="https://github.com/user-attachments/assets/caf6f7b4-f964-42cf-aace-b4b71dcc80e6">

Check back at your repository in the `browse section` to find you artifacts uploaded.

Likewise, artifacts can also be donwloaded manually.

```
curl -X GET http://admin:pass@<server-ip-address>:8081/repository/My_Maven_Webapp/My_Maven_Webapp.war --output My_Maven_Webapp.war
```
### Integratin Nexus with Maven Builds

## Let's configure your Maven project to work with Nexus. Navigate to your project directory:

```
cd /home/ubuntu/maven-java
```

### Configuring pom.xml

Your `pom.xml` file is the heart of your Maven project. Here's a sample configuration:

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>myapp</groupId>
  <artifactId>My_Maven_Webapp</artifactId>
  <packaging>war</packaging>
  <version>1.0.0</version>
  <name>My sample Maven Webapp</name>
  <url>http://maven.apache.org</url>

  <!-- Properties for Java version and encoding -->
  <properties>
    <maven.compiler.release>17</maven.compiler.release>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
  </properties>

  <!-- Dependencies -->
  <dependencies>
    <dependency>
       <groupId>javax.servlet</groupId>
       <artifactId>javax.servlet-api</artifactId>
       <version>4.0.1</version>
       <scope>provided</scope>
    </dependency>
  </dependencies>

  <!-- Build configuration -->
  <build>
    <finalName>Seun_Web2</finalName>
    <plugins>
      <!-- Compiler plugin -->
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-compiler-plugin</artifactId>
        <version>3.10.1</version>
        <configuration>
          <release>17</release>
        </configuration>
      </plugin>
      <!-- WAR plugin -->
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-war-plugin</artifactId>
        <version>3.3.2</version>
      </plugin>
      <!-- Deploy plugin -->
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-deploy-plugin</artifactId>
        <version>3.1.0</version>
      </plugin>
    </plugins>
  </build>

  <!-- Distribution Management for Nexus -->
  <distributionManagement>
    <repository>
      <id>nexus</id>
      <name>Seun_Web2</name>
      <url>http://<Ip-address>:8081/repository/Seun_Web/</url> <!-- Your repository URL here -->
    </repository>
  </distributionManagement>
</project>
```

## Setting Up Nexus
Configure Maven to use Nexus by creating a `settings.xml` file:

```
mkdir -p ~/.m2 (this should already exist following initial deploymenets)
sudo nano ~/.m2/settings.xml
```

Add the following content:

```xml
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 https://maven.apache.org/xsd/settings-1.0.0.xsd">
    <servers>
        <server>
            <id>nexus</id>
            <username>username</username>
            <password>password</password>
        </server>
    </servers>
</settings>
```

Ensure proper permissions:

```
chmod 755 ~/.m2/settings.xml
chown username:groupname ~/.m2/settings.xml
```

## Deploying Your Application

To deploy your application to Nexus:

```
mvn clean deploy
```

This command will compile your code, run tests, package your application, and upload it to Nexus.

<img width="555" alt="image" src="https://github.com/user-attachments/assets/a1922b90-13de-418c-b6c5-7c4e52e7a7e7">

## Updating Your Application

To update your application:

1. Modify your `pom.xml` to increment the version number.
2. Update your application code as needed.
3. Run `mvn clean deploy` again to deploy the new version.

## Troubleshooting

If you encounter a 401 Unauthorized error, ensure that:

1. Your `settings.xml` is in the correct location (`~/.m2/settings.xml` or `/root/.m2/settings.xml` if running as root).
2. The credentials in `settings.xml` match those in your Nexus server.

## Java Compatibility

Ensure you're using Java 17 or later. Set up your environment:

## Conclusion
By following these detailed steps, I successfully set up Tomcat, deployed a Java application, and integrated Nexus Repository into my workflow. This deployment not only streamlined my development process but also enhanced collaboration within my team. With the ability to manage dependencies efficiently and deploy applications reliably, you will feel more confident in delivering quality software in a timely manner.
