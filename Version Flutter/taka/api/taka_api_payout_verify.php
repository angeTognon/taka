<?php
function verifyMonerooPayout($payoutId) {
    $url = "https://api.moneroo.io/v1/payouts/$payoutId/verify";
    $secretKey = 'pvk_sandbox_g29b8r|01K51G6VSRZGSYWXNTC9V2SEQ8';

    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        "Authorization: Bearer $secretKey",
        "Accept: application/json"
    ]);
    $response = curl_exec($ch);
    curl_close($ch);

    return json_decode($response, true);
}

// Exemple d'utilisation
$payoutId = $result['response']['data']['id'];
$verification = verifyMonerooPayout($payoutId);
if ($verification['data']['status'] == 'success') {
    echo "Versement confirmé !";
} else {
    echo "Versement en attente ou échoué.";
}