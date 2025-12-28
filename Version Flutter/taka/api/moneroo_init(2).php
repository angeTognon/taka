<?php
// filepath: /Users/mac/Documents/taka2/moneroo_init.php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Methods: POST, OPTIONS");
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}
header('Content-Type: application/json');

$input = json_decode(file_get_contents('php://input'), true);

$url = 'https://api.moneroo.io/v1/payments/initialize';
$headers = [
    'Content-Type: application/json',
    'Authorization: Bearer pvk_ko62b8|01K5CEF100KW1V975FMKDB0J7Z',
    'Accept: application/json'
];

// Liste des méthodes compatibles par devise (sans djamo_ci ni djamo_sn)
$methods_by_currency = [
    "XOF" => [
        "moov_bj",
        "mtn_bj"
    ],
    // ... autres devises ...
];

$currency = isset($input['currency']) && !empty($input['currency']) ? $input['currency'] : "XOF";
$methods = $methods_by_currency[$currency] ?? $methods_by_currency["XOF"];

// Construction des metadata dynamiquement
$metadata = [
    "user_id" => $input['user_id']
];
if (isset($input['book_id']) && !empty($input['book_id'])) {
    $metadata['book_id'] = $input['book_id'];
}
if (isset($input['plan_id']) && !empty($input['plan_id'])) {
    $metadata['plan_id'] = $input['plan_id'];
}
if (isset($input['ref']) && !empty($input['ref'])) {
    $metadata['ref'] = $input['ref'];
}

$data = [
    "amount" => intval($input['amount']),
    "currency" => $currency,
    "description" => $input['description'],
    "customer" => [
        "email" => $input['email'],
        "first_name" => $input['first_name'],
        "last_name" => $input['last_name']
    ],
    "return_url" => isset($input['return_url']) && !empty($input['return_url']) ? $input['return_url'] : "https://takaafrica.com",
    "metadata" => $metadata,
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
echo json_encode(['checkout_url' => $response_data['data']['checkout_url']]);