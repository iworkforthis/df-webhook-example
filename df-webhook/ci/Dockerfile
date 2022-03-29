FROM node:16.2.0-alpine

COPY --chown=1000 /server /server

WORKDIR /server

USER node

EXPOSE 3000

CMD ["node", "server.mjs"]