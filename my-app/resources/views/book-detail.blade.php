@extends('layouts.app')

@section('title', ($book['title'] ?? 'Livre') . ' - TAKA')

@section('content')
<div class="book-detail-page">
    @php
        $title = $book['title'] ?? '';
        $author = $book['author'] ?? '';
        $genre = $book['genre'] ?? '';
        $summary = $book['summary'] ?? '';
        $priceType = strtolower($book['price_type'] ?? '');
        $price = $book['price'] ?? '';
        $pages = is_numeric($book['pages'] ?? null) ? (int)$book['pages'] : 0;
        $authorBio = $book['author_bio'] ?? '';
        $excerpt = $book['excerpt'] ?? '';
        
        $coverPath = $book['cover_path'] ?? '';
        $imageUrl = '';
        if (!empty($coverPath)) {
            if (str_starts_with($coverPath, 'http')) {
                $imageUrl = $coverPath;
            } else {
                $imageUrl = 'https://takaafrica.com/pharmaRh/taka/' . $coverPath;
            }
        }
        
        // Générer le slug pour l'URL de partage
        $slug = \App\Helpers\BookHelper::titleToSlug($title);
        $bookUrl = url('/' . $slug);
        
        // Formatage du prix
        $displayPrice = 'Gratuit';
        if ($priceType !== 'gratuit' && !empty($price) && is_numeric($price)) {
            $displayPrice = number_format((float)$price, 0, ',', ' ') . ' FCFA';
        }
        
        $isLoggedIn = auth()->check();
        
        // Prépare les noms pour le paiement
        $firstName = 'Utilisateur';
        $lastName = 'TAKA';
        if ($isLoggedIn && auth()->user()->name) {
            $nameParts = explode(' ', trim(auth()->user()->name));
            $firstName = $nameParts[0] ?? 'Utilisateur';
            $lastName = count($nameParts) > 1 ? implode(' ', array_slice($nameParts, 1)) : ($nameParts[0] ?? 'TAKA');
        } elseif ($isLoggedIn && auth()->user()->email) {
            $firstName = explode('@', auth()->user()->email)[0];
        }
    @endphp

    <!-- Header avec bouton retour et partage -->
    <div class="book-detail-header">
        <div class="container">
            <div class="book-detail-nav">
                <a href="{{ url()->previous() !== url()->current() ? url()->previous() : route('home') }}" class="back-btn">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M19 12H5M12 19l-7-7 7-7"/>
                    </svg>
                </a>
                <button class="share-btn" onclick="shareBook()">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#F97316" stroke-width="2">
                        <circle cx="18" cy="5" r="3"/>
                        <circle cx="6" cy="12" r="3"/>
                        <circle cx="18" cy="19" r="3"/>
                        <line x1="8.59" y1="13.51" x2="15.42" y2="17.49"/>
                        <line x1="15.41" y1="6.51" x2="8.59" y2="10.49"/>
                    </svg>
                </button>
            </div>
        </div>
    </div>

    <!-- Section principale -->
    <div class="book-detail-main">
        <div class="container">
            <div class="book-main-content">
                <!-- Mobile: Layout vertical -->
                <div class="book-main-mobile">
                    <div class="book-cover-wrapper">
                        @if(!empty($imageUrl))
                            <img src="{{ $imageUrl }}" alt="{{ $title }}" class="book-cover-img">
                        @else
                            <div class="book-cover-placeholder">📚</div>
                        @endif
                    </div>
                    @if(!empty($excerpt))
                        <button class="btn-excerpt" onclick="showExcerpt()">Lire un extrait</button>
                    @endif
                    <div class="book-info-mobile">
                        <h1 class="book-title">{{ $title }}</h1>
                        <div class="book-rating">
                            @for($i = 0; $i < 5; $i++)
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#F97316" stroke-width="1">
                                    <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>
                                </svg>
                            @endfor
                            <span class="rating-text">Aucune évaluation</span>
                        </div>
                        <div class="book-author-genre">
                            <span class="text-gray">de </span>
                            <span class="author-name">{{ $author }}</span>
                            <span class="text-gray"> • </span>
                            <span class="genre-name">{{ $genre }}</span>
                        </div>
                        <div class="book-price-box">
                            <span class="book-price-large">{{ $displayPrice }}</span>
                            <span class="book-pages-text">le livre complet / {{ $pages }} pages</span>
                        </div>
                        <div class="book-summary">{{ Str::limit($summary, 200) }}</div>
                        @if(strlen($summary) > 200)
                            <button class="btn-read-more" onclick="showFullDescription()">Lire plus</button>
                        @endif
                        <div class="book-actions">
                            <button class="btn-action-primary" onclick="handlePurchase()">
                                @if(!$isLoggedIn && $priceType !== 'gratuit')
                                    Se connecter pour acheter
                                @elseif($priceType === 'gratuit' || $isPurchased)
                                    Lire
                                @else
                                    Acheter
                                @endif
                            </button>
                        </div>
                        <p class="payment-info">Paiement dans tous les pays par téléphone ou carte bancaire.</p>
                    </div>
                </div>

                <!-- Desktop: Layout horizontal -->
                <div class="book-main-desktop">
                    <div class="book-cover-wrapper">
                        @if(!empty($imageUrl))
                            <img src="{{ $imageUrl }}" alt="{{ $title }}" class="book-cover-img">
                        @else
                            <div class="book-cover-placeholder">📚</div>
                        @endif
                        @if(!empty($excerpt))
                            <button class="btn-excerpt" onclick="showExcerpt()">Lire un extrait</button>
                        @endif
                    </div>
                    
                    <div class="book-info-desktop">
                        <h1 class="book-title">{{ $title }}</h1>
                        
                        <!-- Rating placeholder -->
                        <div class="book-rating">
                            @for($i = 0; $i < 5; $i++)
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#F97316" stroke-width="1">
                                    <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>
                                </svg>
                            @endfor
                            <span class="rating-text">Aucune évaluation</span>
                        </div>
                        
                        <!-- Auteur et catégorie -->
                        <div class="book-author-genre">
                            <span class="text-gray">de </span>
                            <span class="author-name">{{ $author }}</span>
                            <span class="text-gray"> • </span>
                            <span class="genre-name">{{ $genre }}</span>
                        </div>
                        
                        <!-- Prix et pages -->
                        <div class="book-price-box">
                            <span class="book-price-large">{{ $displayPrice }}</span>
                            <span class="book-pages-text">le livre complet / {{ $pages }} pages</span>
                        </div>
                        
                        <!-- Description -->
                        <div class="book-summary" id="bookSummaryPreview">
                            {{ Str::limit($summary, 200) }}
                        </div>
                        @if(strlen($summary) > 200)
                            <button class="btn-read-more" onclick="showFullDescription()">Lire plus</button>
                        @endif
                        
                        <!-- Boutons d'action -->
                        <div class="book-actions">
                            <button 
                                class="btn-action-primary" 
                                id="buyButton"
                                onclick="handlePurchase()"
                                @if(!$isLoggedIn && $priceType !== 'gratuit') data-needs-login="true" @endif
                            >
                                @if(!$isLoggedIn && $priceType !== 'gratuit')
                                    Se connecter pour acheter
                                @elseif($priceType === 'gratuit' || $isPurchased)
                                    Lire
                                @else
                                    Acheter
                                @endif
                            </button>
                        </div>
                        <p class="payment-info">Paiement dans tous les pays par téléphone ou carte bancaire.</p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Section À propos de l'auteur -->
    @if(!empty($authorBio))
    <div class="author-section">
        <div class="container">
            <h2>À propos de l'auteur</h2>
            <div class="author-info">
                <div class="author-avatar">👤</div>
                <div class="author-details">
                    <h3>{{ $author }}</h3>
                    <p class="author-books-count">{{ count($authorBooks) + 1 }} livres</p>
                    <p class="author-bio">{{ Str::limit($authorBio, 200) }}</p>
                </div>
            </div>
        </div>
    </div>
    @endif

    <!-- Section Livres du même auteur -->
    @if(count($authorBooks) > 0)
    <div class="related-books-section">
        <div class="container">
            <h2>Livres du même auteur</h2>
            <div class="related-books-grid">
                @foreach($authorBooks as $relatedBook)
                    @php
                        $relatedTitle = $relatedBook['title'] ?? '';
                        $relatedSlug = \App\Helpers\BookHelper::titleToSlug($relatedTitle);
                        $relatedPriceType = strtolower($relatedBook['price_type'] ?? '');
                        $relatedPrice = $relatedBook['price'] ?? '';
                        $relatedCoverPath = $relatedBook['cover_path'] ?? '';
                        $relatedImageUrl = '';
                        if (!empty($relatedCoverPath)) {
                            if (str_starts_with($relatedCoverPath, 'http')) {
                                $relatedImageUrl = $relatedCoverPath;
                            } else {
                                $relatedImageUrl = 'https://takaafrica.com/pharmaRh/taka/' . $relatedCoverPath;
                            }
                        }
                        $relatedDisplayPrice = $relatedPriceType === 'gratuit' ? 'Gratuit' : (number_format((float)$relatedPrice, 0, ',', ' ') . ' FCFA');
                    @endphp
                    <a href="{{ route('book.show', $relatedSlug) }}" class="related-book-card">
                        <div class="related-book-cover">
                            @if(!empty($relatedImageUrl))
                                <img src="{{ $relatedImageUrl }}" alt="{{ $relatedTitle }}">
                            @else
                                <div class="related-book-placeholder">📚</div>
                            @endif
                        </div>
                        <h4 class="related-book-title">{{ $relatedTitle }}</h4>
                        <p class="related-book-price">{{ $relatedDisplayPrice }}</p>
                    </a>
                @endforeach
            </div>
        </div>
    </div>
    @endif

    <!-- Section Livres de la même catégorie -->
    @if(count($categoryBooks) > 0)
    <div class="related-books-section category-books-section">
        <div class="container">
            <h2>Livres de la même catégorie</h2>
            <div class="related-books-grid">
                @foreach($categoryBooks as $relatedBook)
                    @php
                        $relatedTitle = $relatedBook['title'] ?? '';
                        $relatedSlug = \App\Helpers\BookHelper::titleToSlug($relatedTitle);
                        $relatedPriceType = strtolower($relatedBook['price_type'] ?? '');
                        $relatedPrice = $relatedBook['price'] ?? '';
                        $relatedCoverPath = $relatedBook['cover_path'] ?? '';
                        $relatedImageUrl = '';
                        if (!empty($relatedCoverPath)) {
                            if (str_starts_with($relatedCoverPath, 'http')) {
                                $relatedImageUrl = $relatedCoverPath;
                            } else {
                                $relatedImageUrl = 'https://takaafrica.com/pharmaRh/taka/' . $relatedCoverPath;
                            }
                        }
                        $relatedDisplayPrice = $relatedPriceType === 'gratuit' ? 'Gratuit' : (number_format((float)$relatedPrice, 0, ',', ' ') . ' FCFA');
                    @endphp
                    <a href="{{ route('book.show', $relatedSlug) }}" class="related-book-card">
                        <div class="related-book-cover">
                            @if(!empty($relatedImageUrl))
                                <img src="{{ $relatedImageUrl }}" alt="{{ $relatedTitle }}">
                            @else
                                <div class="related-book-placeholder">📚</div>
                            @endif
                        </div>
                        <h4 class="related-book-title">{{ $relatedTitle }}</h4>
                        <p class="related-book-price">{{ $relatedDisplayPrice }}</p>
                    </a>
                @endforeach
            </div>
        </div>
    </div>
    @endif
