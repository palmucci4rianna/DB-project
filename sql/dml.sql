-- =============================================================================
-- POPOLAMENTO DATI (DML) - WEDDING PLANNER AGENCY
-- DBMS Target: MySQL 8.0 Community Server
-- File: sql/dml.sql
-- Dataset: Realistico, consistente e calibrato per l'esecuzione delle query analitiche STAT-01..08
-- =============================================================================

USE wedding_planner;

-- Disabilitazione temporanea foreign key check durante il caricamento di massa
SET FOREIGN_KEY_CHECKS = 0;

-- Svuotamento preventivo tabelle per garantire re-eseguibilita idempotente
TRUNCATE TABLE FOTO;
TRUNCATE TABLE RECENSIONE;
TRUNCATE TABLE APPUNTAMENTO;
TRUNCATE TABLE COMUNICAZIONE;
TRUNCATE TABLE QUOTA_REGALO;
TRUNCATE TABLE PARTECIPAZIONE;
TRUNCATE TABLE INVITATO;
TRUNCATE TABLE REGALO;
TRUNCATE TABLE LISTA_NOZZE;
TRUNCATE TABLE ATTIVITA_CHECKLIST;
TRUNCATE TABLE CHECKLIST;
TRUNCATE TABLE VOCE_TEMPLATE;
TRUNCATE TABLE TEMPLATE_CHECKLIST;
TRUNCATE TABLE ATTIVITA_TIMELINE;
TRUNCATE TABLE TIMELINE;
TRUNCATE TABLE CONTRATTO;
TRUNCATE TABLE PREVENTIVO;
TRUNCATE TABLE COLLABORAZIONE;
TRUNCATE TABLE FORNITORE;
TRUNCATE TABLE CATEGORIA_FORNITORE;
TRUNCATE TABLE BOMBONIERA;
TRUNCATE TABLE TAVOLO;
TRUNCATE TABLE SVOLGIMENTO_EVENTO;
TRUNCATE TABLE LOCATION;
TRUNCATE TABLE EVENTO;
TRUNCATE TABLE ASSEGNAZIONE_DIPENDENTE;
TRUNCATE TABLE DISPONIBILITA;
TRUNCATE TABLE MOTIVO_ASSENZA;
TRUNCATE TABLE RUOLO_DIPENDENTE;
TRUNCATE TABLE RUOLO;
TRUNCATE TABLE DIPENDENTE;
TRUNCATE TABLE COPPIA;
TRUNCATE TABLE PERSONA;

SET FOREIGN_KEY_CHECKS = 1;

-- -----------------------------------------------------------------------------
-- 1. SOGGETTI FISICI (PERSONA)
-- -----------------------------------------------------------------------------
INSERT INTO PERSONA (codice_fiscale, nome, cognome, email, telefono) VALUES
-- Staff Agenzia
('RSSMRA85M01A944W', 'Mario', 'Rossi', 'mario.rossi@weddingagency.it', '+39 340 1122334'),
('BNCGLL90A41H501Z', 'Giulia', 'Bianchi', 'giulia.bianchi@weddingagency.it', '+39 347 2233445'),
('VRDLGI92M15F205K', 'Luigi', 'Verdi', 'luigi.verdi@weddingagency.it', '+39 333 3344556'),
('FRNFRC95C55A944J', 'Francesca', 'Ferrari', 'francesca.ferrari@weddingagency.it', '+39 338 4455667'),

-- Coppia 1: marco_elena (Evento completato 2025-06-21)
('MRNBNC88H12A944R', 'Marco', 'Bernardi', 'marco.bernardi88@gmail.com', '+39 320 9876543'),
('LNAVRD90R45A944T', 'Elena', 'Vitali', 'elena.vitali90@gmail.com', '+39 328 8765432'),

-- Coppia 2: luca_chiara (Evento confermato 2026-09-12)
('LCARSI91T10F205Y', 'Luca', 'Ricci', 'luca.ricci91@libero.it', '+39 345 7654321'),
('CHRGLL93L52F205B', 'Chiara', 'Galli', 'chiara.galli93@gmail.com', '+39 349 6543210'),

-- Coppia 3: davide_giulia (Evento completato 2025-09-20)
('DVDSNT87A04H501M', 'Davide', 'Santoro', 'davide.santoro87@hotmail.it', '+39 331 5432109'),
('GLAMNT89E62H501N', 'Giulia', 'Monti', 'giulia.monti89@gmail.com', '+39 339 4321098'),

-- Coppia 4: alessandro_federica (Evento in pianificazione 2027-05-15)
('LSSMRT94P18A944Q', 'Alessandro', 'Martini', 'alessandro.martini94@gmail.com', '+39 366 3210987'),
('FDRRSL96S59A944X', 'Federica', 'Russo', 'federica.russo96@gmail.com', '+39 342 2109876'),

-- Invitati & Ospiti (inclusi ospiti ricorrenti per test STAT-08)
('PLMFRN85A01A944P', 'Fabio', 'Palmucci', 'fabio.palmucci@outlook.it', '+39 335 1112233'),
('MNTSTE91C22A944Z', 'Stefano', 'Montanari', 'stefano.montanari@yahoo.it', '+39 334 2223344'),
('GLLMRT92D41F205C', 'Marta', 'Galli', 'marta.galli@gmail.com', '+39 348 3334455'),
('VTLGPP60L15A944M', 'Giuseppe', 'Vitali', 'giuseppe.vitali@virgilio.it', '+39 338 4445566'),
('BRNANM62B50A944O', 'Anna Maria', 'Bernardi', 'annamaria.bernardi@gmail.com', '+39 339 5556677'),
('RCCMRT89P05F205E', 'Matteo', 'Ricci', 'matteo.ricci@gmail.com', '+39 347 6667788'),
('FRRALE93A12H501W', 'Alessio', 'Ferrari', 'alessio.ferrari@gmail.com', '+39 340 7778899'),
('SNTSRA88E55H501K', 'Sara', 'Santoro', 'sara.santoro@gmail.com', '+39 346 8889900');

