-- =============================================================================
-- Schema SQL DDL per DB-MAIN: Wedding Planner Agency
-- Metodologia Accademica Basi di Dati (Prof. D. Maio, Prof.ssa A. Franco)
-- Compatibile con DB-MAIN SQL DDL Extractor (Standard SQL-92 / ANSI SQL)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. SOGGETTI FISICI, COPPIE E PERSONALE
-- -----------------------------------------------------------------------------

CREATE TABLE PERSONA (
    codice_fiscale VARCHAR(16) NOT NULL,
    nome VARCHAR(50) NOT NULL,
    cognome VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    PRIMARY KEY (codice_fiscale)
);

CREATE TABLE COPPIA (
    username VARCHAR(50) NOT NULL,
    cf_coniuge1 VARCHAR(16) NOT NULL,
    cf_coniuge2 VARCHAR(16) NOT NULL,
    data_prevista DATE NOT NULL,
    budget_indicativo DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (username),
    FOREIGN KEY (cf_coniuge1) REFERENCES PERSONA (codice_fiscale),
    FOREIGN KEY (cf_coniuge2) REFERENCES PERSONA (codice_fiscale)
);

CREATE TABLE DIPENDENTE (
    codice_fiscale VARCHAR(16) NOT NULL,
    email_aziendale VARCHAR(100) NOT NULL,
    data_assunzione DATE NOT NULL,
    data_fine_rapporto DATE,
    stato VARCHAR(20) NOT NULL,
    PRIMARY KEY (codice_fiscale),
    FOREIGN KEY (codice_fiscale) REFERENCES PERSONA (codice_fiscale)
);

CREATE TABLE RUOLO (
    nome_ruolo VARCHAR(50) NOT NULL,
    descrizione VARCHAR(255) NOT NULL,
    max_eventi_contemporanei INTEGER NOT NULL,
    PRIMARY KEY (nome_ruolo)
);

CREATE TABLE RUOLO_DIPENDENTE (
    dipendente_cf VARCHAR(16) NOT NULL,
    nome_ruolo VARCHAR(50) NOT NULL,
    data_assegnazione DATE NOT NULL,
    principale CHAR(1) NOT NULL,
    PRIMARY KEY (dipendente_cf, nome_ruolo),
    FOREIGN KEY (dipendente_cf) REFERENCES DIPENDENTE (codice_fiscale),
    FOREIGN KEY (nome_ruolo) REFERENCES RUOLO (nome_ruolo)
);

CREATE TABLE MOTIVO_ASSENZA (
    categoria VARCHAR(50) NOT NULL,
    descrizione VARCHAR(255) NOT NULL,
    remunerata CHAR(1) NOT NULL,
    PRIMARY KEY (categoria)
);

CREATE TABLE DISPONIBILITA (
    dipendente_cf VARCHAR(16) NOT NULL,
    data_inizio DATE NOT NULL,
    data_fine DATE NOT NULL,
    tipo VARCHAR(20) NOT NULL,
    stato VARCHAR(20) NOT NULL,
    categoria_assenza VARCHAR(50),
    PRIMARY KEY (dipendente_cf, data_inizio),
    FOREIGN KEY (dipendente_cf) REFERENCES DIPENDENTE (codice_fiscale),
    FOREIGN KEY (categoria_assenza) REFERENCES MOTIVO_ASSENZA (categoria)
);

CREATE TABLE ASSEGNAZIONE_DIPENDENTE (
    username_coppia VARCHAR(50) NOT NULL,
    dipendente_cf VARCHAR(16) NOT NULL,
    data_inizio DATE NOT NULL,
    data_fine DATE,
    motivo_cambio VARCHAR(255),
    attiva CHAR(1) NOT NULL,
    PRIMARY KEY (username_coppia, dipendente_cf, data_inizio),
    FOREIGN KEY (username_coppia) REFERENCES COPPIA (username),
    FOREIGN KEY (dipendente_cf) REFERENCES DIPENDENTE (codice_fiscale)
);

