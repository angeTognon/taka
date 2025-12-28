@extends('layouts.app')

@section('title', 'Tableau de bord auteur - TAKA')

@auth
@section('content')
<div class="dashboard-page">
    <div class="dashboard-container">
        <!-- Header -->
        <div class="dashboard-header">
            <div class="header-text">
                <h1>Tableau de bord auteur</h1>
                <p>Suivez les performances de vos publications</p>
            </div>
            <a href="{{ route('publish') }}" class="btn-new-book">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <line x1="12" y1="5" x2="12" y2="19"></line>
                    <line x1="5" y1="12" x2="19" y2="12"></line>
                </svg>
                Nouveau livre
            </a>
        </div>

        <!-- Stats Cards -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon stat-icon-blue">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path>
                        <path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path>
                    </svg>
                </div>
                <div class="stat-info">
                    <div class="stat-title">Livres publiés</div>
                    <div class="stat-value" id="totalBooks">{{ $stats['totalBooks'] ?? 0 }}</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon stat-icon-green">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <polyline points="23 6 13.5 15.5 8.5 10.5 1 18"></polyline>
                        <polyline points="17 6 23 6 23 12"></polyline>
                    </svg>
                </div>
                <div class="stat-info">
                    <div class="stat-title">Ventes totales</div>
                    <div class="stat-value" id="totalSales">{{ $stats['totalSales'] ?? 0 }}</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon stat-icon-orange">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <line x1="12" y1="1" x2="12" y2="23"></line>
                        <path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path>
                    </svg>
                </div>
                <div class="stat-info">
                    <div class="stat-title">Revenus nets</div>
                    <div class="stat-value" id="totalRevenue">{{ number_format($stats['totalRevenue'] ?? 0, 0, ',', ' ') }} FCFA</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon stat-icon-purple">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
                        <circle cx="9" cy="7" r="4"></circle>
                        <path d="M23 21v-2a4 4 0 0 0-3-3.87"></path>
                        <path d="M16 3.13a4 4 0 0 1 0 7.75"></path>
                    </svg>
                </div>
                <div class="stat-info">
                    <div class="stat-title">Lecteurs uniques</div>
                    <div class="stat-value" id="totalReaders">{{ $stats['totalReaders'] ?? 0 }}</div>
                </div>
            </div>
        </div>

        <!-- Main Content -->
        <div class="dashboard-main">
            <div class="dashboard-content">
                <!-- Books Management -->
                <div class="books-section">
                    <div class="section-header">
                        <h2>Mes livres</h2>
                        <select class="period-select" id="periodSelect">
                            <option value="week" {{ $period === 'week' ? 'selected' : '' }}>Cette semaine</option>
                            <option value="month" {{ $period === 'month' ? 'selected' : '' }}>Ce mois</option>
                            <option value="year" {{ $period === 'year' ? 'selected' : '' }}>Cette année</option>
                            <option value="all" {{ $period === 'all' ? 'selected' : '' }}>Tous</option>
                        </select>
                    </div>
                    <div class="books-list" id="booksList">
                        @if(count($books ?? []) > 0)
                            @foreach($books as $book)
                                <div class="book-item" data-book-id="{{ $book['id'] ?? '' }}">
                                    <div class="book-cover">
                                        @if(!empty($book['cover_path']))
                                            @php
                                                $coverUrl = str_starts_with($book['cover_path'], 'http') ? $book['cover_path'] : 'https://takaafrica.com/pharmaRh/taka/' . $book['cover_path'];
                                            @endphp
                                            <img src="{{ $coverUrl }}" alt="{{ $book['title'] ?? '' }}">
                                        @else
                                            <div class="book-placeholder">
                                                <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                    <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path>
                                                    <path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path>
                                                </svg>
                                            </div>
                                        @endif
                                    </div>
                                    <div class="book-details">
                                        <div class="book-header">
                                            <div class="book-title-section">
                                                <h3 class="book-title">{{ $book['title'] ?? '' }}</h3>
                                                <p class="book-date">
                                                    @php
                                                        $publishDate = $book['publishDate'] ?? $book['created_at'] ?? '';
                                                        $date = $publishDate ? \Carbon\Carbon::parse($publishDate)->format('d/m/Y') : '';
                                                    @endphp
                                                    @if($date)
                                                        Publié le {{ $date }}
                                                    @endif
                                                </p>
                                            </div>
                                            @php
                                                $status = $book['statut_validation'] ?? $book['status'] ?? 'En attente';
                                                $isPublished = strtolower($status) === 'publié' || strtolower($status) === 'validé';
                                            @endphp
                                            <span class="book-status {{ $isPublished ? 'status-published' : 'status-pending' }}">
                                                {{ $status }}
                                            </span>
                                        </div>
                                        <div class="book-stats">
                                            <div class="book-stat">
                                                <span class="stat-label">Ventes</span>
                                                <span class="stat-value">{{ $book['sales'] ?? 0 }}</span>
                                            </div>
                                            <div class="book-stat">
                                                <span class="stat-label">Revenus</span>
                                                <span class="stat-value">{{ number_format($book['revenue'] ?? 0, 0, ',', ' ') }} FCFA</span>
                                            </div>
                                            <div class="book-stat">
                                                <span class="stat-label">Note</span>
                                                <span class="stat-value">
                                                    {{ number_format($book['rating'] ?? 0, 1) }}
                                                    <svg width="14" height="14" viewBox="0 0 24 24" fill="#FBBF24" stroke="#FBBF24" stroke-width="2">
                                                        <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon>
                                                    </svg>
                                                </span>
                                            </div>
                                            <div class="book-stat">
                                                <span class="stat-label">Lecteurs</span>
                                                <span class="stat-value">{{ $book['readers'] ?? 0 }}</span>
                                            </div>
                                        </div>
                                        <div class="book-actions">
                                            <button class="btn-action btn-view" onclick="showBookDetail({{ json_encode($book) }})">
                                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                    <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                                                    <circle cx="12" cy="12" r="3"></circle>
                                                </svg>
                                                Voir
                                            </button>
                                            <button class="btn-action btn-edit" onclick="editBook({{ json_encode($book) }})">
                                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                    <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                                                    <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
                                                </svg>
                                                Modifier
                                            </button>
                                            <button class="btn-action btn-download" onclick="downloadBook('{{ $book['file_path'] ?? '' }}')">
                                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                    <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
                                                    <polyline points="7 10 12 15 17 10"></polyline>
                                                    <line x1="12" y1="15" x2="12" y2="3"></line>
                                                </svg>
                                                Version imprimée
                                            </button>
                                            <button class="btn-action btn-delete" onclick="deleteBook({{ $book['id'] ?? 0 }})">
                                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                    <polyline points="3 6 5 6 21 6"></polyline>
                                                    <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
                                                </svg>
                                                Supprimer
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            @endforeach
                        @else
                            <p class="empty-message">Aucun livre publié</p>
                        @endif
                    </div>
                </div>

                <!-- Sales Chart -->
                <div class="sales-chart-section">
                    <h2>Évolution des ventes</h2>
                    <div class="chart-container">
                        <div class="chart-bars">
                            @php
                                $salesData = $salesChartData ?? [];
                                if (empty($salesData)) {
                                    // Générer les 6 derniers mois par défaut
                                    $now = \Carbon\Carbon::now();
                                    $months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun', 'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
                                    $salesData = [];
                                    for ($i = 5; $i >= 0; $i--) {
                                        $monthDate = $now->copy()->subMonths($i);
                                        $salesData[] = ['month' => $months[$monthDate->month - 1], 'sales' => 0];
                                    }
                                }
                                $maxSales = collect($salesData)->max('sales') ?? 1;
                            @endphp
                            @foreach($salesData as $data)
                                @php
                                    $height = $maxSales > 0 ? ($data['sales'] / $maxSales) * 100 : 0;
                                @endphp
                                <div class="chart-bar-wrapper">
                                    <div class="chart-bar" style="height: {{ $height }}%">
                                        <span class="chart-value">{{ $data['sales'] }}</span>
                                    </div>
                                    <div class="chart-month">{{ $data['month'] }}</div>
                                </div>
                            @endforeach
                        </div>
                    </div>
                </div>
            </div>

            <!-- Sidebar - Performance -->
            <div class="dashboard-sidebar">
                <div class="performance-section">
                    <h2>Performances</h2>
                    <div class="performance-item">
                        <div class="performance-header">
                            <span class="performance-label">Note moyenne</span>
                            <span class="performance-value">{{ number_format($performanceData['averageRating'] ?? 0, 1) }}/5</span>
                        </div>
                        <div class="progress-bar">
                            <div class="progress-fill" style="width: {{ (($performanceData['averageRating'] ?? 0) / 5) * 100 }}%; background: #FBBF24;"></div>
                        </div>
                    </div>
                    <div class="performance-item">
                        <div class="performance-header">
                            <span class="performance-label">Taux d'achèvement</span>
                            <span class="performance-value">{{ number_format((($performanceData['completionRate'] ?? 0) * 100), 0) }}%</span>
                        </div>
                        <div class="progress-bar">
                            <div class="progress-fill" style="width: {{ ($performanceData['completionRate'] ?? 0) * 100 }}%; background: #10B981;"></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Book Detail Modal -->
