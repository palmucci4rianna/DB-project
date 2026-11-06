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

## 5. Problemi e incoerenze nel modello attuale (da risolvere)

### 5.1 Due versioni dello schema in conflitto
| Aspetto | Mermaid `.md`/`.png` (vecchio) | Snippet nel docx `dic26` (nuovo) |
|---|---|---|
| Chiavi | `int id` surrogata ovunque | Chiavi naturali/composte (`username_coppia`, `dipendente_email`, `CF`, `partita_iva`…) |
| Storico | `ASSEGNAZIONE_PLANNER` | `ASSEGNAZIONE_DIPENDENTE` |
| Fornitori | Nessuna `CATEGORIA_FORNITORE` né `COLLABORAZIONE` | Presenti |
| Evento–Preventivo | 1:N | N:M (`EVENTO_PREVENTIVO`, che però usa `int id`) |
| Checklist | `completata` boolean presente | `completata` assente |

→ Decidere **una** versione. Nella relazione lo schema concettuale non ha chiavi surrogate; si
scelgono le chiavi nella fase logica ("Scelta delle chiavi"), dove si possono introdurre id surrogati motivandoli.

### 5.2 Errori puntuali nello snippet `dic26`
- `DIPENDENTE`: PK `dipendente_email` **e** attributo `email` duplicato.
- `RUOLO`: PK `nome` **e** `nome` duplicato. `FORNITORE`: `partita_iva` duplicata.
- `FORNITORE.categoria` (stringa) **e** l'associazione con `CATEGORIA_FORNITORE`: è ridondante, tenere solo l'associazione.
- `EVENTO` ha PK `(username_coppia, data, tipologia)` ma tutte le FK verso l'evento usano solo
  `(username_coppia, evento_data)`. Inoltre `tipologia` e `tipo_cerimonia` si confondono: chiarire
  (tipologia = matrimonio/pre/post; tipo_cerimonia = civile/religiosa/…).
- `COPPIA.username_coppia`: lo username non compare nei requisiti e la coppia non fa login.
- `INVITATO.stato` **e** `PARTECIPAZIONE.stato`: lo stato dipende dall'evento, quindi va **solo** in Partecipazione
  (anche la bozza lo nota: "in invitato ho lo stato → non gestire"). Lo stesso vale per `relazione` con gli sposi
  (un ospite ricorrente può essere amico di una coppia e cugino di un'altra) → spostarla in Partecipazione.
- `INVITATO` PK `CF`: va bene con le chiavi naturali (vedi §7), ma va scritto tra le assunzioni che serve il CF di ogni ospite.
- `PARTECIPAZIONE`: nella lista attributi mancano le FK verso Tavolo e Bomboniera.
- `PRENOTAZIONE` PK `(CF_invitato, id_regalo)`, ma `REGALO` non ha `id_regalo` (la sua PK è `(coppia, data, descrizione)`).
- `ATTIVITA_TIMELINE`: PK `(id_attivita, orario_previsto)` senza FK verso timeline/evento; `responsabile`
  è una stringa ma esiste anche l'associazione con DIPENDENTE. Il responsabile può essere **anche un fornitore**:
  servono due FK opzionali mutuamente esclusive (vincolo da dichiarare).
- `ATTIVITA_CHECKLIST`: manca `completata`/`data_completamento` (serve per la statistica 8), mancano le FK
  verso dipendente responsabile, voce_template e **fornitore** (la bozza dice "collegabile a un fornitore").
- `VOCE_TEMPLATE`: manca l'attributo `fase` citato nel testo.
- `CHECKLIST` PK `id_checklist` senza tipo e senza legame con l'evento.
- `RECENSIONE`: PK con `voto` → sbagliato, la PK è l'evento (1:1).
- `APPUNTAMENTO`: manca la FK verso il dipendente (associazione "conduce").
- `COMUNICAZIONE`: `mittente` stringa nella PK; il mittente può essere la coppia o un dipendente → FK dipendente + campo direzione.
  I "promemoria automatici" sono una funzione dell'app, da togliere dal DB o modellare a parte.
- `DISPONIBILITA`: ha `tipo` e `stato` ma manca la FK verso `MOTIVO_ASSENZA`.
- `EVENTO`–`LOCATION` N:M: mancano gli attributi dell'associazione (`ora_inizio`, `ora_fine`, magari un uso:
  cerimonia/aperitivo/ricevimento). `servizi_inclusi` è multivalore (stringa oppure entità a parte).

### 5.3 Problemi di modellazione più profondi
1. **Preventivo N:M Evento rompe i calcoli economici.** Se un preventivo (e quindi il contratto 1:1) vale per
   più eventi, la statistica 2 (budget vs contratti per evento) e la 4 diventano ambigue. **Consiglio: Preventivo N:1 Evento**
   (come nel mermaid vecchio). Due eventi simili ricevono due preventivi distinti.
2. **Manca il ricavo dell'agenzia.** Il "riepilogo finanziario con fatturato e margine" non è calcolabile: i contratti
   sono soldi della coppia verso i fornitori. Serve per esempio `EVENTO.compenso_agenzia` (o una % sui contratti) e
   magari i costi del personale.
3. **Assegnazione legata alla coppia, ma il limite riguarda gli "eventi attivi".** Se una coppia ha più eventi
   (pre/post), il conteggio non torna. Decidere se assegnare il dipendente all'**evento** oppure contare le coppie.
   Inoltre "un dipendente ricopre ruoli diversi" contraddice `DIPENDENTE }o--|| RUOLO` (N:1).
