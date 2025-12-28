@extends('layouts.app')

@section('title', 'Explorer les livres - TAKA')

@section('content')
<div class="explore-page">
    <div class="explore-container">
        <!-- Header -->
        <div class="explore-header">
            <h1 class="explore-title">Explorer les livres</h1>
            <p class="explore-subtitle">Découvrez la richesse de la littérature africaine</p>
        </div>

        <!-- Search Bar -->
        <div class="search-bar-container">
            <form method="GET" action="{{ route('explore') }}" id="searchForm">
                <div class="search-input-wrapper">
                    <i class="fas fa-search search-icon"></i>
                    <input type="text" 
                           name="search" 
                           id="searchInput" 
                           value="{{ $search }}"
                           placeholder="Rechercher par titre, auteur, mot-clé..." 
                           class="search-input"
                           autocomplete="off">
                </div>
                <input type="hidden" name="genre" id="hiddenGenre" value="{{ $genre }}">
                <input type="hidden" name="language" id="hiddenLanguage" value="{{ $language }}">
                <input type="hidden" name="price" id="hiddenPrice" value="{{ $priceFilter }}">
                <input type="hidden" name="sort" id="hiddenSort" value="{{ $sort }}">
                <input type="hidden" name="view" id="hiddenView" value="{{ $viewMode }}">
            </form>
        </div>

        <!-- Main Content -->
        <div class="explore-main">
            <!-- Filters Sidebar (Desktop) -->
            <aside class="filters-sidebar">
                <div class="filters-card">
                    <div class="filters-header">
                        <i class="fas fa-filter"></i>
                        <h2>Filtres</h2>
                    </div>

                    <!-- Genre Filter -->
                    <div class="filter-section">
                        <label class="filter-label">Genre</label>
                        <select name="genre" id="genreFilter" class="filter-select">
                            @foreach($genres as $g)
                                <option value="{{ $g }}" {{ $genre === $g ? 'selected' : '' }}>{{ $g }}</option>
                            @endforeach
                        </select>
                    </div>

                    <!-- Language Filter -->
                    <div class="filter-section">
                        <label class="filter-label">Langue</label>
                        <select name="language" id="languageFilter" class="filter-select">
                            @foreach($languages as $l)
                                <option value="{{ $l }}" {{ $language === $l ? 'selected' : '' }}>{{ $l }}</option>
                            @endforeach
                        </select>
                    </div>

                    <!-- Price Filter -->
                    <div class="filter-section">
                        <label class="filter-label">Prix</label>
                        <div class="radio-group">
                            <label class="radio-label">
                                <input type="radio" name="price" value="all" {{ $priceFilter === 'all' ? 'checked' : '' }}>
                                <span>Tous</span>
                            </label>
                            <label class="radio-label">
                                <input type="radio" name="price" value="free" {{ $priceFilter === 'free' ? 'checked' : '' }}>
                                <span>Gratuit</span>
                            </label>
                            <label class="radio-label">
                                <input type="radio" name="price" value="paid" {{ $priceFilter === 'paid' ? 'checked' : '' }}>
                                <span>Payant</span>
                            </label>
                        </div>
                    </div>
                </div>
            </aside>

            <!-- Content Area -->
            <div class="explore-content">
                <!-- Sort and View Controls -->
                <div class="controls-bar">
                    <div class="sort-controls">
                        <span class="control-label">Trier par:</span>
                        <select name="sort" id="sortFilter" class="control-select">
                            <option value="recent" {{ $sort === 'recent' ? 'selected' : '' }}>Nouveautés</option>
                            <option value="title" {{ $sort === 'title' ? 'selected' : '' }}>Titre</option>
                        </select>
                    </div>

                    <div class="view-controls">
                        <span class="control-label">Affichage:</span>
                        <button type="button" class="view-btn {{ $viewMode === 'grid' ? 'active' : '' }}" data-view="grid">
                            <i class="fas fa-th"></i>
                        </button>
                        <button type="button" class="view-btn {{ $viewMode === 'list' ? 'active' : '' }}" data-view="list">
                            <i class="fas fa-list"></i>
                        </button>
                    </div>
                </div>

                <!-- Results Count -->
                <div class="results-count">
                    {{ $totalBooks }} livres trouvés
                </div>

                <!-- Books Display -->
                <div id="booksContainer" class="books-container {{ $viewMode }}">
                    @php
                        $totalPages = max(1, (int)ceil($totalBooks / $perPage));
                    @endphp
                    @if($totalBooks == 0 || empty($books))
                        <div class="no-results">
                            <p>Aucun livre trouvé</p>
                        </div>
                    @else
                        @foreach($books as $book)
                            @php
                                $bookId = is_numeric($book['id'] ?? null) ? (int)$book['id'] : 0;
                                $title = $book['title'] ?? '';
                                $author = $book['author'] ?? '';
                                $summary = $book['summary'] ?? '';
                                $genre = $book['genre'] ?? '';
                                $country = $book['country'] ?? '';
                                $price = $book['price'] ?? '';
                                $priceType = strtolower($book['price_type'] ?? '');
                                $pages = is_numeric($book['pages'] ?? null) ? (int)$book['pages'] : 0;
                                $rating = is_numeric($book['rating'] ?? null) ? (float)$book['rating'] : 0.0;
                                $isBestseller = ($book['isBestseller'] ?? false) === true;
                                $isPurchased = in_array($bookId, $purchasedBookIds);
                                
                                $coverPath = $book['cover_path'] ?? '';
                                $imageUrl = '';
                                if (!empty($coverPath)) {
                                    if (str_starts_with($coverPath, 'http')) {
                                        $imageUrl = $coverPath;
                                    } else {
                                        $imageUrl = $baseUrl . '/' . $coverPath;
                                    }
                                }
                                
                                $slug = \App\Helpers\BookHelper::titleToSlug($title);
                                
                                // Formatage du prix
                                $displayPrice = 'Gratuit';
                                if ($priceType !== 'gratuit' && !empty($price) && is_numeric($price)) {
                                    $displayPrice = number_format((float)$price, 0, ',', ' ') . ' FCFA';
                                }
                            @endphp

                            @if($viewMode === 'grid')
                                <!-- Grid Card -->
                                <div class="book-card-grid">
                                    <a href="{{ route('book.show', $slug) }}" class="book-card-link">
                                        <div class="book-cover-wrapper">
                                            @if(!empty($imageUrl))
                                                <img src="{{ $imageUrl }}" alt="{{ $title }}" class="book-cover-img">
                                            @else
                                                <div class="book-cover-placeholder">
                                                    <i class="fas fa-book"></i>
                                                </div>
                                            @endif
                                            
                                            <div class="book-badges">
                                                @if($isBestseller)
                                                    <span class="book-badge bestseller">Best-seller</span>
                                                @endif
                                                <span class="book-badge {{ $priceType === 'gratuit' ? 'free' : 'paid' }}">
                                                    {{ strtoupper($priceType ?: 'PAYANT') }}
                                                </span>
                                            </div>
                                            
                                            <div class="book-favorite-icon">
                                                <i class="far fa-heart"></i>
                                            </div>
                                        </div>
                                        
                                        <div class="book-card-info">
                                            <h3 class="book-card-title">{{ $title }}</h3>
                                            <p class="book-card-description">{{ $summary }}</p>
                                            
                                            <div class="book-card-meta">
                                                <span class="book-card-genre">{{ $genre }}</span>
                                                <div class="book-card-rating">
                                                    <i class="fas fa-star"></i>
                                                    <span>{{ number_format($rating, 1) }}</span>
                                                </div>
                                            </div>
                                            
                                            <div class="book-card-price-row">
                                                <span class="book-card-price">{{ $displayPrice }}</span>
                                                <span class="book-card-pages">{{ $pages }} pages</span>
                                            </div>
                                            
                                            <div class="book-card-actions">
                                                <a href="{{ route('book.show', $slug) }}" class="book-btn book-btn-outline">Détails</a>
                                                <button type="button" 
                                                        class="book-btn book-btn-primary"
                                                        onclick="event.preventDefault(); handleBookAction({{ $bookId }}, '{{ $priceType }}', {{ $isPurchased ? 'true' : 'false' }}, {{ json_encode($book) }});">
                                                    {{ ($priceType === 'gratuit' || $isPurchased) ? 'Lire' : 'Acheter' }}
                                                </button>
                                                <button type="button" 
                                                        class="book-btn book-btn-share"
                                                        onclick="event.preventDefault(); shareBook('{{ $slug }}', '{{ addslashes($title) }}', '{{ addslashes($author) }}');"
                                                        title="Partager">
                                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                        <circle cx="18" cy="5" r="3"/>
                                                        <circle cx="6" cy="12" r="3"/>
                                                        <circle cx="18" cy="19" r="3"/>
                                                        <line x1="8.59" y1="13.51" x2="15.42" y2="17.49"/>
                                                        <line x1="15.41" y1="6.51" x2="8.59" y2="10.49"/>
                                                    </svg>
                                                </button>
                                            </div>
                                        </div>
                                    </a>
                                </div>
                            @else
                                <!-- List Item -->
                                <div class="book-card-list">
                                    <div class="book-list-content">
                                        <div class="book-list-cover">
                                            @if(!empty($imageUrl))
                                                <img src="{{ $imageUrl }}" alt="{{ $title }}">
                                            @else
                                                <div class="book-cover-placeholder-small">
                                                    <i class="fas fa-book"></i>
                                                </div>
                                            @endif
                                        </div>
                                        
                                        <div class="book-list-info">
                                            <div class="book-list-header">
                                                <div class="book-list-main">
                                                    <h3 class="book-list-title">{{ $title }}</h3>
                                                    <p class="book-list-author">{{ $author }}</p>
                                                    <p class="book-list-description">{{ $summary }}</p>
                                                    
                                                    <div class="book-list-meta-row">
                                                        <span class="book-list-genre">{{ $genre }}</span>
                                                        <span class="book-list-country">{{ $country }}</span>
                                                        <span class="book-list-pages">{{ $pages }} pages</span>
                                                        <span class="book-list-price-badge {{ $priceType === 'gratuit' ? 'free' : 'paid' }}">
                                                            {{ strtoupper($priceType ?: 'PAYANT') }}
                                                        </span>
                                                        <span class="book-list-price">{{ $displayPrice }}</span>
                                                    </div>
                                                </div>
                                                
                                                <div class="book-list-badges">
                                                    @if($isBestseller)
                                                        <span class="book-badge bestseller">Best-seller</span>
                                                    @endif
                                                </div>
                                            </div>
                                            
                                            <div class="book-list-actions">
                                                <a href="{{ route('book.show', $slug) }}" class="book-btn book-btn-outline">Détails</a>
                                                <button type="button" 
                                                        class="book-btn book-btn-primary"
                                                        onclick="handleBookAction({{ $bookId }}, '{{ $priceType }}', {{ $isPurchased ? 'true' : 'false' }}, {{ json_encode($book) }});">
                                                    {{ ($priceType === 'gratuit' || $isPurchased) ? 'Lire' : 'Acheter' }}
                                                </button>
                                                <button type="button" 
                                                        class="book-btn book-btn-share"
                                                        onclick="event.preventDefault(); shareBook('{{ $slug }}', '{{ addslashes($title) }}', '{{ addslashes($author) }}');"
                                                        title="Partager">
                                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
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
                                </div>
                            @endif
                        @endforeach
                    @endif
                </div>

                <!-- Pagination -->
                @if($totalPages > 1)
                <div class="pagination-container">
                    <a href="{{ route('explore', ['page' => max(1, $page - 1)]) }}" 
                       class="pagination-btn" 
                       {{ $page <= 1 ? 'style="pointer-events: none; opacity: 0.5;"' : '' }}>
                        Précédent
                    </a>
                    
                    <span class="pagination-info">{{ $page }} / {{ $totalPages }}</span>
                    
                    <a href="{{ route('explore', ['page' => min($totalPages, $page + 1)]) }}" 
                       class="pagination-btn" 
                       {{ $page >= $totalPages ? 'style="pointer-events: none; opacity: 0.5;"' : '' }}>
                        Suivant
                    </a>
                </div>
                @endif
            </div>
        </div>
    </div>