<div id="bookDetailModal" class="modal">
    <div class="modal-content">
        <span class="close-modal" onclick="closeBookDetail()">&times;</span>
        <div id="bookDetailContent"></div>
    </div>
</div>

@push('styles')
<style>
:root {
    --dashboard-bg: #F9FAFB;
    --white: #FFFFFF;
    --text-primary: #111827;
    --text-secondary: #6B7280;
    --border-color: #E5E7EB;
    --orange: #F97316;
    --blue: #3B82F6;
    --green: #10B981;
    --purple: #8B5CF6;
    --yellow: #FBBF24;
    --shadow: 0 1px 8px rgba(0, 0, 0, 0.04);
}

.dashboard-page {
    min-height: calc(100vh - 200px);
    background: var(--dashboard-bg);
    padding: 32px 20px;
}

.dashboard-container {
    max-width: 1400px;
    margin: 0 auto;
}

.dashboard-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 32px;
    gap: 24px;
}

.header-text h1 {
    font-size: 28px;
    font-weight: 700;
    color: var(--text-primary);
    margin: 0 0 8px 0;
    font-family: 'Inter', sans-serif;
}

.header-text p {
    font-size: 16px;
    color: var(--text-secondary);
    margin: 0;
    font-family: 'Inter', sans-serif;
}

