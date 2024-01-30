# Watchtower - Update your Docker container images automatically

## Quick Start
With watchtower you can update the running version of your containerized app simply by pushing a new image to the Docker Hub or your own image registry. 
Watchtower will pull down your new image, gracefully shut down your existing container and restart it with the same options that were used when it was deployed initially

This Docker Compose stack will run watchtower permanently, every day, every week, every month at 04:30 hours

## References
https://containrrr.dev/watchtower/
