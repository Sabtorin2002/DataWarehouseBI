CREATE DIMENSION dim_timp_ierarhie
LEVEL nivel_zi IS DIM_TIMP.id_timp
LEVEL nivel_an IS DIM_TIMP.an
HIERARCHY timp_rollup (
nivel_zi CHILD OF nivel_an
);


CREATE DIMENSION dim_produs_ierarhie
LEVEL nivel_produs IS DIM_PRODUS.id_produs
LEVEL nivel_categorie IS DIM_PRODUS.nume_categorie
HIERARCHY produs_rollup (
nivel_produs CHILD OF nivel_categorie
);

CREATE TABLE DIMENSION_EXCEPTIONS (
    statement_id   VARCHAR2(30),
    owner          VARCHAR2(30),
    table_name     VARCHAR2(30),
    dimension_name VARCHAR2(30),
    relationship   VARCHAR2(30),
    bad_rowid      ROWID
);

BEGIN
    DBMS_DIMENSION.VALIDATE_DIMENSION('dim_timp_ierarhie', FALSE, TRUE, 'Check Timp');
    DBMS_DIMENSION.VALIDATE_DIMENSION('dim_produs_ierarhie', FALSE, TRUE, 'Check Produs');
END;
/

-- Trebuie sa intoarca 0 randuri (fara erori)
SELECT * FROM DIMENSION_EXCEPTIONS;

-- Trebuie sa arate status VALID la ambele
SELECT dimension_name, compile_state, invalid FROM USER_DIMENSIONS
WHERE DIMENSION_NAME LIKE 'DIM_%'