</div>

<!-- Modal Extraits -->
@if(!empty($excerpt))
<div id="excerptModal" class="modal" style="display: none;">
    <div class="modal-content">
        <div class="modal-header">
            <h2>Extrait</h2>
            <button class="modal-close" onclick="closeExcerpt()">×</button>
        </div>
        <div class="modal-body">
            <p>{{ $excerpt }}</p>
        </div>
    </div>
</div>
@endif

<!-- Modal Description complète -->
<div id="descriptionModal" class="modal" style="display: none;">
    <div class="modal-content">
        <div class="modal-header">
            <h2>Description complète</h2>
            <button class="modal-close" onclick="closeDescription()">×</button>
        </div>
        <div class="modal-body">
            <p>{{ $summary }}</p>
        </div>
    </div>
</div>

@push('styles')
<style>
.book-detail-page {
    background: white;
    min-height: calc(100vh - 200px);
}

.book-detail-header {
    background: white;
    border-bottom: 1px solid #E5E7EB;
    padding: 16px 0;
}

.book-detail-nav {
    display: flex;
    justify-content: space-between;
    align-items: center;
    max-width: 1280px;
    margin: 0 auto;
    padding: 0 20px;
}

.back-btn, .share-btn {
    background: none;
    border: none;
    cursor: pointer;
    padding: 8px;
    color: black;
    display: flex;
    align-items: center;
    justify-content: center;
}

