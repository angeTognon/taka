@extends('layouts.app')

@section('title', 'TAKA - Accueil')

@section('content')
<div class="home-page">
    <!-- Hero Section -->
    <section class="hero-section">
        <div class="hero-container">
            <h1 class="hero-title">
            Lis pour comprendre, <span class="hero-title-orange">Pense librement</span>.<br>
            Progresse autrement.
            </h1>
            <p class="hero-subtitle">
            Livres africains, internationaux et rares. Gratuit ou premium. <br>Lis sur ton téléphone. Publie ton livre. Gagne.
            </p>
            <div class="hero-actions">
                <a href="{{ route('explore') }}" class="btn-cta btn-cta-primary">
                    <span>📚</span>
                    Lire des livres maintenant
                </a>
                <a href="{{ route(auth()->check() ? 'publish' : 'login') }}" class="btn-cta btn-cta-black">
                    <span>▶️</span>
                    Publier mon livre
                </a>
                <a href="{{ route(auth()->check() ? 'subscription' : 'login') }}" class="btn-cta btn-cta-outline">
                    Découvrir les abonnements
                </a>
            </div>
        </div>
    </section>

    <!-- Advantages Section -->
    <section class="advantages-section">
        <div class="container">
            <h2 class="section-title">Pourquoi lire sur TAKA ?</h2>
            <div class="advantages-grid">
                <div class="advantage-card">
                    <div class="advantage-icon" style="background: #F9FAFB;">
                        <span style="color: #FB923C; font-size: 36px;">📚</span>
                    </div>
                    <h3>Un large choix de livres</h3>
                    <p>Romans, business, argent, psychologie, spiritualité, histoire, développement personnel…</p>
                </div>
                <div class="advantage-card">
                    <div class="advantage-icon" style="background: #FFF1F3;">
                        <span style="color: #F472B6; font-size: 36px;">❤️</span>
                    </div>
                    <h3>Lecture gratuite</h3>
                    <p>Accès à des livres 100% gratuits via notre Bibliothèque Libre</p>
                </div>
                <div class="advantage-card">
                    <div class="advantage-icon" style="background: #F0FDF4;">
                        <span style="color: #10B981; font-size: 36px;">📱</span>
                    </div>
                    <h3>Paiement mobile & simple</h3>
                    <p>Orange Money, MTN, Wave ou carte bancaire. Tu paies facilement directement depuis ton téléphone. </p>
                </div>
                <div class="advantage-card">
                    <div class="advantage-icon" style="background: #F1F5FE;">
                        <span style="color: #2563EB; font-size: 36px;">🛡️</span>
                    </div>
                    <h3>Lecture 100% sécurisée</h3>
                    <p>Tu lis directement sur TAKA, via un lecteur intégré, pour protéger le contenu et soutenir les auteurs.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Ways to Read Section -->
    <section class="ways-section">
        <div class="container">
            <h2 class="section-title">3 façons de lire sur TAKA</h2>
            <div class="ways-grid">
                <div class="way-card">
                    <div class="way-icon" style="background: #D1FAE5;">
                        <span style="color: #10B981; font-size: 40px;">📖</span>
                    </div>
                    <div class="way-card-content">
                        <h3>Lire gratuitement</h3>
                        <p>Accède à une sélection de livres offerts par leurs auteurs. Découvre, explore et commence à lire sans payer.</p>
                        <a href="{{ route('explore') }}" class="way-link" style="color: #10B981;">
                            Découvrir les livres gratuits →
                        </a>
                    </div>
                </div>
                <div class="way-card">
                    <div class="way-icon" style="background: #DBEAFE;">
                        <span style="color: #2563EB; font-size: 40px;">💻</span>
                    </div>
                    <div class="way-card-content">
                        <h3>Acheter un livre</h3>
                        <p>Un livre t'intéresse ? Achète-le une seule fois et lis-le directement sur TAKA.</p>
                        <a href="{{ route('explore') }}" class="way-link" style="color: #2563EB;">
                            Parcourir le catalogue →
                        </a>
                    </div>
                </div>
                <div class="way-card">
                    <div class="way-icon" style="background: #F3E8FF;">
                        <span style="color: #8B5CF6; font-size: 40px;">👥</span>
                    </div>
                    <div class="way-card-content">
                        <h3>S'abonner et lire sans limite </h3>
                        <p>Accède à une large sélection de livres premium et rares, sans te poser de questions.
                        </p>
                        <a href="{{ route('subscription') }}" class="way-link" style="color: #8B5CF6;">
                            Choisir un forfait →
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Publish CTA Section -->
    <section class="publish-cta-section">
        <div class="container">
            <div class="publish-cta-content">
                <div class="publish-cta-text">
                    <h2 class="publish-cta-title">Tu écris ? Publie et gagne avec TAKA</h2>
                    <p class="publish-cta-subtitle">Ton livre mérite d'être lu. TAKA te donne une plateforme pour publier simplement et toucher tes revenus.</p>
                    
                    <div class="publish-features">
                        <div class="publish-feature">
                            <div class="publish-feature-icon" style="background: #DBEAFE;">
                                <span style="color: #2563EB; font-size: 32px;">✍️</span>
                            </div>
                            <div class="publish-feature-content">
                                <h3>Publie librement</h3>
                                <p>Gratuit ou payant, c'est toi qui choisis.</p>
                            </div>
                        </div>
                        
                        <div class="publish-feature">
                            <div class="publish-feature-icon" style="background: #D1FAE5;">
                                <span style="color: #10B981; font-size: 32px;">💰</span>
                            </div>
                            <div class="publish-feature-content">
                                <h3>Monétise facilement</h3>
                                <p>Fixe ton prix. Reçois tes revenus.</p>
                            </div>
                        </div>
                        
                        <div class="publish-feature">
                            <div class="publish-feature-icon" style="background: #FEF3C7;">
                                <span style="color: #F59E0B; font-size: 32px;">⚡</span>
                            </div>
                            <div class="publish-feature-content">
                                <h3>Zéro technique</h3>
                                <p>TAKA gère tout pour toi.</p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="publish-cta-action">
                        <a href="{{ route(auth()->check() ? 'publish' : 'login') }}" class="btn-publish-cta">
                            Publier mon livre maintenant →
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Trending Books Section -->
    <section class="trending-section">
        <div class="container">
            <div class="trending-header">
                <h2 class="section-title-inline">Livres en tendance</h2>
                <a href="{{ route('explore') }}" class="see-all-link">
                    Voir tout →
                </a>
            </div>
            <div class="books-grid">
                @if(empty($trendingBooks))
                    <div class="loading">Aucun livre en tendance pour le moment.</div>
                @else
                    @foreach($trendingBooks as $book)
                        @php
                            $bookId = is_numeric($book['id'] ?? null) ? (int)$book['id'] : 0;
                            $title = $book['title'] ?? '';
                            $author = $book['author'] ?? '';
                            $summary = $book['summary'] ?? '';
                            $genre = $book['genre'] ?? '';
                            $price = $book['price'] ?? '';
                            $priceType = strtolower($book['price_type'] ?? '');
                            $pages = is_numeric($book['pages'] ?? null) ? (int)$book['pages'] : 0;
                            $rating = is_numeric($book['rating'] ?? null) ? (float)$book['rating'] : 0.0;
                            $isBestseller = ($book['isBestseller'] ?? false) === true;
                            
                            $coverPath = $book['cover_path'] ?? '';
                            $imageUrl = '';
                            if (!empty($coverPath)) {
                                if (str_starts_with($coverPath, 'http')) {
                                    $imageUrl = $coverPath;
                                } else {
                                    $imageUrl = 'https://takaafrica.com/pharmaRh/taka/' . $coverPath;
                                }
                            }
                            
                            // Générer le slug pour l'URL
                            $slug = \App\Helpers\BookHelper::titleToSlug($title);
                            
                            // Formatage du prix
                            $displayPrice = 'Gratuit';
                            if ($priceType !== 'gratuit' && !empty($price) && is_numeric($price)) {
                                $displayPrice = number_format((float)$price, 0, ',', ' ') . ' FCFA';
                            }
                        @endphp
                        
                        <div class="book-card">
                            <div class="book-cover-wrapper">
                                @if(!empty($imageUrl))
                                    <img src="{{ $imageUrl }}" alt="{{ $title }}">
                                @else
                                    <div style="display: flex; align-items: center; justify-content: center; height: 100%; color: #9CA3AF; font-size: 48px;">📚</div>
                                @endif
                                
                                <div class="book-badges">
                                    @if($isBestseller)
                                        <span class="book-badge bestseller">Best-seller</span>
                                    @endif
                                    <span class="book-badge {{ $priceType === 'gratuit' ? 'free' : 'paid' }}">
                                        {{ strtoupper($priceType ?: 'PAYANT') }}
                                    </span>
                                </div>
                                
                                <div class="book-favorite">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#6B7280" stroke-width="2">
                                        <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/>
                                    </svg>
                                </div>
                            </div>
                            
                            <div class="book-info">
                                <h3 class="book-title">{{ $title }}</h3>
                                <p class="book-description">{{ $summary }}</p>
                                
                                <div class="book-meta">
                                    <span class="book-genre">{{ $genre }}</span>
                                    <div class="book-rating">
                                        <span>⭐</span>
                                        <span>{{ number_format($rating, 1) }}</span>
                                    </div>
                                </div>
                                
                                <div class="book-price-row">
                                    <span class="book-price">{{ $displayPrice }}</span>
                                    <span class="book-pages">{{ $pages }} pages</span>
                                </div>
                                
                                <div class="book-actions">
                                    <a href="{{ route('book.show', $slug) }}" class="book-btn book-btn-outline">Détails</a>
                                    <a href="{{ route('book.show', $slug) }}" class="book-btn book-btn-primary">
                                        {{ $priceType === 'gratuit' ? 'Lire' : 'Acheter' }}
                                    </a>
                                </div>
                            </div>
                        </div>
                    @endforeach
                @endif
            </div>
        </div>
    </section>

    <!-- Testimonials Section -->
    <section class="testimonials-section">
        <div class="container">
            <h2 class="section-title">Ce qu'ils disent de TAKA</h2>
            <div class="testimonials-grid">
                <div class="testimonial-card">
                    <div class="testimonial-header">
                        <div class="testimonial-avatar">
                            <img src="{{ asset('images/images/aminata.png') }}" alt="Alex Konate">
                        </div>
                        <div class="testimonial-info">
                            <h4>Alex Konate</h4>
                        </div>
                    </div>
                    <p class="testimonial-quote">
                        "Sur TAKA, j'ai découvert des livres puissants que je n'aurais jamais trouvés ailleurs. On lit gratuitement, puis on a envie d'aller plus loin. C'est devenu mon espace de lecture quotidien."
                    </p>
                </div>
                <div class="testimonial-card">
                    <div class="testimonial-header">
                        <div class="testimonial-avatar">
                            <img src="{{ asset('images/images/Amina Dambaba.jpg') }}" alt="Amina Dambaba">
                        </div>
                        <div class="testimonial-info">
                            <h4>Amina Dambaba</h4>
                        </div>
                    </div>
                    <p class="testimonial-quote">
                        "J'adore ! Je suis une grande passionnée d'écriture, je vis d'ailleurs de l'écriture. Voir une plateforme qui met en avant les écrivains africains, c'est vraiment intéressant. De plus, la plateforme est très facile à comprendre, tout y est, sans parler de l'abonnement qui est très accessible."
                    </p>
                </div>
                <div class="testimonial-card">
                    <div class="testimonial-header">
                        <div class="testimonial-avatar">
                            <img src="{{ asset('images/images/Habib Hountchegnon.jpg') }}" alt="Habib Hountchegnon">
                        </div>
                        <div class="testimonial-info">
                            <h4>Habib Hountchegnon</h4>
                        </div>
                    </div>
                    <p class="testimonial-quote">
                        "Publier sur TAKA a tout changé pour moi. J'ai gagné en visibilité et mes livres se vendent mieux. La plateforme est simple et respecte vraiment les auteurs."
                    </p>
                </div>
            </div>
        </div>
    </section>

    <!-- Final CTA Section -->
    <section class="final-cta-section">
        <div class="container">
            <h2>Rejoins la révolution littéraire TAKA</h2>
            <p>Plus de 50 000 lecteurs nous font déjà confiance. Et vous ?</p>
            <a href="{{ route('explore') }}" class="btn-cta-white">Commencer maintenant</a>
        </div>
    </section>
