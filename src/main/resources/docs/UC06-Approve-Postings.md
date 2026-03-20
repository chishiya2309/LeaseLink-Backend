# Đặc tả Use Case: UC06 - Kiểm duyệt tin đăng

**1. Tên Use Case:** Kiểm duyệt tin đăng (Approve/Reject Postings)
**2. Actor chính:** Admin (Quản trị viên)
**3. Mục tiêu:** Đảm bảo toàn bộ bất động sản công khai hiển thị trên trang chủ đạt chuẩn không spam, không ảo, đúng mức giá thị trường.
**4. Mô tả ngắn:** Bài đăng do Host vừa lưu sẽ nằm vào Hàng đợi Đang Xử lý (Pending Queue). Admin kiểm tra nội dung bài, duyệt để Publish lên hoặc từ chối bắt Host sửa lại.
**5. Tiền điều kiện:** 
   - Admin Session đã login trên thiết bị.
   - Luôn có những Records mang trạng thái Status = `PENDING` ở Server (Dữ liệu Host đăng).
**6. Hậu điều kiện:** Bản ghi sẽ bị thay thế trường Status thành `APPROVED` (xong) hoặc `REJECTED` (Lưu thông tin Phản hồi lý do do Admin ghi lỗi).
**7. Kích hoạt:** Admin nhấn vào Mục "Duyệt Bài" trong Menu dọc Admin Dashboard.

**8. Luồng chính (Main Flow - Phê duyệt Approve):**
  1. Dashboard List liệt kê các căn ở Status Queue (Sắp theo thời gian đẩy vào trước – FIFO).
  2. Admin click chi tiết xem thử nội dung Data mà Host nhập để duyệt xem có mã QR lừa đảo ghép vào ảnh nhà hay không, hoặc nội dung text xúc phạm.
  3. Admin nhận xét nội dung mọi thứ Ok.
  4. Nhấn Button "✅ Duyệt (Approve)".
  5. Hệ thống Update Status bảng `Property` sang `Approved`.
  6. Backend gửi Log cho Host biết. Bài trở thành Trực tiếp đối với Guest.
  7. Pop Toast Success - Hệ thống đẩy bản tiếp theo trong Queue lên mặt Admin.

**9. Luồng ngoại lệ (Luồng nhánh Reject - Từ chối):**
  1. Tới bước 3 phía trên, Admin thấy số ảo giá ảo (Phòng Q1 100k/tháng), vi phạm điều khoản cấm.
  2. Admin click nút "❌ Từ chối (Reject)".
  3. Màn hình chặn Popup Dialog hiện lên: "Vui lòng đính lý do tại sao từ chối cho Host".
  4. Admin tích checkbox lý do: "Đăng sai sự thật / Ảnh xấu không rõ nét / Vi phạm từ ngữ".
  5. Cập nhật Status sang `REJECTED`, đổ chuông báo Notification tới Host yêu cầu chỉnh sửa ở UC02.

**10. Quy tắc nghiệp vụ (Business Rules):**
  - Mọi bài khi Rejected phải bắt buộc sinh field text `Reason_Message`, không cho phép Reject chay gây hoang mang đối tác.
  - Phải có Log lưu ai (Mã Admin ID nào) là người đã nhấp chuột lệnh Duyệt/Từ chối hôm đó để truy vết lỗi trách nhiệm sau này.

**11. Dữ liệu vào ra:**
  - **Dữ liệu vào (Input):** `Property ID`, Action Choice (Boolean: `isApprove` true/false), `Reason Text`.
  - **Dữ liệu ra (Output):** Thông báo Notification (Email/Chuông) gửi lại bảng `User`, Change Flag `status` Database.

**12. Đặc tả lớp MVC cho usecase:**
  - **View:** `ApprovalListView` (Datatable), `ModerationDetailView` (màn hình mô phỏng Mockup trang chi tiết của Guest cho Admin thẩm định), `ReasonDialogView`.
  - **Controller:** `ModerationController` (Quyết định flow update Database & Trigger Logic).
  - **Model:** `PropertyModel` (Thay đổi state), `NotificationService` (Bắn mail cho Host).
