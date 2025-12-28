@extends('layouts.app')

@section('title', 'Programme d\'affiliation - TAKA')

@auth
@section('content')
<div class="affiliate-page">
    <div class="affiliate-container">
        <!-- Header -->
        <div class="affiliate-header">
            <h1>Programme d'affiliation TAKA</h1>
            <p>Gagnez de l'argent en recommandant TAKA à votre audience</p>
        </div>

        <!-- Stats Cards -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon stat-icon-blue">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                        <circle cx="12" cy="12" r="3"></circle>
                    </svg>
                </div>
                <div class="stat-info">
                    <div class="stat-title">Clics totaux</div>
                    <div class="stat-value" id="totalClicks">{{ $stats['totalClicks'] ?? 0 }}</div>
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
                    <div class="stat-title">Conversions</div>
                    <div class="stat-value" id="conversions">{{ $stats['conversions'] ?? 0 }}</div>
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
                    <div class="stat-title">Gains totaux</div>
                    <div class="stat-value" id="totalEarnings">{{ number_format($stats['totalEarnings'] ?? 0, 0, ',', ' ') }} FCFA</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon stat-icon-yellow">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <circle cx="12" cy="12" r="10"></circle>
                        <polyline points="12 6 12 12 16 14"></polyline>
                    </svg>
                </div>
                <div class="stat-info">
                    <div class="stat-title">En attente</div>
                    <div class="stat-value" id="pendingPayment">{{ number_format($stats['totalEarnings'] ?? 0, 0, ',', ' ') }} FCFA</div>
                </div>
            </div>
        </div>

        <!-- Main Content -->
        <div class="affiliate-main">
            <div class="affiliate-content">
                <!-- Affiliate Links Section -->
                <div class="links-section">
                    <div class="section-header">
                        <h2>Mes liens d'affiliation</h2>
                        <button class="btn-new-link" id="createLinkBtn" onclick="showCreateLinkDialog()">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <line x1="12" y1="5" x2="12" y2="19"></line>
                                <line x1="5" y1="12" x2="19" y2="12"></line>
                            </svg>
                            Créer un nouveau lien
                        </button>
                    </div>
                    <div class="links-list" id="linksList">
                        @if(count($affiliateLinks ?? []) > 0)
                            @foreach($affiliateLinks as $link)
                                <div class="link-item" data-link-id="{{ $link['id'] ?? '' }}">
                                    <div class="link-header">
                                        <div class="link-title-section">
                                            <h3 class="link-title">{{ $link['title'] ?? '' }}</h3>
                                            <div class="link-url-container">
                                                <div class="link-url" id="linkUrl{{ $link['id'] }}">{{ $link['url'] ?? '' }}</div>
                                                <div class="link-actions">
                                                    <button class="btn-link-action" onclick="copyLink('{{ $link['url'] ?? '' }}', {{ $link['id'] ?? 0 }})" title="Copier">
                                                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" id="copyIcon{{ $link['id'] }}">
                                                            <rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect>
                                                            <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path>
                                                        </svg>
                                                    </button>
                                                    <button class="btn-link-action" onclick="openLink('{{ $link['url'] ?? '' }}')" title="Ouvrir">
                                                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                            <path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"></path>
                                                            <polyline points="15 3 21 3 21 9"></polyline>
                                                            <line x1="10" y1="14" x2="21" y2="3"></line>
                                                        </svg>
                                                    </button>
                                                    <button class="btn-link-action" onclick="showEditLinkDialog({{ json_encode($link) }})" title="Modifier">
                                                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                            <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                                                            <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
                                                        </svg>
                                                    </button>
                                                    <button class="btn-link-action btn-delete" onclick="showDeleteLinkDialog({{ $link['id'] ?? 0 }}, '{{ $link['title'] ?? '' }}')" title="Supprimer">
                                                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                            <polyline points="3 6 5 6 21 6"></polyline>
                                                            <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
                                                        </svg>
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            @endforeach
                        @else
                            <p class="empty-message">Aucun lien d'affiliation pour le moment.</p>
                        @endif
                    </div>
                </div>

                <!-- Performance Chart -->
                <div class="performance-chart-section">
                    <div class="section-header">
                        <h2>Évolution des gains</h2>
                        <select class="period-select" id="periodSelect">
                            <option value="week">Cette semaine</option>
                            <option value="month" selected>Ce mois</option>
                            <option value="year">Cette année</option>
                        </select>
                    </div>
                    <div class="chart-container">
                        <div class="chart-bars" id="chartBars">
                            @php
                                // Données statiques pour l'instant (comme dans Flutter)
                                $monthlyData = [
                                    ['month' => 'Jan', 'earnings' => 12500],
                                    ['month' => 'Fév', 'earnings' => 18900],
                                    ['month' => 'Mar', 'earnings' => 28900],
                                    ['month' => 'Avr', 'earnings' => 22100],
                                    ['month' => 'Mai', 'earnings' => 31200],
                                    ['month' => 'Jun', 'earnings' => 35600],
                                ];
                                $maxEarnings = collect($monthlyData)->max('earnings');
                            @endphp
                            @foreach($monthlyData as $data)
                                @php
                                    $height = $maxEarnings > 0 ? ($data['earnings'] / $maxEarnings) * 100 : 0;
                                @endphp
                                <div class="chart-bar-wrapper">
                                    <div class="chart-bar" style="height: {{ $height }}%">
                                        <span class="chart-value">{{ round($data['earnings'] / 1000) }}k</span>
                                    </div>
                                    <div class="chart-month">{{ $data['month'] }}</div>
                                </div>
                            @endforeach
                        </div>
                    </div>
                </div>
            </div>

            <!-- Sidebar -->
            <div class="affiliate-sidebar">
                <!-- Commission Structure -->
                <div class="sidebar-card">
                    <h3>Structure des commissions</h3>
                    <div class="commission-item">
                        <span>Achat de livre</span>
                        <span class="commission-value">20% du prix</span>
                    </div>
                </div>

                <!-- Payment Info -->
                <div class="sidebar-card payment-info">
                    <h3>Informations de paiement</h3>
                    <div class="payment-details">
                        <div class="payment-detail">Fréquence: Mensuelle</div>
                        <div class="payment-detail">Seuil minimum: 10.000 FCFA</div>
                        <div class="payment-detail">Méthode: Mobile Money / Virement</div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Create Link Modal -->