</div>

@push('styles')
<style>
.explore-page {
    background: #F9FAFB;
    min-height: calc(100vh - 200px);
    padding: 32px 20px;
}

.explore-container {
    max-width: 1280px;
    margin: 0 auto;
}

/* Header */
.explore-header {
    margin-bottom: 32px;
}

.explore-title {
    font-size: 28px;
    font-weight: 700;
    color: #111827;
    margin-bottom: 8px;
    font-family: "PBold", sans-serif;
}

.explore-subtitle {
    font-size: 16px;
    color: #6B7280;
    font-family: "PRegular", sans-serif;
}

/* Search Bar */
.search-bar-container {
    margin-bottom: 32px;
}

.search-input-wrapper {
    position: relative;
    width: 100%;
}

.search-icon {
    position: absolute;
    left: 16px;
    top: 50%;
    transform: translateY(-50%);
    color: #9CA3AF;
    font-size: 20px;
    z-index: 1;
    pointer-events: none;
}

.search-input {
    width: 100%;
    padding: 12px 24px 12px 48px;
    border: 1px solid #E5E7EB;
    border-radius: 12px;
    font-size: 15px;
    font-family: "PRegular", sans-serif;
    background: white;
}

.search-input:focus {
    outline: none;
    border-color: #F97316;
    border-width: 2px;
    padding-left: 46px; /* Adjust for border width */
}

