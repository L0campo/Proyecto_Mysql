

DELIMITER $$

CREATE FUNCTION calcular_promedio_pedidos_cliente(p_id_cliente INT)
RETURNS DECIMAL(12, 2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_promedio DECIMAL(12, 2) DEFAULT 0;

    SELECT COALESCE(AVG(total_sin_iva), 0)
    INTO   v_promedio
    FROM   pedidos
    WHERE  id_cliente = p_id_cliente;

    RETURN ROUND(v_promedio, 2);
END$$

DELIMITER ;


SELECT calcular_promedio_pedidos_cliente(1)  AS promedio_cliente_1;
SELECT calcular_promedio_pedidos_cliente(999) AS promedio_cliente_inexistente; 


CREATE OR REPLACE VIEW vista_resumen_sedes AS
SELECT
    s.nombre_sede,
    COUNT(p.id_pedido)                    AS total_pedidos,
    COALESCE(SUM(p.total_sin_iva),  0)    AS valor_total_sin_iva,
    COALESCE(AVG(p.total_sin_iva),  0)    AS promedio_por_pedido
FROM sedes s
LEFT JOIN pedidos p ON p.id_sede = s.id_sede
GROUP BY
    s.id_sede,
    s.nombre_sede;


SELECT * FROM vista_resumen_sedes
ORDER BY valor_total_sin_iva DESC;


CREATE OR REPLACE VIEW vista_resumen_sedes AS
SELECT
    s.nombre_sede,
    COUNT(p.id_pedido)                    AS total_pedidos,
    COALESCE(SUM(p.total_sin_iva),  0)    AS valor_total_sin_iva,
    COALESCE(AVG(p.total_sin_iva),  0)    AS promedio_por_pedido
FROM sedes s
LEFT JOIN pedidos p ON p.id_sede = s.id_sede
GROUP BY
    s.id_sede,
    s.nombre_sede;


SELECT * FROM vista_resumen_sedes
ORDER BY valor_total_sin_iva DESC;



SELECT
    nombre,
    categoria,
    stock_actual                      AS stock,
    precio,
    (SELECT ROUND(AVG(precio), 2)
     FROM productos)                  AS precio_promedio_general
FROM productos
WHERE precio > (
    SELECT AVG(precio)
    FROM productos
)
ORDER BY precio DESC;


CREATE TABLE IF NOT EXISTS auditoria_precios (
    id_auditoria       INT          NOT NULL AUTO_INCREMENT,
    id_producto        INT          NOT NULL,
    precio_anterior    DECIMAL(10,2) NOT NULL,
    precio_nuevo       DECIMAL(10,2) NOT NULL,
    fecha_modificacion DATETIME     NOT NULL,

    CONSTRAINT pk_auditoria PRIMARY KEY (id_auditoria)
);

DELIMITER $$

CREATE TRIGGER auditar_cambio_precio
AFTER UPDATE ON productos
FOR EACH ROW
BEGIN
    IF OLD.precio <> NEW.precio THEN
        INSERT INTO auditoria_precios (
            id_producto,
            precio_anterior,
            precio_nuevo,
            fecha_modificacion
        )
        VALUES (
            OLD.id_producto,
            OLD.precio,
            NEW.precio,
            NOW()
        );
    END IF;
END$$

DELIMITER ;

UPDATE productos SET precio = 3500.00 WHERE id_producto = 1;  
UPDATE productos SET nombre = 'Pepsi 350ml' WHERE id_producto = 1; -

SELECT * FROM auditoria_precios ORDER BY fecha_modificacion DESC;