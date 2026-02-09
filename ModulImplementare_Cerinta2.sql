-- 1.1. Populare TVA (din datele existente)
INSERT INTO TVA_UOUK (id_tva, procent_tva, descriere)
SELECT DISTINCT 
    IDTVA_ACHIZITIE, 
    TVA_ACHIZITIE, 
    'Cota TVA ' || TVA_ACHIZITIE || '%'
FROM SmartCashExport
WHERE IDTVA_ACHIZITIE IS NOT NULL;

select * from TVA_UOUK;

-- 1.2. Populare Categorii (Folosim o logica de keyword matching pe Denumire, pentru ca nu avem nume explicite)
INSERT INTO CATEGORIE_PRODUS_UOUK (id_categorie_produs, denumire_categorie)
VALUES (1, 'Panificatie');

INSERT INTO CATEGORIE_PRODUS_UOUK (id_categorie_produs, denumire_categorie)
VALUES (2, 'Lactate si Branzeturi');

INSERT INTO CATEGORIE_PRODUS_UOUK (id_categorie_produs, denumire_categorie)
VALUES (3, 'Carne si Mezeluri');

INSERT INTO CATEGORIE_PRODUS_UOUK (id_categorie_produs, denumire_categorie)
VALUES (4, 'Bauturi');

INSERT INTO CATEGORIE_PRODUS_UOUK (id_categorie_produs, denumire_categorie)
VALUES (5, 'Dulciuri si Snacks');

INSERT INTO CATEGORIE_PRODUS_UOUK (id_categorie_produs, denumire_categorie)
VALUES (6, 'Fructe si Legume');

INSERT INTO CATEGORIE_PRODUS_UOUK (id_categorie_produs, denumire_categorie)
VALUES (99, 'Diverse / General');

-- 1.3. Populare Producatori (Extragem cativa reali + Generic)
INSERT INTO PRODUCATOR_UOUK (id_producator, nume_producator)
VALUES (1, 'Frontera');

INSERT INTO PRODUCATOR_UOUK (id_producator, nume_producator)
VALUES (2, 'Olympus');

INSERT INTO PRODUCATOR_UOUK (id_producator, nume_producator)
VALUES (3, 'Timisoreana');

INSERT INTO PRODUCATOR_UOUK (id_producator, nume_producator)
VALUES (4, 'Coca-Cola HBC');

INSERT INTO PRODUCATOR_UOUK (id_producator, nume_producator)
VALUES (5, 'Vel Pitar');

INSERT INTO PRODUCATOR_UOUK (id_producator, nume_producator)
VALUES (99, 'Producator General');

-- 1.4. Generare Magazine (Fictive - datele lipsesc in export)
INSERT INTO MAGAZIN_UOUK (id_magazin, nume_magazin, tip_magazin, suprafata_mp) 
VALUES (1, 'Dinatos La Doi Pasi', 'Supermarket', 800);

-- 1.5. Generare Functii si Angajati (Fictive)
INSERT INTO FUNCTIE_UOUK (id_functie, denumire_functie) VALUES (1, 'Gestionar Receptie');
INSERT INTO FUNCTIE_UOUK (id_functie, denumire_functie) VALUES (2, 'Manager Magazin');
INSERT INTO FUNCTIE_UOUK (id_functie, denumire_functie) VALUES (3, 'Casier');

-- Angajati (date semi-fictive, distribuiti corect pe functii)

-- Manager Magazin (DOAR UNUL)
INSERT INTO ANGAJAT_UOUK (id_angajat, nume, prenume, data_angajare, id_functie)
VALUES (1, 'Stoica', 'Elias-Valeriu', TO_DATE('10-01-2019','DD-MM-YYYY'), 2);

-- Gestionari Receptie
INSERT INTO ANGAJAT_UOUK (id_angajat, nume, prenume, data_angajare, id_functie)
VALUES (2, 'Toma', 'Sabin-Sebastian', TO_DATE('15-06-2020','DD-MM-YYYY'), 1);

INSERT INTO ANGAJAT_UOUK (id_angajat, nume, prenume, data_angajare, id_functie)
VALUES (3, 'Popa', 'Andrei-Ionut', TO_DATE('03-02-2021','DD-MM-YYYY'), 1);

INSERT INTO ANGAJAT_UOUK (id_angajat, nume, prenume, data_angajare, id_functie)
VALUES (4, 'Semen', 'Valentin-Ion', TO_DATE('20-09-2020','DD-MM-YYYY'), 3);

