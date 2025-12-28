<?php
header('Content-Type: application/json');
include 'db.php';

$user_id = $_GET['user_id'] ?? null;
$period = $_GET['period'] ?? 'month'; // Par défaut : mois

if (!$user_id) {
  echo json_encode(['success' => false, 'error' => 'user_id manquant']);
  exit;
}

// Ajoute le filtre de période
$dateFilter = '';
if ($period === 'week') {
  $dateFilter = "AND created_at >= DATE_SUB(NOW(), INTERVAL 1 WEEK)";
} elseif ($period === 'month') {
  $dateFilter = "AND created_at >= DATE_SUB(NOW(), INTERVAL 1 MONTH)";
} elseif ($period === 'year') {
  $dateFilter = "AND created_at >= DATE_SUB(NOW(), INTERVAL 1 YEAR)";
} elseif ($period === 'all') {
  // Pas de filtre de date - récupérer tous les livres
  $dateFilter = '';
}

$stmt = $pdo->prepare("SELECT * FROM taka_books WHERE user_id = ? $dateFilter ORDER BY created_at DESC");
$stmt->execute([$user_id]);
$books = $stmt->fetchAll(PDO::FETCH_ASSOC);

foreach ($books as &$book) {
    $bookId = $book['id'];

    // Ventes
    $stmt2 = $pdo->prepare('SELECT COUNT(*) FROM user_book_purchases WHERE book_id = ?');
    $stmt2->execute([$bookId]);
    $book['sales'] = (int)$stmt2->fetchColumn();

    // Revenu
    $price = is_numeric($book['price']) ? (int)$book['price'] : 0;
    $book['revenue'] = $book['sales'] * $price;

    // Lecteurs uniques
    $stmt3 = $pdo->prepare('SELECT COUNT(DISTINCT user_id) FROM user_book_purchases WHERE book_id = ?');
    $stmt3->execute([$bookId]);
    $book['readers'] = (int)$stmt3->fetchColumn();

    // Statut, rating, publishDate (pour compatibilité Flutter)
    $book['status'] = 'Publié';
    $book['rating'] = 0;
    $book['publishDate'] = $book['created_at'];
}
unset($book);

echo json_encode(['success' => true, 'books' => $books]);