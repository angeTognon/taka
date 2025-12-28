<?php
// filepath: /Users/mac/Documents/taka2/taka_api_list_affiliate_links.php

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') exit;

include 'db.php'; // $pdo

$user_id = isset($_GET['user_id']) ? intval($_GET['user_id']) : 0;
if (!$user_id) {
    echo json_encode(['error' => 'user_id requis']);
    exit;
}

// Récupère tous les liens d'affiliation de l'utilisateur
$stmt = $pdo->prepare("SELECT id, title, type, book_id FROM taka_affiliate_links WHERE user_id = ?");
$stmt->execute([$user_id]);
$links = $stmt->fetchAll(PDO::FETCH_ASSOC);

$result = [];
foreach ($links as $link) {
    // Génère le code ref pour ce lien
    $ref = "TAKA-AFF-2024-USER" . $user_id;
    if ($link['type'] === 'book' && $link['book_id']) {
        $ref .= "-BOOK" . $link['book_id'];
    }

    // URL du lien
    $url = "https://takaafrica.com?ref=$ref";

    // Statistiques par lien (à adapter si tu as une table de clics)
    $clicks = 0; // Si tu as une table taka_affiliate_clicks, fais un COUNT ici

    // Conversions et earnings pour ce lien
    if ($link['type'] === 'book' && $link['book_id']) {
        // Pour un lien livre, filtre aussi sur le book_id
        $stmt2 = $pdo->prepare("SELECT COUNT(*) as conversions, SUM(amount) as earnings FROM taka_affiliate_earnings WHERE user_id = ? AND type = 'book' AND book_id = ?");
        $stmt2->execute([$user_id, $link['book_id']]);
    } else {
        // Pour les autres liens
        $stmt2 = $pdo->prepare("SELECT COUNT(*) as conversions, SUM(amount) as earnings FROM taka_affiliate_earnings WHERE user_id = ? AND type = ?");
        $stmt2->execute([$user_id, $link['type']]);
    }
    $row = $stmt2->fetch(PDO::FETCH_ASSOC);
    $conversions = (int)($row['conversions'] ?? 0);
    $earnings = (int)($row['earnings'] ?? 0);

    $result[] = [
        'id' => $link['id'],
        'title' => $link['title'],
        'url' => $url,
        'clicks' => $clicks,
        'conversions' => $conversions,
        'earnings' => $earnings,
    ];
}

echo json_encode(['links' => $result]);