/* Main Layout */
.explore-main {
    display: flex;
    gap: 32px;
    align-items: flex-start;
}

/* Filters Sidebar */
.filters-sidebar {
    width: 256px;
    flex-shrink: 0;
}

.filters-card {
    background: white;
    padding: 24px;
    border-radius: 12px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}

.filters-header {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-bottom: 24px;
}

.filters-header i {
    color: #6B7280;
    font-size: 24px;
}

.filters-header h2 {
    font-size: 18px;
    font-weight: 600;
    color: #111827;
    font-family: "PBold", sans-serif;
}

.filter-section {
    margin-bottom: 24px;
}

.filter-label {
    display: block;
    font-size: 14px;
    font-weight: 500;
    color: #111827;
    margin-bottom: 12px;
    font-family: "PBold", sans-serif;
}

.filter-select {
    width: 100%;
    padding: 8px 12px;
    border: 1px solid #E5E7EB;
    border-radius: 12px;
    font-size: 15px;
    font-family: "PRegular", sans-serif;
    background: white;
}

.filter-select:focus {
    outline: none;
    border-color: #F97316;
    border-width: 2px;
}

.radio-group {
    display: flex;
    flex-direction: column;
    gap: 8px;
}

.radio-label {
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 14px;
    font-family: "PRegular", sans-serif;
    cursor: pointer;
}

