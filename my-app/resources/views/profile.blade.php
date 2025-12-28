@extends('layouts.app')

@section('title', 'Mon Profil - TAKA')

@if(!auth()->check())
@section('content')
<div class="restricted-page">
    <div class="restricted-container">
        <h1 class="restricted-title">Accès restreint</h1>
        <p class="restricted-text">Vous devez être connecté pour accéder à cette page.</p>
        <a href="{{ route('login') }}" class="restricted-btn">Se connecter</a>
    </div>
</div>
@endsection
@else
@section('content')
<div class="profile-page">
    <div class="profile-container">
        <!-- Profile Header -->
        <div class="profile-header">
            <div class="profile-avatar-section">
                <div class="avatar-wrapper">
                    <div class="avatar-circle">
                        <i class="fas fa-user"></i>
                    </div>
                    <div class="avatar-edit-badge">
                        <i class="fas fa-edit"></i>
                    </div>
                </div>
            </div>
            <div class="profile-info-section">
                <h1 class="profile-name">{{ $user->name ?? 'Utilisateur TAKA' }}</h1>
                <p class="profile-email">{{ $user->email }}</p>
                <div class="profile-stats">
                    <div class="stat-item">
                        <div class="stat-value" id="totalBooksRead">47</div>
                        <div class="stat-label">Livres lus</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-value" id="readingStreak">23</div>
                        <div class="stat-label">Jours consécutifs</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-value" id="subscription">Confort</div>
                        <div class="stat-label">Abonnement</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-value" id="timeOnTaka">
                            @php
                                $daysOnTaka = max(0, (int)round($daysOnTaka ?? 0));
                                $monthsOnTaka = max(0, (int)round($monthsOnTaka ?? 0));
                            @endphp
                            @if($daysOnTaka < 30)
                                {{ $daysOnTaka }} jour{{ $daysOnTaka > 1 ? 's' : '' }}
                            @else
                                {{ $monthsOnTaka }} mois
                            @endif
                        </div>
                        <div class="stat-label">sur TAKA</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Navigation Tabs -->
        <div class="navigation-tabs">
            <div class="tabs-container">
                <button class="tab-btn active" data-tab="reading" onclick="switchTab('reading')">
                    <i class="fas fa-book"></i>
                    <span>Mes lectures</span>
                </button>
                <button class="tab-btn" data-tab="purchased" onclick="switchTab('purchased')">
                    <i class="fas fa-download"></i>
                    <span>Livres achetés</span>
                </button>
                <button class="tab-btn" data-tab="recommendations" onclick="switchTab('recommendations')">
                    <i class="fas fa-heart"></i>
                    <span>Recommandations</span>
                </button>
                <button class="tab-btn" data-tab="settings" onclick="switchTab('settings')">
                    <i class="fas fa-cog"></i>
                    <span>Paramètres</span>
                </button>
            </div>
        </div>

        <!-- Tab Content -->
        <div class="tab-content-container">
            <!-- Reading Tab -->
            <div class="tab-panel active" id="readingTab">
                <div class="panel-content">
                    <h2 class="panel-title">En cours de lecture</h2>
                    <div id="currentlyReadingContainer">
                        <div class="loading-spinner" id="readingLoading" style="display: none;">
                            <div class="spinner"></div>
                        </div>
                        <div id="currentlyReadingContent">
                            <p class="empty-message">Aucun livre en cours de lecture.</p>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Purchased Tab -->
            <div class="tab-panel" id="purchasedTab">
                <div class="panel-content">
                    <h2 class="panel-title">Livres achetés</h2>
                    <div id="purchasedBooksContainer">
                        <div class="loading-spinner" id="purchasedLoading" style="display: none;">
                            <div class="spinner"></div>
                        </div>
                        <div id="purchasedBooksContent">
                            <p class="empty-message">Chargement...</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Recommendations Tab -->
            <div class="tab-panel" id="recommendationsTab">
                <div class="panel-content">
                    <h2 class="panel-title">Recommandations personnalisées</h2>
                    <div id="recommendationsContainer">
                        <div id="recommendationsContent">
                            @if(isset($recommendations) && count($recommendations) > 0)
                                <div class="recommendations-grid">
                                    @foreach($recommendations as $book)
                                        @php
                                            $coverPath = $book['cover_path'] ?? '';
                                            $imageUrl = '';
                                            if (!empty($coverPath)) {
                                                if (str_starts_with($coverPath, 'http')) {
                                                    $imageUrl = $coverPath;
                                                } else {
                                                    $imageUrl = 'https://takaafrica.com/pharmaRh/taka/' . $coverPath;
                                                }
                                            }
                                            $slug = \App\Helpers\BookHelper::titleToSlug($book['title'] ?? '');
                                        @endphp
                                        <div class="recommendation-card">
                                            <div class="recommendation-cover">
                                                @if(!empty($imageUrl))
                                                    <img src="{{ $imageUrl }}" alt="{{ $book['title'] ?? '' }}" onerror="this.onerror=null; this.parentElement.innerHTML='<div class=\'recommendation-cover-placeholder\'><i class=\'fas fa-book\'></i></div>';">
                                                @else
                                                    <div class="recommendation-cover-placeholder">
                                                        <i class="fas fa-book"></i>
                                                    </div>
                                                @endif
                                            </div>
                                            <div class="recommendation-info">
                                                <h3 class="recommendation-title">{{ $book['title'] ?? '' }}</h3>
                                                <p class="recommendation-author">{{ $book['author'] ?? '' }}</p>
                                                <div class="recommendation-tags">
                                                    @if(!empty($book['genre']))
                                                        <span class="recommendation-tag">{{ $book['genre'] }}</span>
                                                    @endif
                                                    @if(!empty($book['language']))
                                                        <span class="recommendation-tag">{{ $book['language'] }}</span>
                                                    @endif
                                                    @if(!empty($book['plan']))
                                                        <span class="recommendation-tag">{{ $book['plan'] }}</span>
                                                    @endif
                                                </div>
                                                @if(!empty($book['summary']))
                                                    <p class="recommendation-summary">{{ Str::limit($book['summary'], 120) }}</p>
                                                @endif
                                                <a href="{{ route('book.show', $slug) }}" class="recommendation-btn">
                                                    <i class="fas fa-info-circle"></i>
                                                    Découvrir
                                                </a>
                                            </div>
                                        </div>
                                    @endforeach
                                </div>
                            @else
                                <p class="empty-message">Aucune recommandation pour le moment.</p>
                            @endif
                        </div>
                    </div>
                </div>
            </div>

            <!-- Settings Tab -->
            <div class="tab-panel" id="settingsTab">
                <div class="panel-content">
                    <div class="settings-section">
                        <h2 class="panel-title">Informations personnelles</h2>
                        <form method="POST" action="{{ route('profile.update') }}" id="profileForm" class="settings-form">
                            @csrf
                            <div class="form-field">
                                <label>Nom complet</label>
                                <input type="text" name="full_name" id="fullNameInput" value="{{ $user->name }}" required class="form-input">
                            </div>
                            <div class="form-field">
                                <label>Email</label>
                                <input type="email" value="{{ $user->email }}" disabled class="form-input">
                            </div>
                            <button type="submit" class="btn-save" id="saveBtn">
                                <span id="saveBtnText">Sauvegarder les modifications</span>
                                <div id="saveBtnLoader" class="btn-loader" style="display: none;"></div>
                            </button>
                        </form>
                    </div>

                    <div class="settings-section">
                        <h2 class="panel-title">Notifications</h2>
                        <div class="notifications-list">
                            <label class="switch-item">
                                <div class="switch-label">
                                    <span class="switch-title">Nouvelles sorties</span>
                                    <span class="switch-subtitle">Recevoir des notifications pour les nouveaux livres</span>
                                </div>
                                <input type="checkbox" checked class="switch-input">
                            </label>
                            <label class="switch-item">
                                <div class="switch-label">
                                    <span class="switch-title">Recommandations</span>
                                    <span class="switch-subtitle">Suggestions personnalisées basées sur vos lectures</span>
                                </div>
                                <input type="checkbox" checked class="switch-input">
                            </label>
                            <label class="switch-item">
                                <div class="switch-label">
                                    <span class="switch-title">Rappels de lecture</span>
                                    <span class="switch-subtitle">Rappels pour continuer vos lectures en cours</span>
                                </div>
                                <input type="checkbox" class="switch-input">
                            </label>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Book Detail Modal -->
