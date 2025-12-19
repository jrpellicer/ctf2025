<?php
require 'db.php';

if ($_POST) {
    $codigo = $_POST['codigo'];
    $nombre = $_POST['nombre'];

    $stmt = $pdo->prepare(
        "INSERT INTO competiciones (codigo, nombre) VALUES (?, ?)"
    );
    $stmt->execute([$codigo, $nombre]);

    echo "Competición creada";
}
?>

<form method="post">
    Código: <input name="codigo" required><br>
    Nombre: <input name="nombre" required><br>
    <button>Crear competición</button>
</form>