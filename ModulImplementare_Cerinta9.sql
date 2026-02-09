-- =================================================================
-- 9a. CEREREA COMPLEXA (VARIANTA INITIALA - FARA OPTIMIZARE)
-- =================================================================

EXPLAIN PLAN FOR
WITH Vanzari_Agregate AS (
    -- Pasul 1: Calculam vanzarile totale per Magazin, Categorie si Furnizor
    SELECT 
        m.tip_magazin,
        p.nume_categorie,
        furn.denumire_furnizor,
        SUM(f.valoare_achizitie_neta) as valoare_totala
    FROM FACT_LINII_ACHIZITII f
    JOIN DIM_TIMP t ON f.id_timp = t.id_timp
    JOIN DIM_MAGAZIN m ON f.id_magazin = m.id_magazin
    JOIN DIM_PRODUS p ON f.id_produs = p.id_produs
    JOIN DIM_FURNIZOR furn ON f.id_furnizor = furn.id_furnizor
    WHERE t.luna = 12 AND t.an = 2025
    GROUP BY m.tip_magazin, p.nume_categorie, furn.denumire_furnizor
),
Clasament_Categorii AS (
    -- Pasul 2: Facem Ranking pe categorii si gasim furnizorul top pentru fiecare
    SELECT 
        tip_magazin,
        nume_categorie,
        SUM(valoare_totala) as total_categorie,
        -- Functie analitica pentru a gasi furnizorul nr 1
        FIRST_VALUE(denumire_furnizor) OVER (
            PARTITION BY tip_magazin, nume_categorie 
            ORDER BY valoare_totala DESC
        ) as furnizor_principal,
        -- Ranking pentru top 3 categorii
        DENSE_RANK() OVER (
            PARTITION BY tip_magazin 
            ORDER BY SUM(valoare_totala) DESC
        ) as rang_categorie
    FROM Vanzari_Agregate
    GROUP BY tip_magazin, nume_categorie, denumire_furnizor, valoare_totala
)
SELECT DISTINCT 
    tip_magazin,
    nume_categorie, 
    total_categorie, 
    furnizor_principal
FROM Clasament_Categorii
WHERE rang_categorie <= 3
ORDER BY tip_magazin, total_categorie DESC;

-- Afisare Plan
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- 9.b)
-- 1. Acordam drepturi de Query Rewrite (Daca nu le are deja)
-- (Ruleaza asta conectat ca SYS sau SYSTEM, daca poti. Daca nu, incearca direct cu DW_DEPOZIT)
-- GRANT QUERY REWRITE TO dw_depozit;
-- GRANT CREATE MATERIALIZED VIEW TO dw_depozit;

-- 2. Crearea Vizualizarii Materializate (Conectat ca DW_DEPOZIT)
CREATE MATERIALIZED VIEW mv_analiza_achizitii
BUILD IMMEDIATE
REFRESH FORCE ON DEMAND
ENABLE QUERY REWRITE
AS
SELECT 
    t.an,
    t.luna,
    m.tip_magazin,
    p.nume_categorie,
    furn.denumire_furnizor,
    SUM(f.valoare_achizitie_neta) as valoare_totala,
    COUNT(*) as nr_tranzactii
FROM FACT_LINII_ACHIZITII f
JOIN DIM_TIMP t ON f.id_timp = t.id_timp
JOIN DIM_MAGAZIN m ON f.id_magazin = m.id_magazin
JOIN DIM_PRODUS p ON f.id_produs = p.id_produs
JOIN DIM_FURNIZOR furn ON f.id_furnizor = furn.id_furnizor
GROUP BY t.an, t.luna, m.tip_magazin, p.nume_categorie, furn.denumire_furnizor;

-- 3. Calculam statistici pe MV
EXEC DBMS_STATS.GATHER_TABLE_STATS('master_dw_if', 'MV_ANALIZA_ACHIZITII');

-- Varianta Rescrisa (garantata sa arate optimizarea)
EXPLAIN PLAN FOR
WITH Vanzari_MV AS (
    -- Aici citim DIRECT din MV, nu din tabelele de fapte
    SELECT 
        tip_magazin,
        nume_categorie,
        denumire_furnizor,
        valoare_totala
    FROM mv_analiza_achizitii
    WHERE an = 2025 AND luna = 12
),
Clasament_Categorii AS (
    -- Restul logicii ramane identica, dar se aplica pe un set de date mult mai mic
    SELECT 
        tip_magazin,
        nume_categorie,
        SUM(valoare_totala) as total_categorie,
        FIRST_VALUE(denumire_furnizor) OVER (
            PARTITION BY tip_magazin, nume_categorie 
            ORDER BY valoare_totala DESC
        ) as furnizor_principal,
        DENSE_RANK() OVER (
            PARTITION BY tip_magazin 
            ORDER BY SUM(valoare_totala) DESC
        ) as rang_categorie
    FROM Vanzari_MV
    GROUP BY tip_magazin, nume_categorie, denumire_furnizor, valoare_totala
)
SELECT DISTINCT *
FROM Clasament_Categorii
WHERE rang_categorie <= 3
ORDER BY tip_magazin, total_categorie DESC;

-- Afisare Plan Nou
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

