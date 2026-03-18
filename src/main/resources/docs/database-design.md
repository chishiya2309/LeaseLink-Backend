# Thiet ke co so du lieu PostgreSQL cho he thong cho thue phong (JWT + RBAC)

Tai lieu nay duoc xay dung dua tren `docs/business-specification.md` de phuc vu cac use case UC01-UC07.

## 1) Muc tieu thiet ke

- Chuan hoa du lieu muc 3NF, de mo rong va bao tri.
- Ho tro phan quyen RBAC cho 3 nhom chinh: `GUEST`, `HOST`, `ADMIN`.
- Ho tro xac thuc JWT voi refresh token rotation + revoke.
- Dam bao truy van tim kiem nhanh cho danh sach bai dang.
- Co co che soft-delete va timestamp day du.

## 2) Tong quan schema

### 2.1 Bang nghiep vu

- `users`
- `areas`
- `room_types`
- `properties`
- `property_images`

### 2.2 Bang RBAC

- `roles`
- `permissions`
- `role_permissions`
- `user_roles`

### 2.3 Bang xac thuc JWT

- `auth_sessions`
- `refresh_tokens`
- `revoked_jtis`

## 3) DDL de xuat

```sql
-- Extensions
create extension if not exists pgcrypto; -- gen_random_uuid()

-- Enums
create type user_status as enum ('ACTIVE', 'LOCKED');
create type property_status as enum ('DRAFT', 'PENDING', 'APPROVED', 'REJECTED', 'HIDDEN', 'DELETED');

-- Core
create table users (
  id uuid primary key default gen_random_uuid(),
  full_name varchar(120) not null,
  email varchar(255) not null unique,
  phone varchar(20) unique,
  password_hash text not null,
  status user_status not null default 'ACTIVE',
  last_login_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table areas (
  id bigserial primary key,
  name varchar(120) not null unique,
  slug varchar(150) not null unique,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table room_types (
  id bigserial primary key,
  name varchar(80) not null unique,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table properties (
  id uuid primary key default gen_random_uuid(),
  host_id uuid not null references users(id),
  area_id bigint not null references areas(id),
  room_type_id bigint not null references room_types(id),

  title varchar(255) not null,
  description text,
  address_line varchar(255) not null,
  monthly_price numeric(14,2) not null check (monthly_price >= 0),
  area_m2 numeric(8,2) check (area_m2 > 0),
  bedrooms smallint check (bedrooms >= 0),
  bathrooms smallint check (bathrooms >= 0),
  allow_pets boolean default false,

  status property_status not null default 'PENDING',
  approved_by uuid references users(id),
  approved_at timestamptz,
  rejected_reason text,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table property_images (
  id uuid primary key default gen_random_uuid(),
  property_id uuid not null references properties(id) on delete cascade,
  image_url text not null,
  is_thumbnail boolean not null default false,
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

-- Chi 1 thumbnail/property
create unique index uq_property_thumbnail_true
on property_images(property_id)
where is_thumbnail = true;

-- RBAC
create table roles (
  id smallserial primary key,
  code varchar(50) not null unique, -- ADMIN, HOST, GUEST
  name varchar(120) not null
);

create table permissions (
  id bigserial primary key,
  code varchar(100) not null unique, -- property.create, property.approve...
  name varchar(150) not null
);

create table role_permissions (
  role_id smallint not null references roles(id) on delete cascade,
  permission_id bigint not null references permissions(id) on delete cascade,
  primary key (role_id, permission_id)
);

create table user_roles (
  user_id uuid not null references users(id) on delete cascade,
  role_id smallint not null references roles(id) on delete cascade,
  primary key (user_id, role_id)
);

-- JWT/Auth
create table auth_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users(id) on delete cascade,
  device_id varchar(120),
  user_agent text,
  ip inet,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  last_seen_at timestamptz not null default now(),
  expires_at timestamptz not null
);

create table refresh_tokens (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references auth_sessions(id) on delete cascade,
  user_id uuid not null references users(id) on delete cascade,
  token_hash text not null,
  jti uuid not null unique,
  issued_at timestamptz not null default now(),
  expires_at timestamptz not null,
  revoked_at timestamptz,
  replaced_by_token_id uuid references refresh_tokens(id),
  revoke_reason varchar(120)
);

create table revoked_jtis (
  jti uuid primary key,
  user_id uuid not null references users(id) on delete cascade,
  token_type varchar(20) not null check (token_type in ('access','refresh')),
  expires_at timestamptz not null,
  revoked_at timestamptz not null default now()
);
```

