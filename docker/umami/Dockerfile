FROM ghcr.io/umami-software/umami:latest

USER root
COPY fetch-ca.sh /usr/local/bin/fetch-ca.sh
RUN chmod +x /usr/local/bin/fetch-ca.sh
USER nextjs

ENTRYPOINT ["/usr/local/bin/fetch-ca.sh"]
