# Đặc tả Nghiệp vụ: Nền tảng Cho Thuê Bất Động Sản Đà Nẵng

## 1. Tổng quan Hệ thống

- **Mô hình**: Nền tảng "Rao vặt / Thị trường" (Marketplace) cho thuê nhà đất nội bộ khu vực Đà Nẵng.
- **Thời gian dự kiến**: 2 tuần phát triển.
- **Quy mô Team**: 2 Lập trình viên.
- **Tính năng Killer**: Tìm kiếm thông minh bằng trí tuệ nhân tạo (AI Search phân tích ngữ nghĩa thói quen người dùng).

---

## 2. Phân quyền và Tác nhân (Actors)

| Actor                  | Thẩm quyền & Chức năng                                                                                                                            | Phân loại Tài khoản               |
| :--------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------ | :-------------------------------- |
| **Guest (Khách thuê)** | Người tìm thuê nhà. Xem tin toàn hệ thống, tìm kiếm (Basic & AI), và xem thông tin (SĐT/Zalo) để gọi đàm phán Chủ nhà.                            | Public User (Không cần đăng nhập) |
| **Host (Chủ Nhà)**     | Người có tài sản cho thuê. Phải được Admin cấp tài khoản. Đăng tin, quản lý, ẩn/xóa, cập nhật thông tin nhà. Mọi bài viết mới đều phải Chờ Duyệt. | Được cấp (Không tự đăng ký)       |
| **Admin (Quản trị)**   | Quản lý hệ thống. Duyệt tin (Duyệt/Từ chối), tạo tài khoản Host mới, Khóa/Mở khóa Host, lưu dữ kiện cấu hình (Loại phòng, Khu vực).               | Tài khoản cấp Admin Max Power     |

---

## 3. Cấu trúc Dữ liệu Cốt lõi (Database)

Thiết kế CSDL MySQL tối giản và Clean, gồm đúng 5 bảng truy vấn tốc độ cao:

1. `users`: Bảng tài khoản gộp cho Host & Admin. Khóa bằng cột Role.
2. `room_types`: Danh mục tùy chọn Loại phòng (1PN, 2PN, Studio...).
3. `areas`: Danh mục Khu vực thuê nhà tại Đà Nẵng (Quận Hải Châu, Quận Sơn Trà...).
4. `properties`: Bảng dữ liệu chính lưu Hồ sơ Nhà (Title, Tiền, Mô tả dải text dài thay tiện ích checkbox, ...). Links FK tới Area và Room_Type.
5. `property_images`: Album ảnh / Thumbnail cho Bài đăng.

---

## 4. Danh sách 7 Use Case Cốt Lõi

1. **UC01:** Đăng nhập hệ thống (Login)
2. **UC02:** Quản lý tin đăng bất động sản (Manage Property Postings)
3. **UC03:** Tìm kiếm và lọc cơ bản (Basic Search & Filter)
4. **UC04:** Tìm kiếm thông minh bằng AI (AI-Powered Smart Search)
5. **UC05:** Xem chi tiết và Liên hệ (View Property Details & Contact)
6. **UC06:** Kiểm duyệt tin đăng (Approve/Reject Postings)
7. **UC07:** Quản lý và Cấp tài khoản Chủ nhà (Manage & Create Host Accounts)

---

## 5. Chi tiết Đặc tả Use Case (Use Case Specification)

### UC01: Đăng nhập hệ thống

- **Actor chính:** Host, Admin
- **Mô tả:** Cho phép Chủ Nhà và Admin đăng nhập vào hệ thống quản trị nội bộ để thực hiện các nghiệp vụ tương ứng với phân quyền.
- **Pre-condition (Điều kiện tiên quyết):** Người dùng đã có tài khoản hợp lệ trên hệ thống.
- **Post-condition (Điều kiện kết thúc):** Người dùng được xác thực và chuyển hướng đến trang Dashboard tương ứng (Dashboard của Host hoặc Dashboard của Admin).
- **Flow of Events (Luồng sự kiện chính):**
  1. Người dùng chọn chức năng "Đăng nhập".
  2. Hệ thống hiển thị form đăng nhập.
  3. Người dùng nhập Email/Tên đăng nhập và Mật khẩu.
  4. Người dùng nhấn nút "Đăng nhập".
  5. Hệ thống xác thực thông tin đối chiếu với cơ sở dữ liệu.
  6. Hệ thống phân quyền và chuyển hướng người dùng vào trang quản trị tương ứng.
