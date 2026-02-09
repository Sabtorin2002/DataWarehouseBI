-- 1. Creare tabel cu Partitionare RANGE pe ID_TIMP
CREATE TABLE FACT_ACHIZITII_PART (
    id_fact_linie_achizitie NUMBER(15),
    id_timp NUMBER(10),
    id_produs NUMBER(10),
    id_furnizor NUMBER(10),
    id_magazin NUMBER(10),
    valoare_achizitie_neta NUMBER(15,2),
    cantitate_achizitionata NUMBER(12,3)
)
PARTITION BY RANGE (id_timp) (
    -- Partitia 1: Luna Noiembrie (Tot ce e strict mai mic decat 1 Dec 2025)
    PARTITION p_nov_2025 VALUES LESS THAN (20251201),
    
    -- Partitia 2: Prima jumatate din Decembrie (1 Dec - 14 Dec)
    PARTITION p_dec_2025_h1 VALUES LESS THAN (20251215),
    
    -- Partitia 3: A doua jumatate din Decembrie (15 Dec - 1 Ian 2026)
    PARTITION p_dec_2025_h2 VALUES LESS THAN (20260101),
    
    -- Partitia de siguranta (pentru orice alta data viitoare)
    PARTITION p_other VALUES LESS THAN (MAXVALUE)
);

INSERT INTO FACT_ACHIZITII_PART
SELECT 
    id_fact_linie_achizitie, id_timp, id_produs, id_furnizor, id_magazin, 
    valoare_achizitie_neta, cantitate_achizitionata
FROM FACT_LINII_ACHIZITII;

COMMIT;

BEGIN
   DBMS_STATS.GATHER_TABLE_STATS('master_dw_if', 'FACT_ACHIZITII_PART');
END;
/

EXPLAIN PLAN FOR
SELECT SUM(valoare_achizitie_neta) 
FROM FACT_ACHIZITII_PART
WHERE id_timp BETWEEN 20251120 AND 20251125; 

-- Afisarea planului
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Stergem tabelul daca exista
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE DIM_PRODUS_PART CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

-- 1. Creare tabel cu Partitionare LIST pe NUME_CATEGORIE
CREATE TABLE DIM_PRODUS_PART (
    id_produs       NUMBER(10),
    nume_categorie  VARCHAR2(100),
    denumire_produs VARCHAR2(255)
)
PARTITION BY LIST (nume_categorie) (
    -- Partitia 1: Alimente proaspete si de baza
    PARTITION p_alimente_baza VALUES (
        'Panificatie', 
        'Lactate si Branzeturi', 
        'Carne si Mezeluri', 
        'Fructe si Legume'
    ),
    -- Partitia 2: Produse de raft / Rasfat
    PARTITION p_snacks_bauturi VALUES (
        'Bauturi', 
        'Dulciuri si Snacks'
    ),
    -- Partitia 3: Orice altceva (Diverse)
    PARTITION p_diverse VALUES (
        'Diverse / General'
    )
);

-- 2. Populare cu date din dimensiunea principala
INSERT INTO DIM_PRODUS_PART (id_produs, nume_categorie, denumire_produs)
SELECT id_produs, nume_categorie, denumire_produs
FROM DIM_PRODUS;

COMMIT;

-- 3. Actualizare statistici (Obligatoriu)
EXEC DBMS_STATS.GATHER_TABLE_STATS('master_dw_if', 'DIM_PRODUS_PART');

EXPLAIN PLAN FOR
SELECT * FROM DIM_PRODUS_PART
WHERE nume_categorie = 'Panificatie';

-- Afisare plan
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);