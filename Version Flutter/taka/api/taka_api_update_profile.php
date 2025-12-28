<?php
header('Content-Type: application/json');
include 'db.php';

$user_id = $_POST['user_id'] ?? null;
$full_name = $_POST['full_name'] ?? null;

if (!$user_id || !$full_name) {
  echo json_encode(['success' => false, 'error' => 'Paramètres manquants']);
  exit;
}

$stmt = $pdo->prepare("UPDATE taka_users SET full_name = ? WHERE id = ?");
$success = $stmt->execute([$full_name, $user_id]);

echo json_encode(['success' => $success]);