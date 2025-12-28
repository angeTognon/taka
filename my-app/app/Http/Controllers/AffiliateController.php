<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Http;

class AffiliateController extends Controller
{
    private $baseUrl = "https://takaafrica.com/pharmaRh/taka";

    public function index()
    {
        if (!Auth::check()) {
            return redirect()->route('login')->with('error', 'Vous devez être connecté pour accéder au programme d\'affiliation.');
        }

        $user = Auth::user();
        $userId = $user->api_id ?? $user->id;

        // Récupérer les données en parallèle
        try {
            $responses = Http::pool(function ($pool) use ($userId) {
                return [
                    $pool->timeout(5)->get("{$this->baseUrl}/taka_api_affiliate_stats.php", ['user_id' => $userId]),
                    $pool->timeout(5)->get("{$this->baseUrl}/taka_api_list_affiliate_links.php", ['user_id' => $userId]),
                ];
            });

            // Statistiques d'affiliation
            $stats = [
                'totalClicks' => 0,
                'conversions' => 0,
                'conversionRate' => 0.0,
                'totalEarnings' => 0,
                'pendingPayment' => 0,
                'thisMonthEarnings' => 0,
            ];

            if ($responses[0]->successful()) {
                $statsData = $responses[0]->json();
                $stats['totalClicks'] = $statsData['totalClicks'] ?? 0;
                $stats['conversions'] = $statsData['conversions'] ?? 0;
                $stats['conversionRate'] = $statsData['conversionRate'] ?? 0.0;
                $stats['totalEarnings'] = $statsData['totalEarnings'] ?? 0;
                $stats['pendingPayment'] = $statsData['pendingPayment'] ?? 0;
                $stats['thisMonthEarnings'] = $statsData['thisMonthEarnings'] ?? 0;
            }

            // Liste des liens d'affiliation
            $affiliateLinks = [];
            if ($responses[1]->successful()) {
                $linksData = $responses[1]->json();
                if (isset($linksData['links'])) {
                    $affiliateLinks = $linksData['links'];
                }
            }

        } catch (\Exception $e) {
            \Log::error("AffiliateController error: " . $e->getMessage());
            $stats = [
                'totalClicks' => 0,
                'conversions' => 0,
                'conversionRate' => 0.0,
                'totalEarnings' => 0,
                'pendingPayment' => 0,
                'thisMonthEarnings' => 0,
            ];
            $affiliateLinks = [];
        }

        return view('affiliate', compact('stats', 'affiliateLinks', 'user'));
    }

    public function createLink(Request $request)
    {
        if (!Auth::check()) {
            return response()->json(['success' => false, 'error' => 'Non autorisé'], 401);
        }

        $request->validate([
            'title' => 'required|string|max:255',
            'type' => 'required|string|in:book,general,subscription',
            'book_id' => 'nullable|integer|required_if:type,book',
        ]);

        $user = Auth::user();
        $userId = $user->api_id ?? $user->id;

        try {
            $response = Http::timeout(5)->asJson()->post("{$this->baseUrl}/taka_api_create_affiliate_link.php", [
                'user_id' => $userId,
                'type' => $request->type,
                'title' => $request->title,
                'book_id' => $request->type === 'book' ? $request->book_id : null,
            ]);

            $data = $response->json();

            if (isset($data['success']) && $data['success'] === true) {
                return response()->json(['success' => true, 'link' => $data['link'] ?? null]);
            } else {
                return response()->json(['success' => false, 'error' => $data['error'] ?? 'Erreur lors de la création']);
            }
        } catch (\Exception $e) {
            \Log::error("Error creating affiliate link: " . $e->getMessage());
            return response()->json(['success' => false, 'error' => 'Erreur lors de la création']);
        }
    }

    public function editLink(Request $request)
    {
        if (!Auth::check()) {
            return response()->json(['success' => false, 'error' => 'Non autorisé'], 401);
        }

        $request->validate([
            'link_id' => 'required|integer',
            'title' => 'required|string|max:255',
            'type' => 'required|string|in:book,general,subscription',
            'book_id' => 'nullable|integer|required_if:type,book',
        ]);

        $user = Auth::user();
        $userId = $user->api_id ?? $user->id;

        try {
            $response = Http::timeout(5)->asJson()->post("{$this->baseUrl}/taka_api_edit_affiliate_link.php", [
                'link_id' => $request->link_id,
                'user_id' => $userId,
                'type' => $request->type,
                'title' => $request->title,
                'book_id' => $request->type === 'book' ? $request->book_id : null,
            ]);

            $data = $response->json();

            if (isset($data['success']) && $data['success'] === true) {
                return response()->json(['success' => true]);
            } else {
                return response()->json(['success' => false, 'error' => $data['error'] ?? 'Erreur lors de la modification']);
            }
        } catch (\Exception $e) {
            \Log::error("Error editing affiliate link: " . $e->getMessage());
            return response()->json(['success' => false, 'error' => 'Erreur lors de la modification']);
        }
    }

    public function deleteLink(Request $request)
    {
        if (!Auth::check()) {
            return response()->json(['success' => false, 'error' => 'Non autorisé'], 401);
        }

        $request->validate([
            'link_id' => 'required|integer',
        ]);

        $user = Auth::user();
        $userId = $user->api_id ?? $user->id;

        try {
            $response = Http::timeout(5)->asJson()->post("{$this->baseUrl}/taka_api_delete_affiliate_link.php", [
                'link_id' => $request->link_id,
                'user_id' => $userId,
            ]);

            $data = $response->json();

            if (isset($data['success']) && $data['success'] === true) {
                return response()->json(['success' => true]);
            } else {
                return response()->json(['success' => false, 'error' => $data['error'] ?? 'Erreur lors de la suppression']);
            }
        } catch (\Exception $e) {
            \Log::error("Error deleting affiliate link: " . $e->getMessage());
            return response()->json(['success' => false, 'error' => 'Erreur lors de la suppression']);
        }
    }

    public function getAuthorBooks()
    {
        if (!Auth::check()) {
            return response()->json(['success' => false, 'error' => 'Non autorisé'], 401);
        }

        $user = Auth::user();
        $userId = $user->api_id ?? $user->id;

        try {
            $response = Http::timeout(5)->get("{$this->baseUrl}/taka_get_author_book.php", [
                'user_id' => $userId,
            ]);

            if ($response->successful()) {
                $data = $response->json();
                return response()->json(['success' => true, 'books' => $data['books'] ?? []]);
            } else {
                return response()->json(['success' => false, 'books' => []]);
            }
        } catch (\Exception $e) {
            \Log::error("Error fetching author books: " . $e->getMessage());
            return response()->json(['success' => false, 'books' => []]);
        }
    }
}
