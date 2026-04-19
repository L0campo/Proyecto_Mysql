-- ------------------------------------------------------------
-- Vista 1: vista_resumen_pedidos_por_sede
-- Cantidad total de pedidos y ventas agrupadas por sede
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vista_resumen_pedidos_por_sede AS
SELECT
    s.id_sede,
    s.nombre_sede,
    s.ubicacion,
    s.encargado,
    COUNT(p.id_pedido)          AS total_pedidos,
    COALESCE(SUM(p.total_sin_iva), 0) AS ventas_sin_iva,
    COALESCE(SUM(p.total_con_iva), 0) AS ventas_con_iva,
    COALESCE(AVG(p.total_con_iva), 0) AS ticket_promedio
FROM sedes s
LEFT JOIN pedidos p ON p.id_sede = s.id_sede
GROUP BY
    s.id_sede,
    s.nombre_sede,
    s.ubicacion,
    s.encargado;


-- ------------------------------------------------------------
-- Vista 2: vista_productos_bajo_stock
-- Productos con stock_actual <= stock_minimo
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vista_productos_bajo_stock AS
SELECT
    p.id_producto,
    p.nombre,
    p.categoria,
    p.precio,
    p.stock_actual,
    p.stock_minimo,
    p.stock_minimo - p.stock_actual   AS unidades_faltantes,
    CASE
        WHEN p.stock_actual = 0            THEN 'Agotado'
        WHEN p.stock_actual < p.stock_minimo THEN 'Crítico'
        ELSE                                    'En mínimo'
    END                                   AS estado_stock
FROM productos p
WHERE p.stock_actual <= p.stock_minimo;


-- ------------------------------------------------------------
-- Vista 3: vista_clientes_activos
-- Clientes con al menos un pedido registrado
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vista_clientes_activos AS
SELECT
    c.id_cliente,
    c.nombre_completo,
    c.identificacion,
    c.telefono,
    c.correo_electronico,
    COUNT(p.id_pedido)              AS total_pedidos,
    MIN(p.fecha_pedido)             AS primer_pedido,
    MAX(p.fecha_pedido)             AS ultimo_pedido,
    COALESCE(SUM(p.total_con_iva), 0) AS total_comprado
FROM clientes c
INNER JOIN pedidos p ON p.id_cliente = c.id_cliente
GROUP BY
    c.id_cliente,
    c.nombre_completo,
    c.identificacion,
    c.telefono,
    c.correo_electronico;