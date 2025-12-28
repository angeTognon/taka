@extends('layouts.app')

@section('title', 'Mon Portefeuille TAKA')

@auth
@section('content')
<div class="wallet-page">
    <!-- Top Block: Solde + Statistiques + Bouton de retrait -->
    <div class="wallet-top-block">
        <!-- Solde disponible -->
        <div class="balance-section">
            <h3>Solde disponible</h3>
            <div class="balance-amount" id="balanceAmount">{{ number_format($balance ?? 0, 0, ',', ' ') }} FCFA</div>
            <p class="balance-hint">Utilisez votre solde pour vos retraits et achats.</p>
        </div>

        <!-- Statistiques -->
        <div class="stats-section">
            <div class="stat-item">
                <div class="stat-icon stat-icon-blue">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <circle cx="9" cy="21" r="1"></circle>
                        <circle cx="20" cy="21" r="1"></circle>
                        <path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"></path>
                    </svg>
                </div>
                <div class="stat-value">{{ $authorStats['totalSales'] ?? 0 }}</div>
                <div class="stat-label">Ventes</div>
            </div>
            <div class="stat-item">
                <div class="stat-icon stat-icon-green">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <line x1="12" y1="1" x2="12" y2="23"></line>
                        <path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path>
                    </svg>
                </div>
                <div class="stat-value">{{ number_format($authorStats['totalRevenue'] ?? 0, 0, ',', ' ') }} FCFA</div>
                <div class="stat-label">Revenu</div>
            </div>
            <div class="stat-item">
                <div class="stat-icon stat-icon-purple">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
                        <circle cx="9" cy="7" r="4"></circle>
                        <path d="M23 21v-2a4 4 0 0 0-3-3.87"></path>
                        <path d="M16 3.13a4 4 0 0 1 0 7.75"></path>
                    </svg>
                </div>
                <div class="stat-value">{{ $authorStats['totalReaders'] ?? 0 }}</div>
                <div class="stat-label">Lecteurs</div>
            </div>
        </div>

        <!-- Bouton de retrait -->
        <div class="withdrawal-section">
            <button 
                class="btn-withdraw" 
                id="withdrawBtn"
                onclick="requestWithdrawal()"
                {{ ($balance ?? 0) >= 10000 && !($hasRequestedWithdrawal ?? false) ? '' : 'disabled' }}>
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <circle cx="12" cy="12" r="10"></circle>
                    <polyline points="12 6 12 12 16 14"></polyline>
                </svg>
                <span id="withdrawBtnText">
                    {{ ($hasRequestedWithdrawal ?? false) ? 'Demande déjà envoyée.' : 'Demander un retrait' }}
                </span>
            </button>

            <!-- Statut de retrait -->
            @if($hasRequestedWithdrawal ?? false)
                <div class="withdrawal-status withdrawal-status-pending">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <circle cx="12" cy="12" r="10"></circle>
                        <polyline points="12 6 12 12 16 14"></polyline>
                    </svg>
                    <span>Demande de retrait en attente</span>
                </div>
            @else
                <div class="withdrawal-status withdrawal-status-none">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path>
                        <polyline points="22 4 12 14.01 9 11.01"></polyline>
                    </svg>
                    <span>Aucune demande de retrait en cours</span>
                </div>
            @endif

            <!-- Message si solde insuffisant -->
            @if(($balance ?? 0) < 10000)
                <div class="withdrawal-warning">
                    Le montant minimum pour un retrait est de 10 000 FCFA.
                </div>
            @endif
        </div>
    </div>

    <!-- Bottom Block: Historique des transactions -->
    <div class="wallet-bottom-block">
        <h2>Vos Affiliations - Livres</h2>
        
        @if(count($transactions ?? []) > 0)
            <div class="transactions-list">
                @foreach($transactions as $tx)
                    <div class="transaction-item">
                        <div class="transaction-icon">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path>
                                <path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path>
                            </svg>
                        </div>
                        <div class="transaction-details">
                            <div class="transaction-amount">+{{ number_format($tx['amount'] ?? 0, 0, ',', ' ') }} FCFA</div>
                            <div class="transaction-type">Affiliation - Livre</div>
                        </div>
                        <div class="transaction-date">
                            {{ isset($tx['created_at']) ? \Carbon\Carbon::parse($tx['created_at'])->format('d/m/Y H:i') : '' }}
                        </div>
                    </div>
                @endforeach
            </div>
        @else
            <div class="empty-transactions">
                Aucune affiliation de livre trouvée.
            </div>
        @endif

        <div class="wallet-tip">
            Astuce : Pour toute question sur les retraits, contactez le support TAKA via le chat ou WhatsApp.
        </div>
    </div>