-- -----------------------------------------------------------------------------
-- 2. SOGGETTI COMMITTENTI (COPPIA)
-- -----------------------------------------------------------------------------
INSERT INTO COPPIA (username, cf_coniuge1, cf_coniuge2, data_prevista, budget_indicativo) VALUES
('marco_elena', 'MRNBNC88H12A944R', 'LNAVRD90R45A944T', '2025-06-21', 45000.00),
('luca_chiara', 'LCARSI91T10F205Y', 'CHRGLL93L52F205B', '2026-09-12', 38000.00),
('davide_giulia', 'DVDSNT87A04H501M', 'GLAMNT89E62H501N', '2025-09-20', 50000.00),
('alessandro_federica', 'LSSMRT94P18A944Q', 'FDRRSL96S59A944X', '2027-05-15', 35000.00);

-- -----------------------------------------------------------------------------
-- 3. STAFF AZIENDALE (DIPENDENTE)
-- -----------------------------------------------------------------------------
INSERT INTO DIPENDENTE (codice_fiscale, email_aziendale, data_assunzione, data_fine_rapporto, stato) VALUES
('RSSMRA85M01A944W', 'mario.rossi@weddingagency.it', '2020-01-15', NULL, 'attivo'),
('BNCGLL90A41H501Z', 'giulia.bianchi@weddingagency.it', '2021-03-01', NULL, 'attivo'),
('VRDLGI92M15F205K', 'luigi.verdi@weddingagency.it', '2022-05-10', NULL, 'attivo'),
('FRNFRC95C55A944J', 'francesca.ferrari@weddingagency.it', '2023-02-01', NULL, 'attivo');

-- -----------------------------------------------------------------------------
-- 4. MANSIONI AZIENDALI (RUOLO)
-- -----------------------------------------------------------------------------
INSERT INTO RUOLO (nome_ruolo, descrizione, max_eventi_contemporanei) VALUES
('Senior Wedding Planner', 'Responsabile primario della pianificazione e regia strategica dell evento', 6),
('Coordinatore On-Site', 'Regia operativa sul campo e sincronizzazione fornitori durante il wedding day', 10),
('Assistente Logistica', 'Gestione operativa to-do list, fornitori, RSVP e disposition sala', 8),
('Floral & Concept Designer', 'Progettazione scenografica, studio palette e light design', 5);

-- -----------------------------------------------------------------------------
-- 5. ASSEGNAZIONE MANSIONI (RUOLO_DIPENDENTE)
-- -----------------------------------------------------------------------------
INSERT INTO RUOLO_DIPENDENTE (dipendente_cf, nome_ruolo) VALUES
('RSSMRA85M01A944W', 'Senior Wedding Planner'),
('RSSMRA85M01A944W', 'Coordinatore On-Site'),
('BNCGLL90A41H501Z', 'Senior Wedding Planner'),
('BNCGLL90A41H501Z', 'Floral & Concept Designer'),
('VRDLGI92M15F205K', 'Coordinatore On-Site'),
('FRNFRC95C55A944J', 'Assistente Logistica');

-- -----------------------------------------------------------------------------
-- 6. MOTIVAZIONI ASSENZA (MOTIVO_ASSENZA)
-- -----------------------------------------------------------------------------
INSERT INTO MOTIVO_ASSENZA (categoria, descrizione, remunerata) VALUES
('Ferie', 'Ferie ordinarie annuali concordate', 'S'),
('Malattia', 'Assenza per malattia con certificato medico', 'S'),
('Maternita', 'Congedo di maternita obbligatorio o facoltativo', 'S'),
('Permesso Studio', 'Permesso retribuito per esami o formazione', 'S'),
('Dimissioni', 'Cessazione volontaria del rapporto lavorativo', 'N'),
('Riassegnazione Interna', 'Avvicendamento organizzativo per ottimizzazione carichi aziendali', 'S'),
('Impegno Istituzionale', 'Partecipazione a fiere di settore o convegni istituzionali', 'S'),
('Mancata Presentazione Committente', 'Mancata presenza della coppia committente all appuntamento programmato', 'N');

-- -----------------------------------------------------------------------------
-- 7. CALENDARIO ASSENZE (DISPONIBILITA)
-- -----------------------------------------------------------------------------
INSERT INTO DISPONIBILITA (dipendente_cf, data_inizio, data_fine, categoria_assenza, note) VALUES
('RSSMRA85M01A944W', '2025-08-01', '2025-08-20', 'Ferie', 'Chiusura estiva d agenzia'),
('BNCGLL90A41H501Z', '2025-12-24', '2026-01-06', 'Ferie', 'Festivita natalizie'),
('FRNFRC95C55A944J', '2026-01-15', '2026-06-15', 'Maternita', 'Congedo di maternita anticipato');

-- -----------------------------------------------------------------------------
-- 8. STORICO COORDINATORE (ASSEGNAZIONE_DIPENDENTE)
-- -----------------------------------------------------------------------------
INSERT INTO ASSEGNAZIONE_DIPENDENTE (username_coppia, dipendente_cf, data_inizio, data_fine, motivo_cambio, attiva) VALUES
-- marco_elena seguita interamente da Mario Rossi
('marco_elena', 'RSSMRA85M01A944W', '2024-09-01', '2025-06-25', NULL, 'S'),