<div id="createLinkModal" class="modal">
    <div class="modal-content">
        <span class="close-modal" onclick="closeCreateLinkModal()">&times;</span>
        <h3>Créer un nouveau lien</h3>
        <form id="createLinkForm" onsubmit="handleCreateLink(event)">
            <div class="form-field">
                <label>Titre du lien *</label>
                <input type="text" id="createLinkTitle" class="form-input" required>
            </div>
            <div class="form-field">
                <label>Type de lien *</label>
                <select id="createLinkType" class="form-select" onchange="handleLinkTypeChange('create')">
                    <option value="book">Livre spécifique</option>
                </select>
            </div>
            <div class="form-field" id="createBookField" style="display: block;">
                <label>Sélectionner un livre *</label>
                <select id="createLinkBookId" class="form-select">
                    <option value="">Chargement...</option>
                </select>
            </div>
            <div class="form-actions">
                <button type="button" class="btn-secondary" onclick="closeCreateLinkModal()">Annuler</button>
                <button type="submit" class="btn-primary" id="createLinkSubmitBtn">Ajouter</button>
            </div>
        </form>
    </div>
</div>

<!-- Edit Link Modal -->
<div id="editLinkModal" class="modal">
    <div class="modal-content">
        <span class="close-modal" onclick="closeEditLinkModal()">&times;</span>
        <h3>Modifier le lien</h3>
        <form id="editLinkForm" onsubmit="handleEditLink(event)">
            <input type="hidden" id="editLinkId">
            <div class="form-field">
                <label>Titre du lien *</label>
                <input type="text" id="editLinkTitle" class="form-input" required>
            </div>
            <div class="form-field">
                <label>Type de lien *</label>
                <select id="editLinkType" class="form-select" onchange="handleLinkTypeChange('edit')">
                    <option value="book">Livre spécifique</option>
                </select>
            </div>
            <div class="form-field" id="editBookField" style="display: block;">
                <label>Sélectionner un livre *</label>
                <select id="editLinkBookId" class="form-select">
                    <option value="">Chargement...</option>
                </select>
            </div>
            <div class="form-actions">
                <button type="button" class="btn-secondary" onclick="closeEditLinkModal()">Annuler</button>
                <button type="submit" class="btn-primary" id="editLinkSubmitBtn">Enregistrer</button>
            </div>
        </form>
    </div>
</div>