</div>

@push('styles')
<style>
.home-page {
    width: 100%;
}

/* Hero Section */
.hero-section {
    background: linear-gradient(135deg, #F9FAFB 0%, #FFFFFF 100%);
    padding: 80px 20px;
    display: flex;
    justify-content: center;
}

.hero-container {
    max-width: 1280px;
    width: 100%;
    text-align: center;
}

.hero-title {
    font-size: 48px;
    font-weight: 700;
    color: #111827;
    line-height: 1.1;
    margin-bottom: 24px;
    font-family: 'Inter', sans-serif;
}

.hero-title-orange {
    color: #F97316;
}

.hero-subtitle {
    font-size: 17px;
    color: #6B7280;
    line-height: 1.5;
    max-width: 66.67%;
    margin: 0 auto 48px;
}

.hero-actions {
    display: flex;
    gap: 16px;
    justify-content: center;
    flex-wrap: wrap;
}

.btn-cta {
    padding: 25px 42px;
    border-radius: 8px;
    font-size: 15px;
    font-weight: 500;
    text-decoration: none;
    display: inline-flex;
    align-items: center;
    gap: 8px;
    transition: all 0.2s;
    border: none;
    cursor: pointer;
}

.btn-cta-primary {
    background: #F97316;
    color: white;
}

.btn-cta-primary:hover {
    background: #EA580C;
}

.btn-cta-black {
    background: #000000;
    color: white;
}

.btn-cta-black:hover {
    background: #1F2937;
}

.btn-cta-outline {
    background: transparent;
    color: #F97316;
    border: 2px solid #F97316;
}

.btn-cta-outline:hover {
    background: #F97316;
    color: white;
}

.btn-cta-white {
    background: white;
    color: #F97316;
    padding: 22px 32px;
    border-radius: 8px;
    font-size: 16px;
    font-weight: 600;
    text-decoration: none;
    display: inline-block;
    transition: all 0.2s;
}

.btn-cta-white:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
}

