# Đặc tả Use Case: UC04 - Tìm kiếm thông minh bằng AI

**1. Tên Use Case:** Tìm kiếm thông minh bằng AI (Smart Search)
**2. Actor chính:** Guest (Khách truy cập)
**3. Mục tiêu:** Đơn giản hóa việc tìm phòng, mô phỏng như chat tự nhiên với chuyên gia môi giới nhờ AI NLP semantic search.
**4. Mô tả ngắn:** Guest nhập mong muốn qua dạng câu văn Text bình thường. AI giải nghĩa đoạn text đó và bóc tách các tham số, gọi Database trả về căn hộ theo độ sát nghĩa nhất.
**5. Tiền điều kiện:** 
   - Module API bên thứ 3 (OpenAI/Gemini) hoặc thư viện xử lý NLP nội bộ đang hoạt động bình thường.
   - Các bài viết Database phải đồng bộ Index với giải pháp AI Vector Search.
**6. Hậu điều kiện:** AI phản hồi bằng lời nói tự nhiên kèm danh sách bất động sản liên quan dựa trên nghĩa biểu đạt.
**7. Kích hoạt:** Khách nhập câu hỏi vào "Khung AI Chat Box" và submit.

**8. Luồng chính (Main Flow):**
  1. Guest ấn vào Tab hoặc Popup "AI Assistant" dành riêng cho tìm kiếm.
  2. Hệ thống hiển thị giao diện mô phỏng Chatbot với vài Chip Prompt (gợi ý nhanh).
  3. Khách nhập câu text: "Tìm chung cư 2 ngủ cho sinh viên Cầu Giấy dưới 10 củ, nuôi được chó".
  4. Guest nhấn nút Enter (Gửi tin).
  5. Hệ thống in Loading Indicator (Animation gõ chữ) tạo cảm giác đợi.
  6. Backend gửi raw prompt này lên mô hình AI Language.
  7. AI phân tích, trả về JSON Object được làm sạch tiêu chí: `{type: "chung cư", bedrooms: 2, location: "Cầu Giấy", target: "sinh viên", pet_allowed: true, max_price: 10000000}`.
  8. Hệ thống lấy object JSON đó đem nhét vào Database tiến hành Tìm Kiếm Nâng Cao / hoặc tìm kiếm Semantic Vector.
  9. Hệ thống ghép kết quả tạo chuỗi String thân thiện (Ví dụ: "Dạ, em tìm được 3 căn chung cư phù hợp cho sinh viên, giá dưới 10tr ở Cầu Giấy và cho phép nuôi pet ạ").
  10. Trả UI về cho Khách kèm Carousels (những thanh thẻ hình ảnh) gợi ý phòng nhà.

**9. Luồng ngoại lệ (Exception Flow):**
  - **A1. Lỗi phân tích Text quá nghèo nàn:** Nếu Guest ghi "Tuyệt vời vãi", AI không xác nhận đây là intent tìm nhà. Hệ thống báo lại Bot "Có vẻ yêu cầu tìm nhà của vị khách chưa cụ thể, mình cần mô tả địa điểm hoặc ngân sách nhé!".
  - **A2. Request API Model lỗi:** Server mất kết nối AI. Backend trả về thông báo fall-back báo lỗi xin lỗi do Backend đang nâng cấp tải và định hướng qua Tab Tìm theo Bộ Lọc UC03.

**10. Quy tắc nghiệp vụ (Business Rules):**
  - Cần quy định bộ tham số Prompt Engineering phía backend cực kỳ cẩn trọng (chỉ bó gọn bắt AI bóc tách JSON, không làm chatbot nói linh tinh ngoài lề nhà cửa).
  - Tần suất rate-limit: 1 User vãng lai (khóa theo IP + Session Cookie) chỉ chat được 5 lượt/1 session để cân đối chi phí API Cloud tiền vé.

**11. Dữ liệu vào ra:**
  - **Dữ liệu vào (Input):** User Input Message (Plain text tự nhiên).
  - **Dữ liệu ra (Output):** AI Response Text, Dữ liệu danh sách JSON Property Matches.

**12. Đặc tả lớp MVC cho usecase:**
  - **View:** `AiChatWidgetView` (Giao diện bong bóng tin nhắn trái/phải).
  - **Controller:** `AiConversationController` (Đón câu nhắn Text, gọi Service AI NLP).
  - **Model:** `AiNLPService` (Tương tác API ngoài LLM), `PropertyModel` (Query dữ liệu bằng tiêu chí trích xuất JSON).
