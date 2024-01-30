# Installation process

## Get Docker Compose stacks ready

On your home directory of your Linux host (please avoid root user), create your configuration files and Docker Compose stack:
```

mkdir -p $HOME/crowdsec/config

cat <<EOF >$HOME/crowdsec/docker-compose.yml
version: '3.8'
services:
  crowdsec:
    image: crowdsecurity/crowdsec:latest
    container_name: crowdsec
    environment:
      GID: "${GID-1000}"
      COLLECTIONS: "crowdsecurity/linux crowdsecurity/traefik"
    # depends_on:  #uncomment if running traefik in the same compose file
    #   - 'traefik'
    volumes:
      - ${HOME}/crowdsec/config/acquis.yaml:/etc/crowdsec/acquis.yaml
      - crowdsec-db:/var/lib/crowdsec/data/
      - crowdsec-config:/etc/crowdsec/
      - traefik_traefik_logs:/var/log/traefik/:ro
    networks:
      - traefik_default
    restart: unless-stopped

  bouncer-traefik:
    image: docker.io/fbonalair/traefik-crowdsec-bouncer:latest
    container_name: bouncer-traefik
    environment:
      PORT: 8082
      CROWDSEC_BOUNCER_API_KEY: \$CROWDSEC_API_KEY
      CROWDSEC_AGENT_HOST: crowdsec:8080
    ports:
      - "8082:8080"
    networks:
      - traefik_default # same network as traefik + crowdsec
    depends_on:
      - crowdsec
    restart: unless-stopped

  whoami:
    image: traefik/whoami
    container_name: "simple-whoami-service"
    labels:
      # Traefik routing to this service
      - "traefik.enable=true"
      - "traefik.http.routers.whoami.rule=Host('whoami-docker.home.techfitsu.org')"
      - "traefik.http.routers.whoami.entrypoints=websecure"
      - "traefik.http.routers.whoami.middlewares=crowdsec-bouncer@file"
      - "traefik.http.services.whoami.loadbalancer.server.port=80"
      - "traefik.http.routers.whoami.service=whoami"
      - "traefik.http.routers.whoami.tls=true"
      - "traefik.http.routers.whoami.tls.certresolver=production"
    
    

networks:
  traefik_default:
    external: true
volumes:
  crowdsec-db:
  crowdsec-config:
  traefik_traefik_logs: # this will be the name of the volume from traefik logs
    external: true # remove if traefik is running on same stack
EOF


cat <<EOF >$HOME/crowdsec/config/acquis.yml
filenames:
  - /var/log/traefik/*
labels:
  type: traefik

EOF


```


## Run CrowdSec containers for the first time to obtain the API key
```
docker-compose up -d --force-recreate
docker exec crowdsec cscli bouncers add bouncer-traefik

# Important: save api key somewhere and export it as CROWDSEC_API_KEY

CROWDSEC_API_KEY=yourkey
# Rerun the containers
docker compose up -d --force-recreate

```

# References:
https://github.com/fbonalair/traefik-crowdsec-bouncer
https://technotim.live/posts/crowdsec-traefik/