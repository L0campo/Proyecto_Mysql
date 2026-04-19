DELIMITER $$

CREATE TRIGGER tr_actualizar_stock
AFTER INSERT ON detalle_pedido
FOR EACH ROW
BEGIN
    DECLARE v_stock_actual INT DEFAULT 0;

    -- Leer stock actual del producto afectado
    SELECT stock_actual
    INTO   v_stock_actual
    FROM   productos
    WHERE  id_producto = NEW.id_producto;

    -- Bloquear si no hay stock suficiente
    IF v_stock_actual < NEW.cantidad THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock insuficiente para confirmar el pedido.';
    END IF;

    -- Descontar la cantidad vendida
    UPDATE productos
    SET    stock_actual = stock_actual - NEW.cantidad
    WHERE  id_producto  = NEW.id_producto;
END$$

DELIMITER ;




DELIMITER $$

CREATE TRIGGER tr_auditar_cambio_precio
BEFORE UPDATE ON productos
FOR EACH ROW
BEGIN
    -- Solo actuar si el precio realmente cambió
    IF OLD.precio <> NEW.precio THEN
        INSERT INTO auditoria_precios (
            id_producto,
            precio_anterior,
            precio_nuevo,
            fecha_cambio
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