.radio-label input[type="radio"] {
    accent-color: #F97316;
}

/* Content Area */
.explore-content {
    flex: 1;
    min-width: 0;
}

.controls-bar {
    background: white;
    padding: 16px;
    border-radius: 12px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 24px;
}

.sort-controls {
    display: flex;
    align-items: center;
    gap: 16px;
}

.control-label {
    color: #6B7280;
    font-size: 15px;
    font-family: "PRegular", sans-serif;
}

.control-select {
    padding: 6px 12px;
    border: 1px solid #E5E7EB;
    border-radius: 8px;
    font-size: 15px;
    font-family: "PRegular", sans-serif;
    background: white;
}

.control-select:focus {
    outline: none;
    border-color: #F97316;
}

.view-controls {
    display: flex;
    align-items: center;
    gap: 8px;
}

.view-btn {
    width: 36px;
    height: 36px;
    border: none;
    border-radius: 8px;
    background: #F3F4F6;
    color: #6B7280;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 0.2s;
}

.view-btn.active {
    background: #F97316;
    color: white;
}

.view-btn:hover {
    background: #E5E7EB;
}

.view-btn.active:hover {
    background: #EA580C;
}

.results-count {
    font-size: 16px;
    color: #6B7280;
    margin-bottom: 16px;
    font-family: "PRegular", sans-serif;
}

/* Books Container */
.books-container {
    margin-bottom: 48px;
}

.books-container.grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
    gap: 24px;
}

.books-container.list {
    display: flex;
    flex-direction: column;
    gap: 16px;
}

.no-results {
    text-align: center;
    padding: 80px 20px;
    color: #6B7280;
    font-family: "PRegular", sans-serif;
}

