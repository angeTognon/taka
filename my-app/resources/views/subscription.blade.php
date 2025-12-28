@extends('layouts.app')

@section('title', 'Abonnement - TAKA')

@section('content')
<div class="subscription-page">
    <div class="subscription-container">
         <!-- Header -->
        <div class="subscription-header">
            <h1 class="subscription-title">Lire sans limite n’a jamais été aussi simple.            </h1>
            <p class="subscription-subtitle">Sur TAKA, certains livres sont gratuits, d’autres payants à l’unité.<br>
            L’abonnement Premium te permet de lire sans limite, sans payer à chaque livre.</p>
        </div>
        <!-- Main Content: Two Columns Layout -->
        <div class="subscription-main">
            <!-- Left Section: Benefits -->
            <div class="benefits-section">
                <div class="benefits-header">
                    <p class="benefits-label">CHOISISSEZ VOTRE FORMULE DE LECTURE</p>
                    <h2 class="benefits-title">VOS AVANTAGES</h2>
                </div>
                <ul class="benefits-list">
                    <li class="benefit-item">
                        <i class="fas fa-check-circle"></i>
                        <span>Lecture illimitée de tous les livres : Gratuits et Payants</span>
                    </li>
                    <li class="benefit-item">
                        <i class="fas fa-check-circle"></i>
                        <span>Accès prioritaire aux nouveautés</span>
                    </li>
                    <li class="benefit-item">
                        <i class="fas fa-check-circle"></i>
                        <span>Aucun paiement à chaque livre</span>
                    </li>
                    <li class="benefit-item">
                        <i class="fas fa-check-circle"></i>
                        <span>Lecture sécurisée sur TAKA</span>
                    </li>
                    <li class="benefit-item">
                        <i class="fas fa-check-circle"></i>
                        <span>Annule ton abonnement à tout moment</span>
                    </li>
                </ul>
            </div>

            <!-- Right Section: Plans -->
            <div class="plans-section">
                <div class="plans-list">
                    @foreach($plans as $index => $plan)
                        @php
                            $planId = $plan['id'];
                            $isActive = false;
                            $canSelect = true;
                            
                            if ($activeSubscription && isset($activeSubscription['plan'])) {
                                $isActive = ($activeSubscription['plan'] === $planId) && 
                                           ($activeSubscription['status'] ?? '') === 'payé' &&
                                           isset($activeSubscription['expires_at']) &&
                                           \Carbon\Carbon::parse($activeSubscription['expires_at'])->isFuture();
                                $canSelect = !$isActive;
                            }
                            
                            // Par défaut, sélectionner le premier plan
                            $isSelected = ($index === 0 && !$activeSubscription) || ($activeSubscription && $activeSubscription['plan'] === $planId);
                        @endphp
                        <div class="plan-option {{ $isSelected && !$isActive ? 'selected' : '' }} {{ $isActive ? 'active-plan' : '' }}" 
                             data-plan-id="{{ $planId }}"
                             onclick="{{ $canSelect ? "selectPlan('{$planId}')" : '' }}"
                             style="{{ $canSelect ? 'cursor: pointer;' : '' }}">
                            <div class="plan-radio">
                                <div class="radio-circle {{ $isSelected ? 'checked' : '' }}">
                                    @if($isSelected)
                                        <div class="radio-dot"></div>
                                    @endif
                                </div>
                            </div>
                            <div class="plan-details">
                                <div class="plan-name">{{ $plan['name'] }}</div>
                                <div class="plan-price-container">
                                    <span class="plan-price">{{ number_format($plan['price'], 0, ',', ' ') }} FCFA / {{ $plan['period'] }}</span>
                                    @if(isset($plan['old_price']) && $plan['old_price'])
                                        <span class="plan-old-price">au lieu de {{ number_format($plan['old_price'], 0, ',', ' ') }} FCFA</span>
                                    @endif
                                </div>
                                @if($isActive)
                                    <div class="plan-status">Actif</div>
                                @endif
                            </div>
                        </div>
                    @endforeach
                </div>

                <!-- Subscribe Button -->
                <button class="btn-subscribe" id="btnSubscribe" onclick="handleSubscribe()">
                    Je m'abonne
                </button>

                <!-- Payment Methods -->
                <div class="payment-methods">
                    <div class="payment-icons">
                        <img src="{{ asset('images/images/mtn-mobile-money.png') }}" alt="MTN Mobile Money" class="payment-icon-img">
                        <img src="{{ asset('images/images/wave.png') }}" alt="Wave" class="payment-icon-img">
                        <img src="{{ asset('images/images/tmoney.png') }}" alt="T-Money" class="payment-icon-img">
                        <img src="{{ asset('images/images/airtel-logo.png') }}" alt="Airtel" class="payment-icon-img">
                        <img src="{{ asset('images/images/moov.png') }}" alt="Moov" class="payment-icon-img">
                        <div class="payment-icon">
                            <svg width="40" height="40" viewBox="0 0 40 40" fill="none">
                                <rect width="40" height="40" rx="8" fill="#EB001B"/>
                                <circle cx="15" cy="20" r="6" fill="#FF5F00"/>
                                <circle cx="25" cy="20" r="6" fill="#F79E1B"/>
                            </svg>
                        </div>
                        <div class="payment-icon">
                            <svg width="40" height="40" viewBox="0 0 40 40" fill="none">
                                <rect width="40" height="40" rx="8" fill="#1A1F71"/>
                                <text x="20" y="25" font-size="14" fill="white" text-anchor="middle" font-weight="bold">VISA</text>
                            </svg>
                        </div>
                    </div>
                    <div class="payment-security">
                        <i class="fas fa-lock"></i>
                        <span>Paiement sécurisé</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Loading Overlay -->