.share-btn {
    color: #F97316;
}

.book-detail-main {
    padding: 40px 0;
}

.book-main-content {
    max-width: 1280px;
    margin: 0 auto;
    padding: 0 20px;
}

.book-main-desktop {
    display: flex;
    gap: 60px;
    align-items: flex-start;
}

.book-main-mobile {
    display: none;
}

.book-cover-wrapper {
    flex-shrink: 0;
}

.book-cover-img {
    width: 280px;
    height: 400px;
    object-fit: cover;
    border-radius: 12px;
    box-shadow: 0 10px 20px rgba(0,0,0,0.2);
}

.book-cover-placeholder {
    width: 280px;
    height: 400px;
    background: #E5E7EB;
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 80px;
    box-shadow: 0 10px 20px rgba(0,0,0,0.2);
}

.btn-excerpt {
    margin-top: 16px;
    width: 100%;
    padding: 12px 24px;
    border: 1px solid #F97316;
    background: white;
    color: #F97316;
    border-radius: 8px;
    cursor: pointer;
    font-size: 14px;
    font-weight: 500;
    transition: all 0.2s;
}

.btn-excerpt:hover {
    background: #F97316;
    color: white;
}

.book-info-desktop {
    flex: 1;
}

.book-title {
    font-size: 32px;
    font-weight: 700;
    color: #111827;
    margin-bottom: 8px;
    line-height: 1.2;
}