<div id="bookDetailModal" class="book-modal" style="display: none;">
    <div class="modal-overlay" onclick="closeBookModal()"></div>
    <div class="modal-content">
        <button class="modal-close" onclick="closeBookModal()">
            <i class="fas fa-times"></i>
        </button>
        <div id="bookModalContent"></div>
    </div>
</div>

@push('styles')
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
<style>
.profile-page {
    background: #F9FAFB;
    min-height: calc(100vh - 200px);
    padding: 32px 0;
}

.profile-container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 20px;
}

/* Profile Header */
.profile-header {
    background: white;
    padding: 32px;
    border-radius: 12px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
    margin-bottom: 32px;
    display: flex;
    gap: 24px;
    align-items: flex-start;
}

.profile-avatar-section {
    flex-shrink: 0;
}

.avatar-wrapper {
    position: relative;
}

.avatar-circle {
    width: 96px;
    height: 96px;
    border-radius: 50%;
    background: #E5E7EB;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #9CA3AF;
    font-size: 36px;
}

.avatar-edit-badge {
    position: absolute;
    bottom: 0;
    right: 0;
    width: 32px;
    height: 32px;
    border-radius: 16px;
    background: #F97316;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-size: 12px;
    cursor: pointer;
}

.profile-info-section {
    flex: 1;
}

