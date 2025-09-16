<?php
if(session_status()!==PHP_SESSION_ACTIVE){session_start();}
function csrf_token(){if(empty($_SESSION['csrf'])){$_SESSION['csrf']=bin2hex(random_bytes(16));}return $_SESSION['csrf'];}
function check_csrf($t){return isset($_SESSION['csrf'])&&hash_equals($_SESSION['csrf'],$t??'');}
