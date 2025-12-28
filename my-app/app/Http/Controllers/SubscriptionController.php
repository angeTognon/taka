<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Http;

class SubscriptionController extends Controller
{
    private $baseUrl = "https://takaafrica.com/pharmaRh/taka";

    public function index(Request $request)
    {
        $user = Auth::user();
        $activeSubscription = null;
        $isLoggedIn = Auth::check();

        // Récupérer l'abonnement actif si l'utilisateur est connecté
        if ($isLoggedIn && $user) {
            try {
                    $response = Http::get("{$this->baseUrl}/taka_api_subscriptions.php", [
                    'user_id' => $user->api_id ?? $user->id ?? null,
                ]);

                if ($response->successful()) {
                    $subscriptions = $response->json();
                    if (is_array($subscriptions) && !empty($subscriptions)) {
                        $activeSubscription = $subscriptions[0];
                        
                        // Vérifier si l'abonnement est actif
                        if (isset($activeSubscription['expires_at'])) {
                            $expiresAt = \Carbon\Carbon::parse($activeSubscription['expires_at']);
                            if ($expiresAt->isPast() || ($activeSubscription['status'] ?? '') !== 'payé') {
                                $activeSubscription = null;
                            }
                        }
                    }
                }
            } catch (\Exception $e) {
                \Log::error("Error fetching subscription: " . $e->getMessage());
            }
        }

        // Plans mis à jour selon les nouvelles spécifications
        $plans = [
            [
                'id' => 'monthly',
                'name' => 'Abonnement mensuel',
                'price' => '2000',
                'period' => 'mois',
                'old_price' => null,
                'popular' => false,
            ],
            [
                'id' => '3months',
                'name' => 'Abonnement 3 mois',
                'price' => '5000',
                'period' => '3 mois',
                'old_price' => '6000',
                'popular' => false,
            ],
            [
                'id' => 'annual',
                'name' => 'Abonnement annuel',
                'price' => '18000',
                'period' => 'an',
                'old_price' => '24000',
                'popular' => false,
            ],
        ];

        return view('subscription', compact('plans', 'activeSubscription', 'isLoggedIn', 'user'));
    }
}
