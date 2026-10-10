FROM eclipse-temurin:25-jre-alpine

WORKDIR /app

# Install bash, curl, jq
RUN apk add --no-cache curl bash jq

# Copy repository configurations
COPY . /app

# Ensure plugins directory exists and clean legacy Bungee jars
RUN mkdir -p /app/plugins && \
    rm -rf /app/plugins/ViaBungee.jar /app/plugins/ViaVersion /app/plugins/ViaBackwards.jar /app/Waterfall.jar

# Download active Velocity release dynamically using PaperMC v2 API
RUN VER=$(curl -sL -H "User-Agent: EaglercraftGateway/1.0" "https://api.papermc.io/v2/projects/velocity" | jq -r '.versions[-1]') && \
    BUILD_NUM=$(curl -sL -H "User-Agent: EaglercraftGateway/1.0" "https://api.papermc.io/v2/projects/velocity/versions/${VER}/builds" | jq -r '.builds[-1]') && \
    JAR_NAME=$(curl -sL -H "User-Agent: EaglercraftGateway/1.0" "https://api.papermc.io/v2/projects/velocity/versions/${VER}/builds/${BUILD_NUM}" | jq -r '.downloads.application.name') && \
    curl -fsSL -H "User-Agent: EaglercraftGateway/1.0" -o /app/velocity.jar "https://api.papermc.io/v2/projects/velocity/versions/${VER}/builds/${BUILD_NUM}/downloads/${JAR_NAME}"

# Download native ViaVersion for Velocity from Modrinth
RUN VIA_URL=$(curl -sL "https://api.modrinth.com/v2/project/viaversion/version" | jq -r '.[0].files[0].url') && \
    curl -fsSL -o /app/plugins/ViaVersion.jar "$VIA_URL"

# Generate start.sh for Velocity
RUN echo '#!/bin/bash' > /app/start.sh && \
    echo 'echo "Starting Velocity Eaglercraft Gateway..."' >> /app/start.sh && \
    echo 'exec java -Xms256M -Xmx512M -XX:+UseG1GC -jar /app/velocity.jar' >> /app/start.sh && \
    chmod +x /app/start.sh

EXPOSE 25577

CMD ["/bin/bash", "/app/start.sh"]
