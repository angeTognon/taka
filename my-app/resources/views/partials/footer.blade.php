<footer class="footer">
    <div class="footer-container">
        <div class="footer-content">
            <!-- Logo and Description -->
            <div class="footer-section logo-section">
                <img src="{{ asset('images/logo.jpeg') }}" alt="TAKA" class="footer-logo">
                <p class="footer-description">
                    Lis africain. Pense libre. Découvre autrement.<br>
                    TAKA, c'est ta librairie digitale nouvelle génération, 100% adaptée à la réalité africaine.
                </p>
            </div>

            <!-- Links Section -->
            <div class="footer-section">
                <h3 class="footer-title">Liens utiles</h3>
                <a href="{{ route('about') }}" class="footer-link">À propos</a>
                <a href="{{ route('faq.authors') }}" class="footer-link">Auteurs</a>
                <a href="{{ route('faq.readers') }}" class="footer-link">Lecteurs</a>
                <a href="{{ route('contact') }}" class="footer-link">Contact</a>
            </div>

            <!-- Community Section -->
            <div class="footer-section">
                <h3 class="footer-title">Communauté</h3>
                <a href="https://chat.whatsapp.com/KqnaLGneaI93fA0sjxef3j?mode=ems_copy_t" target="_blank" class="footer-link community-link">
                    <img src="{{ asset('images/images/whatsapp.png') }}" alt="WhatsApp" class="community-icon">
                    Groupe LECTEURS WhatsApp
                </a>
                <a href="https://chat.whatsapp.com/DCNEoG8uU58HdanJDxIWLS" target="_blank" class="footer-link community-link">
                    <img src="{{ asset('images/images/whatsapp.png') }}" alt="WhatsApp" class="community-icon">
                    Groupe AUTEURS WhatsApp
                </a>
            </div>

            <!-- Legal Section -->
            <div class="footer-section">
                <h3 class="footer-title">Légal</h3>
                <a href="{{ route('politique') }}" class="footer-link">Politique de confidentialité</a>
                <a href="{{ route('conditions') }}" class="footer-link">Conditions de distribution</a>
            </div>
        </div>

        <!-- Copyright -->
        <div class="footer-copyright">
            <p>© 2026 TAKA. Tous droits réservés.</p>
        </div>
    </div>
</footer>

<style>
.footer {
    background: #111827;
    color: #D1D5DB;
    padding: 48px 0 32px;
}

.footer-container {
    max-width: 1280px;
    margin: 0 auto;
    padding: 0 16px;
}

.footer-content {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 32px;
    margin-bottom: 32px;
}

.footer-section {
    display: flex;
    flex-direction: column;
    gap: 16px;
}

.footer-logo {
    height: 50px;
    width: 50px;
    margin-bottom: 16px;
}

.footer-description {
    font-size: 14px;
    line-height: 1.5;
    color: #D1D5DB;
}

.footer-title {
    font-size: 18px;
    font-weight: 600;
    color: white;
    margin-bottom: 8px;
}

.footer-link {
    color: #D1D5DB;
    text-decoration: underline;
    font-size: 14px;
    transition: color 0.2s;
}

.footer-link:hover {
    color: white;
}

.community-link {
    display: flex;
    align-items: center;
    gap: 8px;
    text-decoration: none;
}

.community-link:hover {
    text-decoration: underline;
}

.community-icon {
    width: 24px;
    height: 24px;
    object-fit: contain;
    flex-shrink: 0;
}

.footer-copyright {
    padding-top: 32px;
    border-top: 1px solid #1F2937;
    text-align: center;
}

.footer-copyright p {
    color: #9CA3AF;
    font-size: 14px;
}

@media (max-width: 768px) {
    .footer-content {
        grid-template-columns: repeat(2, 1fr);
    }
    
    .logo-section {
        grid-column: 1 / -1;
    }
}
</style>