.book-rating {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-bottom: 12px;
}

.rating-text {
    font-size: 14px;
    color: #6B7280;
}

.book-author-genre {
    font-size: 16px;
    margin-bottom: 16px;
}

.text-gray {
    color: #6B7280;
}

.author-name {
    font-weight: 600;
    text-decoration: underline;
    color: #111827;
}

.genre-name {
    font-weight: 600;
    color: #111827;
}

.book-price-box {
    background: #F3F4F6;
    padding: 16px;
    border-radius: 8px;
    margin-bottom: 20px;
    display: flex;
    align-items: center;
    gap: 16px;
    flex-wrap: wrap;
}

.book-price-large {
    font-size: 24px;
    font-weight: 700;
    color: #F97316;
}

.book-pages-text {
    font-size: 14px;
    color: #6B7280;
}

.book-summary {
    font-size: 16px;
    line-height: 1.6;
    color: #374151;
    margin-bottom: 8px;
}

.btn-read-more {
    background: none;
    border: none;
    color: #F97316;
    text-decoration: underline;
    cursor: pointer;
    padding: 0;
    margin-bottom: 24px;
    font-weight: 600;
    font-size: 16px;
}

.book-actions {
    margin-bottom: 12px;
}

.btn-action-primary {
    width: 100%;
    padding: 16px 24px;
    background: #F97316;
    color: white;
    border: none;
    border-radius: 8px;
    font-size: 16px;
    font-weight: 500;
    cursor: pointer;
    transition: background 0.2s;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
}

.btn-action-primary:hover {
    background: #EA580C;
}

.btn-action-primary:disabled {
    opacity: 0.6;
    cursor: not-allowed;
}

.payment-info {
    font-size: 12px;
    color: #6B7280;
}

.author-section {
    background: #F9FAFB;
    padding: 32px 0;
    margin-top: 32px;
}

.author-section .container {
    max-width: 1280px;
    margin: 0 auto;
    padding: 0 20px;
}

.author-section h2 {
    font-size: 24px;
    font-weight: 700;
    color: #111827;
    margin-bottom: 16px;
}

.author-info {
    display: flex;
    gap: 16px;
    align-items: flex-start;
}

.author-avatar {
    width: 80px;
    height: 80px;
    border-radius: 50%;
    background: #E5E7EB;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 40px;
    flex-shrink: 0;
}

