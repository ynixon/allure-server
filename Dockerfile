# Stage 1: Build the application
FROM gradle:6.9.2-jdk11 as build
WORKDIR /app
COPY . .
ARG RELEASE_VERSION=${RELEASE_VERSION:-0.0.0}
RUN gradle -Pversion=docker -i -s --no-daemon bootJar

# Stage 2: Create the production image
FROM adoptopenjdk:11-jre-hotspot as production
WORKDIR /app

# Verify Java installation
RUN java -version

COPY --from=build /app/build/libs/allure-server-docker.jar /app/allure-server-docker.jar
EXPOSE ${PORT:-8080}
ENV JAVA_OPTS="-Xms256m -Xmx2048m"
ENTRYPOINT ["java", "-Dloader.path=/ext", "-cp", "allure-server-docker.jar", "-Dspring.profiles.active=${SPRING_PROFILES_ACTIVE:default}", "org.springframework.boot.loader.PropertiesLauncher"]

