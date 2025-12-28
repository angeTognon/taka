<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

// Si c'est une requête OPTIONS (preflight), retourner immédiatement
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Inclusion du fichier de connexion à la base de données
require_once 'db.php';

try {
    // Utiliser la connexion $pdo depuis db.php
    
    // Récupérer le slug du livre depuis l'URL
    $bookSlug = isset($_GET['slug']) ? trim($_GET['slug']) : '';
    
    if (empty($bookSlug)) {
        echo json_encode([
            'success' => false,
            'message' => 'Slug du livre manquant'
        ]);
        exit;
    }
    
    // Fonction pour convertir un titre en slug comparable
    function titleToSlug($title) {
        // Convertir en minuscules
        $slug = strtolower($title);
        
        // Remplacer les caractères accentués
        $unwanted_array = array(
            'Š'=>'S', 'š'=>'s', 'Ž'=>'Z', 'ž'=>'z', 'À'=>'A', 'Á'=>'A', 'Â'=>'A', 'Ã'=>'A', 
            'Ä'=>'A', 'Å'=>'A', 'Æ'=>'A', 'Ç'=>'C', 'È'=>'E', 'É'=>'E', 'Ê'=>'E', 'Ë'=>'E', 
            'Ì'=>'I', 'Í'=>'I', 'Î'=>'I', 'Ï'=>'I', 'Ñ'=>'N', 'Ò'=>'O', 'Ó'=>'O', 'Ô'=>'O', 
            'Õ'=>'O', 'Ö'=>'O', 'Ø'=>'O', 'Ù'=>'U', 'Ú'=>'U', 'Û'=>'U', 'Ü'=>'U', 'Ý'=>'Y', 
            'Þ'=>'B', 'ß'=>'Ss', 'à'=>'a', 'á'=>'a', 'â'=>'a', 'ã'=>'a', 'ä'=>'a', 'å'=>'a', 
            'æ'=>'a', 'ç'=>'c', 'è'=>'e', 'é'=>'e', 'ê'=>'e', 'ë'=>'e', 'ì'=>'i', 'í'=>'i', 
            'î'=>'i', 'ï'=>'i', 'ð'=>'o', 'ñ'=>'n', 'ò'=>'o', 'ó'=>'o', 'ô'=>'o', 'õ'=>'o', 
            'ö'=>'o', 'ø'=>'o', 'ù'=>'u', 'ú'=>'u', 'û'=>'u', 'ý'=>'y', 'þ'=>'b', 'ÿ'=>'y'
        );
        $slug = strtr($slug, $unwanted_array);
        
        // Remplacer les caractères spéciaux et espaces par des tirets
        $slug = preg_replace('/[^a-z0-9]+/', '-', $slug);
        
        // Enlever les tirets en début et fin
        $slug = trim($slug, '-');
        
        return $slug;
    }
    
    // Récupérer tous les livres approuvés
    // Note: Ajustez le nom de la table des utilisateurs si nécessaire (taka_users ?)
    $stmt = $pdo->prepare("
        SELECT 
            b.id,
            b.title,
            b.genre,
            b.language,
            b.summary,
            b.price_type,
            b.price,
            b.cover_path,
            b.file_path,
            b.author_bio,
            b.author_photo_path,
            b.author_links,
            b.excerpt,
            b.quote,
            b.plan,
            b.created_at,
            b.user_id,
            COALESCE(u.name, 'Auteur TAKA') as author,
            '' as country,
            0 as pages
        FROM taka_books b
        LEFT JOIN taka_users u ON b.user_id = u.id
        WHERE b.statut_validation = 'approved'
    ");
    
    $stmt->execute();
    $allBooks = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Chercher le livre dont le slug correspond
    $book = null;
    foreach ($allBooks as $b) {
        if (titleToSlug($b['title']) === titleToSlug(urldecode($bookSlug))) {
            $book = $b;
            break;
        }
    }
    
    if ($book) {
        echo json_encode([
            'success' => true,
            'book' => $book
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Livre non trouvé'
        ]);
    }
    
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Erreur de base de données: ' . $e->getMessage()
    ]);
}
?>
