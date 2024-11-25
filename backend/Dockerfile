# Express backend için gerekli adımlar
FROM node:18

WORKDIR /app

# package.json ve package-lock.json dosyalarını kopyala
COPY package*.json ./

# Bağımlılıkları yükle (cors dahil)
RUN npm install

# Uygulamanın kaynak kodlarını kopyala
COPY . .

# Uygulama çalıştırma komutunu belirt
CMD ["npm", "start"]