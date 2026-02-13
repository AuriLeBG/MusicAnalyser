# ===========================================
# Base Builder Stage - Common for both modes
# ===========================================

FROM eclipse-temurin:21-jdk-noble AS base

WORKDIR /app

# Copy Gradle wrapper and build files (better layer caching)
COPY gradlew .
COPY gradle gradle
COPY build.gradle .
COPY settings.gradle .

RUN apt-get update && apt-get install -y bash && rm -rf /var/lib/apt/lists/*

# Make gradlew executable and download dependencies
RUN chmod +x gradlew
RUN ./gradlew dependencies --no-daemon

# ===========================================
# Production Build Stage
# ===========================================

FROM base AS builder-production

# Copy source code
COPY src src

# Build JAR with tests
RUN ./gradlew test bootJar --no-daemon

# ===========================================
# Production Runtime Stage
# ===========================================

FROM base AS production

WORKDIR /app

# Copy built JAR
COPY --from=builder-production /app/build/libs/*.jar app.jar

ENTRYPOINT ["java", "-jar", "app.jar"]

# ===========================================
# Development Stage
# ===========================================

FROM base AS development

# Copy source code
COPY src src

# Run continuous compilation in background + bootRun for hot reload
# compileJava --continuous watches src/ for changes and recompiles
# DevTools then detects class changes in build/classes/ and restarts the app
CMD bash -c "./gradlew compileJava --continuous & ./gradlew bootRun --args='--spring.profiles.active=docker'"








# Installation de bash
# RUN apt-get update && apt-get install -y bash && rm -rf /var/lib/apt/lists/*

# CMD ["./gradlew", "bootRun", "--args='--spring.profiles.active=docker'", "--continuous"]