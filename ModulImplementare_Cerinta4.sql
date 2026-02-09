GRANT SELECT ON CATEGORIE_PRODUS_UOUK TO master_dw_if;
GRANT SELECT ON PRODUCATOR_UOUK TO master_dw_if;
GRANT SELECT ON PRODUS_UOUK TO master_dw_if;
GRANT SELECT ON FURNIZOR_UOUK TO master_dw_if;
GRANT SELECT ON MAGAZIN_UOUK TO master_dw_if;
GRANT SELECT ON ANGAJAT_UOUK TO master_dw_if;
GRANT SELECT ON FUNCTIE_UOUK TO master_dw_if;
GRANT SELECT ON TVA_UOUK TO master_dw_if;
GRANT SELECT ON PROMOTIE_UOUK TO master_dw_if;
GRANT SELECT ON PRODUS_PROMOTIE_UOUK TO master_dw_if;
GRANT SELECT ON FACTURA_INTRARE_UOUK TO master_dw_if;
GRANT SELECT ON LINIE_FACTURA_INTRARE_UOUK TO master_dw_if;

GRANT CONNECT, RESOURCE, CREATE VIEW, UNLIMITED TABLESPACE TO master_dw_if;

-- Optional, drepturi pentru debug si planuri de executie
GRANT SELECT_CATALOG_ROLE TO master_dw_if;

INSERT INTO DIM_TIMP (id_timp, data_calendaristica, zi, luna, an, nume_luna, trimestru, zi_saptamana, nume_zi, este_weekend, este_sarbatoare)
SELECT DISTINCT
    TO_NUMBER(TO_CHAR(data_factura, 'YYYYMMDD')), -- ID generat: 20251201
    data_factura,
    EXTRACT(DAY FROM data_factura),
    EXTRACT(MONTH FROM data_factura),
    EXTRACT(YEAR FROM data_factura),
    TO_CHAR(data_factura, 'Month', 'NLS_DATE_LANGUAGE = ROMANIAN'),
    TO_CHAR(data_factura, 'Q'),
    TO_CHAR(data_factura, 'D'), -- 1-7
    TO_CHAR(data_factura, 'Day', 'NLS_DATE_LANGUAGE = ROMANIAN'),
    CASE WHEN TO_CHAR(data_factura, 'DY', 'NLS_DATE_LANGUAGE=AMERICAN') IN ('SAT', 'SUN') THEN 1 ELSE 0 END,
    0 -- Presupunem default nu e sarbatoare, se poate actualiza manual
FROM factura_intrare_uouk;

-- 1. Resetăm toate valorile la 0
UPDATE DIM_TIMP
SET ESTE_SARBATOARE = 0;

-- 2. Setăm 1 doar pentru sărbătorile legale
UPDATE DIM_TIMP
SET ESTE_SARBATOARE = 1
WHERE (ZI = 30 AND LUNA = 11) OR (ZI = 6 AND LUNA = 12);

-- Furnizor
INSERT INTO DIM_FURNIZOR (id_furnizor, denumire_furnizor, cod_fiscal, tip_furnizor)
SELECT id_furnizor, nume_furnizor, cod_fiscal, 'General' 
FROM FURNIZOR_UOUK;

-- Magazin
INSERT INTO DIM_MAGAZIN (id_magazin, nume_magazin, tip_magazin, suprafata_mp)
SELECT id_magazin, nume_magazin, tip_magazin, suprafata_mp 
FROM MAGAZIN_UOUK;

-- TVA
INSERT INTO DIM_TVA (id_tva, procent_tva, denumire_tva)
SELECT id_tva, procent_tva, descriere 
FROM TVA_UOUK;

-- Angajat (Transformare: Join cu Functie + Concatenare Nume)
INSERT INTO DIM_ANGAJAT (id_angajat, nume_prenume, functie, data_angajarii, este_activ)
SELECT 
    a.id_angajat, 
    a.nume || ' ' || a.prenume, 
    f.denumire_functie, 
    a.data_angajare, 
    'Y' -- Default Activ
FROM ANGAJAT_UOUK a
JOIN FUNCTIE_UOUK f ON a.id_functie = f.id_functie;

INSERT INTO DIM_PROMOTIE (id_promotie, nume_promotie, tip_promotie, procent_discount_maxim, data_start, data_sfarsit)
SELECT id_promotie, nume_promotie, tip_promotie, 0, start_date, end_date 
FROM PROMOTIE_UOUK;

INSERT INTO DIM_PRODUS (id_produs, cod_intern, denumire_produs, cod_ean13, unitate_masura, nume_categorie, nume_producator, flag_produs_activ)
SELECT 
    p.id_produs,
    p.cod_articol_sursa,
    p.denumire_produs,
    p.cod_ean13,
    p.um,
    c.denumire_categorie,
    pr.nume_producator,
    1 -- Activ
FROM PRODUS_UOUK p
JOIN CATEGORIE_PRODUS_UOUK c ON p.id_categorie_produs = c.id_categorie_produs
JOIN PRODUCATOR_UOUK pr ON p.id_producator = pr.id_producator;

-- Mai intai, cream o secventa pentru PK-ul tabelului de fapte
CREATE SEQUENCE seq_fact_id START WITH 1 INCREMENT BY 1;

INSERT INTO FACT_LINII_ACHIZITII (
    id_fact_linie_achizitie,
    id_timp,
    id_produs,
    id_furnizor,
    id_magazin,
    id_angajat,
    id_tva,
    id_promotie,
    cantitate_achizitionata,
    pret_achizitie_unitar,
    valoare_achizitie_neta,
    valoare_achizitie_tva,
    valoare_tva,
    discount_valoare
)
SELECT 
    seq_fact_id.NEXTVAL,
    -- 1. Cheie Timp (Format YYYYMMDD)
    TO_NUMBER(TO_CHAR(f.data_factura, 'YYYYMMDD')),
    -- 2. Chei simple
    l.id_produs,
    f.id_furnizor,
    f.id_magazin,
    f.id_angajat,
    l.id_tva,
    -- 3. Cheie Promotie (Logica complexa: Cautam promotie activa la data facturii)
    COALESCE(
        (SELECT pp.id_promotie 
         FROM PRODUS_PROMOTIE_UOUK pp
         JOIN PROMOTIE_UOUK pr ON pp.id_promotie = pr.id_promotie
         WHERE pp.id_produs = l.id_produs 
           AND f.data_factura BETWEEN pr.start_date AND pr.end_date
           AND ROWNUM = 1), 
        99 -- ID-ul pentru "Fara Promotie" daca nu gasim una activa
    ),
    -- 4. Masuri
    l.cantitate,
    l.pret_achizitie,
    l.valoare_neta, -- Valoare neta
    l.valoare_neta * (1 + (select procent_tva/100 from tva_UOUK where id_tva = l.id_tva)), -- Valoare Bruta aprox
    l.valoare_neta * (select procent_tva/100 from tva_UOUK where id_tva = l.id_tva), -- Valoare doar TVA
    0 -- Discount (momentan 0 daca nu e specificat in linie)
FROM LINIE_FACTURA_INTRARE_UOUK l
JOIN FACTURA_INTRARE_UOUK f ON l.id_factura_intrare = f.id_factura_intrare;

COMMIT;