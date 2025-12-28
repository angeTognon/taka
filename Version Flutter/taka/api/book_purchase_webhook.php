<?php
// filepath: /Users/mac/Documents/taka2/book_purchase_webhook.php

require_once 'db.php'; // $pdo doit être défini ici

//$secret = 'pvk_ko62b8|01K5CEF100KW1V975FMKDB0J7Z';
$secret = 'pvk_18ufnk|01K94R1FMCMFW5SWAWT9Q3QMDM';

$payload = file_get_contents('php://input');
$signature = hash_hmac('sha256', $payload, $secret);

// Sécurité Moneroo
if (!isset($_SERVER['HTTP_X_MONEROO_SIGNATURE']) || !hash_equals($signature, $_SERVER['HTTP_X_MONEROO_SIGNATURE'])) {
    http_response_code(403);
    exit;
}

$data = json_decode($payload, true);

// Log pour debug (à commenter en prod)
file_put_contents('webhook_debug.txt', date('c')."\n".print_r($data, true), FILE_APPEND);

if ($data['event'] === 'payment.success' && $data['data']['status'] === 'success') {
    $user_id = $data['data']['metadata']['user_id'];
    $book_id = $data['data']['metadata']['book_id'];
    $amount_paid = isset($data['data']['amount']) ? floatval($data['data']['amount']) : 0;
    $purchased_at = date('Y-m-d H:i:s');

    // Vérifie si l'achat existe déjà pour éviter les doublons
    $stmt = $pdo->prepare("SELECT id FROM user_book_purchases WHERE user_id=? AND book_id=?");
    $stmt->execute([$user_id, $book_id]);
    if (!$stmt->fetch()) {
        $stmt = $pdo->prepare("INSERT INTO user_book_purchases (user_id, book_id, purchased_at) VALUES (?, ?, ?)");
        $stmt->execute([$user_id, $book_id, $purchased_at]);
        if ($stmt->errorCode() !== '00000') {
            file_put_contents('webhook_debug.txt', "Erreur SQL achat: ".print_r($stmt->errorInfo(), true), FILE_APPEND);
        }
    }

    // --- Affiliation livre ---
    if (!empty($data['data']['metadata']['ref'])) {
        $ref = $data['data']['metadata']['ref'];
        if (preg_match('/TAKA-AFF-2024-USER(\d+)/', $ref, $matches)) {
            $affiliate_user_id = intval($matches[1]);
            $commission = round($amount_paid * 0.20); // 20% du montant payé
            $type = 'book';
            // Empêche le doublon de commission pour le même achat
            $stmt2 = $pdo->prepare('SELECT id FROM taka_affiliate_earnings WHERE user_id=? AND type=? AND book_id=?');
            $stmt2->execute([$affiliate_user_id, $type, $book_id]);
            if (!$stmt2->fetch()) {
                $stmt3 = $pdo->prepare('INSERT INTO taka_affiliate_earnings (user_id, amount, type, book_id, created_at) VALUES (?, ?, ?, ?, NOW())');
                $stmt3->execute([$affiliate_user_id, $commission, $type, $book_id]);
                if ($stmt3->errorCode() !== '00000') {
                    file_put_contents('webhook_debug.txt', "Erreur SQL aff: ".print_r($stmt3->errorInfo(), true), FILE_APPEND);
                }
            }
        }
    }
}

http_response_code(200);
echo json_encode(['success' => true]);