-- luca_chiara con avvicendamento (V-06): prima Francesca Ferrari, poi Giulia Bianchi per maternità
('luca_chiara', 'FRNFRC95C55A944J', '2025-10-01', '2026-01-14', 'Maternita', 'N'),
('luca_chiara', 'BNCGLL90A41H501Z', '2026-01-15', NULL, NULL, 'S'),

-- davide_giulia seguita da Giulia Bianchi
('davide_giulia', 'BNCGLL90A41H501Z', '2024-11-01', '2025-09-25', NULL, 'S'),

-- alessandro_federica seguita da Mario Rossi
('alessandro_federica', 'RSSMRA85M01A944W', '2026-02-01', NULL, NULL, 'S');

-- -----------------------------------------------------------------------------
-- 9. EVENTO / MATRIMONIO
-- -----------------------------------------------------------------------------
INSERT INTO EVENTO (username_coppia, data, budget_effettivo, n_invitati_previsti, tipo_cerimonia, tema_stile, stato) VALUES
('marco_elena', '2025-06-21', 47500.00, 120, 'Civile', 'Botanical Chic & Ulivo', 'completato'),
('luca_chiara', '2026-09-12', 39000.00, 100, 'Religioso', 'Classico Romantico', 'confermato'),
('davide_giulia', '2025-09-20', 52000.00, 140, 'Simbolico', 'Boho Chic & Tramonto', 'completato'),
('alessandro_federica', '2027-05-15', 36000.00, 90, 'Civile', 'Minimal Modern', 'in_pianificazione');

-- -----------------------------------------------------------------------------
-- 10. SEDI E STRUTTURE (LOCATION)
-- -----------------------------------------------------------------------------
INSERT INTO LOCATION (nome_location, tipologia, indirizzo, citta, capienza_massima, costo_affitto, referente_nome, referente_telefono) VALUES
('Villa Guastavillani', 'Villa Storica', 'Via degli Scalini 12', 'Bologna', 250, 4500.00, 'Alberto Malvezzi', '+39 051 445566'),
('Castello di San Martino', 'Castello Medievale', 'Via Castello 1', 'San Martino in Argine', 300, 6000.00, 'Beatrice Bentivoglio', '+39 051 889900'),
('Tenuta Belvedere', 'Agriturismo di Charme', 'Via Panoramica 45', 'Zola Predosa', 150, 3200.00, 'Stefano Monti', '+39 051 776655'),
('Chiesa di Santa Maria della Vita', 'Luogo di Culto', 'Via Clavature 8', 'Bologna', 180, 500.00, 'Don Andrea Morandi', '+39 051 223344');

-- -----------------------------------------------------------------------------
-- 11. OCCUPAZIONE SEDI (SVOLGIMENTO_EVENTO)
-- -----------------------------------------------------------------------------
INSERT INTO SVOLGIMENTO_EVENTO (username_coppia, data_evento, nome_location, fascia_oraria, tipo_utilizzo) VALUES
('marco_elena', '2025-06-21', 'Villa Guastavillani', 'Pomeridiana-Serale (15:00-01:00)', 'Cerimonia Civile all aperto e Ricevimento'),
('luca_chiara', '2026-09-12', 'Chiesa di Santa Maria della Vita', 'Mattutina (10:00-13:00)', 'Celebrazione Matrimonio Religioso'),
('luca_chiara', '2026-09-12', 'Castello di San Martino', 'Pomeridiana (13:30-22:00)', 'Banchetto e Ricevimento Serale'),
('davide_giulia', '2025-09-20', 'Tenuta Belvedere', 'Intera Giornata (11:00-24:00)', 'Rito Simbolico nei vigneti e Ricevimento');

-- -----------------------------------------------------------------------------
-- 12. DISPOSIZIONE SALA (TAVOLO)
-- -----------------------------------------------------------------------------
INSERT INTO TAVOLO (username_coppia, data_evento, nome_numero, capienza, forma, zona_sala) VALUES
-- marco_elena
('marco_elena', '2025-06-21', 'Tavolo Sposi', 2, 'Rettangolare', 'Giardino pensile centrale'),
('marco_elena', '2025-06-21', 'Tavolo Ulivo (Famiglia)', 10, 'Rotondo', 'Porticato est'),
('marco_elena', '2025-06-21', 'Tavolo Lavanda (Amici)', 10, 'Rotondo', 'Giardino fiorito'),
('marco_elena', '2025-06-21', 'Tavolo Ginestra (Colleghi)', 8, 'Rotondo', 'Porticato ovest'),

-- davide_giulia
('davide_giulia', '2025-09-20', 'Tavolo Imperiale Sposi', 12, 'Imperiale', 'Bordo Piscina'),
('davide_giulia', '2025-09-20', 'Tavolo Vigneto A', 10, 'Rotondo', 'Prato panoramico'),
('davide_giulia', '2025-09-20', 'Tavolo Vigneto B', 10, 'Rotondo', 'Prato panoramico');

-- -----------------------------------------------------------------------------
-- 13. OMAGGI OSPITI (BOMBONIERA)
-- -----------------------------------------------------------------------------
INSERT INTO BOMBONIERA (tipologia, descrizione, target) VALUES
('Testimoni Deluxe', 'Scatola personalizzata in legno nobile con degustazione vini riserva e cavatappi d autore', 'Testimoni di Nozze'),
('Genitori Special', 'Vaso in vetro soffiato di Murano serigrafato con iniziali degli sposi', 'Genitori degli Sposi'),
('Ospiti Standard', 'Vasetto esagonale di miele millefiori biologico km 0 con spargimiele in legno d olivo', 'Invitati Generici');

