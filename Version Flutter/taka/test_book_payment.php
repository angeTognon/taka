<?php
// Test script pour vérifier la logique de paiement
$input = [
    'amount' => 3500,
    'currency' => 'EUR',
    'country' => 'France',
    'description' => 'Achat livre: LES SECRETS DU MARKETING DIGITAL',
    'email' => 'admin@gmail.com',
    'first_name' => 'TAKA',
    'last_name' => 'OFFICIEL',
    'user_id' => '2',
    'book_id' => '39',
    'return_url' => 'https://takaafrica.com'
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

// Récupération des données
$currency = isset($input['currency']) && !empty($input['currency']) ? $input['currency'] : "XOF";
$country = isset($input['country']) ? $input['country'] : "Bénin";
$amount = isset($input['amount']) ? floatval($input['amount']) : 0;

echo "=== TEST PAYMENT LOGIC ===\n";
echo "Currency: $currency\n";
echo "Country: $country\n";
echo "Amount: $amount\n";

$methods = $methods_by_currency[$currency] ?? $methods_by_currency["XOF"];
echo "Payment methods: " . json_encode($methods) . "\n";

$data = [
    "amount" => $amount,
    "currency" => $currency,
    "description" => $input['description'],
    "customer" => [
        "email" => $input['email'],
        "first_name" => $input['first_name'],
        "last_name" => $input['last_name']
    ],
    "return_url" => $input['return_url'],
    "metadata" => [
        "user_id" => $input['user_id'],
        "book_id" => $input['book_id'],
        "currency" => $currency,
        "country" => $country
    ],
    "methods" => $methods
];

echo "Data to send to Moneroo:\n";
echo json_encode($data, JSON_PRETTY_PRINT) . "\n";
?>




















