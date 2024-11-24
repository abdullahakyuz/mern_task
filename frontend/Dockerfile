# 1. Kullanılacak temel imaj
FROM node:18 AS build

# 2. Çalışma dizini oluştur ve belirle
WORKDIR /app

# 3. Bağımlılık dosyalarını (package.json ve package-lock.json) kopyala
COPY package*.json ./

# 4. Bağımlılıkları yükle
RUN npm install

# 5. React uygulaması kaynak kodunu kopyala
COPY . .

# 6. React uygulamasını derle (build)
RUN npm run build

# 7. Üretim ortamı için bir web sunucusu (Nginx) kullan
FROM nginx:alpine

# 8. Derlenen uygulamayı Nginx'in varsayılan dizinine kopyala
COPY --from=build /app/build /usr/share/nginx/html

# 9. Nginx için birden fazla port açabiliriz (React için genelde 80)
EXPOSE 80

# 10. Nginx'i çalıştır
CMD ["nginx", "-g", "daemon off;"]
