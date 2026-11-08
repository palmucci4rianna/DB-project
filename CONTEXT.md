# CONTEXT — Progetto Basi di Dati: Wedding Planner

Contesto per il progetto d'esame di Basi di Dati (UniBo, corso 72609). Riassume i
file in [proposta/](proposta/), i vincoli del corso, cosa fanno bene/male le
relazioni di esempio e i problemi aperti del nostro modello.

---

## 1. Stato del repo

| Cosa | Dove | Note |
|---|---|---|
| Proposta inviata (breve) | `proposta/proposta.docx`, `proposta/db-prop forum.docx` | Stesso testo; la seconda è la versione per il forum |
| Bozza dettagliata (dicembre '26) | `proposta/db-wedding-planner dic26.docx` | Specifiche estese, operazioni, entità, associazioni, schema mermaid con **chiavi naturali** |
| Diagramma ER (vecchio) | `proposta/diagram/wedding-planner.md` + `.png` | Mermaid con **chiavi surrogate `int id`** ovunque, versione precedente alla bozza |
| Linee guida del corso | `proposta/linea.guida.pdf` | Vedi §2 |
| Relazioni di esempio | `proposta/Gruppo{1453,1456,1701}_Relazione.pdf` | Vedi §3 |
| Esempio proposta | `proposta/utilities/virtuale/esempio proposta da virtuale.docx` | Sito piante grasse (gruppo da 2) |
| **Schema ER (DB-Main)** | `er/wedding-planner.lun` | Bozza dello schema concettuale: 35 entità, 47 associazioni (vedi §8) |
| Generatore ER | `er/generatore/` | `GeneraER.java` + `genera.sh` (API JIDBM di DB-Main). **Rigenerare sovrascrive il .lun** |
| Progetto Java/Gradle | `settings.gradle.kts`, `app/build.gradle.kts` | Solo scheletro, nessun sorgente ancora |
| Zip duplicato | `gradle/progetto-db.zip` | Copia di pdf + proposta.docx; non ha senso dentro `gradle/`, non committare |

**Da sistemare nel progetto Gradle:** `rootProject.name = "OOP25-UniBodget"` è rimasto da un
altro progetto (OOP) → rinominare. `app/build.gradle.kts` ha solo il plugin `java`: mancano
`application`, il driver JDBC e il `mainClass`.

---

## 2. Requisiti del corso (linee guida)

- Gruppo da 1 a 3 persone; **la complessità deve essere proporzionata al numero di componenti**.
- La proposta va registrata nell'archivio elaborati. Se il tutor non risponde entro 1 settimana, è approvata.
- La consegna dell'elaborato serve per accedere allo scritto; consegnato una volta, vale per sempre.
- Qualsiasi DBMS **relazionale**, con un'**interfaccia utente adeguata** (anche web).
- **Deve funzionare sui PC del laboratorio**, altrimenti bisogna portare il proprio portatile.

### Struttura obbligatoria della relazione
1. **Analisi dei requisiti**
   - Intervista (testo "grezzo" del committente)
   - Rilevamento delle ambiguità e correzioni proposte (tabella *Riga / Termine / Nuovo termine*)
   - Specifiche in linguaggio naturale ed estrazione dei concetti principali
2. **Progettazione concettuale**
   - Schema scheletro → raffinamenti proposti → schema concettuale finale
3. **Progettazione logica**
   - Stima del volume dei dati
   - Operazioni principali e loro frequenza
   - Schemi di navigazione e tabelle degli accessi
   - Raffinamento dello schema (eliminazione di identificatori esterni, attributi composti, gerarchie; scelta delle chiavi)
   - Analisi delle ridondanze
   - Traduzione di entità e associazioni in relazioni
   - Schema relazionale finale
   - Traduzione delle operazioni in query SQL
4. **Progettazione dell'applicazione**
   - Architettura + **screenshot obbligatori** dell'interfaccia

### Formato della proposta (dall'esempio di Virtuale)
Descrizione generale ma completa del dominio, poi l'elenco sintetico delle operazioni,
di tipo e complessità diversi: inserimenti/eliminazioni, visualizzazioni semplici e
statistiche complesse. L'esempio (gruppo da 2) ha circa **4 operazioni utente + 3
statistiche + 6 di amministrazione**.

---

## 3. Cosa insegnano le relazioni di esempio

| | 1456 – Terreno agricolo | 1453 – MMORPG "Blades & Magic" | 1701 – Palestra |
|---|---|---|---|
| Gruppo | 1 persona | 3 persone | 1 persona |
| Pagine | 35 | 49 | 31 |
| Tabelle | ~17 | ~35 | ~19 |
| Stack | Java + JDBC + **SQL Server** | Java **Swing** + **UCanAccess** (MS Access) | Java **JavaFX** (FXML) + **Hibernate** + **MySQL** |
| Notazione ER | DB-Main (cardinalità `0-N`, `1-1`, `id:`) | ER classico, diviso per "ambiti" | ER classico, diviso per aree |

### Pattern ricorrenti (da copiare)
- **Analisi per viste/utenti** (1456): requisiti separati per Operai/Venditori/Amministratore,
  con operazioni codificate (`O1…`, `V1…`, `A1…`). Per noi: Planner, Amministratore, ed eventualmente Coppia.
- **Tabelle ambiguità** con numero di riga del testo → termine → termine normalizzato.
- **Glossario** dei termini (1453, 1701).
- **Schema diviso per aree** (1453: Account-Character, Item, World, NPC, Game), poi lo schema generale.
- **Vincoli inespressi dichiarati esplicitamente** (1701: "rimane il vincolo inespresso che…"). Da fare sempre.
- **Reificazione per gli storici** (1701: l'acquisto dell'abbonamento diventa un'entità, così un cliente
  può comprare lo stesso tipo più volte). Uguale alla nostra `ASSEGNAZIONE_DIPENDENTE` e `COLLABORAZIONE`.
- **Tavola dei volumi**: `Concetto | Tipo (E/R) | Volume`, con valori coerenti tra loro.
- **Tavola delle operazioni**: `Op | Tipo (I=interattiva, B=batch) | Frequenza`.
- **Tavola degli accessi**: `Concetto | Costrutto | Accessi | Tipo (L/S)`. **Le scritture pesano il doppio**
  (convenzione usata da tutti). Costo totale = frequenza × accessi.
- **Analisi delle ridondanze con calcolo dei costi** con e senza ridondanza, poi la scelta motivata
  (1456: flag `Bio`, mantenuto `Scorte`; 1701: associazione `PossedimentoAttuale`).
- **Eliminazione delle gerarchie motivata** caso per caso (collasso verso l'alto se gli accessi sono
  contestuali, verso il basso se i figli hanno associazioni diverse).
- **Chiave surrogata** quando la chiave composta è troppo lunga e viene importata altrove (1456: `IdDettaglioLavoro`).
- **Notazione relazionale**: `TABELLA(attr, …, attrOpzionale*)` + righe `FK: x REFERENCES Y`, `AK:` per le chiavi alternative.
- **SQL**: `CREATE TABLE` con `CHECK` (domini enumerati, valori ≥ 0), query parametriche con `?`.
- **App**: login semplificato (inserire l'id del dipendente; password solo per l'admin), una schermata per ruolo,
  una classe model + una classe DAO per tabella (1456), oppure un controller per ogni FXML (1701).

### Punti deboli da evitare
- 1453 **salta l'analisi delle ridondanze** ("poco senso") → è una sezione obbligatoria, va fatta.
- 1456 genera gli id con `MAX(id)+1` → usare `AUTO_INCREMENT`/`IDENTITY`.
- 1453 lascia vari vincoli "al gioco" → per noi meglio `CHECK`/trigger o controlli nell'app, documentati.

---

## 4. Il nostro dominio (sintesi della bozza dettagliata)

Un'agenzia di wedding planning segue la coppia dalla prima consulenza fino al post-evento.

- **Coppia**: dati anagrafici, data prevista, budget indicativo. Assegnata a un dipendente/planner con
  **storico assegnazioni** (data inizio/fine, motivo del cambio: malattia, dimissioni, ferie).
- **Dipendente** con **ruolo** (planner senior, assistente, coordinatore on-site, amministrativo); ogni ruolo
  ha un `max_eventi_contemporanei`. **Disponibilità** e **MotivoAssenza** (con flag "remunerata") servono a trovare chi è libero.
- **Evento** (matrimonio ed eventi pre/post): data, budget approvato, invitati previsti/confermati,
  tipo di cerimonia (civile, religiosa, simbolica, all'aperto), stato. Una o più **Location** con orario di inizio e fine.
- **Fornitori** per **categoria** (catering, foto/video, fiori, musica, trasporti, abiti, cake design, celebrante),
  con **storico collaborazioni** e valutazione interna. **Preventivo** (in attesa/accettato/rifiutato) → **Contratto**
  (data firma, importo, acconto, saldo, penali, stato pagamento). L'admin può **bloccare/sbloccare** un fornitore.
- **Invitati** con **Partecipazione** per evento (stato CONFERMATO/RIFIUTATO/IN_ATTESA, allergie, menù,
  trasporto, **tavolo**, **bomboniera**).
- **Timeline** del giorno (attività con orario, durata, luogo, responsabile, stato, nota staff/nota coppia).
- **Checklist** per fase temporale, generata da **TemplateChecklist** + **VoceTemplate** (con `giorni_prima` per calcolare la scadenza).
- **Lista nozze**: Regalo (prezzo, link, negozio, tipologia: soldi/oggetto/donazione, stato), **Prenotazione** da uno o più invitati con quota e messaggio.
- **Comunicazioni** (mittente, oggetto, argomento, allegati) e **Appuntamenti** (in presenza o videocall, resoconto).
- **Portfolio** = *vista* sugli eventi `completato` + **Recensione** (voto, testo, tag stile, stagione) + **Foto**.

### Operazioni previste nella bozza
**Base (11):** registrare la coppia e assegnare il planner · creare l'evento con location/data/budget ·
aggiungere un fornitore e richiedere un preventivo · accettare il preventivo e generare il contratto · aggiungere un invitato e il suo stato ·
aggiornare i tavoli · aggiungere/completare un'attività della checklist · aggiungere/aggiornare un regalo · inserire un'attività nella timeline ·
registrare una comunicazione o un appuntamento · aggiungere l'evento completato al portfolio con la valutazione.

**Statistiche (8):**
1. Fornitori più usati per categoria nell'ultimo anno (numero contratti, importo medio)
2. Scostamento % tra budget approvato e somma dei contratti, per evento attivo (con quelli in sforamento)
3. Planner con più eventi in un periodo
4. Per tipo di cerimonia: budget medio speso, invitati medi, valutazione media
5. Ospiti ricorrenti (> 1 evento) con numero di prenotazioni e totale delle quote
6. Tasso di conversione preventivo → contratto per fornitore (i più bassi)
7. Location più usate per tipo di cerimonia (numero eventi, invitati medi, budget medio)
8. Per tipo di cerimonia: % di attività della checklist scadute e non completate, con le fasi più in ritardo

**Admin (4):** gestire i template della checklist · riassegnare la coppia a un altro planner · bloccare/sbloccare un fornitore ·
riepilogo finanziario annuo (fatturato, numero eventi, margine).

---

## 5. Problemi e Decisioni Ancora Aperti (Da Risolvere)

Tutti i problemi concettuali, di modellazione relazionale e di vincoli di dominio sono stati **definitivamente allineati e risolti** (vedi archivio completo in §6).

L'unico punto operativo aperto riguarda la **Fase 5 (Sviluppo Software)**:
- [ ] **Configurazione e Sviluppo GUI in JavaFX / FXML:** Configurare in `app/build.gradle.kts` il plugin `org.openjfx.javafxplugin` (moduli `javafx.controls`, `javafx.fxml`) per Java 21 su macOS Apple Silicon e implementare le viste FXML (Dashboard Statistiche, Table Planner, Gestione Evento e Planner).

---

## 6. Problemi, Errori e Incoerenze Risolti (Archivio Soluzioni)

Questa sezione archivia tutti i problemi, bug e conflitti di modellazione precedentemente rilevati che sono stati **formalmente risolti e implementati** nei documenti e negli script di progetto.

### 6.1 Unificazione dello Schema Concettuale e Risoluzione Conflitti (ex §5.1)
* **Stato:** **RISOLTO**.
* **Soluzione Adottata:** Eliminata la dicotomia tra Mermaid vecchio e bozza docx. È stata adottata in modo univoco l'architettura a **33 entità con chiavi naturali e identificatori primari coerenti**, formalizzata in:
  - [`md/progettazione-concettuale.md`](md/progettazione-concettuale.md): glossario a 33 termini, tabella ambiguità, dizionario entità e associazioni con cardinalità $(min, max)$.
  - [`md/wedding-planner.md`](md/wedding-planner.md): diagramma Mermaid completo a 33 entità senza box isolati.
  - [`schema.sql`](schema.sql): script DDL ANSI SQL-92 per il reverse engineering pulito in DB-main.

### 6.2 Risoluzione dei 18 Errori Puntuali dello Snippet (ex §5.2)
1. **`DIPENDENTE`:** PK normalizzata su `codice_fiscale` (specializzazione IS-A di `PERSONA`). L'attributo `email_aziendale` è `VARCHAR(100) UNIQUE NOT NULL`. L'email personale risiede in `PERSONA`.
2. **`RUOLO` e `FORNITORE`:** Eliminate le duplicazioni; PK `RUOLO.nome_ruolo` e `FORNITORE.partita_iva`.
3. **`FORNITORE.categoria`:** Rimossa la stringa ridondante in `FORNITORE`; la categoria merceologica è garantita unicamente dalla chiave esterna `nome_categoria REFERENCES CATEGORIA_FORNITORE(nome_categoria)` [V-17].
4. **Chiave Primaria `EVENTO`:** Formalizzata come `(username_coppia, data)`. Chiarita la semantica: `tipo_cerimonia` (civile, religiosa, simbolica) e `tema_stile` (palette e scenografia).
5. **`COPPIA.username`:** Mantenuto come chiave primaria naturale sintetica del soggetto contrattuale committente, referenziando due coniugi distinti con vincolo `CHECK (cf_coniuge1 <> cf_coniuge2)` [V-01].
6. **Stato Invitato vs Partecipazione:** Lo stato dell'invito (`CONFERMATO`, `RIFIUTATO`, `IN_ATTESA`) è collocato **esclusivamente** in `PARTECIPAZIONE(codice_fiscale, username_coppia, data_evento)`. In `INVITATO` risiedono solo i dati anagrafici globali (`rapporto_parentela`, `nucleo_familiare`, `tipologia_bomboniera`).
7. **`INVITATO` con PK `codice_fiscale`:** Censito come sottotipo di `PERSONA` con assunzione di dominio esplicitata.
8. **Foreign Keys in `PARTECIPAZIONE`:** Inclusa la FK `tavolo_nome_numero REFERENCES TAVOLO`. `BOMBONIERA` è collegata a `INVITATO` tramite FK facoltativa `tipologia_bomboniera REFERENCES BOMBONIERA(tipologia)` [V-18].
9. **Ristrutturazione `PRENOTAZIONE` → `QUOTA_REGALO`:** Sostituita con `QUOTA_REGALO(codice_fiscale, username_coppia, data_evento, data_ora)`. La quota è indipendente dalla lista nozze per donazioni monetarie libere (`descrizione_regalo NULLABLE`), ma vincola il donante a essere un invitato dell'evento tramite FK composita su `PARTECIPAZIONE` [V-02].
10. **`ATTIVITA_TIMELINE`:** PK definita come `(username_coppia, data_evento, orario_previsto)` legata a `TIMELINE` ed `EVENTO`.
11. **`ATTIVITA_CHECKLIST`:** Inseriti `scadenza DATE` (calcolata da `EVENTO.data - VOCE_TEMPLATE.giorni_prima_evento`) e `data_completamento DATE NULL` per il calcolo dei ritardi operativi (STAT-07) [V-12].
12. **`VOCE_TEMPLATE`:** Inserito l'attributo `fase_temporale VARCHAR(50) NOT NULL` (ripreso in `ATTIVITA_CHECKLIST`).
13. **`CHECKLIST`:** Definita come entità debole 1:1 con `EVENTO` con PK `(username_coppia, data_evento)` e FK verso `TEMPLATE_CHECKLIST(id_template)`.
14. **`RECENSIONE`:** PK corretta in `(username_coppia, data_evento)` (1:1 da `EVENTO`), con trigger [V-16] che impedisce la recensione se `EVENTO.stato <> 'completato'`.
15. **`APPUNTAMENTO`:** Inserita la FK `dipendente_cf REFERENCES DIPENDENTE` e la FK facoltativa `categoria_assenza REFERENCES MOTIVO_ASSENZA` (obbligatoria con `CHECK` condizionale se `stato = 'annullato'`) [V-09].
16. **`COMUNICAZIONE`:** PK definita da `id_comunicazione AUTO_INCREMENT` con `username_coppia`, `mittente IN ('coppia', 'planner')`, timestamp, canale e testo.
17. **`DISPONIBILITA`:** Collegata a `MOTIVO_ASSENZA(categoria)` con trigger [V-05] di verifica della non-sovrapposizione temporale delle assenze del personale.
18. **`SVOLGIMENTO_EVENTO`:** Creata la relazione ponte tra `EVENTO` e `LOCATION` con PK `(username_coppia, data_evento, nome_location, fascia_oraria)` e attributo `tipo_utilizzo`.

### 6.3 Risoluzione dei Problemi di Modellazione Profondi (ex §5.3)
* **Preventivo 1:N per Evento (non N:M):** Ciascun preventivo è emesso per uno ed un solo evento (`PREVENTIVO.username_coppia, PREVENTIVO.data_evento`), mentre un evento può sollecitare più preventivi concorrenti. Questo rende deterministico e privo di ambiguità il calcolo del budget e dei contratti (STAT-02).
* **Generalizzazione `PERSONA`:** Modellata gerarchia IS-A con radice `PERSONA` (`codice_fiscale`) e sottotipi `DIPENDENTE` e `INVITATO`. Nel logico è stata formalizzata l'eliminazione delle gerarchie per partizione/sostituzione.
* **Ruoli Multipli del Personale:** Implementata reificazione $N:M$ tramite tabella `RUOLO_DIPENDENTE(dipendente_cf, nome_ruolo)`.
* **Fattibilità Query 5 e 8:** Entrambe le interrogazioni sono state formulate in SQL, testate ed eseguite in [`sql/queries.sql`](sql/queries.sql):
  - STAT-07: percentuali di ritardo checklist per fase e modello.
  - STAT-08: ospiti ricorrenti a più matrimoni con somma totale delle quote donate.
* **Stato e Blocco Fornitore:** Armonizzato tramite `FORNITORE.attivo CHAR(1) ('S', 'N')` e storico `COLLABORAZIONE.stato IN ('attiva', 'sospesa', 'cessata')`, con trigger [V-15] che vieta la stipula di contratti con fornitori non attivi.

### 6.4 Analisi Quantitativa delle Ridondanze Risolta (ex §5.4)
* **Stato:** **RISOLTO**.
* Formalizzata nel Capitolo 3 ([`md/progettazione-logica.md`](md/progettazione-logica.md), Sezione 5).
* Calcolo dei costi di lettura ($L=1$) e scrittura ($S=2$) sull'attributo `LISTA_NOZZE.totale_raccolto`: dimostrato un **risparmio annuo di oltre 259.200 accessi (riduzione del 94.7%)**.
* Implementati in [`sql/ddl.sql`](sql/ddl.sql) i trigger atomici (`trg_quota_regalo_after_insert/update/delete`) per il mantenimento automatico e sincronizzato della ridondanza e del flag `REGALO.completato = 'S'`.

### 6.5 Formalizzazione e Implementazione dei Vincoli Inespressi (ex §5.5)
* **Stato:** **RISOLTO**.
* Tutti i 18 vincoli aziendali sono censiti e formalizzati a tre livelli (Concettuale, Logico con `ASSERTION`, Fisico con Trigger MySQL) nel documento dedicato [`md/vincoli-progettazione.md`](md/vincoli-progettazione.md).
* Implementati a livello fisico con messaggi diagnostici `SIGNAL SQLSTATE '45000'` in [`sql/ddl.sql`](sql/ddl.sql).

### 6.6 Setup Esecutivo e Risoluzione Errori Ambiente Software (App Java)
* **Stato:** **RISOLTO**.
* Configurato JDK 21 (OpenJDK 21.0.10) in `gradle.properties`, `gradlew` e `.vscode/settings.json`.
* Risolto errore named pipe Windows su macOS in `DAOUtils.java`, ripristinando la connessione JDBC TCP su porta 3306.
* Risolti i bug di compilazione e mapping nei DAO (`Queries.java`, `Tag.java`, `Material.java`, `Product.java`, `AppTest.java`).
* Eseguita con successo la suite di test (`./gradlew test` al 100% di successi) e avviata regolarmente l'applicazione (`./gradlew run`).
* Risolto errore sintattico KaTeX per underscore non escapati in `md/progettazione-concettuale.md`.

---
### 6.7 Decisioni di Modellazione e Dominio Consolidate (08/11/2026)
* **Ricavi e Fatturato Agenzia:** Adottata la **Semplificazione Accademica**: il fatturato/volume d'affari è misurato dal valore economico complessivo gestito per i matrimoni (somma dei contratti stipulati con i fornitori partner + canoni di affitto location), evitando di appesantire lo schema con la contabilità interna del personale.
* **Responsabile Operativo Timeline e Checklist:** Confermato **esclusivamente un `DIPENDENTE` dell'agenzia** (`dipendente_cf`), che è l'unico operatore accreditato a sistema per la supervisione dei compiti e il coordinamento sul campo.
* **Template Timeline:** **Confermata la gestione diretta per evento** (`TIMELINE` e `ATTIVITA_TIMELINE`). Il pattern a template su 3 livelli è mantenuto per la `CHECKLIST` (dove le scadenze $T - \text{giorni}$ sono standardizzabili per rito), mentre la regia della giornata ha orari assoluti e specifici (luce naturale, orari di culto, disponibilità sede).
* **Tecnologia Interfaccia Grafica:** Scelta **JavaFX / FXML** per l'interfaccia utente finale (con schermate FXML modulari, CSS styling moderno e controller dedicati).
* **Ancoraggio Assegnazione Wedding Planner:** Confermato l'ancoraggio a **`COPPIA`** (`ASSEGNAZIONE_DIPENDENTE`), garantendo il tracciamento storico della coppia fin dalle prime consulenze e la verifica di carico contemporaneo [V-08] sui matrimoni attivi.

---

## 7. Quadro Decisioni Architetturali (Aggiornato)

| # | Tema | Decisione Consolidata | Riferimento Implementativo |
|---|---|---|---|
| 1 | Gruppo | **3 persone** → scope ampio a 33 entità, analisi rigorosa dei volumi e dei costi | `md/progettazione-concettuale.md` |
| 2 | DBMS | **MySQL 8.0 Community Server (Storage Engine InnoDB)** | `md/progettazione-fisica.md`, `sql/ddl.sql` |
| 3 | Consegna | **Metà dicembre 2026**, appello orale/scritto a gennaio 2027 | Calendario didattico UniBo |
| 4 | Architettura App | Java 21 + **JavaFX / FXML** + JDBC puro + Pattern DAO/MVC | Cartella `app/`, FXML Views, `./gradlew run` |
| 5 | Schema ER | **DB-Main** (file `schema.sql` ANSI SQL-92 per estrazione) + Mermaid per documentazione | `schema.sql`, `md/wedding-planner.md` |
| 6 | Gestione Chiavi | **Chiavi naturali/composte** su concettuale e logico; id surrogati solo dove strettamente necessario | `md/progettazione-logica.md` |
| 7 | Preventivo–Evento | **1:N**: ogni preventivo riguarda un solo evento; un evento può avere più preventivi concorrenti | [V-14] in `md/vincoli-progettazione.md` |
| 8 | Assegnazione dipendente | Legata a **Coppia** con storico `[data_inizio, data_fine]`, `motivo_cambio` e flag `attiva` | [V-06, V-07, V-08] in `sql/ddl.sql` |
| 9 | Ruoli dipendente | **Reificazione N:M** tramite tabella `RUOLO_DIPENDENTE` | `sql/ddl.sql` |
| 10 | Dominio Agenzia | L'ER modella una sola agenzia; nessuna entità superflua AGENZIA | `md/progettazione-concettuale.md` |
| 11 | Lista nozze e quote | `QUOTA_REGALO` indipendente dalla lista (ammessi doni liberi), vincolata agli invitati | [V-02, V-03] in `md/vincoli-progettazione.md` |
| 12 | Gerarchia Persone | Radice `PERSONA` (PK `codice_fiscale`), sottotipi `DIPENDENTE` e `INVITATO`, coppia su 2 persone | `md/progettazione-logica.md` |
| 13 | Template Checklist | Pattern su 3 livelli: `TEMPLATE_CHECKLIST` → `VOCE_TEMPLATE` → `ATTIVITA_CHECKLIST` | [V-12] in `sql/ddl.sql` |

---

## 8. Note di modellazione

### PERSONA e COPPIA
- `PERSONA(CF, nome, cognome, email, telefono, …)` con sottotipi **DIPENDENTE**, **CONIUGE**, **INVITATO**.
  Gerarchia **totale e sovrapposta (t, o)**: la stessa persona può essere invitata a più matrimoni (ospiti ricorrenti),
  un coniuge può essere stato invitato in passato, un dipendente può essere invitato.
- **COPPIA** è un'entità (ha molte associazioni: eventi, comunicazioni, appuntamenti) con **due associazioni distinte**
  verso CONIUGE: `coniuge1 (1,1)` e `coniuge2 (1,1)`. Identificatore esterno = `(CF_coniuge1, CF_coniuge2)`.
  Nomi neutri (coniuge1/2, non sposo/sposa).
  - Vincoli inespressi: `CF_coniuge1 ≠ CF_coniuge2`; per evitare il doppione (A,B)/(B,A) imporre `CF_coniuge1 < CF_coniuge2`.
  - Alternativa scartata: un'unica associazione "composta da" con cardinalità (2,2) lato coppia. È elegante in ER,
    ma nel relazionale "esattamente 2" non è esprimibile e la coppia resta senza chiave naturale.
- Eliminazione della gerarchia (da motivare con gli accessi nella fase logica), ipotesi:
  - CONIUGE e INVITATO hanno pochi attributi propri → **collasso verso l'alto** in PERSONA (le partecipazioni e i dati
    per evento stanno già in PARTECIPAZIONE).
  - DIPENDENTE ha molti attributi e associazioni proprie → **sostituzione con associazione** (tabella DIPENDENTE con PK = CF che referenzia PERSONA).
  - Il collasso verso il basso è sconsigliato perché la gerarchia è sovrapposta (duplicherebbe i dati anagrafici).
- Con le chiavi naturali, PK di PERSONA = **CF** → serve il CF anche degli invitati (accettabile nel dominio, va scritto tra le assunzioni).

---

## 9. Bozza ER in DB-Main (`er/wedding-planner.lun`, 06/11/2026)

Generata con `er/generatore/genera.sh` tramite JIDBM, l'API Java ufficiale di DB-Main (in `/opt/dbmain/bin/jidbm.jar`).
Da qui in poi **si modifica in DB-Main**: rilanciare il generatore sovrascrive le modifiche fatte a mano.
Note tecniche: JIDBM non sa creare un progetto da zero e il suo loader XML va in crash, quindi il generatore parte
dall'esempio `VOLS.LUN`, ne cancella lo schema e poi corregge il nome del progetto direttamente nel file `.lun`.

### Aree (impaginazione)
- **In alto a sinistra:** personale (DIPENDENTE, RUOLO, ASSENZA, MOTIVO_ASSENZA, ASSEGNAZIONE).
- **In alto al centro:** PERSONA con i sottotipi, COPPIA, COMUNICAZIONE, APPUNTAMENTO.
- **Al centro:** EVENTO, LOCATION, PREVENTIVO.
- **A destra:** invitati (PARTECIPAZIONE, TAVOLO, BOMBONIERA) e lista nozze (LISTA_NOZZE, REGALO).
- **In basso a sinistra:** fornitori (CATEGORIA_FORNITORE, FORNITORE, COLLABORAZIONE, CONTRATTO).
- **In basso al centro:** template di checklist e timeline, con TIPO_CERIMONIA.
- **In basso a destra:** portfolio (RECENSIONE, FOTO).

### Scelte fatte nella bozza (da confermare)
- **Niente entità CHECKLIST e TIMELINE** (avevano solo delle note): le attività sono legate direttamente a EVENTO.
- **Pattern a template su tre livelli:** TEMPLATE → VOCE → ATTIVITA, sia per la checklist sia per la timeline (**la timeline è una proposta**).
  I template sono legati a **TIPO_CERIMONIA**, che ora è un'entità (prima era una stringa).
- **ASSEGNAZIONE** collega DIPENDENTE ed EVENTO e indica **con quale RUOLO**, così più figure possono seguire lo stesso evento.
  Identificatore: (dipendente, evento, data_inizio).
- **DISPONIBILITA rinominata ASSENZA**: registra i periodi in cui il dipendente non è disponibile.
- **Blocco del fornitore** = una COLLABORAZIONE con stato `sospesa`. Il flag `FORNITORE.attivo` è stato tolto.
- **prenotazione** è un'associazione N:M tra INVITATO e REGALO con attributi (quota, messaggio, data, stato).
  Vincolo inespresso: l'invitato deve avere una PARTECIPAZIONE all'evento della lista.
- **ATTIVITA_TIMELINE:** il responsabile è *esattamente uno* tra dipendente e fornitore (gruppo `RESP` con vincolo di esclusione + almeno-uno).
- **Materiale per la progettazione logica già presente:**
  - attributo composto: `LOCATION.indirizzo`;
  - attributi multivalore: `servizi_inclusi`, `allergie`, `allegati`, `tag_stile`;
  - gerarchia PERSONA (t, o);
  - ridondanze: `n_invitati_confermati`, `totale_raccolto`, `valutazione_interna`, `saldo`, `stagione`.
- **Ricavi dell'agenzia (proposta):** l'agenzia guadagna in due modi.
  1. **Compenso dalla coppia.** PACCHETTO è il catalogo dei servizi dell'agenzia (organizzazione completa, parziale,
     coordinamento del giorno), con un prezzo base e le categorie di fornitori che coordina (`include`).
     INCARICO è il contratto agenzia–coppia per un evento (1:1), con il pacchetto scelto e il `compenso_pattuito`.
     PAGAMENTO contiene i versamenti della coppia (acconto, rate, saldo).
  2. **Provvigione dai fornitori:** `CONTRATTO.commissione_agenzia` [0-1].
  - Riepilogo finanziario annuo: fatturato = SUM(PAGAMENTO.importo) dell'anno + SUM(commissione_agenzia) dei contratti firmati
    nell'anno; poi numero di eventi e compenso medio. Un "margine" vero richiederebbe i costi (es. stipendi), che non sono modellati:
    proposta di riformulare l'operazione come "ricavi per anno, divisi tra compensi e provvigioni".
  - Ridondanza candidata: un `totale_versato` su INCARICO (derivabile da PAGAMENTO).
- **Orari:** DB-Main non ha un tipo "time", quindi orari e date-ora usano il tipo data.
- **Attenzione alle chiavi naturali a cascata:** la chiave di EVENTO è (CF_coniuge1, CF_coniuge2, data) e si propaga a
  PARTECIPAZIONE, TAVOLO, REGALO, ATTIVITA_*, … Nel logico vanno valutati i costi (chiavi esterne di 3-4 colonne).
