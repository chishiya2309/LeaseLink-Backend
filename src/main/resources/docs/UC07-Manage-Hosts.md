# Đặc tả Use Case: UC07 - Quản lý và Cấp tài khoản Chủ nhà

**1. Tên Use Case:** Quản lý và Cấp tài khoản Chủ nhà (Manage Host Accounts)
**2. Actor chính:** Admin (Quản trị viên)
**3. Mục tiêu:**: Admin phát tài khoản cho đối tác môi giới chuẩn, kiểm soát rủi ro và "Ban/Lock" đối tác nếu có lừa đảo làm mất uy tín.
**4. Mô tả ngắn:** Guest vẫn có thể đăng ký được để trở thành Host đăng tin (UC01). Admin có thể Thêm account thủ công. Admin cũng quản lý bảng Data chứa tất cả mọi người dùng nền tảng để Ban nick nếu phát hiện gian lận.
**5. Tiền điều kiện:**

- Admin Login trên thiết bị.
  **6. Hậu điều kiện:** Dữ liệu Users có một Row Account mới khởi tạo ra Role Host, hoặc trường Active bị chuyển thành Lock với Host có sẵn.
  **7. Kích hoạt:** Admin nhấn "Tạo Chủ nhà Mới" hoặc nút "Quản lý / Lock" trên row dữ liệu Host List.

**8. Luồng chính (Main Flow - Cấp Account Mới):**

1. Admin mở mục "Thành Viên / User Account". Bấm "Add New Account".
2. Giao diện mở Modal Form điền dữ liệu.
3. Admin điền thông tin đối tác Host: Tên đối tác (Họ tên), Số Điện thoại (dùng ghim lên mọi bài rao), Email, Gen ra 1 chuỗi ngẫu nhiên "Password" (gửi về cho host, admin có thể không biết để bảo mật). Roles set Cứng (Host).
4. Submit Button.
5. API kiểm tra Validation Email Unique / Số điện thoại Unique.
6. DB Bảng `Users` Insert Data mã hóa mật khẩu.
7. Email Service kích hoạt, bắn một email "Chào mừng bạn được tạo tài khoản thành viên hệ thống nền tảng X, đây là thông tin credential..." gửi thẳng tay Host.

**9. Luồng ngoại lệ (Lock Account - Khóa tài khoản):**

1. Admin dùng Input Filter tìm SĐT của Khách A đã bị phàn nàn là Cò Bịp mồi chài rác rưởi.
2. Tại lưới User Table list, click vào Action "Ban / Lock".
3. Hệ thống Confirm: "Nhập lý do Ban User".
4. Bấm Ban. Hệ thống cập nhật row `Users`. Xóa cứng cookie Đăng nhập hiện hành trên mọi máy trạm của họ ra.
5. Đồng thời, kích hoạt Lệnh Trigger Database: Lục lại toàn bộ các bài Property đang Public do `Owner_id` là ông Khách A thiết lập → Force Soft Delete (Khóa mờ tất cả bài viết cùng lúc).

**10. Quy tắc nghiệp vụ (Business Rules):**

- Tránh tự sát thao tác (Self-lock): Lệnh nút Lock không hiển thị với chính Row của Admin bản thân (Current Session User).
- Không thể lập Form tạo Host trùng Mail hoặc SĐT có với Host khóa cũ.

**11. Dữ liệu vào ra:**

- **Dữ liệu vào (Input):** Form Credential (Email, Sdt, Name). Action Boolean (Lock/Unlock).
- **Dữ liệu ra (Output):** Object `Host User`, Send Mail Ticket (SMTP server trả log).