/* Grid Card */
.book-card-grid {
    background: white;
    border-radius: 12px;
    overflow: hidden;
    box-shadow: 0 1px 8px rgba(0,0,0,0.1);
    transition: transform 0.2s, box-shadow 0.2s;
    height: 400px;
    display: flex;
    flex-direction: column;
}

.book-card-grid:hover {
    transform: translateY(-4px);
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
}

.book-card-link {
    display: flex;
    flex-direction: column;
    height: 100%;
    text-decoration: none;
    color: inherit;
}

.book-cover-wrapper {
    position: relative;
    height: 200px;
    background: #E5E7EB;
    overflow: hidden;
}

.book-cover-img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.book-cover-placeholder {
    width: 100%;
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #9CA3AF;
    font-size: 48px;
}

.book-cover-placeholder-small {
    width: 80px;
    height: 112px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #9CA3AF;
    font-size: 32px;
    background: #E5E7EB;
    border-radius: 8px;
}

.book-badges {
    position: absolute;
    top: 8px;
    right: 8px;
    display: flex;
    flex-direction: column;
    gap: 4px;
}

.book-badge {
    padding: 4px 8px;
    border-radius: 12px;
    font-size: 10px;
    font-weight: 600;
    color: white;
    font-family: "PBold", sans-serif;
}

.book-badge.bestseller {
    background: red;
}

.book-badge.free {
    background: #009F38;
}

.book-badge.paid {
    background: #DF2E0A;
}

.book-favorite-icon {
    position: absolute;
    top: 8px;
    left: 8px;
    color: #6B7280;
    font-size: 20px;
}

.book-card-info {
    padding: 16px;
    flex: 1;
    display: flex;
    flex-direction: column;
}

.book-card-title {
    font-size: 16px;
    font-weight: 600;
    color: #111827;
    margin-bottom: 8px;
    font-family: "PBold", sans-serif;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
}

.book-card-description {
    font-size: 12px;
    color: #6B7280;
    margin-bottom: 8px;
    font-family: "PRegular", sans-serif;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
    flex: 1;
}

.book-card-meta {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 8px;
}

.book-card-genre {
    padding: 4px 8px;
    background: #F3F4F6;
    border-radius: 4px;
    font-size: 10px;
    color: #6B7280;
    font-family: "PRegular", sans-serif;
}

.book-card-rating {
    display: flex;
    align-items: center;
    gap: 4px;
    font-size: 14px;
    font-weight: 500;
    color: #111827;
    font-family: "PBold", sans-serif;
}

.book-card-rating i {
    color: #FBBF24;
    font-size: 14px;
}

.book-card-price-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 12px;
}

.book-card-price {
    font-size: 15px;
    font-weight: 700;
    color: #088525;
    font-family: "PBold", sans-serif;
}

.book-card-pages {
    font-size: 12px;
    color: #6B7280;
    font-family: "PRegular", sans-serif;
}

.book-card-actions {
    display: flex;
    gap: 8px;
}

.book-btn {
    flex: 1;
    padding: 8px;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 500;
    text-align: center;
    text-decoration: none;
    border: none;
    cursor: pointer;
    transition: all 0.2s;
    font-family: "PRegular", sans-serif;
}

.book-btn-outline {
    background: white;
    color: #F97316;
    border: 1px solid #F97316;
}

.book-btn-outline:hover {
    background: #F97316;
    color: white;
}

.book-btn-primary {
    background: #F97316;
    color: white;
}

.book-btn-primary:hover {
    background: #EA580C;
}

.book-btn-share {
    flex: 0 0 auto;
    width: 40px;
    padding: 8px;
    background: #6B7280;
    color: white;
    display: flex;
    align-items: center;
    justify-content: center;
}

.book-btn-share:hover {
    background: #4B5563;
}

.book-btn-share svg {
    width: 16px;
    height: 16px;
}

/* List Card */
.book-card-list {
    background: white;
    padding: 16px;
    border-radius: 12px;
    box-shadow: 0 1px 8px rgba(0,0,0,0.1);
}

.book-list-content {
    display: flex;
    gap: 16px;
}

.book-list-cover {
    flex-shrink: 0;
}

