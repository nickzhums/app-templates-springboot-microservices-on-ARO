FROM openjdk:11
VOLUME /opt/egbtm
#ADD data /
COPY target/spring-petclinic-1.5.1.jar /app/
COPY changelog.txt /opt/

WORKDIR /app

ENV JAVA_OPTS=""
ENTRYPOINT ["java", "-jar", "spring-petclinic-1.5.1.jar"]

