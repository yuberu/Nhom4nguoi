
import express from 'express';
import pool from '../config/db.js';
import { xacThuc } from '../middleware/auth.js';

const router = express.Router();

router.use(xacThuc);

// 1. Danh sách đặt chỗ
router.get('/', async (req, res) => {
    try {
        const userId = req.nguoiDung.id;

        const result = await pool.query(`
            SELECT
                dc.*,
                bx.ten AS ten_bai_xe,
                x.bien_so_xe,
                x.ten_xe
            FROM dat_cho dc
            JOIN bai_xe bx ON dc.bai_xe_id = bx.id
            LEFT JOIN xe x ON dc.xe_id = x.id
            WHERE dc.nguoi_dung_id = $1
            ORDER BY dc.id DESC
        `, [userId]);

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

// 2. Tạo đặt chỗ
router.post('/', async (req, res) => {
    try {
        const userId = req.nguoiDung.id;

        const {
            bai_xe_id,
            xe_id,
            thoi_gian_bat_dau,
            thoi_gian_ket_thuc
        } = req.body;

        if (
            !bai_xe_id ||
            !xe_id ||
            !thoi_gian_bat_dau ||
            !thoi_gian_ket_thuc
        ) {
            return res.status(400).json({
                thanh_cong: false,
                loi: 'Vui lòng nhập đầy đủ thông tin'
            });
        }

        if (
            !Number.isInteger(Number(bai_xe_id)) ||
            Number(bai_xe_id) <= 0 ||
            !Number.isInteger(Number(xe_id)) ||
            Number(xe_id) <= 0
        ) {
            return res.status(400).json({
                thanh_cong: false,
                loi: 'Mã bãi xe hoặc mã xe không hợp lệ'
            });
        }

        const start = new Date(thoi_gian_bat_dau);
        const end = new Date(thoi_gian_ket_thuc);

        if (
            Number.isNaN(start.getTime()) ||
            Number.isNaN(end.getTime()) ||
            end <= start
        ) {
            return res.status(400).json({
                thanh_cong: false,
                loi: 'Thời gian đặt chỗ không hợp lệ'
            });
        }

        // Kiểm tra xe thuộc người đang đăng nhập
        const vehicle = await pool.query(`
            SELECT id
            FROM xe
            WHERE id = $1
              AND nguoi_dung_id = $2
        `, [Number(xe_id), userId]);

        if (vehicle.rows.length === 0) {
            return res.status(403).json({
                thanh_cong: false,
                loi: 'Phương tiện không thuộc tài khoản của bạn'
            });
        }

        // Kiểm tra bãi xe tồn tại
        const lot = await pool.query(`
            SELECT id
            FROM bai_xe
            WHERE id = $1
        `, [Number(bai_xe_id)]);

        if (lot.rows.length === 0) {
            return res.status(404).json({
                thanh_cong: false,
                loi: 'Không tìm thấy bãi xe'
            });
        }

        const result = await pool.query(`
            INSERT INTO dat_cho (
                nguoi_dung_id,
                bai_xe_id,
                xe_id,
                thoi_gian_bat_dau,
                thoi_gian_ket_thuc
            )
            VALUES ($1, $2, $3, $4, $5)
            RETURNING *
        `, [
            userId,
            Number(bai_xe_id),
            Number(xe_id),
            start.toISOString(),
            end.toISOString()
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

// 3. Chi tiết đặt chỗ
router.get('/:id', async (req, res) => {
    try {
        const userId = req.nguoiDung.id;
        const { id } = req.params;

        const result = await pool.query(`
            SELECT
                dc.*,
                bx.ten AS ten_bai_xe,
                x.bien_so_xe,
                x.ten_xe
            FROM dat_cho dc
            JOIN bai_xe bx ON dc.bai_xe_id = bx.id
            LEFT JOIN xe x ON dc.xe_id = x.id
            WHERE dc.id = $1
              AND dc.nguoi_dung_id = $2
        `, [id, userId]);

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

// 4. Hủy đặt chỗ
router.put('/:id/huy', async (req, res) => {
    try {
        const userId = req.nguoiDung.id;
        const { id } = req.params;

        const result = await pool.query(`
            UPDATE dat_cho
            SET trang_thai = 'da_huy'
            WHERE id = $1
              AND nguoi_dung_id = $2
              AND trang_thai <> 'da_huy'
            RETURNING *
        `, [id, userId]);

        if (result.rows.length === 0) {
            return res.status(404).json({
                thanh_cong: false,
                loi: 'Không tìm thấy đặt chỗ hoặc đặt chỗ đã bị hủy'
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