</div>

<!-- Withdrawal Success Modal -->
<div id="withdrawalModal" class="modal">
    <div class="modal-content modal-small">
        <h3>Demande de retrait</h3>
        <p>Votre demande de retrait a été envoyée à l'équipe TAKA. Vous serez crédité sous 48h ouvrées.</p>
        <div class="modal-actions">
            <button class="btn-primary" onclick="closeWithdrawalModal()">OK</button>
        </div>
    </div>
</div>

@push('styles')
<style>
:root {
    --wallet-bg: #FFFFFF;
    --wallet-secondary-bg: #F9FAFB;
    --text-primary: #1E293B;
    --text-secondary: #6B7280;
    --orange: #F97316;
    --blue: #3B82F6;
    --green: #10B981;
    --purple: #8B5CF6;
    --shadow: 0 4px 10px rgba(0, 0, 0, 0.05);
}

.wallet-page {
    min-height: calc(100vh - 200px);
    background: var(--wallet-bg);
    padding: 30px 20px;
}

.wallet-top-block,
.wallet-bottom-block {
    max-width: 1200px;
    margin: 0 auto 20px;
    background: var(--wallet-bg);
    border-radius: 16px;
    box-shadow: var(--shadow);
    padding: 20px;
}

/* Balance Section */
.balance-section {
    width: 100%;
    padding: 16px;
    background: rgba(249, 115, 22, 0.07);
    border-radius: 12px;
    margin-bottom: 20px;
    text-align: center;
}

.balance-section h3 {
    font-size: 16px;
    font-weight: 700;
    color: var(--text-primary);
    margin: 0 0 8px 0;
    font-family: 'Inter', sans-serif;
}

.balance-amount {
    font-size: 32px;
    font-weight: 700;
    color: var(--orange);
    margin: 8px 0;
    font-family: 'Inter', sans-serif;
}

.balance-hint {
    font-size: 14px;
    color: var(--text-secondary);
    margin: 8px 0 0 0;
    font-family: 'Inter', sans-serif;
}

/* Stats Section */
.stats-section {
    padding: 16px;
    background: var(--wallet-secondary-bg);
    border-radius: 12px;
    margin-bottom: 20px;
    display: flex;
    justify-content: space-around;
    flex-wrap: wrap;
    gap: 16px;
}

.stat-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    flex: 1;
    min-width: 100px;
}

.stat-icon {
    width: 48px;
    height: 48px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    margin-bottom: 8px;
}

.stat-icon-blue {
    background: rgba(59, 130, 246, 0.1);
    color: var(--blue);
}

.stat-icon-green {
    background: rgba(16, 185, 129, 0.1);
    color: var(--green);
}

.stat-icon-purple {
    background: rgba(139, 92, 246, 0.1);
    color: var(--purple);
}

.stat-value {
    font-size: 16px;
    font-weight: 700;
    color: var(--text-primary);
    margin-bottom: 6px;
    font-family: 'Inter', sans-serif;
}

.stat-label {
    font-size: 13px;
    color: var(--text-secondary);
    font-family: 'Inter', sans-serif;
}

