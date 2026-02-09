import streamlit as st
import pandas as pd
import oracledb
import plotly.express as px

# ==========================================
# 1. CONFIGURARE CONEXIUNI ORACLE
# ==========================================
# Datele tale de conectare
DB_USER = "master_dw_if"
DB_PASSWORD = "depozit"
DB_HOST = "193.226.53.52"
DB_PORT = 1521
DB_SERVICE = "db1"

# Functia de conectare actualizata (fara parametri, foloseste variabilele globale)
def get_connection():
    dsn_tns = f"{DB_HOST}:{DB_PORT}/{DB_SERVICE}"
    return oracledb.connect(user=DB_USER, password=DB_PASSWORD, dsn=dsn_tns)

# ==========================================
# 2. INTERFATA GRAFICA STREAMLIT
# ==========================================
st.set_page_config(page_title="DW & BI Retail Dashboard", layout="wide")
st.title("🛒 Sistem BI & Data Warehouse - Retail Alimentar")

# Tab-urile pentru cele 3 cerinte
tab1, tab2, tab3, tab4 = st.tabs(["1. Gestiune OLTP (Intrari)", "2. Propagare ETL (OLTP -> DW)", "3. Rapoarte BI (Analytics)", "4. Self-Service BI (Ad-hoc)"])

# ==========================================
# TAB 1: GESTIUNE OLTP (Insert Date - DINAMIC)
# ==========================================
with tab1:
    st.header("📝 Introducere Factură Nouă (OLTP)")
    st.info("Aici simulăm activitatea operațională: recepția de marfă în magazin.")

    conn = None
    try:
        conn = get_connection()
        
        # 1. Incarcam listele din baza de date (ca sa nu fie hardcodate)
        # Nota: Folosim tabelele sursa (OLTP). Daca sunt in alta schema, pune prefixul (ex: dw_proiect.FURNIZOR)
        df_furnizori = pd.read_sql("SELECT id_furnizor, nume_furnizor FROM FURNIZOR_UOUK", conn)
        df_magazine = pd.read_sql("SELECT id_magazin, nume_magazin FROM MAGAZIN_UOUK", conn)
        df_angajati = pd.read_sql("SELECT id_angajat, nume, prenume FROM ANGAJAT_UOUK", conn)
        df_produse = pd.read_sql("SELECT id_produs, denumire_produs FROM PRODUS_UOUK ORDER BY denumire_produs", conn)

        # Formular de input
        with st.form("form_factura"):
            col1, col2 = st.columns(2)
            
            with col1:
                # Selectbox inteligent: Arata Numele, dar returneaza ID-ul
                furnizor_id = st.selectbox(
                    "Selectează Furnizor", 
                    options=df_furnizori['ID_FURNIZOR'], 
                    format_func=lambda x: df_furnizori[df_furnizori['ID_FURNIZOR'] == x]['NUME_FURNIZOR'].values[0]
                )
                
                magazin_id = st.selectbox(
                    "Selectează Magazin", 
                    options=df_magazine['ID_MAGAZIN'], 
                    format_func=lambda x: df_magazine[df_magazine['ID_MAGAZIN'] == x]['NUME_MAGAZIN'].values[0]
                )
                
                angajat_id = st.selectbox(
                    "Angajat Recepție", 
                    options=df_angajati['ID_ANGAJAT'], 
                    format_func=lambda x: f"{df_angajati[df_angajati['ID_ANGAJAT'] == x]['NUME'].values[0]} {df_angajati[df_angajati['ID_ANGAJAT'] == x]['PRENUME'].values[0]}"
                )
                
                data_fact = st.date_input("Data Facturii")
            
            with col2:
                # Dropdown pentru produse (mult mai sigur decat sa scrii ID manual)
                produs_id = st.selectbox(
                    "Selectează Produs", 
                    options=df_produse['ID_PRODUS'], 
                    format_func=lambda x: f"{df_produse[df_produse['ID_PRODUS'] == x]['DENUMIRE_PRODUS'].values[0]} (ID: {x})"
                )
                
                cantitate = st.number_input("Cantitate", min_value=1.0, step=0.5)
                pret = st.number_input("Pret Achizitie (RON)", min_value=0.1, step=0.1)
            
            submitted = st.form_submit_button("💾 Salvează Factura în OLTP")

            if submitted:
                cursor = conn.cursor()
                try:
                    # A. Inseram Antet Factura
                    # Folosim sufixul _UOUK daca asa ai tabelele tale (verifica numele exact!)
                    # Daca tabelele se numesc doar FACTURA_INTRARE, sterge _UOUK
                    cursor.execute("SELECT NVL(MAX(id_factura_intrare), 0) + 1 FROM FACTURA_INTRARE_UOUK")
                    new_id_fact = cursor.fetchone()[0]
                    
                    sql_fact = """
                        INSERT INTO FACTURA_INTRARE_UOUK (id_factura_intrare, numar_factura, data_factura, id_furnizor, id_magazin, id_angajat)
                        VALUES (:1, :2, :3, :4, :5, :6)
                    """
                    cursor.execute(sql_fact, [new_id_fact, f'FACT-WEB-{new_id_fact}', data_fact, furnizor_id, magazin_id, angajat_id])
                    
                    # B. Inseram Linie Factura
                    cursor.execute("SELECT NVL(MAX(id_linie), 0) + 1 FROM LINIE_FACTURA_INTRARE_UOUK")
                    new_id_linie = cursor.fetchone()[0]
                    
                    val_neta = cantitate * pret
                    
                    # ID_TVA = 2 este hardcodat (presupunem 19%). Daca vrei dinamic, poti face selectbox si pt TVA.
                    sql_linie = """
                        INSERT INTO LINIE_FACTURA_INTRARE_UOUK (id_linie, id_factura_intrare, id_produs, cantitate, pret_achizitie, valoare_neta, id_tva)
                        VALUES (:1, :2, :3, :4, :5, :6, 2)
                    """
                    cursor.execute(sql_linie, [new_id_linie, new_id_fact, produs_id, cantitate, pret, val_neta])
                    
                    conn.commit()
                    st.success(f"✅ Factura {new_id_fact} a fost salvată cu succes! (Produs: {produs_id}, Cantitate: {cantitate})")
                    
                except Exception as e:
                    st.error(f"Eroare la salvare SQL: {e}")
                finally:
                    cursor.close()

    except Exception as e:
        st.error(f"Eroare conexiune sau lipsa tabele: {e}")
        st.warning("Verifica daca numele tabelelor (FURNIZOR, PRODUS etc.) sunt corecte si daca ai drepturi SELECT pe ele.")
    finally:
        if conn: conn.close()

