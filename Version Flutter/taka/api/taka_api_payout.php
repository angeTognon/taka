<?php
function sendMonerooPayout($author, $amount, $currency, $description, $method, $recipient) {
    $url = 'https://api.moneroo.io/v1/payouts/initialize';
    $secretKey = 'pvk_sandbox_g29b8r|01K51G6VSRZGSYWXNTC9V2SEQ8';

    $payload = [
        "amount" => $amount,
        "currency" => $currency,
        "description" => $description,
        "customer" => [
            "email" => $author['email'],
            "first_name" => $author['first_name'],
            "last_name" => $author['last_name'],
        ],
        "metadata" => [
            "payout_request" => uniqid(),
            "customer_id" => strval($author['id'])
        ],
        "method" => $method,
        "recipient" => $recipient // <-- objet ex: ['account_number' => '4149518161']
    ];

    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        "Authorization: Bearer $secretKey",
        "Content-Type: application/json",
        "Accept: application/json"
    ]);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));

    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    return [
        'http_code' => $httpCode,
        'response' => json_decode($response, true)
    ];
}