-- -----------------------------------------------------------------------------
-- 2. EVENTO, LOCATION E LOGISTICA
-- -----------------------------------------------------------------------------

CREATE TABLE EVENTO (
    username_coppia VARCHAR(50) NOT NULL,
    data DATE NOT NULL,
    budget_approvato DECIMAL(10,2) NOT NULL,
    n_invitati_previsti INTEGER NOT NULL,
    n_invitati_confermati INTEGER NOT NULL,
    tipo_cerimonia VARCHAR(50) NOT NULL,
    stato VARCHAR(30) NOT NULL,
    PRIMARY KEY (username_coppia, data),
    FOREIGN KEY (username_coppia) REFERENCES COPPIA (username)
);

CREATE TABLE LOCATION (
    nome VARCHAR(100) NOT NULL,
    indirizzo VARCHAR(150) NOT NULL,
    capienza_max INTEGER NOT NULL,
    prezzo_affitto DECIMAL(10,2) NOT NULL,
    servizi_inclusi VARCHAR(255),
    PRIMARY KEY (nome, indirizzo)
);

CREATE TABLE SVOLGIMENTO_EVENTO (
    username_coppia VARCHAR(50) NOT NULL,
    data_evento DATE NOT NULL,
    nome_location VARCHAR(100) NOT NULL,
    indirizzo_location VARCHAR(150) NOT NULL,
    orario_inizio TIME NOT NULL,
    orario_fine TIME NOT NULL,
    PRIMARY KEY (username_coppia, data_evento, nome_location, indirizzo_location),
    FOREIGN KEY (username_coppia, data_evento) REFERENCES EVENTO (username_coppia, data),
    FOREIGN KEY (nome_location, indirizzo_location) REFERENCES LOCATION (nome, indirizzo)
);

CREATE TABLE TAVOLO (
    username_coppia VARCHAR(50) NOT NULL,
    data_evento DATE NOT NULL,
    nome_numero VARCHAR(50) NOT NULL,
    capienza INTEGER NOT NULL,
    posizione VARCHAR(100),
    PRIMARY KEY (username_coppia, data_evento, nome_numero),
    FOREIGN KEY (username_coppia, data_evento) REFERENCES EVENTO (username_coppia, data)
);

CREATE TABLE BOMBONIERA (
    tipologia VARCHAR(50) NOT NULL,
    descrizione VARCHAR(255) NOT NULL,
    target VARCHAR(100),
    PRIMARY KEY (tipologia)
);

-- -----------------------------------------------------------------------------
-- 3. FORNITORI, PREVENTIVI (1:N) E CONTRATTI
-- -----------------------------------------------------------------------------

CREATE TABLE CATEGORIA_FORNITORE (
    nome_categoria VARCHAR(50) NOT NULL,
    descrizione VARCHAR(255),
    PRIMARY KEY (nome_categoria)
);

CREATE TABLE FORNITORE (
    partita_iva VARCHAR(11) NOT NULL,
    ragione_sociale VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    zona_operativita VARCHAR(100) NOT NULL,
    valutazione_interna DECIMAL(3,2) NOT NULL,
    attivo CHAR(1) NOT NULL,
    nome_categoria VARCHAR(50) NOT NULL,
    PRIMARY KEY (partita_iva),
    FOREIGN KEY (nome_categoria) REFERENCES CATEGORIA_FORNITORE (nome_categoria)
);

CREATE TABLE COLLABORAZIONE (
    partita_iva VARCHAR(11) NOT NULL,
    data_inizio DATE NOT NULL,
    data_fine DATE,
    stato VARCHAR(20) NOT NULL,
    note VARCHAR(255),
    valutazione DECIMAL(3,2),
    PRIMARY KEY (partita_iva, data_inizio),
    FOREIGN KEY (partita_iva) REFERENCES FORNITORE (partita_iva)
);