.profile-name {
    font-size: 24px;
    font-weight: 700;
    color: #000000;
    margin-bottom: 8px;
    font-family: "PBold", sans-serif;
}

.profile-email {
    font-size: 16px;
    color: #6B7280;
    margin-bottom: 16px;
    font-family: "PRegular", sans-serif;
}

.profile-stats {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 24px;
}

.stat-item {
    text-align: center;
}

.stat-value {
    font-size: 24px;
    font-weight: 700;
    color: #F97316;
    margin-bottom: 4px;
    font-family: "PBold", sans-serif;
}

.stat-label {
    font-size: 12px;
    color: #6B7280;
    font-family: "PRegular", sans-serif;
}

/* Navigation Tabs */
.navigation-tabs {
    background: white;
    border-radius: 12px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
    margin-bottom: 32px;
    overflow-x: auto;
}

.tabs-container {
    display: flex;
}

.tab-btn {
    padding: 16px 24px;
    border: none;
    background: none;
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 16px;
    font-weight: 500;
    color: #6B7280;
    border-bottom: 2px solid transparent;
    transition: all 0.2s;
    white-space: nowrap;
    font-family: "PRegular", sans-serif;
}

.tab-btn.active {
    color: #F97316;
    border-bottom-color: #F97316;
    font-family: "PBold", sans-serif;
}

.tab-btn i {
    font-size: 20px;
}

/* Tab Content */
.tab-content-container {
    background: white;
    border-radius: 12px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}

.tab-panel {
    display: none;
    padding: 24px;
}

.tab-panel.active {
    display: block;
}

.panel-content {
    display: flex;
    flex-direction: column;
    gap: 24px;
}

.panel-title {
    font-size: 20px;
    font-weight: 600;
    color: #000000;
    font-family: "PBold", sans-serif;
}

/* Books Grid */
.books-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 32px;
}

.book-card {
    padding: 18px;
    background: #F9FAFB;
    border-radius: 14px;
    border: 1px solid #E5E7EB;
    box-shadow: 0 2px 8px rgba(0,0,0,0.08);
    display: flex;
    gap: 24px;
}

.book-cover {
    flex-shrink: 0;
}

.book-cover img {
    width: 80px;
    height: 120px;
    object-fit: cover;
    border-radius: 10px;
    background: #E5E7EB;
}

.book-cover-placeholder {
    width: 80px;
    height: 120px;
    border-radius: 10px;
    background: #E5E7EB;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #9CA3AF;
    font-size: 36px;
}

.book-info {
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 6px;
}

.book-title {
    font-size: 18px;
    font-weight: 700;
    color: #000000;
    font-family: "PBold", sans-serif;
}

.book-author {
    font-size: 14px;
    color: #6B7280;
    font-family: "PRegular", sans-serif;
}

.book-tags {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    margin: 10px 0;
}

.book-tag {
    padding: 4px 8px;
    background: #F3F4F6;
    border-radius: 4px;
    font-size: 12px;
    color: #374151;
    font-family: "PRegular", sans-serif;
}

.book-summary {
    font-size: 14px;
    color: #374151;
    line-height: 1.5;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
    font-family: "PRegular", sans-serif;
    margin-top: auto;
}

.book-actions {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: 10px;
}

.book-date {
    font-size: 12px;
    color: #9CA3AF;
    font-family: "PRegular", sans-serif;
}

.book-btn {
    padding: 10px 18px;
    background: #F97316;
    color: white;
    border: none;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 500;
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 8px;
    font-family: "PBold", sans-serif;
    transition: background 0.2s;
}

.book-btn:hover {
    background: #EA580C;
}

.book-btn-outline {
    background: white;
    color: #F97316;
    border: 1px solid #F97316;
}

.book-btn-outline:hover {
    background: #FFF7ED;
}

/* Reading Progress */
.reading-progress {
    margin: 12px 0;
}

.progress-label {
    display: flex;
    justify-content: space-between;
    font-size: 14px;
    margin-bottom: 4px;
    font-family: "PRegular", sans-serif;
}

