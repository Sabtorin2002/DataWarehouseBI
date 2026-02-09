-- 1. Index pe TIMP (pentru filtrari pe ani, luni, zile)
CREATE BITMAP INDEX bmi_fact_timp ON FACT_LINII_ACHIZITII(id_timp);

-- 2. Index pe FURNIZOR (pentru analize pe parteneri)
CREATE BITMAP INDEX bmi_fact_furn ON FACT_LINII_ACHIZITII(id_furnizor);

-- 3. Index pe MAGAZIN (pentru analize pe locatii)
CREATE BITMAP INDEX bmi_fact_mag ON FACT_LINII_ACHIZITII(id_magazin);

-- 4. Index pe PRODUS (pentru analize pe categorii)
CREATE BITMAP INDEX bmi_fact_prod ON FACT_LINII_ACHIZITII(id_produs);

-- 5. Index pe ANGAJAT (pentru performanta receptie)
CREATE BITMAP INDEX bmi_fact_ang ON FACT_LINII_ACHIZITII(id_angajat);

-- 6. Index pe TVA (pentru analize fiscale)
CREATE BITMAP INDEX bmi_fact_tva ON FACT_LINII_ACHIZITII(id_tva);

-- 7. Index pe PROMOTIE (pentru impact campanii)
CREATE BITMAP INDEX bmi_fact_prom ON FACT_LINII_ACHIZITII(id_promotie);

EXEC DBMS_STATS.GATHER_TABLE_STATS('master_dw_if', 'FACT_LINII_ACHIZITII');

-- =================================================================
-- PASUL 3: CEREREA SQL SI PLANUL DE EXECUTIE
-- =================================================================

EXPLAIN PLAN FOR
SELECT /*+ INDEX_COMBINE(f) */ 
    t.an,
    t.luna,
    furn.denumire_furnizor,
    SUM(f.valoare_achizitie_neta) as total_valoare,
    SUM(f.cantitate_achizitionata) as total_cantitate
FROM FACT_LINII_ACHIZITII f
JOIN DIM_TIMP t ON f.id_timp = t.id_timp
JOIN DIM_FURNIZOR furn ON f.id_furnizor = furn.id_furnizor
WHERE 
    t.an = 2025                  
    AND furn.denumire_furnizor LIKE '%Coca-Cola%' 
GROUP BY t.an, t.luna, furn.denumire_furnizor;

-- Afisare plan nou
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);