<!-- Delete Confirmation Modal -->
<div id="deleteLinkModal" class="modal">
    <div class="modal-content modal-small">
        <h3>Supprimer le lien</h3>
        <p>Voulez-vous vraiment supprimer ce lien d'affiliation ?</p>
        <div class="form-actions">
            <button type="button" class="btn-secondary" onclick="closeDeleteLinkModal()">Annuler</button>
            <button type="button" class="btn-danger" id="confirmDeleteBtn" onclick="confirmDeleteLink()">Supprimer</button>
        </div>
    </div>
</div>

@push('styles')
<style>
:root {
    --affiliate-bg: #F9FAFB;
    --white: #FFFFFF;
    --text-primary: #111827;
    --text-secondary: #6B7280;
    --border-color: #E5E7EB;
    --orange: #F97316;
    --blue: #3B82F6;
    --green: #10B981;
    --yellow: #FBBF24;
    --red: #F87171;
    --shadow: 0 1px 8px rgba(0, 0, 0, 0.04);
}

.affiliate-page {
    min-height: calc(100vh - 200px);
    background: var(--affiliate-bg);
    padding: 32px 20px;
}

.affiliate-container {
    max-width: 1400px;
    margin: 0 auto;
}

.affiliate-header {
    margin-bottom: 32px;
}

.affiliate-header h1 {
    font-size: 32px;
    font-weight: 700;
    color: var(--text-primary);
    margin: 0 0 8px 0;
    font-family: 'Inter', sans-serif;
}