- **Alternative Flows (Luồng thay thế):**
  - **1a. Sai thông tin đăng nhập:** Hệ thống hiển thị thông báo "Email hoặc mật khẩu không chính xác" và cho phép nhập lại.
  - **1b. Tài khoản bị khóa:** Nếu tài khoản Host bị Admin khóa, hệ thống hiển thị thông báo "Tài khoản của bạn đã bị tạm khóa, vui lòng liên hệ Admin".

### UC02: Quản lý tin đăng bất động sản

- **Actor chính:** Host
- **Mô tả:** Chủ nhà có thể thêm mới, cập nhật thông tin (giá cả, hình ảnh, mô tả, tình trạng cho thuê), hoặc ẩn/xóa bài đăng bất động sản của mình.
- **Pre-condition:** Host đã đăng nhập thành công.
- **Post-condition:** Thông tin bất động sản được lưu trữ vào hệ thống và chuyển sang trạng thái "Chờ duyệt" (nếu là bài mới/cập nhật quan trọng).
- **Flow of Events (Luồng sự kiện chính - Thêm mới):**
  1. Chủ nhà chọn "Đăng bài/Cập nhật".
  2. Hệ thống hiển thị form nhập thông tin (Loại BĐS, diện tích, giá thuê, địa chỉ, hình ảnh...).
  3. Chủ nhà gửi thông tin đầy đủ dữ liệu và nhấn "Lưu/Đăng tải".
  4. Hệ thống kiểm tra hợp lệ của dữ liệu (validate).
  5. Hệ thống lưu tin đăng với trạng thái "Chờ duyệt".
  6. Hệ thống thông báo tạo tin thành công.
- **Alternative Flows:**
  - **2a. Dữ liệu không hợp lệ:** Nếu thiếu các trường bắt buộc hoặc định dạng ảnh không đúng, hệ thống hiển thị lỗi tại các field tương ứng và yêu cầu sửa lại.
  - **2b. Host bị khóa:** Nếu tài khoản Host bị khóa trong phiên làm việc, hệ thống ngăn chặn hành động Lưu và yêu cầu liên hệ Admin.

### UC03: Tìm kiếm và lọc cơ bản

- **Actor chính:** Guest
- **Mô tả:** Khách hàng tìm kiếm bất động sản theo từ khóa hoặc sử dụng các bộ lọc truyền thống (mức giá, khu vực, loại hình, diện tích) để thu hẹp kết quả.
- **Pre-condition:** Hệ thống có sẵn các tin đăng đang ở trạng thái "Đã duyệt/Hiển thị".
- **Post-condition:** Hệ thống trả về danh sách các bất động sản phù hợp với tiêu chí của Khách.
- **Flow of Events:**
  1. Guest nhập từ khóa vào thanh tìm kiếm hoặc chọn các khung lọc tiêu chí (dropdown).
  2. Guest nhấn "Tìm kiếm" (hoặc hệ thống tự động tải lại danh sách khi thay đổi bộ lọc).
  3. Hệ thống tiến hành truy vấn cơ sở dữ liệu với các tham số tương ứng.
  4. Hệ thống hiển thị danh sách kết quả (Ảnh thumbnail, giá, địa chỉ tóm tắt).
  5. Nếu không có kết quả, hệ thống hiển thị thông báo "Không tìm thấy bất động sản phù hợp".
- **Alternative Flows:**
  - **3a. Không tìm thấy kết quả:** Hệ thống gợi ý người dùng nới lỏng các bộ lọc (ví dụ: tăng khoảng giá, chọn khu vực lân cận).

### UC04: Tìm kiếm thông minh bằng AI

