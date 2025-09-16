USE sistema_ventas;
INSERT IGNORE INTO categoria (idcategoria, nombre) VALUES (1,'General'),(2,'Bebidas'),(3,'Snacks');
INSERT IGNORE INTO producto (idproducto, nombre, precio, stock, idcategoria) VALUES
  (1,'Gaseosa 500ml',3.50,100,2),(2,'Galletas',2.20,200,3);
INSERT IGNORE INTO cliente (dni, nombre) VALUES ('00000000','Publico General');
-- Hash de 'admin' se recomienda generarla con password_hash desde app; este es un placeholder inseguro
INSERT IGNORE INTO vendedor (idVendedor, nombre, usuario, contrasena_hash, rol)
VALUES (1,'Administrador','admin','$2y$10$abcdefghijklmnopqrstuvABCDEFGHijklmnopQRSTUVwx.yzABC','ADMIN');

update vendedor
SET contrasena_hash = '$2y$10$S4v7D2SNBgoVG0wC6SqieeUShwgtk.sLnJQECL9arC45NU45LLhFS'
WHERE usuario = 'admin';

CREATE USER 'venta_user'@'localhost' IDENTIFIED BY 'TuClaveFuerte123';
GRANT ALL PRIVILEGES ON sistema_ventas.* TO 'venta_user'@'localhost';
FLUSH PRIVILEGES;

--validacion
DELIMITER //
CREATE TRIGGER IF NOT EXISTS trg_validar_stock
BEFORE INSERT ON detalle_venta
FOR EACH ROW
BEGIN
  DECLARE disponible INT;
  SELECT stock INTO disponible FROM producto WHERE idproducto = NEW.idproducto FOR UPDATE;
  IF disponible < NEW.cantidad THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente';
  END IF;
END//
DELIMITER ;

ALTER TABLE vendedor
ADD COLUMN rol ENUM('ADMIN','VENDEDOR') NOT NULL DEFAULT 'VENDEDOR';

UPDATE vendedor SET rol='ADMIN' WHERE usuario='admin';

USE sistema_ventas;

SELECT idVendedor, nombre, usuario, contrasena_hash, rol
FROM vendedor
LIMIT 100;


UPDATE vendedor 
SET contrasena_hash = '$2y$10$YcTy27/Ky4BZRephyhRfYufYKMpz/SNPoKQx0CDgEo1byK5YlQ/c.'
WHERE usuario = 'ana';

UPDATE vendedor 
SET contrasena_hash = 'P$2y$10$swvlI3wvwRmqf729qQ9oju.tfyLUV03a/l50K7uAaT2RgIuq9q5.K'
WHERE usuario = 'carlos';

-- Movimientos de almacén: ingresos/salidas
CREATE TABLE IF NOT EXISTS movimiento_almacen (
  id INT AUTO_INCREMENT PRIMARY KEY,
  fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  idproducto INT NOT NULL,
  tipo ENUM('INGRESO','SALIDA') NOT NULL,
  cantidad INT NOT NULL,
  motivo VARCHAR(255) NULL,
  idVendedor INT NULL,
  CONSTRAINT fk_mov_prod FOREIGN KEY (idproducto) REFERENCES producto(idproducto)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_mov_vend FOREIGN KEY (idVendedor) REFERENCES vendedor(idVendedor)
    ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE INDEX ix_mov_prod_fecha ON movimiento_almacen (idproducto, fecha);

DELIMITER //

DROP TRIGGER IF EXISTS trg_no_stock_negativo_salida//
CREATE TRIGGER trg_no_stock_negativo_salida
BEFORE INSERT ON movimiento_almacen
FOR EACH ROW
BEGIN
  DECLARE disp INT;  -- Declaraciones SIEMPRE arriba

  IF NEW.tipo = 'SALIDA' THEN
    -- FOR UPDATE bloquea la fila de producto para evitar carreras
    SELECT stock INTO disp
    FROM producto
    WHERE idproducto = NEW.idproducto
    FOR UPDATE;

    IF disp < NEW.cantidad THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock insuficiente (trigger)';
    END IF;
  END IF;
END//
DELIMITER ;
