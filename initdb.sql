--
-- PostgreSQL database dump
--

\restrict 16Ewaq0FTVFFfHW7JhHebxsxM2xAgW5MmZQ1s3m6JMpkQ2qPhbIygtvPUwXYEuq

-- Dumped from database version 17.9
-- Dumped by pg_dump version 18.3

-- Started on 2026-04-02 20:15:18

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 4691 (class 1262 OID 33669)
-- Name: lease_link; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE lease_link WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.UTF-8';


\unrestrict 16Ewaq0FTVFFfHW7JhHebxsxM2xAgW5MmZQ1s3m6JMpkQ2qPhbIygtvPUwXYEuq
\connect lease_link
\restrict 16Ewaq0FTVFFfHW7JhHebxsxM2xAgW5MmZQ1s3m6JMpkQ2qPhbIygtvPUwXYEuq

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 6 (class 2615 OID 34201)
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- TOC entry 4692 (class 0 OID 0)
-- Dependencies: 6
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS '';


--
-- TOC entry 2 (class 3079 OID 34202)
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- TOC entry 4693 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- TOC entry 903 (class 1247 OID 34248)
-- Name: property_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.property_status AS ENUM (
    'DRAFT',
    'PENDING',
    'APPROVED',
    'REJECTED',
    'HIDDEN',
    'DELETED'
);


--
-- TOC entry 948 (class 1247 OID 34558)
-- Name: propertystatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.propertystatus AS ENUM (
    'APPROVED',
    'DELETED',
    'DRAFT',
    'HIDDEN',
    'PENDING',
    'REJECTED'
);


--
-- TOC entry 900 (class 1247 OID 34240)
-- Name: user_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.user_status AS ENUM (
    'PENDING',
    'ACTIVE',
    'LOCKED'
);


--
-- TOC entry 951 (class 1247 OID 34574)
-- Name: userstatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.userstatus AS ENUM (
    'ACTIVE',
    'LOCKED',
    'PENDING'
);


--
-- TOC entry 4405 (class 2605 OID 34572)
-- Name: CAST (public.propertystatus AS character varying); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.propertystatus AS character varying) WITH INOUT AS IMPLICIT;


--
-- TOC entry 4406 (class 2605 OID 34582)
-- Name: CAST (public.userstatus AS character varying); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.userstatus AS character varying) WITH INOUT AS IMPLICIT;


--
-- TOC entry 4324 (class 2605 OID 34571)
-- Name: CAST (character varying AS public.propertystatus); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (character varying AS public.propertystatus) WITH INOUT AS IMPLICIT;


--
-- TOC entry 4325 (class 2605 OID 34581)
-- Name: CAST (character varying AS public.userstatus); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (character varying AS public.userstatus) WITH INOUT AS IMPLICIT;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 220 (class 1259 OID 34277)
-- Name: areas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.areas (
    id bigint NOT NULL,
    name character varying(120) NOT NULL,
    slug character varying(150) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 219 (class 1259 OID 34276)
-- Name: areas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.areas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4694 (class 0 OID 0)
-- Dependencies: 219
-- Name: areas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.areas_id_seq OWNED BY public.areas.id;


--
-- TOC entry 231 (class 1259 OID 34402)
-- Name: auth_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth_sessions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    device_id character varying(120),
    user_agent text,
    ip character varying(45),
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    last_seen_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone NOT NULL
);


--
-- TOC entry 235 (class 1259 OID 34488)
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    recipient_id uuid NOT NULL,
    type character varying(50) NOT NULL,
    title character varying(160) NOT NULL,
    message text NOT NULL,
    link character varying(255),
    is_read boolean DEFAULT false NOT NULL,
    read_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 233 (class 1259 OID 34444)
