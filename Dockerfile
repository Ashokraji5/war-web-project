# Use official Tomcat 9 with JDK 17 slim
FROM tomcat:9.0-jdk17-openjdk-slim

# Set working directory
WORKDIR /usr/local/tomcat

# Remove default ROOT application
RUN rm -rf webapps/ROOT

# Copy WAR built by Maven from target directory
COPY target/*.war /usr/local/tomcat/webapps/app.war

# Expose Tomcat port
EXPOSE 8080

# Run Tomcat in foreground
CMD ["catalina.sh", "run"]