<div id="loadingOverlay" class="loading-overlay" style="display: none;">
    <div class="loading-spinner"></div>
</div>

@push('styles')
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
<style>
* {
    box-sizing: border-box;
}

.subscription-page {
    background: #F9FAFB;
    min-height: calc(100vh - 200px);
    padding: 48px 20px;
    width: 100%;
    overflow-x: hidden;
}

.subscription-container {
    max-width: 1400px;
    margin: 0 auto;
    width: 100%;
}

.subscription-header {
    text-align: center;
    margin-bottom: 64px;
}

.subscription-title {
    font-size: 28px;
    font-weight: 700;
    color: #000000;
    margin-bottom: 16px;
    font-family: "PBold", sans-serif;
}

.subscription-subtitle {
    font-size: 17px;
    color: #6B7280;
    line-height: 1.5;
    max-width: 768px;
    margin: 0 auto;
    font-family: "PRegular", sans-serif;
}

.subscription-main {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 48px;
    align-items: start;
    width: 100%;
}

/* Left Section: Benefits */
.benefits-section {
    background: white;
    padding: 48px 40px;
    border-radius: 16px;
    min-height: 500px;
    border: 1px solid #E5E7EB;
    width: 100%;
    min-width: 0;
}

.benefits-header {
    margin-bottom: 48px;
}

.benefits-label {
    font-size: 12px;
    font-weight: 600;
    color: #F97316;
    text-transform: uppercase;
    letter-spacing: 1px;
    margin-bottom: 12px;
    font-family: "PBold", sans-serif;
}

.benefits-title {
    font-size: 26px;
    font-weight: 700;
    color: #111827;
    margin: 0;
    font-family: "PBold", sans-serif;
}

.benefits-list {
    list-style: none;
    padding: 0;
    margin: 0;
}

.benefit-item {
    display: flex;
    align-items: flex-start;
    gap: 16px;
    margin-bottom: 24px;
}

.benefit-item i {
    color: #111827;
    font-size: 24px;
    margin-top: 2px;
    flex-shrink: 0;
}

.benefit-item span {
    font-size: 18px;
    color: #111827;
    font-family: "PRegular", sans-serif;
    line-height: 1.5;
}

/* Right Section: Plans */
.plans-section {
    background: white;
    padding: 40px;
    border-radius: 16px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
    width: 100%;
    min-width: 0;
}

.plans-list {
    margin-bottom: 32px;
}

.plan-option {
    display: flex;
    align-items: center;
    gap: 16px;
    padding: 20px;
    border: 2px solid #E5E7EB;
    border-radius: 12px;
    margin-bottom: 16px;
    background: white;
    transition: all 0.2s;
}

.plan-option:hover {
    border-color: #F97316;
}

.plan-option.selected {
    border-color: #F97316;
    background: #FFF7ED;
}

.plan-option.active-plan {
    border-color: #10B981;
    background: #F0FDF4;
}

.plan-radio {
    flex-shrink: 0;
}

.radio-circle {
    width: 24px;
    height: 24px;
    border: 2px solid #D1D5DB;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 0.2s;
}

.plan-option.selected .radio-circle,
.plan-option.active-plan .radio-circle {
    border-color: #F97316;
}

.plan-option.active-plan .radio-circle {
    border-color: #10B981;
}

.radio-circle.checked {
    border-color: #F97316;
    background: #F97316;
}

.plan-option.active-plan .radio-circle.checked {
    border-color: #10B981;
    background: #10B981;
}

.radio-dot {
    width: 10px;
    height: 10px;
    background: white;
    border-radius: 50%;
}

.plan-details {
    flex: 1;
}

.plan-name {
    font-size: 18px;
    font-weight: 400;
    color: #111827;
    margin-bottom: 8px;
    font-family: "PBold", sans-serif;
}

