# Vincoli di Integrità e Regole di Progettazione
## Guida Completa per la Progettazione Concettuale, Logica e Fisica/Applicativa
**Progetto di Basi di Dati — Università di Bologna (Prof. D. Maio, Prof.ssa A. Franco)**

---

## 1. Quadro Metodologico dei Vincoli di Integrità

Nello sviluppo di una base di dati, i vincoli di dominio e le regole aziendali attraversano tre livelli di astrazione successivi:

1. **Livello Concettuale (Modello E/R):**
   - **Vincoli Grafici:** Esprimibili direttamente mediante costrutti visuali: identificatori primari (chiavi naturali o esterne per entità deboli), cardinalità minime e massime dei ruoli $(min, max)$, cardinalità degli attributi $(0,1)$ o $(1,1)$, e gerarchie di specializzazione (IS-A totale/parziale, esclusiva/sovrapposta).
   - **Vincoli Non Esprimibili Graficamente (Regole Aziendali):** Vincoli semantici complessi, temporali o di aggregazione che non possono essere disegnati nello schema e vanno formalizzati testualmente con precisione matematica.
2. **Livello Logico (Modello Relazionale):**
   - **Vincoli Strutturali DDL:** `PRIMARY KEY`, `FOREIGN KEY` (integrità referenziale), `NOT NULL`, `UNIQUE`.
   - **Vincoli di Tupla/Tabella:** Clausole `CHECK` (predicati booleani che operano su colonne della singola riga).
   - **Vincoli Inter-Relazionali / Aggregati:** Nella teoria dello standard SQL si formalizzano come **`CREATE ASSERTION`** (asserzioni a livello di schema). Poiché la quasi totalità dei DBMS reali (MySQL, PostgreSQL) non implementa `ASSERTION`, nella progettazione logica si documenta la formulazione teorica dell'asserzione specificando che verrà implementata a livello fisico.
3. **Livello Fisico e Software Applicativo (SQL DDL / Trigger / Java DAO):**
   - **Vincoli Fisici e Trigger SQL:** Trigger procedurali `BEFORE INSERT / BEFORE UPDATE` che sollevano eccezioni con `SIGNAL SQLSTATE '45000'` per abortire transazioni che violano i vincoli inter-tabella o temporali.
   - **Viste di Controllo (Views):** Viste analitiche per monitorare scostamenti (es. budget, ritardi).
   - **Business Logic e Transazioni ACID (Java):** Verifiche preventive a livello di controller/service applicativo con gestione della concorrenza (`TRANSACTION ISOLATION LEVEL READ COMMITTED / SERIALIZABLE`).

---

## 2. Trattazione Dettagliata dei Vincoli di Dominio

---

### [V-01] Composizione della Coppia da Due Coniugi Distinti
* **Descrizione di Dominio:** Una coppia committente è un soggetto contrattuale composito formato da esattamente due persone fisiche censite, le quali devono essere soggetti distinti.
* **Progettazione Concettuale (E/R):**
  - Entità coinvolte: `COPPIA` e `PERSONA`.
  - Associazione binaria `CONIUGI`: `COPPIA (2, 2) -- (0, 1) PERSONA`.
  - Vincolo non grafico: I due componenti collegati alla medesima coppia devono avere identificatori differenti:
    $$\text{Coniuge}_1 \neq \text{Coniuge}_2$$
* **Progettazione Logica (Relazionale):**
  - Poiché la cardinalità per Coppia è fissa a 2, si inseriscono due chiavi esterne non nulle nella relazione `COPPIA`:
    $$\text{COPPIA}(\underline{\text{username}}, \text{data\_prevista}, \text{budget\_indicativo}, \text{cf\_coniuge1}, \text{cf\_coniuge2})$$
  - Vincoli DDL:
    - `FOREIGN KEY (cf_coniuge1) REFERENCES PERSONA(codice_fiscale) NOT NULL`
    - `FOREIGN KEY (cf_coniuge2) REFERENCES PERSONA(codice_fiscale) NOT NULL`
    - `CHECK (cf_coniuge1 <> cf_coniuge2)`