/* Advantages Section */
.advantages-section {
    background: #F9FAFB;
    padding: 80px 40px;
}

.section-title {
    font-size: 30px;
    font-weight: 700;
    color: #111827;
    text-align: center;
    margin-bottom: 48px;
}

.advantages-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 24px;
    max-width: 1280px;
    margin: 0 auto;
}

.advantage-card {
    text-align: center;
}

.advantage-icon {
    width: 72px;
    height: 72px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 0 auto 24px;
}

.advantage-card h3 {
    font-size: 18px;
    font-weight: 700;
    color: #111827;
    margin-bottom: 10px;
}

.advantage-card p {
    font-size: 16px;
    color: #6B7280;
    line-height: 1.5;
}

/* Ways Section */
.ways-section {
    background: #F9FAFB;
    padding: 80px 40px;
}

/* Publish CTA Section */
.publish-cta-section {
    padding: 80px 40px;
    background: linear-gradient(135deg, #667EEA 0%, #764BA2 100%);
    color: white;
}

.publish-cta-content {
    max-width: 1200px;
    margin: 0 auto;
    text-align: center;
}

.publish-cta-title {
    font-size: 30px;
    font-weight: 700;
    margin-bottom: 20px;
    color: white;
    line-height: 1.2;
}

.publish-cta-subtitle {
    font-size: 17px;
    margin-bottom: 48px;
    color: rgba(255, 255, 255, 0.95);
    line-height: 1.6;
    max-width: 700px;
    margin-left: auto;
    margin-right: auto;
}

.publish-features {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
    gap: 32px;
    margin-bottom: 48px;
    max-width: 1000px;
    margin-left: auto;
    margin-right: auto;
}

.publish-feature {
    display: flex;
    flex-direction: column;
    align-items: center;
    text-align: center;
    background: rgba(255, 255, 255, 0.1);
    backdrop-filter: blur(10px);
    padding: 32px 24px;
    border-radius: 16px;
    border: 1px solid rgba(255, 255, 255, 0.2);
    transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.publish-feature:hover {
    transform: translateY(-5px);
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
    background: rgba(255, 255, 255, 0.15);
}

.publish-feature-icon {
    width: 80px;
    height: 80px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    margin-bottom: 20px;
}

.publish-feature-content h3 {
    font-size: 18px;
    font-weight: 600;
    margin-bottom: 8px;
    color: white;
}

.publish-feature-content p {
    font-size: 16px;
    color: rgba(255, 255, 255, 0.9);
    line-height: 1.5;
    margin: 0;
}

.publish-cta-action {
    margin-top: 40px;
}

.btn-publish-cta {
    display: inline-flex;
    align-items: center;
    gap: 12px;
    padding: 18px 40px;
    background: white;
    color: #667EEA;
    font-size: 18px;
    font-weight: 600;
    border-radius: 12px;
    text-decoration: none;
    transition: transform 0.3s ease, box-shadow 0.3s ease;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
}

.btn-publish-cta:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(0, 0, 0, 0.3);
}

.ways-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 36px;
    max-width: 1280px;
    margin: 0 auto;
}

