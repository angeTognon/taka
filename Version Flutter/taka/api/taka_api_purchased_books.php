<?php
header('Content-Type: application/json');
include 'db.php';

$user_id = $_GET['user_id'] ?? null;
if (!$user_id) {
  echo json_encode(['success' => false, 'error' => 'user_id manquant']);
  exit;
}

// Récupère tous les livres achetés par l'utilisateur avec leurs infos
$stmt = $pdo->prepare("
  SELECT 
    b.id, b.title, b.genre, b.language, b.summary, b.file_path, b.cover_path, 
    b.plan, b.author_bio, b.author_photo_path, b.author_links, b.excerpt, b.quote, 
    b.price_type, b.price, b.created_at, p.purchased_at
  FROM user_book_purchases p
  JOIN taka_books b ON b.id = p.book_id
  WHERE p.user_id = ?
  ORDER BY p.purchased_at DESC
");
$stmt->execute([$user_id]);
$books = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo json_encode(['success' => true, 'books' => $books]);