# ==========================================
# TAB 2: PROPAGARE ETL (OLTP -> DW)
# ==========================================
with tab2:
    st.header("🔄 Procesare ETL (Extract, Transform, Load)")
    st.markdown("Acest modul declanșează procedura de actualizare a depozitului de date.")

    col_kpi1, col_kpi2 = st.columns(2)
    
    # Verificare status curent (Linii in DW)
    conn_dw = None
    try:
        conn_dw = get_connection()
        # Verificam daca tabelul e gol sau are date
        df_count = pd.read_sql("SELECT COUNT(*) as cnt FROM FACT_LINII_ACHIZITII", conn_dw)
        count_before = df_count.iloc[0]['CNT']
        col_kpi1.metric("Linii in DW (Acum)", f"{count_before}")
    except Exception as e:
        col_kpi1.error(f"Eroare conectare DW: {e}")
    finally:
        if conn_dw: conn_dw.close()

    # Butonul de ETL
    if st.button("🚀 Execută Propagarea Datelor (ETL)"):
        with st.spinner("Se rulează procedura PL/SQL REFRESH_DW_ETL..."):
            conn_etl = None
            try:
                conn_etl = get_connection()
                cursor = conn_etl.cursor()
                
                # Apelam procedura stocata
                cursor.callproc("REFRESH_DW_ETL")
                
                conn_etl.close() # Inchidem conexiunea de executie
                
                st.success("Propagare realizată cu succes!")
                
                # Re-citire date pentru validare vizuala
                conn_check = get_connection()
                df_count_new = pd.read_sql("SELECT COUNT(*) as cnt FROM FACT_LINII_ACHIZITII", conn_check)
                count_after = df_count_new.iloc[0]['CNT']
                conn_check.close()
                
                col_kpi2.metric("Linii in DW (După ETL)", f"{count_after}", delta=int(count_after - count_before))
                
                if count_after > count_before:
                    st.balloons()
                    st.write("Datele noi din OLTP au ajuns cu succes în DW!")
                elif count_after == count_before:
                    st.info("Procedura a rulat, dar nu au fost găsite date noi de importat.")
                    
            except Exception as e:
                st.error(f"Eroare la rularea ETL: {e}")