/* Withdrawal Section */
.withdrawal-section {
    text-align: center;
}

.btn-withdraw {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 14px 32px;
    background: var(--orange);
    color: white;
    border: none;
    border-radius: 8px;
    font-size: 16px;
    font-weight: 500;
    font-family: 'Inter', sans-serif;
    cursor: pointer;
    transition: background 0.2s;
}

.btn-withdraw:hover:not(:disabled) {
    background: #EA580C;
}

.btn-withdraw:disabled {
    background: #94A3B8;
    cursor: not-allowed;
}

.withdrawal-status {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    margin-top: 12px;
    font-size: 15px;
    font-weight: 700;
    font-family: 'Inter', sans-serif;
}

.withdrawal-status-pending {
    color: var(--orange);
}

.withdrawal-status-none {
    color: var(--green);
}

.withdrawal-warning {
    margin-top: 12px;
    color: #DC2626;
    font-size: 14px;
    font-family: 'Inter', sans-serif;
    text-align: center;
}

/* Bottom Block */
.wallet-bottom-block h2 {
    font-size: 18px;
    font-weight: 700;
    color: var(--text-primary);
    margin: 0 0 12px 0;
    font-family: 'Inter', sans-serif;
}

.transactions-list {
    display: flex;
    flex-direction: column;
    gap: 6px;
    margin-bottom: 12px;
}

.transaction-item {
    display: flex;
    align-items: center;
    padding: 8px 16px;
    background: var(--wallet-bg);
    border: 1px solid #E5E7EB;
    border-radius: 8px;
    gap: 16px;
}

.transaction-icon {
    width: 40px;
    height: 40px;
    border-radius: 50%;
    background: rgba(59, 130, 246, 0.1);
    color: var(--blue);
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
}

.transaction-details {
    flex: 1;
}

.transaction-amount {
    font-size: 16px;
    font-weight: 700;
    color: var(--orange);
    font-family: 'Inter', sans-serif;
    margin-bottom: 4px;
}

.transaction-type {
    font-size: 14px;
    color: var(--text-secondary);
    font-family: 'Inter', sans-serif;
}

.transaction-date {
    font-size: 12px;
    color: var(--text-secondary);
    font-family: 'Inter', sans-serif;
    white-space: nowrap;
}

.empty-transactions {
    padding: 40px 20px;
    text-align: center;
    color: var(--text-secondary);
    font-size: 14px;
    font-family: 'Inter', sans-serif;
}

.wallet-tip {
    padding: 12px;
    background: rgba(59, 130, 246, 0.05);
    border-radius: 8px;
    color: var(--text-secondary);
    font-size: 14px;
    text-align: center;
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
    background: var(--wallet-bg);
    margin: 40px auto;
    padding: 24px;
    border-radius: 16px;
    max-width: 500px;
    width: 90%;
}

.modal-small {
    max-width: 400px;
}

.modal-content h3 {
    font-size: 19px;
    font-weight: 700;
    color: var(--text-primary);
    margin: 0 0 16px 0;
    font-family: 'Inter', sans-serif;
}

.modal-content p {
    font-size: 14px;
    color: var(--text-secondary);
    margin: 0 0 24px 0;
    font-family: 'Inter', sans-serif;
    line-height: 1.6;
}

.modal-actions {
    display: flex;
    justify-content: flex-end;
}

.btn-primary {
    padding: 10px 20px;
    border: none;
    border-radius: 8px;
    background: var(--orange);
    color: white;
    font-size: 14px;
    font-weight: 700;
    font-family: 'Inter', sans-serif;
    cursor: pointer;
    transition: background 0.2s;
}

.btn-primary:hover {
    background: #EA580C;
}

