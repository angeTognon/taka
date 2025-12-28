@extends('layouts.app')

@section('title', 'Administration TAKA')

@section('content')
<div class="admin-page">
    <div class="admin-container">
        <div class="admin-header">
            <h1 class="admin-title">Administration TAKA</h1>
            <form method="POST" action="{{ route('admin.logout') }}" style="display: inline;">
                @csrf
                <button type="submit" class="btn-logout">Déconnexion</button>
            </form>
        </div>
        
        <!-- Loading State -->
        <div id="loadingState" class="loading-container">
            <div class="spinner"></div>
            <p>Chargement...</p>
        </div>

        <!-- Empty State -->
        <div id="emptyState" class="empty-state" style="display: none;">
            <p>Aucun livre à afficher.</p>
        </div>

        <!-- Content -->
        <div id="adminContent" style="display: none;">
            <!-- Stats Section -->
            <div class="stats-section">
                <div class="stats-card">
                    <div class="stats-grid" id="statsGrid">
                        <!-- Stats will be populated by JavaScript -->
                    </div>
                </div>
            </div>

            <!-- Books Grid -->
            <div class="books-section">
                <div class="books-grid" id="booksGrid">
                    <!-- Books will be populated by JavaScript -->
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Book Details Modal -->
<div id="bookDetailsModal" class="modal" style="display: none;">
    <div class="modal-content">
        <div class="modal-header">
            <span class="modal-icon">ℹ️</span>
            <h2 id="modalTitle"></h2>
        </div>
        <div class="modal-body">
            <p><strong>Nom du publieur :</strong> <span id="modalAuthorName"></span></p>
            <p><strong>Email :</strong> <span id="modalAuthorEmail"></span></p>
            <p><strong>Inscrit le :</strong> <span id="modalAuthorCreatedAt"></span></p>
            <p><strong>Prix :</strong> <span id="modalPrice" class="modal-price"></span></p>
            <div class="modal-summary">
                <strong>Résumé :</strong>
                <p id="modalSummary"></p>
            </div>
        </div>
        <div class="modal-footer">
            <button class="btn-modal-close" onclick="closeBookDetailsModal()">Fermer</button>
            <a id="modalViewBook" href="#" target="_blank" class="btn-modal-view">
                <span>👁️</span> Voir le livre
            </a>
        </div>
    </div>
</div>

@push('styles')
<style>
.admin-page,
.admin-page * {
    box-sizing: border-box;
}

.admin-page {
    min-height: 100vh;
    background: #F9FAFB;
    padding: 20px;
    overflow-x: hidden;
    width: 100%;
    max-width: 100vw;
}

.admin-container {
    max-width: 1400px;
    margin: 0 auto;
    width: 100%;
    box-sizing: border-box;
}

.admin-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
    flex-wrap: wrap;
    gap: 16px;
}

.admin-title {
    font-size: 22px;
    font-weight: 700;
    color: #F97316;
    margin: 0;
    font-family: 'Inter', sans-serif;
}

.btn-logout {
    background: #6B7280;
    color: white;
    border: none;
    padding: 10px 20px;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 500;
    cursor: pointer;
    transition: background 0.2s;
    font-family: 'Inter', sans-serif;
}

.btn-logout:hover {
    background: #4B5563;
}

.loading-container {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 60px 20px;
}

.spinner {
    width: 40px;
    height: 40px;
    border: 4px solid #F3F4F6;
    border-top-color: #F97316;
    border-radius: 50%;
    animation: spin 1s linear infinite;
}

@keyframes spin {
    to { transform: rotate(360deg); }
}

.empty-state {
    text-align: center;
    padding: 60px 20px;
    color: #6B7280;
}

/* Stats Section */
.stats-section {
    margin-bottom: 20px;
    width: 100%;
    box-sizing: border-box;
}

.stats-card {
    background: white;
    border-radius: 12px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.06);
    padding: 18px 24px;
    width: 100%;
    box-sizing: border-box;
    overflow: hidden;
}

.stats-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 16px;
    align-items: center;
    width: 100%;
    box-sizing: border-box;
}

.stat-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    text-align: center;
}

