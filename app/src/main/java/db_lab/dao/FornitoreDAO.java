package db_lab.dao;

import db_lab.data.DAOException;
import db_lab.data.DAOUtils;
import db_lab.data.QueryResult;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public final class FornitoreDAO {

    private FornitoreDAO() {}

    public static QueryResult listFornitori(Connection conn, String categoria) {
        StringBuilder sql = new StringBuilder("""
            SELECT 
                f.nome_categoria AS Categoria,
                f.partita_iva AS PartitaIVA,
                f.ragione_sociale AS RagioneSociale,
                f.telefono AS Telefono,
                f.email AS Email,
                f.attivo AS Attivo,
                COUNT(c.numero_preventivo) AS ContrattiStipulati,
                COALESCE(SUM(c.importo_concordato), 0.00) AS TotaleFatturato,
                ROUND(COALESCE(AVG(c.importo_concordato), 0.00), 2) AS ImportoMedio
            FROM FORNITORE f
            LEFT JOIN PREVENTIVO p 
                ON f.partita_iva = p.fornitore_piva
            LEFT JOIN CONTRATTO c 
                ON p.numero_preventivo = c.numero_preventivo 
               AND p.fornitore_piva = c.fornitore_piva
            """);

        if (categoria != null && !categoria.equalsIgnoreCase("TUTTE")) {
            sql.append(" WHERE f.nome_categoria = ? ");
            sql.append(" GROUP BY f.nome_categoria, f.partita_iva, f.ragione_sociale, f.telefono, f.email, f.attivo ");
            sql.append(" ORDER BY f.nome_categoria, f.ragione_sociale ASC;");
            return DAOUtils.executeGenericQuery(conn, sql.toString(), categoria);
        } else {
            sql.append(" GROUP BY f.nome_categoria, f.partita_iva, f.ragione_sociale, f.telefono, f.email, f.attivo ");
            sql.append(" ORDER BY f.nome_categoria, f.ragione_sociale ASC;");
            return DAOUtils.executeGenericQuery(conn, sql.toString());
        }
    }

    public static QueryResult listContratti(Connection conn, String coppia, String dataEvento) {
        String sql = """
            SELECT 
                c.numero_preventivo AS NumeroContratto,
                f.ragione_sociale AS Fornitore,
                f.nome_categoria AS Categoria,
                c.data_firma AS DataFirma,
                c.importo_concordato AS ImportoConcordato,
                c.acconto_versato AS AccontoVersato,
                (c.importo_concordato - c.acconto_versato) AS SaldoResiduo,
                c.stato_pagamento AS StatoPagamento
            FROM CONTRATTO c
            JOIN PREVENTIVO p 
                ON c.numero_preventivo = p.numero_preventivo 
               AND c.fornitore_piva = p.fornitore_piva
            JOIN FORNITORE f 
                ON c.fornitore_piva = f.partita_iva
            WHERE p.username_coppia = ? AND p.data_evento = ?
            ORDER BY c.data_firma ASC;
            """;
        return DAOUtils.executeGenericQuery(conn, sql, coppia, dataEvento);
    }

    public static List<String> listCategorie(Connection conn) {
        String sql = "SELECT nome_categoria FROM CATEGORIA_FORNITORE ORDER BY nome_categoria ASC;";
        List<String> list = new ArrayList<>();
        list.add("TUTTE");
        try (var stmt = conn.createStatement(); var rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                list.add(rs.getString("nome_categoria"));
            }
        } catch (SQLException e) {
            throw new DAOException(e);
        }
        return list;
    }
}
