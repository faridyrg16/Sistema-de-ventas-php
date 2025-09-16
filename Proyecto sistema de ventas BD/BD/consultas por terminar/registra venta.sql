START TRANSACTION;

INSERT INTO venta(fecha, dniCliente, idVendedor, total)
VALUES (NOW(), ?, ?, 0);
--LAST_INSERT_ID() para idventa

INSERT INTO detalle_venta(idventa, idproducto, cantidad, precio_unitario, subtotal)
VALUES (?,?,?,?,?);

UPDATE producto SET stock = stock - ? WHERE idproducto=?;

UPDATE venta v
JOIN (SELECT idventa, SUM(subtotal) tot FROM detalle_venta WHERE idventa=? GROUP BY idventa) t
  ON v.idventa=t.idventa
SET v.total = t.tot;

COMMIT;
