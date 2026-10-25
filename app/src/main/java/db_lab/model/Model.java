package db_lab.model;

import db_lab.data.Product;
import db_lab.data.ProductPreview;
import java.sql.Connection;
import java.util.List;
import java.util.Optional;

public interface Model {
    Optional<Product> find(int productCode);

    List<ProductPreview> previews();

    boolean loadedPreviews();

    List<ProductPreview> loadPreviews();

    // Create a mocked version of the model.
    //
    static Model mock() {
        return new MockedModel();
    }

    // Create a model that connects to a database using the given connection.
    //
    static Model fromConnection(Connection connection) {
        return new DBModel(connection);
    }
}