## 4) RBAC de xuat theo use case

### 4.1 Roles

- `GUEST`
- `HOST`
- `ADMIN`

### 4.2 Permissions

- Guest:
  - `property.read_public`
  - `search.basic`
  - `search.ai`
- Host:
  - `property.create_own`
  - `property.update_own`
  - `property.hide_own`
  - `property.read_own`
- Admin:
  - `property.approve`
  - `property.reject`
  - `host.create`
  - `host.lock`
  - `host.unlock`
  - `host.read_all`

### 4.3 Quy tac owner

Voi Host, moi thao tac update/hide/delete tren `properties` phai co dieu kien:

```sql
where host_id = :current_user_id
```

## 5) JWT strategy

- Access token song ngan (10-15 phut), claim gom `sub`, `roles`, `jti`.
- Refresh token song dai (7-30 ngay), luu `token_hash` trong DB (khong luu token raw).
- Moi lan refresh thi rotate token:
  - revoke token cu (`revoked_at`)
  - tao token moi va lien ket `replaced_by_token_id`
- Logout 1 thiet bi: revoke theo `session_id`.
- Logout toan bo: `auth_sessions.is_active=false` + revoke toan bo refresh token cua user.
- Neu can chan access token ngay lap tuc: ghi vao `revoked_jtis`.

## 6) Index quan trong

```sql
-- Users
create index idx_users_status on users(status);
create unique index idx_users_email_active on users(email) where deleted_at is null;

-- Property search/listing
create index idx_properties_public_search
  on properties(status, area_id, room_type_id, monthly_price, created_at desc)
  where deleted_at is null;

create index idx_properties_host
  on properties(host_id, status, updated_at desc)
  where deleted_at is null;

-- Full text search
create index idx_properties_fts
  on properties using gin (to_tsvector('simple', coalesce(title,'') || ' ' || coalesce(description,'')));

-- Approval queue
create index idx_properties_pending
  on properties(status, created_at asc)
  where status = 'PENDING';

-- JWT
create index idx_refresh_tokens_user_session on refresh_tokens(user_id, session_id);
create index idx_refresh_tokens_expires on refresh_tokens(expires_at);
create index idx_revoked_jtis_expires on revoked_jtis(expires_at);
```

## 7) Mapping UC01-UC07 -> Bang du lieu

- UC01 Login: `users`, `user_roles`, `auth_sessions`, `refresh_tokens`
- UC02 Host quan ly tin: `properties`, `property_images`
- UC03 Search basic: `properties`, `areas`, `room_types`, `property_images`
- UC04 AI search: parse intent -> query `properties` + bo loc metadata
- UC05 Xem chi tiet/lien he: `properties`, `property_images`, `users`
- UC06 Admin duyet tin: `properties.status`, `approved_by`, `approved_at`, `rejected_reason`
- UC07 Admin quan ly host: `users`, `roles`, `user_roles`

## 8) Bao mat va toan ven du lieu

- Luu mat khau bang BCrypt hoac Argon2 trong `password_hash`.
- Bat buoc prepared statement/ORM parameter binding de tranh SQL Injection.
- Soft delete voi `deleted_at`; moi truy van nghiep vu mac dinh loc `deleted_at is null`.
- Bat buoc check permission + owner rule de tranh IDOR / privilege escalation.
- Nen bo sung `audit_logs` cho action nhay cam cua Host/Admin.

## 9) Seed RBAC toi thieu (goi y)

```sql
insert into roles(code, name)
values
  ('GUEST', 'Guest'),
  ('HOST', 'Host'),
  ('ADMIN', 'Administrator');

insert into permissions(code, name)
values
  ('property.read_public', 'Read approved public properties'),
  ('search.basic', 'Basic property search'),
  ('search.ai', 'AI-assisted search'),
  ('property.create_own', 'Create own property'),
  ('property.update_own', 'Update own property'),
  ('property.hide_own', 'Hide own property'),
  ('property.read_own', 'Read own properties'),
  ('property.approve', 'Approve property'),
  ('property.reject', 'Reject property'),
  ('host.create', 'Create host account'),
  ('host.lock', 'Lock host account'),
  ('host.unlock', 'Unlock host account'),
  ('host.read_all', 'View all hosts');
```

