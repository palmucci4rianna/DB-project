# Progettazione Logica della Base di Dati: Wedding Planner
## Documentazione Tecnica e Metodologica (Capitolo 3 della Relazione)
**Corso di Basi di Dati — Università di Bologna (Prof. D. Maio, Prof.ssa A. Franco)**

---

# 1. Introduzione Metodologica

La fase di **Progettazione Logica** ha l'obiettivo di tradurre lo Schema Concettuale (Entity-Relationship) arricchito dai vincoli di integrità in uno **Schema Relazionale** efficiente, normalizzato e direttamente implementabile su un Relational DBMS (MySQL 8.0).

Secondo la metodologia didattica del corso di Basi di Dati di UniBo, la progettazione logica si articola nelle seguenti fasi:
1. **Stima dei Volumi dei Dati:** Quantificazione dello spazio di memoria e del carico informativo a regime.
2. **Definizione della Tabella delle Operazioni e Stima delle Frequenze:** Censimento delle transazioni OLTP e delle query analitiche OLAP con frequenza d'accesso stimata.
3. **Schemi di Navigazione e Tabelle degli Accessi:** Valutazione analitica del costo computazionale (Lettura $L=1$, Scrittura $S=2$) per le operazioni critiche.
4. **Analisi Critica delle Ridondanze:** Studio quantitativo di convenienza per gli attributi derivabili.
5. **Raffinamento e Ristrutturazione dello Schema E/R:** Eliminazione delle gerarchie di generalizzazione IS-A, eliminazione degli identificatori esterni e partizione delle chiavi.
6. **Schema Relazionale Finale:** Definizione formale delle relazioni, delle chiavi primarie (PK) e dei vincoli di integrità referenziale (FK).
7. **Traduzione SQL delle Interrogazioni Statistiche:** Scrittura ed ottimizzazione delle 8 query analitiche del dominio.

---

# 2. Stima dei Volumi dei Dati

Si assume uno scenario operativo realistico per un'agenzia di Wedding Planning consolidata, attiva sul mercato da **5 anni**, con un trend costante di circa **40 matrimoni organizzati all'anno** (200 eventi complessivi nello storico).

### Tabella 1: Volume Stimato per le Entità

