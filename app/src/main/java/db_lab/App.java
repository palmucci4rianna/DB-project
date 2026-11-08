package db_lab;

import db_lab.data.DAOUtils;
import db_lab.ui.MainWindow;
import java.sql.Connection;
import javax.swing.JOptionPane;
import javax.swing.SwingUtilities;
import javax.swing.UIManager;

public final class App {

    public static void main(String[] args) {
        // Imposta Look & Feel nativo di sistema
        try {
            UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
        } catch (Exception ignored) {}

        // Tenta la connessione al database 'wedding_planner'
        Connection connection = null;
        try {
            connection = DAOUtils.getWeddingPlannerConnection();
            System.out.println("✓ Connessione al database 'wedding_planner' su localhost:3306 stabilita con successo.");
        } catch (Exception e) {
            System.err.println("✗ Impossibile connettersi al database 'wedding_planner': " + e.getMessage());
            // Mostra messaggio di errore grafico se disponibile
            try {
                JOptionPane.showMessageDialog(
                    null,
                    "Impossibile connettersi a MySQL (database 'wedding_planner').\n\n" +
                    "Dettaglio: " + e.getMessage() + "\n\n" +
                    "Assicurati che il servizio MySQL sia avviato su localhost:3306\n" +
                    "e che lo schema 'wedding_planner' sia stato inizializzato.",
                    "Errore di Connessione al Database",
                    JOptionPane.ERROR_MESSAGE
                );
            } catch (Exception ignored) {}
            return;
        }

        final Connection finalConn = connection;
        SwingUtilities.invokeLater(() -> {
            var window = new MainWindow(finalConn);
            window.setVisible(true);
        });
    }
}
