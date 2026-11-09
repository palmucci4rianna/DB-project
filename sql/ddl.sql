-- =============================================================================
-- PROGETTAZIONE FISICA DATABASE: WEDDING PLANNER AGENCY
-- DBMS Target: MySQL 8.0 Community Server (Storage Engine: InnoDB)
-- File: sql/ddl.sql
-- Autore: Progetto Basi di Dati - Università di Bologna (Prof. D. Maio, Prof.ssa A. Franco)
-- Caratteristiche: Normalizzazione 3NF/BCNF, Chiavi Naturali, Indici B-Tree, Trigger
-- =============================================================================
--
-- NOTA COMPATIBILITA' MySQL 8 (errore 3823)
-- MySQL 8 NON permette che una colonna usata in un vincolo CHECK faccia parte
-- di una foreign key con azione referenziale ON UPDATE CASCADE (né SET NULL /
-- SET DEFAULT). ON DELETE CASCADE e RESTRICT invece sono ammessi.
--   Errore originale: "Column 'cf_coniuge1' cannot be used in a check constraint
--   'chk_coppia_due_coniugi_distinti': needed in a foreign key constraint
--   'fk_coppia_coniuge1' referential action."
-- Soluzione adottata: sulle 5 FK coinvolte (cercare "FIX MySQL 8") si usa
-- ON UPDATE RESTRICT al posto di ON UPDATE CASCADE, mantenendo i CHECK.
-- Conseguenza: non si può modificare la chiave riferita (es. il codice fiscale
-- di una persona o la data di un evento) finché esistono righe che la usano
-- in quelle tabelle. Accettabile: sono chiavi naturali che non dovrebbero cambiare.
-- =============================================================================

DROP DATABASE IF EXISTS wedding_planner;
CREATE DATABASE wedding_planner
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE wedding_planner;

-- Disabilitazione temporanea per velocizzare la creazione e abilitazione successiva
SET foreign_key_checks = 1;

-- =============================================================================
-- PARTE 1: DEFINIZIONE TABELLE E VINCOLI DDL
-- =============================================================================

-- 1. SOGGETTI FISICI: PERSONA
CREATE TABLE PERSONA (
    codice_fiscale      VARCHAR(16)     NOT NULL,
    nome                VARCHAR(50)     NOT NULL,
    cognome             VARCHAR(50)     NOT NULL,
    email               VARCHAR(100)    NOT NULL,
    telefono            VARCHAR(20)     NULL,
    CONSTRAINT pk_persona PRIMARY KEY (codice_fiscale),
    CONSTRAINT chk_persona_cf_len CHECK (CHAR_LENGTH(codice_fiscale) = 16)
) ENGINE=InnoDB;

-- 2. SOGGETTI COMMITTENTI: COPPIA
CREATE TABLE COPPIA (
    username            VARCHAR(50)     NOT NULL,
    cf_coniuge1         VARCHAR(16)     NOT NULL,
    cf_coniuge2         VARCHAR(16)     NOT NULL,
    data_prevista       DATE            NOT NULL,
    budget_indicativo   DECIMAL(10,2)   NOT NULL,
    CONSTRAINT pk_coppia PRIMARY KEY (username),
    -- FIX MySQL 8: era ON UPDATE CASCADE, in conflitto con chk_coppia_due_coniugi_distinti
    CONSTRAINT fk_coppia_coniuge1 FOREIGN KEY (cf_coniuge1)
        REFERENCES PERSONA (codice_fiscale) ON DELETE RESTRICT ON UPDATE RESTRICT,
    -- FIX MySQL 8: era ON UPDATE CASCADE, in conflitto con chk_coppia_due_coniugi_distinti
    CONSTRAINT fk_coppia_coniuge2 FOREIGN KEY (cf_coniuge2)
        REFERENCES PERSONA (codice_fiscale) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT chk_coppia_due_coniugi_distinti CHECK (cf_coniuge1 <> cf_coniuge2),
    CONSTRAINT chk_coppia_budget_positivo CHECK (budget_indicativo > 0)
) ENGINE=InnoDB;

-- 3. STAFF AZIENDALE: DIPENDENTE
CREATE TABLE DIPENDENTE (
    codice_fiscale      VARCHAR(16)     NOT NULL,
    email_aziendale     VARCHAR(100)    NOT NULL UNIQUE,
    data_assunzione     DATE            NOT NULL,
    data_fine_rapporto  DATE            NULL,
    stato               VARCHAR(20)     NOT NULL DEFAULT 'attivo',
    CONSTRAINT pk_dipendente PRIMARY KEY (codice_fiscale),
    CONSTRAINT fk_dipendente_persona FOREIGN KEY (codice_fiscale) 
        REFERENCES PERSONA (codice_fiscale) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_dipendente_stato CHECK (stato IN ('attivo', 'in_congedo', 'dimesso', 'licenziato')),
    CONSTRAINT chk_dipendente_fine_rapporto CHECK (data_fine_rapporto IS NULL OR data_fine_rapporto >= data_assunzione)
) ENGINE=InnoDB;

-- 4. MANSIONI AZIENDALI: RUOLO
CREATE TABLE RUOLO (
    nome_ruolo                  VARCHAR(50)     NOT NULL,
    descrizione                 VARCHAR(255)    NOT NULL,
    max_eventi_contemporanei    INT             NOT NULL,
    CONSTRAINT pk_ruolo PRIMARY KEY (nome_ruolo),
    CONSTRAINT chk_ruolo_max_eventi CHECK (max_eventi_contemporanei > 0)
) ENGINE=InnoDB;