.author-details {
    flex: 1;
}

.author-details h3 {
    font-size: 18px;
    font-weight: 700;
    color: #111827;
    margin-bottom: 4px;
}

.author-books-count {
    font-size: 14px;
    color: #6B7280;
    margin-bottom: 8px;
}

.author-bio {
    font-size: 14px;
    line-height: 1.5;
    color: #374151;
}

.related-books-section {
    padding: 32px 0;
}

.related-books-section .container {
    max-width: 1280px;
    margin: 0 auto;
    padding: 0 20px;
}

.category-books-section {
    background: #F9FAFB;
}

.related-books-section h2 {
    font-size: 24px;
    font-weight: 700;
    color: #111827;
    margin-bottom: 20px;
}

.related-books-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
    gap: 16px;
}

.related-book-card {
    text-decoration: none;
    color: inherit;
    transition: transform 0.2s;
}

.related-book-card:hover {
    transform: translateY(-4px);
}

.related-book-cover {
    width: 100%;
    aspect-ratio: 9/13;
    border-radius: 8px;
    overflow: hidden;
    box-shadow: 0 4px 8px rgba(0,0,0,0.1);
    margin-bottom: 8px;
    background: #E5E7EB;
}

.related-book-cover img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.related-book-placeholder {
    width: 100%;
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 48px;
}

.related-book-title {
    font-size: 14px;
    font-weight: 600;
    color: #111827;
    margin-bottom: 4px;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
}

.related-book-price {
    font-size: 14px;
    font-weight: 700;
    color: #F97316;
}

/* Modal Styles */
.modal {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0,0,0,0.5);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 1000;
    padding: 20px;
}

.modal-content {
    background: white;
    border-radius: 16px;
    max-width: 600px;
    width: 100%;
    max-height: 80vh;
    display: flex;
    flex-direction: column;
    box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1);
}

.modal-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 24px;
    border-bottom: 1px solid #E5E7EB;
}

.modal-header h2 {
    font-size: 20px;
    font-weight: 700;
    color: #111827;
    margin: 0;
}

.modal-close {
    background: none;
    border: none;
    font-size: 32px;
    color: #6B7280;
    cursor: pointer;
    padding: 0;
    width: 32px;
    height: 32px;
    display: flex;
    align-items: center;
    justify-content: center;
    line-height: 1;
}

.modal-body {
    padding: 24px;
    overflow-y: auto;
    flex: 1;
}

.modal-body p {
    font-size: 14px;
    line-height: 1.6;
    color: #374151;
    white-space: pre-wrap;
}

/* Responsive */
@media (max-width: 900px) {
    .book-main-desktop {
        display: none;
    }
    
    .book-main-mobile {
        display: block;
    }
    
    .book-cover-wrapper {
        display: flex;
        flex-direction: column;
        align-items: center;
        margin-bottom: 24px;
    }
    
    .book-cover-img,
    .book-cover-placeholder {
        width: 200px;
        height: 280px;
    }
    
    .book-info-mobile {
        width: 100%;
    }
    
    .book-title {
        font-size: 18px;
        text-align: center;
    }
    
    .book-rating {
        justify-content: center;
    }
    
    .book-author-genre {
        text-align: center;
        margin-bottom: 16px;
    }
    
    .book-price-box {
        justify-content: center;
        text-align: center;
    }
    
    .book-summary {
        text-align: center;
    }
    
    .author-info {
        flex-direction: column;
        align-items: center;
        text-align: center;
    }
    
    .related-books-grid {
        display: flex;
        overflow-x: auto;
        gap: 16px;
        padding-bottom: 8px;
        -webkit-overflow-scrolling: touch;
    }
    
    .related-book-card {
        min-width: 140px;
        flex-shrink: 0;
    }
    
    .related-books-section .container {
        padding: 0 16px;
    }
    
    .book-detail-main {
        padding: 20px 0;
    }
    
    .book-main-content {
        padding: 0 16px;
    }
    
    .book-title {
        font-size: 18px;
    }
    
    .book-author-genre {
        font-size: 15px;
    }
    
    .book-summary {
        font-size: 15px;
    }
    
    .book-price-large {
        font-size: 18px;
    }
    
    .btn-action-primary {
        font-size: 15px;
    }
    
    .author-section h2,
    .related-books-section h2 {
        font-size: 18px;
    }
    
    .author-details h3 {
        font-size: 18px;
    }
    
    .author-bio {
        font-size: 15px;
    }
    
    .author-section,
    .related-books-section {
        padding: 32px 0;
    }
    
    .author-section .container {
        padding: 0 16px;
    }
}
</style>
@endpush

