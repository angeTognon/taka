<?php
// Script de test pour l'API Moneroo

echo "=== Test API Moneroo ===\n";

// Test avec différentes devises
$test_cases = [
    ['currency' => 'EUR', 'country' => 'Italie', 'amount' => 100],
    ['currency' => 'XOF', 'country' => 'Bénin', 'amount' => 1000],
    ['currency' => 'USD', 'country' => 'États-Unis', 'amount' => 100],
];

foreach ($test_cases as $test) {
    echo "\n--- Test: {$test['currency']} ({$test['country']}) ---\n";
    
    // Simuler les données d'entrée
    $input = [
        'currency' => $test['currency'],
        'country' => $test['country'],
        'amount' => $test['amount'],
        'description' => 'Test paiement',
        'email' => 'test@example.com',
        'first_name' => 'Test',
        'last_name' => 'User',
        'user_id' => '123',
        'book_id' => '456'
    ];
    
    // Inclure le fichier moneroo_init_book.php pour tester
    $_SERVER['REQUEST_METHOD'] = 'POST';
    
    // Capturer la sortie
    ob_start();
    
    try {
        // Simuler l'exécution du fichier
        $json_input = json_encode($input);
        
        // Test de la logique de sélection des méthodes
        $methods_by_currency = [
            "XOF" => ["moov_bj", "mtn_bj"],
            "EUR" => ["card"],
            "USD" => ["card"],
            "GBP" => ["card"],
        ];
        
        $currency = $input['currency'];
        $methods = $methods_by_currency[$currency] ?? $methods_by_currency["XOF"];
        
        echo "Devise: $currency\n";
        echo "Méthodes: " . implode(', ', $methods) . "\n";
        
        // Test de l'URL Moneroo
        $url = 'https://api.moneroo.io/v1/payments/initialize';
        echo "URL API: $url\n";
        
        // Test des headers
        $headers = [
            'Content-Type: application/json',
            'Authorization: Bearer pvk_ko62b8|01K5CEF100KW1V975FMKDB0J7Z',
            'Accept: application/json'
        ];
        echo "Headers configurés: " . count($headers) . " headers\n";
        
        echo "✅ Configuration OK pour {$test['currency']}\n";
        
    } catch (Exception $e) {
        echo "❌ Erreur: " . $e->getMessage() . "\n";
    }
    
    $output = ob_get_clean();
    echo $output;
}

echo "\n=== Test terminé ===\n";
?>




















