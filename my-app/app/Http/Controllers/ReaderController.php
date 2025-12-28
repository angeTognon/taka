<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use App\Helpers\BookHelper;

class ReaderController extends Controller
{
    private $baseUrl = "https://takaafrica.com/pharmaRh/taka";

    public function show($slug)
    {
        // Décoder le slug (au cas où il serait URL encodé)
        $slug = urldecode($slug);
        
        $book = null;
        
        try {
            // Charger tous les livres pour trouver celui correspondant au slug
            $response = Http::timeout(8)->get("{$this->baseUrl}/taka_api_books.php", [
                'per_page' => 1000,
            ]);
            
            if ($response->successful()) {
                $data = $response->json();
                $allBooks = $data['books'] ?? [];
                
                // Si le slug est un nombre (ID), chercher directement par ID
                if (is_numeric($slug)) {
                    $bookId = (int)$slug;
                    foreach ($allBooks as $b) {
                        $bId = is_numeric($b['id'] ?? null) ? (int)$b['id'] : 0;
                        if ($bId === $bookId) {
                            $book = $b;
                            break;
                        }
                    }
                } else {
                    // Sinon, chercher par slug comme d'habitude
                    foreach ($allBooks as $b) {
                        $bookTitle = $b['title'] ?? '';
                        if (empty($bookTitle)) {
                            continue;
                        }
                        
                        // Générer le slug à partir du titre
                        $bookSlugGenerated = BookHelper::titleToSlug($bookTitle);
                        
                        if ($bookSlugGenerated === $slug) {
                            $book = $b;
                            break;
                        }
                    }
                    
                    // Si pas trouvé, essayer avec Str::slug()
                    if (!$book) {
                        foreach ($allBooks as $b) {
                            $bookTitle = $b['title'] ?? '';
                            if (empty($bookTitle)) {
                                continue;
                            }
                            $bookSlugLaravel = \Illuminate\Support\Str::slug($bookTitle);
                            if ($bookSlugLaravel === $slug) {
                                $book = $b;
                                break;
                            }
                        }
                    }
                }
            }
        } catch (\Exception $e) {
            \Log::error("Error loading book for reader with slug '$slug': " . $e->getMessage());
        }
        
        if (!$book) {
            abort(404, 'Livre non trouvé');
        }
        
        // Construire l'URL du fichier PDF
        $filePath = $book['file_path'] ?? '';
        $pdfUrl = '';
        if (!empty($filePath)) {
            if (str_starts_with($filePath, 'http')) {
                $pdfUrl = $filePath;
            } else {
                $pdfUrl = $this->baseUrl . '/' . $filePath;
            }
        }
        
        $bookTitle = $book['title'] ?? '';
        $bookAuthor = $book['author'] ?? '';
        $totalPages = is_numeric($book['pages'] ?? null) ? (int)$book['pages'] : 1;
        
        return view('reader', compact('book', 'bookTitle', 'bookAuthor', 'totalPages', 'pdfUrl', 'slug'));
    }
}
