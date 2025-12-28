<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Str;
use App\Helpers\BookHelper;

class BookController extends Controller
{
    private $baseUrl = "https://takaafrica.com/pharmaRh/taka";
    
    public function show($slug)
    {
        $book = null;
        $authorBooks = [];
        $categoryBooks = [];
        $isPurchased = false;
        
        // Décoder le slug (au cas où il serait URL encodé)
        $slug = urldecode($slug);
        // Normaliser le slug pour la comparaison (identique à la fonction de génération)
        $slug = $this->normalizeSlug($slug);
        
        try {
            // OPTIMISATION 1: Utiliser le cache pour charger tous les livres (cache de 10 minutes)
            $cacheKey = 'all_books_for_slug_search';
            $allBooks = Cache::remember($cacheKey, 600, function () {
                $response = Http::timeout(8)->get("{$this->baseUrl}/taka_api_books.php", [
                    'per_page' => 1000,
                ]);
                
                if ($response->successful()) {
                    $data = $response->json();
                    return $data['books'] ?? [];
                }
                return [];
            });
            
            // Trouver le livre correspondant au slug avec plusieurs méthodes de comparaison
            foreach ($allBooks as $b) {
                $bookTitle = $b['title'] ?? '';
                if (empty($bookTitle)) {
                    continue;
                }
                
                // Méthode 1: Générer le slug avec BookHelper::titleToSlug (méthode principale)
                $bookSlugGenerated = BookHelper::titleToSlug($bookTitle);
                
                // Normaliser le slug généré pour la comparaison
                $bookSlugNormalized = $this->normalizeSlug($bookSlugGenerated);
                
                // Méthode 2: Essayer avec Str::slug de Laravel (fallback)
                $bookSlugLaravel = Str::slug($bookTitle);
                $bookSlugLaravelNormalized = $this->normalizeSlug($bookSlugLaravel);
                
                // Comparaisons multiples pour être plus tolérant
                // La comparaison normalisée est la plus fiable
                if ($bookSlugNormalized === $slug || 
                    $bookSlugGenerated === $slug ||
                    $bookSlugLaravelNormalized === $slug ||
                    $bookSlugLaravel === $slug) {
                    $book = $b;
                    break;
                }
            }
            
            if ($book) {
                $author = $book['author'] ?? '';
                $genre = $book['genre'] ?? '';
                $bookId = is_numeric($book['id']) ? (int)$book['id'] : (int)($book['id'] ?? 0);
                $userId = $book['user_id'] ?? null; // Utiliser user_id pour filtrer les livres du même auteur
                
                // OPTIMISATION 2: Utiliser les livres déjà chargés pour filtrer par auteur (plus efficace)
                // Filtrer tous les livres du même auteur depuis $allBooks en utilisant user_id
                if (!empty($userId)) {
                    $currentBookId = $book['id'] ?? null;
                    
                    $authorBooks = array_filter($allBooks, function($b) use ($userId, $currentBookId) {
                        $bookUserId = $b['user_id'] ?? null;
                        $bookId = $b['id'] ?? null;
                        
                        // Inclure les livres du même auteur (même user_id), mais exclure le livre actuel
                        return $bookUserId == $userId && 
                               $bookId != $currentBookId; // Utiliser != pour gérer les types différents
                    });
                    $authorBooks = array_values($authorBooks);
                }
                
                // OPTIMISATION 3: Utiliser les livres déjà chargés pour filtrer par genre (plus efficace)
                // Filtrer tous les livres du même genre depuis $allBooks
                if (!empty($genre)) {
                    $categoryBooks = array_filter($allBooks, function($b) use ($book, $genre) {
                        $bookGenre = $b['genre'] ?? '';
                        $bookId = $b['id'] ?? null;
                        $currentBookId = $book['id'] ?? null;
                        // Inclure les livres du même genre, mais exclure le livre actuel
                        return !empty($bookGenre) && 
                               $bookGenre === $genre && 
                               $bookId !== $currentBookId;
                    });
                    // Limiter à 6 livres pour la catégorie (comme dans Flutter)
                    $categoryBooks = array_slice(array_values($categoryBooks), 0, 6);
                }
                
                // OPTIMISATION 3: Vérifier si le livre est acheté avec cache
                if (auth()->check()) {
                    $userId = auth()->user()->api_id ?? auth()->id();
                    $cacheKeyUserBooks = "user_books_{$userId}";
                    
                    // Cache pour les livres achetés (5 minutes)
                    $purchasedBookIds = Cache::remember($cacheKeyUserBooks, 300, function () use ($userId) {
                        try {
                            $userBooksResponse = Http::timeout(3)->get("{$this->baseUrl}/taka_api_user_books.php", [
                                'user_id' => $userId,
                            ]);
                            
                            if ($userBooksResponse->successful()) {
                                $userBooksData = $userBooksResponse->json();
                                if (isset($userBooksData['success']) && $userBooksData['success'] === true) {
                                    return array_map('intval', $userBooksData['books'] ?? []);
                                }
                            }
                        } catch (\Exception $e) {
                            \Log::warning("Error loading user books for cache: " . $e->getMessage());
                        }
                        return [];
                    });
                    
                    $isPurchased = in_array($bookId, $purchasedBookIds);
                }
            }
        } catch (\Exception $e) {
            // Log l'erreur pour debug
            \Log::error("Error loading book with slug '$slug': " . $e->getMessage());
        }
        
        if (!$book) {
            // Log pour debug : lister quelques slugs disponibles
            try {
                $cacheKey = 'all_books_for_slug_search';
                $allBooks = Cache::get($cacheKey, []);
                $sampleSlugs = [];
                foreach (array_slice($allBooks, 0, 5) as $b) {
                    $title = $b['title'] ?? '';
                    if (!empty($title)) {
                        $sampleSlugs[] = [
                            'title' => $title,
                            'slug_bookhelper' => BookHelper::titleToSlug($title),
                            'slug_laravel' => Str::slug($title),
                        ];
                    }
                }
                \Log::warning("Book not found for slug '$slug'. Sample slugs: " . json_encode($sampleSlugs));
            } catch (\Exception $e) {
                \Log::error("Error logging sample slugs: " . $e->getMessage());
            }
            
            // Si le livre n'est pas trouvé, retourner 404 comme dans Flutter
            abort(404, 'Livre non trouvé');
        }
        
        return view('book-detail', compact('book', 'authorBooks', 'categoryBooks', 'isPurchased'));
    }
    