# ==========================================
# TAB 3: RAPOARTE BI
# ==========================================
with tab3:
    st.header("📊 Tablou de Bord Analitic (Decembrie 2025)")
    
    conn_bi = None
    try:
        conn_bi = get_connection()
        
        # --- RAPORT 1: Pareto Produse (Bar Chart) ---
        st.subheader("1. Top Produse (Costuri)")
        sql_pareto = """
            SELECT p.denumire_produs, SUM(f.valoare_achizitie_neta) as valoare
            FROM FACT_LINII_ACHIZITII f
            JOIN DIM_PRODUS p ON f.id_produs = p.id_produs
            GROUP BY p.denumire_produs
            ORDER BY valoare DESC FETCH FIRST 10 ROWS ONLY
        """
        df_pareto = pd.read_sql(sql_pareto, conn_bi)
        if not df_pareto.empty:
            fig_pareto = px.bar(df_pareto, x='VALOARE', y='DENUMIRE_PRODUS', orientation='h', title="Top 10 Produse după Valoare", color='VALOARE')
            st.plotly_chart(fig_pareto, use_container_width=True)
        else:
            st.warning("Nu există date pentru Raportul 1.")

        # --- RAPORT 2: Evolutie Zilnica (Line Chart) ---
        st.subheader("2. Evoluția Zilnică a Aprovizionării")
        sql_trend = """
            SELECT t.data_calendaristica, SUM(f.valoare_achizitie_neta) as valoare_zilnica
            FROM FACT_LINII_ACHIZITII f JOIN DIM_TIMP t ON f.id_timp = t.id_timp
            WHERE t.an = 2025 AND t.luna = 12
            GROUP BY t.data_calendaristica ORDER BY t.data_calendaristica
        """
        df_trend = pd.read_sql(sql_trend, conn_bi)
        if not df_trend.empty:
            fig_trend = px.line(df_trend, x='DATA_CALENDARISTICA', y='VALOARE_ZILNICA', markers=True, title="Trend Achiziții Decembrie")
            st.plotly_chart(fig_trend, use_container_width=True)
        else:
             st.warning("Nu există date pentru Raportul 2 (Decembrie 2025).")

        # --- RAPORT 3 & 5 (Coloane alaturate - Pie Charts) ---
        c1, c2 = st.columns(2)
        
        with c1:
            st.subheader("3. Distribuție pe Zile")
            sql_days = """
                SELECT t.nume_zi, SUM(f.valoare_achizitie_neta) as valoare
                FROM FACT_LINII_ACHIZITII f JOIN DIM_TIMP t ON f.id_timp = t.id_timp
                GROUP BY t.nume_zi
            """
            df_days = pd.read_sql(sql_days, conn_bi)
            if not df_days.empty:
                fig_days = px.pie(df_days, names='NUME_ZI', values='VALOARE', hole=0.4)
                st.plotly_chart(fig_days, use_container_width=True)

        with c2:
            st.subheader("5. Structura TVA")
            sql_tva = """
                SELECT tv.denumire_tva, SUM(f.valoare_tva) as total_tva
                FROM FACT_LINII_ACHIZITII f JOIN DIM_TVA tv ON f.id_tva = tv.id_tva
                GROUP BY tv.denumire_tva
            """
            df_tva = pd.read_sql(sql_tva, conn_bi)
            if not df_tva.empty:
                fig_tva = px.pie(df_tva, names='DENUMIRE_TVA', values='TOTAL_TVA', title="Taxe Plătite")
                st.plotly_chart(fig_tva, use_container_width=True)

        # --- RAPORT 4: Top Zile Record (Tabel Detaliat) ---
        # Aici am adaugat raportul lipsa
        st.subheader("4. Top 5 Zile cu Plăți Record")
        st.markdown("Cele mai costisitoare zile din punct de vedere al achizițiilor.")
        
        sql_top_days = """
            SELECT * FROM (
                SELECT 
                    dt.data_calendaristica,
                    SUM(f.valoare_achizitie_neta) as total_achizitii_ron,
                    SUM(f.cantitate_achizitionata) as volum_marfa
                FROM FACT_LINII_ACHIZITII f
                JOIN DIM_TIMP dt ON f.id_timp = dt.id_timp
                GROUP BY dt.data_calendaristica
                ORDER BY total_achizitii_ron DESC
            ) WHERE ROWNUM <= 5
        """
        df_top_days = pd.read_sql(sql_top_days, conn_bi)
        
        if not df_top_days.empty:
            # Afisam ca tabel interactiv
            st.dataframe(df_top_days, use_container_width=True)
        else:
            st.warning("Nu există date pentru Raportul 4.")

    except Exception as e:
        st.error(f"Eroare la incarcarea rapoartelor: {e}")
    finally:
        if conn_bi: conn_bi.close()
