<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Cache;

class ExploreController extends Controller
{
    private $baseUrl = "https://takaafrica.com/pharmaRh/taka";

    public function index(Request $request)
    {
        // Récupérer la page
        $page = max(1, (int)$request->get('page', 1));
        $perPage = 6; // 6 livres par page comme demandé
        
        // Sur la page 1, utiliser les paramètres de l'URL directement
        // Sur les autres pages, utiliser la session pour les filtres
        if ($page === 1) {
            // Page 1 : utiliser les paramètres de l'URL et les sauvegarder en session
            $search = $request->get('search', '');
            $genre = $request->get('genre', 'Tous');
            $language = $request->get('language', 'Toutes');
            $priceFilter = $request->get('price', 'all');
            $sort = $request->get('sort', 'recent');
            $viewMode = $request->get('view', 'grid');
            
            // Sauvegarder en session pour les pages suivantes
            $request->session()->put('explore_search', $search);
            $request->session()->put('explore_genre', $genre);
            $request->session()->put('explore_language', $language);
            $request->session()->put('explore_price', $priceFilter);
            $request->session()->put('explore_sort', $sort);
            $request->session()->put('explore_view', $viewMode);
        } else {
            // Pages suivantes : utiliser la session (sauf si un paramètre est explicitement dans l'URL)
            $search = $request->has('search') ? $request->get('search', '') : $request->session()->get('explore_search', '');
            $genre = $request->has('genre') ? $request->get('genre', 'Tous') : $request->session()->get('explore_genre', 'Tous');
            $language = $request->has('language') ? $request->get('language', 'Toutes') : $request->session()->get('explore_language', 'Toutes');
            $priceFilter = $request->has('price') ? $request->get('price', 'all') : $request->session()->get('explore_price', 'all');
            $sort = $request->has('sort') ? $request->get('sort', 'recent') : $request->session()->get('explore_sort', 'recent');
            $viewMode = $request->has('view') ? $request->get('view', 'grid') : $request->session()->get('explore_view', 'grid');
        }
        
        $books = [];
        $totalBooks = 0;
        $purchasedBookIds = [];

        try {
            // Si filtre prix = 'all', on peut utiliser directement la pagination serveur
            // Sinon, on doit charger plus de livres pour compenser le filtrage côté client
            if ($priceFilter === 'all') {
                // Pas de filtrage prix, pagination directe
                $params = [
                    'sort' => $sort,
                    'per_page' => $perPage,
                    'page' => $page,
                ];

                if (!empty($search)) {
                    $params['search'] = $search;
                }
                if ($genre !== 'Tous') {
                    $params['genre'] = $genre;
                }
                if ($language !== 'Toutes') {
                    $params['language'] = $language;
                }

                $response = Http::timeout(5)->get("{$this->baseUrl}/taka_api_books.php", $params);

                if ($response->successful()) {
                    $data = $response->json();
                    $books = $data['books'] ?? [];
                    
                    // Total depuis l'API
                    if (isset($data['total']) && is_numeric($data['total']) && (int)$data['total'] > 0) {
                        $totalBooks = (int)$data['total'];
                    } else {
                        // Si pas de total dans l'API, estimer basé sur les résultats
                        if (count($books) === 0 && $page > 1) {
                            // Page vide après la première - le total est la page précédente
                            $totalBooks = ($page - 1) * $perPage;
                        } elseif (count($books) < $perPage) {
                            // Dernière page - le total est le nombre de cette page + les pages précédentes
                            $totalBooks = ($page - 1) * $perPage + count($books);
                        } elseif (count($books) === $perPage) {
                            // Page complète - estimer qu'il y a au moins une page de plus
                            // Mais pour éviter de surestimer, on fait une requête supplémentaire pour vérifier
                            $nextPageParams = $params;
                            $nextPageParams['page'] = $page + 1;
                            $nextResponse = Http::timeout(2)->get("{$this->baseUrl}/taka_api_books.php", $nextPageParams);
                            if ($nextResponse->successful()) {
                                $nextData = $nextResponse->json();
                                $nextBooks = $nextData['books'] ?? [];
                                if (count($nextBooks) > 0) {
                                    // Il y a une page suivante, estimer au moins 2 pages de plus
                                    $totalBooks = ($page + 2) * $perPage;
                                } else {
                                    // Pas de page suivante, c'est la dernière
                                    $totalBooks = $page * $perPage;
                                }
                            } else {
                                // Erreur, estimer conservativement
                                $totalBooks = $page * $perPage;
                            }
                        } else {
                            // Page 1 avec moins de résultats que perPage
                            $totalBooks = count($books);
                        }
                    }
                }
            } else {
                // Filtrage prix côté client - OPTIMISÉ pour la rapidité ET la complétude
                // On charge progressivement jusqu'à avoir assez de résultats filtrés
                
                // Construire les paramètres de base
                $baseParams = [
                    'sort' => $sort,
                ];
                
                if (!empty($search)) {
                    $baseParams['search'] = $search;
                }
                if ($genre !== 'Tous') {
                    $baseParams['genre'] = $genre;
                }
                if ($language !== 'Toutes') {
                    $baseParams['language'] = $language;
                }
                
                // Charger les livres pour la page demandée
                $allFilteredBooks = [];
                $currentApiPage = 1;
                $maxApiPages = 40; // Limite raisonnable
                $apiPerPage = 50; // Réduire pour éviter les timeouts
                
                // Calculer combien de livres filtrés on a besoin
                $neededFiltered = $page * $perPage;
                
                // Charger progressivement jusqu'à avoir assez de résultats filtrés
                $totalBooks = 0;
                $filterRatio = 0.5; // Ratio par défaut
                $fetchedBooks = [];
                $hasMoreBooks = true;
                
                while (count($allFilteredBooks) < $neededFiltered && $currentApiPage <= $maxApiPages && $hasMoreBooks) {
                    $params = array_merge($baseParams, [
                        'per_page' => $apiPerPage,
                        'page' => $currentApiPage,
                    ]);

                    $response = Http::timeout(8)->get("{$this->baseUrl}/taka_api_books.php", $params);

                    if ($response->successful()) {
                        $data = $response->json();
                        $fetchedBooks = $data['books'] ?? [];
                        
                        if (empty($fetchedBooks)) {
                            $hasMoreBooks = false;
                            break; // Plus de livres disponibles
                        }
                        
                        // Filtrer par prix
                        $filtered = $this->filterBooksByPrice($fetchedBooks, $priceFilter);
                        $allFilteredBooks = array_merge($allFilteredBooks, $filtered);
                        
                        // Calculer le ratio de filtrage sur la première page
                        if ($currentApiPage === 1 && count($fetchedBooks) > 0) {
                            $filterRatio = count($filtered) / count($fetchedBooks);
                            // S'assurer que le ratio n'est pas trop bas ou trop haut
                            if ($filterRatio < 0.01) {
                                $filterRatio = 0.01; // Minimum 1%
                            }
                            if ($filterRatio > 1.0) {
                                $filterRatio = 1.0; // Maximum 100%
                            }
                        }
                        
                        // Estimer le total - on le met à jour à chaque page pour être précis
                        if (isset($data['total']) && is_numeric($data['total']) && (int)$data['total'] > 0) {
                            // Si l'API donne un total, l'utiliser avec le ratio
                            $totalBooks = max(1, (int)((int)$data['total'] * $filterRatio));
                        }
                        
                        $currentApiPage++;
                    } else {
                        $hasMoreBooks = false;
                        break;
                    }
                }
                
                // Prendre les livres de la page demandée
                $startIndex = ($page - 1) * $perPage;
                $books = array_slice($allFilteredBooks, $startIndex, $perPage);
                
                // Ajuster le total si on n'a pas assez de livres
                if (count($allFilteredBooks) < $neededFiltered && ($currentApiPage > $maxApiPages || empty($fetchedBooks))) {
                    // On a tout chargé, le total est le nombre réel de livres filtrés
                    $totalBooks = count($allFilteredBooks);
                } else {
                    // Si on n'a pas de total de l'API, estimer basé sur le ratio
                    if ($totalBooks === 0 && count($allFilteredBooks) > 0) {
                        // Estimer en fonction du ratio et de ce qu'on a trouvé
                        $estimatedTotal = (int)(count($allFilteredBooks) / max($filterRatio, 0.1));
                        $totalBooks = max(count($allFilteredBooks), $estimatedTotal);
                    }
                }
                
                // S'assurer que le total est au moins égal au nombre de livres filtrés qu'on a
                if ($totalBooks < count($allFilteredBooks)) {
                    $totalBooks = count($allFilteredBooks);
                }
            }

            // Si l'utilisateur est connecté, récupérer ses livres achetés avec cache
            // Utiliser api_id si disponible et mettre en cache pour éviter les requêtes répétées
            if (Auth::check()) {
                $user = Auth::user();
                $userId = $user->api_id ?? $user->id;
                
                // Utiliser le cache pour les livres achetés (cache de 5 minutes)
                $cacheKey = "user_books_{$userId}";
                $purchasedBookIds = Cache::remember($cacheKey, 300, function () use ($userId) {
                    try {
                        $userBooksResponse = Http::timeout(2)->get("{$this->baseUrl}/taka_api_user_books.php", [
                            'user_id' => $userId,
                        ]);

                        if ($userBooksResponse->successful()) {
                            $userBooksData = $userBooksResponse->json();
                            if (isset($userBooksData['success']) && $userBooksData['success'] === true) {
                                return array_map('intval', $userBooksData['books'] ?? []);
                            }
                        }
                    } catch (\Exception $e) {
                        \Log::warning("Error loading purchased books: " . $e->getMessage());
                    }
                    return [];
                });
            }
        } catch (\Exception $e) {
            // En cas d'erreur, continuer avec des tableaux vides
            \Log::error("Error in ExploreController: " . $e->getMessage());
        }

        // Genres disponibles (comme dans Flutter)
        $genres = [
            'Tous',
            'Roman',
            'Développement personnel',
            'Religion et spiritualité',
            'Littérature noire africaine',
            'Fiction',
            'Histoire',
            'Biographie',
            'Poésie',
            'Essai',
            'Jeunesse',
            'Non-fiction',
            
        ];

        // Langues disponibles (comme dans Flutter)
        $languages = [
            'Toutes',
            'Français',
            'Anglais',
            'Arabe',
            'Swahili',
            'Wolof',
            'Hausa',
        ];

        $baseUrl = $this->baseUrl;
        $isLoggedIn = Auth::check();
        $user = Auth::user();
        
        // Calculer le nombre total de pages pour la vue
        $totalPages = max(1, (int)ceil($totalBooks / $perPage));

        return view('explore', compact(
            'books',
            'totalBooks',
            'totalPages',
            'purchasedBookIds',
            'genres',
            'languages',
            'search',
            'genre',
            'language',
            'priceFilter',
            'sort',
            'page',
            'perPage',
            'viewMode',
            'baseUrl',
            'isLoggedIn',
            'user'
        ));
    }

