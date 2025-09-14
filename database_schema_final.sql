-- =============================================================================
-- HAIR STUDIO DATABASE SCHEMA - PHIÊN BẢN CUỐI CÙNG
-- 10 BẢNG (Đã loại bỏ Gallery & Blog)
-- =============================================================================

-- Bảng 1: QUẢN LÝ NGƯỜI DÙNG
CREATE TABLE nguoi_dung (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ho_ten VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    so_dien_thoai VARCHAR(15),
    mat_khau_hash VARCHAR(255) NOT NULL,
    gioi_tinh CHAR(1) CHECK (gioi_tinh IN ('M', 'F', 'O')),
    ngay_sinh DATE,
    dia_chi TEXT,
    avatar_url VARCHAR(255),
    trang_thai BOOLEAN DEFAULT TRUE,
    vai_tro VARCHAR(20) DEFAULT 'customer' CHECK (vai_tro IN ('customer', 'admin')),
    ngay_tao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ngay_cap_nhat TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng 2: QUẢN LÝ NHÂN VIÊN  
CREATE TABLE nhan_vien (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ho_ten VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    so_dien_thoai VARCHAR(15),
    chuyen_mon TEXT[],
    kinh_nghiem INTEGER,
    avatar_url VARCHAR(255),
    mo_ta TEXT,
    luong_co_ban DECIMAL(10,2),
    trang_thai BOOLEAN DEFAULT TRUE,
    -- Thông tin lịch làm việc
    lich_lam_viec JSONB DEFAULT '{}',
    ngay_bat_dau_lam DATE,
    ngay_tao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ngay_cap_nhat TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng 3: DANH MỤC DỊCH VỤ
CREATE TABLE danh_muc_dich_vu (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ten_danh_muc VARCHAR(100) NOT NULL,
    mo_ta TEXT,
    thu_tu_hien_thi INTEGER DEFAULT 0,
    trang_thai BOOLEAN DEFAULT TRUE,
    ngay_tao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng 4: DỊCH VỤ
CREATE TABLE dich_vu (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    danh_muc_id UUID REFERENCES danh_muc_dich_vu(id),
    ten_dich_vu VARCHAR(100) NOT NULL,
    mo_ta TEXT,
    gia_tien DECIMAL(10,2) NOT NULL,
    thoi_gian_thuc_hien INTEGER NOT NULL, -- phút
    hinh_anh_url VARCHAR(255),
    tags TEXT[],
    trang_thai BOOLEAN DEFAULT TRUE,
    thu_tu_hien_thi INTEGER DEFAULT 0,
    ngay_tao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ngay_cap_nhat TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng 5: LỊCH HẸN
CREATE TABLE lich_hen (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    khach_hang_id UUID REFERENCES nguoi_dung(id),
    nhan_vien_id UUID REFERENCES nhan_vien(id),
    ngay_hen DATE NOT NULL,
    gio_bat_dau TIME NOT NULL,
    gio_ket_thuc TIME NOT NULL,
    tong_tien DECIMAL(10,2),
    trang_thai VARCHAR(20) DEFAULT 'pending' CHECK (
        trang_thai IN ('pending', 'confirmed', 'in_progress', 'completed', 'cancelled', 'no_show')
    ),
    ghi_chu TEXT,
    phuong_thuc_thanh_toan VARCHAR(20),
    ngay_tao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ngay_cap_nhat TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng 6: CHI TIẾT LỊCH HẸN
CREATE TABLE chi_tiet_lich_hen (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lich_hen_id UUID REFERENCES lich_hen(id) ON DELETE CASCADE,
    dich_vu_id UUID REFERENCES dich_vu(id),
    gia_tien DECIMAL(10,2) NOT NULL,
    thoi_gian_thuc_hien INTEGER, -- phút
    ghi_chu TEXT,
    ngay_tao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng 7: ĐÁNH GIÁ
CREATE TABLE danh_gia (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lich_hen_id UUID REFERENCES lich_hen(id),
    khach_hang_id UUID REFERENCES nguoi_dung(id),
    nhan_vien_id UUID REFERENCES nhan_vien(id),
    diem_so INTEGER CHECK (diem_so >= 1 AND diem_so <= 5),
    noi_dung TEXT,
    hinh_anh_url VARCHAR(255)[],
    trang_thai BOOLEAN DEFAULT TRUE,
    ngay_tao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng 8: GIAO DỊCH
CREATE TABLE giao_dich (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lich_hen_id UUID REFERENCES lich_hen(id),
    khach_hang_id UUID REFERENCES nguoi_dung(id),
    so_tien DECIMAL(10,2) NOT NULL,
    phuong_thuc VARCHAR(20) NOT NULL CHECK (
        phuong_thuc IN ('cash', 'card', 'bank_transfer', 'e_wallet')
    ),
    trang_thai VARCHAR(20) DEFAULT 'pending' CHECK (
        trang_thai IN ('pending', 'completed', 'failed', 'refunded')
    ),
    ma_giao_dich VARCHAR(100),
    ghi_chu TEXT,
    ngay_giao_dich TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng 9: KHUYẾN MÃI
CREATE TABLE khuyen_mai (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ten_khuyen_mai VARCHAR(100) NOT NULL,
    mo_ta TEXT,
    ma_khuyen_mai VARCHAR(50) UNIQUE,
    loai_giam VARCHAR(20) CHECK (loai_giam IN ('percentage', 'fixed_amount')),
    gia_tri_giam DECIMAL(10,2),
    gia_tri_don_hang_toi_thieu DECIMAL(10,2),
    so_luong_su_dung INTEGER DEFAULT 1,
    da_su_dung INTEGER DEFAULT 0,
    ngay_bat_dau DATE,
    ngay_ket_thuc DATE,
    trang_thai BOOLEAN DEFAULT TRUE,
    ngay_tao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng 10: LIÊN HỆ
CREATE TABLE lien_he (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ho_ten VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    so_dien_thoai VARCHAR(15),
    chu_de VARCHAR(200),
    noi_dung TEXT NOT NULL,
    trang_thai VARCHAR(20) DEFAULT 'new' CHECK (
        trang_thai IN ('new', 'in_progress', 'resolved', 'closed')
    ),
    nguoi_xu_ly UUID REFERENCES nguoi_dung(id),
    ghi_chu_noi_bo TEXT,
    ngay_tao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ngay_cap_nhat TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- TẠO INDEX ĐỂ TỐI ƯU HIỆU SUẤT
-- =============================================================================

-- Index cho bảng nguoi_dung
CREATE INDEX idx_nguoi_dung_email ON nguoi_dung(email);
CREATE INDEX idx_nguoi_dung_sdt ON nguoi_dung(so_dien_thoai);
CREATE INDEX idx_nguoi_dung_trang_thai ON nguoi_dung(trang_thai);

-- Index cho bảng nhan_vien  
CREATE INDEX idx_nhan_vien_email ON nhan_vien(email);
CREATE INDEX idx_nhan_vien_trang_thai ON nhan_vien(trang_thai);

-- Index cho bảng dich_vu
CREATE INDEX idx_dich_vu_danh_muc ON dich_vu(danh_muc_id);
CREATE INDEX idx_dich_vu_trang_thai ON dich_vu(trang_thai);
CREATE INDEX idx_dich_vu_gia ON dich_vu(gia_tien);

-- Index cho bảng lich_hen
CREATE INDEX idx_lich_hen_khach_hang ON lich_hen(khach_hang_id);
CREATE INDEX idx_lich_hen_nhan_vien ON lich_hen(nhan_vien_id);
CREATE INDEX idx_lich_hen_ngay ON lich_hen(ngay_hen);
CREATE INDEX idx_lich_hen_trang_thai ON lich_hen(trang_thai);
CREATE INDEX idx_lich_hen_ngay_trang_thai ON lich_hen(ngay_hen, trang_thai);

-- Index cho bảng chi_tiet_lich_hen
CREATE INDEX idx_chi_tiet_lich_hen ON chi_tiet_lich_hen(lich_hen_id);
CREATE INDEX idx_chi_tiet_dich_vu ON chi_tiet_lich_hen(dich_vu_id);

-- Index cho bảng danh_gia
CREATE INDEX idx_danh_gia_lich_hen ON danh_gia(lich_hen_id);
CREATE INDEX idx_danh_gia_khach_hang ON danh_gia(khach_hang_id);
CREATE INDEX idx_danh_gia_nhan_vien ON danh_gia(nhan_vien_id);
CREATE INDEX idx_danh_gia_diem ON danh_gia(diem_so);

-- Index cho bảng giao_dich
CREATE INDEX idx_giao_dich_lich_hen ON giao_dich(lich_hen_id);
CREATE INDEX idx_giao_dich_khach_hang ON giao_dich(khach_hang_id);
CREATE INDEX idx_giao_dich_ngay ON giao_dich(ngay_giao_dich);
CREATE INDEX idx_giao_dich_trang_thai ON giao_dich(trang_thai);

-- Index cho bảng khuyen_mai
CREATE INDEX idx_khuyen_mai_ma ON khuyen_mai(ma_khuyen_mai);
CREATE INDEX idx_khuyen_mai_ngay ON khuyen_mai(ngay_bat_dau, ngay_ket_thuc);
CREATE INDEX idx_khuyen_mai_trang_thai ON khuyen_mai(trang_thai);

-- Index cho bảng lien_he
CREATE INDEX idx_lien_he_email ON lien_he(email);
CREATE INDEX idx_lien_he_trang_thai ON lien_he(trang_thai);
CREATE INDEX idx_lien_he_ngay ON lien_he(ngay_tao);

-- =============================================================================
-- DỮ LIỆU MẪU CHO DEVELOPMENT
-- =============================================================================

-- Danh mục dịch vụ        
INSERT INTO danh_muc_dich_vu (ten_danh_muc, mo_ta, thu_tu_hien_thi) VALUES
('Cắt Tóc', 'Các dịch vụ cắt tóc chuyên nghiệp', 1),
('Nhuộm Tóc', 'Dịch vụ nhuộm và tạo màu tóc', 2),
('Uốn Tóc', 'Dịch vụ uốn và tạo kiểu tóc', 3),
('Chăm Sóc Tóc', 'Các liệu trình chăm sóc và phục hồi tóc', 4);

-- Dịch vụ mẫu
INSERT INTO dich_vu (danh_muc_id, ten_dich_vu, mo_ta, gia_tien, thoi_gian_thuc_hien, thu_tu_hien_thi)
SELECT 
    dm.id,
    CASE dm.ten_danh_muc
        WHEN 'Cắt Tóc' THEN 'Cắt Tóc Nam'
        WHEN 'Nhuộm Tóc' THEN 'Nhuộm Tóc Cơ Bản'
        WHEN 'Uốn Tóc' THEN 'Uốn Tóc Xoăn'
        WHEN 'Chăm Sóc Tóc' THEN 'Dưỡng Tóc Protein'
    END,
    'Mô tả dịch vụ chuyên nghiệp',
    CASE dm.ten_danh_muc
        WHEN 'Cắt Tóc' THEN 150000
        WHEN 'Nhuộm Tóc' THEN 400000
        WHEN 'Uốn Tóc' THEN 350000
        WHEN 'Chăm Sóc Tóc' THEN 250000
    END,
    CASE dm.ten_danh_muc
        WHEN 'Cắt Tóc' THEN 45
        WHEN 'Nhuộm Tóc' THEN 120
        WHEN 'Uốn Tóc' THEN 90
        WHEN 'Chăm Sóc Tóc' THEN 60
    END,
    1
FROM danh_muc_dich_vu dm;

-- Nhân viên mẫu
INSERT INTO nhan_vien (ho_ten, email, so_dien_thoai, chuyen_mon, kinh_nghiem, mo_ta, luong_co_ban) VALUES
('Nguyễn Văn Tuấn', 'tuan.nv@hairstudio.com', '0901234567', ARRAY['Cắt tóc nam', 'Tạo kiểu'], 5, 'Chuyên gia cắt tóc nam với 5 năm kinh nghiệm', 12000000),
('Trần Thị Lan', 'lan.tt@hairstudio.com', '0901234568', ARRAY['Nhuộm tóc', 'Tạo màu'], 7, 'Chuyên viên nhuộm tóc hàng đầu', 15000000),
('Lê Hoàng Nam', 'nam.lh@hairstudio.com', '0901234569', ARRAY['Uốn tóc', 'Duỗi tóc'], 4, 'Thợ uốn tóc chuyên nghiệp', 11000000);

-- User admin mẫu
INSERT INTO nguoi_dung (ho_ten, email, so_dien_thoai, mat_khau_hash, vai_tro) VALUES
('Admin Hair Studio', 'admin@hairstudio.com', '0900000000', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewtnZ.', 'admin');

COMMENT ON TABLE nguoi_dung IS 'Bảng quản lý thông tin người dùng và khách hàng';
COMMENT ON TABLE nhan_vien IS 'Bảng quản lý thông tin nhân viên và lịch làm việc';  
COMMENT ON TABLE danh_muc_dich_vu IS 'Bảng phân loại các dịch vụ';
COMMENT ON TABLE dich_vu IS 'Bảng chi tiết các dịch vụ salon cung cấp';
COMMENT ON TABLE lich_hen IS 'Bảng quản lý lịch hẹn của khách hàng';
COMMENT ON TABLE chi_tiet_lich_hen IS 'Bảng chi tiết các dịch vụ trong mỗi lịch hẹn';
COMMENT ON TABLE danh_gia IS 'Bảng đánh giá của khách hàng';
COMMENT ON TABLE giao_dich IS 'Bảng quản lý các giao dịch thanh toán';
COMMENT ON TABLE khuyen_mai IS 'Bảng quản lý mã khuyến mãi và ưu đãi';
COMMENT ON TABLE lien_he IS 'Bảng quản lý thông tin liên hệ từ khách hàng';