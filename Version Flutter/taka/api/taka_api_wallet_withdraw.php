<?php
header('Content-Type: application/json');
include 'db.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);
    $user_id = $data['user_id'] ?? null;
    if ($user_id) {
        // Vérifie si une demande existe déjà
        $stmt = $pdo->prepare("SELECT id FROM taka_wallet_withdraw WHERE user_id = ? AND status = 'pending'");
        $stmt->execute([$user_id]);
        if ($stmt->fetchColumn()) {
            echo json_encode(['success' => false, 'error' => 'Déjà demandé']);
        } else {
            $stmt = $pdo->prepare("INSERT INTO taka_wallet_withdraw (user_id, status, requested_at) VALUES (?, 'pending', NOW())");
            $stmt->execute([$user_id]);
            echo json_encode(['success' => true]);
        }
    } else {
        echo json_encode(['success' => false, 'error' => 'user_id requis']);
    }
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $user_id = $_GET['user_id'] ?? null;
    if ($user_id) {
        $stmt = $pdo->prepare("SELECT id FROM taka_wallet_withdraw WHERE user_id = ? AND status = 'pending'");
        $stmt->execute([$user_id]);
        echo json_encode(['requested' => $stmt->fetchColumn() ? true : false]);
    } else {
        echo json_encode(['requested' => false]);
    }
    exit;
}