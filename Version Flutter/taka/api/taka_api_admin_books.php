<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') exit;

include 'db.php'; // $pdo

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $stmt = $pdo->prepare("
        SELECT b.*, u.full_name AS author_name, u.email AS author_email, u.created_at AS author_created_at
        FROM taka_books b
        LEFT JOIN taka_users u ON b.user_id = u.id
        ORDER BY b.created_at DESC
    ");
    $stmt->execute();
    $books = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        'success' => true,
        'books' => $books
    ]);
    exit;
}
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);

    if (isset($data['action']) && $data['action'] === 'validate' && !empty($data['book_id'])) {
        // Valider le livre
        $stmt = $pdo->prepare("UPDATE taka_books SET statut_validation = 'Validé' WHERE id = ?");
        $stmt->execute([$data['book_id']]);

        // Récupérer l'email de l'auteur
        $stmt2 = $pdo->prepare("SELECT u.email, b.title FROM taka_books b JOIN taka_users u ON b.user_id = u.id WHERE b.id = ?");
        $stmt2->execute([$data['book_id']]);
        $author = $stmt2->fetch(PDO::FETCH_ASSOC);

        if ($author && !empty($author['email'])) {
            $to = $author['email'];
            $subject = "Votre livre a été validé sur TAKA";
            $message = "Bonjour,\n\nVotre livre \"{$author['title']}\" vient d'être validé par l'équipe TAKA et est désormais disponible sur la plateforme.\n\nMerci pour votre contribution !\n\nL'équipe TAKA";
            $headers = "From: noreply@taka.com\r\n";
            mail($to, $subject, $message, $headers);
        }

        echo json_encode(['success' => true, 'message' => 'Livre validé et email envoyé']);
        exit;
    }

    echo json_encode(['success' => false, 'error' => 'Paramètres invalides']);
    exit;
}
echo json_encode(['success' => false, 'error' => 'Méthode non supportée']);