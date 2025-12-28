@extends('layouts.app')

@section('title', 'FAQ Lecteurs - TAKA')

@section('content')
<div class="faq-page">
    <div class="container">
        <!-- Header -->
        <div class="faq-header">
            <div class="faq-header-icon">📚</div>
            <h1>Questions fréquentes – Lecteurs TAKA</h1>
            <p>Tout ce que tu dois savoir pour lire, acheter et profiter de la bibliothèque TAKA</p>
        </div>

        <!-- Category Filter -->
        <div class="faq-filter">
            <button class="filter-chip active" data-category="Tous">Tous</button>
            <button class="filter-chip" data-category="Général">Général</button>
            <button class="filter-chip" data-category="Lecture">Lecture</button>
            <button class="filter-chip" data-category="Paiement">Paiement</button>
            <button class="filter-chip" data-category="Sécurité">Sécurité</button>
            <button class="filter-chip" data-category="Technique">Technique</button>
            <button class="filter-chip" data-category="Compte">Compte</button>
            <button class="filter-chip" data-category="Offrir">Offrir</button>
            <button class="filter-chip" data-category="Support">Support</button>
        </div>

        <!-- FAQ List -->
        <div class="faq-list">
            <!-- Général -->
            <div class="faq-item" data-category="Général">
                <div class="faq-question">
                    <span>Qu'est-ce que TAKA ?</span>
                    <span class="faq-category">Général</span>
                    <span class="faq-toggle">+</span>
                </div>
                <div class="faq-answer">
                    <p>TAKA est une plateforme 100 % africaine qui vous permet d'acheter, lire et découvrir des livres numériques directement depuis votre téléphone, tablette ou ordinateur.</p>
                    <p><strong>Notre mission :</strong> rendre la littérature africaine et francophone accessible à tous, partout.</p>
                </div>
            </div>

            <div class="faq-item" data-category="Général">
                <div class="faq-question">
                    <span>Astuce TAKA : Comment recevoir des livres gratuits et des promos ?</span>
                    <span class="faq-category">Général</span>
                    <span class="faq-toggle">+</span>
                </div>
                <div class="faq-answer">
                    <p>Abonnez-vous à notre newsletter et rejoignez notre groupe WhatsApp "Lecteurs TAKA" pour recevoir des livres gratuits, des promos et des avant-premières.</p>
                </div>
            </div>

            <!-- Lecture -->
            <div class="faq-item" data-category="Lecture">
                <div class="faq-question">
                    <span>Comment fonctionne la lecture sur TAKA ?</span>
                    <span class="faq-category">Lecture</span>
                    <span class="faq-toggle">+</span>
                </div>
                <div class="faq-answer">
                    <ul>
                        <li>Tu choisis ton livre (gratuit, payant ou via abonnement)</li>
                        <li>Tu lis en ligne, directement depuis l'application</li>
                        <li>Tu ajoutes des signets, reprends où tu t'étais arrêté</li>
                        <li>Pas de téléchargement → pas de piratage, pas de perte</li>
                        <li>Ton historique est conservé dans ton compte</li>
                    </ul>
                </div>
            </div>

            <div class="faq-item" data-category="Lecture">
                <div class="faq-question">
                    <span>Quelles sont les 3 façons de lire sur TAKA ?</span>
                    <span class="faq-category">Lecture</span>
                    <span class="faq-toggle">+</span>
                </div>
                <div class="faq-answer">
                    <p><strong>1. 📘 Lire gratuitement</strong></p>
                    <p>Accède à notre Bibliothèque Gratuite : une sélection d'œuvres offertes par leurs auteurs. Zéro inscription, zéro paiement.</p>
                    <p><strong>2. 💳 Acheter un livre en quelques clics</strong></p>
                    <p>Tu vois un livre que tu veux lire ? Tu l'achètes une seule fois. Paiement rapide et sécurisé, lecture instantanée, tu le gardes à vie dans ta bibliothèque TAKA.</p>
                    <p><strong>3. 🔐 T'abonner pour tout lire</strong></p>
                    <p>Devient membre du TAKA READING CLUB, notre formule d'abonnement premium. Accès à 2000 livres africains, lecture illimitée ou limitée selon ton forfait, zéro pub, résiliation à tout moment.</p>
                </div>
            </div>

            <div class="faq-item" data-category="Lecture">
                <div class="faq-question">
                    <span>Comment lire un livre acheté sur TAKA ?</span>
                    <span class="faq-category">Lecture</span>
                    <span class="faq-toggle">+</span>
                </div>
                <div class="faq-answer">
                    <p>Dès que vous achetez un livre, il est automatiquement ajouté à votre bibliothèque TAKA. Vous pouvez le lire immédiatement en ligne via notre lecteur intégré sécurisé, sans téléchargement illégal possible.</p>
                </div>
            </div>

            <div class="faq-item" data-category="Lecture">
                <div class="faq-question">
                    <span>Quels types de livres vais-je trouver sur TAKA ?</span>
                    <span class="faq-category">Lecture</span>
                    <span class="faq-toggle">+</span>
                </div>
                <div class="faq-answer">
                    <p>Vous trouverez tous les genres :</p>
                    <ul>
                        <li>Romans, poésie, nouvelles</li>
                        <li>Livres business et développement personnel</li>
                        <li>Essais, biographies, documents historiques, Religion et Spiritualité</li>
                        <li>Littérature jeunesse et scolaire</li>
                        <li>Ouvrages en langues africaines</li>
                    </ul>
                    <p>Tous nos livres respectent des standards de qualité élevés.</p>
                </div>
            </div>

            <div class="faq-item" data-category="Lecture">
                <div class="faq-question">
                    <span>Est-ce que la lecture est gratuite ?</span>
                    <span class="faq-category">Lecture</span>
                    <span class="faq-toggle">+</span>
                </div>
                <div class="faq-answer">
                    <p>La plupart des livres sont payants (à prix très accessibles), mais nous proposons aussi une sélection de livres gratuits via notre compte officiel "TAKA Gratuit" pour vous permettre de découvrir de nouveaux auteurs.</p>
                </div>
            </div>

            <div class="faq-item" data-category="Lecture">
                <div class="faq-question">
                    <span>Puis-je lire sans connexion internet ?</span>
                    <span class="faq-category">Lecture</span>
                    <span class="faq-toggle">+</span>
                </div>
                <div class="faq-answer">
                    <p>Oui, une fois le livre acheté, vous pouvez l'ajouter à votre mode lecture hors ligne dans l'application TAKA.</p>
                </div>
            </div>

            <!-- Paiement -->
            <div class="faq-item" data-category="Paiement">
                <div class="faq-question">
                    <span>Comment payer sur TAKA ?</span>
                    <span class="faq-category">Paiement</span>
                    <span class="faq-toggle">+</span>
                </div>
                <div class="faq-answer">
                    <p>Nous acceptons plusieurs moyens de paiement sécurisés :</p>
                    <ul>
                        <li>Mobile Money (Orange, MTN, Moov, Wave…)</li>
                        <li>Carte bancaire (Visa, Mastercard)</li>
                    </ul>
                </div>
            </div>

            <!-- Sécurité -->
            <div class="faq-item" data-category="Sécurité">
                <div class="faq-question">
                    <span>Mon paiement est-il sécurisé ?</span>
                    <span class="faq-category">Sécurité</span>
                    <span class="faq-toggle">+</span>
                </div>
                <div class="faq-answer">
                    <p>Oui. Toutes les transactions sont protégées par un cryptage SSL et gérées par des partenaires de paiement reconnus. TAKA ne conserve jamais vos informations bancaires.</p>
                </div>
            </div>

            <!-- Offrir -->
            <div class="faq-item" data-category="Offrir">
                <div class="faq-question">
                    <span>Est-ce que je peux offrir un livre à quelqu'un ?</span>
                    <span class="faq-category">Offrir</span>
                    <span class="faq-toggle">+</span>
                </div>
                <div class="faq-answer">
                    <p>Oui ! Vous pouvez acheter un livre et l'envoyer directement à un ami via son compte TAKA ou par email.</p>
                </div>
            </div>

            <!-- Support -->
            <div class="faq-item" data-category="Support">
                <div class="faq-question">
                    <span>Comment signaler un problème ou un bug ?</span>
                    <span class="faq-category">Support</span>
                    <span class="faq-toggle">+</span>
                </div>
                <div class="faq-answer">
                    <p>Vous pouvez contacter notre support 24h/24.</p>
                </div>
            </div>

            <!-- Compte -->
            <div class="faq-item" data-category="Compte">
                <div class="faq-question">
                    <span>Que faire si je perds l'accès à mon compte ?</span>
                    <span class="faq-category">Compte</span>
                    <span class="faq-toggle">+</span>
                </div>
                <div class="faq-answer">
                    <p>Pas de panique. Utilisez la fonction "Mot de passe oublié" ou contactez notre support pour récupérer l'accès à votre bibliothèque.</p>
                </div>
            </div>
        </div>

        <!-- Contact CTA -->
        <div class="faq-contact-cta">
            <div class="cta-icon">💬</div>
            <h3>Vous ne trouvez pas votre réponse ?</h3>
            <p>Notre équipe est là pour vous aider 24h/24</p>
            <a href="{{ route('contact') }}" class="btn-contact">Nous contacter</a>
        </div>
    </div>
