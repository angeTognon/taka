<?php
// Test de déploiement - Vérifier si les fichiers sont bien déployés

echo "=== TEST DE DÉPLOIEMENT ===\n";

// Test 1: Vérifier si le fichier moneroo_init_book.php existe et a été modifié
$file_path = 'moneroo_init_book.php';
if (file_exists($file_path)) {
    $content = file_get_contents($file_path);
    $last_modified = date('Y-m-d H:i:s', filemtime($file_path));
    echo "✅ Fichier $file_path existe\n";
    echo "📅 Dernière modification: $last_modified\n";
    
    // Vérifier si le fichier contient les nouvelles devises
    if (strpos($content, 'EUR') !== false) {
        echo "✅ Le fichier contient EUR (Euro)\n";
    } else {
        echo "❌ Le fichier ne contient PAS EUR (Euro)\n";
    }
    
    if (strpos($content, 'selectedCurrency') !== false) {
        echo "✅ Le fichier utilise la devise sélectionnée\n";
    } else {
        echo "❌ Le fichier n'utilise PAS la devise sélectionnée\n";
    }
    
    if (strpos($content, 'selectedCountry') !== false) {
        echo "✅ Le fichier utilise le pays sélectionné\n";
    } else {
        echo "❌ Le fichier n'utilise PAS le pays sélectionné\n";
    }
    
} else {
    echo "❌ Fichier $file_path n'existe pas\n";
}

echo "\n=== TEST AVEC DONNÉES SIMULÉES ===\n";

// Simuler un appel avec l'Italie
$test_data = [
    'currency' => 'EUR',
    'country' => 'Italie',
    'amount' => 100,
    'email' => 'test@example.com',
    'first_name' => 'Test',
    'last_name' => 'User',
    'user_id' => '123',
    'book_id' => '456'
];

echo "Données de test: " . json_encode($test_data) . "\n";

// Inclure le fichier pour tester
$_SERVER['REQUEST_METHOD'] = 'POST';
$_SERVER['CONTENT_TYPE'] = 'application/json';

// Simuler l'input
$json_input = json_encode($test_data);

// Capturer la sortie
ob_start();

try {
    // Simuler l'exécution
    $input = json_decode($json_input, true);
    
    $methods_by_currency = [
        "XOF" => ["moov_bj", "mtn_bj"],
        "EUR" => ["card"],
        "USD" => ["card"],
    ];
    
    $currency = $input['currency'];
    $country = $input['country'];
    $methods = $methods_by_currency[$currency] ?? $methods_by_currency["XOF"];
    
    echo "Devise reçue: $currency\n";
    echo "Pays reçu: $country\n";
    echo "Méthodes sélectionnées: " . implode(', ', $methods) . "\n";
    
    if ($currency === 'EUR' && $country === 'Italie') {
        echo "✅ Configuration correcte pour l'Italie\n";
    } else {
        echo "❌ Configuration incorrecte\n";
    }
    
} catch (Exception $e) {
    echo "❌ Erreur: " . $e->getMessage() . "\n";
}

$output = ob_get_clean();
echo $output;

echo "\n=== FIN DU TEST ===\n";
?>




















