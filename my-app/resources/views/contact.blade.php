@extends('layouts.app')

@section('title', 'Contact - TAKA')

@section('content')
<div class="contact-page">
    <div class="container">
        <!-- Header -->
        <div class="contact-header">
            <div class="contact-icon">💬</div>
            <h1>Contactez l'équipe TAKA</h1>
            <p>Nous sommes là pour vous aider 24h/24, 7j/7</p>
        </div>

        <!-- Quick Contact -->
        <div class="quick-contact">
            <a href="https://wa.me/2290197147572" target="_blank" class="quick-contact-card whatsapp">
                <div class="quick-contact-icon-wrapper">
                    <div class="quick-contact-icon">💬</div>
                </div>
                <h3>WhatsApp</h3>
                <p>+229 0197147572</p>
            </a>
            <a href="mailto:contact@takaafrica.com" class="quick-contact-card email">
                <div class="quick-contact-icon-wrapper">
                    <div class="quick-contact-icon">📧</div>
                </div>
                <h3>Email</h3>
                <p>contact@takaafrica.com</p>
            </a>
        </div>

        <!-- Contact Form -->
        <div class="contact-form-container">
            <h2>Envoyez-nous un message</h2>
            <form id="contactForm" class="contact-form">
                <div class="form-group">
                    <label>Catégorie</label>
                    <select id="category" name="category" class="form-input" required>
                        <option value="Support général" selected>Support général</option>
                        <option value="Support auteur">Support auteur</option>
                        <option value="Support lecteur">Support lecteur</option>
                        <option value="Problème technique">Problème technique</option>
                        <option value="Question commerciale">Question commerciale</option>
                        <option value="Partenariat">Partenariat</option>
                        <option value="Presse et médias">Presse et médias</option>
                    </select>
                </div>

                <div class="form-group">
                    <label>Nom complet</label>
                    <input type="text" id="name" name="name" class="form-input" placeholder="Votre nom complet" required>
                </div>

                <div class="form-group">
                    <label>Adresse email</label>
                    <input type="email" id="email" name="email" class="form-input" placeholder="votre@email.com" required>
                </div>

                <div class="form-group">
                    <label>Sujet</label>
                    <input type="text" id="subject" name="subject" class="form-input" placeholder="Résumé de votre demande" required>
                </div>

                <div class="form-group">
                    <label>Message</label>
                    <textarea id="message" name="message" class="form-input" rows="6" placeholder="Décrivez votre demande en détail..." required></textarea>
                </div>

                <button type="submit" class="btn-submit">Envoyer le message</button>
            </form>
        </div>

        <!-- Other Contact Methods -->
        <div class="other-contact-container">
            <h2>Autres moyens de nous contacter</h2>
            <div class="contact-method">
                <div class="contact-method-icon location">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path>
                        <circle cx="12" cy="10" r="3"></circle>
                    </svg>
                </div>
                <div class="contact-method-content">
                    <h3>Adresse</h3>
                    <p>TAKA AFRICA<br>Parakou, Bénin</p>
                </div>
            </div>

            <div class="contact-method">
                <div class="contact-method-icon phone">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"></path>
                    </svg>
                </div>
                <div class="contact-method-content">
                    <h3>Téléphone</h3>
                    <p>+229 0197147572</p>
                </div>
            </div>

            <div class="contact-method">
                <div class="contact-method-icon schedule">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <circle cx="12" cy="12" r="10"></circle>
                        <polyline points="12 6 12 12 16 14"></polyline>
                    </svg>
                </div>
                <div class="contact-method-content">
                    <h3>Horaires</h3>
                    <p>Support 24h/24, 7j/7<br>Réponse sous 2h en moyenne</p>
                </div>
            </div>
        </div>

        <!-- FAQ Link -->
        <div class="faq-link-container">
            <div class="faq-icon">❓</div>
            <h3 class="faq-link-title">Consultez notre FAQ</h3>
            <p class="faq-link-description">Trouvez rapidement des réponses aux questions les plus fréquentes</p>
            <a href="{{ route('faq.readers') }}" class="btn-faq">Voir la FAQ</a>
        </div>
    </div>
</div>

@push('styles')
<style>
.contact-page {
    background: #F9FAFB;
    min-height: calc(100vh - 200px);
    padding: 40px 20px;
}

.container {
    max-width: 1280px;
    margin: 0 auto;
}

