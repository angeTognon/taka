@extends('layouts.app')

@section('title', 'Politique de confidentialité - TAKA')

@section('content')
<div class="legal-page">
    <div class="container">
        <!-- Header -->
        <div class="legal-header">
            <div class="legal-icon">🔒</div>
            <h1>Politique de Confidentialité TAKA</h1>
            <p>Dernière mise à jour : {{ date('d/m/Y') }}</p>
        </div>

        <!-- Sections -->
        <div class="legal-sections">
            <div class="legal-section">
                <h2>1. Introduction</h2>
                <p>TAKA AFRICA (ci-après "TAKA", "nous", "notre" ou "nos") s'engage à protéger la confidentialité et la sécurité des informations personnelles de ses utilisateurs. Cette politique de confidentialité explique comment nous collectons, utilisons, partageons et protégeons vos informations lorsque vous utilisez notre plateforme de livres numériques.</p>
            </div>

            <div class="legal-section">
                <h2>2. Informations que nous collectons</h2>
                <p>Nous collectons les types d'informations suivants :</p>
                <ul>
                    <li>Informations d'identification : nom, adresse e-mail, numéro de téléphone</li>
                    <li>Informations de paiement : données de carte bancaire, informations Mobile Money (traitées de manière sécurisée par nos partenaires de paiement)</li>
                    <li>Informations de lecture : livres consultés, temps de lecture, préférences</li>
                    <li>Données techniques : adresse IP, type de navigateur, système d'exploitation</li>
                    <li>Informations de communication : messages envoyés via notre support client</li>
                </ul>
            </div>

            <div class="legal-section">
                <h2>3. Comment nous utilisons vos informations</h2>
                <p>Nous utilisons vos informations pour :</p>
                <ul>
                    <li>Fournir et améliorer nos services de lecture numérique</li>
                    <li>Traiter vos achats et abonnements</li>
                    <li>Personnaliser votre expérience de lecture</li>
                    <li>Communiquer avec vous concernant votre compte et nos services</li>
                    <li>Assurer la sécurité de notre plateforme</li>
                    <li>Respecter nos obligations légales et réglementaires</li>
                </ul>
            </div>

            <div class="legal-section">
                <h2>4. Partage de vos informations</h2>
                <p>Nous ne vendons jamais vos informations personnelles. Nous pouvons partager vos informations uniquement dans les cas suivants :</p>
                <ul>
                    <li>Avec votre consentement explicite</li>
                    <li>Avec nos prestataires de services (paiement, hébergement, support technique)</li>
                    <li>Pour respecter une obligation légale ou une décision de justice</li>
                    <li>Pour protéger nos droits, notre propriété ou notre sécurité</li>
                </ul>
            </div>

            <div class="legal-section">
                <h2>5. Sécurité des données</h2>
                <p>Nous mettons en place des mesures de sécurité appropriées pour protéger vos informations :</p>
                <ul>
                    <li>Chiffrement SSL/TLS pour toutes les transmissions de données</li>
                    <li>Stockage sécurisé avec accès restreint</li>
                    <li>Surveillance continue de nos systèmes</li>
                    <li>Formation régulière de notre personnel sur la sécurité des données</li>
                </ul>
            </div>

            <div class="legal-section">
                <h2>6. Vos droits</h2>
                <p>Conformément aux lois applicables, vous avez le droit de :</p>
                <ul>
                    <li>Accéder à vos informations personnelles</li>
                    <li>Corriger ou mettre à jour vos données</li>
                    <li>Supprimer votre compte et vos données</li>
                    <li>Vous opposer au traitement de vos données</li>
                    <li>Demander la portabilité de vos données</li>
                    <li>Retirer votre consentement à tout moment</li>
                </ul>
            </div>

            <div class="legal-section">
                <h2>7. Cookies et technologies similaires</h2>
                <p>Nous utilisons des cookies et technologies similaires pour :</p>
                <ul>
                    <li>Améliorer la fonctionnalité de notre site</li>
                    <li>Analyser l'utilisation de nos services</li>
                    <li>Personnaliser votre expérience</li>
                    <li>Assurer la sécurité de votre compte</li>
                </ul>
                <p>Vous pouvez gérer vos préférences de cookies dans les paramètres de votre navigateur.</p>
            </div>

            <div class="legal-section">
                <h2>8. Conservation des données</h2>
                <p>Nous conservons vos informations personnelles aussi longtemps que nécessaire pour fournir nos services et respecter nos obligations légales. Les données de compte inactif peuvent être supprimées après 3 ans d'inactivité.</p>
            </div>

            <div class="legal-section">
                <h2>9. Transferts internationaux</h2>
                <p>Vos données peuvent être transférées et traitées dans des pays autres que votre pays de résidence. Nous nous assurons que ces transferts respectent les standards de protection appropriés.</p>
            </div>

            <div class="legal-section">
                <h2>10. Modifications de cette politique</h2>
                <p>Nous pouvons mettre à jour cette politique de confidentialité périodiquement. Nous vous informerons de tout changement significatif par e-mail ou via notre plateforme.</p>
            </div>
        </div>

        <!-- Contact Section -->
        <div class="legal-contact">
            <div class="contact-icon">💬</div>
            <h3>Nous contacter</h3>
            <p>Pour toute question concernant cette politique de confidentialité :</p>
            <div class="contact-info">
                <p>📧 contact@takaafrica.com</p>
                <p>📱 WhatsApp : +229 0197147572</p>
                <p>🏢 TAKA AFRICA, Bénin</p>
            </div>
        </div>
    </div>
