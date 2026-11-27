
import express from 'express';
import pool from '../config/db.js';
import { xacThuc } from '../middleware/auth.js';

const router = express.Router();

// Tất cả API xe đều yêu cầu đăng nhập
router.use(xacThuc);

// 1. Lấy danh sách xe của người dùng hiện tại
router.get('/', async (req, res) => {
    try {
        const nguoiDungId = req.nguoiDung.id;

        const result = await pool.query(`
            SELECT *
            FROM xe
            WHERE nguoi_dung_id = $1
            ORDER BY id DESC
        `, [nguoiDungId]);

        res.status(200).json({
            thanhCong: true,
            duLieu: result.rows
        });

    } catch (error) {
        console.error('Lỗi lấy danh sách xe:', error.message);

        res.status(500).json({
            thanhCong: false,
            loi: 'Không thể lấy danh sách xe'
        });
    }
});

// 2. Xem chi tiết một xe
router.get('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const nguoiDungId = req.nguoiDung.id;

        if (!/^\d+$/.test(id)) {
            return res.status(400).json({
                thanhCong: false,
                loi: 'ID xe không hợp lệ'
            });
        }

        const result = await pool.query(`
            SELECT *
            FROM xe
            WHERE id = $1
              AND nguoi_dung_id = $2
        `, [id, nguoiDungId]);

        if (result.rows.length === 0) {
            return res.status(404).json({
                thanhCong: false,
                loi: 'Không tìm thấy xe'
            });
        }

        res.status(200).json({
            thanhCong: true,
            duLieu: result.rows[0]
        });

    } catch (error) {
        console.error('Lỗi xem chi tiết xe:', error.message);

        res.status(500).json({
            thanhCong: false,
            loi: 'Không thể xem thông tin xe'
        });
    }
});

// 3. Thêm xe mới
router.post('/', async (req, res) => {
    try {
        const nguoiDungId = req.nguoiDung.id;

        const {
            bien_so_xe,
            ten_xe,
            loai_xe,
            mau_xe
        } = req.body;

        if (
            typeof bien_so_xe !== 'string' ||
            !bien_so_xe.trim() ||
            bien_so_xe.trim().length > 20
        ) {
            return res.status(400).json({
                thanhCong: false,
                loi: 'Biển số xe không hợp lệ'
            });
        }

        const fields = [
            ['ten_xe', ten_xe, 100],
            ['loai_xe', loai_xe, 30],
            ['mau_xe', mau_xe, 50]
        ];

        for (const [name, value, maxLength] of fields) {
            if (
                value !== undefined &&
                value !== null &&
                (typeof value !== 'string' ||
                 value.trim().length > maxLength)
            ) {
                return res.status(400).json({
                    thanhCong: false,
                    loi: `Thông tin ${name} không hợp lệ`
                });
            }
        }

        const result = await pool.query(`
            INSERT INTO xe (
                nguoi_dung_id,
                bien_so_xe,
                ten_xe,
                loai_xe,
                mau_xe
            )
            VALUES ($1, $2, $3, $4, $5)
            RETURNING *
        `, [
            nguoiDungId,
            bien_so_xe.trim(),
            ten_xe?.trim() || null,
            loai_xe?.trim() || null,
            mau_xe?.trim() || null
        ]);

        res.status(201).json({
            thanhCong: true,
            thongBao: 'Thêm xe thành công',
            duLieu: result.rows[0]
        });

    } catch (error) {
        console.error('Lỗi thêm xe:', error.message);

        if (error.code === '23505') {
            return res.status(409).json({
                thanhCong: false,
                loi: 'Biển số xe này đã được đăng ký'
            });
        }

        res.status(500).json({
            thanhCong: false,
            loi: 'Không thể thêm xe'
        });
    }
});

// 4. Cập nhật thông tin xe
router.put('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const nguoiDungId = req.nguoiDung.id;

        const {
            bien_so_xe,
            ten_xe,
            loai_xe,
            mau_xe
        } = req.body;

        if (!/^\d+$/.test(id)) {
            return res.status(400).json({
                thanhCong: false,
                loi: 'ID xe không hợp lệ'
            });
        }

        if (
            typeof bien_so_xe !== 'string' ||
            !bien_so_xe.trim() ||
            bien_so_xe.trim().length > 20
        ) {
            return res.status(400).json({
                thanhCong: false,
                loi: 'Biển số xe không hợp lệ'
            });
        }

        const fields = [
            ['ten_xe', ten_xe, 100],
            ['loai_xe', loai_xe, 30],
            ['mau_xe', mau_xe, 50]
        ];

        for (const [name, value, maxLength] of fields) {
            if (
                value !== undefined &&
                value !== null &&
                (typeof value !== 'string' ||
                 value.trim().length > maxLength)
            ) {
                return res.status(400).json({
                    thanhCong: false,
                    loi: `Thông tin ${name} không hợp lệ`
                });
            }
        }

        const result = await pool.query(`
            UPDATE xe
            SET
                bien_so_xe = $1,
                ten_xe = $2,
                loai_xe = $3,
                mau_xe = $4
            WHERE id = $5
              AND nguoi_dung_id = $6
            RETURNING *
        `, [
            bien_so_xe.trim(),
            ten_xe?.trim() || null,
            loai_xe?.trim() || null,
            mau_xe?.trim() || null,
            id,
            nguoiDungId
        ]);

        if (result.rows.length === 0) {
            return res.status(404).json({
                thanhCong: false,
                loi: 'Không tìm thấy xe'
            });
        }

        res.status(200).json({
            thanhCong: true,
            thongBao: 'Cập nhật xe thành công',
            duLieu: result.rows[0]
        });

    } catch (error) {
        console.error('Lỗi cập nhật xe:', error.message);

        if (error.code === '23505') {
            return res.status(409).json({
                thanhCong: false,
                loi: 'Biển số xe này đã được đăng ký'
            });
        }

        res.status(500).json({
            thanhCong: false,
            loi: 'Không thể cập nhật xe'
        });
    }
});

// 5. Xóa xe
router.delete('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const nguoiDungId = req.nguoiDung.id;

        if (!/^\d+$/.test(id)) {
            return res.status(400).json({
                thanhCong: false,
                loi: 'ID xe không hợp lệ'
            });
        }

        const result = await pool.query(`
            DELETE FROM xe
            WHERE id = $1
              AND nguoi_dung_id = $2
            RETURNING *
        `, [id, nguoiDungId]);

        if (result.rows.length === 0) {
            return res.status(404).json({
                thanhCong: false,
                loi: 'Không tìm thấy xe'
            });
        }

        res.status(200).json({
            thanhCong: true,
            thongBao: 'Xóa xe thành công',
            duLieu: result.rows[0]
        });

    } catch (error) {
        console.error('Lỗi xóa xe:', error.message);

        res.status(500).json({
            thanhCong: false,
            loi: 'Không thể xóa xe'
        });
    }
});

export default router;
