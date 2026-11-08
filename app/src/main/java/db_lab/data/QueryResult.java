package db_lab.data;

import java.util.List;
import java.util.Vector;

public record QueryResult(
    List<String> columnNames,
    List<Object[]> rows,
    int rowCount,
    long executionTimeMs
) {
    public Vector<String> getColumnVector() {
        return new Vector<>(columnNames);
    }

    public Vector<Vector<Object>> getDataVector() {
        Vector<Vector<Object>> data = new Vector<>();
        for (Object[] r : rows) {
            Vector<Object> row = new Vector<>();
            for (Object o : r) {
                row.add(o == null ? "NULL" : o);
            }
            data.add(row);
        }
        return data;
    }
}
