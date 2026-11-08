package db_lab.dao;

import db_lab.data.DAOUtils;
import db_lab.data.QueryResult;
import java.sql.Connection;

public final class EventoDAO {

    private EventoDAO() {}

    public static QueryResult listAllEventi(Connection conn) {
        String sql = """
            SELECT 
                e.username_coppia AS Coppia,
                e.data AS DataEvento,
                e.stato AS Stato,
                e.budget_effettivo AS BudgetAllocato,
                e.n_invitati_previsti AS InvitatiPrevisti,
                e.tipo_cerimonia AS TipoCerimonia,
                e.tema_stile AS TemaStile,
                CONCAT(p.nome, ' ', p.cognome) AS WeddingPlannerAssegnato,
                COALESCE(contratti.TotaleContratti, 0.00) AS TotaleImpegniFornitori
            FROM EVENTO e
            LEFT JOIN ASSEGNAZIONE_DIPENDENTE ad 
                ON e.username_coppia = ad.username_coppia 
               AND ad.attiva = 'S'
            LEFT JOIN PERSONA p 
                ON ad.dipendente_cf = p.codice_fiscale
            LEFT JOIN (
                SELECT 
                    prev.username_coppia,
                    prev.data_evento,
                    SUM(c.importo_concordato) AS TotaleContratti
                FROM PREVENTIVO prev
                JOIN CONTRATTO c 
                    ON prev.numero_preventivo = c.numero_preventivo 
                   AND prev.fornitore_piva = c.fornitore_piva
                GROUP BY prev.username_coppia, prev.data_evento
            ) contratti 
                ON e.username_coppia = contratti.username_coppia 
               AND e.data = contratti.data_evento
            ORDER BY e.data ASC;
            """;
        return DAOUtils.executeGenericQuery(conn, sql);
    }
}