INSERT INTO ANGAJAT_UOUK (id_angajat, nume, prenume, data_angajare, id_functie)
VALUES (5, 'Dumitrescu', 'Alexandru', TO_DATE('11-04-2022','DD-MM-YYYY'), 1);

INSERT INTO ANGAJAT_UOUK (id_angajat, nume, prenume, data_angajare, id_functie)
VALUES (6, 'Marin', 'Cristian', TO_DATE('07-07-2021','DD-MM-YYYY'), 1);

INSERT INTO ANGAJAT_UOUK (id_angajat, nume, prenume, data_angajare, id_functie)
VALUES (7, 'Radu', 'Mihai', TO_DATE('18-10-2022','DD-MM-YYYY'), 3);

-- Furnizori Panificatie
INSERT INTO FURNIZOR_UOUK VALUES (1, 'Panifresh Distribution SRL', 'RO100001');
INSERT INTO FURNIZOR_UOUK VALUES (2, 'Vel Pitar Logistic SRL', 'RO100002');
INSERT INTO FURNIZOR_UOUK VALUES (3, 'Brutarul Urban SRL', 'RO100003');

-- Furnizori Lactate & Branzeturi
INSERT INTO FURNIZOR_UOUK VALUES (4, 'Olympus Dairy Distribution', 'RO200001');
INSERT INTO FURNIZOR_UOUK VALUES (5, 'Albalact Logistic', 'RO200002');
INSERT INTO FURNIZOR_UOUK VALUES (6, 'Napolact Supply Chain', 'RO200003');

-- Furnizori Carne & Mezeluri
INSERT INTO FURNIZOR_UOUK VALUES (7, 'Cris-Tim Distributie', 'RO300001');
INSERT INTO FURNIZOR_UOUK VALUES (8, 'Smithfield Romania Trading', 'RO300002');
INSERT INTO FURNIZOR_UOUK VALUES (9, 'Fox Comserv Distribution', 'RO300003');

-- Furnizori Bauturi
INSERT INTO FURNIZOR_UOUK VALUES (10, 'Coca-Cola HBC Romania', 'RO400001');
INSERT INTO FURNIZOR_UOUK VALUES (11, 'PepsiCo Distribution', 'RO400002');
INSERT INTO FURNIZOR_UOUK VALUES (12, 'Ursus Breweries Supply', 'RO400003');
INSERT INTO FURNIZOR_UOUK VALUES (13, 'Heineken Romania Trading', 'RO400004');

-- Furnizori Dulciuri & Snacks
INSERT INTO FURNIZOR_UOUK VALUES (14, 'Mondelez Romania Distribution', 'RO500001');
INSERT INTO FURNIZOR_UOUK VALUES (15, 'Ferrero Romania Supply', 'RO500002');
INSERT INTO FURNIZOR_UOUK VALUES (16, 'Kandia Dulce Trading', 'RO500003');

-- Furnizori Fructe & Legume
INSERT INTO FURNIZOR_UOUK VALUES (17, 'Fresh Garden Import Export', 'RO600001');
INSERT INTO FURNIZOR_UOUK VALUES (18, 'AgroProducatori Uniti', 'RO600002');
INSERT INTO FURNIZOR_UOUK VALUES (19, 'Eco Fruct SRL', 'RO600003');

-- Furnizori Mixti / Generali
INSERT INTO FURNIZOR_UOUK VALUES (20, 'Distributie Generala SRL', 'RO700001');
INSERT INTO FURNIZOR_UOUK VALUES (21, 'Smart Food Logistics', 'RO700003');

-- Furnizor Generic (fallback)
INSERT INTO FURNIZOR_UOUK VALUES (99, 'Furnizor General', 'RO999999');

-- Panificatie
INSERT INTO PRODUCATOR_UOUK VALUES (1, 'Frontera');
INSERT INTO PRODUCATOR_UOUK VALUES (2, 'Vel Pitar');
INSERT INTO PRODUCATOR_UOUK VALUES (3, 'Boromir');
INSERT INTO PRODUCATOR_UOUK VALUES (4, 'Dobrogea Grup');
INSERT INTO PRODUCATOR_UOUK VALUES (5, 'Pambac Bacau');

-- Lactate si Branzeturi
INSERT INTO PRODUCATOR_UOUK VALUES (6, 'Olympus');
INSERT INTO PRODUCATOR_UOUK VALUES (7, 'Albalact');
INSERT INTO PRODUCATOR_UOUK VALUES (8, 'Napolact');
INSERT INTO PRODUCATOR_UOUK VALUES (9, 'Hochland');
INSERT INTO PRODUCATOR_UOUK VALUES (10, 'LaDorna');

