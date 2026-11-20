
import express from 'express';
import pool from '../config/db.js';

const router = express.Router();

// 1. API lấy danh sách đặt chỗ
router.get('/', async (req, res) => {
    try {
        const result = await pool.query(`
            SELECT 
                dc.*,
                nd.email,
                bx.ten AS ten_bai_xe
            FROM dat_cho dc
            JOIN nguoi_dung nd ON dc.nguoi_dung_id = nd.id
            JOIN bai_xe bx ON dc.bai_xe_id = bx.id
            ORDER BY dc.id DESC
        `);

        res.status(200).json({
            thanh_cong: true,
            du_lieu: result.rows
        });
    } catch (error) {
        console.error('Lỗi lấy danh sách đặt chỗ:', error.message);
        res.status(500).json({
            thanh_cong: false,
            loi: 'Không thể lấy danh sách đặt chỗ'
        });
    }
});

// 2. API tạo đặt chỗ
router.post('/', async (req, res) => {
    try {
        const {
            nguoi_dung_id,
            bai_xe_id,
            thoi_gian_bat_dau,
            thoi_gian_ket_thuc
        } = req.body;

        if (!nguoi_dung_id || !bai_xe_id ||
            !thoi_gian_bat_dau || !thoi_gian_ket_thuc) {
            return res.status(400).json({
                thanh_cong: false,
                loi: 'Vui lòng nhập đầy đủ thông tin'
            });
        }

        if (new Date(thoi_gian_ket_thuc) <=
            new Date(thoi_gian_bat_dau)) {
            return res.status(400).json({
                thanh_cong: false,
                loi: 'Thời gian kết thúc phải sau thời gian bắt đầu'
            });
        }

        const result = await pool.query(`
            INSERT INTO dat_cho (
                nguoi_dung_id,
                bai_xe_id,
                thoi_gian_bat_dau,
                thoi_gian_ket_thuc
            )
            VALUES ($1, $2, $3, $4)
            RETURNING *
        `, [
            nguoi_dung_id,
            bai_xe_id,
            thoi_gian_bat_dau,
            thoi_gian_ket_thuc
        ]);

        res.status(201).json({
            thanh_cong: true,
            thong_bao: 'Đặt chỗ thành công',
            du_lieu: result.rows[0]
        });
    } catch (error) {
        console.error('Lỗi tạo đặt chỗ:', error.message);
        res.status(500).json({
            thanh_cong: false,
            loi: 'Không thể tạo đặt chỗ'
        });
    }
});

// 3. API xem chi tiết đặt chỗ
router.get('/:id', async (req, res) => {
    try {
        const { id } = req.params;

        const result = await pool.query(
            'SELECT * FROM dat_cho WHERE id = $1',
            [id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({
                thanh_cong: false,
                loi: 'Không tìm thấy đặt chỗ'
            });
        }

        res.status(200).json({
            thanh_cong: true,
            du_lieu: result.rows[0]
        });
    } catch (error) {
        console.error('Lỗi xem đặt chỗ:', error.message);
        res.status(500).json({
            thanh_cong: false,
            loi: 'Không thể xem đặt chỗ'
        });
    }
});

// 4. API hủy đặt chỗ
router.put('/:id/huy', async (req, res) => {
    try {
        const { id } = req.params;

        const result = await pool.query(`
            UPDATE dat_cho
            SET trang_thai = 'da_huy'
            WHERE id = $1
            RETURNING *
        `, [id]);

        if (result.rows.length === 0) {
            return res.status(404).json({
                thanh_cong: false,
                loi: 'Không tìm thấy đặt chỗ'
            });
        }

        res.status(200).json({
            thanh_cong: true,
            thong_bao: 'Hủy đặt chỗ thành công',
            du_lieu: result.rows[0]
        });
    } catch (error) {
        console.error('Lỗi hủy đặt chỗ:', error.message);
        res.status(500).json({
            thanh_cong: false,
            loi: 'Không thể hủy đặt chỗ'
        });
    }
});

export default router;
