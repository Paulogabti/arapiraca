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
      res.status(200).json({ user: { id: user.id.toString(), name: user.name, email: user.email } });
    } else {
      res.status(401).send('Credenciais inválidas');
    }
  });
});

app.post('/licitacoes', (req, res) => {
  const { numero, modalidade, numeroModalidade, objeto, status, data, observacoes, user_id } = req.body;

  if (!numeroModalidade) {
    res.status(400).send('numeroModalidade não pode ser nulo');
    return;
  }

  const queryUser = 'SELECT name FROM users WHERE id = ?';
  db.query(queryUser, [user_id], (err, userResult) => {
    if (err) {
      console.error('Erro ao buscar o responsável:', err);
      res.status(500).send('Erro ao buscar o responsável');
      return;
    }

    if (userResult.length === 0) {
      res.status(404).send('Usuário não encontrado');
      return;
    }

    const responsavel = userResult[0].name;

    const query = 'INSERT INTO licitacoes (numero, modalidade, numeroModalidade, objeto, responsavel, status, data, observacoes, user_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)';
    db.query(query, [numero, modalidade, numeroModalidade, objeto, responsavel, status, data, observacoes, user_id], (err, result) => {
      if (err) {
        console.error('Erro ao adicionar licitação:', err);
        res.status(500).send('Erro ao adicionar licitação');
      } else {
        res.status(201).send('Licitação adicionada');
      }
    });
  });
});

