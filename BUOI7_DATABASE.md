
# BUỔI 7 – CƠ SỞ DỮ LIỆU SQLITE

## Database
expense_manager.db

## Bảng categories
- id: Khóa chính, tự động tăng.
- name: Tên danh mục.
- type: Thu nhập hoặc Chi tiêu.
- icon: Biểu tượng danh mục.

## Bảng transactions
- id: Khóa chính, tự động tăng.
- category_id: Khóa ngoại liên kết categories.
- amount: Số tiền, phải lớn hơn 0.
- type: Thu nhập hoặc Chi tiêu.
- date: Ngày giao dịch.
- note: Ghi chú.

## Chức năng đã xây dựng
- Thêm, sửa, xóa giao dịch.
- Lấy danh sách giao dịch từ SQLite.
- Lấy danh mục theo loại giao dịch.
- Tính tổng thu nhập, tổng chi tiêu và số dư.
- Kiểm tra danh mục hợp lệ và bật khóa ngoại.
