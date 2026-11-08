package db_lab.data;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public final class DAOUtils {

    // Establishes a connection to a MySQL daemon running locally at port 3306.
    //
    public static Connection localMySQLConnection(String database, String username, String password) {
        try {
            var host = "localhost";
            var port = "3306";
            var connectionString = "jdbc:mysql://" + host + ":" + port + "/" + database + "?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
            return DriverManager.getConnection(connectionString, username, password);
        } catch (Exception e) {
            throw new DAOException(e);
        }
    }

    // We must always prepare a statement to make sure we do not fall victim to SQL injection:
    // https://owasp.org/www-community/attacks/SQL_Injection
    //
    // This is a helper that prepares the statement with all the values we give it:
    //
    //     prepare(connection, MY_QUERY, query_arg1, query_arg2, ...)
    //
    public static PreparedStatement prepare(Connection connection, String query, Object... values) throws SQLException {
        PreparedStatement statement = null;
        try {
            statement = connection.prepareStatement(query);
            for (int i = 0; i < values.length; i++) {
                statement.setObject(i + 1, values[i]);
            }
            return statement;
        } catch (Exception e) {
            if (statement != null) {
                statement.close();
            }
            throw e;
        }
    }

    public static Connection getWeddingPlannerConnection() {
        String[] users = {"root", "ariannapalmucci", "root"};
        String[] passes = {"", "12345678", "root"};
        Exception lastException = null;

        for (int i = 0; i < users.length; i++) {
            try {
                return localMySQLConnection("wedding_planner", users[i], passes[i]);
            } catch (Exception e) {
                lastException = e;
            }
        }
        throw new DAOException("Impossibile connettersi al database 'wedding_planner'. Assicurati che MySQL sia attivo.", lastException);
    }

    public static QueryResult executeGenericQuery(Connection connection, String sql, Object... values) {
        long startTime = System.currentTimeMillis();
        try (var statement = prepare(connection, sql, values);
             var resultSet = statement.executeQuery()) {
            
            var meta = resultSet.getMetaData();
            int colCount = meta.getColumnCount();
            var cols = new java.util.ArrayList<String>();
            for (int i = 1; i <= colCount; i++) {
                cols.add(meta.getColumnLabel(i));
            }

            var rows = new java.util.ArrayList<Object[]>();
            while (resultSet.next()) {
                Object[] row = new Object[colCount];
                for (int i = 1; i <= colCount; i++) {
                    row[i - 1] = resultSet.getObject(i);
                }
                rows.add(row);
            }
            long elapsed = System.currentTimeMillis() - startTime;
            return new QueryResult(cols, rows, rows.size(), elapsed);
        } catch (Exception e) {
            throw new DAOException(e);
        }
    }
}
