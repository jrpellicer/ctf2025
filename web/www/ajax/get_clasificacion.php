<?php
require '../db.php'; // Ajusta la ruta según tu proyecto

header('Content-Type: application/json');

$equipos = [];

if (isset($_GET['comp'])) {
    $stmt = $pdo->prepare(
        "SELECT nombre, codigo_hex, puntos, tiempo
         FROM equipos
         WHERE competicion_id = ?
         ORDER BY puntos DESC, tiempo ASC, nombre ASC"
    );
    $stmt->execute([$_GET['comp']]);
    $equipos = $stmt->fetchAll(PDO::FETCH_ASSOC);
}

echo json_encode($equipos);
