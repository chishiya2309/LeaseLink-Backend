# Đặc tả Use Case: UC03 - Tìm kiếm và lọc cơ bản

**1. Tên Use Case:** Tìm kiếm và lọc cơ bản (Basic Search & Filter)
**2. Actor chính:** Guest (Khách truy cập)
**3. Mục tiêu:** Cho phép Khách tìm kiếm các căn bất động sản đúng theo nhu cầu thuê mướn dựa trên các tiêu chí cụ thể (loại bất động sản (Nhà, Chung Cư, Căn Hộ), khu vực (quận/huyện), số phòng ngủ, mức giá, có cho phép thú cưng hay không).
**4. Mô tả ngắn:** Guest sử dụng thanh tìm kiếm chọn các Dropdown menu bộ lọc để query kết quả chi tiết.
**5. Tiền điều kiện:**

- Website đang hiển thị luồng public cho người dùng ngoài.;
- Cơ sở dữ liệu tồn tại các bài bất động sản đang ở trạng thái CÔNG KHAI (`APPROVED`).
  **6. Hậu điều kiện:** Hệ thống trả về list các bài đăng khớp hoàn toàn với các truy vấn của Guest, xếp hạng bằng thuật toán (VD: Mới nhất).
  **7. Kích hoạt:** Thay đổi thông số Bộ lọc. Nhấn "Tìm kiếm".

**8. Luồng chính (Main Flow):**

1. Guest quan sát khu vực thanh Search Component ở Trang Chủ.
2. Guest tinh chỉnh Dropdown:
   - Khu vực (Ví dụ: Quận Ngũ Hành Sơn, Quận Sơn Trà...).
   - Lọc theo Mức Giá (với thanh kéo 2 đầu).
   - Loại Bất Động Sản (Có 3 loại chính: Nhà nguyên căn, Chung cư, Căn hộ).
   - Số giường.
   - Cho phép thú cưng.
3. Guest nhấn CTA "Tìm kiếm".
4. Hệ thống tóm tắt các tham số Filter, gửi Http Request (Query string params).
5. Back-End tiến hành tạo Query bằng phép `AND` cho các bộ điều kiện vào CSDL.
6. Back-End trả về Data format mảng (Array).
7. Hệ thống Front-End in ra màn hình lưới (Grid) hiển thị thẻ Card cho từng Căn nhà (chứa ảnh thumbnail nhỏ, Tiêu đề, Giá tổng, Địa chỉ tóm tắt).
8. Hiển thị tính năng thanh Phân trang (Pagination) ở dưới cùng.

**9. Luồng ngoại lệ (Exception Flow):**

- **A1. Không tìm thấy bài viết (Empty List):** Hệ thống query xong trả về kết quả 0 matches. Front-End hiển thị thông báo "Không tìm thấy kết quả phù hợp với tiêu chí. Bạn hãy điều chỉnh bộ lọc"
- **A2. Khách để trống bộ lọc:** Nếu Guest chỉ cần nhấn nút "Search" rỗng, hệ thống sẽ bỏ qua mọi Parameter và lấy lệnh "Lấy tất cả căn, sắp xếp ngày đăng gần nhất (Descending)".

**10. Quy tắc nghiệp vụ (Business Rules):**

- CHỈ fetch và hiển thị những `properties` ở tình trạng `APPROVED`. Không lộ các bài `PENDING`, `LOCKED`, hoặc `HIDDEN`.
- Phân trang cấu hình Page Size từ 10 - 20 items / trang để load ứng dụng mượt, không làm dump RAM Server.

**11. Dữ liệu vào ra:**

- **Dữ liệu vào (Input):** Các tham số Long areaId, Long roomTypeId, BigDecimal minPrice, BigDecimal maxPrice, Short bedrooms, boolean allowPets.
- **Dữ liệu ra (Output):** Json Mảng Object `Property`, Tổng Count (để tính số trang Pagination).