.plan-price-container {
    display: flex;
    flex-direction: column;
    gap: 4px;
}

.plan-price {
    font-size: 20px;
    font-weight: 700;
    color: #111827;
    font-family: "PBold", sans-serif;
}

.plan-old-price {
    font-size: 14px;
    color: #6B7280;
    text-decoration: line-through;
    font-family: "PRegular", sans-serif;
}

.plan-status {
    display: inline-block;
    margin-top: 8px;
    padding: 4px 12px;
    background: #10B981;
    color: white;
    border-radius: 12px;
    font-size: 12px;
    font-weight: 600;
    font-family: "PBold", sans-serif;
}

.btn-subscribe {
    width: 100%;
    padding: 20px;
    background: #F97316;
    color: white;
    border: none;
    border-radius: 12px;
    font-size: 18px;
    font-weight: 700;
    cursor: pointer;
    font-family: "PBold", sans-serif;
    transition: background 0.2s;
    margin-bottom: 24px;
}

.btn-subscribe:hover {
    background: #EA580C;
}

.btn-subscribe:disabled {
    background: #D1D5DB;
    cursor: not-allowed;
}

.payment-methods {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 16px;
    width: 100%;
    flex-wrap: wrap;
}

.payment-icons {
    display: flex;
    gap: 12px;
    align-items: center;
    flex-wrap: wrap;
    flex: 1;
    min-width: 0;
}

.payment-icon {
    width: 40px;
    height: 40px;
    display: flex;
    align-items: center;
    justify-content: center;
}

.payment-icon-img {
    height: 40px;
    width: auto;
    max-width: 60px;
    object-fit: contain;
    flex-shrink: 0;
}

.payment-security {
    display: flex;
    align-items: center;
    gap: 8px;
    color: #374151;
    font-size: 14px;
    font-family: "PRegular", sans-serif;
    flex-shrink: 0;
    white-space: nowrap;
}

.payment-security i {
    color: #374151;
}

.loading-overlay {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0, 0, 0, 0.3);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 10000;
}

.loading-spinner {
    width: 50px;
    height: 50px;
    border: 4px solid #f3f3f3;
    border-top: 4px solid #F97316;
    border-radius: 50%;
    animation: spin 1s linear infinite;
}

@keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
}

/* Responsive */
@media (max-width: 1024px) {
    .subscription-main {
        grid-template-columns: 1fr;
        gap: 32px;
    }
    
    .benefits-section {
        background: white;
    }
}

@media (max-width: 768px) {
    .subscription-page {
        padding: 24px 16px;
    }
    
    .subscription-title {
        font-size: 18px;
    }
    
    .subscription-subtitle {
        font-size: 15px;
    }
    
    .benefits-section {
        padding: 32px 24px;
        background: white;
    }
    
    .benefits-label {
        font-size: 15px;
    }
    
    .benefits-title {
        font-size: 18px;
    }
    
    .benefit-item span {
        font-size: 15px;
    }
    
    .plans-section {
        padding: 24px;
    }
    
    .plan-name {
        font-size: 18px;
    }
    
    .plan-price {
        font-size: 15px;
    }
    
    .plan-old-price {
        font-size: 15px;
    }
    
    .btn-subscribe {
        padding: 16px;
        font-size: 15px;
    }
    
    .payment-security {
        font-size: 15px;
    }
    
    .payment-methods {
        flex-direction: column;
        align-items: flex-start;
        gap: 12px;
    }
}
</style>
@endpush

@push('scripts')
<script>
const baseUrl = 'https://takaafrica.com/pharmaRh/taka';
const isLoggedIn = {{ auth()->check() ? 'true' : 'false' }};
const userId = {{ auth()->check() && auth()->user() ? (auth()->user()->api_id ?: auth()->user()->id) : 'null' }};
const userEmail = '{{ auth()->check() ? auth()->user()->email : "" }}';
const userName = '{{ auth()->check() && auth()->user()->name ? auth()->user()->name : "" }}';
let selectedPlanId = '';
let isLoading = false;

// Récupérer le paramètre ref depuis l'URL
const urlParams = new URLSearchParams(window.location.search);
const affiliateRef = urlParams.get('ref') || '';

const plans = @json($plans);

// Initialiser avec le premier plan sélectionné par défaut
document.addEventListener('DOMContentLoaded', function() {
    if (plans.length > 0) {
        selectedPlanId = plans[0].id;
        updatePlanSelection();
    }
});

function selectPlan(planId) {
    if (isLoading) return;
    
    selectedPlanId = planId;
    updatePlanSelection();
}

