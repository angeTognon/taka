<?php
header('Content-Type: application/json');
require 'taka_api_payout.php'; // Ton fichier avec la fonction sendMonerooPayout

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);

    $author = [
        'id' => strval($data['author_id']),
        'email' => $data['email'],
        'first_name' => $data['first_name'],
        'last_name' => $data['last_name']
    ];
    $amount = intval($data['amount']);
    $currency = 'USD'; // <-- Ajoute cette ligne
    $description = $data['description'];
    $method = $data['method'];

$recipient = ['account_number' => '4149518162'];
    // Passe la devise à la fonction
    $result = sendMonerooPayout($author, $amount, $currency, $description, $method, $recipient);

    echo json_encode($result['response']);
    exit;
}
echo json_encode(['success' => false, 'error' => 'Méthode non supportée']);