@push('scripts')
<script>
const bookData = @json($book);
const isPurchased = @json($isPurchased ?? false);
const isLoggedIn = @json($isLoggedIn);
const bookSlug = '{{ $slug }}';
const bookUrl = '{{ $bookUrl }}';

// Récupérer le paramètre ref depuis l'URL (affiliation)
const urlParams = new URLSearchParams(window.location.search);
const affiliateRef = urlParams.get('ref') || '';

function shareBook() {
    if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(bookUrl).then(() => {
            showShareNotification();
        }).catch(() => {
            fallbackCopy(bookUrl);
        });
    } else {
        fallbackCopy(bookUrl);
    }
}

function fallbackCopy(text) {
    const textArea = document.createElement('textarea');
    textArea.value = text;
    textArea.style.position = 'fixed';
    textArea.style.opacity = '0';
    document.body.appendChild(textArea);
    textArea.select();
    try {
        document.execCommand('copy');
        showShareNotification();
    } catch (err) {
        alert('Impossible de copier le lien');
    }
    document.body.removeChild(textArea);
}

function showShareNotification() {
    // Créer une notification toast simple
    const notification = document.createElement('div');
    notification.style.cssText = `
        position: fixed;
        bottom: 20px;
        right: 20px;
        background: #10B981;
        color: white;
        padding: 16px 24px;
        border-radius: 8px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        z-index: 10000;
        display: flex;
        align-items: center;
        gap: 12px;
        max-width: 300px;
    `;
    notification.innerHTML = `
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2">
            <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/>
            <polyline points="22 4 12 14.01 9 11.01"/>
        </svg>
        <div>
            <div style="font-weight: 600; margin-bottom: 4px;">Lien copié !</div>
            <div style="font-size: 12px; opacity: 0.9;">Partagez "${bookData.title}"</div>
        </div>
    `;
    document.body.appendChild(notification);
    
    setTimeout(() => {
        notification.style.opacity = '0';
        notification.style.transition = 'opacity 0.3s';
        setTimeout(() => notification.remove(), 300);
    }, 3000);
}

function showExcerpt() {
    document.getElementById('excerptModal').style.display = 'flex';
}

function closeExcerpt() {
    document.getElementById('excerptModal').style.display = 'none';
}

function showFullDescription() {
    document.getElementById('descriptionModal').style.display = 'flex';
}

function closeDescription() {
    document.getElementById('descriptionModal').style.display = 'none';
}

// Fermer les modals en cliquant à l'extérieur
window.onclick = function(event) {
    const excerptModal = document.getElementById('excerptModal');
    const descriptionModal = document.getElementById('descriptionModal');
    
    if (event.target === excerptModal) {
        closeExcerpt();
    }
    if (event.target === descriptionModal) {
        closeDescription();
    }
}

