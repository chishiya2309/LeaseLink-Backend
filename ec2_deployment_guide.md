# 🚀 Hướng dẫn chi tiết Tạo EC2 & Deploy Backend Spring Boot

Bài viết này cung cấp lộ trình chuẩn mực "từ tay trắng đến deploy" một backend Spring Boot đóng gói Docker chạy trên máy chủ ảo Amazon EC2.

---

## Bước 1: Khởi tạo EC2 Instance (Máy ảo AWS)

1. Đăng nhập vào [AWS Console](https://console.aws.amazon.com/), tìm dịnh vụ **EC2** trên thanh tìm kiếm.
2. Tại bảng điều khiển EC2 Dashboard menu trái, click vào **Instances** > Nhấn nút màu cam **Launch instances** ở góc trên bên phải.
3. Điền các cấu hình khởi tạo máy ảo:
   - **Name:** Đặt tên gợi nhớ `leaselink-backend-prod`
   - **Application and OS Images:** Chọn thẻ **Ubuntu** (Nên chọn phiên bản `Ubuntu 22.04 LTS` hoặc `24.04 LTS` vì nó phổ biến và cài đặt Docker cực kỳ dễ dàng).
   - **Instance type:** Chọn `t3.small` (2 vCPU, 2GB RAM).
     > [!WARNING]
     > Java ngốn khá nhiều RAM khởi động. Bạn **không nên** dùng `t2.micro / t3.micro` (1GB RAM - Free Tier) cho Spring Boot để tránh tình trạng văng quá tải OOMKilled giữa chừng.
   - **Key pair (login):**
     - Nhấn `Create new key pair`, điền tên ví dụ `leaselink-key`.
     - Chọn định dạng **`.pem`** nếu cấu hình trên Mac/Linux/Powershell hoặc **`.ppk`** nếu dùng tool PuTTY trên Windows cũ.
     - Sau khi `Create`, file sẽ **tự động tải xuống**. Hãy lưu file chứng chỉ chìa khóa bí mật này vào nơi an toàn.
   - **Network settings:** Click [x] Allow SSH from Anywhere, check [x] Allow HTTP and HTTPS traffic.
     - _(Quan trọng)_ Mở edit tuỳ chỉnh tường lửa: click Add security group rule, dóng chọn `Custom TCP`, điền Port range là **`8080`** và thả Source type là `Anywhere`. Port này cần có để người dùng truy cập được Spring Boot backend !
   - **Configure storage:** Kéo thanh dung lượng lên mức tối thiểu **`20 GB`** (ổ đĩa `gp3` Free tier cho phép cấp tới 30GB miễn phí, nên thoái mái).
4. Nhấn nút màu cam **Launch instance**. Chờ 1-2 phút cho trạng thái chuyển thành `Running`.

---

## Bước 2: Truy cập và Cài đặt hạ tầng Docker trên EC2

1. Bật Command Prompt / PowerShell lên (Nên đứng ở thư mục đang chứa file `leaselink-key.pem`).
2. Nhập lệnh SSH kết nối vào server (với `<Public-IP>` là chuỗi địa chỉ IP trích xuất được từ bảng cấu hình EC2):
   ```bash
   ssh -i "leaselink-key.pem" ubuntu@<Public-IP>
   ```
   > Gõ `yes` nếu terminal cảnh báo xác nhận chứng chỉ dấu vân tay rủi ro từ server mới.
3. **Cập nhật hệ thống Ubuntu:**
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```
4. **Cài đặt Docker Engine & Compose:**

   ```bash
   # Cài curl (có sẵn nhưng cứ đảm bảo)
   sudo apt-get install curl -y

   # Trích xuất đoạn mã cài đặt tự động docker từ web gốc
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh

   # Cài thêm module mở rộng Docker Compose
   sudo apt-get install docker-compose-plugin -y
   ```

5. **Cấp quyền chạy Docker cho user hiện tại** (để bạn không bị bắt phải gõ `sudo docker` mỗi câu lệnh):
   ```bash
   sudo usermod -aG docker $USER
   newgrp docker
   ```
   > [!TIP]
   > Hãy gõ thử `docker ps` xem có chạy lên bảng trạng thái chuẩn không. Nếu chưa lên, bạn chỉ cần gõ lệnh `exit` sau đó SSH ngược trở lại để apply quyền là được!

---

## Bước 3: Đưa Source code lên máy chủ EC2

Có hai phương án, bạn chọn 1 nhé:

### 🌟 Ước lệ A (Sử dụng Git, Khuyên Dùng):

Phù hợp nhất, đặc biệt khi sau này làm việc nhóm và CI/CD.

1. Cam kết và Push dự án hiện tại của bạn lên một **Private Repo Github**. (Nhớ exclude thư mục cài đặt `.env`).
2. Login lên EC2, cài đặt Git bằng `sudo apt intall git`.
3. Phân quyền và clone repo xuống:

   ```bash
   # Lấy code web của bạn về
   git clone https://github.com/<user_nam>/leaselink-backend.git

   # Bước vào folder mới lấy xuống
   cd leaselink-backend
   ```

### 📦 Ước lệ B (Copy File qua SCP ngang):

Chỉ dùng nếu lười cài Git và muốn ép thẳng code lên ngay.

1. Từ Terminal máy của bạn (chứ không phải terminal trong ssh), gõ lệnh để chép đè cả thư mục `backend` qua giao thức cổng `22`:

```bash
scp -i "leaselink-key.pem" -r ./backend ubuntu@<Public-IP>:/home/ubuntu/leaselink-backend
```

---

## Bước 4: Khởi dòng cấu trúc biến môi trường Mật (.env)

Bất kể phương án mang code lên, file `.env` của bạn hoàn toàn bị ẩn vì tính tối mật (không nên up lên Github). Do đó phải tạo lại nó trên môi trường thật:

1. Trỏ vào thư mục lấy code hiện thời: `cd /home/ubuntu/leaselink-backend`
2. Tạo tệp `.env`:
   ```bash
   nano .env
   ```
3. Copy toàn bộ thông số từ file `.env` ở máy cục bộ và _Paste chuột phải_ dán trọn gói vào sửa sổ terminal đang chạy GNU nano.
4. Lưu và thoát bằng thao tác: Nhấn `Ctrl + O` (Để save) -> `Enter` (Xác nhận tên file) -> Nhấn `Ctrl + X` (Để tắt).

---

## Bước 5: Build và Chạy Backend! (Chung kết)

> [!IMPORTANT]
> Toàn bộ logic build rườm rà (thậm chí chưa cài cả Java JDK, hay Maven trên máy) bây giờ đã là quá khứ. Dockerfile và Compose ta làm sẵn nay sẽ thể hiện sức mạnh.

1. Chạy lệnh ma thuật để đóng block và khởi tạo toàn bộ hạ tầng ngầm hóa:
   ```bash
   docker compose --env-file .env up -d --build
   ```
2. Hãy chờ khoảng `2-4 phút`. Tiến trình này sẽ cài đặt Maven bản quyền, build ứng dụng `leaselink-backend.jar`, thiết lập profile Production (`SPRING_PROFILES_ACTIVE=prod`), kết xuất RAM và run app độc lập.
3. Kênh Backend bây giờ đang chạy. **Cách theo dõi nhật ký dòng in Console (Log):**
   ```bash
   docker compose logs -f
   ```
   > Để ý nếu thấy chùm chữ `[INFO] ... Started BackendServiceApplication in XX seconds (process running for YY)` thì tức là nó đã sống và gắn kết cơ sở dữ liệu Postgres ở Aiven, Redis Lab! Nhấn tổ hợp `Ctrl + C` để thoát màn đọc log.

---

## Bước 6: Test gọi API

Mở trình duyệt bất kỳ hoặc công cụ **Postman**, trỏ vào link sau:
`http://<Public-IP_Của_EC2>:8080/` (thử trỏ 1 api endpoint ví dụ `/api/v1/property/search`)

Quá trình cấp mã và build đã thành tỷ phú. Máy ảo EC2 sẽ làm công việc quản trị tự khởi động lại App (`restart: unless-stopped`) nếu nhỡ có sự cố sập giữa chừng. Chúc mừng bạn đã hoàn thiện triển khai Production!