/* Responsive */
@media (max-width: 768px) {
    .wallet-page {
        padding: 16px 12px;
    }

    .wallet-top-block,
    .wallet-bottom-block {
        padding: 12px;
        border-radius: 10px;
    }

    .balance-amount {
        font-size: 24px;
    }

    .stats-section {
        flex-direction: column;
        gap: 8px;
    }

    .stat-item {
        flex-direction: row;
        justify-content: flex-start;
        gap: 16px;
        min-width: auto;
    }

    .stat-icon {
        width: 40px;
        height: 40px;
        margin-bottom: 0;
    }

    .stat-value {
        font-size: 14px;
    }

    .stat-label {
        font-size: 12px;
    }

    .btn-withdraw {
        padding: 10px 18px;
        font-size: 14px;
    }

    .withdrawal-status {
        font-size: 13px;
    }

    .transaction-item {
        padding: 6px 8px;
    }

    .transaction-amount {
        font-size: 14px;
    }

    .transaction-type {
        font-size: 12px;
    }

    .transaction-date {
        font-size: 10px;
    }
}
</style>
@endpush

@push('scripts')
<script>
let hasRequestedWithdrawal = {{ ($hasRequestedWithdrawal ?? false) ? 'true' : 'false' }};
const minWithdrawalAmount = 10000;
const currentBalance = {{ $balance ?? 0 }};

async function requestWithdrawal() {
    if (currentBalance < minWithdrawalAmount || hasRequestedWithdrawal) {
        return;
    }

    const btn = document.getElementById('withdrawBtn');
    const btnText = document.getElementById('withdrawBtnText');
    
    btn.disabled = true;
    btnText.textContent = 'Envoi...';

    try {
        const response = await fetch('{{ route("wallet.request-withdrawal") }}', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content
            }
        });

        const data = await response.json();

        if (data.success) {
            hasRequestedWithdrawal = true;
            btn.disabled = true;
            btnText.textContent = 'Demande déjà envoyée.';
            
            // Mettre à jour le statut visuel
            updateWithdrawalStatus(true);
            
            // Afficher le modal de confirmation
            document.getElementById('withdrawalModal').style.display = 'block';
        } else {
            alert(data.error || 'Erreur lors de la demande de retrait');
            btn.disabled = false;
            btnText.textContent = 'Demander un retrait';
        }
    } catch (error) {
        console.error('Error:', error);
        alert('Erreur réseau: ' + error.message);
        btn.disabled = false;
        btnText.textContent = 'Demander un retrait';
    }
}

function updateWithdrawalStatus(hasRequest) {
    hasRequestedWithdrawal = hasRequest;
    const statusDiv = document.querySelector('.withdrawal-status');
    
    if (hasRequest) {
        statusDiv.className = 'withdrawal-status withdrawal-status-pending';
        statusDiv.innerHTML = `
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <circle cx="12" cy="12" r="10"></circle>
                <polyline points="12 6 12 12 16 14"></polyline>
            </svg>
            <span>Demande de retrait en attente</span>
        `;
    } else {
        statusDiv.className = 'withdrawal-status withdrawal-status-none';
        statusDiv.innerHTML = `
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path>
                <polyline points="22 4 12 14.01 9 11.01"></polyline>
            </svg>
            <span>Aucune demande de retrait en cours</span>
        `;
    }
}

function closeWithdrawalModal() {
    document.getElementById('withdrawalModal').style.display = 'none';
}

// Close modal when clicking outside
window.onclick = function(event) {
    const modal = document.getElementById('withdrawalModal');
    if (event.target == modal) {
        closeWithdrawalModal();
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
        <p style="font-size: 16px; color: #6B7280; margin-bottom: 24px; font-family: 'Inter', sans-serif;">Vous devez être connecté pour accéder à votre portefeuille.</p>
        <a href="{{ route('login') }}" style="display: inline-flex; align-items: center; gap: 8px; padding: 14px 32px; background: #F97316; color: white; border-radius: 8px; text-decoration: none; font-size: 16px; font-weight: 500; font-family: 'Inter', sans-serif;">Se connecter</a>
    </div>
</div>
@endsection
@endauth
