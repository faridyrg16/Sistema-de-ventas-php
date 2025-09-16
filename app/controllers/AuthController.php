<?php
require_once __DIR__.'/../lib/session.php';require_once __DIR__.'/../lib/auth.php';require_once __DIR__.'/../lib/util.php';
function auth_login(){if($_SERVER['REQUEST_METHOD']==='POST'){if(!check_csrf($_POST['csrf']??'')){http_response_code(400);die('CSRF');}$ok=login($_POST['usuario']??'',$_POST['password']??'');if($ok){header('Location: index.php?r=home');exit;}$error='Credenciales inválidas';}include __DIR__.'/../views/auth_login.php';}
function auth_logout(){logout();header('Location: index.php?r=auth/login');}
