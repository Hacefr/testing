FROM eclipse-temurin:25-jre-alpine

WORKDIR /app

# Install bash, curl, jq
RUN apk add --no-cache curl bash jq

# Copy configurations
COPY . /app

# Ensure plugins directory structure exists and remove legacy Bungee artifacts
RUN mkdir -p /app/plugins/eaglerxserver && \
    rm -rf /app/plugins/ViaBungee.jar /app/plugins/ViaVersion /app/Waterfall.jar

# Download active Velocity core
RUN curl -fsSL -o /app/velocity.jar "https://mineacademy.org/api/velocity/latest"

# Download native ViaVersion & ViaBackwards for Velocity from Modrinth
RUN VIA_URL=$(curl -sL "https://api.modrinth.com/v2/project/viaversion/version" | jq -r '.[0].files[0].url') && \
    curl -fsSL -o /app/plugins/ViaVersion.jar "$VIA_URL"

RUN VIAB_URL=$(curl -sL "https://api.modrinth.com/v2/project/viabackwards/version" | jq -r '.[0].files[0].url') && \
    curl -fsSL -o /app/plugins/ViaBackwards.jar "$VIAB_URL"

# Generate start.sh for Velocity
RUN echo '#!/bin/bash' > /app/start.sh && \
    echo 'echo "Starting Velocity Eaglercraft Gateway..."' >> /app/start.sh && \
    echo 'exec java -Xms256M -Xmx512M -XX:+UseG1GC -jar /app/velocity.jar' >> /app/start.sh && \
    chmod +x /app/start.sh

EXPOSE 25577

CMD ["/bin/bash", "/app/start.sh"]