-- -----------------------------------------------------------------------------
-- 14. SETTORI MERCEOLOGICI (CATEGORIA_FORNITORE)
-- -----------------------------------------------------------------------------
INSERT INTO CATEGORIA_FORNITORE (nome_categoria, descrizione) VALUES
('Catering & Banqueting', 'Servizio di ristorazione, alta cucina, open bar e banqueting nuziale'),
('Foto & Video', 'Servizi fotografici di reportage, riprese aeree drone e video cinematografico'),
('Fiori & Allestimenti', 'Floral design, noleggio gazebo, tensostrutture, arredi lounge e scenografie'),
('Musica & Spettacolo', 'Band live per rito e aperitivo, animazione, dj set per il dopocena e luci'),
('Abiti & Sartoria', 'Atelier d alta moda sposa, abiti su misura sposo e accessori cerimoniali');

-- -----------------------------------------------------------------------------
-- 15. ANAGRAFICA FORNITORI (FORNITORE)
-- -----------------------------------------------------------------------------
INSERT INTO FORNITORE (partita_iva, ragione_sociale, indirizzo, telefono, email, sito_web, attivo, nome_categoria) VALUES
('03456781201', 'Galateo Ricevimenti S.r.l.', 'Via Emilia Ponente 100, Bologna', '+39 051 614011', 'eventi@galateoricevimenti.it', 'www.galateoricevimenti.it', 'S', 'Catering & Banqueting'),
('02987651203', 'Raffaele Del Monte Photography', 'Via Saragozza 45, Bologna', '+39 051 334455', 'info@delmontephoto.it', 'www.delmontephoto.it', 'S', 'Foto & Video'),
('01827361208', 'Fiori & Colori di Sofia Conti', 'Via D Azeglio 18, Bologna', '+39 051 267788', 'sofia@fioriecolori.it', 'www.fioriecolori.it', 'S', 'Fiori & Allestimenti'),
('04123891209', 'Groove Wedding Band & Sound', 'Via Marconi 32, Bologna', '+39 051 556677', 'booking@groovewedding.it', 'www.groovewedding.it', 'S', 'Musica & Spettacolo'),
('05234901202', 'Atelier Sogno Bianco', 'Galleria Cavour 7, Bologna', '+39 051 228899', 'atelier@sognobianco.it', 'www.sognobianco.it', 'S', 'Abiti & Sartoria');

-- -----------------------------------------------------------------------------
-- 16. ACCORDI QUADRO (COLLABORAZIONE)
-- -----------------------------------------------------------------------------
INSERT INTO COLLABORAZIONE (fornitore_piva, data_inizio, data_fine, stato, termini_accordo) VALUES
('03456781201', '2023-01-01', '2026-12-31', 'attiva', 'Convenzione Top Partner con sconto agenzia 10% sul food cost'),
('02987651203', '2023-03-01', '2026-12-31', 'attiva', 'Accordo esclusivo servizio drone omaggio per clienti agenzia'),
('01827361208', '2022-09-01', '2026-12-31', 'attiva', 'Accordo fornitura allestimenti floreali e complementi arredo'),
('04123891209', '2024-01-15', '2027-01-14', 'attiva', 'Pacchetto all-inclusive cerimonia, aperitivo e dj set finale'),
('05234901202', '2023-05-01', '2026-05-01', 'attiva', 'Convenzione con fitting prioritario e prova velo gratuita');

-- -----------------------------------------------------------------------------
-- 17. PREVENTIVI FORNITORI (PREVENTIVO)
-- -----------------------------------------------------------------------------
INSERT INTO PREVENTIVO (numero_preventivo, fornitore_piva, username_coppia, data_evento, data_emissione, data_scadenza, importo_proposto, stato, dettagli_servizio) VALUES
-- Evento marco_elena
('PREV-2024-01', '03456781201', 'marco_elena', '2025-06-21', '2024-10-15', '2024-12-15', 18500.00, 'accettato', 'Menu 4 portate gourmet, aperitivo a isole tematiche, open bar 3 ore'),
('PREV-2024-02', '02987651203', 'marco_elena', '2025-06-21', '2024-10-20', '2024-12-20', 3200.00, 'accettato', 'Servizio completo 2 operatori, riprese drone 4K, fotolibro sposi e mini album genitori'),
('PREV-2024-03', '01827361208', 'marco_elena', '2025-06-21', '2024-11-05', '2025-01-05', 4200.00, 'accettato', 'Allestimento cerimonia civile, bouquet sposa, bottoniere, centrotavola con ulivo e candele'),
('PREV-2024-04', '04123891209', 'marco_elena', '2025-06-21', '2024-11-10', '2025-01-10', 2100.00, 'accettato', 'Quintetto jazz aperitivo + DJ set dopocena con service audio/luci compreso'),

-- Evento luca_chiara
('PREV-2025-10', '03456781201', 'luca_chiara', '2026-09-12', '2025-11-01', '2026-01-31', 16000.00, 'accettato', 'Menu tradizionale emiliano rivisitato, buffet antipasti, torta monumentale'),
('PREV-2025-11', '02987651203', 'luca_chiara', '2026-09-12', '2025-11-05', '2026-01-31', 3000.00, 'accettato', 'Copertura fotografica dall arrivo sposi al taglio torta, consegna gallery digitale HD'),

-- Evento davide_giulia
('PREV-2024-20', '03456781201', 'davide_giulia', '2025-09-20', '2024-12-01', '2025-02-01', 21000.00, 'accettato', 'Menu fusion biologico km 0, show cooking antipasti, buffet dolci'),
('PREV-2024-21', '01827361208', 'davide_giulia', '2025-09-20', '2024-12-10', '2025-02-10', 5000.00, 'accettato', 'Arco nuziale floreale pampas grass per rito simbolico e tableau vivant personalizzato');

