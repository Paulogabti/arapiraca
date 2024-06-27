const express = require('express');
const mysql = require('mysql');
const bodyParser = require('body-parser');
const app = express();

app.use(bodyParser.json());

const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: 'your_password',
  database: 'your_database'
});

db.connect(err => {
  if (err) throw err;
  console.log('Connected to database');
});

app.post('/register', (req, res) => {
  const { name, email, password_hash } = req.body;
  const query = 'INSERT INTO users (name, email, password_hash) VALUES (?, ?, ?)';
  db.query(query, [name, email, password_hash], (err, result) => {
    if (err) {
      console.error(err);
      res.status(500).send('Error registering user');
    } else {
      res.status(200).send('User registered');
    }
  });
});

app.listen(3000, () => {
  console.log('Server running on port 3000');
});
