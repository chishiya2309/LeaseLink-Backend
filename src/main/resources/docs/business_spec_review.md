# 📋 Đánh giá Business Specification — Nền tảng Cho Thuê BĐS Đà Nẵng

## Kết luận tổng quan

> [!TIP]
> Tài liệu **đã ở mức tốt** cho một project môn học CNPM Hướng Đối Tượng. Đề tài thực tế, scope vừa phải, có đủ các actor/use case cơ bản. Dưới đây là phân tích chi tiết và **một số điểm cần bổ sung/điều chỉnh** để phù hợp hơn với yêu cầu môn học.

---

## ✅ Điểm mạnh

| Tiêu chí | Đánh giá |
|:---|:---|
| **Đề tài thực tế** | Cho thuê BĐS là bài toán phổ biến, dễ demo, dễ hiểu |
| **Phân quyền rõ ràng** | 3 actor (Guest, Host, Admin) với phân loại tài khoản cụ thể |
| **Use Case đầy đủ** | 7 UC core bao phủ CRUD, Search, Auth, Approval workflow |
| **Flow of Events** | Mỗi UC có Pre/Post-condition và luồng sự kiện chính — đúng format đặc tả |
| **Database tối giản** | 5 bảng, cấu trúc rõ ràng, phù hợp scope 2 tuần |
| **Killer Feature** | AI Search là điểm nhấn tạo sự khác biệt |

---

## ⚠️ Điểm cần bổ sung / điều chỉnh

### 1. 🔴 Thiếu yếu tố "Hướng Đối Tượng" trong tài liệu

> [!IMPORTANT]
> Đây là môn **Công nghệ Phần mềm Hướng Đối Tượng** — giảng viên sẽ đánh giá cao nếu tài liệu thể hiện tư duy OOP ngay từ bước đặc tả.

**Nên bổ sung:**
- **Class Diagram** sơ bộ: Xác định các class chính (`User`, `Property`, `RoomType`, `Area`, `PropertyImage`) và quan hệ giữa chúng (association, composition, inheritance)
- **Kế thừa (Inheritance)**: Ví dụ `User` → `Host` / `Admin` (hoặc dùng `Role` enum — cần làm rõ lý do chọn design pattern nào)
- **Sequence Diagram** cho ít nhất 2-3 UC quan trọng (UC01, UC02, UC06)
- **State Diagram** cho vòng đời tin đăng: `Draft → Pending → Approved / Rejected → Hidden / Deleted`

### 2. 🟡 Alternative Flow / Exception Flow còn thiếu

Các UC hiện chỉ có **luồng chính** (Happy Path). Môn học yêu cầu đặc tả đầy đủ hơn:

| UC | Alternative/Exception cần thêm |
|:---|:---|
| **UC01** | Sai mật khẩu, tài khoản bị khóa, quên mật khẩu |
| **UC02** | Validate fail (thiếu field, ảnh quá lớn), Host bị khóa không thể đăng |
| **UC04** | AI service lỗi / timeout → fallback về tìm kiếm cơ bản |
| **UC06** | Admin từ chối → Host chỉnh sửa → Re-submit |

### 3. 🟡 Non-Functional Requirements (NFR) — Chưa có

Môn CNPM thường yêu cầu đặc tả cả yêu cầu phi chức năng:

- **Performance**: Thời gian tải trang tìm kiếm < 2 giây
- **Security**: Mã hóa mật khẩu (BCrypt), phân quyền API endpoint
- **Usability**: Responsive design, hỗ trợ mobile
- **Availability**: Uptime target (nếu deploy)
- **Scalability**: Dự kiến số lượng tin đăng / người dùng đồng thời

### 4. 🟡 Về tính khả thi của AI Search trong 2 tuần

> [!WARNING]
> AI Search (UC04) là tính năng hay nhưng khá phức tạp. Với 2 tuần + 2 dev, cần cân nhắc:

**Rủi ro:**
- Tích hợp OpenAI/Gemini API cần xử lý: API key, rate limit, cost, error handling
- Nếu dùng Vector DB (Semantic Search) → setup phức tạp thêm
- Có thể chiếm 40-50% thời gian dev

**Đề xuất:**
- **MVP**: Dùng Gemini API đơn giản (gửi prompt + property list → nhận kết quả). Không cần Vector DB.
- **Fallback plan**: Nếu không kịp, có thể chuyển thành "Tìm kiếm nâng cao" (keyword-based) và giữ AI Search cho demo/future scope
- Nên ghi rõ trong spec: đây là **Should-have** (MoSCoW), không phải **Must-have**

### 5. 🟢 Gợi ý thêm Design Pattern phù hợp môn học

Để tăng điểm OOP, nên áp dụng và ghi rõ trong tài liệu:

| Pattern | Áp dụng vào |
|:---|:---|
| **MVC** | Kiến trúc tổng thể (Controller, Service, Repository, View) |
| **Strategy** | Thuật toán tìm kiếm (BasicSearch vs AISearch) — cùng interface, khác implementation |
| **Observer** | Thông báo khi tin được duyệt/từ chối → notify Host |
| **Factory** | Tạo User theo Role (Host / Admin) |
| **State** | Vòng đời tin đăng (Pending → Approved → Rejected) |

### 6. 🟢 Tech Stack nên ghi rõ

Tài liệu nên bổ sung phần **Technology Stack**:

```
- Backend:  Spring Boot (Java) — phù hợp OOP
- Frontend: React / Thymeleaf
- Database: MySQL
- AI:       Gemini API (Google AI)
- Build:    Maven / Gradle
```

---

## 📊 So sánh với yêu cầu môn học

| Yêu cầu môn CNPM HĐT | Có trong spec? | Ghi chú |
|:---|:---:|:---|
| Use Case Diagram | ❌ | Cần vẽ diagram, không chỉ liệt kê |
| Use Case Specification | ✅ | Đã có, cần thêm Alternative Flow |
| Class Diagram | ❌ | **Bắt buộc** — cần bổ sung |
| Sequence Diagram | ❌ | Nên có ít nhất 2-3 cái |
| Activity Diagram | ❌ | Nên có cho UC02 (luồng đăng tin) |
| State Diagram | ❌ | Nên có cho Property lifecycle |
| Non-Functional Requirements | ❌ | Cần bổ sung |
| Design Pattern | ❌ | Rất nên ghi rõ để tăng điểm |
| ERD (Entity Relationship Diagram) | ⚠️ | Có mô tả text, chưa có diagram |

---

## 🎯 Đề xuất hành động tiếp theo

1. **Bổ sung các diagram UML**: Class, Use Case, Sequence, State — đây là phần cốt lõi của môn HĐT
2. **Thêm Alternative/Exception Flow** cho mỗi UC
3. **Thêm mục Non-Functional Requirements**
4. **Xác định rõ MoSCoW priority** cho từng feature (đặc biệt AI Search)
5. **Ghi rõ Tech Stack và Design Pattern** sẽ áp dụng
6. **Vẽ ERD** thay vì chỉ mô tả bằng text

> [!NOTE]
> Nội dung nghiệp vụ (business logic) của đề tài đã **ổn và phù hợp**. Vấn đề chính là cần bổ sung **phần kỹ thuật phần mềm hướng đối tượng** (UML diagrams, design patterns, etc.) để đáp ứng yêu cầu môn học.
