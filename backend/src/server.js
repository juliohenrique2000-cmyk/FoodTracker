const express = require('express');
const cors = require('cors');
const { PrismaClient } = require('@prisma/client');

const app = express();
const prisma = new PrismaClient();

app.use(cors());
app.use(express.json());

// Routes
app.get('/activities', async (req, res) => {
  try {
    const activities = await prisma.activity.findMany();
    res.json(activities);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/activities', async (req, res) => {
  try {
    const activity = await prisma.activity.create({
      data: req.body
    });
    res.json(activity);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.put('/activities/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const activity = await prisma.activity.update({
      where: { id: parseInt(id) },
      data: req.body
    });
    res.json(activity);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.delete('/activities/:id', async (req, res) => {
  try {
    const { id } = req.params;
    await prisma.activity.delete({
      where: { id: parseInt(id) }
    });
    res.json({ message: 'Activity deleted' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Register route
app.post('/register', async (req, res) => {
  try {
    const { name, email, password } = req.body;
    const existingUser = await prisma.user.findUnique({
      where: { email: email }
    });
    if (existingUser) {
      return res.status(400).json({ error: 'User already exists' });
    }
    const user = await prisma.user.create({
      data: { name, email, password }
    });
    res.status(201).json({ message: 'User registered successfully', user: { id: user.id, email: user.email } });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Login route
app.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await prisma.user.findUnique({
      where: { email: email }
    });
    if (user && user.password === password) {
      res.json({ message: 'Login successful', user: { id: user.id, email: user.email, name: user.name } });
    } else {
      res.status(401).json({ error: 'Invalid credentials' });
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