-- Name: password_reset_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.password_reset_tokens (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    email_snapshot character varying(255) NOT NULL,
    otp_hash text NOT NULL,
    reset_token_hash text,
    expires_at timestamp with time zone NOT NULL,
    verified_at timestamp with time zone,
    consumed_at timestamp with time zone,
    attempt_count integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 228 (class 1259 OID 34364)
-- Name: permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permissions (
    id bigint NOT NULL,
    code character varying(100) NOT NULL,
    name character varying(150) NOT NULL
);


--
-- TOC entry 227 (class 1259 OID 34363)
-- Name: permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4695 (class 0 OID 0)
-- Dependencies: 227
-- Name: permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.permissions_id_seq OWNED BY public.permissions.id;


--
-- TOC entry 223 (class 1259 OID 34302)
-- Name: properties; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.properties (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    host_id uuid NOT NULL,
    area_id bigint NOT NULL,
    room_type_id bigint NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    address_line character varying(255) NOT NULL,
    monthly_price numeric(14,2) NOT NULL,
    area_m2 numeric(8,2),
    bedrooms smallint,
    allow_pets boolean DEFAULT false,
    status public.property_status DEFAULT 'PENDING'::public.property_status NOT NULL,
    approved_by uuid,
    approved_at timestamp with time zone,
    rejected_reason text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT properties_area_m2_check CHECK ((area_m2 > (0)::numeric)),
    CONSTRAINT properties_bedrooms_check CHECK ((bedrooms >= 0)),
    CONSTRAINT properties_monthly_price_check CHECK ((monthly_price >= (0)::numeric))
);


--
-- TOC entry 224 (class 1259 OID 34337)
-- Name: property_images; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.property_images (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    property_id uuid NOT NULL,
    image_url text NOT NULL,
    is_thumbnail boolean DEFAULT false NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 232 (class 1259 OID 34418)
-- Name: refresh_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.refresh_tokens (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    session_id uuid NOT NULL,
    user_id uuid NOT NULL,
    token_hash text NOT NULL,
    jti uuid NOT NULL,
    issued_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    revoked_at timestamp with time zone,
    replaced_by_token_id uuid,
    revoke_reason character varying(120)
);


--
-- TOC entry 234 (class 1259 OID 34460)
-- Name: revoked_jtis; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.revoked_jtis (
    jti uuid NOT NULL,
    user_id uuid NOT NULL,
    token_type character varying(20) NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    revoked_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT revoked_jtis_token_type_check CHECK (((token_type)::text = ANY ((ARRAY['access'::character varying, 'refresh'::character varying])::text[])))
);


--
-- TOC entry 229 (class 1259 OID 34372)
-- Name: role_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.role_permissions (
    role_id smallint NOT NULL,
    permission_id bigint NOT NULL
);


--
-- TOC entry 226 (class 1259 OID 34355)
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id smallint NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(120) NOT NULL
);


--
-- TOC entry 225 (class 1259 OID 34354)
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roles_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4696 (class 0 OID 0)
-- Dependencies: 225
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- TOC entry 222 (class 1259 OID 34291)
-- Name: room_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.room_types (
    id bigint NOT NULL,
    name character varying(80) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 221 (class 1259 OID 34290)
-- Name: room_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.room_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4697 (class 0 OID 0)
-- Dependencies: 221
-- Name: room_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.room_types_id_seq OWNED BY public.room_types.id;


--
-- TOC entry 230 (class 1259 OID 34387)
-- Name: user_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_roles (
    user_id uuid NOT NULL,
    role_id smallint NOT NULL
);


--
-- TOC entry 218 (class 1259 OID 34261)
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    full_name character varying(120) NOT NULL,
    email character varying(255) NOT NULL,
    phone character varying(20),
    password_hash text NOT NULL,
    status public.user_status DEFAULT 'ACTIVE'::public.user_status NOT NULL,
    last_login_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    lock_reason text
);


--
-- TOC entry 4411 (class 2604 OID 34280)
-- Name: areas id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.areas ALTER COLUMN id SET DEFAULT nextval('public.areas_id_seq'::regclass);


--
-- TOC entry 4429 (class 2604 OID 34367)
-- Name: permissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions ALTER COLUMN id SET DEFAULT nextval('public.permissions_id_seq'::regclass);


--
-- TOC entry 4428 (class 2604 OID 34358)
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- TOC entry 4415 (class 2604 OID 34294)
-- Name: room_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_types ALTER COLUMN id SET DEFAULT nextval('public.room_types_id_seq'::regclass);


--
-- TOC entry 4670 (class 0 OID 34277)
-- Dependencies: 220
-- Data for Name: areas; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.areas (id, name, slug, is_active, created_at, updated_at) VALUES (11, 'Huyện Hoàng Sa', 'huyen-hoang-sa', true, '2026-03-24 08:27:16.71665+00', '2026-03-24 08:27:16.71665+00');
INSERT INTO public.areas (id, name, slug, is_active, created_at, updated_at) VALUES (22, 'Hải Châu', 'hai-chau', true, '2026-03-24 09:22:46.747718+00', '2026-03-24 09:22:46.747718+00');
INSERT INTO public.areas (id, name, slug, is_active, created_at, updated_at) VALUES (23, 'Thanh Khê', 'thanh-khe', true, '2026-03-24 09:22:46.747718+00', '2026-03-24 09:22:46.747718+00');
INSERT INTO public.areas (id, name, slug, is_active, created_at, updated_at) VALUES (24, 'Sơn Trà', 'son-tra', true, '2026-03-24 09:22:46.747718+00', '2026-03-24 09:22:46.747718+00');
INSERT INTO public.areas (id, name, slug, is_active, created_at, updated_at) VALUES (25, 'Ngũ Hành Sơn', 'ngu-hanh-son', true, '2026-03-24 09:22:46.747718+00', '2026-03-24 09:22:46.747718+00');
INSERT INTO public.areas (id, name, slug, is_active, created_at, updated_at) VALUES (26, 'Liên Chiểu', 'lien-chieu', true, '2026-03-24 09:22:46.747718+00', '2026-03-24 09:22:46.747718+00');
INSERT INTO public.areas (id, name, slug, is_active, created_at, updated_at) VALUES (27, 'Cẩm Lệ', 'cam-le', true, '2026-03-24 09:22:46.747718+00', '2026-03-24 09:22:46.747718+00');
INSERT INTO public.areas (id, name, slug, is_active, created_at, updated_at) VALUES (28, 'Hoa Xuân', 'hoa-xuan', true, '2026-03-24 09:22:46.747718+00', '2026-03-24 09:22:46.747718+00');
INSERT INTO public.areas (id, name, slug, is_active, created_at, updated_at) VALUES (29, 'Hoà Khánh', 'hoa-khanh', true, '2026-03-24 09:22:46.747718+00', '2026-03-24 09:22:46.747718+00');
INSERT INTO public.areas (id, name, slug, is_active, created_at, updated_at) VALUES (30, 'An Thượng', 'an-thuong', true, '2026-03-24 09:22:46.747718+00', '2026-03-24 09:22:46.747718+00');
INSERT INTO public.areas (id, name, slug, is_active, created_at, updated_at) VALUES (31, 'Mỹ An', 'my-an', true, '2026-03-24 09:22:46.747718+00', '2026-03-24 09:22:46.747718+00');


--
-- TOC entry 4681 (class 0 OID 34402)
-- Dependencies: 231
-- Data for Name: auth_sessions; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('9baf9204-0710-46e6-875d-64493dbd92aa', 'af82b3fe-b7d3-4342-a07f-1cdbc65233ee', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', false, '2026-03-23 17:02:04.64337+00', '2026-03-23 17:02:04.64337+00', '2026-03-30 17:02:04.642337+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('5f87c056-878f-414f-92b6-769a53b76880', '28eeca87-18d2-44af-afde-58f5ed6927c9', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-24 06:19:45.805382+00', '2026-03-24 06:19:45.805382+00', '2026-03-31 06:19:45.803343+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('d7ae594f-f5d5-426d-8e63-5ea768b1c3f5', '28eeca87-18d2-44af-afde-58f5ed6927c9', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-24 08:10:51.087552+00', '2026-03-24 08:10:51.087552+00', '2026-03-31 08:10:51.086553+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('1e5ee1d7-8fc9-4854-aa40-c249367bd7cb', '28eeca87-18d2-44af-afde-58f5ed6927c9', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-24 09:20:25.617168+00', '2026-03-24 09:20:25.617168+00', '2026-03-31 09:20:25.616167+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('379d4414-e32b-424f-93d1-12b78a7fa20c', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-24 09:35:04.806407+00', '2026-03-24 09:35:04.806407+00', '2026-03-31 09:35:04.802508+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('88c6bc97-8713-4d8d-98ad-19c71f5207d6', 'af82b3fe-b7d3-4342-a07f-1cdbc65233ee', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', false, '2026-03-23 17:10:51.839192+00', '2026-03-23 17:10:51.839192+00', '2026-03-30 17:10:51.838219+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('0f3c4153-064b-408d-adde-6618483fc0f2', 'af82b3fe-b7d3-4342-a07f-1cdbc65233ee', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', false, '2026-03-25 03:35:26.130909+00', '2026-03-25 03:35:26.130909+00', '2026-04-01 03:35:26.126999+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('1f7299f6-5f6c-45e4-bd7d-34ac9d301740', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-26 01:53:57.386596+00', '2026-03-26 01:53:57.386596+00', '2026-04-02 01:53:57.384069+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('8bbb5dd8-13b7-49c0-ab25-325fbdfe729f', '28eeca87-18d2-44af-afde-58f5ed6927c9', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-26 02:00:15.217752+00', '2026-03-26 02:00:15.217752+00', '2026-04-02 02:00:15.217752+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('9a37163d-320c-41cd-b96c-c96400251248', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-26 02:29:08.920896+00', '2026-03-26 02:29:08.920896+00', '2026-04-02 02:29:08.917188+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('9a04b5eb-2065-4abd-a63d-0963283f908f', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-26 02:36:07.038348+00', '2026-03-26 02:36:07.038348+00', '2026-04-02 02:36:07.035349+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('88f9017f-a86d-4e63-a548-cd8d0cf6a02e', '5f0c2f5f-00e3-4f89-a5ac-b2c39ede0104', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-26 02:36:29.715956+00', '2026-03-26 02:36:29.715956+00', '2026-04-02 02:36:29.715956+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('140245f8-54f7-4845-85ea-d5c897484796', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-26 02:38:15.670059+00', '2026-03-26 02:38:15.670059+00', '2026-04-02 02:38:15.670059+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('a27cefc3-bee6-4f67-9340-e00ea3a6f3fc', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-26 02:47:58.19845+00', '2026-03-26 02:47:58.19845+00', '2026-04-02 02:47:58.195443+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('3a8ae196-d087-4ba0-98b3-fa5676807eb5', '28eeca87-18d2-44af-afde-58f5ed6927c9', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-26 02:50:41.635654+00', '2026-03-26 02:50:41.635654+00', '2026-04-02 02:50:41.635654+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('eaf6b1bf-106a-4a50-8e8d-c393e28fd3fd', '28eeca87-18d2-44af-afde-58f5ed6927c9', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-26 02:52:38.906263+00', '2026-03-26 02:52:38.906263+00', '2026-04-02 02:52:38.905231+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('d341224e-f349-46d4-9a2c-bdf0b1e78f6b', '28eeca87-18d2-44af-afde-58f5ed6927c9', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-26 02:53:12.518094+00', '2026-03-26 02:53:12.518094+00', '2026-04-02 02:53:12.517095+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('df2b876e-7a7c-4f44-a4bd-58a8adadd8ae', '28eeca87-18d2-44af-afde-58f5ed6927c9', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-26 06:05:56.189464+00', '2026-03-26 06:05:56.189464+00', '2026-04-02 06:05:56.185827+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('7813a742-089f-401f-8fad-37a390657ed4', 'af82b3fe-b7d3-4342-a07f-1cdbc65233ee', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-26 08:53:00.42408+00', '2026-03-26 08:53:00.42408+00', '2026-04-02 08:53:00.422078+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('2ca12f78-c0b7-4297-9e27-041d79294bee', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-26 08:56:23.172538+00', '2026-03-26 08:56:23.172538+00', '2026-04-02 08:56:23.169537+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('89b0c2d7-8e99-4a94-9d0d-477340979473', 'af82b3fe-b7d3-4342-a07f-1cdbc65233ee', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-26 08:57:13.055882+00', '2026-03-26 08:57:13.055882+00', '2026-04-02 08:57:13.054905+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('46d3d0ae-0bed-4b95-ac32-8d667e3beb29', 'af82b3fe-b7d3-4342-a07f-1cdbc65233ee', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-26 08:59:28.020833+00', '2026-03-26 08:59:28.020833+00', '2026-04-02 08:59:28.019822+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('dc4d84be-f004-41cb-9534-e303c4ee7b58', 'af82b3fe-b7d3-4342-a07f-1cdbc65233ee', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-26 09:14:47.534752+00', '2026-03-26 09:14:47.534752+00', '2026-04-02 09:14:47.531145+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('c80b4e9d-4af1-42b0-a3a8-fc98ae57960d', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-26 09:25:42.700435+00', '2026-03-26 09:25:42.700435+00', '2026-04-02 09:25:42.699436+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('9b65f1d5-ae70-4673-b9e5-6e6ce039e9e7', '28eeca87-18d2-44af-afde-58f5ed6927c9', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-26 10:11:01.865507+00', '2026-03-26 10:11:01.865507+00', '2026-04-02 10:11:01.862425+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('e2fd76c3-70d1-4d52-912e-570ad64d8592', 'cfd595c3-035b-4243-bcfb-edb7c549df30', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-26 11:42:15.223427+00', '2026-03-26 11:42:15.223427+00', '2026-04-02 11:42:15.223427+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('074e6857-5b75-4661-ba91-96a13ff4e1c9', '5f0c2f5f-00e3-4f89-a5ac-b2c39ede0104', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-26 11:52:19.535154+00', '2026-03-26 11:52:19.535154+00', '2026-04-02 11:52:19.533136+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('ba39c69b-81b3-4af4-b267-539fc5fe7b9a', '5f0c2f5f-00e3-4f89-a5ac-b2c39ede0104', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-26 11:57:51.70827+00', '2026-03-26 11:57:51.70827+00', '2026-04-02 11:57:51.707275+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('9738924e-1ce3-4c09-88a2-3ad416c2296d', 'cfd595c3-035b-4243-bcfb-edb7c549df30', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-26 11:59:15.95867+00', '2026-03-26 11:59:15.95867+00', '2026-04-02 11:59:15.95867+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('3bc29829-8fc0-44a1-bb6d-26ca9a1d6915', '28eeca87-18d2-44af-afde-58f5ed6927c9', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-27 01:43:23.594045+00', '2026-03-27 01:43:23.594045+00', '2026-04-03 01:43:23.590042+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('ce65e402-4536-4194-9f39-e83e20d341d8', '28eeca87-18d2-44af-afde-58f5ed6927c9', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-27 02:44:35.437797+00', '2026-03-27 02:44:35.437797+00', '2026-04-03 02:44:35.435777+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('13697863-375b-4f05-9a10-00e9f54720a0', '28eeca87-18d2-44af-afde-58f5ed6927c9', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-27 06:15:15.631695+00', '2026-03-27 06:15:15.631695+00', '2026-04-03 06:15:15.627082+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('57cf0ed0-ca67-4485-836a-bedaf5f8652a', '28eeca87-18d2-44af-afde-58f5ed6927c9', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-27 06:32:25.817971+00', '2026-03-27 06:32:25.817971+00', '2026-04-03 06:32:25.80689+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('674baa07-83f3-40b3-8d84-d1dc363a4112', '28eeca87-18d2-44af-afde-58f5ed6927c9', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-27 07:36:04.116792+00', '2026-03-27 07:36:04.116792+00', '2026-04-03 07:36:04.1138+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('ffccc9d1-8207-4f08-a841-ea6c4a4c87bc', 'af82b3fe-b7d3-4342-a07f-1cdbc65233ee', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-28 08:56:19.386875+00', '2026-03-28 08:56:19.386875+00', '2026-04-04 08:56:19.382958+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('cc57248f-0a53-4a56-98fd-19b9b5ede93b', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-28 08:57:20.271031+00', '2026-03-28 08:57:20.271031+00', '2026-04-04 08:57:20.271031+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('94e9a290-d903-4630-9407-373a5fe9e1bc', '28eeca87-18d2-44af-afde-58f5ed6927c9', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-28 09:47:51.594256+00', '2026-03-28 09:47:51.594256+00', '2026-04-04 09:47:51.591172+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('845fa58b-8a6a-4f96-af1d-00a6c3e9fc2b', '28eeca87-18d2-44af-afde-58f5ed6927c9', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-28 12:44:52.042156+00', '2026-03-28 12:44:52.042156+00', '2026-04-04 12:44:52.040157+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('124c2c92-3bfa-40e7-a588-295f124e2829', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-28 15:16:03.052821+00', '2026-03-28 15:16:03.052821+00', '2026-04-04 15:16:03.04882+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('2522743e-ca0c-434e-bd92-46f68d819816', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-28 15:44:41.749056+00', '2026-03-28 15:44:41.749056+00', '2026-04-04 15:44:41.74206+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('85cbf8a8-3ae6-4c59-89ad-bbc7664aaab1', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-28 16:04:55.101823+00', '2026-03-28 16:04:55.101823+00', '2026-04-04 16:04:55.09782+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('1b3312e5-705a-48f3-b60a-f8603794b15d', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-28 16:11:07.629198+00', '2026-03-28 16:11:07.629198+00', '2026-04-04 16:11:07.625198+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('bb1eea6d-8c49-45b4-a528-263a57e185f8', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-28 16:27:29.775113+00', '2026-03-28 16:27:29.775113+00', '2026-04-04 16:27:29.774114+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('3d4bf4b3-0a60-49bd-aa57-274a48276971', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-28 16:30:10.336387+00', '2026-03-28 16:30:10.336387+00', '2026-04-04 16:30:10.336387+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('89ccb996-c534-465f-af56-b98a57ec0e93', '3ec0c781-ed01-4efc-b02e-6ef9ffe05576', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', false, '2026-03-28 15:30:05.331616+00', '2026-03-28 15:30:05.331616+00', '2026-04-04 15:30:05.309618+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('3d21adc1-9a6f-40c7-94de-0ba948059570', '3ec0c781-ed01-4efc-b02e-6ef9ffe05576', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', false, '2026-03-28 16:21:35.787978+00', '2026-03-28 16:21:35.787978+00', '2026-04-04 16:21:35.758359+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('f571ef2d-759c-409b-9f73-fdf44035bd20', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-28 16:59:36.062277+00', '2026-03-28 16:59:36.062277+00', '2026-04-04 16:59:36.005594+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('aeaf688f-0f22-408f-a16e-53a77f669990', '3ec0c781-ed01-4efc-b02e-6ef9ffe05576', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-28 17:01:42.789967+00', '2026-03-28 17:01:42.789967+00', '2026-04-04 17:01:42.787956+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('746a15d8-57d8-441a-917b-e5d078d05351', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-28 17:02:41.364031+00', '2026-03-28 17:02:41.364031+00', '2026-04-04 17:02:41.364031+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('a35f8eb6-8da4-4ca2-9b06-b15d74ab71fd', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-28 17:22:34.817948+00', '2026-03-28 17:22:34.817948+00', '2026-04-04 17:22:34.808042+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('720a2133-4a44-427c-8580-2e487090e020', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-29 01:18:38.063473+00', '2026-03-29 01:18:38.063473+00', '2026-04-05 01:18:38.057473+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('cda0130c-6963-4f46-85e6-0f1cadec022f', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-29 01:49:47.991255+00', '2026-03-29 01:49:47.991255+00', '2026-04-05 01:49:47.990254+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('afa3ed5c-15ae-4de9-a2d6-b5519841b95a', '007deeb1-cee0-47f6-9467-6450433c4315', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-29 02:16:18.848869+00', '2026-03-29 02:16:18.848869+00', '2026-04-05 02:16:18.835587+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('a4e932e1-af0b-4b8a-87fc-228e5c1223e8', '8508dcf4-5077-4f8a-9bff-52a08f472dcf', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-29 03:14:40.429648+00', '2026-03-29 03:14:40.429648+00', '2026-04-05 03:14:40.427657+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('f4cdbc8e-1acb-44b3-82ff-33cc50b838eb', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-29 03:15:21.438367+00', '2026-03-29 03:15:21.438367+00', '2026-04-05 03:15:21.438367+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('4bee12c2-9bfc-45ab-b2e5-d1a97557f393', '8508dcf4-5077-4f8a-9bff-52a08f472dcf', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-29 03:16:18.295913+00', '2026-03-29 03:16:18.295913+00', '2026-04-05 03:16:18.28664+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('47fa3c2b-9546-4590-88be-876307fcdb38', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-29 03:52:01.106378+00', '2026-03-29 03:52:01.106378+00', '2026-04-05 03:52:01.105293+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('2b6a8602-0e25-42c4-adb7-b52d7876b8be', '8508dcf4-5077-4f8a-9bff-52a08f472dcf', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-29 03:58:54.343557+00', '2026-03-29 03:58:54.343557+00', '2026-04-05 03:58:54.333047+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('809ae27b-61fd-4559-9c43-989446fd9d28', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-29 04:05:11.313021+00', '2026-03-29 04:05:11.313021+00', '2026-04-05 04:05:11.312019+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('df4d2d02-466b-410a-b9d6-6bc189583325', '8508dcf4-5077-4f8a-9bff-52a08f472dcf', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-29 04:06:05.194307+00', '2026-03-29 04:06:05.194307+00', '2026-04-05 04:06:05.18376+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('fe764c4c-3508-445e-9ba8-b686b2c43f83', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', true, '2026-03-29 06:40:06.516733+00', '2026-03-29 06:40:06.516733+00', '2026-04-05 06:40:06.510641+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('c30dbaf1-a47f-4e53-a2cf-611374d0e723', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', true, '2026-03-29 07:11:44.11952+00', '2026-03-29 07:11:44.11952+00', '2026-04-05 07:11:44.119169+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('d3e7bc22-5013-4fc4-a161-571cdd848da5', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', true, '2026-03-29 07:13:11.176129+00', '2026-03-29 07:13:11.176129+00', '2026-04-05 07:13:11.175729+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('bf3659b5-2b29-4ec2-865d-36b42942648c', 'd0740f8c-5c94-403d-827c-6ab31b04ec49', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', false, '2026-03-29 06:59:49.964668+00', '2026-03-29 06:59:49.964668+00', '2026-04-05 06:59:49.963574+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('81847009-6bed-48da-aeec-3197157a7349', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', true, '2026-03-29 07:22:23.759808+00', '2026-03-29 07:22:23.759808+00', '2026-04-05 07:22:23.759582+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('9aab618e-5e70-4ce1-bd1c-4c014e86bd96', '0e82682f-af39-4947-b07f-72952c92976c', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', false, '2026-03-29 07:17:52.913114+00', '2026-03-29 07:17:52.913114+00', '2026-04-05 07:17:52.912507+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('ca7f959a-c750-4f01-8f0b-0447fb725989', '28eeca87-18d2-44af-afde-58f5ed6927c9', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-29 07:25:37.458131+00', '2026-03-29 07:25:37.458131+00', '2026-04-05 07:25:37.456131+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('62a50eeb-f706-49d9-9c32-950c7f8de9bf', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', true, '2026-03-29 07:38:00.710155+00', '2026-03-29 07:38:00.710155+00', '2026-04-05 07:38:00.709856+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('15b87586-866e-451a-9fcf-383b2d2c84e4', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', true, '2026-03-29 07:44:25.896116+00', '2026-03-29 07:44:25.896116+00', '2026-04-05 07:44:25.895799+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('67aa4abe-65d8-4291-9083-a0befaba5e22', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', true, '2026-03-29 07:45:30.531455+00', '2026-03-29 07:45:30.531455+00', '2026-04-05 07:45:30.530793+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('750f626d-6013-4558-839d-165ae8054dd7', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', true, '2026-03-29 07:46:57.573507+00', '2026-03-29 07:46:57.573507+00', '2026-04-05 07:46:57.57333+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('4786a54a-a2a8-4b32-b51a-1755c219ec15', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', true, '2026-03-29 07:48:13.899279+00', '2026-03-29 07:48:13.899279+00', '2026-04-05 07:48:13.899096+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('ecdba08d-09dc-4e53-a51b-ced7dbedd57d', '0e82682f-af39-4947-b07f-72952c92976c', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', false, '2026-03-29 07:28:07.845139+00', '2026-03-29 07:28:07.845139+00', '2026-04-05 07:28:07.844783+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('e9aeef60-cebd-47bb-ac30-f5ecbf9b04f9', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', true, '2026-03-29 07:49:39.076725+00', '2026-03-29 07:49:39.076725+00', '2026-04-05 07:49:39.076534+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('fa58db9c-3ba6-4285-a790-972483a9ffe3', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', true, '2026-03-29 07:50:15.880389+00', '2026-03-29 07:50:15.880389+00', '2026-04-05 07:50:15.880111+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('717374a8-b22b-48cf-acb4-f5fa4e0d4264', '0e82682f-af39-4947-b07f-72952c92976c', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', true, '2026-03-29 07:50:32.1491+00', '2026-03-29 07:50:32.1491+00', '2026-04-05 07:50:32.148815+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('4a55c885-e581-459b-8933-cefb22118efb', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', true, '2026-03-29 07:50:40.63148+00', '2026-03-29 07:50:40.63148+00', '2026-04-05 07:50:40.631234+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('148d9771-6741-476a-a6a4-40bcead42146', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', true, '2026-03-29 08:39:53.15395+00', '2026-03-29 08:39:53.15395+00', '2026-04-05 08:39:53.149772+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('2aacbcea-6896-4898-8ae0-33330bcf5bdb', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', true, '2026-03-29 08:44:39.108883+00', '2026-03-29 08:44:39.108883+00', '2026-04-05 08:44:39.108471+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('c8e2e2ac-7e3a-4db3-8b79-bd14e903c66b', '28eeca87-18d2-44af-afde-58f5ed6927c9', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-29 08:51:58.751483+00', '2026-03-29 08:51:58.751483+00', '2026-04-05 08:51:58.747445+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('d0da4d60-2a00-41e0-9d96-984b13884c56', '28eeca87-18d2-44af-afde-58f5ed6927c9', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-29 08:55:59.437403+00', '2026-03-29 08:55:59.437403+00', '2026-04-05 08:55:59.434407+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('ad4078b5-1ae4-46e7-8d8c-e2105d6e4826', '28eeca87-18d2-44af-afde-58f5ed6927c9', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-29 10:09:10.674405+00', '2026-03-29 10:09:10.674405+00', '2026-04-05 10:09:10.674405+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('10dd1f19-69de-438a-823f-b38cf96b39a1', '28eeca87-18d2-44af-afde-58f5ed6927c9', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', true, '2026-03-29 12:23:46.588093+00', '2026-03-29 12:23:46.588093+00', '2026-04-05 12:23:46.587784+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('d31f56d8-63f0-445d-8173-316996fca55b', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', true, '2026-03-29 12:43:49.349491+00', '2026-03-29 12:43:49.349491+00', '2026-04-05 12:43:49.348914+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('dd2c78c8-a853-4026-86f4-be2c34e48242', '28eeca87-18d2-44af-afde-58f5ed6927c9', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '0:0:0:0:0:0:0:1', true, '2026-03-30 15:45:03.070047+00', '2026-03-30 15:45:03.070047+00', '2026-04-06 15:45:03.066993+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('5b88285b-364a-4745-ae71-7621ec2d46f2', 'af82b3fe-b7d3-4342-a07f-1cdbc65233ee', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', '172.18.0.1', true, '2026-03-31 03:25:51.597678+00', '2026-03-31 03:25:51.597678+00', '2026-04-07 03:25:51.592892+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('90a6006e-168d-4253-b260-3e373875e5ee', 'cfd595c3-035b-4243-bcfb-edb7c549df30', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', true, '2026-03-31 14:43:03.785252+00', '2026-03-31 14:43:03.785252+00', '2026-04-07 14:43:03.785048+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('1996d3cd-3aec-453a-a628-1b2f9f142582', '5f0c2f5f-00e3-4f89-a5ac-b2c39ede0104', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', true, '2026-03-31 14:43:23.309848+00', '2026-03-31 14:43:23.309848+00', '2026-04-07 14:43:23.309553+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('b9c580fe-e1a3-456d-a9ae-e4767c64d5d4', '28eeca87-18d2-44af-afde-58f5ed6927c9', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', true, '2026-03-31 14:44:08.987667+00', '2026-03-31 14:44:08.987667+00', '2026-04-07 14:44:08.987048+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('d3bc7bee-a5c1-4230-96de-b13bdcfdefa0', '5f0c2f5f-00e3-4f89-a5ac-b2c39ede0104', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', true, '2026-03-31 14:44:56.273055+00', '2026-03-31 14:44:56.273055+00', '2026-04-07 14:44:56.272475+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('397b5d99-c290-47da-bb4b-d22f32f0e92a', '28eeca87-18d2-44af-afde-58f5ed6927c9', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', true, '2026-03-31 14:45:28.709657+00', '2026-03-31 14:45:28.709657+00', '2026-04-07 14:45:28.709371+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('9bbea148-5b1c-4d03-ad03-4c7488e11f4f', 'af82b3fe-b7d3-4342-a07f-1cdbc65233ee', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', true, '2026-03-31 14:52:07.052162+00', '2026-03-31 14:52:07.052162+00', '2026-04-07 14:52:07.051984+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('9fc8b8ce-4ed9-4fe7-81be-46ec3f90da8d', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', '172.18.0.1', true, '2026-03-31 15:14:28.262157+00', '2026-03-31 15:14:28.262157+00', '2026-04-07 15:14:28.258806+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('c81e03a7-7d7b-46a8-a008-06281a736806', '28eeca87-18d2-44af-afde-58f5ed6927c9', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', true, '2026-03-31 15:21:29.229874+00', '2026-03-31 15:21:29.229874+00', '2026-04-07 15:21:29.22958+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('c6d7c41b-7bc1-44c0-8193-c8e6e959f489', '28eeca87-18d2-44af-afde-58f5ed6927c9', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '172.18.0.1', true, '2026-03-31 15:23:44.961775+00', '2026-03-31 15:23:44.961775+00', '2026-04-07 15:23:44.961126+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('27605ba1-84fe-411f-91b1-d09508215a29', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', true, '2026-04-01 08:40:53.207671+00', '2026-04-01 08:40:53.207671+00', '2026-04-08 08:40:53.207488+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('09e8c10e-5daf-435d-ba51-2bf6e4aa43b2', '28eeca87-18d2-44af-afde-58f5ed6927c9', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '172.18.0.1', true, '2026-04-01 09:51:31.528808+00', '2026-04-01 09:51:31.528808+00', '2026-04-08 09:51:31.52861+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('b9dc297c-73ac-4c9c-8f9b-7daf707abcd6', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', true, '2026-04-01 09:51:40.806241+00', '2026-04-01 09:51:40.806241+00', '2026-04-08 09:51:40.801148+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('511b22d2-c856-49fa-b06b-f2aea92ce49f', '28eeca87-18d2-44af-afde-58f5ed6927c9', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '172.18.0.1', true, '2026-04-01 10:01:34.433058+00', '2026-04-01 10:01:34.433058+00', '2026-04-08 10:01:34.432823+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('c69eb545-3c02-4877-8e70-5eb93b7d47e7', '28eeca87-18d2-44af-afde-58f5ed6927c9', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', '172.18.0.1', true, '2026-04-01 10:04:55.361104+00', '2026-04-01 10:04:55.361104+00', '2026-04-08 10:04:55.360913+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('3952c02d-f5c4-4b24-8637-4f8493ce9f6c', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', '172.18.0.1', true, '2026-04-01 10:20:30.772081+00', '2026-04-01 10:20:30.772081+00', '2026-04-08 10:20:30.771265+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('12dcb41a-a1cb-4a3b-af48-70a3758f7f82', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', true, '2026-04-01 10:28:43.850664+00', '2026-04-01 10:28:43.850664+00', '2026-04-08 10:28:43.850472+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('78bed69d-e3a0-4b26-accb-4027af7da264', '28eeca87-18d2-44af-afde-58f5ed6927c9', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '172.18.0.1', true, '2026-04-01 10:35:57.445441+00', '2026-04-01 10:35:57.445441+00', '2026-04-08 10:35:57.445202+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('a668ee0d-af9d-4b22-b739-e9e5021b8b5b', '5f0c2f5f-00e3-4f89-a5ac-b2c39ede0104', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '172.18.0.1', true, '2026-04-01 10:58:35.11625+00', '2026-04-01 10:58:35.11625+00', '2026-04-08 10:58:35.116077+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('9516406b-6656-45d4-bfee-75fb5bfd3920', '28eeca87-18d2-44af-afde-58f5ed6927c9', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '172.18.0.1', true, '2026-04-01 11:22:49.991509+00', '2026-04-01 11:22:49.991509+00', '2026-04-08 11:22:49.991219+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('b965ee8d-2e84-4c1a-b403-22c30326786c', 'af82b3fe-b7d3-4342-a07f-1cdbc65233ee', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', true, '2026-04-01 13:50:06.416124+00', '2026-04-01 13:50:06.416124+00', '2026-04-08 13:50:06.415951+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('fb1d9bc3-8deb-45b0-97d7-af0ab9ee193a', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', true, '2026-04-01 13:52:40.798758+00', '2026-04-01 13:52:40.798758+00', '2026-04-08 13:52:40.798619+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('32434ae3-8a0e-4f67-831f-6f01788e3217', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', true, '2026-04-01 13:56:09.30113+00', '2026-04-01 13:56:09.30113+00', '2026-04-08 13:56:09.300963+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('b46dfcbd-0f59-4f2e-9a7a-3f529dc3b9f4', 'fe59b795-b12b-4db6-9249-8fe3b3d33054', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', false, '2026-04-01 13:58:03.199443+00', '2026-04-01 13:58:03.199443+00', '2026-04-08 13:58:03.199261+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('e11583e5-18da-42c2-aad3-d2f2603f2369', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', true, '2026-04-01 14:00:17.22188+00', '2026-04-01 14:00:17.22188+00', '2026-04-08 14:00:17.221657+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('762837d2-5162-47d5-8ea5-34a3672ab211', 'd0740f8c-5c94-403d-827c-6ab31b04ec49', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', false, '2026-03-29 07:10:30.728069+00', '2026-03-29 07:10:30.728069+00', '2026-04-05 07:10:30.72752+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('f954cd1f-868f-4088-a6e6-8397913d81d6', 'd0740f8c-5c94-403d-827c-6ab31b04ec49', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', false, '2026-03-29 07:11:20.874393+00', '2026-03-29 07:11:20.874393+00', '2026-04-05 07:11:20.873497+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('1a6f637e-cbdf-45cb-9162-bebaf33e223b', 'd0740f8c-5c94-403d-827c-6ab31b04ec49', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', false, '2026-03-29 07:22:07.719903+00', '2026-03-29 07:22:07.719903+00', '2026-04-05 07:22:07.719516+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('21994c56-6808-4676-a5dd-5a6ff46c2d4c', 'd0740f8c-5c94-403d-827c-6ab31b04ec49', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', false, '2026-03-29 07:37:08.49992+00', '2026-03-29 07:37:08.49992+00', '2026-04-05 07:37:08.499633+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('deb401fe-a968-48b7-b851-66d0b6707e17', 'd0740f8c-5c94-403d-827c-6ab31b04ec49', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', false, '2026-03-29 07:38:17.722633+00', '2026-03-29 07:38:17.722633+00', '2026-04-05 07:38:17.722343+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('b4bf669e-2f61-4c2a-b797-bf270791e988', 'd0740f8c-5c94-403d-827c-6ab31b04ec49', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', false, '2026-03-29 07:42:38.520755+00', '2026-03-29 07:42:38.520755+00', '2026-04-05 07:42:38.520475+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('30bc307f-ec10-46c8-8ea4-38b050cc2974', 'd0740f8c-5c94-403d-827c-6ab31b04ec49', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', false, '2026-03-29 07:44:47.083214+00', '2026-03-29 07:44:47.083214+00', '2026-04-05 07:44:47.082897+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('bc20ccea-845f-414b-ad59-6714edfe7513', 'd0740f8c-5c94-403d-827c-6ab31b04ec49', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', false, '2026-03-29 07:46:35.741602+00', '2026-03-29 07:46:35.741602+00', '2026-04-05 07:46:35.741406+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('0f6095b4-1200-4cae-a086-d360fc9bc2e5', 'd0740f8c-5c94-403d-827c-6ab31b04ec49', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', false, '2026-03-29 07:46:46.968073+00', '2026-03-29 07:46:46.968073+00', '2026-04-05 07:46:46.967784+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('7bb3c6b2-6f13-4830-b751-48212ca1ccec', 'd0740f8c-5c94-403d-827c-6ab31b04ec49', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', false, '2026-03-29 07:47:58.683804+00', '2026-03-29 07:47:58.683804+00', '2026-04-05 07:47:58.683553+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('48c9ceac-9396-4fed-bfc3-ffc352464aa8', '26b055dd-4b1e-4a93-b76e-74db41cec950', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', false, '2026-04-01 13:52:15.080228+00', '2026-04-01 13:52:15.080228+00', '2026-04-08 13:52:15.080058+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('f0f101b2-c4e3-4bc3-bf67-d99498b047e4', '26b055dd-4b1e-4a93-b76e-74db41cec950', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', false, '2026-04-01 13:52:58.923452+00', '2026-04-01 13:52:58.923452+00', '2026-04-08 13:52:58.923196+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('4a8f0e2b-9faf-4ab9-a2c5-030719485514', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', true, '2026-04-01 14:04:28.604364+00', '2026-04-01 14:04:28.604364+00', '2026-04-08 14:04:28.604171+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('2296d7bb-f7cd-455b-a3a0-ccafc0751f02', 'fe59b795-b12b-4db6-9249-8fe3b3d33054', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', false, '2026-04-01 14:00:04.383371+00', '2026-04-01 14:00:04.383371+00', '2026-04-08 14:00:04.380033+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('a9f39ffe-3c2f-4fc5-a295-f851252ee49c', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', true, '2026-04-01 14:05:13.657098+00', '2026-04-01 14:05:13.657098+00', '2026-04-08 14:05:13.656965+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('2fc6bbc8-e140-4a5a-b2aa-2dc2339b7656', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', true, '2026-04-01 14:22:23.6733+00', '2026-04-01 14:22:23.6733+00', '2026-04-08 14:22:23.672765+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('0c49da4c-a26c-4445-b580-f700a9e41cbc', 'af82b3fe-b7d3-4342-a07f-1cdbc65233ee', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', true, '2026-04-01 14:48:35.097728+00', '2026-04-01 14:48:35.097728+00', '2026-04-08 14:48:35.097549+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('49be4df6-d6a6-43f2-8322-40c4bfd84b66', '5d053abf-972f-466c-9ffc-24affd11062e', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', true, '2026-04-01 14:52:35.968009+00', '2026-04-01 14:52:35.968009+00', '2026-04-08 14:52:35.967805+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('e42499dc-51b0-4995-876e-66d484600d45', 'af82b3fe-b7d3-4342-a07f-1cdbc65233ee', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', true, '2026-04-01 14:54:02.66186+00', '2026-04-01 14:54:02.66186+00', '2026-04-08 14:54:02.661695+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('fe02cf92-875d-43d5-8bae-d8bba8fff105', 'af82b3fe-b7d3-4342-a07f-1cdbc65233ee', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', '172.18.0.1', true, '2026-04-02 01:41:48.162775+00', '2026-04-02 01:41:48.162775+00', '2026-04-09 01:41:48.159003+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('66fe80e9-11be-40f0-b9bc-c528f4a57be3', '28eeca87-18d2-44af-afde-58f5ed6927c9', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', true, '2026-04-02 01:42:50.952005+00', '2026-04-02 01:42:50.952005+00', '2026-04-09 01:42:50.951621+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('8cbb8250-ae1f-4872-8505-e88ac4042b17', '28eeca87-18d2-44af-afde-58f5ed6927c9', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', '172.18.0.1', true, '2026-04-02 01:45:30.102392+00', '2026-04-02 01:45:30.102392+00', '2026-04-09 01:45:30.102155+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('4ff147e0-e811-4ebf-aa29-194a7eb1f19d', '28eeca87-18d2-44af-afde-58f5ed6927c9', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '172.18.0.1', true, '2026-04-02 01:49:01.787654+00', '2026-04-02 01:49:01.787654+00', '2026-04-09 01:49:01.787457+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('50856d08-d6c5-4294-aa54-28aa920fef28', '28eeca87-18d2-44af-afde-58f5ed6927c9', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '172.18.0.1', true, '2026-04-02 01:50:40.142757+00', '2026-04-02 01:50:40.142757+00', '2026-04-09 01:50:40.142465+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('0bb66d89-0ce4-4093-bdc5-f8d1ccc46489', '28eeca87-18d2-44af-afde-58f5ed6927c9', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '172.18.0.1', true, '2026-04-02 01:55:45.625472+00', '2026-04-02 01:55:45.625472+00', '2026-04-09 01:55:45.62518+00');
INSERT INTO public.auth_sessions (id, user_id, device_id, user_agent, ip, is_active, created_at, last_seen_at, expires_at) VALUES ('db10fc47-4283-49f9-92ab-719d0faf6c29', '28eeca87-18d2-44af-afde-58f5ed6927c9', NULL, 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Mobile Safari/537.36', '172.18.0.1', true, '2026-04-02 01:57:46.32724+00', '2026-04-02 01:57:46.32724+00', '2026-04-09 01:57:46.327041+00');


--
-- TOC entry 4685 (class 0 OID 34488)
-- Dependencies: 235
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('2a29a5ce-8822-4214-8255-3362d99e8a79', '5d053abf-972f-466c-9ffc-24affd11062e', 'NEW_PROPERTY_SUBMISSION', 'Có bài đăng mới chờ duyệt', 'Hưng Hảo Hán vừa gửi bài đăng "Thuê Nhà Dài Hạn Đà Nẵng 3 Phòng Ngủ Đẹp Khu Nam Hòa Xuân" để admin kiểm duyệt.', '/dashboard?page=duyet-tin-dang', true, '2026-03-29 03:57:29.337451+00', '2026-03-29 03:51:40.839726+00', '2026-03-29 03:57:29.343629+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('84192064-f14f-44b7-979e-cee0a8828f1e', '8508dcf4-5077-4f8a-9bff-52a08f472dcf', 'PROPERTY_REJECTED', 'Tin đăng bị từ chối', 'Bài đăng "Thuê Nhà Dài Hạn Đà Nẵng 3 Phòng Ngủ Đẹp Khu Nam Hòa Xuân" của bạn đã bị từ chối.', '/dashboard?page=tin-dang-cua-toi', true, '2026-03-29 03:59:08.268316+00', '2026-03-29 03:57:45.514368+00', '2026-03-29 03:59:08.268316+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('7b443d92-ff37-488f-aa3f-e1e9e91999fc', '8508dcf4-5077-4f8a-9bff-52a08f472dcf', 'PROPERTY_APPROVED', 'Tin đăng đã được duyệt', 'Bài đăng "Thuê Nhà Dài Hạn Đà Nẵng 3 Phòng Ngủ Đẹp Khu Nam Hòa Xuân" của bạn đã được admin duyệt thành công.', '/dashboard?page=tin-dang-cua-toi', true, '2026-03-29 04:06:25.543813+00', '2026-03-29 04:04:52.593091+00', '2026-03-29 04:06:25.547812+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('702da08d-b6d5-47ac-8549-2a69643e7fe3', '8508dcf4-5077-4f8a-9bff-52a08f472dcf', 'PROPERTY_APPROVED', 'Tin đăng đã được duyệt', 'Bài đăng "Thuê Nhà Dài Hạn Đà Nẵng 3 Phòng Ngủ Đẹp Khu Nam Hòa Xuân" của bạn đã được admin duyệt thành công.', '/dashboard?page=tin-dang-cua-toi', true, '2026-03-29 04:06:31.833762+00', '2026-03-29 04:05:29.529729+00', '2026-03-29 04:06:31.835768+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('2e001e2c-0ef7-4d47-a911-5c83df41244d', '5d053abf-972f-466c-9ffc-24affd11062e', 'NEW_HOST_REGISTRATION', 'Có host mới đăng ký', 'Host Huy Ngô vừa đăng ký tài khoản và đang chờ duyệt.', '/dashboard?page=quan-ly-host', true, '2026-03-29 07:11:51.0076+00', '2026-03-29 06:59:45.227765+00', '2026-03-29 07:11:51.009822+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('93ffc579-f5a1-4473-9ec3-af901f2b9d7b', '28eeca87-18d2-44af-afde-58f5ed6927c9', 'NEW_HOST_REGISTRATION', 'Có host mới đăng ký', 'Host Huy Ngô vừa đăng ký tài khoản và đang chờ duyệt.', '/dashboard?page=quan-ly-host', true, '2026-03-29 07:32:56.964049+00', '2026-03-29 06:59:45.228972+00', '2026-03-29 06:59:45.228972+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('89f79ad1-d287-4b7c-b94a-fe293a5f3e95', '28eeca87-18d2-44af-afde-58f5ed6927c9', 'NEW_PROPERTY_SUBMISSION', 'Có bài đăng mới chờ duyệt', 'Hưng Hảo Hán vừa gửi bài đăng "Thuê Nhà Dài Hạn Đà Nẵng 3 Phòng Ngủ Đẹp Khu Nam Hòa Xuân" để admin kiểm duyệt.', '/dashboard?page=duyet-tin-dang', true, '2026-03-29 07:32:56.964049+00', '2026-03-29 03:51:40.839726+00', '2026-03-29 03:51:40.839726+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('2d939a8a-ec38-4151-9b5d-f0daa2d4de50', '5d053abf-972f-466c-9ffc-24affd11062e', 'NEW_PROPERTY_SUBMISSION', 'Có bài đăng mới chờ duyệt', 'Huy Ngô vừa gửi bài đăng "Dự Án Azura Đà Nẵng Căn Hộ 1 Phòng Ngủ Nội Thất Sang Trọng Cho Thuê" để admin kiểm duyệt.', '/dashboard?page=duyet-tin-dang', true, '2026-03-29 07:44:30.081665+00', '2026-03-29 07:44:06.709863+00', '2026-03-29 07:44:30.082458+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('21a27bce-8070-4fee-9c78-7cee3af90cff', 'd0740f8c-5c94-403d-827c-6ab31b04ec49', 'PROPERTY_APPROVED', 'Tin đăng đã được duyệt', 'Bài đăng "Dự Án Azura Đà Nẵng Căn Hộ 1 Phòng Ngủ Nội Thất Sang Trọng Cho Thuê" của bạn đã được admin duyệt thành công.', '/dashboard?page=tin-dang-cua-toi', true, '2026-03-29 07:44:51.629478+00', '2026-03-29 07:44:40.281161+00', '2026-03-29 07:44:51.630131+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('a9fad41d-3576-4b81-ac08-f7b667f3beee', '28eeca87-18d2-44af-afde-58f5ed6927c9', 'NEW_PROPERTY_SUBMISSION', 'Có bài đăng mới chờ duyệt', 'Huy Ngô vừa gửi bài đăng "Dự Án Azura Đà Nẵng Căn Hộ 1 Phòng Ngủ Nội Thất Sang Trọng Cho Thuê" để admin kiểm duyệt.', '/dashboard?page=duyet-tin-dang', true, '2026-03-29 08:56:34.657428+00', '2026-03-29 07:44:06.709556+00', '2026-03-29 08:56:34.658409+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('f2b3b9ea-067c-40a4-9b71-953f22dd2d07', '28eeca87-18d2-44af-afde-58f5ed6927c9', 'NEW_PROPERTY_SUBMISSION', 'Có bài đăng mới chờ duyệt', 'Lê Quang Hưng vừa gửi bài đăng "Thị Trường Bất Động Sản Đầu Năm 2026: Nhịp Điều Chỉnh Và Cơ Hội Cho" để admin kiểm duyệt.', '/dashboard?page=duyet-tin-dang', false, NULL, '2026-03-31 14:53:53.788309+00', '2026-03-31 14:53:53.788309+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('c00317fd-10cd-4496-8dcd-9723646b61a8', '28eeca87-18d2-44af-afde-58f5ed6927c9', 'NEW_PROPERTY_SUBMISSION', 'Có bài đăng mới chờ duyệt', 'System Administrator vừa gửi bài đăng "Thuê Nhà Phố Euro Village Đà Nẵng 4 Phòng Ngủ Hiện Đại" để admin kiểm duyệt.', '/dashboard?page=duyet-tin-dang', false, NULL, '2026-03-31 15:20:17.458886+00', '2026-03-31 15:20:17.458886+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('b8fee3ee-741b-4d26-b608-d7b6b4fd6ee7', '28eeca87-18d2-44af-afde-58f5ed6927c9', 'NEW_PROPERTY_SUBMISSION', 'Có bài đăng mới chờ duyệt', 'bao bao vừa gửi bài đăng "sdfs s fsdf saddf" để admin kiểm duyệt.', '/dashboard?page=duyet-tin-dang', false, NULL, '2026-03-31 15:24:19.277382+00', '2026-03-31 15:24:19.277382+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('84870fc1-cf1c-44e4-a24d-930a4e35f4d0', '28eeca87-18d2-44af-afde-58f5ed6927c9', 'NEW_PROPERTY_SUBMISSION', 'Có bài đăng mới chờ duyệt', 'System Administrator vừa gửi bài đăng "Cho Thuê Chung Cư Panoma 2 Phòng Ngủ Hiện Đại" để admin kiểm duyệt.', '/dashboard?page=duyet-tin-dang', false, NULL, '2026-04-01 09:54:17.100661+00', '2026-04-01 09:54:17.100661+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('75c83fc3-47a0-44eb-8e45-6dbead78e597', '28eeca87-18d2-44af-afde-58f5ed6927c9', 'NEW_PROPERTY_SUBMISSION', 'Có bài đăng mới chờ duyệt', 'System Administrator vừa gửi bài đăng "Cho Thuê Biệt Thự One River Đà Nẵng Nội Thất Sang Trọng" để admin kiểm duyệt.', '/dashboard?page=duyet-tin-dang', false, NULL, '2026-04-01 10:14:35.789023+00', '2026-04-01 10:14:35.789023+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('a14b7fc4-eef7-435b-add2-0fbf4e8a31fa', '28eeca87-18d2-44af-afde-58f5ed6927c9', 'NEW_PROPERTY_SUBMISSION', 'Có bài đăng mới chờ duyệt', 'System Administrator vừa gửi bài đăng "Cho Thuê Biệt Thự Euro Village Danang 4 Phòng Ngủ Khép Kín" để admin kiểm duyệt.', '/dashboard?page=duyet-tin-dang', false, NULL, '2026-04-01 10:23:40.150659+00', '2026-04-01 10:23:40.150659+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('63d683a1-cbe8-4237-bc0e-074ec4c28f84', '28eeca87-18d2-44af-afde-58f5ed6927c9', 'NEW_PROPERTY_SUBMISSION', 'Có bài đăng mới chờ duyệt', 'Đỗ Khánh Linh vừa gửi bài đăng "Căn hộ 1PN full nội thất, giặt riêng, phòng rộng rãi, có ban công thoáng mát, gần biển, nhiều tiện ích" để admin kiểm duyệt.', '/dashboard?page=duyet-tin-dang', false, NULL, '2026-04-01 11:16:41.751313+00', '2026-04-01 11:16:41.751313+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('7ff065a8-b0a4-4b84-a693-39a5aabbed82', '28eeca87-18d2-44af-afde-58f5ed6927c9', 'NEW_PROPERTY_SUBMISSION', 'Có bài đăng mới chờ duyệt', 'bao bao vừa gửi bài đăng "Căn hộ 1PN full nội thất, giặt riêng, phòng rộng rãi, có ban công thoáng mát, gần biển, nhiều tiện ích" để admin kiểm duyệt.', '/dashboard?page=duyet-tin-dang', false, NULL, '2026-04-01 11:24:13.031279+00', '2026-04-01 11:24:13.031279+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('357bc70d-6472-4c8b-9cd5-507695ebab65', '28eeca87-18d2-44af-afde-58f5ed6927c9', 'NEW_PROPERTY_SUBMISSION', 'Có bài đăng mới chờ duyệt', 'bao bao vừa gửi bài đăng "Căn hộ 1PN full nội thất, giặt riêng, phòng rộng rãi, có ban công thoáng mát, gần biển, nhiều tiện ích -Vị trí: Hoàng Kế Viêm, Mỹ An -Giá 14tr" để admin kiểm duyệt.', '/dashboard?page=duyet-tin-dang', false, NULL, '2026-04-01 12:12:09.339329+00', '2026-04-01 12:12:09.339329+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('b953055c-b86a-4e0d-8c37-2f8b67bf446e', '28eeca87-18d2-44af-afde-58f5ed6927c9', 'PROPERTY_APPROVED', 'Tin đăng đã được duyệt', 'Bài đăng "Penhouse đẹp, full nội thất, giặt riêng, phòng rộng rãi, ban công lớn mát mẻ, view đẹp, ok pet ok" của bạn đã được admin duyệt thành công.', '/dashboard?page=tin-dang-cua-toi', false, NULL, '2026-04-01 12:12:46.972745+00', '2026-04-01 12:12:46.972745+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('65e0991f-105f-47f7-87a5-088e837345e5', '28eeca87-18d2-44af-afde-58f5ed6927c9', 'PROPERTY_REJECTED', 'Tin đăng bị từ chối', 'Bài đăng "Penhouse đẹp, full nội thất, giặt riêng, phòng rộng rãi, ban công lớn mát mẻ, view đẹp, ok pet ok" của bạn đã bị từ chối. Lý do: hình ảnh sai', '/dashboard?page=tin-dang-cua-toi', false, NULL, '2026-04-01 12:13:26.67638+00', '2026-04-01 12:13:26.67638+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('0579e2d8-cc6d-42f0-b820-700255edb911', '28eeca87-18d2-44af-afde-58f5ed6927c9', 'NEW_HOST_REGISTRATION', 'Có host mới đăng ký', 'Host Nguyễn Thị Lý vừa đăng ký tài khoản và đang chờ duyệt.', '/dashboard?page=quan-ly-host', false, NULL, '2026-04-01 13:51:38.124169+00', '2026-04-01 13:51:38.124169+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('307522cf-09b0-477f-bd39-139cc7c855fa', 'af82b3fe-b7d3-4342-a07f-1cdbc65233ee', 'PROPERTY_REJECTED', 'Tin đăng bị từ chối', 'Bài đăng "Thị Trường Bất Động Sản Đầu Năm 2026: Nhịp Điều Chỉnh Và Cơ Hội Cho" của bạn đã bị từ chối. Lý do: Thông tin chưa rõ ràng', '/dashboard?page=tin-dang-cua-toi', true, '2026-04-01 14:48:53.546122+00', '2026-04-01 10:24:28.036852+00', '2026-04-01 14:48:53.546762+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('23a9baf7-118f-447b-ae11-7c8f0f5e8207', '28eeca87-18d2-44af-afde-58f5ed6927c9', 'NEW_PROPERTY_SUBMISSION', 'Có bài đăng mới chờ duyệt', 'Lê Quang Hưng vừa gửi bài đăng "Thuê Nhà Riêng Đà Nẵng Gần Cầu Rồng 3 Phòng Ngủ Đẹp Có Gara Ô Tô" để admin kiểm duyệt.', '/dashboard?page=duyet-tin-dang', false, NULL, '2026-04-01 14:52:04.475445+00', '2026-04-01 14:52:04.475445+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('f373c242-685f-4f00-852f-6f52580dcd9c', '5d053abf-972f-466c-9ffc-24affd11062e', 'NEW_PROPERTY_SUBMISSION', 'Có bài đăng mới chờ duyệt', 'Lê Quang Hưng vừa gửi bài đăng "Thị Trường Bất Động Sản Đầu Năm 2026: Nhịp Điều Chỉnh Và Cơ Hội Cho" để admin kiểm duyệt.', '/dashboard?page=duyet-tin-dang', true, '2026-04-01 14:52:43.339789+00', '2026-03-31 14:53:53.788076+00', '2026-03-31 14:53:53.788076+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('8ae86d48-4898-4a23-b693-53e15271b3b2', '5d053abf-972f-466c-9ffc-24affd11062e', 'NEW_PROPERTY_SUBMISSION', 'Có bài đăng mới chờ duyệt', 'System Administrator vừa gửi bài đăng "Thuê Nhà Phố Euro Village Đà Nẵng 4 Phòng Ngủ Hiện Đại" để admin kiểm duyệt.', '/dashboard?page=duyet-tin-dang', true, '2026-04-01 14:52:43.339789+00', '2026-03-31 15:20:17.458636+00', '2026-03-31 15:20:17.458636+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('14a999ad-c4c9-445c-9c51-3d8d905fe1a4', '5d053abf-972f-466c-9ffc-24affd11062e', 'NEW_PROPERTY_SUBMISSION', 'Có bài đăng mới chờ duyệt', 'bao bao vừa gửi bài đăng "sdfs s fsdf saddf" để admin kiểm duyệt.', '/dashboard?page=duyet-tin-dang', true, '2026-04-01 14:52:43.339789+00', '2026-03-31 15:24:19.277155+00', '2026-03-31 15:24:19.277155+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('845b29c6-41f5-472a-b1db-09ae005b9112', '5d053abf-972f-466c-9ffc-24affd11062e', 'PROPERTY_APPROVED', 'Tin đăng đã được duyệt', 'Bài đăng "Thuê Nhà Phố Euro Village Đà Nẵng 4 Phòng Ngủ Hiện Đại" của bạn đã được admin duyệt thành công.', '/dashboard?page=tin-dang-cua-toi', true, '2026-04-01 14:52:43.339789+00', '2026-04-01 09:37:07.809613+00', '2026-04-01 09:37:07.809613+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('be1b68e2-6c42-435f-866b-7518a6c9a7d7', '5d053abf-972f-466c-9ffc-24affd11062e', 'NEW_PROPERTY_SUBMISSION', 'Có bài đăng mới chờ duyệt', 'System Administrator vừa gửi bài đăng "Cho Thuê Chung Cư Panoma 2 Phòng Ngủ Hiện Đại" để admin kiểm duyệt.', '/dashboard?page=duyet-tin-dang', true, '2026-04-01 14:52:43.339789+00', '2026-04-01 09:54:17.100817+00', '2026-04-01 09:54:17.100817+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('c3489b35-abe0-4f65-8663-f21ce7e5c412', '5d053abf-972f-466c-9ffc-24affd11062e', 'PROPERTY_APPROVED', 'Tin đăng đã được duyệt', 'Bài đăng "Cho Thuê Chung Cư Panoma 2 Phòng Ngủ Hiện Đại" của bạn đã được admin duyệt thành công.', '/dashboard?page=tin-dang-cua-toi', true, '2026-04-01 14:52:43.339789+00', '2026-04-01 10:10:51.815547+00', '2026-04-01 10:10:51.815547+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('8c39c719-fcda-4f9c-8f78-258c42cb3b25', '5d053abf-972f-466c-9ffc-24affd11062e', 'NEW_PROPERTY_SUBMISSION', 'Có bài đăng mới chờ duyệt', 'System Administrator vừa gửi bài đăng "Cho Thuê Biệt Thự One River Đà Nẵng Nội Thất Sang Trọng" để admin kiểm duyệt.', '/dashboard?page=duyet-tin-dang', true, '2026-04-01 14:52:43.339789+00', '2026-04-01 10:14:35.788736+00', '2026-04-01 10:14:35.788736+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('63751e7b-f096-4be4-8419-c9baba07ee2c', '5d053abf-972f-466c-9ffc-24affd11062e', 'PROPERTY_APPROVED', 'Tin đăng đã được duyệt', 'Bài đăng "Cho Thuê Biệt Thự One River Đà Nẵng Nội Thất Sang Trọng" của bạn đã được admin duyệt thành công.', '/dashboard?page=tin-dang-cua-toi', true, '2026-04-01 14:52:43.339789+00', '2026-04-01 10:16:15.326863+00', '2026-04-01 10:16:15.326863+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('12f1a3d5-0fb4-4603-937c-2a83eb4fa028', '5d053abf-972f-466c-9ffc-24affd11062e', 'NEW_PROPERTY_SUBMISSION', 'Có bài đăng mới chờ duyệt', 'System Administrator vừa gửi bài đăng "Cho Thuê Biệt Thự Euro Village Danang 4 Phòng Ngủ Khép Kín" để admin kiểm duyệt.', '/dashboard?page=duyet-tin-dang', true, '2026-04-01 14:52:43.339789+00', '2026-04-01 10:23:40.151082+00', '2026-04-01 10:23:40.151082+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('c5502619-7c7e-48dd-ad71-16989e83a56d', '5d053abf-972f-466c-9ffc-24affd11062e', 'PROPERTY_APPROVED', 'Tin đăng đã được duyệt', 'Bài đăng "Cho Thuê Chung Cư Panoma 2 Phòng Ngủ Hiện Đại" của bạn đã được admin duyệt thành công.', '/dashboard?page=tin-dang-cua-toi', true, '2026-04-01 14:52:43.339789+00', '2026-04-01 10:17:15.334713+00', '2026-04-01 10:17:15.334713+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('fa345fb0-84ff-4891-b743-a10fbe4dc5e1', '5d053abf-972f-466c-9ffc-24affd11062e', 'PROPERTY_APPROVED', 'Tin đăng đã được duyệt', 'Bài đăng "Cho Thuê Chung Cư Panoma 2 Phòng Ngủ Hiện Đại" của bạn đã được admin duyệt thành công.', '/dashboard?page=tin-dang-cua-toi', true, '2026-04-01 14:52:43.339789+00', '2026-04-01 10:17:23.923827+00', '2026-04-01 10:17:23.923827+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('9df5bcd5-c3af-4a24-a5b3-1b8882071352', '5d053abf-972f-466c-9ffc-24affd11062e', 'PROPERTY_APPROVED', 'Tin đăng đã được duyệt', 'Bài đăng "Cho Thuê Biệt Thự Euro Village Danang 4 Phòng Ngủ Khép Kín" của bạn đã được admin duyệt thành công.', '/dashboard?page=tin-dang-cua-toi', true, '2026-04-01 14:52:43.339789+00', '2026-04-01 10:24:34.035413+00', '2026-04-01 10:24:34.035413+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('b51e9ff9-e82f-4951-9c4b-6b021f8f7653', '5d053abf-972f-466c-9ffc-24affd11062e', 'NEW_PROPERTY_SUBMISSION', 'Có bài đăng mới chờ duyệt', 'Đỗ Khánh Linh vừa gửi bài đăng "Căn hộ 1PN full nội thất, giặt riêng, phòng rộng rãi, có ban công thoáng mát, gần biển, nhiều tiện ích" để admin kiểm duyệt.', '/dashboard?page=duyet-tin-dang', true, '2026-04-01 14:52:43.339789+00', '2026-04-01 11:16:41.750673+00', '2026-04-01 11:16:41.750673+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('7e3ecb81-35e7-4821-8765-261d9de88ac9', '5d053abf-972f-466c-9ffc-24affd11062e', 'NEW_PROPERTY_SUBMISSION', 'Có bài đăng mới chờ duyệt', 'bao bao vừa gửi bài đăng "Căn hộ 1PN full nội thất, giặt riêng, phòng rộng rãi, có ban công thoáng mát, gần biển, nhiều tiện ích" để admin kiểm duyệt.', '/dashboard?page=duyet-tin-dang', true, '2026-04-01 14:52:43.339789+00', '2026-04-01 11:24:13.031061+00', '2026-04-01 11:24:13.031061+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('24af8fdd-9099-4e68-9aeb-e76a2eeea8e1', '5d053abf-972f-466c-9ffc-24affd11062e', 'NEW_PROPERTY_SUBMISSION', 'Có bài đăng mới chờ duyệt', 'bao bao vừa gửi bài đăng "Căn hộ 1PN full nội thất, giặt riêng, phòng rộng rãi, có ban công thoáng mát, gần biển, nhiều tiện ích -Vị trí: Hoàng Kế Viêm, Mỹ An -Giá 14tr" để admin kiểm duyệt.', '/dashboard?page=duyet-tin-dang', true, '2026-04-01 14:52:43.339789+00', '2026-04-01 12:12:09.339077+00', '2026-04-01 12:12:09.339077+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('cdb1a532-c59a-4ba5-a726-44cd53f25de5', '5d053abf-972f-466c-9ffc-24affd11062e', 'NEW_HOST_REGISTRATION', 'Có host mới đăng ký', 'Host Nguyễn Thị Lý vừa đăng ký tài khoản và đang chờ duyệt.', '/dashboard?page=quan-ly-host', true, '2026-04-01 14:52:43.339789+00', '2026-04-01 13:51:38.123757+00', '2026-04-01 13:51:38.123757+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('89d1f4ae-fa80-46d0-88b8-a457f45b9fba', '5d053abf-972f-466c-9ffc-24affd11062e', 'NEW_PROPERTY_SUBMISSION', 'Có bài đăng mới chờ duyệt', 'Lê Quang Hưng vừa gửi bài đăng "Thuê Nhà Riêng Đà Nẵng Gần Cầu Rồng 3 Phòng Ngủ Đẹp Có Gara Ô Tô" để admin kiểm duyệt.', '/dashboard?page=duyet-tin-dang', true, '2026-04-01 14:52:43.339789+00', '2026-04-01 14:52:04.475272+00', '2026-04-01 14:52:04.475272+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('9c5028d5-0ea2-4d32-a0f4-f4d93040d63c', '28eeca87-18d2-44af-afde-58f5ed6927c9', 'PROPERTY_REJECTED', 'Tin đăng bị từ chối', 'Bài đăng "sdfs s fsdf saddf" của bạn đã bị từ chối. Lý do: Chưa đủ thông tin mô tả ', '/dashboard?page=tin-dang-cua-toi', false, NULL, '2026-04-01 14:53:14.678757+00', '2026-04-01 14:53:14.678757+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('93e5defb-ef27-4515-b056-f348eabcab47', 'af82b3fe-b7d3-4342-a07f-1cdbc65233ee', 'PROPERTY_APPROVED', 'Tin đăng đã được duyệt', 'Bài đăng "Thuê Nhà Riêng Đà Nẵng Gần Cầu Rồng 3 Phòng Ngủ Đẹp Có Gara Ô Tô" của bạn đã được admin duyệt thành công.', '/dashboard?page=tin-dang-cua-toi', true, '2026-04-01 14:54:09.695062+00', '2026-04-01 14:53:41.312608+00', '2026-04-01 14:54:09.695546+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('9aaaade3-040d-4217-a1e4-4f4509c06f74', '5d053abf-972f-466c-9ffc-24affd11062e', 'NEW_PROPERTY_SUBMISSION', 'Có bài đăng mới chờ duyệt', 'bao bao vừa gửi bài đăng "Cho Thuê Căn Hộ Cao Cấp 4 Phòng Ngủ Tại Trung Tâm Thành Phố" để admin kiểm duyệt.', '/dashboard?page=duyet-tin-dang', false, NULL, '2026-04-02 01:48:58.726432+00', '2026-04-02 01:48:58.726432+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('bfd61049-7cf0-4f37-9507-de85ea3baad0', '28eeca87-18d2-44af-afde-58f5ed6927c9', 'NEW_PROPERTY_SUBMISSION', 'Có bài đăng mới chờ duyệt', 'bao bao vừa gửi bài đăng "Cho Thuê Căn Hộ Cao Cấp 4 Phòng Ngủ Tại Trung Tâm Thành Phố" để admin kiểm duyệt.', '/dashboard?page=duyet-tin-dang', false, NULL, '2026-04-02 01:48:58.726706+00', '2026-04-02 01:48:58.726706+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('2388c1c9-68e5-4a09-a522-5949113af4a9', '28eeca87-18d2-44af-afde-58f5ed6927c9', 'NEW_PROPERTY_SUBMISSION', 'Có bài đăng mới chờ duyệt', 'bao bao vừa gửi bài đăng "Căn hộ 1PN gần biển Mỹ Khê, full nội thất, giặt riêng, phòng rộng rãi, có ban công thoáng mát, khu yên tĩnh, 6/4 trống sẵn" để admin kiểm duyệt.', '/dashboard?page=duyet-tin-dang', false, NULL, '2026-04-02 02:02:32.187129+00', '2026-04-02 02:02:32.187129+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('1447d606-e875-48d7-8c7f-07447c95ed8a', '5d053abf-972f-466c-9ffc-24affd11062e', 'NEW_PROPERTY_SUBMISSION', 'Có bài đăng mới chờ duyệt', 'bao bao vừa gửi bài đăng "Căn hộ 1PN gần biển Mỹ Khê, full nội thất, giặt riêng, phòng rộng rãi, có ban công thoáng mát, khu yên tĩnh, 6/4 trống sẵn" để admin kiểm duyệt.', '/dashboard?page=duyet-tin-dang', false, NULL, '2026-04-02 02:02:32.187273+00', '2026-04-02 02:02:32.187273+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('ea769d8a-2f6f-45c1-8990-4c68d9db0746', '28eeca87-18d2-44af-afde-58f5ed6927c9', 'NEW_PROPERTY_SUBMISSION', 'Có bài đăng mới chờ duyệt', 'bao bao vừa gửi bài đăng "Cho Thuê Căn Hộ Sam Tower Đà Nẵng 2 Phòng Ngủ Giá Tốt" để admin kiểm duyệt.', '/dashboard?page=duyet-tin-dang', false, NULL, '2026-04-02 02:06:34.781861+00', '2026-04-02 02:06:34.781861+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('a1865286-29ef-4c42-b992-16112fe65f7c', '5d053abf-972f-466c-9ffc-24affd11062e', 'NEW_PROPERTY_SUBMISSION', 'Có bài đăng mới chờ duyệt', 'bao bao vừa gửi bài đăng "Cho Thuê Căn Hộ Sam Tower Đà Nẵng 2 Phòng Ngủ Giá Tốt" để admin kiểm duyệt.', '/dashboard?page=duyet-tin-dang', false, NULL, '2026-04-02 02:06:34.782048+00', '2026-04-02 02:06:34.782048+00');
INSERT INTO public.notifications (id, recipient_id, type, title, message, link, is_read, read_at, created_at, updated_at) VALUES ('ff710e39-3395-431e-a68a-4c819da04dbd', '28eeca87-18d2-44af-afde-58f5ed6927c9', 'PROPERTY_APPROVED', 'Tin đăng đã được duyệt', 'Bài đăng "Cho Thuê Căn Hộ Sam Tower Đà Nẵng 2 Phòng Ngủ Giá Tốt" của bạn đã được admin duyệt thành công.', '/dashboard?page=tin-dang-cua-toi', false, NULL, '2026-04-02 02:29:22.382719+00', '2026-04-02 02:29:22.382719+00');


--
-- TOC entry 4683 (class 0 OID 34444)
-- Dependencies: 233
-- Data for Name: password_reset_tokens; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.password_reset_tokens (id, user_id, email_snapshot, otp_hash, reset_token_hash, expires_at, verified_at, consumed_at, attempt_count, created_at, updated_at) VALUES ('712b004e-aac0-42b4-9cea-62429e3eeeba', 'af82b3fe-b7d3-4342-a07f-1cdbc65233ee', 'aki23092005@gmail.com', '$2a$12$o3w2N8eyfVUEtp8gEd9wUedMiVp0WC58mm2G2scM1bfJ2Wdnsdxia', '$2a$12$NW7I4Hi20JkVJ7d8URQ3aO7OyYxB32ep1NeBJD.Qcx6cq0dj43zbi', '2026-03-23 17:24:39.151064+00', '2026-03-23 17:09:39.151064+00', '2026-03-23 17:10:05.444034+00', 0, '2026-03-23 17:08:58.640017+00', '2026-03-23 17:10:06.238915+00');
INSERT INTO public.password_reset_tokens (id, user_id, email_snapshot, otp_hash, reset_token_hash, expires_at, verified_at, consumed_at, attempt_count, created_at, updated_at) VALUES ('e43ac63b-61bc-4b41-a8ed-9d453fe561c8', 'af82b3fe-b7d3-4342-a07f-1cdbc65233ee', 'aki23092005@gmail.com', '$2a$12$sEUVYEtWHvKXg9t/LpWT/uejaIqLfgoZZ5IkbpTFwEScTWocxchfi', '$2a$12$fqYUNZ7wH7RlGFGlXLqZNeUX9go4bHSi96aZj2WYElvQgk36v41MO', '2026-03-25 04:01:57.713277+00', '2026-03-25 03:46:57.713277+00', '2026-03-25 03:47:25.635678+00', 0, '2026-03-25 03:46:15.232348+00', '2026-03-25 03:47:26.692497+00');
INSERT INTO public.password_reset_tokens (id, user_id, email_snapshot, otp_hash, reset_token_hash, expires_at, verified_at, consumed_at, attempt_count, created_at, updated_at) VALUES ('7e18b48b-bad6-40cf-ba25-0cc9509a3457', 'af82b3fe-b7d3-4342-a07f-1cdbc65233ee', 'aki23092005@gmail.com', '$2a$12$sEdxDnbqABwh2Vt.J9tdR.ItWz09jC/17ML7RQHNF9V0o9yAbKFz.', '$2a$12$4C15VmNKSXTsHqrInp45EeWRLQVM76oG8.293ZzaaJiGW66i4jfAG', '2026-03-26 09:07:11.554213+00', '2026-03-26 08:52:11.554213+00', '2026-03-26 08:52:32.187841+00', 0, '2026-03-26 08:51:26.266097+00', '2026-03-26 08:52:32.920808+00');
INSERT INTO public.password_reset_tokens (id, user_id, email_snapshot, otp_hash, reset_token_hash, expires_at, verified_at, consumed_at, attempt_count, created_at, updated_at) VALUES ('9bffd001-1249-415d-aed0-35b230cc5b4d', '0e82682f-af39-4947-b07f-72952c92976c', 'naveren772@jsncos.com', '$2a$12$WfHhkLLFx01zsQ3DQnwQ/ONLEaU.3EzlXFUWe0Y5gW/IrOe.rPIC6', NULL, '2026-03-29 07:32:49.521779+00', NULL, '2026-03-29 07:24:11.346306+00', 0, '2026-03-29 07:22:49.882781+00', '2026-03-29 07:22:49.882781+00');
INSERT INTO public.password_reset_tokens (id, user_id, email_snapshot, otp_hash, reset_token_hash, expires_at, verified_at, consumed_at, attempt_count, created_at, updated_at) VALUES ('4df23275-038e-475c-b80c-c83a0e19b85d', '0e82682f-af39-4947-b07f-72952c92976c', 'naveren772@jsncos.com', '$2a$12$jG/T1OsFZ/gsYnI.nGVbZe0FNFxBmreoohEDkBtuL/L3pxfTED.RK', '$2a$12$Hntc05o6iJ8QWGb4Q5J.5Oek6a25eAeAzQSF9TOUusew2x8NOTQvm', '2026-03-29 07:40:00.337848+00', '2026-03-29 07:25:00.337848+00', '2026-03-29 07:25:13.962942+00', 0, '2026-03-29 07:24:11.694508+00', '2026-03-29 07:25:14.649777+00');
INSERT INTO public.password_reset_tokens (id, user_id, email_snapshot, otp_hash, reset_token_hash, expires_at, verified_at, consumed_at, attempt_count, created_at, updated_at) VALUES ('f035fc95-4eb0-4ff4-848c-2e5dcb7363d9', 'fe59b795-b12b-4db6-9249-8fe3b3d33054', 'vayow82347@flownue.com', '$2a$12$MnTw7vWoDIx8bvYAEjm.8.ZCpOA/.PAUiGQodQ.s0zziO0jMJ3NHK', '$2a$12$z2gXH/P8oPHB7dSUcC2EHO4Ks9amXkP4uQKsiaOt7SGndhXKKy2VC', '2026-04-01 14:14:21.461746+00', '2026-04-01 13:59:21.461746+00', '2026-04-01 13:59:35.909383+00', 0, '2026-04-01 13:58:53.04133+00', '2026-04-01 13:59:36.545626+00');


--
-- TOC entry 4678 (class 0 OID 34364)
-- Dependencies: 228
-- Data for Name: permissions; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.permissions (id, code, name) VALUES (1, 'property.read_public', 'Read approved public properties');
INSERT INTO public.permissions (id, code, name) VALUES (2, 'search.basic', 'Basic property search');
INSERT INTO public.permissions (id, code, name) VALUES (3, 'search.ai', 'AI-assisted search');
INSERT INTO public.permissions (id, code, name) VALUES (4, 'property.create_own', 'Create own property');
INSERT INTO public.permissions (id, code, name) VALUES (5, 'property.update_own', 'Update own property');
INSERT INTO public.permissions (id, code, name) VALUES (6, 'property.hide_own', 'Hide own property');
INSERT INTO public.permissions (id, code, name) VALUES (7, 'property.read_own', 'Read own properties');
INSERT INTO public.permissions (id, code, name) VALUES (8, 'property.approve', 'Approve property');
INSERT INTO public.permissions (id, code, name) VALUES (9, 'property.reject', 'Reject property');
INSERT INTO public.permissions (id, code, name) VALUES (10, 'host.create', 'Create host account');
INSERT INTO public.permissions (id, code, name) VALUES (11, 'host.lock', 'Lock host account');
INSERT INTO public.permissions (id, code, name) VALUES (12, 'host.unlock', 'Unlock host account');
INSERT INTO public.permissions (id, code, name) VALUES (13, 'host.read_all', 'View all hosts');


--
-- TOC entry 4673 (class 0 OID 34302)
-- Dependencies: 223
-- Data for Name: properties; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.properties (id, host_id, area_id, room_type_id, title, description, address_line, monthly_price, area_m2, bedrooms, allow_pets, status, approved_by, approved_at, rejected_reason, created_at, updated_at, deleted_at) VALUES ('b5bd261b-cbbd-40c9-8c79-c9b0b1a64f3f', '5d053abf-972f-466c-9ffc-24affd11062e', 24, 3, 'Thuê Nhà Phố Euro Village Đà Nẵng 4 Phòng Ngủ Hiện Đại', 'Cho thuê nhà phố Euro Village
Thuê nhà phố Euro Village Đà Nẵng, khu đô thị cao cấp ven sông Hàn, môi trường sống an ninh, yên tĩnh, cộng đồng dân cư văn minh, nhiều người nước ngoài sinh sống.

Diện tích: 100m²
Công năng: 4 phòng ngủ, 4 phòng vệ sinh
Nội thất: Full nội thất hiện đại, cao cấp, dọn vào ở ngay
Thiết kế: Nhà phố rộng rãi, thoáng, nhiều ánh sáng tự nhiên
Sân trước: Có sân trước rộng, tiện để xe và trồng cây
✨ Vị trí trung tâm Euro Village, gần sông Hàn, cầu Trần Thị Lý, dễ dàng di chuyển đến biển Mỹ Khê, trung tâm thành phố và các tiện ích xung quanh
✨ Thích hợp thuê ở lâu dài, hoặc cho chuyên gia nước ngoài sinh sống
✨ Khu dân cư an ninh, không gian sống xanh, yên tĩnh

💰 Giá thuê: 35 triệu/tháng', 'An Hải, An Hải Tây, Sơn Trà, Đà Nẵng 550000, Việt Nam', 35000000.00, 99.00, 4, true, 'APPROVED', '5d053abf-972f-466c-9ffc-24affd11062e', '2026-04-01 09:37:07.807304+00', NULL, '2026-03-31 15:20:17.43155+00', '2026-04-01 09:37:07.817639+00', NULL);
INSERT INTO public.properties (id, host_id, area_id, room_type_id, title, description, address_line, monthly_price, area_m2, bedrooms, allow_pets, status, approved_by, approved_at, rejected_reason, created_at, updated_at, deleted_at) VALUES ('0a45c75e-6742-4774-be9d-c8c3f49350a6', '28eeca87-18d2-44af-afde-58f5ed6927c9', 24, 1, 'Căn studio full nội thất, có hồ bơi, sảnh cafe, phòng rộng rãi, sạch đẹp, cửa kính lớn view thoáng, 5/4 trống', 'Căn studio full nội thất, có hồ bơi, sảnh cafe, phòng rộng rãi, sạch đẹp, cửa kính lớn view thoáng, 5/4 trống 
-Vị trí: Lê Mạnh Trinh, Sơn Trà
-Giá 12tr
', 'Lê Mạnh Trinh, Sơn Trà', 12000000.00, 70.00, 1, false, 'APPROVED', '28eeca87-18d2-44af-afde-58f5ed6927c9', '2026-03-27 02:13:59.249372+00', NULL, '2026-03-27 02:12:00.214416+00', '2026-03-27 02:13:59.317739+00', NULL);
INSERT INTO public.properties (id, host_id, area_id, room_type_id, title, description, address_line, monthly_price, area_m2, bedrooms, allow_pets, status, approved_by, approved_at, rejected_reason, created_at, updated_at, deleted_at) VALUES ('01a84411-d474-41f7-b4e4-575d14275f04', '28eeca87-18d2-44af-afde-58f5ed6927c9', 24, 1, '🏡 5/4 Trống sẵn căn 1PN đẹp gần cầu Hàn - Sơn Trà ', '🏡 5/4 Trống sẵn căn 1PN đẹp gần cầu Hàn - Sơn Trà 
👉 Đầy đủ nội thất, thang máy, pet nhỏ (300k), phòng tầng cao sạch đẹp, full cửa kính siêu thoáng, khuôn viên lớn
--------------
💵 Giá 9,5tr
📍Địa chỉ: Ngô Quyền, Sơn Trà', 'Ngô Quyền, Sơn Trà', 9500000.00, 70.00, 1, true, 'APPROVED', '28eeca87-18d2-44af-afde-58f5ed6927c9', '2026-03-27 02:14:00.965521+00', NULL, '2026-03-27 02:12:57.056415+00', '2026-03-27 02:14:01.034042+00', NULL);
INSERT INTO public.properties (id, host_id, area_id, room_type_id, title, description, address_line, monthly_price, area_m2, bedrooms, allow_pets, status, approved_by, approved_at, rejected_reason, created_at, updated_at, deleted_at) VALUES ('4f3aa900-7e7e-4995-8d1b-b8330b8c0340', '28eeca87-18d2-44af-afde-58f5ed6927c9', 31, 1, 'Căn hộ 1PN gần biển Mỹ Khê, full nội thất, máy giặt riêng, phòng tầng cao rộng rãi, có cửa sổ và ban công view  thoáng, ok pet, 10/4 có phòng', 'Căn hộ 1PN gần biển Mỹ Khê, full nội thất, máy giặt riêng, phòng tầng cao rộng rãi, có cửa sổ và ban công view  thoáng, ok pet, 10/4 có phòng
-Vị trí: Dương Tụ Quán, Mỹ An
-Giá 14,9tr', 'Dương Tụ Quán, Mỹ An', 14900000.00, 70.00, 1, true, 'APPROVED', '28eeca87-18d2-44af-afde-58f5ed6927c9', '2026-03-27 02:14:02.787704+00', NULL, '2026-03-27 02:13:49.685303+00', '2026-03-27 02:14:02.855383+00', NULL);
INSERT INTO public.properties (id, host_id, area_id, room_type_id, title, description, address_line, monthly_price, area_m2, bedrooms, allow_pets, status, approved_by, approved_at, rejected_reason, created_at, updated_at, deleted_at) VALUES ('b2a343a0-5910-4d57-8374-02692a70c955', '5f0c2f5f-00e3-4f89-a5ac-b2c39ede0104', 31, 1, 'Căn hộ 1PN full nội thất, giặt riêng, phòng rộng rãi, có ban công thoáng mát, gần biển, nhiều tiện ích', 'Căn hộ 1PN full nội thất, giặt riêng, phòng rộng rãi, có ban công thoáng mát, gần biển, nhiều tiện ích
-Vị trí: Hoàng Kế Viêm, Mỹ An
-Giá 14tr', 'Hoàng Kế Viêm, Mỹ An', 14000000.00, 54.00, 1, false, 'PENDING', NULL, NULL, NULL, '2026-04-01 11:16:41.744725+00', '2026-04-01 11:16:41.744725+00', NULL);
INSERT INTO public.properties (id, host_id, area_id, room_type_id, title, description, address_line, monthly_price, area_m2, bedrooms, allow_pets, status, approved_by, approved_at, rejected_reason, created_at, updated_at, deleted_at) VALUES ('bec2b2be-856b-41cd-8256-073417b3203a', '28eeca87-18d2-44af-afde-58f5ed6927c9', 25, 1, 'Căn hộ 2PN đẹp, full nội thất, giặt riêng, phòng rộng rãi, có ban công thoáng', 'Căn hộ 2PN đẹp, full nội thất, giặt riêng, phòng rộng rãi, có ban công thoáng
-Vị trí: Khuê Mỹ Đông 12, Khuê Mỹ
-Giá 18tr', 'Khuê Mỹ Đông 12, Khuê Mỹ', 18000000.00, 45.00, 2, false, 'APPROVED', '28eeca87-18d2-44af-afde-58f5ed6927c9', '2026-03-27 07:38:14.101283+00', NULL, '2026-03-27 07:38:00.585528+00', '2026-03-27 07:38:14.348558+00', NULL);
INSERT INTO public.properties (id, host_id, area_id, room_type_id, title, description, address_line, monthly_price, area_m2, bedrooms, allow_pets, status, approved_by, approved_at, rejected_reason, created_at, updated_at, deleted_at) VALUES ('2086fead-4f58-4d75-80fb-e6ac7c8c5ce6', '28eeca87-18d2-44af-afde-58f5ed6927c9', 24, 1, 'Penhouse đẹp, full nội thất, giặt riêng, phòng rộng rãi, ban công lớn mát mẻ, view đẹp, ok pet ok', 'Penhouse đẹp, full nội thất, giặt riêng, phòng rộng rãi, ban công lớn mát mẻ, view đẹp, ok pet
-Vị trí: An Đồn 5, Sơn Trà
-Giá 13tr', 'An Đồn 5, Sơn Trà', 13000000.00, 70.00, 1, true, 'REJECTED', '28eeca87-18d2-44af-afde-58f5ed6927c9', '2026-03-27 02:13:57.286725+00', 'hình ảnh sai', '2026-03-27 02:10:53.82931+00', '2026-04-01 12:13:26.681819+00', NULL);
INSERT INTO public.properties (id, host_id, area_id, room_type_id, title, description, address_line, monthly_price, area_m2, bedrooms, allow_pets, status, approved_by, approved_at, rejected_reason, created_at, updated_at, deleted_at) VALUES ('6ed3ebf1-c2d0-435f-995f-914ba73fcd6b', 'd0740f8c-5c94-403d-827c-6ab31b04ec49', 24, 1, 'Dự Án Azura Đà Nẵng Căn Hộ 1 Phòng Ngủ Nội Thất Sang Trọng Cho Thuê', 'Cho thuê căn hộ ở dự án Azura Đà Nẵng
Dự án Azura Đà Nẵng là dự án căn hộ cao cấp số 1 tại Đà Nẵng. Toạ lại số 339 Trần Hưng Đạo, quận Sơn Trà, thành phố Đà Nẵng.

 ✍️Diện tích 65m2

✍️Gồm có 1 phòng khách, 1 phòng bếp, 1 phòng ngủ, 1 phòng vệ sinh, ban công

✍️Nội thất đầy đủ, đẹp, hiện đại, màu sắc tinh tế, sang trọng

Căn hộ Azura với tiện ích cao cấp như hồ bơi rộng, phòng gym hiện đại, an ninh 24/7, tầng hầm đậu xe…

Vị trí đẹp, bên cạnh sông Hàn, cách biển Phạm Văn Đồng 1km, xung quanh có nhiều tiện ích, thuận tiện sinh sống

Giá thuê: 27 triệu/tháng', '339 Đ. Trần Hưng Đạo, An Hải Bắc, Sơn Trà, Đà Nẵng 550000, Việt Nam', 25000000.00, 65.00, 1, true, 'HIDDEN', '5d053abf-972f-466c-9ffc-24affd11062e', '2026-03-29 07:44:40.279179+00', NULL, '2026-03-29 07:44:06.69833+00', '2026-03-29 07:44:40.297508+00', NULL);
INSERT INTO public.properties (id, host_id, area_id, room_type_id, title, description, address_line, monthly_price, area_m2, bedrooms, allow_pets, status, approved_by, approved_at, rejected_reason, created_at, updated_at, deleted_at) VALUES ('e7d919f5-eb4f-449f-8d0a-5c9a46b584f1', '28eeca87-18d2-44af-afde-58f5ed6927c9', 31, 1, 'Căn hộ 1PN gần biển Mỹ Khê, full nội thất, giặt riêng, phòng rộng rãi, có ban công thoáng mát, khu yên tĩnh, 6/4 trống sẵn', 'Căn hộ 1PN gần biển Mỹ Khê, full nội thất, giặt riêng, phòng rộng rãi, có ban công thoáng mát, khu yên tĩnh, 6/4 trống sẵn
-Vị trí: Dương Tụ Quán, Mỹ An
-Giá 13,9tr', 'Dương Tụ Quán, Mỹ An', 13900000.00, 55.00, 1, false, 'PENDING', NULL, NULL, NULL, '2026-04-02 02:02:32.18115+00', '2026-04-02 02:02:32.18115+00', NULL);
INSERT INTO public.properties (id, host_id, area_id, room_type_id, title, description, address_line, monthly_price, area_m2, bedrooms, allow_pets, status, approved_by, approved_at, rejected_reason, created_at, updated_at, deleted_at) VALUES ('a569e2b1-cd7f-4b25-999c-aecb20dc192b', '8508dcf4-5077-4f8a-9bff-52a08f472dcf', 27, 3, 'Thuê Nhà Dài Hạn Đà Nẵng 3 Phòng Ngủ Đẹp Khu Nam Hòa Xuân', 'Cho thuê nhà dài hạn Đà Nẵng
Thuê nhà dài hạn Đà Nẵng – nhà khu Nam Hòa Xuân, Đà Nẵng – không gian sống xanh, hiện đại, đầy đủ tiện nghi:

Nhà cho thuê Nam Hòa Xuân với diện tích 105m², thiết kế 3 tầng thông thoáng, tối ưu ánh sáng tự nhiên và gió trời. Công năng gồm 3 phòng ngủ rộng rãi, 4 phòng vệ sinh (có bồn tắm), phù hợp cho gia đình ở lâu dài hoặc chuyên gia nước ngoài sinh sống.

Ngôi nhà nổi bật với ban công rộng, sân trước, sân sau thoáng mát, đặc biệt có hồ cá koi tạo điểm nhấn phong thủy và thư giãn. Không gian sống gần gũi thiên nhiên với nhiều cây xanh bố trí trong nhà, mang lại cảm giác dễ chịu, trong lành.

Trang bị nội thất đầy đủ, cao cấp: 3 tivi, tủ lạnh side by side 2 cánh lớn, máy lọc nước uống, cùng các tiện nghi sinh hoạt hiện đại khác, sẵn sàng vào ở ngay.

💰 Giá thuê: 25 triệu/tháng', 'Hòa Xuân, Cẩm Lệ, Đà Nẵng, Việt Nam', 25000000.00, 150.00, 3, true, 'DELETED', '5d053abf-972f-466c-9ffc-24affd11062e', '2026-03-29 04:05:29.529729+00', NULL, '2026-03-29 03:51:40.744853+00', '2026-03-29 07:46:01.28965+00', NULL);
INSERT INTO public.properties (id, host_id, area_id, room_type_id, title, description, address_line, monthly_price, area_m2, bedrooms, allow_pets, status, approved_by, approved_at, rejected_reason, created_at, updated_at, deleted_at) VALUES ('f4b6423a-7b6e-4dba-bb7d-15bab56f3cc9', '28eeca87-18d2-44af-afde-58f5ed6927c9', 24, 1, 'Căn hộ 1PN mới, full nội thất, giặt riêng, phòng sạch đẹp, có cửa sổ thoáng, khu yên tĩnh', 'Căn hộ 1PN mới, full nội thất, giặt riêng, phòng sạch đẹp, có cửa sổ thoáng, khu yên tĩnh', 'Cao Bá Quát, Sơn Trà', 15000000.00, 70.00, 1, false, 'APPROVED', '28eeca87-18d2-44af-afde-58f5ed6927c9', '2026-03-27 02:14:05.748837+00', NULL, '2026-03-27 02:03:05.010318+00', '2026-03-27 02:14:05.816447+00', NULL);
INSERT INTO public.properties (id, host_id, area_id, room_type_id, title, description, address_line, monthly_price, area_m2, bedrooms, allow_pets, status, approved_by, approved_at, rejected_reason, created_at, updated_at, deleted_at) VALUES ('0f3d71ec-8c9c-40d0-82f5-4598271aab72', '5d053abf-972f-466c-9ffc-24affd11062e', 25, 1, 'Cho Thuê Biệt Thự One River Đà Nẵng Nội Thất Sang Trọng', 'Cho thuê biệt thự One River Đà Nẵng
Cho thuê biệt thự One River Đà Nẵng, tọa lạc trong khu đô thị sinh thái cao cấp, không gian sống riêng tư, yên tĩnh và an ninh tuyệt đối, phù hợp gia đình thượng lưu, chuyên gia cao cấp, người nước ngoài sinh sống lâu dài.

📐 Diện tích: 300m²
🏠 Kết cấu: 3 tầng
🛏 Thiết kế: 4 phòng ngủ khép kín
🚿 5 phòng vệ sinh, bố trí khoa học, tiện nghi

✨ Nội thất & tiện nghi:

Full nội thất sang trọng, thiết kế hiện đại
Phòng khách lớn, trần cao, không gian mở
Phòng ngủ rộng, ánh sáng tự nhiên, riêng tư
Nhà mới, hoàn thiện cao cấp, vào ở ngay
Có hồ bơi rộng và thang máy
🌿 Ưu điểm khu One River:

Khu đô thị cao cấp ven sông
An ninh 24/7, cộng đồng cư dân văn minh
Không gian xanh, yên tĩnh, riêng tư
Kết nối nhanh trung tâm thành phố
💰 Giá thuê: 125 triệu/tháng', 'Icity One River, 23 Đ. Song Hào, Hoà Hải, Ngũ Hành Sơn, Đà Nẵng 550000, Việt Nam', 125000000.00, 300.00, 4, true, 'APPROVED', '5d053abf-972f-466c-9ffc-24affd11062e', '2026-04-01 10:16:15.325904+00', NULL, '2026-04-01 10:14:35.77493+00', '2026-04-01 10:16:15.333727+00', NULL);
INSERT INTO public.properties (id, host_id, area_id, room_type_id, title, description, address_line, monthly_price, area_m2, bedrooms, allow_pets, status, approved_by, approved_at, rejected_reason, created_at, updated_at, deleted_at) VALUES ('81314a11-ad2e-411f-bb7a-8864217c5c8b', '28eeca87-18d2-44af-afde-58f5ed6927c9', 31, 2, '🌇Sun - Panoma - Căn 2PN - 2WC tuyệt đẹp', '🌇Sun - Panoma - Căn 2PN - 2WC tuyệt đẹp

✅ Tầng cao view biển 
✅ Đầy đủ nội thất, giặt sấy
✅ Hợp đồng 1 năm, cọc 1 tt3
💵 Giá 32tr', '🌇Sun - Panoma - Căn 2PN - 2WC tuyệt đẹp', 32000000.00, 60.00, 0, false, 'APPROVED', '28eeca87-18d2-44af-afde-58f5ed6927c9', '2026-03-27 07:38:18.017582+00', NULL, '2026-03-27 07:30:48.487098+00', '2026-03-27 07:38:18.255964+00', NULL);
INSERT INTO public.properties (id, host_id, area_id, room_type_id, title, description, address_line, monthly_price, area_m2, bedrooms, allow_pets, status, approved_by, approved_at, rejected_reason, created_at, updated_at, deleted_at) VALUES ('53def4cc-2d5f-41ca-9dbd-2b3af7fd5f29', '28eeca87-18d2-44af-afde-58f5ed6927c9', 31, 1, 'Căn hộ 1PN full nội thất, giặt riêng, phòng rộng rãi, có ban công thoáng mát, gần biển, nhiều tiện ích', 'Căn hộ 1PN full nội thất, giặt riêng, phòng rộng rãi, có ban công thoáng mát, gần biển, nhiều tiện ích
-Vị trí: Hoàng Kế Viêm, Mỹ An
-Giá 14tr', 'Hoàng Kế Viêm, Mỹ An', 14000000.00, 55.00, 1, false, 'PENDING', NULL, NULL, NULL, '2026-04-01 11:24:13.024764+00', '2026-04-01 11:24:13.024764+00', NULL);
INSERT INTO public.properties (id, host_id, area_id, room_type_id, title, description, address_line, monthly_price, area_m2, bedrooms, allow_pets, status, approved_by, approved_at, rejected_reason, created_at, updated_at, deleted_at) VALUES ('07c18775-420c-4c22-a2d6-194d15375ffe', '28eeca87-18d2-44af-afde-58f5ed6927c9', 11, 1, 'sdfs s fsdf saddf', ' sf g dfsgdf gsdfg fdsg', 'á sdf ds fsd s', 30000.00, 22.00, 1, false, 'REJECTED', NULL, NULL, 'Chưa đủ thông tin mô tả ', '2026-03-31 15:24:19.270728+00', '2026-04-01 14:53:14.685505+00', NULL);
INSERT INTO public.properties (id, host_id, area_id, room_type_id, title, description, address_line, monthly_price, area_m2, bedrooms, allow_pets, status, approved_by, approved_at, rejected_reason, created_at, updated_at, deleted_at) VALUES ('eb45ad8e-51e5-4a43-afde-9f87ac8fee31', 'af82b3fe-b7d3-4342-a07f-1cdbc65233ee', 24, 3, 'Thuê Nhà Riêng Đà Nẵng Gần Cầu Rồng 3 Phòng Ngủ Đẹp Có Gara Ô Tô', 'Cho thuê nhà riêng Đà Nẵng giá rẻ
Thuê nhà riêng Đà Nẵng, vị trí trung tâm gần cầu Rồng – sông Hàn, khu dân cư an ninh, giao thông thuận tiện, rất phù hợp thuê ở lâu dài.

Diện tích: 100m²
Kết cấu: nhà 4 tầng lệch
Có gara ô tô riêng
Công năng gồm:
1 phòng khách rộng, thoáng
1 phòng bếp hiện đại, đầy đủ tiện nghi
3 phòng ngủ khép kín, trong đó có 1 phòng giường đôi
4 phòng vệ sinh
Nhà được trang bị full nội thất đẹp, hiện đại, chỉ cần xách vali vào ở. Không gian thoáng mát, thiết kế hợp lý, ánh sáng tự nhiên tốt.

Vị trí cực đẹp:

Gần cầu Rồng
Gần sông Hàn
Cách biển Mỹ Khê chỉ 700m
Thuận tiện di chuyển vào trung tâm thành phố, khu du lịch và tiện ích xung quanh
👉 Giá thuê: 30 triệu/tháng

Phù hợp khách gia đình, chuyên gia, người nước ngoài cần thuê nhà riêng Đà Nẵng gần cầu Rồng, nội thất đầy đủ, ở ổn định lâu dài.', 'Đ. An Mỹ, An Hải, An Hải Tây, Sơn Trà, Đà Nẵng 550000, Việt Nam', 30000000.00, 100.00, 3, true, 'APPROVED', '5d053abf-972f-466c-9ffc-24affd11062e', '2026-04-01 14:53:41.312173+00', NULL, '2026-04-01 14:52:04.469827+00', '2026-04-01 14:53:41.32069+00', NULL);
INSERT INTO public.properties (id, host_id, area_id, room_type_id, title, description, address_line, monthly_price, area_m2, bedrooms, allow_pets, status, approved_by, approved_at, rejected_reason, created_at, updated_at, deleted_at) VALUES ('3d59a9d7-6c4d-4b72-9620-ec24af5d2f7f', '28eeca87-18d2-44af-afde-58f5ed6927c9', 22, 1, 'Cho Thuê Căn Hộ Sam Tower Đà Nẵng 2 Phòng Ngủ Giá Tốt', 'Cho thuê căn hộ Sam Tower
Cho thuê căn hộ Sam Tower Đà Nẵng, vị trí trung tâm, giao thông thuận tiện, phù hợp để ở lâu dài cho gia đình trẻ, chuyên gia và người nước ngoài làm việc tại Đà Nẵng.

🔹 Diện tích: 69m²
🔹 Thiết kế: 2 phòng ngủ, 2 phòng vệ sinh
🔹 Không gian: bố trí hợp lý, phòng khách thoáng, nhiều ánh sáng tự nhiên
🔹 Nội thất: đầy đủ, tiện nghi, sẵn sàng vào ở

Căn hộ Sam Tower sở hữu hệ thống tiện ích nội khu đồng bộ, an ninh 24/7, thang máy, lễ tân, bãi đỗ xe rộng rãi, môi trường sống văn minh – yên tĩnh.

💰 Giá thuê: 28 triệu/tháng (đã bao gồm phí quản lý)', 'Thuận Phước, Hải Châu, Đà Nẵng 550000, Việt Nam', 28000000.00, 69.00, 2, true, 'APPROVED', '28eeca87-18d2-44af-afde-58f5ed6927c9', '2026-04-02 02:29:22.381689+00', NULL, '2026-04-02 02:06:34.77418+00', '2026-04-02 02:29:22.390212+00', NULL);
INSERT INTO public.properties (id, host_id, area_id, room_type_id, title, description, address_line, monthly_price, area_m2, bedrooms, allow_pets, status, approved_by, approved_at, rejected_reason, created_at, updated_at, deleted_at) VALUES ('b61bd9fd-edc2-43d5-90f3-1ed9ba90c63e', '28eeca87-18d2-44af-afde-58f5ed6927c9', 31, 1, 'Căn hộ 1PN đẹp, full nội thất, giặt riêng, phòng sạch đẹp, ban công lớn, gần biển Mỹ Khê, khu yên tĩnh', 'Căn hộ 1PN đẹp, full nội thất, giặt riêng, phòng sạch đẹp, ban công lớn, gần biển Mỹ Khê, khu yên tĩnh, 3/4 có phòng
-Vị trí: An Thượng 32, Mỹ An
-Giá 16,5tr', 'An Thượng 32, Mỹ An', 16500000.00, 70.00, 1, false, 'APPROVED', '28eeca87-18d2-44af-afde-58f5ed6927c9', '2026-03-27 02:14:07.523286+00', NULL, '2026-03-27 02:04:34.079326+00', '2026-03-27 02:14:07.590212+00', NULL);
INSERT INTO public.properties (id, host_id, area_id, room_type_id, title, description, address_line, monthly_price, area_m2, bedrooms, allow_pets, status, approved_by, approved_at, rejected_reason, created_at, updated_at, deleted_at) VALUES ('7a553c81-03c8-4b94-adbe-b6672111ad3b', '5d053abf-972f-466c-9ffc-24affd11062e', 25, 2, 'Cho Thuê Chung Cư Panoma 2 Phòng Ngủ Hiện Đại', 'Cho thuê chung cư Panoma Đà Nẵng – căn góc view trực diện sông Hàn cực đẹp 🌊

Căn hộ tọa lạc tại dự án cao cấp Panoma, vị trí trung tâm thành phố, ngay trục đường ven sông, thuận tiện di chuyển đến biển Mỹ Khê, sân bay và khu hành chính.

🔹 Diện tích: 70m²
🔹 Thiết kế: Căn góc 2 phòng ngủ, 2 vệ sinh
🔹 View trực diện sông Hàn, ban công rộng, thoáng gió tự nhiên
🔹 Phòng khách sáng, cửa kính lớn panorama
🔹 Bếp hiện đại, đầy đủ thiết bị
🔹 Nội thất cao cấp, vào ở ngay

Chung cư Panoma 2PN diện tích 70m2, căn góc view sông Hàn, không gian sống sang trọng, riêng tư, phù hợp chuyên gia nước ngoài, gia đình trẻ hoặc khách thuê dài hạn tại trung tâm Đà Nẵng.

💰 Giá thuê: 38 triệu/tháng

Liên hệ xem nhà ngay để sở hữu căn hộ Panoma view sông Hàn đẹp và hiếm tại thị trường cho thuê Đà Nẵng.', 'Ngũ Hành Sơn, Bắc Mỹ Phú, Ngũ Hành Sơn, Đà Nẵng 550000, Việt Nam', 38000000.00, 70.00, 1, false, 'APPROVED', '5d053abf-972f-466c-9ffc-24affd11062e', '2026-04-01 10:17:23.922683+00', NULL, '2026-04-01 09:54:17.094907+00', '2026-04-01 10:17:23.931806+00', NULL);
INSERT INTO public.properties (id, host_id, area_id, room_type_id, title, description, address_line, monthly_price, area_m2, bedrooms, allow_pets, status, approved_by, approved_at, rejected_reason, created_at, updated_at, deleted_at) VALUES ('aec25813-5eac-4a73-8c5c-25da27d3ce90', '28eeca87-18d2-44af-afde-58f5ed6927c9', 24, 1, 'Căn hộ 2PN đẹp, full nội thất, giặt riêng, phòng sạch sẽ, cửa sổ thoáng, khu yên tĩnh', 'Căn hộ 2PN đẹp, full nội thất, giặt riêng, phòng sạch sẽ, cửa sổ thoáng, khu yên tĩnh
-Vị trí: An Mỹ, Sơn Trà
-Giá 13,5tr', 'An Mỹ, Sơn Trà', 13500000.00, 22.00, 1, false, 'APPROVED', '28eeca87-18d2-44af-afde-58f5ed6927c9', '2026-03-27 07:38:22.507739+00', NULL, '2026-03-27 07:37:16.584618+00', '2026-03-27 07:38:22.820603+00', NULL);
INSERT INTO public.properties (id, host_id, area_id, room_type_id, title, description, address_line, monthly_price, area_m2, bedrooms, allow_pets, status, approved_by, approved_at, rejected_reason, created_at, updated_at, deleted_at) VALUES ('433409ce-8c6c-40b9-a021-e48f82c3aa51', '5d053abf-972f-466c-9ffc-24affd11062e', 24, 1, 'Cho Thuê Biệt Thự Euro Village Danang 4 Phòng Ngủ Khép Kín', 'Cho thuê biệt thự Euro Village Danang
Biệt thự Euro Village Danang – không gian sống đẳng cấp bên sông Hàn 🌿

Khu biệt thự tọa lạc tại khu đô thị cao cấp Euro Village, an ninh 24/7, cộng đồng dân cư văn minh, vị trí trung tâm thành phố, kết nối nhanh ra biển Mỹ Khê và sân bay quốc tế Đà Nẵng.

🔹 Diện tích: 250m²
🔹 Thiết kế: 4 phòng ngủ rộng rãi, mỗi phòng đều có vệ sinh khép kín
🔹 Phòng khách thoáng, cửa kính lớn đón ánh sáng tự nhiên
🔹 Bếp hiện đại, đầy đủ tiện nghi
🔹 Sân vườn riêng, không gian yên tĩnh, thích hợp ở gia đình hoặc chuyên gia nước ngoài
🔹 Nội thất cao cấp, dọn vào ở ngay

Biệt thự cho thuê Euro Village 4 phòng ngủ khép kín, diện tích 250m2, không gian sống sang trọng, riêng tư, phù hợp làm nhà ở cao cấp hoặc văn phòng đại diện.

💰 Giá thuê: 70 triệu/tháng

Liên hệ ngay để xem nhà và trải nghiệm biệt thự cao cấp tại Euro Village Đà Nẵng

', 'An Hải, An Hải Tây, Sơn Trà, Đà Nẵng 550000, Việt Nam', 70000000.00, 250.00, 4, true, 'APPROVED', '5d053abf-972f-466c-9ffc-24affd11062e', '2026-04-01 10:24:34.034365+00', NULL, '2026-04-01 10:23:40.145261+00', '2026-04-01 10:24:34.042046+00', NULL);
INSERT INTO public.properties (id, host_id, area_id, room_type_id, title, description, address_line, monthly_price, area_m2, bedrooms, allow_pets, status, approved_by, approved_at, rejected_reason, created_at, updated_at, deleted_at) VALUES ('8987d5bc-ee21-4cfd-9504-c84d7e5bcc2a', '28eeca87-18d2-44af-afde-58f5ed6927c9', 31, 1, 'Căn hộ 1PN full nội thất, giặt riêng, phòng rộng rãi, có ban công thoáng mát, gần biển, nhiều tiện ích -Vị trí: Hoàng Kế Viêm, Mỹ An -Giá 14tr', 'Căn hộ 1PN full nội thất, giặt riêng, phòng rộng rãi, có ban công thoáng mát, gần biển, nhiều tiện ích 
-Vị trí: Hoàng Kế Viêm, Mỹ An 
-Giá 14tr', 'Hoàng Kế Viêm, Mỹ An ', 14000000.00, 55.00, 1, false, 'PENDING', NULL, NULL, NULL, '2026-04-01 12:12:09.324563+00', '2026-04-01 12:12:09.324563+00', NULL);
INSERT INTO public.properties (id, host_id, area_id, room_type_id, title, description, address_line, monthly_price, area_m2, bedrooms, allow_pets, status, approved_by, approved_at, rejected_reason, created_at, updated_at, deleted_at) VALUES ('81b4f2fb-764c-4792-8bfa-b64bc73ba30c', '3ec0c781-ed01-4efc-b02e-6ef9ffe05576', 22, 1, 'Căn Hộ Bạch Đằng Complex Đà Nẵng 2 Phòng Ngủ Full Nội Thất Cao Cấp', 'Cho thuê căn hộ Bạch Đằng Complex

Căn hộ Bạch Đằng Complex Đà Nẵng, diện tích 120m², thiết kế 2 phòng ngủ, 2 phòng vệ sinh, không gian rộng rãi, thoáng mát. Căn hộ sở hữu ban công lớn hướng Đông Bắc, đón gió mát tự nhiên, view trực diện sông Hàn tuyệt đẹp. Nội thất tông trắng sáng hiện đại, tinh tế, mang lại cảm giác sang trọng và thư giãn.

Tòa nhà căn hộ cho thuê tọa lạc ngay trung tâm, trên trục đường Bạch Đằng ven sông, thuận tiện di chuyển, gần nhà hàng, quán cà phê, khu vui chơi và các tiện ích cao cấp. Phù hợp chuyên gia nước ngoài, gia đình hoặc khách thuê dài hạn.', '50 Bạch Đằng, Hải Châu, Đà Nẵng 550000, Việt Nam', 45000000.00, 120.00, 2, true, 'APPROVED', '5d053abf-972f-466c-9ffc-24affd11062e', '2026-03-28 17:03:13.67183+00', NULL, '2026-03-28 16:26:58.330669+00', '2026-03-28 17:03:13.79483+00', NULL);
INSERT INTO public.properties (id, host_id, area_id, room_type_id, title, description, address_line, monthly_price, area_m2, bedrooms, allow_pets, status, approved_by, approved_at, rejected_reason, created_at, updated_at, deleted_at) VALUES ('12e175b4-a270-4438-928b-deb22e1e7841', 'af82b3fe-b7d3-4342-a07f-1cdbc65233ee', 25, 1, 'Thị Trường Bất Động Sản Đầu Năm 2026: Nhịp Điều Chỉnh Và Cơ Hội Cho', 'Với những chủ nhân thành đạt, mỗi căn hộ không chỉ là không gian sống, mà còn là một bức tranh nghệ thuật độc bản, thể hiện rõ nét cá tính và gu thẩm mỹ riêng. Từ việc chọn lựa từng chi tiết nội thất, vật liệu đến cách phối màu, tất cả đều phản ánh sự tinh tế và đẳng cấp.', '50 Bạch Đằng, Hải Châu, Đà Nẵng 550000, Việt Nam', 3600000.00, 36.00, 1, true, 'DELETED', NULL, NULL, 'Thông tin chưa rõ ràng', '2026-03-31 14:53:53.763648+00', '2026-04-01 14:48:46.065468+00', NULL);
INSERT INTO public.properties (id, host_id, area_id, room_type_id, title, description, address_line, monthly_price, area_m2, bedrooms, allow_pets, status, approved_by, approved_at, rejected_reason, created_at, updated_at, deleted_at) VALUES ('bd7f6762-e245-429f-afc4-476c292d695b', '28eeca87-18d2-44af-afde-58f5ed6927c9', 22, 1, 'Cho Thuê Căn Hộ Cao Cấp 4 Phòng Ngủ Tại Trung Tâm Thành Phố', 'Cho thuê căn hộ cao cấp tại Đà Nẵng
Cho thuê căn hộ cao cấp tại trung tâm thành phố, vị trí đắc địa trên đường Núi Thành, kết nối nhanh ra sân bay, trung tâm hành chính, khu văn phòng và các tuyến đường lớn.

Diện tích lớn 300m², không gian hiếm trong phân khúc căn hộ trung tâm
Thiết kế 4 phòng ngủ, 4 phòng vệ sinh, bố trí khoa học, riêng tư
Nội thất cao cấp, tông trắng sáng – trẻ trung – hiện đại, không gian thoáng và sang
Phòng khách rộng, bếp hiện đại, ánh sáng tự nhiên tràn ngập
Trang bị đầy đủ nội thất, chỉ việc xách vali vào ở
Giá thuê: 90 triệu/tháng
👉 Đã bao gồm: internet, chỗ để xe máy, phí quản lý

📍 Lựa chọn lý tưởng cho khách tìm thuê căn hộ cao cấp trung tâm thành phố Đà Nẵng, diện tích lớn, tiện nghi đầy đủ, không gian sống đẳng cấp.

', 'Núi Thành, Hải Châu, Đà Nẵng 550000, Việt Nam', 90000000.00, 300.00, 4, true, 'PENDING', NULL, NULL, NULL, '2026-04-02 01:48:58.701885+00', '2026-04-02 01:48:58.701885+00', NULL);


--
-- TOC entry 4674 (class 0 OID 34337)
-- Dependencies: 224
-- Data for Name: property_images; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('ba17a582-6ac0-45c0-b63d-10d6cda0f219', 'f4b6423a-7b6e-4dba-bb7d-15bab56f3cc9', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/b10a7c50-1c74-4ef8-8142-b8a150cf8536_1.jpg', true, 0, '2026-03-27 02:03:05.014344+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('fcfec605-a075-489e-85ac-efaff011ea45', 'f4b6423a-7b6e-4dba-bb7d-15bab56f3cc9', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/3246f4ca-b3a4-4d61-842b-c94ca65eb3ca_z7662097919166_51614200ef5816485cbd33f66de2d12d.jpg', false, 1, '2026-03-27 02:03:05.014344+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('06ff62c6-c2eb-49b4-9920-12dc9c11df08', 'f4b6423a-7b6e-4dba-bb7d-15bab56f3cc9', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/ba99fb15-0ab7-4a51-bed0-9faf9514591f_z7662097940594_45de76d65ad0be5af175cc2fb772a445.jpg', false, 2, '2026-03-27 02:03:05.014344+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('f5a15c58-b8c7-4ae4-94e2-1313d905db0c', 'f4b6423a-7b6e-4dba-bb7d-15bab56f3cc9', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/0d219ce1-a659-4042-bc98-3842076fe537_z7662097951645_a8e82b717dbd86a97a93ca86adaae441.jpg', false, 3, '2026-03-27 02:03:05.014344+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('81122a96-73c8-4c6a-926b-d2b3cc67c74e', 'f4b6423a-7b6e-4dba-bb7d-15bab56f3cc9', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/2b93a38b-345b-440f-8144-7f77301eefca_z7662097963493_c983c90c58d20da27b641a6ed9debd45.jpg', false, 4, '2026-03-27 02:03:05.014344+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('d5a23838-a25d-493c-9b91-fab88b6fcc8c', 'b61bd9fd-edc2-43d5-90f3-1ed9ba90c63e', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/7ff2b675-7414-4cc2-8a6c-bc8c270671ec_1.jpg', true, 0, '2026-03-27 02:04:34.080328+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('e42005db-946d-4f40-9c5b-1e451a4b3095', 'b61bd9fd-edc2-43d5-90f3-1ed9ba90c63e', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/32f4e2a0-7831-4922-a761-34bb0fffec80_2.jpg', false, 1, '2026-03-27 02:04:34.080328+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('d2e74c6c-b683-41e9-a647-60eaae543575', 'b61bd9fd-edc2-43d5-90f3-1ed9ba90c63e', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/445d6010-a684-4b31-afdb-61966ffc2338_z7662057501942_ba09078276e28e6ea7f0c35b7758c48b.jpg', false, 2, '2026-03-27 02:04:34.080328+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('eb755498-db82-4523-9825-029670ca3514', 'b61bd9fd-edc2-43d5-90f3-1ed9ba90c63e', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/3b2977e3-cad6-4c84-8e89-954073673275_z7662057504847_e5a17903b2305828542b145ef111e345.jpg', false, 3, '2026-03-27 02:04:34.080328+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('a08a0b3f-0f20-4f43-8ae2-fa4825f02a41', 'b61bd9fd-edc2-43d5-90f3-1ed9ba90c63e', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/fcaaa98b-2e2c-4ba0-b9e0-7c75ff9168a1_z7662057511294_126604dc7050056305e82cc8266e4c82.jpg', false, 4, '2026-03-27 02:04:34.080328+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('f208655f-ed80-482e-83e0-136144d4af27', 'b61bd9fd-edc2-43d5-90f3-1ed9ba90c63e', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/5001c2dc-ae0b-4992-ac09-abe676ba8734_z7662057514255_a0f7831d63c3c067b15828a04351731a.jpg', false, 5, '2026-03-27 02:04:34.080328+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('d9c53ee3-b66f-47eb-8b63-ba27cc0fb52d', '2086fead-4f58-4d75-80fb-e6ac7c8c5ce6', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/73e2b34a-7cee-4f42-8b32-5129dc97e705_1.jpg', true, 0, '2026-03-27 02:10:53.82931+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('cae02032-1f30-400c-b084-c22450406c6c', '2086fead-4f58-4d75-80fb-e6ac7c8c5ce6', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/54452ef2-080e-447b-8dfe-816b6f7088a4_z7662057501942_ba09078276e28e6ea7f0c35b7758c48b.jpg', false, 1, '2026-03-27 02:10:53.82931+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('77a847fb-f714-4ef3-a0a1-29d16c7708f2', '2086fead-4f58-4d75-80fb-e6ac7c8c5ce6', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/7d48a646-beb4-4116-a75b-1e59302fa69b_z7662057504847_e5a17903b2305828542b145ef111e345.jpg', false, 2, '2026-03-27 02:10:53.82931+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('01477c01-acad-4d18-a5d3-9a723c2393e6', '2086fead-4f58-4d75-80fb-e6ac7c8c5ce6', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/05beed65-8aa7-417b-8359-e3089c684cf1_z7662057511294_126604dc7050056305e82cc8266e4c82.jpg', false, 3, '2026-03-27 02:10:53.82931+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('a8f78ef0-2238-4e91-9725-80be1b4f72fa', '2086fead-4f58-4d75-80fb-e6ac7c8c5ce6', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/a70a9197-4646-4621-bedb-4a86849f99c4_z7662057514255_a0f7831d63c3c067b15828a04351731a.jpg', false, 4, '2026-03-27 02:10:53.82931+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('7d7b4790-081b-4763-9c00-4348b5e4a79f', '2086fead-4f58-4d75-80fb-e6ac7c8c5ce6', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/40a72048-6d50-4ad4-8010-cceb7f2a8e4a_z7662057521871_738002c278cd8e1de110172564ad7cfc.jpg', false, 5, '2026-03-27 02:10:53.82931+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('3fcc57d1-58a4-4209-b7e6-5c2e1b648dd6', '0a45c75e-6742-4774-be9d-c8c3f49350a6', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/e1bfaa16-908f-47ae-820d-9643b62de70c_z7661980367666_cb73d5fac890a9ca9060224b36f4bdd3.jpg', true, 0, '2026-03-27 02:12:00.214416+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('d9bafa59-888d-45ab-905a-43ee1a88ff4a', '0a45c75e-6742-4774-be9d-c8c3f49350a6', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/102ea9c9-06df-4a81-aa73-587de2bfc991_z7661980372060_71cfb10246379d71b960e95c48e2a7ef.jpg', false, 1, '2026-03-27 02:12:00.214416+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('d6ed064e-f05f-4a37-9b78-ab59242c0371', '0a45c75e-6742-4774-be9d-c8c3f49350a6', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/444a6d39-aece-4a67-bb5f-8adb6444333a_z7661980379712_a0b9b6cbba87a1d80ebac6292ae44f79.jpg', false, 2, '2026-03-27 02:12:00.214416+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('6ac1a042-6b23-4cd5-a7dc-2bb56260f42b', '0a45c75e-6742-4774-be9d-c8c3f49350a6', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/6ddf84ff-a6f6-40a0-94be-6a9dd1855657_z7661980383606_131bf0114283d19542e7e1c0bd11817e.jpg', false, 3, '2026-03-27 02:12:00.215419+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('26635abc-d86a-4972-857c-883abdbeeff8', '0a45c75e-6742-4774-be9d-c8c3f49350a6', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/64df111b-366f-4700-bdc0-5aa35dc51435_z7661980390377_210d610b57bba5ad471741cdd7f29a34.jpg', false, 4, '2026-03-27 02:12:00.215419+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('f65cbdd3-527e-4072-933e-f1ba32cc263c', '0a45c75e-6742-4774-be9d-c8c3f49350a6', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/f4e3105e-9d1b-4bd5-a02c-0f884f4ad599_z7661980394813_be35fed6558976943c46630adc156999.jpg', false, 5, '2026-03-27 02:12:00.215419+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('df26ad7a-fbbc-4d81-9c7f-6e4b155086d9', '0a45c75e-6742-4774-be9d-c8c3f49350a6', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/253514ce-613a-41a3-b44d-43298f700a12_z7661980398792_d590eebac5fbbfc73d5acd48e2fc85b9.jpg', false, 6, '2026-03-27 02:12:00.215419+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('c50d55f5-ea05-4f52-950b-f567c37229f1', '0a45c75e-6742-4774-be9d-c8c3f49350a6', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/2b8a6621-b3a5-4c4e-8bc0-49f78e2111c8_z7661980404576_abc73691f9f648a72d3fbe30ce11be7a.jpg', false, 7, '2026-03-27 02:12:00.215419+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('e400bcb0-7882-4148-9792-061fd69df779', '01a84411-d474-41f7-b4e4-575d14275f04', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/fc340b22-29e7-49d9-b605-941d34efe241_z7661977396042_1c7af1345481be95dbb28bbda81f1f49.jpg', true, 0, '2026-03-27 02:12:57.056415+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('47423e54-57f1-4f91-8464-7f1701b54271', '01a84411-d474-41f7-b4e4-575d14275f04', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/a3e13d94-1d0e-4d09-82de-4767648faa74_z7661977400221_2ae58653f19677b7e1eb65ee512a8a16.jpg', false, 1, '2026-03-27 02:12:57.056415+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('38106694-21f0-43ad-80a3-f08aff718122', '01a84411-d474-41f7-b4e4-575d14275f04', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/6091f934-e71c-406a-9de7-9b2a9d802821_z7661977407037_8218e620b5e1c22c150cdfe80cde3b2d.jpg', false, 2, '2026-03-27 02:12:57.056415+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('5ff765c8-5fd5-4829-afd6-a83368fb295a', '01a84411-d474-41f7-b4e4-575d14275f04', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/a122a634-0347-4cb7-b546-bb4f7716b658_z7661977411776_5eb174e547ad04d495b2aadcbe3782ae.jpg', false, 3, '2026-03-27 02:12:57.056415+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('af7ed802-02fd-4c38-8056-f50d5b91810e', '01a84411-d474-41f7-b4e4-575d14275f04', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/8ab5d2ec-dc55-4b97-a3e9-57edb83f0354_z7661977418210_6c75387c9ae0547e2a0e82c104c4b6ca.jpg', false, 4, '2026-03-27 02:12:57.056415+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('8957c82c-41f5-4bb7-9c7c-322f7b3d51e5', '01a84411-d474-41f7-b4e4-575d14275f04', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/e13924e8-8648-4a4c-9847-4e771f499e67_z7661977423737_69704b1a745f7cd138bb5c0c91360ab9.jpg', false, 5, '2026-03-27 02:12:57.056415+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('4c9269d9-4d38-4769-858d-d10a6c7239ae', '4f3aa900-7e7e-4995-8d1b-b8330b8c0340', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/c1e7a45f-89ea-414c-a749-ba8d2151384c_z7661974811372_2e80f5e2edd4b21b8c5129bd07f20ab0.jpg', true, 0, '2026-03-27 02:13:49.685303+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('05f86cf8-3db0-4b3b-a1f8-625afdd7b228', '4f3aa900-7e7e-4995-8d1b-b8330b8c0340', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/37d9c708-a76e-45da-8925-93fb12967fe0_z7661974816093_9de154f6819924e8cb520fe7d1f56178.jpg', false, 1, '2026-03-27 02:13:49.6863+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('99c3d908-15d5-4258-b74d-dab630adff24', '4f3aa900-7e7e-4995-8d1b-b8330b8c0340', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/d98be583-846a-4064-a81f-1869c1702b0c_z7661974819841_ea2cf965a7260072814c8c1e9c6f4a6f.jpg', false, 2, '2026-03-27 02:13:49.6863+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('8ee315c1-bda0-4aa1-845e-dc87f5a97c83', '4f3aa900-7e7e-4995-8d1b-b8330b8c0340', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/f92f1455-6b23-4645-a9c0-35d993ee74eb_z7661974822545_3d7025ba08f0ed731eb8a490dc4e85ca.jpg', false, 3, '2026-03-27 02:13:49.6863+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('c408931d-f5b4-4798-8018-3ce7803e73af', '4f3aa900-7e7e-4995-8d1b-b8330b8c0340', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/c95691b9-80f7-4742-8553-c7edf997abad_z7661974826509_41065a0db4d8c0108c6ac5a0a1d74dfd.jpg', false, 4, '2026-03-27 02:13:49.6863+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('cb7ba9bf-5dab-4e3a-8f45-e49800867189', '4f3aa900-7e7e-4995-8d1b-b8330b8c0340', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/247263d2-476f-4d73-97e1-a4108515601e_z7661974831705_fe794c2c0096e3783d353e5e3c2d9bde.jpg', false, 5, '2026-03-27 02:13:49.6863+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('e04470a0-107b-4242-95bb-36ebb4b6ee1c', '4f3aa900-7e7e-4995-8d1b-b8330b8c0340', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/23cff086-a6fe-4527-ab4c-21afc5040771_z7661974846437_2b51fb9146797b82cdbff62f59960316.jpg', false, 6, '2026-03-27 02:13:49.6863+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('af5c1bdc-6d77-4e3d-9fc1-5c9d04f68c2d', '4f3aa900-7e7e-4995-8d1b-b8330b8c0340', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/def5424d-d85a-4139-85d9-267657997b2c_z7661974846869_17b294805919c68caa4f784533e88ba5.jpg', false, 7, '2026-03-27 02:13:49.6863+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('d9076462-519e-46e9-b977-930293a6b95b', '4f3aa900-7e7e-4995-8d1b-b8330b8c0340', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/5e657c07-c5a3-4531-a668-32ce4400f409_z7661974852262_821a2ce2555b296969e74c6befe6ee88.jpg', false, 8, '2026-03-27 02:13:49.6863+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('0f106a7f-1ae7-45f0-8bc8-44c3702ad1e1', '81314a11-ad2e-411f-bb7a-8864217c5c8b', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/c6927901-efa5-4663-b804-0edf18fc1604_z7661971417171_e6565dda8f924fb84e698a11b7e9f095.jpg', true, 0, '2026-03-27 07:30:48.488181+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('1d09c862-e2e7-43e8-86bd-60b47be57ed6', '81314a11-ad2e-411f-bb7a-8864217c5c8b', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/b036ab9c-68a5-458f-afbe-fc6798d03239_z7661971418665_f42031c562ab6f0dcd9ea2e9b55bc3ad.jpg', false, 1, '2026-03-27 07:30:48.488181+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('2a513ab6-d92d-4601-9c4b-9ab17f325120', '81314a11-ad2e-411f-bb7a-8864217c5c8b', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/d6378c78-b39e-4593-9ad3-aaf3012180bd_z7661971418815_5add2cc2316a38673cffd4375cdd2a34.jpg', false, 2, '2026-03-27 07:30:48.488181+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('0ec207f3-0522-449e-8857-3df0209c4e42', '81314a11-ad2e-411f-bb7a-8864217c5c8b', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/0cfafb4e-5e70-4359-82ce-3f95c36c1505_z7661971424333_477616fb245c344d9e059eb982813d10.jpg', false, 3, '2026-03-27 07:30:48.488181+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('c49f55b1-bf4c-4310-bed1-98c3b7dd03a6', '81314a11-ad2e-411f-bb7a-8864217c5c8b', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/5e0eb0e8-01f5-4029-8ec2-e57f590c355a_z7661971429417_680ef67a6124acbe26aa701fe266dcd4.jpg', false, 4, '2026-03-27 07:30:48.488181+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('9e8bf833-9067-41d3-9dbf-e4ae67d39865', '81314a11-ad2e-411f-bb7a-8864217c5c8b', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/11067fe7-6e8e-4ada-9d4c-2c0152fe0b80_z7661971433387_c6966854add2c8ce89d9eb2b0d0a155b.jpg', false, 5, '2026-03-27 07:30:48.488181+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('b2e46f3d-1c8e-4cdb-8f10-f4ee89f96ad5', '81314a11-ad2e-411f-bb7a-8864217c5c8b', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/22c2390d-e2a3-4fac-9d68-c526b660e532_z7661971435928_38fead3e63daddae0a8ddb6280e121de.jpg', false, 6, '2026-03-27 07:30:48.488181+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('acb7a7a2-c321-4d6f-aa50-e88a8866997a', 'aec25813-5eac-4a73-8c5c-25da27d3ce90', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/553ae694-7b02-4afc-9d5f-35c7be172f81_z7661971418665_f42031c562ab6f0dcd9ea2e9b55bc3ad.jpg', true, 0, '2026-03-27 07:37:16.586616+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('c118a4be-0d1a-45ad-bb3b-c4c73a620389', 'aec25813-5eac-4a73-8c5c-25da27d3ce90', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/0566caa6-166c-424e-acc4-8ffffa0c6c1b_z7661971418815_5add2cc2316a38673cffd4375cdd2a34.jpg', false, 1, '2026-03-27 07:37:16.587616+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('97162b1c-393b-4869-b30a-e7c3b138d5bd', 'aec25813-5eac-4a73-8c5c-25da27d3ce90', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/aca5e7c4-db58-4c65-91b7-12819b26614b_z7661971424333_477616fb245c344d9e059eb982813d10.jpg', false, 2, '2026-03-27 07:37:16.587616+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('e53d9bf4-b923-4fcb-9925-2b02b669a0fc', 'aec25813-5eac-4a73-8c5c-25da27d3ce90', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/ec2eb369-5478-415d-a574-732248974163_z7661971433387_c6966854add2c8ce89d9eb2b0d0a155b.jpg', false, 3, '2026-03-27 07:37:16.587616+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('1400d32f-0847-400a-8ad2-2178495339b1', 'aec25813-5eac-4a73-8c5c-25da27d3ce90', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/3cdde85a-f0e8-4a6f-bdcf-81e10ec51ac7_z7661971435928_38fead3e63daddae0a8ddb6280e121de.jpg', false, 4, '2026-03-27 07:37:16.587616+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('a0dafe85-2775-4551-beb7-96600de63fe6', 'bec2b2be-856b-41cd-8256-073417b3203a', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/da7db5b1-8703-4a84-a796-b00bf86ff4f0_z7661971418815_5add2cc2316a38673cffd4375cdd2a34.jpg', true, 0, '2026-03-27 07:38:00.586029+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('c6628d2a-e379-4fbb-bef5-43cb247ec8a4', 'bec2b2be-856b-41cd-8256-073417b3203a', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/068e45d8-84c5-4ca9-b14a-645d89e43eca_z7661971424333_477616fb245c344d9e059eb982813d10.jpg', false, 1, '2026-03-27 07:38:00.586029+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('86615f17-abdb-495d-9fab-b1ebf99a7e41', 'bec2b2be-856b-41cd-8256-073417b3203a', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/f5b1e50a-81ea-42c6-aeae-6259e48643d8_z7661971426809_035f61f9c6e89d7ec2ead8b289e8cd54.jpg', false, 2, '2026-03-27 07:38:00.586029+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('0e44fffd-e3d4-4e71-b865-b1078182ceaf', 'bec2b2be-856b-41cd-8256-073417b3203a', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/e6841248-e92a-4364-9613-24d6bfd4ae17_z7661971435928_38fead3e63daddae0a8ddb6280e121de.jpg', false, 3, '2026-03-27 07:38:00.587073+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('b9a89bef-b57d-46d6-a34f-b5a89753c015', '81b4f2fb-764c-4792-8bfa-b64bc73ba30c', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/42ac4ff5-aa12-446a-b924-8c0b99d9c530_can-ho-bach-dang-complex-1240x720.jpg', true, 0, '2026-03-28 16:26:58.332668+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('60014a31-7938-44ec-885d-9590a339fba5', '81b4f2fb-764c-4792-8bfa-b64bc73ba30c', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/c9130ecf-7daa-4063-8dbf-b15f3eacb1cb_z7649207729666_ae1d405274c5839038b601e54c33ad4c.jpg', false, 1, '2026-03-28 16:26:58.332668+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('9fc371a7-6088-4765-96f1-4c27b2b98174', '81b4f2fb-764c-4792-8bfa-b64bc73ba30c', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/d92698a2-db29-4501-a4ca-cb749c725401_z7649207734914_ddba21e4829907a4cb9cba8da47b5ac9.jpg', false, 2, '2026-03-28 16:26:58.332668+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('ab9c9678-4c41-4c0b-8dfd-d221d9a475df', 'a569e2b1-cd7f-4b25-999c-aecb20dc192b', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/7a2c12ab-a99a-46fc-b3bf-3aa56dff9222_thue-nha-dai-han-da-nang-1240x720.jpg', true, 0, '2026-03-29 03:51:40.758865+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('e0b7acd3-2f67-4bbe-abe1-13c2551aa2a7', 'a569e2b1-cd7f-4b25-999c-aecb20dc192b', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/3b4f4f7a-ae6d-40c9-bb0c-4a2e5769cda4_z7643681813480_8600ec980630e35e4a3e6406645e360f-1240x720.jpg', false, 1, '2026-03-29 03:51:40.758865+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('b453f7f4-ffb6-4367-8d74-3991f83e58e8', 'a569e2b1-cd7f-4b25-999c-aecb20dc192b', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/c80e8e60-9a34-446a-af9c-665985556f20_z7643682098679_2c4d22517bd56d720a63ef34f8841cf1.jpg', false, 2, '2026-03-29 03:51:40.758865+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('7688151e-974d-4e97-8d34-100e7b2c339f', 'a569e2b1-cd7f-4b25-999c-aecb20dc192b', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/4b77722b-2e6a-419a-8e89-19ddb0ad9e52_z7643682193660_b24b8202c17eef07b532927c262471de.jpg', false, 3, '2026-03-29 03:51:40.758865+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('7c276f14-7daa-4d71-bd85-993b8eeade65', 'a569e2b1-cd7f-4b25-999c-aecb20dc192b', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/8d1df229-d81d-4c75-9d19-393159dfcafa_z7643682819599_e43129e93b3aece9ed25989c1ba64b32-1240x720.jpg', false, 4, '2026-03-29 03:51:40.758865+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('2418dce7-6d29-400d-b62e-b80242353fed', '6ed3ebf1-c2d0-435f-995f-914ba73fcd6b', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/ebe77e87-7f6c-4bd7-8bdf-3ace60d36fc8_du-an-azura-da-nang-1-1240x720.jpg', true, 0, '2026-03-29 07:44:06.701551+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('7fd4d0ca-b4ec-4339-91d6-ba286b78e2b1', '6ed3ebf1-c2d0-435f-995f-914ba73fcd6b', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/02f3ab2e-a0ec-40b4-b11a-e4ab2535e81a_z7640071468903_3e5d392286147a29a59af8063e613f3d-1240x720.jpg', false, 1, '2026-03-29 07:44:06.701722+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('b76a676b-53a1-4354-8ba6-e8ee5c44156c', '6ed3ebf1-c2d0-435f-995f-914ba73fcd6b', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/96f9321e-7fe8-4f75-9532-4f74eea45464_z7640071449647_6b2a16cb7717fdc7fcfb60f22c624493-1240x720.jpg', false, 2, '2026-03-29 07:44:06.701777+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('4f7f998c-c0a6-47b5-aedf-c852d431bcc9', '6ed3ebf1-c2d0-435f-995f-914ba73fcd6b', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/82b1cf74-9f79-48ae-8c84-f0d29ec0d9be_z7640071435532_c92b24f1bfd59aabc236703c2945904d-1240x720.jpg', false, 3, '2026-03-29 07:44:06.701824+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('a94e0b38-26ef-470a-920e-d725cd43654e', '12e175b4-a270-4438-928b-deb22e1e7841', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/e8af1383-9662-409b-b0c1-7c9d948a5d1f_bat-dong-san8-1771753555.jpg', true, 0, '2026-03-31 14:53:53.770126+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('f9f21e00-35f0-4251-be8d-ae71439d8c8f', 'b5bd261b-cbbd-40c9-8c79-c9b0b1a64f3f', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/1e6ce60d-c3bc-438e-95cd-515aaf20b521_z7635541455732_ade70abdd32079abedf0e9dbb46964bf-1240x720.jpg', true, 0, '2026-03-31 15:20:17.43212+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('32e236b4-5b68-4bf1-bfdb-bcf35300458d', 'b5bd261b-cbbd-40c9-8c79-c9b0b1a64f3f', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/2f35d86d-b306-448b-86da-81a9a836a2c1_z7635541456920_dfc90e0e641fc39dd8d80b988562e4da-1240x720.jpg', false, 1, '2026-03-31 15:20:17.432242+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('8d333a28-c220-4046-9975-3339c8ca9d1f', 'b5bd261b-cbbd-40c9-8c79-c9b0b1a64f3f', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/35a9106f-ae7f-46cf-8405-21b8a7aea69c_z7635543799668_2adc78db09caa3cb54123716b5c22017-1240x720.jpg', false, 2, '2026-03-31 15:20:17.432353+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('1887f778-6db7-4ff7-a0ad-4c3bf04353d0', '07c18775-420c-4c22-a2d6-194d15375ffe', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/4a3186d2-039a-44df-8ca5-81bc89c4329e_z7673994442154_7259e02e843a6a91d80985cb12db962c.jpg', true, 0, '2026-03-31 15:24:19.271263+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('f0725dca-f426-4975-9bee-4d0a999ac365', '7a553c81-03c8-4b94-adbe-b6672111ad3b', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/b86da776-74a0-4e7d-ae29-0b44ff64e2ce_cho-thue-chung-cu-panoma-1240x720.jpg', true, 0, '2026-04-01 09:54:17.095314+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('465e3e24-86c9-4c21-95c0-57b877750cbd', '7a553c81-03c8-4b94-adbe-b6672111ad3b', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/9ff25711-4df7-4afd-8f2d-5347cb969d0d_z7575400981495_88ebe1f34cfe4ab0fa213bff8dc0cce6-1240x720.jpg', false, 1, '2026-04-01 09:54:17.095485+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('eaf8cf8a-ec08-4772-9108-fa576e855bf5', '7a553c81-03c8-4b94-adbe-b6672111ad3b', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/64b74d39-a06c-4985-8325-3bd286eb7505_z7575400981505_9ddd44b4d1a3594515a0de0b60b521a6-1240x720.jpg', false, 2, '2026-04-01 09:54:17.095577+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('0c9fae8f-da00-4c77-b81a-b3e13cae7741', '0f3d71ec-8c9c-40d0-82f5-4598271aab72', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/e7a3a5ca-1cb6-4dc7-af6b-652afea5507a_cho-thue-biet-thu-one-river-1-1240x720.jpg', true, 0, '2026-04-01 10:14:35.77571+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('af9e2c83-b5ca-4cbb-bb97-eb66ea7b6440', '0f3d71ec-8c9c-40d0-82f5-4598271aab72', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/188bbcb7-c9bc-4a56-923b-74a6830de9b6_z7490674533619_86eeda8ee675664d6b271a08a1bbf148-1240x720.jpg', false, 1, '2026-04-01 10:14:35.775885+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('f7b3941f-f751-46c0-8791-f40f1f480c17', '0f3d71ec-8c9c-40d0-82f5-4598271aab72', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/de5d9422-1f63-4c21-9836-2ea6a63aa00f_z7679229804586_5a1e9319725274395cd8e74f888a4a53.jpg', false, 2, '2026-04-01 10:14:35.775995+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('7bdcd153-74f0-4628-9d9a-f3e23344caa7', '0f3d71ec-8c9c-40d0-82f5-4598271aab72', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/432d3acb-ea22-4ee8-be60-a7e0677f6cfa_z7490675017970_ec1d158d7ebf66e1e5613aabab4f4f5f-1240x720.jpg', false, 3, '2026-04-01 10:14:35.776074+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('f56de68e-6c47-40f3-8b19-098c46bca519', '433409ce-8c6c-40b9-a021-e48f82c3aa51', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/8dcc41c1-cfd3-4a31-b53b-aa97e90b6c0b_biet-thu-euro-village-danang.jpg', true, 0, '2026-04-01 10:23:40.145572+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('30bf5acf-78d6-48b1-9825-8591039fdb5d', '433409ce-8c6c-40b9-a021-e48f82c3aa51', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/58006b59-d8f7-4c0a-b6dd-df786cf03aa5_z7575407668309_fcddd76a7d38ec1b12f10ae1942af563.jpg', false, 1, '2026-04-01 10:23:40.145701+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('4f9c451b-2939-44ed-a58a-d82e7142eb62', '433409ce-8c6c-40b9-a021-e48f82c3aa51', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/7b51535a-58d6-4e64-8a18-86bfb02c0b4f_z7575407681481_0121e717dbf12df8f119f16a60beeab4-1240x720.jpg', false, 2, '2026-04-01 10:23:40.145765+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('07816e3b-d39e-4551-a7be-02bcb6a7f20f', 'b2a343a0-5910-4d57-8374-02692a70c955', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/7e95bb17-27fd-430b-9dc3-fe1650e34886_z7679761603999_5bf4b0603008d68829e57ff4407a7a8e.jpg', true, 0, '2026-04-01 11:16:41.745044+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('a66265f2-9f82-4a2e-9488-65cfe3d7aef4', '53def4cc-2d5f-41ca-9dbd-2b3af7fd5f29', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/722fe780-24e9-4b1f-8a40-4cea6a1259ed_z7679761639162_c0ae2000b1b5f9cc16d87ee9a36ff6f8.jpg', true, 0, '2026-04-01 11:24:13.025095+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('92898207-ffc3-4ce8-84f0-95355a3cd012', '8987d5bc-ee21-4cfd-9504-c84d7e5bcc2a', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/d4b756ce-d7ab-4a19-b397-6f56229d78cd_z7679761609980_7fe5b2903934f65741a80279134381fe.jpg', true, 0, '2026-04-01 12:12:09.324833+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('a2322a90-cea6-4a37-8c00-8a8ef7861956', 'eb45ad8e-51e5-4a43-afde-9f87ac8fee31', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/95ec0708-369f-4fa4-b9a6-0bf81c1ef700_thue-nha-rieng-da-nang-1-1240x720.jpg', true, 0, '2026-04-01 14:52:04.470161+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('198208f2-2bf4-44fd-94b2-74e4a3ac89de', 'eb45ad8e-51e5-4a43-afde-9f87ac8fee31', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/9e470599-443c-494e-bf74-a17b0a0aac31_z7449751113340_087dd7df90fdc3e45abac75f0f67be66-1240x720.jpg', false, 1, '2026-04-01 14:52:04.47027+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('c29c66f0-8029-4d25-891b-1f4ccf00fa38', 'eb45ad8e-51e5-4a43-afde-9f87ac8fee31', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/0ef84765-f7de-45ae-a170-f5fc0c7aadfb_z7449751005998_1f0c245040a171d231e5e1345998cb98-1240x720.jpg', false, 2, '2026-04-01 14:52:04.470372+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('abf15b41-a5ba-496e-ae76-b8f4dd965e64', 'eb45ad8e-51e5-4a43-afde-9f87ac8fee31', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/499a97d6-ed88-4a42-b110-aeddc19077f1_z7449751051841_aba8e8d5b632ea7a263065becd2e4b08-1240x720.jpg', false, 3, '2026-04-01 14:52:04.470441+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('e0d39af7-6ddf-4313-8baa-e9ee17622f6c', 'eb45ad8e-51e5-4a43-afde-9f87ac8fee31', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/06cd3e43-4b13-4c7c-ac93-4b9bd8ceb386_z7449751121731_5f8b879bd45ec846f33d1d7733ae7819-1240x720.jpg', false, 4, '2026-04-01 14:52:04.4705+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('d059c13b-80b9-4abc-834e-2d591bbc7bfa', 'bd7f6762-e245-429f-afc4-476c292d695b', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/3842e94d-4f2a-489c-aa6c-e2eeae6556a0_cho-thue-can-ho-cao-cap-1240x720.jpg', true, 0, '2026-04-02 01:48:58.703088+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('aae5a2b8-35cf-456a-ba8d-f4278ec80bbd', 'bd7f6762-e245-429f-afc4-476c292d695b', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/7e6774f7-e205-4f53-a5b1-765c650baa09_z7502606863019_46ee31f592a06106522272136b9785fa-1240x720.jpg', false, 1, '2026-04-02 01:48:58.703616+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('29d9ef34-0fd6-433d-8429-22e55d7700b0', 'bd7f6762-e245-429f-afc4-476c292d695b', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/37da073e-1a11-4145-b47e-63501f304d10_z7502606781292_7a861d4d9770c2a6be1571b9216aef54-1240x720.jpg', false, 2, '2026-04-02 01:48:58.703779+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('9df7f73e-7e47-4144-9d7e-80b171dee578', 'bd7f6762-e245-429f-afc4-476c292d695b', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/ed3d5ff9-0ab8-4bb5-9099-16007e4a55cb_z7502606921809_e8e7870eab3fe4959abff13c5dbecfba-1240x720.jpg', false, 3, '2026-04-02 01:48:58.70387+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('4133519b-bb59-42e1-9d52-01a3e4eae238', 'bd7f6762-e245-429f-afc4-476c292d695b', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/04a5f505-c916-47b2-909f-762493945dea_cho-thue-can-ho-cao-cap-1240x720%20%281%29.jpg', false, 4, '2026-04-02 01:48:58.703951+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('ab0a8403-54ce-4ca6-a35c-2229b2061417', 'e7d919f5-eb4f-449f-8d0a-5c9a46b584f1', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/13d481a9-e210-43dc-8009-8e1e30206474_z7679513952313_69834c09315f1968d970d3bdff74a28e.jpg', true, 0, '2026-04-02 02:02:32.181455+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('9b97a850-184f-4990-9cbb-04c876ff9742', 'e7d919f5-eb4f-449f-8d0a-5c9a46b584f1', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/c6ebdd9e-4f93-42ce-a044-3e2a7e774045_z7679513956660_da2d87496b3a24dc3a34f5021253447a.jpg', false, 1, '2026-04-02 02:02:32.181516+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('9fc08b19-23f0-454e-b552-d9e88762415b', 'e7d919f5-eb4f-449f-8d0a-5c9a46b584f1', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/d2361aff-926e-4cf9-be0d-2783ec0e80b7_z7679513963161_3fc6c59dba60b865bfcec37e205decfe.jpg', false, 2, '2026-04-02 02:02:32.181599+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('dbacfbd2-e261-4335-a851-0fa89737120e', 'e7d919f5-eb4f-449f-8d0a-5c9a46b584f1', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/e7084345-88d2-4960-a385-2d71f9050392_z7679513972503_095ee8034f7369603e69cb8ae3d109fa.jpg', false, 3, '2026-04-02 02:02:32.181676+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('0b1e84e8-b7da-4d9a-833d-df796663eb1e', 'e7d919f5-eb4f-449f-8d0a-5c9a46b584f1', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/492fd4ac-884e-4252-884b-20b582cccc4b_z7679513982774_f0f742971c21a597a5c843393c9e378c.jpg', false, 4, '2026-04-02 02:02:32.181761+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('466b5267-cc39-41e6-8e6c-68ffaa085993', 'e7d919f5-eb4f-449f-8d0a-5c9a46b584f1', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/7e8c5477-876e-43f6-a02f-07c7b89393f3_z7679513982780_7acd0d188506f3fadf76ece8dc2dc456.jpg', false, 5, '2026-04-02 02:02:32.181827+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('8d8c1007-44fb-4fe6-963b-9a5de3ce20cd', '3d59a9d7-6c4d-4b72-9620-ec24af5d2f7f', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/ea127208-dc16-416c-b477-49c27510c7d3_IMG_20260402_090619.jpg', true, 0, '2026-04-02 02:06:34.774622+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('a9f74aaa-7b3b-4794-bc97-1cd99d15cac1', '3d59a9d7-6c4d-4b72-9620-ec24af5d2f7f', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/0e3ac6a8-0277-4e40-b608-e0dafa31fe8b_IMG_20260402_090618.jpg', false, 1, '2026-04-02 02:06:34.774765+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('3be87a22-eb4c-4a12-90f8-f5fe8980f47a', '3d59a9d7-6c4d-4b72-9620-ec24af5d2f7f', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/24161480-e43d-4d72-9d17-a9f1c584d2ee_IMG_20260402_090616.jpg', false, 2, '2026-04-02 02:06:34.774868+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('2037cfbc-68f9-46fe-9387-4c5114ebc8a6', '3d59a9d7-6c4d-4b72-9620-ec24af5d2f7f', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/52139fc8-3331-4452-bf98-5bd28c53c4f1_IMG_20260402_090614.jpg', false, 3, '2026-04-02 02:06:34.774947+00');
INSERT INTO public.property_images (id, property_id, image_url, is_thumbnail, sort_order, created_at) VALUES ('d51b0e05-9849-4a8c-a5ff-eae8df655435', '3d59a9d7-6c4d-4b72-9620-ec24af5d2f7f', 'https://leaselink-storage-bucket.s3.ap-southeast-1.amazonaws.com/df99b88d-2ffa-4411-8291-16b1b0cab5c1_IMG_20260402_090612.jpg', false, 4, '2026-04-02 02:06:34.775401+00');


--
-- TOC entry 4682 (class 0 OID 34418)
-- Dependencies: 232
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('8b6c4a66-1f12-4ad8-bf0d-0e73cba4f915', '9baf9204-0710-46e6-875d-64493dbd92aa', 'af82b3fe-b7d3-4342-a07f-1cdbc65233ee', '$2a$12$m0jMGud730ov/1RvrYZOceuP7y6eL/YMxu85/n2g5MBLzrh6GCSmy', '277ca6c5-2e6f-47b1-b2c9-29aa9a3da628', '2026-03-23 17:02:04.962259+00', '2026-03-30 17:02:04.96126+00', '2026-03-23 17:10:13.0497+00', NULL, 'Password reset');
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('d25031c4-d815-45dc-93a8-ff0fc1972cd8', '5f87c056-878f-414f-92b6-769a53b76880', '28eeca87-18d2-44af-afde-58f5ed6927c9', '$2a$12$5kCyeFW3dfbKWqS6UlpbYeeoGwpaLZHJc5KllBbIkkB.uOgwPz5I.', '1ca5dead-c347-4aea-9de6-94fd9a312182', '2026-03-24 06:19:46.151579+00', '2026-03-31 06:19:46.150574+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('9ed0dd29-3409-4fc9-8473-f16fb343f711', 'd7ae594f-f5d5-426d-8e63-5ea768b1c3f5', '28eeca87-18d2-44af-afde-58f5ed6927c9', '$2a$12$aPvqcNETkfHCGx7vKX84cONLYBS5tioZSh.bubM0HdK2UlUJrlSHi', '5ed93a3c-9746-4f08-9a01-8fcfe00cf727', '2026-03-24 08:10:51.438827+00', '2026-03-31 08:10:51.437823+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('a735a2e6-77ac-48a1-af34-38e446a9df8d', '1e5ee1d7-8fc9-4854-aa40-c249367bd7cb', '28eeca87-18d2-44af-afde-58f5ed6927c9', '$2a$12$CZ2TnhsoTSqdIW.iV75reeunAqYmp5XcghmLyiFcf/DIlLLvZnG.S', 'e94f974e-202f-4ac7-a06c-baa97ed9a23d', '2026-03-24 09:20:26.305194+00', '2026-03-31 09:20:26.304194+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('516322dc-97c4-4627-a12c-02ff48ed9ec2', '379d4414-e32b-424f-93d1-12b78a7fa20c', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$aEpMFnHNyCcKL1EAtWX1Hey8sPs/gOI5gJrlKtBqPO31LRmp/ZRuO', '2a79235f-f324-4edc-933f-591dfb11bf87', '2026-03-24 09:35:05.148404+00', '2026-03-31 09:35:05.147404+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('8131d422-1a54-4ed3-bb47-965b3e38d2fc', '0f3c4153-064b-408d-adde-6618483fc0f2', 'af82b3fe-b7d3-4342-a07f-1cdbc65233ee', '$2a$12$ITsJ3SurTKZyRiCsbfbNqOwALmyst7P70ixg1wqmO3fyDxdFk6hci', '33462a25-9b25-4858-80df-9082d51416c9', '2026-03-25 03:35:26.490932+00', '2026-04-01 03:35:26.490932+00', '2026-03-25 03:47:33.133323+00', NULL, 'Password reset');
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('032c6176-ed36-40a0-8f35-1f4ab1ae9143', '88c6bc97-8713-4d8d-98ad-19c71f5207d6', 'af82b3fe-b7d3-4342-a07f-1cdbc65233ee', '$2a$12$g/MxLcEMiTuMODMu.hfAXOQlT6RdwBk58jP3zXzpkv0PgYZ27bKsq', 'e5f750a0-2513-4974-a5c7-0b77333563a0', '2026-03-23 17:10:52.177193+00', '2026-03-30 17:10:52.17619+00', '2026-03-25 03:47:33.133323+00', NULL, 'Password reset');
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('f4deddf7-cbbb-4399-9f36-0ffd1b4286fc', '1f7299f6-5f6c-45e4-bd7d-34ac9d301740', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$wM4jy/EuY/z2/Or.c/SC..2PxRR/brXSAr.JVF0fl47Xwt.8UG15C', 'c3f8b856-3ef9-4d71-ac1e-8af178618098', '2026-03-26 01:53:58.487248+00', '2026-04-02 01:53:58.486245+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('54b9558a-c059-45da-a07b-d7acca555067', '8bbb5dd8-13b7-49c0-ab25-325fbdfe729f', '28eeca87-18d2-44af-afde-58f5ed6927c9', '$2a$12$mk5iyBPeHh56MIfHao.iNe5K9S57I/W6sEupmb.w98WRvz60uvtmy', '3b2fe557-e67a-4c35-87de-003dd242b577', '2026-03-26 02:00:15.538734+00', '2026-04-02 02:00:15.537732+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('26b75f1d-6e45-438a-b149-3fa1aa16d7d1', '9a37163d-320c-41cd-b96c-c96400251248', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$.4ZGp9dqqiUUBcYpfguJTu9hcLVBhBOAd6XTfgt74lx04PhQskvSC', 'bec2c5dd-6cea-4229-b304-3c34379625db', '2026-03-26 02:29:09.255204+00', '2026-04-02 02:29:09.255204+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('60616f36-1d89-49e0-b391-e57d006aeb49', '9a04b5eb-2065-4abd-a63d-0963283f908f', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$aLulhM2.TQKjGV4LneF0DOzy7FefjxJhqKeNtEiTxIR/lnMqLzNFW', '19694f90-02dc-4243-b417-b1aeda1c789d', '2026-03-26 02:36:07.377225+00', '2026-04-02 02:36:07.376223+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('a08c8233-f06d-4409-a144-128410eb1e62', '88f9017f-a86d-4e63-a548-cd8d0cf6a02e', '5f0c2f5f-00e3-4f89-a5ac-b2c39ede0104', '$2a$12$.5gYkNseHqPhNgQfhTbncO51m.QuS6sVlddzbS4iXLUwWfZwggUkq', '3e602655-724d-42bb-bb1c-0c98b72ed122', '2026-03-26 02:36:30.083123+00', '2026-04-02 02:36:30.082511+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('b66b1faa-0150-4a7a-9c8e-b44d28659955', '140245f8-54f7-4845-85ea-d5c897484796', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$kGs8edqOPkSZcx6ULXHo.e6/rLvZfofEklqE1S4fW3AXwaQvgxiRS', 'a96244e8-b452-4bd5-80f8-a50599a99aeb', '2026-03-26 02:38:16.005569+00', '2026-04-02 02:38:16.005569+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('e7f11873-7941-4972-bdce-9ecd7523c2a0', 'a27cefc3-bee6-4f67-9340-e00ea3a6f3fc', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$2X.rPOWUsq3QMFLVfQ2cfOhCGiyAttn2EUzEH6o9dZbMMJ.HF2EWS', 'e6d292ce-6333-4a9e-973a-d5a4e0d35918', '2026-03-26 02:47:58.541473+00', '2026-04-02 02:47:58.541473+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('fafc30a2-6ad9-4b68-af03-fa1625e85e60', '3a8ae196-d087-4ba0-98b3-fa5676807eb5', '28eeca87-18d2-44af-afde-58f5ed6927c9', '$2a$12$DaCogCW1KvIdMiRTSX7wBOJXORpP/87HhJLXx8csgH7.Sv4Ie41xi', '5a50d6a4-575e-498b-ada9-ff7bb2847a1a', '2026-03-26 02:50:41.96966+00', '2026-04-02 02:50:41.968668+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('6ff4e071-8146-4f34-881b-0ec2fe61fe94', 'eaf6b1bf-106a-4a50-8e8d-c393e28fd3fd', '28eeca87-18d2-44af-afde-58f5ed6927c9', '$2a$12$E.fFGfJ.Mkxmt21Dl30F2.4n8IA6r84/GHqw7m.hv1rntyZxsPqLu', 'f4fa6e72-c11c-417a-b63d-44151ba1d2c6', '2026-03-26 02:52:39.250256+00', '2026-04-02 02:52:39.250256+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('1f1a397c-9ceb-4353-b2d3-05fbbbf9dd71', 'd341224e-f349-46d4-9a2c-bdf0b1e78f6b', '28eeca87-18d2-44af-afde-58f5ed6927c9', '$2a$12$qneOeexIFKT4RnOzkrleV.hVf9kafKnKHvbseUFB.qrTady1nE1QW', 'd8a1e5fd-bacf-4c65-b106-0c95efa9fc4e', '2026-03-26 02:53:12.848398+00', '2026-04-02 02:53:12.848398+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('6d83450e-b679-4a3d-a832-e6c7af5bfac2', 'df2b876e-7a7c-4f44-a4bd-58a8adadd8ae', '28eeca87-18d2-44af-afde-58f5ed6927c9', '$2a$12$23eysSf2enuZa1.0FWw8TO..NrP7l5Sgqns/dJd6sj9pTkGUNS6zy', 'd0e20844-b10c-41dd-8810-77db148f050b', '2026-03-26 06:05:56.788894+00', '2026-04-02 06:05:56.787892+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('c766937e-c8ef-4db1-952e-a8d4fcc8981d', '7813a742-089f-401f-8fad-37a390657ed4', 'af82b3fe-b7d3-4342-a07f-1cdbc65233ee', '$2a$12$DTkmAgSnnWFFJl8rY/gKqe/NfiWh26yLAQKHt6MQCaslJmxAKoc2G', '74480f90-351a-411b-b750-14eb3b92e682', '2026-03-26 08:53:00.756082+00', '2026-04-02 08:53:00.755081+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('8e0a6bae-b046-4868-b0e4-934186174c42', '2ca12f78-c0b7-4297-9e27-041d79294bee', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$g5hvsIQgCMU2m4mPcG2fL.9187htVhqyfa39HYCz.qvdjk7.k6xeK', 'f8b29952-d248-4b95-be9d-fda1198f8567', '2026-03-26 08:56:23.510654+00', '2026-04-02 08:56:23.509651+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('fe18bead-2c04-4399-b3a2-f6b51869669b', '89b0c2d7-8e99-4a94-9d0d-477340979473', 'af82b3fe-b7d3-4342-a07f-1cdbc65233ee', '$2a$12$pOrOx4mXjsHmrOaWsgm5jOsSSuAaXaf04c1pFkytGy6ae/5TYgs1e', 'f4a0e574-d882-41a1-8dc6-880231405fc7', '2026-03-26 08:57:13.393883+00', '2026-04-02 08:57:13.393883+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('1e8e4460-a35b-4a7d-ba64-a5a8fa3c89d9', '46d3d0ae-0bed-4b95-ac32-8d667e3beb29', 'af82b3fe-b7d3-4342-a07f-1cdbc65233ee', '$2a$12$ByUjZGQ04o6ZxwU/JnH.dOYf7.cVNOhIIN5wkciYlHhpvdEtILQuu', '25f66e39-d838-4dfa-afc0-1117a733f02e', '2026-03-26 08:59:28.337117+00', '2026-04-02 08:59:28.336217+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('8edac144-de94-4dbd-becf-08c110e881e4', 'dc4d84be-f004-41cb-9534-e303c4ee7b58', 'af82b3fe-b7d3-4342-a07f-1cdbc65233ee', '$2a$12$1cRpHX/uSpdpm6rh8DGgJu2XY5aaNs3WFxwz8IauWvvYpup1TVUMK', '136ddd7d-021a-428d-a894-9c9ce6065828', '2026-03-26 09:14:47.878793+00', '2026-04-02 09:14:47.877795+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('5eacafff-4ce7-4f98-8e6b-0118cb793463', 'c80b4e9d-4af1-42b0-a3a8-fc98ae57960d', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$nA9KlP8fdtmGY5U7v6G6Fu3SxgDuC02gyhIzNSu81Goo2BPnTif7e', '2d802df4-a4e6-491b-9973-35561226bbea', '2026-03-26 09:25:43.305545+00', '2026-04-02 09:25:43.305545+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('2c3950e3-7740-4548-a1ca-425e0ae3a69c', '9b65f1d5-ae70-4673-b9e5-6e6ce039e9e7', '28eeca87-18d2-44af-afde-58f5ed6927c9', '$2a$12$pcvsQBcWpdPwXjoPAIO/nOzWwyK2k.HzPn4SYkrdZbmaMswkKFSWO', '3f13d3a0-e47d-4ed7-b20e-b65803c7f28e', '2026-03-26 10:11:02.20755+00', '2026-04-02 10:11:02.206213+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('170de585-28f8-4dd2-bdf8-cbba11ad510b', 'e2fd76c3-70d1-4d52-912e-570ad64d8592', 'cfd595c3-035b-4243-bcfb-edb7c549df30', '$2a$12$jECWuQEhDPH/zwd2nVe/0uc/956yTDtgIZV.WrK8EfMQzDi3FlzT.', 'fa9760e8-f97a-466c-b62f-73f3938cb98f', '2026-03-26 11:42:15.549678+00', '2026-04-02 11:42:15.549678+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('8275cdfe-7f28-4fd8-82af-07a18f0ed637', '074e6857-5b75-4661-ba91-96a13ff4e1c9', '5f0c2f5f-00e3-4f89-a5ac-b2c39ede0104', '$2a$12$eH4fa/00aauhrmDVaafo9eFgEzupstCsQe3JDmgQMop8i9DPpFbt6', '5d5e89d0-ac60-4c67-8aaa-22a4d0124822', '2026-03-26 11:52:19.875013+00', '2026-04-02 11:52:19.875013+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('86ff5041-d0d3-4896-9a88-62169b112bc2', 'ba39c69b-81b3-4af4-b267-539fc5fe7b9a', '5f0c2f5f-00e3-4f89-a5ac-b2c39ede0104', '$2a$12$dIp.cuBKeJUTC2/LfYDEr.Pc6LE8qfzOultbiA2eD5fyP/QXBfYgm', '737e288f-e3a8-46f9-aad7-5dd39894db67', '2026-03-26 11:57:52.048063+00', '2026-04-02 11:57:52.04706+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('07bacc2f-c931-4c76-acc1-38f081eca847', '9738924e-1ce3-4c09-88a2-3ad416c2296d', 'cfd595c3-035b-4243-bcfb-edb7c549df30', '$2a$12$3wWxC0jQS6PMlOYEa4feTeiJa7nFmZinD78gJ0kZ4ggSGbFgxCQMq', 'b987571d-3b25-4d89-8cff-e21d0ab74480', '2026-03-26 11:59:16.309891+00', '2026-04-02 11:59:16.308833+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('00077a21-fdcd-4ced-a526-f5730caf0e0e', '3bc29829-8fc0-44a1-bb6d-26ca9a1d6915', '28eeca87-18d2-44af-afde-58f5ed6927c9', '$2a$12$YWoAEzLuoMLEoNJuRTRPteJC60dTTrHqLU3qlo4j8Mk6rTqtKe7KW', '47606862-df89-4487-86dc-fdf1ddd2d7dd', '2026-03-27 01:43:23.980044+00', '2026-04-03 01:43:23.979041+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('d69eabfa-7813-4f35-b394-064f7078ade6', 'ce65e402-4536-4194-9f39-e83e20d341d8', '28eeca87-18d2-44af-afde-58f5ed6927c9', '$2a$12$cOIL2I4.5PL1u3IkQoj9EuIIKCFjDQX8we6HZqu3BxHts0rIRVULS', 'f882c002-2bf1-4c8f-ad53-6f7ace2d283d', '2026-03-27 02:44:35.850427+00', '2026-04-03 02:44:35.849662+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('8eb37bca-d2e0-47ef-8f43-56267c5b0fe8', '13697863-375b-4f05-9a10-00e9f54720a0', '28eeca87-18d2-44af-afde-58f5ed6927c9', '$2a$12$VwMHeXeL0/E8fWJifhMxa..g4NeglvQrPuq9UfgFMyIgy0IPVKney', 'bfc8217f-42b3-4f06-9518-007db4f5f5fc', '2026-03-27 06:15:16.188184+00', '2026-04-03 06:15:16.18718+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('3d02b163-ef52-4ee6-9535-27028d368d0c', '57cf0ed0-ca67-4485-836a-bedaf5f8652a', '28eeca87-18d2-44af-afde-58f5ed6927c9', '$2a$12$aBTOjMn2BAFoow7930LWf.o4zb92HSXEvskTpatZ98ipaciUzOvKO', '2ae76409-a296-47b5-9119-c88e6bd6d689', '2026-03-27 06:32:27.304086+00', '2026-04-03 06:32:27.302267+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('f5677684-b1d1-49e4-bf00-07c5b7c6203b', '674baa07-83f3-40b3-8d84-d1dc363a4112', '28eeca87-18d2-44af-afde-58f5ed6927c9', '$2a$12$y3Lvnmhrz24LfT6kGx9vm.JIEPnKer72bxVji.Xf33MJwX9/KEPZS', '81f412b0-e32b-41a2-8b1b-6c86fb253b0b', '2026-03-27 07:36:04.463753+00', '2026-04-03 07:36:04.462749+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('4e092b06-884c-440f-9276-c6c17f839545', 'ffccc9d1-8207-4f08-a841-ea6c4a4c87bc', 'af82b3fe-b7d3-4342-a07f-1cdbc65233ee', '$2a$12$cNAXw5XuL0XHGFIYZ3uY8Ols31IBJsbVa996AU1PrHPJIn8/GirhS', 'f832cf75-1e5d-48a0-9ad5-a125fd423cd3', '2026-03-28 08:56:19.781545+00', '2026-04-04 08:56:19.781545+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('f8de6fdd-7756-4c2a-969e-61cc347a4795', 'cc57248f-0a53-4a56-98fd-19b9b5ede93b', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$CQK9lHDCaJAG3CQMQPJO4eiATDIH9ijzTtdClwSE3.CiZVLyHYO2O', '30521b37-8fef-440f-8792-c1f058fdc26c', '2026-03-28 08:57:20.592125+00', '2026-04-04 08:57:20.592125+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('c5d07d26-be53-42d7-bf6e-f300ebf82366', '94e9a290-d903-4630-9407-373a5fe9e1bc', '28eeca87-18d2-44af-afde-58f5ed6927c9', '$2a$12$LJ.Ipxt3zxEW92Gougbwn.rZtvYxyz.1tdgFva9i5.ENMFdVr1wBG', '30ca3b11-0f09-4914-a0e3-4b5a6191dc7c', '2026-03-28 09:47:51.926265+00', '2026-04-04 09:47:51.925169+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('760381da-f067-4293-85ed-883c323dec23', '845fa58b-8a6a-4f96-af1d-00a6c3e9fc2b', '28eeca87-18d2-44af-afde-58f5ed6927c9', '$2a$12$PB5V8aliTvZEIFsx.HTUNuLQfBaocp93.3GQT8Ro8xr4SwMYsbfTu', '54dd37cf-6d83-48a1-8b0f-7b53d9e7f405', '2026-03-28 12:44:52.416052+00', '2026-04-04 12:44:52.416052+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('b7acd3fc-7585-45f5-9be8-f31662646ba9', '124c2c92-3bfa-40e7-a588-295f124e2829', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$0ip2o5Ptq6fCzkAsStz8xuajWUGObuE0pszoMMnrK.bnJyX49DJxC', '7ed2217c-f38d-46d0-b9d3-106e70b51578', '2026-03-28 15:16:03.403364+00', '2026-04-04 15:16:03.40236+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('bd8f8396-5567-46ba-a414-83b863cd9ad6', '2522743e-ca0c-434e-bd92-46f68d819816', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$eBwcvdOK4yVIr4dBZ6ikCeascL2ykypEydaXYvQX6e1lqUNHmoqpS', 'f329b93f-3706-4861-88ea-ca0ecc946c2e', '2026-03-28 15:44:42.13746+00', '2026-04-04 15:44:42.136453+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('1190e10d-cea2-47fc-b1c1-48779be4b4a7', '89ccb996-c534-465f-af56-b98a57ec0e93', '3ec0c781-ed01-4efc-b02e-6ef9ffe05576', '$2a$12$5l8VuxnHTCjK6B6TX7IgJO9wR8jnQL8OgjkoIdC7qrGeu4R/l31ry', 'd00c328a-d07c-492f-a440-d416ce2a1c91', '2026-03-28 15:30:05.831621+00', '2026-04-04 15:30:05.829619+00', '2026-03-28 16:58:02.583775+00', NULL, 'Admin locked account: Nghi ngờ lừa đảo, tạm khóa để điều tra thêm');
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('6a2a05bc-ea41-4de2-a9e8-737bf3a9386e', '85cbf8a8-3ae6-4c59-89ad-bbc7664aaab1', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$WZyttiqupI2WtRi2QPr4A.NjR7gEAVuxKa.lt.uvCYIH4Wy0ooOKO', '17979416-0b4f-440c-a1dc-65552641fd6c', '2026-03-28 16:04:55.517822+00', '2026-04-04 16:04:55.516818+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('c55e06c8-e3fa-4ae2-b4b8-7c52cca86b7b', '1b3312e5-705a-48f3-b60a-f8603794b15d', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$g4HNTr2YtlWdhF7pXE2.Ruw16rAeed6c9i1KlMNL33S1vwOZ/1zZ.', '9fa3b5c3-c9b8-4bdf-91ab-03623f0e0102', '2026-03-28 16:11:08.091635+00', '2026-04-04 16:11:08.091635+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('4cc2d376-24f5-43a0-91d6-0f41b863cecd', 'bb1eea6d-8c49-45b4-a528-263a57e185f8', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$R0e7qJYQRtbd78q5A2Gm0eLzTCjExP20YwEJUK3AJA8fM0LVsVgD6', '1fdca70e-07e0-41b6-a971-7473d13a8b6f', '2026-03-28 16:27:30.228005+00', '2026-04-04 16:27:30.228005+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('8f15a5da-101e-4f2f-9954-be68658221b5', '3d4bf4b3-0a60-49bd-aa57-274a48276971', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$g3G6r9yKESfVwxKHcrFX2.B0g6MyvaXJm9bZdXWJiv4OvDlkC8o7a', '338aefc7-99f1-44b0-af3e-eccbbaa6e8d6', '2026-03-28 16:30:10.727914+00', '2026-04-04 16:30:10.727914+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('8714c770-c3b2-42cf-b16e-663ae947da93', '3d21adc1-9a6f-40c7-94de-0ba948059570', '3ec0c781-ed01-4efc-b02e-6ef9ffe05576', '$2a$12$3Pzcz9kvgM.9CW4axy/NQOMBfMliFdlzeyGc9bwGBJX1PmgvlnJZG', 'a1a8e860-e39d-431c-b7ce-471e95843ae1', '2026-03-28 16:21:36.72074+00', '2026-04-04 16:21:36.717728+00', '2026-03-28 16:58:02.583775+00', NULL, 'Admin locked account: Nghi ngờ lừa đảo, tạm khóa để điều tra thêm');
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('58cc7dbf-8ae2-4941-85b3-8f9ecf7b4ff4', 'f571ef2d-759c-409b-9f73-fdf44035bd20', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$PHS7/7spda9y44sRjbk3H.8upo.EdstQTmThCgm5k2Z18rfGflpHe', 'c21396c0-c27d-4744-8bb1-c7dc148d558d', '2026-03-28 16:59:36.590567+00', '2026-04-04 16:59:36.587566+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('36833328-dad6-4266-beb8-0e7d5b6d1311', 'aeaf688f-0f22-408f-a16e-53a77f669990', '3ec0c781-ed01-4efc-b02e-6ef9ffe05576', '$2a$12$LdJMHPfwaDFc/xTkAicFReenjof9st0wzTFbxqHMhpkCx5x4/w8h6', 'ed6bd9ec-ca5a-4c26-bc99-7095c45e84a9', '2026-03-28 17:01:43.738314+00', '2026-04-04 17:01:43.737806+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('87d6a88f-ae1f-4472-82b6-4e9bd41acfbe', '746a15d8-57d8-441a-917b-e5d078d05351', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$Qnm0gKHc9CFvwezf9DNeqe7mmjmtDzaCzcZSnMgGYlEj3PYXBkMiW', '3211e5e3-7a92-4a07-8c9c-e84a0f1d105d', '2026-03-28 17:02:41.882033+00', '2026-04-04 17:02:41.881031+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('a7e04600-69af-4dfa-8fb5-4b3aa08b1569', 'a35f8eb6-8da4-4ca2-9b06-b15d74ab71fd', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$z8pf0GxW7gpQnddOuL6WNe5drYdWJM1rfVR9lPU8iJEOaBs8jZApe', '99ae61b1-8c61-44f1-910e-a20fb1612bbf', '2026-03-28 17:22:35.231946+00', '2026-04-04 17:22:35.229946+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('0057c0ea-a0ea-4d9d-89a2-fd5a8703ae25', '720a2133-4a44-427c-8580-2e487090e020', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$rrjyTPIsDQ3VYttlpILR3uHTmRSghTC45PAAydFTgsBsC8mdxdBGC', '7821f3be-bfc9-4b88-97c1-cb0c3672ea8f', '2026-03-29 01:18:38.407513+00', '2026-04-05 01:18:38.405938+00', '2026-03-29 01:49:29.211775+00', '933bfd32-37e2-4a38-b046-ce3558e6b2a0', 'Rotated');
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('4f7d0161-3b65-4505-83cb-fa764ce184e3', '720a2133-4a44-427c-8580-2e487090e020', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$QmREKkfIrJSmVK9pP6YT/.NbbWi.UytKU9JCc1E0crWLuU1i/y.ui', '1fd08682-1a6b-4ebb-a270-a4a93efd8dfa', '2026-03-29 01:49:37.462436+00', '2026-04-05 01:49:37.461436+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('933bfd32-37e2-4a38-b046-ce3558e6b2a0', '720a2133-4a44-427c-8580-2e487090e020', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$PnuumV4vfkZU4ijOlabvzejXlxh8vwDrkpyCOrdjFtRjl1saAQ/Hi', '9a59f030-b4b5-406a-a2f0-2d6a601570c2', '2026-03-29 01:49:29.203774+00', '2026-04-05 01:49:29.194938+00', '2026-03-29 01:49:37.462436+00', '4f7d0161-3b65-4505-83cb-fa764ce184e3', 'Rotated');
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('a2eb5014-bfa9-4e1c-9105-6f8484f470c4', 'cda0130c-6963-4f46-85e6-0f1cadec022f', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$AbaS4Jhxdgs0hcNk73Swk.RuY4BVoBtFj5hIB7XNmt.xpifXeIIBK', '268a5ffb-6239-4a03-b9da-91b66ee541e6', '2026-03-29 01:49:48.311364+00', '2026-04-05 01:49:48.311364+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('3e144959-721f-4f25-a5c0-3c1999f69a2c', 'afa3ed5c-15ae-4de9-a2d6-b5519841b95a', '007deeb1-cee0-47f6-9467-6450433c4315', '$2a$12$1k.t8I4HpeJzZsHLOVKFmOJaydsrq55Ztkiid014KvwyuC18RuO7m', 'da857671-ef77-43f2-b3f3-18ebf7b8cd76', '2026-03-29 02:16:19.231681+00', '2026-04-05 02:16:19.227495+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('eac4ff71-a8df-4a1f-8d94-420a3a833131', 'a4e932e1-af0b-4b8a-87fc-228e5c1223e8', '8508dcf4-5077-4f8a-9bff-52a08f472dcf', '$2a$12$RbzZyVwI9kgvM46dwhY3l.aQ/BZSwiQgq/PDN8FuDzeD2J/fdmVcG', 'da26d9fd-eaca-472c-905f-fd5238060226', '2026-03-29 03:14:40.808433+00', '2026-04-05 03:14:40.805218+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('418d6e4b-4d01-401e-9fd6-4ee5b29f416c', 'f4cdbc8e-1acb-44b3-82ff-33cc50b838eb', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$IH7.Z6y3ZyIY/YytIcZGZuB6RpUT0U/hOitbFlW9ekj51kNwF9F5q', 'a290da34-b7a6-4b2c-b559-47817338a94a', '2026-03-29 03:15:21.810333+00', '2026-04-05 03:15:21.809245+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('30bfcecc-7250-4e05-a658-47aa44b2536e', '4bee12c2-9bfc-45ab-b2e5-d1a97557f393', '8508dcf4-5077-4f8a-9bff-52a08f472dcf', '$2a$12$T3xc/j2sYogcfTaxJFituunAcWUTXOvrH6dDc0.bu8OXM1El64CzC', '3bafe5b3-88cc-4383-ab78-5736b9bfa2a0', '2026-03-29 03:16:18.690993+00', '2026-04-05 03:16:18.686951+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('a909d1bc-2c42-4d30-a94f-f0d2a5253387', '47fa3c2b-9546-4590-88be-876307fcdb38', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$zm7t3/8Fb7dZRwLFbWFv/.SS/2GDg98hjsV46ln03VYGhthWW4Wbe', '529cb07f-75a2-47e1-bd92-7eab1f011394', '2026-03-29 03:52:01.477276+00', '2026-04-05 03:52:01.475403+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('c0623d34-689c-4cb8-9994-554ce42802dd', '2b6a8602-0e25-42c4-adb7-b52d7876b8be', '8508dcf4-5077-4f8a-9bff-52a08f472dcf', '$2a$12$yIIRnVX4ezpYBZo3Sv4tJOQc.qVV9CCx9ihZVqJfwXJG4Rv8MGOlS', '032215f1-2744-487e-b60c-b69ef4e20351', '2026-03-29 03:58:54.735221+00', '2026-04-05 03:58:54.732207+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('d0b80b00-42c8-4209-9b95-f9197b0d7015', '809ae27b-61fd-4559-9c43-989446fd9d28', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$NtXe8.JuLBf1gUZLyqH1duAT9gFQ/6twKxKO4LcXaVTmtJ1B1yYOG', 'aafe6ef2-a23b-4a09-a5d1-19665676aef2', '2026-03-29 04:05:11.635019+00', '2026-04-05 04:05:11.635019+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('6e747025-0b78-4e44-ad94-d832f0e7322e', 'df4d2d02-466b-410a-b9d6-6bc189583325', '8508dcf4-5077-4f8a-9bff-52a08f472dcf', '$2a$12$CX6Yg6gtK7xcHRFbtNfFjOgwDfyv0HVZew9gIQV4b/o1Gkx5oyJwS', 'eee3080b-9bea-4c56-9977-85963f8a31e8', '2026-03-29 04:06:06.080134+00', '2026-04-05 04:06:06.075592+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('9f5acecf-c06f-4647-b29f-c52c3ef6db05', 'fe764c4c-3508-445e-9ba8-b686b2c43f83', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$8XC5F6pyXydng.ymbyT5k.K3OmVyYxVOx2dwZRiJ2IhW80v/a/4WG', '5a2d239f-42dc-47f5-9df2-977dbdaca2c1', '2026-03-29 06:40:06.873258+00', '2026-04-05 06:40:06.872168+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('1eda4412-0d1f-4e12-8953-38f8b512b2ee', 'c30dbaf1-a47f-4e53-a2cf-611374d0e723', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$kbEr2QY5szBzhIQXrM6LfeAXJFPLlzsVY3Qiw1wUT/J01hUypOU2S', '070317d5-9882-4b90-8e4c-48be27eabdbb', '2026-03-29 07:11:44.454471+00', '2026-04-05 07:11:44.454101+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('6ac6f1a8-e4c2-47a6-a58b-63c64129b2f2', 'd3e7bc22-5013-4fc4-a161-571cdd848da5', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$p9UFX7MIlbH9elucSo4IdeV9zp84xiqmq/2J95neLWKulMSPgv8YW', '8e68e40c-dd58-44c8-bd06-4b28752fd0ad', '2026-03-29 07:13:11.574892+00', '2026-04-05 07:13:11.574457+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('34ac9af2-fd7f-4d00-a12a-36a03185662a', '81847009-6bed-48da-aeec-3197157a7349', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$SpFe3ULPoOFe/oiAPt/7oeOJ6LZ05YfJfhWhYLp/agMyb76/gIO56', '1150590d-2745-44f6-b8e6-0e38271fffa9', '2026-03-29 07:22:24.273707+00', '2026-04-05 07:22:24.272257+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('00173afc-5555-44fd-b762-a3f0a4f3bb27', '9aab618e-5e70-4ce1-bd1c-4c014e86bd96', '0e82682f-af39-4947-b07f-72952c92976c', '$2a$12$cppcKDsgYVvmNL3mJTubxus3YvQ0mReQyVxDfy0J45Ky1gMdgCQH.', '2e4c1270-83f7-4d50-accd-8329598b1aa1', '2026-03-29 07:17:53.252124+00', '2026-04-05 07:17:53.251751+00', '2026-03-29 07:25:13.962942+00', NULL, 'Password reset');
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('63611688-75ca-4b97-aeb6-841d48c721de', 'ca7f959a-c750-4f01-8f0b-0447fb725989', '28eeca87-18d2-44af-afde-58f5ed6927c9', '$2a$12$gW0pEbtXxuW7Q5qtv66YGu50prL/UYBWp03Y/P85qvncah70NIDFS', '390356a5-9835-47b9-93f4-71ebf4fcc2d6', '2026-03-29 07:25:37.804225+00', '2026-04-05 07:25:37.803262+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('816d8109-e238-46b7-b989-e60b1a4ca126', '62a50eeb-f706-49d9-9c32-950c7f8de9bf', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$fXpzTBiBRotvWu/YqNLSGuZahoKHHO8d7gO4f6COQ/zRnom/ZAw5a', 'a850ce2f-7198-4093-bf51-47d1878cd948', '2026-03-29 07:38:01.042148+00', '2026-04-05 07:38:01.041816+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('4c662a7b-cde5-43eb-8857-b6fc7829fecb', '15b87586-866e-451a-9fcf-383b2d2c84e4', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$/gEwEy7WQbpFhn0iNVUZTOlmBUwQ96aG6CkkziPYOLjncAmxv71JK', '1c6c7e43-fec8-40bb-a3de-dda48e1538f5', '2026-03-29 07:44:26.23138+00', '2026-04-05 07:44:26.231012+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('5670fcf4-1fed-4835-a1a6-020b796cecbf', '67aa4abe-65d8-4291-9083-a0befaba5e22', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$yXvffca6FxveubbsrHI3XurgdBrmIhx3y9c.TBWHl3ASqfljYEBYa', '54292512-84cd-43d5-8fcd-8fc55416fccb', '2026-03-29 07:45:30.925656+00', '2026-04-05 07:45:30.925052+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('28528e82-c9c0-4976-a76e-f0e7600520a8', 'ecdba08d-09dc-4e53-a51b-ced7dbedd57d', '0e82682f-af39-4947-b07f-72952c92976c', '$2a$12$yTLxztP33GFUcfPFSz0NJOQR7d5XrIrI172fpuoF7E5PijLt/goJK', 'bacb1480-8494-41f2-a026-ad6fed7a0443', '2026-03-29 07:28:08.275006+00', '2026-04-05 07:28:08.274626+00', '2026-03-29 07:48:58.3512+00', NULL, 'Admin locked account: Nghi ngờ lừa đảo, sẽ kiểm tra thêm');
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('8c374648-70c8-4b76-bd93-047bf246e034', '1a6f637e-cbdf-45cb-9162-bebaf33e223b', 'd0740f8c-5c94-403d-827c-6ab31b04ec49', '$2a$12$lFLF0lgt3TwXt2cK7eB1lOFyovAdquBooER530g0nAG10YltwgzU2', '4bd027d2-a2bc-44f0-948f-8a389165a2ca', '2026-03-29 07:22:08.082884+00', '2026-04-05 07:22:08.082372+00', '2026-04-01 14:03:13.116422+00', NULL, 'Admin locked account: Nghi ngờ lừa đảo, tạm khóa để điều tra');
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('4e3eb796-57cd-4fea-b9d7-f92bb310f126', '21994c56-6808-4676-a5dd-5a6ff46c2d4c', 'd0740f8c-5c94-403d-827c-6ab31b04ec49', '$2a$12$K4A3NpbLt9NNfEyxq/rPjea0nMeF5VGpb4h1mHujB2bfwRlB.BIdW', 'efc0377c-113f-4116-8f6a-f8ac2af9b6ee', '2026-03-29 07:37:08.901054+00', '2026-04-05 07:37:08.900699+00', '2026-04-01 14:03:13.116422+00', NULL, 'Admin locked account: Nghi ngờ lừa đảo, tạm khóa để điều tra');
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('d2b0ea7e-0685-44be-8643-c68aadb802b4', 'fa58db9c-3ba6-4285-a790-972483a9ffe3', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$.bpLrvTA2iNb7YG4zoj9TO6vVWN6nB3zLv62pjKITaacivcV4hIsS', '91287c7a-bb73-4737-8630-9b6a138b3b37', '2026-03-29 07:50:16.199424+00', '2026-04-05 07:50:16.199148+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('9b157f82-1a2f-4311-b245-144c9c5fd0c9', '717374a8-b22b-48cf-acb4-f5fa4e0d4264', '0e82682f-af39-4947-b07f-72952c92976c', '$2a$12$3SEBFcdWuu6QYs50Eh9ZBOn/rvziAmnGjYWeNAAI7vEHqscM785Ei', 'b0e40ccf-62ab-413a-9590-b55519ad0b49', '2026-03-29 07:50:32.504374+00', '2026-04-05 07:50:32.503973+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('f5c64712-378a-458d-b5c4-972954fca523', '0f6095b4-1200-4cae-a086-d360fc9bc2e5', 'd0740f8c-5c94-403d-827c-6ab31b04ec49', '$2a$12$51ny4YD90owBXhxWJBIHHuHCQrn7YCa.Q3caNXnbDNs.2aizAfXlK', '4d509f3d-fa79-486f-86aa-c2f2a1c976b4', '2026-03-29 07:46:47.28941+00', '2026-04-05 07:46:47.28908+00', '2026-04-01 14:03:13.116422+00', NULL, 'Admin locked account: Nghi ngờ lừa đảo, tạm khóa để điều tra');
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('09655b4e-cc68-4762-a12e-6100c74031f4', '750f626d-6013-4558-839d-165ae8054dd7', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$Ct1132nXwa5DzDkbKXXY3./z27O4p6l1wRrhkfc0hW44aQ28GDIae', '8f5f91f5-7a14-4d3a-92d7-711dd6dc821a', '2026-03-29 07:46:57.892394+00', '2026-04-05 07:46:57.892064+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('901df34a-48d8-4f9b-b0f0-260b772bcd7f', '4786a54a-a2a8-4b32-b51a-1755c219ec15', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$0V7EwaPByCbIUxqz7m9l0ukldsjenWymxswiwvFisfK5NeXg4jhJ6', '6af50205-303e-4f2a-a093-131510148a2c', '2026-03-29 07:48:14.222641+00', '2026-04-05 07:48:14.222278+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('5f61ac86-3c0e-479c-9478-06beeb3d4c72', 'e9aeef60-cebd-47bb-ac30-f5ecbf9b04f9', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$EveClteLo9RGNKRWLZPM9O4OhqfDK4mrDmFDMEjMpmzuvi7y5DQ5S', '246b2d6d-9750-4bf0-85c1-6435fd0bd57c', '2026-03-29 07:49:39.398951+00', '2026-04-05 07:49:39.398664+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('ca1b0ccb-49a6-4d40-81b7-fec5afefc638', '4a55c885-e581-459b-8933-cefb22118efb', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$kCHHGBSy/BLZIbYVzR4aLuUNa7.RHHiDgKe8mTyxjTQtkh89P3SeG', 'f7f79926-0156-48f7-8e4b-2ea7daa05558', '2026-03-29 07:50:40.959971+00', '2026-04-05 07:50:40.959656+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('eec7c706-b158-425f-a1d6-f2aded30e787', '148d9771-6741-476a-a6a4-40bcead42146', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$2zGz6V3n3NClkglJ9MRKzu4BQ5VX.YxDhdfygkBC0Y31uoDz.QRo6', '0763144a-9c8b-4b98-9756-0faba16b754d', '2026-03-29 08:39:53.508103+00', '2026-04-05 08:39:53.507226+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('abc67a32-e08a-42d8-af55-5f49128257f6', '2aacbcea-6896-4898-8ae0-33330bcf5bdb', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$8cWOO8zwMLwYO7eua8hdp.1vbOH2gNsh1c7AAIa6i9U7N.HwKL.06', '85d27bd2-55f1-4a7a-ab3c-cde7ada19b6d', '2026-03-29 08:44:39.421711+00', '2026-04-05 08:44:39.421257+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('b7406574-1b23-4eba-9368-2d1c6b988721', 'c8e2e2ac-7e3a-4db3-8b79-bd14e903c66b', '28eeca87-18d2-44af-afde-58f5ed6927c9', '$2a$12$wzWVi54VtnQr8Nw51pbOsOqaeG264BDER1gRBy.QTSMkCLeZ48D9a', '16a5fa37-7258-4a07-9e6f-e3d312f33e01', '2026-03-29 08:51:59.13718+00', '2026-04-05 08:51:59.136177+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('dd3529d8-f7b7-4af0-8e9f-0f292892a23b', 'd0da4d60-2a00-41e0-9d96-984b13884c56', '28eeca87-18d2-44af-afde-58f5ed6927c9', '$2a$12$kJvk38OwNpxvhZsR1SCOMOg/ReoFwnO7T3x6kdcY9CXL0JGzQldR.', '23d1018b-aff0-49b2-a33f-13a6cef02b1b', '2026-03-29 08:55:59.782706+00', '2026-04-05 08:55:59.780771+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('9d93d80f-4c7c-4525-93b5-f7bce23cf171', 'ad4078b5-1ae4-46e7-8d8c-e2105d6e4826', '28eeca87-18d2-44af-afde-58f5ed6927c9', '$2a$12$bM0buQmNXHAcRFDLPnLnl.D0ifpdIhtH48HdKnByxTcV9qX30f61S', 'c116b6af-bd19-46fe-a442-0b22a77ec8ba', '2026-03-29 10:09:10.999715+00', '2026-04-05 10:09:10.999715+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('238c2668-b0c2-446b-9793-138a021cba09', '10dd1f19-69de-438a-823f-b38cf96b39a1', '28eeca87-18d2-44af-afde-58f5ed6927c9', '$2a$12$UXf7wcKxp02LmJhsjHiyg.bMQf7nPq.vaZSDFht7bI57zlSFK9Pii', '0059ba55-0bb9-4ecd-88c1-e494ee48b516', '2026-03-29 12:23:46.910684+00', '2026-04-05 12:23:46.910297+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('077bbbf0-bda1-409f-aff3-d4fc108e031d', 'd31f56d8-63f0-445d-8173-316996fca55b', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$G/Be8W3eTHvntTBl3FPF1OaweVLLj4pJB7qvRCvqPxlDY9HIjTssG', 'ad8e872e-1a21-4c2c-aa93-f0cc53cd7ea6', '2026-03-29 12:43:49.69835+00', '2026-04-05 12:43:49.69762+00', '2026-03-29 16:31:20.176893+00', '74621fcc-1a1e-4b77-9410-4585f88c6655', 'Rotated');
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('411554e8-e087-4c6c-896f-8da56ed7cb59', 'dd2c78c8-a853-4026-86f4-be2c34e48242', '28eeca87-18d2-44af-afde-58f5ed6927c9', '$2a$12$jOR5KnpuTkJi6mqJhlwZheryGp8sbU8.YUGLHVV5lk7RliupCo.qi', '038d7433-d032-4d85-ba63-09f0e00b8bfb', '2026-03-30 15:45:03.426093+00', '2026-04-06 15:45:03.425082+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('7cd76b53-cfe2-4ed3-91b5-0b7bbff18256', '5b88285b-364a-4745-ae71-7621ec2d46f2', 'af82b3fe-b7d3-4342-a07f-1cdbc65233ee', '$2a$12$rzldpcjBlumvBCiLmII4O.1mkjBrv2.8TuV7keu7vKlwsThq6kYLG', 'd0bfdd26-fe3f-46ab-bee3-1092f912ba82', '2026-03-31 03:25:51.933599+00', '2026-04-07 03:25:51.932694+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('74621fcc-1a1e-4b77-9410-4585f88c6655', 'd31f56d8-63f0-445d-8173-316996fca55b', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$NX0c9nLhcggCA2qlFHeYJ.5nllXghmcX44ywFv5jD3CSLi9sww3w.', '4810b1a5-b17e-4987-b750-b7d29de5e831', '2026-03-29 16:31:20.163933+00', '2026-04-05 16:31:20.157497+00', '2026-03-31 08:22:16.059668+00', '7ccac29f-aa9b-4973-9179-e027d63fc162', 'Rotated');
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('bbf55c35-954a-47d0-bccf-e6316c6d39bd', '90a6006e-168d-4253-b260-3e373875e5ee', 'cfd595c3-035b-4243-bcfb-edb7c549df30', '$2a$12$nK7pFkBB0vX6rK4dXujrg.eTWyda..2jGTk.xO3VAH/eUsOtHARoG', '3c35e53b-d888-4f51-9bae-30b73263ef69', '2026-03-31 14:43:04.09711+00', '2026-04-07 14:43:04.096798+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('cf98175e-d1b0-4634-9f16-14c5fc51078a', '1996d3cd-3aec-453a-a628-1b2f9f142582', '5f0c2f5f-00e3-4f89-a5ac-b2c39ede0104', '$2a$12$8AjO1R8XwEgmX0xRNq4x.OoCqs430jCafUlK2MmtUDBHifgb/yHrq', '5a0d25c1-5137-42fc-a85f-90754e58f8a3', '2026-03-31 14:43:23.621218+00', '2026-04-07 14:43:23.620891+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('bb98079a-8ede-46fb-9036-e4d915d3b96e', 'b9c580fe-e1a3-456d-a9ae-e4767c64d5d4', '28eeca87-18d2-44af-afde-58f5ed6927c9', '$2a$12$SjCGIlZYbX84vq2l2szD9.lW1dJK0mD.sFhTxiRms8DlS2S6DVVX6', '2c3376a0-b359-4525-bb96-1cd14afd6842', '2026-03-31 14:44:09.299061+00', '2026-04-07 14:44:09.298722+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('4a317c84-e955-43de-89ca-51df23d17ebf', 'd3bc7bee-a5c1-4230-96de-b13bdcfdefa0', '5f0c2f5f-00e3-4f89-a5ac-b2c39ede0104', '$2a$12$ICERPErNjJLkDcVahgdmxuDsj8xgKo8uSLzgmCZMlUPYX9VmbhDAW', '9d0a7c65-8e70-432b-a83f-1905c0eb0d93', '2026-03-31 14:44:56.585557+00', '2026-04-07 14:44:56.585231+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('19bc1c72-6243-46ae-9012-cb3205295678', '397b5d99-c290-47da-bb4b-d22f32f0e92a', '28eeca87-18d2-44af-afde-58f5ed6927c9', '$2a$12$J2MPPmeYwaNteYroJWFmteVUYcIGlluO91GnWAxKt4/pqWVExDMD.', '1f0e0254-1b08-4754-ae2d-116e44044601', '2026-03-31 14:45:29.021441+00', '2026-04-07 14:45:29.021118+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('01a88313-0e84-41b7-a017-0bcc48702d54', 'd31f56d8-63f0-445d-8173-316996fca55b', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$LFVmZQYIwMoNOPVILDuW5O7WxfemTlpyPRYWe0FrN2ufxH5W80F.u', 'd97e646e-ea60-43ac-8112-4fd2ca1936e2', '2026-03-31 14:51:53.798821+00', '2026-04-07 14:51:53.798525+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('7ccac29f-aa9b-4973-9179-e027d63fc162', 'd31f56d8-63f0-445d-8173-316996fca55b', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$1LWbWNJB5aaomcu7wUkV5.2zvOIaoagLbqKLU4amDB./AEiNdHSv2', 'd2ad3491-da01-4333-9824-a619c74eedeb', '2026-03-31 08:22:16.059381+00', '2026-04-07 08:22:16.059008+00', '2026-03-31 14:51:53.799066+00', '01a88313-0e84-41b7-a017-0bcc48702d54', 'Rotated');
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('b16bbfe5-7ab7-4c76-b07f-89df62592deb', '9bbea148-5b1c-4d03-ad03-4c7488e11f4f', 'af82b3fe-b7d3-4342-a07f-1cdbc65233ee', '$2a$12$PVO11za8yr0r2mYh0pPml.riK5avswqdu8z83i0joAqjHqayza.NC', '01c8c00a-c46e-4b02-ac74-4d166e32de2b', '2026-03-31 14:52:07.363154+00', '2026-04-07 14:52:07.362868+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('f342ab12-f952-40b9-8c6d-772b933507f5', 'c81e03a7-7d7b-46a8-a008-06281a736806', '28eeca87-18d2-44af-afde-58f5ed6927c9', '$2a$12$gMaM4NcX/DJ5jHQia9DcN.Jq1L3qKMfhMhmMtgFhXgzg3cOfSIQHO', '15462af3-b87a-4542-b8e1-724adb833a81', '2026-03-31 15:21:29.541015+00', '2026-04-07 15:21:29.54059+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('e9f1adb1-2ce5-4ea7-b888-ecb4ba12b178', '27605ba1-84fe-411f-91b1-d09508215a29', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$vLN1Srm/VlVEe6yHTS7fIegvPLSy4JUyCEKtMzwubg4izK0KEH3RW', 'd0d0260f-b8a4-40ae-a4f5-38502379af42', '2026-04-01 08:40:53.520424+00', '2026-04-08 08:40:53.520152+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('ecb12c36-7968-4f5e-99b8-3c4b6eda1e5e', 'c6d7c41b-7bc1-44c0-8193-c8e6e959f489', '28eeca87-18d2-44af-afde-58f5ed6927c9', '$2a$12$O1NW6x9cwBKRv3n/vhPvpOCmIXlOvAVj7HYT6Nuhlm4oONtK2Mfw2', 'b667b03c-4bd0-4b5c-8b6d-a5a8e42e849b', '2026-04-01 09:04:42.040905+00', '2026-04-08 09:04:42.040621+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('d7b43e50-bce0-4005-abeb-99afb2e85837', 'c6d7c41b-7bc1-44c0-8193-c8e6e959f489', '28eeca87-18d2-44af-afde-58f5ed6927c9', '$2a$12$7rB1vXvfLhbcIraG1eN7GuXDVS7t59zXDo21/o5j2JyPmqY0.w.ES', '102538a3-7d54-4210-ac9a-eb225d3e424e', '2026-03-31 15:23:45.272991+00', '2026-04-07 15:23:45.272666+00', '2026-04-01 09:04:42.041113+00', 'ecb12c36-7968-4f5e-99b8-3c4b6eda1e5e', 'Rotated');
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('ebf8e7a9-fae2-4ec0-97c1-a4dd9bd7a8b5', '09e8c10e-5daf-435d-ba51-2bf6e4aa43b2', '28eeca87-18d2-44af-afde-58f5ed6927c9', '$2a$12$9nCihTqWh8wYw5nLkMrZOukKkHXUv57pOE9cyRIRMmwoNNaYyXHu.', 'a111d0ff-140b-435c-aa51-fd0ed2334b8b', '2026-04-01 09:51:31.840498+00', '2026-04-08 09:51:31.840246+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('68388d74-5320-4b22-aed3-7c5954ab1c35', 'b9dc297c-73ac-4c9c-8f9b-7daf707abcd6', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$p4fFJgPuE.SIIKd1xDZ6u.lEyVMuXNnUWjlth5Qcl09rcZpfiWt92', '3f0c6d09-c757-4171-b750-b88b467e0542', '2026-04-01 09:51:41.120299+00', '2026-04-08 09:51:41.120023+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('c6bd0db2-dd38-4a92-97c9-22c554bd9375', '511b22d2-c856-49fa-b06b-f2aea92ce49f', '28eeca87-18d2-44af-afde-58f5ed6927c9', '$2a$12$QPJk0nyGZSfMPSKLlLJlMuRTaQf2mD7qPcpHcKhDxnlENxML5o3rm', 'cc938eb7-7054-4dc3-bf47-15b95c8f1d15', '2026-04-01 10:01:34.744071+00', '2026-04-08 10:01:34.743825+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('5fc7cb2a-e69f-4ea6-b7d6-29a73b2a5f1d', 'c69eb545-3c02-4877-8e70-5eb93b7d47e7', '28eeca87-18d2-44af-afde-58f5ed6927c9', '$2a$12$IjBK.l6k2N.fJhZhFY/3euky.qFTo4UDmzkaCYbtHgwfLe55cQMcC', '3a97ba8a-9fff-4279-889e-f12d71ed0eac', '2026-04-01 10:04:55.672736+00', '2026-04-08 10:04:55.672461+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('7b5d4181-2d9f-43cd-bb6c-30c6b434e291', '9fc8b8ce-4ed9-4fe7-81be-46ec3f90da8d', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$JXGkKIBgY9kj9ME/lWfXKukmcip10J/N9Jlk04d4.J46W720QYztK', '0ea35f05-c6f1-4add-9aa5-c9e9167cd621', '2026-04-01 10:10:45.507576+00', '2026-04-08 10:10:45.501528+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('56da26b8-a050-474d-8839-96b90c4b3714', '9fc8b8ce-4ed9-4fe7-81be-46ec3f90da8d', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$Mis7dN6Okq1qzDtsR2DAD.cCS4HOxKFqKt0BfL8aUsDPCtHYVyeBO', '56c2030d-129a-4dbb-a879-f17794ef1e34', '2026-03-31 15:14:28.581221+00', '2026-04-07 15:14:28.580301+00', '2026-04-01 10:10:45.51646+00', '7b5d4181-2d9f-43cd-bb6c-30c6b434e291', 'Rotated');
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('f9b9785b-491d-493b-9095-527ffdc17b7d', '3952c02d-f5c4-4b24-8637-4f8493ce9f6c', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$oVwBeh9FGkaQ5jG23tdjWes/SefEvC6Vg7bPW5W4IKCidJCqXAtOC', '1b9d30c8-8847-495d-9844-f174d8322c5a', '2026-04-01 10:20:31.085077+00', '2026-04-08 10:20:31.084788+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('d4b8823c-de77-428b-9f5e-af255081f7e6', '12dcb41a-a1cb-4a3b-af48-70a3758f7f82', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$0jRkOu5.ICOBcRjbn1ypTOJ6hZgySN5jbEpOxRKiieJwwI8FC5GIG', '52250dfd-bd95-463b-84bc-af2067e92f26', '2026-04-01 10:28:44.162058+00', '2026-04-08 10:28:44.161784+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('bc3d8b2e-ad62-44d0-a4b2-6f15e5c5d9dd', '78bed69d-e3a0-4b26-accb-4027af7da264', '28eeca87-18d2-44af-afde-58f5ed6927c9', '$2a$12$AEER9UEv4aBiCmURB27e/enhZ2X7OgKqr67Fr77Iec9Zk3qrbYQem', 'deea2590-7cad-43e8-939b-a21323632c17', '2026-04-01 10:35:57.791489+00', '2026-04-08 10:35:57.791125+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('52acbf05-0176-4d2f-a265-7aa00eb9fb14', 'a668ee0d-af9d-4b22-b739-e9e5021b8b5b', '5f0c2f5f-00e3-4f89-a5ac-b2c39ede0104', '$2a$12$nwJdZPSLG2MI7M/XCxts8u02xZaAogY6zZt3rQpOjSaptmzICbsZC', '362b00ce-903c-475b-90e3-85d39a07b24b', '2026-04-01 10:58:35.428174+00', '2026-04-08 10:58:35.427909+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('5b67b0e3-4aee-4fe5-b070-f66eab3590d0', 'b965ee8d-2e84-4c1a-b403-22c30326786c', 'af82b3fe-b7d3-4342-a07f-1cdbc65233ee', '$2a$12$F7jfAuDWo.BJFRJW/6K7iORHPQz8MiKcoNP9tEnR55lPji.caFOm6', 'df27d030-c268-4eb5-93cc-365dfad42692', '2026-04-01 13:50:06.728254+00', '2026-04-08 13:50:06.72797+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('92681edc-fef6-44d1-89e8-58222a9272ed', '7bb3c6b2-6f13-4830-b751-48212ca1ccec', 'd0740f8c-5c94-403d-827c-6ab31b04ec49', '$2a$12$47wXPLyhfuK7P4lwzAR3Cuf5b5Ogqh1ykvpWCy7xQXVSbx/kbFcIa', '8f4c2b22-6839-4bcc-90c5-198e95784713', '2026-03-29 07:47:59.001459+00', '2026-04-05 07:47:59.001177+00', '2026-04-01 14:03:13.116422+00', NULL, 'Admin locked account: Nghi ngờ lừa đảo, tạm khóa để điều tra');
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('6c59c314-962a-4829-98e1-21ce57be7355', '9516406b-6656-45d4-bfee-75fb5bfd3920', '28eeca87-18d2-44af-afde-58f5ed6927c9', '$2a$12$M.4XZ1F7q1xz2uutjB9n2OcUoWFZXKZE3OqPcpYvEdQKBDmRkH0Bu', 'f83cf57a-21c8-4b5a-9a9e-110926b80a74', '2026-04-01 11:22:50.302839+00', '2026-04-08 11:22:50.302567+00', '2026-04-02 01:50:26.923513+00', '392ac0cf-10ec-4529-9ce6-5a1f2b4ad5d2', 'Rotated');
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('e9755a27-ad92-456a-ba0f-0c1c787eca15', 'fb1d9bc3-8deb-45b0-97d7-af0ab9ee193a', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$auLRAdT/043ybiuEDPZKouBwt6eswhnW3E/QqEVQvhe6IZvkpQdyO', 'ed8a386c-02db-4073-9820-77de5d47f267', '2026-04-01 13:52:41.109812+00', '2026-04-08 13:52:41.109584+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('8b5ba034-98cd-439c-b980-b3247c10ceb1', '32434ae3-8a0e-4f67-831f-6f01788e3217', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$r93eQqnP2OdBnBSE91ofY.m.UgHEFIng4jaDxnkLZ50I8T7b8vlBC', '2dedf255-0e17-4706-863a-9eb78d27c352', '2026-04-01 13:56:09.616651+00', '2026-04-08 13:56:09.616196+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('05c0d120-b7cc-4a05-843f-fc25469e0682', 'b46dfcbd-0f59-4f2e-9a7a-3f529dc3b9f4', 'fe59b795-b12b-4db6-9249-8fe3b3d33054', '$2a$12$etL9XgmODXoJ05LIvC2Ir.5T7ht9tZvRE5O5o04bf3kFACXYIUuca', 'b8bab2e4-2b77-4ff9-85bf-2efa7661efc6', '2026-04-01 13:58:03.517293+00', '2026-04-08 13:58:03.51705+00', '2026-04-01 13:59:35.909383+00', NULL, 'Password reset');
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('e382749f-385d-4001-bc2e-77e7fc1af3a9', 'e11583e5-18da-42c2-aad3-d2f2603f2369', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$5IU1r5QN5WNcyHmzjT1eG.ZLMLOvFxEpmQ2Jp4.p./tj7Jdk1vSxK', '87e00404-f12c-4e50-ad3c-48e270a3c88b', '2026-04-01 14:00:17.533276+00', '2026-04-08 14:00:17.533047+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('44481c0f-5e52-4117-9ce7-9077725ba241', '30bc307f-ec10-46c8-8ea4-38b050cc2974', 'd0740f8c-5c94-403d-827c-6ab31b04ec49', '$2a$12$CQYfPao8bb3krV2EaVxBRu8ZmTI1yruSw/8cYIzC3qpk0Pg4wpZje', '10311feb-e54b-4d8d-8376-e307ae705a2c', '2026-03-29 07:44:47.437118+00', '2026-04-05 07:44:47.436741+00', '2026-04-01 14:03:13.116422+00', NULL, 'Admin locked account: Nghi ngờ lừa đảo, tạm khóa để điều tra');
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('500fb93d-5937-497b-a4ed-96bfaaaaa683', '762837d2-5162-47d5-8ea5-34a3672ab211', 'd0740f8c-5c94-403d-827c-6ab31b04ec49', '$2a$12$zl1as2nH36PM3ZO1hHPG2.gbMj0v2GljOZgamrU6MqbIPSd2Goqum', '0d5464bb-ecc1-4173-8eb5-fa15ef70da4c', '2026-03-29 07:10:31.133535+00', '2026-04-05 07:10:31.133091+00', '2026-04-01 14:03:13.116422+00', NULL, 'Admin locked account: Nghi ngờ lừa đảo, tạm khóa để điều tra');
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('d4c7e99b-da4e-4346-9055-ff3c6d3f07d0', 'b4bf669e-2f61-4c2a-b797-bf270791e988', 'd0740f8c-5c94-403d-827c-6ab31b04ec49', '$2a$12$2SCmL1CWaxkdyoIOuy9truUEUbDeCD265CrzA5YmOajFvxtIvBuL2', '64914ead-7c4f-4bf6-85aa-64c41cf74132', '2026-03-29 07:42:38.841022+00', '2026-04-05 07:42:38.840599+00', '2026-04-01 14:03:13.116422+00', NULL, 'Admin locked account: Nghi ngờ lừa đảo, tạm khóa để điều tra');
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('e660a59f-277a-4cee-ad02-1a361de443ea', 'bc20ccea-845f-414b-ad59-6714edfe7513', 'd0740f8c-5c94-403d-827c-6ab31b04ec49', '$2a$12$OmL...YoDrwZPvpADRHvd.cZyiVrv2YTT8k6OL6XLrR9MS3bLjqfy', 'fde5ab45-8096-497a-95a5-fbf46f0f5e59', '2026-03-29 07:46:36.15234+00', '2026-04-05 07:46:36.151978+00', '2026-04-01 14:03:13.116422+00', NULL, 'Admin locked account: Nghi ngờ lừa đảo, tạm khóa để điều tra');
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('a440f34f-cddb-4a54-9fed-7ee2a0bca6b4', 'bf3659b5-2b29-4ec2-865d-36b42942648c', 'd0740f8c-5c94-403d-827c-6ab31b04ec49', '$2a$12$vLspSM.ILc3Z.MMfn7iyre.f8qB7lU1vjAjD5M1cVVX9agCAMT9Ci', '93609242-f229-4f66-889b-6ab5b7d46d14', '2026-03-29 06:59:50.33298+00', '2026-04-05 06:59:50.331933+00', '2026-04-01 14:03:13.116422+00', NULL, 'Admin locked account: Nghi ngờ lừa đảo, tạm khóa để điều tra');
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('579a398e-5fa4-42c3-a55e-33e056d757cb', 'deb401fe-a968-48b7-b851-66d0b6707e17', 'd0740f8c-5c94-403d-827c-6ab31b04ec49', '$2a$12$qeOKWV7z4SSotNU57V615uYE3rOdC/sFchsLS1C0TYtvpFoaXdVBm', 'd6caf15a-b18b-47f6-bd92-35a0333d5931', '2026-03-29 07:38:18.068608+00', '2026-04-05 07:38:18.068287+00', '2026-04-01 14:03:13.116422+00', NULL, 'Admin locked account: Nghi ngờ lừa đảo, tạm khóa để điều tra');
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('c2319c90-82c8-4127-a6fe-8527af8ea75a', 'f954cd1f-868f-4088-a6e6-8397913d81d6', 'd0740f8c-5c94-403d-827c-6ab31b04ec49', '$2a$12$rUJjg1T38zSzLjh81okNlOEZyB/tLGfD8QJuiUfYNWbJTItlT9hgO', '75df0346-fe31-4560-be3f-7c774253f355', '2026-03-29 07:11:21.204738+00', '2026-04-05 07:11:21.20434+00', '2026-04-01 14:03:13.116422+00', NULL, 'Admin locked account: Nghi ngờ lừa đảo, tạm khóa để điều tra');
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('23a89de2-ba12-47bf-8abd-0627091ba2d0', '48c9ceac-9396-4fed-bfc3-ffc352464aa8', '26b055dd-4b1e-4a93-b76e-74db41cec950', '$2a$12$Hlt.nCsAIx8UjZcj.AygIeV1Nvg50NnRb4C0kg4JIjGtcSny3znqm', '85d8d9dc-796b-4149-a828-4f88cdb5e5cd', '2026-04-01 13:52:15.391254+00', '2026-04-08 13:52:15.391019+00', '2026-04-01 14:03:46.207893+00', NULL, 'Admin locked account: Test');
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('0cc421f4-8af6-4a7f-b0c6-487f8bc34303', 'f0f101b2-c4e3-4bc3-bf67-d99498b047e4', '26b055dd-4b1e-4a93-b76e-74db41cec950', '$2a$12$fIeN3E8FELburMuvPtEi0eqRSpSJPDZqHr51G8C2yNqLUuMbXZ4De', '6dab2d6e-30d9-4ecb-ae65-7d01b2a8c28c', '2026-04-01 13:52:59.239532+00', '2026-04-08 13:52:59.239271+00', '2026-04-01 14:03:46.207893+00', NULL, 'Admin locked account: Test');
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('06b40778-49f7-432f-ab6a-c93d694c8cdb', '4a8f0e2b-9faf-4ab9-a2c5-030719485514', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$/IYIgNE19GgMnZWxtyhWCueqIJ9hKcO4LD.aIvnDD4iuHjtfhi.j6', 'acb7eb87-ef51-476d-996d-ba7d7d009b5c', '2026-04-01 14:04:28.915944+00', '2026-04-08 14:04:28.915711+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('f9d251f0-584f-4e84-a90c-59f0cd8c71eb', '2296d7bb-f7cd-455b-a3a0-ccafc0751f02', 'fe59b795-b12b-4db6-9249-8fe3b3d33054', '$2a$12$9I8yczCTUNynPlnAPEDqb..jGxa3wcjQYMyEkqyeJpy8eYCONl8ia', 'e286bed0-0493-4f1f-9a26-96ac0a77ef0a', '2026-04-01 14:00:04.779494+00', '2026-04-08 14:00:04.779236+00', '2026-04-01 14:04:47.394525+00', NULL, 'Admin locked account: Test');
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('42f7ebc8-50b2-4ff2-baae-9ddfb282ba8b', 'a9f39ffe-3c2f-4fc5-a295-f851252ee49c', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$RFON673xhwujKbKrVz0ztO1DscS0DzVYzIf9Jd8hmGJUSJ91L.EK.', '75d1421a-d17d-49cb-8b19-979d022f6e6b', '2026-04-01 14:05:13.968644+00', '2026-04-08 14:05:13.967994+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('67804cd1-a52d-46d6-91d2-d7acc0362936', '2fc6bbc8-e140-4a5a-b2aa-2dc2339b7656', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$O3iIl4tObKpRgrARrGJlo.0OaZCq4zAE1evj2KfGbK9O1l96Xu0Bq', 'f4f4983f-af69-464c-9124-eb8b27cc2042', '2026-04-01 14:22:23.984876+00', '2026-04-08 14:22:23.984635+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('c8b2d26b-7ce7-486b-af0c-d16eb135f1b9', '0c49da4c-a26c-4445-b580-f700a9e41cbc', 'af82b3fe-b7d3-4342-a07f-1cdbc65233ee', '$2a$12$Cxq6pPRr5qnmpfz/B9wa3OVAn8RiPx8s2JL7ktv5ag7KmztB3hUJy', '45c82768-7727-41a7-818b-e9f7109b311e', '2026-04-01 14:48:35.408855+00', '2026-04-08 14:48:35.408613+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('c9a2edf8-0ab6-41dd-92f7-4c72d2ccc274', '49be4df6-d6a6-43f2-8322-40c4bfd84b66', '5d053abf-972f-466c-9ffc-24affd11062e', '$2a$12$aUR4eAW1wZSZwwsoqncZBuGu8jwwxKJUVROXjc2wB2B0zx7z8JPWa', '54310727-792b-4ae8-8de2-25505cdb397b', '2026-04-01 14:52:36.279547+00', '2026-04-08 14:52:36.279313+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('f01fe11f-333e-45bf-aa38-1852002849c0', 'e42499dc-51b0-4995-876e-66d484600d45', 'af82b3fe-b7d3-4342-a07f-1cdbc65233ee', '$2a$12$uYXuofl.eMguNZlmXRohMeeUiDVgVKlcDfRrpZQLlAHBAjinvpHqC', '19ef8bf3-0b96-4cb8-ad8f-97be9a3abba8', '2026-04-01 14:54:03.021067+00', '2026-04-08 14:54:03.020831+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('b5ef5c61-588d-4b2f-acb4-8a6de1df3f1a', 'fe02cf92-875d-43d5-8bae-d8bba8fff105', 'af82b3fe-b7d3-4342-a07f-1cdbc65233ee', '$2a$12$Lqv7LzKuA5Ry8DpZPYl8b.ggV7/M1rYUT1lsFymtLjLfvev2jIws.', '123a9b39-af6e-4f25-a141-16fd97e2f858', '2026-04-02 01:41:48.481785+00', '2026-04-09 01:41:48.481054+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('7b5905f2-04d9-4c10-b0af-3752e5f1d539', '66fe80e9-11be-40f0-b9bc-c528f4a57be3', '28eeca87-18d2-44af-afde-58f5ed6927c9', '$2a$12$Kkb9ZBZBiwOKV.kBmpcbYeYNQkdWJVtiIvUhzDf/FH6j6YnbO5ktu', '69da3d5d-36e6-4066-a361-b31e24e7dd43', '2026-04-02 01:42:51.263831+00', '2026-04-09 01:42:51.263406+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('70264ade-3f08-42e7-b50b-9e6f576dea1a', '8cbb8250-ae1f-4872-8505-e88ac4042b17', '28eeca87-18d2-44af-afde-58f5ed6927c9', '$2a$12$hjqpIr.Zrxa2XHRsNkAZOOiEJND5H8rJ///1cDksyrhWululZ6zJm', 'c199ca11-1ff8-4f29-833a-ae24cf6903bc', '2026-04-02 01:45:30.414335+00', '2026-04-09 01:45:30.413945+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('392ac0cf-10ec-4529-9ce6-5a1f2b4ad5d2', '9516406b-6656-45d4-bfee-75fb5bfd3920', '28eeca87-18d2-44af-afde-58f5ed6927c9', '$2a$12$tA/wjADzKxpcpFYswaMCuuzRsKq1lPENl9lDeG0pe1VaePPkOpJ1i', '903a5c53-298f-47be-9bad-836a135e59cc', '2026-04-02 01:50:26.92321+00', '2026-04-09 01:50:26.922889+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('50c6037d-e9ea-4cfd-b03a-cf3ff0168b88', 'db10fc47-4283-49f9-92ab-719d0faf6c29', '28eeca87-18d2-44af-afde-58f5ed6927c9', '$2a$12$0oW/qcSWtVbfYmT.QFplEegsqNSiB/q7KFXINmCuyyeyhMkRId5.O', '9360f112-d1e9-48f1-92a7-cba2b474b6c9', '2026-04-02 01:57:46.638383+00', '2026-04-09 01:57:46.638107+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('0b4b8501-d2a8-49d4-893e-8c238d81a5e2', '50856d08-d6c5-4294-aa54-28aa920fef28', '28eeca87-18d2-44af-afde-58f5ed6927c9', '$2a$12$ETjM4KN1AgnnA40ex5sexeNedAJzzM16Qo7iqwMWI0j9rYdKQ8H02', 'ebca449c-3273-4876-93ed-e9228273807f', '2026-04-02 02:51:21.148818+00', '2026-04-09 02:51:21.148511+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('6fd800b4-9f19-4f29-b6de-e659fc4f19c3', '50856d08-d6c5-4294-aa54-28aa920fef28', '28eeca87-18d2-44af-afde-58f5ed6927c9', '$2a$12$G3kAuoT8Gj1PE6GhD0kXLemNmEt/3eSsVYRZivfDt8srPh3HQJ3D.', '914fa041-9707-4295-8b9d-89a70e4593e6', '2026-04-02 01:50:40.45584+00', '2026-04-09 01:50:40.455523+00', '2026-04-02 02:51:21.149009+00', '0b4b8501-d2a8-49d4-893e-8c238d81a5e2', 'Rotated');
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('72796ccf-b2d7-45e4-8c0f-849274d7aa02', '0bb66d89-0ce4-4093-bdc5-f8d1ccc46489', '28eeca87-18d2-44af-afde-58f5ed6927c9', '$2a$12$k4Jc/kSJPkslGankFmCa/.Rv5MbHOgKOYMslyLGAYR81a2qthJDUW', '0b71c993-75bc-4602-b521-aa6c8af8cd1a', '2026-04-02 02:56:21.156145+00', '2026-04-09 02:56:21.155853+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('80ceb4c6-c6ed-4f6c-b7a7-bb453425f6ae', '0bb66d89-0ce4-4093-bdc5-f8d1ccc46489', '28eeca87-18d2-44af-afde-58f5ed6927c9', '$2a$12$YX9hvm/b46JKjr14e9WBeOVEYs9MuXBQ/4i/soaDw1EeIR0cf4jK2', '7bcd996a-e927-4f81-850a-d6b747451094', '2026-04-02 01:55:45.938059+00', '2026-04-09 01:55:45.937765+00', '2026-04-02 02:56:21.156305+00', '72796ccf-b2d7-45e4-8c0f-849274d7aa02', 'Rotated');
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('9471faa9-bfec-4990-871c-9b548d355929', '4ff147e0-e811-4ebf-aa29-194a7eb1f19d', '28eeca87-18d2-44af-afde-58f5ed6927c9', '$2a$12$7s5Wlkir1/8uamrZoexqG.Ed191PdNpLqoB50pieK3/ldpAOHo4Na', '34b6a61d-f1bc-49d2-9c76-9e49d6e24a4d', '2026-04-02 06:07:06.223953+00', '2026-04-09 06:07:06.223672+00', NULL, NULL, NULL);
INSERT INTO public.refresh_tokens (id, session_id, user_id, token_hash, jti, issued_at, expires_at, revoked_at, replaced_by_token_id, revoke_reason) VALUES ('d56bc77d-30f9-405d-8e52-15bd8d35042c', '4ff147e0-e811-4ebf-aa29-194a7eb1f19d', '28eeca87-18d2-44af-afde-58f5ed6927c9', '$2a$12$XkmjgceMZsMuH957oiTEZueCRgm9ZE85tNeZgg2C1fiM3QuaOjDeu', 'f0a57cdd-0a30-4614-a39a-d8bb990cb940', '2026-04-02 01:49:02.264927+00', '2026-04-09 01:49:02.26458+00', '2026-04-02 06:07:06.224116+00', '9471faa9-bfec-4990-871c-9b548d355929', 'Rotated');


--
-- TOC entry 4684 (class 0 OID 34460)
-- Dependencies: 234
-- Data for Name: revoked_jtis; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4679 (class 0 OID 34372)
-- Dependencies: 229
-- Data for Name: role_permissions; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.role_permissions (role_id, permission_id) VALUES (1, 1);
INSERT INTO public.role_permissions (role_id, permission_id) VALUES (2, 1);
INSERT INTO public.role_permissions (role_id, permission_id) VALUES (3, 1);
INSERT INTO public.role_permissions (role_id, permission_id) VALUES (1, 2);
INSERT INTO public.role_permissions (role_id, permission_id) VALUES (2, 2);
INSERT INTO public.role_permissions (role_id, permission_id) VALUES (3, 2);
INSERT INTO public.role_permissions (role_id, permission_id) VALUES (1, 3);
INSERT INTO public.role_permissions (role_id, permission_id) VALUES (2, 3);
INSERT INTO public.role_permissions (role_id, permission_id) VALUES (3, 3);
INSERT INTO public.role_permissions (role_id, permission_id) VALUES (2, 4);
INSERT INTO public.role_permissions (role_id, permission_id) VALUES (2, 5);
INSERT INTO public.role_permissions (role_id, permission_id) VALUES (2, 6);
INSERT INTO public.role_permissions (role_id, permission_id) VALUES (2, 7);
INSERT INTO public.role_permissions (role_id, permission_id) VALUES (3, 8);
INSERT INTO public.role_permissions (role_id, permission_id) VALUES (3, 9);
INSERT INTO public.role_permissions (role_id, permission_id) VALUES (3, 10);
INSERT INTO public.role_permissions (role_id, permission_id) VALUES (3, 11);
INSERT INTO public.role_permissions (role_id, permission_id) VALUES (3, 12);
INSERT INTO public.role_permissions (role_id, permission_id) VALUES (3, 13);


--
-- TOC entry 4676 (class 0 OID 34355)
-- Dependencies: 226
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.roles (id, code, name) VALUES (1, 'GUEST', 'Guest');
INSERT INTO public.roles (id, code, name) VALUES (2, 'HOST', 'Host');
INSERT INTO public.roles (id, code, name) VALUES (3, 'ADMIN', 'Administrator');


--
-- TOC entry 4672 (class 0 OID 34291)
-- Dependencies: 222
-- Data for Name: room_types; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.room_types (id, name, is_active, created_at, updated_at) VALUES (1, 'Căn hộ', true, '2026-03-24 06:27:00.511504+00', '2026-03-24 06:27:00.511504+00');
INSERT INTO public.room_types (id, name, is_active, created_at, updated_at) VALUES (3, 'Nhà nguyên căn', true, '2026-03-24 06:27:00.670745+00', '2026-03-24 06:27:00.670745+00');
INSERT INTO public.room_types (id, name, is_active, created_at, updated_at) VALUES (2, 'Chung cư', true, '2026-03-24 06:27:00.591559+00', '2026-03-24 06:27:00.591559+00');


--
-- TOC entry 4680 (class 0 OID 34387)
-- Dependencies: 230
-- Data for Name: user_roles; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.user_roles (user_id, role_id) VALUES ('af82b3fe-b7d3-4342-a07f-1cdbc65233ee', 2);
INSERT INTO public.user_roles (user_id, role_id) VALUES ('5d053abf-972f-466c-9ffc-24affd11062e', 3);
INSERT INTO public.user_roles (user_id, role_id) VALUES ('10455dc2-bdc5-4c63-9919-0f8254730239', 2);
INSERT INTO public.user_roles (user_id, role_id) VALUES ('0beb0de4-3708-4044-89de-6fb09aef756c', 2);
INSERT INTO public.user_roles (user_id, role_id) VALUES ('310da63e-ec1c-4fa7-b7cd-0d4b0f3d3b60', 2);
INSERT INTO public.user_roles (user_id, role_id) VALUES ('cfd595c3-035b-4243-bcfb-edb7c549df30', 2);
INSERT INTO public.user_roles (user_id, role_id) VALUES ('5f0c2f5f-00e3-4f89-a5ac-b2c39ede0104', 2);
INSERT INTO public.user_roles (user_id, role_id) VALUES ('1de11e1a-91cb-412e-aab0-5f657f535dbc', 2);
INSERT INTO public.user_roles (user_id, role_id) VALUES ('51f28ce8-372e-4a6c-9455-126bbe2911b9', 2);
INSERT INTO public.user_roles (user_id, role_id) VALUES ('28eeca87-18d2-44af-afde-58f5ed6927c9', 3);
INSERT INTO public.user_roles (user_id, role_id) VALUES ('3ec0c781-ed01-4efc-b02e-6ef9ffe05576', 2);
INSERT INTO public.user_roles (user_id, role_id) VALUES ('007deeb1-cee0-47f6-9467-6450433c4315', 2);
INSERT INTO public.user_roles (user_id, role_id) VALUES ('8508dcf4-5077-4f8a-9bff-52a08f472dcf', 2);
INSERT INTO public.user_roles (user_id, role_id) VALUES ('d0740f8c-5c94-403d-827c-6ab31b04ec49', 2);
INSERT INTO public.user_roles (user_id, role_id) VALUES ('0e82682f-af39-4947-b07f-72952c92976c', 2);
INSERT INTO public.user_roles (user_id, role_id) VALUES ('26b055dd-4b1e-4a93-b76e-74db41cec950', 2);
INSERT INTO public.user_roles (user_id, role_id) VALUES ('fe59b795-b12b-4db6-9249-8fe3b3d33054', 2);


--
-- TOC entry 4668 (class 0 OID 34261)
-- Dependencies: 218
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.users (id, full_name, email, phone, password_hash, status, last_login_at, created_at, updated_at, deleted_at, lock_reason) VALUES ('1de11e1a-91cb-412e-aab0-5f657f535dbc', 'Nguyễn Hoàng Nam', 'host.nam@leaselink.vn', '0901000001', '$2a$12$W6gVHBHNmoZ1.735Ep5viuysbQ9dKDtG0hlRiZtKteLkP2ZUW.TS6', 'ACTIVE', '2026-03-22 09:22:46.747718+00', '2026-03-24 09:22:46.747718+00', '2026-03-24 09:22:46.747718+00', NULL, NULL);
INSERT INTO public.users (id, full_name, email, phone, password_hash, status, last_login_at, created_at, updated_at, deleted_at, lock_reason) VALUES ('10455dc2-bdc5-4c63-9919-0f8254730239', 'Trần Minh Anh', 'host.anh@leaselink.vn', '0901000002', '$2a$12$pEu.i82iocWEfxvZZU1ibe14Bep71uDrYbPOEanbJtsYuHn1t3B36', 'ACTIVE', '2026-03-21 09:22:46.747718+00', '2026-03-24 09:22:46.747718+00', '2026-03-24 09:22:46.747718+00', NULL, NULL);
INSERT INTO public.users (id, full_name, email, phone, password_hash, status, last_login_at, created_at, updated_at, deleted_at, lock_reason) VALUES ('310da63e-ec1c-4fa7-b7cd-0d4b0f3d3b60', 'Lê Thu Hà', 'host.ha@leaselink.vn', '0901000003', '$2a$12$Z8UwbArUCl8BqaT1J5QedepXETT1ii0oTf/G5P0/l6l8JcmCL3nFW', 'ACTIVE', '2026-03-24 03:22:46.747718+00', '2026-03-24 09:22:46.747718+00', '2026-03-24 09:22:46.747718+00', NULL, NULL);
INSERT INTO public.users (id, full_name, email, phone, password_hash, status, last_login_at, created_at, updated_at, deleted_at, lock_reason) VALUES ('0beb0de4-3708-4044-89de-6fb09aef756c', 'Phạm Quốc Bảo', 'host.bao@leaselink.vn', '0901000004', '$2a$12$XuTReB0YZCjBHpq3JqUaY.32Oarg8FSlApcu1apvCqv/c8xzSDzpS', 'ACTIVE', '2026-03-24 01:22:46.747718+00', '2026-03-24 09:22:46.747718+00', '2026-03-24 09:22:46.747718+00', NULL, NULL);
INSERT INTO public.users (id, full_name, email, phone, password_hash, status, last_login_at, created_at, updated_at, deleted_at, lock_reason) VALUES ('51f28ce8-372e-4a6c-9455-126bbe2911b9', 'Bùi Thanh Nhàn', 'host.nhan@leaselink.vn', '0901000007', '$2a$12$m.o0yHz60QiD0uYPXqvOkOYayMOv5JA6MAHgOI7MfuAOgfOn7.z.e', 'LOCKED', '2026-03-09 09:22:46.747718+00', '2026-03-24 09:22:46.747718+00', '2026-03-24 09:22:46.747718+00', NULL, NULL);
INSERT INTO public.users (id, full_name, email, phone, password_hash, status, last_login_at, created_at, updated_at, deleted_at, lock_reason) VALUES ('28eeca87-18d2-44af-afde-58f5ed6927c9', 'bao bao', '23110078@student.hcmute.edu.vn', '0798888529', '$2a$12$SBStdqBjly17TPpo92rHzO62KB27vmdWLLl0m/DVX//B63PkWqZ/a', 'ACTIVE', '2026-04-02 01:57:46.326333+00', '2026-03-24 05:29:09.263234+00', '2026-04-02 01:57:46.643466+00', NULL, NULL);
INSERT INTO public.users (id, full_name, email, phone, password_hash, status, last_login_at, created_at, updated_at, deleted_at, lock_reason) VALUES ('3ec0c781-ed01-4efc-b02e-6ef9ffe05576', 'Trần Văn B', 'coyoso8285@izkat.com', '0347123456', '$2a$12$AWU0PsZEVF6wz19V0.2I3es925mhtHh0tSHD1dU7ui40HbNRpp8gO', 'ACTIVE', '2026-03-28 17:01:42.785448+00', '2026-03-28 15:28:07.050892+00', '2026-03-28 17:01:43.804877+00', NULL, NULL);
INSERT INTO public.users (id, full_name, email, phone, password_hash, status, last_login_at, created_at, updated_at, deleted_at, lock_reason) VALUES ('0e82682f-af39-4947-b07f-72952c92976c', 'Nguyễn Văn Nam', 'naveren772@jsncos.com', '0347123772', '$2a$12$7BCO2VbMYSFs2GibMzlgrOmeM.LsIxh0jf7ogJxZt1hgTgPxr/dgO', 'ACTIVE', '2026-03-29 07:50:32.148394+00', '2026-03-29 07:16:53.439286+00', '2026-03-29 07:50:32.517921+00', NULL, NULL);
INSERT INTO public.users (id, full_name, email, phone, password_hash, status, last_login_at, created_at, updated_at, deleted_at, lock_reason) VALUES ('007deeb1-cee0-47f6-9467-6450433c4315', 'Mohamed Ali', 'tacok70571@izkat.com', '0347151515', '$2a$12$qdWhmFb1S4fKaoUctUrM1uHoMfGxOGLCL85Av8S/3pTcG.Lsn04PG', 'ACTIVE', '2026-03-29 02:16:18.820977+00', '2026-03-29 02:12:02.006526+00', '2026-03-29 02:16:19.295705+00', NULL, NULL);
INSERT INTO public.users (id, full_name, email, phone, password_hash, status, last_login_at, created_at, updated_at, deleted_at, lock_reason) VALUES ('26b055dd-4b1e-4a93-b76e-74db41cec950', 'Nguyễn Thị Lý', 'lifiyop290@flownue.com', '0347124582', '$2a$12$Gz0nGhlj3sVbG3HGWSjr.eW8N/idBKgFGrju8NQlOH11v5..wYaIC', 'ACTIVE', '2026-04-01 13:52:58.922726+00', '2026-04-01 13:51:38.096548+00', '2026-04-01 14:05:33.52561+00', NULL, NULL);
INSERT INTO public.users (id, full_name, email, phone, password_hash, status, last_login_at, created_at, updated_at, deleted_at, lock_reason) VALUES ('d0740f8c-5c94-403d-827c-6ab31b04ec49', 'Huy Ngô', 'hixider322@jsncos.com', '0347123322', '$2a$12$Gk3DbMYwVFZi/0yntUAuiesm/ehsxACdHVu..LRkZaktSwHNSdeTG', 'ACTIVE', '2026-03-29 07:47:58.68312+00', '2026-03-29 06:59:45.108067+00', '2026-04-01 14:05:46.692227+00', NULL, NULL);
INSERT INTO public.users (id, full_name, email, phone, password_hash, status, last_login_at, created_at, updated_at, deleted_at, lock_reason) VALUES ('5f0c2f5f-00e3-4f89-a5ac-b2c39ede0104', 'Đỗ Khánh Linh', 'host.linh@leaselink.vn', '0901000005', '$2a$12$a2.ykvhPilgT3gI0NZA2gOhJNfQpD8Q5VjI8RX3ixtcXx0Mei1ZC2', 'ACTIVE', '2026-04-01 10:58:35.115729+00', '2026-03-24 09:22:46.747718+00', '2026-04-01 10:58:35.432848+00', NULL, NULL);
INSERT INTO public.users (id, full_name, email, phone, password_hash, status, last_login_at, created_at, updated_at, deleted_at, lock_reason) VALUES ('8508dcf4-5077-4f8a-9bff-52a08f472dcf', 'Hưng Hảo Hán', 'necig29607@jsncos.com', '0347296074', '$2a$12$DWoddXh8E/IONWyuhG7qyevC3bq10mry4jVFII24qbgNSYUcSDizy', 'ACTIVE', '2026-03-29 04:06:05.16269+00', '2026-03-29 03:14:15.609786+00', '2026-03-29 04:06:06.217755+00', NULL, NULL);
INSERT INTO public.users (id, full_name, email, phone, password_hash, status, last_login_at, created_at, updated_at, deleted_at, lock_reason) VALUES ('cfd595c3-035b-4243-bcfb-edb7c549df30', 'Võ Gia Huy', 'host.huy@leaselink.vn', '0901000006', '$2a$12$mvIiCxQs/vwyF9Zw84vh4e93M8vvcb08BqGU2aE08c1HoFdBcMHs.', 'PENDING', '2026-03-31 14:43:03.784598+00', '2026-03-24 09:22:46.747718+00', '2026-03-31 14:43:04.103431+00', NULL, NULL);
INSERT INTO public.users (id, full_name, email, phone, password_hash, status, last_login_at, created_at, updated_at, deleted_at, lock_reason) VALUES ('5d053abf-972f-466c-9ffc-24affd11062e', 'System Administrator', 'admin@leaselink.vn', '0900000001', '$2a$12$VAaYjWUqU2tmY.NKpqSEOefB6.UNQXL0VH5NUINu1KlK/vv6Ey8YC', 'ACTIVE', '2026-04-01 14:52:35.96738+00', '2026-03-24 09:22:46.747718+00', '2026-04-01 14:52:36.283006+00', NULL, NULL);
INSERT INTO public.users (id, full_name, email, phone, password_hash, status, last_login_at, created_at, updated_at, deleted_at, lock_reason) VALUES ('fe59b795-b12b-4db6-9249-8fe3b3d33054', 'Nguyễn Tuấn Kiệt', 'vayow82347@flownue.com', '0314123852', '$2a$12$POwzH1YlGa5PxWgOyWbzYuWCGeOLg8oZQUIkFlYIgL.mcBQjCyMT6', 'ACTIVE', '2026-04-01 14:00:04.379733+00', '2026-04-01 13:57:09.035702+00', '2026-04-01 14:53:48.252434+00', NULL, NULL);
INSERT INTO public.users (id, full_name, email, phone, password_hash, status, last_login_at, created_at, updated_at, deleted_at, lock_reason) VALUES ('af82b3fe-b7d3-4342-a07f-1cdbc65233ee', 'Lê Quang Hưng', 'aki23092005@gmail.com', '0347123321', '$2a$12$MX/DI6lUMbDTtXfq09qYl.dMSkVFb1ouQu4q7ija/53LTWNYNxsHe', 'ACTIVE', '2026-04-02 01:41:48.1514+00', '2026-03-23 17:01:47.98111+00', '2026-04-02 01:41:48.542343+00', NULL, NULL);


--
-- TOC entry 4698 (class 0 OID 0)
-- Dependencies: 219
-- Name: areas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.areas_id_seq', 31, true);


--
-- TOC entry 4699 (class 0 OID 0)
-- Dependencies: 227
-- Name: permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.permissions_id_seq', 13, true);


--
-- TOC entry 4700 (class 0 OID 0)
-- Dependencies: 225
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.roles_id_seq', 3, true);


--
-- TOC entry 4701 (class 0 OID 0)
-- Dependencies: 221
-- Name: room_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.room_types_id_seq', 14, true);


--
-- TOC entry 4458 (class 2606 OID 34287)
-- Name: areas areas_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.areas
    ADD CONSTRAINT areas_name_key UNIQUE (name);


--
-- TOC entry 4460 (class 2606 OID 34285)
-- Name: areas areas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.areas
    ADD CONSTRAINT areas_pkey PRIMARY KEY (id);


--
-- TOC entry 4462 (class 2606 OID 34289)
-- Name: areas areas_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.areas
    ADD CONSTRAINT areas_slug_key UNIQUE (slug);


--
-- TOC entry 4489 (class 2606 OID 34412)
-- Name: auth_sessions auth_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_sessions
    ADD CONSTRAINT auth_sessions_pkey PRIMARY KEY (id);


--
-- TOC entry 4506 (class 2606 OID 34498)
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- TOC entry 4499 (class 2606 OID 34454)
-- Name: password_reset_tokens password_reset_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_pkey PRIMARY KEY (id);


--
-- TOC entry 4481 (class 2606 OID 34371)
-- Name: permissions permissions_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_code_key UNIQUE (code);


--
-- TOC entry 4483 (class 2606 OID 34369)
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- TOC entry 4472 (class 2606 OID 34316)
-- Name: properties properties_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.properties
    ADD CONSTRAINT properties_pkey PRIMARY KEY (id);


--
-- TOC entry 4474 (class 2606 OID 34347)
-- Name: property_images property_images_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.property_images
    ADD CONSTRAINT property_images_pkey PRIMARY KEY (id);


--
-- TOC entry 4493 (class 2606 OID 34428)
-- Name: refresh_tokens refresh_tokens_jti_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_jti_key UNIQUE (jti);


--
-- TOC entry 4495 (class 2606 OID 34426)
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- TOC entry 4502 (class 2606 OID 34466)
-- Name: revoked_jtis revoked_jtis_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.revoked_jtis
    ADD CONSTRAINT revoked_jtis_pkey PRIMARY KEY (jti);


--
-- TOC entry 4485 (class 2606 OID 34376)
-- Name: role_permissions role_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_pkey PRIMARY KEY (role_id, permission_id);


--
-- TOC entry 4477 (class 2606 OID 34362)
-- Name: roles roles_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_code_key UNIQUE (code);


--
-- TOC entry 4479 (class 2606 OID 34360)
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- TOC entry 4464 (class 2606 OID 34301)
-- Name: room_types room_types_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_types
    ADD CONSTRAINT room_types_name_key UNIQUE (name);


--
-- TOC entry 4466 (class 2606 OID 34299)
-- Name: room_types room_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_types
    ADD CONSTRAINT room_types_pkey PRIMARY KEY (id);


--
-- TOC entry 4487 (class 2606 OID 34391)
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (user_id, role_id);


--
-- TOC entry 4452 (class 2606 OID 34273)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 4454 (class 2606 OID 34275)
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- TOC entry 4456 (class 2606 OID 34271)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 4503 (class 1259 OID 34504)
-- Name: idx_notifications_recipient_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notifications_recipient_created ON public.notifications USING btree (recipient_id, created_at DESC);


--
-- TOC entry 4504 (class 1259 OID 34505)
-- Name: idx_notifications_recipient_unread; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notifications_recipient_unread ON public.notifications USING btree (recipient_id, is_read);


--
-- TOC entry 4496 (class 1259 OID 34482)
-- Name: idx_password_reset_tokens_expires; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_password_reset_tokens_expires ON public.password_reset_tokens USING btree (expires_at);


--
-- TOC entry 4497 (class 1259 OID 34481)
-- Name: idx_password_reset_tokens_user_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_password_reset_tokens_user_created ON public.password_reset_tokens USING btree (user_id, created_at DESC);


--
-- TOC entry 4467 (class 1259 OID 34476)
-- Name: idx_properties_fts; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_properties_fts ON public.properties USING gin (to_tsvector('simple'::regconfig, (((COALESCE(title, ''::character varying))::text || ' '::text) || COALESCE(description, ''::text))));


--
-- TOC entry 4468 (class 1259 OID 34475)
-- Name: idx_properties_host; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_properties_host ON public.properties USING btree (host_id, status, updated_at DESC) WHERE (deleted_at IS NULL);


--
-- TOC entry 4469 (class 1259 OID 34477)
-- Name: idx_properties_pending; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_properties_pending ON public.properties USING btree (status, created_at) WHERE (status = 'PENDING'::public.property_status);


--
-- TOC entry 4470 (class 1259 OID 34474)
-- Name: idx_properties_public_search; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_properties_public_search ON public.properties USING btree (status, area_id, room_type_id, monthly_price, created_at DESC) WHERE (deleted_at IS NULL);


--
-- TOC entry 4490 (class 1259 OID 34479)
-- Name: idx_refresh_tokens_expires; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_refresh_tokens_expires ON public.refresh_tokens USING btree (expires_at);


--
-- TOC entry 4491 (class 1259 OID 34478)
-- Name: idx_refresh_tokens_user_session; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_refresh_tokens_user_session ON public.refresh_tokens USING btree (user_id, session_id);


--
-- TOC entry 4500 (class 1259 OID 34480)
-- Name: idx_revoked_jtis_expires; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_revoked_jtis_expires ON public.revoked_jtis USING btree (expires_at);


--
-- TOC entry 4449 (class 1259 OID 34473)
-- Name: idx_users_email_active; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_users_email_active ON public.users USING btree (email) WHERE (deleted_at IS NULL);


--
-- TOC entry 4450 (class 1259 OID 34472)
-- Name: idx_users_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_status ON public.users USING btree (status);


--
-- TOC entry 4475 (class 1259 OID 34353)
-- Name: uq_property_thumbnail_true; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_property_thumbnail_true ON public.property_images USING btree (property_id) WHERE (is_thumbnail = true);


--
-- TOC entry 4516 (class 2606 OID 34413)
-- Name: auth_sessions auth_sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_sessions
    ADD CONSTRAINT auth_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4522 (class 2606 OID 34499)
-- Name: notifications notifications_recipient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_recipient_id_fkey FOREIGN KEY (recipient_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4520 (class 2606 OID 34455)
-- Name: password_reset_tokens password_reset_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4507 (class 2606 OID 34332)
-- Name: properties properties_approved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.properties
    ADD CONSTRAINT properties_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES public.users(id);


--
-- TOC entry 4508 (class 2606 OID 34322)
-- Name: properties properties_area_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.properties
    ADD CONSTRAINT properties_area_id_fkey FOREIGN KEY (area_id) REFERENCES public.areas(id);


--
-- TOC entry 4509 (class 2606 OID 34317)
-- Name: properties properties_host_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.properties
    ADD CONSTRAINT properties_host_id_fkey FOREIGN KEY (host_id) REFERENCES public.users(id);


--
-- TOC entry 4510 (class 2606 OID 34327)
-- Name: properties properties_room_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.properties
    ADD CONSTRAINT properties_room_type_id_fkey FOREIGN KEY (room_type_id) REFERENCES public.room_types(id);


--
-- TOC entry 4511 (class 2606 OID 34348)
-- Name: property_images property_images_property_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.property_images
    ADD CONSTRAINT property_images_property_id_fkey FOREIGN KEY (property_id) REFERENCES public.properties(id) ON DELETE CASCADE;


--
-- TOC entry 4517 (class 2606 OID 34439)
-- Name: refresh_tokens refresh_tokens_replaced_by_token_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_replaced_by_token_id_fkey FOREIGN KEY (replaced_by_token_id) REFERENCES public.refresh_tokens(id);


--
-- TOC entry 4518 (class 2606 OID 34429)
-- Name: refresh_tokens refresh_tokens_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.auth_sessions(id) ON DELETE CASCADE;


--
-- TOC entry 4519 (class 2606 OID 34434)
-- Name: refresh_tokens refresh_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4521 (class 2606 OID 34467)
-- Name: revoked_jtis revoked_jtis_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.revoked_jtis
    ADD CONSTRAINT revoked_jtis_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4512 (class 2606 OID 34382)
-- Name: role_permissions role_permissions_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES public.permissions(id) ON DELETE CASCADE;


--
-- TOC entry 4513 (class 2606 OID 34377)
-- Name: role_permissions role_permissions_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- TOC entry 4514 (class 2606 OID 34397)
-- Name: user_roles user_roles_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- TOC entry 4515 (class 2606 OID 34392)
-- Name: user_roles user_roles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


-- Completed on 2026-04-02 20:15:25

--
-- PostgreSQL database dump complete
--

\unrestrict 16Ewaq0FTVFFfHW7JhHebxsxM2xAgW5MmZQ1s3m6JMpkQ2qPhbIygtvPUwXYEuq

