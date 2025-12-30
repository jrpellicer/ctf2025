<?php
// Esto forzará al navegador a interpretar todo como UTF-8 puro
header('Content-Type: text/html; charset=utf-8');
require 'db.php';


/* Conversión Markdown básica y segura */
function markdownBasico(string $text): string
{
    $text = htmlspecialchars($text, ENT_QUOTES, 'UTF-8');

    // Títulos
    $text = preg_replace('/^### (.+)$/m', '<h3>$1</h3>', $text);
    $text = preg_replace('/^## (.+)$/m', '<h2>$1</h2>', $text);
    $text = preg_replace('/^# (.+)$/m', '<h1>$1</h1>', $text);

    // Negrita y cursiva
    $text = preg_replace('/\*\*(.+?)\*\*/', '<strong>$1</strong>', $text);
    $text = preg_replace('/\*(.+?)\*/', '<em>$1</em>', $text);

    // Listas
    $text = preg_replace('/^- (.+)$/m', '<li>$1</li>', $text);
    $text = preg_replace('/(<li>.*<\/li>)/s', '<ul>$1</ul>', $text);

    // Saltos de línea
    return nl2br($text);
}

$retos = $pdo->query(
    "SELECT id, nombre, puntos, descripcion
     FROM retos
     ORDER BY id ASC"
)->fetchAll();
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Retos</title>
    <link rel="stylesheet" href="css/estilos.css">
</head>
<body>
    <div class="container">
        <h1>Retos de la competición</h1>

        <?php foreach ($retos as $r): ?>
            <div class="reto-card">
                <div class="reto-header">
                    <span class="reto-nombre">
                        Reto <?= htmlspecialchars($r['id']) ?>: <?= htmlspecialchars($r['nombre']) ?>
                    </span>
                    <span class="reto-puntos">
                        <?= (int)$r['puntos'] ?> pts
                    </span>
                </div>

                <?php if (!empty($r['descripcion'])): ?>
                    <div class="reto-descripcion">
                        <?= markdownBasico($r['descripcion']) ?>
                    </div>
                <?php else: ?>
                    <div class="reto-descripcion empty">
                        Sin descripción
                    </div>
                <?php endif; ?>
            </div>
        <?php endforeach; ?>
    </div>
</body>
</html>