async function handlePurchase() {
    const button = document.getElementById('buyButton');
    const needsLogin = button.dataset.needsLogin === 'true';
    
    if (needsLogin) {
        window.location.href = '{{ route("login") }}';
        return;
    }
    
    const priceType = bookData.price_type?.toLowerCase() || '';
    const bookId = bookData.id;
    
    if (priceType === 'gratuit' || isPurchased) {
        // Rediriger vers le lecteur avec le slug
        const bookSlug = '{{ addslashes($slug) }}';
        window.location.href = '/reader/' + encodeURIComponent(bookSlug);
        return;
    }
    
    if (!isLoggedIn) {
        window.location.href = '{{ route("login") }}';
        return;
    }
    
    // Désactiver le bouton
    button.disabled = true;
    button.innerHTML = 'Traitement...';
    
    try {
        // Récupérer la devise et le pays depuis localStorage ou utiliser les valeurs par défaut
        const currency = localStorage.getItem('currency') || 'XOF';
        const country = localStorage.getItem('country') || 'Bénin';
        
        // S'assurer que le prix est un entier (Moneroo attend un entier)
        const amount = Math.round(parseFloat(bookData.price) || 0);
        
        if (amount <= 0) {
            alert('Prix du livre invalide.');
            button.disabled = false;
            button.innerHTML = 'Acheter';
            return;
        }
        
        const response = await fetch('https://takaafrica.com/pharmaRh/taka/moneroo_init_book.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                amount: amount,
                currency: currency,
                country: country,
                description: `Achat livre: ${bookData.title}`,
                email: '{{ auth()->user()->email ?? "" }}',
                first_name: '{{ $firstName ?? "Utilisateur" }}',
                last_name: '{{ $lastName ?? "TAKA" }}',
                user_id: '{{ auth()->id() ?? "" }}',
                book_id: bookId,
                return_url: 'https://takaafrica.com',
                ...(affiliateRef ? { ref: affiliateRef } : {}),
            }),
        });
        
        // Vérifier si la réponse est OK avant de parser le JSON
        if (!response.ok) {
            const errorData = await response.json().catch(() => ({ error: 'Erreur inconnue' }));
            console.error('Erreur API:', errorData);
            let errorMsg = 'Erreur lors de l\'initialisation du paiement.';
            if (errorData.error) {
                errorMsg = errorData.error;
                if (errorData.response) {
                    try {
                        const responseData = typeof errorData.response === 'string' ? JSON.parse(errorData.response) : errorData.response;
                        if (responseData.message) {
                            errorMsg += ': ' + responseData.message;
                        }
                    } catch (e) {
                        // Ignore parsing errors
                    }
                }
            }
            
            // Détecter l'erreur de devise non supportée
            if (errorMsg.includes('No payment methods enabled for this currency') || errorMsg.includes('payment methods for this currency')) {
                errorMsg = 'Cette devise n\'est pas supportée pour le paiement. Veuillez sélectionner un autre pays dans le menu déroulant en haut de la page.';
                // Réinitialiser à Bénin par défaut
                localStorage.setItem('country', 'Bénin');
                localStorage.setItem('currency', 'XOF');
                // Mettre à jour le sélecteur si présent
                const countrySelect = document.getElementById('countryCurrency');
                if (countrySelect) {
                    countrySelect.value = 'Bénin|XOF';
                }
            }
            
            alert(errorMsg);
            button.disabled = false;
            button.innerHTML = 'Acheter';
            return;
        }
        
        const data = await response.json();
        
        if (data.checkout_url) {
            // Ouvrir le paiement dans un nouvel onglet
            window.open(data.checkout_url, '_blank');
            
            // Attendre la confirmation du paiement
            waitForPayment(bookId);
        } else {
            let errorMsg = 'Erreur lors de l\'initialisation du paiement.';
            if (data.error) {
                errorMsg = data.error;
                if (data.response) {
                    try {
                        const responseData = typeof data.response === 'string' ? JSON.parse(data.response) : data.response;
                        if (responseData.message) {
                            errorMsg += ': ' + responseData.message;
                        }
                    } catch (e) {
                        // Ignore parsing errors
                    }
                }
            }
            alert(errorMsg);
            button.disabled = false;
            button.innerHTML = 'Acheter';
        }
    } catch (error) {
        console.error('Erreur:', error);
        alert('Erreur réseau: ' + error.message);
        button.disabled = false;
        button.innerHTML = 'Acheter';
    }
}

async function waitForPayment(bookId) {
    const maxTries = 60;
    let tries = 0;
    
    const checkPayment = setInterval(async () => {
        tries++;
        
        try {
            const response = await fetch(`https://takaafrica.com/pharmaRh/taka/check_book_payment_status.php?user_id={{ auth()->id() ?? "" }}&book_id=${bookId}`);
            const data = await response.json();
            
            if (data.status === 'paid') {
                clearInterval(checkPayment);
                alert('Paiement réussi! Vous pouvez maintenant lire le livre.');
                location.reload();
            } else if (tries >= maxTries) {
                clearInterval(checkPayment);
                const button = document.getElementById('buyButton');
                button.disabled = false;
                button.innerHTML = 'Acheter';
            }
        } catch (error) {
            console.error('Erreur vérification paiement:', error);
        }
    }, 1000);
}
</script>
@endpush
@endsection
