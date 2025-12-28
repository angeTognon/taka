<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Gestion des requêtes OPTIONS (preflight)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Inclure le fichier de connexion à la base de données
require_once 'db.php';

// Récupérer l'ID de l'utilisateur depuis les paramètres GET
$user_id = isset($_GET['user_id']) ? intval($_GET['user_id']) : 0;

if ($user_id <= 0) {
    echo json_encode([
        'success' => false,
        'error' => 'ID utilisateur invalide'
    ]);
    exit;
}

try {
    // Calculer la note moyenne de tous les livres de l'auteur
    $sql = "SELECT AVG(rating) as averageRating FROM books WHERE user_id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $user_id);
    $stmt->execute();
    $result = $stmt->get_result();
    $row = $result->fetch_assoc();
    $averageRating = $row['averageRating'] ? floatval($row['averageRating']) : 0.0;
    $stmt->close();

    // Calculer le taux d'achèvement
    // Pour l'instant, on simule avec un calcul basé sur les ventes et lecteurs
    $sql2 = "SELECT 
                SUM(sales) as totalSales,
                SUM(readers) as totalReaders
            FROM books 
            WHERE user_id = ?";
    $stmt2 = $conn->prepare($sql2);
    $stmt2->bind_param("i", $user_id);
    $stmt2->execute();
    $result2 = $stmt2->get_result();
    $row2 = $result2->fetch_assoc();
    $totalSales = $row2['totalSales'] ? intval($row2['totalSales']) : 0;
    $totalReaders = $row2['totalReaders'] ? intval($row2['totalReaders']) : 0;
    
    // Calculer le taux d'achèvement (simulation: ratio lecteurs/ventes)
    // Plus ce ratio est élevé, plus les lecteurs reviennent lire les livres
    $completionRate = 0.0;
    if ($totalSales > 0) {
        // Calculer un taux entre 0 et 1
        $ratio = min($totalReaders / $totalSales, 1.5); // Max 150% pour avoir une marge
        $completionRate = min($ratio / 1.5, 1.0); // Normaliser entre 0 et 1
    }
    
    $stmt2->close();
    
    // Retourner les données
    echo json_encode([
        'success' => true,
        'averageRating' => round($averageRating, 2),
        'completionRate' => round($completionRate, 2)
    ]);

} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'error' => 'Erreur lors de la récupération des performances: ' . $e->getMessage()
    ]);
}

$conn->close();
?>

