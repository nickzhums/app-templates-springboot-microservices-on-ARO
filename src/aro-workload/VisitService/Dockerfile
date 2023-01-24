FROM openjdk:11
VOLUME /opt/egbtm
#ADD data /
COPY target/VisitService-0.0.1-SNAPSHOT.jar /app/

WORKDIR /app

ENV JAVA_OPTS=""
ENTRYPOINT ["java", "-jar", "VisitService-0.0.1-SNAPSHOT.jar"]
