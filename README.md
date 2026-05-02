<p align="center">
  <img src="https://img.shields.io/badge/Spring%20Boot-4.0.3-6DB33F?style=for-the-badge&logo=springboot&logoColor=white" alt="Spring Boot">
  <img src="https://img.shields.io/badge/Java-17-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white" alt="Java 17">
  <img src="https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white" alt="PostgreSQL">
  <img src="https://img.shields.io/badge/Redis-DC382D?style=for-the-badge&logo=redis&logoColor=white" alt="Redis">
  <img src="https://img.shields.io/badge/AWS-EC2%20%7C%20S3-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white" alt="AWS">
  <img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker">
  <img src="https://img.shields.io/badge/Gemini%20AI-8E75B2?style=for-the-badge&logo=googlegemini&logoColor=white" alt="Gemini AI">
</p>

# 🏠 LeaseLink — Backend API

**LeaseLink** là một nền tảng **cho thuê bất động sản** (phòng trọ, căn hộ, nhà ở) với khả năng **tìm kiếm thông minh bằng AI**. Hệ thống cho phép chủ nhà (Host) đăng tin, quản trị viên (Admin) kiểm duyệt và quản lý tài khoản, đồng thời người dùng có thể tìm kiếm bất động sản bằng ngôn ngữ tự nhiên thông qua trợ lý AI tích hợp Gemini.

> **Đồ án môn Công Nghệ Phần Mềm Hướng Đối Tượng** — ĐH Sư Phạm Kỹ Thuật TP.HCM (HCMUTE)

---

## 📋 Mục lục

