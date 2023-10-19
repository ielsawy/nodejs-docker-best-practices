# FROM node:18.18.2--bullseye-slim
# ARG NPM_TOKEN
# RUN apt-get update && apt-get install -y --no-install-recommends dumb-init
# ARG NPM_TOKEN
# RUN echo "//registry.npmjs.org/:_authToken=$NPM_TOKEN" > .npmrc && \
#    npm ci --only=production; \
#    rm -rf .npmrc
# ENV NODE_ENV production
# ENV NPM_TOKEN 1234
# WORKDIR /usr/src/app
# COPY --chown=node:node . .
# RUN npm ci --only=production
# USER node
# CMD ["dumb-init", "node", "server.js"]

# --------------> The build image__
FROM node:latest AS build
RUN apt-get update && apt-get install -y --no-install-recommends dumb-init
ARG NPM_TOKEN
WORKDIR /usr/src/app
COPY package*.json /usr/src/app/
RUN --mount=type=secret,mode=0644,id=npmrc,target=/usr/src/app/.npmrc npm ci --only=production

# --------------> The production image__
FROM node:18.18.2

ENV NODE_ENV production
COPY --from=build /usr/bin/dumb-init /usr/bin/dumb-init
USER node
WORKDIR /usr/src/app
COPY --chown=node:node --from=build /usr/src/app/node_modules /usr/src/app/node_modules
COPY --chown=node:node . /usr/src/app
CMD ["dumb-init", "node", "server.js"]

