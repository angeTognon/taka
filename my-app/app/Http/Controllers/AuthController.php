<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Http;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    private $baseUrl = "https://takaafrica.com/pharmaRh/taka";

    public function showLogin()
    {
        return view('auth.login');
    }

    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        try {
            // Appel à l'API comme dans Flutter
            $response = Http::withHeaders([
                'Content-Type' => 'application/json',
            ])->post("{$this->baseUrl}/taka_api_users.php?action=login", [
                'email' => $request->email,
                'password' => $request->password,
            ]);

            $data = $response->json();

            if (isset($data['success']) && $data['success'] === true && isset($data['user'])) {
                $userData = $data['user'];
                
                // Log pour debug
                \Log::info('AuthController - Login API response userData:', $userData);
                
                // Récupérer created_at depuis l'API
                $apiCreatedAt = $userData['created_at'] ?? ($userData['createdAt'] ?? null);
                
                // Créer ou mettre à jour l'utilisateur localement pour la session Laravel
                $updateData = [
                    'name' => $userData['full_name'] ?? 'Utilisateur TAKA',
                    'password' => Hash::make($request->password), // Stocker le mot de passe hashé localement
                    'api_id' => (string)$userData['id'], // Stocker l'ID de l'API
                ];
                
                // Si created_at vient de l'API et que l'utilisateur n'existe pas encore, l'utiliser
                if ($apiCreatedAt) {
                    try {
                        $parsedDate = \Carbon\Carbon::parse($apiCreatedAt);
                        // Si l'utilisateur n'existe pas, on peut définir created_at
                        $existingUser = User::where('email', $userData['email'])->first();
                        if (!$existingUser) {
                            $updateData['created_at'] = $parsedDate;
                        }
                    } catch (\Exception $e) {
                        // Ignorer si le parsing échoue
                    }
                }
                
                $user = User::updateOrCreate(
                    ['email' => $userData['email']],
                    $updateData
                );

                // Connecter l'utilisateur
                Auth::login($user, $request->boolean('remember'));
                $request->session()->regenerate();

                // Stocker les données additionnelles dans la session (comme dans Flutter SharedPreferences)
                // Inclure created_at pour le calcul des jours sur TAKA
                // L'API peut retourner created_at dans userData directement ou dans userData['created_at']
                $createdAt = $userData['created_at'] ?? ($userData['createdAt'] ?? null);
                
                // Si pas de created_at dans l'API, utiliser la date locale
                if (!$createdAt) {
                    $createdAt = $user->created_at ? $user->created_at->toDateTimeString() : now()->toDateTimeString();
                }
                
                $sessionData = [
                    'id' => $userData['id'],
                    'full_name' => $userData['full_name'] ?? 'Utilisateur TAKA',
                    'email' => $userData['email'],
                    'created_at' => $createdAt,
                ];
                
                \Log::info('AuthController - Storing in session:', $sessionData);
                session(['user_api_data' => $sessionData]);

                return redirect()->intended(route('home'))->with('success', 'Connexion réussie ! Bienvenue sur TAKA.');
            } else {
                return back()->withErrors([
                    'email' => 'Identifiants invalides',
                ])->onlyInput('email');
            }
        } catch (\Exception $e) {
            \Log::error("Login error: " . $e->getMessage());
            return back()->withErrors([
                'email' => 'Erreur lors de la connexion. Veuillez réessayer.',
            ])->onlyInput('email');
        }
    }

    public function register(Request $request)
    {
        $request->validate([
            'full_name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255',
            'password' => 'required|string|min:6|confirmed',
        ]);

        try {
            // Appel à l'API comme dans Flutter
            $body = [
                'full_name' => $request->full_name,
                'email' => $request->email,
                'password' => $request->password,
            ];

            // Ajouter le paramètre ref si présent dans la requête (affiliation)
            if ($request->has('ref') && !empty($request->ref)) {
                $body['ref'] = $request->ref;
            }

            $response = Http::withHeaders([
                'Content-Type' => 'application/json',
            ])->post("{$this->baseUrl}/taka_api_users.php?action=register", $body);

            $data = $response->json();

            if (isset($data['success']) && $data['success'] === true) {
                // Créer l'utilisateur localement
                $user = User::updateOrCreate(
                    ['email' => $request->email],
                    [
                        'name' => $request->full_name,
                        'password' => Hash::make($request->password),
                        'api_id' => isset($data['id']) ? (string)$data['id'] : null,
                    ]
                );

                // Connecter l'utilisateur
                Auth::login($user);
                $request->session()->regenerate();

                // Stocker les données additionnelles dans la session
                if (isset($data['created_at'])) {
                    session(['user_api_data' => [
                        'id' => $data['id'],
                        'full_name' => $request->full_name,
                        'email' => $request->email,
                        'created_at' => $data['created_at'] ?? now()->toDateTimeString(),
                    ]]);
                }

                return redirect()->route('home')->with('success', 'Inscription réussie ! Bienvenue sur TAKA.');
            } else {
                $errorMessage = $data['error'] ?? 'Erreur lors de l\'inscription (email déjà utilisé ?)';
                return back()->withErrors([
                    'email' => $errorMessage,
                ])->withInput($request->except('password', 'password_confirmation'));
            }
        } catch (\Exception $e) {
            \Log::error("Register error: " . $e->getMessage());
            return back()->withErrors([
                'email' => 'Erreur lors de l\'inscription. Veuillez réessayer.',
            ])->withInput($request->except('password', 'password_confirmation'));
        }
    }

    public function logout(Request $request)
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();
        return redirect()->route('home');
    }
}
