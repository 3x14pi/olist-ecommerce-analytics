# Olist: analisi vendite e clienti

Analisi end-to-end del dataset pubblico [Olist Brazilian E-Commerce](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce), costruita per rispondere a quattro domande di business: quanto fattura il marketplace, quali categorie e regioni generano valore, e quanto spesso i clienti tornano ad acquistare?

**[Apri la dashboard interattiva su Tableau Public](https://public.tableau.com/app/profile/antonio.ferri4043/viz/Olist-AnalisiVenditeClienti/Dashboard1)**

![Anteprima della dashboard](result/dashboard.png)

**Ruolo:** Data Analyst | **Dominio:** e-commerce | **Periodo dati:** 2016-2018

### Cosa dimostra questo progetto

- trasformazione di dati relazionali grezzi in un modello analitico PostgreSQL;
- analisi SQL con join, CTE, funzioni finestra e segmentazione RFM;
- traduzione dei risultati in insight e raccomandazioni di business;
- comunicazione dei KPI tramite una dashboard Tableau Public interattiva.

## Risultati principali

- **Fatturato ~ R$ 13,6 mln**, in crescita costante nel 2017, con **picco a novembre 2017 (Black Friday)**.
- Categorie top per fatturato: **health & beauty, orologi/regali, casa (bed & bath)**.
- **Forte concentrazione geografica**: São Paulo da solo pesa **~38%** del fatturato → business dipendente dal Sud-Est, resto del Paese ancora inesplorato.
- **Retention critica**: solo **~3% dei clienti** compra più di una volta → dipendenza dall'acquisizione continua di nuovi clienti.
- **Le consegne in ritardo affossano la soddisfazione**: voto medio **4,29** (in orario) vs **2,57** (in ritardo) → la logistica è una leva strategica.

Ogni numero è riproducibile dalle viste versionate in [`sql/analisi.sql`](sql/analisi.sql) — KPI generali, fatturato per categoria/mese/stato, retention, ritardi vs recensioni — e in [`sql/v_rfm_segmenti.sql`](sql/v_rfm_segmenti.sql) per i segmenti cliente.

## Segmentazione clienti con RFM

Ho classificato i ~95.000 clienti su **Recency, Frequency, Monetary** per capire
dove si concentra il valore.

**Nota metodologica.** Con retention ~3%, quasi tutti i clienti hanno un solo
ordine: la **Frequency è poco discriminante**. Ho quindi usato uno score di
frequenza a gradini (1 / 2 / 3+ ordini) e dato peso maggiore a **Recency e
Monetary** nella definizione dei segmenti.

| Segmento           | % clienti | % fatturato | Azione consigliata                          |
| ------------------ | --------- | ----------- | ------------------------------------------- |
| Campioni           | 15,5%     | 29,3%       | Trattenere: programmi VIP, fidelizzazione   |
| A rischio          | 14,7%     | 28,8%       | Riconquistare con offerte mirate            |
| Nel mezzo          | 34,9%     | 27,4%       | Spingere al secondo acquisto con promozioni |
| Fedeli (rari)      | 3,1%      | 5,6%        | Incentivare il riacquisto                   |
| Persi/Basso valore | 16,4%     | 4,6%        | Riattivazione a basso costo                 |
| Nuovi/Promettenti  | 15,4%     | 4,3%        | Incentivo al riacquisto                     |

**Insight chiave:**
- **Campioni + A rischio = 30% dei clienti ma ~58% del fatturato**: il valore è molto concentrato.
- Il segmento **"A rischio" vale ~29% del fatturato (~3,9 mln R$)** pur essendo solo il 14,7% dei clienti → massima priorità per il win-back.

## Raccomandazioni di business
Ogni criticità emersa dai dati si traduce in un'azione concreta:
- **Aumentare la retention.** Il business dipende dall'acquisizione continua, che è costosa. Suggerisco di testare campagne di **win-back post primo acquisto** (email a 30/60/90 giorni) sui segmenti RFM a rischio e di misurare l'impatto sul tasso di riacquisto a 6 mesi.
- **Trattare la logistica come leva strategica.** Il divario di soddisfazione tra consegne in orario (4,29) e in ritardo (2,57) impatta direttamente recensioni e riacquisto. Prioritizzare gli **stati/rotte con più ritardi** e stimare il ritorno di un miglioramento dei tempi sul rating medio.
- **Concentrazione su São Paulo (~38%).** Espansione mirata su Nordest/Centro-Ovest partendo dalle categorie già forti, monitorando il costo di acquisizione per regione.

## Stack tecnologico
| Strumento | Uso |
|-----------|-----|
| **Python** (pandas, NumPy) | esplorazione, pulizia, ETL |
| **PostgreSQL** + **SQLAlchemy** | database e caricamento dati |
| **SQL** | analisi (JOIN, CTE, window functions, RFM) |
| **Tableau Public** | dashboard interattiva |

## Pipeline analitica
1. **Data understanding** — analisi delle 9 tabelle e della qualità dei dati in [`notebook/01-Understanding.ipynb`](notebook/01-Understanding.ipynb).
2. **Modello dati** — schema e relazioni in [`docs/data_model.png`](docs/data_model.png) e [`docs/data_model.txt`](docs/data_model.txt).
3. **ETL** — pulizia, caricamento in PostgreSQL, creazione delle viste ed export in [`notebook/02-ETL.ipynb`](notebook/02-ETL.ipynb).
4. **Analisi SQL** — viste riusabili in [`sql/analisi.sql`](sql/analisi.sql).
5. **Segmentazione RFM** — scoring e segmenti in [`sql/v_rfm_segmenti.sql`](sql/v_rfm_segmenti.sql).
6. **Visualizzazione** — dashboard interattiva pubblicata su Tableau Public.

## Riproducibilità

I file CSV Olist non sono inclusi nel repository per evitare di versionare oltre 160 MB di dati grezzi. Scarica il dataset dalla [fonte Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) e copia i CSV in `data/raw/` mantenendo i nomi originali (il file `archive.zip` non serve).

```bash
git clone https://github.com/3x14pi/olist-ecommerce-analytics.git
cd olist-ecommerce-analytics
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
createdb olist          # richiede PostgreSQL in esecuzione
jupyter notebook
```

Esegui poi `notebook/02-ETL.ipynb` dall'alto verso il basso: carica le tabelle, crea le viste eseguendo i file di `sql/` e rigenera gli export in `result/` e `data/processed/`. La password del database viene chiesta a runtime e non è mai scritta nel codice.

Per una valutazione rapida non serve nulla di tutto questo: la dashboard è pubblica e `result/` contiene già gli aggregati e l'anteprima statica.

## Limiti metodologici

- Il fatturato usa il prezzo degli articoli e non include il freight value.
- Gli ultimi mesi della serie sono incompleti (settembre 2018 contiene 1 ordine contro i ~6.500 mensili del periodo precedente): il calo finale sarebbe un artefatto del dataset, non un calo di business, quindi la dashboard si ferma ad agosto 2018. Gli export in `result/` restano invece sull'intero periodo.
- La retention è definita come quota di clienti con almeno due ordini; il dataset contiene soprattutto clienti con un solo acquisto, quindi la frequency discrimina poco.
- Le associazioni tra ordini, pagamenti e recensioni richiedono attenzione perché alcune chiavi non sono univoche: l'analisi ritardi/recensioni resta a livello di ordine proprio per non duplicare le righe di dettaglio. Le scelte sono documentate nel modello dati.

## Struttura del progetto
```
.
├── notebook/     # Jupyter: 01 data understanding, 02 ETL
├── sql/          # viste di analisi + segmentazione RFM
├── docs/         # diagramma del modello dati
├── data/         # raw/ e processed/ (vuote: i dati si scaricano da Kaggle)
├── result/       # export aggregati (KPI, categorie, trend, RFM) + dashboard
├── requirements.txt
└── .gitignore
```

## Output principali

- [`result/dashboard.png`](result/dashboard.png) — anteprima statica della dashboard;
- [`result/fatturato_mensile.xlsx`](result/fatturato_mensile.xlsx) — trend mensile del fatturato;
- [`result/categorie.xlsx`](result/categorie.xlsx) — fatturato per categoria;
- [`result/rfm_segmenti.xlsx`](result/rfm_segmenti.xlsx) — distribuzione dei segmenti cliente;
- [`result/retention.xlsx`](result/retention.xlsx) — clienti ricorrenti sul totale;
- [`result/consegne_recensioni.xlsx`](result/consegne_recensioni.xlsx) — voto medio per consegne in orario e in ritardo.

## 👤 Autore
**Antonio Ferri** — [Dashboard su Tableau Public](https://public.tableau.com/app/profile/antonio.ferri4043/viz/Olist-AnalisiVenditeClienti/Dashboard1)