.way-card {
    background: white;
    padding: 40px 24px;
    border-radius: 20px;
    box-shadow: 0 2px 12px rgba(0,0,0,0.06);
    text-align: center;
    display: flex;
    flex-direction: column;
    align-items: center;
}

.way-icon {
    width: 80px;
    height: 80px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 0 auto 32px;
}

.way-card-content {
    flex: 1;
    display: flex;
    flex-direction: column;
}

.way-card-content h3 {
    font-size: 18px;
    font-weight: 700;
    color: #111827;
    margin-bottom: 18px;
}

.way-card-content p {
    font-size: 16px;
    color: #6B7280;
    line-height: 1.5;
    margin-bottom: 24px;
}

.way-link {
    font-size: 16px;
    font-weight: 700;
    text-decoration: none;
    display: inline-flex;
    align-items: center;
    gap: 6px;
}

/* Trending Section */
.trending-section {
    background: white;
    padding: 80px 100px;
}

.trending-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 48px;
}

.section-title-inline {
    font-size: 28px;
    font-weight: 700;
    color: #111827;
}

.see-all-link {
    font-size: 16px;
    font-weight: 600;
    color: #F97316;
    text-decoration: none;
    display: flex;
    align-items: center;
    gap: 4px;
}

.books-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 24px;
}

