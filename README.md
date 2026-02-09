# 📊 Data Warehouse & Business Intelligence — Mini Food Retailer (Purchases / Procurement)

## Overview
This project designs and implements a **Data Warehouse (DW) + Business Intelligence (BI)** solution for a **mini food retailer**, focused on the **procurement process (Achiziții / intrări de marfă)**. The goal is to transform transactional data into a dimensional model that supports fast analytical queries for monitoring **suppliers, products, stores, costs, VAT, promotions, and staff performance**.

## Business Goals
The BI layer answers questions such as:
- Which **products / producers** generate the highest purchase volumes (e.g., last quarter)?
- How does the **purchase price evolve** compared to the previous year?
- Which **suppliers provide the best discounts** and how do they affect costs/margins?
- Are there patterns between the **receiving employee** and discrepancies / invoice values?
- What is the impact of **VAT rate changes** on final acquisition cost?

---

## 🏗️ Architecture (OLTP → ETL → DW → BI)

### 1) OLTP Source
The operational database models the procurement flow using master-detail documents:
- **FACTURA_INTRARE** (invoice header) + **LINIE_FACTURA_INTRARE** (invoice lines)
- Reference entities: **MAGAZIN**, **FURNIZOR**, **ANGAJAT**, **FUNCTIE**, **PRODUS**, **CATEGORIE_PRODUS**, **PRODUCATOR**, **TVA**, **PROMOTIE**

### 2) ETL (Extract, Transform, Load)
Data is extracted from the operational system (including a denormalized export used as a main transactional source), cleaned/transformed, then loaded into the DW star schema.

### 3) Data Warehouse Model (Star Schema)
The warehouse is built as a **Star Schema**.

**Fact Table: `FACT_LINII_ACHIZITII`** (granularity = one invoice line)  
Key measures include:
- `cantitate_achizitionata`
- `pret_achizitie_unitar`
- `valoare_achizitie_neta`
- `valoare_achizitie_tva`
- `discount_valoare`

**Dimensions:**
- `DIM_TIMP` (day/month/quarter/year + calendar attributes)
- `DIM_PRODUS` (Category → Producer → Product)
- `DIM_FURNIZOR`
- `DIM_MAGAZIN`
- `DIM_ANGAJAT`
- `DIM_TVA`
- `DIM_PROMOTIE`

---

## ⚙️ Performance & DW Techniques
To support analytical workloads (read-intensive), the implementation includes:
- **Bitmap indexes** on key foreign keys (time, supplier, store, product, employee, VAT, promotion) for fast filtering and star transformations
- **Partitioning** (e.g., range partitioning by time for the large fact table) to enable partition pruning and improve query performance
- **Dimension hierarchies** (e.g., Time rollups, Product rollups) to enable drill-down/roll-up analysis
- Consideration of **Slowly Changing Dimensions (SCD)** to preserve history where needed (e.g., product/supplier changes)

---

## 📈 BI Outputs (Reports / Analytics Examples)
Example analytical reports implemented/planned:
- Top products by acquisition cost (Pareto / Top-N)
- Daily trend of procurement value
- Distribution of costs by day of week
- Top days with highest cumulative invoices
- VAT structure (tax totals by VAT rate)

---

## 🧰 Tech Stack
- **SQL / Oracle** for schema creation, constraints, indexes, partitions, and optimization
- **ETL logic** (extract → transform → load) from OLTP/export tables into DW dimensions + fact table
- **BI layer** (dashboards/reports) built on top of the star schema

---

## 👥 Team
- Popa Andrei-Ionuț  
- Semen Valentin-Ion  
- Stoica Elias-Valeriu  
- Toma Sabin-Sebastian