CREATE TABLE PREVENTIVO (
    partita_iva VARCHAR(11) NOT NULL,
    numero_preventivo INTEGER NOT NULL,
    username_coppia VARCHAR(50) NOT NULL,
    data_evento DATE NOT NULL,
    dipendente_cf VARCHAR(16) NOT NULL,
    data_emissione DATE NOT NULL,
    data_scadenza DATE,
    importo DECIMAL(10,2) NOT NULL,
    descrizione VARCHAR(255) NOT NULL,
    stato VARCHAR(20) NOT NULL,
    PRIMARY KEY (partita_iva, numero_preventivo),
    FOREIGN KEY (partita_iva) REFERENCES FORNITORE (partita_iva),
    FOREIGN KEY (username_coppia, data_evento) REFERENCES EVENTO (username_coppia, data),
    FOREIGN KEY (dipendente_cf) REFERENCES DIPENDENTE (codice_fiscale)
);

CREATE TABLE CONTRATTO (
    partita_iva VARCHAR(11) NOT NULL,
    numero_preventivo INTEGER NOT NULL,
    data_firma DATE NOT NULL,
    importo_definitivo DECIMAL(10,2) NOT NULL,
    acconto DECIMAL(10,2) NOT NULL,
    saldo DECIMAL(10,2) NOT NULL,
    stato_pagamento VARCHAR(30) NOT NULL,
    penali VARCHAR(255),
    PRIMARY KEY (partita_iva, numero_preventivo),
    FOREIGN KEY (partita_iva, numero_preventivo) REFERENCES PREVENTIVO (partita_iva, numero_preventivo)
);

-- -----------------------------------------------------------------------------
-- 4. TIMELINE DI REGIA E CHECKLIST CON TEMPLATE
-- -----------------------------------------------------------------------------

CREATE TABLE TIMELINE (
    username_coppia VARCHAR(50) NOT NULL,
    data_evento DATE NOT NULL,
    note_regia VARCHAR(255),
    stato_timeline VARCHAR(20) NOT NULL,
    PRIMARY KEY (username_coppia, data_evento),
    FOREIGN KEY (username_coppia, data_evento) REFERENCES EVENTO (username_coppia, data)
);

CREATE TABLE ATTIVITA_TIMELINE (
    username_coppia VARCHAR(50) NOT NULL,
    data_evento DATE NOT NULL,
    orario_previsto TIME NOT NULL,
    titolo VARCHAR(100) NOT NULL,
    durata_minuti INTEGER NOT NULL,
    descrizione VARCHAR(255),
    luogo VARCHAR(100),
    stato VARCHAR(20) NOT NULL,
    nota_staff VARCHAR(255),
    nota_coppia VARCHAR(255),
    dipendente_cf VARCHAR(16) NOT NULL,
    partita_iva_fornitore VARCHAR(11),
    PRIMARY KEY (username_coppia, data_evento, orario_previsto),
    FOREIGN KEY (username_coppia, data_evento) REFERENCES TIMELINE (username_coppia, data_evento),
    FOREIGN KEY (dipendente_cf) REFERENCES DIPENDENTE (codice_fiscale),
    FOREIGN KEY (partita_iva_fornitore) REFERENCES FORNITORE (partita_iva)
);

CREATE TABLE TEMPLATE_CHECKLIST (
    nome_template VARCHAR(50) NOT NULL,
    tipo_cerimonia VARCHAR(50) NOT NULL,
    descrizione VARCHAR(255),
    PRIMARY KEY (nome_template)
);

CREATE TABLE VOCE_TEMPLATE (
    nome_template VARCHAR(50) NOT NULL,
    titolo_voce VARCHAR(100) NOT NULL,
    descrizione VARCHAR(255),
    priorita VARCHAR(20) NOT NULL,
    fase VARCHAR(50) NOT NULL,
    giorni_prima INTEGER NOT NULL,
    PRIMARY KEY (nome_template, titolo_voce),
    FOREIGN KEY (nome_template) REFERENCES TEMPLATE_CHECKLIST (nome_template)
);

