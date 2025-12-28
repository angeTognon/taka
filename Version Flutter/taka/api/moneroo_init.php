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
    'Authorization: Bearer pvk_18ufnk|01K94R1FMCMFW5SWAWT9Q3QMDM',
    'Accept: application/json'
];

// Liste des méthodes compatibles par PAYS selon la documentation Moneroo
$methods_by_country = [
    // Zone UEMOA (XOF)
    "Bénin" => ["moov_bj", "mtn_bj", "card_xof"],
    "Burkina Faso" => ["moov_bf", "orange_bf", "card_xof"],
    "Côte d'Ivoire" => ["moov_ci", "mtn_ci", "orange_ci", "wave_ci", "card_xof"],
    "Guinée-Bissau" => ["card_xof"], // Pas de méthodes spécifiques dans la doc
    "Mali" => ["moov_ml", "orange_ml", "card_xof"],
    "Niger" => ["airtel_ne", "card_xof"],
    "Sénégal" => ["orange_sn", "wave_sn", "e_money_sn", "freemoney_sn", "card_xof"],
    "Togo" => ["moov_tg", "togocel", "card_xof"],
    
    // Zone CEMAC (XAF)
    "Cameroun" => ["mtn_cm", "orange_cm", "card_xaf"],
    "Centrafrique" => ["card_xaf"], // Pas de méthodes spécifiques dans la doc
    "Congo" => ["card_xaf"], // Pas de méthodes spécifiques dans la doc (Congo = CG, pas CD)
    "Guinée équatoriale" => ["card_xaf"], // Pas de méthodes spécifiques dans la doc
    "Gabon" => ["card_xaf"], // Pas de méthodes spécifiques dans la doc
    "Tchad" => ["card_xaf"], // Pas de méthodes spécifiques dans la doc
    
    // Autres pays africains
    "Nigeria" => ["airtel_ng", "mtn_ng"],
    "Ghana" => ["mtn_gh", "vodafone_gh", "card_ghs"],
    "Kenya" => ["mpesa_ke", "card_kes"],
    "Tanzanie" => ["airtel_tz", "halopesa_tz", "mpesa_tz", "tigo_tz", "card_tzs"],
    "Ouganda" => ["airtel_ug", "mtn_ug", "card_ugx"],
    "Rwanda" => ["airtel_rw", "mtn_rw"],
    "Zambie" => ["airtel_zm", "mtn_zm", "zamtel_zm"],
    "Malawi" => ["airtel_mw", "tnm_mw"],
    "Éthiopie" => [], // Pas dans la doc
    "Afrique du Sud" => ["card_zar"],
    "Guinée" => ["mtn_gf"],
    
    // Maghreb
    "Algérie" => [], // Pas dans la doc
    "Maroc" => [], // Pas dans la doc
    "Tunisie" => [], // Pas dans la doc
    "Égypte" => [], // Pas dans la doc
    "Libye" => [], // Pas dans la doc
    "Soudan" => [], // Pas dans la doc
    
    // Pays occidentaux - Utiliser card_usd (supporté mondialement)
    "France" => ["card_usd"], // USD supporté mondialement
    "Belgique" => ["card_usd"],
    "Allemagne" => ["card_usd"],
    "Italie" => ["card_usd"],
    "Espagne" => ["card_usd"],
    "Portugal" => ["card_usd"],
    "Pays-Bas" => ["card_usd"],
    "États-Unis" => ["card_usd", "crypto_usd"],
    "Royaume-Uni" => ["card_usd"], // Pas de GBP spécifique, utiliser USD
    "Canada" => ["card_usd"],
    "Suisse" => ["card_usd"], // Pas de CHF spécifique
    
    // Autres
    "Brésil" => ["card_usd"], // Pas de BRL spécifique
    "Chine" => ["card_usd"],
    "Japon" => ["card_usd"],
    "Inde" => ["card_usd"],
    "Australie" => ["card_usd"],
    "Nouvelle-Zélande" => ["card_usd"],
];

// Récupération du pays et de la devise
$country = isset($input['country']) && !empty($input['country']) ? $input['country'] : "Bénin";
$currency = isset($input['currency']) && !empty($input['currency']) ? $input['currency'] : "XOF";

// Log pour debug
error_log("Moneroo Init - Pays: $country, Devise: $currency");

// Sélection des méthodes selon le pays sélectionné
$methods = $methods_by_country[$country] ?? [];

// Log des méthodes sélectionnées
error_log("Moneroo Init - Méthodes sélectionnées: " . json_encode($methods));

// Si aucune méthode pour ce pays, essayer par devise en fallback
if (empty($methods)) {
    $methods_by_currency = [
        "XOF" => ["moov_bj", "mtn_bj"],
        "XAF" => ["mtn_cm", "orange_cm"],
        "NGN" => ["airtel_ng", "mtn_ng"],
        "GHS" => ["mtn_gh", "tigo_gh", "vodafone_gh"],
        "KES" => ["mpesa_ke"],
        "TZS" => ["airtel_tz", "halopesa_tz", "mpesa_tz", "tigo_tz"],
        "UGX" => ["airtel_ug", "mtn_ug"],
        "RWF" => ["airtel_rw", "mtn_rw"],
        "ZMW" => ["airtel_zm", "mtn_zm", "zamtel_zm"],
        "MWK" => ["airtel_mw", "tnm_mw"],
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
    ];
    $methods = $methods_by_currency[$currency] ?? ["moov_bj", "mtn_bj"];
}

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
    "metadata" => $metadata
];

// TOUJOURS ajouter le paramètre methods - Moneroo l'exige toujours
// Si methods est vide, utiliser un fallback par devise
if (empty($methods)) {
    $methods_by_currency_fallback = [
        "XOF" => ["moov_bj", "mtn_bj", "card_xof"],
        "XAF" => ["mtn_cm", "orange_cm", "card_xaf"],
        "NGN" => ["airtel_ng", "mtn_ng"],
        "GHS" => ["mtn_gh", "vodafone_gh", "card_ghs"],
        "KES" => ["mpesa_ke", "card_kes"],
        "TZS" => ["airtel_tz", "halopesa_tz", "mpesa_tz", "tigo_tz", "card_tzs"],
        "UGX" => ["airtel_ug", "mtn_ug", "card_ugx"],
        "RWF" => ["airtel_rw", "mtn_rw"],
        "ZMW" => ["airtel_zm", "mtn_zm", "zamtel_zm"],
        "MWK" => ["airtel_mw", "tnm_mw"],
        "ZAR" => ["card_zar"],
        "GNF" => ["mtn_gf"],
        "EUR" => ["card_usd"], // USD supporté mondialement comme fallback
        "USD" => ["card_usd", "crypto_usd"],
        "GBP" => ["card_usd"], // Fallback USD
        "CAD" => ["card_usd"], // Fallback USD
        "CHF" => ["card_usd"], // Fallback USD
        "BRL" => ["card_usd"], // Fallback USD
        "CNY" => ["card_usd"], // Fallback USD
        "JPY" => ["card_usd"], // Fallback USD
        "INR" => ["card_usd"], // Fallback USD
        "AUD" => ["card_usd"], // Fallback USD
        "NZD" => ["card_usd"], // Fallback USD
    ];
    $methods = $methods_by_currency_fallback[$currency] ?? ["moov_bj", "mtn_bj", "card_xof"];
}
$data["methods"] = $methods;

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