    /**
     * Normalise un slug pour la comparaison (identique à BookHelper::titleToSlug)
     */
    private function normalizeSlug($slug)
    {
        if (empty($slug)) {
            return '';
        }
        
        // Décoder les entités HTML (au cas où)
        $slug = html_entity_decode($slug, ENT_QUOTES | ENT_HTML5, 'UTF-8');
        
        // Convertir en minuscule
        $slug = mb_strtolower(trim($slug), 'UTF-8');
        
        // Remplacer les caractères accentués (comme dans BookHelper)
        $accents = [
            'à' => 'a', 'á' => 'a', 'â' => 'a', 'ã' => 'a', 'ä' => 'a', 'å' => 'a',
            'è' => 'e', 'é' => 'e', 'ê' => 'e', 'ë' => 'e',
            'ì' => 'i', 'í' => 'i', 'î' => 'i', 'ï' => 'i',
            'ò' => 'o', 'ó' => 'o', 'ô' => 'o', 'õ' => 'o', 'ö' => 'o',
            'ù' => 'u', 'ú' => 'u', 'û' => 'u', 'ü' => 'u',
            'ý' => 'y', 'ÿ' => 'y',
            'ñ' => 'n', 'ç' => 'c',
        ];
        $slug = strtr($slug, $accents);
        
        // Remplacer les caractères non-alphanumériques par des tirets
        $slug = preg_replace('/[^a-z0-9]+/', '-', $slug);
        
        // Remplacer les tirets multiples par un seul
        $slug = preg_replace('/-+/', '-', $slug);
        
        // Supprimer les tirets en début et fin
        $slug = trim($slug, '-');
        
        return $slug;
    }
    
}
