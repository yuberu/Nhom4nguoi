
import express from 'express';
import { dangKy, dangNhap } from '../controllers/authController.js';

const router = express.Router();

// API đăng ký tài khoản
router.post('/dang-ky', dangKy);

// API đăng nhập
router.post('/dang-nhap', dangNhap);

export default router;
