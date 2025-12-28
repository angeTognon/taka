<?php
header('Content-Type: application/json');
include 'db.php';

$total_users = $pdo->query("SELECT COUNT(*) FROM taka_users")->fetchColumn();
$total_books = $pdo->query("SELECT COUNT(*) FROM taka_books")->fetchColumn();
$total_pending = $pdo->query("SELECT COUNT(*) FROM taka_books WHERE statut_validation = 'En attente de validation'")->fetchColumn();
$total_validated = $pdo->query("SELECT COUNT(*) FROM taka_books WHERE statut_validation = 'Validé'")->fetchColumn();

echo json_encode([
  'total_users' => intval($total_users),
  'total_books' => intval($total_books),
  'total_pending' => intval($total_pending),
  'total_validated' => intval($total_validated),
]);