.book-list-cover img {
    width: 80px;
    height: 112px;
    object-fit: cover;
    border-radius: 8px;
    background: #E5E7EB;
}

.book-list-info {
    flex: 1;
    display: flex;
    flex-direction: column;
}

.book-list-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 12px;
}

.book-list-main {
    flex: 1;
}

.book-list-title {
    font-size: 16px;
    font-weight: 600;
    color: #111827;
    margin-bottom: 4px;
    font-family: "PBold", sans-serif;
}

.book-list-author {
    font-size: 14px;
    color: #6B7280;
    margin-bottom: 8px;
    font-family: "PRegular", sans-serif;
}

.book-list-description {
    font-size: 14px;
    color: #6B7280;
    margin-bottom: 12px;
    font-family: "PRegular", sans-serif;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
}

.book-list-meta-row {
    display: flex;
    flex-wrap: wrap;
    gap: 16px;
    align-items: center;
}

.book-list-genre,
.book-list-country,
.book-list-pages {
    font-size: 12px;
    color: #6B7280;
    font-family: "PRegular", sans-serif;
}

.book-list-genre {
    padding: 4px 8px;
    background: #F3F4F6;
    border-radius: 4px;
}

.book-list-price-badge {
    padding: 4px 8px;
    border-radius: 5px;
    font-size: 10px;
    font-weight: 600;
    color: white;
    font-family: "PBold", sans-serif;
}

.book-list-price-badge.free {
    background: #009F38;
}

.book-list-price-badge.paid {
    background: #DF2E0A;
}

.book-list-price {
    font-size: 15px;
    font-weight: 700;
    color: #088525;
    font-family: "PBold", sans-serif;
}

.book-list-badges {
    display: flex;
    gap: 8px;
}

.book-list-actions {
    display: flex;
    gap: 8px;
}

/* Pagination */
.pagination-container {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 16px;
    margin-top: 48px;
}

.pagination-btn {
    padding: 12px 24px;
    background: #F97316;
    color: white;
    border: none;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 500;
    cursor: pointer;
    font-family: "PRegular", sans-serif;
    transition: background 0.2s;
}

.pagination-btn:hover:not(:disabled) {
    background: #EA580C;
}

.pagination-btn:disabled {
    background: #D1D5DB;
    cursor: not-allowed;
}

.pagination-info {
    font-size: 16px;
    font-weight: 700;
    color: #111827;
    font-family: "PBold", sans-serif;
}

/* Responsive */
@media (max-width: 1024px) {
    .explore-main {
        flex-direction: column;
    }
    
    .filters-sidebar {
        width: 100%;
    }
    
    .books-container.grid {
        grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
    }
}

@media (max-width: 768px) {
    .explore-page {
        padding: 16px;
    }
    
    .explore-title {
        font-size: 22px;
    }
    
    .explore-subtitle {
        font-size: 13px;
    }
    
    .controls-bar {
        flex-direction: column;
        gap: 16px;
        align-items: stretch;
    }
    
    .sort-controls,
    .view-controls {
        justify-content: space-between;
    }
    
    .books-container.grid {
        grid-template-columns: 1fr;
    }
    
    .book-list-content {
        flex-direction: column;
    }
    
    .book-list-cover {
        align-self: center;
    }
}

@media (max-width: 640px) {
    .view-controls {
        display: none; /* Cacher le toggle vue sur mobile comme dans Flutter */
    }
}

/* Loading Overlay for Filters */
.filter-loading-overlay {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(255, 255, 255, 0.9);
    display: none;
    justify-content: center;
    align-items: center;
    flex-direction: column;
    z-index: 10000;
    backdrop-filter: blur(4px);
}

.filter-spinner {
    width: 50px;
    height: 50px;
    border: 4px solid #E5E7EB;
    border-top-color: #F97316;
    border-radius: 50%;
    animation: spin 0.8s linear infinite;
    margin-bottom: 16px;
}

.filter-loading-overlay p {
    font-size: 16px;
    color: #374151;
    font-family: "PRegular", sans-serif;
}

@keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
}
</style>
@endpush

