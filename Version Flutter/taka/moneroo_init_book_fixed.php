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

// Liste complète des méthodes compatibles par devise
$methods_by_currency = [
    // Zone UEMOA (XOF)
    "XOF" => [
        "moov_bj", "mtn_bj",           // Bénin
        "moov_bf", "mtn_bf",           // Burkina Faso
        "moov_ci", "mtn_ci",           // Côte d'Ivoire
        "moov_ml", "mtn_ml",           // Mali
        "moov_ne", "mtn_ne",           // Niger
        "moov_sn", "mtn_sn",           // Sénégal
        "moov_tg", "mtn_tg",           // Togo
        "moov_gw", "mtn_gw"            // Guinée-Bissau
    ],
    
    // Zone CEMAC (XAF)
    "XAF" => [
        "mtn_cm", "orange_cm",         // Cameroun
        "mtn_cf", "orange_cf",         // Centrafrique
        "mtn_cg", "orange_cg",         // Congo
        "mtn_gq", "orange_gq",         // Guinée équatoriale
        "mtn_ga", "orange_ga",         // Gabon
        "mtn_td", "orange_td"          // Tchad
    ],
    
    // Autres pays africains
    "NGN" => ["airtel_ng", "mtn_ng"],  // Nigeria
    "GHS" => ["mtn_gh", "tigo_gh", "vodafone_gh"], // Ghana
    "KES" => ["mpesa_ke"],             // Kenya
    "TZS" => ["airtel_tz", "halopesa_tz", "mpesa_tz", "tigo_tz"], // Tanzanie
    "UGX" => ["airtel_ug", "mtn_ug"],  // Ouganda
    "RWF" => ["airtel_rw", "mtn_rw"],  // Rwanda
    "ZMW" => ["airtel_zm", "mtn_zm", "zamtel_zm"], // Zambie
    "MWK" => ["airtel_mw", "tnm_mw"],  // Malawi
    "CDF" => ["airtel_cd", "orange_cd", "vodacom_cd"], // RDC
    "ETB" => ["telebirr_et"],          // Éthiopie
    "ZAR" => ["mtn_za", "vodacom_za"], // Afrique du Sud
    
    // Pays occidentaux - AJOUTÉ POUR L'ITALIE ET AUTRES
    "EUR" => ["card"],                 // Europe (Italie, France, Allemagne, etc.)
    "USD" => ["card"],                 // États-Unis
    "GBP" => ["card"],                 // Royaume-Uni
    "CAD" => ["card"],                 // Canada
    "CHF" => ["card"],                 // Suisse
    
    // Autres devises
    "BRL" => ["card"],                 // Brésil
    "CNY" => ["card"],                 // Chine
    "JPY" => ["card"],                 // Japon
    "INR" => ["card"],                 // Inde
    "AUD" => ["card"],                 // Australie
    "NZD" => ["card"],                 // Nouvelle-Zélande
];

// Récupération de la devise et du pays
$currency = isset($input['currency']) && !empty($input['currency']) ? $input['currency'] : "XOF";
$country = isset($input['country']) ? $input['country'] : "Bénin";

// Log pour debug
error_log("Moneroo Book Init - Devise: $currency, Pays: $country");

// Sélection des méthodes de paiement
$methods = $methods_by_currency[$currency] ?? $methods_by_currency["XOF"];

// Si la devise n'est pas supportée, utiliser les méthodes par défaut
if (!isset($methods_by_currency[$currency])) {
    error_log("Devise non supportée: $currency, utilisation de XOF par défaut");
    $methods = $methods_by_currency["XOF"];
}

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
    "book_id" => $book_id,
    "currency" => $currency,
    "country" => $country,
    "type" => "book_purchase"
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

// Log des données envoyées pour debug
error_log("Moneroo Book Init - Données envoyées: " . json_encode($data));

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
        'data_sent' => $data,
        'currency' => $currency,
        'country' => $country,
        'methods' => $methods
    ]);
    exit;
}

$response_data = json_decode($response, true);
echo json_encode(['checkout_url' => $response_data['data']['checkout_url']]);
?>




















