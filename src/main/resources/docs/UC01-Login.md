# Đặc tả Use Case: UC01 - Đăng nhập và Đăng ký

**1. Tên Use Case:** Đăng nhập hệ thống (Login) và Đăng ký Chủ nhà (Host Registration)
**2. Actor chính:** Guest, Host (Chủ Nhà), Admin (Quản trị viên)
**3. Mục tiêu:**

- Cho phép người dùng (Host, Admin) xác thực danh tính để truy cập vào hệ thống theo đúng quyền hạn.
- Cho phép người dùng mới đăng ký tài khoản để trở thành Chủ nhà (Host), chờ Admin phê duyệt.
  **4. Mô tả ngắn:**
- **Đăng ký:** Người dùng nhập các thông tin cá nhân cơ bản để tạo tài khoản Chủ nhà mới. Tài khoản khi tạo xong sẽ mang trạng thái `pending` (chờ duyệt).
- **Đăng nhập:** Người dùng nhập thông tin tài khoản (Email, Mật khẩu) để đăng nhập vào trang quản trị (Dashboard). Tài khoản Chủ nhà phải được Admin chuyển sang trạng thái `active` mới có thể tiến hành đăng tin.
  **5. Tiền điều kiện:**
- **Đăng nhập:** Người dùng đã có tài khoản trên hệ thống. Trạng thái hiện tại là chưa đăng nhập.
- **Đăng ký:** Người dùng truy cập vào trang đăng ký với tư cách khách (Guest), và sử dụng Email chưa từng tồn tại trên hệ thống.
  **6. Hậu điều kiện:**
- Đăng nhập thành công: Phiên làm việc (Session/Token) được thiết lập, người dùng được chuyển hướng đến Dashboard tương ứng.
- Đăng ký thành công: Một bản ghi Chủ nhà mới được lưu vào hệ thống với trạng thái `pending`.
- Thất bại (Đăng nhập/Đăng ký): Trạng thái không thay đổi, hệ thống hiển thị thông báo lỗi.
  **7. Kích hoạt:**
- Người dùng nhấp vào nút "Đăng nhập" hoặc "Đăng ký" trên giao diện trang chủ hoặc thanh điều hướng.

**8. Luồng chính (Main Flow):**

**8.1. Luồng Đăng nhập:**

1. Người dùng bấm "Đăng nhập".
2. Hệ thống hiển thị Form đăng nhập.
3. Người dùng nhập `Email/Tên đăng nhập` và `Mật khẩu`.
4. Người dùng nhấn nút "Đăng nhập".
5. Hệ thống tiếp nhận, kiểm tra dữ liệu có đúng định dạng không.
6. Hệ thống truy vấn CSDL, đối chiếu hash mật khẩu với dữ liệu thực tế.
7. Hệ thống xác thực thành công, tiếp tục kiểm tra phân quyền (Role) và trạng thái tài khoản (Status).
8. Hệ thống điều hướng: Admin -> `Admin Dashboard`, Host ứng với `active` -> `Host Dashboard`.

**8.2. Luồng Đăng ký (Dành cho Chủ nhà):**

1. Người dùng bấm "Đăng ký" hoặc "Trở thành Chủ nhà".
2. Hệ thống hiển thị Form đăng ký tài khoản Chủ nhà.
3. Người dùng nhập các thông tin bắt buộc: `Họ và tên`, `Email`, `Mật khẩu`, `Xác nhận mật khẩu`, `Số điện thoại`.
4. Người dùng nhấn nút "Đăng ký".
5. Hệ thống kiểm tra tính hợp lệ của dữ liệu (Email định dạng chuẩn, Mật khẩu khớp nhau và đủ mạnh, Email chưa tồn tại).
6. Hệ thống tiến hành mã hoá mật khẩu (hash) và tạo mới bản ghi người dùng vào CSDL với `role` = `HOST` và `status` = `pending`.
7. Hệ thống tiến hành gửi thông báo (realtime và lưu db) cho các Admin về việc có Host mới đăng ký.
8. Hệ thống hiển thị thông báo: "Đăng ký thành công! Tài khoản của bạn đang ở trạng thái chờ duyệt. Admin xác nhận thì bạn mới được đăng tin nhé."

**9. Luồng ngoại lệ (Exception Flow):**

**9.1. Ngoại lệ Đăng nhập:**

- **A1. Bỏ trống thông tin:** (Tại bước 5) Nếu người dùng để trống form, hệ thống chặn gửi và hiện khung đỏ nhắc nhở.
- **A2. Sai thông tin:** (Tại bước 6) Nếu Email không tồn tại hoặc mật khẩu sai, thông báo "Tài khoản hoặc mật khẩu không chính xác". Quay lại form.
- **A3. Tài khoản đang chờ duyệt:** (Tại bước 7) Nếu tài khoản có `status` là **`pending`**, đăng nhập vào và hiển thị thông báo: "Tài khoản của bạn đang chờ phê duyệt từ Quản trị viên."
- **A4. Tài khoản bị khóa:** (Tại bước 7) Nếu tài khoản có `status` là **`locked`**, chặn đăng nhập và báo: "Tài khoản của bạn đã bị khóa. Vui lòng liên hệ Admin."

**9.2. Ngoại lệ Đăng ký:**

- **B1. Thiếu thông tin hoặc sai định dạng:** (Tại bước 5) Form hiện lỗi ở các trường không thoả mãn điều kiện nhập liệu.
- **B2. Trùng Email:** (Tại bước 5) Nếu Email đã tồn tại, thông báo: "Email này đã được đăng ký. Vui lòng sử dụng Email khác hoặc Đăng nhập."
- **B3. Mật khẩu không trùng khớp:** (Tại bước 5) Thông báo "Xác nhận mật khẩu không khớp. Vui lòng nhập lại."

**10. Quy tắc nghiệp vụ (Business Rules):**

- Mật khẩu bắt buộc mã hóa bằng thuật toán băm chiều (Bcrypt). Hệ thống tuyệt đối không lưu dạng plain-text.
- Tất cả tài khoản Chủ nhà khi vừa **Đăng ký mới** đều phải nhận trạng thái mặc định là **`pending`**.
- Admin là người duy nhất có quyền xem xét hồ sơ/trạng thái người dùng và chuyển trạng thái từ `pending` sang `active` (duyệt) hay `locked` (khoá/từ chối duyệt).
- Chống Brute-force: Nếu đăng nhập sai quá liên tục 5 lần, tài khoản/IP đó sẽ tạm thời bị khóa đăng nhập trong vòng 15 phút.

**11. Dữ liệu vào ra:**

- **Dữ liệu vào (Input):**
  - Đăng nhập: `email`, `password`.
  - Đăng ký: `full_name`, `email`, `password`, `confirm_password`, `phone_number`.
- **Dữ liệu ra (Output):**
  - Đăng nhập: Cấp Phiên làm việc (Session ID / JWT Token), thông tin hồ sơ `User Profile`.
  - Đăng ký: Bản ghi mới trong bảng `users`, trạng thái `pending`.
