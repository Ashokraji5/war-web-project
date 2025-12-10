FROM tomcat:9.0-jdk17-temurin

ARG WAR_URL
ENV WAR_URL=${WAR_URL}

RUN set -e && \
    apt-get update && \
    apt-get install -y --no-install-recommends wget && \
    rm -rf /usr/local/tomcat/webapps/* && \
    wget -O /usr/local/tomcat/webapps/ROOT.war ${WAR_URL} && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

EXPOSE 8080
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

