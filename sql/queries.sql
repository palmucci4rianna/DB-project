-- =============================================================================
-- QUERY STATISTICHE ED ANALITICHE (OLAP) - WEDDING PLANNER AGENCY
-- DBMS Target: MySQL 8.0 Community Server
-- File: sql/queries.sql
-- Descrizione: 8 interrogazioni complesse per il controllo direzionale,
-- monitoraggio finanziario, gestione del personale e analisi delle performance.
-- =============================================================================

USE wedding_planner;

-- -----------------------------------------------------------------------------
-- [STAT-01] Fornitori Maggiormente Contrattualizzati per Categoria e Spesa Media
-- Obiettivo: Individuare, per ciascun settore merceologico, i fornitori partner
-- con cui sono stati stipulati contratti, calcolando il volume contratti,
-- il fatturato totale generato e la spesa media, ordinati per popolarita.
-- -----------------------------------------------------------------------------
SELECT 
    f.nome_categoria AS Categoria,
    f.partita_iva AS PartitaIVA,
    f.ragione_sociale AS Fornitore,
    COUNT(c.numero_preventivo) AS NumeroContrattiStipulati,
    COALESCE(SUM(c.importo_concordato), 0.00) AS TotaleFatturato,
    ROUND(COALESCE(AVG(c.importo_concordato), 0.00), 2) AS SpesaMediaPerContratto,
    DENSE_RANK() OVER (
        PARTITION BY f.nome_categoria 
        ORDER BY COUNT(c.numero_preventivo) DESC, SUM(c.importo_concordato) DESC
    ) AS PosizioneClassifica
FROM FORNITORE f
LEFT JOIN PREVENTIVO p 
    ON f.partita_iva = p.fornitore_piva
LEFT JOIN CONTRATTO c 
    ON p.numero_preventivo = c.numero_preventivo 
   AND p.fornitore_piva = c.fornitore_piva
WHERE f.attivo = 'S'
GROUP BY f.nome_categoria, f.partita_iva, f.ragione_sociale
ORDER BY f.nome_categoria, PosizioneClassifica;


-- -----------------------------------------------------------------------------
-- [STAT-02] Monitoraggio Scostamento Budget (Variance Analysis) per Eventi Attivi
-- Obiettivo: Valutare la salute economico-finanziaria dei matrimoni in corso,
-- confrontando il budget allocato con gli impegni contrattuali assunti
-- (somma contratti fornitori + costo affitto location).
-- -----------------------------------------------------------------------------
SELECT 
    e.username_coppia AS Coppia,
    e.data AS DataEvento,
    e.stato AS StatoEvento,
    e.budget_effettivo AS BudgetAllocato,
    COALESCE(SUM(DISTINCT l.costo_affitto), 0.00) AS CostoTotaleLocation,
    COALESCE(SUM(c.importo_concordato), 0.00) AS CostoTotaleFornitori,
    (COALESCE(SUM(DISTINCT l.costo_affitto), 0.00) + COALESCE(SUM(c.importo_concordato), 0.00)) AS CostoTotaleImpegnato,
    (e.budget_effettivo - (COALESCE(SUM(DISTINCT l.costo_affitto), 0.00) + COALESCE(SUM(c.importo_concordato), 0.00))) AS ResiduoMargine,
    ROUND(
        ((COALESCE(SUM(DISTINCT l.costo_affitto), 0.00) + COALESCE(SUM(c.importo_concordato), 0.00)) / e.budget_effettivo) * 100, 
        2
    ) AS PercentualeBudgetConsumato
FROM EVENTO e
LEFT JOIN SVOLGIMENTO_EVENTO se 
    ON e.username_coppia = se.username_coppia 
   AND e.data = se.data_evento
LEFT JOIN LOCATION l 
    ON se.nome_location = l.nome_location
LEFT JOIN PREVENTIVO p 
    ON e.username_coppia = p.username_coppia 
   AND e.data = p.data_evento
LEFT JOIN CONTRATTO c 
    ON p.numero_preventivo = c.numero_preventivo 
   AND p.fornitore_piva = c.fornitore_piva
WHERE e.stato IN ('in_pianificazione', 'confermato', 'completato')
GROUP BY e.username_coppia, e.data, e.stato, e.budget_effettivo
ORDER BY e.data ASC;


