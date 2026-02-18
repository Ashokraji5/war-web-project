FROM tomcat:9.0-jdk17-openjdk-slim

# Set working directory to Tomcat installation
WORKDIR /usr/local/tomcat

# Remove default ROOT application to avoid conflicts
RUN rm -rf webapps/ROOT

# Download the WAR file from Nexus repository
# Replace URL with your Nexus repo path and artifact coordinates
ADD http://54.164.75.43:8081/repository/jenkins-maven-release-role/koddas/web/war/wwp/1.0.0/wwp-1.0.0.war /usr/local/tomcat/webapps/app.war


# Expose Tomcat default port
EXPOSE 8080

# Run Tomcat in foreground
CMD ["catalina.sh", "run"]