| Concetto / Entità | Tipologia Entità | Volume Stimato (Tuple) | Motivazione e Criteri di Stima |
| :--- | :--- | :--- | :--- |
| **`PERSONA`** | Forte (Radice IS-A) | **26.000** | Somma di Coniugi (500), Dipendenti (10), Invitati unici (25.490). |
| **`COPPIA`** | Forte | **250** | 200 coppie con evento completato + 50 coppie in fase di pianificazione/trattativa. |
| **`DIPENDENTE`** | Specializzazione di Persona | **10** | Staff aziendale (3 Senior Planner, 4 Assistenti, 2 Coordinatori on-site, 1 Amministrativo). |
| **`RUOLO`** | Forte | **4** | Mansioni aziendali standard codificate. |
| **`RUOLO_DIPENDENTE`** | Reificazione ($N:M$) | **16** | Media di 1.6 ruoli ricoperti da ciascun dipendente. |
| **`MOTIVO_ASSENZA`** | Forte | **8** | Categorie codificate (Ferie, Malattia, Congedo, Maternità, Permesso, Dimissioni, ecc.). |
| **`DISPONIBILITA`** | Debole da Dipendente | **400** | Storico presenze/assenze (circa 8 periodi di ferie/assenze all'anno per dipendente in 5 anni). |
| **`ASSEGNAZIONE_DIPENDENTE`** | Reificazione ($N:M$) | **320** | 250 coppie seguite, di cui circa il 25% ha subito un cambio planner con riassegnazione storica. |
| **`EVENTO`** | Debole da Coppia | **200** | 200 matrimoni pianificati o completati (40 eventi/anno in 5 anni). |
| **`LOCATION`** | Forte | **25** | Strutture ricettive convenzionate (ville, castelli, chiese, agriturismi). |
| **`SVOLGIMENTO_EVENTO`** | Reificazione ($N:M$) | **400** | Media di 2 location utilizzate per ciascun evento (es. cerimonia in chiesa + ricevimento in villa). |
| **`TAVOLO`** | Debole da Evento | **2.400** | Media di 12 tavoli per evento (capienza media 10-12 persone). |
| **`BOMBONIERA`** | Forte | **12** | Tipologie di dono codificate nel catalogo di agenzia (testimoni, genitori, ospiti standard). |
| **`CATEGORIA_FORNITORE`** | Forte | **8** | Categorie merceologiche (Catering, Foto/Video, Fiori, Musica, Trasporti, Abiti, Cake, Celebrante). |
| **`FORNITORE`** | Forte | **60** | Fornitori partner attivi e convenzionati (circa 7-8 partner per categoria). |
| **`COLLABORAZIONE`** | Debole da Fornitore | **120** | Storico contratti di convenzione (rinnovati ogni 2-3 anni). |
| **`PREVENTIVO`** | Debole (1:N Evento) | **1.200** | Media di 6 preventivi richiesti a fornitori diversi per ogni matrimonio. |
| **`CONTRATTO`** | Debole (1:1 da Prev.) | **600** | Circa il 50% dei preventivi viene accettato (media di 3 contratti fornitore per evento). |
| **`TIMELINE`** | Debole (1:1 Evento) | **200** | Esattamente 1 timeline di regia per ciascun evento. |
| **`ATTIVITA_TIMELINE`** | Debole da Timeline | **2.400** | Media di 12 momenti orari per scaletta nella giornata del matrimonio. |
| **`TEMPLATE_CHECKLIST`** | Forte | **6** | Modelli standard predefiniti (Civile, Religioso, Simbolico, All'aperto, Destination Wedding, Veloce). |
| **`VOCE_TEMPLATE`** | Debole da Template | **180** | Media di 30 attività standard codificate in ciascun template. |
| **`CHECKLIST`** | Debole (1:1 Evento) | **200** | Esattamente 1 checklist operativa per evento. |
| **`ATTIVITA_CHECKLIST`** | Debole da Checklist | **6.000** | Media di 30 compiti operativi per ciascun matrimonio (derivati da template + personalizzati). |
| **`LISTA_NOZZE`** | Debole (1:1 Evento) | **200** | Esattamente 1 registro doni per evento. |
| **`REGALO`** | Debole da Lista Nozze | **1.600** | Media di 8 articoli o quote desiderate inserite per lista nozze. |
| **`INVITATO`** | Specializzazione di Persona | **25.000** | Anagrafica complessiva degli ospiti (alcuni invitati a più di un matrimonio). |
| **`PARTECIPAZIONE`** | Reificazione ($N:M$) | **25.500** | Media di ~127 invitati per matrimonio; alcuni ospiti ricorrenti partecipano a più nozze. |
| **`QUOTA_REGALO`** | Reificazione ($N:M$) | **10.000** | Circa 50 versamenti/donazioni per matrimonio da parte di invitati (confermati o rifiutati). |
| **`COMUNICAZIONE`** | Debole da Coppia | **3.000** | Media di 12 comunicazioni/messaggi formali archiviati per coppia. |
| **`APPUNTAMENTO`** | Debole da Coppia | **1.250** | Media di 5 incontri di consulenza (di persona o videocall) per coppia. |
| **`RECENSIONE`** | Debole (1:1 Evento) | **180** | Rilasciata da circa il 90% delle coppie con evento completato (180 su 200). |
| **`FOTO`** | Debole da Evento | **1.800** | Media di 10 fotografie ad alta risoluzione selezionate per portfolio per ciascun matrimonio. |

---

# 3. Tabella delle Operazioni e Stima delle Frequenze

Classifichiamo le operazioni in:
- **I = Interattive / OLTP:** Operazioni frequenti di lettura/scrittura a supporto del lavoro giornaliero.
- **B = Batch / OLAP:** Interrogazioni analitiche direzionali aggregate, eseguite periodicamente (settimanalmente, mensilmente o annualmente).

| Codice | Descrizione dell'Operazione | Tipo | Frequenza Stimata ($F$) |
| :--- | :--- | :---: | :--- |
| **OP-01** | Registrazione di una nuova coppia con due coniugi e assegnazione del wedding planner | I | 2 / mese (24 / anno) |
| **OP-02** | Creazione evento con budget e assegnazione location con fasce orarie | I | 2 / mese (24 / anno) |
| **OP-03** | Istanziazione automatica della checklist dell'evento a partire dal template del rito | I | 2 / mese (24 / anno) |
| **OP-04** | Inserimento nuovo fornitore nel catalogo e associazione alla categoria | I | 1 / mese (12 / anno) |
| **OP-05** | Richiesta preventivo a un fornitore per un determinato evento | I | 20 / mese (240 / anno) |
| **OP-06** | Accettazione preventivo con stipula contratto fornitore e registrazione acconto | I | 10 / mese (120 / anno) |
| **OP-07** | Inserimento invitato e registrazione partecipazione (RSVP, allergie, menù) | I | 200 / mese (2.400 / anno) |
| **OP-08** | Aggiornamento stato conferma partecipazione e assegnazione posto al tavolo | I | 100 / mese (1.200 / anno) |
| **OP-09** | Inserimento nuova voce regalo nella lista nozze | I | 30 / mese (360 / anno) |
| **OP-10** | Registrazione donazione/quota regalo da parte di un invitato con messaggio auguri | I | 150 / mese (1.800 / anno) |
| **OP-11** | Chiusura task della checklist con registrazione della data completamento effettiva | I | 100 / mese (1.200 / anno) |
| **OP-12** | Inserimento attività nella timeline di regia oraria con responsabile | I | 40 / mese (480 / anno) |
| **OP-13** | Inserimento recensione della coppia e foto a portfolio ad evento concluso | I | 3 / mese (36 / anno) |
| **STAT-01**| Analisi fornitori maggiormente contrattualizzati per categoria e spesa media nell'ultimo anno | B | 1 / mese (12 / anno) |
| **STAT-02**| Monitoraggio scostamento budget (Variance Analysis) per tutti gli eventi attivi | B | 4 / mese (48 / anno, settimanale) |
| **STAT-03**| Tasso di conversione commerciale (preventivi -> contratti) per ciascun fornitore | B | 1 / mese (12 / anno) |
| **STAT-04**| Produttività wedding planner: numero eventi gestiti con successo e gradimento medio | B | 1 / mese (12 / anno) |
| **STAT-05**| Benchmark di costo medio, invitati effettivi e soddisfazione per tipologia di cerimonia | B | 2 / anno |
| **STAT-06**| Frequenza d'uso, tasso occupazione e spesa media per ciascuna location | B | 4 / anno (trimestrale) |
| **STAT-07**| Monitoraggio criticità e percentuale attività in ritardo per fase e rito della checklist | B | 4 / mese (48 / anno, settimanale) |
| **STAT-08**| Tracciamento ospiti ricorrenti e totale quote complessive donate nelle liste nozze | B | 2 / mese (24 / anno) |

---

# 4. Schemi di Navigazione e Tabelle degli Accessi

Secondo la metrica formale UniBo:
- **Accesso in Lettura ($L$):** costo = **$1$** per ogni tupla esaminata.
- **Accesso in Scrittura ($S$):** costo = **$2$** per ogni tupla inserita, modificata o eliminata.
- **Costo Totale per Operazione:** $\text{Costo Singolo} = \sum (\text{Accessi } L \times 1) + \sum (\text{Accessi } S \times 2)$.
- **Costo Annuo Ponderato:** $\text{Costo Annuo} = \text{Costo Singolo} \times F_{\text{anno}}$.

Di seguito analizziamo dettagliatamente **4 operazioni chiave** altamente rappresentative (2 transazionali ad alta frequenza e 2 query analitiche complesse).

---

### Operazione 1: OP-08 — Conferma Partecipazione e Assegnazione al Tavolo
* **Descrizione:** Dato un invitato (tramite Codice Fiscale) e un evento, si aggiorna la partecipazione impostando lo stato su `'CONFERMATO'`, si verifica la capienza residua del tavolo designato e si assegna l'ospite al tavolo.
* **Frequenza:** $F = 1.200 \text{ volte/anno}$.

#### Schema di Navigazione:
```
[ PARTECIPAZIONE ] (Lettura riga specifica)
        |
        v
    [ TAVOLO ] (Lettura capienza tavolo)
        |
        v
[ PARTECIPAZIONE ] (Conteggio partecipanti già seduti allo stesso tavolo)
        |
        v
[ PARTECIPAZIONE ] (Scrittura aggiornamento: stato='CONFERMATO', tavolo_nome_numero=...)
```

#### Tabella degli Accessi OP-08:

| Entità / Relazione | Tipo Accesso | Accessi per Esecuzione | Costo Unitario | Costo Parziale | Note |
| :--- | :---: | :---: | :---: | :---: | :--- |
| `PARTECIPAZIONE` | L | 1 | 1 | 1 | Lettura tupla dell'ospite per l'evento |
| `TAVOLO` | L | 1 | 1 | 1 | Lettura capienza massima del tavolo prescelto |
| `PARTECIPAZIONE` | L | 10 | 1 | 10 | Lettura ospiti già assegnati a quel tavolo (media 10) |
| `PARTECIPAZIONE` | S | 1 | 2 | 2 | Scrittura aggiornamento (stato confermato + tavolo) |
| **Totale Singolo** | | | | **14** | |
| **Totale Annuo** | | | | **16.800** | $14 \times 1.200 \text{ esecuzioni/anno}$ |

---

### Operazione 2: OP-10 — Registrazione Quota Regalo da Parte di un Invitato
* **Descrizione:** Un ospite versa una donazione/quota per l'evento. Il sistema verifica che sia un invitato dell'evento, registra la transazione monetaria e, se la quota è destinata a un regalo specifico della lista nozze, verifica che non ecceda il prezzo residuo del regalo.
* **Frequenza:** $F = 1.800 \text{ volte/anno}$.

#### Schema di Navigazione:
```
   [ INVITATO ] (Verifica esistenza anagrafica)
        |
        v
[ PARTECIPAZIONE ] (Verifica invito all'evento)
        |
        v
    [ REGALO ] (Opzionale: lettura prezzo se specificato)
        |
        v
[ QUOTA_REGALO ] (Lettura quote già versate per quel regalo)
        |
        v
[ QUOTA_REGALO ] (Scrittura inserimento nuova tupla)
```

#### Tabella degli Accessi OP-10:

| Entità / Relazione | Tipo Accesso | Accessi per Esecuzione | Costo Unitario | Costo Parziale | Note |
| :--- | :---: | :---: | :---: | :---: | :--- |
| `INVITATO` | L | 1 | 1 | 1 | Controllo esistenza dell'ospite |
| `PARTECIPAZIONE` | L | 1 | 1 | 1 | Verifica che l'ospite sia invitato a questo evento |
| `REGALO` | L | 1 | 1 | 1 | Lettura prezzo del bene (se regalo specifico) |
| `QUOTA_REGALO` | L | 6 | 1 | 6 | Lettura quote precedenti su quel regalo (media 6) |
| `QUOTA_REGALO` | S | 1 | 2 | 2 | Inserimento della nuova donazione |
| **Totale Singolo** | | | | **11** | |
| **Totale Annuo** | | | | **19.800** | $11 \times 1.800 \text{ esecuzioni/anno}$ |

---

### Operazione 3: STAT-02 — Monitoraggio Scostamento Budget (Variance Analysis)
* **Descrizione:** Per tutti gli eventi attualmente attivi (in fase di pianificazione, circa 40 contemporaneamente), calcola il budget approvato e somma tutti gli importi definitivi dei contratti fornitore confermati, calcolando la percentuale di scostamento.
* **Frequenza:** Eseguita settimanalmente dai planner e dalla direzione: $F = 48 \text{ volte/anno}$.

#### Schema di Navigazione:
```
[ EVENTO ] (Filtro eventi con stato='in pianificazione')
    |
    v (1:N)
[ PREVENTIVO ] (Join preventivi dell'evento)
    |
    v (1:1)
[ CONTRATTO ] (Join contratti stipulati e somma importo_definitivo)
```

#### Tabella degli Accessi STAT-02:

| Entità / Relazione | Tipo Accesso | Accessi per Esecuzione | Costo Unitario | Costo Parziale | Note |
| :--- | :---: | :---: | :---: | :---: | :--- |
| `EVENTO` | L | 40 | 1 | 40 | Scansione 40 eventi attivi in pianificazione |
| `PREVENTIVO` | L | 240 | 1 | 240 | Media di 6 preventivi richiesti per evento ($40 \times 6$) |
| `CONTRATTO` | L | 120 | 1 | 120 | Media di 3 contratti confermati per evento ($40 \times 3$) |
| **Totale Singolo** | | | | **400** | |
| **Totale Annuo** | | | | **19.200** | $400 \times 48 \text{ esecuzioni/anno}$ |

---

### Operazione 4: STAT-08 — Tracciamento Ospiti Ricorrenti e Generosità Quote
* **Descrizione:** Individua gli invitati che hanno preso parte a più di un matrimonio organizzato dall'agenzia ($\text{COUNT}(\text{DISTINCT Evento}) > 1$), calcolando per ciascuno il numero totale di partecipazioni e la somma complessiva delle quote versate in tutte le liste nozze.
* **Frequenza:** $F = 24 \text{ volte/anno}$ (due volte al mese).

#### Schema di Navigazione:
```
[ INVITATO ] (Scansione invitati con partecipazioni)
    |
    v
[ PARTECIPAZIONE ] (Raggruppamento per codice_fiscale, filtro HAVING COUNT > 1)
    |
    v
[ QUOTA_REGALO ] (Aggregazione quote versate dall'invitato)
```

#### Tabella degli Accessi STAT-08:

| Entità / Relazione | Tipo Accesso | Accessi per Esecuzione | Costo Unitario | Costo Parziale | Note |
| :--- | :---: | :---: | :---: | :---: | :--- |
| `INVITATO` | L | 25.000 | 1 | 25.000 | Scansione anagrafica ospiti (tramite indice su CF) |
| `PARTECIPAZIONE` | L | 25.500 | 1 | 25.500 | Conteggio eventi distinti per ospite |
| `QUOTA_REGALO` | L | 2.500 | 1 | 2.500 | Lettura quote versate dagli ospiti ricorrenti (~500 ospiti $\times$ 5 quote) |
| **Totale Singolo** | | | | **53.000** | |
| **Totale Annuo** | | | | **1.272.000** | $53.000 \times 24 \text{ esecuzioni/anno}$ |

---

# 5. Analisi Critica delle Ridondanze

Uno dei requisiti fondanti della Progettazione Logica secondo la scuola UniBo è la valutazione formale e quantitativa delle ridondanze.

Studiamo il candidato principale di ridondanza: l'attributo **`totale_raccolto`** nell'entità **`LISTA_NOZZE`**.

### Definizione della Ridondanza
- **Dato derivabile:** `LISTA_NOZZE.totale_raccolto` è matematicamente equivalente a:
  $$\\text{TotaleRaccolto} = \\sum_{q \\in \\text{QUOTA\\_REGALO per questo evento}} q.\\text{importo}$$
- **Confronto tra due alternative progettuali:**
  - **Schema $S_1$ (Senza Ridondanza):** L'attributo `totale_raccolto` viene eliminato dalla relazione `LISTA_NOZZE`. Ogni volta che l'informazione è richiesta (apertura pagina evento, dashboard coppia, resoconto planner), si calcola a runtime con una query `SUM`.
  - **Schema $S_2$ (Con Ridondanza):** L'attributo `totale_raccolto` viene mantenuto fisicamente in `LISTA_NOZZE` e aggiornato incrementalmente ad ogni nuovo versamento registrato in `QUOTA_REGALO`.

### Operazioni Impattate
1. **$OP_A$: Registrazione di una nuova quota regalo (`OP-10`).**
   - Frequenza: $F_A = 1.800 \text{ volte/anno}$.
2. **$OP_B$: Visualizzazione del riepilogo lista nozze (Dashboard Sposi / Portale Invitati / Scheda Evento Planner).**
   - Eseguita ogni volta che gli sposi controllano i doni, un invitato visita la lista o il planner verifica lo stato: stimata in $15 \text{ visualizzazioni/giorno} = 5.400 \text{ volte/anno}$.
   - Frequenza: $F_B = 5.400 \text{ volte/anno}$.

---

### Calcolo Comparativo dei Costi

#### 1. Analisi di $OP_A$ (Registrazione Quota)
- **In Schema $S_1$ (Senza Ridondanza):**
  - Si inserisce la tupla in `QUOTA_REGALO`: $1 \text{ scrittura } = 2$.
  - Costo singola esecuzione: $2$.
  - Costo annuo: $2 \times 1.800 = \mathbf{3.600}$.
- **In Schema $S_2$ (Con Ridondanza):**
  - Si inserisce la tupla in `QUOTA_REGALO`: $1 \text{ scrittura } = 2$.
  - Si legge la tupla `LISTA_NOZZE`: $1 \text{ lettura } = 1$.
  - Si aggiorna l'accumulatore `totale_raccolto` in `LISTA_NOZZE`: $1 \text{ scrittura } = 2$.
  - Costo singola esecuzione: $2 + 1 + 2 = 5$.
  - Costo annuo: $5 \times 1.800 = \mathbf{9.000}$.

#### 2. Analisi di $OP_B$ (Visualizzazione Riepilogo Lista Nozze)
Si consideri un evento medio con $50$ donazioni registrate in `QUOTA_REGALO`.
- **In Schema $S_1$ (Senza Ridondanza):**
  - Si deve scansionare e sommare l'importo di tutte le 50 tuple in `QUOTA_REGALO`: $50 \text{ letture } = 50$.
  - Costo singola esecuzione: $50$.
  - Costo annuo: $50 \times 5.400 = \mathbf{270.000}$.
- **In Schema $S_2$ (Con Ridondanza):**
  - Si legge direttamente la singola tupla in `LISTA_NOZZE` accedendo all'attributo pre-calcolato: $1 \text{ lettura } = 1$.
  - Costo singola esecuzione: $1$.
  - Costo annuo: $1 \times 5.400 = \mathbf{5.400}$.

---

### Bilancio Complessivo e Decisione Progettuale

| Schema Considerato | Costo Annuo $OP_A$ (Scrittura) | Costo Annuo $OP_B$ (Lettura) | Costo Annuo Totale |
| :--- | :---: | :---: | :---: |
| **Schema $S_1$ (Senza Ridondanza)** | 3.600 | 270.000 | **273.600** |
| **Schema $S_2$ (Con Ridondanza)** | 9.000 | 5.400 | **14.400** |

$$\\Delta \\text{Costo} = 273.600 - 14.400 = \\mathbf{+259.200 \\text{ accessi risparmiati all'anno}}$$

> **Verdetto Formale:** 
> L'analisi quantitativa dimostra inequivocabilmente che **mantenere la ridondanza `totale_raccolto` in `LISTA_NOZZE` è altamente conveniente**, riducendo il costo computazionale annuo del **94.7%** a fronte di un modesto overhead di scrittura (gestibile tramite Trigger SQL `AFTER INSERT ON QUOTA_REGALO`).

---

# 6. Raffinamento e Ristrutturazione dello Schema E/R

Per consentire la traduzione nel modello relazionale, lo schema E/R concettuale viene ristrutturato affrontando:
1. Eliminazione delle gerarchie di specializzazione (IS-A).
2. Eliminazione degli identificatori esterni (entità deboli).
3. Normalizzazione e scelta delle chiavi primarie.

---

### 6.1 Eliminazione delle Gerarchie di Generalizzazione (IS-A)

Nello schema concettuale è presente la gerarchia facente capo all'entità radice **`PERSONA`**, specializzata in **`DIPENDENTE`** e **`INVITATO`**:

```
                  +-------------------+
                  |      PERSONA      |
                  +-------------------+
                    ^               ^
             (IS-A) |               | (IS-A)
       +------------+               +------------+
       |                                         |
+--------------+                          +--------------+
|  DIPENDENTE  |                          |   INVITATO   |
+--------------+                          +--------------+
```

Valutiamo le tre strategie canoniche di ristrutturazione:

1. **Strategia 1 — Collasso verso l'alto (Unica tabella `PERSONA`):**
   - Si creerebbe un'unica relazione contenente tutti gli attributi del dipendente e dell'invitato, con un discriminatore di tipo.
   - *Svantaggi:* Moltissimi valori `NULL` (la stragrande maggioranza delle 26.000 persone sono invitati e non avrebbero attributi di assunzione, email aziendale, ecc.). Inoltre, la semantica dei ruoli verrebbe compromessa.
2. **Strategia 2 — Collasso verso il basso (Tabelle `DIPENDENTE` e `INVITATO` separate senza `PERSONA`):**
   - Si duplicherebbero i campi anagrafici (`nome`, `cognome`, `email`, `telefono`) sia in Dipendente sia in Invitato.
   - *Svantaggi:* Perdita dell'identità unica del soggetto: se un dipendente viene invitato a un matrimonio o una persona cambia ruolo, si creerebbero duplicati e possibili disallineamenti di recapiti.
3. **Strategia 3 — Mantenimento delle Relazioni Separate con Partizione delle Chiavi (Scelta Adottata):**
   - Si mantengono **tre relazioni distinte**:
     - `PERSONA`: anagrafica generale con chiave primaria `codice_fiscale`.
     - `DIPENDENTE`: identificata da `codice_fiscale` (che è contestualmente Primary Key e Foreign Key verso `PERSONA`), contenente gli attributi esclusivi del personale (`email_aziendale`, `data_assunzione`, `data_fine_rapporto`, `stato`).
     - `INVITATO`: identificata da `codice_fiscale` (PK e FK verso `PERSONA`), contenente gli attributi esclusivi dell'ospite (`relazione`, `tipologia_bomboniera`).
   - *Vantaggi:* Zero campi `NULL`, integrità referenziale nativa, nessuna duplicazione e supporto perfetto ai casi reali in cui un membro dello staff sia invitato come ospite ad un evento.

---

### 6.2 Eliminazione degli Identificatori Esterni (Entità Deboli)

Nel passaggio al modello relazionale, ogni entità debole assorbe la chiave primaria dell'entità dominante:

1. **`EVENTO`:** Dominata da `COPPIA` $\rightarrow$ $\text{PK} = \{\underline{\text{username\_coppia}, \text{data}}\}$.
2. **`TIMELINE`, `CHECKLIST`, `LISTA_NOZZE`, `RECENSIONE`:** Tutte in relazione 1:1 con `EVENTO` $\rightarrow$ Assorbono la chiave identica dell'evento: $\text{PK} = \{\underline{\text{username\_coppia}, \text{data\_evento}}\}$.
3. **`TAVOLO`:** Debole da `EVENTO` $\rightarrow$ $\text{PK} = \{\underline{\text{username\_coppia}, \text{data\_evento}, \text{nome\_numero}}\}$.
4. **`ATTIVITA_TIMELINE`:** Debole da `TIMELINE` $\rightarrow$ $\text{PK} = \{\underline{\text{username\_coppia}, \text{data\_evento}, \text{orario\_previsto}}\}$.
5. **`ATTIVITA_CHECKLIST`:** Debole da `CHECKLIST` $\rightarrow$ $\text{PK} = \{\underline{\text{username\_coppia}, \text{data\_evento}, \text{titolo\_attivita}}\}$.
6. **`REGALO`:** Debole da `LISTA_NOZZE` $\rightarrow$ $\text{PK} = \{\underline{\text{username\_coppia}, \text{data\_evento}, \text{descrizione}}\}$.
7. **`PREVENTIVO`:** Debole da `FORNITORE` con riferimento a `EVENTO` $\rightarrow$ $\text{PK} = \{\underline{\text{partita\_iva}, \text{numero\_preventivo}}\}$ con FK verso `EVENTO`.
8. **`CONTRATTO`:** In relazione 1:1 identificante da `PREVENTIVO` accettato $\rightarrow$ $\text{PK} = \{\underline{\text{partita\_iva}, \text{numero\_preventivo}}\}$.
9. **`DISPONIBILITA`:** Debole da `DIPENDENTE` $\rightarrow$ $\text{PK} = \{\underline{\text{dipendente\_cf}, \text{data\_inizio}}\}$.
10. **`FOTO`:** Debole da `EVENTO` $\rightarrow$ $\text{PK} = \{\underline{\text{username\_coppia}, \text{data\_evento}, \text{percorso\_file}}\}$.
11. **`VOCE_TEMPLATE`:** Debole da `TEMPLATE_CHECKLIST` $\rightarrow$ $\text{PK} = \{\underline{\text{nome\_template}, \text{titolo\_voce}}\}$.

---

# 7. Schema Relazionale Finale

Di seguito viene formalizzato lo schema logico relazionale finale in notazione accademica. 
- La **chiave primaria (PK)** è indicata con sottolineatura continua: $\underline{\text{attributo}}$.
- Le **chiavi esterne (FK)** sono annotate con asterisco o specificate esplicitamente a pedice.

---

### 1. Modulo Anagrafico e Personale
1. $\text{PERSONA}(\underline{\text{codice\_fiscale}}, \text{nome}, \text{cognome}, \text{email}, \text{telefono})$
2. $\text{DIPENDENTE}(\underline{\text{codice\_fiscale}}^*, \text{email\_aziendale}, \text{data\_assunzione}, \text{data\_fine\_rapporto}, \text{stato})$  
   *FK: $\text{codice\_fiscale} \rightarrow \text{PERSONA}$*
3. $\text{RUOLO}(\underline{\text{nome\_ruolo}}, \text{descrizione}, \text{max\_eventi\_contemporanei})$
4. $\text{RUOLO\_DIPENDENTE}(\underline{\text{dipendente\_cf}}^*, \underline{\text{nome\_ruolo}}^*, \text{data\_assegnazione}, \text{principale})$  
   *FK: $\text{dipendente\_cf} \rightarrow \text{DIPENDENTE}$, $\text{nome\_ruolo} \rightarrow \text{RUOLO}$*
5. $\text{MOTIVO\_ASSENZA}(\underline{\text{categoria}}, \text{descrizione}, \text{remunerata})$
6. $\text{DISPONIBILITA}(\underline{\text{dipendente\_cf}}^*, \underline{\text{data\_inizio}}, \text{data\_fine}, \text{tipo}, \text{stato}, \text{categoria\_assenza}^*)$  
   *FK: $\text{dipendente\_cf} \rightarrow \text{DIPENDENTE}$, $\text{categoria\_assenza} \rightarrow \text{MOTIVO\_ASSENZA}$*

---

### 2. Modulo Committenza e Gestione Incarichi
7. $\text{COPPIA}(\underline{\text{username}}, \text{cf\_coniuge1}^*, \text{cf\_coniuge2}^*, \text{data\_prevista}, \text{budget\_indicativo})$  
   *FK: $\text{cf\_coniuge1} \rightarrow \text{PERSONA}$, $\text{cf\_coniuge2} \rightarrow \text{PERSONA}$*
8. $\text{ASSEGNAZIONE\_DIPENDENTE}(\underline{\text{username\_coppia}}^*, \underline{\text{dipendente\_cf}}^*, \underline{\text{data\_inizio}}, \text{data\_fine}, \text{motivo\_cambio}, \text{attiva})$  
   *FK: $\text{username\_coppia} \rightarrow \text{COPPIA}$, $\text{dipendente\_cf} \rightarrow \text{DIPENDENTE}$*

---

### 3. Modulo Evento e Logistica
9. $\text{EVENTO}(\underline{\text{username\_coppia}}^*, \underline{\text{data}}, \text{budget\_approvato}, \text{n\_invitati\_previsti}, \text{n\_invitati\_confermati}, \text{tipo\_cerimonia}, \text{stato})$  
   *FK: $\text{username\_coppia} \rightarrow \text{COPPIA}$*
10. $\text{LOCATION}(\underline{\text{nome}}, \underline{\text{indirizzo}}, \text{capienza\_max}, \text{prezzo\_affitto}, \text{servizi\_inclusi})$
11. $\text{SVOLGIMENTO\_EVENTO}(\underline{\text{username\_coppia}}^*, \underline{\text{data\_evento}}^*, \underline{\text{nome\_location}}^*, \underline{\text{indirizzo\_location}}^*, \text{orario\_inizio}, \text{orario\_fine})$  
    *FK: $(\text{username\_coppia}, \text{data\_evento}) \rightarrow \text{EVENTO}$, $(\text{nome\_location}, \text{indirizzo\_location}) \rightarrow \text{LOCATION}$*
12. $\text{TAVOLO}(\underline{\text{username\_coppia}}^*, \underline{\text{data\_evento}}^*, \underline{\text{nome\_numero}}, \text{capienza}, \text{posizione})$  
    *FK: $(\text{username\_coppia}, \text{data\_evento}) \rightarrow \text{EVENTO}$*
13. $\text{BOMBONIERA}(\underline{\text{tipologia}}, \text{descrizione}, \text{target})$

---

### 4. Modulo Fornitori, Preventivi e Contratti
14. $\text{CATEGORIA\_FORNITORE}(\underline{\text{nome\_categoria}}, \text{descrizione})$
15. $\text{FORNITORE}(\underline{\text{partita\_iva}}, \text{ragione\_sociale}, \text{email}, \text{telefono}, \text{zona\_operativita}, \text{valutazione\_interna}, \text{attivo}, \text{nome\_categoria}^*)$  
    *FK: $\text{nome\_categoria} \rightarrow \text{CATEGORIA\_FORNITORE}$*
16. $\text{COLLABORAZIONE}(\underline{\text{partita\_iva}}^*, \underline{\text{data\_inizio}}, \text{data\_fine}, \text{stato}, \text{note}, \text{valutazione})$  
    *FK: $\text{partita\_iva} \rightarrow \text{FORNITORE}$*
17. $\text{PREVENTIVO}(\underline{\text{partita\_iva}}^*, \underline{\text{numero\_preventivo}}, \text{username\_coppia}^*, \text{data\_evento}^*, \text{dipendente\_cf}^*, \text{data\_emissione}, \text{data\_scadenza}, \text{importo}, \text{descrizione}, \text{stato})$  
    *FK: $\text{partita\_iva} \rightarrow \text{FORNITORE}$, $(\text{username\_coppia}, \text{data\_evento}) \rightarrow \text{EVENTO}$, $\text{dipendente\_cf} \rightarrow \text{DIPENDENTE}$*
18. $\text{CONTRATTO}(\underline{\text{partita\_iva}}^*, \underline{\text{numero\_preventivo}}^*, \text{data\_firma}, \text{importo\_definitivo}, \text{acconto}, \text{saldo}, \text{stato\_pagamento}, \text{penali})$  
    *FK: $(\text{partita\_iva}, \text{numero\_preventivo}) \rightarrow \text{PREVENTIVO}$*

---

### 5. Modulo Timeline di Regia e Checklist con Template
19. $\text{TIMELINE}(\underline{\text{username\_coppia}}^*, \underline{\text{data\_evento}}^*, \text{note\_regia}, \text{stato\_timeline})$  
    *FK: $(\text{username\_coppia}, \text{data\_evento}) \rightarrow \text{EVENTO}$*
20. $\text{ATTIVITA\_TIMELINE}(\underline{\text{username\_coppia}}^*, \underline{\text{data\_evento}}^*, \underline{\text{orario\_previsto}}, \text{titolo}, \text{durata\_minuti}, \text{descrizione}, \text{luogo}, \text{stato}, \text{nota\_staff}, \text{nota\_coppia}, \text{dipendente\_cf}^*, \text{partita\_iva\_fornitore}^*)$  
    *FK: $(\text{username\_coppia}, \text{data\_evento}) \rightarrow \text{TIMELINE}$, $\text{dipendente\_cf} \rightarrow \text{DIPENDENTE}$, $\text{partita\_iva\_fornitore} \rightarrow \text{FORNITORE}$*
21. $\text{TEMPLATE\_CHECKLIST}(\underline{\text{nome\_template}}, \text{tipo\_cerimonia}, \text{descrizione})$
22. $\text{VOCE\_TEMPLATE}(\underline{\text{nome\_template}}^*, \underline{\text{titolo\_voce}}, \text{descrizione}, \text{priorita}, \text{fase}, \text{giorni\_prima})$  
    *FK: $\text{nome\_template} \rightarrow \text{TEMPLATE\_CHECKLIST}$*
23. $\text{CHECKLIST}(\underline{\text{username\_coppia}}^*, \underline{\text{data\_evento}}^*, \text{nome\_template}^*, \text{note\_generali})$  
    *FK: $(\text{username\_coppia}, \text{data\_evento}) \rightarrow \text{EVENTO}$, $\text{nome\_template} \rightarrow \text{TEMPLATE\_CHECKLIST}$*
24. $\text{ATTIVITA\_CHECKLIST}(\underline{\text{username\_coppia}}^*, \underline{\text{data\_evento}}^*, \underline{\text{titolo\_attivita}}, \text{descrizione}, \text{scadenza}, \text{data\_completamento}, \text{priorita}, \text{fase}, \text{stato}, \text{dipendente\_cf}^*)$  
    *FK: $(\text{username\_coppia}, \text{data\_evento}) \rightarrow \text{CHECKLIST}$, $\text{dipendente\_cf} \rightarrow \text{DIPENDENTE}$*

---

### 6. Modulo Ospiti, Partecipazioni, Lista Nozze e Quote
25. $\text{INVITATO}(\underline{\text{codice\_fiscale}}^*, \text{relazione}, \text{tipologia\_bomboniera}^*)$  
    *FK: $\text{codice\_fiscale} \rightarrow \text{PERSONA}$, $\text{tipologia\_bomboniera} \rightarrow \text{BOMBONIERA}$*
26. $\text{PARTECIPAZIONE}(\underline{\text{codice\_fiscale}}^*, \underline{\text{username\_coppia}}^*, \underline{\text{data\_evento}}^*, \text{stato}, \text{allergie}, \text{preferenza\_menu}, \text{trasporto}, \text{note}, \text{tavolo\_nome\_numero}^*)$  
    *FK: $\text{codice\_fiscale} \rightarrow \text{INVITATO}$, $(\text{username\_coppia}, \text{data\_evento}) \rightarrow \text{EVENTO}$, $(\text{username\_coppia}, \text{data\_evento}, \text{tavolo\_nome\_numero}) \rightarrow \text{TAVOLO}$*
27. $\text{LISTA\_NOZZE}(\underline{\text{username\_coppia}}^*, \underline{\text{data\_evento}}^*, \text{totale\_desiderato}, \text{totale\_raccolto}, \text{stato\_lista})$  
    *FK: $(\text{username\_coppia}, \text{data\_evento}) \rightarrow \text{EVENTO}$*
28. $\text{REGALO}(\underline{\text{username\_coppia}}^*, \underline{\text{data\_evento}}^*, \underline{\text{descrizione}}, \text{prezzo}, \text{link}, \text{negozio}, \text{stato}, \text{tipologia}, \text{tipo\_frazionamento})$  
    *FK: $(\text{username\_coppia}, \text{data\_evento}) \rightarrow \text{LISTA\_NOZZE}$*
29. $\text{QUOTA\_REGALO}(\underline{\text{codice\_fiscale}}^*, \underline{\text{username\_coppia}}^*, \underline{\text{data\_evento}}^*, \underline{\text{data\_ora}}, \text{importo}, \text{messaggio\_auguri}, \text{metodo\_pagamento}, \text{stato}, \text{descrizione\_regalo}^*)$  
    *FK: $\text{codice\_fiscale} \rightarrow \text{INVITATO}$, $(\text{username\_coppia}, \text{data\_evento}) \rightarrow \text{EVENTO}$, $(\text{username\_coppia}, \text{data\_evento}, \text{descrizione\_regalo}) \rightarrow \text{REGALO}$*

---

### 7. Modulo Comunicazioni, Appuntamenti e Portfolio
30. $\text{COMUNICAZIONE}(\underline{\text{username\_coppia}}^*, \underline{\text{data\_ora}}, \underline{\text{mittente}}, \text{dipendente\_cf}^*, \text{oggetto}, \text{contenuto}, \text{argomento}, \text{allegati})$  
    *FK: $\text{username\_coppia} \rightarrow \text{COPPIA}$, $\text{dipendente\_cf} \rightarrow \text{DIPENDENTE}$*
31. $\text{APPUNTAMENTO}(\underline{\text{username\_coppia}}^*, \underline{\text{data\_ora}}, \text{dipendente\_cf}^*, \text{categoria\_assenza}^*, \text{luogo\_modalita}, \text{durata\_minuti}, \text{resoconto}, \text{stato})$  
    *FK: $\text{username\_coppia} \rightarrow \text{COPPIA}$, $\text{dipendente\_cf} \rightarrow \text{DIPENDENTE}$, $\text{categoria\_assenza} \rightarrow \text{MOTIVO\_ASSENZA}$*
32. $\text{RECENSIONE}(\underline{\text{username\_coppia}}^*, \underline{\text{data\_evento}}^*, \text{data}, \text{voto}, \text{testo}, \text{tag\_stile}, \text{stagione})$  
    *FK: $(\text{username\_coppia}, \text{data\_evento}) \rightarrow \text{EVENTO}$*
33. $\text{FOTO}(\underline{\text{username\_coppia}}^*, \underline{\text{data\_evento}}^*, \underline{\text{percorso\_file}}, \text{didascalia}, \text{autore}, \text{data\_scatto})$  
    *FK: $(\text{username\_coppia}, \text{data\_evento}) \rightarrow \text{EVENTO}$*

---

# 8. Traduzione delle 8 Query Statistiche in SQL Standard

Le seguenti query traducono formalmente le interrogazioni analitiche concordate nel dominio, ottimizzate secondo lo schema relazionale finale:

### STAT-01: Analisi Fornitori per Categoria e Spesa
*Individua i fornitori maggiormente contrattualizzati nell'ultimo anno per ciascuna categoria, indicando il numero totale di contratti, il fatturato complessivo generato e l'importo medio.*
```sql
SELECT 
    f.nome_categoria AS Categoria,
    f.ragione_sociale AS Fornitore,
    COUNT(c.numero_preventivo) AS NumeroContratti,
    SUM(c.importo_definitivo) AS FatturatoTotale,
    AVG(c.importo_definitivo) AS ImportoMedioContratto
FROM FORNITORE f
JOIN CONTRATTO c ON f.partita_iva = c.partita_iva
WHERE c.data_firma >= DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR)
GROUP BY f.nome_categoria, f.ragione_sociale
ORDER BY f.nome_categoria, FatturatoTotale DESC;
```

---

### STAT-02: Monitoraggio dello Scostamento di Budget (Variance Analysis)
*Calcola, per ogni evento attivo in fase di pianificazione, la spesa contrattualizzata effettiva e lo scostamento percentuale rispetto al budget approvato, evidenziando gli sforamenti.*
```sql
SELECT 
    e.username_coppia AS Coppia,
    e.data AS DataEvento,
    e.budget_approvato AS BudgetApprovato,
    COALESCE(SUM(c.importo_definitivo), 0) AS TotaleContrattualizzato,
    ROUND(((COALESCE(SUM(c.importo_definitivo), 0) - e.budget_approvato) / e.budget_approvato) * 100, 2) AS ScostamentoPercentuale,
    CASE 
        WHEN COALESCE(SUM(c.importo_definitivo), 0) > e.budget_approvato * 1.05 THEN 'CRITICO: SFORAMENTO'
        WHEN COALESCE(SUM(c.importo_definitivo), 0) > e.budget_approvato THEN 'ATTENZIONE: LIMITE'
        ELSE 'IN BUDGET'
    END AS StatoBudget
FROM EVENTO e
LEFT JOIN PREVENTIVO p ON e.username_coppia = p.username_coppia AND e.data = p.data_evento
LEFT JOIN CONTRATTO c ON p.partita_iva = c.partita_iva AND p.numero_preventivo = c.numero_preventivo
WHERE e.stato = 'in pianificazione'
GROUP BY e.username_coppia, e.data, e.budget_approvato
ORDER BY ScostamentoPercentuale DESC;
```

---

### STAT-03: Indice di Conversione Commerciale per Fornitore
*Calcola il conversion rate da preventivo a contratto per ciascun fornitore, evidenziando i partner con tasso critico.*
```sql
SELECT 
    f.partita_iva AS PartitaIVA,
    f.ragione_sociale AS Fornitore,
    COUNT(p.numero_preventivo) AS PreventiviEmessi,
    COUNT(c.numero_preventivo) AS ContrattiStipulati,
    ROUND((COUNT(c.numero_preventivo) * 100.0) / COUNT(p.numero_preventivo), 2) AS TassoConversionePercentuale
FROM FORNITORE f
JOIN PREVENTIVO p ON f.partita_iva = p.partita_iva
LEFT JOIN CONTRATTO c ON p.partita_iva = c.partita_iva AND p.numero_preventivo = c.numero_preventivo
GROUP BY f.partita_iva, f.ragione_sociale
HAVING COUNT(p.numero_preventivo) >= 5
ORDER BY TassoConversionePercentuale ASC;
```

---

### STAT-04: Carico di Lavoro e Produttività dei Wedding Planner
*Individua il wedding planner con il maggior numero di eventi gestiti con successo nell'ultimo anno, ponderato con la media delle valutazioni qualitative ricevute dalle coppie a portfolio.*
```sql
SELECT 
    d.codice_fiscale AS CodiceFiscale,
    p.nome AS Nome,
    p.cognome AS Cognome,
    COUNT(DISTINCT e.data) AS EventiCompletati,
    ROUND(AVG(r.voto), 2) AS ValutazioneMediaPortfolio
FROM DIPENDENTE d
JOIN PERSONA p ON d.codice_fiscale = p.codice_fiscale
JOIN ASSEGNAZIONE_DIPENDENTE a ON d.codice_fiscale = a.dipendente_cf
JOIN EVENTO e ON a.username_coppia = e.username_coppia
LEFT JOIN RECENSIONE r ON e.username_coppia = r.username_coppia AND e.data = r.data_evento
WHERE e.stato = 'completato'
  AND e.data >= DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR)
GROUP BY d.codice_fiscale, p.nome, p.cognome
ORDER BY EventiCompletati DESC, ValutazioneMediaPortfolio DESC;
```

---

### STAT-05: Benchmark per Tipologia di Cerimonia
*Calcola per ciascun rito (civile, religioso, simbolico, all'aperto) il budget medio speso, la media degli invitati effettivi e il punteggio medio di soddisfazione.*
```sql
SELECT 
    e.tipo_cerimonia AS TipoCerimonia,
    COUNT(e.data) AS NumeroMatrimoni,
    ROUND(AVG(e.budget_approvato), 2) AS BudgetMedio,
    ROUND(AVG(e.n_invitati_confermati), 1) AS MediaInvitatiEffettivi,
    ROUND(AVG(r.voto), 2) AS SoddisfazioneMedia
FROM EVENTO e
LEFT JOIN RECENSIONE r ON e.username_coppia = r.username_coppia AND e.data = r.data_evento
WHERE e.stato = 'completato'
GROUP BY e.tipo_cerimonia
ORDER BY NumeroMatrimoni DESC;
```

---

### STAT-06: Frequenza d'Uso e Capienza Media delle Location
*Classifica le location più richieste per tipologia di matrimonio con dettaglio sugli eventi ospitati, capienza media effettiva e spesa media di canone.*
```sql
SELECT 
    l.nome AS Location,
    l.indirizzo AS Indirizzo,
    e.tipo_cerimonia AS TipoCerimonia,
    COUNT(DISTINCT se.data_evento) AS MatrimoniOspitati,
    ROUND(AVG(e.n_invitati_confermati), 1) AS MediaInvitatiPresenti,
    l.prezzo_affitto AS CanoneAffitto
FROM LOCATION l
JOIN SVOLGIMENTO_EVENTO se ON l.nome = se.nome_location AND l.indirizzo = se.indirizzo_location
JOIN EVENTO e ON se.username_coppia = e.username_coppia AND se.data_evento = e.data
GROUP BY l.nome, l.indirizzo, e.tipo_cerimonia, l.prezzo_affitto
ORDER BY MatrimoniOspitati DESC;
```

---

### STAT-07: Monitoraggio Criticità e Ritardi Checklist
*Calcola la percentuale di attività non ancora completate oltre la data di scadenza (o chiuse in ritardo), aggregate per fase organizzativa e tipologia di cerimonia.*
```sql
SELECT 
    e.tipo_cerimonia AS TipoCerimonia,
    ac.fase AS FaseOrganizzativa,
    COUNT(ac.titolo_attivita) AS TotaleAttivita,
    SUM(CASE 
        WHEN (ac.data_completamento IS NOT NULL AND ac.data_completamento > ac.scadenza)
          OR (ac.stato <> 'completata' AND CURRENT_DATE > ac.scadenza) THEN 1 
        ELSE 0 
    END) AS AttivitaInRitardo,
    ROUND((SUM(CASE 
        WHEN (ac.data_completamento IS NOT NULL AND ac.data_completamento > ac.scadenza)
          OR (ac.stato <> 'completata' AND CURRENT_DATE > ac.scadenza) THEN 1 
        ELSE 0 
    END) * 100.0) / COUNT(ac.titolo_attivita), 2) AS PercentualeRitardi
FROM EVENTO e
JOIN CHECKLIST c ON e.username_coppia = c.username_coppia AND e.data = c.data_evento
JOIN ATTIVITA_CHECKLIST ac ON c.username_coppia = ac.username_coppia AND c.data_evento = ac.data_evento
WHERE e.stato IN ('in pianificazione', 'confermato')
GROUP BY e.tipo_cerimonia, ac.fase
ORDER BY PercentualeRitardi DESC;
```

---

### STAT-08: Tracciamento Ospiti Ricorrenti e Generosità Quote
*Traccia gli invitati che hanno partecipato a più di un matrimonio gestito dall'agenzia, con aggregazione del numero di partecipazioni e del totale complessivo delle quote donate nelle liste nozze.*
```sql
SELECT 
    p.codice_fiscale AS CodiceFiscale,
    p.nome AS Nome,
    p.cognome AS Cognome,
    COUNT(DISTINCT part.data_evento) AS NumeroMatrimoniPartecipati,
    COALESCE(SUM(qr.importo), 0) AS TotaleQuoteVersate
FROM PERSONA p
JOIN INVITATO i ON p.codice_fiscale = i.codice_fiscale
JOIN PARTECIPAZIONE part ON i.codice_fiscale = part.codice_fiscale
LEFT JOIN QUOTA_REGALO qr ON i.codice_fiscale = qr.codice_fiscale AND part.username_coppia = qr.username_coppia AND part.data_evento = qr.data_evento
WHERE part.stato = 'CONFERMATO'
GROUP BY p.codice_fiscale, p.nome, p.cognome
HAVING COUNT(DISTINCT part.data_evento) > 1
ORDER BY TotaleQuoteVersate DESC, NumeroMatrimoniPartecipati DESC;
```
