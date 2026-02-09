CREATE OR REPLACE PROCEDURE REFRESH_DW_ETL IS
BEGIN
    -- =========================================================================
    -- PASUL 1: ACTUALIZARE DIMENSIUNI (DOAR ADAUGAM CE E NOU)
    -- =========================================================================
    
    -- 1.1. Actualizam TIMPUL (Daca au aparut date noi in facturi)
    INSERT INTO DIM_TIMP (id_timp, data_calendaristica, zi, luna, an, nume_luna, trimestru, zi_saptamana, nume_zi, este_weekend, este_sarbatoare)
    SELECT DISTINCT
        TO_NUMBER(TO_CHAR(data_factura, 'YYYYMMDD')),
        data_factura,
        EXTRACT(DAY FROM data_factura),
        EXTRACT(MONTH FROM data_factura),
        EXTRACT(YEAR FROM data_factura),
        TO_CHAR(data_factura, 'Month', 'NLS_DATE_LANGUAGE = ROMANIAN'),
        TO_CHAR(data_factura, 'Q'),
        TO_CHAR(data_factura, 'D'),
        TO_CHAR(data_factura, 'Day', 'NLS_DATE_LANGUAGE = ROMANIAN'),
        CASE WHEN TO_CHAR(data_factura, 'DY', 'NLS_DATE_LANGUAGE=AMERICAN') IN ('SAT', 'SUN') THEN 1 ELSE 0 END,
        0
    FROM FACTURA_INTRARE_UOUK
    WHERE TO_NUMBER(TO_CHAR(data_factura, 'YYYYMMDD')) NOT IN (SELECT id_timp FROM DIM_TIMP); -- <--- Doar ce nu exista!

    -- 1.2. Actualizam PRODUSELE (Daca au aparut produse noi)
    INSERT INTO DIM_PRODUS (id_produs, cod_intern, denumire_produs, cod_ean13, unitate_masura, nume_categorie, nume_producator, flag_produs_activ)
    SELECT 
        p.id_produs, p.cod_articol_sursa, p.denumire_produs, p.cod_ean13, p.um, 
        c.denumire_categorie, pr.nume_producator, 1
    FROM PRODUS_UOUK p
    JOIN CATEGORIE_PRODUS_UOUK c ON p.id_categorie_produs = c.id_categorie_produs
    JOIN PRODUCATOR_UOUK pr ON p.id_producator = pr.id_producator
    WHERE p.id_produs NOT IN (SELECT id_produs FROM DIM_PRODUS); -- <--- Doar ce nu exista!

    -- (Optional, similar pentru Magazin/Furnizor/Angajat daca prevezi ca adaugi noi in aplicatie)

    -- =========================================================================
    -- PASUL 2: REIMPROSPATARE TABEL FAPTE (FACT TABLE)
    -- =========================================================================
    -- Aici stergem liniile din DW pentru a le reincarca proaspat din OLTP.
    -- Este safe pentru ca DIMENSIUNILE au fost deja asigurate mai sus.
    
    DELETE FROM FACT_LINII_ACHIZITII;
    
    -- Inseram TOT din nou (inclusiv noile facturi adaugate din aplicatie)
    INSERT INTO FACT_LINII_ACHIZITII (
        id_fact_linie_achizitie, id_timp, id_produs, id_furnizor, id_magazin, id_tva, id_promotie, id_angajat, 
        cantitate_achizitionata, pret_achizitie_unitar, valoare_achizitie_neta, valoare_achizitie_tva, discount_valoare, valoare_tva
    )
    SELECT 
        seq_fact_id.NEXTVAL, -- Generam ID-uri noi
        TO_NUMBER(TO_CHAR(f.data_factura, 'YYYYMMDD')),
        l.id_produs,
        f.id_furnizor,
        f.id_magazin,
        l.id_tva,
        COALESCE(
        (SELECT pp.id_promotie 
         FROM PRODUS_PROMOTIE_UOUK pp
         JOIN PROMOTIE_UOUK pr ON pp.id_promotie = pr.id_promotie
         WHERE pp.id_produs = l.id_produs 
           AND f.data_factura BETWEEN pr.start_date AND pr.end_date
           AND ROWNUM = 1), 
        99 -- ID-ul pentru "Fara Promotie" daca nu gasim una activa
        ) AS id_promotie,
        f.id_angajat,
        l.cantitate,
        l.pret_achizitie,
        l.valoare_neta,
        l.valoare_neta * (1 + (select procent_tva/100 from tva_UOUK where id_tva = l.id_tva)),
        0, -- Fara discount (simplificat)
        l.valoare_neta * (select procent_tva/100 from tva_UOUK where id_tva = l.id_tva)
    FROM LINIE_FACTURA_INTRARE_UOUK l
    JOIN FACTURA_INTRARE_UOUK f ON l.id_factura_intrare = f.id_factura_intrare;

    COMMIT;
END;
/