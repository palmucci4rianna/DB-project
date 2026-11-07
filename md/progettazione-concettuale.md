# Progetto di Basi di Dati: Wedding Planner
## Documentazione di Analisi dei Requisiti e Progettazione Concettuale
**Corso di Basi di Dati — Università di Bologna (Prof. D. Maio, Prof.ssa A. Franco)**

---

# PARTE 1: ANALISI DEI REQUISITI

## 1.1 Descrizione Generale del Dominio
L'obiettivo del progetto è la realizzazione di una base di dati a supporto della gestione operativa e strategica di un'agenzia professionale di organizzazione matrimoni (*Wedding Planner*). Il sistema copre l'intero ciclo di vita dell'evento:
1. **Fase di Avvio e Consulenza:** Registrazione della coppia (composta da due persone fisiche censite con dati anagrafici e codice fiscale), assegnazione di un wedding planner dello staff con gestione del limite di eventi contemporanei per ruolo e storico delle riassegnazioni.
2. **Definizione dell'Evento:** Pianificazione del budget concordato, scelta delle location (con fasce orarie e capienze), data e tipologia di cerimonia (civile, religiosa, simbolica, all'aperto).
3. **Gestione Fornitori e Contrattualistica:** Catalogo fornitori per categoria merceologica, storico delle collaborazioni e valutazioni di agenzia, emissione e confronto di preventivi (ciascuno relativo a uno specifico evento, cardinalità 1:N), stipula dei contratti formali con tracciamento di acconti, saldi e penali, blocco cautelativo di fornitori inadempienti.
4. **Logistica e Allestimenti:** Disposizione degli invitati ai tavoli, assegnazione delle tipologie di bomboniere, programmazione della timeline della giornata dell'evento con orari e responsabili.
5. **Checklist Operativa:** Generazione della checklist dell'evento a partire da template riutilizzabili parametrici per tipologia di cerimonia (con calcolo automatico delle scadenze tramite giorni di anticipo) e monitoraggio dei ritardi di completamento mediante data effettiva.
6. **Lista Nozze e Quote:** Catalogo regali (sia singoli interi non frazionabili, sia frazionabili a quote libere o fisse), tracciamento delle quote versate dagli invitati legati alla loro partecipazione con messaggi di auguri, calcolo del raccolto rispetto al totale desiderato.
7. **Relazione con la Coppia e Portfolio:** Tracciamento delle comunicazioni formali (con allegati) e degli appuntamenti, raccolta della recensione post-evento e galleria fotografica per il portfolio di agenzia.
8. **Analisi e Statistiche Direzionali:** Interrogazioni statistiche aggregate su produttività del personale, scostamenti di budget, gradimento per rito, conversion rate dei preventivi, frequenza d'uso delle location, ritardi checklist e generosità degli ospiti ricorrenti.

---

## 1.2 Rilevamento delle Ambiguità e Soluzioni Proposte

Come prescritto dalla metodologia accademica di Basi di Dati, i requisiti espressi in linguaggio naturale contengono ambiguità lessicali e concettuali che vengono esplicitate e risolte prima della modellazione.

| Termine Ambiguo | Descrizione dell'Ambiguità | Risoluzione e Standard Adottato |
| :--- | :--- | :--- |
| **Persona vs Dipendente vs Sposo vs Invitato** | Nel testo compaiono figure umane con compiti diversi ma dati anagrafici comuni (CF, nome, cognome, email, telefono). | Introduzione dell'entità generalizzata **`PERSONA`** come radice comune. `DIPENDENTE` e `INVITATO` sono specializzazioni gerarchiche (IS-A) di `PERSONA`. I due membri della `COPPIA` sono istanze di `PERSONA` collegate tramite l'associazione di composizione `CONIUGI`. |
| **Cliente vs Coppia** | Il testo si riferisce a volte ai singoli sposi, a volte alla "coppia", a volte al "cliente". | L'unità contrattuale e committente per l'agenzia è la **`COPPIA`**, identificata dal proprio `Username` e composta da esattamente due persone (`PERSONA`, coniuge 1 e coniuge 2). |
| **Wedding Planner vs Dipendente vs Ruolo** | Il wedding planner viene inteso come figura professionale, ma lo staff copre anche ruoli diversi e un dipendente può avere più mansioni. | `DIPENDENTE` è l'anagrafica del collaboratore aziendale; `RUOLO` definisce le mansioni (Planner Senior, Assistente, On-Site Coordinator, Amministrativo). L'associazione è molti-a-molti ($N:M$) reificata in `RUOLO_DIPENDENTE`, consentendo a un dipendente di ricoprire più ruoli. |
| **Matrimonio vs Evento** | Nel testo si parla indifferentemente di matrimonio o evento. | L'entità centrale è **`EVENTO`**, debole rispetto alla `COPPIA` e identificata da `{COPPIA, Data}`. L'evento specifica la tipologia di cerimonia, il budget approvato e aggrega location, tavoli, timeline, checklist e lista nozze. |
| **Invitato vs Partecipazione** | L'invitato possiede dati anagrafici propri ma anche informazioni specifiche relative all'evento (stato RSVP, menù, allergie, tavolo). | Separazione netta: `INVITATO` modella il soggetto (specializzazione di `PERSONA`); `PARTECIPAZIONE` è l'entità reificata molti-a-molti che lega l'invitato a un determinato `EVENTO`. |
| **Regalo vs Quota vs Prenotazione** | Nel testo si parla di regalo prenotabile da uno o più invitati tramite quota. | `REGALO` è la voce desiderata nella lista nozze (singolo intero o frazionabile a quote); `PRENOTAZIONE` è la quota/versamento effettuato da un ospite mediante la sua `PARTECIPAZIONE` all'evento. |
| **Preventivo vs Contratto** | Il fornitore invia preventivi, alcuni dei quali si trasformano in contratti. | Il `PREVENTIVO` è la proposta economica formulata per uno specifico evento (relazione 1:N da Evento); il `CONTRATTO` è l'accordo formale vincolante generato 1:1 dall'accettazione del preventivo. |
| **Template vs Checklist** | La checklist è l'elenco concreto per l'evento; il template è il modello riutilizzabile. | `TEMPLATE_CHECKLIST` e `VOCE_TEMPLATE` definiscono il modello per rito con giorni di anticipo (`GiorniPrima`); `CHECKLIST` e `ATTIVITA_CHECKLIST` rappresentano l'istanza operativa concreta legata all'evento, con scadenze temporali effettive. |

---

## 1.3 Glossario dei Termini