@push('scripts')
<script>
const baseUrl = "{{ $baseUrl }}";
const isLoggedIn = {{ $isLoggedIn ? 'true' : 'false' }};
const userId = {{ $isLoggedIn && $user ? $user->id : 'null' }};

// Récupérer le paramètre ref depuis l'URL (affiliation)
const urlParams = new URLSearchParams(window.location.search);
const affiliateRef = urlParams.get('ref') || '';

// Handle filter changes
document.addEventListener('DOMContentLoaded', function() {
    // Search input debounce
    let searchTimeout;
    const searchInput = document.getElementById('searchInput');
    if (searchInput) {
        searchInput.addEventListener('input', function() {
            clearTimeout(searchTimeout);
            searchTimeout = setTimeout(() => {
                updateFilters();
            }, 500);
        });
    }
    
    // Genre filter
    const genreFilter = document.getElementById('genreFilter');
    if (genreFilter) {
        genreFilter.addEventListener('change', updateFilters);
    }
    
    // Language filter
    const languageFilter = document.getElementById('languageFilter');
    if (languageFilter) {
        languageFilter.addEventListener('change', updateFilters);
    }
    
    // Price radio buttons
    const priceRadios = document.querySelectorAll('input[name="price"]');
    priceRadios.forEach(radio => {
        radio.addEventListener('change', updateFilters);
    });
    
    // Sort filter
    const sortFilter = document.getElementById('sortFilter');
    if (sortFilter) {
        sortFilter.addEventListener('change', updateFilters);
    }
    
    // View buttons
    const viewButtons = document.querySelectorAll('.view-btn');
    viewButtons.forEach(btn => {
        btn.addEventListener('click', function() {
            const view = this.dataset.view;
            document.getElementById('hiddenView').value = view;
            updateFilters();
        });
    });
});

function updateFilters() {
    // Afficher le loader immédiatement
    showLoadingOverlay();
    
    const form = document.getElementById('searchForm');
    const search = document.getElementById('searchInput').value;
    const genre = document.getElementById('genreFilter').value;
    const language = document.getElementById('languageFilter').value;
    const price = document.querySelector('input[name="price"]:checked').value;
    const sort = document.getElementById('sortFilter').value;
    const view = document.getElementById('hiddenView').value;
    
    const url = new URL(form.action);
    url.searchParams.set('search', search);
    url.searchParams.set('genre', genre);
    url.searchParams.set('language', language);
    url.searchParams.set('price', price);
    url.searchParams.set('sort', sort);
    url.searchParams.set('view', view);
    url.searchParams.set('page', '1'); // Reset to page 1
    
    window.location.href = url.toString();
}

function showLoadingOverlay() {
    // Créer ou afficher le loader
    let loader = document.getElementById('filterLoader');
    if (!loader) {
        loader = document.createElement('div');
        loader.id = 'filterLoader';
        loader.className = 'filter-loading-overlay';
        loader.innerHTML = '<div class="filter-spinner"></div><p>Chargement des résultats...</p>';
        document.body.appendChild(loader);
    }
    loader.style.display = 'flex';
}

function handleBookAction(bookId, priceType, isPurchased, book) {
    if (priceType === 'gratuit' || isPurchased) {
        // Redirect to reader
        window.location.href = `/reader/${bookId}`;
        return;
    }
    
    if (!isLoggedIn) {
        window.location.href = '{{ route("login") }}';
        return;
    }
    
    // Handle purchase
    handlePurchase(book);
}

function shareBook(slug, title, author) {
    const bookUrl = window.location.origin + '/' + encodeURIComponent(slug);
    
    // Always copy to clipboard directly
    copyToClipboard(bookUrl, title);
}

function copyToClipboard(text, title) {
    // Try modern clipboard API first
    if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(text).then(() => {
            showShareNotification(`Lien de "${title}" copié ! Partagez-le maintenant.`);
        }).catch(() => {
            // Fallback to old method
            fallbackCopyToClipboard(text, title);
        });
    } else {
        fallbackCopyToClipboard(text, title);
    }
}

function fallbackCopyToClipboard(text, title) {
    const textArea = document.createElement('textarea');
    textArea.value = text;
    textArea.style.position = 'fixed';
    textArea.style.opacity = '0';
    document.body.appendChild(textArea);
    textArea.select();
    try {
        document.execCommand('copy');
        showShareNotification(`Lien de "${title}" copié ! Partagez-le maintenant.`);
    } catch (err) {
        showShareNotification('Impossible de copier le lien', 'error');
    }
    document.body.removeChild(textArea);
}

