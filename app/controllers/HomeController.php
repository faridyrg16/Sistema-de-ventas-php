<?php
require_once __DIR__ . '/../lib/session.php';
require_once __DIR__ . '/../lib/auth.php';
require_once __DIR__ . '/../lib/util.php';

function home_index(){
    require_login();
    include __DIR__ . '/../views/home.php';
}
function home_logout(){
    logout();
    redirect('login.php');
}

