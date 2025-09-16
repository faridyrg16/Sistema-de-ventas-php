<?php
require_once __DIR__.'/../lib/session.php';
require_once __DIR__.'/../lib/auth.php';
require_once __DIR__.'/../lib/db.php';
require_once __DIR__.'/../lib/util.php';

function almacen_index(){
  require_login();
  include __DIR__.'/../views/almacen_index.php';
}

function almacen_stock(){
  require_login();
  $pdo = DB::pdo();
  $rows = $pdo->query("SELECT idproducto, nombre, precio, stock FROM producto ORDER BY nombre")->fetchAll();
  include __DIR__.'/../views/almacen_stock.php';
}

function almacen_ingreso(){
  require_login();
  $pdo = DB::pdo();
  $rows = $pdo->query("SELECT idproducto, nombre, precio, stock FROM producto ORDER BY nombre")->fetchAll();
  include __DIR__.'/../views/almacen_ingreso.php';
}

function almacen_ingreso_save(){
  require_login();
  if ($_SERVER['REQUEST_METHOD'] !== 'POST') { header('Location: index.php?r=almacen/ingreso'); exit; }

  $pdo = DB::pdo();
  $pid = (int)($_POST['idproducto'] ?? 0);
  $cant = (int)($_POST['cantidad'] ?? 0);

  if ($pid <= 0 || $cant <= 0) { header('Location: index.php?r=almacen/ingreso'); exit; }

  $pdo->beginTransaction();
  try {
    $pdo->prepare("UPDATE producto SET stock = stock + ? WHERE idproducto = ?")->execute([$cant, $pid]);
    $pdo->prepare("INSERT INTO movimiento_almacen (idproducto, tipo, cantidad, motivo, idVendedor)
                   VALUES (?, 'INGRESO', ?, NULL, ?)")->execute([$pid, $cant, current_user()['id'] ?? null]);
    $pdo->commit();
  } catch (Throwable $e) {
    $pdo->rollBack();
    http_response_code(400);
    echo 'Error ingreso: '.h($e->getMessage());
    return;
  }
  header('Location: index.php?r=almacen/ingreso');
  exit;
}

function almacen_salida(){
  require_login();
  $pdo = DB::pdo();
  $rows = $pdo->query("SELECT idproducto, nombre, precio, stock FROM producto ORDER BY nombre")->fetchAll();

  // últimas salidas para la tabla inferior
  $salidas = $pdo->query(
    "SELECT m.id, m.fecha, p.nombre AS producto, m.cantidad, m.motivo
     FROM movimiento_almacen m
     LEFT JOIN producto p ON p.idproducto = m.idproducto
     WHERE m.tipo='SALIDA'
     ORDER BY m.fecha DESC
     LIMIT 50"
  )->fetchAll();

  include __DIR__.'/../views/almacen_salida.php';
}

function almacen_salida_save(){
  require_login();
  if ($_SERVER['REQUEST_METHOD'] !== 'POST') { header('Location: index.php?r=almacen/salida'); exit; }

  $pdo = DB::pdo();
  $pid = (int)($_POST['idproducto'] ?? 0);
  $cant = (int)($_POST['cantidad'] ?? 0);
  $motivo = trim($_POST['motivo'] ?? '');

  if ($pid <= 0 || $cant <= 0 || $motivo === '') { header('Location: index.php?r=almacen/salida'); exit; }

  $pdo->beginTransaction();
  try {
    // validar stock suficiente
    $stk = $pdo->prepare("SELECT stock FROM producto WHERE idproducto=?");
    $stk->execute([$pid]);
    $disp = (int)$stk->fetchColumn();
    if ($disp < $cant) { throw new Exception('Stock insuficiente'); }

    $pdo->prepare("UPDATE producto SET stock = stock - ? WHERE idproducto = ?")->execute([$cant, $pid]);
    $pdo->prepare("INSERT INTO movimiento_almacen (idproducto, tipo, cantidad, motivo, idVendedor)
                   VALUES (?, 'SALIDA', ?, ?, ?)")->execute([$pid, $cant, $motivo, current_user()['id'] ?? null]);
    $pdo->commit();
  } catch (Throwable $e) {
    $pdo->rollBack();
    http_response_code(400);
    echo 'Error salida: '.h($e->getMessage());
    return;
  }
  header('Location: index.php?r=almacen/salida');
  exit;
}
