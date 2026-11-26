
import express from 'express';
import pool from '../config/db.js';

const router = express.Router();

// 1. API lấy danh sách vé tháng
router.get('/', async (req, res) => {
    try {
        const result = await pool.query(`
            SELECT
                vt.*,
                nd.email,
                bx.ten AS ten_bai_xe
            FROM ve_thang vt
            JOIN nguoi_dung nd ON vt.nguoi_dung_id = nd.id
            JOIN bai_xe bx ON vt.bai_xe_id = bx.id
            ORDER BY vt.id DESC
        `);

        res.status(200).json({
            thanh_cong: true,
            du_lieu: result.rows
        });

    } catch (error) {
        console.error('Lỗi lấy danh sách vé tháng:', error.message);

        res.status(500).json({
            thanh_cong: false,
            loi: 'Không thể lấy danh sách vé tháng'
        });
    }
});

// 2. API đăng ký vé tháng
router.post('/', async (req, res) => {
    try {
        const {
            nguoi_dung_id,
            bai_xe_id,
            bien_so_xe,
            ngay_bat_dau,
            ngay_ket_thuc,
            gia_tien
        } = req.body;

        if (
            !Number.isInteger(Number(nguoi_dung_id)) ||
            Number(nguoi_dung_id) <= 0 ||
            !Number.isInteger(Number(bai_xe_id)) ||
            Number(bai_xe_id) <= 0 ||
            typeof bien_so_xe !== 'string' ||
            !bien_so_xe.trim() ||
            !ngay_bat_dau ||
            !ngay_ket_thuc ||
            !Number.isFinite(Number(gia_tien)) ||
            Number(gia_tien) < 0
        ) {
            return res.status(400).json({
                thanh_cong: false,
                loi: 'Thông tin đăng ký vé tháng không hợp lệ'
            });
        }

        const bat_dau = new Date(ngay_bat_dau);
        const ket_thuc = new Date(ngay_ket_thuc);

        if (
            Number.isNaN(bat_dau.getTime()) ||
            Number.isNaN(ket_thuc.getTime()) ||
            ket_thuc <= bat_dau
        ) {
            return res.status(400).json({
                thanh_cong: false,
                loi: 'Ngày kết thúc phải sau ngày bắt đầu'
            });
        }

        const result = await pool.query(`
            INSERT INTO ve_thang (
                nguoi_dung_id,
                bai_xe_id,
                bien_so_xe,
                ngay_bat_dau,
                ngay_ket_thuc,
                gia_tien,
                trang_thai
            )
            VALUES ($1, $2, $3, $4, $5, $6, 'dang_hoat_dong')
            RETURNING *
        `, [
            Number(nguoi_dung_id),
            Number(bai_xe_id),
            bien_so_xe.trim(),
            ngay_bat_dau,
            ngay_ket_thuc,
            Number(gia_tien)
        ]);

        res.status(201).json({
            thanh_cong: true,
            thong_bao: 'Đăng ký vé tháng thành công',
            du_lieu: result.rows[0]
        });

    } catch (error) {
        console.error('Lỗi đăng ký vé tháng:', error.message);

        res.status(500).json({
            thanh_cong: false,
            loi: 'Không thể đăng ký vé tháng'
        });
    }
});

// 3. API xem chi tiết vé tháng
router.get('/:id', async (req, res) => {
    try {
        const { id } = req.params;

        if (!/^\d+$/.test(id)) {
            return res.status(400).json({
                thanh_cong: false,
                loi: 'ID vé tháng không hợp lệ'
            });
        }

        const result = await pool.query(
            'SELECT * FROM ve_thang WHERE id = $1',
            [id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({
                thanh_cong: false,
                loi: 'Không tìm thấy vé tháng'
            });
        }

        res.status(200).json({
            thanh_cong: true,
            du_lieu: result.rows[0]
        });

    } catch (error) {
        console.error('Lỗi xem vé tháng:', error.message);

        res.status(500).json({
            thanh_cong: false,
            loi: 'Không thể xem vé tháng'
        });
    }
});

// 4. API gia hạn vé tháng
router.put('/:id/gia-han', async (req, res) => {
    try {
        const { id } = req.params;
        const { ngay_ket_thuc, gia_tien } = req.body;

        if (!/^\d+$/.test(id)) {
            return res.status(400).json({
                thanh_cong: false,
                loi: 'ID vé tháng không hợp lệ'
            });
        }

        if (
            !ngay_ket_thuc ||
            Number.isNaN(new Date(ngay_ket_thuc).getTime()) ||
            !Number.isFinite(Number(gia_tien)) ||
            Number(gia_tien) < 0
        ) {
            return res.status(400).json({
                thanh_cong: false,
                loi: 'Thông tin gia hạn không hợp lệ'
            });
        }

        const result = await pool.query(`
            UPDATE ve_thang
            SET
                ngay_ket_thuc = $1,
                gia_tien = $2,
                trang_thai = 'dang_hoat_dong'
            WHERE id = $3
              AND trang_thai <> 'da_huy'
              AND ngay_ket_thuc < $1::date
            RETURNING *
        `, [ngay_ket_thuc, Number(gia_tien), id]);

        if (result.rows.length === 0) {
            return res.status(404).json({
                thanh_cong: false,
                loi: 'Không tìm thấy vé hoặc ngày gia hạn không hợp lệ'
            });
        }

        res.status(200).json({
            thanh_cong: true,
            thong_bao: 'Gia hạn vé tháng thành công',
            du_lieu: result.rows[0]
        });

    } catch (error) {
        console.error('Lỗi gia hạn vé tháng:', error.message);

        res.status(500).json({
            thanh_cong: false,
            loi: 'Không thể gia hạn vé tháng'
        });
    }
});

// 5. API hủy vé tháng
router.put('/:id/huy', async (req, res) => {
    try {
        const { id } = req.params;

        if (!/^\d+$/.test(id)) {
            return res.status(400).json({
                thanh_cong: false,
                loi: 'ID vé tháng không hợp lệ'
            });
        }

        const result = await pool.query(`
            UPDATE ve_thang
            SET trang_thai = 'da_huy'
            WHERE id = $1
              AND trang_thai = 'dang_hoat_dong'
            RETURNING *
        `, [id]);

        if (result.rows.length === 0) {
            return res.status(404).json({
                thanh_cong: false,
                loi: 'Không tìm thấy vé tháng đang hoạt động'
            });
        }

        res.status(200).json({
            thanh_cong: true,
            thong_bao: 'Hủy vé tháng thành công',
            du_lieu: result.rows[0]
        });

    } catch (error) {
        console.error('Lỗi hủy vé tháng:', error.message);

        res.status(500).json({
            thanh_cong: false,
            loi: 'Không thể hủy vé tháng'
        });
    }
});

export default router;