CREATE TABLE CHECKLIST (
    username_coppia VARCHAR(50) NOT NULL,
    data_evento DATE NOT NULL,
    nome_template VARCHAR(50),
    note_generali VARCHAR(255),
    PRIMARY KEY (username_coppia, data_evento),
    FOREIGN KEY (username_coppia, data_evento) REFERENCES EVENTO (username_coppia, data),
    FOREIGN KEY (nome_template) REFERENCES TEMPLATE_CHECKLIST (nome_template)
);

CREATE TABLE ATTIVITA_CHECKLIST (
    username_coppia VARCHAR(50) NOT NULL,
    data_evento DATE NOT NULL,
    titolo_attivita VARCHAR(100) NOT NULL,
    descrizione VARCHAR(255),
    scadenza DATE NOT NULL,
    data_completamento DATE,
    priorita VARCHAR(20) NOT NULL,
    fase VARCHAR(50) NOT NULL,
    stato VARCHAR(20) NOT NULL,
    dipendente_cf VARCHAR(16),
    PRIMARY KEY (username_coppia, data_evento, titolo_attivita),
    FOREIGN KEY (username_coppia, data_evento) REFERENCES CHECKLIST (username_coppia, data_evento),
    FOREIGN KEY (dipendente_cf) REFERENCES DIPENDENTE (codice_fiscale)
);

-- -----------------------------------------------------------------------------
-- 5. OSPITI, PARTECIPAZIONI, LISTA NOZZE E QUOTE REGALO
-- -----------------------------------------------------------------------------

CREATE TABLE INVITATO (
    codice_fiscale VARCHAR(16) NOT NULL,
    relazione VARCHAR(50) NOT NULL,
    tipologia_bomboniera VARCHAR(50),
    PRIMARY KEY (codice_fiscale),
    FOREIGN KEY (codice_fiscale) REFERENCES PERSONA (codice_fiscale),
    FOREIGN KEY (tipologia_bomboniera) REFERENCES BOMBONIERA (tipologia)
);

CREATE TABLE PARTECIPAZIONE (
    codice_fiscale VARCHAR(16) NOT NULL,
    username_coppia VARCHAR(50) NOT NULL,
    data_evento DATE NOT NULL,
    stato VARCHAR(20) NOT NULL,
    allergie VARCHAR(255),
    preferenza_menu VARCHAR(100),
    trasporto CHAR(1) NOT NULL,
    note VARCHAR(255),
    tavolo_nome_numero VARCHAR(50),
    PRIMARY KEY (codice_fiscale, username_coppia, data_evento),
    FOREIGN KEY (codice_fiscale) REFERENCES INVITATO (codice_fiscale),
    FOREIGN KEY (username_coppia, data_evento) REFERENCES EVENTO (username_coppia, data),
    FOREIGN KEY (username_coppia, data_evento, tavolo_nome_numero) REFERENCES TAVOLO (username_coppia, data_evento, nome_numero)
);

CREATE TABLE LISTA_NOZZE (
    username_coppia VARCHAR(50) NOT NULL,
    data_evento DATE NOT NULL,
    totale_desiderato DECIMAL(10,2) NOT NULL,
    totale_raccolto DECIMAL(10,2) NOT NULL,
    stato_lista VARCHAR(20) NOT NULL,
    PRIMARY KEY (username_coppia, data_evento),
    FOREIGN KEY (username_coppia, data_evento) REFERENCES EVENTO (username_coppia, data)
);

CREATE TABLE REGALO (
    username_coppia VARCHAR(50) NOT NULL,
    data_evento DATE NOT NULL,
    descrizione VARCHAR(100) NOT NULL,
    prezzo DECIMAL(10,2) NOT NULL,
    link VARCHAR(255),
    negozio VARCHAR(100),
    stato VARCHAR(30) NOT NULL,
    tipologia VARCHAR(50) NOT NULL,
    tipo_frazionamento VARCHAR(30) NOT NULL,
    PRIMARY KEY (username_coppia, data_evento, descrizione),
    FOREIGN KEY (username_coppia, data_evento) REFERENCES LISTA_NOZZE (username_coppia, data_evento)
);

