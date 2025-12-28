<?php
// ⚠️ Aucun espace ou saut de ligne avant ce bloc

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

include 'db.php';

$input = json_decode(file_get_contents('php://input'), true);

if (!$input) {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid input']);
    exit;
}

// Génère une référence unique pour la transaction
$transaction_ref = uniqid('pub_', true);

// Stocke les infos du livre en attente (statut "pending")
$stmt = $pdo->prepare('INSERT INTO taka_books_pending 
    (transaction_ref, title, genre, language, summary, plan, author_bio, author_links, excerpt, quote, user_id, price_type, price, created_at)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())');
$stmt->execute([
    $transaction_ref,
    $input['title'] ?? '',
    $input['genre'] ?? '',
    $input['language'] ?? '',
    $input['summary'] ?? '',
    $input['plan'] ?? '',
    $input['authorBio'] ?? '',
    $input['authorLinks'] ?? '',
    $input['excerpt'] ?? '',
    $input['quote'] ?? '',
    $input['user_id'] ?? null,
    $input['priceType'] ?? 'gratuit',
    isset($input['price']) && $input['price'] !== '' ? intval($input['price']) : null
]);

// Prépare la requête Moneroo
$url = 'https://api.moneroo.io/v1/payments/initialize';
$headers = [
    'Content-Type: application/json',
    'Authorization: Bearer pvk_18ufnk|01K94R1FMCMFW5SWAWT9Q3QMDM',
    'Accept: application/json'
];

// Liste des méthodes compatibles par PAYS (mapping par pays car chaque pays a ses propres codes)
$methods_by_country = [
    // Zone UEMOA (XOF)
    "Bénin" => ["moov_bj", "mtn_bj"],
    "Burkina Faso" => ["moov_bf", "mtn_bf"],
    "Côte d'Ivoire" => ["moov_ci", "mtn_ci"],
    "Guinée-Bissau" => ["moov_gw", "mtn_gw"],
    "Mali" => ["moov_ml", "mtn_ml"],
    "Niger" => ["moov_ne", "mtn_ne"],
    "Sénégal" => ["moov_sn", "mtn_sn"],
    "Togo" => ["moov_tg", "mtn_tg"],
    
    // Zone CEMAC (XAF)
    "Cameroun" => ["mtn_cm", "orange_cm"],
    "Centrafrique" => ["mtn_cf", "orange_cf"],
    "Congo" => ["mtn_cg", "orange_cg"],
    "Guinée équatoriale" => ["mtn_gq", "orange_gq"],
    "Gabon" => ["mtn_cm", "orange_cm"], // Utiliser les méthodes du Cameroun (même zone XAF)
    "Tchad" => ["mtn_td", "orange_td"],
    
    // Autres pays africains
    "Nigeria" => ["airtel_ng", "mtn_ng"],
    "Ghana" => ["mtn_gh", "tigo_gh", "vodafone_gh"],
    "Kenya" => ["mpesa_ke"],
    "Tanzanie" => ["airtel_tz", "halopesa_tz", "mpesa_tz", "tigo_tz"],
    "Ouganda" => ["airtel_ug", "mtn_ug"],
    "Rwanda" => ["airtel_rw", "mtn_rw"],
    "Zambie" => ["airtel_zm", "mtn_zm", "zamtel_zm"],
    "Malawi" => ["airtel_mw", "tnm_mw"],
    "Éthiopie" => [], // Méthodes à ajouter
    "Afrique du Sud" => [], // Méthodes à ajouter
    
    // Maghreb
    "Algérie" => [], // Méthodes à ajouter
    "Maroc" => [], // Méthodes à ajouter
    "Tunisie" => [], // Méthodes à ajouter
    "Égypte" => [], // Méthodes à ajouter
    "Libye" => [], // Méthodes à ajouter
    "Soudan" => [], // Méthodes à ajouter
    
    // Pays occidentaux
    "France" => ["card"],
    "Belgique" => ["card"],
    "Allemagne" => ["card"],
    "Italie" => ["card"],
    "Espagne" => ["card"],
    "Portugal" => ["card"],
    "Pays-Bas" => ["card"],
    "États-Unis" => ["card"],
    "Royaume-Uni" => ["card"],
    "Canada" => ["card"],
    "Suisse" => ["card"],
    
    // Autres
    "Brésil" => ["card"],
    "Chine" => ["card"],
    "Japon" => ["card"],
    "Inde" => ["card"],
    "Australie" => ["card"],
    "Nouvelle-Zélande" => ["card"],
];

// Récupération du pays et de la devise
$country = $input['country'] ?? "Bénin";
$currency = $input['currency'] ?? "XOF";

// Sélection des méthodes selon le pays sélectionné
$methods = $methods_by_country[$country] ?? [];

// Si aucune méthode pour ce pays, essayer par devise en fallback
if (empty($methods)) {
    $methods_by_currency = [
        "XOF" => ["moov_bj", "mtn_bj"],
        "XAF" => ["mtn_cm", "orange_cm"],
        "NGN" => ["airtel_ng", "mtn_ng"],
        "GHS" => ["mtn_gh", "tigo_gh", "vodafone_gh"],
        "KES" => ["mpesa_ke"],
        "TZS" => ["airtel_tz", "halopesa_tz", "mpesa_tz", "tigo_tz"],
        "UGX" => ["airtel_ug", "mtn_ug"],
        "RWF" => ["airtel_rw", "mtn_rw"],
        "ZMW" => ["airtel_zm", "mtn_zm", "zamtel_zm"],
        "MWK" => ["airtel_mw", "tnm_mw"],
        "EUR" => ["card"],
        "USD" => ["card"],
        "GBP" => ["card"],
        "CAD" => ["card"],
        "CHF" => ["card"],
        "BRL" => ["card"],
        "CNY" => ["card"],
        "JPY" => ["card"],
        "INR" => ["card"],
        "AUD" => ["card"],
        "NZD" => ["card"],
    ];
    $methods = $methods_by_currency[$currency] ?? ["moov_bj", "mtn_bj"];
}

$data = [
    "amount" => intval($input['amount']),
    "currency" => $currency,
    "description" => $input['description'] ?? 'Publication TAKA',
    "customer" => [
        "email" => $input['email'] ?? '',
        "first_name" => $input['first_name'] ?? '',
        "last_name" => $input['last_name'] ?? ''
    ],
    "return_url" => $input['return_url'] ?? "https://takaafrica.com",
    "metadata" => [
        "user_id" => $input['user_id'],
        "transaction_ref" => $transaction_ref
    ]
];

// TOUJOURS ajouter le paramètre methods - Moneroo l'exige toujours
// Si methods contient "card" ou est vide, utiliser XOF comme fallback universel
if (empty($methods) || in_array("card", $methods)) {
    // Pour les pays non supportés ou avec cartes, utiliser XOF (Bénin) comme fallback
    // car Moneroo supporte principalement les méthodes mobile money africaines
    $methods = ["moov_bj", "mtn_bj"];
}
$data["methods"] = $methods;

$ch = curl_init($url);
curl_setopt($ch, CURLOPT_POST, 1);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);

$response = curl_exec($ch);
$httpcode = curl_getinfo($ch, CURLINFO_HTTP_CODE);

if ($httpcode != 201) {
    http_response_code($httpcode);
    echo json_encode([
        'error' => 'Erreur Moneroo',
        'httpcode' => $httpcode,
        'response' => $response,
        'data_sent' => $data
    ]);
    exit;
}

$response_data = json_decode($response, true);
echo json_encode([
    'checkout_url' => $response_data['data']['checkout_url'],
    'transaction_ref' => $transaction_ref
]);