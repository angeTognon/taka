@extends('layouts.app')

@section('title', 'Programme d\'Affiliation TAKA')

@section('content')
<div class="affiliate-program-page">
    <!-- Hero Section -->
    <section class="hero-section">
        <div class="hero-content">
            <div class="hero-icon">🤝</div>
            <h1>🤝 Programme d'Affiliation TAKA</h1>
            <p>Fais la promotion des livres africains.<br>Gagne de l'argent. Inspire ton audience.</p>
            <div class="hero-steps-container">
                <div class="hero-steps-label">C'est simple :</div>
                <div class="hero-steps">
                    <div class="hero-step">
                        <div class="step-number">1.</div>
                        <div class="step-label">Tu recommandes</div>
                    </div>
                    <div class="hero-step">
                        <div class="step-number">2.</div>
                        <div class="step-label">Ils achètent</div>
                    </div>
                    <div class="hero-step">
                        <div class="step-number">3.</div>
                        <div class="step-label">Tu encaisses</div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- How It Works Section -->
    <section class="how-it-works-section">
        <div class="container">
            <h2>Comment ça marche ?</h2>
            <div class="steps-list">
                <div class="step-card blue">
                    <div class="step-number-circle">1</div>
                    <div class="step-content">
                        <h3>Inscris-toi gratuitement</h3>
                        <p>En quelques clics, tu obtiens ton tableau de bord personnel</p>
                    </div>
                    <div class="step-icon">👤</div>
                </div>
                <div class="step-card orange">
                    <div class="step-number-circle">2</div>
                    <div class="step-content">
                        <h3>Partage tes liens personnalisés</h3>
                        <p>Choisis des livres, génère tes liens uniques et partage-les sur tes réseaux</p>
                    </div>
                    <div class="step-icon">🔗</div>
                </div>
                <div class="step-card green">
                    <div class="step-number-circle">3</div>
                    <div class="step-content">
                        <h3>Gagne des commissions</h3>
                        <p>20% de commission par livre vendu, paiement mensuel transparent</p>
                    </div>
                    <div class="step-icon">💰</div>
                </div>
            </div>
        </div>
    </section>

    <!-- Who Can Join Section -->
    <section class="who-can-join-section">
        <div class="container">
            <h2>Qui peut devenir affilié TAKA ?</h2>
            <div class="profile-cards">
                <div class="profile-card purple">
                    <div class="profile-emoji">📲</div>
                    <div class="profile-text">Influenceur ou micro-influenceur</div>
                </div>
                <div class="profile-card blue">
                    <div class="profile-emoji">📖</div>
                    <div class="profile-text">Passionné de lecture</div>
                </div>
                <div class="profile-card green">
                    <div class="profile-emoji">📝</div>
                    <div class="profile-text">Blogueur ou chroniqueur littéraire</div>
                </div>
                <div class="profile-card indigo">
                    <div class="profile-emoji">🎓</div>
                    <div class="profile-text">Enseignant, étudiant ou documentaliste</div>
                </div>
                <div class="profile-card orange">
                    <div class="profile-emoji">💼</div>
                    <div class="profile-text">Entrepreneur digital ou community manager</div>
                </div>
                <div class="profile-card red">
                    <div class="profile-emoji">❤️</div>
                    <div class="profile-text">Lecteur fidèle qui veut recommander ses coups de cœur</div>
                </div>
            </div>
        </div>
    </section>

    <!-- Payment Section -->
    <section class="payment-section">
        <div class="container">
            <h2>💳 Paiement & Conditions</h2>
            <div class="payment-info">
                <div class="payment-item">
                    <div class="payment-icon">📅</div>
                    <div class="payment-text">Paiement entre le 1er et le 15 du mois</div>
                </div>
                <div class="payment-item">
                    <div class="payment-icon">💳</div>
                    <div class="payment-text">Minimum de 15.000 FCFA pour déclencher un paiement</div>
                </div>
                <div class="payment-item">
                    <div class="payment-icon">📱</div>
                    <div class="payment-text">Paiement par Mobile Money (Orange, MTN, Wave)</div>
                </div>
                <div class="payment-item">
                    <div class="payment-icon">🆓</div>
                    <div class="payment-text">Pas de frais, pas d'intermédiaires</div>
                </div>
            </div>
        </div>
    </section>

    <!-- Transparency Section -->
    <section class="transparency-section">
        <div class="container">
            <h2>🔐 Transparent, fiable, sécurisé</h2>
            <p class="transparency-subtitle">Ton tableau de bord affiche en temps réel :</p>
            <div class="dashboard-features">
                <div class="dashboard-feature blue">
                    <div class="feature-icon">🖱️</div>
                    <div class="feature-text">Tes clics</div>
                </div>
                <div class="dashboard-feature green">
                    <div class="feature-icon">🛒</div>
                    <div class="feature-text">Tes ventes confirmées</div>
                </div>
                <div class="dashboard-feature orange">
                    <div class="feature-icon">💵</div>
                    <div class="feature-text">Tes revenus</div>
                </div>
                <div class="dashboard-feature purple">
                    <div class="feature-icon">📈</div>
                    <div class="feature-text">Tes livres les plus performants</div>
                </div>
                <div class="dashboard-feature red">
                    <div class="feature-icon">📊</div>
                    <div class="feature-text">Les supports qui marchent le mieux</div>
                </div>
            </div>
        </div>
    </section>

    <!-- FAQ Section -->
    <section class="faq-section">
        <div class="container">
            <h2>📌 FAQ Affiliés TAKA</h2>
            <div class="faq-list">
                <div class="faq-item">
                    <div class="faq-question">
                        <span>Qu'est-ce que TAKA ?</span>
                        <span class="faq-toggle">+</span>
                    </div>
                    <div class="faq-answer">
                        <p>TAKA est une plateforme panafricaine de vente et promotion de livres numériques et imprimés, mettant en avant les auteurs africains et afro-descendants.</p>
                    </div>
                </div>

                <div class="faq-item">
                    <div class="faq-question">
                        <span>En quoi consiste le programme d'affiliation TAKA ?</span>
                        <span class="faq-toggle">+</span>
                    </div>
                    <div class="faq-answer">
                        <p>C'est un système qui te permet de promouvoir nos livres et de toucher 20% de commission sur chaque vente réalisée via ton lien personnalisé.</p>
                    </div>
                </div>

                <div class="faq-item">
                    <div class="faq-question">
                        <span>Puis-je suivre mes ventes en direct ?</span>
                        <span class="faq-toggle">+</span>
                    </div>
                    <div class="faq-answer">
                        <p>Oui. Ton tableau de bord te permet de suivre tes clics, ventes et revenus à tout moment.</p>
                    </div>
                </div>

                <div class="faq-item">
                    <div class="faq-question">
                        <span>Je suis auteur, puis-je être affilié ?</span>
                        <span class="faq-toggle">+</span>
                    </div>
                    <div class="faq-answer">
                        <p>Oui. Et si tu fais la promo de ton propre livre, tu cumules ta rémunération d'auteur + la commission d'affilié.</p>
                    </div>
                </div>

                <div class="faq-item">
                    <div class="faq-question">
                        <span>Quelles sont les règles de communication ?</span>
                        <span class="faq-toggle">+</span>
                    </div>
                    <div class="faq-answer">
                        <p>Pas de spam, pas de contenu trompeur, pas de pratiques frauduleuses. Respecte les lois et les règles des plateformes où tu postes.</p>
                    </div>
                </div>

                <div class="faq-item">
                    <div class="faq-question">
                        <span>Que se passe-t-il si je ne respecte pas les règles ?</span>
                        <span class="faq-toggle">+</span>
                    </div>
                    <div class="faq-answer">
                        <p>Suspension ou exclusion définitive du programme.</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Contact Section -->
    <section class="contact-section">
        <div class="container">
            <h2>Besoin d'aide ?</h2>
            <div class="contact-methods">
                <div class="contact-method">
                    <div class="contact-icon blue">📧</div>
                    <div class="contact-method-title">Email</div>
                    <div class="contact-method-value">contact@takaafrica.com</div>
                </div>
                <div class="contact-method">
                    <div class="contact-icon green">📱</div>
                    <div class="contact-method-title">WhatsApp</div>
                    <div class="contact-method-value">+229 0197147572</div>
                </div>
            </div>
            <a href="{{ route(auth()->check() ? 'affiliate' : 'login') }}" class="btn-become-affiliate">Devenir Affilié Maintenant</a>
        </div>
    </section>