</div>

@push('styles')
<style>
.legal-page {
    background: #F9FAFB;
    min-height: calc(100vh - 200px);
    padding: 40px 20px;
}

.container {
    max-width: 1280px;
    margin: 0 auto;
}

.legal-header {
    background: white;
    padding: 48px 24px;
    border-radius: 16px;
    text-align: center;
    margin-bottom: 24px;
    box-shadow: 0 1px 10px rgba(0,0,0,0.1);
}

.legal-icon {
    font-size: 48px;
    margin-bottom: 16px;
}

.legal-header h1 {
    font-size: 24px;
    font-weight: 700;
    color: #111827;
    margin-bottom: 8px;
}

.legal-header p {
    font-size: 14px;
    color: #6B7280;
}

.legal-sections {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
    gap: 18px;
    margin-bottom: 32px;
}

.legal-section {
    background: white;
    padding: 24px;
    border-radius: 12px;
    box-shadow: 0 1px 5px rgba(0,0,0,0.08);
    min-height: 220px;
    display: flex;
    flex-direction: column;
}

.legal-section h2 {
    font-size: 18px;
    font-weight: 700;
    color: #111827;
    margin-bottom: 12px;
}

.legal-section p {
    font-size: 14px;
    color: #374151;
    line-height: 1.5;
    margin-bottom: 12px;
}

.legal-section ul {
    font-size: 14px;
    color: #374151;
    line-height: 1.8;
    margin-left: 20px;
    flex: 1;
}

.legal-section li {
    margin-bottom: 8px;
}

.legal-contact {
    background: linear-gradient(135deg, #F97316 0%, #FB923C 100%);
    padding: 32px;
    border-radius: 16px;
    text-align: center;
    color: white;
}

.contact-icon {
    font-size: 32px;
    margin-bottom: 12px;
}

.legal-contact h3 {
    font-size: 20px;
    font-weight: 700;
    margin-bottom: 8px;
}

.legal-contact > p {
    font-size: 14px;
    margin-bottom: 16px;
    opacity: 0.95;
}

.contact-info p {
    font-size: 14px;
    margin-bottom: 8px;
    opacity: 0.95;
}

@media (max-width: 768px) {
    .legal-header h1 {
        font-size: 18px;
    }
    
    .legal-sections {
        grid-template-columns: 1fr;
    }
    
    .legal-section {
        min-height: auto;
    }
}
</style>
@endpush
@endsection
