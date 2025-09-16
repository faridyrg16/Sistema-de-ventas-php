drop database if exists sistema_ventas;
CREATE DATABASE IF NOT EXISTS sistema_ventas CHARACTER SET utf8mb4;
USE sistema_ventas;
DROP TABLE IF EXISTS `asistencia`;

CREATE TABLE `asistencia` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `idVendedor` int(11) DEFAULT NULL,
  `login_ts` datetime NOT NULL,
  `login_date` date GENERATED ALWAYS AS (cast(`login_ts` as date)) STORED,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_asistencia_user_day` (`idVendedor`,`login_date`),
  CONSTRAINT `asistencia_ibfk_1` FOREIGN KEY (`idVendedor`) REFERENCES `vendedor` (`idVendedor`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4;

LOCK TABLES `asistencia` WRITE;
/*!40000 ALTER TABLE `asistencia` DISABLE KEYS */;
INSERT INTO `asistencia` VALUES
(1,1,'0000-00-00 00:00:00',NULL),
(2,1,'0000-00-00 00:00:00',NULL),
(3,1,'0000-00-00 00:00:00',NULL),
(4,1,'0000-00-00 00:00:00',NULL),
(5,1,'0000-00-00 00:00:00',NULL),
(6,1,'0000-00-00 00:00:00',NULL),
(7,1,'0000-00-00 00:00:00',NULL),
(8,1,'0000-00-00 00:00:00',NULL),
(9,1,'0000-00-00 00:00:00',NULL),
(10,1,'0000-00-00 00:00:00',NULL),
(11,1,'0000-00-00 00:00:00',NULL),
(12,1,'0000-00-00 00:00:00',NULL),
(13,1,'0000-00-00 00:00:00',NULL),
(14,1,'2025-09-15 12:48:02','2025-09-15'),
(15,1,'2025-09-16 09:10:49','2025-09-16');
/*!40000 ALTER TABLE `asistencia` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categoria`
--

DROP TABLE IF EXISTS `categoria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `categoria` (
  `idcategoria` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `descripcion` text DEFAULT NULL,
  PRIMARY KEY (`idcategoria`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categoria`
--

