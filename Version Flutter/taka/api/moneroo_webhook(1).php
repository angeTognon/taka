<?php
// filepath: /Users/mac/Documents/taka2/moneroo_webhook.php

require_once 'db.php'; // Doit créer $pdo (PDO connecté à ta base)

$secret = 'pvk_ko62b8|01K5CEF100KW1V975FMKDB0J7Z'; // à récupérer sur Moneroo
$payload = file_get_contents('php://input');
$signature = hash_hmac('sha256', $payload, $secret);

if (!isset($_SERVER['HTTP_X_MONEROO_SIGNATURE']) || !hash_equals($signature, $_SERVER['HTTP_X_MONEROO_SIGNATURE'])) {
    http_response_code(403);
    exit;
}

$data = json_decode($payload, true);

if ($data['event'] === 'payment.success' && $data['data']['status'] === 'success') {
    $user_id = $data['data']['metadata']['user_id'];
    $plan = $data['data']['metadata']['plan_id'];
    $payment_method = 'mobile'; // ou récupère-le si dispo
    $status = 'payé';
    $started_at = date('Y-m-d H:i:s');
    $expires_at = date('Y-m-d H:i:s', strtotime('+1 month'));
    $transaction_ref = $data['data']['id'];

    // Insère ou met à jour l'abonnement
    $sql = "INSERT INTO taka_subscriptions (user_id, plan, payment_method, status, started_at, expires_at, transaction_ref)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE
                status=VALUES(status),
                started_at=VALUES(started_at),
                expires_at=VALUES(expires_at),
                transaction_ref=VALUES(transaction_ref)";
    $stmt = $pdo->prepare($sql);
    $stmt->execute([$user_id, $plan, $payment_method, $status, $started_at, $expires_at, $transaction_ref]);

    // --- Affiliation abonnement ---
    if (!empty($data['data']['metadata']['ref'])) {
        $ref = $data['data']['metadata']['ref'];
        if (preg_match('/TAKA-AFF-2024-USER(\d+)/', $ref, $matches)) {
            $affiliate_user_id = intval($matches[1]);
            // Détermine la commission selon le plan
            $commission = [
                'essential' => 400,
                'comfort' => 700,
                'unlimited' => 1000
            ];
            $amount = $commission[$plan] ?? 0;
            if ($amount > 0) {
                $type = 'subscription';
                $stmt2 = $pdo->prepare('INSERT INTO taka_affiliate_earnings (user_id, amount, type) VALUES (?, ?, ?)');
                $stmt2->execute([$affiliate_user_id, $amount, $type]);
            }
        }
    }
}

http_response_code(200);
echo json_encode(['success' => true]);