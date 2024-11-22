const express = require('express');
const mongoose = require('mongoose');

const app = express();
const PORT = 5000;

// MongoDB bağlantısı
mongoose.connect('mongodb://mongo:27017/mern-db', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

mongoose.connection.once('open', () => {
  console.log('MongoDB bağlantısı başarılı!');
});

app.get('/', (req, res) => {
  res.send('MERN Backend çalışıyor!');
});

app.listen(PORT, () => console.log(`Server ${PORT} portunda çalışıyor`));
