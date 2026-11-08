# Progettazione Fisica della Base di Dati: Wedding Planner
## Documentazione Tecnica e Metodologica (Capitolo 4 della Relazione)
**Corso di Basi di Dati — Università di Bologna (Prof. D. Maio, Prof.ssa A. Franco)**

---

# 1. Introduzione Metodologica alla Progettazione Fisica

La fase di **Progettazione Fisica** ha lo scopo di tradurre lo Schema Relazionale Logico normalizzato in strutture fisiche di memorizzazione concrete fornite dal DBMS di destinazione, minimizzando i tempi di risposta (latenza delle transazioni e delle query) e razionalizzando l'occupazione di memoria secondaria.

### 1.1 Selezione della Piattaforma DBMS e Storage Engine
* **DBMS Scelto:** **MySQL 8.0 Community Server (x86_64 / ARM64)**.
* **Storage Engine:** **InnoDB**.
  * InnoDB è il motore transazionale predefinito e standard de-facto di MySQL, pienamente conforme ai principi **ACID** (*Atomicity, Consistency, Isolation, Durability*).
  * Offre supporto nativo per l'integrità referenziale (**Foreign Keys** con clausole `ON DELETE` e `ON UPDATE`), locking a livello di singola riga (**Row-Level Locking**) e controllo della concorrenza multi-versione (**MVCC** - *Multi-Version Concurrency Control*).
* **Set di Caratteri e Collation:**
  * **Charset:** `utf8mb4` (supporto completo per tutti i caratteri Unicode, inclusi glifi internazionali, apostrofi corretti ed emoji).
  * **Collation:** `utf8mb4_unicode_ci` (confronti case-insensitive e conformi alle regole linguistiche Unicode internazionali).

---

# 2. Architettura di Memorizzazione e File Organization

### 2.1 Organizzazione dei Tablespace
La configurazione fisica sfrutta la direttiva `innodb_file_per_table = ON`.
* Ciascuna delle 33 relazioni del database è memorizzata fisicamente su un proprio file con estensione `.ibd` all'interno della directory dei dati del server (`/var/lib/mysql/wedding_planner/`).
* Ciò consente un'amministrazione granulare: deframmentazione mirata con `OPTIMIZE TABLE`, recupero istantaneo dello spazio disco eliminato a livello di sistema operativo e separazione fisica dei percorsi di I/O.

### 2.2 Struttura della Pagina Fisica (InnoDB Page)
* **Dimensione Pagina Base:** $16 \text{ KB}$ ($16.384 \text{ byte}$).
* Ogni pagina InnoDB è suddivisa internamente in:
  1. **Page Header & Fil Header:** Metadati della pagina, puntatori a pagine sorelle sinistra e destra nel B+Tree (allocazione a lista bidirezionale), LSN (*Log Sequence Number*).
  2. **User Records:** Zona dati in cui sono fisicamente scritte le righe ordinate secondo la chiave primaria.
  3. **Free Space:** Spazio contiguo disponibile per nuovi inserimenti o espansioni di colonne a lunghezza variabile.
  4. **Page Directory:** Array di puntatori a record (slot) utilizzato per eseguire una ricerca binaria ad alta velocità all'interno della pagina.
  5. **Fil Trailer:** Checksum crittografico per la validazione dell'integrità fisica contro scritture parziali (*torn pages*).

### 2.3 Clustered Index (Indice Primario a Grappolo)
In InnoDB, **ogni tabella è organizzata fisicamente come un B+Tree Clustered basato sulla Primary Key**:
* Le foglie del B+Tree contengono l'intera tupla di dati (tutte le colonne della tabella).
* I nodi intermedi contengono esclusivamente le chiavi di indirizzamento e i puntatori alle pagine figlie.
* **Scelta Progettuale delle Chiavi Primarie Composite:**
  * Nelle tabelle dipendenti deboli (es. `PARTECIPAZIONE(codice_fiscale, username_coppia, data_evento)` o `ATTIVITA_CHECKLIST(username_coppia, data_evento, codice_attivita)`), l'ordinamento naturale della chiave primaria garantisce che tutte le tuple relative al medesimo evento o alla medesima coppia siano memorizzate fisicamente contigue sullo stesso blocco disco o su blocchi contigui.
  * Questa contiguità fisica trasforma gli accessi di lettura per evento in scansioni sequenziali velocissime (**Sequential Read**), abbattendo drasticamente le operazioni di Seek della testina e saturando la cache del Buffer Pool con un unico prefetch I/O.

