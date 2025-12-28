<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') exit;

include 'db.php'; // $pdo

require 'vendor/autoload.php'; // PDF parser

use Smalot\PdfParser\Parser;

// Fonction pour récupérer le nombre de pages d'un PDF
function getPdfPageCount($filePath) {
    $filePath = ltrim($filePath, '/');
    $fullPath = __DIR__ . '/uploads/books/' . basename($filePath);

    if (!file_exists($fullPath)) {
        return 0;
    }

    try {
        $parser = new Parser();
        $pdf = $parser->parseFile($fullPath);
        return count($pdf->getPages());
    } catch (Exception $e) {
        return 0;
    }
}

// Recherche, filtres, tri, pagination
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $where = ["statut_validation = 'Validé'"];
    $params = [];

    // Recherche texte (titre, résumé, bio auteur)
    if (!empty($_GET['search'])) {
        $where[] = "(title LIKE ? OR summary LIKE ? OR author_bio LIKE ?)";
        $search = '%' . $_GET['search'] . '%';
        $params[] = $search;
        $params[] = $search;
        $params[] = $search;
    }

    // Filtres
    if (!empty($_GET['genre']) && $_GET['genre'] !== 'Tous') {
        $where[] = "genre = ?";
        $params[] = $_GET['genre'];
    }
    if (!empty($_GET['language']) && $_GET['language'] !== 'Toutes') {
        $where[] = "language = ?";
        $params[] = $_GET['language'];
    }
    if (!empty($_GET['plan']) && $_GET['plan'] !== 'all') {
        $where[] = "plan = ?";
        $params[] = $_GET['plan'];
    }

    // Construction de la requête
    $sql = "SELECT * FROM taka_books";
    if ($where) {
        $sql .= " WHERE " . implode(" AND ", $where);
    }

    // Tri
    $sort = $_GET['sort'] ?? 'recent';
    switch ($sort) {
        case 'recent':
            $sql .= " ORDER BY created_at DESC";
            break;
        case 'title':
            $sql .= " ORDER BY title ASC";
            break;
        default:
            $sql .= " ORDER BY created_at DESC";
            break;
    }

    // Pagination
    $page = isset($_GET['page']) ? max(1, intval($_GET['page'])) : 1;
    $perPage = isset($_GET['per_page']) ? intval($_GET['per_page']) : 12;
    $offset = ($page - 1) * $perPage;
    $sql .= " LIMIT $perPage OFFSET $offset";

    // Exécution
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    $books = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Ajoute le nombre de pages réel pour chaque livre
    foreach ($books as &$book) {
        $book['pages'] = getPdfPageCount($book['file_path']);
    }
    unset($book);

    // Nombre total pour la pagination
    $countSql = "SELECT COUNT(*) FROM taka_books";
    if ($where) {
        $countSql .= " WHERE " . implode(" AND ", $where);
    }
    $countStmt = $pdo->prepare($countSql);
    $countStmt->execute($params);
    $total = $countStmt->fetchColumn();

    echo json_encode([
        'books' => $books,
        'total' => intval($total),
        'page' => $page,
        'per_page' => $perPage,
    ]);
    exit;
}

// Ajouter un livre
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);
    $stmt = $pdo->prepare("
        INSERT INTO taka_books 
        (title, genre, language, summary, file_path, cover_path, plan, author_bio, author_photo_path, author_links, excerpt, quote, user_id, created_at, statut_validation) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), ?)
    ");
    $stmt->execute([
        $data['title'],
        $data['genre'],
        $data['language'],
        $data['summary'],
        $data['file_path'],
        $data['cover_path'],
        $data['plan'],
        $data['author_bio'],
        $data['author_photo_path'],
        $data['author_links'],
        $data['excerpt'],
        $data['quote'],
        $data['user_id'],
        $data['statut_validation'] ?? 'En attente de validation',
    ]);
    echo json_encode(['success' => true, 'id' => $pdo->lastInsertId()]);
    exit;
}

echo json_encode(['error' => 'Requête invalide']);