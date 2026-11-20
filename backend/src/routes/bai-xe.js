
import express from 'express';
import pool from '../config/db.js';

const router = express.Router();

// API lấy danh sách bãi xe
router.get('/', async (req, res) => {
    try {
        const result = await pool.query(
            'SELECT * FROM bai_xe ORDER BY id ASC'
        );

        res.status(200).json({
            thanh_cong: true,
            du_lieu: result.rows
        });
    } catch (error) {
        console.error('Lỗi lấy danh sách bãi xe:', error.message);

        res.status(500).json({
            thanh_cong: false,
            loi: 'Không thể lấy danh sách bãi xe'
        });
    }
});

export default router;