* **Progetto Fisico / Applicativo:**
  - Nativamente gestito dal DBMS via DDL.
  - Livello Java: Validazione a form (`!coniuge1.getCf().equals(coniuge2.getCf())`).

---

### [V-02] Indipendenza della Quota Regalo e Vincolo di Invito all'Evento
* **Descrizione di Dominio:** Gli ospiti possono versare una quota monetaria / donazione per gli sposi. La quota è indipendente dall'esistenza o meno di una lista nozze fisica (può essere una donazione libera o legata a un dono specifico), ma il donante **deve obbligatoriamente essere una persona invitata all'evento**.
* **Progettazione Concettuale (E/R):**
  - Entità: `QUOTA_REGALO`, `INVITATO`, `EVENTO`, `REGALO` (opzionale).
  - Associazioni:
    - `INVITATO (0, N) -- (1, 1) QUOTA_REGALO` (chi dona è un invitato).
    - `EVENTO (0, N) -- (1, 1) QUOTA_REGALO` (la quota è devoluta per un evento).
    - `REGALO (0, N) -- (0, 1) QUOTA_REGALO` (la quota può facoltativamente essere destinata a una voce di regalo, oppure essere libera/busta se `(0, 1)`).
  - Vincolo non grafico: L'invitato che effettua la quota deve risultare tra gli invitati dello specifico evento:
    $$\exists p \in \text{PARTECIPAZIONE} : p.\text{Invitato} = \text{QUOTA\_REGALO.Invitato} \land p.\text{Evento} = \text{QUOTA\_REGALO.Evento}$$
* **Progettazione Logica (Relazionale):**
  - Tabella `QUOTA_REGALO`:
    $$\text{QUOTA\_REGALO}(\underline{\text{codice\_fiscale}, \text{username\_coppia}, \text{data\_evento}, \text{data\_ora}}, \text{importo}, \text{messaggio}, \text{metodo}, \text{stato}, \text{descrizione\_regalo})$$
  - Chiavi Esterne:
    - `(codice_fiscale, username_coppia, data_evento) REFERENCES PARTECIPAZIONE(codice_fiscale, username_coppia, data_evento)` $ightarrow$ **Garantisce a livello strutturale che chi dona è invitato a quell'evento!**
    - `(username_coppia, data_evento, descrizione_regalo) REFERENCES REGALO(username_coppia, data_evento, descrizione)` con `descrizione_regalo NULLABLE` $ightarrow$ Consente quote libere slegate da regali fisici.
* **Progetto Fisico / Applicativo:**
  - Garantito dall'integrità referenziale composita delle Foreign Key in SQL.
  - Query statistica STAT-08 (Ospiti ricorrenti): Immediata tramite `GROUP BY codice_fiscale HAVING COUNT(DISTINCT evento) > 1` con `SUM(importo)`.

---

### [V-03] Ortogonalità tra Partecipazione Fisica (RSVP) e Donazione Quota
* **Descrizione di Dominio:** Un invitato può partecipare al matrimonio e fare il regalo, partecipare e non fare il regalo, non partecipare e fare il regalo, oppure non partecipare e non fare il regalo.
* **Progettazione Concettuale (E/R):**
  - Entità: `INVITATO`, `PARTECIPAZIONE`, `QUOTA_REGALO`.
  - Cardinalità:
    - `INVITATO (0, N) -- (1, 1) PARTECIPAZIONE`: L'invitato riceve un invito all'evento con `stato` $\in \{\text{'CONFERMATO'}, \text{'RIFIUTATO'}, \text{'IN\_ATTESA'}\}$.
    - `INVITATO (0, N) -- (1, 1) QUOTA_REGALO`: L'invitato può registrare $0$ o più donazioni per l'evento, indipendentemente dallo `stato` della sua presenza fisica.
