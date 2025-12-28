@php
    $currentRoute = Route::currentRouteName();
    $isLoggedIn = auth()->check();
    $user = auth()->user();
@endphp

<header class="header">
    <div class="header-container">
        <div class="header-content">
            <!-- Logo -->
            <a href="{{ route('home') }}" class="logo-link">
                <img src="{{ asset('images/logo.jpeg') }}" alt="TAKA" class="logo-img">
            </a>

            <!-- Desktop Navigation -->
            <nav class="desktop-nav">
                <a href="{{ route('home') }}" class="nav-link {{ $currentRoute === 'home' ? 'active' : '' }}">
                    Accueil
                </a>
                <a href="{{ route('explore') }}" class="nav-link {{ $currentRoute === 'explore' ? 'active' : '' }}">
                    Lire
                </a>
                <a href="{{ route('publish') }}" class="nav-link {{ $currentRoute === 'publish' ? 'active' : '' }}">
                    Publier
                </a>
                <a href="{{ route('subscription') }}" class="nav-link {{ $currentRoute === 'subscription' ? 'active' : '' }}">
                    Abonnement
                </a>
                
                <!-- Country Selector -->
                <div class="country-selector">
                    <select id="countryCurrency" class="country-select">
                        <option value="Bénin|XOF">🇧🇯 Bénin (XOF)</option>
                        <option value="Burkina Faso|XOF">🇧🇫 Burkina Faso (XOF)</option>
                        <option value="Côte d'Ivoire|XOF">🇨🇮 Côte d'Ivoire (XOF)</option>
                        <option value="Mali|XOF">🇲🇱 Mali (XOF)</option>
                        <option value="Niger|XOF">🇳🇪 Niger (XOF)</option>
                        <option value="Sénégal|XOF">🇸🇳 Sénégal (XOF)</option>
                        <option value="Togo|XOF">🇹🇬 Togo (XOF)</option>
                        <option value="Cameroun|XAF">🇨🇲 Cameroun (XAF)</option>
                        <option value="Nigeria|NGN">🇳🇬 Nigeria (NGN)</option>
                        <option value="Ghana|GHS">🇬🇭 Ghana (GHS)</option>
                    </select>
                </div>

                @if($isLoggedIn)
                    <!-- User Menu -->
                    <div class="user-menu-wrapper">
                        <button class="user-menu-btn" onclick="toggleUserMenu()">
                            <i class="icon-person"></i>
                            <span>{{ explode(' ', $user->name ?? 'Utilisateur')[0] }}</span>
                        </button>
                        <div id="userMenu" class="user-menu-dropdown">
                            <a href="{{ route('profile') }}" class="user-menu-item">Mon profil</a>
                            <a href="{{ route('dashboard') }}" class="user-menu-item">Tableau de bord</a>
                            <a href="{{ route('affiliate') }}" class="user-menu-item">Affiliation</a>
                            <a href="{{ route('wallet') }}" class="user-menu-item">Mon Portefeuille TAKA</a>
                            <div class="user-menu-divider"></div>
                            <form method="POST" action="{{ route('logout') }}">
                                @csrf
                                <button type="submit" class="user-menu-item logout">Se déconnecter</button>
                            </form>
                        </div>
                    </div>
                @else
                    <a href="{{ route('login') }}" class="btn-login">
                        <i class="icon-person"></i>
                        Se connecter
                    </a>
                @endif
            </nav>

            <!-- Mobile Menu Button -->
            <button class="mobile-menu-btn" onclick="toggleMobileMenu()">
                <i class="icon-menu" id="menuIcon"></i>
            </button>
        </div>

        <!-- Mobile Navigation -->
        <div id="mobileMenu" class="mobile-nav">
            <a href="{{ route('home') }}" class="mobile-nav-link {{ $currentRoute === 'home' ? 'active' : '' }}">
                Accueil
            </a>
            <a href="{{ route('explore') }}" class="mobile-nav-link {{ $currentRoute === 'explore' ? 'active' : '' }}">
                Lire
            </a>
            <a href="{{ route('publish') }}" class="mobile-nav-link {{ $currentRoute === 'publish' ? 'active' : '' }}">
                Publier
            </a>
            <a href="{{ route('subscription') }}" class="mobile-nav-link {{ $currentRoute === 'subscription' ? 'active' : '' }}">
                Abonnement
            </a>
            
            @if($isLoggedIn)
                <div class="mobile-user-section">
                    <p>Connecté en tant que {{ explode(' ', $user->name ?? 'Utilisateur')[0] }}</p>
                    <a href="{{ route('profile') }}" class="mobile-nav-link">Mon profil</a>
                    <a href="{{ route('dashboard') }}" class="mobile-nav-link">Tableau de bord</a>
                    <a href="{{ route('wallet') }}" class="mobile-nav-link">Mon Portefeuille TAKA</a>
                    <form method="POST" action="{{ route('logout') }}">
                        @csrf
                        <button type="submit" class="mobile-nav-link logout">Se déconnecter</button>
                    </form>
                </div>
            @else
                <a href="{{ route('login') }}" class="btn-login mobile">
                    <i class="icon-person"></i>
                    Se connecter
                </a>
            @endif
        </div>
    </div>
</header>

