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
    // Définir les noms des mois en français
    $monthNames = [
        1 => 'Jan', 2 => 'Fév', 3 => 'Mar', 4 => 'Avr', 
        5 => 'Mai', 6 => 'Jun', 7 => 'Jul', 8 => 'Aoû', 
        9 => 'Sep', 10 => 'Oct', 11 => 'Nov', 12 => 'Déc'
    ];
    
    // Générer les 6 derniers mois
    $salesData = [];
    $currentMonth = intval(date('n')); // Mois actuel (1-12)
    $currentYear = intval(date('Y'));  // Année actuelle
    
    for ($i = 5; $i >= 0; $i--) {
        // Calculer le mois et l'année pour chaque itération
        $targetMonth = $currentMonth - $i;
        $targetYear = $currentYear;
        
        // Gérer le passage à l'année précédente
        if ($targetMonth <= 0) {
            $targetMonth += 12;
            $targetYear -= 1;
        }
        
        // Récupérer les ventes pour ce mois spécifique
        $sql = "SELECT SUM(sales) as total_sales 
                FROM books 
                WHERE user_id = ? 
                AND MONTH(created_at) = ? 
                AND YEAR(created_at) = ?";
        
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("iii", $user_id, $targetMonth, $targetYear);
        $stmt->execute();
        $result = $stmt->get_result();
        $row = $result->fetch_assoc();
        $stmt->close();
        
        $totalSales = $row['total_sales'] ? intval($row['total_sales']) : 0;
        
        $salesData[] = [
            'month' => $monthNames[$targetMonth],
            'sales' => $totalSales,
            'year' => $targetYear,
            'monthNumber' => $targetMonth
        ];
    }
    
    // Retourner les données
    echo json_encode([
        'success' => true,
        'sales' => $salesData,
        'current_month' => $monthNames[$currentMonth],
        'current_year' => $currentYear
    ]);

} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'error' => 'Erreur lors de la récupération des données de ventes: ' . $e->getMessage()
    ]);
}

$conn->close();
?>

