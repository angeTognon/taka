<?php
header('Content-Type: application/json');
include 'db.php';

$id = $_POST['id'] ?? null;
$user_id = $_POST['user_id'] ?? null;

if (!$id || !$user_id) {
  echo json_encode(['success' => false, 'error' => 'Paramètres manquants']);
  exit;
}

// Optionnel : supprimer les fichiers associés (file_path, cover_path, author_photo_path)
$stmt = $pdo->prepare('SELECT file_path, cover_path, author_photo_path FROM taka_books WHERE id=? AND user_id=?');
$stmt->execute([$id, $user_id]);
$book = $stmt->fetch(PDO::FETCH_ASSOC);

foreach (['file_path', 'cover_path', 'author_photo_path'] as $key) {
  if (!empty($book[$key]) && file_exists($book[$key])) {
    @unlink($book[$key]);
  }
}

// Supprime le livre
$stmt = $pdo->prepare('DELETE FROM taka_books WHERE id=? AND user_id=?');
$success = $stmt->execute([$id, $user_id]);

echo json_encode(['success' => $success]);