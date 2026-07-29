#  Olist — Analisi Vendite & Clienti

Progetto di analisi sul dataset pubblico [Olist Brazilian E-Commerce](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce): dai dati grezzi fino a una **dashboard interattiva** che risponde alle domande della direzione di un marketplace.

###  **[▶ Apri la dashboard interattiva su Tableau Public](https://public.tableau.com/app/profile/antonio.ferri4043/viz/Olist-AnalisiVenditeClienti/Dashboard1)**

![Dashboard](result/dashboard.png)

---

## Il progetto in breve
**Olist** è un marketplace e-commerce brasiliano. La direzione vuole capire come sta andando il business.
Ho costruito l'**intera pipeline analitica** — dai dati grezzi alla dashboard — per rispondere a: *quanto fatturiamo? Quali categorie e regioni rendono di più? I clienti tornano a comprare?*

## 📊 Insight chiave
- 💰 **Fatturato ~ R$ 13,6 mln**, in crescita costante nel 2017, con **picco a novembre 2017 (Black Friday)**.
- 🏷️ Categorie top per fatturato: **health & beauty, orologi/regali, casa (bed & bath)**.
- 🗺️ **Forte concentrazione geografica**: São Paulo da solo pesa **~38%** del fatturato → business dipendente dal Sud-Est, resto del Paese ancora inesplorato.
- 🔄 **Retention critica**: solo **~3% dei clienti** compra più di una volta → dipendenza dall'acquisizione continua di nuovi clienti.
- 🚚 **Le consegne in ritardo affossano la soddisfazione**: voto medio **4,29** (in orario) vs **2,57** (in ritardo) → la logistica è una leva strategica.

## 🛠️ Stack tecnologico
| Strumento | Uso |
|-----------|-----|
| **Python** (pandas, NumPy) | esplorazione, pulizia, ETL |
| **PostgreSQL** + **SQLAlchemy** | database e caricamento dati |
| **SQL** | analisi (JOIN, CTE, window functions, RFM) |
| **Tableau Public** | dashboard interattiva |

## 🔍 Metodologia (pipeline)
1. **Data Understanding** — analisi delle 9 tabelle, qualità dei dati → [`notebook/01`](notebook/)
2. **Modello dati** — diagramma / star schema → [`docs/data_model.png`](docs/data_model.png)
3. **ETL** — pulizia + caricamento in PostgreSQL → [`notebook/02`](notebook/)
4. **Analisi SQL** — 5 domande di business come viste riusabili → [`sql/analisi.sql`](sql/analisi.sql)
5. **Segmentazione RFM** — clienti per valore (Recency, Frequency, Monetary) → [`sql/v_rfm_segmenti.sql`](sql/v_rfm_segmenti.sql)
6. **Visualizzazione** — dashboard interattiva in Tableau →  [`result/dashboard.png`](result/dashboard.png)

## 📁 Struttura del progetto
```
.
├── notebook/     # Jupyter: 01 data understanding, 02 ETL
├── sql/          # viste di analisi + segmentazione RFM
├── docs/         # diagramma del modello dati
├── result/       # export aggregati (KPI, categorie, trend, RFM) + dashboard
```


## 👤 Autore
**Antonio Ferri** — [Dashboard su Tableau Public](https://public.tableau.com/app/profile/antonio.ferri4043)
