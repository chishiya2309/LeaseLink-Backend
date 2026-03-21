# JPA Models Implementation — Option B (Unidirectional + Explicit Fetching)

Build all 11 JPA entity classes matching [initdb.sql](file:///d:/Workspace/Project_CongNghePhanMemHuongDoiTuong/LeaseLink/backend/initdb.sql) schema exactly. Use Option B architecture: `@ManyToOne` unidirectional for FK references, `@OneToMany` only for strict aggregate roots (`Property → PropertyImage`). Enums as Java enums with `@Enumerated(EnumType.STRING)`. A shared `BaseEntity` for common audit columns.

## Proposed Changes

### Enums

#### [NEW] [UserStatus.java](file:///d:/Workspace/Project_CongNghePhanMemHuongDoiTuong/LeaseLink/backend/src/main/java/vn/hcmute/edu/lequanghung_nguyenthaibao/backend/model/enums/UserStatus.java)
`PENDING`, `ACTIVE`, `LOCKED` (matches [initdb.sql](file:///d:/Workspace/Project_CongNghePhanMemHuongDoiTuong/LeaseLink/backend/initdb.sql) line 7)

#### [NEW] [PropertyStatus.java](file:///d:/Workspace/Project_CongNghePhanMemHuongDoiTuong/LeaseLink/backend/src/main/java/vn/hcmute/edu/lequanghung_nguyenthaibao/backend/model/enums/PropertyStatus.java)
`DRAFT`, `PENDING`, `APPROVED`, `REJECTED`, `HIDDEN`, `DELETED`

---

### Base Class

#### [NEW] [BaseEntity.java](file:///d:/Workspace/Project_CongNghePhanMemHuongDoiTuong/LeaseLink/backend/src/main/java/vn/hcmute/edu/lequanghung_nguyenthaibao/backend/model/base/BaseEntity.java)
`@MappedSuperclass` with `createdAt`, `updatedAt` using `@PrePersist` / `@PreUpdate`.

---

### Core Module (5 entities)

#### [NEW] [User.java](file:///d:/Workspace/Project_CongNghePhanMemHuongDoiTuong/LeaseLink/backend/src/main/java/vn/hcmute/edu/lequanghung_nguyenthaibao/backend/model/User.java)
- PK: `UUID`, columns match `users` table
- `@Enumerated(STRING) status` → `UserStatus`
- **No** `@OneToMany` to properties/sessions (Option B: query via Repository)

#### [NEW] [Area.java](file:///d:/Workspace/Project_CongNghePhanMemHuongDoiTuong/LeaseLink/backend/src/main/java/vn/hcmute/edu/lequanghung_nguyenthaibao/backend/model/Area.java)
- PK: `Long` (bigserial), fields: `name`, `slug`, `isActive`

#### [NEW] [RoomType.java](file:///d:/Workspace/Project_CongNghePhanMemHuongDoiTuong/LeaseLink/backend/src/main/java/vn/hcmute/edu/lequanghung_nguyenthaibao/backend/model/RoomType.java)
- PK: `Long`, fields: `name`, `isActive`

#### [NEW] [Property.java](file:///d:/Workspace/Project_CongNghePhanMemHuongDoiTuong/LeaseLink/backend/src/main/java/vn/hcmute/edu/lequanghung_nguyenthaibao/backend/model/Property.java)
- PK: `UUID`
- `@ManyToOne` → `User host`, `Area area`, `RoomType roomType`, `User approvedBy`
- `@OneToMany(cascade=ALL, orphanRemoval=true)` → `List<PropertyImage> images` (aggregate root)
- `@Enumerated(STRING) status` → `PropertyStatus`
- Soft-delete via `deletedAt`

#### [NEW] [PropertyImage.java](file:///d:/Workspace/Project_CongNghePhanMemHuongDoiTuong/LeaseLink/backend/src/main/java/vn/hcmute/edu/lequanghung_nguyenthaibao/backend/model/PropertyImage.java)
- PK: `UUID`, FK `propertyId` (via `@ManyToOne`)
- Fields: `imageUrl`, `isThumbnail`, `sortOrder`

---

### RBAC Module (4 entities)

#### [NEW] [Role.java](file:///d:/Workspace/Project_CongNghePhanMemHuongDoiTuong/LeaseLink/backend/src/main/java/vn/hcmute/edu/lequanghung_nguyenthaibao/backend/model/Role.java)
- PK: `Short` (smallserial), fields: `code`, `name`
- `@ManyToMany` → `Set<Permission>` via `role_permissions` join table

#### [NEW] [Permission.java](file:///d:/Workspace/Project_CongNghePhanMemHuongDoiTuong/LeaseLink/backend/src/main/java/vn/hcmute/edu/lequanghung_nguyenthaibao/backend/model/Permission.java)
- PK: `Long`, fields: `code`, `name`

> [!NOTE]
> `user_roles` and `role_permissions` are modeled as `@ManyToMany` join tables inside `User` and `Role` respectively — no separate entity classes needed.

`User` will have `@ManyToMany → Set<Role>` via `user_roles`.

---

### JWT/Auth Module (3 entities)

#### [NEW] [AuthSession.java](file:///d:/Workspace/Project_CongNghePhanMemHuongDoiTuong/LeaseLink/backend/src/main/java/vn/hcmute/edu/lequanghung_nguyenthaibao/backend/model/AuthSession.java)
- PK: `UUID`, `@ManyToOne` → `User`
- Fields: `deviceId`, `userAgent`, `ip` (mapped as `String`), `isActive`, `expiresAt`, `lastSeenAt`

#### [NEW] [RefreshToken.java](file:///d:/Workspace/Project_CongNghePhanMemHuongDoiTuong/LeaseLink/backend/src/main/java/vn/hcmute/edu/lequanghung_nguyenthaibao/backend/model/RefreshToken.java)
- PK: `UUID`, `@ManyToOne` → `AuthSession`, `User`
- Self-referencing `@ManyToOne` → `RefreshToken replacedByToken`
- Fields: `tokenHash`, `jti`, `issuedAt`, `expiresAt`, `revokedAt`, `revokeReason`

#### [NEW] [RevokedJti.java](file:///d:/Workspace/Project_CongNghePhanMemHuongDoiTuong/LeaseLink/backend/src/main/java/vn/hcmute/edu/lequanghung_nguyenthaibao/backend/model/RevokedJti.java)
- PK: `UUID jti` (not auto-generated)
- `@ManyToOne` → `User`
- Fields: `tokenType`, `expiresAt`, `revokedAt`

---

## Verification Plan

### Automated Tests
- Run `mvn compile -f d:\Workspace\Project_CongNghePhanMemHuongDoiTuong\LeaseLink\backend\pom.xml` to verify all entities compile without errors.

### Manual Verification
- After `mvn compile`, verify Hibernate auto-generates tables matching [initdb.sql](file:///d:/Workspace/Project_CongNghePhanMemHuongDoiTuong/LeaseLink/backend/initdb.sql) schema by starting the Spring Boot application and checking the SQL logs (`show-sql: true` is already configured).
