<?php
$autoloadA = __DIR__ . '/../../vendor/autoload.php';
$autoloadB = __DIR__ . '/../vendor/dompdf/autoload.inc.php';

if (file_exists($autoloadA)) {
    require_once $autoloadA;
} elseif (file_exists($autoloadB)) {
    require_once $autoloadB;
} else {
    function render_pdf($html, $filename='reporte.pdf', $download=false){
        http_response_code(500);
        echo 'Dompdf no instalado. Instálalo con: <code>composer require dompdf/dompdf</code>';
        exit;
    }
    return;
}

use Dompdf\Dompdf;
use Dompdf\Options;

function render_pdf(string $html, string $filename='reporte.pdf', bool $download=false){
    $opts = new Options();
    $opts->set('isHtml5ParserEnabled', true);
    $opts->set('isRemoteEnabled', true);

    $dompdf = new Dompdf($opts);
    $dompdf->loadHtml($html, 'UTF-8');
    $dompdf->setPaper('A4', 'portrait');
    $dompdf->render();
    $dompdf->stream($filename, ['Attachment' => $download ? 1 : 0]);
    exit;
}
