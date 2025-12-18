# Use lightweight Java 21 runtime
FROM amazoncorretto:21-alpine

# Set working directory inside container
WORKDIR /app

# Copy built JAR from Maven target directory
COPY target/*.jar app.jar

# Expose application port (optional for console app)
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