-- -----------------------------------------------------------------------------
-- [STAT-03] Tasso di Conversione Commerciale per Fornitore Partner
-- Obiettivo: Misurare l efficacia dei fornitori nel convertire i preventivi
-- richiesti e presentati agli sposi in contratti formali di ingaggio.
-- -----------------------------------------------------------------------------
SELECT 
    f.partita_iva AS PartitaIVA,
    f.ragione_sociale AS Fornitore,
    f.nome_categoria AS Categoria,
    COUNT(p.numero_preventivo) AS PreventiviEmessi,
    COUNT(c.numero_preventivo) AS ContrattiFinalizzati,
    ROUND(
        CASE 
            WHEN COUNT(p.numero_preventivo) > 0 
            THEN (COUNT(c.numero_preventivo) / COUNT(p.numero_preventivo)) * 100 
            ELSE 0.00 
        END, 
        2
    ) AS TassoConversionePercentuale
FROM FORNITORE f
JOIN PREVENTIVO p 
    ON f.partita_iva = p.fornitore_piva
LEFT JOIN CONTRATTO c 
    ON p.numero_preventivo = c.numero_preventivo 
   AND p.fornitore_piva = c.fornitore_piva
GROUP BY f.partita_iva, f.ragione_sociale, f.nome_categoria
HAVING COUNT(p.numero_preventivo) >= 1
ORDER BY TassoConversionePercentuale DESC, ContrattiFinalizzati DESC;


-- -----------------------------------------------------------------------------
-- [STAT-04] Produttivita e Gradimento Wedding Planner
-- Obiettivo: Analizzare le performance di ciascun wedding planner dello staff:
-- numero di eventi gestiti e portati a termine, e indice di gradimento medio.
-- -----------------------------------------------------------------------------
SELECT 
    d.codice_fiscale AS CodiceFiscale,
    CONCAT(p.nome, ' ', p.cognome) AS WeddingPlanner,
    COUNT(DISTINCT e.username_coppia) AS EventiCompletati,
    ROUND(COALESCE(AVG(r.voto_complessivo), 0.00), 2) AS MediaVotoGlobale,
    ROUND(COALESCE(AVG(r.valutazione_servizio), 0.00), 2) AS MediaValutazioneServizio,
    ROUND(COALESCE(AVG(r.valutazione_stress_free), 0.00), 2) AS IndiceStressFree,
    COUNT(r.voto_complessivo) AS NumeroRecensioniRicevute
FROM DIPENDENTE d
JOIN PERSONA p 
    ON d.codice_fiscale = p.codice_fiscale
JOIN ASSEGNAZIONE_DIPENDENTE ad 
    ON d.codice_fiscale = ad.dipendente_cf
JOIN EVENTO e 
    ON ad.username_coppia = e.username_coppia
LEFT JOIN RECENSIONE r 
    ON e.username_coppia = r.username_coppia 
   AND e.data = r.data_evento
WHERE e.stato = 'completato'
GROUP BY d.codice_fiscale, p.nome, p.cognome
ORDER BY MediaVotoGlobale DESC, EventiCompletati DESC;


-- -----------------------------------------------------------------------------
-- [STAT-05] Benchmark di Costo, Invitati e Soddisfazione per Tipo Cerimonia
-- Obiettivo: Confrontare le diverse tipologie di rito (Civile, Religioso, Simbolico)
-- in termini di dimensione media ospiti, budget impiegato e soddisfazione sposi.
-- -----------------------------------------------------------------------------
SELECT 
    e.tipo_cerimonia AS TipologiaCerimonia,
    COUNT(DISTINCT e.username_coppia) AS TotaleEventiCensiti,
    ROUND(AVG(e.budget_effettivo), 2) AS BudgetMedioAllocato,
    ROUND(AVG(e.n_invitati_previsti), 1) AS MediaInvitatiPrevisti,
    ROUND(
        AVG(e.budget_effettivo / e.n_invitati_previsti), 
        2
    ) AS CostoMedioTeoricoPerInvitato,
    ROUND(COALESCE(AVG(r.voto_complessivo), 0.00), 2) AS LivelloGradimentoMedio
FROM EVENTO e
LEFT JOIN RECENSIONE r 
    ON e.username_coppia = r.username_coppia 
   AND e.data = r.data_evento
GROUP BY e.tipo_cerimonia
ORDER BY TotaleEventiCensiti DESC;


-- -----------------------------------------------------------------------------
-- [STAT-06] Frequenza d Uso, Occupazione e Spesa Media per Location
-- Obiettivo: Esaminare la saturazione e il volume d affari indirizzato
-- verso le strutture ricettive e ville convenzionate con l agenzia.
-- -----------------------------------------------------------------------------
SELECT 
    l.nome_location AS Struttura,
    l.tipologia AS TipologiaSede,
    l.citta AS Citta,
    l.capienza_massima AS CapienzaMassima,
    l.costo_affitto AS CanoneBase,
    COUNT(se.username_coppia) AS NumeroUtilizzi,
    ROUND(COALESCE(AVG(e.n_invitati_previsti), 0), 0) AS MediaInvitatiOspitati,
    ROUND(
        (COALESCE(AVG(e.n_invitati_previsti), 0) / l.capienza_massima) * 100, 
        2
    ) AS TassoOccupazioneMedioPercentuale,
    SUM(l.costo_affitto) AS FatturatoTotaleAffitti