.affiliate-header p {
    font-size: 16px;
    color: var(--text-secondary);
    margin: 0;
    font-family: 'Inter', sans-serif;
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

.stat-icon-yellow {
    background: rgba(251, 191, 36, 0.1);
    color: var(--yellow);
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
    font-size: 20px;
    font-weight: 700;
    color: var(--text-primary);
    line-height: 1.2;
    font-family: 'Inter', sans-serif;
}

.affiliate-main {
    display: grid;
    grid-template-columns: 1fr 320px;
    gap: 32px;
    align-items: start;
}

.affiliate-content {
    display: flex;
    flex-direction: column;
    gap: 32px;
}

.links-section,
.performance-chart-section {
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

.btn-new-link {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 8px 16px;
    background: var(--orange);
    color: white;
    border: none;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 500;
    font-family: 'Inter', sans-serif;
    cursor: pointer;
    transition: background 0.2s;
}

.btn-new-link:hover {
    background: #EA580C;
}

.links-list {
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

.link-item {
    padding: 16px;
    border: 1px solid var(--border-color);
    border-radius: 8px;
}

.link-title {
    font-size: 16px;
    font-weight: 600;
    color: var(--text-primary);
    margin: 0 0 8px 0;
    font-family: 'Inter', sans-serif;
}

.link-url-container {
    background: var(--affiliate-bg);
    border-radius: 4px;
    padding: 8px;
    display: flex;
    align-items: center;
    gap: 8px;
}

.link-url {
    flex: 1;
    font-size: 14px;
    color: var(--text-secondary);
    font-family: 'monospace';
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.link-actions {
    display: flex;
    gap: 4px;
}

.btn-link-action {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 32px;
    height: 32px;
    padding: 0;
    border: none;
    background: transparent;
    color: var(--orange);
    cursor: pointer;
    border-radius: 4px;
    transition: background 0.2s;
}

.btn-link-action:hover {
    background: rgba(249, 115, 22, 0.1);
}

.btn-link-action.btn-delete {
    color: var(--red);
}

.btn-link-action.btn-delete:hover {
    background: rgba(248, 113, 113, 0.1);
}

.btn-link-action svg {
    width: 16px;
    height: 16px;
}

.performance-chart-section .chart-container {
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

.affiliate-sidebar {
    position: sticky;
    top: 100px;
    display: flex;
    flex-direction: column;
    gap: 24px;
}

.sidebar-card {
    background: var(--white);
    padding: 24px;
    border-radius: 12px;
    box-shadow: var(--shadow);
}

.sidebar-card h3 {
    font-size: 18px;
    font-weight: 600;
    color: var(--text-primary);
    margin: 0 0 16px 0;
    font-family: 'Inter', sans-serif;
}

.commission-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-size: 14px;
    font-family: 'Inter', sans-serif;
}

.commission-item:first-child {
    margin-bottom: 0;
}

.commission-value {
    font-weight: 600;
    color: var(--text-primary);
    font-family: 'Inter', sans-serif;
}

.payment-info {
    background: #FFF7ED;
}

.payment-details {
    display: flex;
    flex-direction: column;
    gap: 8px;
}

.payment-detail {
    font-size: 14px;
    color: var(--text-primary);
    font-family: 'Inter', sans-serif;
}

/* Modal Styles */
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

.modal-small {
    max-width: 400px;
}

.modal-content h3 {
    font-size: 18px;
    font-weight: 600;
    color: var(--text-primary);
    margin: 0 0 24px 0;
    font-family: 'Inter', sans-serif;
}

.close-modal {
    position: absolute;
    right: 16px;
    top: 16px;
    font-size: 28px;
    font-weight: bold;
    color: var(--text-secondary);
    cursor: pointer;
    line-height: 1;
}

.close-modal:hover {
    color: var(--text-primary);
}

.form-field {
    margin-bottom: 16px;
}

.form-field label {
    display: block;
    font-size: 14px;
    color: var(--text-primary);
    margin-bottom: 8px;
    font-family: 'Inter', sans-serif;
}

.form-input,
.form-select {
    width: 100%;
    padding: 10px 12px;
    border: 1px solid var(--border-color);
    border-radius: 8px;
    font-size: 14px;
    font-family: 'Inter', sans-serif;
    background: var(--white);
    color: var(--text-primary);
}

.form-input:focus,
.form-select:focus {
    outline: none;
    border-color: var(--orange);
}

.form-actions {
    display: flex;
    gap: 12px;
    justify-content: flex-end;
    margin-top: 24px;
}

.btn-secondary {
    padding: 10px 20px;
    border: 1px solid var(--border-color);
    border-radius: 8px;
    background: var(--white);
    color: var(--text-primary);
    font-size: 14px;
    font-weight: 500;
    font-family: 'Inter', sans-serif;
    cursor: pointer;
    transition: background 0.2s;
}

.btn-secondary:hover {
    background: var(--affiliate-bg);
}

.btn-primary {
    padding: 10px 20px;
    border: none;
    border-radius: 8px;
    background: var(--orange);
    color: white;
    font-size: 14px;
    font-weight: 500;
    font-family: 'Inter', sans-serif;
    cursor: pointer;
    transition: background 0.2s;
}

.btn-primary:hover {
    background: #EA580C;
}

.btn-danger {
    padding: 10px 20px;
    border: none;
    border-radius: 8px;
    background: var(--red);
    color: white;
    font-size: 14px;
    font-weight: 500;
    font-family: 'Inter', sans-serif;
    cursor: pointer;
    transition: background 0.2s;
}

.btn-danger:hover {
    background: #DC2626;
}

.modal-content p {
    font-size: 14px;
    color: var(--text-secondary);
    margin: 0 0 24px 0;
    font-family: 'Inter', sans-serif;
}

/* Responsive */
@media (max-width: 1024px) {
    .affiliate-main {
        grid-template-columns: 1fr;
    }

    .affiliate-sidebar {
        position: static;
    }
}

@media (max-width: 768px) {
    .affiliate-page {
        padding: 16px 12px;
    }

    .affiliate-header h1 {
        font-size: 22px;
    }

    .stats-grid {
        grid-template-columns: 1fr;
        gap: 12px;
    }

    .section-header {
        flex-direction: column;
        align-items: flex-start;
        gap: 16px;
    }

    .btn-new-link {
        width: 100%;
        justify-content: center;
    }
}
</style>
@endpush

@push('scripts')
<script>
const baseUrl = "https://takaafrica.com/pharmaRh/taka";
const userId = {{ auth()->user()->api_id ?? auth()->id() }};
let authorBooks = [];
let currentDeleteLinkId = null;
let copiedLinkId = null;

// Initialize
document.addEventListener('DOMContentLoaded', function() {
    loadAuthorBooks();
});

// Load author books
async function loadAuthorBooks() {
    try {
        const response = await fetch('{{ route("affiliate.author-books") }}');
        const data = await response.json();
        if (data.success && data.books) {
            authorBooks = data.books;
            populateBookSelects();
        }
    } catch (error) {
        console.error('Error loading author books:', error);
    }
}

function populateBookSelects() {
    const createSelect = document.getElementById('createLinkBookId');
    const editSelect = document.getElementById('editLinkBookId');
    
    if (createSelect) {
        createSelect.innerHTML = '<option value="">Sélectionner un livre</option>';
        authorBooks.forEach(book => {
            const option = document.createElement('option');
            option.value = book.id;
            option.textContent = book.title;
            createSelect.appendChild(option);
        });
    }
    
    if (editSelect) {
        editSelect.innerHTML = '<option value="">Sélectionner un livre</option>';
        authorBooks.forEach(book => {
            const option = document.createElement('option');
            option.value = book.id;
            option.textContent = book.title;
            editSelect.appendChild(option);
        });
    }
}

// Show Create Link Modal
function showCreateLinkDialog() {
    document.getElementById('createLinkModal').style.display = 'block';
    document.getElementById('createLinkForm').reset();
    document.getElementById('createLinkType').value = 'book';
    handleLinkTypeChange('create');
}

function closeCreateLinkModal() {
    document.getElementById('createLinkModal').style.display = 'none';
}

// Show Edit Link Modal
function showEditLinkDialog(link) {
    document.getElementById('editLinkModal').style.display = 'block';
    document.getElementById('editLinkId').value = link.id;
    document.getElementById('editLinkTitle').value = link.title || '';
    
    // L'API ne retourne pas type et book_id, on les déduit depuis l'URL
    // Format livre: https://takaafrica.com/book/{book_id}?ref=...
    // Format général: https://takaafrica.com?ref=...
    let linkType = 'book'; // Par défaut (seul type disponible)
    let bookId = null;
    
    if (link.url) {
        const bookMatch = link.url.match(/\/book\/(\d+)/);
        if (bookMatch && bookMatch[1]) {
            linkType = 'book';
            bookId = bookMatch[1];
        }
    }
    
    document.getElementById('editLinkType').value = linkType;
    handleLinkTypeChange('edit');
    
    // Set book ID si c'est un lien livre
    if (linkType === 'book' && bookId) {
        setTimeout(() => {
            document.getElementById('editLinkBookId').value = bookId;
        }, 100);
    }
}

function closeEditLinkModal() {
    document.getElementById('editLinkModal').style.display = 'none';
}

// Show Delete Link Modal
function showDeleteLinkDialog(linkId, linkTitle) {
    currentDeleteLinkId = linkId;
    document.getElementById('deleteLinkModal').style.display = 'block';
}

function closeDeleteLinkModal() {
    document.getElementById('deleteLinkModal').style.display = 'none';
    currentDeleteLinkId = null;
}

// Handle link type change
function handleLinkTypeChange(mode) {
    const prefix = mode === 'create' ? 'create' : 'edit';
    const type = document.getElementById(prefix + 'LinkType').value;
    const bookField = document.getElementById(prefix + 'BookField');
    
    if (type === 'book') {
        bookField.style.display = 'block';
        document.getElementById(prefix + 'LinkBookId').required = true;
    } else {
        bookField.style.display = 'none';
        document.getElementById(prefix + 'LinkBookId').required = false;
    }
}

// Handle Create Link
async function handleCreateLink(event) {
    event.preventDefault();
    
    const title = document.getElementById('createLinkTitle').value.trim();
    const type = document.getElementById('createLinkType').value;
    const bookId = document.getElementById('createLinkBookId').value;
    
    if (!title) {
        alert('Veuillez remplir le titre du lien.');
        return;
    }
    
    if (type === 'book' && !bookId) {
        alert('Veuillez sélectionner un livre.');
        return;
    }
    
    const submitBtn = document.getElementById('createLinkSubmitBtn');
    submitBtn.disabled = true;
    submitBtn.textContent = 'Création...';
    
    try {
        const response = await fetch('{{ route("affiliate.create") }}', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content
            },
            body: JSON.stringify({
                title: title,
                type: type,
                book_id: type === 'book' ? parseInt(bookId) : null
            })
        });
        
        const data = await response.json();
        
        if (data.success) {
            alert('Lien créé avec succès');
            closeCreateLinkModal();
            window.location.reload();
        } else {
            alert(data.error || 'Erreur lors de la création');
        }
    } catch (error) {
        console.error('Error:', error);
        alert('Erreur réseau: ' + error.message);
    } finally {
        submitBtn.disabled = false;
        submitBtn.textContent = 'Ajouter';
    }
}

// Handle Edit Link
async function handleEditLink(event) {
    event.preventDefault();
    
    const linkId = document.getElementById('editLinkId').value;
    const title = document.getElementById('editLinkTitle').value.trim();
    const type = document.getElementById('editLinkType').value;
    const bookId = document.getElementById('editLinkBookId').value;
    
    if (!title) {
        alert('Veuillez remplir le titre du lien.');
        return;
    }
    
    if (type === 'book' && !bookId) {
        alert('Veuillez sélectionner un livre.');
        return;
    }
    
    const submitBtn = document.getElementById('editLinkSubmitBtn');
    submitBtn.disabled = true;
    submitBtn.textContent = 'Enregistrement...';
    
    try {
        const response = await fetch('{{ route("affiliate.edit") }}', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content
            },
            body: JSON.stringify({
                link_id: parseInt(linkId),
                title: title,
                type: type,
                book_id: type === 'book' ? parseInt(bookId) : null
            })
        });
        
        const data = await response.json();
        
        if (data.success) {
            alert('Lien modifié avec succès');
            closeEditLinkModal();
            window.location.reload();
        } else {
            alert(data.error || 'Erreur lors de la modification');
        }
    } catch (error) {
        console.error('Error:', error);
        alert('Erreur réseau: ' + error.message);
    } finally {
        submitBtn.disabled = false;
        submitBtn.textContent = 'Enregistrer';
    }
}