-- 5. ASSEGNAZIONE MANSIONI: RUOLO_DIPENDENTE
CREATE TABLE RUOLO_DIPENDENTE (
    dipendente_cf       VARCHAR(16)     NOT NULL,
    nome_ruolo          VARCHAR(50)     NOT NULL,
    CONSTRAINT pk_ruolo_dipendente PRIMARY KEY (dipendente_cf, nome_ruolo),
    CONSTRAINT fk_rd_dipendente FOREIGN KEY (dipendente_cf) 
        REFERENCES DIPENDENTE (codice_fiscale) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_rd_ruolo FOREIGN KEY (nome_ruolo) 
        REFERENCES RUOLO (nome_ruolo) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 6. MOTIVAZIONI ASSENZA: MOTIVO_ASSENZA
CREATE TABLE MOTIVO_ASSENZA (
    categoria           VARCHAR(50)     NOT NULL,
    descrizione         VARCHAR(255)    NOT NULL,
    remunerata          CHAR(1)         NOT NULL DEFAULT 'S',
    CONSTRAINT pk_motivo_assenza PRIMARY KEY (categoria),
    CONSTRAINT chk_motivo_remunerata CHECK (remunerata IN ('S', 'N'))
) ENGINE=InnoDB;

-- 7. CALENDARIO ASSENZE: DISPONIBILITA
CREATE TABLE DISPONIBILITA (
    id_disponibilita    INT AUTO_INCREMENT NOT NULL,
    dipendente_cf       VARCHAR(16)     NOT NULL,
    data_inizio         DATE            NOT NULL,
    data_fine           DATE            NOT NULL,
    categoria_assenza   VARCHAR(50)     NOT NULL,
    note                VARCHAR(255)    NULL,
    CONSTRAINT pk_disponibilita PRIMARY KEY (id_disponibilita),
    CONSTRAINT fk_disp_dipendente FOREIGN KEY (dipendente_cf) 
        REFERENCES DIPENDENTE (codice_fiscale) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_disp_motivo FOREIGN KEY (categoria_assenza) 
        REFERENCES MOTIVO_ASSENZA (categoria) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_disp_date CHECK (data_inizio <= data_fine)
) ENGINE=InnoDB;

-- 8. STORICO COORDINATORE: ASSEGNAZIONE_DIPENDENTE
CREATE TABLE ASSEGNAZIONE_DIPENDENTE (
    username_coppia     VARCHAR(50)     NOT NULL,
    dipendente_cf       VARCHAR(16)     NOT NULL,
    data_inizio         DATE            NOT NULL,
    data_fine           DATE            NULL,
    motivo_cambio       VARCHAR(255)    NULL,
    attiva              CHAR(1)         NOT NULL DEFAULT 'S',
    CONSTRAINT pk_assegnazione_dipendente PRIMARY KEY (username_coppia, dipendente_cf, data_inizio),
    CONSTRAINT fk_ass_coppia FOREIGN KEY (username_coppia) 
        REFERENCES COPPIA (username) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_ass_dipendente FOREIGN KEY (dipendente_cf) 
        REFERENCES DIPENDENTE (codice_fiscale) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_ass_attiva CHECK (attiva IN ('S', 'N')),
    CONSTRAINT chk_ass_date CHECK (data_fine IS NULL OR data_inizio <= data_fine)
) ENGINE=InnoDB;

-- 9. EVENTO / MATRIMONIO
CREATE TABLE EVENTO (
    username_coppia     VARCHAR(50)     NOT NULL,
    data                DATE            NOT NULL,
    budget_effettivo    DECIMAL(10,2)   NOT NULL,
    n_invitati_previsti INT             NOT NULL,
    tipo_cerimonia      VARCHAR(50)     NOT NULL,
    tema_stile          VARCHAR(100)    NOT NULL,
    stato               VARCHAR(20)     NOT NULL DEFAULT 'in_pianificazione',
    CONSTRAINT pk_evento PRIMARY KEY (username_coppia, data),
    CONSTRAINT fk_evento_coppia FOREIGN KEY (username_coppia) 
        REFERENCES COPPIA (username) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_evento_stato CHECK (stato IN ('in_pianificazione', 'confermato', 'completato', 'annullato')),
    CONSTRAINT chk_evento_budget CHECK (budget_effettivo > 0),
    CONSTRAINT chk_evento_invitati CHECK (n_invitati_previsti > 0)
) ENGINE=InnoDB;

-- 10. SEDI E STRUTTURE: LOCATION
CREATE TABLE LOCATION (
    nome_location       VARCHAR(100)    NOT NULL,
    tipologia           VARCHAR(50)     NOT NULL,
    indirizzo           VARCHAR(150)    NOT NULL,
    citta               VARCHAR(50)     NOT NULL,
    capienza_massima    INT             NOT NULL,
    costo_affitto       DECIMAL(10,2)   NOT NULL,
    referente_nome      VARCHAR(100)    NOT NULL,
    referente_telefono  VARCHAR(20)     NOT NULL,
    CONSTRAINT pk_location PRIMARY KEY (nome_location),
    CONSTRAINT chk_location_capienza CHECK (capienza_massima > 0),
    CONSTRAINT chk_location_costo CHECK (costo_affitto >= 0)
) ENGINE=InnoDB;

-- 11. OCCUPAZIONE SEDI: SVOLGIMENTO_EVENTO
CREATE TABLE SVOLGIMENTO_EVENTO (
    username_coppia     VARCHAR(50)     NOT NULL,
    data_evento         DATE            NOT NULL,
    nome_location       VARCHAR(100)    NOT NULL,
    fascia_oraria       VARCHAR(50)     NOT NULL,
    tipo_utilizzo       VARCHAR(50)     NOT NULL,
    CONSTRAINT pk_svolgimento_evento PRIMARY KEY (username_coppia, data_evento, nome_location, fascia_oraria),
    CONSTRAINT fk_se_evento FOREIGN KEY (username_coppia, data_evento) 
        REFERENCES EVENTO (username_coppia, data) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_se_location FOREIGN KEY (nome_location) 
        REFERENCES LOCATION (nome_location) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 12. DISPOSIZIONE SALA: TAVOLO
CREATE TABLE TAVOLO (
    username_coppia     VARCHAR(50)     NOT NULL,
    data_evento         DATE            NOT NULL,
    nome_numero         VARCHAR(50)     NOT NULL,
    capienza            INT             NOT NULL,
    forma               VARCHAR(30)     NOT NULL,
    zona_sala           VARCHAR(50)     NOT NULL,
    CONSTRAINT pk_tavolo PRIMARY KEY (username_coppia, data_evento, nome_numero),
    CONSTRAINT fk_tavolo_evento FOREIGN KEY (username_coppia, data_evento) 
        REFERENCES EVENTO (username_coppia, data) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_tavolo_capienza CHECK (capienza > 0)
) ENGINE=InnoDB;

-- 13. OMAGGI OSPITI: BOMBONIERA
CREATE TABLE BOMBONIERA (
    tipologia           VARCHAR(50)     NOT NULL,
    descrizione         VARCHAR(255)    NOT NULL,
    target              VARCHAR(50)     NOT NULL,
    CONSTRAINT pk_bomboniera PRIMARY KEY (tipologia)
) ENGINE=InnoDB;

-- 14. SETTORI MERCEOLOGICI: CATEGORIA_FORNITORE
CREATE TABLE CATEGORIA_FORNITORE (
    nome_categoria      VARCHAR(50)     NOT NULL,
    descrizione         VARCHAR(255)    NOT NULL,
    CONSTRAINT pk_categoria_fornitore PRIMARY KEY (nome_categoria)
) ENGINE=InnoDB;

-- 15. ANAGRAFICA FORNITORI: FORNITORE
CREATE TABLE FORNITORE (
    partita_iva         VARCHAR(20)     NOT NULL,
    ragione_sociale     VARCHAR(100)    NOT NULL,
    indirizzo           VARCHAR(150)    NOT NULL,
    telefono            VARCHAR(20)     NOT NULL,
    email               VARCHAR(100)    NOT NULL,
    sito_web            VARCHAR(100)    NULL,
    attivo              CHAR(1)         NOT NULL DEFAULT 'S',
    nome_categoria      VARCHAR(50)     NOT NULL,
    CONSTRAINT pk_fornitore PRIMARY KEY (partita_iva),
    CONSTRAINT fk_fornitore_categoria FOREIGN KEY (nome_categoria) 
        REFERENCES CATEGORIA_FORNITORE (nome_categoria) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_fornitore_attivo CHECK (attivo IN ('S', 'N'))
) ENGINE=InnoDB;

-- 16. ACCORDI QUADRO: COLLABORAZIONE
CREATE TABLE COLLABORAZIONE (
    id_collaborazione   INT AUTO_INCREMENT NOT NULL,
    fornitore_piva      VARCHAR(20)     NOT NULL,
    data_inizio         DATE            NOT NULL,
    data_fine           DATE            NULL,
    stato               VARCHAR(20)     NOT NULL DEFAULT 'attiva',
    termini_accordo     VARCHAR(255)    NOT NULL,
    CONSTRAINT pk_collaborazione PRIMARY KEY (id_collaborazione),
    CONSTRAINT fk_collab_fornitore FOREIGN KEY (fornitore_piva) 
        REFERENCES FORNITORE (partita_iva) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_collab_stato CHECK (stato IN ('attiva', 'sospesa', 'cessata')),
    CONSTRAINT chk_collab_date CHECK (data_fine IS NULL OR data_inizio <= data_fine)
) ENGINE=InnoDB;

-- 17. PREVENTIVI FORNITORI: PREVENTIVO
CREATE TABLE PREVENTIVO (
    numero_preventivo   VARCHAR(50)     NOT NULL,
    fornitore_piva      VARCHAR(20)     NOT NULL,
    username_coppia     VARCHAR(50)     NOT NULL,
    data_evento         DATE            NOT NULL,
    data_emissione      DATE            NOT NULL,
    data_scadenza       DATE            NULL,
    importo_proposto    DECIMAL(10,2)   NOT NULL,
    stato               VARCHAR(20)     NOT NULL DEFAULT 'in_valutazione',
    dettagli_servizio   TEXT            NOT NULL,
    CONSTRAINT pk_preventivo PRIMARY KEY (numero_preventivo, fornitore_piva),
    CONSTRAINT fk_prev_fornitore FOREIGN KEY (fornitore_piva) 
        REFERENCES FORNITORE (partita_iva) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_prev_evento FOREIGN KEY (username_coppia, data_evento) 
        REFERENCES EVENTO (username_coppia, data) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_prev_stato CHECK (stato IN ('in_valutazione', 'accettato', 'rifiutato', 'scaduto')),
    CONSTRAINT chk_prev_date CHECK (data_scadenza IS NULL OR data_emissione <= data_scadenza),
    CONSTRAINT chk_prev_importo CHECK (importo_proposto > 0)
) ENGINE=InnoDB;

-- 18. CONTRATTI FORNITORI: CONTRATTO
CREATE TABLE CONTRATTO (
    numero_preventivo   VARCHAR(50)     NOT NULL,
    fornitore_piva      VARCHAR(20)     NOT NULL,
    data_firma          DATE            NOT NULL,
    importo_concordato  DECIMAL(10,2)   NOT NULL,
    acconto_versato     DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
    stato_pagamento     VARCHAR(20)     NOT NULL DEFAULT 'acconto',
    clausole_recesso    TEXT            NOT NULL,
    CONSTRAINT pk_contratto PRIMARY KEY (numero_preventivo, fornitore_piva),
    CONSTRAINT fk_contratto_preventivo FOREIGN KEY (numero_preventivo, fornitore_piva) 
        REFERENCES PREVENTIVO (numero_preventivo, fornitore_piva) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_contratto_stato_pag CHECK (stato_pagamento IN ('da_saldare', 'acconto', 'saldato')),
    CONSTRAINT chk_contratto_importi CHECK (importo_concordato > 0 AND acconto_versato >= 0 AND acconto_versato <= importo_concordato)
) ENGINE=InnoDB;

-- 19. REGIA ORARIA: TIMELINE
CREATE TABLE TIMELINE (
    username_coppia     VARCHAR(50)     NOT NULL,
    data_evento         DATE            NOT NULL,
    ora_inizio          TIME            NOT NULL,
    ora_fine            TIME            NOT NULL,
    stato_regia         VARCHAR(20)     NOT NULL DEFAULT 'bozza',
    CONSTRAINT pk_timeline PRIMARY KEY (username_coppia, data_evento),
    CONSTRAINT fk_timeline_evento FOREIGN KEY (username_coppia, data_evento) 
        REFERENCES EVENTO (username_coppia, data) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_timeline_stato CHECK (stato_regia IN ('bozza', 'confermata', 'in_corso', 'completata')),
    CONSTRAINT chk_timeline_ore CHECK (ora_inizio <= ora_fine)
) ENGINE=InnoDB;

-- 20. SCALETTA ATTIVITA: ATTIVITA_TIMELINE
CREATE TABLE ATTIVITA_TIMELINE (
    username_coppia     VARCHAR(50)     NOT NULL,
    data_evento         DATE            NOT NULL,
    orario_previsto     TIME            NOT NULL,
    titolo              VARCHAR(100)    NOT NULL,
    descrizione         VARCHAR(255)    NOT NULL,
    durata_minuti       INT             NOT NULL,
    luogo               VARCHAR(100)    NOT NULL,
    dipendente_cf       VARCHAR(16)     NOT NULL,
    CONSTRAINT pk_attivita_timeline PRIMARY KEY (username_coppia, data_evento, orario_previsto),
    CONSTRAINT fk_atl_timeline FOREIGN KEY (username_coppia, data_evento) 
        REFERENCES TIMELINE (username_coppia, data_evento) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_atl_dipendente FOREIGN KEY (dipendente_cf) 
        REFERENCES DIPENDENTE (codice_fiscale) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_atl_durata CHECK (durata_minuti > 0)
) ENGINE=InnoDB;

-- 21. MODELLI STANDARD: TEMPLATE_CHECKLIST
CREATE TABLE TEMPLATE_CHECKLIST (
    id_template         INT AUTO_INCREMENT NOT NULL,
    nome_template       VARCHAR(100)    NOT NULL,
    tipo_cerimonia      VARCHAR(50)     NOT NULL,
    descrizione         VARCHAR(255)    NOT NULL,
    CONSTRAINT pk_template_checklist PRIMARY KEY (id_template)
) ENGINE=InnoDB;

-- 22. VOCI DI MODELLO: VOCE_TEMPLATE
CREATE TABLE VOCE_TEMPLATE (
    id_template             INT             NOT NULL,
    codice_attivita         VARCHAR(50)     NOT NULL,
    titolo                  VARCHAR(100)    NOT NULL,
    fase_temporale          VARCHAR(50)     NOT NULL,
    giorni_prima_evento     INT             NOT NULL,
    responsabile_predefinito VARCHAR(50)    NOT NULL,
    CONSTRAINT pk_voce_template PRIMARY KEY (id_template, codice_attivita),
    CONSTRAINT fk_vt_template FOREIGN KEY (id_template) 
        REFERENCES TEMPLATE_CHECKLIST (id_template) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_vt_giorni CHECK (giorni_prima_evento >= 0)
) ENGINE=InnoDB;

-- 23. TO-DO LIST OPERATIVA: CHECKLIST
CREATE TABLE CHECKLIST (
    username_coppia     VARCHAR(50)     NOT NULL,
    data_evento         DATE            NOT NULL,
    id_template         INT             NOT NULL,
    data_generazione    DATE            NOT NULL,
    CONSTRAINT pk_checklist PRIMARY KEY (username_coppia, data_evento),
    CONSTRAINT fk_chk_evento FOREIGN KEY (username_coppia, data_evento) 
        REFERENCES EVENTO (username_coppia, data) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_chk_template FOREIGN KEY (id_template) 
        REFERENCES TEMPLATE_CHECKLIST (id_template) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 24. TASK OPERATIVI: ATTIVITA_CHECKLIST
CREATE TABLE ATTIVITA_CHECKLIST (
    username_coppia     VARCHAR(50)     NOT NULL,
    data_evento         DATE            NOT NULL,
    codice_attivita     VARCHAR(50)     NOT NULL,
    titolo              VARCHAR(100)    NOT NULL,
    fase_temporale      VARCHAR(50)     NOT NULL,
    scadenza            DATE            NOT NULL,
    data_completamento  DATE            NULL,
    stato               VARCHAR(20)     NOT NULL DEFAULT 'da_iniziare',
    priorita            VARCHAR(20)     NOT NULL DEFAULT 'media',
    note                VARCHAR(255)    NULL,
    dipendente_cf       VARCHAR(16)     NOT NULL,
    CONSTRAINT pk_attivita_checklist PRIMARY KEY (username_coppia, data_evento, codice_attivita),
    -- FIX MySQL 8: era ON UPDATE CASCADE, in conflitto con chk_ac_scadenza (usa data_evento)
    CONSTRAINT fk_ac_checklist FOREIGN KEY (username_coppia, data_evento)
        REFERENCES CHECKLIST (username_coppia, data_evento) ON DELETE CASCADE ON UPDATE RESTRICT,
    CONSTRAINT fk_ac_dipendente FOREIGN KEY (dipendente_cf) 
        REFERENCES DIPENDENTE (codice_fiscale) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_ac_stato CHECK (stato IN ('da_iniziare', 'in_corso', 'completata', 'annullata')),
    CONSTRAINT chk_ac_priorita CHECK (priorita IN ('bassa', 'media', 'alta', 'critica')),
    CONSTRAINT chk_ac_scadenza CHECK (scadenza <= data_evento)
) ENGINE=InnoDB;

-- 25. REGISTRO DONI: LISTA_NOZZE (con ridondanza analizzata)
CREATE TABLE LISTA_NOZZE (
    username_coppia     VARCHAR(50)     NOT NULL,
    data_evento         DATE            NOT NULL,
    iban                VARCHAR(35)     NOT NULL,
    banca               VARCHAR(100)    NOT NULL,
    intestatario        VARCHAR(100)    NOT NULL,
    totale_raccolto     DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
    CONSTRAINT pk_lista_nozze PRIMARY KEY (username_coppia, data_evento),
    CONSTRAINT fk_ln_evento FOREIGN KEY (username_coppia, data_evento) 
        REFERENCES EVENTO (username_coppia, data) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_ln_totale CHECK (totale_raccolto >= 0)
) ENGINE=InnoDB;

-- 26. ARTICOLI LISTA: REGALO
CREATE TABLE REGALO (
    username_coppia     VARCHAR(50)     NOT NULL,
    data_evento         DATE            NOT NULL,
    descrizione         VARCHAR(150)    NOT NULL,
    prezzo              DECIMAL(10,2)   NOT NULL,
    tipo_frazionamento  VARCHAR(20)     NOT NULL DEFAULT 'QUOTE_LIBERE',
    link_esterno        VARCHAR(255)    NULL,
    completato          CHAR(1)         NOT NULL DEFAULT 'N',
    CONSTRAINT pk_regalo PRIMARY KEY (username_coppia, data_evento, descrizione),
    CONSTRAINT fk_regalo_lista FOREIGN KEY (username_coppia, data_evento) 
        REFERENCES LISTA_NOZZE (username_coppia, data_evento) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_regalo_tipo CHECK (tipo_frazionamento IN ('INTERO', 'QUOTE_LIBERE', 'QUOTE_FISSE')),
    CONSTRAINT chk_regalo_completato CHECK (completato IN ('S', 'N')),
    CONSTRAINT chk_regalo_prezzo CHECK (prezzo > 0)
) ENGINE=InnoDB;

-- 27. ANAGRAFICA INVITATI: INVITATO
CREATE TABLE INVITATO (
    codice_fiscale      VARCHAR(16)     NOT NULL,
    rapporto_parentela  VARCHAR(50)     NOT NULL,
    nucleo_familiare    VARCHAR(50)     NOT NULL,
    tipologia_bomboniera VARCHAR(50)    NULL,
    CONSTRAINT pk_invitato PRIMARY KEY (codice_fiscale),
    CONSTRAINT fk_invitato_persona FOREIGN KEY (codice_fiscale) 
        REFERENCES PERSONA (codice_fiscale) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_invitato_bomboniera FOREIGN KEY (tipologia_bomboniera) 
        REFERENCES BOMBONIERA (tipologia) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 28. GESTIONE PRESENZE: PARTECIPAZIONE
CREATE TABLE PARTECIPAZIONE (
    codice_fiscale      VARCHAR(16)     NOT NULL,
    username_coppia     VARCHAR(50)     NOT NULL,
    data_evento         DATE            NOT NULL,
    stato               VARCHAR(20)     NOT NULL DEFAULT 'IN_ATTESA',
    esigenze_alimentari VARCHAR(100)    NULL,
    intolleranze        VARCHAR(100)    NULL,
    menu_scelto         VARCHAR(50)     NOT NULL DEFAULT 'STANDARD',
    tavolo_nome_numero  VARCHAR(50)     NULL,
    CONSTRAINT pk_partecipazione PRIMARY KEY (codice_fiscale, username_coppia, data_evento),
    CONSTRAINT fk_part_invitato FOREIGN KEY (codice_fiscale) 
        REFERENCES INVITATO (codice_fiscale) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_part_evento FOREIGN KEY (username_coppia, data_evento) 
        REFERENCES EVENTO (username_coppia, data) ON DELETE CASCADE ON UPDATE CASCADE,
    -- FIX MySQL 8: era ON UPDATE CASCADE, in conflitto con chk_part_tavolo_stato (usa tavolo_nome_numero)
    CONSTRAINT fk_part_tavolo FOREIGN KEY (username_coppia, data_evento, tavolo_nome_numero)
        REFERENCES TAVOLO (username_coppia, data_evento, nome_numero) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT chk_part_stato CHECK (stato IN ('CONFERMATO', 'RIFIUTATO', 'IN_ATTESA')),
    CONSTRAINT chk_part_tavolo_stato CHECK (tavolo_nome_numero IS NULL OR stato = 'CONFERMATO')
) ENGINE=InnoDB;

-- 29. DONAZIONI E REGALI: QUOTA_REGALO
CREATE TABLE QUOTA_REGALO (
    codice_fiscale      VARCHAR(16)     NOT NULL,
    username_coppia     VARCHAR(50)     NOT NULL,
    data_evento         DATE            NOT NULL,
    data_ora            DATETIME        NOT NULL,
    importo             DECIMAL(10,2)   NOT NULL,
    messaggio_auguri    VARCHAR(255)    NULL,
    metodo_pagamento    VARCHAR(30)     NOT NULL,
    stato               VARCHAR(20)     NOT NULL DEFAULT 'confermato',
    descrizione_regalo  VARCHAR(150)    NULL,
    CONSTRAINT pk_quota_regalo PRIMARY KEY (codice_fiscale, username_coppia, data_evento, data_ora),
    CONSTRAINT fk_qr_partecipazione FOREIGN KEY (codice_fiscale, username_coppia, data_evento) 
        REFERENCES PARTECIPAZIONE (codice_fiscale, username_coppia, data_evento) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_qr_regalo FOREIGN KEY (username_coppia, data_evento, descrizione_regalo) 
        REFERENCES REGALO (username_coppia, data_evento, descrizione) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_qr_metodo CHECK (metodo_pagamento IN ('BONIFICO', 'CARTA', 'PAYPAL', 'CONTANTI')),
    CONSTRAINT chk_qr_stato CHECK (stato IN ('in_attesa', 'confermato', 'fallito', 'stornato')),
    CONSTRAINT chk_qr_importo CHECK (importo > 0)
) ENGINE=InnoDB;

-- 30. REGISTRO MESSAGGI: COMUNICAZIONE
CREATE TABLE COMUNICAZIONE (
    id_comunicazione    INT AUTO_INCREMENT NOT NULL,
    username_coppia     VARCHAR(50)     NOT NULL,
    mittente            VARCHAR(20)     NOT NULL,
    data_ora            DATETIME        NOT NULL,
    canale              VARCHAR(30)     NOT NULL,
    oggetto             VARCHAR(100)    NOT NULL,
    testo               TEXT            NOT NULL,
    CONSTRAINT pk_comunicazione PRIMARY KEY (id_comunicazione),
    CONSTRAINT fk_com_coppia FOREIGN KEY (username_coppia) 
        REFERENCES COPPIA (username) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_com_mittente CHECK (mittente IN ('coppia', 'planner')),
    CONSTRAINT chk_com_canale CHECK (canale IN ('email', 'whatsapp', 'telefono', 'portale'))
) ENGINE=InnoDB;

-- 31. CONSULENZE: APPUNTAMENTO
CREATE TABLE APPUNTAMENTO (
    username_coppia     VARCHAR(50)     NOT NULL,
    data_ora            DATETIME        NOT NULL,
    dipendente_cf       VARCHAR(16)     NOT NULL,
    categoria_assenza   VARCHAR(50)     NULL,
    luogo_modalita      VARCHAR(100)    NOT NULL,
    durata              INT             NOT NULL,
    resoconto           TEXT            NULL,
    stato               VARCHAR(20)     NOT NULL DEFAULT 'confermato',
    CONSTRAINT pk_appuntamento PRIMARY KEY (username_coppia, data_ora),
    CONSTRAINT fk_app_coppia FOREIGN KEY (username_coppia) 
        REFERENCES COPPIA (username) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_app_dipendente FOREIGN KEY (dipendente_cf) 
        REFERENCES DIPENDENTE (codice_fiscale) ON DELETE RESTRICT ON UPDATE CASCADE,
    -- FIX MySQL 8: era ON UPDATE CASCADE, in conflitto con chk_app_assenza (usa categoria_assenza)
    CONSTRAINT fk_app_assenza FOREIGN KEY (categoria_assenza)
        REFERENCES MOTIVO_ASSENZA (categoria) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT chk_app_stato CHECK (stato IN ('confermato', 'svolto', 'annullato', 'riprogrammato')),
    CONSTRAINT chk_app_assenza CHECK (stato <> 'annullato' OR categoria_assenza IS NOT NULL),
    CONSTRAINT chk_app_durata CHECK (durata > 0)
) ENGINE=InnoDB;

-- 32. FEEDBACK SPOSI: RECENSIONE
CREATE TABLE RECENSIONE (
    username_coppia                 VARCHAR(50)     NOT NULL,
    data_evento                     DATE            NOT NULL,
    data_recensione                 DATE            NOT NULL,
    voto_complessivo                INT             NOT NULL,
    valutazione_servizio            INT             NOT NULL,
    valutazione_creativita          INT             NOT NULL,
    valutazione_stress_free         INT             NOT NULL,
    testo                           TEXT            NOT NULL,
    autorizzazione_pubblicazione    CHAR(1)         NOT NULL DEFAULT 'S',
    CONSTRAINT pk_recensione PRIMARY KEY (username_coppia, data_evento),
    CONSTRAINT fk_rec_evento FOREIGN KEY (username_coppia, data_evento) 
        REFERENCES EVENTO (username_coppia, data) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_rec_voto CHECK (voto_complessivo BETWEEN 1 AND 5),
    CONSTRAINT chk_rec_servizio CHECK (valutazione_servizio BETWEEN 1 AND 5),
    CONSTRAINT chk_rec_creativita CHECK (valutazione_creativita BETWEEN 1 AND 5),
    CONSTRAINT chk_rec_stress CHECK (valutazione_stress_free BETWEEN 1 AND 5),
    CONSTRAINT chk_rec_pubb CHECK (autorizzazione_pubblicazione IN ('S', 'N'))
) ENGINE=InnoDB;

-- 33. PORTFOLIO MULTIMEDIALE: FOTO
CREATE TABLE FOTO (
    id_foto             INT AUTO_INCREMENT NOT NULL,
    username_coppia     VARCHAR(50)     NOT NULL,
    data_evento         DATE            NOT NULL,
    file_path           VARCHAR(255)    NOT NULL,
    titolo              VARCHAR(100)    NOT NULL,
    descrizione         VARCHAR(255)    NULL,
    principale          CHAR(1)         NOT NULL DEFAULT 'N',
    CONSTRAINT pk_foto PRIMARY KEY (id_foto),
    CONSTRAINT fk_foto_evento FOREIGN KEY (username_coppia, data_evento) 
        REFERENCES EVENTO (username_coppia, data) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_foto_principale CHECK (principale IN ('S', 'N'))
) ENGINE=InnoDB;


-- =============================================================================
-- PARTE 2: STRATEGIA DI INDICIZZAZIONE (B-TREE SECONDARY INDEXES)
-- =============================================================================

-- Indici di supporto a Foreign Key e Join frequenti
CREATE INDEX idx_coppia_coniugi ON COPPIA (cf_coniuge1, cf_coniuge2);
CREATE INDEX idx_disp_dip_date ON DISPONIBILITA (dipendente_cf, data_inizio, data_fine);
CREATE INDEX idx_ass_dip_attiva ON ASSEGNAZIONE_DIPENDENTE (dipendente_cf, attiva);
CREATE INDEX idx_evento_data_stato ON EVENTO (data, stato);
CREATE INDEX idx_fornitore_cat_attivo ON FORNITORE (nome_categoria, attivo);
CREATE INDEX idx_contratto_data_firma ON CONTRATTO (data_firma);
CREATE INDEX idx_part_evento_stato ON PARTECIPAZIONE (username_coppia, data_evento, stato);
CREATE INDEX idx_part_tavolo ON PARTECIPAZIONE (username_coppia, data_evento, tavolo_nome_numero);
CREATE INDEX idx_quota_regalo_evento ON QUOTA_REGALO (username_coppia, data_evento, stato);
CREATE INDEX idx_quota_regalo_invitato ON QUOTA_REGALO (codice_fiscale);
CREATE INDEX idx_chk_scadenza_stato ON ATTIVITA_CHECKLIST (scadenza, stato);
CREATE INDEX idx_rec_voto ON RECENSIONE (voto_complessivo);


-- =============================================================================
-- PARTE 3: TRIGGER PROCEDURALI PER I VINCOLI DI INTEGRITA AZIENDALI
-- =============================================================================

DELIMITER //

-- [V-05] Disgiunzione degli intervalli di assenza del personale (DISPONIBILITA)
CREATE TRIGGER trg_disponibilita_before_insert
BEFORE INSERT ON DISPONIBILITA
FOR EACH ROW
BEGIN
    DECLARE v_overlap INT;
    
    SELECT COUNT(*) INTO v_overlap
    FROM DISPONIBILITA
    WHERE dipendente_cf = NEW.dipendente_cf
      AND data_inizio <= NEW.data_fine
      AND data_fine >= NEW.data_inizio;
      
    IF v_overlap > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '[V-05] Periodo di indisponibilita sovrapposto ad un altro intervallo gia censito per il dipendente.';
    END IF;
END //

CREATE TRIGGER trg_disponibilita_before_update
BEFORE UPDATE ON DISPONIBILITA
FOR EACH ROW
BEGIN
    DECLARE v_overlap INT;
    
    SELECT COUNT(*) INTO v_overlap
    FROM DISPONIBILITA
    WHERE dipendente_cf = NEW.dipendente_cf
      AND id_disponibilita <> OLD.id_disponibilita
      AND data_inizio <= NEW.data_fine
      AND data_fine >= NEW.data_inizio;
      
    IF v_overlap > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '[V-05] Periodo di indisponibilita sovrapposto ad un altro intervallo gia censito per il dipendente.';
    END IF;
END //

-- [V-07 & V-08] Unicita assegnazione attiva per coppia e carico massimo planner
CREATE TRIGGER trg_assegnazione_before_insert
BEFORE INSERT ON ASSEGNAZIONE_DIPENDENTE
FOR EACH ROW
BEGIN
    DECLARE v_attive_coppia INT;
    DECLARE v_attive_dip INT;
    DECLARE v_max_permessi INT;
    
    IF NEW.attiva = 'S' THEN
        -- Verifica V-07: Al massimo 1 planner attivo per coppia
        SELECT COUNT(*) INTO v_attive_coppia
        FROM ASSEGNAZIONE_DIPENDENTE
        WHERE username_coppia = NEW.username_coppia
          AND attiva = 'S';
          
        IF v_attive_coppia > 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '[V-07] Esiste gia un wedding planner attivo assegnato a questa coppia committente.';
        END IF;
        
        -- Verifica V-08: Limite carico massimo contemporaneo dipendente
        SELECT COUNT(*) INTO v_attive_dip
        FROM ASSEGNAZIONE_DIPENDENTE
        WHERE dipendente_cf = NEW.dipendente_cf
          AND attiva = 'S';
          
        SELECT COALESCE(MAX(r.max_eventi_contemporanei), 0) INTO v_max_permessi
        FROM RUOLO_DIPENDENTE rd
        JOIN RUOLO r ON rd.nome_ruolo = r.nome_ruolo
        WHERE rd.dipendente_cf = NEW.dipendente_cf;
        
        IF v_attive_dip >= v_max_permessi THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '[V-08] Il wedding planner ha raggiunto il limite massimo di eventi contemporanei ammessi per la sua qualifica.';
        END IF;
    END IF;
END //

CREATE TRIGGER trg_assegnazione_before_update
BEFORE UPDATE ON ASSEGNAZIONE_DIPENDENTE
FOR EACH ROW
BEGIN
    DECLARE v_attive_coppia INT;
    DECLARE v_attive_dip INT;
    DECLARE v_max_permessi INT;
    
    IF NEW.attiva = 'S' AND (OLD.attiva <> 'S' OR OLD.dipendente_cf <> NEW.dipendente_cf) THEN
        SELECT COUNT(*) INTO v_attive_coppia
        FROM ASSEGNAZIONE_DIPENDENTE
        WHERE username_coppia = NEW.username_coppia
          AND attiva = 'S'
          AND NOT (dipendente_cf = OLD.dipendente_cf AND data_inizio = OLD.data_inizio);
          
        IF v_attive_coppia > 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '[V-07] Esiste gia un wedding planner attivo per la coppia selezionata.';
        END IF;
        
        SELECT COUNT(*) INTO v_attive_dip
        FROM ASSEGNAZIONE_DIPENDENTE
        WHERE dipendente_cf = NEW.dipendente_cf
          AND attiva = 'S'
          AND NOT (username_coppia = OLD.username_coppia AND data_inizio = OLD.data_inizio);
          
        SELECT COALESCE(MAX(r.max_eventi_contemporanei), 0) INTO v_max_permessi
        FROM RUOLO_DIPENDENTE rd
        JOIN RUOLO r ON rd.nome_ruolo = r.nome_ruolo
        WHERE rd.dipendente_cf = NEW.dipendente_cf;
        
        IF v_attive_dip >= v_max_permessi THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '[V-08] Il wedding planner ha raggiunto il carico massimo di eventi contemporanei.';
        END IF;
    END IF;
END //

-- [V-15] Cronologia contrattuale e validita fornitore
CREATE TRIGGER trg_contratto_before_insert
BEFORE INSERT ON CONTRATTO
FOR EACH ROW
BEGIN
    DECLARE v_emissione DATE;
    DECLARE v_data_evento DATE;
    DECLARE v_attivo CHAR(1);
    
    SELECT p.data_emissione, p.data_evento, f.attivo
    INTO v_emissione, v_data_evento, v_attivo
    FROM PREVENTIVO p
    JOIN FORNITORE f ON p.fornitore_piva = f.partita_iva
    WHERE p.numero_preventivo = NEW.numero_preventivo
      AND p.fornitore_piva = NEW.fornitore_piva;
      
    IF v_attivo <> 'S' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '[V-15] Impossibile stipulare contratto: il fornitore non risulta convenzionato o attivo nel catalogo.';
    END IF;
    
    IF NEW.data_firma < v_emissione THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '[V-15] Data stipula contratto antecedente alla data di emissione del preventivo fornitore.';
    END IF;
    
    IF NEW.data_firma > v_data_evento THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '[V-15] Data stipula contratto successiva alla data dell evento da organizzare.';
    END IF;
END //

-- [V-10 & V-11] Capienza tavoli e coerenza seduta con stato RSVP
CREATE TRIGGER trg_partecipazione_before_insert
BEFORE INSERT ON PARTECIPAZIONE
FOR EACH ROW
BEGIN
    DECLARE v_capienza INT;
    DECLARE v_occupati INT;
    
    IF NEW.tavolo_nome_numero IS NOT NULL THEN
        IF NEW.stato <> 'CONFERMATO' THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '[V-11] Assegnazione del posto al tavolo consentita esclusivamente per invitati con presenza CONFERMATO.';
        END IF;
        
        SELECT capienza INTO v_capienza
        FROM TAVOLO
        WHERE username_coppia = NEW.username_coppia
          AND data_evento = NEW.data_evento
          AND nome_numero = NEW.tavolo_nome_numero;
          
        SELECT COUNT(*) INTO v_occupati
        FROM PARTECIPAZIONE
        WHERE username_coppia = NEW.username_coppia
          AND data_evento = NEW.data_evento
          AND tavolo_nome_numero = NEW.tavolo_nome_numero;
          
        IF v_occupati >= v_capienza THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '[V-10] Capienza massima del tavolo superata. Impossibile aggiungere ulteriori sedute.';
        END IF;
    END IF;
END //

CREATE TRIGGER trg_partecipazione_before_update
BEFORE UPDATE ON PARTECIPAZIONE
FOR EACH ROW
BEGIN
    DECLARE v_capienza INT;
    DECLARE v_occupati INT;
    
    IF NEW.tavolo_nome_numero IS NOT NULL THEN
        IF NEW.stato <> 'CONFERMATO' THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '[V-11] Assegnazione tavolo consentita solo ad invitati con presenza confermata.';
        END IF;
        
        IF (OLD.tavolo_nome_numero IS NULL) OR (OLD.tavolo_nome_numero <> NEW.tavolo_nome_numero) THEN
            SELECT capienza INTO v_capienza
            FROM TAVOLO
            WHERE username_coppia = NEW.username_coppia
              AND data_evento = NEW.data_evento
              AND nome_numero = NEW.tavolo_nome_numero;
              
            SELECT COUNT(*) INTO v_occupati
            FROM PARTECIPAZIONE
            WHERE username_coppia = NEW.username_coppia
              AND data_evento = NEW.data_evento
              AND tavolo_nome_numero = NEW.tavolo_nome_numero
              AND codice_fiscale <> OLD.codice_fiscale;
              
            IF v_occupati >= v_capienza THEN
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = '[V-10] Il tavolo di destinazione e saturo (capienza massima raggiunta).';
            END IF;
        END IF;
    END IF;
END //

-- [V-04] Plafond del regalo e tipo frazionamento (INTERO, QUOTE)
CREATE TRIGGER trg_quota_regalo_before_insert
BEFORE INSERT ON QUOTA_REGALO
FOR EACH ROW
BEGIN
    DECLARE v_prezzo DECIMAL(10,2);
    DECLARE v_tipo VARCHAR(20);
    DECLARE v_raccolto DECIMAL(10,2);
    DECLARE v_count_quote INT;
    
    IF NEW.descrizione_regalo IS NOT NULL THEN
        SELECT prezzo, tipo_frazionamento INTO v_prezzo, v_tipo
        FROM REGALO
        WHERE username_coppia = NEW.username_coppia
          AND data_evento = NEW.data_evento
          AND descrizione = NEW.descrizione_regalo;
          
        SELECT COALESCE(SUM(importo), 0), COUNT(*)
        INTO v_raccolto, v_count_quote
        FROM QUOTA_REGALO
        WHERE username_coppia = NEW.username_coppia
          AND data_evento = NEW.data_evento
          AND descrizione_regalo = NEW.descrizione_regalo
          AND stato = 'confermato';
          
        IF (v_raccolto + NEW.importo) > v_prezzo THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '[V-04] La quota inserita eccede il prezzo complessivo dell articolo selezionato nella lista nozze.';
        END IF;
        
        IF v_tipo = 'INTERO' AND (v_count_quote > 0 OR NEW.importo <> v_prezzo) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '[V-04] L articolo e classificato a pezzo INTERO: richiede una singola quota dell importo esatto pari al prezzo.';
        END IF;
    END IF;
END //

-- Mantenimento automatico dell'attributo ridondante LISTA_NOZZE.totale_raccolto e REGALO.completato
CREATE TRIGGER trg_quota_regalo_after_insert
AFTER INSERT ON QUOTA_REGALO
FOR EACH ROW
BEGIN
    DECLARE v_tot_regalo DECIMAL(10,2);
    DECLARE v_prezzo_regalo DECIMAL(10,2);
    
    IF NEW.stato = 'confermato' THEN
        UPDATE LISTA_NOZZE
        SET totale_raccolto = totale_raccolto + NEW.importo
        WHERE username_coppia = NEW.username_coppia
          AND data_evento = NEW.data_evento;
          
        IF NEW.descrizione_regalo IS NOT NULL THEN
            SELECT prezzo INTO v_prezzo_regalo
            FROM REGALO
            WHERE username_coppia = NEW.username_coppia
              AND data_evento = NEW.data_evento
              AND descrizione = NEW.descrizione_regalo;
              
            SELECT COALESCE(SUM(importo), 0) INTO v_tot_regalo
            FROM QUOTA_REGALO
            WHERE username_coppia = NEW.username_coppia
              AND data_evento = NEW.data_evento
              AND descrizione_regalo = NEW.descrizione_regalo
              AND stato = 'confermato';
              
            IF v_tot_regalo >= v_prezzo_regalo THEN
                UPDATE REGALO
                SET completato = 'S'
                WHERE username_coppia = NEW.username_coppia
                  AND data_evento = NEW.data_evento
                  AND descrizione = NEW.descrizione_regalo;
            END IF;
        END IF;
    END IF;
END //

CREATE TRIGGER trg_quota_regalo_after_update
AFTER UPDATE ON QUOTA_REGALO
FOR EACH ROW
BEGIN
    DECLARE v_diff DECIMAL(10,2);
    SET v_diff = 0.00;
    
    IF OLD.stato = 'confermato' THEN
        SET v_diff = v_diff - OLD.importo;
    END IF;
    IF NEW.stato = 'confermato' THEN
        SET v_diff = v_diff + NEW.importo;
    END IF;
    
    IF v_diff <> 0.00 THEN
        UPDATE LISTA_NOZZE
        SET totale_raccolto = totale_raccolto + v_diff
        WHERE username_coppia = NEW.username_coppia
          AND data_evento = NEW.data_evento;
    END IF;
END //

CREATE TRIGGER trg_quota_regalo_after_delete
AFTER DELETE ON QUOTA_REGALO
FOR EACH ROW
BEGIN
    IF OLD.stato = 'confermato' THEN
        UPDATE LISTA_NOZZE
        SET totale_raccolto = totale_raccolto - OLD.importo
        WHERE username_coppia = OLD.username_coppia
          AND data_evento = OLD.data_evento;
    END IF;
END //

-- [V-16] Recensione consentita esclusivamente ad evento completato
CREATE TRIGGER trg_recensione_before_insert
BEFORE INSERT ON RECENSIONE
FOR EACH ROW
BEGIN
    DECLARE v_stato VARCHAR(20);
    DECLARE v_data_evento DATE;
    
    SELECT stato, data INTO v_stato, v_data_evento
    FROM EVENTO
    WHERE username_coppia = NEW.username_coppia
      AND data = NEW.data_evento;
      
    IF v_stato <> 'completato' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '[V-16] Impossibile inviare la recensione: l evento deve risultare formalmente completato.';
    END IF;
    
    IF NEW.data_recensione < v_data_evento THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '[V-16] La data di rilascio del feedback non puo essere antecedente alla data di celebrazione dell evento.';
    END IF;
END //

DELIMITER ;
