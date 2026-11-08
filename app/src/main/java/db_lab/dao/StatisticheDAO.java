package db_lab.dao;

import db_lab.data.DAOUtils;
import db_lab.data.QueryResult;
import java.sql.Connection;
import java.util.LinkedHashMap;
import java.util.Map;

public final class StatisticheDAO {

    public record StatQueryInfo(String id, String title, String description, String sql) {}

    public static final Map<String, StatQueryInfo> QUERIES = new LinkedHashMap<>();

    static {
        QUERIES.put("STAT-01", new StatQueryInfo(
            "STAT-01",
            "Fornitori Maggiormente Contrattualizzati per Categoria e Spesa Media",
            "Individua per ciascun settore merceologico i fornitori partner con contratti stipulati, fatturato totale generato e spesa media.",
            """
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
            """
        ));

        QUERIES.put("STAT-02", new StatQueryInfo(
            "STAT-02",
            "Monitoraggio Scostamento Budget (Variance Analysis) per Eventi Attivi",
            "Confronta il budget allocato agli eventi con gli impegni contrattuali assunti (contratti + canoni location), evidenziando margini residui o sforamenti.",
            """
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
            """
        ));

        QUERIES.put("STAT-03", new StatQueryInfo(
            "STAT-03",
            "Tasso di Conversione Commerciale per Fornitore Partner",
            "Misura l'efficacia commerciale dei fornitori nel convertire preventivi proposti in contratti stipulati.",
            """
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
            """
        ));

        QUERIES.put("STAT-04", new StatQueryInfo(
            "STAT-04",
            "Produttività e Gradimento Wedding Planner",
            "Analizza il numero di eventi completati con successo e la media delle recensioni (servizio e indice stress-free) per ciascun planner.",
            """
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
            """
        ));

        QUERIES.put("STAT-05", new StatQueryInfo(
            "STAT-05",
            "Benchmark di Costo, Invitati e Soddisfazione per Tipo Cerimonia",
            "Confronto tra cerimonie Civili, Religiose e Simboliche per budget medio, invitati effettivi e soddisfazione coppie.",
            """
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
            """
        ));

        QUERIES.put("STAT-06", new StatQueryInfo(
            "STAT-06",
            "Frequenza d'Uso, Saturazione e Ricavi per Location Partner",
            "Rileva il tasso di occupazione medio, il numero di utilizzi e il fatturato canoni generato da castelli, ville e agriturismi convenzionati.",
            """
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
            """
        ));

        QUERIES.put("STAT-07", new StatQueryInfo(
            "STAT-07",
            "Monitoraggio Criticità e Percentuale Attività in Ritardo nella Checklist",
            "Calcola il tasso di compiti completati dopo la scadenza deterministica (o scaduti e non chiusi) per fase temporale e modello di checklist.",
            """
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
            """
        ));

        QUERIES.put("STAT-08", new StatQueryInfo(
            "STAT-08",
            "Tracciamento Ospiti Ricorrenti e Totale Quote Donate",
            "Individua le persone invitate a 2 o più matrimoni dell'agenzia, con conteggio delle presenze e somma complessiva delle donazioni effettuate.",
            """
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
            """
        ));
    }

    public static QueryResult executeStat(Connection conn, String statId) {
        StatQueryInfo info = QUERIES.get(statId);
        if (info == null) {
            throw new IllegalArgumentException("Query non trovata: " + statId);
        }
        return DAOUtils.executeGenericQuery(conn, info.sql());
    }
}
