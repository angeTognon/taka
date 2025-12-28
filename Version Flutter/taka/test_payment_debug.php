<?php
// Script de test et debug pour le paiement
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Methods: POST, OPTIONS");
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}
header('Content-Type: application/json');

// Log toutes les requêtes entrantes
error_log("=== TEST PAYMENT DEBUG ===");
error_log("Request Method: " . $_SERVER['REQUEST_METHOD']);
error_log("Content Type: " . ($_SERVER['CONTENT_TYPE'] ?? 'Not set'));
error_log("Raw Input: " . file_get_contents('php://input'));

$input = json_decode(file_get_contents('php://input'), true);

if ($input === null) {
    echo json_encode([
        'error' => 'Invalid JSON input', 
        'raw_input' => file_get_contents('php://input'),
        'json_error' => json_last_error_msg()
    ]);
    exit;
}

error_log("Parsed Input: " . json_encode($input));

// Vérifier les paramètres critiques
$currency = $input['currency'] ?? 'NOT_SET';
$country = $input['country'] ?? 'NOT_SET';
$amount = $input['amount'] ?? 'NOT_SET';
$email = $input['email'] ?? 'NOT_SET';
$first_name = $input['first_name'] ?? 'NOT_SET';
$last_name = $input['last_name'] ?? 'NOT_SET';
$user_id = $input['user_id'] ?? 'NOT_SET';
$book_id = $input['book_id'] ?? 'NOT_SET';

error_log("Currency: $currency");
error_log("Country: $country");
error_log("Amount: $amount");
error_log("Email: $email");
error_log("First Name: $first_name");
error_log("Last Name: $last_name");
error_log("User ID: $user_id");
error_log("Book ID: $book_id");

// Configuration des méthodes par devise
$methods_by_currency = [
    "XOF" => ["moov_bj", "mtn_bj", "moov_bf", "mtn_bf", "moov_ci", "mtn_ci", "moov_ml", "mtn_ml", "moov_ne", "mtn_ne", "moov_sn", "mtn_sn", "moov_tg", "mtn_tg", "moov_gw", "mtn_gw"],
    "XAF" => ["mtn_cm", "orange_cm", "mtn_cf", "orange_cf", "mtn_cg", "orange_cg", "mtn_gq", "orange_gq", "mtn_ga", "orange_ga", "mtn_td", "orange_td"],
    "NGN" => ["airtel_ng", "mtn_ng"],
    "GHS" => ["mtn_gh", "tigo_gh", "vodafone_gh"],
    "KES" => ["mpesa_ke"],
    "TZS" => ["airtel_tz", "halopesa_tz", "mpesa_tz", "tigo_tz"],
    "UGX" => ["airtel_ug", "mtn_ug"],
    "RWF" => ["airtel_rw", "mtn_rw"],
    "ZMW" => ["airtel_zm", "mtn_zm", "zamtel_zm"],
    "MWK" => ["airtel_mw", "tnm_mw"],
    "CDF" => ["airtel_cd", "orange_cd", "vodacom_cd"],
    "ETB" => ["telebirr_et"],
    "ZAR" => ["mtn_za", "vodacom_za"],
    "EUR" => ["card"],
    "USD" => ["card"],
    "GBP" => ["card"],
    "CAD" => ["card"],
    "CHF" => ["card"],
    "BRL" => ["card"],
    "CNY" => ["card"],
    "JPY" => ["card"],
    "INR" => ["card"],
    "AUD" => ["card"],
    "NZD" => ["card"],
    "DZD" => ["card"],
    "MAD" => ["card"],
    "TND" => ["card"],
    "EGP" => ["card"],
    "LYD" => ["card"],
    "SDG" => ["card"],
];

// Sélection des méthodes de paiement
$methods = $methods_by_currency[$currency] ?? $methods_by_currency["XOF"];

// Validation des données
$errors = [];

if ($amount === 'NOT_SET' || $amount <= 0) {
    $errors[] = "Montant invalide: $amount";
}

if ($email === 'NOT_SET' || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
    $errors[] = "Email invalide: $email";
}

if ($first_name === 'NOT_SET' || empty($first_name)) {
    $errors[] = "Prénom manquant: $first_name";
}

if ($last_name === 'NOT_SET' || empty($last_name)) {
    $errors[] = "Nom manquant: $last_name";
}

if ($user_id === 'NOT_SET' || empty($user_id)) {
    $errors[] = "User ID manquant: $user_id";
}

if ($book_id === 'NOT_SET' || empty($book_id)) {
    $errors[] = "Book ID manquant: $book_id";
}

if (!empty($errors)) {
    echo json_encode([
        'error' => 'Données de validation manquantes',
        'details' => $errors,
        'received_data' => $input,
        'methods_for_currency' => $methods
    ]);
    exit;
}

// Test de l'API Moneroo
$url = 'https://api.moneroo.io/v1/payments/initialize';
$headers = [
    'Content-Type: application/json',
    'Authorization: Bearer pvk_ko62b8|01K5CEF100KW1V975FMKDB0J7Z',
    'Accept: application/json'
];

$data = [
    "amount" => floatval($amount),
    "currency" => $currency,
    "description" => "Test achat livre",
    "customer" => [
        "email" => $email,
        "first_name" => $first_name,
        "last_name" => $last_name
    ],
    "return_url" => "https://takaafrica.com",
    "metadata" => [
        "user_id" => $user_id,
        "book_id" => $book_id,
        "currency" => $currency,
        "country" => $country
    ],
    "methods" => $methods
];

error_log("Données envoyées à Moneroo: " . json_encode($data));

$ch = curl_init($url);
curl_setopt($ch, CURLOPT_POST, 1);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
curl_setopt($ch, CURLOPT_TIMEOUT, 30);

$response = curl_exec($ch);
$httpcode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$curl_error = curl_error($ch);
curl_close($ch);

error_log("Code de réponse HTTP: $httpcode");
error_log("Réponse Moneroo: " . $response);
error_log("Erreur cURL: " . $curl_error);

if ($curl_error) {
    echo json_encode([
        'error' => 'Erreur cURL',
        'curl_error' => $curl_error,
        'data_sent' => $data
    ]);
    exit;
}

if ($httpcode != 201) {
    echo json_encode([
        'error' => 'Erreur Moneroo API',
        'httpcode' => $httpcode,
        'response' => $response,
        'data_sent' => $data,
        'currency' => $currency,
        'country' => $country,
        'methods' => $methods
    ]);
    exit;
}

$response_data = json_decode($response, true);

if (isset($response_data['data']['checkout_url'])) {
    echo json_encode([
        'success' => true,
        'checkout_url' => $response_data['data']['checkout_url'],
        'debug_info' => [
            'currency' => $currency,
            'country' => $country,
            'amount' => $amount,
            'methods' => $methods,
            'moneroo_response' => $response_data
        ]
    ]);
} else {
    echo json_encode([
        'error' => 'Pas de checkout_url dans la réponse',
        'response' => $response_data,
        'data_sent' => $data
    ]);
}
?>
















