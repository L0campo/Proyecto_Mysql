use proyecto;




DELIMITER $$

CREATE FUNCTION fn_calcular_total_con_iva(p_id_pedido INT)
RETURNS DECIMAL(10, 2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_subtotal DECIMAL(10, 2) DEFAULT 0;
    DECLARE v_total_con_iva DECIMAL(10, 2) DEFAULT 0;

    -- Sumar todos los subtotales del pedido
    SELECT COALESCE(SUM(subtotal), 0)
    INTO   v_subtotal
    FROM   detalle_pedido
    WHERE  id_pedido = p_id_pedido;

    -- Aplicar IVA del 19%
    SET v_total_con_iva = v_subtotal * 1.19;

    RETURN ROUND(v_total_con_iva, 2);
END$$

DELIMITER ;


-- Llamado directo
SELECT fn_calcular_total_con_iva(1) AS total_con_iva;

-- Comparar contra el valor guardado en pedidos
SELECT
    p.id_pedido,
    p.total_sin_iva,
    p.total_con_iva                    AS total_guardado,
    fn_calcular_total_con_iva(p.id_pedido) AS total_calculado
FROM pedidos p;

-- Verificar que la funciÃ³n existe
SHOW FUNCTION STATUS WHERE Name = 'fn_calcular_total_con_iva';




DELIMITER $$

CREATE FUNCTION fn_validar_stock(p_id_producto INT, p_cantidad INT)
RETURNS VARCHAR(100)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_stock_actual  INT DEFAULT 0;
    DECLARE v_stock_minimo  INT DEFAULT 0;
    DECLARE v_nombre        VARCHAR(100) DEFAULT '';

    -- Leer estado actual del producto
    SELECT stock_actual, stock_minimo, nombre
    INTO   v_stock_actual, v_stock_minimo, v_nombre
    FROM   productos
    WHERE  id_producto = p_id_producto;

    -- Producto no encontrado
    IF v_nombre = '' THEN
        RETURN 'ERROR: producto no encontrado.';
    END IF;

    -- Cantidad solicitada inválida
    IF p_cantidad <= 0 THEN
        RETURN 'ERROR: la cantidad debe ser mayor a cero.';
    END IF;

    -- Stock insuficiente
    IF v_stock_actual < p_cantidad THEN
        RETURN CONCAT(
            'SIN STOCK: "', v_nombre, '" tiene ',
            v_stock_actual, ' unidades disponibles, ',
            'se solicitaron ', p_cantidad, '.'
        );
    END IF;

    -- Stock disponible pero quedaría bajo el mínimo
    IF (v_stock_actual - p_cantidad) < v_stock_minimo THEN
        RETURN CONCAT(
            'ALERTA: "', v_nombre, '" disponible, ',
            'pero el stock quedará en ', (v_stock_actual - p_cantidad),
            ' (mínimo: ', v_stock_minimo, ').'
        );
    END IF;

    -- Todo en orden
    RETURN CONCAT(
        'OK: "', v_nombre, '" disponible. ',
        'Stock actual: ', v_stock_actual,
        ', quedarán ', (v_stock_actual - p_cantidad), ' unidades.'
    );
END$$

DELIMITER ;