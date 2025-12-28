<?php
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
    'Authorization: Bearer pvk_sandbox_n2n736|01K51H6VGYRPKQ1CYAQNAYKKSK',
    //'Authorization: Bearer pvk_zk8ffc|01K4W0XG8G2PSRVS3B9JSV4FWZ',
    'Accept: application/json'
];

// Liste des méthodes compatibles par devise (sans djamo_ci ni djamo_sn)
$methods_by_currency = [
    "XOF" => [
        "e_money_sn", "freemoney_sn", "moov_bj", "moov_ci", "moov_tg",
        "mtn_bj", "mtn_ci", "orange_ci", "orange_ml", "orange_sn", "togocel", "wave_ci", "wave_sn"
    ],
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

// Utilise la devise reçue ou XOF par défaut
$currency = isset($input['currency']) && !empty($input['currency']) ? $input['currency'] : "XOF";
$methods = $methods_by_currency[$currency] ?? $methods_by_currency["XOF"];

// Construction des données à envoyer à Moneroo
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
    "metadata" => [
        "user_id" => $input['user_id'],
        "plan_id" => $input['plan_id']
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
echo json_encode(['checkout_url' => $response_data['data']['checkout_url']]);