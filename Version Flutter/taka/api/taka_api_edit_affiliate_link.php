<?php
header('Content-Type: application/json');
require_once 'db.php'; // Fichier de connexion à la base de données

// Récupère le corps JSON
$input = json_decode(file_get_contents('php://input'), true);

$link_id = isset($input['link_id']) ? intval($input['link_id']) : 0;
$user_id = isset($input['user_id']) ? intval($input['user_id']) : 0;
$type = isset($input['type']) ? $input['type'] : '';
$title = isset($input['title']) ? $input['title'] : '';
$book_id = isset($input['book_id']) ? intval($input['book_id']) : null;

if ($link_id <= 0 || $user_id <= 0 || empty($type) || empty($title)) {
    echo json_encode(['success' => false, 'error' => 'Paramètres manquants']);
    exit;
}

// Prépare la requête SQL
$sql = "UPDATE taka_affiliate_links SET type = ?, title = ?, book_id = ? WHERE id = ? AND user_id = ?";
$stmt = $pdo->prepare($sql);
$result = $stmt->execute([
    $type,
    $title,
    $book_id,
    $link_id,
    $user_id
]);

if ($result) {
    echo json_encode(['success' => true]);
} else {
    echo json_encode(['success' => false, 'error' => 'Erreur lors de la modification']);
}
?>