<?php
// ⚠️ Aucun espace ou saut de ligne avant ce bloc

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

header('Content-Type: application/json');

require_once 'db.php';

// Clé secrète Moneroo (à adapter selon ton environnement)
$secret = 'pvk_sandbox_n2n736|01K51H6VGYRPKQ1CYAQNAYKKSK';

// Vérification de la signature Moneroo
$payload = file_get_contents('php://input');
$signature = hash_hmac('sha256', $payload, $secret);

if (!isset($_SERVER['HTTP_X_MONEROO_SIGNATURE']) || !hash_equals($signature, $_SERVER['HTTP_X_MONEROO_SIGNATURE'])) {
    http_response_code(403);
    echo json_encode(['error' => 'Invalid signature']);
    exit;
}

$data = json_decode($payload, true);

if (!$data || !isset($data['event']) || !isset($data['data'])) {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid webhook']);
    exit;
}

// Vérifie que c'est bien un paiement réussi
if ($data['event'] !== 'payment.success' || $data['data']['status'] !== 'success') {
    echo json_encode(['status' => 'ignored']);
    exit;
}

$metadata = $data['data']['metadata'] ?? [];
$transaction_ref = $metadata['transaction_ref'] ?? null;

if (!$transaction_ref) {
    http_response_code(400);
    echo json_encode(['error' => 'No transaction_ref']);
    exit;
}

// Récupère le livre en attente
$stmt = $pdo->prepare('SELECT * FROM taka_books_pending WHERE transaction_ref = ?');
$stmt->execute([$transaction_ref]);
$pending = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$pending) {
    http_response_code(404);
    echo json_encode(['error' => 'Pending book not found']);
    exit;
}

// Insère le livre dans la table principale
$stmt2 = $pdo->prepare('INSERT INTO taka_books 
    (title, genre, language, summary, plan, author_bio, author_links, excerpt, quote, user_id, price_type, price, created_at)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())');
$stmt2->execute([
    $pending['title'],
    $pending['genre'],
    $pending['language'],
    $pending['summary'],
    $pending['plan'],
    $pending['author_bio'],
    $pending['author_links'],
    $pending['excerpt'],
    $pending['quote'],
    $pending['user_id'],
    $pending['price_type'],
    $pending['price']
]);

// Supprime l'entrée temporaire
$stmt3 = $pdo->prepare('DELETE FROM taka_books_pending WHERE transaction_ref = ?');
$stmt3->execute([$transaction_ref]);

echo json_encode(['success' => true, 'book_id' => $pdo->lastInsertId()]);