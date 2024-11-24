const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const winston = require('winston');
const app = express();

// Winston Logger Ayarları
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.Console(), // Konsola yaz
    new winston.transports.File({ filename: 'backend.log' }) // backend.log dosyasına yaz
  ]
});

// Middleware
app.use(cors()); // CORS yapılandırması
app.use(express.json());

// MongoDB Bağlantısı
mongoose.connect('mongodb://mongodb:27017/mern-db', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
  .then(() => {
    logger.info('MongoDB bağlantısı başarılı!');
  })
  .catch((err) => {
    logger.error('MongoDB bağlantısı başarısız: ', err);
  });

// Test Endpoint
app.get('/', (req, res) => {
  logger.info('Ana endpoint çağrıldı.');
  res.send('Express.js Backend çalışıyor!');
});

// API Endpoint
app.get('/api-endpoint', (req, res) => {
  logger.info('API endpoint çağrıldı.');
  res.json({ message: "API'den veri başarıyla alındı!" });
});

// Hata Yakalama Middleware
app.use((err, req, res, next) => {
  logger.error(`Hata: ${err.message}`);
  res.status(500).json({ error: err.message });
});

// Sunucu Başlatma
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  logger.info(`Sunucu ${PORT} portunda çalışıyor.`);
});
