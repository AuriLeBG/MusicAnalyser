FROM eclipse-temurin:21-jdk-noble

WORKDIR /app

# Installation de bash
RUN apt-get update && apt-get install -y bash && rm -rf /var/lib/apt/lists/*

CMD ["./gradlew", "bootRun", "--args='--spring.profiles.active=docker'", "--continuous"]