-- Carne si Mezeluri
INSERT INTO PRODUCATOR_UOUK VALUES (11, 'Cris-Tim');
INSERT INTO PRODUCATOR_UOUK VALUES (12, 'Fox');
INSERT INTO PRODUCATOR_UOUK VALUES (13, 'Aldis');
INSERT INTO PRODUCATOR_UOUK VALUES (14, 'Smithfield');
INSERT INTO PRODUCATOR_UOUK VALUES (15, 'Caroli Foods');

-- Bauturi alcoolice
INSERT INTO PRODUCATOR_UOUK VALUES (16, 'Timisoreana');
INSERT INTO PRODUCATOR_UOUK VALUES (17, 'Ursus Breweries');
INSERT INTO PRODUCATOR_UOUK VALUES (18, 'Heineken Romania');
INSERT INTO PRODUCATOR_UOUK VALUES (19, 'Bergenbier');

-- Bauturi non-alcoolice
INSERT INTO PRODUCATOR_UOUK VALUES (20, 'Coca-Cola HBC');
INSERT INTO PRODUCATOR_UOUK VALUES (21, 'PepsiCo');
INSERT INTO PRODUCATOR_UOUK VALUES (22, 'Romaqua Group');
INSERT INTO PRODUCATOR_UOUK VALUES (23, 'European Drinks');

-- Dulciuri si Snacks
INSERT INTO PRODUCATOR_UOUK VALUES (24, 'Kandia Dulce');
INSERT INTO PRODUCATOR_UOUK VALUES (25, 'Milka / Mondelez');
INSERT INTO PRODUCATOR_UOUK VALUES (26, 'Ferrero');
INSERT INTO PRODUCATOR_UOUK VALUES (27, 'Kinder');
INSERT INTO PRODUCATOR_UOUK VALUES (28, 'Chipita');

-- Fructe si Legume procesate / diverse
INSERT INTO PRODUCATOR_UOUK VALUES (29, 'Bonduelle');
INSERT INTO PRODUCATOR_UOUK VALUES (30, 'Dole');
INSERT INTO PRODUCATOR_UOUK VALUES (31, 'Del Monte');

-- Producatori locali / diversi
INSERT INTO PRODUCATOR_UOUK VALUES (32, 'Producatori Locali Asociati');
INSERT INTO PRODUCATOR_UOUK VALUES (33, 'AgroRomania Cooperative');

-- Producator Generic (fallback)
INSERT INTO PRODUCATOR_UOUK VALUES (99, 'Producator General');