.btn-new-book {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 12px 24px;
    background: var(--orange);
    color: white;
    border-radius: 8px;
    text-decoration: none;
    font-weight: 600;
    font-size: 14px;
    font-family: 'Inter', sans-serif;
    white-space: nowrap;
    transition: background 0.2s;
}

.btn-new-book:hover {
    background: #EA580C;
}

.stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 24px;
    margin-bottom: 32px;
}

.stat-card {
    background: var(--white);
    padding: 24px;
    border-radius: 12px;
    box-shadow: var(--shadow);
    display: flex;
    align-items: center;
    gap: 16px;
}

.stat-icon {
    width: 48px;
    height: 48px;
    border-radius: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
}

.stat-icon-blue {
    background: rgba(59, 130, 246, 0.1);
    color: var(--blue);
}

.stat-icon-green {
    background: rgba(16, 185, 129, 0.1);
    color: var(--green);
}

.stat-icon-orange {
    background: rgba(249, 115, 22, 0.1);
    color: var(--orange);
}

.stat-icon-purple {
    background: rgba(139, 92, 246, 0.1);
    color: var(--purple);
}

.stat-info {
    flex: 1;
}

.stat-title {
    font-size: 14px;
    color: var(--text-secondary);
    margin-bottom: 8px;
    font-family: 'Inter', sans-serif;
}

.stat-value {
    font-size: 24px;
    font-weight: 700;
    color: var(--text-primary);
    font-family: 'Inter', sans-serif;
}

.dashboard-main {
    display: grid;
    grid-template-columns: 1fr 320px;
    gap: 32px;
    align-items: start;
}

.dashboard-content {
    display: flex;
    flex-direction: column;
    gap: 32px;
}

.books-section,
.sales-chart-section,
.performance-section {
    background: var(--white);
    padding: 24px;
    border-radius: 12px;
    box-shadow: var(--shadow);
}

.section-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 24px;
}

.section-header h2 {
    font-size: 20px;
    font-weight: 600;
    color: var(--text-primary);
    margin: 0;
    font-family: 'Inter', sans-serif;
}

