FROM node:22-alpine AS build
WORKDIR /app
COPY src/ui/web-app/package*.json ./
RUN npm ci
COPY src/ui/web-app/ ./
RUN npm run build

FROM nginx:1.27-alpine AS final
COPY infra/nginx/default.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
