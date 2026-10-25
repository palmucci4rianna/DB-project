erDiagram
    UTENTE {
        int id PK
        string nome
        string cognome
        string email
        string password
        date data_registrazione
    }
    PREFERENZE_UTENTE {
        int id PK
        string valuta_base
        string tema
        decimal limite_budget_mensile
        date data_inizio
        date data_fine
    }
    SESSIONE {
        int id PK
        datetime data_ora
        string dispositivo
        int durata_minuti
    }
    CATEGORIA {
        int id PK
        string nome
        string tipo
        string colore
        boolean speciale
    }
    MOVIMENTO {
        int id PK
        decimal importo
        date data
        string descrizione
        string tipo
    }
    TAG {
        int id PK
        string nome
        string colore
    }
    MOVIMENTO_TAG {
        int id PK
    }
    VALUTA {
        int id PK
        string codice_iso
        string nome
        string simbolo
    }
    TASSO_DI_CAMBIO {
        int id PK
        decimal valore
        date data_rilevazione
    }
    ALERT_VALUTA {
        int id PK
        decimal soglia
        string operatore
        string stato
    }
    AMICO {
        int id PK
        string nome
        string cognome
        string contatto
    }
    PRESTITO {
        int id PK
        decimal importo_originale
        decimal saldo_residuo
        date data_inizio
        string direzione
    }
    RATA_PRESTITO {
        int id PK
        decimal importo
        date data
        string nota
    }
    MUTUO {
        int id PK
        string banca
        decimal importo
        decimal tasso_interesse
        int durata_mesi
        date data_inizio
    }
    RATA_MUTUO {
        int id PK
        int numero_rata
        decimal quota_capitale
        decimal quota_interessi
        date data_scadenza
        string stato
    }
    TITOLO {
        int id PK
        string codice
        string nome
        string mercato
        string tipo
    }
    TRANSAZIONE_TITOLO {
        int id PK
        string tipo
        decimal quantita
        decimal prezzo_unitario
        date data
    }
    POSIZIONE_TITOLO {
        int id PK
        decimal quantita_corrente
        decimal prezzo_medio_carico
    }
    PREZZO_STORICO {
        int id PK
        decimal prezzo
        date data
    }
    WATCHLIST {
        int id PK
        date data_aggiunta
        string nota
    }
    LIMITE_BUDGET {
        int id PK
        decimal importo
        string periodo
        string tipo
    }
    ALERT_BUDGET {
        int id PK
        decimal valore_raggiunto
        decimal percentuale
        datetime data_generazione
        string stato
    }
    OBIETTIVO_RISPARMIO {
        int id PK
        string descrizione
        decimal importo_target
        decimal importo_attuale
        date scadenza
        string stato
    }
    REPORT_MENSILE {
        int id PK
        int mese
        int anno
        decimal totale_entrate
        decimal totale_uscite
        decimal saldo
        decimal variazione_percentuale
    }
    SIMULAZIONE_INVESTIMENTO {
        int id PK
        date data_simulata
        decimal importo_investito
        decimal valore_attuale_simulato
        decimal rendimento_percentuale
    }

    UTENTE ||--o{ PREFERENZE_UTENTE : "ha storico"
    UTENTE ||--o{ SESSIONE : "genera"
    UTENTE ||--o{ CATEGORIA : "personalizza"
    UTENTE ||--o{ MOVIMENTO : "registra"
    UTENTE ||--o{ LIMITE_BUDGET : "imposta"
    UTENTE ||--o{ OBIETTIVO_RISPARMIO : "ha"
    UTENTE ||--o{ REPORT_MENSILE : "genera"
    UTENTE ||--o{ AMICO : "ha in rubrica"
    UTENTE ||--o{ MUTUO : "ha"
    UTENTE ||--o{ WATCHLIST : "ha"
    UTENTE ||--o{ ALERT_VALUTA : "imposta"
    UTENTE ||--o{ PRESTITO : "ha"
    UTENTE ||--o{ TRANSAZIONE_TITOLO : "effettua"
    UTENTE ||--o{ POSIZIONE_TITOLO : "possiede"
    UTENTE ||--o{ SIMULAZIONE_INVESTIMENTO : "crea"
    UTENTE ||--o{ ALERT_BUDGET : "riceve"

    MOVIMENTO }o--|| CATEGORIA : "appartiene a"
    MOVIMENTO }o--|| VALUTA : "espresso in"
    MOVIMENTO ||--o{ MOVIMENTO_TAG : "ha"
    TAG ||--o{ MOVIMENTO_TAG : "applicato in"
    MOVIMENTO ||--o| RATA_PRESTITO : "corrisponde a"
    MOVIMENTO ||--o| RATA_MUTUO : "corrisponde a"

    TASSO_DI_CAMBIO }o--|| VALUTA : "valuta base"
    TASSO_DI_CAMBIO }o--|| VALUTA : "valuta destinazione"
    ALERT_VALUTA }o--|| VALUTA : "monitora coppia"

    PRESTITO }o--|| AMICO : "con"
    PRESTITO ||--o{ RATA_PRESTITO : "composto da"

    MUTUO ||--o{ RATA_MUTUO : "composto da"

    LIMITE_BUDGET }o--o| CATEGORIA : "su categoria"
    ALERT_BUDGET }o--|| LIMITE_BUDGET : "generato da"

    TITOLO ||--o{ TRANSAZIONE_TITOLO : "ha"
    TITOLO ||--o{ POSIZIONE_TITOLO : "ha"
    TITOLO ||--o{ PREZZO_STORICO : "ha"
    TITOLO ||--o{ WATCHLIST : "in"
    SIMULAZIONE_INVESTIMENTO }o--|| TITOLO : "su"

    REPORT_MENSILE }o--|| VALUTA : "in valuta"

