<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Cache;

class DashboardController extends Controller
{
    private $baseUrl = "https://takaafrica.com/pharmaRh/taka";

    public function index(Request $request)
    {
        if (!Auth::check()) {
            return redirect()->route('login')->with('error', 'Vous devez être connecté pour accéder au tableau de bord auteur.');
        }

        $user = Auth::user();
        $userId = $user->api_id ?? $user->id;
        $period = $request->get('period', 'month'); // week, month, year, all

        // Récupérer toutes les données en parallèle
        try {
            $responses = Http::pool(function ($pool) use ($userId, $period) {
                // Si period='all', ne pas envoyer le paramètre period à l'API
                // L'API utilisera alors 'month' par défaut, mais on va faire un appel supplémentaire pour 'all'
                $apiParams = ['user_id' => $userId];
                if ($period !== 'all') {
                    $apiParams['period'] = $period;
                }
                return [
                    $pool->timeout(5)->get("{$this->baseUrl}/taka_api_author_sales.php", ['user_id' => $userId]),
                    $pool->timeout(5)->get("{$this->baseUrl}/taka_api_author_books.php", $apiParams),
                    $pool->timeout(5)->get("{$this->baseUrl}/taka_api_books_count.php", ['user_id' => $userId]),
                    $pool->timeout(5)->get("{$this->baseUrl}/taka_api_author_performance.php", ['user_id' => $userId]),
                    $pool->timeout(5)->get("{$this->baseUrl}/taka_api_author_sales_chart.php", ['user_id' => $userId]),
                ];
            });

            // Stats globales
            $stats = [
                'totalBooks' => 0,
                'totalSales' => 0,
                'totalRevenue' => 0,
                'totalReaders' => 0,
            ];

            if ($responses[0]->successful()) {
                $salesData = $responses[0]->json();
                if (isset($salesData['success']) && $salesData['success'] === true) {
                    $stats['totalSales'] = $salesData['totalSales'] ?? 0;
                    $stats['totalRevenue'] = $salesData['totalRevenue'] ?? 0;
                    $stats['totalReaders'] = $salesData['totalReaders'] ?? 0;
                }
            }

            // Nombre total de livres
            if ($responses[2]->successful()) {
                $countData = $responses[2]->json();
                $stats['totalBooks'] = $countData['totalBooks'] ?? 0;
            }

            // Liste des livres avec le filtre de période
            $books = [];
            if ($responses[1]->successful()) {
                $booksData = $responses[1]->json();
                if (isset($booksData['success']) && $booksData['success'] === true && isset($booksData['books'])) {
                    $books = $booksData['books'];
                }
            }
            
            // Si period='all', on a besoin de récupérer tous les livres sans filtre de date
            // L'API ne supporte pas 'all', donc on envoie une valeur qui ne correspond à aucun filtre
            // ce qui laissera $dateFilter vide dans l'API
            if ($period === 'all') {
                try {
                    // Envoyer une valeur qui ne correspond à aucun cas (week/month/year)
                    // L'API laissera alors $dateFilter vide, donc aucun filtre de date
                    $allResponse = Http::timeout(5)->get("{$this->baseUrl}/taka_api_author_books.php", [
                        'user_id' => $userId,
                        'period' => 'all' // L'API ne reconnaîtra pas cette valeur, donc pas de filtre
                    ]);
                    if ($allResponse->successful()) {
                        $allData = $allResponse->json();
                        if (isset($allData['success']) && $allData['success'] === true && isset($allData['books'])) {
                            $books = $allData['books'];
                        }
                    }
                } catch (\Exception $e) {
                    \Log::warning("Error fetching all books: " . $e->getMessage());
                }
            }
            
            // Si aucun livre avec le filtre période mais qu'on sait qu'il y a des livres (totalBooks > 0),
            // essayer avec 'year' pour récupérer plus de livres
            if (empty($books) && $stats['totalBooks'] > 0 && !in_array($period, ['year', 'all'])) {
                try {
                    $yearResponse = Http::timeout(5)->get("{$this->baseUrl}/taka_api_author_books.php", [
                        'user_id' => $userId,
                        'period' => 'year'
                    ]);
                    if ($yearResponse->successful()) {
                        $yearData = $yearResponse->json();
                        if (isset($yearData['success']) && $yearData['success'] === true && isset($yearData['books'])) {
                            $books = $yearData['books'];
                        }
                    }
                } catch (\Exception $e) {
                    \Log::warning("Error fetching books with year filter: " . $e->getMessage());
                }
            }

            // Performances
            $performanceData = [
                'averageRating' => 0.0,
                'completionRate' => 0.0,
            ];

            if ($responses[3]->successful()) {
                $perfData = $responses[3]->json();
                if (isset($perfData['success']) && $perfData['success'] === true) {
                    $performanceData['averageRating'] = floatval($perfData['averageRating'] ?? 0);
                    $performanceData['completionRate'] = floatval($perfData['completionRate'] ?? 0);
                }
            }

            // Données du graphique
            $salesChartData = [];
            if ($responses[4]->successful()) {
                $chartData = $responses[4]->json();
                if (isset($chartData['success']) && $chartData['success'] === true && isset($chartData['sales'])) {
                    $salesChartData = $chartData['sales'];
                }
            }

        } catch (\Exception $e) {
            \Log::error("DashboardController error: " . $e->getMessage());
            $stats = [
                'totalBooks' => 0,
                'totalSales' => 0,
                'totalRevenue' => 0,
                'totalReaders' => 0,
            ];
            $books = [];
            $performanceData = [
                'averageRating' => 0.0,
                'completionRate' => 0.0,
            ];
            $salesChartData = [];
        }

        return view('dashboard', compact('stats', 'books', 'performanceData', 'salesChartData', 'period'));
    }

    public function deleteBook(Request $request)
    {
        if (!Auth::check()) {
            return response()->json(['success' => false, 'error' => 'Non autorisé'], 401);
        }

        $request->validate([
            'book_id' => 'required|integer',
        ]);

        $user = Auth::user();
        $userId = $user->api_id ?? $user->id;

        try {
            $response = Http::timeout(5)->asForm()->post("{$this->baseUrl}/taka_api_delete_book.php", [
                'id' => $request->book_id,
                'user_id' => $userId,
            ]);

            $data = $response->json();

            if (isset($data['success']) && $data['success'] === true) {
                return response()->json(['success' => true]);
            } else {
                return response()->json(['success' => false, 'error' => $data['error'] ?? 'Erreur lors de la suppression']);
            }
        } catch (\Exception $e) {
            \Log::error("Error deleting book: " . $e->getMessage());
            return response()->json(['success' => false, 'error' => 'Erreur lors de la suppression']);
        }
    }
}