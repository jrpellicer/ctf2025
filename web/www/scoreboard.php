<?php
require 'db.php';

$competiciones = $pdo->query("SELECT * FROM competiciones")->fetchAll();
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Clasificación de Equipos</title>
    <link rel="stylesheet" href="css/estilos.css">
</head>
<body>
    <?php include 'menu.php'; ?>
    <div class="container">
        <h1>Capture The Flag Windows Server</h1>

        <form id="formComp">
            <label for="comp">Competición:</label>
            <select name="comp" id="comp">
                <?php foreach ($competiciones as $c): ?>
                    <option value="<?= $c['id'] ?>">
                        <?= htmlspecialchars($c['nombre']) ?>
                    </option>
                <?php endforeach ?>
            </select>
        </form>

        <h2>Clasificación</h2>
        <table id="tablaClasificacion">
            <thead>
                <tr>
                    <th>#</th>
                    <th>Equipo</th>
                    <th>Puntos</th>
                    <th>Tiempo</th>
                </tr>
            </thead>
            <tbody>
                <!-- Se llenará dinámicamente -->
            </tbody>
        </table>
    </div>

<script>
let estadoAnterior = [];

/* Formatea segundos a HH:MM:SS */
function formatearTiempo(segundos) {
    if (segundos === null || segundos === undefined) {
        return '—';
    }

    const h = Math.floor(segundos / 3600);
    const m = Math.floor((segundos % 3600) / 60);
    const s = segundos % 60;

    return String(h).padStart(2, '0') + ':' +
           String(m).padStart(2, '0') + ':' +
           String(s).padStart(2, '0');
}

async function cargarClasificacion() {
    const comp = document.getElementById('comp').value;
    const response = await fetch(`ajax/get_clasificacion.php?comp=${comp}`);
    const equipos = await response.json();

    const tbody = document.querySelector('#tablaClasificacion tbody');
    tbody.innerHTML = '';

    // Crear un mapa de posiciones anteriores
    const mapaPosiciones = {};
    estadoAnterior.forEach((id, index) => {
        mapaPosiciones[id] = index;
    });

    equipos.forEach((e, i) => {
        const tr = document.createElement('tr');
        tr.dataset.id = e.codigo_hex;

        tr.innerHTML = `
            <td>${i + 1}</td>
            <td>${e.nombre}</td>
            <td>${e.puntos}</td>
            <td>${formatearTiempo(e.tiempo)}</td>
        `;

        // Animación por cambio de posición
        if (mapaPosiciones[e.codigo_hex] !== undefined) {
            if (i < mapaPosiciones[e.codigo_hex]) {
                tr.classList.add('move-up');
            } else if (i > mapaPosiciones[e.codigo_hex]) {
                tr.classList.add('move-down');
            }
        }

        tbody.appendChild(tr);
    });

    // Guardar nuevo estado
    estadoAnterior = equipos.map(e => e.codigo_hex);
}

// Cambio de competición
document.getElementById('comp').addEventListener('change', () => {
    estadoAnterior = [];
    cargarClasificacion();
});

// Actualización automática
setInterval(cargarClasificacion, 5000);

// Carga inicial
cargarClasificacion();
</script>
</body>
</html>
