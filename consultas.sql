-- ------------------------------------------------------------
-- Consulta 1: Productos con stock por debajo del mínimo
-- Operador: WHERE con comparación directa
-- ------------------------------------------------------------
SELECT
    id_producto,
    nombre,
    categoria,
    stock_actual,
    stock_minimo,
    stock_minimo - stock_actual AS unidades_faltantes
FROM productos
WHERE stock_actual < stock_minimo
ORDER BY unidades_faltantes DESC;


-- ------------------------------------------------------------
-- Consulta 2: Pedidos realizados entre dos fechas
-- Operador: BETWEEN (ambos extremos son inclusivos)
-- ------------------------------------------------------------
SELECT
    p.id_pedido,
    p.fecha_pedido,
    c.nombre_completo   AS cliente,
    s.nombre_sede       AS sede,
    p.total_sin_iva,
    p.total_con_iva
FROM pedidos p
JOIN clientes c ON c.id_cliente = p.id_cliente
JOIN sedes    s ON s.id_sede    = p.id_sede
WHERE p.fecha_pedido BETWEEN '2024-01-01' AND '2024-12-31'
ORDER BY p.fecha_pedido ASC;


-- ------------------------------------------------------------
-- Consulta 3: Búsqueda de clientes por nombre parcial
-- Operador: LIKE con comodín %
-- ------------------------------------------------------------
SELECT
    id_cliente,
    nombre_completo,
    identificacion,
    telefono,
    correo_electronico
FROM clientes
WHERE nombre_completo LIKE '%García%'
ORDER BY nombre_completo ASC;


-- ------------------------------------------------------------
-- Consulta 4: Productos de ciertas categorías
-- Operador: IN con lista de valores
-- ------------------------------------------------------------
SELECT
    id_producto,
    nombre,
    categoria,
    precio,
    volumen_ml,
    stock_actual
FROM productos
WHERE categoria IN ('Gaseosa', 'Agua', 'Jugo')
ORDER BY categoria ASC, precio ASC;

-- BETWEEN con rango de precios en lugar de fechas
SELECT nombre, categoria, precio
FROM productos
WHERE precio BETWEEN 1500.00 AND 5000.00
ORDER BY precio ASC;

-- LIKE insensible a tildes: buscar tanto 'Garcia' como 'García'
SELECT nombre_completo
FROM clientes
WHERE nombre_completo LIKE '%garcia%'
   OR nombre_completo LIKE '%garcía%';

-- IN con subconsulta dinámica en lugar de lista fija
SELECT nombre, categoria, precio
FROM productos
WHERE categoria IN (
    SELECT DISTINCT categoria
    FROM productos
    WHERE stock_actual > 0
);

-- NOT IN: productos que NO son de esas categorías
SELECT nombre, categoria
FROM productos
WHERE categoria NOT IN ('Gaseosa', 'Agua', 'Jugo')
ORDER BY categoria;


-- ------------------------------------------------------------
-- Consulta 5: Productos más vendidos
-- Técnica: JOIN + GROUP BY + ORDER BY con agregación
-- ------------------------------------------------------------
SELECT
    pr.id_producto,
    pr.nombre,
    pr.categoria,
    pr.precio,
    SUM(dp.cantidad)                    AS unidades_vendidas,
    SUM(dp.subtotal)                    AS ingresos_generados,
    COUNT(DISTINCT dp.id_pedido)        AS pedidos_en_que_aparece
FROM productos pr
JOIN detalle_pedido dp ON dp.id_producto = pr.id_producto
GROUP BY
    pr.id_producto,
    pr.nombre,
    pr.categoria,
    pr.precio
ORDER BY unidades_vendidas DESC
LIMIT 10;


