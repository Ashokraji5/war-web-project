# Use official Tomcat base image
FROM tomcat:9.0-jdk17-temurin

# Metadata (optional)
LABEL maintainer="yourname@company.com" \
      description="Tomcat app image built from WAR stored in Nexus"

# Remove default Tomcat apps for a clean deployment
RUN rm -rf /usr/local/tomcat/webapps/*

# Pass Nexus WAR URL as a build argument
ARG WAR_URL

# Install wget to download the WAR file
RUN apt-get update && apt-get install -y wget && \
    wget -O /usr/local/tomcat/webapps/ROOT.war ${WAR_URL} && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Expose default Tomcat port
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
