DROP DATABASE IF EXISTS sistema_ventas;
CREATE DATABASE sistema_ventas CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE sistema_ventas;

DROP TABLE IF EXISTS categoria;
CREATE TABLE categoria (
  idcategoria INT AUTO_INCREMENT PRIMARY KEY,
  nombre      VARCHAR(100) NOT NULL,
  descripcion TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO categoria (idcategoria, nombre, descripcion) VALUES
(1,'General','Categoría por defecto'),
(2,'Bebidas','Líquidos'),
(3,'Snacks','Aperitivos');

DROP TABLE IF EXISTS cliente;
CREATE TABLE cliente (
  dni              VARCHAR(8)  PRIMARY KEY,
  nombre           VARCHAR(100) NOT NULL,
  direccion        VARCHAR(255),
  fecha_nacimiento DATE,
  telefono         VARCHAR(20),
  correo           VARCHAR(100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO cliente (dni, nombre, direccion, fecha_nacimiento, telefono, correo) VALUES
('00000000','Publico General','',NULL,'',''),
('11111111','Cliente Uno',NULL,NULL,NULL,NULL),
('12345678','yesica|',NULL,NULL,'9999999',''),
('22222222','Cliente Dos',NULL,NULL,NULL,NULL),
('33333333','Cliente Tres',NULL,NULL,NULL,NULL),
('72748152','Farid Romero','Cusco',NULL,'999999999','farid@example.com');

DROP TABLE IF EXISTS vendedor;
CREATE TABLE vendedor (
  idVendedor      INT AUTO_INCREMENT PRIMARY KEY,
  nombre          VARCHAR(100) NOT NULL,
  usuario         VARCHAR(50)  NOT NULL,
  contrasena_hash VARCHAR(255) NOT NULL,
  direccion       VARCHAR(255),
  telefono        VARCHAR(20),
  correo          VARCHAR(100),
  rol             ENUM('ADMIN','VENDEDOR') NOT NULL DEFAULT 'VENDEDOR',
  UNIQUE KEY ux_usuario (usuario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO vendedor (idVendedor,nombre,usuario,contrasena_hash,direccion,telefono,correo,rol) VALUES
(1,'Administrador','admin','$2y$10$S4v7D2SNBgoVG0wC6SqieeUShwgtk.sLnJQECL9arC45NU45LLhFS','','','','ADMIN'),
(2,'Ana Pérez','ana','$2y$10$YcTy27/Ky4BZRephyhRfYufYKMpz/SNPoKQx0CDgEo1byK5YlQ/c.',NULL,NULL,NULL,'VENDEDOR'),
(3,'Carlos Díaz','carlos','$2y$10$swvlI3wvwRmqf729qQ9oju.tfyLUV03a/l50K7uAaT2RgIuq9q5.K',NULL,NULL,NULL,'VENDEDOR');

DROP TABLE IF EXISTS producto;
CREATE TABLE producto (
  idproducto  INT AUTO_INCREMENT PRIMARY KEY,
  nombre      VARCHAR(100) NOT NULL,
  descripcion TEXT,
  precio      DECIMAL(10,2) NOT NULL,
  stock       INT NOT NULL DEFAULT 0,
  idcategoria INT,
  CONSTRAINT fk_producto_categoria
    FOREIGN KEY (idcategoria) REFERENCES categoria(idcategoria)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT chk_stock CHECK (stock >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO producto (idproducto,nombre,descripcion,precio,stock,idcategoria) VALUES
(1,'Gaseosa 500ml','Bebida gaseosa',3.50,95,2),
(2,'Galletas','Paquete galletas',2.20,200,3),   -- subido de 77 a 200
(3,'Agua Mineral 600ml',NULL,2.50,256,2),
(4,'Chocolatina',NULL,1.80,100,3),              -- subido de 29 a 100
(5,'Papas Fritas 200g',NULL,3.00,57,3);

DROP TABLE IF EXISTS venta;
CREATE TABLE venta (
  idventa     INT AUTO_INCREMENT PRIMARY KEY,
  fecha       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dniCliente  VARCHAR(8),
  idVendedor  INT,
  total       DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  KEY ix_venta_cliente (dniCliente),
  KEY ix_venta_vendedor (idVendedor),
  CONSTRAINT fk_venta_cliente
    FOREIGN KEY (dniCliente) REFERENCES cliente(dni)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_venta_vendedor
    FOREIGN KEY (idVendedor) REFERENCES vendedor(idVendedor)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS detalle_venta;
CREATE TABLE detalle_venta (
  iddetalle       INT AUTO_INCREMENT PRIMARY KEY,
  idventa         INT NOT NULL,
  idproducto      INT,
  cantidad        INT NOT NULL,
  precio_unitario DECIMAL(10,2) NOT NULL,
  subtotal        DECIMAL(10,2) NOT NULL,
  KEY ix_det_venta (idventa),
  KEY ix_det_producto (idproducto),
  CONSTRAINT fk_detalle_venta_venta
    FOREIGN KEY (idventa) REFERENCES venta(idventa)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_detalle_venta_producto
    FOREIGN KEY (idproducto) REFERENCES producto(idproducto)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
--trigers para asistencia
DELIMITER $$
DROP TRIGGER IF EXISTS trg_mov_bi_valida_salida $$
CREATE TRIGGER trg_mov_bi_valida_salida
BEFORE INSERT ON movimiento_almacen
FOR EACH ROW
BEGIN
  DECLARE disp INT;

  IF NEW.tipo = 'SALIDA' THEN
    SELECT stock INTO disp
    FROM producto
    WHERE idproducto = NEW.idproducto
    FOR UPDATE;

    IF disp < NEW.cantidad THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock insuficiente (movimiento: salida)';
    END IF;
  END IF;
END $$
DROP TRIGGER IF EXISTS trg_mov_ai_aplica $$
CREATE TRIGGER trg_mov_ai_aplica
AFTER INSERT ON movimiento_almacen
FOR EACH ROW
BEGIN
  IF NEW.tipo = 'INGRESO' THEN
    UPDATE producto SET stock = stock + NEW.cantidad
    WHERE idproducto = NEW.idproducto;
  ELSE
    UPDATE producto SET stock = stock - NEW.cantidad
    WHERE idproducto = NEW.idproducto;
  END IF;
END $$
DROP TRIGGER IF EXISTS trg_mov_bu_valida_update $$
CREATE TRIGGER trg_mov_bu_valida_update
BEFORE UPDATE ON movimiento_almacen
FOR EACH ROW
BEGIN
  DECLARE disp INT;
  DECLARE delta INT;
  SET delta = (CASE WHEN NEW.tipo='INGRESO' THEN NEW.cantidad ELSE -NEW.cantidad END)
            - (CASE WHEN OLD.tipo='INGRESO' THEN OLD.cantidad ELSE -OLD.cantidad END);

  SELECT stock INTO disp
  FROM producto
  WHERE idproducto = NEW.idproducto
  FOR UPDATE;
  IF (disp + delta) < 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Stock insuficiente (update de movimiento)';
  END IF;
END $$
DROP TRIGGER IF EXISTS trg_mov_au_aplica_delta $$
CREATE TRIGGER trg_mov_au_aplica_delta
AFTER UPDATE ON movimiento_almacen
FOR EACH ROW
BEGIN
  DECLARE delta INT;
  SET delta = (CASE WHEN NEW.tipo='INGRESO' THEN NEW.cantidad ELSE -NEW.cantidad END)
            - (CASE WHEN OLD.tipo='INGRESO' THEN OLD.cantidad ELSE -OLD.cantidad END);

  UPDATE producto SET stock = stock + delta
  WHERE idproducto = NEW.idproducto;
END $$
DROP TRIGGER IF EXISTS trg_mov_bd_valida_delete $$
CREATE TRIGGER trg_mov_bd_valida_delete
BEFORE DELETE ON movimiento_almacen
FOR EACH ROW
BEGIN
  DECLARE disp INT;
  DECLARE delta INT;
  SET delta = (CASE WHEN OLD.tipo='INGRESO' THEN -OLD.cantidad ELSE +OLD.cantidad END);

  SELECT stock INTO disp
  FROM producto
  WHERE idproducto = OLD.idproducto
  FOR UPDATE;

  IF (disp + delta) < 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'No se puede borrar el movimiento: dejaría stock negativo';
  END IF;
END $$

DROP TRIGGER IF EXISTS trg_mov_ad_revierte $$
CREATE TRIGGER trg_mov_ad_revierte
AFTER DELETE ON movimiento_almacen
FOR EACH ROW
BEGIN
  IF OLD.tipo = 'INGRESO' THEN
    UPDATE producto SET stock = stock - OLD.cantidad
    WHERE idproducto = OLD.idproducto;
  ELSE
    UPDATE producto SET stock = stock + OLD.cantidad
    WHERE idproducto = OLD.idproducto;
  END IF;
END $$
DROP TRIGGER IF EXISTS trg_det_ai_mov_por_venta $$
CREATE TRIGGER trg_det_ai_mov_por_venta
AFTER INSERT ON detalle_venta
FOR EACH ROW
BEGIN
  INSERT INTO movimiento_almacen (fecha, idproducto, tipo, cantidad, motivo, idVendedor)
  SELECT v.fecha, NEW.idproducto, 'SALIDA', NEW.cantidad,
         CONCAT('venta #', v.idventa), v.idVendedor
  FROM venta v
  WHERE v.idventa = NEW.idventa;
END $$
DROP TRIGGER IF EXISTS trg_det_au_ajustes $$
CREATE TRIGGER trg_det_au_ajustes
AFTER UPDATE ON detalle_venta
FOR EACH ROW
BEGIN
  DECLARE vendedor INT;
  DECLARE fventa DATETIME;
  DECLARE delta INT;
  SELECT v.idVendedor, v.fecha INTO vendedor, fventa
  FROM venta v WHERE v.idventa = NEW.idventa;

  IF NEW.idproducto = OLD.idproducto THEN
    SET delta = NEW.cantidad - OLD.cantidad;
    IF delta > 0 THEN
      INSERT INTO movimiento_almacen (fecha, idproducto, tipo, cantidad, motivo, idVendedor)
      VALUES (fventa, NEW.idproducto, 'SALIDA', delta, CONCAT('ajuste venta #', NEW.idventa), vendedor);
    ELSEIF delta < 0 THEN
      INSERT INTO movimiento_almacen (fecha, idproducto, tipo, cantidad, motivo, idVendedor)
      VALUES (fventa, NEW.idproducto, 'INGRESO', -delta, CONCAT('ajuste venta #', NEW.idventa), vendedor);
    END IF;
  ELSE
    INSERT INTO movimiento_almacen (fecha, idproducto, tipo, cantidad, motivo, idVendedor)
    VALUES (fventa, OLD.idproducto, 'INGRESO', OLD.cantidad, CONCAT('cambio prod venta #', NEW.idventa), vendedor);

    INSERT INTO movimiento_almacen (fecha, idproducto, tipo, cantidad, motivo, idVendedor)
    VALUES (fventa, NEW.idproducto, 'SALIDA', NEW.cantidad, CONCAT('cambio prod venta #', NEW.idventa), vendedor);
  END IF;
END $$

-- 9) Al borrar detalle: devolver stock
DROP TRIGGER IF EXISTS trg_det_ad_devolucion $$
CREATE TRIGGER trg_det_ad_devolucion
AFTER DELETE ON detalle_venta
FOR EACH ROW
BEGIN
  DECLARE vendedor INT;
  DECLARE fventa DATETIME;

  SELECT v.idVendedor, v.fecha INTO vendedor, fventa
  FROM venta v WHERE v.idventa = OLD.idventa;

  INSERT INTO movimiento_almacen (fecha, idproducto, tipo, cantidad, motivo, idVendedor)
  VALUES (fventa, OLD.idproducto, 'INGRESO', OLD.cantidad, CONCAT('anulación det venta #', OLD.idventa), vendedor);
END $$

DELIMITER ;
