-- =============================================================
-- 5. DEFINIREA CONSTRANGERILOR SUPLIMENTARE (DATA QUALITY)
-- =============================================================

-- 1. Validari pentru Dimensiunea TIMP
-- Ne asiguram ca luna este 1-12 si trimestrul 1-4
ALTER TABLE DIM_TIMP 
ADD CONSTRAINT chk_timp_luna CHECK (luna BETWEEN 1 AND 12);

ALTER TABLE DIM_TIMP 
ADD CONSTRAINT chk_timp_trimestru CHECK (trimestru BETWEEN 1 AND 4);

ALTER TABLE DIM_TIMP 
ADD CONSTRAINT chk_timp_zi CHECK (zi BETWEEN 1 AND 31);

-- 2. Validari pentru Tabelul de Fapte (FACT_LINII_ACHIZITII)
-- Nu putem avea cantitati sau preturi negative in achizitii
ALTER TABLE FACT_LINII_ACHIZITII 
ADD CONSTRAINT chk_fact_cantitate CHECK (cantitate_achizitionata >= 0);

ALTER TABLE FACT_LINII_ACHIZITII 
ADD CONSTRAINT chk_fact_pret CHECK (pret_achizitie_unitar >= 0);

ALTER TABLE FACT_LINII_ACHIZITII 
ADD CONSTRAINT chk_fact_val_neta CHECK (valoare_achizitie_neta >= 0);

-- 3. Validari pentru Dimensiunea PRODUS
-- Flag-ul activ poate fi doar 0 sau 1
ALTER TABLE DIM_PRODUS 
ADD CONSTRAINT chk_prod_flag CHECK (flag_produs_activ IN (0, 1));

-- 4. Validari pentru Dimensiunea ANGAJAT
-- Asiguram ca numele nu este NULL (pentru rapoarte)
ALTER TABLE DIM_ANGAJAT 
MODIFY (nume_prenume CONSTRAINT nn_ang_nume NOT NULL);

-- 5. Validari pentru Dimensiunea TVA
-- Procentul TVA trebuie sa fie logic (intre 0 si 100)
ALTER TABLE DIM_TVA 
ADD CONSTRAINT chk_tva_proc CHECK (procent_tva BETWEEN 0 AND 100);

COMMIT;