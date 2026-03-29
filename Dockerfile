# Stage 1: Build the application
FROM maven:3.9.6-eclipse-temurin-17 AS builder
WORKDIR /app

# Copy the pom.xml and download dependencies first to cache them
COPY pom.xml .
# Download dependencies for offline testing
RUN mvn dependency:go-offline -B

# Copy the source code
COPY src ./src

# Build the application (using 'prod' profile if necessary, but skipping tests for speed)
RUN mvn clean package -DskipTests

# Stage 2: Create the runtime image
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# The pom.xml specifies <finalName>leaselink-backend</finalName>
COPY --from=builder /app/target/leaselink-backend.jar app.jar

# Expose the application port
EXPOSE 8080

# Environment variables for JVM tuning (Targeting a 2GB EC2 t3.small, giving max 1GB to JVM heap)
ENV JAVA_OPTS="-Xms512m -Xmx1024m -XX:+UseG1GC"
ENV SPRING_PROFILES_ACTIVE="prod"

# Run the application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
