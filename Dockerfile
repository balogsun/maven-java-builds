FROM tomcat:8.0.20-jre8

RUN apt-get update

RUN apt-get install maven -y --force-yes

WORKDIR /usr/local/tomcat

COPY . .

RUN mvn clean package
#Copy the built war to the webapp folder
RUN cp ./target/TSPBuild.war ./webapps/TSPBuild.war