function showShareNotification(message, type = 'success') {
    // Create a simple notification element
    const notification = document.createElement('div');
    notification.className = 'share-notification ' + type;
    notification.textContent = message;
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: ${type === 'error' ? '#EF4444' : '#10B981'};
        color: white;
        padding: 12px 20px;
        border-radius: 8px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        z-index: 10000;
        font-size: 14px;
        font-weight: 500;
        animation: slideIn 0.3s ease-out;
    `;
    document.body.appendChild(notification);
    
    setTimeout(() => {
        notification.style.animation = 'slideOut 0.3s ease-out';
        setTimeout(() => {
            document.body.removeChild(notification);
        }, 300);
    }, 3000);
}

// Add CSS animation styles for notifications
if (!document.getElementById('share-notification-styles')) {
    const style = document.createElement('style');
    style.id = 'share-notification-styles';
    style.textContent = `
        @keyframes slideIn {
            from {
                transform: translateX(100%);
                opacity: 0;
            }
            to {
                transform: translateX(0);
                opacity: 1;
            }
        }
        @keyframes slideOut {
            from {
                transform: translateX(0);
                opacity: 1;
            }
            to {
                transform: translateX(100%);
                opacity: 0;
            }
        }
    `;
    document.head.appendChild(style);
}

async function handlePurchase(book) {
    const buyButton = event.target;
    const originalText = buyButton.innerHTML;
    buyButton.disabled = true;
    buyButton.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Traitement...';
    
    try {
        // S'assurer que le prix est un entier (Moneroo attend un entier)
        const price = Math.round(parseFloat(book.price) || 0);
        const bookId = book.id;
        const title = book.title || '';
        
        if (price <= 0) {
            alert('Prix du livre invalide.');
            buyButton.disabled = false;
            buyButton.innerHTML = originalText;
            return;
        }
        
        const currency = localStorage.getItem('currency') || 'XOF';
        const country = localStorage.getItem('country') || 'Bénin';
        
        const response = await fetch(`${baseUrl}/moneroo_init_book.php`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                amount: price,
                currency: currency,
                country: country,
                description: `Achat livre: ${title}`,
                email: '{{ $isLoggedIn && $user ? $user->email : "" }}',
                first_name: '{{ $isLoggedIn && $user && $user->name ? explode(" ", $user->name)[0] : "Utilisateur" }}',
                last_name: '{{ $isLoggedIn && $user && $user->name ? (count(explode(" ", $user->name)) > 1 ? implode(" ", array_slice(explode(" ", $user->name), 1)) : "TAKA") : "TAKA" }}',
                user_id: userId,
                book_id: bookId,
                return_url: 'https://takaafrica.com',
                ...(affiliateRef ? { ref: affiliateRef } : {}),
            })
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
            return;
        }
        
        const data = await response.json();
        
        if (data.checkout_url) {
            window.open(data.checkout_url, '_blank');
            await waitForBookPayment(bookId);
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
        }
    } catch (e) {
        console.error('Erreur de paiement:', e);
        alert('Erreur réseau ou de paiement.');
    } finally {
        buyButton.disabled = false;
        buyButton.innerHTML = originalText;
    }
}

async function waitForBookPayment(bookId) {
    let tries = 0;
    const maxTries = 60;
    const checkInterval = setInterval(async () => {
        tries++;
        try {
            const response = await fetch(`${baseUrl}/check_book_payment_status.php?user_id=${userId}&book_id=${bookId}`);
            const data = await response.json();
            
            if (data.status === 'paid') {
                clearInterval(checkInterval);
                alert('Paiement réussi! Vous pouvez maintenant lire le livre.');
                location.reload();
            } else if (tries >= maxTries) {
                clearInterval(checkInterval);
                alert('Délai d\'attente du paiement dépassé.');
            }
        } catch (e) {
            console.error('Error checking payment status:', e);
            clearInterval(checkInterval);
        }
    }, 1000);
}
</script>
@endpush
@endsection