// Confirm Delete Link
async function confirmDeleteLink() {
    if (!currentDeleteLinkId) return;
    
    const btn = document.getElementById('confirmDeleteBtn');
    btn.disabled = true;
    btn.textContent = 'Suppression...';
    
    try {
        const response = await fetch('{{ route("affiliate.delete") }}', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content
            },
            body: JSON.stringify({
                link_id: currentDeleteLinkId
            })
        });
        
        const data = await response.json();
        
        if (data.success) {
            alert('Lien supprimé avec succès');
            closeDeleteLinkModal();
            window.location.reload();
        } else {
            alert(data.error || 'Erreur lors de la suppression');
        }
    } catch (error) {
        console.error('Error:', error);
        alert('Erreur réseau: ' + error.message);
    } finally {
        btn.disabled = false;
        btn.textContent = 'Supprimer';
    }
}

// Copy Link
async function copyLink(url, linkId) {
    try {
        await navigator.clipboard.writeText(url);
        
        // Update icon to checkmark
        const icon = document.getElementById('copyIcon' + linkId);
        if (icon) {
            icon.innerHTML = '<path d="M20 6L9 17l-5-5"></path>';
            icon.setAttribute('stroke', '#10B981');
        }
        
        copiedLinkId = linkId;
        
        // Show notification
        showNotification('Lien copié dans le presse-papiers');
        
        // Reset icon after 2 seconds
        setTimeout(() => {
            if (copiedLinkId === linkId && icon) {
                icon.innerHTML = '<rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path>';
                icon.setAttribute('stroke', 'currentColor');
            }
            copiedLinkId = null;
        }, 2000);
    } catch (error) {
        console.error('Error copying link:', error);
        alert('Erreur lors de la copie');
    }
}

