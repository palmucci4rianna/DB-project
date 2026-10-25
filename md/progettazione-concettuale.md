# Progettazione Concettuale della Base di Dati: Wedding Planner

Documentazione concettuale redatta secondo i canoni formali del modello **Entity-Relationship (E/R)** (metodologia accademica Università di Bologna - Prof. D. Maio, Prof.ssa A. Franco).

---

## 1. Principi Metodologici di Modellazione
1. **Eliminazione degli ID artificiali (`id: int PK`):** Nel modello concettuale non si introducono surrogate keys arbitrarie se esistono identificatori naturali di dominio o identificatori esterni sensati.
2. **Entità Forti:** Identificate da chiavi naturali proprie del dominio (`Username`, `PartitaIVA`, `CodiceFiscale`, `Email`, `NomeRuolo`, `NomeCategoria`, `{Nome, Indirizzo}`).
3. **Entità Deboli (Identificazione Esterna Mista o Pura):** Entità la cui esistenza e identificazione dipendono da un'entità dominante (con partecipazione totale obbligatoria `(1,1)` all'associazione identificante). L'identificatore è composto dall'identificatore dell'entità dominante più un discriminante locale (es. `EVENTO` identificato da `COPPIA + Data`, `TAVOLO` identificato da `EVENTO + NomeNumero`).
4. **Reificazione di Associazioni:** Quando un'associazione molti-a-molti possiede attributi propri e deve a sua volta partecipare ad altre associazioni, viene reificata in un'entità (es. `PARTECIPAZIONE` tra `INVITATO` ed `EVENTO`, che a sua volta partecipa all'assegnazione a `TAVOLO` e `BOMBONIERA`).

---

## 2. Dizionario delle Entità per Gruppo Semantico

### Gruppo 1: Coppia ed Evento

#### `COPPIA`
* **Tipo:** Entità Forte.
* **Identificatore:** `Username` (identificatore interno semplice, credenziale di registrazione della coppia).
* **Attributi:**
  * `Username`: stringa `(1,1)` — **Identificatore**
  * `NomeConiuge1`: stringa `(1,1)`
  * `NomeConiuge2`: stringa `(1,1)`
  * `Email`: stringa `(1,1)` — Chiave alternativa univoca
  * `Telefono`: stringa `(1,1)`
  * `DataPrevista`: data `(1,1)`
  * `BudgetIndicativo`: decimale `(1,1)`

#### `EVENTO`
* **Tipo:** Entità Debole (identificazione esterna mista).
* **Entità Dominante:** `COPPIA`.
* **Identificatore:** `{COPPIA, Data}` tramite associazione `ORGANIZZAZIONE` (una coppia organizza un evento in una specifica data).
* **Attributi:**
  * `Data`: data `(1,1)` — **Componente interna identificatore**
  * `BudgetApprovato`: decimale `(1,1)`
  * `NInvitatiPrevisti`: intero `(1,1)`
  * `NInvitatiConfermati`: intero `(1,1)`
  * `TipoCerimonia`: stringa `(1,1)` (religiosa, civile, simbolica, all'aperto)
  * `Stato`: stringa `(1,1)` (pianificazione, confermato, completato, annullato)

---

### Gruppo 2: Staff, Ruoli e Calendario

#### `DIPENDENTE`
* **Tipo:** Entità Forte.
* **Identificatore:** `Email` (identificatore interno semplice, email aziendale univoca).
* **Attributi:**
  * `Email`: stringa `(1,1)` — **Identificatore**
  * `Nome`: stringa `(1,1)`
  * `Cognome`: stringa `(1,1)`
  * `Telefono`: stringa `(1,1)`
  * `DataAssunzione`: data `(1,1)`
  * `DataFineRapporto`: data `(0,1)` (opzionale)
  * `Stato`: stringa `(1,1)` (attivo, sospeso, dimesso)

#### `RUOLO`
* **Tipo:** Entità Forte.
* **Identificatore:** `NomeRuolo` (identificatore interno semplice, es. *'Planner Senior'*, *'Assistente'*, *'Coordinatore on-site'*, *'Amministrativo'*).
* **Attributi:**
  * `NomeRuolo`: stringa `(1,1)` — **Identificatore**
  * `Descrizione`: stringa `(1,1)`
  * `MaxEventiContemporanei`: intero `(1,1)`

#### `MOTIVO_ASSENZA`
* **Tipo:** Entità Forte.
* **Identificatore:** `Categoria` (identificatore interno semplice, es. *'Ferie'*, *'Malattia'*, *'Permesso'*, *'Maternità'*).
* **Attributi:**
  * `Categoria`: stringa `(1,1)` — **Identificatore**
  * `Descrizione`: stringa `(1,1)`
  * `Remunerata`: booleano `(1,1)`

#### `DISPONIBILITA`
* **Tipo:** Entità Debole (storicizzazione temporale, identificazione esterna mista).
* **Entità Dominante:** `DIPENDENTE`.
* **Identificatore:** `{DIPENDENTE, DataInizio}` tramite associazione `ASSENZA`.
* **Attributi:**
  * `DataInizio`: data `(1,1)` — **Componente interna identificatore**
  * `DataFine`: data `(1,1)`
  * `Tipo`: stringa `(1,1)` (presenza, assenza)
  * `Stato`: stringa `(1,1)` (richiesta, approvata, rifiutata)

#### `ASSEGNAZIONE_DIPENDENTE`
* **Tipo:** Entità Debole (storicizzazione del wedding planner assegnato alla coppia, identificazione esterna mista).
* **Entità Dominanti:** `COPPIA` e `DIPENDENTE`.
* **Identificatore:** `{COPPIA, DIPENDENTE, DataInizio}` tramite associazioni `STORICO_ASSEGNAZIONE` e `INCARICO_PLANNER`.
* **Attributi:**
  * `DataInizio`: data `(1,1)` — **Componente interna identificatore**
  * `DataFine`: data `(0,1)` (opzionale se l'assegnazione è ancora in corso)
  * `MotivoCambio`: stringa `(0,1)` (opzionale, compilato in caso di sostituzione)
  * `Attiva`: booleano `(1,1)`

---

### Gruppo 3: Fornitori, Preventivi e Contratti

#### `CATEGORIA_FORNITORE`
* **Tipo:** Entità Forte.
* **Identificatore:** `NomeCategoria` (identificatore interno semplice, es. *'Catering'*, *'Fotografia'*, *'Allestimento floreale'*, *'Musica'*, *'Abiti'*, *'Cake design'*, *'Celebrante'*).
* **Attributi:**
  * `NomeCategoria`: stringa `(1,1)` — **Identificatore**
  * `Descrizione`: stringa `(1,1)`

#### `FORNITORE`
* **Tipo:** Entità Forte.
* **Identificatore:** `PartitaIVA` (identificatore interno semplice).
* **Attributi:**
  * `PartitaIVA`: stringa `(1,1)` — **Identificatore**
  * `RagioneSociale`: stringa `(1,1)`
  * `ZonaOperativa`: stringa `(1,1)`
  * `ValutazioneInterna`: decimale `(1,1)` (media rating agenzia)
  * `Attivo`: booleano `(1,1)` (bloccabile da amministratore)

#### `COLLABORAZIONE`
* **Tipo:** Entità Debole (storicizzazione collaborazioni con fornitore, identificazione esterna mista).
* **Entità Dominante:** `FORNITORE`.
* **Identificatore:** `{FORNITORE, DataInizio}` tramite associazione `STORICO_COLLAB`.
* **Attributi:**
  * `DataInizio`: data `(1,1)` — **Componente interna identificatore**
  * `DataFine`: data `(0,1)` (opzionale)
  * `Stato`: stringa `(1,1)` (attivo, sospeso, terminato)
  * `Note`: stringa `(0,1)`
  * `Valutazione`: decimale `(1,1)`

#### `PREVENTIVO`
* **Tipo:** Entità Debole (documento commerciale emesso da un fornitore per un evento, identificazione esterna mista).
* **Entità Dominante:** `FORNITORE`.
* **Identificatore:** `{FORNITORE, DataEmissione, NumPreventivo}` tramite associazione `EMETTE`.
* **Attributi:**
  * `DataEmissione`: data `(1,1)` — **Componente interna identificatore**
  * `NumPreventivo`: intero `(1,1)` — **Componente interna identificatore**
  * `Importo`: decimale `(1,1)`
  * `Descrizione`: stringa `(1,1)`
  * `Stato`: stringa `(1,1)` (in attesa, accettato, rifiutato)

#### `CONTRATTO`
* **Tipo:** Entità Debole (formalizzazione 1:1 di un preventivo accettato, identificazione esterna pura).
* **Entità Dominante:** `PREVENTIVO`.
* **Identificatore:** `{PREVENTIVO}` tramite associazione `GENERA`.
* **Attributi:**
  * `DataFirma`: data `(1,1)`
  * `ImportoDefinitivo`: decimale `(1,1)`
  * `Acconto`: decimale `(1,1)`
  * `Saldo`: decimale `(1,1)`
  * `StatoPagamento`: stringa `(1,1)` (acconto versato, saldo da versare, saldo versato)
  * `Penali`: stringa `(0,1)` (opzionale)

---

### Gruppo 4: Logistica dell'Evento

#### `LOCATION`
* **Tipo:** Entità Forte.
* **Identificatore:** `{Nome, Indirizzo}` (identificatore interno composto).
* **Attributi:**
  * `Nome`: stringa `(1,1)` — **Componente identificatore**
  * `Indirizzo`: stringa `(1,1)` — **Componente identificatore**
  * `CapienzaMax`: intero `(1,1)`
  * `PrezzoAffitto`: decimale `(1,1)`
  * `ServiziInclusi`: stringa `(1,1)`

#### `BOMBONIERA`
* **Tipo:** Entità Forte.
* **Identificatore:** `Tipologia` (identificatore interno semplice, es. *'Standard Adulti'*, *'Bambini'*, *'Testimoni'*).
* **Attributi:**
  * `Tipologia`: stringa `(1,1)` — **Identificatore**
  * `Descrizione`: stringa `(1,1)`
  * `Target`: stringa `(1,1)`

#### `TIMELINE`
* **Tipo:** Entità Debole (1:1 con l'evento, identificazione esterna pura).
* **Entità Dominante:** `EVENTO`.
* **Identificatore:** `{EVENTO}` tramite associazione `HA_TIMELINE`.
* **Attributi:**
  * `NoteGenerali`: stringa `(0,1)`

#### `ATTIVITA_TIMELINE`
* **Tipo:** Entità Debole (dettaglio orario della giornata, identificazione esterna mista).
* **Entità Dominante:** `TIMELINE` (e quindi `EVENTO`).
* **Identificatore:** `{TIMELINE, OrarioPrevisto}` tramite associazione `COMPOSIZIONE_TL`.
* **Attributi:**
  * `OrarioPrevisto`: orario `(1,1)` — **Componente interna identificatore**
  * `DurataMinuti`: intero `(1,1)`
  * `Descrizione`: stringa `(1,1)`
  * `Luogo`: stringa `(1,1)`
  * `Stato`: stringa `(1,1)` (da pianificare, confermato, completato)
  * `NotaStaff`: stringa `(0,1)`
  * `NotaCoppia`: stringa `(0,1)`

#### `CHECKLIST`
* **Tipo:** Entità Debole (1:1 con l'evento, identificazione esterna pura).
* **Entità Dominante:** `EVENTO`.
* **Identificatore:** `{EVENTO}` tramite associazione `HA_CHECKLIST`.
* **Attributi:**
  * `NoteGenerali`: stringa `(0,1)`

#### `ATTIVITA_CHECKLIST`
* **Tipo:** Entità Debole (task operativo della checklist, identificazione esterna mista).
* **Entità Dominante:** `CHECKLIST` (e quindi `EVENTO`).
* **Identificatore:** `{CHECKLIST, TitoloAttivita}` tramite associazione `COMPOSIZIONE_CL`.
* **Attributi:**
  * `TitoloAttivita`: stringa `(1,1)` — **Componente interna identificatore**
  * `Descrizione`: stringa `(1,1)`
  * `Scadenza`: data `(1,1)`
  * `DataCompletamento`: data `(0,1)` (opzionale, fondamentale per il calcolo del tempo medio di completamento e dei ritardi)
  * `Priorita`: stringa `(1,1)` (alta, media, bassa)
  * `Completata`: booleano `(1,1)`
  * `Fase`: stringa `(1,1)`

#### `TEMPLATE_CHECKLIST`
* **Tipo:** Entità Forte.
* **Identificatore:** `NomeTemplate` (identificatore interno semplice).
* **Attributi:**
  * `NomeTemplate`: stringa `(1,1)` — **Identificatore**
  * `TipoCerimonia`: stringa `(1,1)`
  * `Descrizione`: stringa `(1,1)`

#### `VOCE_TEMPLATE`
* **Tipo:** Entità Debole (voce base del template riutilizzabile, identificazione esterna mista).
* **Entità Dominante:** `TEMPLATE_CHECKLIST`.
* **Identificatore:** `{TEMPLATE_CHECKLIST, TitoloVoce}` tramite associazione `COMPOSIZIONE_TPL`.
* **Attributi:**
  * `TitoloVoce`: stringa `(1,1)` — **Componente interna identificatore**
  * `Descrizione`: stringa `(1,1)`
  * `Priorita`: stringa `(1,1)`
  * `GiorniPrima`: intero `(1,1)` (usato per calcolare la scadenza a ritroso dalla data evento)

#### `LISTA_NOZZE`
* **Tipo:** Entità Debole (1:1 con l'evento, identificazione esterna pura).
* **Entità Dominante:** `EVENTO`.
* **Identificatore:** `{EVENTO}` tramite associazione `HA_LISTA`.
* **Attributi:**
  * `TotaleDesiderato`: decimale `(1,1)`
  * `TotaleRaccolto`: decimale `(1,1)`

#### `REGALO`
* **Tipo:** Entità Debole (singola voce della lista nozze, identificazione esterna mista).
* **Entità Dominante:** `LISTA_NOZZE` (e quindi `EVENTO`).
* **Identificatore:** `{LISTA_NOZZE, Descrizione}` tramite associazione `COMPOSIZIONE_LN`.
* **Attributi:**
  * `Descrizione`: stringa `(1,1)` — **Componente interna identificatore**
  * `Prezzo`: decimale `(1,1)`
  * `Link`: stringa `(0,1)` (opzionale)
  * `Negozio`: stringa `(0,1)` (opzionale)
  * `Stato`: stringa `(1,1)` (disponibile, prenotato, acquistato)
  * `Tipologia`: stringa `(1,1)` (oggetto, quota monetaria, donazione)

#### `TAVOLO`
* **Tipo:** Entità Debole (allestimento della sala per l'evento, identificazione esterna mista).
* **Entità Dominante:** `EVENTO`.
* **Identificatore:** `{EVENTO, NomeNumero}` tramite associazione `DISPOSIZIONE`.
* **Attributi:**
  * `NomeNumero`: stringa `(1,1)` — **Componente interna identificatore**
  * `Capienza`: intero `(1,1)`
  * `Posizione`: stringa `(1,1)`

---

### Gruppo 5: Invitati, Partecipazioni e Quote

#### `INVITATO`
* **Tipo:** Entità Forte (anagrafica ospite indipendente dall'evento).
* **Identificatore:** `CodiceFiscale` (identificatore interno semplice).
* **Attributi:**
  * `CodiceFiscale`: stringa `(1,1)` — **Identificatore**
  * `Nome`: stringa `(1,1)`
  * `Cognome`: stringa `(1,1)`
  * `Email`: stringa `(1,1)`
  * `Telefono`: stringa `(0,1)` (opzionale)
  * `Relazione`: stringa `(1,1)` (famiglia sposo, famiglia sposa, amici comuni, colleghi)

#### `PARTECIPAZIONE`
* **Tipo:** Entità Reificata (nasce dalla relazione molti-a-molti tra Invitato ed Evento per portare attributi contestuali e partecipare ad altre associazioni).
* **Entità Dominanti:** `INVITATO` ed `EVENTO`.
* **Identificatore:** `{INVITATO, EVENTO}` tramite associazioni `INVITO` e `INCLUSIONE`.
* **Attributi:**
  * `Stato`: stringa `(1,1)` (CONFERMATO, RIFIUTATO, IN_ATTESA)
  * `Allergie`: stringa `(0,1)` (opzionale)
  * `PreferenzaMenu`: stringa `(0,1)` (opzionale)
  * `Trasporto`: booleano `(1,1)`
  * `Note`: stringa `(0,1)` (opzionale)

#### `PRENOTAZIONE`
* **Tipo:** Entità Reificata (quota versata per un regalo).
* **Entità Dominanti:** `INVITATO` e `REGALO`.
* **Identificatore:** `{INVITATO, REGALO, DataOra}` tramite associazioni `EFFETTUA` e `RICEVE_QUOTA`.
* **Attributi:**
  * `DataOra`: data/ora `(1,1)` — **Componente interna identificatore**
  * `Quota`: decimale `(1,1)`
  * `MessaggioAuguri`: stringa `(0,1)` (opzionale)
  * `Stato`: stringa `(1,1)` (versato, in attesa bonifico)

---

### Gruppo 6: Comunicazioni, Appuntamenti e Portfolio

#### `COMUNICAZIONE`
* **Tipo:** Entità Debole (messaggio o documento scambiato, identificazione esterna mista).
* **Entità Dominante:** `COPPIA`.
* **Identificatore:** `{COPPIA, DataOra, Mittente}` tramite associazione `RICEVE_COM`.
* **Attributi:**
  * `DataOra`: data/ora `(1,1)` — **Componente interna identificatore**
  * `Mittente`: stringa `(1,1)` — **Componente interna identificatore**
  * `Oggetto`: stringa `(1,1)`
  * `Contenuto`: testo `(1,1)`
  * `Argomento`: stringa `(1,1)`
  * `Allegati`: stringa `(0,1)` (opzionale)

#### `APPUNTAMENTO`
* **Tipo:** Entità Debole (incontro tra planner e coppia, identificazione esterna mista).
* **Entità Dominante:** `COPPIA`.
* **Identificatore:** `{COPPIA, DataOra}` tramite associazione `PARTECIPA_APP`.
* **Attributi:**
  * `DataOra`: data/ora `(1,1)` — **Componente interna identificatore**
  * `LuogoModalita`: stringa `(1,1)` (in presenza, videocall)
  * `DurataMinuti`: intero `(1,1)`
  * `Resoconto`: testo `(0,1)` (opzionale)

#### `RECENSIONE`
* **Tipo:** Entità Debole (feedback post-evento 1:1, identificazione esterna pura).
* **Entità Dominante:** `EVENTO`.
* **Identificatore:** `{EVENTO}` tramite associazione `VALUTAZIONE`.
* **Attributi:**
  * `Voto`: intero `(1,1)` (scala 1-5)
  * `Testo`: testo `(0,1)` (opzionale)
  * `Data`: data `(1,1)`
  * `TagStile`: stringa `(0,1)` (bohémien, classico, moderno, ecc.)
  * `Stagione`: stringa `(1,1)`

#### `FOTO`
* **Tipo:** Entità Debole (scatto della galleria dell'evento, identificazione esterna mista).
* **Entità Dominante:** `EVENTO`.
* **Identificatore:** `{EVENTO, PercorsoFile}` tramite associazione `GALLERIA`.
* **Attributi:**
  * `PercorsoFile`: stringa `(1,1)` — **Componente interna identificatore**
  * `Didascalia`: stringa `(0,1)` (opzionale)
  * `Autore`: stringa `(0,1)` (opzionale)
  * `DataScatto`: data `(0,1)` (opzionale)

---

## 3. Schema delle Associazioni Concettuali con Cardinalità (min, max)

| Associazione | Entità 1 | Card. E1 | Entità 2 | Card. E2 | Note / Ruolo |
| :--- | :--- | :---: | :--- | :---: | :--- |
| **`INQUADRAMENTO`** | `DIPENDENTE` | `(1, 1)` | `RUOLO` | `(0, N)` | Ogni dipendente ricopre esattamente un ruolo alla volta. |
| **`ASSENZA`** | `DIPENDENTE` | `(0, N)` | `DISPONIBILITA` | `(1, 1)` | Identificante per Disponibilità. |
| **`CAUSALE`** | `DISPONIBILITA` | `(0, 1)` | `MOTIVO_ASSENZA` | `(0, N)` | Opzionale se la disponibilità è di presenza. |
| **`STORICO_ASSEGNAZIONE`** | `COPPIA` | `(0, N)` | `ASSEGNAZIONE_DIPENDENTE` | `(1, 1)` | Identificante per Assegnazione. |
| **`INCARICO_PLANNER`** | `DIPENDENTE` | `(0, N)` | `ASSEGNAZIONE_DIPENDENTE` | `(1, 1)` | Identificante per Assegnazione. |
| **`ORGANIZZAZIONE`** | `COPPIA` | `(1, N)` | `EVENTO` | `(1, 1)` | Identificante per Evento. Una coppia organizza almeno un evento. |
| **`RICEVE_COM`** | `COPPIA` | `(0, N)` | `COMUNICAZIONE` | `(1, 1)` | Identificante per Comunicazione. |
| **`INVIA_COM`** | `DIPENDENTE` | `(0, N)` | `COMUNICAZIONE` | `(0, 1)` | Dipendente autore della comunicazione (se inviata da staff). |
| **`PARTECIPA_APP`** | `COPPIA` | `(0, N)` | `APPUNTAMENTO` | `(1, 1)` | Identificante per Appuntamento. |
| **`CONDUCE_APP`** | `DIPENDENTE` | `(0, N)` | `APPUNTAMENTO` | `(1, 1)` | Dipendente che conduce l'incontro. |
| **`SVOLGIMENTO`** | `EVENTO` | `(1, N)` | `LOCATION` | `(0, N)` | N:M: più location per evento (chiesa, villa, ecc.), con orari. |
| **`APPARTENENZA`** | `FORNITORE` | `(1, 1)` | `CATEGORIA_FORNITORE` | `(0, N)` | Ogni fornitore è classificato in una categoria specifica. |
| **`STORICO_COLLAB`** | `FORNITORE` | `(0, N)` | `COLLABORAZIONE` | `(1, 1)` | Identificante per Collaborazione. |
| **`EMETTE`** | `FORNITORE` | `(0, N)` | `PREVENTIVO` | `(1, 1)` | Identificante per Preventivo. |
| **`RICHIEDE_PREV`** | `EVENTO` | `(0, N)` | `PREVENTIVO` | `(1, 1)` | Un preventivo è richiesto per uno specifico evento. |
| **`GENERA`** | `PREVENTIVO` | `(0, 1)` | `CONTRATTO` | `(1, 1)` | 1:1, identificante per Contratto. |
| **`HA_TIMELINE`** | `EVENTO` | `(1, 1)` | `TIMELINE` | `(1, 1)` | 1:1, identificante per Timeline. |
| **`COMPOSIZIONE_TL`** | `TIMELINE` | `(1, N)` | `ATTIVITA_TIMELINE` | `(1, 1)` | Identificante per AttivitàTimeline. |
| **`RESPONSABILE_TL`** | `ATTIVITA_TIMELINE` | `(0, 1)` | `DIPENDENTE` | `(0, N)` | Staff responsabile della singola fase della giornata. |
| **`HA_CHECKLIST`** | `EVENTO` | `(1, 1)` | `CHECKLIST` | `(1, 1)` | 1:1, identificante per Checklist. |
| **`COMPOSIZIONE_CL`** | `CHECKLIST` | `(1, N)` | `ATTIVITA_CHECKLIST` | `(1, 1)` | Identificante per AttivitàChecklist. |
| **`RESPONSABILE_CL`** | `ATTIVITA_CHECKLIST` | `(0, 1)` | `DIPENDENTE` | `(0, N)` | Staff responsabile del task. |
| **`COMPOSIZIONE_TPL`** | `TEMPLATE_CHECKLIST` | `(1, N)` | `VOCE_TEMPLATE` | `(1, 1)` | Identificante per VoceTemplate. |
| **`ISTANZIA`** | `TEMPLATE_CHECKLIST` | `(0, N)` | `CHECKLIST` | `(0, 1)` | Template da cui è stata generata la checklist dell'evento. |
| **`GENERA_ATTIVITA`**| `VOCE_TEMPLATE` | `(0, N)` | `ATTIVITA_CHECKLIST` | `(0, 1)` | Traccia l'origine della voce template (se generata da modello). |
| **`HA_LISTA`** | `EVENTO` | `(1, 1)` | `LISTA_NOZZE` | `(1, 1)` | 1:1, identificante per ListaNozze. |
| **`COMPOSIZIONE_LN`** | `LISTA_NOZZE` | `(0, N)` | `REGALO` | `(1, 1)` | Identificante per Regalo. |
| **`DISPOSIZIONE`** | `EVENTO` | `(0, N)` | `TAVOLO` | `(1, 1)` | Identificante per Tavolo. |
| **`INVITO`** | `INVITATO` | `(0, N)` | `PARTECIPAZIONE` | `(1, 1)` | Identificante per Partecipazione. |
| **`INCLUSIONE`** | `EVENTO` | `(0, N)` | `PARTECIPAZIONE` | `(1, 1)` | Identificante per Partecipazione. |
| **`ASSEGNAZIONE_TAV`**| `PARTECIPAZIONE` | `(0, 1)` | `TAVOLO` | `(0, N)` | Assegnazione della persona confermata al tavolo dell'evento. |
| **`ASSEGNAZIONE_BOMB`**|`PARTECIPAZIONE` | `(0, 1)` | `BOMBONIERA` | `(0, N)` | Associazione della tipologia di bomboniera spettante. |
| **`EFFETTUA`** | `INVITATO` | `(0, N)` | `PRENOTAZIONE` | `(1, 1)` | Identificante per Prenotazione. |
| **`RICEVE_QUOTA`** | `REGALO` | `(0, N)` | `PRENOTAZIONE` | `(1, 1)` | Identificante per Prenotazione. |
| **`VALUTAZIONE`** | `EVENTO` | `(0, 1)` | `RECENSIONE` | `(1, 1)` | 1:1, identificante per Recensione. |
| **`GALLERIA`** | `EVENTO` | `(0, N)` | `FOTO` | `(1, 1)` | Identificante per Foto. |

---

## 4. Regole Aziendali e Vincoli non esprimibili graficamente
1. **Assegnazione Tavolo coerente:** Un'istanza di `PARTECIPAZIONE` relativa a un `EVENTO` $E$ può essere associata solo a un `TAVOLO` appartenente allo stesso `EVENTO` $E$.
2. **Capienza Tavoli:** La somma delle partecipazioni confermate assegnate a un tavolo non può superare la `Capienza` massima del tavolo stesso.
3. **Limite Eventi per Planner:** Il numero di eventi attivi simultaneamente assegnati a un dipendente non può eccedere il valore `MaxEventiContemporanei` del suo `RUOLO`.
4. **Preventivi e Contratti:** Un `CONTRATTO` può essere generato solo se lo `Stato` del `PREVENTIVO` è *'accettato'*.
5. **Completamento Checklist:** Il flag `Completata = true` su `ATTIVITA_CHECKLIST` richiede la valorizzazione obbligatoria di `DataCompletamento`.