- [Mô tả dự án (CV)](#-mô-tả-dự-án-cv)
- [Tính năng chính](#-tính-năng-chính)
- [Kiến trúc hệ thống](#-kiến-trúc-hệ-thống)
- [Tech Stack](#-tech-stack)
- [Cấu trúc thư mục](#-cấu-trúc-thư-mục)
- [Thiết kế Database](#-thiết-kế-database)
- [API Endpoints](#-api-endpoints)
- [Cài đặt & Chạy local](#-cài-đặt--chạy-local)
- [Triển khai Production](#-triển-khai-production)
- [Tác giả](#-tác-giả)

---

## 📝 Mô tả dự án (CV)

> Sao chép đoạn dưới đây để ghi vào CV/Resume:

### Tiếng Việt

**LeaseLink — Nền tảng cho thuê bất động sản tích hợp AI**

Thiết kế và phát triển phần Backend (RESTful API) cho nền tảng cho thuê bất động sản LeaseLink, phục vụ kết nối giữa chủ nhà (Host) và người thuê. Hệ thống xây dựng trên **Spring Boot 4.x** với kiến trúc phân lớp (Controller → Service → Repository), áp dụng các nguyên lý **OOP** và **SOLID**. Triển khai hệ thống xác thực **JWT** (Access Token + Refresh Token + Session tracking) kết hợp phân quyền **RBAC** (Admin / Host). Tích hợp **Google Gemini AI** để cho phép người dùng tìm kiếm bất động sản bằng ngôn ngữ tự nhiên — AI phân tích intent, trích xuất tiêu chí (giá, khu vực, loại phòng...) và truy vấn database bằng **JPA Specification** động. Xây dựng quy trình kiểm duyệt tin đăng đa trạng thái (Draft → Pending → Approved/Rejected), hệ thống thông báo real-time, và tích hợp **email transactional** (Brevo) cho luồng reset mật khẩu. Sử dụng **AWS S3** cho lưu trữ media (ảnh, video bất động sản), **Redis** cho caching/session, **PostgreSQL** làm database chính. Container hóa bằng **Docker** (multi-stage build) và triển khai trên **AWS EC2**.

### English

**LeaseLink — AI-Powered Real Estate Rental Platform**

Designed and developed the Backend (RESTful API) for LeaseLink, a real estate rental platform connecting landlords (Hosts) with tenants. Built on **Spring Boot 4.x** with a layered architecture (Controller → Service → Repository), applying **OOP** and **SOLID** principles. Implemented a **JWT**-based authentication system (Access Token + Refresh Token + Session tracking) with **RBAC** authorization (Admin / Host roles). Integrated **Google Gemini AI** to enable natural language property search — the AI analyzes user intent, extracts search criteria (price, area, room type, etc.), and dynamically queries the database using **JPA Specification**. Built a multi-state listing moderation workflow (Draft → Pending → Approved/Rejected), real-time notification system, and integrated **transactional emails** (Brevo) for password reset flows. Utilized **AWS S3** for media storage (property images/videos), **Redis** for caching/session management, and **PostgreSQL** as the primary database. Containerized with **Docker** (multi-stage build) and deployed on **AWS EC2**.

---

## ✨ Tính năng chính

### 🔐 Xác thực & Phân quyền
- Đăng ký / Đăng nhập với **JWT** (Access Token + Refresh Token)
- Quản lý session (Auth Session tracking, revoke JTI)
- Phân quyền **RBAC**: `ADMIN`, `HOST`
- Quên mật khẩu / Đặt lại mật khẩu qua **Email OTP** (Brevo API)
- BCrypt password hashing (cost factor = 12)

### 🏘️ Quản lý Bất động sản
- Host đăng tin cho thuê kèm **ảnh + video**
- Upload media lên **AWS S3** (tách biệt transaction DB)
- CRUD tin đăng với phân quyền sở hữu
- Tìm kiếm nâng cao: lọc theo khu vực, loại phòng, khoảng giá, số phòng ngủ, cho phép thú cưng...
- Phân trang kết quả (Spring Data Pagination)

### 🤖 Tìm kiếm thông minh bằng AI
- Tích hợp **Google Gemini 2.5 Flash** làm NLP engine
- Người dùng mô tả nhu cầu bằng **ngôn ngữ tự nhiên** (VD: "Tìm phòng trọ 2 triệu ở Hải Châu có ban công")
- AI trích xuất cấu trúc dữ liệu: loại phòng, khu vực, giá, từ khóa...
- Kết hợp **JPA Specification** để build dynamic query
- Xếp hạng kết quả theo keyword relevance scoring (title ×2, description ×1)
- Lọc intent: tự động phân biệt câu hỏi liên quan BĐS vs câu hỏi ngoài lề

### ✅ Kiểm duyệt tin đăng (Admin)
- Quy trình duyệt đa trạng thái: `DRAFT` → `PENDING` → `APPROVED` / `REJECTED`
- Admin duyệt / từ chối tin với lý do
- Tự động ẩn tin khi Host bị khóa tài khoản

### 👤 Quản lý người dùng (Admin)
- Tạo tài khoản Host (tự sinh mật khẩu + gửi email)
- Khóa / Mở khóa tài khoản Host (thu hồi session + ẩn tin đăng)
- Tìm kiếm và lọc danh sách Host theo trạng thái

### 🔔 Hệ thống thông báo
- Thông báo trong ứng dụng (tin được duyệt, bị từ chối, tài khoản bị khóa...)
- Đánh dấu đã đọc (đơn lẻ / tất cả)
- Đếm thông báo chưa đọc

---

## 🏗️ Kiến trúc hệ thống

```
┌─────────────────────────────────────────────────────────────────┐
│                        Client (React / Mobile)                  │
└──────────────────────────────┬──────────────────────────────────┘
                               │ HTTPS
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Spring Boot 4.x (Backend API)                │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌──────────┐  │
│  │ Controller  │→│  Service   │→│ Repository  │→│   JPA    │  │
│  │  (REST)    │  │  (Logic)   │  │  (Data)    │  │(Hibernate)│  │
│  └────────────┘  └────────────┘  └────────────┘  └──────────┘  │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐               │
│  │ JWT Filter │  │ Security   │  │  AI NLP    │               │
│  │            │  │  Config    │  │  (Gemini)  │               │
│  └────────────┘  └────────────┘  └────────────┘               │
└───────┬──────────────┬──────────────┬──────────────┬───────────┘
        │              │              │              │
        ▼              ▼              ▼              ▼
  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────┐
  │PostgreSQL│  │  Redis   │  │  AWS S3  │  │  Brevo Email │
  │ (Aiven)  │  │ (Cache)  │  │ (Media)  │  │  (SMTP API)  │
  └──────────┘  └──────────┘  └──────────┘  └──────────────┘
```

---

## 🛠️ Tech Stack

| Layer            | Technology                                             |
| ---------------- | ------------------------------------------------------ |
| **Framework**    | Spring Boot 4.0.3, Spring Security, Spring Data JPA    |
| **Language**     | Java 17                                                |
| **Database**     | PostgreSQL (Aiven Cloud)                               |
| **Caching**      | Redis (Spring Data Redis + Spring Cache)               |
| **Auth**         | JWT (jjwt 0.12.x) + BCrypt                            |
| **AI / NLP**     | Google Gemini 2.5 Flash API                            |
| **Storage**      | AWS S3 (SDK v2.25)                                     |
| **Email**        | Brevo (Sendinblue) Transactional API                   |
| **API Docs**     | SpringDoc OpenAPI 3.0 (Swagger UI)                     |
| **Build Tool**   | Maven 3.9.x                                            |
| **Container**    | Docker (multi-stage) + Docker Compose                  |
| **Deployment**   | AWS EC2 (t3.small, Ubuntu)                             |
| **Utilities**    | Lombok, spring-dotenv                                  |

---

## 📁 Cấu trúc thư mục

```
backend/
├── src/main/java/.../backend/
│   ├── config/                  # Cấu hình (Security, CORS, S3, Redis, OpenAPI, Brevo)
│   ├── controller/              # REST Controllers
│   │   ├── request/             # Request DTOs
│   │   └── response/           # Response DTOs
│   ├── dto/                     # Data Transfer Objects (AI criteria, ...)
│   │   ├── request/
│   │   └── response/
│   ├── exception/               # Custom Exception & Global Handler
│   ├── filter/                  # JWT Authentication Filter
│   ├── model/                   # JPA Entities
│   │   ├── base/                # BaseEntity (audit fields)
│   │   └── enums/               # PropertyStatus, UserStatus, NotificationType
│   ├── repository/              # Spring Data JPA Repositories + Specifications
│   ├── service/                 # Service interfaces
│   │   └── impl/                # Service implementations
│   ├── util/                    # Utility classes
│   └── uml/                     # PlantUML diagrams (Use Case, Class, ERD, Sequence, Activity)
├── src/main/resources/
│   ├── application.yaml         # Main config
│   ├── application-dev.yml      # Dev profile
│   ├── application-prod.yml     # Production profile
│   └── application-test.yml     # Test profile
├── Dockerfile                   # Multi-stage Docker build
├── docker-compose.yml           # Container orchestration
├── initdb.sql                   # Database initialization script
├── pom.xml                      # Maven dependencies
└── .env.example                 # Environment variables template
```

---

## 🗄️ Thiết kế Database

### Entities chính

| Entity              | Mô tả                                  |
| ------------------- | --------------------------------------- |
| `User`              | Người dùng (Host / Admin)              |
| `Role`              | Vai trò (RBAC)                         |
| `Permission`        | Quyền hạn                              |
| `Property`          | Tin đăng bất động sản                  |
| `PropertyImage`     | Ảnh / thumbnail của tin đăng           |
| `Area`              | Khu vực / Quận huyện                   |
| `RoomType`          | Loại phòng (Trọ, Chung cư, Nhà...)     |
| `Notification`      | Thông báo hệ thống                     |
| `RefreshToken`      | Refresh token cho JWT rotation         |
| `AuthSession`       | Phiên đăng nhập                        |
| `RevokedJti`        | Blacklist JWT đã thu hồi               |
| `PasswordResetToken`| Token đặt lại mật khẩu                 |

### Trạng thái tin đăng (`PropertyStatus`)
```
DRAFT → PENDING → APPROVED
                 → REJECTED
                 → HIDDEN (khi Host bị khóa)
                 → DELETED (soft delete)
```

### Trạng thái người dùng (`UserStatus`)
```
PENDING → ACTIVE ↔ LOCKED
```

---

## 🔌 API Endpoints

### Authentication (`/users`)
| Method | Endpoint                 | Auth | Mô tả                          |
| ------ | ------------------------ | ---- | ------------------------------- |
| POST   | `/users/register`        | ❌    | Đăng ký tài khoản Host          |
| POST   | `/users/login`           | ❌    | Đăng nhập                       |
| POST   | `/users/refresh-token`   | ❌    | Làm mới Access Token            |
| POST   | `/users/forgot-password` | ❌    | Gửi mã reset qua email          |
| POST   | `/users/verify-reset-code`| ❌   | Xác thực mã OTP                 |
| POST   | `/users/reset-password`  | ❌    | Đặt lại mật khẩu               |
| POST   | `/users/logout`          | ✅    | Đăng xuất (revoke token)        |

### Property Management (`/api/v1/properties`)
| Method | Endpoint                          | Auth   | Mô tả                       |
| ------ | --------------------------------- | ------ | ---------------------------- |
| POST   | `/api/v1/properties`              | HOST   | Tạo tin đăng mới             |
| PUT    | `/api/v1/properties/{id}`         | HOST   | Cập nhật tin đăng            |
| DELETE | `/api/v1/properties/{id}`         | HOST   | Xóa tin đăng                 |
| GET    | `/api/v1/properties/me`           | HOST   | Xem tin đăng của mình        |
| GET    | `/api/v1/properties/{id}`         | ❌      | Xem chi tiết tin đăng        |
| GET    | `/api/v1/properties/approved`     | ❌      | Danh sách tin đã duyệt       |
| GET    | `/api/v1/properties/search`       | ❌      | Tìm kiếm bộ lọc nâng cao    |
| GET    | `/api/v1/properties/pending`      | ADMIN  | Danh sách tin chờ duyệt      |
| GET    | `/api/v1/properties`              | ADMIN  | Xem tất cả tin (filter)      |
| POST   | `/api/v1/properties/{id}/approve` | ADMIN  | Duyệt tin đăng               |
| POST   | `/api/v1/properties/{id}/reject`  | ADMIN  | Từ chối tin đăng              |

### AI Search (`/api/v1/ai`)
| Method | Endpoint            | Auth | Mô tả                                 |
| ------ | ------------------- | ---- | -------------------------------------- |
| POST   | `/api/v1/ai/search` | ❌    | Tìm kiếm BĐS bằng ngôn ngữ tự nhiên  |

### Admin (`/api/v1/admin`)
| Method | Endpoint                           | Auth  | Mô tả                            |
| ------ | ---------------------------------- | ----- | --------------------------------- |
| GET    | `/api/v1/admin/hosts`              | ADMIN | Danh sách Host                    |
| POST   | `/api/v1/admin/hosts`              | ADMIN | Tạo tài khoản Host               |
| PATCH  | `/api/v1/admin/hosts/{id}/status`  | ADMIN | Khóa / Mở khóa Host              |

### Notifications (`/api/v1/notifications`)
| Method | Endpoint                              | Auth | Mô tả                       |
| ------ | ------------------------------------- | ---- | ---------------------------- |
| GET    | `/api/v1/notifications`               | ✅    | Danh sách thông báo          |
| PATCH  | `/api/v1/notifications/{id}/read`     | ✅    | Đánh dấu đã đọc             |
| PATCH  | `/api/v1/notifications/read-all`      | ✅    | Đánh dấu tất cả đã đọc      |

### Reference Data
| Method | Endpoint              | Auth | Mô tả              |
| ------ | --------------------- | ---- | ------------------- |
| GET    | `/api/v1/areas`       | ❌    | Danh sách khu vực   |
| GET    | `/api/v1/room-types`  | ❌    | Danh sách loại phòng |

---

## ⚡ Cài đặt & Chạy local

### Yêu cầu
- **Java 17+**
- **Maven 3.9+**
- **PostgreSQL** (hoặc dùng cloud: Aiven)
- **Redis** (hoặc dùng cloud: Redis Labs)
- **AWS S3 bucket** (cho upload media)

### 1. Clone repository
```bash
git clone https://github.com/chishiya2309/LeaseLink-Backend.git
cd LeaseLink-Backend
```

### 2. Cấu hình biến môi trường
```bash
cp .env.example .env
```
Chỉnh sửa file `.env` với thông tin thực:
```env
DB_URL=jdbc:postgresql://localhost:5432/leaselink
DB_USERNAME=postgres
DB_PASSWORD=your_password
ACCESS_KEY=your_aws_access_key
SECRET_KEY=your_aws_secret_key
BREVO_API_KEY=your_brevo_api_key
BREVO_SENDER_EMAIL=noreply@leaselink.vn
BREVO_SENDER_NAME=LeaseLink
GEMINI_API_KEY=your_gemini_api_key
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=your_redis_password
```

### 3. Khởi tạo Database
```bash
psql -U postgres -d leaselink -f initdb.sql
```

### 4. Chạy ứng dụng
```bash
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev
```

### 5. Truy cập Swagger UI
```
http://localhost:8080/swagger-ui.html
```

---

## 🚀 Triển khai Production

### Docker
```bash
# Build & Run
docker compose --env-file .env up -d --build

# Xem logs
docker compose logs -f
```

### AWS EC2
Xem hướng dẫn chi tiết tại: [ec2_deployment_guide.md](./ec2_deployment_guide.md)

**Tóm tắt:**
1. Khởi tạo EC2 instance (Ubuntu, t3.small, 20GB)
2. Cài đặt Docker Engine + Compose
3. Clone source code & tạo file `.env`
4. `docker compose --env-file .env up -d --build`

**Cấu hình JVM Production:**
```
-Xms512m -Xmx1024m -XX:+UseG1GC
```

---

## 📊 UML Diagrams

Dự án bao gồm đầy đủ các biểu đồ UML (PlantUML):

| Diagram                | Mô tả                                    |
| ---------------------- | ----------------------------------------- |
| Use Case Tổng Quát     | Tổng quan các use case của hệ thống       |
| Class Diagram          | Biểu đồ lớp thiết kế OOP                 |
| ERD                    | Entity Relationship Diagram               |
| Sequence Diagrams      | Luồng xử lý từng use case (UC01 → UC07)  |
| Activity Diagrams      | Biểu đồ hoạt động từng chức năng         |

---

## 👥 Tác giả

| Thành viên            | Vai trò       |
| --------------------- | ------------- |
| **Lê Quang Hưng**    | Backend Dev   |
| **Nguyễn Thái Bảo**  | Backend Dev   |

📫 **Trường:** Đại học Sư Phạm Kỹ Thuật TP.HCM (HCMUTE)

---

<p align="center">
  <i>Built with ❤️ using Spring Boot & Gemini AI</i>
</p>