.progress-bar {
    height: 8px;
    background: #E5E7EB;
    border-radius: 4px;
    overflow: hidden;
}

.progress-fill {
    height: 100%;
    background: #F97316;
    transition: width 0.3s;
}

/* Settings Form */
.settings-section {
    margin-bottom: 32px;
}

.settings-form {
    display: flex;
    flex-direction: column;
    gap: 16px;
}

.form-field {
    display: flex;
    flex-direction: column;
    gap: 8px;
}

.form-field label {
    font-size: 14px;
    font-weight: 500;
    color: #374151;
    font-family: "PBold", sans-serif;
}

.form-input {
    padding: 12px 16px;
    border: 1px solid #D1D5DB;
    border-radius: 8px;
    font-size: 15px;
    font-family: "PRegular", sans-serif;
    transition: border-color 0.2s;
}

.form-input:focus {
    outline: none;
    border-color: #F97316;
    border-width: 2px;
}

.form-input:disabled {
    background: #F3F4F6;
    color: #6B7280;
}

.btn-save {
    padding: 12px 24px;
    background: #F97316;
    color: white;
    border: none;
    border-radius: 8px;
    font-size: 15px;
    font-weight: 500;
    cursor: pointer;
    font-family: "PBold", sans-serif;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    transition: background 0.2s;
    width: fit-content;
}

.btn-save:hover:not(:disabled) {
    background: #EA580C;
}

.btn-save:disabled {
    opacity: 0.6;
    cursor: not-allowed;
}

.btn-loader {
    width: 20px;
    height: 20px;
    border: 2px solid rgba(255,255,255,0.3);
    border-top-color: white;
    border-radius: 50%;
    animation: spin 0.8s linear infinite;
}

/* Notifications */
.notifications-list {
    display: flex;
    flex-direction: column;
    gap: 0;
}

.switch-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 16px 0;
    border-bottom: 1px solid #E5E7EB;
    cursor: pointer;
}

.switch-item:last-child {
    border-bottom: none;
}

.switch-label {
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 4px;
}

.switch-title {
    font-size: 16px;
    font-weight: 500;
    color: #000000;
    font-family: "PBold", sans-serif;
}

.switch-subtitle {
    font-size: 14px;
    color: #6B7280;
    font-family: "PRegular", sans-serif;
}

.switch-input {
    width: 48px;
    height: 24px;
    accent-color: #F97316;
    cursor: pointer;
}

/* Loading Spinner */
.loading-spinner {
    display: flex;
    justify-content: center;
    align-items: center;
    padding: 40px;
}

.spinner {
    width: 40px;
    height: 40px;
    border: 4px solid #E5E7EB;
    border-top-color: #F97316;
    border-radius: 50%;
    animation: spin 0.8s linear infinite;
}

@keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
}

.empty-message {
    text-align: center;
    padding: 40px;
    color: #6B7280;
    font-size: 16px;
    font-family: "PRegular", sans-serif;
}

/* Recommendations Grid (Format Flutter) */
.recommendations-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(500px, 1fr));
    gap: 32px;
    margin-top: 24px;
}

@media (max-width: 700px) {
    .recommendations-grid {
        grid-template-columns: 1fr;
        gap: 12px;
    }
}

.recommendation-card {
    display: flex;
    flex-direction: row;
    gap: 24px;
    padding: 18px;
    background: #F9FAFB;
    border-radius: 14px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
    border: 1px solid #E5E7EB;
}

@media (max-width: 700px) {
    .recommendation-card {
        padding: 10px;
        gap: 10px;
    }
}

.recommendation-cover {
    flex-shrink: 0;
}

.recommendation-cover img {
    width: 80px;
    height: 120px;
    object-fit: cover;
    border-radius: 10px;
    background: #E5E7EB;
}

@media (max-width: 700px) {
    .recommendation-cover img {
        width: 48px;
        height: 72px;
        border-radius: 6px;
    }
}

.recommendation-cover-placeholder {
    width: 80px;
    height: 120px;
    background: #E5E7EB;
    border-radius: 10px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #9CA3AF;
}

.recommendation-cover-placeholder i {
    font-size: 36px;
}

@media (max-width: 700px) {
    .recommendation-cover-placeholder {
        width: 48px;
        height: 72px;
        border-radius: 6px;
    }
    
    .recommendation-cover-placeholder i {
        font-size: 24px;
    }
}

.recommendation-info {
    flex: 1;
    display: flex;
    flex-direction: column;
    min-width: 0;
}

