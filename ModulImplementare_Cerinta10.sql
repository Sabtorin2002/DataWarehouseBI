-- RAPORT 1: Top 10 Produse dupa Valoarea Achizitiei
SELECT 
    p.denumire_produs,
    p.nume_categorie,
    SUM(f.valoare_achizitie_neta) as valoare_totala,
    SUM(f.cantitate_achizitionata) as cantitate_totala
FROM FACT_LINII_ACHIZITII f
JOIN DIM_PRODUS p ON f.id_produs = p.id_produs
GROUP BY p.denumire_produs, p.nume_categorie
ORDER BY valoare_totala DESC
FETCH FIRST 10 ROWS ONLY;

-- RAPORT 2: Evolutia zilnica a achizitiilor (Decembrie 2025)
SELECT 
    t.data_calendaristica,
    t.nume_zi,
    COUNT(DISTINCT f.id_fact_linie_achizitie) as nr_linii_procesate,
    SUM(f.valoare_achizitie_neta) as valoare_zilnica
FROM FACT_LINII_ACHIZITII f
JOIN DIM_TIMP t ON f.id_timp = t.id_timp
WHERE t.an = 2025 AND t.luna = 12
GROUP BY t.data_calendaristica, t.nume_zi
ORDER BY t.data_calendaristica;

-- RAPORT 3: Matricea Achizitiilor pe Zilele Saptamanii (Tehnica PIVOT)
SELECT * FROM (
    SELECT 
        t.nume_zi,
        f.valoare_achizitie_neta
    FROM FACT_LINII_ACHIZITII f
    JOIN DIM_TIMP t ON f.id_timp = t.id_timp
)
PIVOT (
    SUM(valoare_achizitie_neta) 
    FOR nume_zi IN (
        'Luni    ' as Luni, 
        'Marţi   ' as Marti, 
        'Miercuri' as Miercuri, 
        'Joi     ' as Joi, 
        'Vineri  ' as Vineri, 
        'Sâmbătă ' as Sambata, 
        'Duminică' as Duminica
    )
);

-- RAPORT 4: Top 5 Zile Record (Folosind Functii Analitice)
SELECT * FROM (
    SELECT 
        t.data_calendaristica,
        SUM(f.valoare_achizitie_neta) as total_zi,
        DENSE_RANK() OVER (ORDER BY SUM(f.valoare_achizitie_neta) DESC) as rang_zi
    FROM FACT_LINII_ACHIZITII f
    JOIN DIM_TIMP t ON f.id_timp = t.id_timp
    GROUP BY t.data_calendaristica
)
WHERE rang_zi <= 5;

-- RAPORT 5: Analiza TVA cu Subtotaluri (Folosind ROLLUP)
SELECT 
    CASE WHEN GROUPING(tv.denumire_tva) = 1 THEN 'TOTAL GENERAL' ELSE tv.denumire_tva END as tip_tva,
    SUM(f.valoare_tva) as total_taxe_stat,
    ROUND(SUM(f.valoare_tva) * 100 / (SELECT SUM(valoare_tva) FROM FACT_LINII_ACHIZITII), 2) || '%' as procent_din_total
FROM FACT_LINII_ACHIZITII f
JOIN DIM_TVA tv ON f.id_tva = tv.id_tva
GROUP BY ROLLUP(tv.denumire_tva);