- **Actor chính:** Guest
- **Mô tả:** Khách hàng nhập một đoạn văn bản theo ngôn ngữ tự nhiên (Natural Language) mô tả nhu cầu thuê nhà của bản thân. AI sẽ phân tích yêu cầu để gợi ý ra các căn nhà phù hợp nhất.
- **Pre-condition:** Hệ thống có tích hợp API xử lý ngôn ngữ tự nhiên (ví dụ: OpenAI API, Gemini) hoặc kỹ thuật tìm kiếm ngữ nghĩa (Semantic Search / Vector DB).
- **Post-condition:** Hệ thống phân tích thành công yêu cầu và trả về danh sách ưu tiên các bất động sản phù hợp nhất kèm theo giải thích ngắn gọn (tùy chọn).
- **Flow of Events:**
  1. Guest truy cập công cụ "Tìm kiếm bằng AI".
  2. Guest nhập đoạn mô tả yêu cầu. (Ví dụ: _"Tôi cần tìm một căn chung cư 2 phòng ngủ ở Quận 1, ưu tiên có ban công, giá dưới 15 triệu, cho nuôi mèo"_).
  3. Hệ thống gợi ý hoặc người dùng nhập mô tả.
  4. Hệ thống (Backend) gửi đoạn text qua AI Content/Vector DB để phân tích từ khóa và bóc tách tiêu chí (Vị trí: Quận Hải Châu, Thú cưng: Cho phép, Giá: <15tr).
  5. Hệ thống trả về list các kết quả phù hợp nhất sắp xếp theo độ trùng khớp (Matching Score).
  6. Hệ thống trả về kết quả cho Guest dưới dạng danh sách các căn hộ phù hợp, sắp xếp từ khớp nhất tới ít khớp hơn.
- **Alternative Flows:**
  - **4a. AI Service lỗi:** Nếu API (Gemini/OpenAI) gặp lỗi hoặc timeout, hệ thống tự động chuyển sang Luồng Tìm kiếm cơ bản (UC03) và thông báo "Tính năng tìm kiếm thông minh đang bảo trì".
  - **4b. Input vô nghĩa:** Nếu đoạn text nhập vào không chứa thông tin về BĐS, hệ thống yêu cầu "Vui lòng mô tả chi tiết hơn về nhu cầu thuê nhà của bạn".

### UC05: Xem chi tiết và Liên hệ

- **Actor chính:** Guest
- **Mô tả:** Khách nhấp vào một bất động sản để xem toàn bộ thông tin chi tiết và lấy thông tin liên lạc để trao đổi.
- **Pre-condition:** Guest đang ở trang danh sách kết quả tìm kiếm hoặc trang chủ.
- **Post-condition:** Guest thấy được thông tin chi tiết và thông tin liên hệ tĩnh (SĐT, Zalo, Email) của Chủ Nhà.
- **Flow of Events:**
  1. Người dùng bấm xem 1 thẻ BĐS hiển thị trên danh sách.
  2. Hệ thống truy xuất và hiển thị trang chi tiết (Album ảnh, mô tả đầy đủ, bản đồ...).
  3. Nếu người dùng quan tâm, có thể xem SDT hoặc gửi biểu mẫu (Message) tới Chủ nhà.
  4. Hệ thống hiển thị thông tin số điện thoại / liên kết Zalo.
  5. Guest tự thực hiện cuộc gọi hoặc nhắn tin thao tác ngoài hệ thống.
- **Alternative Flows:**
  - **5a. Tin đăng bị ẩn/xóa:** Nếu trong lúc Guest đang xem mà Host ẩn tin hoặc Admin xóa tin, khi reload lại trang hệ thống sẽ thông báo "Tin này không còn khả dụng" và quay về trang chủ.

### UC06: Kiểm duyệt tin đăng

- **Actor chính:** Admin
- **Mô tả:** Quản trị viên xem xét các tin đăng mới hoặc vừa được chỉnh sửa bởi Host để quyết định cho phép hiển thị lên website hay từ chối (tránh spam, tin ảo).
- **Pre-condition:** Admin đã đăng nhập thành công. Có tin đăng ở trạng thái "Chờ duyệt".
- **Post-condition:** Tin đăng chuyển sang trạng thái "Đã duyệt" (hiển thị public) hoặc "Bị từ chối" (có lý do đính kèm).
- **Flow of Events:**
  1. Admin truy cập danh sách "Tin đăng chờ kiểm duyệt".
  2. Admin chọn một tin để xem chi tiết nội dung.
  3. Admin đối chiếu nội dung với quy định của website.
  4. Admin nhấn "Duyệt tin" hoặc "Từ chối".
  5. Cập nhật trạng thái bài viết trên CSDL.
  6. Hệ thống gửi thông báo (email/web) cho Chủ nhà về kết quả kiểm duyệt.
- **Alternative Flows:**
  - **6a. Từ chối tin:** Admin nhập lý do từ chối (Vd: ảnh mờ, thông tin sai sự thật). Tin đăng chuyển về trạng thái "Bị từ chối" và Host có thể sửa để nộp lại.

### UC07: Quản lý và Cấp tài khoản Chủ nhà

