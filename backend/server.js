const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const app = express();


app.use(cors());  

mongoose.connect('mongodb://mongodb:27017/mern-db', {  
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
  .then(() => {
    console.log('MongoDB bağlantısı başarılı!');
  })
  .catch((err) => {
    console.error('MongoDB bağlantısı başarısız: ', err);
  });

app.use(express.json());

app.get('/', (req, res) => {
  res.send('Express.js Backend çalışıyor!');
});

app.get('/api-endpoint', (req, res) => {
  res.json({ message: "API'den veri başarıyla alındı!" });
});

// Backend uygulaması 5000 portunda çalışacak
const PORT = process.env.PORT || 5000;
app.listen(3000, '0.0.0.0', () => {
  console.log(`Server ${PORT} portunda çalışıyor.`);
});

