# Node + npm you asked for
FROM node:22.20.0-alpine

# Pin npm
RUN npm i -g npm@10.9.3

# Workdir
WORKDIR /opt

# Init a fresh package.json in the image and make it ESM
RUN npm init -y \
 && npm pkg set type=module \
 && npm pkg set scripts.start="node server.js" \
 && npm install express alpinejs express-rate-limit --omit=dev

# App files + static assets
COPY server.js ./
COPY static ./static

ENV NODE_ENV=production
EXPOSE 3000

CMD ["node", "server.js"]