#!/bin/bash

# install docker
sudo curl -fsSL https://get.docker.com |bash

# install portainer
sudo docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce


##########################################################################################
#####################################JELYFIN##############################################
MEDIA_DIR="/media"

docker volume create jellyfin-config
#docker volume create jellyfin-cache

mkdir -p "$MEDIA_DIR"
mkdir "$MEDIA_DIR"/movies
mkdir "$MEDIA_DIR"/tv
mkdir "$MEDIA_DIR"/music

#docker run -d --name jellyfin -e PUID=1000 -e PGID=1000 -e TZ=America/New_York -p 8096:8096 -v jellyfin-config:/config --volume jellyfin-cache:/cache --mount type=bind,source="$MEDIA_DIR",target=/media/tv --restart=unless-stopped jellyfin/jellyfin
docker run -d --name=jellyfin -e PUID=1000 -e PGID=1000 -e TZ=America/New_York -p 8096:8096 -v jellyfin-config:/config -v "$MEDIA_DIR"/tv:/data/tvshows -v "$MEDIA_DIR/movies":/data/movies -v "$MEDIA_DIR/music":/data/music --restart unless-stopped lscr.io/linuxserver/jellyfin:latest

##########################################################################################

docker volume create nzbget-config

DOWNLOADS_DIR="/downloads"

mkdir -p "$DOWNLOADS_DIR"

docker run -d --name=nzbget -e PUID=1000 -e PGID=1000 -e TZ=America/New_York -e NZBGET_USER=nzbget -e NZBGET_PASS=DoomSlayer11235 -p 6789:6789 --volume nzbget-config:/config -v "$DOWNLOADS_DIR":/downloads --restart unless-stopped lscr.io/linuxserver/nzbget:latest

################################################

docker volume create sonarr-config

#mkdir "$MEDIA_DIR"/tv

docker run -d --name=sonarr -e PUID=1000 -e PGID=1000 -e TZ=America/New_York -p 8989:8989 --volume sonarr-config:/config -v "$MEDIA_DIR"/tv:/tv -v "$DOWNLOADS_DIR":/downloads --restart unless-stopped lscr.io/linuxserver/sonarr:latest

#########################

docker volume create radarr-config

docker run -d --name=radarr -e PUID=1000 -e PGID=1000 -e TZ=America/New_York -p 7878:7878 -v radarr-config:/config -v "$MEDIA_DIR"/movies:/movies -v "$DOWNLOADS_DIR":/downloads --restart unless-stopped lscr.io/linuxserver/radarr:latest

###########################

docker volume create lidarr-config

docker run -d --name=lidarr -e PUID=1000 -e PGID=1000 -e TZ=America/New_York -p 8686:8686 -v lidarr-config:/config -v "$MEDIA_DIR"/music:/music -v "$DOWNLOADS_DIR":/downloads --restart unless-stopped lscr.io/linuxserver/lidarr:latest

#################################

docker volume create ombi-config

docker run -d --name=ombi -e PUID=1000 -e PGID=1000 -e TZ=America/New_York -p 3579:3579 -v ombi-config:/config --restart unless-stopped lscr.io/linuxserver/ombi:latest

#################################

docker volume create organizr-config

docker run -d --name=organizr -v organizr-config:/config -e PGID=1000 -e PUID=1000 -p 80:80 -e fpm="false" -e branch="v2-master" organizr/organizr

#################################

