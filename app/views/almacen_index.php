<?php require_once __DIR__ . '/../lib/util.php'; ?>
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>Almacén</title>
  <link rel="stylesheet" href="assets/styles.css">
</head>
<body>
<div class="container">
  <div class="card">
    <h2>Almacén</h2>
    <p>
      <a class="btn" href="index.php?r=almacen/stock">📦 Ver stock</a>
      <a class="btn" href="index.php?r=almacen/ingreso">➕ Ingresos</a>
      <a class="btn" href="index.php?r=almacen/salida">➖ Salidas</a>
      <a class="btn" href="index.php?r=home">salir</a>
    </p>
    <p class="mono">Gestiona existencias, registra ingresos y salidas con motivo.</p>
  </div>
</div>
</body>
</html>
