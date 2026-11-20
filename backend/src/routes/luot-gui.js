
import express from 'express';
import pool from '../config/db.js';

const router = express.Router();

// 1. API lấy danh sách lượt gửi xe
router.get('/', async (req, res) => {
    try {
        const result = await pool.query(`
            SELECT *
            FROM luot_gui
            ORDER BY id DESC
        `);

        res.status(200).json({
            thanh_cong: true,
            du_lieu: result.rows
        });
    } catch (error) {
        console.error('Lỗi lấy lượt gửi xe:', error.message);

        res.status(500).json({
            thanh_cong: false,
            loi: 'Không thể lấy danh sách lượt gửi xe'
        });
    }
});

// 2. API ghi nhận xe vào bãi
router.post('/vao', async (req, res) => {
    try {
        const {
            nguoi_dung_id,
            bai_xe_id,
            bien_so_xe
        } = req.body;

        if (
            !nguoi_dung_id ||
            !bai_xe_id ||
            !bien_so_xe ||
            !Number.isInteger(Number(nguoi_dung_id)) ||
            !Number.isInteger(Number(bai_xe_id))
        ) {
            return res.status(400).json({
                thanh_cong: false,
                loi: 'Thông tin xe vào không hợp lệ'
            });
        }

        const result = await pool.query(`
            INSERT INTO luot_gui (
                nguoi_dung_id,
                bai_xe_id,
                bien_so_xe,
                thoi_gian_vao,
                trang_thai
            )
            VALUES ($1, $2, $3, NOW(), 'dang_gui')
            RETURNING *
        `, [
            nguoi_dung_id,
            bai_xe_id,
            bien_so_xe.trim()
        ]);

        res.status(201).json({
            thanh_cong: true,
            thong_bao: 'Ghi nhận xe vào bãi thành công',
            du_lieu: result.rows[0]
        });

    } catch (error) {
        console.error('Lỗi ghi nhận xe vào:', error.message);

        res.status(500).json({
            thanh_cong: false,
            loi: 'Không thể ghi nhận xe vào bãi'
        });
    }
});

// 3. API ghi nhận xe ra khỏi bãi
router.put('/ra/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { phi_gui } = req.body;

        if (!/^\d+$/.test(id)) {
            return res.status(400).json({
                thanh_cong: false,
                loi: 'ID lượt gửi không hợp lệ'
            });
        }

        if (
            phi_gui === undefined ||
            !Number.isFinite(Number(phi_gui)) ||
            Number(phi_gui) < 0
        ) {
            return res.status(400).json({
                thanh_cong: false,
                loi: 'Phí gửi xe không hợp lệ'
            });
        }

        const result = await pool.query(`
            UPDATE luot_gui
            SET
                thoi_gian_ra = NOW(),
                phi_gui = $1,
                trang_thai = 'da_ra'
            WHERE id = $2
              AND trang_thai = 'dang_gui'
            RETURNING *
        `, [Number(phi_gui), id]);

        if (result.rows.length === 0) {
            return res.status(404).json({
                thanh_cong: false,
                loi: 'Không tìm thấy lượt gửi đang hoạt động'
            });
        }

        res.status(200).json({
            thanh_cong: true,
            thong_bao: 'Ghi nhận xe ra thành công',
            du_lieu: result.rows[0]
        });

    } catch (error) {
        console.error('Lỗi ghi nhận xe ra:', error.message);

        res.status(500).json({
            thanh_cong: false,
            loi: 'Không thể ghi nhận xe ra'
        });
    }
});

// 4. API xem chi tiết lượt gửi xe
router.get('/:id', async (req, res) => {
    try {
        const { id } = req.params;

        if (!/^\d+$/.test(id)) {
            return res.status(400).json({
                thanh_cong: false,
                loi: 'ID lượt gửi không hợp lệ'
            });
        }

        const result = await pool.query(
            'SELECT * FROM luot_gui WHERE id = $1',
            [id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({
                thanh_cong: false,
                loi: 'Không tìm thấy lượt gửi xe'
            });
        }

        res.status(200).json({
            thanh_cong: true,
            du_lieu: result.rows[0]
        });

    } catch (error) {
        console.error('Lỗi xem lượt gửi:', error.message);

        res.status(500).json({
            thanh_cong: false,
            loi: 'Không thể xem lượt gửi xe'
        });
    }
});

export default router;