# ==========================================
# TAB 4: SELF-SERVICE BI (PRO - MULTI DIMENSION)
# ==========================================
with tab4:
    st.header("🛠️ Self-Service BI (Advanced)")
    st.markdown("Construiește rapoarte complexe combinând multiple dimensiuni.")

    # 1. Definirea Optiunilor EXTINSE
    dimensiuni_map = {
        "Categorie Produs": "p.nume_categorie",
        "Denumire Produs": "p.denumire_produs",
        "Tip Magazin": "m.tip_magazin",
        "Nume Magazin": "m.nume_magazin",
        "Furnizor": "furn.denumire_furnizor",
        "An": "t.an",
        "Luna": "t.nume_luna",
        "Zi Saptamana": "t.nume_zi",
        "Data Calendaristica": "t.data_calendaristica",
        "Cota TVA": "tv.denumire_tva"
    }

    masuri_map = {
        "Valoare Netă Achiziții": "SUM(f.valoare_achizitie_neta)",
        "Cantitate Produse": "SUM(f.cantitate_achizitionata)",
        "Valoare TVA": "SUM(f.valoare_tva)",
        "Număr Tranzacții": "COUNT(*)",
        "Pret Mediu Unitar": "AVG(f.pret_achizitie_unitar)"
    }

    # 2. Controale Utilizator (Folosim MULTISELECT)
    with st.form("bi_form"):
        c1, c2, c3 = st.columns(3)
        with c1:
            # Aici e magia: Permitem multiple selectii
            sel_dims = st.multiselect("Alege Dimensiuni (Grupare)", list(dimensiuni_map.keys()), default=["Categorie Produs"])
        with c2:
            sel_masura = st.selectbox("Alege Măsura (Valoare)", list(masuri_map.keys()))
        with c3:
            sel_chart = st.selectbox("Tip Vizualizare", ["Bar Chart", "Line Chart", "Pie Chart", "Tabel Detaliat"])
        
        # Butonul e in form, deci nu face refresh pana nu dai click
        submitted = st.form_submit_button("🚀 Generează Raportul Complex")

    # 3. Logica de Generare
    if submitted:
        if not sel_dims:
            st.error("⚠️ Te rog selectează cel puțin o dimensiune!")
        else:
            conn_ss = None
            try:
                conn_ss = get_connection()
                
                # Construim lista de coloane pentru SQL
                col_db_list = [dimensiuni_map[d] for d in sel_dims]
                col_alias_list = [d.replace(" ", "_") for d in sel_dims]
                
                # Facem string-ul pentru SELECT si GROUP BY (ex: t.an, p.nume_categorie)
                cols_sql = ", ".join([f'{db} as "{alias}"' for db, alias in zip(col_db_list, col_alias_list)])
                groupby_sql = ", ".join(col_db_list)
                agg_db = masuri_map[sel_masura]

                # Query Dinamic Complex
                sql_adhoc = f"""
                    SELECT {cols_sql}, {agg_db} as VALOARE
                    FROM FACT_LINII_ACHIZITII f
                    JOIN DIM_TIMP t ON f.id_timp = t.id_timp
                    JOIN DIM_PRODUS p ON f.id_produs = p.id_produs
                    JOIN DIM_MAGAZIN m ON f.id_magazin = m.id_magazin
                    JOIN DIM_FURNIZOR furn ON f.id_furnizor = furn.id_furnizor
                    JOIN DIM_TVA tv ON f.id_tva = tv.id_tva
                    GROUP BY {groupby_sql}
                    ORDER BY VALOARE DESC
                """
                
                # Executie
                df_adhoc = pd.read_sql(sql_adhoc, conn_ss)

                if not df_adhoc.empty:
                    st.success(f"Analiză generată: **{sel_masura}** grupat pe **{', '.join(sel_dims)}**")
                    
                    # LOGICA DE AFISARE GRAFICA INTELIGENTA
                    
                    # Cazul 1: Tabel (Mereu disponibil)
                    if sel_chart == "Tabel Detaliat":
                        st.dataframe(df_adhoc, use_container_width=True)

                    # Cazul 2: Grafice
                    else:
                        # Daca avem prea multe dimensiuni, graficul e urat -> Fortam Tabel sau facem Grouped Bar
                        if len(sel_dims) > 2:
                            st.warning("⚠️ Pentru mai mult de 2 dimensiuni, recomandăm vizualizarea Tabel. Graficul poate fi aglomerat.")
                            st.dataframe(df_adhoc, use_container_width=True)
                        
                        else:
                            # 1 Dimensiune (Clasic)
                            if len(sel_dims) == 1:
                                x_axis = col_alias_list[0]
                                color_axis = col_alias_list[0] # Coloram la fel ca X
                                
                                if sel_chart == "Bar Chart":
                                    fig = px.bar(df_adhoc, x=x_axis, y='VALOARE', color=color_axis, title=f"{sel_masura} per {sel_dims[0]}")
                                elif sel_chart == "Line Chart":
                                    fig = px.line(df_adhoc, x=x_axis, y='VALOARE', markers=True)
                                elif sel_chart == "Pie Chart":
                                    fig = px.pie(df_adhoc, names=x_axis, values='VALOARE')
                                st.plotly_chart(fig, use_container_width=True)

                            # 2 Dimensiuni (Stacked/Grouped - Foarte Puternic!)
                            elif len(sel_dims) == 2:
                                x_axis = col_alias_list[0]     # Prima dim pe axa X (ex: An)
                                color_axis = col_alias_list[1] # A doua dim e Legenda/Culoarea (ex: Categorie)
                                
                                if sel_chart == "Bar Chart":
                                    # Face Stacked Bar automat
                                    fig = px.bar(df_adhoc, x=x_axis, y='VALOARE', color=color_axis, barmode='group', 
                                                 title=f"{sel_masura}: {sel_dims[0]} vs {sel_dims[1]}")
                                    st.plotly_chart(fig, use_container_width=True)
                                
                                elif sel_chart == "Line Chart":
                                    # Linii multiple (cate una pentru fiecare categorie din dim 2)
                                    fig = px.line(df_adhoc, x=x_axis, y='VALOARE', color=color_axis, markers=True,
                                                  title=f"Evoluție {sel_dims[0]} detaliată pe {sel_dims[1]}")
                                    st.plotly_chart(fig, use_container_width=True)
                                
                                elif sel_chart == "Pie Chart":
                                    st.warning("Pie Chart suportă doar 1 dimensiune. Afișăm prima dimensiune selectată.")
                                    fig = px.pie(df_adhoc, names=x_axis, values='VALOARE')
                                    st.plotly_chart(fig, use_container_width=True)

                else:
                    st.warning("Nu există date pentru combinația selectată.")

            except Exception as e:
                st.error(f"Eroare SQL: {e}")
            finally:
                if conn_ss: conn_ss.close()