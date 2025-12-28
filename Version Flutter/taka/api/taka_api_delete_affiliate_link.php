<?php
header('Content-Type: application/json');
require_once 'db.php';

$input = json_decode(file_get_contents('php://input'), true);
$link_id = isset($input['link_id']) ? intval($input['link_id']) : 0;
$user_id = isset($input['user_id']) ? intval($input['user_id']) : 0;

if ($link_id <= 0 || $user_id <= 0) {
    echo json_encode(['success' => false, 'error' => 'Paramètres manquants']);
    exit;
}

$sql = "DELETE FROM taka_affiliate_links WHERE id = ? AND user_id = ?";
$stmt = $pdo->prepare($sql);
$result = $stmt->execute([$link_id, $user_id]);

if ($result) {
    echo json_encode(['success' => true]);
} else {
    echo json_encode(['success' => false, 'error' => 'Erreur lors de la suppression']);
}
?>