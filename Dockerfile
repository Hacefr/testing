FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Install bash, curl, jq
RUN apk add --no-cache curl bash jq

# Download official BungeeCord core
RUN curl -fsSL -o Waterfall.jar "https://ci.md-5.net/job/BungeeCord/lastSuccessfulBuild/artifact/bootstrap/target/BungeeCord.jar"

# Copy configurations
COPY . /app

# Ensure plugins directory exists
RUN mkdir -p /app/plugins

# Download real latest ViaVersion & ViaBackwards release jars
RUN VIA_URL=$(curl -sL https://api.github.com/repos/ViaVersion/ViaVersion/releases/latest | jq -r '.assets[] | select(.name | endswith(".jar")) | .browser_download_url' | head -n 1) && \
    curl -fsSL -o /app/plugins/ViaVersion.jar "$VIA_URL"

RUN VIAB_URL=$(curl -sL https://api.github.com/repos/ViaVersion/ViaBackwards/releases/latest | jq -r '.assets[] | select(.name | endswith(".jar")) | .browser_download_url' | head -n 1) && \
    curl -fsSL -o /app/plugins/ViaBackwards.jar "$VIAB_URL"

# Create start.sh
RUN echo '#!/bin/bash' > /app/start.sh && \
    echo 'echo "Starting Eaglercraft Gateway Proxy..."' >> /app/start.sh && \
    echo 'exec java -Xms256M -Xmx512M -jar /app/Waterfall.jar' >> /app/start.sh && \
    chmod +x /app/start.sh

EXPOSE 25577

CMD ["/bin/bash", "/app/start.sh"]