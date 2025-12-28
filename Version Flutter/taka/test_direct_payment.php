<?php
// Test direct de l'API Moneroo avec les paramètres EUR/France
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header('Content-Type: application/json');

// Simuler les données que Flutter devrait envoyer
$input = [
    'amount' => 10000,
    'currency' => 'EUR',
    'country' => 'France',
    'description' => 'Achat livre: Retour aux sources',
    'email' => 'admin@gmail.com',
    'first_name' => 'TAKA',
    'last_name' => 'OFFICIEL',
    'user_id' => '2',
    'book_id' => '34',
    'return_url' => 'https://takaafrica.com'
];

echo "=== TEST DIRECT PAYMENT ===\n";
echo "Input simulé: " . json_encode($input) . "\n\n";

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

// Récupération des données
$currency = isset($input['currency']) && !empty($input['currency']) ? $input['currency'] : "XOF";
$country = isset($input['country']) ? $input['country'] : "Bénin";
$amount = isset($input['amount']) ? floatval($input['amount']) : 0;
$email = isset($input['email']) && !empty($input['email']) ? $input['email'] : "";
$first_name = isset($input['first_name']) && !empty($input['first_name']) ? $input['first_name'] : "";
$last_name = isset($input['last_name']) && !empty($input['last_name']) ? $input['last_name'] : "";
$user_id = isset($input['user_id']) && !empty($input['user_id']) ? $input['user_id'] : "";
$book_id = isset($input['book_id']) && !empty($input['book_id']) ? $input['book_id'] : "";

echo "Devise sélectionnée: $currency\n";
echo "Pays sélectionné: $country\n";
echo "Montant: $amount\n";
echo "Email: $email\n";

$methods = $methods_by_currency[$currency] ?? $methods_by_currency["XOF"];
echo "Méthodes de paiement: " . json_encode($methods) . "\n\n";

$description = isset($input['description']) ? $input['description'] : "Achat livre";
$return_url = isset($input['return_url']) && !empty($input['return_url']) ? $input['return_url'] : "https://takaafrica.com";

$metadata = [
    "user_id" => $user_id,
    "book_id" => $book_id,
    "currency" => $currency,
    "country" => $country
];

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

echo "Données envoyées à Moneroo: " . json_encode($data, JSON_PRETTY_PRINT) . "\n\n";

$ch = curl_init($url);
curl_setopt($ch, CURLOPT_POST, 1);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);

$response = curl_exec($ch);
$httpcode = curl_getinfo($ch, CURLINFO_HTTP_CODE);

echo "Code de réponse HTTP: $httpcode\n";
echo "Réponse Moneroo: " . $response . "\n";

if ($httpcode == 201) {
    $response_data = json_decode($response, true);
    if (isset($response_data['data']['checkout_url'])) {
        echo "\n✅ SUCCESS! Checkout URL: " . $response_data['data']['checkout_url'] . "\n";
    } else {
        echo "\n❌ Pas de checkout_url dans la réponse\n";
    }
} else {
    echo "\n❌ Erreur HTTP: $httpcode\n";
}
?>




















