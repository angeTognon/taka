<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') exit;

include 'db.php'; // $pdo

// GET: Récupérer le montant total du wallet pour un user
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $user_id = $_GET['user_id'] ?? null;
    if ($user_id) {
        $stmt = $pdo->prepare("SELECT total_amount FROM taka_wallet WHERE user_id = ?");
        $stmt->execute([$user_id]);
        $amount = $stmt->fetchColumn();
        echo json_encode(['success' => true, 'total_amount' => intval($amount)]);
    } else {
        echo json_encode(['success' => false, 'error' => 'user_id requis']);
    }
    exit;
}

// POST: Insérer ou mettre à jour le montant total du wallet pour un user
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);
    $user_id = $data['user_id'] ?? null;
    $total_amount = $data['total_amount'] ?? null;

    if ($user_id && $total_amount !== null) {
        // Vérifie si le user existe déjà dans le wallet
        $stmt = $pdo->prepare("SELECT id FROM taka_wallet WHERE user_id = ?");
        $stmt->execute([$user_id]);
        if ($stmt->fetchColumn()) {
            // Update
            $stmt = $pdo->prepare("UPDATE taka_wallet SET total_amount = ? WHERE user_id = ?");
            $stmt->execute([$total_amount, $user_id]);
        } else {
            // Insert
            $stmt = $pdo->prepare("INSERT INTO taka_wallet (user_id, total_amount) VALUES (?, ?)");
            $stmt->execute([$user_id, $total_amount]);
        }
        echo json_encode(['success' => true]);
    } else {
        echo json_encode(['success' => false, 'error' => 'user_id et total_amount requis']);
    }
    exit;
}

echo json_encode(['success' => false, 'error' => 'Méthode non supportée']);