</div>

@push('styles')
<style>
.affiliate-program-page {
    background: white;
}

/* Hero Section */
.hero-section {
    height: 520px;
    background: linear-gradient(135deg, #059669 0%, #0D9488 50%, #14B8A6 100%);
    position: relative;
    display: flex;
    align-items: center;
    justify-content: center;
}

.hero-section::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0, 0, 0, 0.1);
}

.hero-content {
    position: relative;
    z-index: 1;
    text-align: center;
    color: white;
    padding: 0 24px;
    max-width: 800px;
}

.hero-icon {
    font-size: 70px;
    margin-bottom: 18px;
}

.hero-content h1 {
    font-size: 22px;
    font-weight: 700;
    margin-bottom: 16px;
}

.hero-content > p {
    font-size: 15px;
    line-height: 1.5;
    margin-bottom: 30px;
}

.hero-steps-container {
    background: rgba(255, 255, 255, 0.15);
    border: 1px solid rgba(255, 255, 255, 0.3);
    border-radius: 16px;
    padding: 24px;
}

.hero-steps-label {
    font-size: 18px;
    font-weight: 700;
    margin-bottom: 12px;
}

.hero-steps {
    display: flex;
    justify-content: space-evenly;
    flex-wrap: wrap;
}

.hero-step {
    text-align: center;
}

