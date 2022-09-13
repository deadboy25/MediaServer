#!/bin/bash

apt-get update

MEDIA_DIR="/media"
DOWNLOADS_DIR="/downloads"
NGINX_PROXY_MANAGER_DIR="/tmp/nginxproxymanager"
CURR_DIR="${pwd}"

mkdir -p "$MEDIA_DIR"
mkdir "$MEDIA_DIR"/movies
mkdir "$MEDIA_DIR"/tv
mkdir "$MEDIA_DIR"/music
mkdir -p "$DOWNLOADS_DIR"
mkdir -p "$NGINX_PROXY_MANAGER_DIR"

# install docker
echo "Installing Docker"
sudo curl -fsSL https://get.docker.com |bash || sleep 10

# install docker compose
echo "Installing Docker Compose"
apt-get install docker-compose-plugin

# install portainer
echo "Installing Portainer"
sudo docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce
sleep 5

# create volumes
echo "Creating required volumes"
docker volume create jellyfin-config
docker volume create nzbget-config
docker volume create sonarr-config
docker volume create radarr-config
docker volume create lidarr-config
docker volume create ombi-config
docker volume create organizr-config

# create containers
echo "Creating Jellyfin container"
docker run -d --name=jellyfin -e PUID=1000 -e PGID=1000 -e TZ=America/New_York -p 8096:8096 -v jellyfin-config:/config -v "$MEDIA_DIR"/tv:/data/tvshows -v "$MEDIA_DIR/movies":/data/movies -v "$MEDIA_DIR/music":/data/music --restart unless-stopped lscr.io/linuxserver/jellyfin:latest

echo "Creating NZBGet container"
docker run -d --name=nzbget -e PUID=1000 -e PGID=1000 -e TZ=America/New_York -e NZBGET_USER=nzbget -e NZBGET_PASS=DoomSlayer11235 -p 6789:6789 --volume nzbget-config:/config -v "$DOWNLOADS_DIR":/downloads --restart unless-stopped lscr.io/linuxserver/nzbget:latest

echo "Creating Sonarr container"
docker run -d --name=sonarr -e PUID=1000 -e PGID=1000 -e TZ=America/New_York -p 8989:8989 --volume sonarr-config:/config -v "$MEDIA_DIR"/tv:/tv -v "$DOWNLOADS_DIR":/downloads --restart unless-stopped lscr.io/linuxserver/sonarr:latest

echo "Creating Radarr container"
docker run -d --name=radarr -e PUID=1000 -e PGID=1000 -e TZ=America/New_York -p 7878:7878 -v radarr-config:/config -v "$MEDIA_DIR"/movies:/movies -v "$DOWNLOADS_DIR":/downloads --restart unless-stopped lscr.io/linuxserver/radarr:latest

echo "Creating Lidarr contianer"
docker run -d --name=lidarr -e PUID=1000 -e PGID=1000 -e TZ=America/New_York -p 8686:8686 -v lidarr-config:/config -v "$MEDIA_DIR"/music:/music -v "$DOWNLOADS_DIR":/downloads --restart unless-stopped lscr.io/linuxserver/lidarr:latest

echo "Creating Ombi container"
docker run -d --name=ombi -e PUID=1000 -e PGID=1000 -e TZ=America/New_York -p 3579:3579 -v ombi-config:/config --restart unless-stopped lscr.io/linuxserver/ombi:latest

echo "Creating Organizr container"
docker run -d --name=organizr -v organizr-config:/config -e PGID=1000 -e PUID=1000 -p 8080:80 -e fpm="false" -e branch="v2-master" organizr/organizr

echo "Creating Nginx Proxy Manager container and its required database container"
cp "$CURR_DIR"/docker-compose.yml "$NGINX_PROXY_MANAGER_DIR"/
cd "$NGINX_PROXY_MANAGER_DIR"/
docker compose up -d && rm -r "$NGINX_PROXY_MANAGER_DIR"

# TODO: Install VPN