* **Progettazione Logica (Relazionale):**
  - Due tabelle separate: `PARTECIPAZIONE` (traccia la presenza al banchetto, intolleranze alimentari, allergie, tavolo) e `QUOTA_REGALO` (traccia i movimenti finanziari dei doni).
  - Nessun vincolo `CHECK` impedisce a una partecipazione con stato `'RIFIUTATO'` di avere tuple collegate in `QUOTA_REGALO`.
* **Progetto Fisico / Applicativo:**
  - Il portale ospiti presenta due sezioni indipendenti: "Conferma Presenza (RSVP)" e "Fai un Regalo agli Sposi / Dona Quota".

---

### [V-04] Plafond e Tipologie di Frazionamento dei Regali della Lista Nozze
* **Descrizione di Dominio:** I regali della lista nozze possono essere a pezzo unico indivisibile (`INTERO`) oppure a quote (`QUOTE_LIBERE` o `QUOTE_FISSE`). La somma delle quote destinate a un regalo non può superare il suo prezzo.
* **Progettazione Concettuale (E/R):**
  - Attributo `REGALO.tipo_frazionamento` $\in \{\text{'INTERO'}, \text{'QUOTE\_LIBERE'}, \text{'QUOTE\_FISSE'}\}$.
  - Vincolo non grafico:
    $$\sum_{q \in \text{QUOTA\_REGALO destinata a } r} q.\text{importo} \le r.\text{prezzo}$$
    Se $r.\text{tipo\_frazionamento} = \text{'INTERO'}$, può esistere al massimo $1$ quota con $\text{importo} = r.\text{prezzo}$.
* **Progettazione Logica (Relazionale):**
  - Vincolo aggregato inter-tabella. Formulazione teorica in `ASSERTION`:
    ```sql
    CREATE ASSERTION assert_plafond_regalo CHECK (
      NOT EXISTS (
        SELECT username_coppia, data_evento, descrizione_regalo
        FROM QUOTA_REGALO
        WHERE descrizione_regalo IS NOT NULL
        GROUP BY username_coppia, data_evento, descrizione_regalo
        HAVING SUM(importo) > (
          SELECT prezzo FROM REGALO 
          WHERE REGALO.username_coppia = QUOTA_REGALO.username_coppia
            AND REGALO.data_evento = QUOTA_REGALO.data_evento
            AND REGALO.descrizione = QUOTA_REGALO.descrizione_regalo
        )
      )
    );
    ```
* **Progetto Fisico / Applicativo:**
  - **Trigger SQL `BEFORE INSERT` su `QUOTA_REGALO`:** Verifica che se `descrizione_regalo IS NOT NULL`, la somma delle quote versate precedentemente più `NEW.importo` non ecceda il prezzo del regalo e rispetti il tipo di frazionamento, altrimenti esegue `SIGNAL SQLSTATE '45000'`.

---

### [V-05] Disgiunzione degli Intervalli di Assenza del Personale (`DISPONIBILITA`)
* **Descrizione di Dominio:** Per ciascun dipendente, due intervalli di assenza (ferie, malattia, permesso) non possono sovrapporsi temporalmente.
* **Progettazione Concettuale (E/R):**
  - Entità `DISPONIBILITA` con attributi `data_inizio` e `data_fine`.
  - Vincolo non grafico: Per ogni dipendente $d$, non esistono due tuple $I_1, I_2 \in \text{DISPONIBILITA}(d)$ tali che:
    $$I_1.\text{data\_inizio} \le I_2.\text{data\_fine} \land I_2.\text{data\_inizio} \le I_1.\text{data\_fine}$$
