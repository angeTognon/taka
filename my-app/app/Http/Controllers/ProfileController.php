<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Http;
use Carbon\Carbon;

class ProfileController extends Controller
{
    private $baseUrl = "https://takaafrica.com/pharmaRh/taka";

    public function index()
    {
        if (!Auth::check()) {
            return redirect()->route('login')->with('error', 'Vous devez être connecté pour accéder à cette page.');
        }

        $user = Auth::user();
        $isLoggedIn = true;

        // Récupérer created_at depuis l'API (comme dans Flutter)
        $daysOnTaka = 0;
        $monthsOnTaka = 0;
        $userCreatedAt = null;
        
        try {
            $userId = $user->api_id ?? $user->id;
            
            // D'abord essayer de récupérer depuis la session (données stockées lors du login)
            $userApiData = session('user_api_data');
            \Log::info('ProfileController - Session user_api_data:', $userApiData ?? []);
            
            if ($userApiData && isset($userApiData['created_at']) && !empty($userApiData['created_at'])) {
                try {
                    $createdAtStr = $userApiData['created_at'];
                    \Log::info('ProfileController - Found created_at in session: ' . $createdAtStr);
                    // Essayer de parser la date avec différents formats
                    try {
                        $userCreatedAt = \Carbon\Carbon::createFromFormat('Y-m-d H:i:s', $createdAtStr);
                    } catch (\Exception $e1) {
                        try {
                            $userCreatedAt = \Carbon\Carbon::parse($createdAtStr);
                        } catch (\Exception $e2) {
                            \Log::warning('ProfileController - Error parsing created_at: ' . $e2->getMessage());
                            $userCreatedAt = null;
                        }
                    }
                } catch (\Exception $e) {
                    \Log::warning('ProfileController - Error parsing created_at from session: ' . $e->getMessage());
                    $userCreatedAt = null;
                }
            }
            
            // Si pas dans la session, essayer de relogger via l'API pour récupérer created_at
            if (!$userCreatedAt) {
                try {
                    // Option: utiliser l'email de l'utilisateur pour récupérer les infos
                    // Mais on ne peut pas faire login sans password...
                    // Donc on essaie directement avec l'API si elle supporte get_user
                    $response = Http::timeout(5)->get("{$this->baseUrl}/taka_api_users.php", [
                        'action' => 'get_user',
                        'user_id' => $userId,
                    ]);
                    
                    if ($response->successful()) {
                        $data = $response->json();
                        \Log::info('ProfileController - API response:', $data);
                        if (isset($data['user']) && isset($data['user']['created_at'])) {
                            $createdAtStr = $data['user']['created_at'];
                            $userCreatedAt = \Carbon\Carbon::parse($createdAtStr);
                        } elseif (isset($data['created_at'])) {
                            $createdAtStr = $data['created_at'];
                            $userCreatedAt = \Carbon\Carbon::parse($createdAtStr);
                        }
                    } else {
                        \Log::warning('ProfileController - API call failed: ' . $response->status());
                    }
                } catch (\Exception $e) {
                    \Log::warning("ProfileController - Error calling API for user info: " . $e->getMessage());
                }
            }
            
            // Si toujours pas de created_at, utiliser la date locale en fallback
            if (!$userCreatedAt) {
                \Log::warning('ProfileController - Using local created_at as fallback');
                // Essayer aussi de récupérer depuis la base locale si api_id correspond
                $userCreatedAt = $user->created_at ?? now();
            }
            
            // Vérifier que created_at n'est pas dans le futur (bug possible)
            if ($userCreatedAt && $userCreatedAt->isFuture()) {
                \Log::warning('ProfileController - created_at is in the future, using now()');
                $userCreatedAt = now();
            }
            
            // Calculer jours et mois (comme dans Flutter: DateTime.now().difference(createdAt).inDays)
            if ($userCreatedAt) {
                $now = Carbon::now();
                
                // Calculer la différence en jours depuis created_at jusqu'à maintenant
                // Inverser l'ordre pour avoir une valeur positive
                if ($userCreatedAt->isFuture()) {
                    // Si created_at est dans le futur, c'est un bug, utiliser 0
                    $daysOnTaka = 0;
                } else {
                    // $userCreatedAt->diffInDays($now) = nombre de jours depuis created_at jusqu'à maintenant
                    // Ou utiliser la valeur absolue de $now->diffInDays($userCreatedAt)
                    $daysOnTaka = max(0, (int)abs($now->diffInDays($userCreatedAt, false)));
                }
                
                $monthsOnTaka = max(0, (int)floor($daysOnTaka / 30));
            } else {
                $daysOnTaka = 0;
                $monthsOnTaka = 0;
            }
            
            \Log::info("ProfileController - Calculated days: $daysOnTaka, months: $monthsOnTaka");
        } catch (\Exception $e) {
            \Log::error("ProfileController - Error fetching user created_at: " . $e->getMessage());
            // Fallback sur le calcul local
            $userCreatedAt = $user->created_at ?? now();
            $daysOnTaka = max(0, (int)Carbon::now()->diffInDays($userCreatedAt));
            $monthsOnTaka = max(0, (int)floor($daysOnTaka / 30));
        }

        // Charger 6 livres aléatoirement pour les recommandations
        $recommendations = [];
        try {
            $userId = $user->api_id ?? $user->id;
            
            // Essayer d'abord l'API de recommandations
            $recommendationsResponse = Http::timeout(5)->get("{$this->baseUrl}/taka_api_recommendations.php", [
                'user_id' => $userId,
            ]);
            
            if ($recommendationsResponse->successful()) {
                $recommendationsData = $recommendationsResponse->json();
                if (isset($recommendationsData['success']) && $recommendationsData['success'] === true && isset($recommendationsData['books'])) {
                    $recommendations = $recommendationsData['books'];
                    // Si on a plus de 6, prendre 6 aléatoirement
                    if (count($recommendations) > 6) {
                        shuffle($recommendations);
                        $recommendations = array_slice($recommendations, 0, 6);
                    }
                }
            }
            
            // Si pas de recommandations ou pas assez, charger des livres aléatoirement depuis l'API générale
            if (count($recommendations) < 6) {
                $allBooksResponse = Http::timeout(8)->get("{$this->baseUrl}/taka_api_books.php", [
                    'per_page' => 100,
                ]);
                
                if ($allBooksResponse->successful()) {
                    $allBooksData = $allBooksResponse->json();
                    $allBooks = $allBooksData['books'] ?? [];
                    
                    // Mélanger et prendre 6 livres
                    shuffle($allBooks);
                    $randomBooks = array_slice($allBooks, 0, 6);
                    
                    // Combiner avec les recommandations existantes (sans doublons)
                    $existingIds = array_map(function($book) {
                        return $book['id'] ?? null;
                    }, $recommendations);
                    
                    foreach ($randomBooks as $book) {
                        if (count($recommendations) >= 6) break;
                        $bookId = $book['id'] ?? null;
                        if (!in_array($bookId, $existingIds)) {
                            $recommendations[] = $book;
                            $existingIds[] = $bookId;
                        }
                    }
                }
            }
        } catch (\Exception $e) {
            \Log::warning("Error loading recommendations: " . $e->getMessage());
        }

        // Note: Les livres en cours de lecture sont gérés côté client via localStorage
        // Les livres achetés sont chargés via JavaScript

        return view('profile', compact('user', 'isLoggedIn', 'daysOnTaka', 'monthsOnTaka', 'recommendations'));
    }

    public function update(Request $request)
    {
        $request->validate([
            'full_name' => 'required|string|max:255',
        ]);

        $user = Auth::user();
        
        try {
            // Mettre à jour via l'API comme dans Flutter
            $response = Http::asForm()->post("{$this->baseUrl}/taka_api_update_profile.php", [
                'user_id' => $user->api_id ?? $user->id,
                'full_name' => $request->full_name,
            ]);

            $data = $response->json();

            if (isset($data['success']) && $data['success'] === true) {
                // Mettre à jour aussi localement
                $user->name = $request->full_name;
                $user->save();

                return back()->with('success', 'Profil mis à jour !');
            } else {
                return back()->withErrors(['error' => $data['error'] ?? 'Impossible de mettre à jour.']);
            }
        } catch (\Exception $e) {
            \Log::error("Error updating profile: " . $e->getMessage());
            return back()->withErrors(['error' => 'Erreur lors de la mise à jour.']);
        }
    }
}
