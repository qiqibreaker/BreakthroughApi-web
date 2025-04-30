FROM node:20-alpine
WORKDIR /app

COPY package*.json ./
RUN apk add --no-cache xdg-utils
RUN npm install --include=dev

COPY . .

EXPOSE 9229 3000
CMD ["npm", "run", "dev"]
