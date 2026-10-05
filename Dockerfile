FROM eclipse-temurin:21-jdk
LABEL authors="andre"

RUN addgroup --system spring && adduser --system --ingroup spring spring
USER spring:spring

ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