.contact-header {
    width: 100%;
    padding: 48px 24px;
    background: linear-gradient(135deg, #F97316 0%, #FB923C 100%);
    border-radius: 16px;
    text-align: center;
    color: white;
    margin-bottom: 24px;
}

.contact-icon {
    font-size: 48px;
    margin-bottom: 16px;
}

.contact-header h1 {
    font-size: 24px;
    font-weight: 700;
    margin-bottom: 8px;
}

.contact-header p {
    font-size: 14px;
    opacity: 0.95;
}

.quick-contact {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 12px;
    margin-bottom: 24px;
}

.quick-contact-card {
    background: white;
    padding: 24px 16px;
    border-radius: 12px;
    text-align: center;
    text-decoration: none;
    color: inherit;
    box-shadow: 0 1px 5px rgba(0,0,0,0.1);
    transition: transform 0.2s;
}

.quick-contact-card:hover {
    transform: translateY(-2px);
}

.quick-contact-icon-wrapper {
    display: inline-flex;
    padding: 12px;
    border-radius: 50%;
    margin-bottom: 8px;
}

.quick-contact-card.whatsapp .quick-contact-icon-wrapper {
    background: rgba(34, 197, 94, 0.1);
}

.quick-contact-card.email .quick-contact-icon-wrapper {
    background: rgba(37, 99, 235, 0.1);
}

.quick-contact-icon {
    font-size: 24px;
}

.quick-contact-card.whatsapp .quick-contact-icon {
    color: #22C55E;
}

.quick-contact-card.email .quick-contact-icon {
    color: #2563EB;
}

.quick-contact-card h3 {
    font-size: 14px;
    font-weight: 700;
    color: #111827;
    margin-bottom: 4px;
}

.quick-contact-card p {
    font-size: 12px;
    color: #6B7280;
}

.contact-form-container {
    background: white;
    padding: 32px;
    border-radius: 16px;
    box-shadow: 0 1px 10px rgba(0,0,0,0.1);
    margin-bottom: 24px;
}

.contact-form-container h2 {
    font-size: 20px;
    font-weight: 700;
    color: #111827;
    margin-bottom: 20px;
}

.form-group {
    margin-bottom: 16px;
}

.form-group label {
    display: block;
    font-size: 16px;
    font-weight: 500;
    color: #111827;
    margin-bottom: 8px;
}

.form-input {
    width: 100%;
    padding: 12px 16px;
    border: 1px solid #D1D5DB;
    border-radius: 12px;
    font-size: 14px;
    font-family: inherit;
    transition: border-color 0.2s;
}

.form-input:focus {
    outline: none;
    border-color: #F97316;
    border-width: 2px;
}

.form-input::placeholder {
    color: #9CA3AF;
}

.btn-submit {
    width: 100%;
    padding: 16px;
    background: #F97316;
    color: white;
    border: none;
    border-radius: 12px;
    font-size: 16px;
    font-weight: 700;
    cursor: pointer;
    transition: background 0.2s;
}

.btn-submit:hover {
    background: #EA580C;
}

.other-contact-container {
    background: white;
    padding: 32px;
    border-radius: 16px;
    box-shadow: 0 1px 10px rgba(0,0,0,0.1);
    margin-bottom: 24px;
}

.other-contact-container h2 {
    font-size: 18px;
    font-weight: 700;
    color: #111827;
    margin-bottom: 16px;
}

.contact-method {
    display: flex;
    align-items: flex-start;
    gap: 12px;
    margin-bottom: 16px;
}

.contact-method:last-child {
    margin-bottom: 0;
}

.contact-method-icon {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 36px;
    height: 36px;
    border-radius: 50%;
    flex-shrink: 0;
}

.contact-method-icon.location {
    background: rgba(239, 68, 68, 0.1);
    color: #EF4444;
}

.contact-method-icon.phone {
    background: rgba(34, 197, 94, 0.1);
    color: #22C55E;
}

.contact-method-icon.schedule {
    background: rgba(37, 99, 235, 0.1);
    color: #2563EB;
}

.contact-method-content h3 {
    font-size: 14px;
    font-weight: 700;
    color: #111827;
    margin-bottom: 4px;
}

.contact-method-content p {
    font-size: 14px;
    color: #6B7280;
    line-height: 1.5;
}

.faq-link-container {
    width: 100%;
    padding: 32px 20px;
    background: #EFF6FF;
    border: 2px solid #BFDBFE;
    border-radius: 16px;
    text-align: center;
}

.faq-icon {
    font-size: 32px;
    color: #2563EB;
    margin-bottom: 12px;
}

.faq-link-title {
    font-size: 18px;
    font-weight: 700;
    color: #2563EB;
    margin-bottom: 8px;
}

.faq-link-description {
    font-size: 14px;
    color: #2563EB;
    margin-bottom: 12px;
    line-height: 1.5;
}

.btn-faq {
    display: inline-block;
    padding: 12px 24px;
    background: #2563EB;
    color: white;
    font-size: 16px;
    font-weight: 700;
    text-decoration: none;
    border-radius: 8px;
    transition: background 0.2s;
}

.btn-faq:hover {
    background: #1D4ED8;
}

@media (max-width: 768px) {
    .contact-page {
        padding: 20px 16px;
    }

    .contact-header h1 {
        font-size: 18px;
    }

    .contact-header p {
        font-size: 13px;
    }

    .quick-contact {
        grid-template-columns: 1fr;
    }

    .contact-form-container,
    .other-contact-container {
        padding: 20px;
    }

    .contact-form-container h2,
    .other-contact-container h2 {
        font-size: 16px;
    }

    .form-group label {
        font-size: 14px;
    }

    .faq-link-title {
        font-size: 16px;
    }

    .faq-link-description {
        font-size: 13px;
    }
}
</style>
@endpush

@push('scripts')
<script>
document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementById('contactForm');
    
    form.addEventListener('submit', function(e) {
        e.preventDefault();
        
        // Get form values
        const category = document.getElementById('category').value;
        const name = document.getElementById('name').value;
        const email = document.getElementById('email').value;
        const subject = document.getElementById('subject').value;
        const message = document.getElementById('message').value;
        
        // Validation
        if (!name || !email || !subject || !message) {
            alert('Veuillez remplir tous les champs obligatoires.');
            return;
        }
        
        // Email validation
        const emailRegex = /^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/;
        if (!emailRegex.test(email)) {
            alert('Veuillez entrer un email valide.');
            return;
        }
        
        // Message length validation
        if (message.length < 10) {
            alert('Le message doit contenir au moins 10 caractères.');
            return;
        }
        
        // Show success message
        alert('Message envoyé avec succès ! Nous vous répondrons sous 2h.');
        
        // Clear form
        form.reset();
        document.getElementById('category').value = 'Support général';
    });
});
</script>
@endpush
@endsection