<style>
.header {
    background: white;
    border-bottom: 1px solid var(--border-gray);
    box-shadow: 0 1px 4px rgba(0,0,0,0.05);
}

.header-container {
    max-width: 1280px;
    margin: 0 auto;
    padding: 0 16px;
}

.header-content {
    display: flex;
    justify-content: space-between;
    align-items: center;
    height: 64px;
}

.logo-link {
    display: flex;
    align-items: center;
}

.logo-img {
    height: 50px;
    width: auto;
}

.desktop-nav {
    display: none;
    align-items: center;
    gap: 16px;
}

@media (min-width: 768px) {
    .desktop-nav {
        display: flex;
    }
}

.nav-link {
    padding: 8px 16px;
    color: var(--text-dark);
    text-decoration: none;
    font-size: 14px;
    font-weight: 500;
    transition: color 0.2s;
}

.nav-link:hover,
.nav-link.active {
    color: var(--main-color);
}

.country-selector select {
    padding: 6px 10px;
    border: 1px solid var(--border-gray);
    border-radius: 8px;
    background: var(--bg-gray);
    font-size: 13px;
    cursor: pointer;
}

.user-menu-wrapper {
    position: relative;
}

.user-menu-btn {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 8px 16px;
    background: var(--bg-gray);
    border: none;
    border-radius: 8px;
    cursor: pointer;
    font-size: 14px;
    font-weight: 500;
    color: var(--text-dark);
}

.user-menu-dropdown {
    display: none;
    position: absolute;
    top: 100%;
    right: 0;
    margin-top: 8px;
    background: white;
    border-radius: 8px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.1);
    min-width: 200px;
    z-index: 1000;
}

.user-menu-wrapper:hover .user-menu-dropdown,
.user-menu-dropdown.show {
    display: block;
}

.user-menu-item {
    display: block;
    padding: 12px 16px;
    color: var(--text-dark);
    text-decoration: none;
    font-size: 14px;
    transition: background 0.2s;
    border: none;
    background: none;
    width: 100%;
    text-align: left;
    cursor: pointer;
}

.user-menu-item:hover {
    background: var(--bg-gray);
}

.user-menu-item.logout {
    color: #EF4444;
}

.user-menu-divider {
    height: 1px;
    background: var(--border-gray);
    margin: 4px 0;
}

.btn-login {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 8px 16px;
    background: var(--main-color);
    color: white;
    text-decoration: none;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 500;
}

.mobile-menu-btn {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 40px;
    height: 40px;
    border: none;
    background: none;
    cursor: pointer;
}

@media (min-width: 768px) {
    .mobile-menu-btn {
        display: none;
    }
}

.mobile-nav {
    display: none;
    padding: 16px 0;
    border-top: 1px solid var(--border-gray);
}

.mobile-nav.show {
    display: block;
}

.mobile-nav-link {
    display: block;
    padding: 12px 16px;
    color: var(--text-dark);
    text-decoration: none;
    font-size: 14px;
    font-weight: 500;
    border: none;
    background: none;
    width: 100%;
    text-align: left;
    cursor: pointer;
}

.mobile-nav-link:hover,
.mobile-nav-link.active {
    color: var(--main-color);
    background: var(--bg-gray);
}

.mobile-user-section {
    padding: 16px;
    border-top: 1px solid var(--border-gray);
    margin-top: 16px;
}

.mobile-user-section p {
    padding: 8px 16px;
    color: var(--text-gray);
    font-size: 14px;
    margin-bottom: 8px;
}

.icon-person::before { content: "👤"; }
.icon-menu::before { content: "☰"; }
.icon-close::before { content: "✕"; }
</style>

<script>
function toggleMobileMenu() {
    const menu = document.getElementById('mobileMenu');
    const icon = document.getElementById('menuIcon');
    menu.classList.toggle('show');
    icon.classList.toggle('icon-close');
}

function toggleUserMenu() {
    const menu = document.getElementById('userMenu');
    menu.classList.toggle('show');
}

// Save country/currency selection
document.getElementById('countryCurrency')?.addEventListener('change', function(e) {
    const [country, currency] = e.target.value.split('|');
    localStorage.setItem('country', country);
    localStorage.setItem('currency', currency);
});

// Load saved country/currency
document.addEventListener('DOMContentLoaded', function() {
    const savedCountry = localStorage.getItem('country');
    const savedCurrency = localStorage.getItem('currency');
    
    // Si États-Unis ou autre devise non supportée, réinitialiser à Bénin
    if (savedCountry === 'États-Unis' || savedCurrency === 'USD') {
        localStorage.setItem('country', 'Bénin');
        localStorage.setItem('currency', 'XOF');
        const select = document.getElementById('countryCurrency');
        if (select) {
            select.value = 'Bénin|XOF';
        }
        return;
    }
    
    if (savedCountry && savedCurrency) {
        const select = document.getElementById('countryCurrency');
        if (select) {
            const value = `${savedCountry}|${savedCurrency}`;
            // Vérifier que la valeur existe dans les options
            if (select.querySelector(`option[value="${value}"]`)) {
                select.value = value;
            } else {
                // Si la valeur n'existe pas, réinitialiser à Bénin
                localStorage.setItem('country', 'Bénin');
                localStorage.setItem('currency', 'XOF');
                select.value = 'Bénin|XOF';
            }
        }
    }
});
</script>

