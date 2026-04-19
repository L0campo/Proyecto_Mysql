use proyecto;

-- Tabla de Sedes
CREATE TABLE sedes (
    id_sede INT AUTO_INCREMENT PRIMARY KEY,
    nombre_sede VARCHAR(250) NOT NULL,
    ubicacion VARCHAR(250),
    capacidad_almacenamiento INT,
    encargado VARCHAR(255)
);

-- Tabla de Clientes
CREATE TABLE clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre_c VARCHAR(100) NOT NULL,
    identificacion VARCHAR(50) UNIQUE NOT NULL,
    direccion TEXT, -- Cambiado a TEXT porque 'int' en tu imagen suele ser un error para direcciones
    telefono VARCHAR(14),
    correo VARCHAR(50)
);

-- Tabla de Productos
CREATE TABLE productos (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    categoria VARCHAR(100),
    precio DECIMAL(10,2) NOT NULL,
    volumen_ml INT,
    stock_actual INT DEFAULT 0,
    stock_min INT DEFAULT 0
);


-- Tabla de Auditoría (Depende de productos)
CREATE TABLE auditoria_precios (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT,
    precio_anterior DECIMAL(10,2),
    precio_nuevo DECIMAL(10,2),
    fecha_cambio DATETIME DEFAULT CURRENT_TIMESTAMP, -- Cambiado de decimal a datetime por lógica
    CONSTRAINT fk_auditoria_producto FOREIGN KEY (id_producto) 
        REFERENCES productos(id_producto) ON DELETE CASCADE
);

-- Tabla de Pedidos (Depende de clientes y sedes)
CREATE TABLE pedidos (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    fecha_pedido DATE NOT NULL,
    id_cliente INT,
    id_sede INT,
    total_sin_iva DECIMAL(10,2),
    total_con_iva DECIMAL(10,2),
    CONSTRAINT fk_pedido_cliente FOREIGN KEY (id_cliente) 
        REFERENCES clientes(id_cliente),
    CONSTRAINT fk_pedido_sede FOREIGN KEY (id_sede) 
        REFERENCES sedes(id_sede)
);

-- Tabla Detalle de Pedido (Relación N a N entre productos y pedidos)
CREATE TABLE detalle_pedido (
    id_pedido INT,
    id_producto INT,
    cantidad INT NOT NULL,
    subtotal DECIMAL(10,2),
    PRIMARY KEY (id_pedido, id_producto), -- Llave primaria compuesta
    CONSTRAINT fk_detalle_pedido FOREIGN KEY (id_pedido) 
        REFERENCES pedidos(id_pedido) ON DELETE CASCADE,
    CONSTRAINT fk_detalle_producto FOREIGN KEY (id_producto) 
        REFERENCES productos(id_producto)
);
