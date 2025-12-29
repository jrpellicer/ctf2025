<?php
require 'db.php';

// ---------- CONEXIÓN MYSQL ----------
$mysqli = new mysqli($host, $user, $pass, $db);

if ($mysqli->connect_error) {
    die("Error de conexión: " . $mysqli->connect_error);
}

// ---------- FUNCIÓN DE CIFRADO ----------
function cifrar(string $equipo_hex, string $reto_hex): string {
    $combinado = $equipo_hex . $reto_hex;

    // Hex → entero
    $v = intval(hexdec($combinado));

    // Rotación izquierda 11 bits (32 bits)
    $cifrado = (($v << 11) | ($v >> 21)) & 0xFFFFFFFF;

    // Hexadecimal de 8 caracteres
    return strtoupper(str_pad(dechex($cifrado), 8, "0", STR_PAD_LEFT));
}

// ---------- LEER DATOS ----------
$equipos = [];
$retos   = [];

// Equipos
$res = $mysqli->query("SELECT codigo_hex FROM equipos");
while ($row = $res->fetch_row()) {
    $equipos[] = $row[0];
}

// Retos
$res = $mysqli->query("SELECT codigo_hex FROM retos");
while ($row = $res->fetch_row()) {
    $retos[] = $row[0];
}

// ---------- MOSTRAR RESULTADOS ----------
echo "Equipo    Reto    -> Código cifrado\n";
echo str_repeat("-", 45) . "\n";

foreach ($equipos as $equipo) {
    foreach ($retos as $reto) {
        if (ctype_xdigit($equipo . $reto)) {
            echo str_pad($equipo, 8) . "  "
               . str_pad($reto, 6) . " -> "
               . cifrar($equipo, $reto) . PHP_EOL;
        } else {
            echo "ERROR: equipo=$equipo reto=$reto\n";
        }
    }
}

$mysqli->close();