* **Progettazione Logica (Relazionale):**
  - Su singola tupla: `CHECK (data_inizio <= data_fine)`.
  - Sulle tuple multiple: Asserzione teorica:
    ```sql
    CREATE ASSERTION assert_no_overlap_disponibilita CHECK (
      NOT EXISTS (
        SELECT 1 FROM DISPONIBILITA d1, DISPONIBILITA d2
        WHERE d1.dipendente_cf = d2.dipendente_cf
          AND d1.data_inizio < d2.data_inizio
          AND d1.data_fine >= d2.data_inizio
      )
    );
    ```
* **Progetto Fisico / Applicativo:**
  - **Trigger SQL `BEFORE INSERT / UPDATE` su `DISPONIBILITA`:** Controlla con una `SELECT COUNT(*)` l'assenza di sovrapposizioni per lo stesso dipendente.
  - Livello applicativo: Calendario interattivo nel gestionale che evidenzia in rosso i giorni già impegnati.

---

### [V-06] Storicizzazione e Avvicendamento del Wedding Planner (`ASSEGNAZIONE_DIPENDENTE`)
* **Descrizione di Dominio:** Non sempre c'è lo stesso wedding planner: per motivi sopravvenuti (es. malattia prolungata, dimissioni, licenziamento, maternità o riorganizzazione aziendale) il planner può cambiare da una certa data in poi. Lo storico tiene traccia delle date e della motivazione formale del cambio.
* **Progettazione Concettuale (E/R):**
  - Entità reificata `ASSEGNAZIONE_DIPENDENTE` tra `COPPIA` e `DIPENDENTE`.
  - Attributi: `data_inizio`, `data_fine` (opzionale), `motivo_cambio` (es. "Malattia prolungata", "Dimissioni", "Maternità", "Riassegnazione"), `attiva` (booleano).
  - Vincolo non grafico: La data dell'evento della coppia deve cadere all'interno del periodo di un'assegnazione attiva o valida.
* **Progettazione Logica (Relazionale):**
  - Relazione:
    $$\text{ASSEGNAZIONE\_DIPENDENTE}(\underline{\text{username\_coppia}, \text{dipendente\_cf}, \text{data\_inizio}}, \text{data\_fine}, \text{motivo\_cambio}, \text{attiva})$$
  - Vincolo intra-tupla: `CHECK (data_fine IS NULL OR data_inizio <= data_fine)`.
* **Progetto Fisico / Applicativo:**
  - Procedura di cambio planner: Transazione applicativa che chiude l'assegnazione corrente (`SET data_fine = CURRENT_DATE, attiva = 'N', motivo_cambio = ?`) e inserisce contestualmente la nuova assegnazione con `attiva = 'S'`.

---

### [V-07] Unicità dell'Assegnazione Attiva per Coppia
* **Descrizione di Dominio:** In ogni istante temporale, per ciascuna coppia committente, può esistere al massimo un'unica assegnazione attiva (`attiva = 'S'`).
* **Progettazione Concettuale (E/R):**
  - Vincolo non grafico su `ASSEGNAZIONE_DIPENDENTE`.
* **Progettazione Logica (Relazionale):**
  - Asserzione teorica:
    ```sql
    CREATE ASSERTION assert_unica_assegnazione_attiva CHECK (
      NOT EXISTS (
        SELECT username_coppia FROM ASSEGNAZIONE_DIPENDENTE
        WHERE attiva = 'S'
        GROUP BY username_coppia
        HAVING COUNT(*) > 1
      )
    );
    ```
* **Progetto Fisico / Applicativo:**
  - Trigger `BEFORE INSERT / UPDATE` che rifiuta l'inserimento se esiste già una riga con `attiva = 'S'` per la medesima coppia.

---

### [V-08] Limite Massimo di Eventi Contemporanei per Dipendente
* **Descrizione di Dominio:** Un planner non può gestire contemporaneamente più eventi attivi di quanti consentiti dai ruoli che ricopre nell'agenzia.
* **Progettazione Concettuale (E/R):**
  - Vincolo non grafico:
    $$\text{COUNT}(\text{Assegnazioni attive di } d) \le \max_{r \in \text{Ruoli}(d)} (r.\text{MaxEventiContemporanei})$$
