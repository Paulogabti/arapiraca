const express = require('express');
const mysql = require('mysql2');
const bodyParser = require('body-parser');
const cors = require('cors');
const app = express();

app.use(cors());
app.use(bodyParser.json());

const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '1234', // Substitua '1234' pela sua senha atual
  database: 'Flutter' // Nome do seu banco de dados
});

db.connect(err => {
  if (err) {
    console.error('Erro ao conectar ao banco de dados:', err);
    return;
  }
  console.log('Conectado ao banco de dados');
});

app.post('/register', (req, res) => {
  const { name, email, password } = req.body;
  const query = 'INSERT INTO users (name, email, password_hash) VALUES (?, ?, ?)';
  db.query(query, [name, email, password], (err, result) => {
    if (err) {
      console.error(err);
      res.status(500).send('Erro ao registrar usuário');
    } else {
      res.status(200).send('Usuário registrado');
    }
  });
});

app.post('/login', (req, res) => {
  const { email, password } = req.body;
  const query = 'SELECT * FROM users WHERE email = ? AND password_hash = ?';
  db.query(query, [email, password], (err, results) => {
    if (err) {
      console.error(err);
      res.status(500).send('Erro ao fazer login');
    } else if (results.length > 0) {
      const user = results[0];
      res.status(200).json({ user: { id: user.id.toString(), email: user.email } });
    } else {
      res.status(401).send('Credenciais inválidas');
    }
  });
});

app.post('/licitacoes', (req, res) => {
  const { numero, modalidade, objeto, responsavel, status, user_id } = req.body;
  const query = 'INSERT INTO licitacoes (numero, modalidade, objeto, responsavel, status, user_id) VALUES (?, ?, ?, ?, ?, ?)';
  db.query(query, [numero, modalidade, objeto, responsavel, status, user_id], (err, result) => {
    if (err) {
      console.error(err);
      res.status(500).send('Erro ao adicionar licitação');
    } else {
      res.status(201).send('Licitação adicionada');
    }
  });
});

app.get('/licitacoes', (req, res) => {
  const { user_id } = req.query;
  const query = 'SELECT * FROM licitacoes WHERE user_id = ?';
  db.query(query, [user_id], (err, results) => {
    if (err) {
      console.error(err);
      res.status(500).send('Erro ao buscar licitações');
    } else {
      res.status(200).json(results);
    }
  });
});

app.put('/licitacoes/:id', (req, res) => {
  const { id } = req.params;
  const { numero, modalidade, objeto, responsavel, status } = req.body;
  const query = 'UPDATE licitacoes SET numero = ?, modalidade = ?, objeto = ?, responsavel = ?, status = ? WHERE id = ?';
  db.query(query, [numero, modalidade, objeto, responsavel, status, id], (err, result) => {
    if (err) {
      console.error(err);
      res.status(500).send('Erro ao atualizar licitação');
    } else {
      res.status(200).send('Licitação atualizada');
    }
  });
});

app.delete('/licitacoes/:id', (req, res) => {
  const { id } = req.params;
  const query = 'DELETE FROM licitacoes WHERE id = ?';
  db.query(query, [id], (err, result) => {
    if (err) {
      console.error(err);
      res.status(500).send('Erro ao deletar licitação');
    } else {
      res.status(200).send('Licitação deletada');
    }
  });
});

app.post('/update-password', (req, res) => {
  const { userId, currentPassword, newPassword } = req.body;
  const query = 'SELECT * FROM users WHERE id = ? AND password_hash = ?';
  db.query(query, [userId, currentPassword], (err, results) => {
    if (err) {
      console.error(err);
      res.status(500).send('Erro ao verificar senha atual');
    } else if (results.length > 0) {
      const updateQuery = 'UPDATE users SET password_hash = ? WHERE id = ?';
      db.query(updateQuery, [newPassword, userId], (updateErr, updateResult) => {
        if (updateErr) {
          console.error(updateErr);
          res.status(500).send('Erro ao atualizar a senha');
        } else {
          res.status(200).send('Senha atualizada com sucesso');
        }
      });
    } else {
      res.status(401).send('Senha atual incorreta');
    }
  });
});

app.listen(3000, () => {
  console.log('Servidor rodando na porta 3000');
});