LOCK TABLES `categoria` WRITE;
/*!40000 ALTER TABLE `categoria` DISABLE KEYS */;
INSERT INTO `categoria` VALUES
(1,'General','Categoría por defecto'),
(2,'Bebidas','Líquidos'),
(3,'Snacks','Aperitivos');
/*!40000 ALTER TABLE `categoria` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cliente`
--

DROP TABLE IF EXISTS `cliente`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `cliente` (
  `dni` varchar(8) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `direccion` varchar(255) DEFAULT NULL,
  `fecha_nacimiento` date DEFAULT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `correo` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`dni`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cliente`
--

LOCK TABLES `cliente` WRITE;
/*!40000 ALTER TABLE `cliente` DISABLE KEYS */;
INSERT INTO `cliente` VALUES
('00000000','Publico General','',NULL,'',''),
('11111111','Cliente Uno',NULL,NULL,NULL,NULL),
('12345678','yesica|',NULL,NULL,'9999999',''),
('22222222','Cliente Dos',NULL,NULL,NULL,NULL),
('33333333','Cliente Tres',NULL,NULL,NULL,NULL),
('72748152','Farid Romero','Cusco',NULL,'999999999','farid@example.com');
/*!40000 ALTER TABLE `cliente` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `detalle_venta`
--

DROP TABLE IF EXISTS `detalle_venta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `detalle_venta` (
  `iddetalle` int(11) NOT NULL AUTO_INCREMENT,
  `idventa` int(11) NOT NULL,
  `idproducto` int(11) DEFAULT NULL,
  `cantidad` int(11) NOT NULL,
  `precio_unitario` decimal(10,2) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  PRIMARY KEY (`iddetalle`),
  KEY `idventa` (`idventa`),
  KEY `idproducto` (`idproducto`),
  CONSTRAINT `detalle_venta_ibfk_1` FOREIGN KEY (`idventa`) REFERENCES `venta` (`idventa`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `detalle_venta_ibfk_2` FOREIGN KEY (`idproducto`) REFERENCES `producto` (`idproducto`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `detalle_venta`
--

LOCK TABLES `detalle_venta` WRITE;
/*!40000 ALTER TABLE `detalle_venta` DISABLE KEYS */;
INSERT INTO `detalle_venta` VALUES
(1,1,1,2,3.50,0.00),
(2,2,1,2,3.50,0.00),
(3,3,2,3,2.20,0.00),
(4,6,2,120,2.20,264.00),
(5,6,4,1,1.80,1.80),
(6,6,3,1,2.50,2.50),
(7,6,1,1,3.50,3.50),
(8,6,5,1,3.00,3.00),
(9,7,3,1,2.50,2.50),
(10,7,5,1,3.00,3.00),
(11,8,3,1,2.50,2.50),
(12,8,5,1,3.00,3.00),
(13,9,4,50,1.80,90.00);
/*!40000 ALTER TABLE `detalle_venta` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_validar_stock
BEFORE INSERT ON detalle_venta
FOR EACH ROW
BEGIN
  DECLARE disponible INT;
  SELECT stock INTO disponible FROM producto WHERE idproducto = NEW.idproducto;
  IF disponible < NEW.cantidad THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Stock insuficiente para este producto';
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `movimiento_almacen`
--

DROP TABLE IF EXISTS `movimiento_almacen`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `movimiento_almacen` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fecha` datetime NOT NULL DEFAULT current_timestamp(),
  `idproducto` int(11) NOT NULL,
  `tipo` enum('INGRESO','SALIDA') NOT NULL,
  `cantidad` int(11) NOT NULL,
  `motivo` varchar(255) DEFAULT NULL,
  `idVendedor` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_mov_vend` (`idVendedor`),
  KEY `ix_mov_prod_fecha` (`idproducto`,`fecha`),
  CONSTRAINT `fk_mov_prod` FOREIGN KEY (`idproducto`) REFERENCES `producto` (`idproducto`) ON UPDATE CASCADE,
  CONSTRAINT `fk_mov_vend` FOREIGN KEY (`idVendedor`) REFERENCES `vendedor` (`idVendedor`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `movimiento_almacen`
--

LOCK TABLES `movimiento_almacen` WRITE;
/*!40000 ALTER TABLE `movimiento_almacen` DISABLE KEYS */;
INSERT INTO `movimiento_almacen` VALUES
(1,'2025-09-15 12:38:34',3,'INGRESO',200,NULL,1),
(2,'2025-09-15 12:38:45',3,'INGRESO',10,NULL,1),
(3,'2025-09-15 12:38:53',3,'SALIDA',1,'merma',1);
/*!40000 ALTER TABLE `movimiento_almacen` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_no_stock_negativo_salida
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `producto`
--

DROP TABLE IF EXISTS `producto`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `producto` (
  `idproducto` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `precio` decimal(10,2) NOT NULL,
  `stock` int(11) NOT NULL DEFAULT 0,
  `idcategoria` int(11) DEFAULT NULL,
  PRIMARY KEY (`idproducto`),
  KEY `idcategoria` (`idcategoria`),
  CONSTRAINT `producto_ibfk_1` FOREIGN KEY (`idcategoria`) REFERENCES `categoria` (`idcategoria`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `chk_stock` CHECK (`stock` >= 0)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `producto`
--

LOCK TABLES `producto` WRITE;
/*!40000 ALTER TABLE `producto` DISABLE KEYS */;
INSERT INTO `producto` VALUES
(1,'Gaseosa 500ml','Bebida gaseosa',3.50,95,2),
(2,'Galletas','Paquete galletas',2.20,77,3),
(3,'Agua Mineral 600ml',NULL,2.50,256,2),
(4,'Chocolatina',NULL,1.80,29,3),
(5,'Papas Fritas 200g',NULL,3.00,57,3);
/*!40000 ALTER TABLE `producto` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vendedor`
--

DROP TABLE IF EXISTS `vendedor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `vendedor` (
  `idVendedor` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `usuario` varchar(50) NOT NULL,
  `contrasena_hash` varchar(255) NOT NULL,
  `direccion` varchar(255) DEFAULT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `correo` varchar(100) DEFAULT NULL,
  `rol` enum('ADMIN','VENDEDOR') NOT NULL DEFAULT 'VENDEDOR',
  PRIMARY KEY (`idVendedor`),
  UNIQUE KEY `usuario` (`usuario`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vendedor`
--

LOCK TABLES `vendedor` WRITE;
/*!40000 ALTER TABLE `vendedor` DISABLE KEYS */;
INSERT INTO `vendedor` VALUES
(1,'Administrador','admin','$2y$10$S4v7D2SNBgoVG0wC6SqieeUShwgtk.sLnJQECL9arC45NU45LLhFS','','','','ADMIN'),
(2,'Ana Pérez','ana','$2y$10$YcTy27/Ky4BZRephyhRfYufYKMpz/SNPoKQx0CDgEo1byK5YlQ/c.',NULL,NULL,NULL,'VENDEDOR'),
(3,'Carlos Díaz','carlos','P$2y$10$swvlI3wvwRmqf729qQ9oju.tfyLUV03a/l50K7uAaT2RgIuq9q5.K',NULL,NULL,NULL,'VENDEDOR');
/*!40000 ALTER TABLE `vendedor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `venta`
--

DROP TABLE IF EXISTS `venta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `venta` (
  `idventa` int(11) NOT NULL AUTO_INCREMENT,
  `fecha` datetime NOT NULL,
  `dniCliente` varchar(8) DEFAULT NULL,
  `idVendedor` int(11) DEFAULT NULL,
  `total` decimal(10,2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (`idventa`),
  KEY `dniCliente` (`dniCliente`),
  KEY `idVendedor` (`idVendedor`),
  CONSTRAINT `venta_ibfk_1` FOREIGN KEY (`dniCliente`) REFERENCES `cliente` (`dni`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `venta_ibfk_2` FOREIGN KEY (`idVendedor`) REFERENCES `vendedor` (`idVendedor`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `venta`
--

LOCK TABLES `venta` WRITE;
/*!40000 ALTER TABLE `venta` DISABLE KEYS */;
INSERT INTO `venta` VALUES
(1,'0000-00-00 00:00:00','00000000',1,0.00),
(2,'0000-00-00 00:00:00','00000000',1,7.00),
(3,'2025-09-01 10:00:00','11111111',1,6.60),
(4,'2025-09-02 15:30:00','22222222',2,0.00),
(5,'2025-09-03 18:45:00','33333333',3,0.00),
(6,'0000-00-00 00:00:00','72748152',1,274.80),
(7,'0000-00-00 00:00:00','12345678',1,5.50),
(8,'0000-00-00 00:00:00','12345678',1,5.50),
(9,'0000-00-00 00:00:00','72748152',1,90.00);
/*!40000 ALTER TABLE `venta` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `vw_top_productos`
--

DROP TABLE IF EXISTS `vw_top_productos`;
/*!50001 DROP VIEW IF EXISTS `vw_top_productos`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `vw_top_productos` AS SELECT
 1 AS `idproducto`,
  1 AS `nombre`,
  1 AS `total_cantidad`,
  1 AS `total_ventas` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `vw_ventas_por_vendedor_mes`
--

DROP TABLE IF EXISTS `vw_ventas_por_vendedor_mes`;
/*!50001 DROP VIEW IF EXISTS `vw_ventas_por_vendedor_mes`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `vw_ventas_por_vendedor_mes` AS SELECT
 1 AS `idVendedor`,
  1 AS `vendedor`,
  1 AS `periodo`,
  1 AS `total_mes`,
  1 AS `num_ventas` */;
SET character_set_client = @saved_cs_client;