FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Install bash, curl, jq
RUN apk add --no-cache curl bash jq

# Download official BungeeCord core
RUN curl -fsSL -o Waterfall.jar "https://ci.md-5.net/job/BungeeCord/lastSuccessfulBuild/artifact/bootstrap/target/BungeeCord.jar"

# Copy configurations
COPY . /app

# Clean any Bukkit jars directly in plugins folder
RUN mkdir -p /app/plugins /app/plugins/ViaVersion && \
    rm -f /app/plugins/ViaVersion.jar /app/plugins/ViaBackwards.jar

# 1. Download official ViaBungee loader to /app/plugins/
RUN VIABUNGEE_URL=$(curl -sL https://api.github.com/repos/ViaVersion/ViaBungee/releases/latest | jq -r '.assets[] | select(.name | endswith(".jar")) | .browser_download_url' | head -n 1) && \
    curl -fsSL -o /app/plugins/ViaBungee.jar "$VIABUNGEE_URL"

# 2. Download core ViaVersion into /app/plugins/ViaVersion/
RUN VIA_URL=$(curl -sL "https://api.modrinth.com/v2/project/viaversion/version" | jq -r '.[0].files[0].url') && \
    curl -fsSL -o /app/plugins/ViaVersion/ViaVersion.jar "$VIA_URL"

# Create start.sh
RUN echo '#!/bin/bash' > /app/start.sh && \
    echo 'echo "Starting Eaglercraft Gateway Proxy..."' >> /app/start.sh && \
    echo 'exec java -Xms256M -Xmx512M -jar /app/Waterfall.jar' >> /app/start.sh && \
    chmod +x /app/start.sh

EXPOSE 25577

CMD ["/bin/bash", "/app/start.sh"]
