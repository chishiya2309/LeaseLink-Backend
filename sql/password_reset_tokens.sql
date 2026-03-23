create table if not exists password_reset_tokens (
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

create index if not exists idx_password_reset_tokens_user_created
    on password_reset_tokens(user_id, created_at desc);

create index if not exists idx_password_reset_tokens_expires
    on password_reset_tokens(expires_at);