* **Progettazione Logica (Relazionale):**
  - Asserzione teorica multi-tabella tra `ASSEGNAZIONE_DIPENDENTE`, `RUOLO_DIPENDENTE` e `RUOLO`.
* **Progetto Fisico / Applicativo:**
  - Trigger SQL su `ASSEGNAZIONE_DIPENDENTE` e logica visuale applicativa che disabilita il planner saturo nelle dropdown.

---

### [V-09] Giustificativo di Assenza o Annullamento degli Appuntamenti (`APPUNTAMENTO`)
* **Descrizione di Dominio:** Gli incontri tra planner e coppia possono essere svolti, annullati o riprogrammati. Se l'appuntamento salta per assenza di una delle parti, viene registrato il motivo codificato da `MOTIVO_ASSENZA`.
* **Progettazione Concettuale (E/R):**
  - Entità `APPUNTAMENTO` collegata a `COPPIA`, `DIPENDENTE` e facoltativamente a `MOTIVO_ASSENZA`.
  - Associazione `GIUSTIFICATIVO_APP`: `APPUNTAMENTO (0, 1) -- (0, N) MOTIVO_ASSENZA`.
  - Attributi di appuntamento: `stato` $\in \{\text{'confermato'}, \text{'svolto'}, \text{'annullato'}, \text{'riprogrammato'}\}$.
* **Progettazione Logica (Relazionale):**
  - Tabella `APPUNTAMENTO`:
    $$\text{APPUNTAMENTO}(\underline{\text{username\_coppia}, \text{data\_ora}}, \text{dipendente\_cf}, \text{categoria\_assenza}, \text{luogo\_modalita}, \text{durata}, \text{resoconto}, \text{stato})$$
  - `FOREIGN KEY (categoria_assenza) REFERENCES MOTIVO_ASSENZA(categoria)` (campo `NULLABLE`, valorizzato obbligatoriamente se `stato = 'annullato'`).
  - `CHECK (stato <> 'annullato' OR categoria_assenza IS NOT NULL)`.
* **Progetto Fisico / Applicativo:**
  - Gestito dal vincolo `CHECK` a livello DDL. Nella UI, se l'utente clicca "Annulla incontro", compare il menu a tendina obbligatorio del motivo assenza.

---

### [V-10] Capienza Totale e Singola dei Tavoli rispetto ai Partecipanti
* **Descrizione di Dominio:** Il numero totale di partecipanti confermati deve essere divisibile tra i tavoli allestiti per l'evento, la cui somma delle sedute deve essere maggiore o uguale ai partecipanti effettivi. Inoltre, nessun tavolo può superare la propria capienza.
* **Progettazione Concettuale (E/R):**
  - Vincoli non grafici:
    $$\sum_{t \in \text{Tavoli}(e)} t.\text{Capienza} \ge e.\text{NInvitatiConfermati}$$
    $$\forall t \in \text{Tavoli}(e) : \text{COUNT}(\text{Partecipazioni sedute a } t) \le t.\text{Capienza}$$
* **Progettazione Logica (Relazionale):**
  - Asserzioni teoriche `CHECK`.
* **Progetto Fisico / Applicativo:**
  - Trigger SQL su `PARTECIPAZIONE` al momento dell'assegnazione di `tavolo_nome_numero`.
  - Schermata gestionale Java "Table Planner" che impedisce il drag-and-drop dell'ospite se il tavolo è esaurito.

---