.recommendation-title {
    font-size: 18px;
    font-weight: 700;
    color: #000000;
    margin: 0 0 6px 0;
    font-family: "PBold", sans-serif;
    line-height: 1.4;
}

@media (max-width: 700px) {
    .recommendation-title {
        font-size: 14px;
        margin-bottom: 4px;
    }
}

.recommendation-author {
    font-size: 14px;
    color: #6B7280;
    margin: 0 0 10px 0;
    font-family: "PRegular", sans-serif;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

@media (max-width: 700px) {
    .recommendation-author {
        font-size: 11px;
        margin-bottom: 6px;
    }
}

.recommendation-tags {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    margin-bottom: 10px;
}

@media (max-width: 700px) {
    .recommendation-tags {
        margin-bottom: 6px;
    }
}

.recommendation-tag {
    display: inline-block;
    padding: 4px 12px;
    background: #F3F4F6;
    border-radius: 16px;
    font-size: 12px;
    color: #374151;
    font-family: "PRegular", sans-serif;
}

.recommendation-summary {
    font-size: 14px;
    color: #374151;
    line-height: 1.5;
    margin: 0 0 auto 0;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
    font-family: "PRegular", sans-serif;
    flex: 1;
}

.recommendation-btn {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 10px 18px;
    background: #F97316;
    color: white;
    text-decoration: none;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 500;
    font-family: "PBold", sans-serif;
    margin-top: auto;
    align-self: flex-end;
    transition: background 0.2s;
}

.recommendation-btn:hover {
    background: #EA580C;
}

@media (max-width: 700px) {
    .recommendation-btn {
        padding: 8px 10px;
        font-size: 12px;
    }
}

/* Book Modal */
.book-modal {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    z-index: 10000;
    display: flex;
    align-items: center;
    justify-content: center;
}

.modal-overlay {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0, 0, 0, 0.5);
}

.modal-content {
    position: relative;
    background: white;
    border-radius: 16px;
    padding: 24px;
    max-width: 400px;
    width: 90%;
    max-height: 90vh;
    overflow-y: auto;
    z-index: 10001;
}

.modal-close {
    position: absolute;
    top: 16px;
    right: 16px;
    background: none;
    border: none;
    font-size: 24px;
    color: #6B7280;
    cursor: pointer;
    padding: 4px;
}

.modal-book-cover {
    text-align: center;
    margin-bottom: 16px;
}

.modal-book-cover img {
    width: 120px;
    height: 180px;
    object-fit: cover;
    border-radius: 12px;
    background: #E5E7EB;
}

.modal-book-title {
    font-size: 20px;
    font-weight: bold;
    color: #000000;
    margin-bottom: 8px;
    font-family: "PBold", sans-serif;
}

.modal-book-author {
    font-size: 14px;
    color: #6B7280;
    margin-bottom: 12px;
    font-family: "PRegular", sans-serif;
}

.modal-book-tags {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    margin-bottom: 12px;
}

.modal-summary-title {
    font-size: 15px;
    font-weight: bold;
    color: #000000;
    margin-bottom: 4px;
    font-family: "PBold", sans-serif;
}

.modal-summary-text {
    font-size: 14px;
    color: #374151;
    line-height: 1.6;
    font-family: "PRegular", sans-serif;
}

/* Restricted Page */
.restricted-page {
    min-height: calc(100vh - 200px);
    display: flex;
    align-items: center;
    justify-content: center;
    background: #F9FAFB;
}

.restricted-container {
    text-align: center;
    padding: 48px;
}

.restricted-title {
    font-size: 24px;
    font-weight: 700;
    color: #000000;
    margin-bottom: 16px;
    font-family: "PBold", sans-serif;
}

.restricted-text {
    font-size: 16px;
    color: #6B7280;
    margin-bottom: 24px;
    font-family: "PRegular", sans-serif;
}

.restricted-btn {
    display: inline-block;
    padding: 22px 24px;
    background: #F97316;
    color: white;
    text-decoration: none;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 500;
    font-family: "PBold", sans-serif;
    transition: background 0.2s;
}

.restricted-btn:hover {
    background: #EA580C;
}

/* Responsive */
@media (max-width: 1024px) {
    .profile-stats {
        grid-template-columns: repeat(2, 1fr);
        gap: 16px;
    }
    
    .books-grid {
        grid-template-columns: 1fr;
        gap: 16px;
    }
}

