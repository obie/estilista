--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: active_admin_comments; Type: TABLE; Schema: public; Owner: rails; Tablespace: 
--

CREATE TABLE active_admin_comments (
    id integer NOT NULL,
    namespace character varying,
    body text,
    resource_id character varying NOT NULL,
    resource_type character varying NOT NULL,
    author_type character varying,
    author_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.active_admin_comments OWNER TO rails;

--
-- Name: active_admin_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: rails
--

CREATE SEQUENCE active_admin_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.active_admin_comments_id_seq OWNER TO rails;

--
-- Name: active_admin_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: rails
--

ALTER SEQUENCE active_admin_comments_id_seq OWNED BY active_admin_comments.id;


--
-- Name: admin_users; Type: TABLE; Schema: public; Owner: rails; Tablespace: 
--

CREATE TABLE admin_users (
    id integer NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.admin_users OWNER TO rails;

--
-- Name: admin_users_id_seq; Type: SEQUENCE; Schema: public; Owner: rails
--

CREATE SEQUENCE admin_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.admin_users_id_seq OWNER TO rails;

--
-- Name: admin_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: rails
--

ALTER SEQUENCE admin_users_id_seq OWNED BY admin_users.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: rails; Tablespace: 
--

CREATE TABLE ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.ar_internal_metadata OWNER TO rails;

--
-- Name: authem_sessions; Type: TABLE; Schema: public; Owner: rails; Tablespace: 
--

CREATE TABLE authem_sessions (
    id integer NOT NULL,
    role character varying NOT NULL,
    subject_id integer NOT NULL,
    subject_type character varying NOT NULL,
    token character varying(60) NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    ttl integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.authem_sessions OWNER TO rails;

--
-- Name: authem_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: rails
--

CREATE SEQUENCE authem_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.authem_sessions_id_seq OWNER TO rails;

--
-- Name: authem_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: rails
--

ALTER SEQUENCE authem_sessions_id_seq OWNED BY authem_sessions.id;


--
-- Name: channels; Type: TABLE; Schema: public; Owner: rails; Tablespace: 
--

CREATE TABLE channels (
    id integer NOT NULL,
    name text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    twitter_hashtag character varying(20) NOT NULL,
    ad text,
    CONSTRAINT twitter_hashtag_alphanumeric_constraint CHECK (((twitter_hashtag)::text ~ '^[\w\d]+$'::text))
);


ALTER TABLE public.channels OWNER TO rails;

--
-- Name: channels_id_seq; Type: SEQUENCE; Schema: public; Owner: rails
--

CREATE SEQUENCE channels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.channels_id_seq OWNER TO rails;

--
-- Name: channels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: rails
--

ALTER SEQUENCE channels_id_seq OWNED BY channels.id;


--
-- Name: developers; Type: TABLE; Schema: public; Owner: rails; Tablespace: 
--

CREATE TABLE developers (
    id integer NOT NULL,
    email character varying NOT NULL,
    username character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    twitter_handle character varying,
    admin boolean DEFAULT false NOT NULL,
    editor character varying DEFAULT 'Text Field'::character varying,
    slack_name character varying
);


ALTER TABLE public.developers OWNER TO rails;

--
-- Name: posts; Type: TABLE; Schema: public; Owner: rails; Tablespace: 
--

CREATE TABLE posts (
    id integer NOT NULL,
    developer_id integer NOT NULL,
    body text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    channel_id integer NOT NULL,
    title character varying NOT NULL,
    slug character varying NOT NULL,
    likes integer DEFAULT 1 NOT NULL,
    tweeted boolean DEFAULT false NOT NULL,
    published_at timestamp with time zone,
    max_likes integer DEFAULT 1 NOT NULL,
    CONSTRAINT likes CHECK ((likes >= 0))
);


ALTER TABLE public.posts OWNER TO rails;

--
-- Name: hot_posts; Type: VIEW; Schema: public; Owner: rails
--

CREATE VIEW hot_posts AS
 WITH posts_with_age AS (
         SELECT posts.id,
            posts.developer_id,
            posts.body,
            posts.created_at,
            posts.updated_at,
            posts.channel_id,
            posts.title,
            posts.slug,
            posts.likes,
            posts.tweeted,
            posts.published_at,
            GREATEST((date_part('epoch'::text, (now() - posts.published_at)) / (3600)::double precision), (0.1)::double precision) AS hour_age
           FROM posts
          WHERE (posts.published_at IS NOT NULL)
        )
 SELECT ((posts_with_age.likes)::double precision / (posts_with_age.hour_age ^ (0.8)::double precision)) AS score,
    posts_with_age.id,
    posts_with_age.developer_id,
    posts_with_age.body,
    posts_with_age.created_at,
    posts_with_age.updated_at,
    posts_with_age.channel_id,
    posts_with_age.title,
    posts_with_age.slug,
    posts_with_age.likes,
    posts_with_age.tweeted,
    posts_with_age.published_at,
    posts_with_age.hour_age
   FROM posts_with_age
  ORDER BY ((posts_with_age.likes)::double precision / (posts_with_age.hour_age ^ (0.8)::double precision)) DESC;


ALTER TABLE public.hot_posts OWNER TO rails;

--
-- Name: developer_scores; Type: VIEW; Schema: public; Owner: rails
--

CREATE VIEW developer_scores AS
 SELECT developers.id,
    developers.username,
    stats.posts,
    stats.likes,
    round(((stats.likes)::numeric / (stats.posts)::numeric), 2) AS avg_likes,
    round(log((2)::numeric, ((((1022)::double precision * ((developer_scores.score - min(developer_scores.score) OVER ()) / (max(developer_scores.score) OVER () - min(developer_scores.score) OVER ()))) + (2)::double precision))::numeric), 1) AS hotness
   FROM ((developers
     JOIN ( SELECT hot_posts.developer_id AS id,
            sum(hot_posts.score) AS score
           FROM hot_posts
          GROUP BY hot_posts.developer_id) developer_scores USING (id))
     JOIN ( SELECT posts.developer_id AS id,
            count(*) AS posts,
            sum(posts.likes) AS likes
           FROM posts
          GROUP BY posts.developer_id) stats USING (id));


ALTER TABLE public.developer_scores OWNER TO rails;

--
-- Name: developers_id_seq; Type: SEQUENCE; Schema: public; Owner: rails
--

CREATE SEQUENCE developers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.developers_id_seq OWNER TO rails;

--
-- Name: developers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: rails
--

ALTER SEQUENCE developers_id_seq OWNED BY developers.id;


--
-- Name: posts_id_seq; Type: SEQUENCE; Schema: public; Owner: rails
--

CREATE SEQUENCE posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.posts_id_seq OWNER TO rails;

--
-- Name: posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: rails
--

ALTER SEQUENCE posts_id_seq OWNED BY posts.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: rails; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


ALTER TABLE public.schema_migrations OWNER TO rails;

--
-- Name: id; Type: DEFAULT; Schema: public; Owner: rails
--

ALTER TABLE ONLY active_admin_comments ALTER COLUMN id SET DEFAULT nextval('active_admin_comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: rails
--

ALTER TABLE ONLY admin_users ALTER COLUMN id SET DEFAULT nextval('admin_users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: rails
--

ALTER TABLE ONLY authem_sessions ALTER COLUMN id SET DEFAULT nextval('authem_sessions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: rails
--

ALTER TABLE ONLY channels ALTER COLUMN id SET DEFAULT nextval('channels_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: rails
--

ALTER TABLE ONLY developers ALTER COLUMN id SET DEFAULT nextval('developers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: rails
--

ALTER TABLE ONLY posts ALTER COLUMN id SET DEFAULT nextval('posts_id_seq'::regclass);


--
-- Data for Name: active_admin_comments; Type: TABLE DATA; Schema: public; Owner: rails
--

COPY active_admin_comments (id, namespace, body, resource_id, resource_type, author_type, author_id, created_at, updated_at) FROM stdin;
\.


--
-- Name: active_admin_comments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: rails
--

SELECT pg_catalog.setval('active_admin_comments_id_seq', 1, false);


--
-- Data for Name: admin_users; Type: TABLE DATA; Schema: public; Owner: rails
--

COPY admin_users (id, email, encrypted_password, reset_password_token, reset_password_sent_at, remember_created_at, sign_in_count, current_sign_in_at, last_sign_in_at, current_sign_in_ip, last_sign_in_ip, created_at, updated_at) FROM stdin;
1	obiefernandez@gmail.com	$2a$11$hSGIKF5lJMcYrkLfKQS/4eMmY1OKTo/CcPgn29exxxxbVbLb2NDoG	\N	\N	2017-03-16 22:13:59.234069	1	2017-03-16 22:13:59.251493	2017-03-16 22:13:59.251493	108.162.237.221	108.162.237.221	2017-03-16 22:13:28.531868	2017-03-16 22:13:59.255422
\.


--
-- Name: admin_users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: rails
--

SELECT pg_catalog.setval('admin_users_id_seq', 1, true);


--
-- Data for Name: ar_internal_metadata; Type: TABLE DATA; Schema: public; Owner: rails
--

COPY ar_internal_metadata (key, value, created_at, updated_at) FROM stdin;
environment	development	2017-03-16 22:11:49.253066	2017-03-16 22:11:49.253066
\.


--
-- Data for Name: authem_sessions; Type: TABLE DATA; Schema: public; Owner: rails
--

COPY authem_sessions (id, role, subject_id, subject_type, token, expires_at, ttl, created_at, updated_at) FROM stdin;
6	developer	1	Developer	Kal57KSuGW60VNr7rHKS3MlIKnG8rM2I_gYCP5S7Rm7Am5K4XVporEB2-1Pq	2016-12-02 21:07:37.562136	2592000	2016-11-02 17:21:07.170646	2016-11-02 21:07:37.56609
28	developer	1	Developer	T4qrzB9ru2XdvC2EW27iA9iaE1iH_q-DGTc_FKDOfVqu7AAVOehZCfMghFwR	2017-06-10 16:47:24.631196	2592000	2017-05-11 16:45:02.9305	2017-05-11 16:47:24.635075
9	developer	1	Developer	xSbGlLfn-iSoU002LYgMQnQq8OO42_Cz_U6me6y3cNiUuTlauz_aubx__0O4	2016-12-29 14:54:28.910687	2592000	2016-11-29 14:31:18.534721	2016-11-29 14:54:28.920501
7	developer	1	Developer	gBwfZ5_Kd3Lrq3ph0po4ncrgsuQcDLCYwJHQzNano2qRuaCPSWF1OYGgmv1F	2016-12-07 20:20:37.212974	2592000	2016-11-07 18:31:45.385662	2016-11-07 20:20:37.216509
17	developer	1	Developer	G5TYyCOWbQVFhlzisXjCBsBjyZhm96VwOFSP8crwU1PgRWWISr2Y58o82E4n	2017-02-15 16:55:00.615008	2592000	2017-01-13 17:39:49.99384	2017-01-16 16:55:00.616098
10	developer	1	Developer	FY1ixtXyh0pRNyESUNFWGyHhvP5_NdCGw5hGevAtT-JKOioumbbQ0Pyjna7q	2016-12-31 12:43:34.60678	2592000	2016-11-30 23:47:24.812689	2016-12-01 12:43:34.643617
34	developer	1	Developer	vNNqzOD79b4tN0MpGWB3t5pTyGxFS7P0ooVoXwXiEqNgY_R62iG0LCO-IEh4	2017-10-22 18:59:44.121202	2592000	2017-09-22 18:57:37.035049	2017-09-22 18:59:44.129666
11	developer	1	Developer	2DdULj7_eTGnafUubxsFfTGJ2tNRn_q4xkkcVyU1N3BFgpqkpqsRh9ce2_tV	2017-01-13 17:53:50.506754	2592000	2016-12-14 17:53:22.823474	2016-12-14 17:53:50.511439
1	developer	1	Developer	83Y1eFTqaohf0lwy06ofR_SqpnsFSn6k0DRDF7n3w1RTqDi4ZySBPFitvXWD	2016-11-08 00:21:09.278536	2592000	2016-10-06 20:48:05.667757	2016-10-09 00:21:09.286777
4	developer	1	Developer	rP79pedErYmfx198_aCdFtlyPqFaoUmgIYuVQNqRHC6HziIiwydB7et0g4tP	2016-11-25 18:22:07.780391	2592000	2016-10-26 18:16:50.673131	2016-10-26 18:22:07.782093
13	developer	1	Developer	NYctfuUZ6-_FcjXWHigROTBk4sqVtF5rJ863nu1VIO1R_zpjVft0L5gW-Fj2	2017-01-15 03:18:21.098426	2592000	2016-12-16 03:14:23.708944	2016-12-16 03:18:21.100083
8	developer	1	Developer	Fao3hH06d-BE9FBE-Ig2mJLWrb57fPhIdG8g5rWv9bSAUmtw0kitP-oG7IqE	2016-12-28 21:15:49.070448	2592000	2016-11-28 18:48:21.921723	2016-11-28 21:15:49.074498
21	developer	1	Developer	QISlipvc8vilVKSqvdur9_50N_6jM3cLsRahPtyAscGovdAO4P3QUUHZOZyY	2017-04-15 21:20:39.743353	2592000	2017-03-16 17:23:54.391946	2017-03-16 21:20:39.747815
18	developer	1	Developer	Znf2fBK4MAVeuXXB1HgGzvb7WOLtYtpmlKAe1puzm33HnxNzYAGE9EiK9pvW	2017-02-23 19:38:01.533762	2592000	2017-01-20 19:55:03.465326	2017-01-24 19:38:01.56024
30	developer	1	Developer	WAmI2ZofPc4m3rR1p7I8eUvTtrLtpxghGht2Mnim7nalgLmlA3yitMawcJ0v	2017-09-24 15:17:21.42426	2592000	2017-08-21 16:50:20.857569	2017-08-25 15:17:21.454488
12	developer	1	Developer	w3ftdm4vaQ8_1dOxl_a3r5fkbxBBjwuFuLScJ6xY3US-NkilFcmiwLTpeOo_	2017-01-13 19:50:21.726588	2592000	2016-12-14 19:47:01.117064	2016-12-14 19:50:21.731055
14	developer	1	Developer	99JXhzTDVc2KcFqmRQnsx4v0xHJcHGa0XA6wuZc1s8ThMZlzot7FvLmgbXPE	2017-01-25 06:10:55.793803	2592000	2016-12-22 19:45:46.38202	2016-12-26 06:10:55.796331
27	developer	1	Developer	7IPPYzHGYWlqaI1hOCM2R71Ri-NXGSWH-XeaRxE0wLZTK9_Xme6h_A5bIXYl	2017-04-26 17:39:47.913586	2592000	2017-03-27 15:02:24.58737	2017-03-27 17:39:47.917008
2	developer	1	Developer	pWSApVqPT02LCaSnC3OtCRbWblCgUFSHlSxuOcq4dmViRDWkO4ZFiaODI5ES	2016-11-23 21:42:00.11313	2592000	2016-10-24 21:39:52.226506	2016-10-24 21:42:00.174669
5	developer	1	Developer	igbeQOb_hx2wX2lOpaUxFYkvYJRLbE5PSnxqHhmQB8x_q4BmF1C-e2csdVjf	2016-12-02 01:35:15.923445	2592000	2016-11-01 15:29:35.769054	2016-11-02 01:35:15.942742
33	developer	1	Developer	5-AooObQ3oDdW-hgEw8mzXSPv161VO1pl1NIOyipW3kxRE1pBytYxFPwsYKD	2017-10-06 15:49:20.730873	2592000	2017-09-06 13:39:40.54688	2017-09-06 15:49:20.746461
37	developer	1	Developer	hsoROxUQLcQ2hQ2i6hGZrQxqH5IGCx_Cf1poHEi3-SIoJ_vpR-ch9cM5UDr_	2019-03-21 04:51:34.152326	2592000	2019-01-30 18:17:34.260139	2019-02-19 04:51:34.153306
31	developer	1	Developer	EQ8yyIUPQTHjyGOIyF9XhkZ56OZt94uaX63L0SDCtOLOhV6UZyfIvtbOR6cN	2017-09-24 16:19:10.694774	2592000	2017-08-25 15:18:53.023327	2017-08-25 16:19:10.748524
32	developer	1	Developer	_gLHLMJ-tbF6vLW04v40cFz6Qw3kcQlvZWQ9tnk7v0nhpZItc7aXamM-NT9Y	2017-10-06 13:39:35.679278	2592000	2017-09-06 13:39:28.949772	2017-09-06 13:39:35.689041
3	developer	1	Developer	ZDlJeXfXz9YiQ8XRplSg7MiK3ZziHw9KUMB4WfmL73L36gboe2-0XDR4dRwY	2016-11-24 16:15:44.279352	2592000	2016-10-25 16:14:11.558586	2016-10-25 16:15:44.281152
26	developer	1	Developer	xJnroQAEW3eZWKSfYWMDRT4vLJsBLzymMPY__XzHsEYgACCBvVHWTaNj_QKY	2017-04-22 14:42:44.991967	2592000	2017-03-22 23:08:00.158576	2017-03-23 14:42:44.995291
15	developer	1	Developer	kt_gGsTfN18Zj-pslT4Nfno9ZxEazt99YMA4uLBO3NENGjUwQMKVDiivHEv7	2017-02-05 00:14:34.198104	2592000	2017-01-02 15:07:03.241157	2017-01-06 00:14:34.20756
35	developer	1	Developer	uYwxEkep89-oroJ2rIq0VvS9jem7Eb61GsXR6IxhrAMGTnv978mtyPm8gQlr	2017-11-04 20:00:27.28873	2592000	2017-10-05 19:58:25.382296	2017-10-05 20:00:27.2903
16	developer	1	Developer	IsVt0VXEviEMBxtnW1SpMmCxd4gcXEJhBblMKu56fCNHpCBkdgQtaEmW6-T_	2017-02-06 22:44:18.099161	2592000	2017-01-06 05:03:14.403278	2017-01-07 22:44:18.101795
19	developer	1	Developer	wryBHI0bWWqXIxNvj5AHG_2yiFg96UotYqys3yg11vHygGtkQLrDoOhEQJZX	2017-03-02 15:46:09.688586	2592000	2017-01-25 15:14:19.033708	2017-01-31 15:46:09.689672
29	developer	1	Developer	dANZoJB2TvAkqw5L8pwROitZ-9QB7mz44SCQOy1_RGjRZSJF8sdTxk-uzrkt	2017-09-13 01:32:22.860759	2592000	2017-08-14 01:21:59.030083	2017-08-14 01:32:22.868373
36	developer	1	Developer	KYyGRYFHLjcRV4t4vD5XDcDbj9pJ9K894pMBiMwW8nkgd1Cwbq_ImcRzZiOA	2018-04-12 13:19:09.618206	2592000	2018-03-13 13:17:51.013777	2018-03-13 13:19:09.624445
20	developer	1	Developer	vrQVRwtWS3Ufck7bEe3LZOvd_qQx401KU11GZdN_cX2df9dDGN1msAjfKxlS	2017-03-17 02:14:04.884935	2592000	2017-02-15 02:10:57.027153	2017-02-15 02:14:04.885711
\.


--
-- Name: authem_sessions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: rails
--

SELECT pg_catalog.setval('authem_sessions_id_seq', 37, true);


--
-- Data for Name: channels; Type: TABLE DATA; Schema: public; Owner: rails
--

COPY channels (id, name, created_at, updated_at, twitter_hashtag, ad) FROM stdin;
1	ruby	2016-10-06 21:19:00.010242	2016-10-06 21:19:00.010242	ruby	\N
2	business	2016-10-06 21:21:05.471111	2016-10-06 21:21:05.471111	business	\N
3	command-line	2016-10-06 21:21:05.480501	2016-10-06 21:21:05.480501	commandline	\N
4	computer-science	2016-10-06 21:21:05.484618	2016-10-06 21:21:05.484618	computerscience	\N
5	design	2016-10-06 21:21:05.488901	2016-10-06 21:21:05.488901	design	\N
6	devops	2016-10-06 21:21:05.492885	2016-10-06 21:21:05.492885	devops	\N
7	elixir	2016-10-06 21:21:05.497087	2016-10-06 21:21:05.497087	elixir	\N
8	angular	2016-10-06 21:21:05.502755	2016-10-06 21:21:05.502755	angular	\N
9	aws	2016-10-06 21:21:05.508111	2016-10-06 21:21:05.508111	aws	\N
10	serverless	2016-10-06 21:21:05.516393	2016-10-06 21:21:05.516393	serverless	\N
11	git	2016-10-06 21:21:05.523401	2016-10-06 21:21:05.523401	git	\N
12	go	2016-10-06 21:21:05.530953	2016-10-06 21:21:05.530953	go	\N
13	html-css	2016-10-06 21:21:05.538179	2016-10-06 21:21:05.538179	htmlcss	\N
14	javascript	2016-10-06 21:21:05.546871	2016-10-06 21:21:05.546871	javascript	\N
15	mobile	2016-10-06 21:21:05.552063	2016-10-06 21:21:05.552063	mobile	\N
17	react	2016-10-06 21:21:05.562247	2016-10-06 21:21:05.562247	react	\N
18	sql	2016-10-06 21:21:05.567337	2016-10-06 21:21:05.567337	sql	\N
19	testing	2016-10-06 21:21:05.572301	2016-10-06 21:21:05.572301	testing	\N
20	vim	2016-10-06 21:21:05.577009	2016-10-06 21:21:05.577009	vim	\N
21	workflow	2016-10-06 21:21:05.581645	2016-10-06 21:21:05.581645	workflow	\N
16	rails	2016-10-06 21:21:05.557441	2017-03-17 02:30:44.726	rails	- cache :rails do\r\n  %a(href="http://leanpub.com/tr5w/c/wYCbjeRUgCy8")\r\n    = image_tag "https://s3.amazonaws.com/titlepages.leanpub.com/tr5w/hero?1484762197", style: "width: auto; height: 200px; float:right; margin-right: 20px"\r\n  %h1 The "Bible" of Ruby on Rails is better than ever\r\n  %h3\r\n    For a limited time,\r\n    = link_to "get half off the ultimate The Rails 5 Way package", "http://leanpub.com/tr5w/c/wYCbjeRUgCy8"\r\n  The "Future Proof Package" is available to TIL readers for only $20. It includes The Rails 5 Way, plus early access to Obie's next two books:\r\n  %em Mastering The Rails Way\r\n  and\r\n  %em Testing The Rails Way
\.


--
-- Name: channels_id_seq; Type: SEQUENCE SET; Schema: public; Owner: rails
--

SELECT pg_catalog.setval('channels_id_seq', 21, true);


--
-- Data for Name: developers; Type: TABLE DATA; Schema: public; Owner: rails
--

COPY developers (id, email, username, created_at, updated_at, twitter_handle, admin, editor, slack_name) FROM stdin;
1	obiefernandez@gmail.com	obiefernandez	2016-10-06 20:48:05.62438	2016-10-06 20:48:05.62438	\N	f	Text Field	\N
\.


--
-- Name: developers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: rails
--

SELECT pg_catalog.setval('developers_id_seq', 2, true);


--
-- Data for Name: posts; Type: TABLE DATA; Schema: public; Owner: rails
--

COPY posts (id, developer_id, body, created_at, updated_at, channel_id, title, slug, likes, tweeted, published_at, max_likes) FROM stdin;
5	1	``` css\r\n@media print {\r\n    div {page-break-inside: avoid;}\r\n}\r\n```\r\nShould be self-explanatory. Note that you can't use this property on absolutely positioned elements, but other than that, it pretty much works perfectly for preserving logical chunks of content in printed output.	2016-11-01 15:32:22.825505	2016-11-01 15:32:23.59996	13	The most useful CSS printing directive	679cfad863	1	t	2016-11-01 11:32:22.84512-04	1
1	1	[Axios](https://www.npmjs.com/package/axios) is a slick promise-based HTTP client that works both in all modern browsers and server-side node.js. I like the simplicity of its interface.\r\n\r\n``` javascript\r\naxios.get('/user?ID=12345')\r\n  .then(function (response) {\r\n    console.log(response);\r\n  })\r\n  .catch(function (error) {\r\n    console.log(error);\r\n  });\r\n```\r\n\r\n...and the fact that it supports concurrent requests without too much hassle\r\n\r\n``` javascript\r\nfunction getUserAccount() {\r\n  return axios.get('/user/12345');\r\n}\r\n \r\nfunction getUserPermissions() {\r\n  return axios.get('/user/12345/permissions');\r\n}\r\n \r\naxios.all([getUserAccount(), getUserPermissions()])\r\n  .then(axios.spread(function (acct, perms) {\r\n    // Both requests are now complete \r\n  }));\r\n```	2016-10-06 21:29:09.369636	2019-11-22 06:15:59.418463	14	Use Axios for HTTP requests in Javascript	c5dab4c6a1	3	t	2016-10-06 17:29:09.387699-04	3
7	1	Damn, I can't believe that I didn't think of disabling this dubious "feature" sooner. Can't even begin to tell you how often an errant fingertip brush makes my Chrome history go backwards (or forwards, for that matter). Turn that shit off with the following command in your terminal.\r\n\r\n```bash\r\ndefaults write com.google.Chrome AppleEnableMouseSwipeNavigateWithScrolls -bool NO\r\n```\r\n\r\nMake sure to restart Chrome for it to take effect.	2016-11-02 17:24:06.372971	2016-11-07 19:00:55.466379	3	So you CAN disable swipe navigation in Chrome	51d8348ded	2	t	2016-11-02 13:24:06.392122-04	2
4	1	Despite being a super common request, Capybara's API doesn't give you a way to submit forms directly (without hitting a submit button). The denial to do so is actually a principled stance, as you can read for yourself in [this pull request](https://github.com/jnicklas/capybara/pull/529). In a nutshell, Jonas believes its a bad practice to do so, plus there is no standard way to support the functionality across all browsers.\r\n\r\nWorkarounds [exist](http://minimul.com/submitting-a-form-without-a-button-using-capybara.html), but seem clunky.	2016-10-26 18:22:06.937126	2016-10-26 18:22:07.450837	19	Why Capybara requires button for submitting forms	261a033e8c	1	t	2016-10-26 14:22:06.958658-04	1
8	1	Today I learned about the existence of [Google Chrome Net Internals](chrome://net-internals), a utility that gives you extensive abilities related to debugging network activity in your browser. Used it as part of trying to diagnose why some of my Rails project links were hanging in development mode.	2016-11-07 18:33:50.532419	2016-11-07 18:33:51.510882	19	Debug Network Activity in Google Chrome	e4ba772f4b	1	t	2016-11-07 13:33:50.545716-05	1
9	1	Rails 4 added support for [enumerations in Active Record classes](http://edgeapi.rubyonrails.org/classes/ActiveRecord/Enum.html). That's cool, but what's cooler is how it has been reimagined by Foraker Labs in Denver, based on the seriously underrated gem [Enumerated Type](https://github.com/rafer/enumerated_type).\r\n\r\nPlease go read [the blog post about it](https://www.foraker.com/blog/enumerated-types-in-activerecord) right now, it'll take 5-10 minutes and I promise you won't regret it.\r\n	2016-11-28 19:01:48.593461	2016-11-28 19:01:49.746759	16	Better enumerated types in Active Record	e186d1b475	1	t	2016-11-28 14:01:48.618729-05	1
2	1	While setting up the Droplet that's hosting this site, I had to switch from root to the rails user several times. In order to get gems and bundler to work properly, I needed a login shell, which  you don't get automatically just using `su`. The solution is to `exec bash -l` after `su`.\r\n\r\nWhat I didn't already know is exactly why that command does what it does. Turns out that `exec` replaces the current process (my shell) instead of starting a new sub-process. So while just typing `bash -l` will also give you the intended result, it's not as efficient.	2016-10-06 21:39:08.534818	2016-11-02 21:07:25.551937	3	Exec a Login Shell	b2864852ad	3	t	2016-10-06 17:39:08.55758-04	3
6	1	Hadn't needed to do a [clearfix](http://stackoverflow.com/questions/211383/what-methods-of-clearfix-can-i-use) in awhile and thought I would have to do something like this:\r\n\r\n```css\r\n.container::after {\r\n    content:"";\r\n    display:block;\r\n    clear:both;\r\n}\r\n```\r\nOr even worse...\r\n\r\n```css\r\n.container::before, .container::after {\r\n    content:"";\r\n    display:table;\r\n}\r\n.container::after {\r\n    clear:both;\r\n}\r\n.container {\r\n    zoom:1; /* For IE 6/7 (trigger hasLayout) */\r\n}\r\n```\r\nThen I was pleasantly surprised to [learn that on modern browsers](http://learnlayout.com/clearfix.html) you just have to set the `overflow` property to `auto` on the containing element and you should be good to go.\r\n\r\n```css\r\n.container {\r\n  overflow: auto;\r\n}\r\n```	2016-11-01 15:46:19.229818	2016-11-07 19:00:50.207657	13	Clearfixing is much easier these days	45abaaef60	2	t	2016-11-01 11:46:19.241363-04	2
10	1	This product just blew my mind, since I know how difficult it is to keep up with Node dependencies. You could manually track updates of your dependencies and test whether things continue to work. But it takes a lot of effort. So most of the time, your software is in a Schrödinger state of being potentially broken, and you have no idea until you run `npm install` and try the next time.\r\n\r\nGreenkeeper handles the chores of dependency management. npm install and npm test is called immediately after an update. There is no doubt about the state of your software.\r\n\r\nhttps://greenkeeper.io/	2016-11-29 14:33:58.363603	2016-11-29 14:33:59.379615	14	Greenkeeper.io automated dependency management	725520f5a2	1	t	2016-11-29 09:33:58.38438-05	1
3	1	When you visit location `/one` and the server redirects you to location `/two`, you expect the browser’s address bar to display the redirected URL. However, [**Turbolinks**](https://github.com/turbolinks/turbolinks) makes requests using `XMLHttpRequest`, which transparently follows redirects. There’s no way for Turbolinks to tell whether a request resulted in a redirect without additional cooperation from the server.\r\n\r\nTo work around this problem, Rails sends a `Turbolinks-Location` header in response to a visit that was redirected using `redirect_to`, and Turbolinks will replace the browser’s topmost history entry with the value provided. If for some reason you are performing redirects manually (so-to-speak, without using the `redirect_to` helper method), then you'll have to take care of adding the header yourself.	2016-10-24 21:41:58.58502	2018-04-25 09:16:31.426495	16	How Turbolinks handles redirects	ac527123f8	2	t	2016-10-24 17:41:58.613089-04	2
11	1	You are using HTML5 "typed" text input fields, aren't you?\r\n\r\nIf you make an input element with `type="email"` and you make it `required`, then the browser will take care of making sure that the email is valid on form submit. Automatically.\r\n\r\nDoesn't eliminate the need for validation on the server side, [or does it](https://davidcel.is/posts/stop-validating-email-addresses-with-regex/)?	2016-12-14 19:50:20.300015	2016-12-15 04:48:28.83635	13	Use the browser to validate email fields	93d32110c3	2	t	2016-12-14 14:50:20.330207-05	2
12	1	File this one under *huge pain in the ass*...\r\nDropbox is ending support for public folders as of September 17th, 2017. Luckily that's a lot of lead time.\r\n\r\n[Description of the new "Shared Files" functionality](https://www.dropbox.com/help/167?oref=e) that replaces public folders.\r\n\r\n	2016-12-16 03:18:20.033761	2016-12-16 03:18:20.911845	21	Dropbox is ending support for public folders	6a5f552aeb	1	t	2016-12-15 22:18:20.056738-05	1
21	1	An aspect of Rails that I adore is how it has a place for nearly everything you need to do. One of those things is to format dates/times using the `strftime` method. Instead of tucking away custom `strftime` patterns in constants, you can configure them onto the native Rails formatter, accessed via `time.to_s(:format_name)`\r\n\r\nDateTime formats are shared with Time and stored in the `Time::DATE_FORMATS` hash. Use your desired format name as the hash key and either a `strftime` string or Proc instance that takes a time or datetime argument as the value.\r\n\r\n```ruby\r\n# config/initializers/time_formats.rb\r\nTime::DATE_FORMATS[:month_and_year] = '%B %Y'\r\nTime::DATE_FORMATS[:short_ordinal] = lambda { |time| time.strftime("%B #{time.day.ordinalize}") }\r\n```\r\n\r\nHere's one of the formats that I've been using lately, to get my times into a more familiar form.\r\n\r\n```ruby\r\nTime::DATE_FORMATS[:short_time] =\r\n   lambda { |time| time.strftime('%I:%M%p').gsub('AM','am').gsub('PM','pm').gsub(':00','') }\r\n```	2017-01-20 20:00:41.006438	2017-01-20 20:00:42.11465	16	Adding your own datetime formats to Rails	77d2cc0213	1	t	2017-01-20 15:00:41.066114-05	1
13	1	In normal unit testing, you say `expect(person.calculate_bmi).to eq(21)` or something like that. Approvals allow you to assert the state of complex objects against a known state.\r\n\r\nFor example, you can say, `Approvals.verify(person)`\r\n\r\nI had not heard of this approach, which is posed as an alternative to traditional TDD.  http://approvaltests.com 	2016-12-22 20:26:07.50406	2016-12-22 20:26:08.665226	19	Approval Tests are a thing	3fac931d09	1	t	2016-12-22 15:26:07.527442-05	1
15	1	Ruby 2 gained keyword arguments while I was away in Javascript-land the last few years, and somehow I missed the memo. Loving the elegance of how you specify defaults and required parameters.\r\n\r\nThoughtbot has [the best writeup](https://robots.thoughtbot.com/ruby-2-keyword-arguments).\r\n\r\nI suspect I will not be using non-keyword arguments in my Ruby code anymore.	2016-12-23 18:40:13.801729	2016-12-23 18:40:14.611203	1	Keyword arguments in Ruby 2	79cc9ec1a7	1	t	2016-12-23 13:40:13.82606-05	1
18	1	It's better for at least a couple of reasons, eloquently stated in [this blog post by Michal Orman](http://michalorman.com/2015/02/fetch-your-environment-variables/)\r\n\r\n> ...we can set default values or handle - providing a block - gracefully missing keys. Also using `fetch` with unknown key will raise `KeyError` that will tell us which exactly key is missing. That is in fact the behavior we are expecting from the app. Without required settings is just not working and complaining about missing setting and not about some random nil references.\r\n\r\nGot that? Instead of this:\r\n\r\n```ruby\r\nAWS.config(\r\n  access_key_id:      ENV['S3_ACCESS_KEY'],\r\n  secret_access_key:  ENV['S3_SECRET_KEY'],\r\n  region:             ENV['S3_REGION']\r\n)\r\n```\r\n\r\nDo this:\r\n\r\n```ruby\r\nAWS.config(\r\n  access_key_id:      ENV.fetch('S3_ACCESS_KEY'),\r\n  secret_access_key:  ENV.fetch('S3_SECRET_KEY'),\r\n  region:             ENV.fetch('S3_REGION')\r\n)\r\n```	2017-01-13 17:43:56.462445	2017-01-13 17:43:56.851908	1	Use fetch method to access ENV variables in Ruby	22726c514a	1	t	2017-01-13 12:43:56.475089-05	1
19	1	This finding was a pleasant surprise. For years, I've been writing the same kind of boilerplate code to override `to_param` on my model classes and generate unique slugs. Turns out there's a really well-written library that does that, with some worthwhile additional functionality. Check out [FriendlyId](https://github.com/norman/friendly_id) for easy slug generation and even the ability to preserve history of slugs after changes, so that it's possible to do 301 redirects with just a couple lines of code.	2017-01-13 17:48:23.456344	2017-01-13 17:48:24.158088	16	Don't roll your own slug code, use FriendlyId	3f4658488c	1	t	2017-01-13 12:48:23.469926-05	1
17	1	Make sure to pass the migration a native Ruby hash as the default value. DO NOT pass it a string representation of an hash, thinking that it'll work (as valid JSON).\r\n\r\nDO THIS\r\n\r\n```ruby\r\nt.jsonb :preferences, default: {}, null: false\r\n```\r\n\r\nNOT\r\n\r\n```ruby\r\nt.jsonb :preferences, default: '{}', null: false\r\n```\r\nIt'll break in a maddeningly non-obvious way. Take my word for it. Also there is this\r\n[relevant StackOverflow post](http://stackoverflow.com/questions/37986984/ruby-on-rails-jsonb-column-default-value) which saved my ass.	2017-01-06 05:06:54.696516	2017-01-06 05:10:21.839465	16	Set defaults for JSONb postgres columns in Rails	2fd6272c8f	1	t	2017-01-06 00:06:54.710351-05	1
14	1	Today I woke up to an exception `RuntimeError: can't modify frozen String`\r\n\r\nI looked at the code that had raised the exception. It was doing a `gsub!` on a value out of params. It took me a bit of digging to figure out why it failed. Turns out there's an edge case that causes one of those values to get pulled out of `ENV` instead of the normal flow where it originates from the user.\r\n\r\nStrings coming out of ENV are frozen. D'oh!	2016-12-22 20:36:29.431658	2019-07-26 17:38:29.818677	1	Don't try to modify strings that come out of ENV	e460c362ba	2	t	2016-12-22 15:36:29.469503-05	2
16	1	The handy-dandy [Nodemon](https://nodemon.io/) tool is not just for Node.  Today I whipped up an invocation that can restart my Rails server whenever there are changes in the `config` directory tree. Super useful when working heavily with i18n, since changing translation files requires bouncing the server to see changes reflected in the view.\r\n\r\n```\r\n$ nodemon --watch config -e rb,yml --exec "rails server"\r\n```	2017-01-04 20:36:21.146659	2020-02-27 14:48:35.054667	16	Use Nodemon to auto-restart Rails server	d17c552d9d	3	t	2017-01-04 15:36:21.166456-05	4
22	1	If you're testing a ActiveRecord model mixin in your application, you might be tempted to unit test it in the context of one of your app's models. However, that would violate your test isolation and introduce complexities related to the behavior of the model.\r\n\r\nBetter solution is to make an Active Record class just for your test, and the fact that you can invoke schema definitions on the fly makes it super easy. Here's the top of one of my specs, illustrating the technique.\r\n\r\n```ruby\r\nrequire 'rails_helper'\r\n\r\nActiveRecord::Schema.define do\r\n  create_table :test_objects, force: true do |t|\r\n    t.jsonb :jobs, null: false, default: {}\r\n  end\r\nend\r\n\r\nclass TestObject < ApplicationRecord\r\n  include WorkerRegistry\r\nend\r\n\r\nRSpec.describe WorkerRegistry do\r\n  let(:test_object) { TestObject.create }\r\n\r\n  ...\r\n```	2017-01-20 20:06:17.098847	2017-01-20 20:06:18.058218	16	ActiveRecord test objects made easy	5f9527b87d	1	t	2017-01-20 15:06:17.117679-05	1
20	1	I learned about [Toastr](http://codeseven.github.io/toastr/demo.html) JavaScript library last week and have been delighted to use it instead of more traditional flash messaging.\r\n\r\nFirst of all get the Toastr sources. I opted to link to them on CDNJS:\r\n\r\n```haml\r\n= stylesheet_link_tag 'https://cdnjs.cloudflare.com/ajax/libs/toastr.js/2.1.3/toastr.min.css'\r\n= javascript_include_tag 'https://cdnjs.cloudflare.com/ajax/libs/toastr.js/2.1.3/toastr.min.js'\r\n```\r\n\r\nNext I defined some extra flash types in my `application_controller.rb` file to match Toastr's native notification types and enable use of the built-in styling.\r\n\r\n```ruby\r\nclass ApplicationController < ActionController::Base\r\n  add_flash_types :success, :info, :warning, :error\r\n  ...\r\n```\r\n\r\nFinally, add the following block of JavaScript to the bottom of a layout template (or whatever shared partial that contains your JS and CSS includes.\r\n\r\n```haml\r\n- flash.keys.each do |key|\r\n  - toastr_key = key\r\n  - toastr_key = 'info' if key == 'notice'\r\n  - toastr_key = 'warning' if key == 'alert'\r\n  :javascript\r\n    $(function() {\r\n      toastr["#{toastr_key}"]("#{flash[key]}");\r\n    });\r\n```\r\n\r\nLines 2 and 3 establish a mapping from conventional Rails `notice` and `alert` so that I don't have to hack libraries like Devise which rely on them.\r\n\r\nEasy.	2017-01-16 16:54:59.340624	2017-01-16 16:56:33.765455	16	Easily add Toastr flash notices to Rails apps	77b3196c4c	2	t	2017-01-16 11:54:59.402033-05	2
27	1	This one caught me by surprise today. Luckily, it's relatively simple to detect the missing functionality using Modernizr.js and use Datepickr instead.\r\n\r\n```javascript\r\n$(function(){           \r\n  if (!Modernizr.inputtypes.date) {\r\n    $('input[type=date]').datepicker({\r\n      dateFormat : 'yy-mm-dd'\r\n    });\r\n  }\r\n});\r\n```\r\n<http://stackoverflow.com/a/30503903/626048>	2017-02-15 02:14:04.298737	2017-08-06 03:36:13.882879	14	HTML5 Date Input doesn't work on Firefox #wtf	38fc905ce5	2	t	2017-02-14 21:14:04.313084-05	2
25	1	Rails inexplicably defaults to SCSS when generating stylesheets. Maybe for the same reasons that DHH doesn't like Haml?\r\n\r\nAnyway, to fix it just add the following directive to `config/environments/development.rb`:\r\n\r\n```ruby\r\nconfig.sass.preferred_syntax = :sass\r\n```	2017-01-25 15:15:55.720711	2017-01-25 15:15:56.70475	16	Change Rails default generators to Sass	a71774d4b1	1	t	2017-01-25 10:15:55.738523-05	1
23	1	Wow, how did I miss this memo? Ruby 2.3 introduced a [safe operator](http://mitrev.net/ruby/2015/11/13/the-operator-in-ruby/)\r\n\r\nInstead of\r\n\r\n```ruby\r\ncurrent_user.try(:profile).try(:bio)\r\n```\r\n\r\nyou can now do\r\n\r\n```ruby\r\ncurrent_user&.profile&.bio\r\n```	2017-01-21 22:02:40.618013	2017-05-11 16:49:21.099636	1	Ruby has a safe operator, no need to try anymore	b41a1ef15d	3	t	2017-01-21 17:02:40.650342-05	3
28	1	In the interest of fast suite runs (amongst other reasons) you want to make sure that your specs are not dependent on remote servers as they do their thing. One of the more popular ways of achieving this noble aim is by using a gem called [WebMock](https://github.com/bblimke/webmock), a library for stubbing and setting expectations on HTTP requests in Ruby.\r\n\r\nThe first time you use WebMock, code that calls external servers will break.\r\n\r\n```\r\nWebMock::NetConnectNotAllowedError:\r\n       Real HTTP connections are disabled. Unregistered request: GET https://nueprops.s3.amazonaws.com/test...\r\n\r\n       You can stub this request with the following snippet:\r\n\r\n       stub_request(:get, "https://nueprops.s3.amazonaws.com...\r\n```\r\n\r\nNow maintaining that stub code is often painful, so you probably want to use a gem called [VCR](https://github.com/vcr/vcr) to automate the process. VCR works really well. After instrumenting your spec correctly, you run it once to generate a _cassette_, which is basically a YAML file that captures the HTTP interaction(s) of your spec with the external servers. Subsequent test runs use the cassette file instead of issuing real network calls.\r\n\r\nCreation and maintenance of cassettes that mock interaction with JSON-based web services   is easy. Services that talk binary? Not so much. And almost every modern Rails project I've ever worked on uses [CarrierWave](https://github.com/carrierwaveuploader/carrierwave) (or Paperclip) to handle uploads to AWS. If you try to use VCR on those requests, you're in for a world of annoyance.\r\n\r\nEnter Fog, the cloud-abstraction library that undergirds those uploader's interactions with AWS S3. It has a [somewhat poorly documented](http://fog.io/about/getting_started.html), yet useful [_mock mode_](https://blog.engineyard.com/2011/mocking-fog-when-using-it-with-carrierwave). Using this mode, I was able to make WebMock stop complaining about CarrierWave trying to upload fixture files to S3.\r\n\r\nHowever, the GET requests generated in my specs were still failing. Given that I'm using the venerable [FactoryGirl](https://github.com/thoughtbot/factory_girl) gem to generate my test data, I was able to eventually move the `stub_request` calls out of my spec and into a better abstraction level.\r\n\r\n```ruby\r\nfactory :standard_star do\r\n  sequence(:name) { |n| "Cat Wrangler #{n}" }\r\n  description "Excellence in project management of ADD people"\r\n  icon { Rack::Test::UploadedFile.new('spec/support/stars/cat-wrangler.jpg') }\r\n  image { Rack::Test::UploadedFile.new('spec/support/stars/cat-wrangler.jpg') }\r\n  after(:create) do |s, e|\r\n    WebMock.stub_request(:get, "https://nueprops.s3.amazonaws.com/test/uploads/standard_star/image/#{s.name.parameterize}/cat-wrangler.jpg").\r\n             to_return(:status => 200, :body => s.image.file.read)\r\n\r\n    WebMock.stub_request(:get, "https://nueprops.s3.amazonaws.com/test/uploads/standard_star/icon/#{s.name.parameterize}/cat-wrangler.jpg").\r\n             to_return(:status => 200, :body => s.icon.file.read)\r\n\r\n  end\r\nend\r\n```	2017-03-16 18:18:05.29033	2017-03-16 18:18:05.685795	16	FactoryGirl, WebMock, VCR, Fog and CarrierWave	e5c4a37f26	1	t	2017-03-16 14:18:05.308206-04	1
29	1	Posting on Rails channel, since there is a [gem](https://github.com/ai/autoprefixer-rails) for using [this amazing tool](https://css-tricks.com/autoprefixer/) with your Rails apps. Using Autoprefixer, you no longer have to worry about writing or maintaining vendor-specific CSS properties. (The ones with the dash prefixes.) You just use the latest W3C standards, and the rest is taken care of for you with post-processing.	2017-03-17 02:20:52.733731	2018-10-20 08:19:25.531358	16	CSS Autoprefixer OMG!!!	1820b15584	2	t	2017-03-16 22:20:52.741821-04	2
26	1	Absentmindedly put a `counter_cache` declaration on the `has_many` instead of where it belongs (pun intended.)\r\n\r\nRails 5 will complain in the most cryptic way it possibly can, which is to raise the following exception\r\n\r\n```\r\nActiveModel::MissingAttributeError: can't write unknown attribute `true`\r\n```\r\n\r\nIf you get that error, now you know how to fix it. Good luck and godspeed.	2017-01-31 15:46:08.494636	2019-08-19 15:50:19.81768	16	When counter_cache on wrong side of association	d1fb72cc20	4	t	2017-01-31 10:46:08.516757-05	4
31	1	Ruby's `next` keyword only works in the context of a loop or enumerator method.\r\n\r\nSo if you're rendering a collection of objects using Rails `render partial: collection`, how do you skip to the next item?\r\n\r\nSince partials are compiled into methods in a dynamically generated view class, you can simulate `next` by using an explicit `return` statement. It will short-circuit the rendering of your partial template and iteration will continue with the next element of the collection.\r\n\r\nFor example\r\n\r\n```haml\r\n# app/views/users/_user.haml\r\n- return if user.disabled?\r\n  %li[user]\r\n    rest of your template...\r\n```	2017-03-27 17:39:47.091856	2017-08-06 00:52:55.974908	16	return while rendering partial collections	8cf85998fd	3	t	2017-03-27 13:39:47.102525-04	3
24	1	As of when I'm writing this (Jan 2017), support for using ActiveRecord `store` with Postgres JSONb columns is [a bit of shit-show](https://github.com/rails/rails/issues/26991#issuecomment-272280143). I'm planning to help fix it as soon as I have some time to spare, but for the moment if you want a better way of supporting these valuable column types in your Rails 5 app, use the new Attributes API. Plus get much improved performance with the Oj gem.\r\n\r\nHere's how to make it work. First, define a `:jsonb` type to replace the native one.\r\n\r\n```ruby\r\nclass JsonbType < ActiveModel::Type::Value\r\n  include ActiveModel::Type::Helpers::Mutable\r\n\r\n  def type\r\n    :jsonb\r\n  end\r\n\r\n  def deserialize(value)\r\n    if value.is_a?(::String)\r\n      Oj.load(value) rescue nil\r\n    else\r\n      value\r\n    end\r\n  end\r\n\r\n  def serialize(value)\r\n    if value.nil?\r\n      nil\r\n    else\r\n      Oj.dump(value)\r\n    end\r\n  end\r\n\r\n  def accessor\r\n    ActiveRecord::Store::StringKeyedHashAccessor\r\n  end\r\nend\r\n```\r\n\r\nNext, register it in an initializer.\r\n\r\n```ruby\r\nActiveRecord::Type.register(:jsonb, JsonbType, override: true)\r\n```\r\n\r\nNote that the `JsonbType` class will need to be somewhere in your loadpath.\r\n\r\nNow just declare the attribute at the top of your ActiveRecord model like this:\r\n\r\n```ruby\r\nclass User < ApplicationRecord\r\n  attribute :preferences, :jsonb, default: {}\r\n```	2017-01-22 23:21:29.598704	2019-11-05 14:23:55.604746	16	Rails 5 Attributes API + JSONb Postgres columns	8c31a92080	9	t	2017-01-22 18:21:29.63036-05	9
30	1	There's a [long](https://rails.lighthouseapp.com/projects/8994/tickets/5998-actionviewtestcase-does-not-honor-default_url_options-set-in-application_controllerrb)-[standing](https://github.com/rspec/rspec-rails/issues/255) [bug](https://github.com/rspec/rspec-rails/issues/1275) in the integration of controller testing into RSpec that prevents you from easily setting `default_url_options` for your controller specs. As far as I can tell, it doesn't get fixed because the RSpec teams considers the problem a bug in Rails, and the Rails team does not care if RSpec breaks.\r\n\r\nI'm talking about the issue you run into when you're trying to work with locale settings passed into your application as namespace variables in `routes.rb` like this:\r\n\r\n```ruby\r\nscope "/:locale" do\r\n    devise_for :users,  #...and so on\r\n```\r\n\r\nToday I learned that the inability to set a default `:locale` parameter can be maddening. Your specs will fail with `ActionView::Template::Error: No route matches` errors:\r\n\r\n```\r\n1) Devise::RegistrationsController POST /users should allow registration\r\n     Failure/Error: %p= link_to 'Confirm my account', confirmation_url(@resource, confirmation_token: @token)\r\n\r\n     ActionView::Template::Error:\r\n       No route matches {"action":"show","confirmation_token":"pcyw_izS8GchnT-R3EGz","controller":"devise/confirmations"} missing required keys: [:locale]\r\n```\r\n\r\nThe reason is that `ActionController::TestCase` ignores normal settings of `default_url_options` in `ApplicationController` or your `config/environments/test.rb`. No other intuitive attempt at a workaround worked either. Frustratingly, it took me around an hour to debug and come up with a monkeypatch-style workaround. The existing workarounds that I could find online are all broken in Rails 5.\r\n\r\nSo here it is:\r\n\r\n```ruby\r\n# spec/support/fix_locales.rb\r\nActionController::TestCase::Behavior.module_eval do\r\n  alias_method :process_old, :process\r\n\r\n  def process(action, *args)\r\n    if params = args.first[:params]\r\n      params["locale"] = I18n.default_locale\r\n    end\r\n    process_old(action, *args)\r\n  end\r\nend\r\n```\r\n\r\nNote the assumption that you are passing params in your spec using a symbol key and not the string `"params"`.	2017-03-22 23:22:34.506894	2020-03-03 15:56:23.349969	16	Using default_url_options in RSpec with Rails 5 	b540850342	4	t	2017-03-22 19:22:34.52811-04	4
32	1	Turns out how to switch between single and clustered modes of Puma is super unclear in the (little to non-existent) documentation. You'd think that setting `WEB_CONCURRENCY` to `1` would do it, but you actually have to set it to zero. Meaning you don't want to spin up any child processes.	2017-05-11 16:47:22.40637	2017-08-06 00:52:03.514161	16	Run Puma in Single mode for development	7457facf95	3	t	2017-05-11 12:47:22.436905-04	3
33	1	Putting this out there since I didn't find anything on StackOverflow or other places concerning this problem, which I'm sure I'm not the first to run into. CloudFlare is great, especially as a way to set-and-forget SSL on your site, along with all the other benefits you get. It acts as a proxy to your app, and if you set its SSL mode to "Flexible" then you don't have to have an SSL certificate setup on your server. This used to be a big deal when SSL certificates were expensive. (You could argue that since Let's Encrypt and free SSL certificates it's not worth using Flexible mode anymore.)\r\n\r\n![](https://dl.dropboxusercontent.com/u/1770482/cloudfront-ssl-flexible.png)\r\n\r\nAnyway, I digress. The point of this TIL is that if you proxy https requests to http endpoint in Rails 5, you'll get the dreaded `InvalidAuthenticityToken` exception whenever you try to submit any forms. It has nothing to do with the `forgery_protection_origin_check` before action in `ApplicationController`.\r\n\r\nThe dead giveaway that you're having this problem is in your logs. Look for the following two lines near each other.\r\n\r\n```\r\nWARN -- : [c2992f72-f8cc-49a2-bc16-b0d429cdef20] HTTP Origin header (https://www.example.com) didn't match request.base_url (http://www.example.com)  \r\n...\r\nFATAL -- : [c2992f72-f8cc-49a2-bc16-b0d429cdef20] ActionController::InvalidAuthenticityToken (ActionController::InvalidAuthenticityToken): \r\nAug 13 18:08:48 pb2-production app/web.1: F, [2017-08-14T01:08:48.226341 #4] FATAL -- : [c2992f72-f8cc-49a2-bc16-b0d429cdef20]    \r\n```\r\n\r\nThe solution is simple. Make sure you have working SSL and HTTPS on Heroku (or wherever you're serving your Rails application.) Turn Cloudflare SSL to Full mode. Problem solved.	2017-08-14 01:32:21.7125	2020-02-07 22:19:45.129408	16	Cloudflare Flexible SSL mode breaks Rails 5 CSRF	875a2a69af	21	t	2017-08-13 21:32:21.727237-04	21
34	1	One of the nicest features of Rails 5 is its integration with [Yarn](https://github.com/yarnpkg/yarn), the latest and greatest package manager for Node.js. Using it means you can install JavaScript dependencies for your app just as easily as you use Bundler to install Ruby gems.\r\n\r\nNow one of the biggest problems you face when using any sort of Node package management is that the combinatorial explosion of libraries downloaded in order to do anything of significance.\r\n\r\n![](http://devhumor.com/content/uploads/images/July2017/npm_package.png)\r\n\r\nGiven that reality, you really do _not_ want to add `node_modules` to your project's git repository, no more than you would want to add all the source code of your gems. Instead, you add `node_modules` to your `.gitignore` file.\r\n\r\nYarn adds a file to the root of your Rails app called `yarn.lock`. Today I learned that if you include the Node.js buildpack to your project on Heroku, it will recognize `yarn.lock` and install any required node modules for you. You just have to make sure that it [runs first in the build chain](https://stackoverflow.com/questions/43021956/how-to-get-heroku-to-recognize-a-yarn-lock-or-package-json-within-a-subdirectory/44215065#44215065).\r\n\r\n`heroku buildpacks:add --index 1 heroku/nodejs`\r\n\r\nSide note: If you use Heroku CI then you'll need to setup your test environment with the extra buildpack also by adding a new section to `app.json`.\r\n\r\n```\r\n"buildpacks": [\r\n{ "url": "heroku/nodejs" },\r\n{ "url": "heroku/ruby" }\r\n]\r\n```\r\n\r\nNote that the nodejs buildpack expects a `test` script to be present in `package.json`. If you don't have one already, just add a dummy directive there. Almost anything will work; I just put an echo statement.\r\n\r\n```\r\n"scripts": {\r\n    "test": "echo 'no tests in js'"\r\n  },\r\n```	2017-08-21 17:03:07.577882	2017-08-21 18:16:43.223281	16	How to setup Heroku Rails app to handle yarn.lock	81c8a7d6e3	1	t	2017-08-21 14:16:42.335541-04	1
35	1	A few years ago I heard about a project called [Fourchette](https://github.com/rainforestapp/fourchette), which facilitated setting up one Heroku app per pull request on a project (aka _review apps_). I remember being all like THAT'S FREAKING BRILLIANT! Then I went back to whatever I was doing and never did anything about it.\r\n\r\nWell, this week I finally had the time and inclination to get review apps working on Heroku. The instructions are out there, but they gave me enough trouble that I figured I'd document the gotchas for posterity.\r\n\r\n## #1. Understand the app.json file, really\r\n\r\nWe already had a tiny [`app.json`](https://devcenter.heroku.com/articles/app-json-schema) file that we had created in connection with getting [Heroku CI](https://devcenter.heroku.com/articles/heroku-ci) to run our test suite. All it had was an environments section that looked like this:\r\n\r\n```\r\n"environments": {\r\n  "test": {\r\n     "env": {\r\n      "DEBUG_MAIL": "true",\r\n      "OK_TO_SEED": "true"\r\n    },\r\n    "addons":[\r\n      "heroku-postgresql:hobby-basic",\r\n      "heroku-redis:hobby-dev"\r\n    ]\r\n```\r\nWhen I started trying to get review apps to work, I simply created a pull request, and followed the dashboard instructions for creating review apps, assuming that since we already had an `app.json` file that it would _just work_. Nope, not at all.\r\n\r\nAfter much thrashing, what finally got me over the hump was understanding the purpose of `app.json` from first principles, which didn't happen until I read [this description of the Heroku Platform API](https://devcenter.heroku.com/articles/setting-up-apps-using-the-heroku-platform-api). App.json originally came about as a way to automate the creation of an entire Heroku project, not just a CI or Review configuration. It predates CI and Review Apps and has been in essence repurposed.\r\n\r\n## #2. Add all your ENV variables\r\n\r\nThe concept of ENV variables being inherited from the designated parent app really threw me for a loop at first. I figured that the only ENV variables needed to be declared in the `env` section of app.json would be the ones I was overriding with a fixed value. Wrong again.\r\n\r\nAfter much trial-and-error, I ended up with a list of all the same ENV variables as my staging environment. Some with fixed values, but most just marked as required.\r\n\r\n```\r\n"env": {\r\n    "AWS_ACCESS_KEY_ID": {\r\n      "required": true\r\n    },\r\n    "AWS_SECRET_ACCESS_KEY": {\r\n      "required": true\r\n    },\r\n```\r\n\r\nThis won't make sense if you're thinking that app.json is specifically for setting up Review Apps (see #1 above.)\r\n\r\n## #3. Understand the lifecycle, especially with regards to add-ons\r\nAfter everything was mostly working (meaning that I was able to get past the build stage and actually access my web app via the browser) I still kept getting errors related to the Redis server being missing. To make a long story short, not only did I have to add it to the `addons` section, but I also had to delete the review app altogether and create it again, so that addons would be created. (Addons are not affected by redeployment.)\r\n\r\n```\r\n"addons":[\r\n  "heroku-postgresql:hobby-basic",\r\n  "heroku-redis:hobby-dev",\r\n  "memcachier:dev"\r\n],\r\n```\r\nIn retrospect, I realize that the reason that was totally unclear is that my review apps Postgres add-on was automatically created, even before I added an `addons` section to app.json. (Initially I thought it was coming from the test environment.)\r\n\r\nI still don't know if Postgres is added by default to all review apps, or inherited from the parent app.\r\n\r\n## 4. Post deploy to the rescue\r\n\r\nThere's at least one thing you want to do once, every time a new review app is created, and that is to load your database schema. You probably want to seed data also.\r\n\r\n```\r\n"scripts": {\r\n  "postdeploy": "OK_TO_SEED=true bundle exec rails db:schema:load db:seed"\r\n}\r\n```\r\n\r\nAs an aside, I have learned to put an `OK_TO_SEED` conditional check around destructive seed operations to help prevent running in production. This is especially important if you run your staging instances in `production` mode, [like you should](https://devcenter.heroku.com/articles/deploying-to-a-custom-rails-environment).	2017-08-25 13:00:15.642772	2020-01-11 07:58:18.582983	16	Getting Heroku Review Apps to Work	4a4e0b9599	6	t	2017-08-25 09:00:15.730542-04	6
39	1	Today as I was looking at a table in DynamoDB via the AWS console. This table is basically a queue of items for a particular user to look at or dismiss, and right now it only has two key columns: one for the user, and one for the item.\r\n\r\nIt struck me that it would be worthwhile to add a few extra columns to this table just to make administration and debugging a little easier. Namely, we could add the name of the user and the name of the item. At worst the tradeoff is that the read/write throughput for the table would be a little higher.	2019-01-30 20:06:28.493706	2019-01-31 07:12:28.866461	10	Vanity columns in join tables	fb5116a868	2	t	2019-01-30 15:08:06.04629-05	2
37	1	From the [changelog](https://github.com/rails/rails/blob/5-1-stable/activerecord/CHANGELOG.md)\r\n\r\n![image](https://user-images.githubusercontent.com/3908/30759940-d56de402-9f9d-11e7-9070-54f2db54109d.png)\r\n\r\nNow if only someone would add it to `has_one` relationships. Tim says it's harder because then you're setting attributes on another object.	2017-09-22 18:59:42.310198	2017-09-23 00:05:00.66596	16	Rails 5.1 added :default option to belongs_to	b6ec4374c0	2	t	2017-09-22 14:59:42.386699-04	2
38	1	Great article at http://tech.degica.com/en/2017/10/03/rubykaigi/ by Chris Salzberg\r\n\r\n> some of the most interesting features of a language are not the ones that are cleverly designed, but the ones that emerge out of a clever design\r\n\r\n	2017-10-05 20:00:26.099614	2017-10-05 20:00:27.032279	1	a Ruby Module is a Class that can be subclassed	8733471581	1	t	2017-10-05 16:00:26.120883-04	1
36	1	Hat tip to my editor [Cynthia](http://www.authorsden.com/cynthiarogersparks) for pointing out why I should never use the word "impactful" in my writing.\r\n\r\n![image](https://user-images.githubusercontent.com/3908/30115108-5d7cc172-92df-11e7-87b8-3c3f98e55937.png)\r\n\r\n![image](https://user-images.githubusercontent.com/3908/30115193-9448467c-92df-11e7-80d3-334e3d486377.png)\r\n\r\nI laughed out loud when I got to that last part (highlight mine.)\r\n\r\nFull explanation [here](http://www.dictionary.com/browse/impactful?s=t)	2017-09-06 13:46:06.751675	2019-01-29 18:48:18.622214	2	Don't Use the Word "Impactful," not worth the risk	05f7c4bae9	3	t	2017-09-06 09:46:07.002288-04	3
43	1	Ran into an issue today with the following code. It's the second or third time it's bitten me, and I think this time I finally am learning the general guideline: don't pass complex objects into your lambda success/failure callbacks!\r\n\r\n```js\r\nexport async function main(event, context, callback) {\r\n  const id = event.pathParameters.id;\r\n  try {\r\n    const result = await startExecution(\r\n      process.env.statemachine_arn, JSON.stringify({ id })\r\n    );\r\n    callback(null, success({ status: true, result }));\r\n  } catch (error) {\r\n    console.log(error.message);\r\n    callback(error, failure({ status: false, message: error.message }));\r\n  }\r\n}\r\n```\r\nThis lambda will fail with `Converting circular structure to JSON` exception, because the result object returned from the `startExecution` function is a big complex object that doesn't work with `JSON.stringify`. I've had the same thing happen to me with the results of `axios` requests, as well as other AWS service calls.\r\n\r\nTo fix, don't pass `result` but instead pass only what you need returned, or simply `true`.	2019-02-13 17:13:31.162566	2019-02-13 17:13:31.420278	10	Careful sending complex objects to lambda callback	00fb51b25c	1	t	2019-02-13 12:13:31.166751-05	1
42	1	```js\r\nbody = await sendEmail({\r\n      from: 'Demos.Guru <support@demos.guru>',\r\n      replyTo: submission.reviewerEmail || undefined,\r\n      to: user.email,\r\n```\r\nToday I learned one of the practical differences between `null` and `undefined` thanks to my good friend and Kickass Partner Richard Kaufman <https://richardkaufman.xyz>.\r\n\r\nIn the code snippet shown, setting `replyTo` to `undefined` makes it disappear from the object, whereas setting it to `null` would leave the property in the object, with its value set to `null`. Makes perfect sense.	2019-02-12 22:46:28.976334	2019-02-12 22:47:07.551908	14	Practical difference undefined vs null in JS	879b8c5b83	1	t	2019-02-12 17:47:07.279636-05	1
44	1	Dynamodb has a query system with a particularly hard learning curve (in my opinion.) Even though I've been using it for years now, I still run into some sticky problems like this one today when I tried to use an `IN` operator in a query expression. Should be fine, right?\r\n\r\n```js\r\n    const key = {\r\n      IndexName: 'by_label_and_status',\r\n      KeyConditionExpression:\r\n        'labelId = :labelId and submissionStatus in (:sent, :opened, :listened)',\r\n      ExpressionAttributeValues: {\r\n        ':labelId': event.pathParameters.labelId,\r\n        ':sent': 'sent',\r\n        ':opened': 'opened',\r\n        ':listened': 'listened',\r\n      },\r\n    };\r\n    const result = await dynamodb.query('submissions', key);\r\n```\r\nThe code above actually fails. Dynamodb is kind enough to report `Invalid operator used in KeyConditionExpression: IN`, but finding the reason why took me a bit of digging.\r\n\r\nIt turns out that indeed if you go to the [guide](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_Query.html#API_Query_RequestSyntax) for Dynamodb expression syntax, you'll see that the allowed comparators for `KeyConditionExpression` are limited.\r\n\r\n>Valid comparisons for the sort key condition are as follows:\r\n>\r\n>sortKeyName = :sortkeyval - true if the sort key value is equal to :sortkeyval.\r\n>\r\n>sortKeyName < :sortkeyval - true if the sort key value is less than :sortkeyval.\r\n>\r\n>sortKeyName <= :sortkeyval - true if the sort key value is less than or equal to :sortkeyval.\r\n>\r\n>sortKeyName > :sortkeyval - true if the sort key value is greater than :sortkeyval.\r\n>\r\n>sortKeyName >= :sortkeyval - true if the sort key value is greater than or equal to :sortkeyval.\r\n>\r\n>sortKeyName BETWEEN :sortkeyval1 AND :sortkeyval2 - true if the sort key value is greater than or equal to :sortkeyval1, and less than or equal to :sortkeyval2.\r\n>\r\n>begins_with ( sortKeyName, :sortkeyval ) - true if the sort key value begins with a particular operand. (You cannot use this function with a sort key that is of type Number.) Note that the function name begins_with is case-sensitive.\r\n>\r\n>Use the ExpressionAttributeValues parameter to replace tokens such as :partitionval and :sortval with actual values at runtime.\r\n\r\nSince the system I'm working on is brand new, I was able to get the code example working by changing the values of our statuses. Instead of having completely disparate statuses for `sent`, `clicked`, and `opened`, I changed them to be `sent`, `sent_clicked`, and `sent_opened`. They are semantically correct, since clicked and opened states are also sent. That change allowed us to use `begins_with` instead of the prohibited `IN` operator.\r\n\r\n```js\r\n    const key = {\r\n      IndexName: 'by_label_and_status',\r\n      KeyConditionExpression:\r\n        'labelId = :labelId and begins_with(submissionStatus, :submissionStatus)',\r\n      ExpressionAttributeValues: {\r\n        ':labelId': event.pathParameters.labelId,\r\n        ':submissionStatus': 'sent',\r\n      },\r\n    };\r\n```\r\n\r\n---\r\nPurchase my Serverless book at https://leanpub.com/serverless	2019-02-18 22:30:01.277352	2019-02-19 01:27:29.220748	10	Limitations of Dynamodb KeyConditionExpression	184022159f	1	t	2019-02-18 17:30:01.291409-05	1
46	1	https://visualstudio.microsoft.com/services/live-share/\r\n\r\nIf you're a fan of pair programming like I am and you haven't tried VSCode's live sharing functionality, then prepare to be delighted and amazed. It's breathtaking. You get multi-cursor support, and seamless sharing of local servers and terminals. Totally blew me away, and we will be using it for sure at Kickass Partners.	2019-02-19 01:58:33.444462	2019-02-19 04:49:32.159734	21	VSCode live sharing rules for pair programming	201320fba9	3	t	2019-02-18 20:58:33.452447-05	3
41	1	![img](https://developers.google.com/web/updates/images/2018/10/store2.png)\r\nI've often wanted to be able to query/manipulate a DOM node. Super easy to do now that you can right-click in the inspector and assign to a global variable.\r\n\r\nMore info at https://developers.google.com/web/updates/2018/10/devtools#store	2019-02-05 01:49:36.78944	2019-04-09 00:43:49.391569	14	Save a DOM node to a global variable in Chrome 71	0cb57fdf0b	2	t	2019-02-04 20:49:36.79628-05	2
47	1	> Asynchronous lambda invocation allows for a quick response back (e.g. 202 Accepted) while allowing the lambda to continue running. This would be desired if you wish to kick off a lambda that runs longer then the API GW 30 second timeout, or if the application needs a quick response without the need for direct success for failure of the longer running lambda.\r\n\r\nAt the time of this post this feature is not natively supported by serverless framework, but it looks trivial to set it up via a resource override. More information at https://github.com/serverless/serverless/issues/4862\r\n---\r\nPurchase my Serverless book at https://leanpub.com/serverless	2019-02-19 04:51:33.691902	2019-02-19 04:51:33.942353	10	Kick off async lambda processing from API Gateway	f98df25c02	1	t	2019-02-18 23:51:33.696338-05	1
45	1	Finally figured out why some of my expired items fail to delete when expected. (bold mine)\r\n> DynamoDB typically deletes expired items **within 48 hours of expiration**. The exact duration within which an item truly gets deleted after expiration is specific to the nature of the workload and the size of the table. Items that have expired and not been deleted will still show up in reads, queries, and scans. These items can still be updated and successful updates to change or remove the expiration attribute will be honored.\r\n\r\nBottom line: you can't rely on DynamoDB's  `ttl` column based expiration to do minute-precise expiration of things in your serverless app. Luckily for my purposes, I don't need minute precision. I do however need hour precision, so I'm planning to write a little scheduled lambda that kicks off every sixty minutes and reaps whatever records have expired but not deleted yet, and delete them manually.\r\n\r\n---\r\nPurchase my Serverless book at https://leanpub.com/serverless\r\n\r\n	2019-02-19 01:33:52.902595	2019-02-19 02:59:34.72162	10	Dynamodb ttl expiration is not minute precise	d1d9316cff	2	t	2019-02-18 20:33:52.911024-05	2
40	1	Figuring this out has taken a few hours out of my day.\r\n\r\n### Assumption\r\n\r\nYour system is comprised of multiple CloudFormation stacks (aka Serverless Framework *services* aka *microservices*)\r\n\r\n### What not to do\r\n\r\n```\r\nfunctions:\r\n  dispatcher:\r\n    handler: dispatcher.dispatch\r\n    events:\r\n      - sns: 'demo_submitted'\r\n```\r\n\r\nIt is critically important to not create SNS topic subscriptions *on the fly* as lambda event triggers. The reason is that Serverless framework tries to be helpful by implicitly auto-magically creating resource declarations for those topics, effectively within the boundaries of the *consumer* service. Unless parts of your microservice are talking amongst themselves using SNS (which would be weird), you usually subscribe to SNS topics that originate in other services, not the one where you are consuming it.\r\n\r\n### Why not to do it\r\n\r\nLet's say you try to subscribe to the same topic with a lambda in another service OR you go down the road of explicitly declaring topics as resources in the services that broadcast to the topics AND you've implicitly created those very same SNS topics already.\r\n\r\nThen when you try to deploy you will get an error that looks something like this:\r\n\r\n```\r\nServerless Error ---------------------------------------\r\n  An error occurred: DemoSubmittedTopic - demo_submitted already exists in stack arn:aws:cloudformation:us-east-1:423:stack/producers-service-dev/5332a.\r\n```\r\n\r\nResources must be unique and in this case, you already created that SNS topic in the consumer, not where it belongs and is expected to live.\r\n\r\n### What to do instead\r\n\r\nWhen you subscribe a lambda to an SNS topic, use the ARN notation as described in https://serverless.com/framework/docs/providers/aws/events/sns#using-a-pre-existing-topic\r\n\r\n```\r\nfunctions:\r\n  dispatcher:\r\n    handler: dispatcher.dispatch\r\n    events:\r\n      - sns:\r\n          arn: arn:xxx\r\n```\r\n\r\nThe ARN notation in the subscription prevents the auto-magical undesirable creation of an SNS resource.	2019-02-01 01:48:17.911743	2020-02-24 19:38:47.424294	10	How to properly do SNS in Serverless	494a65d156	2	t	2019-01-31 20:48:17.919088-05	2
\.


--
-- Name: posts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: rails
--

SELECT pg_catalog.setval('posts_id_seq', 47, true);


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: rails
--

COPY schema_migrations (version) FROM stdin;
20150316165229
20150316165241
20150317204546
20150319202107
20150319204402
20150324163219
20150408210733
20150414002719
20150424190902
20150430195052
20150501143525
20150501152953
20150529183728
20150529190009
20150529190148
20150601191337
20150603155844
20150610141445
20150610145829
20150825183004
20150903191744
20150922171442
20150925155814
20151001212705
20160115214137
20160115214650
20160125205238
20160205153837
20160211043316
20160223002123
20160622144602
20160622152349
20160622154534
20160701161129
20160708201736
20170316191026
20170316191029
20170316204203
\.


--
-- Name: active_admin_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: rails; Tablespace: 
--

ALTER TABLE ONLY active_admin_comments
    ADD CONSTRAINT active_admin_comments_pkey PRIMARY KEY (id);


--
-- Name: admin_users_pkey; Type: CONSTRAINT; Schema: public; Owner: rails; Tablespace: 
--

ALTER TABLE ONLY admin_users
    ADD CONSTRAINT admin_users_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: rails; Tablespace: 
--

ALTER TABLE ONLY ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: authem_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: rails; Tablespace: 
--

ALTER TABLE ONLY authem_sessions
    ADD CONSTRAINT authem_sessions_pkey PRIMARY KEY (id);


--
-- Name: channels_pkey; Type: CONSTRAINT; Schema: public; Owner: rails; Tablespace: 
--

ALTER TABLE ONLY channels
    ADD CONSTRAINT channels_pkey PRIMARY KEY (id);


--
-- Name: developers_pkey; Type: CONSTRAINT; Schema: public; Owner: rails; Tablespace: 
--

ALTER TABLE ONLY developers
    ADD CONSTRAINT developers_pkey PRIMARY KEY (id);


--
-- Name: posts_pkey; Type: CONSTRAINT; Schema: public; Owner: rails; Tablespace: 
--

ALTER TABLE ONLY posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: unique_slug; Type: CONSTRAINT; Schema: public; Owner: rails; Tablespace: 
--

ALTER TABLE ONLY posts
    ADD CONSTRAINT unique_slug UNIQUE (slug);


--
-- Name: index_active_admin_comments_on_author_type_and_author_id; Type: INDEX; Schema: public; Owner: rails; Tablespace: 
--

CREATE INDEX index_active_admin_comments_on_author_type_and_author_id ON active_admin_comments USING btree (author_type, author_id);


--
-- Name: index_active_admin_comments_on_namespace; Type: INDEX; Schema: public; Owner: rails; Tablespace: 
--

CREATE INDEX index_active_admin_comments_on_namespace ON active_admin_comments USING btree (namespace);


--
-- Name: index_active_admin_comments_on_resource_type_and_resource_id; Type: INDEX; Schema: public; Owner: rails; Tablespace: 
--

CREATE INDEX index_active_admin_comments_on_resource_type_and_resource_id ON active_admin_comments USING btree (resource_type, resource_id);


--
-- Name: index_admin_users_on_email; Type: INDEX; Schema: public; Owner: rails; Tablespace: 
--

CREATE UNIQUE INDEX index_admin_users_on_email ON admin_users USING btree (email);


--
-- Name: index_admin_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: rails; Tablespace: 
--

CREATE UNIQUE INDEX index_admin_users_on_reset_password_token ON admin_users USING btree (reset_password_token);


--
-- Name: index_authem_sessions_on_expires_at_and_token; Type: INDEX; Schema: public; Owner: rails; Tablespace: 
--

CREATE UNIQUE INDEX index_authem_sessions_on_expires_at_and_token ON authem_sessions USING btree (expires_at, token);


--
-- Name: index_authem_sessions_subject; Type: INDEX; Schema: public; Owner: rails; Tablespace: 
--

CREATE INDEX index_authem_sessions_subject ON authem_sessions USING btree (expires_at, subject_type, subject_id);


--
-- Name: index_posts_on_channel_id; Type: INDEX; Schema: public; Owner: rails; Tablespace: 
--

CREATE INDEX index_posts_on_channel_id ON posts USING btree (channel_id);


--
-- Name: index_posts_on_developer_id; Type: INDEX; Schema: public; Owner: rails; Tablespace: 
--

CREATE INDEX index_posts_on_developer_id ON posts USING btree (developer_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: rails; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: fk_rails_06b7a0db99; Type: FK CONSTRAINT; Schema: public; Owner: rails
--

ALTER TABLE ONLY posts
    ADD CONSTRAINT fk_rails_06b7a0db99 FOREIGN KEY (channel_id) REFERENCES channels(id);


--
-- Name: fk_rails_2c578d8f8f; Type: FK CONSTRAINT; Schema: public; Owner: rails
--

ALTER TABLE ONLY posts
    ADD CONSTRAINT fk_rails_2c578d8f8f FOREIGN KEY (developer_id) REFERENCES developers(id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

