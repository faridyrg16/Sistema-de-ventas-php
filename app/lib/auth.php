<?php
// app/lib/auth.php
require_once __DIR__ . '/session.php';
require_once __DIR__ . '/db.php';

/**
 * Devuelve el usuario actual o null.
 */
function current_user() {
    return $_SESSION['user'] ?? null;
}

/**
 * ¿Es admin?
 */
function is_admin() {
    return (current_user()['rol'] ?? '') === 'ADMIN';
}

/**
 * Exige login: si no hay sesión, redirige al login con mensaje.
 */
function require_login() {
    if (session_status() === PHP_SESSION_NONE) {
        session_start();
    }
    if (empty($_SESSION['user'])) {
        header('Location: index.php?r=auth/login&msg=login_required');
        exit;
    }
}

/**
 * Login: soporta contraseñas bcrypt (password_hash) y SHA-256 legacy (hex).
 */
function login($usuario, $password) {
    $pdo = DB::pdo();

    $st = $pdo->prepare('SELECT idVendedor, nombre, usuario, contrasena_hash, rol
                         FROM vendedor WHERE usuario = ?');
    $st->execute([$usuario]);
    $u = $st->fetch();

    if (!$u) return false;

    $hash = $u['contrasena_hash'] ?? '';

    // 1) Intento bcrypt (password_hash / password_verify)
    $ok = false;
    if (preg_match('/^\$2[ayb]\$/', $hash)) {
        $ok = password_verify($password, $hash);
    }

    // 2) Fallback SHA-256 (para los usuarios con hash en hex de 64 chars)
    if (!$ok && preg_match('/^[0-9a-f]{64}$/i', $hash)) {
        $ok = hash_equals(hash('sha256', $password), strtolower($hash));
    }

    if (!$ok) return false;

    // Registrar asistencia (momento de login)
    $as = $pdo->prepare('INSERT INTO asistencia(idVendedor, login_ts) VALUES (?, NOW())');
    $as->execute([$u['idVendedor']]);

    // Guardar sesión
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
