-- 1) Crear BD limpia
DROP DATABASE IF EXISTS sistema_ventas;
CREATE DATABASE sistema_ventas CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE sistema_ventas;

-- 2) Catálogo básico
CREATE TABLE categoria (
  idcategoria INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  descripcion TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO categoria (idcategoria, nombre, descripcion) VALUES
(1,'General','Categoría por defecto'),
(2,'Bebidas','Líquidos'),
(3,'Snacks','Aperitivos');

CREATE TABLE cliente (
  dni VARCHAR(8) PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  direccion VARCHAR(255),
  fecha_nacimiento DATE,
  telefono VARCHAR(20),
  correo VARCHAR(100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO cliente (dni, nombre, direccion, fecha_nacimiento, telefono, correo) VALUES
('00000000','Publico General','',NULL,'',''),
('11111111','Cliente Uno',NULL,NULL,NULL,NULL),
('12345678','yesica|',NULL,NULL,'9999999',''),
('22222222','Cliente Dos',NULL,NULL,NULL,NULL),
('33333333','Cliente Tres',NULL,NULL,NULL,NULL),
('72748152','Farid Romero','Cusco',NULL,'999999999','farid@example.com');

CREATE TABLE vendedor (
  idVendedor INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  usuario VARCHAR(50) NOT NULL,
  contrasena_hash VARCHAR(255) NOT NULL,
  direccion VARCHAR(255),
  telefono VARCHAR(20),
  correo VARCHAR(100),
  rol ENUM('ADMIN','VENDEDOR') NOT NULL DEFAULT 'VENDEDOR',
  UNIQUE KEY ux_usuario (usuario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO vendedor (idVendedor,nombre,usuario,contrasena_hash,direccion,telefono,correo,rol) VALUES
(1,'Administrador','admin','$2y$10$S4v7D2SNBgoVG0wC6SqieeUShwgtk.sLnJQECL9arC45NU45LLhFS','','','','ADMIN'),
(2,'Ana Pérez','ana','$2y$10$YcTy27/Ky4BZRephyhRfYufYKMpz/SNPoKQx0CDgEo1byK5YlQ/c.',NULL,NULL,NULL,'VENDEDOR'),
(3,'Carlos Díaz','carlos','$2y$10$swvlI3wvwRmqf729qQ9oju.tfyLUV03a/l50K7uAaT2RgIuq9q5.K',NULL,NULL,NULL,'VENDEDOR');

-- 3) PRODUCTO
CREATE TABLE producto (
  idproducto INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  descripcion TEXT,
  precio DECIMAL(10,2) NOT NULL,
  stock INT NOT NULL DEFAULT 0,
  idcategoria INT,
  CONSTRAINT fk_producto_categoria
    FOREIGN KEY (idcategoria) REFERENCES categoria(idcategoria)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT chk_stock CHECK (stock >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO producto (idproducto,nombre,descripcion,precio,stock,idcategoria) VALUES
(1,'Gaseosa 500ml','Bebida gaseosa',3.50,95,2),
(2,'Galletas','Paquete galletas',2.20,200,3),
(3,'Agua Mineral 600ml',NULL,2.50,256,2),
(4,'Chocolatina',NULL,1.80,100,3),
(5,'Papas Fritas 200g',NULL,3.00,57,3);

-- 4) VENTA / DETALLE
CREATE TABLE venta (
  idventa INT AUTO_INCREMENT PRIMARY KEY,
  fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dniCliente VARCHAR(8),
  idVendedor INT,
  total DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  KEY ix_venta_cliente (dniCliente),
  KEY ix_venta_vendedor (idVendedor),
  CONSTRAINT fk_venta_cliente
    FOREIGN KEY (dniCliente) REFERENCES cliente(dni)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_venta_vendedor
    FOREIGN KEY (idVendedor) REFERENCES vendedor(idVendedor)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE detalle_venta (
  iddetalle INT AUTO_INCREMENT PRIMARY KEY,
  idventa INT NOT NULL,
  idproducto INT,
  cantidad INT NOT NULL,
  precio_unitario DECIMAL(10,2) NOT NULL,
  subtotal DECIMAL(10,2) NOT NULL,
  KEY ix_det_venta (idventa),
  KEY ix_det_producto (idproducto),
  CONSTRAINT fk_detalle_venta_venta
    FOREIGN KEY (idventa) REFERENCES venta(idventa)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_detalle_venta_producto
    FOREIGN KEY (idproducto) REFERENCES producto(idproducto)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DELIMITER ;;
CREATE TRIGGER trg_validar_stock
BEFORE INSERT ON detalle_venta
FOR EACH ROW
BEGIN
  DECLARE disponible INT;
  IF NEW.idproducto IS NOT NULL THEN
    SELECT stock INTO disponible FROM producto WHERE idproducto = NEW.idproducto;
    IF disponible < NEW.cantidad THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente para este producto';
    END IF;
  END IF;
END;;
DELIMITER ;

-- 5) MOVIMIENTO ALMACÉN (opcional si lo usas)
CREATE TABLE movimiento_almacen (
  id INT AUTO_INCREMENT PRIMARY KEY,
  fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  idproducto INT NOT NULL,
  tipo ENUM('INGRESO','SALIDA') NOT NULL,
  cantidad INT NOT NULL,
  motivo VARCHAR(255),
  idVendedor INT,
  KEY ix_mov_prod_fecha (idproducto, fecha),
  CONSTRAINT fk_mov_prod FOREIGN KEY (idproducto) REFERENCES producto(idproducto) ON UPDATE CASCADE,
  CONSTRAINT fk_mov_vend FOREIGN KEY (idVendedor) REFERENCES vendedor(idVendedor) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DELIMITER ;;
CREATE TRIGGER trg_no_stock_negativo_salida
BEFORE INSERT ON movimiento_almacen
FOR EACH ROW
BEGIN
  DECLARE disp INT;
  IF NEW.tipo = 'SALIDA' THEN
    SELECT stock INTO disp FROM producto WHERE idproducto = NEW.idproducto FOR UPDATE;
    IF disp < NEW.cantidad THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente (trigger)';
    END IF;
  END IF;
END;;
DELIMITER ;

-- 6) ASISTENCIA (la pieza que falta)
CREATE TABLE asistencia (
  id INT AUTO_INCREMENT PRIMARY KEY,
  idVendedor INT NULL,
  login_ts DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  login_date DATE GENERATED ALWAYS AS (CAST(login_ts AS DATE)) STORED,
  UNIQUE KEY ux_asistencia_user_day (idVendedor, login_date),
  CONSTRAINT fk_asistencia_vendedor
    FOREIGN KEY (idVendedor) REFERENCES vendedor(idVendedor)
    ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- (Semilla válida —sin '0000-00-00')
INSERT INTO asistencia (idVendedor, login_ts) VALUES
(1, '2025-09-15 12:48:02'),
(1, '2025-09-16 09:10:49);