-- -----------------------------------------------------------------------------
-- 18. CONTRATTI FORNITORI (CONTRATTO)
-- -----------------------------------------------------------------------------
INSERT INTO CONTRATTO (numero_preventivo, fornitore_piva, data_firma, importo_concordato, acconto_versato, stato_pagamento, clausole_recesso) VALUES
('PREV-2024-01', '03456781201', '2024-11-15', 18500.00, 18500.00, 'saldato', 'Recesso con rimborso 50% fino a 60 gg dall evento. Forza maggiore tutelata.'),
('PREV-2024-02', '02987651203', '2024-11-20', 3200.00, 3200.00, 'saldato', 'Acconto 30% a conferma, saldo alla consegna album. Proprieta scatti agli sposi.'),
('PREV-2024-03', '01827361208', '2024-11-28', 4200.00, 4200.00, 'saldato', 'Modifica palette ammessa entro 30 gg. Risoluzione senza penale causa maltempo.'),
('PREV-2024-04', '04123891209', '2024-12-05', 2100.00, 2100.00, 'saldato', 'Pratiche SIAE a carico della committenza. Agibilita ENPALS garantita dal gruppo.'),

('PREV-2025-10', '03456781201', '2025-12-10', 16000.00, 4800.00, 'acconto', 'Acconto 30% versato, secondo acconto 40% a 30 gg, saldo a consuntivo invitati effettivi.'),
('PREV-2025-11', '02987651203', '2025-12-12', 3000.00, 900.00, 'acconto', 'Caparra confirmatoria 30% all ordine, saldo a ricezione gallery online.'),

('PREV-2024-20', '03456781201', '2025-01-10', 21000.00, 21000.00, 'saldato', 'Contratto a corpo con degustazione menu inclusa per 4 persone. Saldato interamente.'),
('PREV-2024-21', '01827361208', '2025-01-15', 5000.00, 5000.00, 'saldato', 'Allestimento eco-sostenibile con fiori riutilizzabili e donazione a fine serata.');

-- -----------------------------------------------------------------------------
-- 19. REGIA ORARIA (TIMELINE)
-- -----------------------------------------------------------------------------
INSERT INTO TIMELINE (username_coppia, data_evento, ora_inizio, ora_fine, stato_regia) VALUES
('marco_elena', '2025-06-21', '15:30:00', '23:59:00', 'completata'),
('luca_chiara', '2026-09-12', '10:30:00', '23:30:00', 'confermata'),
('davide_giulia', '2025-09-20', '16:00:00', '23:59:00', 'completata');

-- -----------------------------------------------------------------------------
-- 20. SCALETTA ATTIVITA (ATTIVITA_TIMELINE)
-- -----------------------------------------------------------------------------
INSERT INTO ATTIVITA_TIMELINE (username_coppia, data_evento, orario_previsto, titolo, descrizione, durata_minuti, luogo, dipendente_cf) VALUES
('marco_elena', '2025-06-21', '15:30:00', 'Accoglienza Ospiti', 'Aperitivo rinfrescante analcolico di benvenuto', 30, 'Giardino d inverno', 'RSSMRA85M01A944W'),
('marco_elena', '2025-06-21', '16:00:00', 'Celebrazione Rito Civile', 'Cerimonia all aperto con accompagnamento d archi', 45, 'Prato degli Ulivi', 'RSSMRA85M01A944W'),
('marco_elena', '2025-06-21', '17:00:00', 'Aperitivo a Isole Gastronomiche', 'Show cooking finger food e musica jazz live', 90, 'Corte d Onore', 'VRDLGI92M15F205K'),
('marco_elena', '2025-06-21', '18:45:00', 'Ingresso Sala e Banchetto Placé', 'Servizio ai tavoli delle portate principali', 120, 'Salone degli Affreschi', 'RSSMRA85M01A944W'),
('marco_elena', '2025-06-21', '21:00:00', 'Taglio Torta Nuziale e Brindisi', 'Scenografia con fontane luminose fredde e sciabolata', 30, 'Belvedere Fontana', 'RSSMRA85M01A944W'),
('marco_elena', '2025-06-21', '21:45:00', 'Open Bar e DJ Set', 'Apertura danze con primo ballo degli sposi', 180, 'Porticato Nobile', 'VRDLGI92M15F205K');

-- -----------------------------------------------------------------------------
-- 21. MODELLI STANDARD (TEMPLATE_CHECKLIST)
-- -----------------------------------------------------------------------------
INSERT INTO TEMPLATE_CHECKLIST (id_template, nome_template, tipo_cerimonia, descrizione) VALUES
(1, 'Template Rito Civile in Villa', 'Civile', 'Piano operativo completo per matrimonio civile con cerimonia in loco'),
(2, 'Template Rito Religioso Tradizionale', 'Religioso', 'Piano operativo con doppi tempi tecnici logistici (chiesa + location)'),
(3, 'Template Rito Simbolico / Boho Chic', 'Simbolico', 'Piano per cerimonie all aperto con allestimenti scenografici non convenzionali');

