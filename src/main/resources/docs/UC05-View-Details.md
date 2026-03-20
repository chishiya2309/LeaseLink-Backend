# Đặc tả Use Case: UC05 - Xem chi tiết và Liên hệ

**1. Tên Use Case:** Xem chi tiết và Liên hệ
**2. Actor chính:** Guest (Khách tìm nhà)
**3. Mục tiêu:** Cung cấp thông tin tường minh về 1 đơn vị bất động sản (phòng, hình, nội dung, bản đồ), và hiển thị Contact Info để Khách liên hệ
**4. Mô tả ngắn:** Click vào Thumbnail (Ảnh đại diện do chủ nhà ghim) để đi đến Property Profile page. Guest ấn giải mã SĐT để thực hiện trao đổi trên Zalo / Điện thoại trực tiếp với người thuê.
**5. Tiền điều kiện:** 
   - Guest thao tác trên màn hình danh sách Property (UC03 / UC04).
   - Bản ghi Property tồn tại và đang ở `APPROVED`.
**6. Hậu điều kiện:** Guest xem full bài viết và lấy được Hotline / link Deep URL dẫn đến kênh liên lạc của Host.
**7. Kích hoạt:** Người dùng nhấp chuột Single Click vào Tiêu đề / Hình ảnh đại diện (Thumbnail) của 1 bất động sản cụ thể.

**8. Luồng chính (Main Flow):**
  1. Guest chọn 1 tài sản từ màn hình tìm kiếm ngoài.
  2. Hệ thống chuyển điều hướng URL sang `.../property/{id}`.
  3. Hệ thống query truy xuất toàn phần mọi Data liên quan Record ID đó.
  4. Hệ thống render giao diện Trang Chi Tiết:
     - Khu vực Image Lightbox Slider (Thumbnail hiển thị lớn nhất đầu tiên, các hình phụ và video ở dưới/ngang).
     - Khu vực thông số và bài báo Description.
     - Khu vực Map ghim API hiển thị vị trí tĩnh.
     - Khu vực Sidebar với thông tin giá và Nút "Hiện Số điện thoại".
  5. Guest ấn vào nút "Hiển thị Số Điện Thoại / Call to action".
  6. Hệ thống thực thi Logic, chuyển dải String (vd \*\*\*88) thành Full chữ chuẩn của SĐT Host.
  7. Guest lấy nội dung SĐT để bấm gọi Call truyền thống hoặc quét QR mở App Zalo qua url `zalo.me/[SDT]`.
  8. Trao đổi việc coi hình ảnh nhà, đi làm hợp đồng offline cọc tiền.

**9. Luồng ngoại lệ (Exception Flow):**
  - **A1. Property bị Host / Admin ngưng bán / Xóa:** Khi ấn mở URL, DB báo không tìm thấy record hoặc nó nằm ở ID bị Deleted. Hệ thống hiển thị 404 Layout -> "Tin đăng chưa sẵn sàng hoặc đã ẩn. Bạn hãy quay lại trang chủ".

**10. Quy tắc nghiệp vụ (Business Rules):**
  - Số điện thoại của Host mặc định phải bị ẩn mã hóa 1/2 mặt nạ dạng `097.XXX.882` cho đến khi User click lấy số. Ý đồ của việc này là để đo Action Tracking Analytics: xem thử căn nhà đó tạo ra bao nhiêu lần chuyển giao "khách thực sự quan tâm bấm gọi".

**11. Dữ liệu vào ra:**
  - **Dữ liệu vào (Input):** `Property_ID` từ Route URL. Lệnh Click Tracking của Guest.
  - **Dữ liệu ra (Output):** Toàn bộ Field Data của bảng `Property` + `Images`, Dữ liệu `Users.PhoneNumber`.

**12. Đặc tả lớp MVC cho usecase:**
  - **View:** `PropertyDetailView` (Layout phức tạp ảnh bên trái to, contact box mua hàng góc phải), `LightBoxSliderComponent`.
  - **Controller:** `PropertyController` (Hàm `show($id)`), `AnalyticController` (Hàm ghi log Tracking "User ấn coi sdt").
  - **Model:** `PropertyModel` (fetch DB Join bảng User Host để lấy Thông tin tên Host).
