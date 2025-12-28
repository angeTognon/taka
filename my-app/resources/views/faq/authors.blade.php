@extends('layouts.app')

@section('title', 'FAQ Auteurs - TAKA')

@section('content')
<div class="faq-page">
    <div class="container">
        <!-- Header -->
        <div class="faq-header">
            <div class="faq-header-icon">❓</div>
            <h1>Foire aux Questions AUTEURS</h1>
            <p>Tout ce que tu dois savoir pour publier, protéger et monétiser ton livre avec TAKA</p>
        </div>

        <!-- TAKA Promise -->
        <div class="faq-promise">
            <h3>🚀 TAKA ne se contente pas de publier ton livre. Elle le propulse.</h3>
            <p>Que tu sois auteur débutant ou éditeur expérimenté, TAKA t'offre des solutions publicitaires clés en main, ciblées et efficaces, pour faire rayonner ton œuvre sur toute l'Afrique… et au-delà.</p>
            <p class="promise-objective">Objectif : te faire connaître, vendre plus, et construire ta marque d'auteur solide, visible, et rentable.</p>
        </div>

        <!-- Category Filter -->
        <div class="faq-filter">
            <button class="filter-chip active" data-category="Tous">Tous</button>
            <button class="filter-chip" data-category="Publication">Publication</button>
            <button class="filter-chip" data-category="Qualité">Qualité</button>
            <button class="filter-chip" data-category="Rémunération">Rémunération</button>
            <button class="filter-chip" data-category="Promotion">Promotion</button>
            <button class="filter-chip" data-category="Technique">Technique</button>
        </div>

        <!-- FAQ List -->
        <div class="faq-list">
            <!-- Publication -->
            <div class="faq-item" data-category="Publication">
                <div class="faq-question">
                    <span>Comment publier un livre sur TAKA ?</span>
                    <span class="faq-toggle">+</span>
                </div>
                <div class="faq-answer">
                    <p>Publier sur TAKA se fait en 6 étapes rapides :</p>
                    <ol>
                        <li>Informations du livre : Catégorie, titre, résumé, prix</li>
                        <li>Fichier du livre : Upload au format Word, EPUB ou PDF</li>
                        <li>Couverture : Image JPG professionnelle (1500x2500px)</li>
                        <li>Plan de publication : Choix de l'offre (Basique, Premium, etc.)</li>
                        <li>Profil auteur : Biographie, photo, liens réseaux sociaux</li>
                        <li>Promotion : Textes d'accroche et stratégie marketing</li>
                    </ol>
                    <p>Le processus prend en moyenne 10 jours ouvrables.</p>
                </div>
            </div>

            <div class="faq-item" data-category="Publication">
                <div class="faq-question">
                    <span>Quels formats de fichiers sont acceptés ?</span>
                    <span class="faq-toggle">+</span>
                </div>
                <div class="faq-answer">
                    <p>Formats acceptés :</p>
                    <ul>
                        <li>Word (.doc/.docx) - Recommandé pour traitement rapide</li>
                        <li>PDF - Accepté mais traitement plus long</li>
                        <li>EPUB - Si disponible</li>
                    </ul>
                    <p>Couverture obligatoire :</p>
                    <ul>
                        <li>Format JPG</li>
                        <li>Dimensions : 1500x2500px</li>
                        <li>Titre et nom d'auteur lisibles</li>
                        <li>Design professionnel</li>
                    </ul>
                </div>
            </div>

            <div class="faq-item" data-category="Publication">
                <div class="faq-question">
                    <span>Puis-je publier un livre en langue africaine ?</span>
                    <span class="faq-toggle">+</span>
                </div>
                <div class="faq-answer">
                    <p>Oui, absolument !</p>
                    <p>Nous encourageons vivement la publication en langues africaines :</p>
                    <ul>
                        <li>Fon, Wolof, Lingala, Bambara, etc.</li>
                        <li>L'Afrique parle plusieurs langues</li>
                        <li>TAKA donne à chacune sa place dans notre bibliothèque</li>
                    </ul>
                    <p>L'Afrique a une richesse linguistique que nous célébrons !</p>
                </div>
            </div>

            <div class="faq-item" data-category="Publication">
                <div class="faq-question">
                    <span>Puis-je publier plusieurs livres à la fois ?</span>
                    <span class="faq-toggle">+</span>
                </div>
                <div class="faq-answer">
                    <p>Oui, tout à fait !</p>
                    <p>Si vous êtes :</p>
                    <ul>
                        <li>Éditeur avec plusieurs titres</li>
                        <li>Auteur prolifique</li>
                        <li>Maison d'édition</li>
                    </ul>
                    <p><strong>Recommandation :</strong> Soumettez vos livres en lot pour faciliter le traitement et bénéficier d'un suivi groupé.</p>
                    <p>Contactez-nous pour les soumissions multiples.</p>
                </div>
            </div>

            <!-- Qualité -->
            <div class="faq-item" data-category="Qualité">
                <div class="faq-question">
                    <span>Quels sont les critères de qualité exigés ?</span>
                    <span class="faq-toggle">+</span>
                </div>
                <div class="faq-answer">
                    <p>TAKA applique une charte qualité rigoureuse :</p>
                    <p><strong>Contenu :</strong></p>
                    <ul>
                        <li>Originalité absolue (pas de plagiat)</li>
                        <li>Utilisation IA limitée (pas 100% généré par IA)</li>
                        <li>Cohérence culturelle africaine</li>
                    </ul>
                    <p><strong>Qualité d'écriture :</strong></p>
                    <ul>
                        <li>Orthographe, grammaire parfaites</li>
                        <li>Texte clair, fluide, structuré</li>
                        <li>Mise en forme professionnelle</li>
                    </ul>
                    <p><strong>Couverture :</strong></p>
                    <ul>
                        <li>Design professionnel</li>
                        <li>Pas 100% générée par IA</li>
                        <li>Titre et auteur lisibles</li>
                    </ul>
                </div>
            </div>

            <div class="faq-item" data-category="Qualité">
                <div class="faq-question">
                    <span>Est-ce que TAKA accepte tous les livres ?</span>
                    <span class="faq-toggle">+</span>
                </div>
                <div class="faq-answer">
                    <p>Non, TAKA vise l'excellence.</p>
                    <p><strong>Processus de validation :</strong></p>
                    <ul>
                        <li>Examen éditorial rigoureux de chaque manuscrit</li>
                        <li>Évaluation qualité avant validation</li>
                        <li>Seuls les ouvrages originaux et bien rédigés sont retenus</li>
                    </ul>
                    <p><strong>Refus automatique :</strong></p>
                    <ul>
                        <li>Œuvres à caractère haineux ou discriminatoire</li>
                        <li>Contenu incitant à des comportements illégaux</li>
                        <li>Plagiat ou contenu non original</li>
                    </ul>
                    <p>Notre ambition : créer LA référence de la littérature africaine de qualité.</p>
                </div>
            </div>

            <!-- Rémunération -->
            <div class="faq-item" data-category="Rémunération">
                <div class="faq-question">
                    <span>Comment et quand vais-je recevoir mes gains ?</span>
                    <span class="faq-toggle">+</span>
                </div>
                <div class="faq-answer">
                    <p><strong>Paiements :</strong></p>
                    <ul>
                        <li>Chaque début de mois (au plus tard le 15)</li>
                        <li>Seuil minimum : 15.000 FCFA</li>
                        <li>Modes : Mobile Money (Orange, MTN, Wave) ou virement bancaire</li>
                    </ul>
                    <p><strong>Rémunération selon l'offre :</strong></p>
                    <ul>
                        <li>Offre Basique : 80% du prix de vente</li>
                        <li>Offre Premium : 50% du prix de vente</li>
                        <li>+ Programme d'affiliation disponible</li>
                    </ul>
                    <p>Si le seuil n'est pas atteint, les gains sont reportés au mois suivant.</p>
                </div>
            </div>

            <div class="faq-item" data-category="Rémunération">
                <div class="faq-question">
                    <span>Mon livre doit-il être exclusivement publié sur TAKA ?</span>
                    <span class="faq-toggle">+</span>
                </div>
                <div class="faq-answer">
                    <p>Non, contrat non exclusif :</p>
                    <ul>
                        <li>Vous restez propriétaire à 100% de vos droits</li>
                        <li>Vous pouvez vendre sur d'autres plateformes</li>
                        <li>Aucune exclusivité demandée</li>
                        <li>Aucun engagement contraignant</li>
                        <li>Liberté totale de distribution</li>
                    </ul>
                    <p>TAKA respecte votre indépendance d'auteur.</p>
                </div>
            </div>

            <!-- Promotion -->
            <div class="faq-item" data-category="Promotion">
                <div class="faq-question">
                    <span>Qu'est-ce que TAKA m'apporte en termes de visibilité ?</span>
                    <span class="faq-toggle">+</span>
                </div>
                <div class="faq-answer">
                    <p>TAKA offre une plateforme à fort trafic :</p>
                    <p><strong>Audience :</strong></p>
                    <ul>
                        <li>500.000 visiteurs mensuels sur le site</li>
                        <li>3 millions de personnes atteintes/mois sur les réseaux</li>
                        <li>Présence active : TikTok, Instagram, Facebook, WhatsApp</li>
                    </ul>
                    <p><strong>Services promotionnels :</strong></p>
                    <ul>
                        <li>Campagnes sponsorisées (Facebook/Instagram Ads)</li>
                        <li>Reels viraux et vidéos TikTok</li>
                        <li>Accompagnement marketing personnalisé</li>
                        <li>Création de visuels impactants</li>
                    </ul>
                    <p>Certains livres atteignent plus de 9 millions FCFA de CA cumulés !</p>
                </div>
            </div>

            <div class="faq-item" data-category="Promotion">
                <div class="faq-question">
                    <span>Quelles sont les différentes offres publicitaires ?</span>
                    <span class="faq-toggle">+</span>
                </div>
                <div class="faq-answer">
                    <p><strong>🟢 Offre BASIQUE :</strong></p>
                    <ul>
                        <li>Mise en ligne + réseaux sociaux</li>
                        <li>80% de rémunération auteur</li>
                        <li>+15% via programme d'affiliation</li>
                    </ul>
                    <p><strong>🔵 Offre PREMIUM :</strong></p>
                    <ul>
                        <li>Tout Basique + publicité sponsorisée</li>
                        <li>Facebook + Instagram Ads (pris en charge par TAKA)</li>
                        <li>50% de rémunération + 70% affiliation</li>
                    </ul>
                    <p><strong>🌍 WRITING BOOST :</strong></p>
                    <ul>
                        <li>Aide à l'écriture/réécriture</li>
                        <li>Coaching éditorial (40.000 FCFA)</li>
                        <li>Tous avantages Premium</li>
                    </ul>
                    <p><strong>🟣 ÉLÉGANCE INTERNATIONALE :</strong></p>
                    <ul>
                        <li>Publication TAKA + Amazon KDP</li>
                        <li>Coaching éditorial (50.000 FCFA)</li>
                        <li>Distribution mondiale</li>
                    </ul>
                </div>
            </div>

            <!-- Technique -->
            <div class="faq-item" data-category="Technique">
                <div class="faq-question">
                    <span>Mon livre sera-t-il bien protégé sur TAKA ?</span>
                    <span class="faq-toggle">+</span>
                </div>
                <div class="faq-answer">
                    <p><strong>Protection maximale :</strong></p>
                    <ul>
                        <li>Aucun téléchargement possible</li>
                        <li>Lecteur sécurisé intégré uniquement</li>
                        <li>Système de cryptage avancé</li>
                        <li>Token de lecture unique par utilisateur</li>
                    </ul>
                    <p><strong>Sécurité :</strong></p>
                    <ul>
                        <li>Empêche le piratage par fichier PDF</li>
                        <li>Pas de partage illégal sur WhatsApp/Telegram</li>
                        <li>Pas de copie ou impression sauvage</li>
                        <li>Suspension immédiate en cas de tentative de contournement</li>
                    </ul>
                    <p><strong>TAKA = Lire. Pas pirater.</strong></p>
                </div>
            </div>

            <div class="faq-item" data-category="Technique">
                <div class="faq-question">
                    <span>Combien de temps dure la publication ?</span>
                    <span class="faq-toggle">+</span>
                </div>
                <div class="faq-answer">
                    <p><strong>Délai moyen : 10 jours ouvrables</strong></p>
                    <p><strong>Facteurs influençant le délai :</strong></p>
                    <ul>
                        <li>Format du fichier (Word/EPUB = plus rapide)</li>
                        <li>Complétude du dossier</li>
                        <li>Charge de traitement</li>
                    </ul>
                    <p><strong>Conseils pour accélérer :</strong></p>
                    <ul>
                        <li>Envoyer tous les éléments en une fois</li>
                        <li>Utiliser le format Word ou EPUB</li>
                        <li>Respecter la charte qualité</li>
                    </ul>
                    <p>Vous serez informé par message/mail dès mise en ligne.</p>
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
    background: linear-gradient(135deg, #F97316 0%, #FB923C 100%);
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

.faq-promise {
    background: white;
    padding: 32px;
    border-radius: 16px;
    margin-bottom: 24px;
    box-shadow: 0 1px 10px rgba(0,0,0,0.1);
}

.faq-promise h3 {
    font-size: 18px;
    font-weight: 700;
    color: #111827;
    margin-bottom: 12px;
    text-align: center;
}

.faq-promise p {
    font-size: 14px;
    color: #374151;
    line-height: 1.5;
    text-align: center;
    margin-bottom: 12px;
}

.faq-promise .promise-objective {
    font-weight: 600;
    color: #EA580C;
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
    border-color: #F97316;
}

.filter-chip.active {
    background: #FED7AA;
    border-color: #EA580C;
    color: #EA580C;
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
}

.faq-question:hover {
    background: #F9FAFB;
}

.faq-toggle {
    font-size: 24px;
    color: #F97316;
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

.faq-answer ul,
.faq-answer ol {
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
    background: linear-gradient(135deg, #2563EB 0%, #1D4ED8 100%);
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
    color: #2563EB;
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
    
    .faq-promise h3 {
        font-size: 16px;
    }
    
    .faq-promise p {
        font-size: 13px;
    }
    
    .faq-question {
        font-size: 14px;
        padding: 16px;
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