| Termine | Descrizione | Sinonimi | Collegamenti |
| :--- | :--- | :--- | :--- |
| **Persona** | Entità radice dei soggetti fisici censiti nel sistema, provvista di codice fiscale e recapiti. | Soggetto, Anagrafica base | Dipendente, Invitato, Coppia |
| **Coppia** | Entità committente formata dai due coniugi (ciascuno istanza di Persona) che stipula il servizio. | Clienti, Sposi | Persona, Evento, AssegnazioneDipendente, Comunicazione |
| **Dipendente** | Membro dello staff aziendale (specializzazione di Persona) con contratto e stato lavorativo. | Staff, Personale | Persona, RuoloDipendente, Disponibilità, Assegnazione |
| **Ruolo** | Mansione professionale codificata con limite massimo di eventi attivi contemporanei. | Qualifica, Livello | RuoloDipendente |
| **RuoloDipendente** | Reificazione dell'associazione molti-a-molti tra Dipendente e Ruolo (più ruoli per dipendente). | Inquadramento, Abilitazione | Dipendente, Ruolo |
| **Disponibilità** | Calendario delle presenze o delle assenze programmate/sopraggiunte del dipendente. | Calendario, Turno | Dipendente, MotivoAssenza |
| **MotivoAssenza** | Tipologia codificata di indisponibilità (ferie, malattia, congedo, permessi, dimissioni). | Giustificativo assenza | Disponibilità |
| **AssegnazioneDipendente** | Tracciamento storico del dipendente assegnato alla cura di una determinata coppia. | Incarico, Presa in carico | Coppia, Dipendente |
| **Evento** | Celebrazione nuziale organizzata in una data precisa, con budget approvato e tipo di rito. | Matrimonio, Nozze | Coppia, Location, Timeline, Checklist, ListaNozze, Preventivo |
| **Location** | Struttura fisica in cui ha luogo una fase dell'evento con capienza e canone d'affitto. | Sede, Villa, Chiesa | Evento |
| **Fornitore** | Impresa o professionista esterno convenzionato che eroga servizi specialistici per eventi. | Vendor, Partner | CategoriaFornitore, Collaborazione, Preventivo |
| **CategoriaFornitore** | Settore merceologico del fornitore (catering, foto/video, fiori, musica, trasporti, abiti, ecc.). | Settore, Categoria | Fornitore |
| **Collaborazione** | Periodo storico di convenzione e partnership tra l'agenzia e un fornitore esterno. | Accordo agenzia | Fornitore |
| **Preventivo** | Proposta economica dettagliata emessa da un fornitore per uno specifico evento (1:N). | Offerta economica | Fornitore, Evento, Dipendente, Contratto |
| **Contratto** | Accordo vincolante generato dall'accettazione del preventivo, con acconto, saldo e penali. | Scrittura contrattuale | Preventivo |
| **Invitato** | Persona fisica censita come potenziale ospite di uno o più matrimoni (specializzazione di Persona). | Ospite anagrafico | Persona, Partecipazione |
| **Partecipazione** | Adesione dell'ospite a uno specifico evento, con stato (RSVP), menù, allergie e tavolo. | Invito evento, Presenza | Invitato, Evento, Tavolo, Bomboniera, Prenotazione |
| **Tavolo** | Postazione della sala ricevimento assegnata agli ospiti confermati con capienza massima. | Postazione, Tavolata | Evento, Partecipazione |
| **Bomboniera** | Tipologia di dono/ricordo destinata a specifiche categorie di partecipanti. | Omaggio, Ricordo | Partecipazione |
| **Timeline** | Scaletta cronologica e programma orario della regia del giorno delle nozze. | Scaletta, Programma orario | Evento, AttivitaTimeline |
| **AttivitaTimeline** | Singolo blocco orario della giornata con durata, luogo, note e responsabile dello staff. | Momento, Tappa regia | Timeline, Dipendente |
| **TemplateChecklist** | Modello astratto predefinito di attività organizzative, suddiviso per tipologia di cerimonia. | Modello checklist, Piano tipo | VoceTemplate, Checklist |
| **VoceTemplate** | Compito standard del template con priorità, fase e giorni di anticipo previsti (giorni_prima). | Task tipo, Attività standard | TemplateChecklist, AttivitaChecklist |
| **Checklist** | Piano di lavoro organizzativo operativo associato a uno specifico evento. | Piano operativo compiti | Evento, AttivitaChecklist, TemplateChecklist |
| **AttivitaChecklist** | Singola operazione da svolgere per l'evento con scadenza calcolata e data completamento. | Task evento, Compito | Checklist, VoceTemplate, Dipendente |
| **ListaNozze** | Registro integrato dei doni desiderati dalla coppia per un evento. | Registro doni, Gift list | Evento, Regalo |
| **Regalo** | Singola voce della lista nozze con prezzo, tipologia, modalità frazionamento e stato. | Dono, Articolo | ListaNozze, Prenotazione |
| **Prenotazione** | Quota monetaria o donazione versata da un partecipante con dedica per un regalo. | Quota regalo, Contributo | Regalo, Partecipazione |
| **Comunicazione** | Messaggio formale o scambio documentale tra il wedding planner e la coppia. | Messaggio, Thread | Coppia, Dipendente |
| **Appuntamento** | Incontro programmato (di persona o videocall) tra il planner e la coppia con verbale. | Consulenza, Riunione | Coppia, Dipendente |
| **Recensione** | Giudizio qualitativo e punteggio espresso dalla coppia al termine delle nozze. | Valutazione sposi | Evento |
| **Foto** | Fotografia dell'evento archiviata per il portfolio aziendale di agenzia. | Scatto portfolio | Evento |

---

## 1.4 Specifiche Ristrutturate in Linguaggio Naturale

### A. Frasi di Carattere Generale
1. L'agenzia organizza eventi matrimoniali gestendo le relazioni con le coppie committenti, il coordinamento del personale interno, l'ingaggio dei fornitori esterni, la logistica del giorno delle nozze e il portfolio dei lavori realizzati.
2. La piattaforma centralizza i dati anagrafici dei soggetti tramite un'entità generalizzata `PERSONA`, evitando duplicazioni di recapiti o incongruenze tra ruoli diversi (ad esempio un dipendente o un fornitore che sia a sua volta invitato a un evento).
3. Ogni matrimonio è unico ed è caratterizzato da vincoli temporali stringenti sia nei preparativi (checklist) sia nella giornata stessa dell'evento (timeline).

### B. Frasi per Concetto / Macro-Area

#### 1. Persone, Coppie e Staff Aziendale
- Il sistema censisce le persone fisiche mediante Codice Fiscale, nome, cognome, indirizzo email personale e recapito telefonico.
- Una coppia committente è identificata da uno username univoco ed è composta da esattamente due persone fisiche censite nel sistema (coniuge 1 e coniuge 2). La coppia indica una data prevista per le nozze e un budget indicativo di spesa.
- L'agenzia impiega dipendenti (specializzazione di Persona), per ciascuno dei quali memorizza l'email aziendale, la data di assunzione, la data eventuale di fine rapporto e lo stato lavorativo (attivo, sospeso, dimesso).
- I dipendenti possono ricoprire più ruoli professionali contemporaneamente (es. Senior Planner, Assistente, Coordinatore on-site, Amministrativo). Ciascun ruolo stabilisce il numero massimo di eventi contemporanei che un dipendente può seguire.
- A ogni coppia viene assegnato un wedding planner disponibile dello staff. Il sistema memorizza lo storico completo delle assegnazioni (data inizio, data fine, motivo cambio e flag di assegnazione attiva corrente, al massimo una attiva per coppia).
- Il calendario del personale è gestito tramite periodi di disponibilità e indisponibilità con date di inizio e fine, motivate da causali codificate (ferie, malattia, congedo, ecc.).

