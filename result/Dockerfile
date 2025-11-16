FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci --production
COPY . .

FROM node:18-alpine
WORKDIR /app
RUN addgroup resultgroup && adduser -H -D -G resultgroup resultuser
COPY --from=build /app /app
RUN chown -R resultuser:resultgroup /app
USER resultuser
COPY  package*.json .
EXPOSE 81
CMD [ "node","server.js" ]