### [V-11] Assegnazione Tavolo Riservata ai Soli Partecipanti Confermati
* **Descrizione di Dominio:** Non è possibile assegnare un posto al tavolo a un invitato la cui presenza sia in attesa o rifiutata.
* **Progettazione Concettuale (E/R):**
  - Associazione `SEDUTA` tra `PARTECIPAZIONE` e `TAVOLO`.
  - Vincolo non grafico: L'associazione è consentita solo per tuple con $\text{PARTECIPAZIONE.stato} = \text{'CONFERMATO'}$.
* **Progettazione Logica (Relazionale):**
  - Nella tabella `PARTECIPAZIONE`:
    $$\text{CHECK (tavolo\_nome\_numero IS NULL OR stato = 'CONFERMATO')}$$
* **Progetto Fisico / Applicativo:**
  - Garantito **immediatamente e nativamente** dalla clausola `CHECK` di riga in SQL DDL.

---

### [V-12] Calcolo Deterministico Scadenza Checklist e Misura dei Ritardi
* **Descrizione di Dominio:** Le scadenze operative sono calcolate dai giorni di anticipo del template ($	ext{DataEvento} - 	ext{GiorniPrima}$). La data effettiva di completamento permette di misurare oggettivamente i ritardi accumulati.
* **Progettazione Concettuale (E/R):**
  - Entità `ATTIVITA_CHECKLIST` con attributi `scadenza` e `data_completamento` (opzionale).
  - Vincolo non grafico: $\text{Scadenza} \le \text{EVENTO.Data}$.
  - Definizione metrica di ritardo: $\text{DataCompletamento} > \text{Scadenza}$.
* **Progettazione Logica (Relazionale):**
  - `CHECK (scadenza <= data_evento)` in `ATTIVITA_CHECKLIST`.
* **Progetto Fisico / Applicativo:**
  - Procedura di inserimento checklist: valorizza `scadenza = DATE_SUB(data_evento, INTERVAL giorni_prima DAY)`.
  - Query statistica STAT-07: calcolo percentuale ritardi con aggregazione SQL.

---

### [V-13] Sequenzialità Oraria e Non-Sovrapposizione della Timeline
* **Descrizione di Dominio:** Tutte le attività orarie della timeline devono svolgersi all'interno della giornata dell'evento. Non possono essere programmate due attività simultanee nella stessa sala o con lo stesso coordinatore di staff responsabile.
* **Progettazione Concettuale (E/R):**
  - Entità `ATTIVITA_TIMELINE` identificata da `{TIMELINE, orario_previsto}` con attributo `durata_minuti`.
  - Vincolo non grafico: Disgiunzione temporale degli intervalli orari per location e per dipendente coordinatore.
* **Progettazione Logica (Relazionale):**
  - Asserzione teorica inter-tupla.
* **Progetto Fisico / Applicativo:**
  - Trigger SQL `BEFORE INSERT / UPDATE` su `ATTIVITA_TIMELINE` che verifica sovrapposizioni su $[\text{orario}, \text{orario} + \text{durata}]$.

---

### [V-14] Unicità dell'Evento per Preventivo e Pluralità dei Preventivi per Evento (1:N)
* **Descrizione di Dominio:** Ogni preventivo emesso da un fornitore fa riferimento ad un unico, specifico evento. A sua volta, ciascun evento può richiedere molteplici preventivi a fornitori diversi o concorrenti per confrontare le offerte.
* **Progettazione Concettuale (E/R):**
  - Associazione `RICHIESTA_PREV`: `EVENTO (0, N) -- (1, 1) PREVENTIVO`.
  - Attributo opzionale `data_scadenza` `(0, 1)` in `PREVENTIVO`.
* **Progettazione Logica (Relazionale):**
  - Tabella `PREVENTIVO` con chiave esterna diretta non nulla:
    $$\text{FOREIGN KEY (username\_coppia, data\_evento) REFERENCES EVENTO(username\_coppia, data) NOT NULL}$$
* **Progetto Fisico / Applicativo:**
  - Nativamente gestito dall'integrità referenziale relazionale DDL.

---

