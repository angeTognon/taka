<?php
// filepath: /var/www/html/moneroo_init_book.php

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

// Liste des méthodes compatibles par devise
$methods_by_currency = [
    "XOF" => ["moov_bj", "mtn_bj"],
    "CDF" => ["airtel_cd", "orange_cd", "vodacom_cd"],
    "XAF" => ["mtn_cm", "orange_cm", "eu_mobile_cm"],
    "GHS" => ["mtn_gh", "tigo_gh", "vodafone_gh"],
    "NGN" => ["airtel_ng", "mtn_ng"],
    "RWF" => ["airtel_rw", "mtn_rw"],
    "TZS" => ["airtel_tz", "halopesa_tz", "mpesa_tz", "tigo_tz"],
    "UGX" => ["airtel_ug", "mtn_ug"],
    "ZMW" => ["airtel_zm", "mtn_zm", "zamtel_zm"],
    "MWK" => ["airtel_mw", "tnm_mw"],
    "KES" => ["mpesa_ke"],
];

$currency = isset($input['currency']) && !empty($input['currency']) ? $input['currency'] : "XOF";
$methods = $methods_by_currency[$currency] ?? $methods_by_currency["XOF"];
$amount = isset($input['amount']) ? floatval($input['amount']) : 0;
$description = isset($input['description']) ? $input['description'] : "Achat livre";
$email = isset($input['email']) ? $input['email'] : "";
$first_name = isset($input['first_name']) ? $input['first_name'] : "";
$last_name = isset($input['last_name']) ? $input['last_name'] : "";
$return_url = isset($input['return_url']) && !empty($input['return_url']) ? $input['return_url'] : "https://takaafrica.com";
$user_id = isset($input['user_id']) ? $input['user_id'] : "";
$book_id = isset($input['book_id']) ? $input['book_id'] : "";

// Construction des metadata
$metadata = [
    "user_id" => $user_id,
    "book_id" => $book_id
];
if (isset($input['ref']) && !empty($input['ref'])) {
    $metadata['ref'] = $input['ref'];
}

$data = [
    "amount" => $amount,
    "currency" => $currency,
    "description" => $description,
    "customer" => [
        "email" => $email,
        "first_name" => $first_name,
        "last_name" => $last_name
    ],
    "return_url" => $return_url,
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