---

# 3. Strategia di Indicizzazione (B-Tree Secondary Indexes)

Gli indici secondari (Secondary B-Tree Indexes) contengono la chiave indicizzata e, come puntatore alla tupla, **la chiave primaria della riga** (e non un indirizzo fisico a byte), garantendo l'immunità degli indici secondari dai movimenti di riga causati da *page split*.

### 3.1 Criteri di Selezione degli Indici
1. **Foreign Keys:** Creazione di indici B-Tree su tutte le chiavi esterne per evitare *Full Table Scan* durante le operazioni di `JOIN` e prevenire il blocco dell'intera tabella genitore nelle verifiche di integrità referenziale `ON DELETE CASCADE`.
2. **Indici di Filtro e Ordinamento:** Aggiunta di indici mirati per le colonne presenti nelle clausole `WHERE`, `ORDER BY` e `GROUP BY` delle operazioni OLTP e dei report statistici OLAP (STAT-01..08).
3. **Indici di Copertura (Covering Indexes):** Strutturazione di indici composti in cui l'indice contiene tutte le colonne richieste dalla query, consentendo a MySQL di risolvere l'interrogazione leggendo esclusivamente l'albero dell'indice senza accedere al Clustered Index (`Using index`).

### 3.2 Tabella Sinottica degli Indici Fisici

| Nome Indice Fisico | Tabella di Riferimento | Colonne Indicizzate | Tipologia Indice | Query / Operazione Beneficiaria |
| :--- | :--- | :--- | :--- | :--- |
| `idx_coppia_coniugi` | `COPPIA` | `(cf_coniuge1, cf_coniuge2)` | B-Tree secondario | Ricerca anagrafica coppia da codice fiscale di uno dei coniugi |
| `idx_disp_dip_date` | `DISPONIBILITA` | `(dipendente_cf, data_inizio, data_fine)` | B-Tree composito | Trigger sovrapposizione assenze [V-05] e calendario planner |
| `idx_ass_dip_attiva` | `ASSEGNAZIONE_DIPENDENTE` | `(dipendente_cf, attiva)` | B-Tree composito | Controllo saturazione planner [V-08] e STAT-04 |
| `idx_evento_data_stato` | `EVENTO` | `(data, stato)` | B-Tree composito | Filtro eventi attivi STAT-02, report periodici direzionali |
| `idx_fornitore_cat_attivo` | `FORNITORE` | `(nome_categoria, attivo)` | B-Tree composito | Ricerca catalogo partner e report contratti STAT-01 |
| `idx_contratto_data_firma` | `CONTRATTO` | `(data_firma)` | B-Tree range | Analisi spesa annuale e trimestrale fornitore (STAT-01) |
| `idx_part_evento_stato` | `PARTECIPAZIONE` | `(username_coppia, data_evento, stato)` | Covering Index | Conteggio presenze confermate, calcolo coperti e STAT-08 |
| `idx_part_tavolo` | `PARTECIPAZIONE` | `(username_coppia, data_evento, tavolo_nome_numero)` | B-Tree composito | Verifica capienza tavolo [V-10] e rendering mappa sala |
| `idx_quota_regalo_evento` | `QUOTA_REGALO` | `(username_coppia, data_evento, stato)` | B-Tree composito | Calcolo totale raccolto lista nozze e riconciliazione contabile |
| `idx_quota_regalo_invitato`| `QUOTA_REGALO` | `(codice_fiscale)` | B-Tree secondario | STAT-08 (Tracciamento donazioni per ospite ricorrente) |
| `idx_chk_scadenza_stato` | `ATTIVITA_CHECKLIST` | `(scadenza, stato)` | B-Tree composito | Monitoraggio ritardi e scadenze imminenti (STAT-07, OP-11) |
| `idx_rec_voto` | `RECENSIONE` | `(voto_complessivo)` | B-Tree secondario | Benchmark qualità e gradimento matrimoni (STAT-04, STAT-05) |

