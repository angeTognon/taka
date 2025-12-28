<?php
// filepath: /Users/mac/Documents/taka2/taka_api_create_affiliate_link.php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once 'db.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Méthode non autorisée']);
    exit;
}

$data = json_decode(file_get_contents('php://input'), true);

$user_id = intval($data['user_id'] ?? 0);
$type = trim($data['type'] ?? '');
$title = trim($data['title'] ?? '');
$book_id = isset($data['book_id']) ? intval($data['book_id']) : null;

if (!$user_id || !$type || !$title) {
    http_response_code(400);
    echo json_encode(['error' => 'Champs requis manquants']);
    exit;
}

// Génération du code d'affiliation
$affiliate_code = "TAKA-AFF-2024-USER$user_id";

// Construction de l'URL selon le type
switch ($type) {
    case 'general':
        $url = "https://takaafrica.com?ref=$affiliate_code";
        break;
    case 'subscription':
        $url = "https://takaafrica.com/subscription?ref=$affiliate_code";
        break;
    case 'book':
        if (!$book_id) {
            http_response_code(400);
            echo json_encode(['error' => 'book_id requis pour un lien livre']);
            exit;
        }
        // Vérifie que le livre existe
        $stmt = $pdo->prepare("SELECT id FROM taka_books WHERE id = ?");
        $stmt->execute([$book_id]);
        $book = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$book) {
            http_response_code(404);
            echo json_encode(['error' => 'Livre non trouvé']);
            exit;
        }
        $url = "https://takaafrica.com/book/$book_id?ref=$affiliate_code";
        break;
    default:
        http_response_code(400);
        echo json_encode(['error' => 'Type de lien invalide']);
        exit;
}

// Structure de commission (exemple)
$commission = [
    'general' => '20% sur chaque vente de livre',
    'subscription' => [
        'essentielle' => 400,
        'confort' => 700,
        'illimitée' => 1000
    ],
    'book' => '20% du prix du livre'
];

// Insertion en base
$stmt = $pdo->prepare("INSERT INTO taka_affiliate_links (user_id, type, title, url, book_id, created_at) VALUES (?, ?, ?, ?, ?, NOW())");
$stmt->execute([$user_id, $type, $title, $url, $book_id]);

echo json_encode([
    'success' => true,
    'link' => [
        'id' => $pdo->lastInsertId(),
        'type' => $type,
        'title' => $title,
        'url' => $url,
        'commission' => $commission[$type] ?? null
    ]
]);