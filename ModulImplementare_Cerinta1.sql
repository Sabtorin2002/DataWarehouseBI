CREATE TABLE MAGAZIN_UOUK (
    id_magazin NUMBER PRIMARY KEY,
    nume_magazin VARCHAR2(100),
    tip_magazin VARCHAR2(50),
    suprafata_mp NUMBER
);

CREATE TABLE FUNCTIE_UOUK(
    id_functie NUMBER PRIMARY KEY,
    denumire_functie VARCHAR2(50)
);

CREATE TABLE TVA_UOUK(
    id_tva NUMBER PRIMARY KEY,
    procent_tva NUMBER(5,2),
    descriere VARCHAR2(50)
);

CREATE TABLE CATEGORIE_PRODUS_UOUK (
    id_categorie_produs NUMBER PRIMARY KEY,
    denumire_categorie VARCHAR2(100)
);

CREATE TABLE PRODUCATOR_UOUK (
    id_producator NUMBER PRIMARY KEY,
    nume_producator VARCHAR2(100)
);

CREATE TABLE FURNIZOR_UOUK (
    id_furnizor NUMBER PRIMARY KEY,
    nume_furnizor VARCHAR2(100),
    cod_fiscal VARCHAR2(20)
);

CREATE TABLE PROMOTIE_UOUK (
    id_promotie NUMBER PRIMARY KEY,
    nume_promotie VARCHAR2(100),
    tip_promotie VARCHAR2(50),
    start_date DATE,
    end_date DATE
);

CREATE TABLE ANGAJAT_UOUK (
    id_angajat NUMBER PRIMARY KEY,
    nume VARCHAR2(50),
    prenume VARCHAR2(50),
    data_angajare DATE,
    id_functie NUMBER,
    CONSTRAINT fk_ang_func FOREIGN KEY (id_functie) REFERENCES FUNCTIE_UOUK(id_functie)
);

CREATE TABLE PRODUS_UOUK (
    id_produs NUMBER PRIMARY KEY,
    cod_articol_sursa VARCHAR2(50),
    denumire_produs VARCHAR2(200),
    cod_ean13 VARCHAR2(20),
    um VARCHAR2(20),
    id_categorie_produs NUMBER,
    id_producator NUMBER,
    CONSTRAINT fk_prod_cat FOREIGN KEY (id_categorie_produs) REFERENCES CATEGORIE_PRODUS_UOUK(id_categorie_produs),
    CONSTRAINT fk_prod_prod FOREIGN KEY (id_producator) REFERENCES PRODUCATOR_UOUK(id_producator)
);

-- Tabel de legatura Many-to-Many (daca exista in diagrama)
CREATE TABLE PRODUS_PROMOTIE_UOUK (
    id_produs NUMBER,
    id_promotie NUMBER,
    CONSTRAINT pk_prod_prom PRIMARY KEY (id_produs, id_promotie),
    CONSTRAINT fk_pp_prod FOREIGN KEY (id_produs) REFERENCES PRODUS_UOUK(id_produs),
    CONSTRAINT fk_pp_prom FOREIGN KEY (id_promotie) REFERENCES PROMOTIE_UOUK(id_promotie)
);

CREATE TABLE FACTURA_INTRARE_UOUK (
    id_factura_intrare NUMBER PRIMARY KEY,
    numar_factura VARCHAR2(50),
    data_factura DATE,
    id_furnizor NUMBER,
    id_magazin NUMBER,
    id_angajat NUMBER, -- Cine a facut receptia
    CONSTRAINT fk_fact_furn FOREIGN KEY (id_furnizor) REFERENCES FURNIZOR_UOUK(id_furnizor),
    CONSTRAINT fk_fact_mag FOREIGN KEY (id_magazin) REFERENCES MAGAZIN_UOUK(id_magazin),
    CONSTRAINT fk_fact_ang FOREIGN KEY (id_angajat) REFERENCES ANGAJAT_UOUK(id_angajat)
);

CREATE TABLE LINIE_FACTURA_INTRARE_UOUK (
    id_linie NUMBER PRIMARY KEY,
    id_factura_intrare NUMBER,
    id_produs NUMBER,
    cantitate NUMBER(10,3),
    pret_achizitie NUMBER(10,4),
    valoare_neta NUMBER(12,4),
    id_tva NUMBER,
    CONSTRAINT fk_lin_fact FOREIGN KEY (id_factura_intrare) REFERENCES FACTURA_INTRARE_UOUK(id_factura_intrare),
    CONSTRAINT fk_lin_prod FOREIGN KEY (id_produs) REFERENCES PRODUS_UOUK(id_produs),
    CONSTRAINT fk_lin_tva FOREIGN KEY (id_tva) REFERENCES TVA_UOUK(id_tva)
);
