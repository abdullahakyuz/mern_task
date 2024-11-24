import React, { useEffect, useState } from 'react';
import './App.css';
import log from './utils/logger';

function App() {
  const [data, setData] = useState(null); // API'den gelen veri için state
  const [error, setError] = useState(null); // Hata mesajları için state

  // API çağrısı
  useEffect(() => {
    log.info('API çağrısı başlatılıyor...');

    fetch('http://express-backend:5000/api-endpoint') // Backend URL'i
      .then((response) => {
        if (!response.ok) {
          throw new Error('API isteği başarısız!');
        }
        return response.json();
      })
      .then((result) => {
        log.info('API isteği başarılı: ', result); // Başarılı API isteği logu
        setData(result);
      })
      .catch((err) => {
        log.error(`API isteği hatası: ${err.message}`); // Hata logu
        setError(err.message);
      });
  }, []);

  return (
    <div className="App">
      <header className="App-header">
        <h1>React + Backend</h1>
        {error ? (
          <p style={{ color: 'red' }}>Hata: {error}</p> // Hata mesajını göster
        ) : (
          <p>{data ? data.message : 'Yükleniyor...'}</p> // API'den gelen mesaj
        )}
      </header>
    </div>
  );
}

export default App;