-- -----------------------------------------------------------------------------
-- 22. VOCI DI MODELLO (VOCE_TEMPLATE)
-- -----------------------------------------------------------------------------
INSERT INTO VOCE_TEMPLATE (id_template, codice_attivita, titolo, fase_temporale, giorni_prima_evento, responsabile_predefinito) VALUES
(1, 'CIV-01', 'Prenotazione Sala Comunale / Ufficiale di Stato Civile', 'Pianificazione Iniziale', 240, 'Coppia'),
(1, 'CIV-02', 'Definizione Menu e Prova Piatti col Catering', 'Dettaglio Fornitori', 120, 'Wedding Planner'),
(1, 'CIV-03', 'Raccolta RSVP e Chiusura Lista Partecipanti', 'Coordinamento Finale', 30, 'Wedding Planner'),
(1, 'CIV-04', 'Approvazione Tableau de Mariage e Disposizione Tavoli', 'Coordinamento Finale', 15, 'Wedding Planner'),
(1, 'CIV-05', 'Briefing Operativo Finale coi Fornitori', 'Ultima Settimana', 5, 'Wedding Planner');

-- -----------------------------------------------------------------------------
-- 23. TO-DO LIST OPERATIVA (CHECKLIST)
-- -----------------------------------------------------------------------------
INSERT INTO CHECKLIST (username_coppia, data_evento, id_template, data_generazione) VALUES
('marco_elena', '2025-06-21', 1, '2024-09-05'),
('luca_chiara', '2026-09-12', 2, '2025-10-05'),
('davide_giulia', '2025-09-20', 3, '2024-11-05');

-- -----------------------------------------------------------------------------
-- 24. TASK OPERATIVI (ATTIVITA_CHECKLIST)
-- (Con scadenze e completamenti per testare ritardi in STAT-07)
-- -----------------------------------------------------------------------------
INSERT INTO ATTIVITA_CHECKLIST (username_coppia, data_evento, codice_attivita, titolo, fase_temporale, scadenza, data_completamento, stato, priorita, note, dipendente_cf) VALUES
-- marco_elena: completata puntuale
('marco_elena', '2025-06-21', 'CIV-01', 'Prenotazione Ufficiale Civile', 'Pianificazione Iniziale', '2024-10-24', '2024-10-20', 'completata', 'critica', 'Firma verbale avvenuta regolarmente', 'RSSMRA85M01A944W'),
-- marco_elena: completata IN RITARDO (+10 giorni dopo la scadenza!) -> alimenta STAT-07
('marco_elena', '2025-06-21', 'CIV-02', 'Prova Piatti Catering', 'Dettaglio Fornitori', '2025-02-21', '2025-03-03', 'completata', 'alta', 'Ritardo dovuto a ferie invernali del catering', 'RSSMRA85M01A944W'),
-- marco_elena: completata puntuale
('marco_elena', '2025-06-21', 'CIV-03', 'Chiusura RSVP', 'Coordinamento Finale', '2025-05-22', '2025-05-20', 'completata', 'alta', '98 confermati su 120 invitati', 'RSSMRA85M01A944W'),
('marco_elena', '2025-06-21', 'CIV-04', 'Approvazione Tableau', 'Coordinamento Finale', '2025-06-06', '2025-06-05', 'completata', 'media', 'Stampa su tela canvas con rami ulivo', 'RSSMRA85M01A944W'),
('marco_elena', '2025-06-21', 'CIV-05', 'Briefing Finale Fornitori', 'Ultima Settimana', '2025-06-16', '2025-06-15', 'completata', 'critica', 'Allineamento orari e accessi veicoli alla villa', 'RSSMRA85M01A944W'),

-- luca_chiara: alcune in corso
('luca_chiara', '2026-09-12', 'CIV-01', 'Prenotazione Chiesa e Corso Prematrimoniale', 'Pianificazione Iniziale', '2026-01-15', '2026-01-10', 'completata', 'critica', 'Attestato consegnato alla curia', 'BNCGLL90A41H501Z'),
('luca_chiara', '2026-09-12', 'CIV-02', 'Scelta Catering e Prova Menu', 'Dettaglio Fornitori', '2026-05-15', NULL, 'in_corso', 'alta', 'Degustazione fissata per fine maggio', 'BNCGLL90A41H501Z');

-- -----------------------------------------------------------------------------
-- 25. REGISTRO DONI (LISTA_NOZZE)
-- -----------------------------------------------------------------------------
INSERT INTO LISTA_NOZZE (username_coppia, data_evento, iban, banca, intestatario, totale_raccolto) VALUES
('marco_elena', '2025-06-21', 'IT60X0542811101000000123456', 'Banca Intesa Sanpaolo', 'Marco Bernardi e Elena Vitali', 0.00),
('luca_chiara', '2026-09-12', 'IT45Y0200801622000100654321', 'UniCredit Banca', 'Luca Ricci e Chiara Galli', 0.00),
('davide_giulia', '2025-09-20', 'IT99Z0306909606100000987654', 'Banca Mediolanum', 'Davide Santoro e Giulia Monti', 0.00);

-- -----------------------------------------------------------------------------
-- 26. ARTICOLI LISTA (REGALO)
-- -----------------------------------------------------------------------------
INSERT INTO REGALO (username_coppia, data_evento, descrizione, prezzo, tipo_frazionamento, link_esterno, completato) VALUES
-- marco_elena
('marco_elena', '2025-06-21', 'Volo A/R e Resort Luna di Miele Polinesia', 6000.00, 'QUOTE_LIBERE', 'https://viaggi.example.com/polinesia', 'N'),
('marco_elena', '2025-06-21', 'Set Valigie Samsonite Rigide 4 Ruote', 600.00, 'QUOTE_FISSE', 'https://samsonite.example.com/set', 'N'),
('marco_elena', '2025-06-21', 'Robot da Cucina KitchenAid Artisan', 750.00, 'INTERO', 'https://kitchenaid.example.com/artisan', 'N'),

