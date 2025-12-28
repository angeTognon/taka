<?php
$payoutId = 'po_0nv0xs51oz8a'; // Remplace par ton ID
$token = 'pvk_sandbox_n2n736|01K51H6VGYRPKQ1CYAQNAYKKSK';

$curl = curl_init();
curl_setopt_array($curl, [
  CURLOPT_URL => "https://api.moneroo.io/v1/payouts/{$payoutId}/verify",
  CURLOPT_RETURNTRANSFER => true,
  CURLOPT_HTTPHEADER => [
    "Authorization: Bearer {$token}",
    "Accept: application/json"
  ]
]);
$response = curl_exec($curl);
$httpCode = curl_getinfo($curl, CURLINFO_HTTP_CODE);
curl_close($curl);

if ($httpCode === 200) {
  $data = json_decode($response, true);
  // Vérifie le statut
  if ($data['data']['status'] === 'success') {
    echo "Versement confirmé !";
  } else {
    echo "Versement en attente ou échoué.";
  }
} else {
  echo "Erreur lors de la vérification.";
}