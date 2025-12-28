<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class PublishController extends Controller
{
    public function index()
    {
        if (!Auth::check()) {
            return redirect()->route('login')->with('error', 'Vous devez être connecté pour publier un livre.');
        }

        $user = Auth::user();
        $isLoggedIn = true;

        // Plans de publication (identique à Flutter)
        $plans = [
            [
                'id' => 'basic',
                'name' => 'BASIQUE',
                'price' => '0 FCFA',
                'features' => [
                    'Mise en ligne de ton livre sur la plateforme TAKA',
                    'Présence sur nos réseaux sociaux (Facebook, Instagram, TikTok)',
                    'Rémunération auteur : 80% du prix de vente',
                ]
            ],
            [
                'id' => 'premium',
                'name' => 'PREMIUM',
                'price' => '0 FCFA',
                'features' => [
                    'Tous les avantages de l\'Offre Basique',
                    'Publicité sponsorisée Facebook + Instagram (coût pris en charge par TAKA)',
                    'Rémunération auteur : 50% sur ventes générées',
                ]
            ],
            [
                'id' => 'international',
                'name' => 'VENDS TON LIVRE A L\'INTERNATIONAL',
                'price' => '30.000 FCFA',
                'features' => [
                    'Publié sur TAKA + Amazon KDP (ebook et papier)',
                    'Analysé et optimisé par notre maison d\'édition partenaire',
                    'Coaching éditorial obligatoire à 50.000 FCFA',
                    'Rémunération Amazon : 30% des ventes',
                    'Publicité sponsorisée Facebook + Instagram',
                    'Rémunération auteur : 40% sur ventes générées',
                ]
            ],
            
        ];

        // Thématiques (mise à jour)
        $genres = [
            'Argent & Richesse',
            'Business & Entrepreneuriat',
            'Leadership & Pouvoir',
            'Psychologie & Comportement humain',
            'Spiritualité & Conscience',
            'Philosophie & Sagesse',
            'Histoire & Géopolitique',
            'Sociétés & Civilisations',
            'Science & Connaissance',
            'Développement personnel',
            'Relations & Sexualité',
            'Politique & Stratégie',
            'Ésotérisme & Savoirs cachés',
            'Religion & Textes sacrés',
            'Afrique & Identité',
            'Livres rares & interdits'
        ];

        return view('publish', compact('plans', 'genres', 'user', 'isLoggedIn'));
    }

    public function store(Request $request)
    {
        // La soumission se fait via JavaScript directement vers l'API
        // Ce contrôleur sert juste à afficher la vue
        return redirect()->route('publish');
    }
}
