<?php
// app/lib/auth.php
require_once __DIR__ . '/session.php';
require_once __DIR__ . '/db.php';

function current_user() {
    return $_SESSION['user'] ?? null;
}

function is_admin() {
    return (current_user()['rol'] ?? '') === 'ADMIN';
}

function require_login() {
    if (session_status() === PHP_SESSION_NONE) {
        session_start();
    }
    if (empty($_SESSION['user'])) {
        header('Location: index.php?r=auth/login&msg=login_required');
        exit;
    }
}

function login($usuario, $password) {
    $pdo = DB::pdo();

    $st = $pdo->prepare('SELECT idVendedor, nombre, usuario, contrasena_hash, rol
                         FROM vendedor WHERE usuario = ?');
    $st->execute([$usuario]);
    $u = $st->fetch();

    if (!$u) return false;

    $hash = $u['contrasena_hash'] ?? '';
    $ok = false;

    if (preg_match('/^\$2[ayb]\$/', $hash)) {
        $ok = password_verify($password, $hash);
    }

    if (!$ok && preg_match('/^[0-9a-f]{64}$/i', $hash)) {
        $ok = hash_equals(hash('sha256', $password), strtolower($hash));
    }

    if (!$ok) return false;

    $as = $pdo->prepare("
        INSERT INTO asistencia (idVendedor, login_ts)
        VALUES (?, NOW())
        ON DUPLICATE KEY UPDATE login_ts = VALUES(login_ts)
    ");
    $as->execute([$u['idVendedor']]);

    $_SESSION['user'] = [
        'id'      => (int)$u['idVendedor'],
        'nombre'  => $u['nombre'],
        'usuario' => $u['usuario'],
        'rol'     => $u['rol'],
    ];
    session_regenerate_id(true);

    return true;
}
function logout() {
    $_SESSION = [];
    if (session_status() === PHP_SESSION_ACTIVE) {
        session_destroy();
    }
}
