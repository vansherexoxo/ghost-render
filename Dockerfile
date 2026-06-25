FROM ghost:5-alpine
RUN cd /var/lib/ghost/versions/5.130.6 && npm install pg --save --legacy-peer-deps
COPY start.sh /start.sh
RUN chmod +x /start.sh
ENTRYPOINT ["/start.sh"]
