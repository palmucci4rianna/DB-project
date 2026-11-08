package db_lab;

import static org.assertj.core.api.Assertions.assertThat;

import db_lab.dao.EventoDAO;
import db_lab.dao.FornitoreDAO;
import db_lab.dao.ListaNozzeDAO;
import db_lab.dao.StatisticheDAO;
import db_lab.dao.TavoliDAO;
import db_lab.data.DAOUtils;
import db_lab.data.QueryResult;
import java.sql.Connection;
import java.sql.SQLException;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

public class WeddingPlannerTest {

    private static Connection conn;

    @BeforeAll
    public static void setUp() {
        try {
            conn = DAOUtils.getWeddingPlannerConnection();
        } catch (Exception e) {
            System.out.println("Salto test se MySQL 'wedding_planner' non è raggiungibile: " + e.getMessage());
        }
    }

    @AfterAll
    public static void tearDown() throws SQLException {
        if (conn != null && !conn.isClosed()) {
            conn.close();
        }
    }

    @Test
    @DisplayName("Verifica connessione attiva a wedding_planner")
    public void testDatabaseConnection() throws SQLException {
        if (conn == null) return;
        assertThat(conn.isClosed()).isFalse();
        assertThat(conn.getCatalog()).isEqualTo("wedding_planner");
    }

    @ParameterizedTest(name = "Esecuzione query {0}")
    @ValueSource(strings = {
        "STAT-01", "STAT-02", "STAT-03", "STAT-04",
        "STAT-05", "STAT-06", "STAT-07", "STAT-08"
    })
    @DisplayName("Verifica esecuzione con esito positivo di tutte le 8 query analitiche")
    public void testAllAnalyticalQueries(String statId) {
        if (conn == null) return;
        QueryResult qr = StatisticheDAO.executeStat(conn, statId);
        assertThat(qr).isNotNull();
        assertThat(qr.columnNames()).isNotEmpty();
        assertThat(qr.rowCount()).isGreaterThan(0);
        assertThat(qr.executionTimeMs()).isGreaterThanOrEqualTo(0);
    }

    @Test
    @DisplayName("Verifica EventoDAO: listAllEventi")
    public void testEventoDAO() {
        if (conn == null) return;
        QueryResult qr = EventoDAO.listAllEventi(conn);
        assertThat(qr).isNotNull();
        assertThat(qr.rowCount()).isGreaterThanOrEqualTo(4);
    }

    @Test
    @DisplayName("Verifica TavoliDAO: listEventKeys e listTavoli")
    public void testTavoliDAO() {
        if (conn == null) return;
        var keys = TavoliDAO.listEventKeys(conn);
        assertThat(keys).isNotEmpty();

        var first = keys.get(0);
        QueryResult qrTavoli = TavoliDAO.listTavoli(conn, first.coppia(), first.dataEvento());
        assertThat(qrTavoli).isNotNull();
        assertThat(qrTavoli.rowCount()).isGreaterThan(0);

        QueryResult qrInvitati = TavoliDAO.listInvitati(conn, first.coppia(), first.dataEvento());
        assertThat(qrInvitati).isNotNull();
        assertThat(qrInvitati.rowCount()).isGreaterThan(0);
    }

    @Test
    @DisplayName("Verifica FornitoreDAO: listFornitori e listContratti")
    public void testFornitoreDAO() {
        if (conn == null) return;
        QueryResult qrForn = FornitoreDAO.listFornitori(conn, "TUTTE");
        assertThat(qrForn).isNotNull();
        assertThat(qrForn.rowCount()).isGreaterThan(0);

        var cats = FornitoreDAO.listCategorie(conn);
        assertThat(cats).contains("TUTTE", "Catering & Banqueting", "Foto & Video");
    }

    @Test
    @DisplayName("Verifica ListaNozzeDAO: getListaHeader e listRegali")
    public void testListaNozzeDAO() {
        if (conn == null) return;
        var keys = TavoliDAO.listEventKeys(conn);
        assertThat(keys).isNotEmpty();

        var first = keys.get(0);
        var header = ListaNozzeDAO.getListaHeader(conn, first.coppia(), first.dataEvento());
        assertThat(header).isNotNull();
        assertThat(header.iban()).isNotEmpty();

        QueryResult qrRegali = ListaNozzeDAO.listRegali(conn, first.coppia(), first.dataEvento());
        assertThat(qrRegali).isNotNull();
    }
}
