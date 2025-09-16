--Ventas por vendedor y mes
SELECT v.idVendedor, ve.nombre, DATE_FORMAT(v.fecha,'%Y-%m') periodo,
       SUM(v.total) total_mes
FROM venta v JOIN vendedor ve ON v.idVendedor=ve.idVendedor
GROUP BY v.idVendedor, periodo;

--productos mas vendidos
SELECT p.nombre, SUM(d.cantidad) total_cant
FROM detalle_venta d JOIN producto p ON d.idproducto=p.idproducto
GROUP BY p.idproducto ORDER BY total_cant DESC LIMIT 10;
