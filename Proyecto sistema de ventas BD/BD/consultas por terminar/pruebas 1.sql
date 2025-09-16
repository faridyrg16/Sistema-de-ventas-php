CREATE DATABASE IF NOT EXISTS sistema_ventas CHARACTER SET utf8mb4;
USE sistema_ventas;

CREATE TABLE IF NOT EXISTS categoria (
  idcategoria INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  descripcion TEXT,
  UNIQUE KEY uk_categoria_nombre (nombre)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS producto (
  idproducto INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  descripcion TEXT,
  precio DECIMAL(10,2) NOT NULL,
  stock INT NOT NULL DEFAULT 0,
  idcategoria INT,
  FOREIGN KEY (idcategoria) REFERENCES categoria(idcategoria)
    ON DELETE SET NULL ON UPDATE CASCADE,
  KEY idx_producto_nombre (nombre),
  KEY idx_producto_categoria (idcategoria)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS cliente (
  dni VARCHAR(8) PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  direccion VARCHAR(255),
  fecha_nacimiento DATE,
  telefono VARCHAR(20),
  correo VARCHAR(100),
  KEY idx_cliente_nombre (nombre)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS vendedor (
  idVendedor INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  usuario VARCHAR(50) NOT NULL UNIQUE,
  contrasena_hash VARCHAR(255) NOT NULL,
  direccion VARCHAR(255),
  telefono VARCHAR(20),
  correo VARCHAR(100)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS venta (
  idventa INT AUTO_INCREMENT PRIMARY KEY,
  fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dniCliente VARCHAR(8),
  idVendedor INT,
  total DECIMAL(10,2) NOT NULL DEFAULT 0,
  FOREIGN KEY (dniCliente) REFERENCES cliente(dni)
    ON DELETE SET NULL ON UPDATE CASCADE,
  FOREIGN KEY (idVendedor) REFERENCES vendedor(idVendedor)
    ON DELETE SET NULL ON UPDATE CASCADE,
  KEY idx_venta_fecha (fecha),
  KEY idx_venta_vendedor (idVendedor)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS detalle_venta (
  iddetalle INT AUTO_INCREMENT PRIMARY KEY,
  idventa INT NOT NULL,
  idproducto INT,
  cantidad INT NOT NULL CHECK (cantidad > 0),
  precio_unitario DECIMAL(10,2) NOT NULL CHECK (precio_unitario >= 0),
  subtotal DECIMAL(10,2) AS (cantidad * precio_unitario) STORED,
  FOREIGN KEY (idventa) REFERENCES venta(idventa)
    ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (idproducto) REFERENCES producto(idproducto)
    ON DELETE SET NULL ON UPDATE CASCADE,
  KEY idx_detalle_venta (idventa),
  KEY idx_detalle_producto (idproducto)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS asistencia (
  id INT AUTO_INCREMENT PRIMARY KEY,
  idVendedor INT,
  login_ts DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (idVendedor) REFERENCES vendedor(idVendedor) ON DELETE SET NULL,
  KEY idx_asistencia_vendedor (idVendedor),
  KEY idx_asistencia_login (login_ts)
) ENGINE=InnoDB;

INSERT IGNORE INTO categoria (idcategoria, nombre, descripcion) VALUES
  (1,'General','Categoría por defecto'),
  (2,'Bebidas','Líquidos'),
  (3,'Snacks','Aperitivos');

INSERT IGNORE INTO producto (idproducto, nombre, descripcion, precio, stock, idcategoria) VALUES
  (1,'Gaseosa 500ml','Bebida gaseosa',3.50,100,2),
  (2,'Galletas','Paquete galletas',2.20,200,3);

INSERT IGNORE INTO cliente (dni, nombre, direccion, telefono, correo) VALUES
  ('00000000','Publico General','', '', ''),
  ('72748152','Farid Yasser Romero Grabiel','Cusco', '925609206', 'farid@gmail.com');

--Usuario admin
--Nota:En producción usa password_hash().
INSERT IGNORE INTO vendedor (idVendedor, nombre, usuario, contrasena_hash, direccion, telefono, correo) VALUES
  (1,'Administrador','admin', SHA2('admin',256), '', '', '');

--reportes
DROP VIEW IF EXISTS vw_ventas_por_vendedor_mes;
CREATE VIEW vw_ventas_por_vendedor_mes AS
SELECT v.idVendedor,
       ve.nombre AS vendedor,
       DATE_FORMAT(v.fecha, '%Y-%m') AS periodo,
       SUM(v.total) AS total_mes,
       COUNT(*) AS num_ventas
FROM venta v
LEFT JOIN vendedor ve ON ve.idVendedor = v.idVendedor
GROUP BY v.idVendedor, periodo;

DROP VIEW IF EXISTS vw_top_productos;
CREATE VIEW vw_top_productos AS
SELECT p.idproducto, p.nombre,
       SUM(d.cantidad) AS total_cantidad,
       SUM(d.cantidad * d.precio_unitario) AS total_ventas
FROM detalle_venta d
LEFT JOIN producto p ON p.idproducto = d.idproducto
GROUP BY p.idproducto
ORDER BY total_cantidad DESC;

--Venta de prueba
START TRANSACTION;

INSERT INTO venta (dniCliente, idVendedor, total)
VALUES ('00000000', 1, 0);

SET @vid := LAST_INSERT_ID();

INSERT INTO detalle_venta (idventa, idproducto, cantidad, precio_unitario)
VALUES (@vid, 1, 2, 3.50);

UPDATE producto
SET stock = stock - 2
WHERE idproducto = 1;

UPDATE venta
SET total = (
  SELECT SUM(cantidad * precio_unitario)
  FROM detalle_venta
  WHERE idventa = @vid
)
WHERE idventa = @vid;

ALTER TABLE producto
ADD CONSTRAINT chk_stock CHECK (stock >= 0);

--Reporte
SELECT * FROM vw_ventas_por_vendedor_mes ORDER BY periodo DESC LIMIT 5;
SELECT * FROM vw_top_productos LIMIT 5;
SELECT idproducto, nombre, stock FROM producto ORDER BY idproducto;

--validacion ed stock
CREATE TRIGGER trg_validar_stock
BEFORE INSERT ON detalle_venta
FOR EACH ROW
BEGIN
  DECLARE disponible INT;
  SELECT stock INTO disponible FROM producto WHERE idproducto = NEW.idproducto;
  IF disponible < NEW.cantidad THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Stock insuficiente para este producto';
  END IF;
END;
