<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class HomeController extends Controller
{
    public function index()
    {
        $trendingBooks = [];
        
        try {
            $response = Http::get('https://takaafrica.com/pharmaRh/taka/taka_api_books.php', [
                'sort' => 'bestseller',
                'per_page' => 4,
                'page' => 1,
            ]);
            
            if ($response->successful()) {
                $data = $response->json();
                $trendingBooks = $data['books'] ?? [];
            }
        } catch (\Exception $e) {
            // En cas d'erreur, on continue avec un tableau vide
            $trendingBooks = [];
        }
        
        return view('home', compact('trendingBooks'));
    }
}
