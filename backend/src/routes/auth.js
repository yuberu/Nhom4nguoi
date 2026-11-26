
import express from 'express';
import {
  dangKy,
  dangNhap,
  layThongTinCaNhan,
} from '../controllers/authController.js';

import { xacThuc } from '../middleware/auth.js';

const router = express.Router();

// API đăng ký
router.post('/dang-ky', dangKy);

// API đăng nhập
router.post('/dang-nhap', dangNhap);

// API lấy thông tin người dùng hiện tại
router.get('/me', xacThuc, layThongTinCaNhan);

export default router;
