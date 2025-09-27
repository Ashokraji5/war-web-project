FROM tomcat:9.0

# Remove default Tomcat webapps (optional but clean)
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy your WAR file and rename it to ROOT.war (optional)
# COPY target/wwp-1.0.0.war /usr/local/tomcat/webapps/ROOT.war

COPY target/wwp-1.0.0.war /usr/local/tomcat/webapps/wwp-1.0.0.war

EXPOSE 8080
