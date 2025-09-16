<?php
// public/index.php — Router limpio

require_once __DIR__.'/../app/controllers/HomeController.php';
require_once __DIR__.'/../app/controllers/AuthController.php';
require_once __DIR__.'/../app/controllers/ProductController.php';
require_once __DIR__.'/../app/controllers/ClientController.php';
require_once __DIR__.'/../app/controllers/SaleController.php';
require_once __DIR__.'/../app/controllers/ReportController.php';
require_once __DIR__.'/../app/controllers/AlmacenController.php';
require_once __DIR__.'/../app/lib/util.php';

$r = $_GET['r'] ?? 'home';
$public = ['auth/login'];

if (!in_array($r, $public)) {
    require_once __DIR__.'/../app/lib/auth.php';
    require_login();
}

switch ($r) {
  // Home
  case 'home':           home_index(); break;
  case 'auth/login':     auth_login(); break;
  case 'auth/logout':    auth_logout(); break;

  // Productos
  case 'product/index':  product_index(); break;
  case 'product/new':    product_new(); break;
  case 'product/create': product_create(); break;
  case 'product/edit':   product_edit(); break;
  case 'product/update': product_update(); break;
  case 'product/delete': product_delete(); break;

  // Clientes (consistente con ClientController.php)
  case 'client/index':   client_index(); break;
  case 'client/new':     client_new(); break;
  case 'client/create':  client_create(); break;
  case 'client/edit':    client_edit(); break;
  case 'client/update':  client_update(); break;
  case 'client/delete':  client_delete(); break;

  // Ventas
  case 'sale/new':       sale_new(); break;
  case 'sale/confirm':   sale_confirm(); break;

  // Reportes
  case 'report/index':   report_index(); break;
  case 'report/last':    report_last(); break;
  case 'report/pdf':     report_pdf(); break;

  // Almacén
  case 'almacen/index':        almacen_index(); break;
  case 'almacen/stock':        almacen_stock(); break;
  case 'almacen/ingreso':      almacen_ingreso(); break;
  case 'almacen/ingreso_save': almacen_ingreso_save(); break;
  case 'almacen/salida':       almacen_salida(); break;
  case 'almacen/salida_save':  almacen_salida_save(); break;

  default:
    http_response_code(404);
    echo '404 action';
}
