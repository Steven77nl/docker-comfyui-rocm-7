# Create .env file
echo "USER_UID=$(id -u)" > .env
echo "USER_GID=$(id -g)" >> .env
echo "RENDER_GID=$(getent group render | cut -d: -f3)" >> .env
echo "VIDEO_GID=$(getent group video | cut -d: -f3)" >> .env

# Run docker container as configured in the docker-compose.yml
docker compose up