function updatePlanSelection() {
    document.querySelectorAll('.plan-option').forEach(option => {
        const planId = option.getAttribute('data-plan-id');
        if (planId === selectedPlanId && !option.classList.contains('active-plan')) {
            option.classList.add('selected');
            option.querySelector('.radio-circle').classList.add('checked');
            option.querySelector('.radio-dot')?.remove();
            const dot = document.createElement('div');
            dot.className = 'radio-dot';
            option.querySelector('.radio-circle').appendChild(dot);
        } else if (!option.classList.contains('active-plan')) {
            option.classList.remove('selected');
            option.querySelector('.radio-circle').classList.remove('checked');
            option.querySelector('.radio-dot')?.remove();
        }
    });
}

async function handleSubscribe() {
    if (!selectedPlanId) {
        alert('Veuillez sélectionner un plan');
        return;
    }
    
    if (!isLoggedIn || !userId) {
        alert('Vous devez être connecté pour vous abonner');
        window.location.href = '{{ route("login") }}';
        return;
    }
    
    const plan = plans.find(p => p.id === selectedPlanId);
    if (!plan) return;
    
    isLoading = true;
    document.getElementById('loadingOverlay').style.display = 'flex';
    document.getElementById('btnSubscribe').disabled = true;
    
    try {
        // Récupérer la devise et le pays depuis localStorage ou utiliser les valeurs par défaut
        const currency = localStorage.getItem('currency') || 'XOF';
        const country = localStorage.getItem('country') || 'Bénin';
        
        // Préparer les noms
        let firstName = 'Utilisateur';
        let lastName = 'Client';
        
        if (userName) {
            const nameParts = userName.trim().split(' ');
            firstName = nameParts[0] || 'Utilisateur';
            lastName = nameParts.length > 1 ? nameParts.slice(1).join(' ') : 'Client';
        } else if (userEmail) {
            firstName = userEmail.split('@')[0];
        }
        
        // S'assurer que le montant est un entier (Moneroo attend un entier)
        const amount = Math.round(parseInt(plan.price.replace(/\./g, '').replace(/\s/g, '')) || 0);
        
        if (amount <= 0) {
            alert('Montant du plan invalide.');
            isLoading = false;
            document.getElementById('loadingOverlay').style.display = 'none';
            document.getElementById('btnSubscribe').disabled = false;
            return;
        }
        
        const payload = {
            amount: amount,
            currency: currency,
            country: country,
            description: 'Abonnement ' + plan.name,
            email: userEmail,
            first_name: firstName,
            last_name: lastName,
            user_id: userId,
            plan_id: selectedPlanId,
            return_url: 'https://takaafrica.com',
        };
        
        if (affiliateRef) {
            payload.ref = affiliateRef;
        }
        
        const response = await fetch(baseUrl + '/moneroo_init.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(payload),
        });
        
        // Vérifier si la réponse est OK avant de parser le JSON
        if (!response.ok) {
            const errorData = await response.json().catch(() => ({ error: 'Erreur inconnue' }));
            console.error('Erreur API:', errorData);
            isLoading = false;
            document.getElementById('loadingOverlay').style.display = 'none';
            document.getElementById('btnSubscribe').disabled = false;
            
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
            // Ouvrir le paiement dans un nouvel onglet
            window.open(data.checkout_url, '_blank');
            // Attendre la validation du paiement
            waitForPaymentValidation();
        } else {
            isLoading = false;
            document.getElementById('loadingOverlay').style.display = 'none';
            document.getElementById('btnSubscribe').disabled = false;
            
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
    } catch (error) {
        isLoading = false;
        document.getElementById('loadingOverlay').style.display = 'none';
        document.getElementById('btnSubscribe').disabled = false;
        console.error('Erreur:', error);
        alert('Erreur réseau : ' + error.message);
    }
}

async function waitForPaymentValidation() {
    let paid = false;
    let maxTries = 30; // 30 x 5s = 2min30 max
    let tries = 0;
    
    while (!paid && tries < maxTries) {
        await new Promise(resolve => setTimeout(resolve, 5000)); // Attendre 5 secondes
        
        try {
            const response = await fetch(`${baseUrl}/check_payment_status.php?user_id=${userId}&plan_id=${selectedPlanId}`);
            const data = await response.json();
            
            if (data.status === 'paid') {
                paid = true;
            }
        } catch (error) {
            console.error('Erreur vérification paiement:', error);
        }
        
        tries++;
    }
    
    isLoading = false;
    document.getElementById('loadingOverlay').style.display = 'none';
    document.getElementById('btnSubscribe').disabled = false;
    
    if (paid) {
        alert('Paiement validé !');
        // Recharger la page pour afficher l'abonnement actif
        window.location.reload();
    } else {
        alert('Paiement non validé ou annulé.');
    }
}
</script>
@endpush
@endsection
