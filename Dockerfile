FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Install bash, curl, jq
RUN apk add --no-cache curl bash jq

# Download official BungeeCord core
RUN curl -fsSL -o Waterfall.jar "https://ci.md-5.net/job/BungeeCord/lastSuccessfulBuild/artifact/bootstrap/target/BungeeCord.jar"

# Copy configurations
COPY . /app

# Ensure plugins directory exists and clean out any broken jars
RUN mkdir -p /app/plugins && rm -f /app/plugins/ViaBackwards.jar

# Download real latest ViaVersion from Modrinth (no rate limits, supports BungeeCord)
RUN VIA_URL=$(curl -sL "https://api.modrinth.com/v2/project/viaversion/version" | jq -r '.[0].files[0].url') && \
    curl -fsSL -o /app/plugins/ViaVersion.jar "$VIA_URL"

# Create start.sh
RUN echo '#!/bin/bash' > /app/start.sh && \
    echo 'echo "Starting Eaglercraft Gateway Proxy..."' >> /app/start.sh && \
    echo 'exec java -Xms256M -Xmx512M -jar /app/Waterfall.jar' >> /app/start.sh && \
    chmod +x /app/start.sh

EXPOSE 25577

CMD ["/bin/bash", "/app/start.sh"]