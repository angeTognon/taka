<?php
// Script de test pour vérifier la syntaxe PHP

echo "=== Test de syntaxe PHP ===\n";

// Test 1: Vérifier moneroo_init_book.php
echo "1. Test moneroo_init_book.php...\n";
$syntax_check = shell_exec('php -l moneroo_init_book.php 2>&1');
if (strpos($syntax_check, 'No syntax errors') !== false) {
    echo "✅ moneroo_init_book.php - Syntaxe OK\n";
} else {
    echo "❌ moneroo_init_book.php - Erreur de syntaxe:\n";
    echo $syntax_check . "\n";
}

// Test 2: Vérifier moneroo_init.php
echo "2. Test moneroo_init.php...\n";
$syntax_check = shell_exec('php -l moneroo_init.php 2>&1');
if (strpos($syntax_check, 'No syntax errors') !== false) {
    echo "✅ moneroo_init.php - Syntaxe OK\n";
} else {
    echo "❌ moneroo_init.php - Erreur de syntaxe:\n";
    echo $syntax_check . "\n";
}

// Test 3: Vérifier moneroo_publish_init.php
echo "3. Test moneroo_publish_init.php...\n";
$syntax_check = shell_exec('php -l moneroo_publish_init.php 2>&1');
if (strpos($syntax_check, 'No syntax errors') !== false) {
    echo "✅ moneroo_publish_init.php - Syntaxe OK\n";
} else {
    echo "❌ moneroo_publish_init.php - Erreur de syntaxe:\n";
    echo $syntax_check . "\n";
}

echo "\n=== Test terminé ===\n";
?>
