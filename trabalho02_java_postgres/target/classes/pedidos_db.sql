--
-- PostgreSQL database dump
--

-- Dumped from database version 16.9 (Ubuntu 16.9-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.9 (Ubuntu 16.9-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: logestoquezero_func(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.logestoquezero_func() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.estoque = 0 THEN
        RAISE WARNING 'O estoque do produto % (ID: %) chegou a zero!', NEW.nome, NEW.id;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.logestoquezero_func() OWNER TO postgres;

--
-- Name: obterprecoproduto(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.obterprecoproduto(p_produto_id integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_preco DECIMAL(10, 2);
BEGIN
    SELECT preco INTO v_preco FROM produtos WHERE id = p_produto_id;
    RETURN v_preco;
END;
$$;


ALTER FUNCTION public.obterprecoproduto(p_produto_id integer) OWNER TO postgres;

--
-- Name: realizarpedido(integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.realizarpedido(IN p_produto_id integer, IN p_quantidade integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Verificar se há estoque suficiente
    IF (SELECT estoque FROM produtos WHERE id = p_produto_id) < p_quantidade THEN
        RAISE EXCEPTION 'Estoque insuficiente para o produto ID %', p_produto_id;
    END IF;

    -- Inserir o novo pedido
    INSERT INTO pedidos (produto_id, quantidade) VALUES (p_produto_id, p_quantidade);

    -- Atualizar o estoque do produto
    UPDATE produtos SET estoque = estoque - p_quantidade WHERE id = p_produto_id;

    RAISE NOTICE 'Pedido realizado com sucesso para o produto ID % com quantidade %.', p_produto_id, p_quantidade;
END;
$$;


ALTER PROCEDURE public.realizarpedido(IN p_produto_id integer, IN p_quantidade integer) OWNER TO postgres;

--
-- Name: validarquantidadepedido_func(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.validarquantidadepedido_func() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.quantidade <= 0 THEN
        RAISE EXCEPTION 'A quantidade do pedido deve ser um valor positivo.';
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.validarquantidadepedido_func() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: pedidos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pedidos (
    id integer NOT NULL,
    produto_id integer NOT NULL,
    quantidade integer NOT NULL,
    data_pedido timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    status character varying(50) DEFAULT 'Pendente'::character varying
);


ALTER TABLE public.pedidos OWNER TO postgres;

--
-- Name: pedidos_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pedidos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pedidos_id_seq OWNER TO postgres;

--
-- Name: pedidos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pedidos_id_seq OWNED BY public.pedidos.id;


--
-- Name: produtos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.produtos (
    id integer NOT NULL,
    nome character varying(100) NOT NULL,
    preco numeric(10,2) NOT NULL,
    estoque integer NOT NULL
);


ALTER TABLE public.produtos OWNER TO postgres;

--
-- Name: produtos_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.produtos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.produtos_id_seq OWNER TO postgres;

--
-- Name: produtos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.produtos_id_seq OWNED BY public.produtos.id;


--
-- Name: pedidos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedidos ALTER COLUMN id SET DEFAULT nextval('public.pedidos_id_seq'::regclass);


--
-- Name: produtos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.produtos ALTER COLUMN id SET DEFAULT nextval('public.produtos_id_seq'::regclass);


--
-- Data for Name: pedidos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pedidos (id, produto_id, quantidade, data_pedido, status) FROM stdin;
1	1	2	2025-07-23 10:43:16.086006	Pendente
3	1	2	2025-07-23 11:32:54.743625	Pendente
\.


--
-- Data for Name: produtos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.produtos (id, nome, preco, estoque) FROM stdin;
2	Notebook	3000.00	50
3	Fone de Ouvido	250.00	200
1	Smartphone	1500.00	96
\.


--
-- Name: pedidos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pedidos_id_seq', 4, true);


--
-- Name: produtos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.produtos_id_seq', 3, true);


--
-- Name: pedidos pedidos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedidos
    ADD CONSTRAINT pedidos_pkey PRIMARY KEY (id);


--
-- Name: produtos produtos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.produtos
    ADD CONSTRAINT produtos_pkey PRIMARY KEY (id);


--
-- Name: produtos logestoquezero_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER logestoquezero_trigger AFTER UPDATE OF estoque ON public.produtos FOR EACH ROW EXECUTE FUNCTION public.logestoquezero_func();


--
-- Name: pedidos validarquantidadepedido_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER validarquantidadepedido_trigger BEFORE INSERT ON public.pedidos FOR EACH ROW EXECUTE FUNCTION public.validarquantidadepedido_func();


--
-- Name: pedidos fk_produto; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedidos
    ADD CONSTRAINT fk_produto FOREIGN KEY (produto_id) REFERENCES public.produtos(id);


--
-- PostgreSQL database dump complete
--

