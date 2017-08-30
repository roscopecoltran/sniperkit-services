--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: artist; Type: TABLE; Schema: public; Owner: sps_admin; Tablespace: 
--

CREATE TABLE artist (
    id integer NOT NULL,
    name character varying(200) NOT NULL
);


ALTER TABLE public.artist OWNER TO sps_admin;

--
-- Name: artist_id_seq; Type: SEQUENCE; Schema: public; Owner: sps_admin
--

CREATE SEQUENCE artist_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.artist_id_seq OWNER TO sps_admin;

--
-- Name: artist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sps_admin
--

ALTER SEQUENCE artist_id_seq OWNED BY artist.id;


--
-- Name: song; Type: TABLE; Schema: public; Owner: sps_admin; Tablespace: 
--

CREATE TABLE song (
    id integer NOT NULL,
    artist_id integer NOT NULL,
    title character varying(200) NOT NULL,
    text text NOT NULL
);


ALTER TABLE public.song OWNER TO sps_admin;

--
-- Name: song_id_seq; Type: SEQUENCE; Schema: public; Owner: sps_admin
--

CREATE SEQUENCE song_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.song_id_seq OWNER TO sps_admin;

--
-- Name: song_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sps_admin
--

ALTER SEQUENCE song_id_seq OWNED BY song.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: sps_admin
--

ALTER TABLE ONLY artist ALTER COLUMN id SET DEFAULT nextval('artist_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: sps_admin
--

ALTER TABLE ONLY song ALTER COLUMN id SET DEFAULT nextval('song_id_seq'::regclass);


--
-- Data for Name: artist; Type: TABLE DATA; Schema: public; Owner: sps_admin
--

COPY artist (id, name) FROM stdin;
1	Йорш
2	DDT
3	Сектор Газа
\.


--
-- Name: artist_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sps_admin
--

SELECT pg_catalog.setval('artist_id_seq', 34, true);


--
-- Data for Name: song; Type: TABLE DATA; Schema: public; Owner: sps_admin
--

COPY song (id, artist_id, title, text) FROM stdin;
1	2	Пацаны	очень трогательная песня
2	1	Мертвая Шлюха	Федина влажная мечта
3	3	Частушки	После 0.5 беленькой заебись
\.


--
-- Name: song_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sps_admin
--

SELECT pg_catalog.setval('song_id_seq', 33, true);


--
-- Name: artist_pkey; Type: CONSTRAINT; Schema: public; Owner: sps_admin; Tablespace: 
--

ALTER TABLE ONLY artist
    ADD CONSTRAINT artist_pkey PRIMARY KEY (id);


--
-- Name: song_pkey; Type: CONSTRAINT; Schema: public; Owner: sps_admin; Tablespace: 
--

ALTER TABLE ONLY song
    ADD CONSTRAINT song_pkey PRIMARY KEY (id);


--
-- Name: song_artist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sps_admin
--

ALTER TABLE ONLY song
    ADD CONSTRAINT song_artist_id_fkey FOREIGN KEY (artist_id) REFERENCES artist(id);


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

