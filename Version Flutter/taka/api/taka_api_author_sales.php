<?php
header('Content-Type: application/json');
include 'db.php';

$user_id = $_GET['user_id'] ?? null;
if (!$user_id) {
  echo json_encode(['success' => false, 'error' => 'user_id manquant']);
  exit;
}

// Récupère tous les livres de l'auteur avec leur prix
$stmt = $pdo->prepare('SELECT id, price FROM taka_books WHERE user_id = ?');
$stmt->execute([$user_id]);
$books = $stmt->fetchAll(PDO::FETCH_ASSOC);

$totalSales = 0;
$totalRevenue = 0;
$totalReaders = 0;

if ($books) {
  $bookIds = array_column($books, 'id');
  $prices = [];
  foreach ($books as $b) {
    $prices[$b['id']] = is_numeric($b['price']) ? (int)$b['price'] : 0;
  }

  if (count($bookIds) > 0) {
    $in = implode(',', array_fill(0, count($bookIds), '?'));

    // Ventes et revenus
    $stmt2 = $pdo->prepare("SELECT book_id, COUNT(*) as sales FROM user_book_purchases WHERE book_id IN ($in) GROUP BY book_id");
    $stmt2->execute($bookIds);
    $salesData = $stmt2->fetchAll(PDO::FETCH_ASSOC);

    foreach ($salesData as $row) {
      $bookId = $row['book_id'];
      $sales = (int)$row['sales'];
      $price = $prices[$bookId] ?? 0;
      $totalSales += $sales;
      $totalRevenue += $price * $sales;
    }

    // Lecteurs uniques
    $stmt3 = $pdo->prepare("SELECT COUNT(DISTINCT user_id) as unique_readers FROM user_book_purchases WHERE book_id IN ($in)");
    $stmt3->execute($bookIds);
    $totalReaders = (int)($stmt3->fetchColumn() ?? 0);
  }
}

echo json_encode([
  'success' => true,
  'totalSales' => $totalSales,
  'totalRevenue' => $totalRevenue,
  'totalReaders' => $totalReaders
]);