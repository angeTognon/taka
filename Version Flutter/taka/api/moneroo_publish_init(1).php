<?php
// ⚠️ Aucun espace ou saut de ligne avant ce bloc

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

include 'db.php';

$input = json_decode(file_get_contents('php://input'), true);

if (!$input) {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid input']);
    exit;
}

// Génère une référence unique pour la transaction
$transaction_ref = uniqid('pub_', true);

// Stocke les infos du livre en attente (statut "pending")
$stmt = $pdo->prepare('INSERT INTO taka_books_pending 
    (transaction_ref, title, genre, language, summary, plan, author_bio, author_links, excerpt, quote, user_id, price_type, price, created_at)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())');
$stmt->execute([
    $transaction_ref,
    $input['title'] ?? '',
    $input['genre'] ?? '',
    $input['language'] ?? '',
    $input['summary'] ?? '',
    $input['plan'] ?? '',
    $input['authorBio'] ?? '',
    $input['authorLinks'] ?? '',
    $input['excerpt'] ?? '',
    $input['quote'] ?? '',
    $input['user_id'] ?? null,
    $input['priceType'] ?? 'gratuit',
    isset($input['price']) && $input['price'] !== '' ? intval($input['price']) : null
]);

// Prépare la requête Moneroo
$url = 'https://api.moneroo.io/v1/payments/initialize';
$headers = [
    'Content-Type: application/json',
    'Authorization: Bearer pvk_sandbox_n2n736|01K51H6VGYRPKQ1CYAQNAYKKSK',
    'Accept: application/json'
];

$methods_by_currency = [
    "XOF" => ["moov_bj", "mtn_bj"],
    // ... autres devises ...
];

$currency = $input['currency'] ?? "XOF";
$methods = $methods_by_currency[$currency] ?? $methods_by_currency["XOF"];

$data = [
    "amount" => intval($input['amount']),
    "currency" => $currency,
    "description" => $input['description'] ?? 'Publication TAKA',
    "customer" => [
        "email" => $input['email'] ?? '',
        "first_name" => $input['first_name'] ?? '',
        "last_name" => $input['last_name'] ?? ''
    ],
    "return_url" => $input['return_url'] ?? "https://takaafrica.com",
    "metadata" => [
        "user_id" => $input['user_id'],
        "transaction_ref" => $transaction_ref
    ],
    "methods" => $methods
];

$ch = curl_init($url);
curl_setopt($ch, CURLOPT_POST, 1);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);

$response = curl_exec($ch);
$httpcode = curl_getinfo($ch, CURLINFO_HTTP_CODE);

if ($httpcode != 201) {
    http_response_code($httpcode);
    echo json_encode([
        'error' => 'Erreur Moneroo',
        'httpcode' => $httpcode,
        'response' => $response,
        'data_sent' => $data
    ]);
    exit;
}

$response_data = json_decode($response, true);
echo json_encode([
    'checkout_url' => $response_data['data']['checkout_url'],
    'transaction_ref' => $transaction_ref
]);