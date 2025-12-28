<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type');
header('Access-Control-Allow-Methods: GET, OPTIONS');
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') exit;

include 'db.php'; // $pdo

$user_id = isset($_GET['user_id']) ? intval($_GET['user_id']) : 0;
if (!$user_id) {
    echo json_encode(['error' => 'user_id requis']);
    exit;
}

// Stats globales
// Livres publiés
$stmt = $pdo->prepare("SELECT COUNT(*) FROM taka_books WHERE user_id = ?");
$stmt->execute([$user_id]);
$totalBooks = (int)$stmt->fetchColumn();

// Ventes totales & revenus
$stmt = $pdo->prepare("SELECT COUNT(*) as totalSales, COALESCE(SUM(amount),0) as totalRevenue FROM taka_sales WHERE user_id = ?");
$stmt->execute([$user_id]);
$salesData = $stmt->fetch(PDO::FETCH_ASSOC);
$totalSales = (int)$salesData['totalSales'];
$totalRevenue = (int)$salesData['totalRevenue'];

// Lecteurs uniques (distincts par user_id_acheteur)
$stmt = $pdo->prepare("SELECT COUNT(DISTINCT buyer_id) FROM taka_sales WHERE user_id = ?");
$stmt->execute([$user_id]);
$totalReaders = (int)$stmt->fetchColumn();

// Liste des livres + stats par livre
$stmt = $pdo->prepare("SELECT * FROM taka_books WHERE user_id = ?");
$stmt->execute([$user_id]);
$books = [];
while ($book = $stmt->fetch(PDO::FETCH_ASSOC)) {
    // Ventes, revenus, lecteurs, note moyenne pour chaque livre
    $book_id = $book['id'];
    $s = $pdo->prepare("SELECT COUNT(*) as sales, COALESCE(SUM(amount),0) as revenue, COUNT(DISTINCT buyer_id) as readers, COALESCE(AVG(rating),0) as rating
                        FROM taka_sales WHERE book_id = ?");
    $s->execute([$book_id]);
    $d = $s->fetch(PDO::FETCH_ASSOC);

    $books[] = [
        'id' => $book['id'],
        'title' => $book['title'],
        'status' => $book['plan'] === 'premium' ? 'Publié' : 'En révision',
        'sales' => (int)$d['sales'],
        'revenue' => (int)$d['revenue'],
        'rating' => round((float)$d['rating'], 1),
        'readers' => (int)$d['readers'],
        'publishDate' => substr($book['created_at'], 0, 10),
    ];
}

// Statistiques de ventes par mois (6 derniers mois)
$salesChart = [];
for ($i = 5; $i >= 0; $i--) {
    $month = date('Y-m', strtotime("-$i months"));
    $label = strftime('%b', strtotime($month . '-01')); // Jan, Fév, etc.
    $stmt = $pdo->prepare("SELECT COUNT(*) FROM taka_sales WHERE user_id = ? AND DATE_FORMAT(created_at, '%Y-%m') = ?");
    $stmt->execute([$user_id, $month]);
    $salesChart[] = [
        'month' => ucfirst($label),
        'sales' => (int)$stmt->fetchColumn(),
    ];
}

// Note moyenne globale
$stmt = $pdo->prepare("SELECT COALESCE(AVG(rating),0) FROM taka_sales WHERE user_id = ?");
$stmt->execute([$user_id]);
$avgRating = round((float)$stmt->fetchColumn(), 1);

// Taux d'achèvement (dummy, à remplacer si tu as une vraie table de lectures)
$completionRate = 0.78;

echo json_encode([
    'stats' => [
        'totalBooks' => $totalBooks,
        'totalSales' => $totalSales,
        'totalRevenue' => $totalRevenue,
        'totalReaders' => $totalReaders,
    ],
    'books' => $books,
    'salesChart' => $salesChart,
    'avgRating' => $avgRating,
    'completionRate' => $completionRate,
]);