erDiagram
    COPPIA {
        string username PK
        string nome_coniuge1
        string nome_coniuge2
        string email
        string telefono
        date data_prevista
        decimal budget_indicativo
    }
    DIPENDENTE {
        string email PK
        string nome
        string cognome
        string telefono
        date data_assunzione
        date data_fine_rapporto
        string stato
    }
    RUOLO {
        string nome_ruolo PK
        string descrizione
        int max_eventi_contemporanei
    }
    MOTIVO_ASSENZA {
        string categoria PK
        string descrizione
        boolean remunerata
    }
    DISPONIBILITA {
        string dipendente_email PK "FK"
        date data_inizio PK
        date data_fine
        string tipo
        string stato
    }
    ASSEGNAZIONE_DIPENDENTE {
        string username_coppia PK "FK"
        string dipendente_email PK "FK"
        date data_inizio PK
        date data_fine
        string motivo_cambio
        boolean attiva
    }
    EVENTO {
        string username_coppia PK "FK"
        date data PK
        decimal budget_approvato
        int n_invitati_previsti
        int n_invitati_confermati
        string tipo_cerimonia
        string stato
    }
    LOCATION {
        string nome PK
        string indirizzo PK
        int capienza_max
        decimal prezzo_affitto
        string servizi_inclusi
    }
    FORNITORE {
        string partita_iva PK
        string ragione_sociale
        string zona_operativa
        decimal valutazione_interna
        boolean attivo
    }
    CATEGORIA_FORNITORE {
        string nome_categoria PK
        string descrizione
    }
    COLLABORAZIONE {
        string partita_iva PK "FK"
        date data_inizio PK
        date data_fine
        string stato
        string note
        decimal valutazione
    }
    PREVENTIVO {
        string partita_iva PK "FK"
        date data_emissione PK
        int num_preventivo PK
        decimal importo
        string descrizione
        string stato
    }
    CONTRATTO {
        string partita_iva PK "FK"
        date data_emissione PK "FK"
        int num_preventivo PK "FK"
        date data_firma
        decimal importo_definitivo
        decimal acconto
        decimal saldo
        string stato_pagamento
        string penali
    }
    INVITATO {
        string codice_fiscale PK
        string nome
        string cognome
        string email
        string telefono
        string relazione
    }
    PARTECIPAZIONE {
        string codice_fiscale PK "FK"
        string username_coppia PK "FK"
        date data_evento PK "FK"
        string stato
        string allergie
        string preferenza_menu
        boolean trasporto
        string note
    }
    PRENOTAZIONE {
        string codice_fiscale PK "FK"
        string username_coppia PK "FK"
        date data_evento PK "FK"
        string descrizione_regalo PK "FK"
        datetime data_ora PK
        decimal quota
        string messaggio_auguri
        string stato
    }
    TAVOLO {
        string username_coppia PK "FK"
        date data_evento PK "FK"
        string nome_numero PK
        int capienza
        string posizione
    }
    BOMBONIERA {
        string tipologia PK
        string descrizione
        string target
    }
    TIMELINE {
        string username_coppia PK "FK"
        date data_evento PK "FK"
        string note_generali
    }
    ATTIVITA_TIMELINE {
        string username_coppia PK "FK"
        date data_evento PK "FK"
        time orario_previsto PK
        int durata_minuti
        string descrizione
        string luogo
        string stato
        string nota_staff
        string nota_coppia
    }
    CHECKLIST {
        string username_coppia PK "FK"
        date data_evento PK "FK"
        string note_generali
    }
    ATTIVITA_CHECKLIST {
        string username_coppia PK "FK"
        date data_evento PK "FK"
        string titolo_attivita PK
        string descrizione
        date scadenza
        date data_completamento
        string priorita
        boolean completata
        string fase
    }
    TEMPLATE_CHECKLIST {
        string nome_template PK
        string tipo_cerimonia
        string descrizione
    }
    VOCE_TEMPLATE {
        string nome_template PK "FK"
        string titolo_voce PK
        string descrizione
        string priorita
        int giorni_prima
    }
    LISTA_NOZZE {
        string username_coppia PK "FK"
        date data_evento PK "FK"
        decimal totale_desiderato
        decimal totale_raccolto
    }
    REGALO {
        string username_coppia PK "FK"
        date data_evento PK "FK"
        string descrizione PK
        decimal prezzo
        string link
        string negozio
        string stato
        string tipologia
    }
    COMUNICAZIONE {
        string username_coppia PK "FK"
        datetime data_ora PK
        string mittente PK
        string oggetto
        string contenuto
        string argomento
        string allegati
    }
    APPUNTAMENTO {
        string username_coppia PK "FK"
        datetime data_ora PK
        string luogo_modalita
        int durata_minuti
        string resoconto
    }
    RECENSIONE {
        string username_coppia PK "FK"
        date data_evento PK "FK"
        int voto
        string testo
        date data
        string tag_stile
        string stagione
    }
    FOTO {
        string username_coppia PK "FK"
        date data_evento PK "FK"
        string percorso_file PK
        string didascalia
        string autore
        date data_scatto
    }

    %% Staff e Ruoli
    DIPENDENTE }o--|| RUOLO : "inquadrato in"
    DIPENDENTE ||--o{ DISPONIBILITA : "ha"
    DISPONIBILITA }o--o| MOTIVO_ASSENZA : "motivata da"
    COPPIA ||--o{ ASSEGNAZIONE_DIPENDENTE : "ha storico"
    DIPENDENTE ||--o{ ASSEGNAZIONE_DIPENDENTE : "assegnato a"

    %% Coppia ed Evento
    COPPIA ||--o{ EVENTO : "organizza"
    COPPIA ||--o{ COMUNICAZIONE : "scambia"
    DIPENDENTE ||--o{ COMUNICAZIONE : "invia"
    COPPIA ||--o{ APPUNTAMENTO : "fissa"
    DIPENDENTE ||--o{ APPUNTAMENTO : "conduce"

    %% Location e Fornitori
    EVENTO }o--o{ LOCATION : "si svolge in"
    FORNITORE }o--|| CATEGORIA_FORNITORE : "appartiene a"
    FORNITORE ||--o{ COLLABORAZIONE : "ha storico"
    FORNITORE ||--o{ PREVENTIVO : "emesso da"
    EVENTO ||--o{ PREVENTIVO : "richiede"
    PREVENTIVO ||--o| CONTRATTO : "genera"

    %% Logistica Evento
    EVENTO ||--|| TIMELINE : "ha"
    TIMELINE ||--o{ ATTIVITA_TIMELINE : "composta da"
    DIPENDENTE ||--o{ ATTIVITA_TIMELINE : "responsabile di"

    EVENTO ||--|| CHECKLIST : "ha"
    CHECKLIST ||--o{ ATTIVITA_CHECKLIST : "composta da"
    DIPENDENTE ||--o{ ATTIVITA_CHECKLIST : "responsabile di"
    TEMPLATE_CHECKLIST ||--o{ VOCE_TEMPLATE : "composto da"
    TEMPLATE_CHECKLIST ||--o{ CHECKLIST : "istanzia"
    VOCE_TEMPLATE ||--o{ ATTIVITA_CHECKLIST : "genera"

    EVENTO ||--|| LISTA_NOZZE : "ha"
    LISTA_NOZZE ||--o{ REGALO : "composta da"
    EVENTO ||--o{ TAVOLO : "dispone"

    %% Partecipazioni e Quote
    INVITATO ||--o{ PARTECIPAZIONE : "partecipa tramite"
    EVENTO ||--o{ PARTECIPAZIONE : "registra"
    PARTECIPAZIONE }o--o| TAVOLO : "assegnata a"
    PARTECIPAZIONE }o--o| BOMBONIERA : "associata a"

    INVITATO ||--o{ PRENOTAZIONE : "versa"
    REGALO ||--o{ PRENOTAZIONE : "riceve quota"

    %% Portfolio
    EVENTO ||--o| RECENSIONE : "riceve"
    EVENTO ||--o{ FOTO : "documentato da"
