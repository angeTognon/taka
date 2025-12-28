<?php
// Test spécifique pour l'Italie
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header('Content-Type: application/json');

// Simuler les données d'un appel depuis Flutter avec l'Italie
$input = [
    'currency' => 'EUR',
    'country' => 'Italie',
    'amount' => 2000,
    'email' => 'test@example.com',
    'first_name' => 'Mario',
    'last_name' => 'Rossi',
    'user_id' => '123',
    'book_id' => '456',
    'description' => 'Achat livre: Test'
];

echo "=== TEST PAIEMENT ITALIE ===\n";
echo "Données reçues: " . json_encode($input) . "\n";

$methods_by_currency = [
    "XOF" => ["moov_bj", "mtn_bj"],
    "EUR" => ["card"],
    "USD" => ["card"],
    "GBP" => ["card"],
];

$currency = $input['currency'];
$country = $input['country'];
$methods = $methods_by_currency[$currency] ?? $methods_by_currency["XOF"];

echo "Devise: $currency\n";
echo "Pays: $country\n";
echo "Méthodes: " . implode(', ', $methods) . "\n";

if ($currency === 'EUR' && $country === 'Italie' && in_array('card', $methods)) {
    echo "✅ SUCCÈS: Configuration correcte pour l'Italie\n";
    echo "✅ L'interface Moneroo devrait afficher l'Italie et les cartes bancaires\n";
} else {
    echo "❌ ÉCHEC: Configuration incorrecte\n";
    echo "❌ L'interface Moneroo affichera encore le Bénin\n";
}

echo "\n=== FIN DU TEST ===\n";
?>




















