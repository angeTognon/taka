@extends('layouts.app')

@section('title', 'À propos - TAKA')

@section('content')
<div class="about-page">
    <!-- Hero Section -->
    <section class="hero-section">
        <div class="hero-content">
            <div class="hero-icon">📚</div>
            <h1>À propos de TAKA</h1>
            <p>La première plateforme littéraire panafricaine qui donne du pouvoir aux lecteurs… et de la liberté aux auteurs.</p>
            <div class="hero-underline"></div>
        </div>
    </section>

    <!-- Stats Section -->
    <section class="stats-section">
        <div class="container">
            <div class="stats-grid">
                <div class="stat-item">
                    <div class="stat-icon">📖</div>
                    <div class="stat-number">+1.000</div>
                    <div class="stat-label">Livres disponibles</div>
                </div>
                <div class="stat-item">
                    <div class="stat-icon">🌍</div>
                    <div class="stat-number">Toute</div>
                    <div class="stat-label">l'Afrique</div>
                </div>
                <div class="stat-item">
                    <div class="stat-icon">👥</div>
                    <div class="stat-number">Jeunes</div>
                    <div class="stat-label">Lecteurs passionnés</div>
                </div>
                <div class="stat-item">
                    <div class="stat-icon">📱</div>
                    <div class="stat-number">100%</div>
                    <div class="stat-label">Mobile Money</div>
                </div>
            </div>
        </div>
    </section>

    <!-- What is TAKA -->
    <section class="what-is-section">
        <div class="container">
            <h2>TAKA, c'est bien plus qu'une bibliothèque numérique</h2>
            <div class="features-grid">
                <div class="feature-card">
                    <div class="feature-icon">🌍</div>
                    <h3>Un mouvement culturel</h3>
                    <p>Révéler la richesse littéraire africaine au monde entier</p>
                </div>
                <div class="feature-card">
                    <div class="feature-icon">🚀</div>
                    <h3>Une révolution éditoriale</h3>
                    <p>Démocratiser l'accès à l'édition pour tous les auteurs africains</p>
                </div>
                <div class="feature-card">
                    <div class="feature-icon">📚</div>
                    <h3>Une nouvelle ère</h3>
                    <p>Transformer la lecture et l'auto-édition en Afrique</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Origin Section -->
    <section class="origin-section">
        <div class="container">
            <h2>🌍 L'Origine de TAKA</h2>
            <div class="origin-content">
                <p>L'idée de TAKA est née d'un constat : Les livres africains sont souvent absents des rayons, oubliés des plateformes internationales, et inaccessibles à ceux qui en ont le plus besoin.</p>
                <div class="origin-quote">
                    <p>"TAKA, c'est notre voix. Notre mémoire. Notre puissance intellectuelle."</p>
                    <p class="quote-action">➡️ Publie. Sois lu. Sois payé. Sois libre.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Mission Section -->
    <section class="mission-section">
        <div class="container">
            <h2>🎯 Notre Mission</h2>
            <p>Offrir à chaque Africain, où qu'il soit, le pouvoir de lire, publier et partager sa voix avec le monde. Créer un écosystème juste, accessible et durable pour la culture africaine, par les Africains, pour les Africains.</p>
        </div>
    </section>

    <!-- Values Section -->
    <section class="values-section">
        <div class="container">
            <h2>🧭 Nos Valeurs</h2>
            <div class="values-grid">
                <div class="value-card">
                    <div class="value-icon">✨</div>
                    <h3>Autonomie</h3>
                    <p>Tu écris ? Tu publies. Tu fixes ton prix. Tu reçois tes redevances. Point. Pas d'intermédiaires obscurs.</p>
                </div>
                <div class="value-card">
                    <div class="value-icon">💬</div>
                    <h3>Écoute Active</h3>
                    <p>Chez TAKA, tu n'es jamais seul. Tu es entouré. Écouté. Soutenu. On grandit ensemble.</p>
                </div>
                <div class="value-card">
                    <div class="value-icon">🚀</div>
                    <h3>Innovation</h3>
                    <p>Paiement mobile local, lecture offline, impression à la demande… TAKA est conçu pour nos réalités.</p>
                </div>
                <div class="value-card">
                    <div class="value-icon">🌱</div>
                    <h3>Impact durable</h3>
                    <p>TAKA n'est pas une start-up de plus. C'est un projet pour les générations futures.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- CTA Section -->
    <section class="cta-section">
        <div class="container">
            <h2>Rejoins la révolution littéraire TAKA</h2>
            <p>Plus de 50 000 lecteurs nous font déjà confiance. Et vous ?</p>
            <a href="{{ route('explore') }}" class="btn-cta">Commencer maintenant</a>
        </div>
    </section>
</div>

@push('styles')
<style>
.about-page {
    background: white;
}

.hero-section {
    background: linear-gradient(135deg, #18C1C9 0%, #F97316 100%);
    padding: 80px 20px;
    text-align: center;
    color: white;
}

.hero-content {
    max-width: 800px;
    margin: 0 auto;
}

.hero-icon {
    font-size: 80px;
    margin-bottom: 24px;
}

.hero-section h1 {
    font-size: 26px;
    font-weight: 700;
    margin-bottom: 16px;
}

.hero-section p {
    font-size: 17px;
    line-height: 1.5;
    margin-bottom: 24px;
}

.hero-underline {
    width: 128px;
    height: 4px;
    background: #FFEB3B;
    border-radius: 2px;
    margin: 0 auto;
}

.stats-section {
    padding: 80px 20px;
    background: white;
}

.stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 32px;
}

