package db_lab.ui;

import db_lab.dao.EventoDAO;
import db_lab.dao.FornitoreDAO;
import db_lab.dao.ListaNozzeDAO;
import db_lab.dao.StatisticheDAO;
import db_lab.dao.TavoliDAO;
import db_lab.data.DAOUtils;
import db_lab.data.QueryResult;
import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Component;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.Font;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.GridLayout;
import java.awt.Insets;
import java.sql.Connection;
import java.util.List;
import javax.swing.BorderFactory;
import javax.swing.Box;
import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JComponent;
import javax.swing.JDialog;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JSplitPane;
import javax.swing.JTabbedPane;
import javax.swing.JTable;
import javax.swing.JTextArea;
import javax.swing.JTextField;
import javax.swing.ListSelectionModel;
import javax.swing.SwingConstants;
import javax.swing.SwingUtilities;
import javax.swing.UIManager;
import javax.swing.table.DefaultTableCellRenderer;
import javax.swing.table.DefaultTableModel;
import javax.swing.table.TableRowSorter;

public class MainWindow extends JFrame {

    private final Connection connection;

    // Statistiche tab components
    private JComboBox<String> statSelector;
    private JLabel statTitleLabel;
    private JTextArea statDescArea;
    private JTextArea statSqlArea;
    private JPanel statSqlPanel;
    private JTable statTable;
    private DefaultTableModel statTableModel;
    private JLabel statStatusLabel;

    // Eventi tab components
    private JTable eventiTable;
    private DefaultTableModel eventiTableModel;
    private JLabel eventiSummaryLabel;

    // Table Planner tab components
    private JComboBox<TavoliDAO.EventKey> tavoliEventSelector;
    private JTable tavoliTable;
    private DefaultTableModel tavoliTableModel;
    private JTable invitatiTable;
    private DefaultTableModel invitatiTableModel;
    private JComboBox<String> assegnazioneTavoloSelector;
    private JLabel seatingFeedbackLabel;

    // Fornitori tab components
    private JComboBox<String> fornitoriCatSelector;
    private JTable fornitoriTable;
    private DefaultTableModel fornitoriTableModel;
    private JComboBox<TavoliDAO.EventKey> contrattiEventSelector;
    private JTable contrattiTable;
    private DefaultTableModel contrattiTableModel;

    // Lista Nozze tab components
    private JComboBox<TavoliDAO.EventKey> nozzeEventSelector;
    private JLabel nozzeHeaderLabel;
    private JTable regaliTable;
    private DefaultTableModel regaliTableModel;
    private JTable quoteTable;
    private DefaultTableModel quoteTableModel;

    // SQL Console tab components
    private JTextArea sqlConsoleArea;
    private JTable sqlConsoleTable;
    private DefaultTableModel sqlConsoleTableModel;
    private JLabel sqlConsoleStatusLabel;

    public MainWindow(Connection connection) {
        super("Wedding Planner Management System — Università di Bologna");
        this.connection = connection;
        initComponents();
    }

    private void initComponents() {
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setMinimumSize(new Dimension(1100, 720));
        setPreferredSize(new Dimension(1220, 800));
        setLayout(new BorderLayout(0, 0));

        // Top Header
        add(createHeaderPanel(), BorderLayout.NORTH);

        // Main Tabbed Pane
        JTabbedPane tabbedPane = new JTabbedPane();
        tabbedPane.setFont(new Font("SansSerif", Font.BOLD, 13));

        tabbedPane.addTab("📊 Statistiche Direzionali (STAT-01..08)", createStatisticheTab());
        tabbedPane.addTab("💍 Panoramica Eventi", createEventiTab());
        tabbedPane.addTab("🪑 Table Planner & RSVP", createTavoliTab());
        tabbedPane.addTab("🤝 Fornitori & Contratti", createFornitoriTab());
        tabbedPane.addTab("🎁 Lista Nozze & Donazioni", createListaNozzeTab());
        tabbedPane.addTab("💻 Console SQL Interattiva", createSqlConsoleTab());

        add(tabbedPane, BorderLayout.CENTER);

        pack();
        setLocationRelativeTo(null);

        // Initial Data Load
        SwingUtilities.invokeLater(() -> {
            loadEventiData();
            reloadTavoliTab();
            reloadFornitoriTab();
            reloadNozzeTab();
            executeSelectedStat();
        });
    }

    private JPanel createHeaderPanel() {
        JPanel header = new JPanel(new BorderLayout());
        header.setBackground(new Color(24, 38, 59));
        header.setBorder(BorderFactory.createEmptyBorder(12, 16, 12, 16));

        JPanel left = new JPanel();
        left.setOpaque(false);
        left.setLayout(new BoxLayout(left, BoxLayout.Y_AXIS));

        JLabel title = new JLabel("💍 WEDDING PLANNER STUDIO");
        title.setFont(new Font("SansSerif", Font.BOLD, 18));
        title.setForeground(Color.WHITE);

        JLabel subtitle = new JLabel("Sistema Informativo di Pianificazione Eventi & Controllo Direzionale — Corso di Basi di Dati");
        subtitle.setFont(new Font("SansSerif", Font.PLAIN, 12));
        subtitle.setForeground(new Color(200, 215, 235));

        left.add(title);
        left.add(Box.createVerticalStrut(3));
        left.add(subtitle);

        JPanel right = new JPanel(new FlowLayout(FlowLayout.RIGHT, 10, 0));
        right.setOpaque(false);

        JLabel statusDot = new JLabel("● MySQL: CONNESSO (wedding_planner)");
        statusDot.setFont(new Font("SansSerif", Font.BOLD, 12));
        statusDot.setForeground(new Color(76, 217, 100));

        right.add(statusDot);

        header.add(left, BorderLayout.WEST);
        header.add(right, BorderLayout.EAST);
        return header;
    }

