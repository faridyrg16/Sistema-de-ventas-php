<?php
declare(strict_types=1);

require_once __DIR__.'/../app/controllers/HomeController.php';
require_once __DIR__.'/../app/controllers/AuthController.php';
require_once __DIR__.'/../app/controllers/ProductController.php';
require_once __DIR__.'/../app/controllers/CustomerController.php';
require_once __DIR__.'/../app/controllers/SaleController.php';
require_once __DIR__.'/../app/controllers/ReportController.php';
require_once __DIR__.'/../app/controllers/AlmacenController.php';
require_once __DIR__.'/../app/lib/util.php';
require_once __DIR__.'/../app/lib/auth.php';


$r = isset($_GET['r']) ? trim((string)$_GET['r']) : 'home';
if ($r === '') { $r = 'home'; }

if (!preg_match('#^[a-z]+(?:/[a-z_]+)?$#', $r)) {
    http_response_code(400);
    echo '400 bad route';
    exit;
}

$PUBLIC = ['auth/login'];

/* 4) Exige login para todo lo no público. */
if (!in_array($r, $PUBLIC, true)) {
    require_login(); 
}
switch ($r) {
    // Home
    case 'home':
        home_index();
        break;

    case 'auth/login':
        auth_login();
        break;

    case 'auth/logout':
        auth_logout();
        break;

    // Productos
    case 'product/index':  product_index();  break;
    case 'product/new':    product_new();    break;
    case 'product/create': product_create(); break;
    case 'product/edit':   product_edit();   break;
    case 'product/update': product_update(); break;
    case 'product/delete': product_delete(); break;

    // Clientes
    case 'customer/index':   customer_index();   break;
    case 'customer/new':     customer_new();     break;
    case 'customer/create':  customer_create();  break;
    case 'customer/edit':    customer_edit();    break;
    case 'customer/update':  customer_update();  break;
    case 'customer/delete':  customer_delete();  break;

    // Ventas
    case 'sale/new':       sale_new();       break;
    case 'sale/confirm':   sale_confirm();   break;

    // Reportes
    case 'report/index':   report_index();   break;
    case 'report/last':    report_last();    break;
    case 'report/pdf':     report_pdf();     break;

    // Almacén
    case 'almacen/index':        almacen_index();        break;
    case 'almacen/stock':        almacen_stock();        break;
    case 'almacen/ingreso':      almacen_ingreso();      break;
    case 'almacen/ingreso_save': almacen_ingreso_save(); break;
    case 'almacen/salida':       almacen_salida();       break;
    case 'almacen/salida_save':  almacen_salida_save();  break;

    default:
        http_response_code(404);
        echo '404 action';
        break;
}