.step-number {
    font-size: 32px;
    font-weight: 700;
    margin-bottom: 8px;
}

.step-label {
    font-size: 16px;
}

/* How It Works Section */
.how-it-works-section {
    padding: 80px 20px;
    background: white;
}

.how-it-works-section h2 {
    font-size: 23px;
    font-weight: 700;
    text-align: center;
    margin-bottom: 64px;
    color: #111827;
}

.steps-list {
    max-width: 900px;
    margin: 0 auto;
}

.step-card {
    display: flex;
    align-items: flex-start;
    gap: 24px;
    padding: 32px;
    border-radius: 16px;
    margin-bottom: 32px;
    position: relative;
}

.step-card.blue {
    background: linear-gradient(135deg, #DBEAFE 0%, #BFDBFE 100%);
    border: 1px solid #93C5FD;
}

.step-card.orange {
    background: linear-gradient(135deg, #FED7AA 0%, #FDBA74 100%);
    border: 1px solid #FBBF24;
}

.step-card.green {
    background: linear-gradient(135deg, #D1FAE5 0%, #A7F3D0 100%);
    border: 1px solid #6EE7B7;
}

.step-number-circle {
    width: 80px;
    height: 80px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 24px;
    font-weight: 700;
    color: white;
    flex-shrink: 0;
}

.step-card.blue .step-number-circle {
    background: linear-gradient(135deg, #2563EB 0%, #1E40AF 100%);
}

.step-card.orange .step-number-circle {
    background: linear-gradient(135deg, #F97316 0%, #EA580C 100%);
}

.step-card.green .step-number-circle {
    background: linear-gradient(135deg, #10B981 0%, #059669 100%);
}

.step-content {
    flex: 1;
}

.step-content h3 {
    font-size: 19px;
    font-weight: 700;
    color: #111827;
    margin-bottom: 8px;
}

.step-content p {
    font-size: 15px;
    color: #6B7280;
    line-height: 1.5;
}

.step-icon {
    font-size: 48px;
    flex-shrink: 0;
}

.step-card.blue .step-icon {
    color: #2563EB;
}

.step-card.orange .step-icon {
    color: #F97316;
}

.step-card.green .step-icon {
    color: #10B981;
}

/* Who Can Join Section */
.who-can-join-section {
    padding: 80px 20px;
    background: #F9FAFB;
}

.who-can-join-section h2 {
    font-size: 25px;
    font-weight: 700;
    text-align: center;
    margin-bottom: 64px;
    color: #111827;
}

.profile-cards {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 24px;
    max-width: 1200px;
    margin: 0 auto;
}

.profile-card {
    background: white;
    padding: 24px;
    border-radius: 16px;
    display: flex;
    align-items: center;
    gap: 16px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    min-height: 100px;
}

.profile-card.purple { border: 1px solid #C4B5FD; }
.profile-card.blue { border: 1px solid #93C5FD; }
.profile-card.green { border: 1px solid #86EFAC; }
.profile-card.indigo { border: 1px solid #818CF8; }
.profile-card.orange { border: 1px solid #FBBF24; }
.profile-card.red { border: 1px solid #FCA5A5; }

.profile-emoji {
    font-size: 48px;
    flex-shrink: 0;
}

.profile-text {
    font-size: 15px;
    font-weight: 600;
    color: #111827;
    line-height: 1.4;
}

/* Payment Section */
.payment-section {
    padding: 80px 20px;
    background: linear-gradient(135deg, #1E40AF 0%, #3B82F6 100%);
    color: white;
}

.payment-section h2 {
    font-size: 24px;
    font-weight: 700;
    text-align: center;
    margin-bottom: 48px;
}

.payment-info {
    max-width: 700px;
    margin: 0 auto;
    background: rgba(255, 255, 255, 0.1);
    border: 1px solid rgba(255, 255, 255, 0.3);
    border-radius: 16px;
    padding: 32px;
}

.payment-item {
    display: flex;
    align-items: center;
    gap: 16px;
    margin-bottom: 12px;
}

.payment-item:last-child {
    margin-bottom: 0;
}

.payment-icon {
    font-size: 24px;
    flex-shrink: 0;
}

.payment-text {
    font-size: 16px;
}

/* Transparency Section */
.transparency-section {
    padding: 80px 20px;
    background: white;
}

.transparency-section h2 {
    font-size: 24px;
    font-weight: 700;
    text-align: center;
    margin-bottom: 32px;
    color: #111827;
}

.transparency-subtitle {
    font-size: 18px;
    text-align: center;
    color: #6B7280;
    margin-bottom: 48px;
}

.dashboard-features {
    display: flex;
    flex-wrap: wrap;
    justify-content: center;
    gap: 10px;
    max-width: 1300px;
    margin: 0 auto;
}

.dashboard-feature {
    width: 250px;
    height: 100px;
    padding: 24px;
    border-radius: 12px;
    display: flex;
    align-items: center;
    gap: 16px;
}

.dashboard-feature.blue {
    background: linear-gradient(135deg, #DBEAFE 0%, #BFDBFE 100%);
    border: 1px solid #93C5FD;
}

.dashboard-feature.green {
    background: linear-gradient(135deg, #D1FAE5 0%, #A7F3D0 100%);
    border: 1px solid #6EE7B7;
}

.dashboard-feature.orange {
    background: linear-gradient(135deg, #FED7AA 0%, #FDBA74 100%);
    border: 1px solid #FBBF24;
}

.dashboard-feature.purple {
    background: linear-gradient(135deg, #E9D5FF 0%, #DDD6FE 100%);
    border: 1px solid #C4B5FD;
}

.dashboard-feature.red {
    background: linear-gradient(135deg, #FEE2E2 0%, #FECACA 100%);
    border: 1px solid #FCA5A5;
}

.feature-icon {
    font-size: 32px;
    flex-shrink: 0;
}

.feature-text {
    font-size: 16px;
    font-weight: 600;
    color: #111827;
}

/* FAQ Section */
.faq-section {
    padding: 80px 20px;
    background: #F9FAFB;
}

.faq-section h2 {
    font-size: 24px;
    font-weight: 700;
    text-align: center;
    margin-bottom: 64px;
    color: #111827;
}

.faq-list {
    max-width: 800px;
    margin: 0 auto;
}

.faq-item {
    background: white;
    border-radius: 12px;
    margin-bottom: 16px;
    box-shadow: 0 1px 4px rgba(0,0,0,0.1);
    overflow: hidden;
}

.faq-question {
    padding: 16px 20px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    cursor: pointer;
    font-size: 15px;
    color: #111827;
}

.faq-question:hover {
    background: #F9FAFB;
}

.faq-toggle {
    font-size: 20px;
    color: #6B7280;
    font-weight: 300;
    transition: transform 0.3s;
}

.faq-item.active .faq-toggle {
    transform: rotate(45deg);
}

.faq-answer {
    padding: 0 20px;
    max-height: 0;
    overflow: hidden;
    transition: max-height 0.3s, padding 0.3s;
}

.faq-item.active .faq-answer {
    padding: 0 20px 16px;
    max-height: 500px;
}

.faq-answer p {
    font-size: 15px;
    color: #6B7280;
    line-height: 1.5;
}

/* Contact Section */
.contact-section {
    padding: 80px 20px;
    background: linear-gradient(135deg, #1F2937 0%, #374151 100%);
    color: white;
}

.contact-section h2 {
    font-size: 24px;
    font-weight: 700;
    text-align: center;
    margin-bottom: 48px;
}

.contact-methods {
    display: flex;
    justify-content: center;
    gap: 24px;
    margin-bottom: 48px;
    flex-wrap: wrap;
}

.contact-method {
    width: 220px;
    padding: 24px;
    background: rgba(255, 255, 255, 0.1);
    border: 1px solid rgba(255, 255, 255, 0.3);
    border-radius: 12px;
    text-align: center;
}

.contact-icon {
    font-size: 48px;
    margin-bottom: 16px;
}

.contact-method-title {
    font-size: 18px;
    font-weight: 700;
    margin-bottom: 8px;
}

.contact-method-value {
    font-size: 16px;
    color: rgba(255, 255, 255, 0.7);
}

.btn-become-affiliate {
    display: inline-block;
    padding: 16px 48px;
    background: #F97316;
    color: white;
    text-decoration: none;
    border-radius: 30px;
    font-size: 18px;
    font-weight: 600;
    transition: transform 0.2s, box-shadow 0.2s;
    box-shadow: 0 4px 8px rgba(0,0,0,0.2);
}

.btn-become-affiliate:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 12px rgba(0,0,0,0.3);
}

@media (max-width: 768px) {
    .hero-section {
        height: 420px;
    }

    .hero-content h1 {
        font-size: 17px;
    }

    .hero-content > p {
        font-size: 13px;
    }

    .hero-steps-container {
        padding: 14px;
    }

    .hero-steps {
        flex-direction: column;
        gap: 10px;
    }

    .hero-step {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 10px;
    }

    .step-number {
        font-size: 26px;
    }

    .step-number {
        font-size: 26px;
    }

    .step-label {
        font-size: 15px;
    }

    .how-it-works-section,
    .who-can-join-section,
    .payment-section,
    .transparency-section,
    .faq-section,
    .contact-section {
        padding: 36px 12px;
    }

    .how-it-works-section h2,
    .who-can-join-section h2,
    .payment-section h2,
    .transparency-section h2,
    .faq-section h2,
    .contact-section h2 {
        font-size: 16px;
        margin-bottom: 32px;
    }

    .profile-cards {
        grid-template-columns: 1fr;
        gap: 16px;
    }

    .profile-card {
        min-height: 90px;
        padding: 16px;
    }

    .profile-emoji {
        font-size: 32px;
    }

    .profile-text {
        font-size: 13px;
    }

    .step-card {
        padding: 16px;
        gap: 14px;
    }

    .step-number-circle {
        width: 54px;
        height: 54px;
        font-size: 20px;
    }

    .step-content h3 {
        font-size: 15px;
    }

    .step-content p {
        font-size: 13px;
    }

    .step-icon {
        font-size: 32px;
    }

    .dashboard-features {
        flex-direction: column;
        align-items: center;
    }

    .dashboard-feature {
        width: 100%;
        height: 70px;
        padding: 14px;
    }

    .feature-icon {
        font-size: 22px;
    }

    .feature-text {
        font-size: 13px;
    }

    .contact-methods {
        flex-direction: column;
        align-items: center;
    }

    .contact-method {
        width: 100%;
    }

    .btn-become-affiliate {
        padding: 12px 24px;
        font-size: 15px;
    }
}
</style>
@endpush

@push('scripts')
<script>
document.addEventListener('DOMContentLoaded', function() {
    const faqItems = document.querySelectorAll('.faq-item');
    
    faqItems.forEach(item => {
        const question = item.querySelector('.faq-question');
        question.addEventListener('click', function() {
            const isActive = item.classList.contains('active');
            
            // Close all items
            faqItems.forEach(i => i.classList.remove('active'));
            
            // Open clicked item if it wasn't active
            if (!isActive) {
                item.classList.add('active');
            }
        });
    });
});
</script>
@endpush
@endsection