CREATE TABLE QUOTA_REGALO (
    codice_fiscale VARCHAR(16) NOT NULL,
    username_coppia VARCHAR(50) NOT NULL,
    data_evento DATE NOT NULL,
    data_ora TIMESTAMP NOT NULL,
    importo DECIMAL(10,2) NOT NULL,
    messaggio_auguri VARCHAR(255),
    metodo_pagamento VARCHAR(50) NOT NULL,
    stato VARCHAR(20) NOT NULL,
    descrizione_regalo VARCHAR(100),
    PRIMARY KEY (codice_fiscale, username_coppia, data_evento, data_ora),
    FOREIGN KEY (codice_fiscale) REFERENCES INVITATO (codice_fiscale),
    FOREIGN KEY (username_coppia, data_evento) REFERENCES EVENTO (username_coppia, data),
    FOREIGN KEY (username_coppia, data_evento, descrizione_regalo) REFERENCES REGALO (username_coppia, data_evento, descrizione)
);

-- -----------------------------------------------------------------------------
-- 6. COMUNICAZIONI, APPUNTAMENTI E PORTFOLIO
-- -----------------------------------------------------------------------------

CREATE TABLE COMUNICAZIONE (
    username_coppia VARCHAR(50) NOT NULL,
    data_ora TIMESTAMP NOT NULL,
    mittente VARCHAR(100) NOT NULL,
    dipendente_cf VARCHAR(16) NOT NULL,
    oggetto VARCHAR(150) NOT NULL,
    contenuto VARCHAR(255) NOT NULL,
    argomento VARCHAR(50) NOT NULL,
    allegati VARCHAR(255),
    PRIMARY KEY (username_coppia, data_ora, mittente),
    FOREIGN KEY (username_coppia) REFERENCES COPPIA (username),
    FOREIGN KEY (dipendente_cf) REFERENCES DIPENDENTE (codice_fiscale)
);

CREATE TABLE APPUNTAMENTO (
    username_coppia VARCHAR(50) NOT NULL,
    data_ora TIMESTAMP NOT NULL,
    dipendente_cf VARCHAR(16) NOT NULL,
    categoria_assenza VARCHAR(50),
    luogo_modalita VARCHAR(100) NOT NULL,
    durata_minuti INTEGER NOT NULL,
    resoconto VARCHAR(255),
    stato VARCHAR(20) NOT NULL,
    PRIMARY KEY (username_coppia, data_ora),
    FOREIGN KEY (username_coppia) REFERENCES COPPIA (username),
    FOREIGN KEY (dipendente_cf) REFERENCES DIPENDENTE (codice_fiscale),
    FOREIGN KEY (categoria_assenza) REFERENCES MOTIVO_ASSENZA (categoria)
);

CREATE TABLE RECENSIONE (
    username_coppia VARCHAR(50) NOT NULL,
    data_evento DATE NOT NULL,
    data DATE NOT NULL,
    voto INTEGER NOT NULL,
    testo VARCHAR(255),
    tag_stile VARCHAR(100),
    stagione VARCHAR(20),
    PRIMARY KEY (username_coppia, data_evento),
    FOREIGN KEY (username_coppia, data_evento) REFERENCES EVENTO (username_coppia, data)
);

CREATE TABLE FOTO (
    username_coppia VARCHAR(50) NOT NULL,
    data_evento DATE NOT NULL,
    percorso_file VARCHAR(255) NOT NULL,
    didascalia VARCHAR(255),
    autore VARCHAR(100),
    data_scatto DATE NOT NULL,
    PRIMARY KEY (username_coppia, data_evento, percorso_file),
    FOREIGN KEY (username_coppia, data_evento) REFERENCES EVENTO (username_coppia, data)
);