INSERT INTO PRODUS_UOUK
(
    id_produs,
    cod_articol_sursa,
    denumire_produs,
    cod_ean13,
    um,
    id_categorie_produs,
    id_producator
)
SELECT 
    rownum + 1000 AS id_produs,       -- ID intern produs
    ARTNR,
    DENUMIRE,
    EAN13,
    UM,

    ------------------------------------------------------------------
    -- Asignare CATEGORIE PRODUS
    ------------------------------------------------------------------
    CASE 
        -- Panificatie
        WHEN UPPER(DENUMIRE) LIKE '%PAINE%'
          OR UPPER(DENUMIRE) LIKE '%FRANZELA%'
          OR UPPER(DENUMIRE) LIKE '%CROISSANT%'
          OR UPPER(DENUMIRE) LIKE '%CHIFLA%'
          OR UPPER(DENUMIRE) LIKE '%BAGHETA%'           THEN 1

        -- Lactate & Branzeturi
        WHEN UPPER(DENUMIRE) LIKE '%LAPTE%'
          OR UPPER(DENUMIRE) LIKE '%IAURT%'
          OR UPPER(DENUMIRE) LIKE '%BRANZA%'
          OR UPPER(DENUMIRE) LIKE '%CASCAVAL%'
          OR UPPER(DENUMIRE) LIKE '%SMANTANA%'          THEN 2

        -- Carne & Mezeluri
        WHEN UPPER(DENUMIRE) LIKE '%SALAM%'
          OR UPPER(DENUMIRE) LIKE '%SUNCA%'
          OR UPPER(DENUMIRE) LIKE '%CARNE%'
          OR UPPER(DENUMIRE) LIKE '%CRENVURST%'
          OR UPPER(DENUMIRE) LIKE '%PARIZER%'           THEN 3

        -- Bauturi
        WHEN UPPER(DENUMIRE) LIKE '%SUC%'
          OR UPPER(DENUMIRE) LIKE '%APA%'
          OR UPPER(DENUMIRE) LIKE '%BERE%'
          OR UPPER(DENUMIRE) LIKE '%COLA%'
          OR UPPER(DENUMIRE) LIKE '%MINERALA%'          THEN 4

        -- Dulciuri & Snacks
        WHEN UPPER(DENUMIRE) LIKE '%CIOCOLATA%'
          OR UPPER(DENUMIRE) LIKE '%BISCUITI%'
          OR UPPER(DENUMIRE) LIKE '%NAPOLITANE%'
          OR UPPER(DENUMIRE) LIKE '%BOMBOANE%'          THEN 5

        -- Fructe & Legume
        WHEN UPPER(DENUMIRE) LIKE '%MAR%'
          OR UPPER(DENUMIRE) LIKE '%ROSIE%'
          OR UPPER(DENUMIRE) LIKE '%BANANA%'
          OR UPPER(DENUMIRE) LIKE '%CARTOF%'            THEN 6

        ELSE 99
    END AS id_categorie_produs,

    ------------------------------------------------------------------
    -- Asignare PRODUCATOR (EXTINS)
    ------------------------------------------------------------------
    CASE 
        -- Panificatie
        WHEN UPPER(DENUMIRE) LIKE '%FRONTERA%'           THEN 1
        WHEN UPPER(DENUMIRE) LIKE '%VEL PITAR%'          THEN 2
        WHEN UPPER(DENUMIRE) LIKE '%BOROMIR%'            THEN 3
        WHEN UPPER(DENUMIRE) LIKE '%DOBROGEA%'           THEN 4
        WHEN UPPER(DENUMIRE) LIKE '%PAMBAC%'             THEN 5

        -- Lactate
        WHEN UPPER(DENUMIRE) LIKE '%OLYMPUS%'            THEN 6
        WHEN UPPER(DENUMIRE) LIKE '%ALBALACT%'           THEN 7
        WHEN UPPER(DENUMIRE) LIKE '%NAPOLACT%'           THEN 8
        WHEN UPPER(DENUMIRE) LIKE '%HOCHLAND%'           THEN 9
        WHEN UPPER(DENUMIRE) LIKE '%DORNA%'              THEN 10

        -- Carne
        WHEN UPPER(DENUMIRE) LIKE '%CRIS%'               THEN 11
        WHEN UPPER(DENUMIRE) LIKE '%FOX%'                THEN 12
        WHEN UPPER(DENUMIRE) LIKE '%ALDIS%'              THEN 13
        WHEN UPPER(DENUMIRE) LIKE '%SMITHFIELD%'         THEN 14
        WHEN UPPER(DENUMIRE) LIKE '%CAROLI%'             THEN 15

        -- Bauturi alcoolice
        WHEN UPPER(DENUMIRE) LIKE '%TIMISOREANA%'        THEN 16
        WHEN UPPER(DENUMIRE) LIKE '%URSUS%'              THEN 17
        WHEN UPPER(DENUMIRE) LIKE '%HEINEKEN%'           THEN 18
        WHEN UPPER(DENUMIRE) LIKE '%BERGENBIER%'         THEN 19

        -- Bauturi non-alcoolice
        WHEN UPPER(DENUMIRE) LIKE '%COCA%'               THEN 20
        WHEN UPPER(DENUMIRE) LIKE '%PEPSI%'              THEN 21
        WHEN UPPER(DENUMIRE) LIKE '%ROMAQUA%'            THEN 22
        WHEN UPPER(DENUMIRE) LIKE '%EUROPEAN DRINKS%'    THEN 23

        -- Dulciuri
        WHEN UPPER(DENUMIRE) LIKE '%KANDIA%'             THEN 24
        WHEN UPPER(DENUMIRE) LIKE '%MILKA%'              THEN 25
        WHEN UPPER(DENUMIRE) LIKE '%FERRERO%'            THEN 26
        WHEN UPPER(DENUMIRE) LIKE '%KINDER%'             THEN 27
        WHEN UPPER(DENUMIRE) LIKE '%CHIPITA%'            THEN 28

        -- Diverse / fallback
        ELSE 99
    END AS id_producator

FROM (
    -- Produse distincte din sursa
    SELECT DISTINCT 
        ARTNR,
        DENUMIRE,
        EAN13,
        UM
    FROM SmartCashExport
);

