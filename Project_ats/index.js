const express = require("express");
const mysql = require("mysql2");
const cors = require("cors");

const app = express();
app.use(cors());
app.use(express.json());

const db = mysql.createConnection({
  host: process.env.DB_HOST || "localhost",
  user: process.env.DB_USER || "root",
  password: process.env.DB_PASSWORD || "Nadine1004",
  database: process.env.DB_NAME || "db_blog_app",
});

app.get("/api/posts", (req, res) => {
  db.query("SELECT * FROM posts", (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

app.post("/api/posts", (req, res) => {
  const {
    category_id = 1,
    title,
    subtitle = "Subjudul",
    author = "Penulis",
    reading_time = "3 min read",
    content,
  } = req.body;
  const query =
    "INSERT INTO posts (category_id, title, subtitle, author, image_url, reading_time, content) VALUES (?, ?, ?, ?, ?, ?, ?)";
  db.query(
    query,
    [
      category_id,
      title,
      subtitle,
      author,
      "assets/images/cat.png",
      reading_time,
      content,
    ],
    (err, result) => {
      if (err) return res.status(500).json({ error: err.message });
      res
        .status(201)
        .json({ message: "Artikel berhasil dibuat", post_id: result.insertId });
    },
  );
});

app.post("/api/login", (req, res) => {
  const { email, password } = req.body;
  db.query(
    "SELECT * FROM users WHERE email = ? AND password = ?",
    [email, password],
    (err, results) => {
      if (err) return res.status(500).json({ error: err.message });
      if (results.length === 0)
        return res.status(401).json({ message: "Email atau password salah" });
      res.json({ message: "Login berhasil", user: results[0] });
    },
  );
});

module.exports = app;