---

# 4. Architettura dei Vincoli di Integrità e Trigger Procedurali

Poiché lo standard SQL `CREATE ASSERTION` non è supportato dai motori relazionali in produzione per motivi di overhead prestazionale su scritture distribuite, la totalità dei vincoli semantici inter-relazionali, aggregati e temporali formalizzati nel Capitolo 2 (`md/vincoli-progettazione.md`) è implementata a livello fisico mediante **Triggers Procedurali MySQL 8.0**.

Tutti i trigger adottano il costrutto standard:
```sql
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '[V-XX] Descrizione analitica violazione';
```
il quale provoca l'interruzione immediata e l'abort con **Rollback atomico della transazione corrente**, garantendo che lo stato della base di dati rimanga incorrotto.

### 4.1 Schema Dettagliato dei Trigger Implementati

1. **`trg_disponibilita_before_insert` & `trg_disponibilita_before_update`:**
   * **Vincolo:** [V-05] Disgiunzione degli intervalli di assenza del personale.
   * **Logica:** Esegue una `SELECT COUNT(*)` verificando se esistono record per lo stesso `dipendente_cf` in cui $\text{data\_inizio} \le \text{NEW.data\_fine} \land \text{data\_fine} \ge \text{NEW.data\_inizio}$. In caso di sovrapposizione solleva eccezione.
2. **`trg_assegnazione_before_insert` & `trg_assegnazione_before_update`:**
   * **Vincoli:** [V-07] Unicità del wedding planner attivo per coppia committente; [V-08] Limite di contemporaneità eventi del planner.
   * **Logica:** Se `NEW.attiva = 'S'`, controlla che la coppia non abbia già un planner attivo; successivamente verifica tramite `MAX(r.max_eventi_contemporanei)` che il numero di matrimoni attivi in carico al dipendente non ecceda la soglia della sua qualifica professionale.
3. **`trg_contratto_before_insert`:**
   * **Vincolo:** [V-15] Cronologia contrattuale e validità della convenzione fornitore.
   * **Logica:** Verifica che il fornitore risulti `attivo = 'S'` e che $\text{Preventivo.data\_emissione} \le \text{NEW.data\_firma} \le \text{Evento.data}$.
4. **`trg_partecipazione_before_insert` & `trg_partecipazione_before_update`:**
   * **Vincoli:** [V-10] Capienza massima dei tavoli; [V-11] Assegnazione posto riservata a invitati con stato `'CONFERMATO'`.
   * **Logica:** Blocca l'assegnazione se $\text{NEW.stato} \neq \text{'CONFERMATO'}$; confronta il conteggio delle tuple sedute al tavolo specificato con il valore `TAVOLO.capienza`, respingendo l'inserimento se il tavolo è saturo.
5. **`trg_quota_regalo_before_insert`:**
   * **Vincolo:** [V-04] Plafond del regalo e indivisibilità pezzo intero.
   * **Logica:** Se la donazione fa riferimento a un dono della lista (`descrizione_regalo IS NOT NULL`), controlla che la somma delle quote versate precedentemente più `NEW.importo` non ecceda il prezzo del bene. Se il regalo è di tipo `'INTERO'`, impone che la quota sia unica e corrisponda esattamente al 100% del prezzo.
6. **`trg_recensione_before_insert`:**
   * **Vincolo:** [V-16] Recensione consentita esclusivamente ad evento completato.
   * **Logica:** Interroga la tabella genitore `EVENTO` accertandosi che `stato = 'completato'` e che $\text{NEW.data\_recensione} \ge \text{EVENTO.data}$.

