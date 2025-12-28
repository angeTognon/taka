<?php
header('Content-Type: application/json');
include 'db.php';

$user_id = $_GET['user_id'] ?? null;
if (!$user_id) {
  echo json_encode(['success' => false, 'error' => 'user_id manquant']);
  exit;
}

// Exclure les livres déjà achetés ou lus par l'utilisateur
$stmt = $pdo->prepare("
  SELECT * FROM taka_books
  WHERE id NOT IN (
    SELECT book_id FROM user_book_purchases WHERE user_id = ?
  )
  ORDER BY RAND()
  LIMIT 6
");
$stmt->execute([$user_id]);
$books = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo json_encode(['success' => true, 'books' => $books]);