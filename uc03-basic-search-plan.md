# Kế hoạch triển khai Backend UC03 (Basic Search)

## 🧠 Brainstorm: Cơ chế Query Tìm Kiếm Cơ Bản

### Bối cảnh
UC03 yêu cầu tìm kiếm các bài đăng bất động sản dựa trên nhiều tiêu chí (Khu vực, Giá thuê tối thiểu/tối đa, Loại BĐS) có thể điền hoặc bỏ trống từ người dùng. Hệ thống bắt buộc phải thỏa mãn quy tắc nghiệp vụ: Chỉ hiển thị bài đăng có `status = 'APPROVED'` và luôn sắp xếp theo ngày đăng mới nhất. Kết quả trả về cần có phân trang (Pagination).

---

### Option A: Trọng tâm dùng Spring Data JPA Specification (Criteria API)
Sử dụng Criteria API của JPA thông qua interface `JpaSpecificationExecutor` để tùy biến xây dựng các chuỗi truy vấn động (Dynamic Queries) dựa vào các param được truyền vào.

✅ **Pros:**
- Cực kỳ linh hoạt khi xây dựng query động (chỉ chèn điều kiện `AND` khi tham số khác null/empty).
- Nằm sẵn trong thư viện Spring Data JPA, không cần thêm thư viện bên thứ ba.
- Dễ dàng tích hợp với đối tượng `Pageable` để xử lý phân trang tự động.

❌ **Cons:**
- Cú pháp viết custom `Specification` khá dài dòng và khó đọc so với SQL thuần.

📊 **Effort:** Medium

---

### Option B: JPQL với `@Query` và tính năng kiểm tra Null (COALESCE)
Sử dụng annotation `@Query` trong Repository với mã JPQL thuần, dùng `(:param IS NULL OR field = :param)` để xử lý điều kiện động truyền vào.

✅ **Pros:**
- Rất dễ hiểu nếu đã có kiến thức cơ bản về SQL/JPQL.
- Code gọn tự gói trong Repository.

❌ **Cons:**
- Tốc độ query giảm (hỗn loạn Execution Plan của SQL)
- Khó test và bảo trì khi tăng lượng cột lọc tĩnh.

📊 **Effort:** Low

---

### Option C: Sử dụng QueryDSL
Tích hợp thư viện Java QueryDSL tạo DSL type-safe

✅ **Pros:**
- Code siêu sạch, type-safe (tránh NPE) theo Fluent API.

❌ **Cons:**
- Công đoạn setup cấu hình Gradle/Maven cồng kềnh, ko phù hợp spec nhanh gọn.

📊 **Effort:** High

---

## 💡 Recommendation
**Option A** Được ưu tiên sử dụng.

---

*(Bao gồm thêm chi tiết implementation tương tự trong `brain/.../implementation_plan.md` artifact).*