-- davide_giulia
('davide_giulia', '2025-09-20', 'Safari Fotografico Tanzania & Zanzibar', 7500.00, 'QUOTE_LIBERE', 'https://safari.example.com/tanzania', 'N');

-- -----------------------------------------------------------------------------
-- 27. ANAGRAFICA INVITATI (INVITATO)
-- -----------------------------------------------------------------------------
INSERT INTO INVITATO (codice_fiscale, rapporto_parentela, nucleo_familiare, tipologia_bomboniera) VALUES
('PLMFRN85A01A944P', 'Amico di Infanzia Sposo', 'Palmucci-Rossi', 'Ospiti Standard'),
('MNTSTE91C22A944Z', 'Collega di Lavoro', 'Montanari', 'Ospiti Standard'),
('GLLMRT92D41F205C', 'Testimone di Nozze Sposa', 'Galli-Verdi', 'Testimoni Deluxe'),
('VTLGPP60L15A944M', 'Padre della Sposa', 'Vitali-Famiglia', 'Genitori Special'),
('BRNANM62B50A944O', 'Madre dello Sposo', 'Bernardi-Famiglia', 'Genitori Special'),
('RCCMRT89P05F205E', 'Fratello e Testimone Sposo', 'Ricci-Testimoni', 'Testimoni Deluxe'),
('FRRALE93A12H501W', 'Cugino dello Sposo', 'Ferrari', 'Ospiti Standard'),
('SNTSRA88E55H501K', 'Sorella dello Sposo', 'Santoro-Famiglia', 'Testimoni Deluxe');

-- -----------------------------------------------------------------------------
-- 28. GESTIONE PRESENZE (PARTECIPAZIONE)
-- -----------------------------------------------------------------------------
INSERT INTO PARTECIPAZIONE (codice_fiscale, username_coppia, data_evento, stato, esigenze_alimentari, intolleranze, menu_scelto, tavolo_nome_numero) VALUES
-- marco_elena (2025-06-21)
('PLMFRN85A01A944P', 'marco_elena', '2025-06-21', 'CONFERMATO', 'Nessuna', 'Nessuna', 'STANDARD', 'Tavolo Lavanda (Amici)'),
('MNTSTE91C22A944Z', 'marco_elena', '2025-06-21', 'CONFERMATO', 'Vegetariano', 'Lattosio', 'VEGETARIANO', 'Tavolo Ginestra (Colleghi)'),
('GLLMRT92D41F205C', 'marco_elena', '2025-06-21', 'CONFERMATO', 'Celiachia certificata', 'Glutine', 'GLUTEN_FREE', 'Tavolo Ulivo (Famiglia)'),
('VTLGPP60L15A944M', 'marco_elena', '2025-06-21', 'CONFERMATO', 'Nessuna', 'Nessuna', 'STANDARD', 'Tavolo Ulivo (Famiglia)'),
('BRNANM62B50A944O', 'marco_elena', '2025-06-21', 'CONFERMATO', 'Nessuna', 'Nessuna', 'STANDARD', 'Tavolo Ulivo (Famiglia)'),
('FRRALE93A12H501W', 'marco_elena', '2025-06-21', 'RIFIUTATO', NULL, NULL, 'STANDARD', NULL),

-- davide_giulia (2025-09-20) - Nota: PLMFRN85A01A944P e ospite ricorrente!
('PLMFRN85A01A944P', 'davide_giulia', '2025-09-20', 'CONFERMATO', 'Nessuna', 'Nessuna', 'STANDARD', 'Tavolo Vigneto A'),
('SNTSRA88E55H501K', 'davide_giulia', '2025-09-20', 'CONFERMATO', 'Vegano', 'Nessuna', 'VEGANO', 'Tavolo Imperiale Sposi'),

-- luca_chiara (2026-09-12)
('RCCMRT89P05F205E', 'luca_chiara', '2026-09-12', 'CONFERMATO', 'Nessuna', 'Nessuna', 'STANDARD', NULL),
('MNTSTE91C22A944Z', 'luca_chiara', '2026-09-12', 'IN_ATTESA', NULL, NULL, 'STANDARD', NULL);

-- -----------------------------------------------------------------------------
-- 29. DONAZIONI E REGALI (QUOTA_REGALO)
-- (L inserimento attivera automaticamente il trigger per aggiornare LISTA_NOZZE.totale_raccolto)
-- -----------------------------------------------------------------------------
INSERT INTO QUOTA_REGALO (codice_fiscale, username_coppia, data_evento, data_ora, importo, messaggio_auguri, metodo_pagamento, stato, descrizione_regalo) VALUES
-- Quote per marco_elena
('PLMFRN85A01A944P', 'marco_elena', '2025-06-21', '2025-05-10 10:15:00', 300.00, 'Un piccolo contributo per il vostro indimenticabile viaggio di nozze! Con affetto, Fabio', 'BONIFICO', 'confermato', 'Volo A/R e Resort Luna di Miele Polinesia'),
('MNTSTE91C22A944Z', 'marco_elena', '2025-06-21', '2025-05-12 18:30:00', 150.00, 'Tantissimi auguri di cuore per un futuro radioso!', 'CARTA', 'confermato', 'Volo A/R e Resort Luna di Miele Polinesia'),
('GLLMRT92D41F205C', 'marco_elena', '2025-06-21', '2025-05-15 12:00:00', 750.00, 'Per la mia migliore amica e sposa splendida. Con amore infinito, Marta', 'BONIFICO', 'confermato', 'Robot da Cucina KitchenAid Artisan'),
('VTLGPP60L15A944M', 'marco_elena', '2025-06-21', '2025-05-20 09:00:00', 2500.00, 'Dai tuoi genitori, con la gioia piu grande nel cuore. Vi amiamo immensamente', 'BONIFICO', 'confermato', 'Volo A/R e Resort Luna di Miele Polinesia'),
('FRRALE93A12H501W', 'marco_elena', '2025-06-21', '2025-05-25 15:45:00', 100.00, 'Anche se da lontano, vi sono vicino col pensiero. Buona vita insieme!', 'PAYPAL', 'confermato', NULL),

