<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') exit;

include 'db.php'; // $pdo

// Créer un abonnement
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_GET['action']) && $_GET['action'] === 'subscribe') {
    $data = json_decode(file_get_contents('php://input'), true);
    $user_id = $data['user_id'] ?? null;
    $plan = $data['plan'] ?? '';
    $payment_method = $data['payment_method'] ?? '';
    $transaction_ref = $data['transaction_ref'] ?? null;
    $status = $data['status'] ?? 'en attente'; // <-- Prend le statut envoyé, sinon "en attente"

    if (!$user_id || !$plan || !$payment_method) {
        echo json_encode(['error' => 'Champs requis manquants']);
        exit;
    }

    // Calcul de la date d'expiration selon le plan (1 mois ici)
    $expires_at = date('Y-m-d H:i:s', strtotime('+1 month'));

    $stmt = $pdo->prepare('INSERT INTO taka_subscriptions (user_id, plan, payment_method, status, started_at, expires_at, transaction_ref) VALUES (?, ?, ?, ?, NOW(), ?, ?)');
    $stmt->execute([$user_id, $plan, $payment_method, $status, $expires_at, $transaction_ref]);
    echo json_encode(['success' => true, 'subscription_id' => $pdo->lastInsertId()]);
    exit;
}

// Récupérer les plans (optionnel, statique)
if ($_SERVER['REQUEST_METHOD'] === 'GET' && isset($_GET['action']) && $_GET['action'] === 'plans') {
    echo json_encode([
        ['id' => 'essential', 'name' => 'Essentielle', 'price' => 2000, 'period' => 'mois', 'books' => 5],
        ['id' => 'comfort', 'name' => 'Confort', 'price' => 3500, 'period' => 'mois', 'books' => 10],
        ['id' => 'unlimited', 'name' => 'Illimitée', 'price' => 5000, 'period' => 'mois', 'books' => -1],
    ]);
    exit;
}

// Récupérer les abonnements d'un utilisateur (optionnel)
if ($_SERVER['REQUEST_METHOD'] === 'GET' && isset($_GET['user_id'])) {
    $stmt = $pdo->prepare('SELECT * FROM taka_subscriptions WHERE user_id = ? ORDER BY started_at DESC');
    $stmt->execute([$_GET['user_id']]);
    $subs = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo json_encode($subs);
    exit;
}

echo json_encode(['error' => 'Requête invalide']);