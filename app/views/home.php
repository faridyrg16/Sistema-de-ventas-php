<?php require_once __DIR__ . '/../lib/util.php'; ?>
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>Inicio</title>
  <link rel="stylesheet" href="assets/styles.css">
</head>
<body>
<div class="container">
  <div class="card">
    <h2>Menú principal</h2>
    <p>
      <a class="btn" href="index.php?r=product/index">Productos</a>
      <a class="btn" href="index.php?r=customer/index">Clientes</a>
      <a class="btn" href="index.php?r=sale/new">Ventas</a>
      <a class="btn" href="index.php?r=report/index">Reportes</a>
      <a class="btn" href="index.php?r=almacen/index">Almacén</a>
      <a class="btn" href="index.php?r=auth/login">salir</a>
    </p>
    <p class="mono">Bienvenido, <?=h(current_user()['nombre'] ?? '')?></p>
  </div>
</div>
</body>
</html>
