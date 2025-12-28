<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit; // Réponse rapide pour les préflight requests
}
include 'db.php'; // Assure-toi que $pdo est défini dans ce fichier

// Register
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_GET['action']) && $_GET['action'] === 'register') {
    $data = json_decode(file_get_contents('php://input'), true);
    $full_name = $data['full_name'] ?? '';
    $email = $data['email'] ?? '';
    $password = $data['password'] ?? '';
    $ref = $data['ref'] ?? null; // <-- Ajouté

    if (!$full_name || !$email || !$password) {
        echo json_encode(['error' => 'Champs requis manquants']);
        exit;
    }
    $hash = password_hash($password, PASSWORD_DEFAULT);
    $stmt = $pdo->prepare('INSERT INTO taka_users (full_name, email, password) VALUES (?, ?, ?)');
    try {
        $stmt->execute([$full_name, $email, $hash]);
        $user_id = $pdo->lastInsertId();

        // --- Affiliation générale ---
        if ($ref && preg_match('/TAKA-AFF-2024-USER(\d+)/', $ref, $matches)) {
            $affiliate_user_id = intval($matches[1]);
            // Montant à créditer (exemple: 1000 FCFA)
            $amount = 0;
            $type = 'general';
            $stmt2 = $pdo->prepare('INSERT INTO taka_affiliate_earnings (user_id, amount, type) VALUES (?, ?, ?)');
            $stmt2->execute([$affiliate_user_id, $amount, $type]);
        }

        echo json_encode(['success' => true, 'id' => $user_id]);
    } catch (PDOException $e) {
        echo json_encode(['error' => 'Email déjà utilisé']);
    }
    exit;
}

// Login
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_GET['action']) && $_GET['action'] === 'login') {
    $data = json_decode(file_get_contents('php://input'), true);
    $email = $data['email'] ?? '';
    $password = $data['password'] ?? '';
    $stmt = $pdo->prepare('SELECT * FROM taka_users WHERE email = ?');
    $stmt->execute([$email]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    if ($user && password_verify($password, $user['password'])) {
        unset($user['password']);
        echo json_encode(['success' => true, 'user' => $user]);
    } else {
        echo json_encode(['error' => 'Identifiants invalides']);
    }
    exit;
}

// Get user by ID
if ($_SERVER['REQUEST_METHOD'] === 'GET' && isset($_GET['id'])) {
    $stmt = $pdo->prepare('SELECT id, full_name, email, created_at FROM taka_users WHERE id = ?');
    $stmt->execute([$_GET['id']]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    echo json_encode($user ?: []);
    exit;
}

echo json_encode(['error' => 'Requête invalide']);