#### 2. Evento e Location
- Un evento rappresenta la celebrazione delle nozze di una coppia in una data determinata. È caratterizzato da budget approvato definitivo, numero invitati previsti, numero invitati confermati, tipologia di cerimonia (civile, religiosa, simbolica, all'aperto) e stato operativo.
- Un evento può svolgersi presso una o più location (identificate da nome e indirizzo, con capienza massima e prezzo di locazione), con indicazione della fascia oraria (orario inizio e fine previsti).

#### 3. Fornitori, Preventivi (1:N) e Contratti
- L'agenzia gestisce un catalogo di fornitori esterni (identificati da Partita IVA, con ragione sociale, recapiti, zona di operatività, stato attivo/bloccato e valutazione agenzia), suddivisi per categoria merceologica.
- Per ogni fornitore si conserva lo storico delle convenzioni e collaborazioni con l'agenzia (date di vigenza, stato accordo e valutazione qualitativa).
- Per ciascun evento, il dipendente responsabile richiede uno o più preventivi ai fornitori. Ogni preventivo è intestato a uno specifico evento (relazione 1:N dall'evento) ed è identificato dal numero progressivo interno al fornitore, con data emissione, data scadenza, importo offerto e stato.
- L'accettazione di un preventivo genera esattamente un contratto formale con data firma, importo definitivo concordato, acconto, saldo, stato pagamenti e penali.

#### 4. Ospiti, Partecipazioni, Tavoli e Bomboniere
- Gli ospiti dell'evento sono persone fisiche censite come invitati (specializzazione di Persona con l'indicazione della relazione con la coppia).
- La partecipazione a uno specifico evento è formalizzata dall'entità reificata Partecipazione, che traccia lo stato di conferma (CONFERMATO, RIFIUTATO, IN_ATTESA), allergie, preferenze pasto, necessità di navetta/trasporto e note personali.
- L'evento definisce la disposizione dei tavoli nella sala (identificati da codice/nome per evento con capienza). A ogni tavolo possono sedere solo invitati con partecipazione confermata.
- All'evento sono associate bomboniere suddivise per tipologia e target.

#### 5. Timeline della Giornata delle Nozze
- Per ogni evento è istituita una timeline oraria coordinata per la regia della giornata.
- La timeline si articola in singole attività orarie identificate dall'orario di inizio, con durata in minuti, titolo, descrizione, luogo specifico nella location, stato di avanzamento, note per lo staff, note per gli sposi e la figura del personale responsabile del coordinamento.

#### 6. Template e Checklist Organizzativa
- L'amministratore configura i modelli di pianificazione (Template Checklist) suddivisi per tipologia di rito, composti da voci di template con titolo, descrizione, priorità, fase organizzativa e giorni di anticipo rispetto all'evento (`giorni_prima`).
- All'apertura dell'evento viene creata la checklist operativa (1:1 con l'evento). Le attività della checklist vengono derivate automaticamente calcolando la scadenza precisa:
  $$\text{Scadenza} = \text{EVENTO.Data} - \text{VOCE_TEMPLATE.GiorniPrima}$$
- Ciascuna attività della checklist traccia la data di completamento effettiva (`DataCompletamento`), consentendo il calcolo metrico dei ritardi rispetto alla scadenza.

#### 7. Lista Nozze, Regali e Quote
- L'evento include una lista nozze con indicazione del valore economico complessivo desiderato e del totale raccolto.
- I regali sono voci della lista nozze provviste di prezzo, eventuale negozio/link web, stato e modalità di frazionamento (`INTERO` per beni indivisibili, `QUOTE_LIBERE` o `QUOTE_FISSE` per fondi aperti come il viaggio di nozze).
- Gli invitati registrati all'evento (sia che abbiano confermato o meno la partecipazione fisica) effettuano donazioni o prenotazioni collegando la loro Partecipazione al Regalo, con importo quota, timestamp e biglietto di auguri.

#### 8. Comunicazioni, Appuntamenti e Portfolio
- Il sistema registra tutte le comunicazioni scambiate con la coppia (timestamp, mittente, oggetto, testo, argomento e allegati) e gli appuntamenti (modalità, durata, resoconto).
- Al termine dell'evento (stato completato), la coppia compila la recensione con voto e tag di stile, e l'evento viene arricchito con la galleria fotografica per il portfolio pubblico.

---

## 1.5 Requisiti Funzionali e Operazioni sui Dati

### Operazioni Transazionali
1. **OP-01:** Registrazione di una nuova coppia con associazione dei due coniugi (istanze di Persona) e contestuale assegnazione del primo wedding planner disponibile.
2. **OP-02:** Creazione dell'evento con date, budget e assegnazione delle location con rispettive fasce orarie.
3. **OP-03:** Istanziazione della checklist operativa a partire dal template del rito prescelto con calcolo delle scadenze tramite i giorni di anticipo.
4. **OP-04:** Censimento di un nuovo fornitore nel catalogo e associazione alla categoria di pertinenza.
5. **OP-05:** Richiesta di preventivo a un fornitore per un determinato evento (relazione 1:N).
6. **OP-06:** Approvazione di un preventivo con stipula del contratto fornitore e registrazione dell'acconto.
7. **OP-07:** Inserimento di un invitato e creazione della partecipazione all'evento con preferenze menù e intolleranze.
8. **OP-08:** Conferma RSVP dell'ospite e assegnazione del posto al tavolo nel rispetto della capienza massima.
9. **OP-09:** Creazione della timeline della giornata con assegnazione dei momenti orari al coordinatore di staff.
10. **OP-10:** Inserimento di regali nella lista nozze e registrazione dei versamenti di quote da parte delle partecipazioni invitate.
11. **OP-11:** Completamento di un'attività della checklist con memorizzazione della data di completamento effettiva.
12. **OP-12:** Chiusura evento a completato, inserimento della recensione della coppia e archiviazione delle fotografie a portfolio.

### Interrogazioni Statistiche Direzionali (Query Complesse)
1. **STAT-01:** Analisi fornitori maggiormente contrattualizzati per categoria nell'ultimo anno, con totale contratti, fatturato complessivo e importo medio.
2. **STAT-02:** Monitoraggio dello scostamento percentuale tra budget preventivo approvato e spesa effettiva impegnata nei contratti, evidenziando gli eventi oltre la soglia di allerta.
3. **STAT-03:** Calcolo del tasso di conversione commerciale (contratti stipulati / preventivi emessi) per ciascun fornitore.
4. **STAT-04:** Produttività e gradimento dei wedding planner: individuazione del dipendente con il maggior numero di eventi gestiti con successo ponderato con il punteggio medio a portfolio.
5. **STAT-05:** Benchmark di costo medio, affluenza effettiva e soddisfazione suddiviso per tipologia di cerimonia.
6. **STAT-06:** Frequenza d'uso e capienza media effettiva delle location per tipologia di matrimonio.
7. **STAT-07:** Monitoraggio ritardi checklist: calcolo della percentuale di attività completate oltre la scadenza o attualmente scadute, aggregate per fase organizzativa e rito.
8. **STAT-08:** Analisi degli ospiti ricorrenti: individuazione degli invitati che hanno preso parte a più matrimoni gestiti dall'agenzia con aggregazione delle quote totali donate nelle liste nozze.

---

# PARTE 2: PROGETTAZIONE CONCETTUALE

## 2.1 Principi Metodologici di Modellazione
1. **Gerarchia di Generalizzazione `PERSONA`:** Tutti i soggetti umani (`DIPENDENTE`, `INVITATO`, e i componenti della `COPPIA`) condividono l'anagrafica di base (`CodiceFiscale`, `Nome`, `Cognome`, `Email`, `Telefono`). `DIPENDENTE` e `INVITATO` sono specializzazioni gerarchiche esclusive o sovrapponibili.
2. **Collegamento tra `COPPIA` e `PERSONA`:** La `COPPIA` è l'entità committente formata da esattamente due persone. È collegata a `PERSONA` tramite l'associazione `CONIUGI` con cardinalità `(2, 2)` da `COPPIA` a `PERSONA` e `(0, 1)` da `PERSONA` a `COPPIA`. Nella traduzione logica, `COPPIA` conterrà due chiavi esterne non nulle: `CF_Coniuge1` e `CF_Coniuge2` con vincolo `CHECK (CF_Coniuge1 <> CF_Coniuge2)`.
3. **Ruoli Multipli del Personale:** L'associazione tra `DIPENDENTE` e `RUOLO` è molti-a-molti ($N:M$) reificata in `RUOLO_DIPENDENTE` con attributi di abilitazione e data di assegnazione.
4. **Assoluto Divieto di ID Surrogati (`int id PK`):** Nessun identificatore artificiale. Si utilizzano chiavi naturali o identificatori esterni (misti o puri) tramite associazioni identificanti con cardinalità `(1, 1)`.
5. **Reificazione di Associazioni:** `PARTECIPAZIONE`, `PRENOTAZIONE`, `ASSEGNAZIONE_DIPENDENTE`, `RUOLO_DIPENDENTE`.

---

## 2.2 Schema Scheletro E/R

```
                  +-------------------+
                  |      PERSONA      |
                  +-------------------+
                    ^       |       ^
             (IS-A) |       | (2,2) | (IS-A)
       +------------+       |       +------------+
       |                    v                    |
+--------------+     +--------------+     +--------------+
|  DIPENDENTE  |     |    COPPIA    |     |   INVITATO   |
+--------------+     +--------------+     +--------------+
   |        |               |                    |
(N,M)     (1,N)           (1,N)                (1,N)
   v        v               v                    v
[RUOLO] [ASSEGN.] ------> [EVENTO] ----------> [PARTECIPAZIONE]
                            |                     |       |
                    +-------+-------+             |       |
                    |       |       |             v       v
                    v       v       v          [TAVOLO] [BOMB.]
                [LOCAT.] [TIMEL.] [CHECK.]        |
                            |       |             |
                            v       v             v
                         [ATT_TL] [ATT_CK] <--- [PRENOTAZIONE]
                                    ^             |
                                    |             v
                              [VOCE_TPL]       [REGALO]
                                    ^             ^
                                    |             |
                              [TPL_CHECK.]     [LISTA_NOZZE]
```

---

## 2.3 Dizionario Dettagliato delle Entità

### Gruppo 1: Soggetti Umani, Coppie ed Eventi

#### `PERSONA`
* **Tipo:** Entità Forte (radice della gerarchia di generalizzazione dei soggetti umani).
* **Identificatore Naturale:** `CodiceFiscale` (identificatore univoco nazionale).
* **Attributi:**
  * `CodiceFiscale`: stringa `(1,1)` — **Identificatore**
  * `Nome`: stringa `(1,1)`
  * `Cognome`: stringa `(1,1)`
  * `Email`: stringa `(1,1)` — Chiave alternativa
  * `Telefono`: stringa `(0,1)`

#### `COPPIA`
* **Tipo:** Entità Forte (committente contrattuale).
* **Identificatore Naturale:** `Username` (credenziali portale clienti).
* **Attributi:**
  * `Username`: stringa `(1,1)` — **Identificatore**
  * `DataPrevista`: data `(1,1)`
  * `BudgetIndicativo`: decimale `(1,1)`
* **Associazione Identificante con Persona:** Connessa a esattamente due istanze di `PERSONA` tramite associazione `CONIUGI` con cardinalità `(2, 2)`.

#### `EVENTO`
* **Tipo:** Entità Debole (identificazione esterna mista).
* **Entità Dominante:** `COPPIA`.
* **Identificatore:** `{COPPIA, Data}` tramite associazione `ORGANIZZAZIONE`.
* **Attributi:**
  * `Data`: data `(1,1)` — **Componente interna identificatore**
  * `BudgetApprovato`: decimale `(1,1)`
  * `NInvitatiPrevisti`: intero `(1,1)`
  * `NInvitatiConfermati`: intero `(1,1)`
  * `TipoCerimonia`: stringa `(1,1)` (civile, religiosa, simbolica, all'aperto)
  * `Stato`: stringa `(1,1)` (in pianificazione, confermato, completato, annullato)

---

### Gruppo 2: Personale, Ruoli e Calendario

#### `DIPENDENTE`
* **Tipo:** Specializzazione (IS-A) di `PERSONA`.
* **Identificatore:** Ereditato da `PERSONA` (`CodiceFiscale`).
* **Attributi Specifici:**
  * `EmailAziendale`: stringa `(1,1)` — Chiave alternativa univoca aziendale
  * `DataAssunzione`: data `(1,1)`
  * `DataFineRapporto`: data `(0,1)`
  * `Stato`: stringa `(1,1)` (attivo, sospeso, dimesso)

#### `RUOLO`
* **Tipo:** Entità Forte.
* **Identificatore Naturale:** `NomeRuolo` (es. Senior Planner, Assistente, Coordinatore On-Site, Amministrativo).
* **Attributi:**
  * `NomeRuolo`: stringa `(1,1)` — **Identificatore**
  * `Descrizione`: stringa `(1,1)`
  * `MaxEventiContemporanei`: intero `(1,1)`

#### `RUOLO_DIPENDENTE`
* **Tipo:** Entità Reificata (associazione molti-a-molti tra Dipendente e Ruolo).
* **Entità Dominanti:** `DIPENDENTE` e `RUOLO`.
* **Identificatore:** `{DIPENDENTE, RUOLO}` tramite associazioni `ASSEGNAZIONE_RUOLO` e `INQUADRAMENTO_RUOLO`.
* **Attributi:**
  * `DataAssegnazione`: data `(1,1)`
  * `Principale`: booleano `(1,1)` (indica il ruolo primario contrattuale)

#### `MOTIVO_ASSENZA`
* **Tipo:** Entità Forte (causale codificata collegata sia a DIPENDENTE/DISPONIBILITA per le assenze lavorative, sia ad APPUNTAMENTO per giustificare incontri annullati o mancati).
* **Identificatore Naturale:** `Categoria` (ferie, malattia, congedo, permessi, dimissioni).
* **Attributi:**
  * `Categoria`: stringa `(1,1)` — **Identificatore**
  * `Descrizione`: stringa `(1,1)`
  * `Remunerata`: booleano `(1,1)`

#### `DISPONIBILITA`
* **Tipo:** Entità Debole (identificazione esterna mista).
* **Entità Dominante:** `DIPENDENTE`.
* **Identificatore:** `{DIPENDENTE, DataInizio}` tramite associazione `CALENDARIO`.
* **Attributi:**
  * `DataInizio`: data `(1,1)` — **Componente interna identificatore**
  * `DataFine`: data `(1,1)`
  * `Tipo`: stringa `(1,1)` (disponibile, indisponibile)
  * `Stato`: stringa `(1,1)` (approvato, in attesa)

#### `ASSEGNAZIONE_DIPENDENTE`
* **Tipo:** Entità Reificata (storico presa in carico della coppia da parte del planner).
* **Entità Dominanti:** `COPPIA` e `DIPENDENTE`.
* **Identificatore:** `{COPPIA, DIPENDENTE, DataInizio}`.
* **Attributi:**
  * `DataInizio`: data `(1,1)` — **Componente interna identificatore**
  * `DataFine`: data `(0,1)`
  * `MotivoCambio`: stringa `(0,1)`
  * `Attiva`: booleano `(1,1)` (al massimo 1 attiva per coppia)

---

### Gruppo 3: Fornitori, Preventivi (1:N) e Contratti

#### `CATEGORIA_FORNITORE`
* **Tipo:** Entità Forte (settore merceologico con associazione diretta 1:N verso FORNITORE).
* **Identificatore Naturale:** `NomeCategoria` (catering, foto/video, fiori, musica, trasporti, abiti, cake design, celebrante).
* **Attributi:**
  * `NomeCategoria`: stringa `(1,1)` — **Identificatore**
  * `Descrizione`: stringa `(1,1)`

#### `FORNITORE`
* **Tipo:** Entità Forte.
* **Identificatore Naturale:** `PartitaIVA` (identificatore fiscale nazionale).
* **Attributi:**
  * `PartitaIVA`: stringa `(1,1)` — **Identificatore**
  * `RagioneSociale`: stringa `(1,1)`
  * `Email`: stringa `(1,1)`
  * `Telefono`: stringa `(1,1)`
  * `ZonaOperativita`: stringa `(1,1)`
  * `ValutazioneInterna`: decimale `(1,1)`
  * `Attivo`: booleano `(1,1)`

#### `COLLABORAZIONE`
* **Tipo:** Entità Debole (identificazione esterna mista).
* **Entità Dominante:** `FORNITORE`.
* **Identificatore:** `{FORNITORE, DataInizio}` tramite associazione `STORICO_FORNITORE`.
* **Attributi:**
  * `DataInizio`: data `(1,1)` — **Componente interna identificatore**
  * `DataFine`: data `(0,1)`
  * `Stato`: stringa `(1,1)` (attiva, sospesa, terminata)
  * `Note`: stringa `(0,1)`
  * `Valutazione`: decimale `(1,1)`

#### `PREVENTIVO`
* **Tipo:** Entità Debole (identificazione esterna mista).
* **Entità Dominante:** `FORNITORE` ed `EVENTO` (cardinalità 1:N dall'evento, ogni preventivo è emesso per un preciso evento).
* **Identificatore:** `{FORNITORE, NumeroPreventivo}` tramite associazione `EMISSIONE_PREV`.
* **Attributi:**
  * `NumeroPreventivo`: intero `(1,1)` — **Componente interna identificatore**
  * `DataEmissione`: data `(1,1)`
  * `DataScadenza`: data `(1,1)`
  * `Importo`: decimale `(1,1)`
  * `Descrizione`: stringa `(1,1)`
  * `Stato`: stringa `(1,1)` (in attesa, confermato, rifiutato)

#### `CONTRATTO`
* **Tipo:** Entità Debole (identificazione esterna pura 1:1 da Preventivo accettato).
* **Entità Dominante:** `PREVENTIVO`.
* **Identificatore:** `{PREVENTIVO}` tramite associazione `STIPULA_CONTRATTO`.
* **Attributi:**
  * `DataFirma`: data `(1,1)`
  * `ImportoDefinitivo`: decimale `(1,1)`
  * `Acconto`: decimale `(1,1)`
  * `Saldo`: decimale `(1,1)`
  * `StatoPagamento`: stringa `(1,1)` (acconto versato, saldato, insoluto)
  * `Penali`: stringa `(0,1)`

---

### Gruppo 4: Logistica dell'Evento, Location e Tavoli

#### `LOCATION`
* **Tipo:** Entità Forte.
* **Identificatore Naturale Composito:** `{Nome, Indirizzo}`.
* **Attributi:**
  * `Nome`: stringa `(1,1)` — **Componente identificatore**
  * `Indirizzo`: stringa `(1,1)` — **Componente identificatore**
  * `CapienzaMax`: intero `(1,1)`
  * `PrezzoAffitto`: decimale `(1,1)`
  * `ServiziInclusi`: testo `(1,1)`

#### `TAVOLO`
* **Tipo:** Entità Debole (identificazione esterna mista).
* **Entità Dominante:** `EVENTO`.
* **Identificatore:** `{EVENTO, NomeNumero}` tramite associazione `DISPOSIZIONE`.
* **Attributi:**
  * `NomeNumero`: stringa `(1,1)` — **Componente interna identificatore**
  * `Capienza`: intero `(1,1)`
  * `Posizione`: stringa `(1,1)`

#### `BOMBONIERA`
* **Tipo:** Entità Forte (tipologia di dono destinata direttamente agli INVITATI).
* **Identificatore Naturale:** `Tipologia` (testimoni, genitori, ospiti adulti, bambini).
* **Attributi:**
  * `Tipologia`: stringa `(1,1)` — **Identificatore**
  * `Descrizione`: stringa `(1,1)`
  * `Target`: stringa `(1,1)`

---

### Gruppo 5: Regia del Giorno (TIMELINE) e Gestione Operativa (CHECKLIST)

#### `TIMELINE`
* **Tipo:** Entità Debole (identificazione esterna pura 1:1 con `EVENTO`).
* **Entità Dominante:** `EVENTO`.
* **Identificatore:** `{EVENTO}` tramite associazione `HA_TIMELINE`.
* **Attributi:**
  * `NoteRegia`: testo `(0,1)`
  * `StatoTimeline`: stringa `(1,1)` (in bozza, approvata)

#### `ATTIVITA_TIMELINE`
* **Tipo:** Entità Debole (identificazione esterna mista).
* **Entità Dominante:** `TIMELINE` (e quindi `EVENTO`).
* **Identificatore:** `{TIMELINE, OrarioPrevisto}` tramite associazione `COMPOSIZIONE_TL`.
* **Attributi:**
  * `OrarioPrevisto`: ora `(1,1)` — **Componente interna identificatore**
  * `Titolo`: stringa `(1,1)`
  * `DurataMinuti`: intero `(1,1)`
  * `Descrizione`: stringa `(1,1)`
  * `Luogo`: stringa `(1,1)` (sala ricevimento, giardino, chiesa)
  * `Stato`: stringa `(1,1)` (pianificato, confermato, completato)
  * `NotaStaff`: stringa `(0,1)`
  * `NotaCoppia`: stringa `(0,1)`

#### `TEMPLATE_CHECKLIST`
* **Tipo:** Entità Forte.
* **Identificatore Naturale:** `NomeTemplate` (es. Cerimonia Civile Standard, Rito Religioso Classico).
* **Attributi:**
  * `NomeTemplate`: stringa `(1,1)` — **Identificatore**
  * `TipoCerimonia`: stringa `(1,1)`
  * `Descrizione`: stringa `(1,1)`

#### `VOCE_TEMPLATE`
* **Tipo:** Entità Debole (identificazione esterna mista).
* **Entità Dominante:** `TEMPLATE_CHECKLIST`.
* **Identificatore:** `{TEMPLATE_CHECKLIST, TitoloVoce}` tramite associazione `COMPOSIZIONE_TPL`.
* **Attributi:**
  * `TitoloVoce`: stringa `(1,1)` — **Componente interna identificatore**
  * `Descrizione`: stringa `(1,1)`
  * `Priorita`: stringa `(1,1)`
  * `Fase`: stringa `(1,1)`
  * `GiorniPrima`: intero `(1,1)` (giorni di anticipo rispetto all'evento per il calcolo della scadenza)

#### `CHECKLIST`
* **Tipo:** Entità Debole (identificazione esterna pura 1:1 con `EVENTO`).
* **Entità Dominante:** `EVENTO`.
* **Identificatore:** `{EVENTO}` tramite associazione `HA_CHECKLIST`.
* **Attributi:**
  * `NoteGenerali`: stringa `(0,1)`

#### `ATTIVITA_CHECKLIST`
* **Tipo:** Entità Debole (identificazione esterna mista).
* **Entità Dominante:** `CHECKLIST` (e quindi `EVENTO`).
* **Identificatore:** `{CHECKLIST, Titolo}` tramite associazione `COMPOSIZIONE_CK`.
* **Attributi:**
  * `Titolo`: stringa `(1,1)` — **Componente interna identificatore**
  * `Descrizione`: stringa `(1,1)`
  * `Scadenza`: data `(1,1)` — Calcolata deterministica: `EVENTO.Data - VOCE_TEMPLATE.GiorniPrima`
  * `DataCompletamento`: data `(0,1)` — Valorizzata alla chiusura (per calcolare il ritardo effettivo)
  * `Priorita`: stringa `(1,1)`
  * `Fase`: stringa `(1,1)`
  * `Stato`: stringa `(1,1)` (da iniziare, in corso, completata, annullata)

---

### Gruppo 6: Ospiti, Partecipazioni, Lista Nozze e Quote

#### `INVITATO`
* **Tipo:** Specializzazione (IS-A) di `PERSONA`.
* **Identificatore:** Ereditato da `PERSONA` (`CodiceFiscale`).
* **Attributi Specifici:**
  * `Relazione`: stringa `(1,1)` (famiglia sposo, famiglia sposa, amici comuni, colleghi)

#### `PARTECIPAZIONE`
* **Tipo:** Entità Reificata (associazione molti-a-molti tra Invitato ed Evento).
* **Entità Dominanti:** `INVITATO` ed `EVENTO`.
* **Identificatore:** `{INVITATO, EVENTO}` tramite associazioni `INVITO` e `INCLUSIONE`.
* **Attributi:**
  * `Stato`: stringa `(1,1)` (CONFERMATO, RIFIUTATO, IN_ATTESA)
  * `Allergie`: stringa `(0,1)`
  * `PreferenzaMenu`: stringa `(0,1)`
  * `Trasporto`: booleano `(1,1)`
  * `Note`: stringa `(0,1)`

#### `LISTA_NOZZE`
* **Tipo:** Entità Debole (identificazione esterna pura 1:1 con `EVENTO`).
* **Entità Dominante:** `EVENTO`.
* **Identificatore:** `{EVENTO}` tramite associazione `HA_LISTA`.
* **Attributi:**
  * `TotaleDesiderato`: decimale `(1,1)`
  * `TotaleRaccolto`: decimale `(1,1)` (attributo derivabile/ridondante)
  * `StatoLista`: stringa `(1,1)` (aperta, chiusa)

#### `REGALO`
* **Tipo:** Entità Debole (identificazione esterna mista).
* **Entità Dominante:** `LISTA_NOZZE` (e quindi `EVENTO`).
* **Identificatore:** `{LISTA_NOZZE, Descrizione}` tramite associazione `COMPOSIZIONE_LN`.
* **Attributi:**
  * `Descrizione`: stringa `(1,1)` — **Componente interna identificatore**
  * `Prezzo`: decimale `(1,1)`
  * `Link`: stringa `(0,1)`
  * `Negozio`: stringa `(0,1)`
  * `Stato`: stringa `(1,1)` (disponibile, parzialmente prenotato, interamente prenotato, acquistato)
  * `Tipologia`: stringa `(1,1)` (bene materiale, quota viaggio di nozze, donazione benefica)
  * `TipoFrazionamento`: stringa `(1,1)` (INTERO non frazionabile, QUOTE_LIBERE, QUOTE_FISSE)

#### `PRENOTAZIONE`
* **Tipo:** Entità Reificata (versamento di quota monetaria o prenotazione regalo).
* **Entità Dominanti:** `PARTECIPAZIONE` e `REGALO`.
* **Identificatore:** `{PARTECIPAZIONE, REGALO, DataOra}` tramite associazioni `VERSAMENTO` e `DESTINAZIONE_QUOTA`.
* **Attributi:**
  * `DataOra`: datetime `(1,1)` — **Componente interna identificatore**
  * `Quota`: decimale `(1,1)`
  * `MessaggioAuguri`: stringa `(0,1)`
  * `MetodoPagamento`: stringa `(1,1)`
  * `Stato`: stringa `(1,1)` (confermata, in attesa bonifico)

---

### Gruppo 7: Comunicazioni, Appuntamenti e Portfolio

#### `COMUNICAZIONE`
* **Tipo:** Entità Debole (identificazione esterna mista).
* **Entità Dominante:** `COPPIA`.
* **Identificatore:** `{COPPIA, DataOra, Mittente}` tramite associazione `RICEVE_COM`.
* **Attributi:**
  * `DataOra`: datetime `(1,1)` — **Componente interna identificatore**
  * `Mittente`: stringa `(1,1)` — **Componente interna identificatore**
  * `Oggetto`: stringa `(1,1)`
  * `Contenuto`: testo `(1,1)`
  * `Argomento`: stringa `(1,1)`
  * `Allegati`: stringa `(0,1)`

#### `APPUNTAMENTO`
* **Tipo:** Entità Debole (identificazione esterna mista).
* **Entità Dominante:** `COPPIA`.
* **Identificatore:** `{COPPIA, DataOra}` tramite associazione `PARTECIPA_APP`.
* **Attributi:**
  * `DataOra`: datetime `(1,1)` — **Componente interna identificatore**
  * `LuogoModalita`: stringa `(1,1)` (in presenza, videocall)
  * `DurataMinuti`: intero `(1,1)`
  * `Resoconto`: testo `(0,1)`

#### `RECENSIONE`
* **Tipo:** Entità Debole (identificazione esterna pura 1:1 con evento completato).
* **Entità Dominante:** `EVENTO`.
* **Identificatore:** `{EVENTO}` tramite associazione `RILASCIO_REC`.
* **Attributi:**
  * `Data`: data `(1,1)`
  * `Voto`: intero `(1,1)` (scala da 1 a 5)
  * `Testo`: testo `(1,1)`
  * `TagStile`: stringa `(1,1)` (bohémien, classico, rustico, moderno, ecc.)
  * `Stagione`: stringa `(1,1)` (primavera, estate, autunno, inverno)

#### `FOTO`
* **Tipo:** Entità Debole (identificazione esterna mista).
* **Entità Dominante:** `EVENTO`.
* **Identificatore:** `{EVENTO, PercorsoFile}` tramite associazione `GALLERIA_FOTO`.
* **Attributi:**
  * `PercorsoFile`: stringa `(1,1)` — **Componente interna identificatore**
  * `Didascalia`: stringa `(0,1)`
  * `Autore`: stringa `(1,1)`
  * `DataScatto`: data `(1,1)`

---

## 2.4 Approfondimento Metodologico: Persona e Collegamento alla Coppia

### A. La Gerarchia IS-A dei Soggetti Umani
La modellazione canonica UniBo per le organizzazioni che gestiscono sia personale sia clienti/invitati adotta l'entità radice `PERSONA`:
- `DIPENDENTE IS-A PERSONA`: eredita codice fiscale, nome, cognome, email personale, telefono. Aggiunge attributi di inquadramento aziendale (`EmailAziendale`, `DataAssunzione`, `Stato`).
- `INVITATO IS-A PERSONA`: eredita l'anagrafica di base e aggiunge la `Relazione` con la coppia. Se un dipendente dell'agenzia è invitato al matrimonio di un amico, o un ex-invitato viene assunto come assistente, il soggetto possiede un'unica identità immutabile nella base di dati (`CodiceFiscale`).

### B. Come `COPPIA` si collega a `PERSONA`
La coppia non è una singola persona fisica né una specializzazione di Persona, bensì un **soggetto contrattuale composito** formato dall'unione di due persone.

```
       +---------------------------------------------+
       |                   COPPIA                    |
       | Username (PK), DataPrevista, BudgetIndicat. |
       +---------------------------------------------+
                 | (2, 2)            | (1, 1)
                 |                   |
                 v CONIUGI           v ORGANIZZAZIONE
          +-------------+      +-----------+
          |   PERSONA   |      |  EVENTO   |
          +-------------+      +-----------+
```

1. **A Livello Concettuale:**
   - L'associazione `CONIUGI` unisce `COPPIA` e `PERSONA`.
   - Cardinalità per `COPPIA`: `(2, 2)` $
ightarrow$ Ogni coppia è costituita da esattamente 2 persone fisiche.
   - Cardinalità per `PERSONA`: `(0, 1)` $
ightarrow$ Una persona può far parte al più di una coppia committente attiva (o `(0, N)` se si ammette la storicizzazione di unioni distinte nel tempo).
   - L'associazione definisce il ruolo: `RuoloConiuge` ('Coniuge 1', 'Coniuge 2').
2. **A Livello Logico Relazionale (Traduzione):**
   - Poiché la cardinalità verso Persona è fissa a 2, la soluzione ottimale è inserire direttamente nella relazione `COPPIA` le due chiavi esterne referenzianti `PERSONA`:
     $$\text{COPPIA}(\underline{\text{Username}}, \text{DataPrevista}, \text{BudgetIndicativo}, \text{CF\_Coniuge1}, \text{CF\_Coniuge2})$$
   - con i vincoli referenziali e di integrità:
     - `FOREIGN KEY (CF_Coniuge1) REFERENCES PERSONA(CodiceFiscale) NOT NULL`
     - `FOREIGN KEY (CF_Coniuge2) REFERENCES PERSONA(CodiceFiscale) NOT NULL`
     - `CHECK (CF_Coniuge1 <> CF_Coniuge2)` (impossibilità di auto-unione).

---

## 2.5 Approfondimento Architetturale: Gestione Dettagliata di Lista Nozze e Timeline

### A. Gestione della Lista Nozze, Regali e Quote
La gestione della lista nozze soddisfa tre requisiti chiave: (1) legame indissolubile con l'evento, (2) supporto sia a doni indivisibili sia a quote libere, (3) risoluzione immediata della Query 8 sugli ospiti ricorrenti.

```
[ EVENTO ] --- (1, 1) --- [ LISTA_NOZZE ] --- (1, N) --- [ REGALO ]
                                                             ^
                                                             | (1, N)
                                                    [ PRENOTAZIONE ]
                                                             ^
                                                             | (1, N)
[ INVITATO ] --- (1, N) -----------------------------> [ PARTECIPAZIONE ]
```

1. **Struttura dei Doni (`REGALO`):**
   - Ogni regalo appartiene alla lista nozze del singolo evento ed è caratterizzato dal `tipo_frazionamento`:
     - `INTERO`: dono materiale a pezzo unico (es. servizio di piatti da €300). Può ricevere al più una sola prenotazione che copre l'intero prezzo.
     - `QUOTE_LIBERE`: fondo aperto a importo libero (es. viaggio di nozze da €5.000). Gli invitati donano importi a piacere fino a coprire il prezzo.
     - `QUOTE_FISSE`: fondo suddiviso in quote predefinite (es. 20 quote da €100).
2. **Effettuazione del Versamento (`PRENOTAZIONE`):**
   - L'ospite che effettua il versamento/prenotazione agisce attraverso la propria `PARTECIPAZIONE` a quell'evento.
   - Poiché la partecipazione esiste sia per gli ospiti confermati (`CONFERMATO`) sia per coloro che hanno declinato l'invito (`RIFIUTATO`), entrambi possono donare quote e lasciare il biglietto di auguri (`messaggio_auguri`).
   - Non è possibile versare quote per un evento a cui non si è formalmente invitati.
3. **Tracciamento Statistico Ospiti Ricorrenti (STAT-08):**
   - Un invitato è identificato dal `CodiceFiscale` in `PERSONA`/`INVITATO`.
   - Se compare in più partecipazioni ad eventi distinti: $\text{COUNT}(\text{DISTINCT } \text{PARTECIPAZIONE.Evento}) > 1$.
   - Il totale delle quote donate in tutti i matrimoni dell'agenzia è calcolato unendo le sue partecipazioni con le relative prenotazioni:
     $$\text{TotaleQuote} = \sum \text{PRENOTAZIONE.Quota}$$

### B. Gestione della Timeline di Regia della Giornata
La timeline organizza lo svolgimento cronologico minuto per minuto della giornata del matrimonio:

```
[ EVENTO ] --- (1, 1) ---> [ TIMELINE ] --- (1, N) ---> [ ATTIVITA_TIMELINE ]
                                                               |
                                                 (1, 1)        | (0, 1)
                                       [ DIPENDENTE ] <--------+--------> [ FORNITORE ]
                                       (Coordinatore)                     (Partner on-site)
```

1. **Unicità della Regia:** Ogni evento possiede esattamente una `TIMELINE` con note di regia generali e stato di approvazione.
2. **Momenti Orari (`ATTIVITA_TIMELINE`):**
   - Ogni riga rappresenta una fase precisa della giornata (es. ore 10:30 "Arrivo sposo", ore 11:00 "Ingresso sposa", ore 12:30 "Aperitivo in giardino", ore 17:00 "Taglio torta", ore 18:30 "Lancio bouquet").
   - Identificata da `{TIMELINE, OrarioPrevisto}`. Riporta la durata stimata in minuti e il luogo specifico della location.
3. **Supervisione e Coinvolgimento:**
   - Ciascuna attività oraria è presidiata da un membro designato dello staff (`DIPENDENTE`, ad esempio l'On-Site Coordinator o l'Assistente).
   - Facoltativamente, l'attività può associare il `FORNITORE` operativamente ingaggiato in quel momento (es. il catering per l'aperitivo, il fotografo per il taglio torta, la band musicale per il primo ballo).
4. **Vincoli di Non Sovrapposizione:** Non possono esistere due attività orarie simultanee che vedano assegnato il medesimo coordinatore o la medesima sala/location.

---

## 2.6 Tabella delle Associazioni Concettuali con Cardinalità (min, max)

| Associazione | Entità Partecipanti con Cardinalità (min, max) | Descrizione Semantica | Attributi Propri |
| :--- | :--- | :--- | :--- |
| **CONIUGI** | `COPPIA` (2, 2) — `PERSONA` (0, 1) | Ogni coppia è formata da 2 persone; una persona fa parte di al più una coppia committente. | `RuoloConiuge` |
| **ORGANIZZAZIONE** | `COPPIA` (1, N) — `EVENTO` (1, 1) | Una coppia commissiona 1 o più eventi; ogni evento appartiene a 1 coppia. | — |
| **ASSEGNAZIONE_RUOLO** | `DIPENDENTE` (1, N) — `RUOLO` (0, N) | Il dipendente può ricoprire più ruoli; un ruolo è ricoperto da più dipendenti (reificata in RUOLO_DIPENDENTE). | `DataAssegnazione`, `Principale` |
| **CALENDARIO** | `DIPENDENTE` (0, N) — `DISPONIBILITA` (1, 1) | Lo staff ha uno storico presenze/assenze; ogni disponibilità fa capo a 1 dipendente. | — |
| **GIUSTIFICATIVO** | `DISPONIBILITA` (0, 1) — `MOTIVO_ASSENZA` (0, N) | L'indisponibilità può essere motivata da una causale; una causale motiva più assenze. | — |
| **STORICO_COPPIA** | `COPPIA` (1, N) — `ASSEGNAZIONE_DIPENDENTE` (1, 1) | La coppia ha uno storico di assegnazioni wedding planner. | — |
| **PRESA_IN_CARICO** | `DIPENDENTE` (0, N) — `ASSEGNAZIONE_DIPENDENTE` (1, 1) | Il dipendente riceve molteplici incarichi nel tempo. | — |
| **SEDE_SVOLGIMENTO** | `EVENTO` (1, N) — `LOCATION` (0, N) | L'evento utilizza 1 o più location con fasce orarie dedicate. | `OrarioInizio`, `OrarioFine` |
| **CATEGORIZZAZIONE** | `FORNITORE` (1, 1) — `CATEGORIA_FORNITORE` (1, N) | Ogni fornitore opera in un settore; un settore raggruppa più fornitori. | — |
| **STORICO_FORNITORE** | `FORNITORE` (0, N) — `COLLABORAZIONE` (1, 1) | Il fornitore vanta periodi convenzionati storici con l'agenzia. | — |
| **EMISSIONE_PREV** | `FORNITORE` (0, N) — `PREVENTIVO` (1, 1) | Il fornitore emette preventivi; un preventivo proviene da un fornitore. | — |
| **RICHIESTA_PREV** | `EVENTO` (0, N) — `PREVENTIVO` (1, 1) | Per un evento sono richiesti vari preventivi; ogni preventivo fa capo a 1 evento (1:N). | — |
| **CURA_PREV** | `DIPENDENTE` (0, N) — `PREVENTIVO` (1, 1) | Il wedding planner supervisiona la trattativa economica del preventivo. | — |
| **STIPULA_CONTRATTO**| `PREVENTIVO` (0, 1) — `CONTRATTO` (1, 1) | L'accettazione del preventivo genera 1:1 il contratto vincolante. | — |
| **INVITO** | `INVITATO` (0, N) — `PARTECIPAZIONE` (1, 1) | L'ospite anagrafico riceve inviti a vari eventi; la partecipazione è di 1 invitato. | — |
| **INCLUSIONE** | `EVENTO` (1, N) — `PARTECIPAZIONE` (1, 1) | L'evento registra le partecipazioni degli ospiti. | — |
| **DISPOSIZIONE** | `EVENTO` (0, N) — `TAVOLO` (1, 1) | L'evento allestisce i tavoli della sala. | — |
| **SEDUTA** | `PARTECIPAZIONE` (0, 1) — `TAVOLO` (0, N) | L'ospite confermato siede a 1 tavolo; al tavolo siedono più ospiti. | — |
| **OMAGGIO** | `PARTECIPAZIONE` (0, 1) — `BOMBONIERA` (0, N) | All'ospite è destinata 1 tipologia di bomboniera. | — |
| **HA_TIMELINE** | `EVENTO` (1, 1) — `TIMELINE` (1, 1) | L'evento possiede esattamente 1 timeline oraria. | — |
| **COMPOSIZIONE_TL** | `TIMELINE` (1, N) — `ATTIVITA_TIMELINE` (1, 1) | La timeline raggruppa le tappe orarie della giornata. | — |
| **RESPONSABILE_TL** | `DIPENDENTE` (0, N) — `ATTIVITA_TIMELINE` (1, 1) | Il coordinatore responsabile del rispetto della scaletta oraria. | — |
| **FORNITORE_TL** | `FORNITORE` (0, N) — `ATTIVITA_TIMELINE` (0, 1) | Il fornitore ingaggiato nel singolo momento orario (opzionale). | — |
| **COMPOSIZIONE_TPL**| `TEMPLATE_CHECKLIST` (1, N) — `VOCE_TEMPLATE` (1, 1) | Il template raccoglie i compiti tipo con giorni_prima. | — |
| **HA_CHECKLIST** | `EVENTO` (1, 1) — `CHECKLIST` (1, 1) | L'evento possiede esattamente 1 checklist operativa. | — |
| **DERIVAZIONE_CK** | `TEMPLATE_CHECKLIST` (0, N) — `CHECKLIST` (1, 1) | La checklist operativa deriva dal template predefinito per il rito. | — |
| **COMPOSIZIONE_CK** | `CHECKLIST` (1, N) — `ATTIVITA_CHECKLIST` (1, 1) | La checklist raggruppa i compiti operativi concreti. | — |
| **ORIGINE_VOCE** | `VOCE_TEMPLATE` (0, N) — `ATTIVITA_CHECKLIST` (0, 1) | L'attività può derivare da una specifica voce del template (tracciabilità). | — |
| **SUPERVISIONE_CK** | `DIPENDENTE` (0, N) — `ATTIVITA_CHECKLIST` (0, 1) | Un dipendente può essere assegnato alla supervisione del compito. | — |
| **HA_LISTA** | `EVENTO` (1, 1) — `LISTA_NOZZE` (1, 1) | L'evento possiede esattamente 1 lista nozze integrata. | — |
| **COMPOSIZIONE_LN** | `LISTA_NOZZE` (0, N) — `REGALO` (1, 1) | La lista nozze raggruppa i regali desiderati. | — |
| **VERSAMENTO** | `PARTECIPAZIONE` (0, N) — `PRENOTAZIONE` (1, 1) | L'invitato registrato dona quote monetarie o prenota regali. | — |
| **DESTINAZIONE_QUOTA**| `REGALO` (0, N) — `PRENOTAZIONE` (1, 1) | Il regalo riceve donazioni e quote. | — |
| **RICEVE_COM** | `COPPIA` (0, N) — `COMUNICAZIONE` (1, 1) | La coppia riceve comunicazioni formali. | — |
| **INVIA_COM** | `DIPENDENTE` (0, N) — `COMUNICAZIONE` (1, 1) | Il dipendente redige comunicazioni per la coppia. | — |
| **PARTECIPA_APP** | `COPPIA` (0, N) — `APPUNTAMENTO` (1, 1) | La coppia partecipa ad appuntamenti di consulenza. | — |
| **CONDUCE_APP** | `DIPENDENTE` (0, N) — `APPUNTAMENTO` (1, 1) | Il wedding planner conduce l'incontro. | — |
| **RILASCIO_REC** | `EVENTO` (0, 1) — `RECENSIONE` (1, 1) | L'evento completato riceve al più una valutazione della coppia. | — |
| **GALLERIA_FOTO** | `EVENTO` (0, N) — `FOTO` (1, 1) | L'evento è documentato da fotografie nel portfolio aziendale. | — |

---

## 2.7 Regole Aziendali e Vincoli di Integrità non esprimibili nel Diagramma E/R

### 1. Vincoli sui Soggetti e sulle Assegnazioni
1. **Integrità dei Componenti della Coppia:** In ogni coppia, i due coniugi devono essere persone distinte:
   $$\text{CF\_Coniuge1} \neq \text{CF\_Coniuge2}$$
2. **Coerenza Assunzioni:** Per ciascun `DIPENDENTE`, se `DataFineRapporto` è presente:
   $$\text{DataAssunzione} \le \text{DataFineRapporto}$$
3. **Disgiunzione Intervalli Calendario:** Per ciascun `DIPENDENTE`, non possono esistere due tuple in `DISPONIBILITA` con periodi temporali $[\text{DataInizio}, \text{DataFine}]$ sovrapposti.
4. **Unicità Assegnazione Attiva:** Per ogni `COPPIA`, in ogni istante $t$, può esistere **al più una** tupla in `ASSEGNAZIONE_DIPENDENTE` con `Attiva = TRUE`.
5. **Capacità Lavorativa per Ruolo:** In ogni periodo, il numero di eventi attivi assegnati a un planner non può eccedere il massimo consentito dai suoi ruoli:
   $$\text{COUNT}(\text{EVENTO active assigned to } d) \le \max_{r \in \text{Ruoli}(d)} (r.\text{MaxEventiContemporanei})$$
6. **Coerenza Temporale dell'Evento:** L'evento celebrato in data $D$ deve cadere nel periodo di assegnazione attiva del wedding planner incaricato:
   $$\text{DataInizio}_{\text{assegnazione}} \le \text{EVENTO.Data} \le \text{DataFine}_{\text{assegnazione}} \quad (\text{se presente})$$

### 2. Vincoli Contrattuali e Finanziari
1. **Validità Partner Fornitore:** Un preventivo può essere emesso e un contratto può essere stipulato solo con fornitori aventi `COLLABORAZIONE` attiva e flag globale `FORNITORE.Attivo = TRUE`.
2. **Cronologia Contrattuale:** Per ciascun fornitore coinvolto in un evento:
   $$\text{PREVENTIVO.DataEmissione} \le \text{CONTRATTO.DataFirma} \le \text{EVENTO.Data}$$
3. **Plafond di Budget:** La somma dei contratti confermati non deve eccedere il budget approvato oltre la soglia di tolleranza concordata:
   $$\sum \text{CONTRATTO.ImportoDefinitivo} \le \text{EVENTO.BudgetApprovato} \times 1.05$$
4. **Quadratura Contratto:** $\text{CONTRATTO.Acconto} + \text{CONTRATTO.Saldo} = \text{CONTRATTO.ImportoDefinitivo}$.

### 3. Vincoli su Checklist, Timeline e Logistica
1. **Scadenza Checklist:** $\text{ATTIVITA_CHECKLIST.Scadenza} = \text{EVENTO.Data} - \text{VOCE_TEMPLATE.GiorniPrima} \le \text{EVENTO.Data}$.
2. **Ritardo Effettivo Checklist:** Se un'attività ha `Stato = 'completata'`, deve avere `DataCompletamento` valorizzata. Se $\text{DataCompletamento} > \text{Scadenza}$, l'attività è formalmente in ritardo.
3. **Sequenzialità Timeline:** Tutte le attività orarie devono svolgersi nel giorno dell'evento senza sovrapposizioni incongruenti per la stessa location o per lo stesso coordinatore on-site.
4. **Capienza Location:** $\text{EVENTO.NInvitatiConfermati} \le \min_{l \in \text{Location}} (l.\text{CapienzaMax})$.
5. **Capienza Tavoli:** $\text{COUNT}(\text{Partecipazioni seated at } t) \le t.\text{Capienza}$.
6. **Seduta Riservata ai Confermati:** Solo le partecipazioni con `Stato = 'CONFERMATO'` possono essere assegnate a un tavolo (`SEDUTA`).

### 4. Vincoli sulla Lista Nozze e Portfolio
1. **Plafond Regali:** $\sum \text{PRENOTAZIONE.Quota} \le \text{REGALO.Prezzo}$.
2. **Regalo Intero Non Frazionabile:** Se $\text{REGALO.TipoFrazionamento} = \text{'INTERO'}$, può esistere al massimo 1 prenotazione con $\text{Quota} = \text{REGALO.Prezzo}$.
3. **Congruenza Partecipazione - Regalo:** L'ospite che versa una quota per un regalo deve possedere una `PARTECIPAZIONE` all'evento a cui appartiene la `LISTA_NOZZE` del regalo.
4. **Tempistica Recensione:** La recensione può essere redatta solo dopo l'evento ($	ext{EVENTO.Stato} = 	ext{'completato'}$) con $	ext{RECENSIONE.Data} \ge 	ext{EVENTO.Data}$.