    /**
     * Filtrer les livres par prix (logique identique à Flutter)
     */
    private function filterBooksByPrice(array $books, string $priceFilter): array
    {
        if ($priceFilter === 'all') {
            return array_values($books); // Pas de filtrage, réindexer
        }
        
        // Logique EXACTEMENT identique à Flutter (lignes 169-190 de explore_screen.dart)
        $filtered = array_filter($books, function ($book) use ($priceFilter) {
            // Exactement comme Flutter: book['price_type']?.toString().toLowerCase() ?? ''
            $priceType = '';
            if (isset($book['price_type']) && $book['price_type'] !== null) {
                $priceType = strtolower(trim((string)$book['price_type']));
            }
            
            // Exactement comme Flutter: book['price']?.toString() ?? ''
            // Gérer le cas où price peut être NULL, un entier, ou une string
            $priceStr = '';
            if (isset($book['price']) && $book['price'] !== null) {
                $priceStr = trim((string)$book['price']);
            }
            
            // Exactement comme Flutter: double.tryParse(priceStr)
            // Si priceStr est vide, price reste null
            // Si priceStr contient un nombre, on le parse
            $price = null;
            if (!empty($priceStr)) {
                $parsed = filter_var($priceStr, FILTER_VALIDATE_FLOAT);
                if ($parsed !== false) {
                    $price = (float)$parsed;
                }
            }

            if ($priceFilter === 'free') {
                // Exactement comme Flutter ligne 175-180:
                // priceType == 'gratuit' || price == 0 || price == null || priceStr.isEmpty
                $isFree = $priceType === 'gratuit' ||
                         ($price !== null && abs($price) < 0.0001) || // price == 0
                         $price === null ||
                         empty($priceStr);
                
                return $isFree;
            } elseif ($priceFilter === 'paid') {
                // Exactement comme Flutter ligne 182-185:
                // price != null && price > 0 && priceType != 'gratuit'
                $isPaid = $price !== null &&
                         $price > 0.0001 && // price > 0 (avec tolérance pour les floats)
                         $priceType !== 'gratuit';
                
                return $isPaid;
            }

            return true; // Ne devrait pas arriver ici
        });
        
        // Réindexer le tableau (comme Flutter .toList())
        return array_values($filtered);
    }
}