-- Quote per davide_giulia (PLMFRN85A01A944P dona anche qui -> verifica STAT-08: donatore ricorrente!)
('PLMFRN85A01A944P', 'davide_giulia', '2025-09-20', '2025-08-15 14:20:00', 250.00, 'Davide e Giulia, un grande abbraccio e felice vita insieme!', 'BONIFICO', 'confermato', 'Safari Fotografico Tanzania & Zanzibar'),
('SNTSRA88E55H501K', 'davide_giulia', '2025-09-20', '2025-08-20 11:10:00', 1000.00, 'Al fratellino migliore del mondo e alla sua bellissima moglie!', 'BONIFICO', 'confermato', 'Safari Fotografico Tanzania & Zanzibar');

-- -----------------------------------------------------------------------------
-- 30. REGISTRO MESSAGGI (COMUNICAZIONE)
-- -----------------------------------------------------------------------------
INSERT INTO COMUNICAZIONE (username_coppia, mittente, data_ora, canale, oggetto, testo) VALUES
('marco_elena', 'planner', '2024-09-10 11:00:00', 'email', 'Benvenuti! Inizio percorso di nozze', 'Cari Marco ed Elena, siamo felici di accompagnarvi in questo meraviglioso viaggio.'),
('marco_elena', 'coppia', '2024-09-11 09:30:00', 'portale', 'Preferenza data sopralluogo', 'Buongiorno Mario, saremmo disponibili per il sopralluogo a Villa Guastavillani sabato mattina.'),
('luca_chiara', 'planner', '2026-01-16 10:00:00', 'email', 'Passaggio consegne wedding planner', 'Gentili Luca e Chiara, a seguito della maternita di Francesca subentro io personalmente come vostra Senior Planner.');

-- -----------------------------------------------------------------------------
-- 31. CONSULENZE (APPUNTAMENTO)
-- -----------------------------------------------------------------------------
INSERT INTO APPUNTAMENTO (username_coppia, data_ora, dipendente_cf, categoria_assenza, luogo_modalita, durata, resoconto, stato) VALUES
('marco_elena', '2024-09-15 10:30:00', 'RSSMRA85M01A944W', NULL, 'Sede Agenzia - Salone Principale', 90, 'Incontro conoscitivo preliminare: allineamento gusti, budget e definizione timeline di massima.', 'svolto'),
('marco_elena', '2024-10-10 15:00:00', 'RSSMRA85M01A944W', NULL, 'Sopralluogo Villa Guastavillani', 120, 'Sopralluogo tecnico con referente villa per definizione spazi cerimonia e piano B antipioggia.', 'svolto'),
('luca_chiara', '2026-02-05 17:30:00', 'BNCGLL90A41H501Z', NULL, 'Videocall Google Meet', 60, 'Revisione bozza partecipazioni e scelta cartoncino artigianale.', 'svolto'),
('alessandro_federica', '2026-03-01 11:00:00', 'RSSMRA85M01A944W', 'Mancata Presentazione Committente', 'Sede Agenzia', 30, 'Appuntamento saltato per contrattempo lavorativo della coppia.', 'annullato');

-- -----------------------------------------------------------------------------
-- 32. FEEDBACK SPOSI (RECENSIONE)
-- (Inseribili regolarmente perche marco_elena e davide_giulia sono nello stato 'completato')
-- -----------------------------------------------------------------------------
INSERT INTO RECENSIONE (username_coppia, data_evento, data_recensione, voto_complessivo, valutazione_servizio, valutazione_creativita, valutazione_stress_free, testo, autorizzazione_pubblicazione) VALUES
('marco_elena', '2025-06-21', '2025-07-05', 5, 5, 5, 5, 'Un sogno che e diventato realta! Mario Rossi e stato una guida impeccabile, rassicurante e presente in ogni istante. Nessun intoppo durante la giornata, allestimenti mozzafiato e ospiti entusiasti. La serenita che ci hanno regalato non ha prezzo.', 'S'),
('davide_giulia', '2025-09-20', '2025-10-10', 5, 5, 5, 4, 'Giulia Bianchi e il suo team hanno curato ogni singolo dettaglio scenografico con passione e raffinatezza. Il rito al tramonto nei vigneti e stato pura magia. Consigliatissimi!', 'S');

-- -----------------------------------------------------------------------------
-- 33. PORTFOLIO MULTIMEDIALE (FOTO)
-- -----------------------------------------------------------------------------
INSERT INTO FOTO (username_coppia, data_evento, file_path, titolo, descrizione, principale) VALUES
('marco_elena', '2025-06-21', '/portfolio/2025/marco_elena/cerimonia_ulivo.jpg', 'Cerimonia all aperto nel prato', 'Lo scambio delle promesse nuziali sotto l arco floreale naturale', 'S'),
('marco_elena', '2025-06-21', '/portfolio/2025/marco_elena/taglio_torta_fontane.jpg', 'Taglio della torta monumentale', 'Momento del brindisi con fontane scintillanti serali al belvedere', 'N'),
('davide_giulia', '2025-09-20', '/portfolio/2025/davide_giulia/tramonto_vigneti.jpg', 'Scorcio romantico al tramonto', 'Gli sposi tra i filari della tenuta con luce dorata naturale', 'S');
