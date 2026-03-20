# Đặc tả Use Case: UC02 - Quản lý tin đăng bất động sản

**1. Tên Use Case:** Quản lý tin đăng bất động sản
**2. Actor chính:** Host (Chủ Nhà)
**3. Mục tiêu:** Hỗ trợ chủ nhà thêm mới, cập nhật thông tin và gỡ bỏ các bài đăng cho thuê nhà của mình.
**4. Mô tả ngắn:** Host thao tác CRUD bài đăng trong bảng điều khiển. Mọi tin đăng thiết lập xong sẽ được chuyển vào hàng đợi để Admin kiểm duyệt.
**5. Tiền điều kiện:** 
   - Chủ nhà (Host) đã đăng nhập thành công vào hệ thống (Host Dashboard).
**6. Hậu điều kiện:** 
   - Bản ghi của bài đăng bất động sản được lưu vào Cơ sở Dữ liệu thành công.
   - Trạng thái (Status) của tin bài lập tức chuyển thành "Chờ duyệt" (Pending) (nếu thêm mới hoặc sửa thông tin trọng yếu).
**7. Kích hoạt:** Host nhấn nút "Đăng tin mới" hoặc chọn thao tác "Cập nhật / Xóa" ở màn hình danh sách bài viết.

**8. Luồng chính (Main Flow - Đăng tin mới):**
  1. Host chọn "Đăng tin mới".
  2. Hệ thống tải Form thông tin.
  3. Host điền hoặc chọn các trường nội dung: Tiêu đề, Giá, Diện tích, Địa chỉ, Khu vực, Loại Bất Động Sản (Nhà nguyên căn, Chung cư, Căn hộ), Số phòng ngủ (với Căn hộ gồm 1PN, 2PN, Studio...), Mô tả chi tiết.
  4. Host đính kèm ảnh chụp/video cho bất động sản và chọn 1 tấm ảnh làm ảnh đại diện (Thumbnail).
  5. Host nhấn nút "Lưu và Đăng xuất bản".
  6. Hệ thống kiểm duyệt file ảnh bằng thuật toán validate, kiểm tra các trường bắt buộc (`required`).
  7. Hệ thống tiến hành lưu gói dữ liệu bài đăng vào cơ sở dữ liệu với trạng thái `PENDING`.
  8. Trả về thông báo thành công và điều hướng Host trở về danh sách quản lý.

**9. Luồng ngoại lệ (Exception Flow):**
  - **A1. Cập nhật/Sửa bài viết:** Nếu Host cập nhật 1 bài viết có sẵn, hệ thống fetch dữ liệu cũ vào form. Quá trình lưu tiến hành lưu đè lên ID cũ. Status từ `APPROVED` trả lùi về `PENDING` (cần duyệt lại).
  - **A2. Xóa/Ẩn bài viết:** Host chọn Ẩn tin. Hệ thống hỏi "Bạn có muốn ẩn/xóa tin này không?". Cập nhật Status thành "Xóa mềm (Hidden/Deleted)".
  - **A3. Thiếu thông tin bắt buộc / Lỗi file ảnh:** Thiếu dữ liệu bắt buộc hoặc upload file không phải JPG/PNG/WebP, hệ thống dừng lưu, thông báo lỗi đỏ ngay tại input đó.

**10. Quy tắc nghiệp vụ (Business Rules):**
  - Host mỗi người tối đa upload 1 video và 10 ảnh / bài (tùy cấu hình config file), mỗi ảnh limit <= 10MB để tiết kiệm storage.
  - Sau khi đăng tin, Host không được public tin ngay mà phải đợi qua tay "Kiểm duyệt".

**11. Dữ liệu vào ra:**
  - **Dữ liệu vào (Input):** Thể loại nhà (Nhà nguyên căn, Chung cư, Căn hộ), Phân loại phòng ngủ (1PN, 2PN, Studio... áp dụng cho Căn hộ), Giá tiền (number), Khu vực (Area ID), Địa chỉ chi tiết (text), Text Mô tả, File Hình ảnh/Video.
  - **Dữ liệu ra (Output):** Thông báo kết quả `success/failed`, Bản ghi DB `Property` mới (kèm Property ID sinh tự động).

**12. Đặc tả lớp MVC cho usecase:**
  - **View:** `PropertyListView` (bảng quản lý), `PropertyFormView` (giao diện form nhập liệu, tính năng chọn 1 ảnh gốc làm thumbnail).
  - **Controller:** `PropertyController` (Handles các actions: Create, Update, Delete. Chịu trách nhiệm gọi thư viện xử lý resize ảnh, lưu file / upload lên AWS S3 rồi hứng Image URL).
  - **Model:** `PropertyModel` (tương tác trực tiếp để insert db), `ImageModel` (bảng phụ chứa array link ảnh map với Property ID).
