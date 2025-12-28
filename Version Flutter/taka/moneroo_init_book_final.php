<?php
// Version finale avec validation des données
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Methods: POST, OPTIONS");
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}
header('Content-Type: application/json');

$input = json_decode(file_get_contents('php://input'), true);

// Log pour debug
error_log("=== MONEROO BOOK INIT DEBUG ===");
error_log("Input reçu: " . json_encode($input));

$url = 'https://api.moneroo.io/v1/payments/initialize';
$headers = [
    'Content-Type: application/json',
    'Authorization: Bearer pvk_ko62b8|01K5CEF100KW1V975FMKDB0J7Z',
    'Accept: application/json'
];

// Configuration des méthodes par devise
$methods_by_currency = [
    "XOF" => ["moov_bj", "mtn_bj"],
    "EUR" => ["card"],
    "USD" => ["card"],
    "GBP" => ["card"],
    "XAF" => ["mtn_cm", "orange_cm"],
    "NGN" => ["airtel_ng", "mtn_ng"],
    "GHS" => ["mtn_gh", "tigo_gh"],
    "KES" => ["mpesa_ke"],
    "TZS" => ["airtel_tz", "halopesa_tz", "mpesa_tz", "tigo_tz"],
    "UGX" => ["airtel_ug", "mtn_ug"],
    "RWF" => ["airtel_rw", "mtn_rw"],
    "ZMW" => ["airtel_zm", "mtn_zm", "zamtel_zm"],
    "MWK" => ["airtel_mw", "tnm_mw"],
    "CDF" => ["airtel_cd", "orange_cd", "vodacom_cd"],
    "ETB" => ["telebirr_et"],
    "ZAR" => ["mtn_za", "vodacom_za"],
];

// Validation et récupération des données
$currency = isset($input['currency']) && !empty($input['currency']) ? $input['currency'] : "XOF";
$country = isset($input['country']) ? $input['country'] : "Bénin";
$amount = isset($input['amount']) ? floatval($input['amount']) : 0;
$email = isset($input['email']) && !empty($input['email']) ? $input['email'] : "";
$first_name = isset($input['first_name']) && !empty($input['first_name']) ? $input['first_name'] : "";
$last_name = isset($input['last_name']) && !empty($input['last_name']) ? $input['last_name'] : "";
$user_id = isset($input['user_id']) && !empty($input['user_id']) ? $input['user_id'] : "";
$book_id = isset($input['book_id']) && !empty($input['book_id']) ? $input['book_id'] : "";

// Validation des données requises
$errors = [];

if ($amount <= 0) {
    $errors[] = "Le montant doit être supérieur à 0";
}

if (empty($email) || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
    $errors[] = "Email valide requis";
}

if (empty($first_name)) {
    $errors[] = "Prénom requis";
}

if (empty($last_name)) {
    $errors[] = "Nom requis";
}

if (empty($user_id)) {
    $errors[] = "User ID requis";
}

if (empty($book_id)) {
    $errors[] = "Book ID requis";
}

// Si des erreurs de validation, retourner l'erreur
if (!empty($errors)) {
    http_response_code(400);
    echo json_encode([
        'error' => 'Données de validation manquantes',
        'details' => $errors,
        'received_data' => $input
    ]);
    exit;
}

error_log("Devise sélectionnée: $currency");
error_log("Pays sélectionné: $country");
error_log("Montant: $amount");
error_log("Email: $email");

$methods = $methods_by_currency[$currency] ?? $methods_by_currency["XOF"];
error_log("Méthodes de paiement: " . json_encode($methods));

$description = isset($input['description']) ? $input['description'] : "Achat livre";
$return_url = isset($input['return_url']) && !empty($input['return_url']) ? $input['return_url'] : "https://takaafrica.com";

$metadata = [
    "user_id" => $user_id,
    "book_id" => $book_id,
    "currency" => $currency,
    "country" => $country
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

error_log("Données envoyées à Moneroo: " . json_encode($data));

$ch = curl_init($url);
curl_setopt($ch, CURLOPT_POST, 1);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);

$response = curl_exec($ch);
$httpcode = curl_getinfo($ch, CURLINFO_HTTP_CODE);

error_log("Code de réponse HTTP: $httpcode");
error_log("Réponse Moneroo: " . $response);

if ($httpcode != 201) {
    http_response_code($httpcode);
    $error_response = [
        'error' => 'Erreur Moneroo',
        'httpcode' => $httpcode,
        'response' => $response,
        'data_sent' => $data,
        'currency' => $currency,
        'country' => $country,
        'methods' => $methods
    ];
    error_log("Erreur détaillée: " . json_encode($error_response));
    echo json_encode($error_response);
    exit;
}

$response_data = json_decode($response, true);
error_log("Réponse décodée: " . json_encode($response_data));

if (isset($response_data['data']['checkout_url'])) {
    echo json_encode(['checkout_url' => $response_data['data']['checkout_url']]);
} else {
    error_log("Pas de checkout_url dans la réponse");
    echo json_encode(['error' => 'Pas de checkout_url dans la réponse', 'response' => $response_data]);
}
?>




















