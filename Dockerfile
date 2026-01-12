# Use official Tomcat base image with JDK 17
FROM tomcat:9.0-jdk17-openjdk-slim

# Set working directory to Tomcat installation
WORKDIR /usr/local/tomcat

# Remove default ROOT application to avoid conflicts
RUN rm -rf webapps/ROOT

# Copy the WAR file built by Maven into Tomcat webapps
# Jenkins pipeline builds the WAR in target/
COPY target/*.war webapps/ROOT.war

# Expose Tomcat default port
EXPOSE 8080

# Run Tomcat in foreground
CMD ["catalina.sh", "run"]



# ARG WAR_URL
# ENV WAR_URL=${WAR_URL}

# → Lets you pass the WAR file’s download link at build time (--build-arg WAR_URL=...).
# → Makes it available inside the container as an environment variable.


# RUN BLOCK:

 # → Install wget container can download files.
 # → Removes all default Tomcat webapps(keeps the image clean)
 # → Download your WAR file from the give URL  and saves ROOT.war .
 # → ROOT.WAR means Tomcat will deploy it as default application at /.
 # → clean up apt cache to reduce image size.

