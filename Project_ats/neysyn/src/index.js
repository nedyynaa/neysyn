const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const multer = require('multer');
const path = require('path');

const app = express();
app.use(cors());
app.use(express.json());

// Konfigurasi penyimpanan file upload fisik
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'uploads/');
    },
    filename: (req, file, cb) => {
        cb(null, Date.now() + path.extname(file.originalname));
    }
});
const upload = multer({ storage: storage });

// Folder uploads agar bisa diakses publik
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: 'Nadine1004',
    database: 'db_blog_app'
});

db.connect((err) => {
    if (err) throw err;
    console.log("Database Terhubung!");
});

// GET: Ambil semua artikel
app.get('/api/posts', (req, res) => {
    db.query('SELECT * FROM posts', (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

// POST: Tambah artikel baru dengan upload gambar
app.post('/api/posts', upload.single('image'), (req, res) => {
    const { category_id = 1, title, subtitle = 'Subjudul', author = 'Penulis', reading_time = '3 min read', content } = req.body;
    const image_url = req.file ? `/uploads/${req.file.filename}` : 'assets/images/cat.png';

    const query = 'INSERT INTO posts (category_id, title, subtitle, author, image_url, reading_time, content) VALUES (?, ?, ?, ?, ?, ?, ?)';
    db.query(query, [category_id, title, subtitle, author, image_url, reading_time, content], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.status(201).json({ message: 'Artikel berhasil dibuat', post_id: result.insertId, image_url });
    });
});

// PUT: Update artikel dengan upload gambar baru (opsional)
app.put('/api/posts/:id', upload.single('image'), (req, res) => {
    const { id } = req.params;
    const { category_id = 1, title, subtitle = 'Subjudul', author = 'Penulis', reading_time = '3 min read', content } = req.body;

    let query, params;
    if (req.file) {
        const image_url = `/uploads/${req.file.filename}`;
        query = 'UPDATE posts SET category_id = ?, title = ?, subtitle = ?, author = ?, image_url = ?, reading_time = ?, content = ? WHERE post_id = ?';
        params = [category_id, title, subtitle, author, image_url, reading_time, content, id];
    } else {
        query = 'UPDATE posts SET category_id = ?, title = ?, subtitle = ?, author = ?, reading_time = ?, content = ? WHERE post_id = ?';
        params = [category_id, title, subtitle, author, reading_time, content, id];
    }

    db.query(query, params, (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ message: 'Artikel berhasil diupdate' });
    });
});

// DELETE: Hapus artikel
app.delete('/api/posts/:id', (req, res) => {
    const { id } = req.params;
    db.query('DELETE FROM posts WHERE post_id = ?', [id], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ message: 'Artikel berhasil dihapus' });
    });
});

// REGISTER & LOGIN
app.post('/api/register', (req, res) => {
    const { username, email, password } = req.body;
    db.query('INSERT INTO users (username, email, password) VALUES (?, ?, ?)', [username, email, password], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.status(201).json({ message: 'Registrasi berhasil', user_id: result.insertId });
    });
});

app.post('/api/login', (req, res) => {
    const { email, password } = req.body;
    db.query('SELECT * FROM users WHERE email = ? AND password = ?', [email, password], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        if (results.length === 0) return res.status(401).json({ message: 'Email atau password salah' });
        res.json({ message: 'Login berhasil', user: results[0] });
    });
});

app.listen(3000, () => {
    console.log('Server aktif di http://localhost:3000');
});