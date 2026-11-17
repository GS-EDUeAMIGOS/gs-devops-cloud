FROM maven:3.9.11-eclipse-temurin-21 AS build
WORKDIR /build
COPY .build/java/pom.xml .
COPY .build/java/src ./src
RUN mvn -B -ntp -DskipTests package

FROM eclipse-temurin:21-jre-jammy
RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --gid 10001 viacidada \
    && useradd --uid 10001 --gid viacidada --no-create-home viacidada
WORKDIR /opt/viacidada
COPY --from=build --chown=10001:10001 /build/target/viacidada-api-0.0.1-SNAPSHOT.jar app.jar
USER 10001:10001
EXPOSE 8080
HEALTHCHECK --interval=15s --timeout=5s --start-period=120s --retries=8 \
    CMD curl --fail --silent http://127.0.0.1:8080/actuator/health || exit 1
ENTRYPOINT ["java", "-jar", "app.jar"]
