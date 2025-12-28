<?php
header('Content-Type: application/json');
include 'db.php';

$id = $_POST['id'] ?? null;
$title = $_POST['title'] ?? '';
$genre = $_POST['genre'] ?? '';
$language = $_POST['language'] ?? '';
$summary = $_POST['summary'] ?? '';
$plan = $_POST['plan'] ?? '';
$authorBio = $_POST['authorBio'] ?? '';
$authorLinks = $_POST['authorLinks'] ?? '';
$excerpt = $_POST['excerpt'] ?? '';
$quote = $_POST['quote'] ?? '';
$priceType = $_POST['priceType'] ?? 'gratuit';
$price = $_POST['price'] ?? '';
$user_id = $_POST['user_id'] ?? null;

// Vérifie l'id
if (!$id || !$user_id) {
  echo json_encode(['success' => false, 'error' => 'Paramètres manquants']);
  exit;
}

// Récupère les anciens chemins de fichiers
$stmt = $pdo->prepare('SELECT file_path, cover_path, author_photo_path FROM taka_books WHERE id=? AND user_id=?');
$stmt->execute([$id, $user_id]);
$old = $stmt->fetch(PDO::FETCH_ASSOC);

$file_path = $old['file_path'];
$cover_path = $old['cover_path'];
$author_photo_path = $old['author_photo_path'];

// Gère le fichier du livre
if (isset($_FILES['file']) && $_FILES['file']['error'] === UPLOAD_ERR_OK) {
  $ext = pathinfo($_FILES['file']['name'], PATHINFO_EXTENSION);
  $file_path = 'uploads/books/' . uniqid('book_') . '.' . $ext;
  move_uploaded_file($_FILES['file']['tmp_name'], $file_path);
}

// Gère la couverture
if (isset($_FILES['cover']) && $_FILES['cover']['error'] === UPLOAD_ERR_OK) {
  $ext = pathinfo($_FILES['cover']['name'], PATHINFO_EXTENSION);
  $cover_path = 'uploads/covers/' . uniqid('cover_') . '.' . $ext;
  move_uploaded_file($_FILES['cover']['tmp_name'], $cover_path);
}

// Gère la photo auteur
if (isset($_FILES['authorPhoto']) && $_FILES['authorPhoto']['error'] === UPLOAD_ERR_OK) {
  $ext = pathinfo($_FILES['authorPhoto']['name'], PATHINFO_EXTENSION);
  $author_photo_path = 'uploads/authors/' . uniqid('author_') . '.' . $ext;
  move_uploaded_file($_FILES['authorPhoto']['tmp_name'], $author_photo_path);
}

// Prépare la requête d’update
$stmt = $pdo->prepare('UPDATE taka_books SET title=?, genre=?, language=?, summary=?, plan=?, author_bio=?, author_links=?, excerpt=?, quote=?, price_type=?, price=?, file_path=?, cover_path=?, author_photo_path=? WHERE id=? AND user_id=?');
$success = $stmt->execute([
  $title, $genre, $language, $summary, $plan, $authorBio, $authorLinks, $excerpt, $quote, $priceType, $price,
  $file_path, $cover_path, $author_photo_path,
  $id, $user_id
]);

echo json_encode(['success' => $success]);