.period-select {
    padding: 8px 12px;
    border: 1px solid var(--border-color);
    border-radius: 8px;
    font-size: 14px;
    font-family: 'Inter', sans-serif;
    background: var(--white);
    color: var(--text-primary);
    cursor: pointer;
}

.books-list {
    display: flex;
    flex-direction: column;
    gap: 16px;
}

.empty-message {
    text-align: center;
    padding: 40px;
    color: var(--text-secondary);
    font-family: 'Inter', sans-serif;
}

.book-item {
    display: flex;
    gap: 16px;
    padding: 16px;
    border: 1px solid var(--border-color);
    border-radius: 8px;
    transition: box-shadow 0.2s;
}

.book-item:hover {
    box-shadow: var(--shadow);
}

.book-cover {
    width: 64px;
    height: 96px;
    border-radius: 8px;
    background: var(--border-color);
    overflow: hidden;
    flex-shrink: 0;
}

.book-cover img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.book-placeholder {
    width: 100%;
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #9CA3AF;
}

.book-details {
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 16px;
}

.book-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    gap: 16px;
}

.book-title-section {
    flex: 1;
}

.book-title {
    font-size: 16px;
    font-weight: 600;
    color: var(--text-primary);
    margin: 0 0 4px 0;
    font-family: 'Inter', sans-serif;
}

.book-date {
    font-size: 14px;
    color: var(--text-secondary);
    margin: 0;
    font-family: 'Inter', sans-serif;
}

.book-status {
    padding: 4px 8px;
    border-radius: 12px;
    font-size: 12px;
    font-weight: 600;
    font-family: 'Inter', sans-serif;
    white-space: nowrap;
}

.status-published {
    background: #DCFCE7;
    color: #166534;
}

.status-pending {
    background: #FEF3C7;
    color: #92400E;
}

.book-stats {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 16px;
}

.book-stat {
    display: flex;
    flex-direction: column;
}

.book-stat .stat-label {
    font-size: 14px;
    color: var(--text-secondary);
    margin-bottom: 4px;
    font-family: 'Inter', sans-serif;
}

.book-stat .stat-value {
    font-size: 16px;
    font-weight: 600;
    color: var(--text-primary);
    display: flex;
    align-items: center;
    gap: 4px;
    font-family: 'Inter', sans-serif;
}

.book-actions {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
}

.btn-action {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 6px 12px;
    border: none;
    border-radius: 6px;
    font-size: 14px;
    font-family: 'Inter', sans-serif;
    cursor: pointer;
    transition: background 0.2s;
    background: transparent;
    flex: 1 1 auto;
    min-width: fit-content;
    justify-content: flex-start;
}

.btn-view {
    color: var(--blue);
}

.btn-view:hover {
    background: rgba(59, 130, 246, 0.1);
}

.btn-edit {
    color: var(--text-secondary);
}

.btn-edit:hover {
    background: rgba(107, 114, 128, 0.1);
}

.btn-download {
    color: var(--text-secondary);
}

.btn-download:hover {
    background: rgba(107, 114, 128, 0.1);
}

.btn-delete {
    color: #EF4444;
}

.btn-delete:hover {
    background: rgba(239, 68, 68, 0.1);
}

.sales-chart-section h2 {
    font-size: 20px;
    font-weight: 600;
    color: var(--text-primary);
    margin: 0 0 24px 0;
    font-family: 'Inter', sans-serif;
}

.chart-container {
    height: 200px;
}

.chart-bars {
    display: flex;
    align-items: flex-end;
    height: 100%;
    gap: 8px;
}

.chart-bar-wrapper {
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    height: 100%;
}

.chart-bar {
    width: 100%;
    background: var(--orange);
    border-radius: 4px;
    position: relative;
    min-height: 20px;
    display: flex;
    align-items: flex-start;
    justify-content: center;
    padding-top: 8px;
}

.chart-value {
    font-size: 12px;
    font-weight: 600;
    color: white;
    font-family: 'Inter', sans-serif;
}

.chart-month {
    margin-top: 8px;
    font-size: 12px;
    color: var(--text-secondary);
    font-family: 'Inter', sans-serif;
}

.dashboard-sidebar {
    position: sticky;
    top: 100px;
}