.book-card {
    background: white;
    border-radius: 12px;
    box-shadow: 0 1px 8px rgba(0,0,0,0.06);
    overflow: hidden;
    transition: transform 0.2s, box-shadow 0.2s;
}

.book-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 4px 12px rgba(0,0,0,0.1);
}

.book-cover-wrapper {
    position: relative;
    height: 370px;
    background: #E5E7EB;
    overflow: hidden;
}

.book-cover-wrapper img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.book-badges {
    position: absolute;
    top: 8px;
    right: 8px;
    display: flex;
    flex-direction: column;
    gap: 4px;
}

.book-badge {
    padding: 4px 8px;
    font-size: 10px;
    font-weight: 600;
    color: white;
    white-space: nowrap;
}

.book-badge.bestseller {
    background: red;
    border-radius: 12px;
    margin-bottom: 4px;
}

.book-badge.free {
    background: #F97316;
    border-radius: 5px;
}

.book-badge.paid {
    background: #009F38;
    border-radius: 5px;
}

.book-favorite {
    position: absolute;
    top: 8px;
    left: 8px;
    width: 20px;
    height: 20px;
    color: #6B7280;
}

.book-info {
    padding: 16px;
}

.book-title {
    font-size: 16px;
    font-weight: 600;
    color: #111827;
    margin-bottom: 8px;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
}

.book-description {
    font-size: 12px;
    color: #6B7280;
    margin-bottom: 8px;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
}

.book-meta {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 8px;
}

.book-genre {
    padding: 4px 8px;
    background: #F3F4F6;
    border-radius: 4px;
    font-size: 10px;
    color: #6B7280;
}

.book-rating {
    display: flex;
    align-items: center;
    gap: 4px;
    font-size: 14px;
    font-weight: 500;
    color: #111827;
}

.book-rating span:first-child {
    color: #FBBF24;
    font-size: 14px;
}

.book-price-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 12px;
}

.book-price {
    font-size: 15px;
    font-weight: 700;
    color: #088525;
}

.book-pages {
    font-size: 12px;
    color: #6B7280;
}

.book-actions {
    display: flex;
    gap: 8px;
}

.book-btn {
    flex: 1;
    padding: 8px;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 500;
    text-align: center;
    text-decoration: none;
    border: none;
    cursor: pointer;
    transition: all 0.2s;
}

.book-btn-outline {
    background: white;
    color: #F97316;
    border: 1px solid #F97316;
}

.book-btn-outline:hover {
    background: #F97316;
    color: white;
}

.book-btn-primary {
    background: #F97316;
    color: white;
}

.book-btn-primary:hover {
    background: #EA580C;
}

/* Testimonials Section */
.testimonials-section {
    background: #F9FAFB;
    padding: 80px 20px;
}

.section-subtitle {
    font-size: 17px;
    color: #6B7280;
    text-align: center;
    margin-bottom: 64px;
}

.testimonials-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 32px;
    max-width: 1280px;
    margin: 0 auto;
}

.testimonial-card {
    background: white;
    padding: 32px;
    border-radius: 12px;
    box-shadow: 0 1px 8px rgba(0,0,0,0.06);
}

.testimonial-header {
    display: flex;
    align-items: center;
    gap: 16px;
    margin-bottom: 16px;
}

.testimonial-avatar {
    width: 48px;
    height: 48px;
    border-radius: 50%;
    overflow: hidden;
    background: #E5E7EB;
}