### 4.2 Mantenimento Atomico delle Ridondanze Analizzate
Nel Capitolo 3 (`md/progettazione-logica.md`, Sezione 5), l'analisi quantitativa dei costi ha dimostrato che la memorizzazione dell'attributo ridondante `LISTA_NOZZE.totale_raccolto` consente un **risparmio annuo di oltre 259.000 accessi (riduzione del 94.7%)**.
A livello fisico, l'allineamento di tale dato derivato è demandato a tre trigger atomici:
* **`trg_quota_regalo_after_insert`:** Aggiunge `NEW.importo` a `totale_raccolto`. Inoltre, calcola se la somma delle quote sul regalo ha raggiunto il prezzo del bene, valorizzando automaticamente `REGALO.completato = 'S'`.
* **`trg_quota_regalo_after_update`:** Ricalcola il delta $(\text{NEW.importo} - \text{OLD.importo})$ e aggiorna il totale della lista.
* **`trg_quota_regalo_after_delete`:** Sottrae `OLD.importo` in caso di storno o cancellazione del movimento contabile.

---

# 5. Stima Quantitativa dell'Occupazione di Memoria su Disco

Per valutare il dimensionamento fisico dello storage, si calcola lo spazio occupato a regime dopo **5 anni di esercizio** (200 eventi complessivi, 26.000 soggetti censiti).

### 5.1 Formula di Calcolo della Dimensione Tupla InnoDB
Per ciascuna riga, lo spazio fisico $L_{row}$ è composto da:
$$L_{row} = \text{Overhead Record (5 B)} + \text{Transaction ID (6 B)} + \text{Rollback Pointer (7 B)} + \sum \text{Campi Fissi} + \sum \text{Campi Variabili Effettivi}$$

### 5.2 Calcolo per le Relazioni Principali

| Relazione | Volume Tuple ($N$) | Lunghezza Media Tupla ($L_{row}$) | Spazio Dati Utile ($N \times L_{row}$) | Spazio con Overhead B+Tree (Fill Factor 70%) | Spazio Indici Secondari Stimato | Occupazione Complessiva |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **`PERSONA`** | 26.000 | 120 byte | 3.12 MB | 4.45 MB | 1.20 MB | **5.65 MB** |
| **`INVITATO`** | 25.000 | 85 byte | 2.12 MB | 3.03 MB | 0.85 MB | **3.88 MB** |
| **`PARTECIPAZIONE`** | 25.500 | 110 byte | 2.80 MB | 4.00 MB | 1.85 MB | **5.85 MB** |
| **`QUOTA_REGALO`** | 10.000 | 140 byte | 1.40 MB | 2.00 MB | 0.95 MB | **2.95 MB** |
| **`ATTIVITA_CHECKLIST`** | 6.000 | 165 byte | 0.99 MB | 1.41 MB | 0.65 MB | **2.06 MB** |
| **`EVENTO`** | 200 | 160 byte | 0.03 MB | 0.05 MB | 0.02 MB | **0.07 MB** |
| **`COPPIA`** | 250 | 95 byte | 0.02 MB | 0.04 MB | 0.02 MB | **0.06 MB** |
| **`CONTRATTO` & `PREV.`** | 1.800 | 220 byte | 0.40 MB | 0.57 MB | 0.25 MB | **0.82 MB** |
| **Altre 25 Tabelle** | ~8.000 | 110 byte | 0.88 MB | 1.25 MB | 0.45 MB | **1.70 MB** |
| **TOTALE GENERALE** | **~103.000** | — | **~11.76 MB** | **~16.80 MB** | **~6.24 MB** | **~23.04 MB** |