.performance-section h2 {
    font-size: 18px;
    font-weight: 600;
    color: var(--text-primary);
    margin: 0 0 16px 0;
    font-family: 'Inter', sans-serif;
}

.performance-item {
    margin-bottom: 16px;
}

.performance-item:last-child {
    margin-bottom: 0;
}

.performance-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 4px;
}

.performance-label {
    font-size: 14px;
    color: var(--text-secondary);
    font-family: 'Inter', sans-serif;
}

.performance-value {
    font-size: 14px;
    font-weight: 600;
    color: var(--text-primary);
    font-family: 'Inter', sans-serif;
}

.progress-bar {
    height: 8px;
    background: var(--border-color);
    border-radius: 4px;
    overflow: hidden;
}

.progress-fill {
    height: 100%;
    border-radius: 4px;
    transition: width 0.3s;
}

/* Modal */
.modal {
    display: none;
    position: fixed;
    z-index: 1000;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.5);
    overflow-y: auto;
}

.modal-content {
    background: var(--white);
    margin: 40px auto;
    padding: 24px;
    border-radius: 16px;
    max-width: 500px;
    width: 90%;
    position: relative;
}

.close-modal {
    position: absolute;
    right: 16px;
    top: 16px;
    font-size: 28px;
    font-weight: bold;
    color: var(--text-secondary);
    cursor: pointer;
}

.close-modal:hover {
    color: var(--text-primary);
}

#bookDetailContent img {
    width: 180px;
    height: 240px;
    object-fit: cover;
    border-radius: 12px;
    margin: 0 auto 16px;
    display: block;
}

#bookDetailContent h3 {
    font-size: 20px;
    font-weight: bold;
    margin: 0 0 8px 0;
    font-family: 'Inter', sans-serif;
}

#bookDetailContent .chip {
    display: inline-block;
    padding: 4px 12px;
    background: var(--border-color);
    border-radius: 16px;
    font-size: 12px;
    margin-right: 8px;
    font-family: 'Inter', sans-serif;
}

#bookDetailContent .detail-section {
    margin-top: 16px;
}

#bookDetailContent .detail-section h4 {
    font-size: 15px;
    font-weight: bold;
    margin: 0 0 4px 0;
    font-family: 'Inter', sans-serif;
}

#bookDetailContent .detail-section p {
    font-size: 14px;
    color: var(--text-secondary);
    margin: 0;
    font-family: 'Inter', sans-serif;
}

/* Responsive */
@media (max-width: 1024px) {
    .dashboard-main {
        grid-template-columns: 1fr;
    }

    .dashboard-sidebar {
        position: static;
    }
}

@media (max-width: 768px) {
    .dashboard-page {
        padding: 16px 12px;
    }

    .dashboard-header {
        flex-direction: column;
        gap: 16px;
    }

    .header-text h1 {
        font-size: 22px;
    }

    .stats-grid {
        grid-template-columns: 1fr;
        gap: 12px;
    }

    .stat-card {
        padding: 14px;
    }

    .book-item {
        flex-direction: row;
        padding: 12px;
        gap: 12px;
    }

    .book-cover {
        width: 80px;
        height: 100px;
        flex-shrink: 0;
    }

    .book-details {
        flex: 1;
        min-width: 0;
        gap: 12px;
    }

    .book-header {
        flex-direction: column;
        align-items: flex-start;
        gap: 8px;
    }

    .book-status {
        align-self: flex-start;
    }

    .book-stats {
        grid-template-columns: repeat(2, 1fr);
        gap: 12px;
    }

    .book-stat .stat-label {
        font-size: 12px;
    }

    .book-stat .stat-value {
        font-size: 14px;
    }

    .book-actions {
        flex-wrap: wrap;
        gap: 8px;
        width: 100%;
    }

    .btn-action {
        padding: 6px 10px;
        font-size: 13px;
        flex: 1 1 auto;
        min-width: fit-content;
    }

    .chart-container {
        height: 120px;
    }

    .chart-bar {
        min-height: 10px;
    }
}
</style>
@endpush

@push('scripts')
<script>
const baseUrl = "https://takaafrica.com/pharmaRh/taka";

// Period change handler
document.getElementById('periodSelect').addEventListener('change', function() {
    const period = this.value;
    window.location.href = '{{ route("dashboard") }}?period=' + period;
});