- **Actor chính:** Admin
- **Mô tả:** Cho phép Admin xem danh sách các Host, tạo mới/cấp tài khoản cho Host, xem lịch sử hoạt động, và có quyền khóa (ban) hoặc mở khóa (unban) tài khoản khi có dấu hiệu vi phạm.
- **Pre-condition:** Admin đã đăng nhập thành công.
- **Post-condition:** Tài khoản Host được tạo mới hoặc trạng thái tài khoản của Host được cập nhật (Active/Locked).
- **Flow of Events:**
  1. Admin truy cập mục "Quản lý Host/Chủ nhà".
  2. Hệ thống hiển thị danh sách tất cả Chủ nhà.
  3. (Cấp mới): Admin nhấn "Thêm Chủ nhà mới" -> Nhập Tên, SĐT, Email, Mật khẩu -> Hệ thống tạo tài khoản và gửi cho Chủ nhà.
  4. (Quản lý): Admin tìm kiếm/lọc tài khoản cần xử lý và xem chi tiết.
  5. Admin chọn action "Khóa tài khoản" và nhập lý do.
  6. Hệ thống cập nhật trạng thái Locked cho tài khoản đó (Host bị khóa sẽ không đăng nhập được và các tin đăng bị ẩn).
- **Alternative Flows:**
  - **7a. Trùng thông tin:** Nếu tạo Host mới với Email hoặc SĐT đã tồn tại, hệ thống báo lỗi "Dữ liệu đã tồn tại trong hệ thống".

---

## 6. Yêu cầu Phi chức năng (Non-Functional Requirements)

- **Performance (Hiệu năng):**
  - Thời gian phản hồi cho các truy vấn tìm kiếm cơ bản phải < 1 giây.
  - Thời gian xử lý tìm kiếm AI (gọi API ngoại vi) không quá 5 giây.
  - Hỗ trợ tối thiểu 50 người dùng truy cập đồng thời.
- **Security (Bảo mật):**
  - Mật khẩu người dùng phải được mã hóa bằng thuật toán mạnh (ví dụ: BCrypt).
  - Phân quyền chặt chẽ cấp API: Host không thể xóa/sửa bài đăng của Host khác.
  - Bảo vệ chống các cuộc tấn công cơ bản: SQL Injection, XSS.
- **Usability (Độ khả dụng):**
  - Giao diện Responsive, hiển thị tốt trên cả Desktop và Mobile.
  - Hệ thống màu sắc và tiêu đề rõ ràng, giúp Guest dễ dàng đọc thông tin BĐS.
  - Form đăng tin của Host phải có hướng dẫn rõ ràng cho từng field.

---

## 7. Kiến trúc và Design Patterns

Hệ thống áp dụng các mẫu thiết kế hướng đối tượng để đảm bảo tính mở rộng và dễ bảo trì:

- **Kiến trúc MVC (Model-View-Controller):** Tách biệt dữ liệu, giao diện và logic xử lý.
- **Strategy Pattern:** Áp dụng cho logic Tìm kiếm. Interface `SearchStrategy` với hai implementation: `BasicSearch` (SQL query) và `AISearch` (Vector/AI API). Điều này giúp dễ dàng thay đổi hoặc thêm phương thức tìm kiếm mới.
- **Observer Pattern:** Sử dụng để gửi thông báo. Khi trạng thái Property thay đổi (được duyệt/từ chối), hệ thống tự động thông báo cho Host liên quan qua Web Notification hoặc Email.
- **State Pattern:** Quản lý vòng đời tin đăng. Class `Property` sẽ có các trạng thái: `Draft`, `Pending`, `Approved`, `Rejected`. Mỗi trạng thái sẽ có các quy tắc xử lý khác nhau (ví dụ: chỉ `Approved` mới được hiển thị Public).

---

## 8. Công nghệ Sử dụng (Tech Stack)

- **Backend:** Java Spring Boot (Ưu tiên tính hướng đối tượng mạnh mẽ, dễ triển khai các Design Patterns).
- **Frontend:**
  - **Option 1:** Thymeleaf (Server-side rendering, nhanh cho dự án 2 tuần).
  - **Option 2:** React (Modern, trải nghiệm mượt mà hơn cho tính năng AI Search).
  - _Quyết định:_ **Spring Boot + React** để đảm bảo tính hiện đại và WOW factor cho Killer Feature.
- **Database:** MySQL.
- **AI Integration:** Google Gemini API (Dễ tích hợp, hỗ trợ tiếng Việt tốt).
- **Deployment (Dự kiến):** Docker + Hosting (Vercel/Render).
