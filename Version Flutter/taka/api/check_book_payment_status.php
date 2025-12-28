<?php
// filepath: /var/www/html/check_book_payment_status.php
header('Content-Type: application/json');
require_once 'db.php';

$user_id = $_GET['user_id'] ?? '';
$book_id = $_GET['book_id'] ?? '';

$stmt = $pdo->prepare("SELECT id FROM user_book_purchases WHERE user_id=? AND book_id=?");
$stmt->execute([$user_id, $book_id]);
if ($stmt->fetch()) {
    echo json_encode(['status' => 'paid']);
} else {
    echo json_encode(['status' => 'pending']);
}