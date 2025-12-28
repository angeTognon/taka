<?php
header('Content-Type: application/json');
include 'db.php';

$user_id = $_GET['user_id'] ?? null;
if (!$user_id) {
  echo json_encode(['success' => false, 'error' => 'user_id manquant']);
  exit;
}

$stmt = $pdo->prepare('SELECT id, user_id, amount, type, book_id, created_at FROM taka_affiliate_earnings WHERE user_id = ? ORDER BY created_at DESC');
$stmt->execute([$user_id]);
$earnings = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo json_encode([
  'success' => true,
  'earnings' => $earnings
]);