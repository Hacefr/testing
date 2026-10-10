FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Install bash, curl
RUN apk add --no-cache curl bash

# Download official BungeeCord core
RUN curl -fsSL -o Waterfall.jar "https://ci.md-5.net/job/BungeeCord/lastSuccessfulBuild/artifact/bootstrap/target/BungeeCord.jar"

# Copy configurations
COPY . /app

# Ensure plugins directory exists
RUN mkdir -p /app/plugins

# Download ViaVersion & ViaBackwards so BungeeCord accepts 1.21.6 packets
RUN curl -fsSL -o /app/plugins/ViaVersion.jar "https://github.com/ViaVersion/ViaVersion/releases/latest/download/ViaVersion.jar" || true
RUN curl -fsSL -o /app/plugins/ViaBackwards.jar "https://github.com/ViaVersion/ViaBackwards/releases/latest/download/ViaBackwards.jar" || true

# Create the missing start.sh script inside the container
RUN echo '#!/bin/bash' > /app/start.sh && \
    echo 'echo "Starting Eaglercraft Gateway Proxy..."' >> /app/start.sh && \
    echo 'exec java -Xms256M -Xmx512M -jar /app/Waterfall.jar' >> /app/start.sh && \
    chmod +x /app/start.sh

EXPOSE 10000

CMD ["/bin/bash", "/app/start.sh"]