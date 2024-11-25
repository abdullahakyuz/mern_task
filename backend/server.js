const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const app = express();

// CORS yapılandırmasını etkinleştirin
app.use(cors());  // Bu, tüm origin'lere izin verir.

// MongoDB bağlantı ayarları (Docker Compose'da servis adı kullanılarak güncellendi)
mongoose.connect('mongodb://mongodb:27017/mern-db', {  // "mongodb" burada servis adıdır
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
  .then(() => {
    console.log('MongoDB bağlantısı başarılı!');
  })
  .catch((err) => {
    console.error('MongoDB bağlantısı başarısız: ', err);
  });

// Middleware
app.use(express.json());

// Basit bir GET isteği ile test endpoint
app.get('/', (req, res) => {
  res.send('Express.js Backend çalışıyor!');
});

// API endpoint
app.get('/api-endpoint', (req, res) => {
  res.json({ message: "API'den veri başarıyla alındı!" });
});

// Backend uygulaması 5000 portunda çalışacak
const PORT = process.env.PORT || 5000;
app.listen(3000, '0.0.0.0', () => {
  console.log(`Server ${PORT} portunda çalışıyor.`);
});
