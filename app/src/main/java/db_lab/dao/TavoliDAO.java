package db_lab.dao;

import db_lab.data.DAOException;
import db_lab.data.DAOUtils;
import db_lab.data.QueryResult;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public final class TavoliDAO {

    private TavoliDAO() {}

    public record EventKey(String coppia, String dataEvento) {
        @Override
        public String toString() {
            return coppia + " (" + dataEvento + ")";
        }
    }

    public static List<EventKey> listEventKeys(Connection conn) {
        String sql = "SELECT username_coppia, data FROM EVENTO ORDER BY data ASC;";
        List<EventKey> list = new ArrayList<>();
        try (var stmt = conn.createStatement(); var rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                list.add(new EventKey(rs.getString("username_coppia"), rs.getString("data")));
            }
        } catch (SQLException e) {
            throw new DAOException(e);
        }
        return list;
    }

    public static QueryResult listTavoli(Connection conn, String coppia, String dataEvento) {
        String sql = """
            SELECT 
                t.nome_numero AS Tavolo,
                t.capienza AS CapienzaMassima,
                t.forma AS Forma,
                t.zona_sala AS ZonaSala,
                COUNT(p.codice_fiscale) AS PostiOccupati,
                (t.capienza - COUNT(p.codice_fiscale)) AS PostiLiberi,
                CASE 
                    WHEN COUNT(p.codice_fiscale) >= t.capienza THEN 'COMPLETO'
                    WHEN COUNT(p.codice_fiscale) = 0 THEN 'VUOTO'
                    ELSE 'DISPONIBILE'
                END AS StatoSaturazione
            FROM TAVOLO t
            LEFT JOIN PARTECIPAZIONE p 
                ON t.username_coppia = p.username_coppia 
               AND t.data_evento = p.data_evento 
               AND t.nome_numero = p.tavolo_nome_numero
            WHERE t.username_coppia = ? AND t.data_evento = ?
            GROUP BY t.nome_numero, t.capienza, t.forma, t.zona_sala
            ORDER BY t.nome_numero ASC;
            """;
        return DAOUtils.executeGenericQuery(conn, sql, coppia, dataEvento);
    }

    public static QueryResult listInvitati(Connection conn, String coppia, String dataEvento) {
        String sql = """
            SELECT 
                part.codice_fiscale AS CodiceFiscale,
                CONCAT(pers.cognome, ' ', pers.nome) AS Nominativo,
                pers.email AS Email,
                pers.telefono AS Telefono,
                part.stato AS StatoRSVP,
                COALESCE(part.tavolo_nome_numero, '-- Non Assegnato --') AS TavoloAssegnato,
                part.menu_scelto AS MenuScelto,
                COALESCE(part.esigenze_alimentari, 'Nessuna') AS EsigenzeAlimentari,
                COALESCE(part.intolleranze, 'Nessuna') AS IntolleranzeAllergie
            FROM PARTECIPAZIONE part
            JOIN INVITATO inv 
                ON part.codice_fiscale = inv.codice_fiscale
            JOIN PERSONA pers 
                ON inv.codice_fiscale = pers.codice_fiscale
            WHERE part.username_coppia = ? AND part.data_evento = ?
            ORDER BY part.stato ASC, part.tavolo_nome_numero ASC, pers.cognome ASC;
            """;
        return DAOUtils.executeGenericQuery(conn, sql, coppia, dataEvento);
    }

    public static List<String> listAvailableTablesNames(Connection conn, String coppia, String dataEvento) {
        String sql = "SELECT nome_numero FROM TAVOLO WHERE username_coppia = ? AND data_evento = ? ORDER BY nome_numero ASC;";
        List<String> list = new ArrayList<>();
        list.add("-- Nessun Tavolo (Rimuovi) --");
        try (var stmt = DAOUtils.prepare(conn, sql, coppia, dataEvento);
             var rs = stmt.executeQuery()) {
            while (rs.next()) {
                list.add(rs.getString("nome_numero"));
            }
        } catch (SQLException e) {
            throw new DAOException(e);
        }
        return list;
    }

    public static void assegnaTavolo(Connection conn, String coppia, String dataEvento, String guestCf, String tableName) {
        String actualTable = (tableName == null || tableName.startsWith("--")) ? null : tableName;

        // Se si desidera assegnare un tavolo, verificare che l'invitato abbia RSVP CONFERMATO
        if (actualTable != null) {
            String checkRsvpSql = "SELECT stato FROM PARTECIPAZIONE WHERE username_coppia = ? AND data_evento = ? AND codice_fiscale = ?;";
            try (var stmt = DAOUtils.prepare(conn, checkRsvpSql, coppia, dataEvento, guestCf);
                 var rs = stmt.executeQuery()) {
                if (rs.next()) {
                    String stato = rs.getString("stato");
                    if (!"CONFERMATO".equalsIgnoreCase(stato)) {
                        throw new DAOException("Impossibile assegnare il tavolo: l'invitato ha stato RSVP '" + stato + "'. Solo gli ospiti con stato 'CONFERMATO' possono occupare un posto.");
                    }
                } else {
                    throw new DAOException("Partecipazione non trovata per l'invitato specificato.");
                }
            } catch (SQLException e) {
                throw new DAOException(e);
            }

            // Verificare capienza residua tavolo
            String checkCapSql = """
                SELECT t.capienza, COUNT(p.codice_fiscale) AS occupati
                FROM TAVOLO t
                LEFT JOIN PARTECIPAZIONE p 
                    ON t.username_coppia = p.username_coppia 
                   AND t.data_evento = p.data_evento 
                   AND t.nome_numero = p.tavolo_nome_numero
                WHERE t.username_coppia = ? AND t.data_evento = ? AND t.nome_numero = ?
                GROUP BY t.capienza;
                """;
            try (var stmt = DAOUtils.prepare(conn, checkCapSql, coppia, dataEvento, actualTable);
                 var rs = stmt.executeQuery()) {
                if (rs.next()) {
                    int capienza = rs.getInt("capienza");
                    int occupati = rs.getInt("occupati");
                    if (occupati >= capienza) {
                        throw new DAOException("Il tavolo '" + actualTable + "' ha già raggiunto la capienza massima (" + capienza + " posti).");
                    }
                }
            } catch (SQLException e) {
                throw new DAOException(e);
            }
        }

        // Esegui l'aggiornamento
        String updateSql = "UPDATE PARTECIPAZIONE SET tavolo_nome_numero = ? WHERE username_coppia = ? AND data_evento = ? AND codice_fiscale = ?;";
        try (var stmt = DAOUtils.prepare(conn, updateSql, actualTable, coppia, dataEvento, guestCf)) {
            stmt.executeUpdate();
        } catch (SQLException e) {
            throw new DAOException("Errore durante l'assegnazione del tavolo: " + e.getMessage(), e);
        }
    }
}
