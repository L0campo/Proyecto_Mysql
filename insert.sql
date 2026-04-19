use proyecto;



-- Sedes
INSERT INTO sedes (nombre_sede, ubicacion, capacidad_almacenamiento, encargado) VALUES 
('Sede Norte', 'Calle 100 #15-20', 5000, 'Juan Pérez'),
('Sede Sur', 'Avenida Central 45', 3000, 'María García');

-- Clientes
INSERT INTO clientes (nombre_c, identificacion, direccion, telefono, correo) VALUES 
('Empresa Logística S.A.', '900.123.456-1', 'Zona Industrial Nave 4', '555-0101', 'contacto@logistica.com'),
('Carlos Restrepo', '10203040', 'Carrera 10 #5-12', '555-0202', 'carlos.res@email.com');


-- Productos
INSERT INTO productos (nombre, categoria, precio, volumen_ml, stock_actual, stock_min) VALUES 
('Limpiador Multiusos', 'Limpieza', 15.50, 500, 100, 20),
('Detergente Líquido', 'Limpieza', 25.00, 1000, 50, 10),
('Desinfectante Spray', 'Hogar', 12.99, 250, 200, 50);

-- Auditoría (Registro inicial de precios)
INSERT INTO auditoria_precios (id_producto, precio_anterior, precio_nuevo) VALUES 
(1, 0.00, 15.50),
(2, 0.00, 25.00),
(3, 0.00, 12.99);



-- Pedidos
INSERT INTO pedidos (fecha_pedido, id_cliente, id_sede, total_sin_iva, total_con_iva) VALUES 
('2026-04-16', 1, 1, 40.50, 48.20),
('2026-04-17', 2, 2, 25.98, 30.92);

-- Detalle de Pedido (Productos comprados en cada pedido)
INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, subtotal) VALUES 
(1, 1, 1, 15.50), -- 1 Limpiador
(1, 2, 1, 25.00), -- 1 Detergente
(2, 3, 2, 25.98); -- 2 Desinfectantes




SELECT 
    p.id_pedido, 
    c.nombre_c AS cliente, 
    pr.nombre AS producto, 
    dp.cantidad, 
    dp.subtotal,
    s.nombre_sede AS sede
FROM pedidos p
JOIN clientes c ON p.id_cliente = c.id_cliente
JOIN detalle_pedido dp ON p.id_pedido = dp.id_pedido
JOIN productos pr ON dp.id_producto = pr.id_producto
JOIN sedes s ON p.id_sede = s.id_sede;

