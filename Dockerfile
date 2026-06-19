FROM node:22-alpine

WORKDIR /app

COPY package.json ./
COPY app ./app

ENV NODE_ENV=production
ENV PORT=3000

USER node

EXPOSE 3000

HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://127.0.0.1:3000/health || exit 1

CMD ["node", "app/server.js"]

