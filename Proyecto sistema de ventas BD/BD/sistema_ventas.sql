-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 15-09-2025 a las 19:51:13
-- Versión del servidor: 10.4.24-MariaDB
-- Versión de PHP: 8.1.6

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `sistema_ventas`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `asistencia`
--

CREATE TABLE `asistencia` (
  `id` int(11) NOT NULL,
  `idVendedor` int(11) DEFAULT NULL,
  `login_ts` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `asistencia`
--

INSERT INTO `asistencia` (`id`, `idVendedor`, `login_ts`) VALUES
(1, 1, '0000-00-00 00:00:00'),
(2, 1, '0000-00-00 00:00:00'),
(3, 1, '0000-00-00 00:00:00'),
(4, 1, '0000-00-00 00:00:00'),
(5, 1, '0000-00-00 00:00:00'),
(6, 1, '0000-00-00 00:00:00'),
(7, 1, '0000-00-00 00:00:00'),
(8, 1, '0000-00-00 00:00:00'),
(9, 1, '0000-00-00 00:00:00'),
(10, 1, '0000-00-00 00:00:00'),
(11, 1, '0000-00-00 00:00:00'),
(12, 1, '0000-00-00 00:00:00'),
(13, 1, '0000-00-00 00:00:00'),
(14, 1, '2025-09-15 12:48:02');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categoria`
--

CREATE TABLE `categoria` (
  `idcategoria` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `descripcion` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `categoria`
--

INSERT INTO `categoria` (`idcategoria`, `nombre`, `descripcion`) VALUES
(1, 'General', 'Categoría por defecto'),
(2, 'Bebidas', 'Líquidos'),
(3, 'Snacks', 'Aperitivos');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cliente`
--

CREATE TABLE `cliente` (
  `dni` varchar(8) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `direccion` varchar(255) DEFAULT NULL,
  `fecha_nacimiento` date DEFAULT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `correo` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `cliente`
--

INSERT INTO `cliente` (`dni`, `nombre`, `direccion`, `fecha_nacimiento`, `telefono`, `correo`) VALUES
('00000000', 'Publico General', '', NULL, '', ''),
('11111111', 'Cliente Uno', NULL, NULL, NULL, NULL),
('22222222', 'Cliente Dos', NULL, NULL, NULL, NULL),
('33333333', 'Cliente Tres', NULL, NULL, NULL, NULL),
('72748152', 'Farid Romero', 'Cusco', NULL, '999999999', 'farid@example.com');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_venta`
--

CREATE TABLE `detalle_venta` (
  `iddetalle` int(11) NOT NULL,
  `idventa` int(11) NOT NULL,
  `idproducto` int(11) DEFAULT NULL,
  `cantidad` int(11) NOT NULL,
  `precio_unitario` decimal(10,2) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `detalle_venta`
--

INSERT INTO `detalle_venta` (`iddetalle`, `idventa`, `idproducto`, `cantidad`, `precio_unitario`, `subtotal`) VALUES
(1, 1, 1, 2, '3.50', '0.00'),
(2, 2, 1, 2, '3.50', '0.00'),
(3, 3, 2, 3, '2.20', '0.00'),
(4, 6, 2, 120, '2.20', '264.00'),
(5, 6, 4, 1, '1.80', '1.80'),
(6, 6, 3, 1, '2.50', '2.50'),
(7, 6, 1, 1, '3.50', '3.50'),
(8, 6, 5, 1, '3.00', '3.00');

--
-- Disparadores `detalle_venta`
--
DELIMITER $$
CREATE TRIGGER `trg_validar_stock` BEFORE INSERT ON `detalle_venta` FOR EACH ROW BEGIN
  DECLARE disponible INT;
  SELECT stock INTO disponible FROM producto WHERE idproducto = NEW.idproducto;
  IF disponible < NEW.cantidad THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Stock insuficiente para este producto';
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `movimiento_almacen`
--

CREATE TABLE `movimiento_almacen` (
  `id` int(11) NOT NULL,
  `fecha` datetime NOT NULL DEFAULT current_timestamp(),
  `idproducto` int(11) NOT NULL,
  `tipo` enum('INGRESO','SALIDA') NOT NULL,
  `cantidad` int(11) NOT NULL,
  `motivo` varchar(255) DEFAULT NULL,
  `idVendedor` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `movimiento_almacen`
--

INSERT INTO `movimiento_almacen` (`id`, `fecha`, `idproducto`, `tipo`, `cantidad`, `motivo`, `idVendedor`) VALUES
(1, '2025-09-15 12:38:34', 3, 'INGRESO', 200, NULL, 1),
(2, '2025-09-15 12:38:45', 3, 'INGRESO', 10, NULL, 1),
(3, '2025-09-15 12:38:53', 3, 'SALIDA', 1, 'merma', 1);

--
-- Disparadores `movimiento_almacen`
--
DELIMITER $$
CREATE TRIGGER `trg_no_stock_negativo_salida` BEFORE INSERT ON `movimiento_almacen` FOR EACH ROW BEGIN
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
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `producto`
--

CREATE TABLE `producto` (
  `idproducto` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `precio` decimal(10,2) NOT NULL,
  `stock` int(11) NOT NULL DEFAULT 0,
  `idcategoria` int(11) DEFAULT NULL
) ;

--
-- Volcado de datos para la tabla `producto`
--

INSERT INTO `producto` (`idproducto`, `nombre`, `descripcion`, `precio`, `stock`, `idcategoria`) VALUES
(1, 'Gaseosa 500ml', 'Bebida gaseosa', '3.50', 95, 2),
(2, 'Galletas', 'Paquete galletas', '2.20', 77, 3),
(3, 'Agua Mineral 600ml', NULL, '2.50', 258, 2),
(4, 'Chocolatina', NULL, '1.80', 79, 3),
(5, 'Papas Fritas 200g', NULL, '3.00', 59, 3);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `vendedor`
--

CREATE TABLE `vendedor` (
  `idVendedor` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `usuario` varchar(50) NOT NULL,
  `contrasena_hash` varchar(255) NOT NULL,
  `direccion` varchar(255) DEFAULT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `correo` varchar(100) DEFAULT NULL,
  `rol` enum('ADMIN','VENDEDOR') NOT NULL DEFAULT 'VENDEDOR'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `vendedor`
--

INSERT INTO `vendedor` (`idVendedor`, `nombre`, `usuario`, `contrasena_hash`, `direccion`, `telefono`, `correo`, `rol`) VALUES
(1, 'Administrador', 'admin', '$2y$10$S4v7D2SNBgoVG0wC6SqieeUShwgtk.sLnJQECL9arC45NU45LLhFS', '', '', '', 'ADMIN'),
(2, 'Ana Pérez', 'ana', '$2y$10$YcTy27/Ky4BZRephyhRfYufYKMpz/SNPoKQx0CDgEo1byK5YlQ/c.', NULL, NULL, NULL, 'VENDEDOR'),
(3, 'Carlos Díaz', 'carlos', 'P$2y$10$swvlI3wvwRmqf729qQ9oju.tfyLUV03a/l50K7uAaT2RgIuq9q5.K', NULL, NULL, NULL, 'VENDEDOR');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `venta`
--

CREATE TABLE `venta` (
  `idventa` int(11) NOT NULL,
  `fecha` datetime NOT NULL,
  `dniCliente` varchar(8) DEFAULT NULL,
  `idVendedor` int(11) DEFAULT NULL,
  `total` decimal(10,2) NOT NULL DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `venta`
--

INSERT INTO `venta` (`idventa`, `fecha`, `dniCliente`, `idVendedor`, `total`) VALUES
(1, '0000-00-00 00:00:00', '00000000', 1, '0.00'),
(2, '0000-00-00 00:00:00', '00000000', 1, '7.00'),
(3, '2025-09-01 10:00:00', '11111111', 1, '6.60'),
(4, '2025-09-02 15:30:00', '22222222', 2, '0.00'),
(5, '2025-09-03 18:45:00', '33333333', 3, '0.00'),
(6, '0000-00-00 00:00:00', '72748152', 1, '274.80');

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vw_top_productos`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vw_top_productos` (
`idproducto` int(11)
,`nombre` varchar(100)
,`total_cantidad` decimal(32,0)
,`total_ventas` decimal(32,2)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vw_ventas_por_vendedor_mes`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vw_ventas_por_vendedor_mes` (
`idVendedor` int(11)
,`vendedor` varchar(100)
,`periodo` varchar(7)
,`total_mes` decimal(32,2)
,`num_ventas` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura para la vista `vw_top_productos`
--
DROP TABLE IF EXISTS `vw_top_productos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_top_productos`  AS SELECT `p`.`idproducto` AS `idproducto`, `p`.`nombre` AS `nombre`, sum(`d`.`cantidad`) AS `total_cantidad`, sum(`d`.`subtotal`) AS `total_ventas` FROM (`detalle_venta` `d` left join `producto` `p` on(`p`.`idproducto` = `d`.`idproducto`)) GROUP BY `p`.`idproducto` ORDER BY sum(`d`.`cantidad`) AS `DESCdesc` ASC  ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vw_ventas_por_vendedor_mes`
--
DROP TABLE IF EXISTS `vw_ventas_por_vendedor_mes`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_ventas_por_vendedor_mes`  AS SELECT `v`.`idVendedor` AS `idVendedor`, `ve`.`nombre` AS `vendedor`, date_format(`v`.`fecha`,'%Y-%m') AS `periodo`, sum(`v`.`total`) AS `total_mes`, count(0) AS `num_ventas` FROM (`venta` `v` left join `vendedor` `ve` on(`ve`.`idVendedor` = `v`.`idVendedor`)) GROUP BY `v`.`idVendedor`, date_format(`v`.`fecha`,'%Y-%m')  ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `asistencia`
--
ALTER TABLE `asistencia`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idVendedor` (`idVendedor`);

--
-- Indices de la tabla `categoria`
--
ALTER TABLE `categoria`
  ADD PRIMARY KEY (`idcategoria`);

--
-- Indices de la tabla `cliente`
--
ALTER TABLE `cliente`
  ADD PRIMARY KEY (`dni`);

--
-- Indices de la tabla `detalle_venta`
--
ALTER TABLE `detalle_venta`
  ADD PRIMARY KEY (`iddetalle`),
  ADD KEY `idventa` (`idventa`),
  ADD KEY `idproducto` (`idproducto`);

--
-- Indices de la tabla `movimiento_almacen`
--
ALTER TABLE `movimiento_almacen`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_mov_vend` (`idVendedor`),
  ADD KEY `ix_mov_prod_fecha` (`idproducto`,`fecha`);

--
-- Indices de la tabla `producto`
--
ALTER TABLE `producto`
  ADD PRIMARY KEY (`idproducto`),
  ADD KEY `idcategoria` (`idcategoria`);

--
-- Indices de la tabla `vendedor`
--
ALTER TABLE `vendedor`
  ADD PRIMARY KEY (`idVendedor`),
  ADD UNIQUE KEY `usuario` (`usuario`);

--
-- Indices de la tabla `venta`
--
ALTER TABLE `venta`
  ADD PRIMARY KEY (`idventa`),
  ADD KEY `dniCliente` (`dniCliente`),
  ADD KEY `idVendedor` (`idVendedor`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `asistencia`
--
ALTER TABLE `asistencia`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT de la tabla `categoria`
--
ALTER TABLE `categoria`
  MODIFY `idcategoria` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `detalle_venta`
--
ALTER TABLE `detalle_venta`
  MODIFY `iddetalle` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `movimiento_almacen`
--
ALTER TABLE `movimiento_almacen`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `producto`
--
ALTER TABLE `producto`
  MODIFY `idproducto` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `vendedor`
--
ALTER TABLE `vendedor`
  MODIFY `idVendedor` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `venta`
--
ALTER TABLE `venta`
  MODIFY `idventa` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `asistencia`
--
ALTER TABLE `asistencia`
  ADD CONSTRAINT `asistencia_ibfk_1` FOREIGN KEY (`idVendedor`) REFERENCES `vendedor` (`idVendedor`) ON DELETE SET NULL;

--
-- Filtros para la tabla `detalle_venta`
--
ALTER TABLE `detalle_venta`
  ADD CONSTRAINT `detalle_venta_ibfk_1` FOREIGN KEY (`idventa`) REFERENCES `venta` (`idventa`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `detalle_venta_ibfk_2` FOREIGN KEY (`idproducto`) REFERENCES `producto` (`idproducto`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Filtros para la tabla `movimiento_almacen`
--
ALTER TABLE `movimiento_almacen`
  ADD CONSTRAINT `fk_mov_prod` FOREIGN KEY (`idproducto`) REFERENCES `producto` (`idproducto`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_mov_vend` FOREIGN KEY (`idVendedor`) REFERENCES `vendedor` (`idVendedor`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Filtros para la tabla `producto`
--
ALTER TABLE `producto`
  ADD CONSTRAINT `producto_ibfk_1` FOREIGN KEY (`idcategoria`) REFERENCES `categoria` (`idcategoria`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Filtros para la tabla `venta`
--
ALTER TABLE `venta`
  ADD CONSTRAINT `venta_ibfk_1` FOREIGN KEY (`dniCliente`) REFERENCES `cliente` (`dni`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `venta_ibfk_2` FOREIGN KEY (`idVendedor`) REFERENCES `vendedor` (`idVendedor`) ON DELETE SET NULL ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