-- ------------------------------------------------------------
-- Consulta 6: Clientes y cantidad de pedidos realizados
-- Técnica: LEFT JOIN + GROUP BY para incluir clientes sin pedidos
-- ------------------------------------------------------------
SELECT
    c.id_cliente,
    c.nombre_completo,
    c.telefono,
    c.correo_electronico,
    COUNT(p.id_pedido)                  AS total_pedidos,
    COALESCE(SUM(p.total_con_iva), 0)   AS total_gastado,
    COALESCE(MAX(p.fecha_pedido), '—')  AS ultimo_pedido
FROM clientes c
LEFT JOIN pedidos p ON p.id_cliente = c.id_cliente
GROUP BY
    c.id_cliente,
    c.nombre_completo,
    c.telefono,
    c.correo_electronico
ORDER BY total_pedidos DESC;


-- ------------------------------------------------------------
-- Consulta 7: Cliente con mayor número de pedidos
-- Técnica: subconsulta en WHERE con MAX sobre COUNT
-- ------------------------------------------------------------
SELECT
    c.id_cliente,
    c.nombre_completo,
    c.identificacion,
    c.telefono,
    c.correo_electronico,
    COUNT(p.id_pedido)                AS total_pedidos,
    SUM(p.total_con_iva)              AS total_gastado
FROM clientes c
JOIN pedidos p ON p.id_cliente = c.id_cliente
GROUP BY
    c.id_cliente,
    c.nombre_completo,
    c.identificacion,
    c.telefono,
    c.correo_electronico
HAVING COUNT(p.id_pedido) = (
    SELECT MAX(conteo)
    FROM (
        SELECT COUNT(id_pedido) AS conteo
        FROM pedidos
        GROUP BY id_cliente
    ) AS conteos_por_cliente
)
ORDER BY total_gastado DESC;


-- ------------------------------------------------------------
-- Consulta 8: Pedidos y totales agrupados por sede
-- Técnica: JOIN triple + GROUP BY + ROLLUP para subtotal global
-- ------------------------------------------------------------
SELECT
    COALESCE(s.nombre_sede, '— TOTAL GLOBAL —')  AS sede,
    s.ubicacion,
    COUNT(p.id_pedido)                            AS total_pedidos,
    SUM(p.total_sin_iva)                          AS ventas_sin_iva,
    SUM(p.total_con_iva)                          AS ventas_con_iva,
    AVG(p.total_con_iva)                          AS ticket_promedio,
    MIN(p.fecha_pedido)                           AS primer_pedido,
    MAX(p.fecha_pedido)                           AS ultimo_pedido
FROM sedes s
JOIN pedidos p ON p.id_sede = s.id_sede
GROUP BY s.nombre_sede, s.ubicacion WITH ROLLUP
ORDER BY ventas_con_iva DESC;



-- Productos más vendidos por categoría (JOIN + GROUP BY en dos niveles)
SELECT
    pr.categoria,
    pr.nombre,
    SUM(dp.cantidad)     AS unidades_vendidas
FROM productos pr
JOIN detalle_pedido dp ON dp.id_producto = pr.id_producto
GROUP BY pr.categoria, pr.nombre
ORDER BY pr.categoria ASC, unidades_vendidas DESC;

-- Clientes que compraron más de 3 veces (HAVING como filtro de grupo)
SELECT
    c.nombre_completo,
    COUNT(p.id_pedido)  AS total_pedidos
FROM clientes c
JOIN pedidos p ON p.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nombre_completo
HAVING COUNT(p.id_pedido) > 3
ORDER BY total_pedidos DESC;

-- Ventas por sede y por mes (GROUP BY con función de fecha)
SELECT
    s.nombre_sede,
    DATE_FORMAT(p.fecha_pedido, '%Y-%m')  AS mes,
    COUNT(p.id_pedido)                    AS pedidos_del_mes,
    SUM(p.total_con_iva)                  AS ventas_del_mes
FROM sedes s
JOIN pedidos p ON p.id_sede = s.id_sede
GROUP BY s.nombre_sede, DATE_FORMAT(p.fecha_pedido, '%Y-%m')
ORDER BY s.nombre_sede ASC, mes ASC;