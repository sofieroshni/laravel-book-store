# Node 20
FROM node:20-alpine

WORKDIR /app

# Kopier package filer
COPY package.json package-lock.json ./

# Installer dependencies
RUN npm install

# Kopier resten af frontend
COPY . .

# Byg Next.js appen
RUN npm run build

EXPOSE 3000

CMD ["npm", "start"]