@media (max-width: 768px) {
    .profile-page {
        padding: 16px 0;
    }
    
    .profile-container {
        padding: 0 8px;
    }
    
    .profile-header {
        flex-direction: column;
        align-items: center;
        text-align: center;
        padding: 16px;
    }
    
    .profile-stats {
        grid-template-columns: repeat(2, 1fr);
        gap: 16px;
        width: 100%;
    }
    
    .stat-value {
        font-size: 16px;
    }
    
    .tab-panel {
        padding: 12px;
    }
    
    .book-card {
        flex-direction: column;
        align-items: center;
        text-align: center;
    }
    
    .book-cover {
        align-self: center;
    }
    
    .book-info {
        align-items: center;
    }
}
</style>
@endpush

@push('scripts')
<script>
const baseUrl = 'https://takaafrica.com/pharmaRh/taka';
const userId = {{ auth()->user()->api_id ?? auth()->id() }};
let currentlyReading = [];
let purchasedBooks = [];
let recommendations = [];

// Utility function
function escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// Generate slug from title (same logic as BookHelper::titleToSlug)
function generateSlug(title) {
    if (!title) return '';
    
    // Decode HTML entities (like &#039; or &apos; for apostrophe)
    const tempDiv = document.createElement('div');
    tempDiv.innerHTML = title;
    title = tempDiv.textContent || tempDiv.innerText || title;
    
    let slug = title.toLowerCase();
    
    // Remove apostrophes and quotes
    slug = slug.replace(/['"«»„‚‹›""„‚]/g, '');
    
    const accents = {
        'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a',
        'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
        'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i',
        'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
        'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u',
        'ý': 'y', 'ÿ': 'y', 'ñ': 'n', 'ç': 'c',
    };
    
    Object.keys(accents).forEach(key => {
        slug = slug.replace(new RegExp(key, 'g'), accents[key]);
    });
    
    slug = slug.replace(/[^a-z0-9]+/g, '-');
    slug = slug.replace(/^-+|-+$/g, '');
    
    return slug;
}

// Initialize
document.addEventListener('DOMContentLoaded', function() {
    loadCurrentlyReading();
    loadPurchasedBooks();
    // loadRecommendations(); // Les recommandations sont maintenant chargées côté serveur
    
    // Form submit handler
    document.getElementById('profileForm').addEventListener('submit', handleProfileSubmit);
});

function switchTab(tabName) {
    // Update tabs
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    document.querySelector(`[data-tab="${tabName}"]`).classList.add('active');
    
    // Update panels
    document.querySelectorAll('.tab-panel').forEach(panel => {
        panel.classList.remove('active');
    });
    document.getElementById(tabName + 'Tab').classList.add('active');
}

function loadCurrentlyReading() {
    document.getElementById('readingLoading').style.display = 'block';
    
    // Load from localStorage (comme dans Flutter avec SharedPreferences)
    const stored = localStorage.getItem('currentlyReading');
    if (stored) {
        try {
            currentlyReading = JSON.parse(stored);
        } catch (e) {
            currentlyReading = [];
        }
    } else {
        currentlyReading = [];
    }
    
    setTimeout(() => {
        document.getElementById('readingLoading').style.display = 'none';
        renderCurrentlyReading();
    }, 300);
}

function renderCurrentlyReading() {
    const container = document.getElementById('currentlyReadingContent');
    
    if (currentlyReading.length === 0) {
        container.innerHTML = '<p class="empty-message">Aucun livre en cours de lecture.</p>';
        return;
    }
    
    const grid = document.createElement('div');
    grid.className = 'books-grid';
    
    currentlyReading.forEach(book => {
        const card = createReadingCard(book);
        grid.appendChild(card);
    });
    
    container.innerHTML = '';
    container.appendChild(grid);
}

function createReadingCard(book) {
    const card = document.createElement('div');
    card.className = 'book-card';
    
    const progress = book.progress || 0;
    
    card.innerHTML = `
        <div class="book-cover">
            <div class="book-cover-placeholder">
                <i class="fas fa-book"></i>
            </div>
        </div>
        <div class="book-info">
            <h3 class="book-title">${book.title || ''}</h3>
            <p class="book-author">${book.author || ''}</p>
            <div class="reading-progress">
                <div class="progress-label">
                    <span>Progression</span>
                    <span>${progress}%</span>
                </div>
                <div class="progress-bar">
                    <div class="progress-fill" style="width: ${progress}%"></div>
                </div>
            </div>
            <div class="book-actions">
                <button class="book-btn" onclick="window.location.href='/reader/${generateSlug(book.title || '')}'">
                    <i class="fas fa-book-reader"></i>
                    <span>Continuer la lecture</span>
                </button>
            </div>
        </div>
    `;
    
    return card;
}

async function loadPurchasedBooks() {
    document.getElementById('purchasedLoading').style.display = 'block';
    const container = document.getElementById('purchasedBooksContent');
    
    try {
        const response = await fetch(`${baseUrl}/taka_api_purchased_books.php?user_id=${userId}`);
        const data = await response.json();
        
        document.getElementById('purchasedLoading').style.display = 'none';
        
        if (data.success && data.books && Array.isArray(data.books)) {
            purchasedBooks = data.books;
            renderPurchasedBooks();
        } else {
            container.innerHTML = '<p class="empty-message">Aucun livre acheté pour le moment</p>';
        }
    } catch (error) {
        document.getElementById('purchasedLoading').style.display = 'none';
        console.error('Error loading purchased books:', error);
        container.innerHTML = '<p class="empty-message">Erreur lors du chargement des livres</p>';
    }
}

function renderPurchasedBooks() {
    const container = document.getElementById('purchasedBooksContent');
    
    if (purchasedBooks.length === 0) {
        container.innerHTML = '<p class="empty-message">Aucun livre acheté pour le moment</p>';
        return;
    }
    
    const grid = document.createElement('div');
    grid.className = 'books-grid';
    
    purchasedBooks.forEach(book => {
        const card = createPurchasedCard(book);
        grid.appendChild(card);
    });
    
    container.innerHTML = '';
    container.appendChild(grid);
}

function createPurchasedCard(book) {
    const card = document.createElement('div');
    card.className = 'book-card';
    
    const coverPath = book.cover_path || '';
    const coverUrl = coverPath ? (coverPath.startsWith('http') ? coverPath : `${baseUrl}/${coverPath}`) : '';
    const slug = book.slug || (book.title ? generateSlug(book.title) : '');
    
    const purchasedDate = book.purchased_at ? new Date(book.purchased_at).toLocaleDateString('fr-FR') : '';
    
    card.innerHTML = `
        <div class="book-cover">
            ${coverUrl ? `<img src="${coverUrl}" alt="${escapeHtml(book.title || '')}" onerror="this.parentElement.innerHTML='<div class=\\'book-cover-placeholder\\'><i class=\\'fas fa-book\\'></i></div>'">` : '<div class="book-cover-placeholder"><i class="fas fa-book"></i></div>'}
        </div>
        <div class="book-info">
            <h3 class="book-title">${escapeHtml(book.title || '')}</h3>
            <p class="book-author">${escapeHtml(book.author_bio || book.author || '')}</p>
            <div class="book-tags">
                ${book.genre ? `<span class="book-tag">${escapeHtml(book.genre)}</span>` : ''}
                ${book.language ? `<span class="book-tag">${escapeHtml(book.language)}</span>` : ''}
                ${book.plan ? `<span class="book-tag">${escapeHtml(book.plan)}</span>` : ''}
            </div>
            <p class="book-summary">${escapeHtml(book.summary || '')}</p>
            <div class="book-actions">
                <span class="book-date">Acheté le ${purchasedDate}</span>
                <button class="book-btn" onclick="window.location.href='/reader/${generateSlug(book.title || '')}'">
                    <i class="fas fa-book-reader"></i>
                    <span>Lire</span>
                </button>
            </div>
        </div>
    `;
    
    // Make card clickable to show detail
    card.style.cursor = 'pointer';
    card.addEventListener('click', (e) => {
        if (!e.target.closest('.book-btn')) {
            showBookDetailModal(book);
        }
    });
    
    return card;
}

async function loadRecommendations() {
    document.getElementById('recommendationsLoading').style.display = 'block';
    const container = document.getElementById('recommendationsContent');
    
    try {
        const response = await fetch(`${baseUrl}/taka_api_recommendations.php?user_id=${userId}`);
        const data = await response.json();
        
        document.getElementById('recommendationsLoading').style.display = 'none';
        
        if (data.success && data.books && Array.isArray(data.books)) {
            recommendations = data.books;
            renderRecommendations();
        } else {
            container.innerHTML = '<p class="empty-message">Aucune recommandation pour le moment.</p>';
        }
    } catch (error) {
        document.getElementById('recommendationsLoading').style.display = 'none';
        console.error('Error loading recommendations:', error);
        container.innerHTML = '<p class="empty-message">Erreur lors du chargement des recommandations</p>';
    }
}

function renderRecommendations() {
    const container = document.getElementById('recommendationsContent');
    
    if (recommendations.length === 0) {
        container.innerHTML = '<p class="empty-message">Aucune recommandation pour le moment.</p>';
        return;
    }
    
    const grid = document.createElement('div');
    grid.className = 'books-grid';
    
    recommendations.forEach(book => {
        const card = createRecommendationCard(book);
        grid.appendChild(card);
    });
    
    container.innerHTML = '';
    container.appendChild(grid);
}

function createRecommendationCard(book) {
    const card = document.createElement('div');
    card.className = 'book-card';
    
    const coverPath = book.cover_path || '';
    const coverUrl = coverPath ? (coverPath.startsWith('http') ? coverPath : `${baseUrl}/${coverPath}`) : '';
    const slug = book.slug || (book.title ? generateSlug(book.title) : '');
    
    const bookDataAttr = encodeURIComponent(JSON.stringify(book));
    
    card.innerHTML = `
        <div class="book-cover">
            ${coverUrl ? `<img src="${coverUrl}" alt="${book.title || ''}" onerror="this.parentElement.innerHTML='<div class=\\'book-cover-placeholder\\'><i class=\\'fas fa-book\\'></i></div>'">` : '<div class="book-cover-placeholder"><i class="fas fa-book"></i></div>'}
        </div>
        <div class="book-info">
            <h3 class="book-title">${escapeHtml(book.title || '')}</h3>
            <p class="book-author">${escapeHtml(book.author_bio || book.author || '')}</p>
            <div class="book-tags">
                ${book.genre ? `<span class="book-tag">${escapeHtml(book.genre)}</span>` : ''}
                ${book.language ? `<span class="book-tag">${escapeHtml(book.language)}</span>` : ''}
                ${book.plan ? `<span class="book-tag">${escapeHtml(book.plan)}</span>` : ''}
            </div>
            <p class="book-summary">${escapeHtml(book.summary || '')}</p>
            <div class="book-actions">
                <button class="book-btn book-btn-outline" onclick="showBookDetailModalFromData('${bookDataAttr}')">
                    <i class="fas fa-info-circle"></i>
                    <span>Découvrir</span>
                </button>
            </div>
        </div>
    `;
    
    return card;
}

function showBookDetailModal(book) {
    const modal = document.getElementById('bookDetailModal');
    const content = document.getElementById('bookModalContent');
    
    const coverPath = book.cover_path || '';
    const coverUrl = coverPath ? (coverPath.startsWith('http') ? coverPath : `${baseUrl}/${coverPath}`) : '';
    
    content.innerHTML = `
        <div class="modal-book-cover">
            ${coverUrl ? `<img src="${coverUrl}" alt="${escapeHtml(book.title || '')}">` : '<div class="book-cover-placeholder" style="width: 120px; height: 180px; margin: 0 auto;"><i class="fas fa-book"></i></div>'}
        </div>
        <h2 class="modal-book-title">${escapeHtml(book.title || '')}</h2>
        <p class="modal-book-author">${escapeHtml(book.author_bio || book.author || '')}</p>
        <div class="modal-book-tags">
            ${book.genre ? `<span class="book-tag">${escapeHtml(book.genre)}</span>` : ''}
            ${book.language ? `<span class="book-tag">${escapeHtml(book.language)}</span>` : ''}
            ${book.plan ? `<span class="book-tag">${escapeHtml(book.plan)}</span>` : ''}
        </div>
        ${book.summary ? `
            <div>
                <h4 class="modal-summary-title">Résumé</h4>
                <p class="modal-summary-text">${escapeHtml(book.summary)}</p>
            </div>
        ` : ''}
    `;
    
    modal.style.display = 'flex';
}

function showBookDetailModalFromData(dataAttr) {
    try {
        const book = JSON.parse(decodeURIComponent(dataAttr));
        showBookDetailModal(book);
    } catch (e) {
        console.error('Error parsing book data:', e);
    }
}

function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

function closeBookModal() {
    document.getElementById('bookDetailModal').style.display = 'none';
}

async function handleProfileSubmit(e) {
    e.preventDefault();
    
    const btn = document.getElementById('saveBtn');
    const btnText = document.getElementById('saveBtnText');
    const btnLoader = document.getElementById('saveBtnLoader');
    
    btn.disabled = true;
    btnText.style.display = 'none';
    btnLoader.style.display = 'block';
    
    try {
        const formData = new FormData(e.target);
        const response = await fetch('{{ route("profile.update") }}', {
            method: 'POST',
            body: formData,
            headers: {
                'X-CSRF-TOKEN': '{{ csrf_token() }}'
            }
        });
        
        if (response.ok) {
            alert('Profil mis à jour !');
            window.location.reload();
        } else {
            alert('Erreur lors de la mise à jour.');
        }
    } catch (error) {
        console.error('Error:', error);
        alert('Erreur réseau: ' + error.message);
    } finally {
        btn.disabled = false;
        btnText.style.display = 'block';
        btnLoader.style.display = 'none';
    }
}

</script>
@endpush
@endsection
@endif