### [V-15] Cronologia Contrattuale e Validità del Fornitore
* **Descrizione di Dominio:** $	ext{DataEmissionePreventivo} \le 	ext{DataFirmaContratto} \le 	ext{DataEvento}$. Inoltre, il fornitore deve avere una convenzione attiva (`COLLABORAZIONE.stato = 'attiva'`) e flag globale `attivo = 'S'`.
* **Progettazione Concettuale (E/R):**
  - Vincoli temporali e di stato non grafici.
* **Progettazione Logica (Relazionale):**
  - Su singola tupla preventivo: `CHECK (data_scadenza IS NULL OR data_emissione <= data_scadenza)`.
  - Tra preventivo, contratto ed evento: Asserzione teorica.
* **Progetto Fisico / Applicativo:**
  - Trigger `BEFORE INSERT` su `CONTRATTO` che valida le date rispetto a `PREVENTIVO` ed `EVENTO`.

---

### [V-16] Recensione Rilasciabile Solo a Evento Concluso
* **Descrizione di Dominio:** La coppia può recensire il matrimonio solo dopo che esso è stato formalmente completato, con data recensione $\ge$ data evento.
* **Progettazione Concettuale (E/R):**
  - Associazione 1:1 `RILASCIO_REC` tra `EVENTO (0, 1)` e `RECENSIONE (1, 1)`.
  - Vincolo non grafico: $\text{EVENTO.stato} = \text{'completato'} \land \text{RECENSIONE.data} \ge \text{EVENTO.data}$.
* **Progettazione Logica (Relazionale):**
  - Asserzione teorica.
* **Progetto Fisico / Applicativo:**
  - Trigger SQL `BEFORE INSERT` su `RECENSIONE` che legge lo stato dell'evento.
  - Livello applicativo: Il bottone "Lascia Recensione" è visibile agli sposi solo se lo stato dell'evento è completato.

---

### [V-17] Classificazione Obbligatoria del Fornitore nella Categoria Merceologica
* **Descrizione di Dominio:** Ciascun fornitore deve appartenere ad una ed una sola categoria merceologica (catering, foto/video, musica, ecc.).
* **Progettazione Concettuale (E/R):**
  - Associazione `CATEGORIZZAZIONE`: `CATEGORIA_FORNITORE (1, N) -- (1, 1) FORNITORE`.
* **Progettazione Logica (Relazionale):**
  - Tabella `FORNITORE` con colonna `nome_categoria VARCHAR(50) NOT NULL REFERENCES CATEGORIA_FORNITORE(nome_categoria)`.
* **Progetto Fisico / Applicativo:**
  - Nativamente gestito da Foreign Key non nulla.

---

### [V-18] Destinazione delle Bomboniere agli Invitati
* **Descrizione di Dominio:** Le bomboniere sono catalogate per tipologia (testimoni, genitori, ospiti generici). A ciascun invitato può essere destinata una tipologia di bomboniera.
* **Progettazione Concettuale (E/R):**
  - Associazione `OMAGGIO`: `BOMBONIERA (0, N) -- (0, 1) INVITATO`.
* **Progettazione Logica (Relazionale):**
  - Tabella `INVITATO` con colonna `tipologia_bomboniera VARCHAR(50) NULL REFERENCES BOMBONIERA(tipologia)`.
* **Progetto Fisico / Applicativo:**
  - Nativamente gestito da Foreign Key facoltativa.

---

## 3. Matrice Sinottica di Mappatura dei Vincoli