// Show book detail modal
function showBookDetail(book) {
    const modal = document.getElementById('bookDetailModal');
    const content = document.getElementById('bookDetailContent');
    
    let coverUrl = '';
    if (book.cover_path) {
        coverUrl = book.cover_path.startsWith('http') 
            ? book.cover_path 
            : baseUrl + '/' + book.cover_path;
    }
    
    content.innerHTML = `
        ${coverUrl ? `<img src="${coverUrl}" alt="${book.title || ''}">` : ''}
        <h3>${book.title || ''}</h3>
        <div style="text-align: center; margin: 16px 0;">
            ${book.genre ? `<span class="chip">${book.genre}</span>` : ''}
            ${book.language ? `<span class="chip">${book.language}</span>` : ''}
            ${book.plan ? `<span class="chip">${book.plan}</span>` : ''}
        </div>
        ${book.summary ? `
            <div class="detail-section">
                <h4>Résumé</h4>
                <p>${book.summary}</p>
            </div>
        ` : ''}
        ${book.author_bio ? `
            <div class="detail-section">
                <h4>Bio de l'auteur</h4>
                <p>${book.author_bio}</p>
            </div>
        ` : ''}
        ${book.author_links ? `
            <div class="detail-section">
                <h4>Liens auteur</h4>
                <p style="color: #3B82F6;">${book.author_links}</p>
            </div>
        ` : ''}
        ${book.excerpt ? `
            <div class="detail-section">
                <h4>Extrait</h4>
                <p style="font-style: italic;">${book.excerpt}</p>
            </div>
        ` : ''}
        ${book.quote ? `
            <div class="detail-section">
                <h4>Citation</h4>
                <p style="font-style: italic;">« ${book.quote} »</p>
            </div>
        ` : ''}
        <div style="text-align: right; margin-top: 24px;">
            <button class="btn-action btn-edit" onclick="closeBookDetail()">Fermer</button>
        </div>
    `;
    
    modal.style.display = 'block';
}

function closeBookDetail() {
    document.getElementById('bookDetailModal').style.display = 'none';
}

// Edit book
function editBook(book) {
    // Store book data in sessionStorage and redirect to publish page
    sessionStorage.setItem('bookToEdit', JSON.stringify(book));
    window.location.href = '{{ route("publish") }}';
}

// Download book
function downloadBook(filePath) {
    if (!filePath) {
        alert('Aucun fichier disponible pour ce livre.');
        return;
    }
    
    const url = filePath.startsWith('http') ? filePath : baseUrl + '/' + filePath;
    window.open(url, '_blank');
}

// Delete book
function deleteBook(bookId) {
    if (!confirm('Supprimer ce livre ?\n\nCette action est irréversible.')) {
        return;
    }
    
    fetch('{{ route("dashboard.delete") }}', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({
            book_id: bookId
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            // Remove book item from DOM
            document.querySelector(`.book-item[data-book-id="${bookId}"]`).remove();
            
            // Show success message
            alert('Livre supprimé.');
            
            // Reload page if no books left
            if (document.querySelectorAll('.book-item').length === 0) {
                window.location.reload();
            }
        } else {
            alert('Erreur: ' + (data.error || 'Suppression impossible.'));
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('Erreur lors de la suppression.');
    });
}

// Close modal when clicking outside
window.onclick = function(event) {
    const modal = document.getElementById('bookDetailModal');
    if (event.target == modal) {
        closeBookDetail();
    }
}
</script>
@endpush

@endsection
@else
@section('content')
<div class="restricted-page" style="min-height: calc(100vh - 200px); display: flex; align-items: center; justify-content: center; background: #F9FAFB;">
    <div style="text-align: center; padding: 40px 20px;">
        <h1 style="font-size: 22px; font-weight: 700; color: #111827; margin-bottom: 16px; font-family: 'Inter', sans-serif;">Accès restreint</h1>
        <p style="font-size: 16px; color: #6B7280; margin-bottom: 24px; font-family: 'Inter', sans-serif;">Vous devez être connecté pour accéder au tableau de bord auteur.</p>
        <a href="{{ route('login') }}" class="btn-new-book" style="display: inline-flex;">Se connecter</a>
    </div>
</div>
@endsection
@endauth
