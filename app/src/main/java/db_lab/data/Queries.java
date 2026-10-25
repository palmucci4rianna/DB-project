package db_lab.data;

public final class Queries {

    public static final String TAGS_FOR_PRODUCT =
        """
        SELECT t.name
        FROM TAG t
        JOIN TAGGED tg ON tg.tag_name = t.name
        WHERE tg.product_code = ?
        """;

    public static final String LIST_PRODUCTS =
        """
        SELECT code, name, description
        FROM PRODUCT
        ORDER BY name
        """;

    public static final String PRODUCT_COMPOSITION =
        """
        SELECT m.code, m.description, c.percent
        FROM COMPOSITION c
        JOIN MATERIAL m ON m.code = c.material_code
        WHERE c.product_code = ?
        ORDER BY m.description
        """;

    public static final String FIND_PRODUCT =
        """
        SELECT code, name, description
        FROM PRODUCT
        WHERE name LIKE ?
        ORDER BY name
        """;
}
