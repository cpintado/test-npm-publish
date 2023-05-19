FROM ubuntu:22.04
LABEL org.opencontainers.description="Publishes an empty NPM package to GitHub Packages"
LABEL org.opencontainers.image.source="https://github.com/cpintado/test-npm-publish"
LABEL org.opencontainers.image.licenses="MIT"
LABEL maintainer="Carlos Pintado"
LABEL org.opencontainers.image.authors="Carlos Pintado"

WORKDIR /home/build
RUN apt update && apt install npm -y
COPY entrypoint.sh ./
RUN chmod +x entrypoint.sh
ENTRYPOINT ["./entrypoint.sh"]