| ID Vincolo | Denominazione Sintetica | Espressione Concettuale (E/R) | Espressione Logica (Relazionale) | Implementazione Fisica / Applicativa |
| :--- | :--- | :--- | :--- | :--- |
| **V-01** | Due Coniugi Distinti per Coppia | Associazione `CONIUGI (2,2)` + Vincolo non grafico | 2 FK NOT NULL + `CHECK (cf1 <> cf2)` | DDL Constraint nativo |
| **V-02** | Quota riservata ad Invitato dell'Evento | Associazione `QUOTA_REGALO` a `INVITATO` ed `EVENTO` | FK composita verso `PARTECIPAZIONE` | Foreign Key composita SQL |
| **V-03** | Ortogonalità RSVP e Donazione | Entità distinte `PARTECIPAZIONE` e `QUOTA_REGALO` | Tabelle distinte senza blocchi incrociati | Funzionalità UI indipendenti |
| **V-04** | Plafond Prezzo Regalo e Indivisibilità | Vincolo aggregato non grafico: $\sum q \le prezzo$ | Asserzione teorica `ASSERTION` | **Trigger SQL `BEFORE INSERT`** |
| **V-05** | Disgiunzione Date Assenze Personale | Vincolo temporale non grafico su `DISPONIBILITA` | `CHECK (d_ini <= d_fine)` + `ASSERTION` | **Trigger SQL `BEFORE INSERT/UPDATE`** |
| **V-06** | Storicizzazione Cambio Wedding Planner | Entità reificata `ASSEGNAZIONE_DIPENDENTE` | Tabella storico con date e `motivo_cambio` | Transazione Java cambio planner |
| **V-07** | Unica Assegnazione Attiva per Coppia | Vincolo non grafico su tupla attiva | Asserzione teorica `ASSERTION` | **Trigger SQL `BEFORE INSERT/UPDATE`** |
| **V-08** | Limite Eventi Contemporanei Planner | Vincolo non grafico: $count \le max$ | Asserzione teorica `ASSERTION` | **Trigger SQL** + Filtro dropdown UI |
| **V-09** | Giustificativo Assenza ad Appuntamenti | Associazione a `MOTIVO_ASSENZA` | FK a `MOTIVO_ASSENZA` + `CHECK` condizionale | DDL Constraint + Form annullamento |
| **V-10** | Capienza Tavoli $\ge$ Partecipanti | Vincolo non grafico: $\sum cap \ge confermati$ | Asserzione teorica `ASSERTION` | **Trigger SQL** + Validazione UI Tavoli |
| **V-11** | Seduta Tavolo solo per RSVP Confermato | Vincolo non grafico su associazione `SEDUTA` | `CHECK (tavolo IS NULL OR stato = 'CONFERMATO')` | DDL Constraint nativo |
| **V-12** | Scadenza Deterministica e Misura Ritardi | Vincolo calcolato: $scadenza = data - giorni$ | `CHECK (scadenza <= data_evento)` | Procedura inserimento + Query STAT-07 |
| **V-13** | Sequenzialità Oraria Timeline | Vincolo orario non grafico: no sovrapposizioni | Asserzione teorica `ASSERTION` | **Trigger SQL `BEFORE INSERT/UPDATE`** |
| **V-14** | Preventivo 1:N per Evento | Associazione `RICHIESTA_PREV (0, N) -- (1, 1)` | FK NOT NULL verso `EVENTO` | DDL Constraint nativo |
| **V-15** | Cronologia Contratti e Validità Fornitore | Vincolo temporale e di stato non grafico | `CHECK` su preventivo + `ASSERTION` | **Trigger SQL `BEFORE INSERT` Contratto** |
| **V-16** | Recensione Solo a Evento Completato | Associazione 1:1 + Vincolo di stato evento | Asserzione teorica `ASSERTION` | **Trigger SQL** + Abilitazione pulsante UI |
| **V-17** | Categoria Merceologica Fornitore | Associazione `CATEGORIZZAZIONE (1, 1)` | FK NOT NULL verso `CATEGORIA_FORNITORE` | DDL Constraint nativo |
| **V-18** | Assegnazione Bomboniera all'Invitato | Associazione `OMAGGIO (0, 1)` | FK NULLABLE verso `BOMBONIERA` | DDL Constraint nativo |
