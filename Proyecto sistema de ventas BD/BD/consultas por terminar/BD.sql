drop database if exists sistema_ventas;
CREATE DATABASE IF NOT EXISTS sistema_ventas CHARACTER SET utf8mb4;
USE sistema_ventas;

CREATE TABLE categoria (
  idcategoria INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  descripcion TEXT
);

CREATE TABLE producto (
  idproducto INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  descripcion TEXT,
  precio DECIMAL(10,2) NOT NULL,
  stock INT NOT NULL DEFAULT 0,
  idcategoria INT,
  FOREIGN KEY (idcategoria) REFERENCES categoria(idcategoria)
    ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE cliente (
  dni VARCHAR(8) PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  direccion VARCHAR(255),
  fecha_nacimiento DATE,
  telefono VARCHAR(20),
  correo VARCHAR(100)
);

CREATE TABLE vendedor (
  idVendedor INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  usuario VARCHAR(50) NOT NULL UNIQUE,
  contrasena_hash VARCHAR(255) NOT NULL,
  direccion VARCHAR(255), telefono VARCHAR(20), correo VARCHAR(100)
);

CREATE TABLE venta (
  idventa INT AUTO_INCREMENT PRIMARY KEY,
  fecha DATETIME NOT NULL,
  dniCliente VARCHAR(8),
  idVendedor INT,
  total DECIMAL(10,2) NOT NULL DEFAULT 0,
  FOREIGN KEY (dniCliente) REFERENCES cliente(dni)
    ON DELETE SET NULL ON UPDATE CASCADE,
  FOREIGN KEY (idVendedor) REFERENCES vendedor(idVendedor)
    ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE detalle_venta (
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
);

CREATE TABLE asistencia (
  id INT AUTO_INCREMENT PRIMARY KEY,
  idVendedor INT,
  login_ts DATETIME NOT NULL,
  FOREIGN KEY (idVendedor) REFERENCES vendedor(idVendedor) ON DELETE SET NULL
);