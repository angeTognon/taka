<?php
// Script de debug pour vérifier le flux de paiement
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header('Content-Type: application/json');

// Log toutes les requêtes entrantes
error_log("=== DEBUG PAYMENT FLOW ===");
error_log("Request Method: " . $_SERVER['REQUEST_METHOD']);
error_log("Content Type: " . ($_SERVER['CONTENT_TYPE'] ?? 'Not set'));
error_log("Raw Input: " . file_get_contents('php://input'));

$input = json_decode(file_get_contents('php://input'), true);

if ($input === null) {
    echo json_encode(['error' => 'Invalid JSON input', 'raw_input' => file_get_contents('php://input')]);
    exit;
}

error_log("Parsed Input: " . json_encode($input));

// Vérifier les paramètres critiques
$currency = $input['currency'] ?? 'NOT_SET';
$country = $input['country'] ?? 'NOT_SET';
$amount = $input['amount'] ?? 'NOT_SET';

error_log("Currency: $currency");
error_log("Country: $country");
error_log("Amount: $amount");

// Simuler une réponse de succès pour tester
echo json_encode([
    'debug' => true,
    'received_currency' => $currency,
    'received_country' => $country,
    'received_amount' => $amount,
    'checkout_url' => 'https://checkout.moneroo.io/test?currency=' . urlencode($currency) . '&country=' . urlencode($country) . '&amount=' . urlencode($amount)
]);
?>




