.stat-item {
    text-align: center;
}

.stat-icon {
    font-size: 64px;
    margin-bottom: 16px;
}

.stat-number {
    font-size: 19px;
    font-weight: 700;
    color: #111827;
    margin-bottom: 8px;
}

.stat-label {
    font-size: 15px;
    color: #6B7280;
}

.what-is-section {
    padding: 80px 20px;
    background: linear-gradient(135deg, #F9FAFB 0%, #FFF7ED 100%);
}

.what-is-section h2 {
    font-size: 23px;
    font-weight: 700;
    text-align: center;
    margin-bottom: 64px;
    color: #111827;
}

.features-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 16px;
}

.feature-card {
    background: white;
    padding: 32px;
    border-radius: 16px;
    text-align: center;
    box-shadow: 0 4px 8px rgba(0,0,0,0.1);
}

.feature-icon {
    font-size: 48px;
    margin-bottom: 16px;
}

.feature-card h3 {
    font-size: 17px;
    font-weight: 700;
    margin-bottom: 16px;
    color: #111827;
}

.feature-card p {
    font-size: 14px;
    color: #6B7280;
    line-height: 1.5;
}

.origin-section {
    padding: 80px 20px;
    background: white;
}

.origin-section h2 {
    font-size: 23px;
    font-weight: 700;
    text-align: center;
    margin-bottom: 48px;
    color: #111827;
}

.origin-content {
    max-width: 800px;
    margin: 0 auto;
    padding: 48px;
    background: linear-gradient(135deg, #F5E0D2 0%, #E8BC97 100%);
    border-radius: 24px;
}

.origin-content > p {
    font-size: 17px;
    line-height: 1.6;
    text-align: center;
    margin-bottom: 32px;
    color: #111827;
}

.origin-quote {
    background: white;
    padding: 24px;
    border-radius: 16px;
    border-left: 4px solid #F97316;
}

.origin-quote p {
    font-size: 20px;
    font-style: italic;
    text-align: center;
    color: #111827;
    margin-bottom: 16px;
}

.quote-action {
    font-size: 18px;
    font-weight: 600;
    color: #C2410C;
    font-style: normal !important;
}

.mission-section {
    padding: 80px 20px;
    background: linear-gradient(135deg, #EA580C 0%, #F97316 100%);
    color: white;
    text-align: center;
}

.mission-section h2 {
    font-size: 23px;
    font-weight: 700;
    margin-bottom: 32px;
}

.mission-section p {
    font-size: 17px;
    line-height: 1.6;
    max-width: 800px;
    margin: 0 auto;
}

.values-section {
    padding: 80px 20px;
    background: #F9FAFB;
}

.values-section h2 {
    font-size: 23px;
    font-weight: 700;
    text-align: center;
    margin-bottom: 64px;
    color: #111827;
}

.values-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
    gap: 16px;
}

.value-card {
    background: white;
    padding: 32px;
    border-radius: 16px;
    text-align: center;
    box-shadow: 0 4px 8px rgba(0,0,0,0.1);
}

.value-icon {
    font-size: 48px;
    margin-bottom: 24px;
}

.value-card h3 {
    font-size: 18px;
    font-weight: 700;
    margin-bottom: 16px;
    color: #111827;
}

.value-card p {
    font-size: 15px;
    color: #6B7280;
    line-height: 1.5;
}

.cta-section {
    padding: 80px 20px;
    background: linear-gradient(135deg, #F97316 0%, #FB923C 100%);
    color: white;
    text-align: center;
}

.cta-section h2 {
    font-size: 25px;
    font-weight: 700;
    margin-bottom: 24px;
}

.cta-section p {
    font-size: 20px;
    margin-bottom: 32px;
    color: #FED7AA;
}

.btn-cta {
    display: inline-block;
    padding: 22px 32px;
    background: white;
    color: #F97316;
    text-decoration: none;
    border-radius: 8px;
    font-weight: 600;
    font-size: 16px;
}

@media (max-width: 768px) {
    .hero-section h1 {
        font-size: 18px;
    }
    
    .hero-section p {
        font-size: 15px;
    }
    
    .stats-grid,
    .features-grid,
    .values-grid {
        grid-template-columns: 1fr;
    }
    
    .what-is-section h2,
    .origin-section h2,
    .mission-section h2,
    .values-section h2,
    .cta-section h2 {
        font-size: 18px;
    }
    
    .what-is-section p,
    .origin-section p,
    .mission-section p,
    .origin-content p,
    .origin-quote p,
    .quote-action,
    .cta-section p {
        font-size: 15px;
    }
    
    .feature-card h3,
    .value-card h3 {
        font-size: 18px;
    }
    
    .feature-card p,
    .value-card p {
        font-size: 15px;
    }
    
    .stat-label {
        font-size: 15px;
    }
}
</style>
@endpush
@endsection