.testimonial-avatar img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.testimonial-info h4 {
    font-size: 16px;
    font-weight: 600;
    color: #111827;
    margin-bottom: 4px;
}

.testimonial-info p {
    font-size: 14px;
    color: #6B7280;
}

.testimonial-quote {
    font-size: 16px;
    color: #374151;
    font-style: italic;
    line-height: 1.5;
}

/* Final CTA Section */
.final-cta-section {
    background: linear-gradient(135deg, #F97316 0%, #FB923C 100%);
    padding: 80px 20px;
    text-align: center;
    color: white;
}

.final-cta-section h2 {
    font-size: 30px;
    font-weight: 700;
    margin-bottom: 18px;
}

.final-cta-section p {
    font-size: 20px;
    color: #FED7AA;
    margin-bottom: 24px;
}

.loading {
    text-align: center;
    padding: 40px;
    color: #6B7280;
    grid-column: 1 / -1;
}

/* Responsive */
@media (max-width: 1024px) {
    .advantages-grid,
    .ways-grid {
        grid-template-columns: repeat(2, 1fr);
    }
    
    .books-grid {
        grid-template-columns: repeat(2, 1fr);
    }
    
    .trending-section {
        padding: 80px 40px;
    }
}

@media (max-width: 768px) {
    .hero-title {
        font-size: 24px;
    }
    
    .hero-subtitle {
        max-width: 100%;
        font-size: 15px;
    }
    
    .hero-actions {
        flex-direction: column;
        align-items: stretch;
    }
    
    .btn-cta {
        width: 100%;
        justify-content: center;
        padding: 15px 20px;
    }
    
    .section-title {
        font-size: 18px;
        margin-bottom: 32px;
    }
    
    .advantages-section,
    .ways-section,
    .publish-cta-section,
    .trending-section,
    .testimonials-section {
        padding: 40px 16px;
    }
    
    .publish-cta-title {
        font-size: 18px;
    }
    
    .publish-cta-subtitle {
        font-size: 15px;
        margin-bottom: 40px;
    }
    
    .publish-features {
        grid-template-columns: 1fr;
        gap: 24px;
        margin-bottom: 40px;
    }
    
    .publish-feature {
        padding: 24px 20px;
    }
    
    .publish-feature-content h3 {
        font-size: 18px;
    }
    
    .publish-feature-content p {
        font-size: 15px;
    }
    
    .btn-publish-cta {
        padding: 16px 32px;
        font-size: 15px;
    }
    
    .advantages-grid {
        grid-template-columns: 1fr;
        gap: 18px;
    }
    
    .ways-grid {
        grid-template-columns: 1fr;
        gap: 14px;
    }
    
    .ways-grid .way-card {
        display: flex;
        align-items: flex-start;
        gap: 16px;
        text-align: left;
        padding: 20px 16px;
        background: white;
    }
    
    .way-icon {
        width: 60px;
        height: 60px;
        margin: 0;
        flex-shrink: 0;
        border-radius: 50%;
    }
    
    .way-icon span {
        font-size: 32px;
    }
    
    .way-card-content {
        flex: 1;
        display: flex;
        flex-direction: column;
    }
    
    .way-card-content h3 {
        font-size: 18px;
        margin-bottom: 8px;
        font-weight: 700;
        color: #111827;
    }
    
    .way-card-content p {
        font-size: 15px;
        margin-bottom: 12px;
        line-height: 1.5;
        color: #374151;
    }
    
    .way-link {
        font-size: 15px;
        font-weight: 700;
        margin-top: auto;
        align-self: flex-start;
    }
    
    .trending-header {
        flex-direction: column;
        align-items: flex-start;
        gap: 16px;
    }
    
    .section-title-inline {
        font-size: 15px;
    }
    
    .books-grid {
        grid-template-columns: 1fr;
        gap: 18px;
    }
    
    .book-card {
        display: flex;
        gap: 12px;
    }
    
    .book-cover-wrapper {
        width: 90px;
        height: 130px;
        flex-shrink: 0;
        border-radius: 12px 0 0 12px;
    }
    
    .book-info {
        flex: 1;
        padding: 12px;
    }
    
    .testimonials-grid {
        grid-template-columns: 1fr;
        gap: 10px;
    }
    
    .testimonial-card {
        padding: 18px;
    }
    
    .final-cta-section {
        padding: 40px 16px;
    }
    
    .final-cta-section h2 {
        font-size: 14px;
    }
    
    .final-cta-section p {
        font-size: 15px;
    }
}
</style>
@endpush

@endsection
