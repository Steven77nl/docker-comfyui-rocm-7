echo "USER_UID=$(id -u)" > .env
echo "USER_GID=$(id -g)" >> .env

docker compose up
