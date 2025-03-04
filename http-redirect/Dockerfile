FROM oven/bun:alpine

WORKDIR /app

COPY index.js ./
COPY *.json ./

RUN bun install

EXPOSE 3000

CMD ["bun", "start"]
