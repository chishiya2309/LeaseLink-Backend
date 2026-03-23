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