
import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import pool from './config/db.js';
import authRoutes from './routes/auth.js';
import baiXeRoutes from './routes/bai-xe.js';
import datChoRoutes from './routes/dat-cho.js';
import luotGuiRoutes from './routes/luot-gui.js';
import veThangRouter from './routes/ve-thang.js';
import xeRoutes from './routes/xe.js';
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
//routes    
app.use('/api/auth', authRoutes);
app.use('/api/bai-xe', baiXeRoutes);
app.use('/api/dat-cho', datChoRoutes);
app.use('/api/luot-gui', luotGuiRoutes);
app.use('/api/ve-thang', veThangRouter);
app.use('/api/xe', xeRoutes);

// Trang kiểm tra Backend
app.get('/', (req, res) => {
  res.json({
    message: 'Smart Parking Backend is running!',
    status: 'OK',
  });
});

// API kiểm tra Backend và PostgreSQL
app.get('/api/health', async (req, res) => {
  try {
    const result = await pool.query('SELECT NOW() AS current_time');

    res.status(200).json({
      success: true,
      message: 'Backend and PostgreSQL are connected!',
      database: 'Connected',
      server_time: result.rows[0].current_time,
    });
  } catch (error) {
    console.error('Database connection error:', error.message);

    res.status(500).json({
      success: false,
      message: 'Database connection failed!',
      database: 'Disconnected',
    });
  }
});

// Khởi chạy Server
app.listen(PORT, () => {
  console.log('================================');
  console.log('SMART PARKING BACKEND');
  console.log(`Server running at http://localhost:${PORT}`);
  console.log(`Health: http://localhost:${PORT}/api/health`);
  console.log('================================');
});
