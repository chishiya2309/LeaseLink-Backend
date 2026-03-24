-- Extensions

create extension if not exists pgcrypto; -- gen_random_uuid()

-- Enums

create type user_status as enum ('PENDING', 'ACTIVE', 'LOCKED');

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

                               ip varchar(45),

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

create table password_reset_tokens (

                                       id uuid primary key default gen_random_uuid(),

                                       user_id uuid not null references users(id) on delete cascade,

                                       email_snapshot varchar(255) not null,

                                       otp_hash text not null,

                                       reset_token_hash text,

                                       expires_at timestamptz not null,

                                       verified_at timestamptz,

                                       consumed_at timestamptz,

                                       attempt_count integer not null default 0,

                                       created_at timestamptz not null default now(),

                                       updated_at timestamptz not null default now()

);

create table revoked_jtis (

                              jti uuid primary key,

                              user_id uuid not null references users(id) on delete cascade,

                              token_type varchar(20) not null check (token_type in ('access','refresh')),

                              expires_at timestamptz not null,

                              revoked_at timestamptz not null default now()

);

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

create index idx_password_reset_tokens_user_created on password_reset_tokens(user_id, created_at desc);

create index idx_password_reset_tokens_expires on password_reset_tokens(expires_at);

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

insert into role_permissions(role_id, permission_id)
select r.id, p.id
from roles r
join permissions p on (
    (r.code = 'GUEST' and p.code in ('property.read_public', 'search.basic', 'search.ai')) or
    (r.code = 'HOST' and p.code in ('property.read_public', 'search.basic', 'search.ai', 'property.create_own', 'property.update_own', 'property.hide_own', 'property.read_own')) or
    (r.code = 'ADMIN' and p.code in ('property.read_public', 'search.basic', 'search.ai', 'property.approve', 'property.reject', 'host.create', 'host.lock', 'host.unlock', 'host.read_all'))
);

insert into areas(name, slug, is_active)
values
    ('Hải Châu', 'hai-chau', true),
    ('Thanh Khê', 'thanh-khe', true),
    ('Sơn Trà', 'son-tra', true),
    ('Ngũ Hành Sơn', 'ngu-hanh-son', true),
    ('Liên Chiểu', 'lien-chieu', true),
    ('Cẩm Lệ', 'cam-le', true),
    ('Hoa Xuân', 'hoa-xuan', true),
    ('Hoà Khánh', 'hoa-khanh', true),
    ('An Thượng', 'an-thuong', true),
    ('Mỹ An', 'my-an', true);

insert into room_types(name, is_active)
values
    ('Nha', true),
    ('Can_ho', true),
    ('Chung_cu', true);

insert into users(full_name, email, phone, password_hash, status, last_login_at)
values
    ('System Administrator', 'admin@leaselink.vn', '0900000001', crypt('Admin@123456', gen_salt('bf', 12)), 'ACTIVE', now() - interval '1 day'),
    ('Nguyễn Hoàng Nam', 'host.nam@leaselink.vn', '0901000001', crypt('Host@123456', gen_salt('bf', 12)), 'ACTIVE', now() - interval '2 day'),
    ('Trần Minh Anh', 'host.anh@leaselink.vn', '0901000002', crypt('Host@123456', gen_salt('bf', 12)), 'ACTIVE', now() - interval '3 day'),
    ('Lê Thu Hà', 'host.ha@leaselink.vn', '0901000003', crypt('Host@123456', gen_salt('bf', 12)), 'ACTIVE', now() - interval '6 hour'),
    ('Phạm Quốc Bảo', 'host.bao@leaselink.vn', '0901000004', crypt('Host@123456', gen_salt('bf', 12)), 'ACTIVE', now() - interval '8 hour'),
    ('Đỗ Khánh Linh', 'host.linh@leaselink.vn', '0901000005', crypt('Host@123456', gen_salt('bf', 12)), 'ACTIVE', now() - interval '12 hour'),
    ('Võ Gia Huy', 'host.huy@leaselink.vn', '0901000006', crypt('Host@123456', gen_salt('bf', 12)), 'PENDING', null),
    ('Bùi Thanh Nhàn', 'host.nhan@leaselink.vn', '0901000007', crypt('Host@123456', gen_salt('bf', 12)), 'LOCKED', now() - interval '15 day');