FROM LOCATION l
LEFT JOIN SVOLGIMENTO_EVENTO se 
    ON l.nome_location = se.nome_location
LEFT JOIN EVENTO e 
    ON se.username_coppia = e.username_coppia 
   AND se.data_evento = e.data
GROUP BY l.nome_location, l.tipologia, l.citta, l.capienza_massima, l.costo_affitto
ORDER BY NumeroUtilizzi DESC, FatturatoTotaleAffitti DESC;


-- -----------------------------------------------------------------------------
-- [STAT-07] Monitoraggio Criticita e Percentuale Attivita in Ritardo nella Checklist
-- Obiettivo: Rilevare i colli di bottiglia operativi identificando in quali fasi
-- temporali e per quali template si concentra il maggior tasso di ritardo.
-- Un attivita e in ritardo se data_completamento > scadenza oppure se
-- non completata e scadenza < CURRENT_DATE.
-- -----------------------------------------------------------------------------
SELECT 
    tc.nome_template AS ModelloChecklist,
    ac.fase_temporale AS FaseOperativa,
    COUNT(ac.codice_attivita) AS TotaleAttivitaFase,
    SUM(
        CASE 
            WHEN (ac.data_completamento IS NOT NULL AND ac.data_completamento > ac.scadenza)
              OR (ac.stato <> 'completata' AND ac.scadenza < '2025-06-25') 
            THEN 1 
            ELSE 0 
        END
    ) AS NumeroAttivitaInRitardo,
    ROUND(
        (SUM(
            CASE 
                WHEN (ac.data_completamento IS NOT NULL AND ac.data_completamento > ac.scadenza)
                  OR (ac.stato <> 'completata' AND ac.scadenza < '2025-06-25') 
                THEN 1 
                ELSE 0 
            END
        ) / COUNT(ac.codice_attivita)) * 100, 
        2
    ) AS PercentualeRitardo
FROM ATTIVITA_CHECKLIST ac
JOIN CHECKLIST c 
    ON ac.username_coppia = c.username_coppia 
   AND ac.data_evento = c.data_evento
JOIN TEMPLATE_CHECKLIST tc 
    ON c.id_template = tc.id_template
GROUP BY tc.nome_template, ac.fase_temporale
ORDER BY PercentualeRitardo DESC, TotaleAttivitaFase DESC;


-- -----------------------------------------------------------------------------
-- [STAT-08] Tracciamento Ospiti Ricorrenti e Totale Quote Donate
-- Obiettivo: Identificare le persone fisiche invitate a piu matrimoni organizzati
-- dall agenzia, calcolando il numero di eventi a cui hanno partecipato e
-- il volume finanziario totale delle quote e donazioni effettuate.
-- -----------------------------------------------------------------------------
SELECT 
    p.codice_fiscale AS CodiceFiscale,
    CONCAT(p.nome, ' ', p.cognome) AS NominativoOspite,
    p.email AS Email,
    COUNT(DISTINCT part.username_coppia) AS MatrimoniCuiRisultaInvitato,
    SUM(CASE WHEN part.stato = 'CONFERMATO' THEN 1 ELSE 0 END) AS MatrimoniConPresenzaConfermata,
    COUNT(qr.data_ora) AS NumeroDonazioniEffettuate,
    COALESCE(SUM(qr.importo), 0.00) AS TotaleQuoteRegaloVersate,
    ROUND(COALESCE(AVG(qr.importo), 0.00), 2) AS DonazioneMediaPerEvento
FROM PERSONA p
JOIN INVITATO i 
    ON p.codice_fiscale = i.codice_fiscale
JOIN PARTECIPAZIONE part 
    ON i.codice_fiscale = part.codice_fiscale
LEFT JOIN QUOTA_REGALO qr 
    ON part.codice_fiscale = qr.codice_fiscale 
   AND part.username_coppia = qr.username_coppia 
   AND part.data_evento = qr.data_evento
   AND qr.stato = 'confermato'
GROUP BY p.codice_fiscale, p.nome, p.cognome, p.email
HAVING COUNT(DISTINCT part.username_coppia) > 1
ORDER BY TotaleQuoteRegaloVersate DESC, MatrimoniCuiRisultaInvitato DESC;