// Open Link
function openLink(url) {
    window.open(url, '_blank');
}

// Show Notification
function showNotification(message) {
    // Simple notification (you can enhance this with a toast library)
    const notification = document.createElement('div');
    notification.style.cssText = 'position: fixed; top: 20px; right: 20px; background: #10B981; color: white; padding: 12px 24px; border-radius: 8px; z-index: 10000; font-family: Inter, sans-serif;';
    notification.textContent = message;
    document.body.appendChild(notification);
    
    setTimeout(() => {
        notification.remove();
    }, 3000);
}

// Close modals when clicking outside
window.onclick = function(event) {
    const createModal = document.getElementById('createLinkModal');
    const editModal = document.getElementById('editLinkModal');
    const deleteModal = document.getElementById('deleteLinkModal');
    
    if (event.target == createModal) {
        closeCreateLinkModal();
    }
    if (event.target == editModal) {
        closeEditLinkModal();
    }
    if (event.target == deleteModal) {
        closeDeleteLinkModal();
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
        <p style="font-size: 16px; color: #6B7280; margin-bottom: 24px; font-family: 'Inter', sans-serif;">Vous devez être connecté pour accéder au programme d'affiliation.</p>
        <a href="{{ route('login') }}" class="btn-new-link" style="display: inline-flex; text-decoration: none;">Se connecter</a>
    </div>
</div>
@endsection
@endauth
