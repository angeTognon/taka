<?php
// ⚠️ Aucun espace ou saut de ligne avant ce bloc

// Activer l'affichage des erreurs (utile pour le développement)
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Headers CORS pour accepter les requêtes depuis Flutter Web
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json');

// Gérer la pré-requête CORS (OPTIONS)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

include 'db.php'; // Assure-toi que ce fichier ne produit aucune sortie

function saveFile($file, $folder) {
    if (!isset($file['name']) || $file['error'] !== UPLOAD_ERR_OK) return null;

    $ext = pathinfo($file['name'], PATHINFO_EXTENSION);
    $filename = uniqid() . '.' . $ext;
    $uploadDir = __DIR__ . "/uploads/$folder";

    if (!is_dir($uploadDir)) {
        mkdir($uploadDir, 0777, true);
    }

    $target = "$uploadDir/$filename";
    move_uploaded_file($file['tmp_name'], $target);
    return "uploads/$folder/$filename";
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Récupération des champs texte
    $title = $_POST['title'] ?? '';
    $genre = $_POST['genre'] ?? '';
    $language = $_POST['language'] ?? '';
    $summary = $_POST['summary'] ?? '';
    $plan = $_POST['plan'] ?? '';
    $authorBio = $_POST['authorBio'] ?? '';
    $authorLinks = $_POST['authorLinks'] ?? '';
    $excerpt = $_POST['excerpt'] ?? '';
    $quote = $_POST['quote'] ?? '';
    $user_id = $_POST['user_id'] ?? null;
    $priceType = $_POST['priceType'] ?? 'gratuit';
    $price = isset($_POST['price']) && $_POST['price'] !== '' ? intval($_POST['price']) : null;

    // Sauvegarde des fichiers (si présents)
    $file_path = isset($_FILES['file']) ? saveFile($_FILES['file'], 'books') : null;
    $cover_path = isset($_FILES['cover']) ? saveFile($_FILES['cover'], 'covers') : null;
    $author_photo_path = isset($_FILES['authorPhoto']) ? saveFile($_FILES['authorPhoto'], 'authors') : null;

    // Validation basique - authorBio et excerpt sont optionnels (non présents dans l'app mobile)
    if (!$title || !$genre || !$language || !$summary || !$plan) {
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'Champs requis manquants']);
        exit;
    }

    try {
        $stmt = $pdo->prepare('INSERT INTO taka_books 
            (title, genre, language, summary, file_path, cover_path, plan, author_bio, author_photo_path, author_links, excerpt, quote, user_id, price_type, price)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)');
        $stmt->execute([
            $title, $genre, $language, $summary,
            $file_path, $cover_path, $plan, $authorBio,
            $author_photo_path, $authorLinks, $excerpt, $quote, $user_id,
            $priceType, $price
        ]);

        echo json_encode([
            'success' => true,
            'book_id' => $pdo->lastInsertId()
        ]);
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'error' => 'Erreur serveur : ' . $e->getMessage()
        ]);
    }
    exit;
}

// Optionnel : Récupération des livres (GET)
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $stmt = $pdo->query('SELECT * FROM taka_books ORDER BY created_at DESC');
    $books = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo json_encode($books);
    exit;
}

// Si la requête est invalide
http_response_code(400);
echo json_encode(['success' => false, 'error' => 'Requête invalide']);