insert into user_roles(user_id, role_id)
select u.id, r.id
from users u
join roles r on r.code = 'ADMIN'
where u.email = 'admin@leaselink.vn';

insert into user_roles(user_id, role_id)
select u.id, r.id
from users u
join roles r on r.code = 'HOST'
where u.email in (
    'host.nam@leaselink.vn',
    'host.anh@leaselink.vn',
    'host.ha@leaselink.vn',
    'host.bao@leaselink.vn',
    'host.linh@leaselink.vn',
    'host.huy@leaselink.vn',
    'host.nhan@leaselink.vn'
);

with property_seed(title, host_email, area_name, room_type_name, address_line, monthly_price, area_m2, bedrooms, allow_pets, status, approved_at, rejected_reason, description) as (
    values
    ('Studio hiện đại gần cầu Rồng', 'host.nam@leaselink.vn', 'Hải Châu', 'Can_ho', '12 Trần Phú, Hải Châu, Đà Nẵng', 6500000, 28, 0, false, 'APPROVED', now() - interval '20 day', null, 'Studio sáng sủa có ban công, gần các tòa nhà văn phòng, quán cà phê và sông Hàn.'),
    ('Căn hộ tối giản cho người đi làm', 'host.anh@leaselink.vn', 'Hải Châu', 'Chung_cu', '45 Lê Đình Dương, Hải Châu, Đà Nẵng', 8200000, 42, 1, true, 'APPROVED', now() - interval '18 day', null, 'Căn hộ 1 phòng ngủ yên tĩnh, đầy đủ nội thất và an ninh tốt, rất phù hợp cho dân văn phòng.'),
    ('Căn hộ gia đình đón gió sông', 'host.ha@leaselink.vn', 'Sơn Trà', 'Chung_cu', '19 Hồ Nghinh, Sơn Trà, Đà Nẵng', 11800000, 63, 2, true, 'APPROVED', now() - interval '17 day', null, 'Căn hộ 2 phòng ngủ gần biển, ngập tràn ánh sáng tự nhiên và cho phép nuôi thú cưng.'),
    ('Studio nhỏ gọn cho sinh viên tại Thanh Khê', 'host.bao@leaselink.vn', 'Thanh Khê', 'Can_ho', '88 Điện Biên Phủ, Thanh Khê, Đà Nẵng', 4800000, 24, 0, false, 'APPROVED', now() - interval '16 day', null, 'Studio giá cả phải chăng, phù hợp cho sinh viên, gần các tuyến xe buýt và cửa hàng tiện lợi.'),
    ('Căn hộ mini ấm cúng gần sân bay', 'host.linh@leaselink.vn', 'Thanh Khê', 'Can_ho', '03 Thái Thị Bôi, Thanh Khê, Đà Nẵng', 5900000, 30, 1, false, 'APPROVED', now() - interval '15 day', null, 'Căn hộ mini riêng tư có thang máy, di chuyển nhanh chóng ra sân bay và trung tâm thành phố.'),
    ('Căn hộ ven biển tại Mỹ An', 'host.nam@leaselink.vn', 'Mỹ An', 'Chung_cu', '27 Châu Thị Vĩnh Tế, Mỹ An, Đà Nẵng', 9100000, 40, 1, true, 'APPROVED', now() - interval '14 day', null, 'Căn hộ 1 phòng ngủ chỉ mất 5 phút ra biển Mỹ Khê, không không gian lý tưởng để làm việc từ xa.'),
    ('Căn hộ thân thiện với thú cưng tại An Thượng', 'host.anh@leaselink.vn', 'An Thượng', 'Chung_cu', '66 An Thượng 29, An Thượng, Đà Nẵng', 12500000, 68, 2, true, 'APPROVED', now() - interval '13 day', null, 'Nằm trong khu phố Tây sầm uất, phòng khách rộng rãi, cho phép nuôi mèo và chó nhỏ.'),
    ('Phòng trọ nhà nguyên căn gần trường đại học', 'host.ha@leaselink.vn', 'Liên Chiểu', 'Nha', '114 Nguyễn Lương Bằng, Liên Chiểu, Đà Nẵng', 3200000, 18, 1, false, 'APPROVED', now() - interval '12 day', null, 'Phòng giá rẻ trong nhà chung, gần khu vực đại học và chợ dân sinh.'),
    ('Studio đầy đủ bếp tại Hòa Khánh', 'host.bao@leaselink.vn', 'Hoà Khánh', 'Can_ho', '32 Âu Cơ, Hoà Khánh, Đà Nẵng', 4300000, 27, 0, false, 'APPROVED', now() - interval '11 day', null, 'Studio trang bị sẵn bếp, rất tiện cho sinh viên và người lao động khu công nghiệp.'),
    ('Căn hộ lớn cho gia đình tại Cẩm Lệ', 'host.linh@leaselink.vn', 'Cẩm Lệ', 'Chung_cu', '72 Cách Mạng Tháng Tám, Cẩm Lệ, Đà Nẵng', 14900000, 88, 3, true, 'APPROVED', now() - interval '10 day', null, 'Căn hộ 3 phòng ngủ có bãi đỗ xe, xung quanh nhiều trường học và siêu thị.'),
    ('Căn hộ ven sông yên bình tại Ngũ Hành Sơn', 'host.nam@leaselink.vn', 'Ngũ Hành Sơn', 'Chung_cu', '14 Lê Văn Hiến, Ngũ Hành Sơn, Đà Nẵng', 13200000, 71, 2, false, 'APPROVED', now() - interval '9 day', null, 'Căn hộ yên tĩnh với tầm nhìn thoáng đãng, phù hợp cho các cặp đôi và gia đình nhỏ.'),
    ('Căn hộ mini giá rẻ tại Sơn Trà', 'host.anh@leaselink.vn', 'Sơn Trà', 'Can_ho', '52 Ngô Quyền, Sơn Trà, Đà Nẵng', 5600000, 29, 1, false, 'APPROVED', now() - interval '8 day', null, 'Căn hộ thiết kế đơn giản, sạch sẽ, gần phố hải sản và đường bờ biển.'),
    ('Căn hộ 2PN cao cấp có ban công tại Hải Châu', 'host.ha@leaselink.vn', 'Hải Châu', 'Chung_cu', '09 Bạch Đằng, Hải Châu, Đà Nẵng', 15800000, 76, 2, false, 'APPROVED', now() - interval '7 day', null, 'Căn hộ ngay trung tâm thành phố view nhìn ra sông, phù hợp cho chuyên gia và cặp đôi.'),
    ('Studio thân thiện cho sinh viên tại Liên Chiểu', 'host.bao@leaselink.vn', 'Liên Chiểu', 'Can_ho', '77 Hồ Tùng Mậu, Liên Chiểu, Đà Nẵng', 3500000, 22, 0, false, 'APPROVED', now() - interval '6 day', null, 'Studio nhỏ gọn với giá thuê hợp lý, tiện đường đi học FPT và đi làm khu công nghiệp.'),
    ('Căn hộ ngập nắng gần Asia Park', 'host.linh@leaselink.vn', 'Cẩm Lệ', 'Chung_cu', '21 Núi Thành, Cẩm Lệ, Đà Nẵng', 7600000, 38, 1, true, 'APPROVED', now() - interval '5 day', null, 'Căn hộ sáng sủa, dễ dàng di chuyển đến Asia Park, phù hợp cho cặp đôi có nuôi thú cưng.'),
    ('Căn hộ 2PN yên tĩnh khu đô thị Hòa Xuân', 'host.nam@leaselink.vn', 'Hoa Xuân', 'Chung_cu', '16 Nguyễn Phước Lan, Hoa Xuân, Đà Nẵng', 11000000, 64, 2, true, 'APPROVED', now() - interval '5 day', null, 'Khu dân cư có nhiều công viên và đường xá rộng rãi, môi trường sống lý tưởng cho gia đình.'),
    ('Căn hộ mini gác lửng trung tâm', 'host.anh@leaselink.vn', 'Hải Châu', 'Can_ho', '37 Phan Châu Trinh, Hải Châu, Đà Nẵng', 8700000, 35, 1, false, 'APPROVED', now() - interval '4 day', null, 'Thiết kế theo phong cách gác lửng (loft) với nội thất hiện đại ngay tại quận trung tâm.'),
    ('Phòng giá rẻ cho thực tập sinh tại Thanh Khê', 'host.ha@leaselink.vn', 'Thanh Khê', 'Nha', '11 Ông Ích Khiêm, Thanh Khê, Đà Nẵng', 2800000, 16, 1, false, 'APPROVED', now() - interval '4 day', null, 'Phòng đơn trong nhà nguyên căn, thích hợp cho thực tập sinh, người mới đi làm và sinh viên.'),
    ('Căn hộ view biển sát Mỹ Khê', 'host.bao@leaselink.vn', 'Sơn Trà', 'Chung_cu', '05 Võ Nguyên Giáp, Sơn Trà, Đà Nẵng', 16800000, 79, 2, true, 'APPROVED', now() - interval '3 day', null, 'Căn hộ tầng cao với view biển tuyệt đẹp cùng các tiện ích tòa nhà cao cấp.'),
    ('Studio ấm áp tại phố ẩm thực Mỹ An', 'host.linh@leaselink.vn', 'Mỹ An', 'Can_ho', '63 Trần Bạch Đằng, Mỹ An, Đà Nẵng', 6100000, 26, 0, true, 'APPROVED', now() - interval '3 day', null, 'Studio được bao quanh bởi nhiều nhà hàng, cực tiện cho người độc thân và người làm việc tự do.'),
    ('Căn hộ 1PN hiện đại gần chợ Hàn', 'host.nam@leaselink.vn', 'Hải Châu', 'Chung_cu', '18 Hùng Vương, Hải Châu, Đà Nẵng', 8400000, 43, 1, false, 'APPROVED', now() - interval '2 day', null, 'Căn hộ thiết kế đẹp khu vực trung tâm, rất gần chợ Hàn và các tòa nhà văn phòng.'),
    ('Căn hộ 2PN có bãi đỗ xe tại Sơn Trà', 'host.anh@leaselink.vn', 'Sơn Trà', 'Chung_cu', '91 Phạm Văn Đồng, Sơn Trà, Đà Nẵng', 11900000, 66, 2, true, 'APPROVED', now() - interval '2 day', null, 'Căn hộ rộng rãi có bãi đỗ xe tầng hầm và đường ra bãi biển dễ dàng.'),
    ('Studio nhỏ gọn gần bến xe', 'host.ha@leaselink.vn', 'Liên Chiểu', 'Can_ho', '54 Tôn Đức Thắng, Liên Chiểu, Đà Nẵng', 3900000, 23, 0, false, 'APPROVED', now() - interval '36 hour', null, 'Studio diện tích tối ưu, phù hợp cho người đi làm cần các tuyến giao thông nhanh chóng.'),
    ('Căn hộ phong cách gia đình tại Hòa Xuân', 'host.bao@leaselink.vn', 'Hoa Xuân', 'Chung_cu', '28 Trần Nam Trung, Hoa Xuân, Đà Nẵng', 14200000, 90, 3, true, 'APPROVED', now() - interval '30 hour', null, 'Căn hộ diện tích lớn trong khu dân cư yên tĩnh, xung quanh có nhiều trường học.'),
    ('Studio mới cải tạo tại Cẩm Lệ', 'host.linh@leaselink.vn', 'Cẩm Lệ', 'Can_ho', '44 Lê Trọng Tấn, Cẩm Lệ, Đà Nẵng', 5100000, 25, 0, false, 'APPROVED', now() - interval '24 hour', null, 'Studio vừa được tân trang lại với thiết kế sạch sẽ và khu vực giặt giũ phơi đồ riêng biệt.'),
    ('Căn hộ đang chờ duyệt tại Mỹ An', 'host.huy@leaselink.vn', 'Mỹ An', 'Chung_cu', '12 An Thượng 5, Mỹ An, Đà Nẵng', 9300000, 41, 1, true, 'PENDING', null, null, 'Bài đăng mới được chủ nhà gửi lên và đang chờ admin kiểm duyệt.'),
    ('Căn hộ gia đình đang chờ duyệt tại Ngũ Hành Sơn', 'host.huy@leaselink.vn', 'Ngũ Hành Sơn', 'Chung_cu', '25 Chu Huy Mân, Ngũ Hành Sơn, Đà Nẵng', 12800000, 72, 2, false, 'PENDING', null, null, 'Căn hộ lớn có ánh sáng tự nhiên và ban công view hướng núi.'),
    ('Bài đăng bị từ chối do trùng lặp tại Hải Châu', 'host.nhan@leaselink.vn', 'Hải Châu', 'Can_ho', '80 Quang Trung, Hải Châu, Đà Nẵng', 6000000, 27, 0, false, 'REJECTED', null, 'Nội dung bài đăng bị trùng lặp và hình ảnh gây hiểu lầm.', 'Bài đăng bị từ chối được hệ thống giữ lại để lưu lịch sử kiểm duyệt.'),
    ('Căn hộ đang tạm ẩn để bảo trì', 'host.nam@leaselink.vn', 'Thanh Khê', 'Chung_cu', '39 Hàm Nghi, Thanh Khê, Đà Nẵng', 7200000, 36, 1, false, 'HIDDEN', null, null, 'Bài đăng tạm thời bị ẩn do chủ nhà đang trong quá trình cải tạo lại nội thất.'),
    ('Bản nháp căn hộ chưa xuất bản', 'host.bao@leaselink.vn', 'Sơn Trà', 'Chung_cu', '88 Nguyễn Chí Thanh, Sơn Trà, Đà Nẵng', 13500000, 70, 2, true, 'DRAFT', null, null, 'Bài đăng đang ở dạng nháp, chưa được gửi đi để kiểm duyệt.')
)
insert into properties(
    host_id, area_id, room_type_id, title, description, address_line,
    monthly_price, area_m2, bedrooms, allow_pets, status, approved_by, approved_at, rejected_reason
)
select
    u.id,
    a.id,
    rt.id,
    ps.title,
    ps.description,
    ps.address_line,
    ps.monthly_price,
    ps.area_m2,
    ps.bedrooms,
    ps.allow_pets,
    ps.status::property_status,
    case when ps.status = 'APPROVED' then admin_u.id else null end,
    ps.approved_at,
    ps.rejected_reason
from property_seed ps
join users u on u.email = ps.host_email
join areas a on a.name = ps.area_name
join room_types rt on rt.name = ps.room_type_name
left join users admin_u on admin_u.email = 'admin@leaselink.vn';

insert into property_images(property_id, image_url, is_thumbnail, sort_order)
select
    p.id,
    'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=1200&q=80&sig=' || row_number() over (order by p.created_at, p.title),
    true,
    0
from properties p
where not exists (
    select 1
    from property_images pi
    where pi.property_id = p.id
      and pi.is_thumbnail = true
);

insert into property_images(property_id, image_url, is_thumbnail, sort_order)
select
    p.id,
    'https://images.unsplash.com/photo-1494526585095-c41746248156?auto=format&fit=crop&w=1200&q=80&sig=' || row_number() over (order by p.created_at desc, p.title),
    false,
    1
from properties p
where p.status in ('APPROVED', 'PENDING')
  and not exists (
      select 1
      from property_images pi
      where pi.property_id = p.id
        and pi.sort_order = 1
  )
limit 20;
