erDiagram
    PERSONA {
        string codice_fiscale PK
        string nome
        string cognome
        string email
        string telefono
    }
    COPPIA {
        string username PK
        string cf_coniuge1 FK
        string cf_coniuge2 FK
        date data_prevista
        decimal budget_indicativo
    }
    DIPENDENTE {
        string codice_fiscale PK "FK"
        string email_aziendale
        date data_assunzione
        date data_fine_rapporto
        string stato
    }
    RUOLO {
        string nome_ruolo PK
        string descrizione
        int max_eventi_contemporanei
    }
    RUOLO_DIPENDENTE {
        string dipendente_cf PK "FK"
        string nome_ruolo PK "FK"
        date data_assegnazione
        boolean principale
    }
    MOTIVO_ASSENZA {
        string categoria PK
        string descrizione
        boolean remunerata
    }
    DISPONIBILITA {
        string dipendente_cf PK "FK"
        date data_inizio PK
        date data_fine
        string tipo
        string stato
    }
    ASSEGNAZIONE_DIPENDENTE {
        string username_coppia PK "FK"
        string dipendente_cf PK "FK"
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
    CATEGORIA_FORNITORE {
        string nome_categoria PK
        string descrizione
    }
    FORNITORE {
        string partita_iva PK
        string ragione_sociale
        string email
        string telefono
        string zona_operativita
        decimal valutazione_interna
        boolean attivo
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
        int numero_preventivo PK
        string username_coppia "FK"
        date data_evento "FK"
        date data_emissione
        date data_scadenza
        decimal importo
        string descrizione
        string stato
    }
    CONTRATTO {
        string partita_iva PK "FK"
        int numero_preventivo PK "FK"
        date data_firma
        decimal importo_definitivo
        decimal acconto
        decimal saldo
        string stato_pagamento
        string penali
    }
    INVITATO {
        string codice_fiscale PK "FK"
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
        string note_regia
        string stato_timeline
    }
    ATTIVITA_TIMELINE {
        string username_coppia PK "FK"
        date data_evento PK "FK"
        time orario_previsto PK
        string titolo
        int durata_minuti
        string descrizione
        string luogo
        string stato
        string nota_staff
        string nota_coppia
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
        string fase
        int giorni_prima
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
        string fase
        string stato
    }
    LISTA_NOZZE {
        string username_coppia PK "FK"
        date data_evento PK "FK"
        decimal totale_desiderato
        decimal totale_raccolto
        string stato_lista
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
        string tipo_frazionamento
    }
    PRENOTAZIONE {
        string codice_fiscale PK "FK"
        string username_coppia PK "FK"
        date data_evento PK "FK"
        string descrizione_regalo PK "FK"
        datetime data_ora PK
        decimal quota
        string messaggio_auguri
        string metodo_pagamento
        string stato
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
        date data
        int voto
        string testo
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

    %% Relazioni Gerarchiche IS-A
    PERSONA ||--o| DIPENDENTE : "e un"
    PERSONA ||--o| INVITATO : "e un"

    %% Relazioni Coppia e Persona
    COPPIA }|--|| PERSONA : "coniuge 1"
    COPPIA }|--|| PERSONA : "coniuge 2"

    %% Relazioni Staff e Ruoli
    DIPENDENTE ||--o{ RUOLO_DIPENDENTE : "abilitato a"
    RUOLO ||--o{ RUOLO_DIPENDENTE : "assegnato tramite"
    DIPENDENTE ||--o{ DISPONIBILITA : "ha"
    DISPONIBILITA }o--o| MOTIVO_ASSENZA : "motivata da"

    %% Relazioni Assegnazione e Organizzazione
    COPPIA ||--o{ ASSEGNAZIONE_DIPENDENTE : "ha storico"
    DIPENDENTE ||--o{ ASSEGNAZIONE_DIPENDENTE : "assegnato a"
    COPPIA ||--o{ EVENTO : "organizza"
    COPPIA ||--o{ COMUNICAZIONE : "scambia"
    DIPENDENTE ||--o{ COMUNICAZIONE : "invia"
    COPPIA ||--o{ APPUNTAMENTO : "fissa"
    DIPENDENTE ||--o{ APPUNTAMENTO : "conduce"

    %% Relazioni Logistica e Fornitori
    EVENTO }o--o{ LOCATION : "si svolge in"
    FORNITORE }o--|| CATEGORIA_FORNITORE : "appartiene a"
    FORNITORE ||--o{ COLLABORAZIONE : "ha storico"
    FORNITORE ||--o{ PREVENTIVO : "emette"
    EVENTO ||--o{ PREVENTIVO : "richiede (1 a N)"
    PREVENTIVO ||--o| CONTRATTO : "genera"

    %% Timeline
    EVENTO ||--|| TIMELINE : "ha"
    TIMELINE ||--o{ ATTIVITA_TIMELINE : "composta da"
    DIPENDENTE ||--o{ ATTIVITA_TIMELINE : "responsabile di"

    %% Checklist e Template
    EVENTO ||--|| CHECKLIST : "ha"
    CHECKLIST ||--o{ ATTIVITA_CHECKLIST : "composta da"
    DIPENDENTE ||--o{ ATTIVITA_CHECKLIST : "responsabile di"
    TEMPLATE_CHECKLIST ||--o{ VOCE_TEMPLATE : "composto da"
    TEMPLATE_CHECKLIST ||--o{ CHECKLIST : "istanzia"
    VOCE_TEMPLATE ||--o{ ATTIVITA_CHECKLIST : "genera"

    %% Lista Nozze
    EVENTO ||--|| LISTA_NOZZE : "ha"
    LISTA_NOZZE ||--o{ REGALO : "composta da"
    EVENTO ||--o{ TAVOLO : "dispone"

    %% Partecipazione e Quote
    INVITATO ||--o{ PARTECIPAZIONE : "partecipa tramite"
    EVENTO ||--o{ PARTECIPAZIONE : "registra"
    PARTECIPAZIONE }o--o| TAVOLO : "assegnata a"
    PARTECIPAZIONE }o--o| BOMBONIERA : "associata a"
    PARTECIPAZIONE ||--o{ PRENOTAZIONE : "versa quota"
    REGALO ||--o{ PRENOTAZIONE : "riceve quota"

    %% Portfolio
    EVENTO ||--o| RECENSIONE : "riceve"
    EVENTO ||--o{ FOTO : "documentato da"