</div>

@push('styles')
<style>
.faq-page {
    background: #F9FAFB;
    min-height: calc(100vh - 200px);
    padding: 40px 20px;
}

.container {
    max-width: 1280px;
    margin: 0 auto;
}

.faq-header {
    background: linear-gradient(135deg, #60A5FA 0%, #2563EB 100%);
    padding: 48px 24px;
    border-radius: 16px;
    text-align: center;
    color: white;
    margin-bottom: 24px;
}

.faq-header-icon {
    font-size: 48px;
    margin-bottom: 16px;
}

.faq-header h1 {
    font-size: 24px;
    font-weight: 700;
    margin-bottom: 8px;
}

.faq-header p {
    font-size: 16px;
    opacity: 0.95;
}

.faq-filter {
    display: flex;
    gap: 12px;
    margin-bottom: 24px;
    overflow-x: auto;
    padding-bottom: 8px;
}

.filter-chip {
    padding: 12px 20px;
    border: 1px solid #D1D5DB;
    background: white;
    border-radius: 25px;
    cursor: pointer;
    font-size: 14px;
    white-space: nowrap;
    transition: all 0.2s;
}

.filter-chip:hover {
    border-color: #2563EB;
}

.filter-chip.active {
    background: #DBEAFE;
    border-color: #2563EB;
    color: #2563EB;
    font-weight: 600;
}

.faq-list {
    margin-bottom: 24px;
}

.faq-item {
    background: white;
    border-radius: 12px;
    margin-bottom: 12px;
    box-shadow: 0 1px 5px rgba(0,0,0,0.1);
    overflow: hidden;
}

.faq-item.hidden {
    display: none;
}

.faq-question {
    padding: 20px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    cursor: pointer;
    font-weight: 700;
    font-size: 16px;
    color: #111827;
    position: relative;
}

.faq-question:hover {
    background: #F9FAFB;
}

.faq-category {
    position: absolute;
    top: 4px;
    right: 50px;
    padding: 4px 8px;
    background: #DBEAFE;
    color: #2563EB;
    border-radius: 5px;
    font-size: 12px;
    font-weight: 500;
}

.faq-toggle {
    font-size: 24px;
    color: #2563EB;
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
    padding: 0 20px 20px;
    max-height: 2000px;
}

.faq-answer p {
    font-size: 14px;
    color: #374151;
    line-height: 1.5;
    margin-bottom: 12px;
}

.faq-answer ul {
    font-size: 14px;
    color: #374151;
    line-height: 1.8;
    margin-left: 20px;
    margin-bottom: 12px;
}

.faq-answer li {
    margin-bottom: 8px;
}

.faq-answer strong {
    font-weight: 600;
    color: #111827;
}

.faq-contact-cta {
    background: linear-gradient(135deg, #FB923C 0%, #F97316 100%);
    padding: 32px;
    border-radius: 16px;
    text-align: center;
    color: white;
}

.cta-icon {
    font-size: 32px;
    margin-bottom: 12px;
}

.faq-contact-cta h3 {
    font-size: 18px;
    font-weight: 700;
    margin-bottom: 8px;
}

.faq-contact-cta p {
    font-size: 14px;
    margin-bottom: 16px;
    opacity: 0.95;
}

.btn-contact {
    display: inline-block;
    padding: 12px 24px;
    background: white;
    color: #F97316;
    text-decoration: none;
    border-radius: 8px;
    font-weight: 600;
    font-size: 16px;
    transition: transform 0.2s;
}

.btn-contact:hover {
    transform: translateY(-2px);
}

@media (max-width: 768px) {
    .faq-header h1 {
        font-size: 18px;
    }
    
    .faq-header p {
        font-size: 14px;
    }
    
    .faq-question {
        font-size: 14px;
        padding: 16px;
    }
    
    .faq-category {
        display: none;
    }
    
    .faq-answer {
        font-size: 13px;
    }
}
</style>
@endpush

@push('scripts')
<script>
document.addEventListener('DOMContentLoaded', function() {
    const filterChips = document.querySelectorAll('.filter-chip');
    const faqItems = document.querySelectorAll('.faq-item');
    
    filterChips.forEach(chip => {
        chip.addEventListener('click', function() {
            const category = this.dataset.category;
            
            // Update active state
            filterChips.forEach(c => c.classList.remove('active'));
            this.classList.add('active');
            
            // Filter FAQ items
            faqItems.forEach(item => {
                if (category === 'Tous' || item.dataset.category === category) {
                    item.classList.remove('hidden');
                } else {
                    item.classList.add('hidden');
                }
            });
        });
    });
    
    // Toggle FAQ items
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