### 5.3 Valutazione Prestazionale sul Buffer Pool
* L'ingombro fisico complessivo stimato dopo 5 anni di piena attività d'agenzia è di circa **23 MB**.
* Poiché la memoria RAM minima di un'istanza server (o macchina di sviluppo) riserva per il parametro `innodb_buffer_pool_size` almeno **128 MB - 1 GB**, **l'intero database con tutti i suoi indici B-Tree risiede stabilmente e permanentemente in memoria RAM**.
* **Conseguenza Operativa:** L'indice di cache hit (*Buffer Pool Hit Rate*) supera costantemente il **99.8%**, riducendo a zero le operazioni fisiche di I/O su disco per le letture e relegando la scrittura asincrona al solo file di Redo Log (`ib_logfile0`), garantendo prestazioni computazionali nell'ordine del millisecondo ($< 2 \text{ ms}$).

---

# 6. Gestione delle Transazioni e Controllo della Concorrenza

### 6.1 Livello di Isolamento (Transaction Isolation Level)
Il sistema adotta il livello standard InnoDB: **`REPEATABLE READ`**.
* **Consistenza nelle Letture:** Grazie al meccanismo **MVCC**, ogni transazione legge uno snapshot temporale coerente della base di dati (*Consistent Read*) basato sul timestamp di inizio transazione. Le operazioni di lettura non acquisiscono mai lock condivisi e non bloccano mai le scritture concorrenti.
* **Prevenzione dei Fantasmi:** InnoDB impiega l'algoritmo **Next-Key Locking** (combinazione di *Record Lock* e *Gap Lock* sui nodi dell'indice B-Tree), impedendo ad altre sessioni di inserire nuove righe all'interno degli intervalli di scansione scelti da una transazione attiva, scongiurando il fenomeno del *Phantom Read*.

### 6.2 Pattern Transazionali Critici nell'Applicazione Java

Nell'applicazione software gestionale, le transazioni sensibili sono gestite con demarcazione esplicita via JDBC:
```java
connection.setAutoCommit(false);
try {
    // Operazioni ACID coordinate
    connection.commit();
} catch (SQLException e) {
    connection.rollback();
    throw e;
}
```

Esempi di transazioni atomiche progettate:
1. **Transazione Cambio Wedding Planner (Avvicendamento):**
   * Aggiornamento dell'assegnazione precedente: `UPDATE ASSEGNAZIONE_DIPENDENTE SET attiva = 'N', data_fine = CURRENT_DATE, motivo_cambio = ? WHERE username_coppia = ? AND attiva = 'S'`.
   * Inserimento contestuale del nuovo incarico: `INSERT INTO ASSEGNAZIONE_DIPENDENTE (username_coppia, dipendente_cf, data_inizio, attiva) VALUES (?, ?, CURRENT_DATE, 'S')`.
   * Esecuzione atomica: se una delle due istruzioni fallisce, l'intero avvicendamento è annullato.
2. **Transazione Assegnazione Tavoli con Locking Pessimistico:**
   * Selezione della capienza del tavolo con lock esclusivo:
     `SELECT capienza FROM TAVOLO WHERE username_coppia = ? AND data_evento = ? AND nome_numero = ? FOR UPDATE;`
   * Conteggio invitati seduti e verifica capienza residua.
   * Assegnazione dell'ospite: `UPDATE PARTECIPAZIONE SET tavolo_nome_numero = ? WHERE codice_fiscale = ?;`
   * `commit();` (rilascio immediato del lock).

---

# 7. Riepilogo dei File di Script Prodotti

A corredo della progettazione fisica, sono stati generati nella cartella `sql/` i file operativi per l'installazione e la validazione del database:
1. **[`sql/ddl.sql`](file:///Users/ariannapalmucci/Desktop/db-project/DB-project/sql/ddl.sql):** Script di creazione completo dello schema `wedding_planner`, tabelle, indici e tutti i trigger procedurali per i 18 vincoli.
2. **[`sql/dml.sql`](file:///Users/ariannapalmucci/Desktop/db-project/DB-project/sql/dml.sql):** Script di popolamento dati con casi di test realistici e completi.
3. **[`sql/queries.sql`](file:///Users/ariannapalmucci/Desktop/db-project/DB-project/sql/queries.sql):** Script contenente le 8 query analitiche STAT-01..08 pronte all'uso direzionale.