4. **Persona come generalizzazione.** Il testo la cita (componenti della coppia + dipendenti, e volendo gli invitati),
   ma nello schema non c'è. È utile per il report (servono gerarchie da eliminare): `PERSONA` → {`DIPENDENTE`, `SPOSO`, `INVITATO`},
   con eliminazione motivata. Anche `WeddingPlanner ⊂ Dipendente` è una gerarchia candidata.
5. **Entità 1:1 quasi vuote** (`TIMELINE`, `CHECKLIST`, `LISTA_NOZZE` hanno solo note/totali): ok nel concettuale, ma
   nella fase logica conviene **accorparle in EVENTO** (raffinamento da documentare).
6. **La nota "non totalmente implementabili" n.5 è sbagliata**: il regalo porta all'evento con il percorso
   `PRENOTAZIONE → REGALO → LISTA_NOZZE → EVENTO`. La query 5 è fattibile. La n.8 regge solo se aggiungiamo `data_completamento`.
7. **Blocco fornitore**: `FORNITORE.attivo` e `COLLABORAZIONE.stato = sospeso` si sovrappongono. Scegliere uno solo
   (consiglio: il blocco come record storico in COLLABORAZIONE o un'entità BLOCCO con date e motivo).
8. **Scope.** Ci sono circa 28 entità e circa 23 operazioni. Siamo in 3, quindi va bene (1453, da 3 persone, aveva circa 35 tabelle).

### 5.4 Ridondanze candidate (per la sezione "Analisi delle ridondanze")
| Attributo | Derivabile da | Operazioni coinvolte |
|---|---|---|
| `EVENTO.n_invitati_confermati` | COUNT di Partecipazione con stato CONFERMATO | aggiornamento tavoli, statistiche 4/7 → **ottimo caso di studio** |
| `LISTA_NOZZE.totale_raccolto` | SUM(Prenotazione.quota) | nuova prenotazione, visualizzazione lista |
| `LISTA_NOZZE.totale_desiderato` | SUM(Regalo.prezzo) | |
| `FORNITORE.valutazione_interna` | AVG(Collaborazione.valutazione) | statistiche fornitori |
| `CONTRATTO.saldo` | importo_definitivo − acconto | |
| `REGALO.stato` | Prenotazioni sul regalo | |
| `RECENSIONE.stagione` | data dell'evento | portfolio |
| `ASSEGNAZIONE.attiva` | `data_fine IS NULL` | riassegnazione, statistica 3 |

### 5.5 Vincoli inespressi da dichiarare
- Una sola assegnazione attiva per coppia (o evento) alla volta.
- Numero di eventi attivi per dipendente ≤ `RUOLO.max_eventi_contemporanei`.
- Solo le partecipazioni CONFERMATO hanno tavolo/menù/bomboniera; il tavolo deve appartenere **allo stesso evento**.
- Persone sedute a un tavolo ≤ capienza; invitati confermati ≤ capienza della location.
- Contratto solo da un preventivo `accettato`; somma delle quote ≤ prezzo del regalo (se regalo multiplo).
- Non si richiedono preventivi a un fornitore bloccato.
- `ora_fine > ora_inizio` per le location dell'evento; scadenza dell'attività = data evento − `giorni_prima`.
- Recensione e foto solo per eventi con stato `completato`.

---

## 6. Decisioni prese (06/11/2026)

| # | Tema | Decisione |
|---|---|---|
| 1 | Gruppo | **3 persone** → scope ampio ok (paragonabile a 1453), niente tagli |
| 2 | Proposta | Già approvata, ma avevamo 2 idee: va **riscritta e ricaricata** con solo il wedding planner (sarà accettata) |
| 3 | Consegna | **Metà dicembre 2026**, scritto a gennaio 2027 |
| 4 | DBMS | **MySQL** |
| 5 | App | Java + **JavaFX o Swing** (da decidere) + **JDBC** puro |
| 6 | Schema ER | **DB-Main** (il mermaid resta solo come bozza) |
| 7 | Chiavi | **Chiavi naturali, niente id surrogati** (richiesta della prof). La prof apprezza una **buona gestione dei template** (come TemplateChecklist/VoceTemplate) |
| 8 | Preventivo–Evento | **N:1**: ogni preventivo riguarda un solo evento (via la tabella EVENTO_PREVENTIVO) |
| 9 | Assegnazione dipendente | All'**Evento** (non alla coppia) → coerente con `max_eventi_contemporanei` |
| 10 | Ruoli del dipendente | **Più ruoli** per dipendente (N:M) — *WIP* |
| 11 | Dominio | L'ER modella **una sola agenzia (la nostra)** e i suoi dipendenti; nessuna entità AGENZIA. Il prezzo sta nel preventivo, legato all'evento |
| 12 | Lista nozze | Regalo **prenotabile da più invitati**, ognuno con la sua quota (come già nella bozza) |
| 13 | Persone | **Sì a PERSONA** come generalizzazione (dipendenti, coniugi, invitati) |

### Ancora aperto
- [ ] JavaFX o Swing
- [ ] Dettaglio dei ruoli multipli (N:M semplice o con storico/date)
- [ ] Ricavi dell'agenzia: proposta inserita nell'ER (vedi §8, "Ricavi"), da confermare
- [ ] Chiave naturale per ogni entità (vedi §7)
- [ ] Estendere il pattern template anche ad altro (es. **template di timeline** per tipo di cerimonia)

---

## 7. Note di modellazione

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

## 8. Bozza ER in DB-Main (`er/wedding-planner.lun`, 06/11/2026)

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