    // =========================================================================
    // TAB 1: STATISTICHE DIREZIONALI
    // =========================================================================
    private JPanel createStatisticheTab() {
        JPanel panel = new JPanel(new BorderLayout(8, 8));
        panel.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));

        // Top Control Panel
        JPanel topPanel = new JPanel(new BorderLayout(6, 6));

        JPanel selectorPanel = new JPanel(new FlowLayout(FlowLayout.LEFT, 10, 5));
        selectorPanel.add(new JLabel("Seleziona Statistica:"));

        statSelector = new JComboBox<>();
        statSelector.setFont(new Font("SansSerif", Font.BOLD, 12));
        for (var entry : StatisticheDAO.QUERIES.entrySet()) {
            statSelector.addItem(entry.getKey() + ": " + entry.getValue().title());
        }
        statSelector.setPreferredSize(new Dimension(580, 28));
        selectorPanel.add(statSelector);

        JButton execBtn = new JButton("⚡ Esegui Statistica");
        execBtn.setFont(new Font("SansSerif", Font.BOLD, 12));
        execBtn.addActionListener(e -> executeSelectedStat());
        selectorPanel.add(execBtn);

        JButton toggleSqlBtn = new JButton("Visualizza / Nascondi SQL");
        toggleSqlBtn.addActionListener(e -> {
            statSqlPanel.setVisible(!statSqlPanel.isVisible());
            topPanel.revalidate();
        });
        selectorPanel.add(toggleSqlBtn);

        topPanel.add(selectorPanel, BorderLayout.NORTH);

        // Info & SQL Panel
        JPanel descPanel = new JPanel(new BorderLayout(4, 4));
        descPanel.setBorder(BorderFactory.createTitledBorder("Descrizione Obiettivo di Business"));
        statTitleLabel = new JLabel();
        statTitleLabel.setFont(new Font("SansSerif", Font.BOLD, 13));
        statDescArea = new JTextArea(2, 60);
        statDescArea.setWrapStyleWord(true);
        statDescArea.setLineWrap(true);
        statDescArea.setEditable(false);
        statDescArea.setOpaque(false);
        statDescArea.setFont(new Font("SansSerif", Font.PLAIN, 12));
        descPanel.add(statTitleLabel, BorderLayout.NORTH);
        descPanel.add(statDescArea, BorderLayout.CENTER);

        statSqlPanel = new JPanel(new BorderLayout());
        statSqlPanel.setBorder(BorderFactory.createTitledBorder("Codice SQL Eseguito"));
        statSqlPanel.setVisible(false);
        statSqlArea = new JTextArea(7, 60);
        statSqlArea.setEditable(false);
        statSqlArea.setFont(new Font("Monospaced", Font.PLAIN, 11));
        statSqlArea.setBackground(new Color(245, 247, 250));
        statSqlPanel.add(new JScrollPane(statSqlArea), BorderLayout.CENTER);

        JPanel combinedHeader = new JPanel(new BorderLayout(4, 4));
        combinedHeader.add(descPanel, BorderLayout.NORTH);
        combinedHeader.add(statSqlPanel, BorderLayout.CENTER);
        topPanel.add(combinedHeader, BorderLayout.CENTER);

        panel.add(topPanel, BorderLayout.NORTH);

        // Center Results Table
        statTableModel = new DefaultTableModel();
        statTable = new JTable(statTableModel);
        styleTable(statTable);
        panel.add(new JScrollPane(statTable), BorderLayout.CENTER);

        // Bottom Status Bar
        statStatusLabel = new JLabel("Pronto.");
        statStatusLabel.setFont(new Font("SansSerif", Font.ITALIC, 11));
        panel.add(statStatusLabel, BorderLayout.SOUTH);

        statSelector.addActionListener(e -> {
            updateStatDescription();
            executeSelectedStat();
        });

        updateStatDescription();
        return panel;
    }

    private void updateStatDescription() {
        String selected = (String) statSelector.getSelectedItem();
        if (selected == null) return;
        String id = selected.substring(0, 7);
        var info = StatisticheDAO.QUERIES.get(id);
        if (info != null) {
            statTitleLabel.setText(info.id() + " — " + info.title());
            statDescArea.setText(info.description());
            statSqlArea.setText(info.sql().trim());
        }
    }

    private void executeSelectedStat() {
        String selected = (String) statSelector.getSelectedItem();
        if (selected == null) return;
        String id = selected.substring(0, 7);
        try {
            QueryResult qr = StatisticheDAO.executeStat(connection, id);
            applyQueryResultToTable(qr, statTableModel, statTable);
            statStatusLabel.setText(String.format("✓ %s completata con successo | Righe restituite: %d | Tempo di esecuzione: %d ms",
                id, qr.rowCount(), qr.executionTimeMs()));
        } catch (Exception ex) {
            JOptionPane.showMessageDialog(this, "Errore durante l'esecuzione di " + id + ":\n" + ex.getMessage(),
                "Errore Query", JOptionPane.ERROR_MESSAGE);
            statStatusLabel.setText("✗ Errore esecuzione: " + ex.getMessage());
        }
    }

    // =========================================================================
    // TAB 2: GESTIONE EVENTI & MATRIMONI
    // =========================================================================
    private JPanel createEventiTab() {
        JPanel panel = new JPanel(new BorderLayout(8, 8));
        panel.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));

        JPanel topBar = new JPanel(new FlowLayout(FlowLayout.LEFT, 10, 5));
        JButton refreshBtn = new JButton("🔄 Aggiorna Elenco Matrimoni");
        refreshBtn.setFont(new Font("SansSerif", Font.BOLD, 12));
        refreshBtn.addActionListener(e -> loadEventiData());
        topBar.add(refreshBtn);

        eventiSummaryLabel = new JLabel("Caricamento...");
        eventiSummaryLabel.setFont(new Font("SansSerif", Font.PLAIN, 12));
        topBar.add(eventiSummaryLabel);

        panel.add(topBar, BorderLayout.NORTH);

        eventiTableModel = new DefaultTableModel();
        eventiTable = new JTable(eventiTableModel);
        styleTable(eventiTable);
        panel.add(new JScrollPane(eventiTable), BorderLayout.CENTER);

        return panel;
    }

    private void loadEventiData() {
        try {
            QueryResult qr = EventoDAO.listAllEventi(connection);
            applyQueryResultToTable(qr, eventiTableModel, eventiTable);
            eventiSummaryLabel.setText(String.format("Totale Matrimoni Censiti nel Database: %d | Clicca sulle intestazioni per ordinare", qr.rowCount()));
        } catch (Exception ex) {
            JOptionPane.showMessageDialog(this, "Errore caricamento eventi:\n" + ex.getMessage(), "Errore", JOptionPane.ERROR_MESSAGE);
        }
    }

    // =========================================================================
    // TAB 3: TABLE PLANNER & RSVP
    // =========================================================================
    private JPanel createTavoliTab() {
        JPanel panel = new JPanel(new BorderLayout(8, 8));
        panel.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));

        // Selector Bar
        JPanel topBar = new JPanel(new FlowLayout(FlowLayout.LEFT, 10, 5));
        topBar.add(new JLabel("Seleziona Matrimonio:"));

        tavoliEventSelector = new JComboBox<>();
        tavoliEventSelector.setFont(new Font("SansSerif", Font.BOLD, 12));
        tavoliEventSelector.setPreferredSize(new Dimension(300, 28));
        tavoliEventSelector.addActionListener(e -> reloadTavoliAndGuests());
        topBar.add(tavoliEventSelector);

        JButton refreshBtn = new JButton("🔄 Ricarica");
        refreshBtn.addActionListener(e -> reloadTavoliAndGuests());
        topBar.add(refreshBtn);

        panel.add(topBar, BorderLayout.NORTH);

        // Split Pane: Left Tables, Right Guests
        JSplitPane splitPane = new JSplitPane(JSplitPane.HORIZONTAL_SPLIT);
        splitPane.setResizeWeight(0.42);

        // Left Panel (Tavoli)
        JPanel leftPanel = new JPanel(new BorderLayout(4, 4));
        leftPanel.setBorder(BorderFactory.createTitledBorder("Tavoli della Sala & Saturazione Posti"));
        tavoliTableModel = new DefaultTableModel();
        tavoliTable = new JTable(tavoliTableModel);
        styleTable(tavoliTable);
        leftPanel.add(new JScrollPane(tavoliTable), BorderLayout.CENTER);

        // Right Panel (Invitati)
        JPanel rightPanel = new JPanel(new BorderLayout(4, 4));
        rightPanel.setBorder(BorderFactory.createTitledBorder("Elenco Ospiti Invitati (RSVP, Esigenze & Tavolo Assegnato)"));
        invitatiTableModel = new DefaultTableModel();
        invitatiTable = new JTable(invitatiTableModel);
        invitatiTable.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
        styleTable(invitatiTable);
        rightPanel.add(new JScrollPane(invitatiTable), BorderLayout.CENTER);

        splitPane.setLeftComponent(leftPanel);
        splitPane.setRightComponent(rightPanel);
        panel.add(splitPane, BorderLayout.CENTER);

        // Bottom Assignment Bar
        JPanel bottomBar = new JPanel(new FlowLayout(FlowLayout.LEFT, 10, 8));
        bottomBar.setBorder(BorderFactory.createTitledBorder("Gestione Assegnazione Posto"));

        bottomBar.add(new JLabel("Assegna l'ospite selezionato al tavolo:"));

        assegnazioneTavoloSelector = new JComboBox<>();
        assegnazioneTavoloSelector.setPreferredSize(new Dimension(220, 28));
        bottomBar.add(assegnazioneTavoloSelector);

        JButton assignBtn = new JButton("✓ Assegna / Sposta Tavolo");
        assignBtn.setFont(new Font("SansSerif", Font.BOLD, 12));
        assignBtn.addActionListener(e -> performTableAssignment());
        bottomBar.add(assignBtn);

        seatingFeedbackLabel = new JLabel("Seleziona una riga nella tabella ospiti a destra e scegli il tavolo.");
        seatingFeedbackLabel.setFont(new Font("SansSerif", Font.ITALIC, 11));
        bottomBar.add(seatingFeedbackLabel);

        panel.add(bottomBar, BorderLayout.SOUTH);

        return panel;
    }

    private void reloadTavoliTab() {
        try {
            tavoliEventSelector.removeAllItems();
            List<TavoliDAO.EventKey> keys = TavoliDAO.listEventKeys(connection);
            for (var k : keys) {
                tavoliEventSelector.addItem(k);
            }
            if (!keys.isEmpty()) {
                tavoliEventSelector.setSelectedIndex(0);
            }
        } catch (Exception ex) {
            JOptionPane.showMessageDialog(this, "Errore caricamento eventi tavoli:\n" + ex.getMessage(), "Errore", JOptionPane.ERROR_MESSAGE);
        }
    }

    private void reloadTavoliAndGuests() {
        TavoliDAO.EventKey key = (TavoliDAO.EventKey) tavoliEventSelector.getSelectedItem();
        if (key == null) return;

        try {
            QueryResult qrTavoli = TavoliDAO.listTavoli(connection, key.coppia(), key.dataEvento());
            applyQueryResultToTable(qrTavoli, tavoliTableModel, tavoliTable);

            QueryResult qrInvitati = TavoliDAO.listInvitati(connection, key.coppia(), key.dataEvento());
            applyQueryResultToTable(qrInvitati, invitatiTableModel, invitatiTable);

            // Populate table selector
            assegnazioneTavoloSelector.removeAllItems();
            List<String> tNames = TavoliDAO.listAvailableTablesNames(connection, key.coppia(), key.dataEvento());
            for (String t : tNames) {
                assegnazioneTavoloSelector.addItem(t);
            }

            seatingFeedbackLabel.setText("Dati aggiornati. Ospiti caricati: " + qrInvitati.rowCount());
        } catch (Exception ex) {
            JOptionPane.showMessageDialog(this, "Errore caricamento tavoli/ospiti:\n" + ex.getMessage(), "Errore", JOptionPane.ERROR_MESSAGE);
        }
    }

    private void performTableAssignment() {
        int row = invitatiTable.getSelectedRow();
        if (row < 0) {
            JOptionPane.showMessageDialog(this, "Seleziona prima un ospite dalla tabella degli invitati (a destra)!",
                "Nessun Ospite Selezionato", JOptionPane.WARNING_MESSAGE);
            return;
        }

        int modelRow = invitatiTable.convertRowIndexToModel(row);
        String guestCf = (String) invitatiTableModel.getValueAt(modelRow, 0);
        String guestName = (String) invitatiTableModel.getValueAt(modelRow, 1);
        String tableName = (String) assegnazioneTavoloSelector.getSelectedItem();

        TavoliDAO.EventKey key = (TavoliDAO.EventKey) tavoliEventSelector.getSelectedItem();
        if (key == null) return;

        try {
            TavoliDAO.assegnaTavolo(connection, key.coppia(), key.dataEvento(), guestCf, tableName);
            JOptionPane.showMessageDialog(this,
                String.format("Assegnazione completata con successo!\nOspite: %s (%s)\nTavolo: %s", guestName, guestCf, tableName),
                "Operazione Riuscita", JOptionPane.INFORMATION_MESSAGE);
            reloadTavoliAndGuests();
        } catch (Exception ex) {
            JOptionPane.showMessageDialog(this,
                "Impossibile completare l'assegnazione:\n" + ex.getMessage(),
                "Violazione Vincolo o Errore", JOptionPane.ERROR_MESSAGE);
        }
    }

    // =========================================================================
    // TAB 4: FORNITORI & CONTRATTI
    // =========================================================================
    private JPanel createFornitoriTab() {
        JPanel panel = new JPanel(new BorderLayout(8, 8));
        panel.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));

        JSplitPane split = new JSplitPane(JSplitPane.VERTICAL_SPLIT);
        split.setResizeWeight(0.55);

        // Top Panel: Suppliers by category
        JPanel topPanel = new JPanel(new BorderLayout(4, 4));
        topPanel.setBorder(BorderFactory.createTitledBorder("Anagrafica Fornitori Partner & Contrattualizzazioni"));

        JPanel catBar = new JPanel(new FlowLayout(FlowLayout.LEFT, 10, 5));
        catBar.add(new JLabel("Filtra per Categoria Fornitore:"));
        fornitoriCatSelector = new JComboBox<>();
        fornitoriCatSelector.setPreferredSize(new Dimension(200, 26));
        fornitoriCatSelector.addActionListener(e -> reloadFornitoriTable());
        catBar.add(fornitoriCatSelector);

        JButton refreshFornBtn = new JButton("🔄 Aggiorna");
        refreshFornBtn.addActionListener(e -> reloadFornitoriTable());
        catBar.add(refreshFornBtn);
        topPanel.add(catBar, BorderLayout.NORTH);

        fornitoriTableModel = new DefaultTableModel();
        fornitoriTable = new JTable(fornitoriTableModel);
        styleTable(fornitoriTable);
        topPanel.add(new JScrollPane(fornitoriTable), BorderLayout.CENTER);

        // Bottom Panel: Contracts by event
        JPanel bottomPanel = new JPanel(new BorderLayout(4, 4));
        bottomPanel.setBorder(BorderFactory.createTitledBorder("Dettaglio Contratti Stipulati per Evento (Stato Pagamento & Saldi)"));

        JPanel eventBar = new JPanel(new FlowLayout(FlowLayout.LEFT, 10, 5));
        eventBar.add(new JLabel("Visualizza Contratti del Matrimonio:"));
        contrattiEventSelector = new JComboBox<>();
        contrattiEventSelector.setPreferredSize(new Dimension(300, 26));
        contrattiEventSelector.addActionListener(e -> reloadContrattiTable());
        eventBar.add(contrattiEventSelector);
        bottomPanel.add(eventBar, BorderLayout.NORTH);

        contrattiTableModel = new DefaultTableModel();
        contrattiTable = new JTable(contrattiTableModel);
        styleTable(contrattiTable);
        bottomPanel.add(new JScrollPane(contrattiTable), BorderLayout.CENTER);

        split.setTopComponent(topPanel);
        split.setBottomComponent(bottomPanel);
        panel.add(split, BorderLayout.CENTER);

        return panel;
    }

    private void reloadFornitoriTab() {
        try {
            fornitoriCatSelector.removeAllItems();
            List<String> cats = FornitoreDAO.listCategorie(connection);
            for (String c : cats) {
                fornitoriCatSelector.addItem(c);
            }

            contrattiEventSelector.removeAllItems();
            List<TavoliDAO.EventKey> keys = TavoliDAO.listEventKeys(connection);
            for (var k : keys) {
                contrattiEventSelector.addItem(k);
            }
        } catch (Exception ex) {
            JOptionPane.showMessageDialog(this, "Errore caricamento categorie/eventi:\n" + ex.getMessage(), "Errore", JOptionPane.ERROR_MESSAGE);
        }
    }

    private void reloadFornitoriTable() {
        String cat = (String) fornitoriCatSelector.getSelectedItem();
        try {
            QueryResult qr = FornitoreDAO.listFornitori(connection, cat);
            applyQueryResultToTable(qr, fornitoriTableModel, fornitoriTable);
        } catch (Exception ex) {
            JOptionPane.showMessageDialog(this, "Errore caricamento fornitori:\n" + ex.getMessage(), "Errore", JOptionPane.ERROR_MESSAGE);
        }
    }

    private void reloadContrattiTable() {
        TavoliDAO.EventKey key = (TavoliDAO.EventKey) contrattiEventSelector.getSelectedItem();
        if (key == null) return;
        try {
            QueryResult qr = FornitoreDAO.listContratti(connection, key.coppia(), key.dataEvento());
            applyQueryResultToTable(qr, contrattiTableModel, contrattiTable);
        } catch (Exception ex) {
            JOptionPane.showMessageDialog(this, "Errore caricamento contratti:\n" + ex.getMessage(), "Errore", JOptionPane.ERROR_MESSAGE);
        }
    }

    // =========================================================================
    // TAB 5: LISTA NOZZE & DONAZIONI
    // =========================================================================
    private JPanel createListaNozzeTab() {
        JPanel panel = new JPanel(new BorderLayout(8, 8));
        panel.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));

        // Top Event Selector & Registry Info Header
        JPanel topContainer = new JPanel(new BorderLayout(4, 4));

        JPanel eventBar = new JPanel(new FlowLayout(FlowLayout.LEFT, 10, 5));
        eventBar.add(new JLabel("Seleziona Lista Nozze Matrimonio:"));
        nozzeEventSelector = new JComboBox<>();
        nozzeEventSelector.setPreferredSize(new Dimension(300, 28));
        nozzeEventSelector.addActionListener(e -> reloadNozzeTables());
        eventBar.add(nozzeEventSelector);

        JButton addDonationBtn = new JButton("💳 Nuova Quota Regalo");
        addDonationBtn.setFont(new Font("SansSerif", Font.BOLD, 12));
        addDonationBtn.addActionListener(e -> openNewDonationDialog());
        eventBar.add(addDonationBtn);

        topContainer.add(eventBar, BorderLayout.NORTH);

        JPanel headerCard = new JPanel(new BorderLayout());
        headerCard.setBackground(new Color(240, 245, 255));
        headerCard.setBorder(BorderFactory.createCompoundBorder(
            BorderFactory.createLineBorder(new Color(180, 205, 245), 1),
            BorderFactory.createEmptyBorder(8, 12, 8, 12)
        ));
        nozzeHeaderLabel = new JLabel("Dati conto e riepilogo lista...");
        nozzeHeaderLabel.setFont(new Font("SansSerif", Font.BOLD, 13));
        headerCard.add(nozzeHeaderLabel, BorderLayout.CENTER);
        topContainer.add(headerCard, BorderLayout.CENTER);

        panel.add(topContainer, BorderLayout.NORTH);

        // Split: Regali desiderati (Top), Donazioni effettuate (Bottom)
        JSplitPane split = new JSplitPane(JSplitPane.VERTICAL_SPLIT);
        split.setResizeWeight(0.5);

        JPanel topRegali = new JPanel(new BorderLayout(4, 4));
        topRegali.setBorder(BorderFactory.createTitledBorder("Articoli Inclusi nella Lista Nozze (Target & Avanzamento)"));
        regaliTableModel = new DefaultTableModel();
        regaliTable = new JTable(regaliTableModel);
        styleTable(regaliTable);
        topRegali.add(new JScrollPane(regaliTable), BorderLayout.CENTER);

        JPanel bottomQuote = new JPanel(new BorderLayout(4, 4));
        bottomQuote.setBorder(BorderFactory.createTitledBorder("Cronologia Quote Regalo & Auguri Ricevuti dagli Invitati"));
        quoteTableModel = new DefaultTableModel();
        quoteTable = new JTable(quoteTableModel);
        styleTable(quoteTable);
        bottomQuote.add(new JScrollPane(quoteTable), BorderLayout.CENTER);

        split.setTopComponent(topRegali);
        split.setBottomComponent(bottomQuote);
        panel.add(split, BorderLayout.CENTER);

        return panel;
    }

    private void reloadNozzeTab() {
        try {
            nozzeEventSelector.removeAllItems();
            List<TavoliDAO.EventKey> keys = TavoliDAO.listEventKeys(connection);
            for (var k : keys) {
                nozzeEventSelector.addItem(k);
            }
            if (!keys.isEmpty()) {
                nozzeEventSelector.setSelectedIndex(0);
            }
        } catch (Exception ex) {
            JOptionPane.showMessageDialog(this, "Errore caricamento eventi nozze:\n" + ex.getMessage(), "Errore", JOptionPane.ERROR_MESSAGE);
        }
    }

    private void reloadNozzeTables() {
        TavoliDAO.EventKey key = (TavoliDAO.EventKey) nozzeEventSelector.getSelectedItem();
        if (key == null) return;

        try {
            var header = ListaNozzeDAO.getListaHeader(connection, key.coppia(), key.dataEvento());
            double pct = header.totaleDesiderato() > 0 ? (header.totaleRaccolto() / header.totaleDesiderato()) * 100 : 0.0;
            nozzeHeaderLabel.setText(String.format(
                "🏦 Banca: %s  |  IBAN: %s  |  Intestatario: %s  |  💰 Raccolto: € %.2f su € %.2f desiderati (%.1f%%)",
                header.banca(), header.iban(), header.intestatario(), header.totaleRaccolto(), header.totaleDesiderato(), pct
            ));

            QueryResult qrRegali = ListaNozzeDAO.listRegali(connection, key.coppia(), key.dataEvento());
            applyQueryResultToTable(qrRegali, regaliTableModel, regaliTable);

            QueryResult qrQuote = ListaNozzeDAO.listQuote(connection, key.coppia(), key.dataEvento());
            applyQueryResultToTable(qrQuote, quoteTableModel, quoteTable);
        } catch (Exception ex) {
            JOptionPane.showMessageDialog(this, "Errore caricamento lista nozze:\n" + ex.getMessage(), "Errore", JOptionPane.ERROR_MESSAGE);
        }
    }

    private void openNewDonationDialog() {
        TavoliDAO.EventKey key = (TavoliDAO.EventKey) nozzeEventSelector.getSelectedItem();
        if (key == null) return;

        JDialog dialog = new JDialog(this, "Registra Nuova Quota Regalo", true);
        dialog.setLayout(new BorderLayout(10, 10));
        dialog.setSize(480, 360);
        dialog.setLocationRelativeTo(this);

        JPanel form = new JPanel(new GridBagLayout());
        form.setBorder(BorderFactory.createEmptyBorder(12, 16, 12, 16));
        GridBagConstraints gbc = new GridBagConstraints();
        gbc.insets = new Insets(5, 5, 5, 5);
        gbc.fill = GridBagConstraints.HORIZONTAL;

        // Invitato Donatore
        gbc.gridx = 0; gbc.gridy = 0;
        form.add(new JLabel("Ospite Donatore:"), gbc);
        gbc.gridx = 1;
        JComboBox<ListaNozzeDAO.DonorOption> donatoreCombo = new JComboBox<>();
        List<ListaNozzeDAO.DonorOption> donors = ListaNozzeDAO.listInvitatiDonatori(connection, key.coppia(), key.dataEvento());
        for (var d : donors) donatoreCombo.addItem(d);
        form.add(donatoreCombo, gbc);

        // Importo
        gbc.gridx = 0; gbc.gridy = 1;
        form.add(new JLabel("Importo Donato (€):"), gbc);
        gbc.gridx = 1;
        JTextField importoField = new JTextField("100.00");
        form.add(importoField, gbc);

        // Metodo Pagamento
        gbc.gridx = 0; gbc.gridy = 2;
        form.add(new JLabel("Metodo di Pagamento:"), gbc);
        gbc.gridx = 1;
        JComboBox<String> metodoCombo = new JComboBox<>(new String[]{"Bonifico Bancario", "Carta di Credito", "Satispay", "Contanti"});
        form.add(metodoCombo, gbc);

        // Regalo Destinazione
        gbc.gridx = 0; gbc.gridy = 3;
        form.add(new JLabel("Articolo Regalo:"), gbc);
        gbc.gridx = 1;
        JComboBox<String> regaliCombo = new JComboBox<>();
        List<String> regaliNomi = ListaNozzeDAO.listRegaliNomi(connection, key.coppia(), key.dataEvento());
        for (var r : regaliNomi) regaliCombo.addItem(r);
        form.add(regaliCombo, gbc);

        // Messaggio Auguri
        gbc.gridx = 0; gbc.gridy = 4;
        form.add(new JLabel("Messaggio di Auguri:"), gbc);
        gbc.gridx = 1;
        JTextField msgField = new JTextField("Tanti auguri per una vita felice insieme!");
        form.add(msgField, gbc);

        dialog.add(form, BorderLayout.CENTER);

        // Buttons
        JPanel btnPanel = new JPanel(new FlowLayout(FlowLayout.RIGHT, 10, 10));
        JButton cancelBtn = new JButton("Annulla");
        cancelBtn.addActionListener(e -> dialog.dispose());

        JButton saveBtn = new JButton("💾 Salva Donazione");
        saveBtn.setFont(new Font("SansSerif", Font.BOLD, 12));
        saveBtn.addActionListener(e -> {
            var donor = (ListaNozzeDAO.DonorOption) donatoreCombo.getSelectedItem();
            if (donor == null) {
                JOptionPane.showMessageDialog(dialog, "Nessun ospite selezionato.", "Attenzione", JOptionPane.WARNING_MESSAGE);
                return;
            }
            double imp;
            try {
                imp = Double.parseDouble(importoField.getText().trim());
                if (imp <= 0) throw new NumberFormatException();
            } catch (Exception ex) {
                JOptionPane.showMessageDialog(dialog, "Inserisci un importo valido positivo (es. 150.00).", "Importo Errato", JOptionPane.WARNING_MESSAGE);
                return;
            }

            try {
                ListaNozzeDAO.inserisciQuota(
                    connection,
                    key.coppia(),
                    key.dataEvento(),
                    donor.cf(),
                    imp,
                    (String) metodoCombo.getSelectedItem(),
                    (String) regaliCombo.getSelectedItem(),
                    msgField.getText().trim()
                );
                dialog.dispose();
                JOptionPane.showMessageDialog(this, "Quota regalo registrata con successo nel database!", "Donazione Registrata", JOptionPane.INFORMATION_MESSAGE);
                reloadNozzeTables();
            } catch (Exception ex) {
                JOptionPane.showMessageDialog(dialog, "Errore salvataggio quota:\n" + ex.getMessage(), "Errore", JOptionPane.ERROR_MESSAGE);
            }
        });

        btnPanel.add(cancelBtn);
        btnPanel.add(saveBtn);
        dialog.add(btnPanel, BorderLayout.SOUTH);

        dialog.setVisible(true);
    }

    // =========================================================================
    // TAB 6: CONSOLE SQL INTERATTIVA
    // =========================================================================
    private JPanel createSqlConsoleTab() {
        JPanel panel = new JPanel(new BorderLayout(8, 8));
        panel.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));

        JPanel topPanel = new JPanel(new BorderLayout(4, 4));

        JPanel quickBtnBar = new JPanel(new FlowLayout(FlowLayout.LEFT, 6, 4));
        quickBtnBar.add(new JLabel("Query Rapide:"));

        JButton btn1 = new JButton("Tutti gli Eventi");
        btn1.addActionListener(e -> sqlConsoleArea.setText("SELECT username_coppia, data, budget_effettivo, stato FROM EVENTO ORDER BY data ASC;"));
        quickBtnBar.add(btn1);

        JButton btn2 = new JButton("Tutti gli Invitati");
        btn2.addActionListener(e -> sqlConsoleArea.setText("""
            SELECT p.codice_fiscale, p.cognome, p.nome, part.username_coppia, part.stato, part.tavolo_nome_numero
            FROM PERSONA p
            JOIN INVITATO i ON p.codice_fiscale = i.codice_fiscale
            JOIN PARTECIPAZIONE part ON i.codice_fiscale = part.codice_fiscale
            ORDER BY p.cognome ASC;
            """.trim()));
        quickBtnBar.add(btn2);

        JButton btn3 = new JButton("Checklist Operativa");
        btn3.addActionListener(e -> sqlConsoleArea.setText("""
            SELECT username_coppia, data_evento, titolo_attivita, scadenza, data_completamento, priorita
            FROM ATTIVITA_CHECKLIST
            ORDER BY scadenza ASC;
            """.trim()));
        quickBtnBar.add(btn3);

        JButton btn4 = new JButton("Fornitori & Categorie");
        btn4.addActionListener(e -> sqlConsoleArea.setText("""
            SELECT partita_iva, ragione_sociale, nome_categoria, telefono, attivo
            FROM FORNITORE
            ORDER BY nome_categoria, ragione_sociale;
            """.trim()));
        quickBtnBar.add(btn4);

        JButton btn5 = new JButton("Recensioni Matrimoni");
        btn5.addActionListener(e -> sqlConsoleArea.setText("""
            SELECT username_coppia, data_evento, voto, data, testo, tag_stile
            FROM RECENSIONE
            ORDER BY data_evento DESC;
            """.trim()));
        quickBtnBar.add(btn5);

        topPanel.add(quickBtnBar, BorderLayout.NORTH);

        JPanel editorPanel = new JPanel(new BorderLayout(4, 4));
        editorPanel.setBorder(BorderFactory.createTitledBorder("Editor Query SQL (SELECT supportate)"));
        sqlConsoleArea = new JTextArea(5, 60);
        sqlConsoleArea.setFont(new Font("Monospaced", Font.PLAIN, 13));
        sqlConsoleArea.setText("SELECT * FROM EVENTO;");
        editorPanel.add(new JScrollPane(sqlConsoleArea), BorderLayout.CENTER);

        JPanel execBar = new JPanel(new FlowLayout(FlowLayout.RIGHT, 10, 4));
        JButton execSqlBtn = new JButton("▶ Esegui Query SQL");
        execSqlBtn.setFont(new Font("SansSerif", Font.BOLD, 12));
        execSqlBtn.addActionListener(e -> executeConsoleSql());
        execBar.add(execSqlBtn);
        editorPanel.add(execBar, BorderLayout.SOUTH);

        topPanel.add(editorPanel, BorderLayout.CENTER);
        panel.add(topPanel, BorderLayout.NORTH);

        sqlConsoleTableModel = new DefaultTableModel();
        sqlConsoleTable = new JTable(sqlConsoleTableModel);
        styleTable(sqlConsoleTable);
        panel.add(new JScrollPane(sqlConsoleTable), BorderLayout.CENTER);

        sqlConsoleStatusLabel = new JLabel("Digita una query SQL e premi 'Esegui Query SQL'.");
        sqlConsoleStatusLabel.setFont(new Font("SansSerif", Font.ITALIC, 11));
        panel.add(sqlConsoleStatusLabel, BorderLayout.SOUTH);

        return panel;
    }

    private void executeConsoleSql() {
        String sql = sqlConsoleArea.getText().trim();
        if (sql.isEmpty()) return;

        try {
            QueryResult qr = DAOUtils.executeGenericQuery(connection, sql);
            applyQueryResultToTable(qr, sqlConsoleTableModel, sqlConsoleTable);
            sqlConsoleStatusLabel.setText(String.format("✓ Query eseguita con successo | Righe restituite: %d | Tempo di esecuzione: %d ms",
                qr.rowCount(), qr.executionTimeMs()));
        } catch (Exception ex) {
            JOptionPane.showMessageDialog(this, "Errore durante l'esecuzione della query:\n" + ex.getMessage(),
                "Errore SQL", JOptionPane.ERROR_MESSAGE);
            sqlConsoleStatusLabel.setText("✗ Errore: " + ex.getMessage());
        }
    }

    // =========================================================================
    // UTILITY: TABLE STYLING & POPULATION
    // =========================================================================
    private void applyQueryResultToTable(QueryResult qr, DefaultTableModel model, JTable table) {
        model.setDataVector(qr.getDataVector(), qr.getColumnVector());
        TableRowSorter<DefaultTableModel> sorter = new TableRowSorter<>(model);
        table.setRowSorter(sorter);
    }

    private void styleTable(JTable table) {
        table.setFont(new Font("SansSerif", Font.PLAIN, 12));
        table.setRowHeight(24);
        table.getTableHeader().setFont(new Font("SansSerif", Font.BOLD, 12));
        table.getTableHeader().setBackground(new Color(235, 240, 248));
        table.setShowGrid(true);
        table.setGridColor(new Color(225, 230, 238));
        table.setAutoResizeMode(JTable.AUTO_RESIZE_ALL_COLUMNS);

        // Striped rows renderer
        table.setDefaultRenderer(Object.class, new DefaultTableCellRenderer() {
            @Override
            public Component getTableCellRendererComponent(JTable t, Object value, boolean isSelected, boolean hasFocus, int row, int col) {
                Component c = super.getTableCellRendererComponent(t, value, isSelected, hasFocus, row, col);
                if (!isSelected) {
                    c.setBackground(row % 2 == 0 ? Color.WHITE : new Color(248, 250, 253));
                }
                return c;
            }
        });
    }
}
