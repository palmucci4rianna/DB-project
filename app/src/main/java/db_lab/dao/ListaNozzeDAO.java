package db_lab.dao;

import db_lab.data.DAOException;
import db_lab.data.DAOUtils;
import db_lab.data.QueryResult;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public final class ListaNozzeDAO {

    private ListaNozzeDAO() {}

    public record ListaHeader(String iban, String banca, String intestatario, double totaleRaccolto, double totaleDesiderato) {}

    public static ListaHeader getListaHeader(Connection conn, String coppia, String dataEvento) {
        String sql = """
            SELECT 
                ln.iban,
                ln.banca,
                ln.intestatario,
                ln.totale_raccolto,
                COALESCE(SUM(r.prezzo), 0.00) AS totale_desiderato
            FROM LISTA_NOZZE ln
            LEFT JOIN REGALO r 
                ON ln.username_coppia = r.username_coppia 
               AND ln.data_evento = r.data_evento
            WHERE ln.username_coppia = ? AND ln.data_evento = ?
            GROUP BY ln.iban, ln.banca, ln.intestatario, ln.totale_raccolto;
            """;
        try (var stmt = DAOUtils.prepare(conn, sql, coppia, dataEvento);
             var rs = stmt.executeQuery()) {
            if (rs.next()) {
                return new ListaHeader(
                    rs.getString("iban"),
                    rs.getString("banca"),
                    rs.getString("intestatario"),
                    rs.getDouble("totale_raccolto"),
                    rs.getDouble("totale_desiderato")
                );
            }
        } catch (SQLException e) {
            throw new DAOException(e);
        }
        return new ListaHeader("N/D", "N/D", "N/D", 0.0, 0.0);
    }

    public static QueryResult listRegali(Connection conn, String coppia, String dataEvento) {
        String sql = """
            SELECT 
                r.descrizione AS Regalo,
                r.prezzo AS PrezzoRichiesto,
                r.tipo_frazionamento AS Frazionamento,
                r.completato AS Completato,
                COALESCE(SUM(qr.importo), 0.00) AS TotaleRaccoltoPerArticolo,
                ROUND(
                    CASE 
                        WHEN r.prezzo > 0 THEN (COALESCE(SUM(qr.importo), 0.00) / r.prezzo) * 100 
                        ELSE 0.00 
                    END, 
                    1
                ) AS PercentualeRaggiunta
            FROM REGALO r
            LEFT JOIN QUOTA_REGALO qr 
                ON r.username_coppia = qr.username_coppia 
               AND r.data_evento = qr.data_evento 
               AND r.descrizione = qr.descrizione_regalo
               AND qr.stato = 'confermato'
            WHERE r.username_coppia = ? AND r.data_evento = ?
            GROUP BY r.descrizione, r.prezzo, r.tipo_frazionamento, r.completato
            ORDER BY r.prezzo DESC;
            """;
        return DAOUtils.executeGenericQuery(conn, sql, coppia, dataEvento);
    }

    public static QueryResult listQuote(Connection conn, String coppia, String dataEvento) {
        String sql = """
            SELECT 
                qr.data_ora AS DataEOra,
                CONCAT(p.cognome, ' ', p.nome) AS Donatore,
                qr.importo AS Importo,
                qr.metodo_pagamento AS Metodo,
                COALESCE(qr.descrizione_regalo, 'Quota Libera') AS Destinazione,
                COALESCE(qr.messaggio_auguri, '') AS MessaggioAuguri,
                qr.stato AS StatoTransazione
            FROM QUOTA_REGALO qr
            JOIN PERSONA p 
                ON qr.codice_fiscale = p.codice_fiscale
            WHERE qr.username_coppia = ? AND qr.data_evento = ?
            ORDER BY qr.data_ora DESC;
            """;
        return DAOUtils.executeGenericQuery(conn, sql, coppia, dataEvento);
    }

    public record DonorOption(String cf, String label) {
        @Override
        public String toString() {
            return label;
        }
    }

    public static List<DonorOption> listInvitatiDonatori(Connection conn, String coppia, String dataEvento) {
        String sql = """
            SELECT part.codice_fiscale, CONCAT(pers.cognome, ' ', pers.nome, ' (', part.codice_fiscale, ')') AS label
            FROM PARTECIPAZIONE part
            JOIN PERSONA pers ON part.codice_fiscale = pers.codice_fiscale
            WHERE part.username_coppia = ? AND part.data_evento = ?
            ORDER BY pers.cognome ASC;
            """;
        List<DonorOption> list = new ArrayList<>();
        try (var stmt = DAOUtils.prepare(conn, sql, coppia, dataEvento);
             var rs = stmt.executeQuery()) {
            while (rs.next()) {
                list.add(new DonorOption(rs.getString("codice_fiscale"), rs.getString("label")));
            }
        } catch (SQLException e) {
            throw new DAOException(e);
        }
        return list;
    }

    public static List<String> listRegaliNomi(Connection conn, String coppia, String dataEvento) {
        String sql = "SELECT descrizione FROM REGALO WHERE username_coppia = ? AND data_evento = ? ORDER BY descrizione ASC;";
        List<String> list = new ArrayList<>();
        list.add("-- Quota Libera (Nessun regalo specifico) --");
        try (var stmt = DAOUtils.prepare(conn, sql, coppia, dataEvento);
             var rs = stmt.executeQuery()) {
            while (rs.next()) {
                list.add(rs.getString("descrizione"));
            }
        } catch (SQLException e) {
            throw new DAOException(e);
        }
        return list;
    }

    public static void inserisciQuota(Connection conn, String coppia, String dataEvento, String cf, double importo, String metodo, String regaloDesc, String messaggio) {
        String reg = (regaloDesc == null || regaloDesc.startsWith("--")) ? null : regaloDesc;
        String sql = """
            INSERT INTO QUOTA_REGALO 
                (codice_fiscale, username_coppia, data_evento, data_ora, importo, messaggio_auguri, metodo_pagamento, stato, descrizione_regalo)
            VALUES (?, ?, ?, NOW(), ?, ?, ?, 'confermato', ?);
            """;
        try (var stmt = DAOUtils.prepare(conn, sql, cf, coppia, dataEvento, importo, messaggio, metodo, reg)) {
            stmt.executeUpdate();
        } catch (SQLException e) {
            throw new DAOException("Errore durante l'inserimento della quota regalo: " + e.getMessage(), e);
        }
    }
}