.stat-icon {
    font-size: 48px;
    margin-bottom: 4px;
}

.stat-value {
    font-size: 20px;
    font-weight: 700;
    font-family: 'Inter', sans-serif;
    margin-bottom: 4px;
}

.stat-label {
    font-size: 13px;
    color: #6B7280;
    font-family: 'Inter', sans-serif;
}

.stat-item.blue .stat-value { color: #2563EB; }
.stat-item.orange .stat-value { color: #F97316; }
.stat-item.amber .stat-value { color: #F59E0B; }
.stat-item.green .stat-value { color: #10B981; }

/* Books Section */
.books-section {
    margin-top: 20px;
    width: 100%;
    box-sizing: border-box;
}

.books-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 16px;
    width: 100%;
    box-sizing: border-box;
}

.book-card {
    background: white;
    border-radius: 12px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.06);
    padding: 12px;
    display: flex;
    flex-direction: column;
    width: 100%;
    box-sizing: border-box;
    min-width: 0;
    overflow: hidden;
}

.book-card-mobile {
    flex-direction: row;
    gap: 12px;
    align-items: flex-start;
}

.book-cover {
    width: 100%;
    height: 200px;
    object-fit: cover;
    border-radius: 8px;
    background: #E5E7EB;
    margin-bottom: 8px;
}

.book-card-mobile .book-cover {
    width: 80px;
    height: 120px;
    margin-bottom: 0;
    flex-shrink: 0;
    object-fit: cover;
}

.book-content {
    flex: 1;
    display: flex;
    flex-direction: column;
    min-width: 0;
    width: 100%;
}

.book-title {
    font-size: 16px;
    font-weight: 700;
    font-family: 'Inter', sans-serif;
    color: #111827;
    margin-bottom: 4px;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
    word-wrap: break-word;
    max-width: 100%;
}

.book-author {
    font-size: 13px;
    color: #374151;
    margin-bottom: 4px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.book-genre {
    font-size: 12px;
    color: #6B7280;
    margin-bottom: 4px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.book-language {
    font-size: 12px;
    color: #6B7280;
    margin-bottom: 4px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.book-status {
    font-size: 12px;
    font-family: 'Inter', sans-serif;
    margin-bottom: 4px;
}

.book-status.validated {
    color: #10B981;
}

.book-status.pending {
    color: #F59E0B;
}

.book-summary {
    font-size: 12px;
    color: #374151;
    margin-bottom: 8px;
    flex: 1;
    display: -webkit-box;
    -webkit-line-clamp: 4;
    -webkit-box-orient: vertical;
    overflow: hidden;
}

.book-price {
    font-size: 15px;
    font-weight: 700;
    color: #F97316;
    margin-bottom: 8px;
}

.book-actions {
    display: flex;
    gap: 8px;
    margin-top: auto;
    width: 100%;
    flex-wrap: wrap;
}

.book-actions-mobile {
    justify-content: space-evenly;
}

.btn-validate {
    background: #F97316;
    color: white;
    border: none;
    padding: 8px 16px;
    border-radius: 8px;
    font-size: 13px;
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 6px;
    transition: background 0.2s;
    flex-shrink: 1;
    min-width: 0;
}

.btn-validate:hover {
    background: #EA580C;
}

.btn-validate:disabled {
    opacity: 0.6;
    cursor: not-allowed;
}

.btn-details {
    background: #10B981;
    color: white;
    border: none;
    padding: 8px 16px;
    border-radius: 8px;
    font-size: 13px;
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 6px;
    transition: background 0.2s;
    flex-shrink: 1;
    min-width: 0;
}

.btn-details:hover {
    background: #059669;
}

.btn-details-mobile {
    padding: 8px 12px;
    font-size: 11px;
}

.btn-details-icon {
    padding: 8px;
    font-size: 12px;
    min-width: 32px;
}

.btn-validate-mobile {
    flex: 1;
    padding: 8px 12px;
    font-size: 11px;
}

.validating-spinner {
    width: 20px;
    height: 20px;
    border: 2px solid #ffffff;
    border-top-color: transparent;
    border-radius: 50%;
    animation: spin 1s linear infinite;
}

/* Modal */
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
}

.modal-content {
    background: white;
    border-radius: 16px;
    padding: 20px;
    max-width: 600px;
    width: 90%;
    max-height: 90vh;
    overflow-y: auto;
    box-sizing: border-box;
}

.modal-header {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-bottom: 12px;
}

.modal-icon {
    font-size: 28px;
}

.modal-header h2 {
    font-size: 18px;
    font-weight: 700;
    font-family: 'Inter', sans-serif;
    flex: 1;
}

.modal-body {
    margin-bottom: 18px;
}

.modal-body p {
    font-size: 14px;
    margin-bottom: 8px;
    color: #374151;
}

.modal-body strong {
    font-weight: 600;
    font-family: 'Inter', sans-serif;
}

.modal-price {
    color: #F97316;
    font-weight: 700;
}

.modal-summary {
    margin-top: 12px;
}

.modal-summary strong {
    display: block;
    margin-bottom: 8px;
}

.modal-summary p {
    font-size: 14px;
    line-height: 1.5;
    color: #374151;
}

.modal-footer {
    display: flex;
    gap: 12px;
    justify-content: center;
}

.btn-modal-close {
    background: #6B7280;
    color: white;
    border: none;
    padding: 10px 20px;
    border-radius: 8px;
    font-size: 14px;
    cursor: pointer;
    transition: background 0.2s;
}

.btn-modal-close:hover {
    background: #4B5563;
}

.btn-modal-view {
    background: #10B981;
    color: white;
    border: none;
    padding: 10px 20px;
    border-radius: 8px;
    font-size: 14px;
    text-decoration: none;
    display: flex;
    align-items: center;
    gap: 8px;
    transition: background 0.2s;
}

.btn-modal-view:hover {
    background: #059669;
}

/* Responsive */
@media (max-width: 768px) {
    .admin-page {
        padding: 10px;
        overflow-x: hidden;
    }
    
    .admin-container {
        padding: 0;
    }

    .admin-header {
        flex-direction: column;
        align-items: stretch;
        margin-bottom: 15px;
    }

    .admin-title {
        font-size: 18px;
        text-align: center;
        margin-bottom: 12px;
    }

    .btn-logout {
        width: 100%;
    }

    .stats-card {
        padding: 12px 16px;
    }

    .stats-grid {
        grid-template-columns: repeat(2, 1fr);
        gap: 16px;
    }

    .stat-icon {
        font-size: 32px;
    }

    .stat-value {
        font-size: 16px;
    }

    .stat-label {
        font-size: 11px;
    }

    .books-grid {
        grid-template-columns: 1fr;
        gap: 12px;
    }

    .book-card {
        padding: 12px;
    }

    .book-actions {
        flex-direction: row;
    }

    .modal-content {
        padding: 16px;
        width: 95%;
    }

    .modal-header h2 {
        font-size: 16px;
    }

    .modal-body p {
        font-size: 13px;
    }

    .modal-summary p {
        font-size: 12px;
    }
}

@media (min-width: 1200px) {
    .books-grid {
        grid-template-columns: repeat(4, 1fr);
    }
}

@media (max-width: 1023px) and (min-width: 768px) {
    .books-grid {
        grid-template-columns: repeat(2, 1fr);
    }
}
</style>
@endpush

@push('scripts')
<script>
const API_BASE_URL = 'https://takaafrica.com/pharmaRh/taka';
let books = [];
let stats = {
    totalUsers: 0,
    totalBooks: 0,
    totalPending: 0,
    totalValidated: 0
};

// Initialize
document.addEventListener('DOMContentLoaded', function() {
    fetchStats();
    fetchBooks();
});

// Fetch Statistics
async function fetchStats() {
    try {
        const response = await fetch(`${API_BASE_URL}/taka_api_admin_stats.php`);
        const data = await response.json();
        
        stats = {
            totalUsers: data.total_users || 0,
            totalBooks: data.total_books || 0,
            totalPending: data.total_pending || 0,
            totalValidated: data.total_validated || 0
        };
        
        renderStats();
    } catch (error) {
        console.error('Error fetching stats:', error);
    }
}

// Render Statistics
function renderStats() {
    const statsGrid = document.getElementById('statsGrid');
    const isMobile = window.innerWidth < 768;
    
    statsGrid.innerHTML = `
        <div class="stat-item blue">
            <div class="stat-icon">👤</div>
            <div class="stat-value">${stats.totalUsers}</div>
            <div class="stat-label">Utilisateurs</div>
        </div>
        <div class="stat-item orange">
            <div class="stat-icon">📚</div>
            <div class="stat-value">${stats.totalBooks}</div>
            <div class="stat-label">${isMobile ? 'Livres' : 'Livres publiés'}</div>
        </div>
        <div class="stat-item amber">
            <div class="stat-icon">⏳</div>
            <div class="stat-value">${stats.totalPending}</div>
            <div class="stat-label">En attente</div>
        </div>
        <div class="stat-item green">
            <div class="stat-icon">✅</div>
            <div class="stat-value">${stats.totalValidated}</div>
            <div class="stat-label">Validés</div>
        </div>
    `;
}

// Fetch Books
async function fetchBooks() {
    try {
        const response = await fetch(`${API_BASE_URL}/taka_api_admin_books.php`);
        const data = await response.json();
        
        if (data.success && data.books) {
            books = data.books;
            renderBooks();
            
            document.getElementById('loadingState').style.display = 'none';
            if (books.length === 0) {
                document.getElementById('emptyState').style.display = 'block';
            } else {
                document.getElementById('adminContent').style.display = 'block';
            }
        } else {
            document.getElementById('loadingState').style.display = 'none';
            document.getElementById('emptyState').style.display = 'block';
        }
    } catch (error) {
        console.error('Error fetching books:', error);
        document.getElementById('loadingState').style.display = 'none';
        document.getElementById('emptyState').style.display = 'block';
    }
}

// Render Books
function renderBooks() {
    const booksGrid = document.getElementById('booksGrid');
    const isMobile = window.innerWidth < 768;
    
    booksGrid.innerHTML = books.map(book => {
        let coverUrl = '';
        if (book.cover_path) {
            if (book.cover_path.startsWith('http')) {
                coverUrl = book.cover_path;
            } else {
                coverUrl = `${API_BASE_URL}/${book.cover_path}`;
            }
        }
        const status = book.statut_validation || 'En attente de validation';
        const isValidated = status === 'Validé';
        const statusClass = isValidated ? 'validated' : 'pending';
        
        if (isMobile) {
            return `
                <div class="book-card book-card-mobile">
                    ${coverUrl ? `
                        <div style="position: relative; width: 80px; height: 120px; flex-shrink: 0; border-radius: 8px; overflow: hidden; background: #E5E7EB;">
                            <img src="${coverUrl}" alt="${book.title || ''}" style="width: 100%; height: 100%; object-fit: cover;" 
                                 onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                            <div style="display: none; width: 100%; height: 100%; align-items: center; justify-content: center; font-size: 32px; position: absolute; top: 0; left: 0;">📚</div>
                        </div>
                    ` : `
                        <div style="width: 80px; height: 120px; background: #E5E7EB; border-radius: 8px; display: flex; align-items: center; justify-content: center; font-size: 32px; flex-shrink: 0;">📚</div>
                    `}
                    <div class="book-content">
                        <div class="book-title">${book.title || ''}</div>
                        <div class="book-author">Auteur: ${book.author_bio || book.author_name || ''}</div>
                        <div class="book-genre">Genre: ${book.genre || ''}</div>
                        <div class="book-status ${statusClass}">Statut: ${status}</div>
                        <div class="book-price">Prix : ${book.price || 'N/A'} FCFA</div>
                        <div class="book-actions book-actions-mobile">
                            ${!isValidated ? `
                                <button class="btn-validate btn-validate-mobile" onclick="validateBook(${book.id}, this)">
                                    <span>✅</span> Valider
                                </button>
                            ` : ''}
                            <button class="btn-details btn-details-mobile" onclick="showBookDetails(${book.id})">
                                <span>ℹ️</span> Détails
                            </button>
                        </div>
                    </div>
                </div>
            `;
        } else {
            return `
                <div class="book-card">
                    ${coverUrl ? `
                        <div style="position: relative; width: 100%; height: 200px; margin-bottom: 8px; border-radius: 8px; overflow: hidden; background: #E5E7EB;">
                            <img src="${coverUrl}" alt="${book.title || ''}" style="width: 100%; height: 100%; object-fit: cover;" 
                                 onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                            <div style="display: none; width: 100%; height: 100%; align-items: center; justify-content: center; font-size: 48px; position: absolute; top: 0; left: 0;">📚</div>
                        </div>
                    ` : `
                        <div style="width: 100%; height: 200px; background: #E5E7EB; border-radius: 8px; display: flex; align-items: center; justify-content: center; font-size: 48px; margin-bottom: 8px;">📚</div>
                    `}
                    <div class="book-content">
                        <div class="book-title">${book.title || ''}</div>
                        <div class="book-author">Auteur: ${book.author_bio || book.author_name || ''}</div>
                        <div class="book-genre">Genre: ${book.genre || ''}</div>
                        <div class="book-language">Langue: ${book.language || ''}</div>
                        <div class="book-status ${statusClass}">Statut: ${status}</div>
                        <div class="book-summary">${book.summary || ''}</div>
                        <div class="book-actions" style="margin-top: auto;">
                            <div class="book-price">Prix : ${book.price || 'N/A'} FCFA</div>
                            <div style="display: flex; gap: 8px;">
                                ${!isValidated ? `
                                    <button class="btn-validate" onclick="validateBook(${book.id}, this)">
                                        <span>✅</span> Valider
                                    </button>
                                ` : ''}
                                <button class="btn-details btn-details-icon" onclick="showBookDetails(${book.id})">
                                    ℹ️
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            `;
        }
    }).join('');
}

// Validate Book
async function validateBook(bookId, buttonElement) {
    if (buttonElement.disabled) return;
    
    buttonElement.disabled = true;
    const originalContent = buttonElement.innerHTML;
    buttonElement.innerHTML = '<div class="validating-spinner"></div>';
    
    try {
        const response = await fetch(`${API_BASE_URL}/taka_api_admin_books.php`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                action: 'validate',
                book_id: bookId
            })
        });
        
        const data = await response.json();
        
        if (data.success) {
            // Refresh books and stats
            await fetchBooks();
            await fetchStats();
            
            // Show success message
            alert('Livre validé !');
        } else {
            alert('Erreur lors de la validation: ' + (data.error || 'Erreur inconnue'));
            buttonElement.innerHTML = originalContent;
            buttonElement.disabled = false;
        }
    } catch (error) {
        console.error('Error validating book:', error);
        alert('Erreur lors de la validation');
        buttonElement.innerHTML = originalContent;
        buttonElement.disabled = false;
    }
}

// Show Book Details
function showBookDetails(bookId) {
    const book = books.find(b => b.id == bookId);
    if (!book) return;
    
    document.getElementById('modalTitle').textContent = book.title || '';
    document.getElementById('modalAuthorName').textContent = book.author_name || 'Non disponible';
    document.getElementById('modalAuthorEmail').textContent = book.author_email || 'Non disponible';
    document.getElementById('modalAuthorCreatedAt').textContent = book.author_created_at || '';
    document.getElementById('modalPrice').textContent = (book.price || 'N/A') + ' FCFA';
    document.getElementById('modalSummary').textContent = book.summary || '';
    
    const filePath = book.file_path ? `${API_BASE_URL}/${book.file_path}` : '#';
    document.getElementById('modalViewBook').href = filePath;
    
    document.getElementById('bookDetailsModal').style.display = 'flex';
}

// Close Book Details Modal
function closeBookDetailsModal() {
    document.getElementById('bookDetailsModal').style.display = 'none';
}

// Close modal on outside click
document.getElementById('bookDetailsModal')?.addEventListener('click', function(e) {
    if (e.target === this) {
        closeBookDetailsModal();
    }
});

// Handle window resize
window.addEventListener('resize', function() {
    renderStats();
    renderBooks();
});
</script>
@endpush
@endsection
