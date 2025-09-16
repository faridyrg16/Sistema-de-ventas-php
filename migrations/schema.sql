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
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS cliente (
  dni VARCHAR(8) PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  direccion VARCHAR(255),
  fecha_nacimiento DATE,
  telefono VARCHAR(20),
  correo VARCHAR(100)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS vendedor (
  idVendedor INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  usuario VARCHAR(50) NOT NULL UNIQUE,
  contrasena_hash VARCHAR(255) NOT NULL,
  rol ENUM('ADMIN','VENDEDOR') NOT NULL DEFAULT 'VENDEDOR'
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
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS detalle_venta (
  iddetalle INT AUTO_INCREMENT PRIMARY KEY,
  idventa INT NOT NULL,
  idproducto INT,
  cantidad INT NOT NULL,
  precio_unitario DECIMAL(10,2) NOT NULL,
  subtotal DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (idventa) REFERENCES venta(idventa)
    ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (idproducto) REFERENCES producto(idproducto)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS asistencia (
  id INT AUTO_INCREMENT PRIMARY KEY,
  idVendedor INT,
  login_ts DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (idVendedor) REFERENCES vendedor(idVendedor) ON DELETE SET NULL
) ENGINE=InnoDB;
DROP VIEW IF EXISTS vw_ventas_por_vendedor_mes;
CREATE VIEW vw_ventas_por_vendedor_mes AS
SELECT v.idVendedor, ve.nombre AS vendedor, DATE_FORMAT(v.fecha, '%Y-%m') AS periodo,
       SUM(v.total) AS total_mes, COUNT(*) AS num_ventas
FROM venta v LEFT JOIN vendedor ve ON ve.idVendedor = v.idVendedor
GROUP BY v.idVendedor, periodo;
DROP VIEW IF EXISTS vw_top_productos;
CREATE VIEW vw_top_productos AS
SELECT p.idproducto, p.nombre, SUM(d.cantidad) AS total_cantidad, SUM(d.subtotal) AS total_ventas
FROM detalle_venta d LEFT JOIN producto p ON p.idproducto = d.idproducto
GROUP BY p.idproducto ORDER BY total_cantidad DESC;