INSERT INTO FACTURA_INTRARE_UOUK (id_factura_intrare, numar_factura, data_factura, id_furnizor, id_magazin, id_angajat)
SELECT 
    rownum, -- ID generat
    'FACT-' || IDREC, -- Numar factura derivat din receptie
    TO_DATE(DATA_DOC, 'DD-MON-RR', 'NLS_DATE_LANGUAGE = AMERICAN'), -- Conversie data
    ROUND(DBMS_RANDOM.VALUE(1, 21)), -- Furnizor Random (1-3)
    1,
    ROUND(DBMS_RANDOM.VALUE(1, 7))  -- Angajat Random (1-3)
FROM (
    SELECT DISTINCT IDREC, DATA_DOC 
    FROM SmartCashExport
);

INSERT INTO LINIE_FACTURA_INTRARE_UOUK (id_linie, id_factura_intrare, id_produs, cantitate, pret_achizitie, valoare_neta, id_tva)
SELECT 
    rownum,
    f.id_factura_intrare,
    p.id_produs,
    s.CANTDOC,
    s.PRETACH,
    s.VALOARE_ACHIZITIE,
    s.IDTVA_ACHIZITIE
FROM SmartCashExport s
-- Join cu Facturile create anterior pentru a gasi ID-ul corect
JOIN FACTURA_INTRARE_UOUK f ON f.numar_factura = 'FACT-' || s.IDREC AND f.data_factura = TO_DATE(s.DATA_DOC, 'DD-MON-RR', 'NLS_DATE_LANGUAGE = AMERICAN')
-- Join cu Produsele create anterior
JOIN PRODUS_UOUK p ON p.cod_articol_sursa = s.ARTNR;

-- 5.1. Inseram 4 campanii promotionale logice
INSERT INTO PROMOTIE_UOUK (id_promotie, nume_promotie, tip_promotie, start_date, end_date) 
VALUES (1, 'Campanie Sarbatori Iarna', 'Reducere Procentuala',
        TO_DATE('01-12-2025','DD-MM-YYYY'), TO_DATE('31-12-2025','DD-MM-YYYY'));

INSERT INTO PROMOTIE_UOUK (id_promotie, nume_promotie, tip_promotie, start_date, end_date) 
VALUES (2, 'Black Friday 2025', 'Discount Masiv',
        TO_DATE('15-11-2025','DD-MM-YYYY'), TO_DATE('30-11-2025','DD-MM-YYYY'));

INSERT INTO PROMOTIE_UOUK (id_promotie, nume_promotie, tip_promotie, start_date, end_date) 
VALUES (3, 'Lichidare Stoc Panificatie', '1 + 1 Gratis',
        TO_DATE('01-11-2025','DD-MM-YYYY'), TO_DATE('30-11-2025','DD-MM-YYYY'));

INSERT INTO PROMOTIE_UOUK (id_promotie, nume_promotie, tip_promotie, start_date, end_date) 
VALUES (4, 'Oferta Weekend', 'Pret Special',
        TO_DATE('01-11-2025','DD-MM-YYYY'), TO_DATE('31-12-2025','DD-MM-YYYY'));

--------------------------------------------------

-- 5.2. Valoare "Dummy" pentru produsele care NU sunt la promotie (Best Practice DW)
INSERT INTO PROMOTIE_UOUK (id_promotie, nume_promotie, tip_promotie, start_date, end_date) 
VALUES (99, 'Fara Promotie', 'Standard',
        TO_DATE('01-01-2000','DD-MM-YYYY'), TO_DATE('01-01-2099','DD-MM-YYYY'));
        
BEGIN
  -- Parcurgem toate produsele din baza de date
  FOR r_prod IN (SELECT id_produs FROM PRODUS_UOUK) LOOP
    
    -- Pentru fiecare produs, decidem ALEATORIU daca intra intr-o promotie sau nu
    -- 30% sanse sa fie intr-o promotie (DBMS_RANDOM.VALUE returneaza intre 0 si 1)
    IF DBMS_RANDOM.VALUE < 0.2 THEN
        BEGIN
            INSERT INTO PRODUS_PROMOTIE_UOUK (id_produs, id_promotie)
            VALUES (
                r_prod.id_produs,
                ROUND(DBMS_RANDOM.VALUE(1, 4)) -- Alegem random o promotie intre 1 si 4
            );
        EXCEPTION
            -- Daca generam o duplicare (acelasi produs la aceeasi promotie), o ignoram
            WHEN DUP_VAL_ON_INDEX THEN NULL;
        END;
    END IF;
    
  END LOOP;
  COMMIT;
END;
/

COMMIT;

select count (*)from produs_uouk
