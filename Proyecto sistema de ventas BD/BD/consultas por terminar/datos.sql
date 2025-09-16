
INSERT INTO vendedor (nombre, usuario, contrasena_hash)
VALUES 
  ('Ana Pérez','ana',SHA2('1234',256)),
  ('Carlos Díaz','carlos',SHA2('1234',256));

INSERT INTO cliente (dni,nombre) VALUES
  ('11111111','Cliente Uno'),
  ('22222222','Cliente Dos'),
  ('33333333','Cliente Tres');

INSERT INTO producto (nombre,precio,stock,idcategoria) VALUES
  ('Agua Mineral 600ml',2.50,50,2),
  ('Chocolatina',1.80,80,3),
  ('Papas Fritas 200g',3.00,60,3);

INSERT INTO venta (fecha,dniCliente,idVendedor,total)
VALUES ('2025-09-01 10:00:00','11111111',1,0),
       ('2025-09-02 15:30:00','22222222',2,0),
       ('2025-09-03 18:45:00','33333333',3,0);

-- Recuperar IDs y detalles
SET @v1 = LAST_INSERT_ID();

-- Detalle primer aventa
INSERT INTO detalle_venta (idventa,idproducto,cantidad,precio_unitario)
VALUES (@v1,2,3,2.20);  -- 3 galletas a 2.20
UPDATE producto SET stock=stock-3 WHERE idproducto=2;
UPDATE venta SET total=(SELECT SUM(cantidad*precio_unitario) FROM detalle_venta WHERE idventa=@v1) WHERE idventa=@v1;