app.get('/licitacoes', (req, res) => {
  const { user_id, year } = req.query;

  let query = 'SELECT * FROM licitacoes';
  let queryParams = [];

  if (user_id) {
    query += ' WHERE user_id = ?';
    queryParams.push(user_id);
  }

  if (year) {
    query += user_id ? ' AND' : ' WHERE';
    query += ' YEAR(data) = ?';
    queryParams.push(year);
  }

  query += ' ORDER BY data DESC';

  db.query(query, queryParams, (err, results) => {
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
  const { numero, modalidade, numeroModalidade, objeto, status, data, observacoes, user_id } = req.body;

  const queryUser = 'SELECT name FROM users WHERE id = ?';
  db.query(queryUser, [user_id], (err, userResult) => {
    if (err) {
      console.error('Erro ao buscar o responsável:', err);
      res.status(500).send('Erro ao buscar o responsável');
      return;
    }

    if (userResult.length === 0) {
      res.status(404).send('Usuário não encontrado');
      return;
    }

    const responsavel = userResult[0].name;

    const queryUpdate = 'UPDATE licitacoes SET numero = ?, modalidade = ?, numeroModalidade = ?, objeto = ?, responsavel = ?, status = ?, data = ?, observacoes = ? WHERE id = ?';
    db.query(queryUpdate, [numero, modalidade, numeroModalidade, objeto, responsavel, status, data, observacoes, id], (err, result) => {
      if (err) {
        console.error('Erro ao atualizar licitação:', err);
        res.status(500).send('Erro ao atualizar licitação');
        return;
      }

      // Verificar se o status é um dos três específicos
      if (['Edital Publicado', 'Homologado', 'Contrato Publicado'].includes(status)) {
        // Verificar se já existe um histórico com o mesmo status e data
        const queryCheckHistorico = 'SELECT * FROM historico_status WHERE licitacao_id = ? AND status = ? AND data_status = ?';
        db.query(queryCheckHistorico, [id, status, data], (err, historicoResult) => {
          if (err) {
            console.error('Erro ao verificar histórico de status:', err);
            res.status(500).send('Erro ao verificar histórico de status');
            return;
          }

          if (historicoResult.length > 0) {
            res.status(400).json({ message: 'Já existe este status para esta mesma data no sistema' });
          } else {
            // Se não existe, insira no histórico
            const queryHistorico = 'INSERT INTO historico_status (licitacao_id, responsavel, modalidade, objeto, status, data_status, observacoes) VALUES (?, ?, ?, ?, ?, ?, ?)';
            db.query(queryHistorico, [id, responsavel, modalidade, objeto, status, data, observacoes], (err, historicoResult) => {
              if (err) {
                if (err.code === 'ER_DUP_ENTRY') {
                  res.status(400).json({ message: 'Duplicidade detectada' });
                } else {
                  console.error('Erro ao salvar histórico de status:', err);
                  res.status(500).send('Erro ao salvar histórico de status');
                }
              } else {
                res.status(200).send('Licitação atualizada');
              }
            });
          }
        });
      } else {
        res.status(200).send('Licitação atualizada sem alteração no histórico');
      }
    });
  });
});

app.delete('/licitacoes/:id', (req, res) => {
  const { id } = req.params;
  const query = 'DELETE FROM licitacoes WHERE id = ?';
  db.query(query, [id], (err, result) => {
    if (err) {
      console.error('Erro ao deletar licitação:', err);
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

app.post('/notes', (req, res) => {
  const { user_id, note_date, note } = req.body;

  // Verificar se o user_id existe na tabela users
  const queryUser = 'SELECT * FROM users WHERE id = ?';
  db.query(queryUser, [user_id], (err, userResult) => {
    if (err) {
      console.error('Erro ao verificar usuário:', err);
      res.status(500).send('Erro ao verificar usuário');
      return;
    }

    if (userResult.length === 0) {
      res.status(400).send('Usuário não encontrado');
      return;
    }

    // Inserir a anotação na tabela notes
    const query = 'INSERT INTO notes (user_id, note_date, note) VALUES (?, ?, ?)';
    db.query(query, [user_id, note_date, note], (err, result) => {
      if (err) {
        console.error('Erro ao adicionar anotação:', err);
        res.status(500).send('Erro ao adicionar anotação');
      } else {
        res.status(201).send('Anotação adicionada');
      }
    });
  });
});

app.get('/notes', (req, res) => {
  const { user_id } = req.query;

  let query = 'SELECT * FROM notes';
  let queryParams = [];

  if (user_id) {
    query += ' WHERE user_id = ?';
    queryParams.push(user_id);
  }

  query += ' ORDER BY note_date DESC';

  db.query(query, queryParams, (err, results) => {
    if (err) {
      console.error('Erro ao buscar anotações:', err);
      res.status(500).send('Erro ao buscar anotações');
    } else {
      res.status(200).json(results);
    }
  });
});

app.put('/notes/:id', (req, res) => {
  const { id } = req.params;
  const { note } = req.body;
  const query = 'UPDATE notes SET note = ? WHERE id = ?';
  db.query(query, [note, id], (err, result) => {
    if (err) {
      console.error('Erro ao atualizar anotação:', err);
      res.status(500).send('Erro ao atualizar anotação');
    } else {
      res.status(200).send('Anotação atualizada');
    }
  });
});

app.delete('/notes/:id', (req, res) => {
  const { id } = req.params;
  const query = 'DELETE FROM notes WHERE id = ?';
  db.query(query, [id], (err, result) => {
    if (err) {
      console.error('Erro ao deletar anotação:', err);
      res.status(500).send('Erro ao deletar anotação');
    } else {
      res.status(200).send('Anotação deletada');
    }
  });
});

app.post('/historico_status', (req, res) => {
  const { licitacao_id, responsavel, modalidade, objeto, status, data_status, observacoes } = req.body;

  if (['Edital Publicado', 'Homologado', 'Contrato Publicado'].includes(status)) {
    const query = 'INSERT INTO historico_status (licitacao_id, responsavel, modalidade, objeto, status, data_status, observacoes) VALUES (?, ?, ?, ?, ?, ?, ?)';
    db.query(query, [licitacao_id, responsavel, modalidade, objeto, status, data_status, observacoes], (err, result) => {
      if (err) {
        if (err.code === 'ER_DUP_ENTRY') {
          console.error('Erro ao salvar histórico de status: Entrada duplicada');
          res.status(400).json({ message: 'Duplicidade detectada' });
        } else {
          console.error('Erro ao salvar histórico de status:', err);
          res.status(500).send('Erro ao salvar histórico de status');
        }
      } else {
        res.status(201).send('Histórico de status salvo');
      }
    });
  } else {
    res.status(200).send('Status não relevante para histórico');
  }
});

app.get('/licitacoes/relevantes', (req, res) => {
  const query = 'SELECT * FROM licitacoes WHERE status IN ("Edital Publicado", "Homologado", "Contrato Publicado") ORDER BY data DESC';

  db.query(query, (err, results) => {
    if (err) {
      console.error('Erro ao buscar licitações relevantes:', err);
      res.status(500).send('Erro ao buscar licitações relevantes');
    } else {
      res.status(200).json(results);
    }
  });
});

app.get('/historico_status', (req, res) => {
  const { licitacao_id } = req.query;
  let query = 'SELECT * FROM historico_status';
  let queryParams = [];

  if (licitacao_id) {
    query += ' WHERE licitacao_id = ?';
    queryParams.push(licitacao_id);
  }

  query += ' ORDER BY data_status DESC';

  db.query(query, queryParams, (err, results) => {
    if (err) {
      console.error('Erro ao buscar histórico de status:', err);
      res.status(500).send('Erro ao buscar histórico de status');
    } else {
      res.status(200).json(results);
    }
  });
});

app.delete('/historico_status/:id', (req, res) => {
  const historicoId = req.params.id;
  const query = 'DELETE FROM historico_status WHERE id = ?';

  db.query(query, [historicoId], (err, result) => {
    if (err) {
      console.error('Erro ao deletar histórico de status:', err);
      res.status(500).send('Erro ao deletar histórico de status');
    } else if (result.affectedRows === 0) {
      res.status(404).send('Histórico de status não encontrado');
    } else {
      res.status(200).send('Histórico de status deletado com sucesso');
    }
  });
});

app.listen(3000, () => {
  console.log('Servidor rodando na porta 3000');
});
