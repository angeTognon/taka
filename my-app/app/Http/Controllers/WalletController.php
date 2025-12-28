<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Http;

class WalletController extends Controller
{
    private $baseUrl = "https://takaafrica.com/pharmaRh/taka";

    public function index()
    {
        if (!Auth::check()) {
            return redirect()->route('login')->with('error', 'Vous devez être connecté pour accéder à votre portefeuille.');
        }

        $user = Auth::user();
        $userId = $user->api_id ?? $user->id;

        // Récupérer les données en parallèle
        try {
            $responses = Http::pool(function ($pool) use ($userId) {
                return [
                    $pool->timeout(5)->get("{$this->baseUrl}/taka_api_author_sales.php", ['user_id' => $userId]),
                    $pool->timeout(5)->get("{$this->baseUrl}/taka_api_affiliate_earnings.php", ['user_id' => $userId]),
                    $pool->timeout(3)->get("{$this->baseUrl}/taka_api_wallet_withdraw.php", ['user_id' => $userId]),
                ];
            });

            // Statistiques auteur (ventes, revenus, lecteurs)
            $authorStats = [
                'totalSales' => 0,
                'totalRevenue' => 0,
                'totalReaders' => 0,
            ];

            if ($responses[0]->successful()) {
                $statsData = $responses[0]->json();
                if (isset($statsData['success']) && $statsData['success'] === true) {
                    $authorStats['totalSales'] = $statsData['totalSales'] ?? 0;
                    $authorStats['totalRevenue'] = $statsData['totalRevenue'] ?? 0;
                    $authorStats['totalReaders'] = $statsData['totalReaders'] ?? 0;
                }
            }

            // Transactions d'affiliation (seulement type "book")
            $transactions = [];
            if ($responses[1]->successful()) {
                $earningsData = $responses[1]->json();
                if (isset($earningsData['success']) && $earningsData['success'] === true && isset($earningsData['earnings'])) {
                    // Filtrer uniquement les transactions de type "book"
                    $transactions = array_filter($earningsData['earnings'], function($tx) {
                        return isset($tx['type']) && $tx['type'] === 'book';
                    });
                    $transactions = array_values($transactions); // Réindexer le tableau
                }
            }

            // Statut de retrait
            $hasRequestedWithdrawal = false;
            if ($responses[2]->successful()) {
                $withdrawData = $responses[2]->json();
                $hasRequestedWithdrawal = isset($withdrawData['requested']) && $withdrawData['requested'] === true;
            }

            // Calculer le solde total
            // Solde = totalRevenue (auteur) + somme des affiliations de type "book"
            $affiliationsTotal = 0;
            foreach ($transactions as $tx) {
                $amount = isset($tx['amount']) ? (is_numeric($tx['amount']) ? (int)$tx['amount'] : 0) : 0;
                $affiliationsTotal += $amount;
            }
            $balance = $authorStats['totalRevenue'] + $affiliationsTotal;

        } catch (\Exception $e) {
            \Log::error("WalletController error: " . $e->getMessage());
            $authorStats = [
                'totalSales' => 0,
                'totalRevenue' => 0,
                'totalReaders' => 0,
            ];
            $transactions = [];
            $hasRequestedWithdrawal = false;
            $balance = 0;
        }

        return view('wallet', compact('authorStats', 'transactions', 'hasRequestedWithdrawal', 'balance', 'user'));
    }

    public function checkWithdrawalStatus()
    {
        if (!Auth::check()) {
            return response()->json(['success' => false, 'error' => 'Non autorisé'], 401);
        }

        $user = Auth::user();
        $userId = $user->api_id ?? $user->id;

        try {
            $response = Http::timeout(3)->get("{$this->baseUrl}/taka_api_wallet_withdraw.php", [
                'user_id' => $userId,
            ]);

            if ($response->successful()) {
                $data = $response->json();
                return response()->json([
                    'success' => true,
                    'requested' => isset($data['requested']) && $data['requested'] === true,
                ]);
            } else {
                return response()->json(['success' => false, 'requested' => false]);
            }
        } catch (\Exception $e) {
            \Log::error("Error checking withdrawal status: " . $e->getMessage());
            return response()->json(['success' => false, 'requested' => false]);
        }
    }

    public function requestWithdrawal(Request $request)
    {
        if (!Auth::check()) {
            return response()->json(['success' => false, 'error' => 'Non autorisé'], 401);
        }

        $user = Auth::user();
        $userId = $user->api_id ?? $user->id;

        try {
            $response = Http::timeout(5)->asJson()->post("{$this->baseUrl}/taka_api_wallet_withdraw.php", [
                'user_id' => $userId,
            ]);

            $data = $response->json();

            if (isset($data['success']) && $data['success'] === true) {
                return response()->json(['success' => true]);
            } else {
                return response()->json(['success' => false, 'error' => $data['error'] ?? 'Erreur lors de la demande de retrait']);
            }
        } catch (\Exception $e) {
            \Log::error("Error requesting withdrawal: " . $e->getMessage());
            return response()->json(['success' => false, 'error' => 'Erreur lors de la demande de retrait']);
        }
    }
}
