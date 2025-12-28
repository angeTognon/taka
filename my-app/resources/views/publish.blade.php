@extends('layouts.app')

@section('title', 'Publier - TAKA')

@php
    // Détecter si on est en mode édition (via sessionStorage côté client)
@endphp

@if(!auth()->check())
@section('content')
<div class="restricted-page">
    <div class="restricted-container">
        <h1 class="restricted-title">Accès restreint</h1>
        <p class="restricted-text">Vous devez être connecté pour publier un livre.</p>
        <a href="{{ route('login') }}" class="restricted-btn">Se connecter</a>
    </div>
</div>
@endsection
@else
@section('content')
<div class="publish-page">
    <div class="publish-container">
        <!-- Progress Steps -->
        <div class="progress-steps">
            <div class="steps-container">
                @for($i = 1; $i <= 4; $i++)
                    @php
                        $stepTitles = [
                            1 => 'Informations du livre',
                            2 => 'Fichier du livre',
                            3 => 'Couverture',
                            4 => 'Plan de publication'
                        ];
                        $stepIcons = [
                            1 => 'description',
                            2 => 'upload_file',
                            3 => 'image',
                            4 => 'attach_money'
                        ];
                    @endphp
                    <div class="step-item" data-step="{{ $i }}">
                        <div class="step-circle" id="stepCircle{{ $i }}">
                            <i class="fas fa-{{ $stepIcons[$i] }}"></i>
                        </div>
                        <div class="step-info">
                            <div class="step-number">Étape {{ $i }}</div>
                            <div class="step-title">{{ $stepTitles[$i] }}</div>
                        </div>
                        @if($i < 4)
                            <div class="step-connector" id="stepConnector{{ $i }}"></div>
                        @endif
                    </div>
                @endfor
            </div>
        </div>

        <!-- Form Content -->
        <div class="form-content">
            <!-- Step 1: Book Information -->
            <div class="step-panel active" id="stepPanel1">
                <h2 class="step-heading">Informations du livre</h2>
                <div class="form-fields">
                    <div class="form-field">
                        <label>Titre du livre *</label>
                        <input type="text" id="bookTitle" class="form-input" placeholder="Entrez le titre de votre livre">
                    </div>
                    <div class="form-field">
                        <label>Thématique *</label>
                        <select id="bookGenre" class="form-select">
                            <option value="">Sélectionner une thématique</option>
                            @foreach($genres as $genre)
                                <option value="{{ $genre }}">{{ $genre }}</option>
                            @endforeach
                        </select>
                    </div>
                    <div class="form-field">
                        <label>Type du Livre *</label>
                        <div class="form-row">
                            <select id="priceType" class="form-select">
                                <option value="gratuit">Gratuit</option>
                                <option value="payant">Payant</option>
                            </select>
                            <input type="number" id="bookPrice" class="form-input" placeholder="Prix du livre (FCFA) *" style="display: none;">
                        </div>
                    </div>
                    <div class="form-field">
                        <label>Description *</label>
                        <textarea id="bookSummary" class="form-textarea" rows="6" placeholder="Décrivez votre livre en quelques paragraphes..."></textarea>
                    </div>
                </div>
            </div>

            <!-- Step 2: Book File -->
            <div class="step-panel" id="stepPanel2">
                <h2 class="step-heading">Fichier du livre</h2>
                <div class="form-fields">
                    <div class="file-upload-area" id="fileUploadArea">
                        <input type="file" id="bookFile" accept=".pdf" style="display: none;">
                        <div class="upload-content">
                            <i class="fas fa-upload-file upload-icon"></i>
                            <h3 class="upload-title">Télécharger votre manuscrit</h3>
                            <p class="upload-subtitle">Formats acceptés: PDF (max 50MB)</p>
                            <button type="button" class="upload-btn" onclick="document.getElementById('bookFile').click()">Choisir un fichier</button>
                            <div id="fileStatus" class="file-status"></div>
                        </div>
                    </div>
                    <div class="info-box">
                        <h4 class="info-title">Conseils pour votre manuscrit:</h4>
                        <ul class="info-list">
                            <li>Assurez-vous que votre texte est bien formaté</li>
                            <li>Vérifiez l'orthographe et la grammaire</li>
                            <li>Incluez une table des matières si nécessaire</li>
                            <li>Le fichier ne doit pas dépasser 50MB</li>
                        </ul>
                    </div>
                </div>
            </div>

            <!-- Step 3: Cover -->
            <div class="step-panel" id="stepPanel3">
                <h2 class="step-heading">Couverture du livre</h2>
                <div class="form-fields">
                    <div class="cover-upload-section">
                        <div class="file-upload-area" id="coverUploadArea">
                            <input type="file" id="bookCover" accept="image/*" style="display: none;">
                            <div class="upload-content">
                                <i class="fas fa-image upload-icon"></i>
                                <h3 class="upload-title">Télécharger la couverture</h3>
                                <p class="upload-subtitle">Format recommandé: 1500x2500px, JPG/PNG</p>
                                <button type="button" class="upload-btn" onclick="document.getElementById('bookCover').click()">Choisir un fichier</button>
                                <div id="coverStatus" class="file-status"></div>
                            </div>
                        </div>
                        <div class="cover-preview-section">
                            <h4 class="preview-title">Aperçu en direct</h4>
                            <div class="cover-preview" id="coverPreview">
                                <i class="fas fa-image"></i>
                                <p>Aperçu de la couverture</p>
                            </div>
                        </div>
                    </div>
                    <div class="info-box yellow">
                        <h4 class="info-title">Conseils pour une couverture réussie:</h4>
                        <ul class="info-list">
                            <li>Utilisez des couleurs contrastées pour le titre</li>
                            <li>Assurez-vous que le titre soit lisible en petit format</li>
                            <li>Évitez les images trop chargées</li>
                            <li>Respectez les dimensions recommandées</li>
                        </ul>
                    </div>
                </div>
            </div>

            <!-- Step 4: Publication Plan -->
            <div class="step-panel" id="stepPanel4">
                <h2 class="step-heading">Choisir votre plan de publication</h2>
                <div class="form-fields">
                    <div class="plans-grid">
                        @foreach($plans as $plan)
                            <div class="plan-card {{ $plan['id'] === 'international' ? 'plan-international' : '' }}" data-plan-id="{{ $plan['id'] }}" onclick="selectPlan('{{ $plan['id'] }}')">
                                <h3 class="plan-name">{{ $plan['name'] }}</h3>
                                <div class="plan-price">{{ $plan['price'] == '0 FCFA' ? 'Gratuit' : $plan['price'] }}</div>
                                <ul class="plan-features">
                                    @foreach($plan['features'] as $feature)
                                        <li><i class="fas fa-check-circle"></i> {{ $feature }}</li>
                                    @endforeach
                                </ul>
                            </div>
                        @endforeach
                    </div>
                    
                    <!-- Summary Box -->
                    <div class="summary-box" id="summaryBox" style="margin-top: 32px;">
                        <h4 class="summary-title">Récapitulatif de votre soumission</h4>
                        <div class="summary-content">
                            <div class="summary-column">
                                <p><strong>Titre:</strong> <span id="summaryTitle">Non renseigné</span></p>
                                <p><strong>Thématique:</strong> <span id="summaryGenre">Non renseigné</span></p>
                            </div>
                            <div class="summary-column">
                                <p><strong>Plan:</strong> <span id="summaryPlan">Non sélectionné</span></p>
                                <p><strong>Fichier:</strong> <span id="summaryFile">✗ Manquant</span></p>
                                <p><strong>Couverture:</strong> <span id="summaryCover">✗ Manquante</span></p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            {{-- ÉTAPES 5 ET 6 COMMENTÉES (SUPPRIMÉES TEMPORAIREMENT) --}}
            {{-- 
            <!-- Step 5: Author Profile -->
            <div class="step-panel" id="stepPanel5">
                <h2 class="step-heading">Profil auteur</h2>
                <div class="form-fields">
                    <div class="cover-upload-section">
                        <div class="file-upload-area" id="authorPhotoUploadArea">
                            <input type="file" id="authorPhoto" accept="image/*" style="display: none;">
                            <div class="upload-content">
                                <i class="fas fa-user upload-icon"></i>
                                <h3 class="upload-title">Photo de profil</h3>
                                <p class="upload-subtitle">Format recommandé: JPG/PNG (max 5MB)</p>
                                <button type="button" class="upload-btn" onclick="document.getElementById('authorPhoto').click()">Choisir une photo</button>
                                <div id="authorPhotoStatus" class="file-status"></div>
                            </div>
                        </div>
                    </div>
                    <div class="form-field">
                        <label>Biographie *</label>
                        <textarea id="authorBio" class="form-textarea" rows="6" placeholder="Parlez-nous de vous, votre parcours, vos inspirations..."></textarea>
                    </div>
                    <div class="form-field">
                        <label>Liens (réseaux sociaux, site web)</label>
                        <textarea id="authorLinks" class="form-textarea" rows="3" placeholder="https://facebook.com/monprofil&#10;https://twitter.com/moncompte&#10;https://monsite.com"></textarea>
                    </div>
                </div>
            </div>

            <!-- Step 6: Promotion -->
            <div class="step-panel" id="stepPanel6">
                <h2 class="step-heading">Textes de promotion</h2>
                <div class="form-fields">
                    <div class="form-field">
                        <label>Extrait du livre *</label>
                        <textarea id="bookExcerpt" class="form-textarea" rows="8" placeholder="Copiez un passage captivant de votre livre (2-3 paragraphes)..."></textarea>
                        <p style="font-size: 14px; color: #6B7280; margin-top: 8px;">Cet extrait sera affiché sur la page de présentation de votre livre</p>
                    </div>
                    <div class="form-field">
                        <label>Citation marquante</label>
                        <textarea id="bookQuote" class="form-textarea" rows="3" placeholder="Une phrase ou citation qui résume l'essence de votre livre..."></textarea>
                        <p style="font-size: 14px; color: #6B7280; margin-top: 8px;">Cette citation sera utilisée pour les promotions sur les réseaux sociaux</p>
                    </div>
                    <div class="summary-box" id="summaryBox">
                        <h4 class="summary-title">Récapitulatif de votre soumission</h4>
                        <div class="summary-content">
                            <div class="summary-column">
                                <p><strong>Titre:</strong> <span id="summaryTitle">Non renseigné</span></p>
                                <p><strong>Genre:</strong> <span id="summaryGenre">Non renseigné</span></p>
                            </div>
                            <div class="summary-column">
                                <p><strong>Plan:</strong> <span id="summaryPlan">Non sélectionné</span></p>
                                <p><strong>Fichier:</strong> <span id="summaryFile">✗ Manquant</span></p>
                                <p><strong>Couverture:</strong> <span id="summaryCover">✗ Manquante</span></p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            --}}

            <!-- Navigation Buttons -->
            <div class="navigation-buttons">
                <button type="button" class="btn-nav btn-prev" id="prevBtn" onclick="prevStep()" disabled>
                    <i class="fas fa-arrow-back"></i> Précédent
                </button>
                <button type="button" class="btn-nav btn-next" id="nextBtn" onclick="nextStep()">
                    Suivant <i class="fas fa-arrow-forward"></i>
                </button>
                <button type="button" class="btn-nav btn-submit" id="submitBtn" onclick="handleSubmit()" style="display: none;">
                    <i class="fas fa-check-circle"></i> Soumettre mon livre
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Loading Overlay -->
<div id="loadingOverlay" class="loading-overlay" style="display: none;">
    <div class="loading-spinner"></div>
    <p class="loading-text">Traitement en cours...</p>
</div>

@push('styles')
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
<style>
.publish-page {
    background: #F9FAFB;
    min-height: calc(100vh - 200px);
    padding: 32px 0;
}

.publish-container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 20px;
}

/* Progress Steps */
.progress-steps {
    background: white;
    padding: 24px;
    border-radius: 12px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
    margin-bottom: 32px;
}

.steps-container {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 24px;
}

.step-item {
    display: flex;
    align-items: center;
    position: relative;
    flex: 0 0 auto;
}

.step-circle {
    width: 40px;
    height: 40px;
    border-radius: 50%;
    background: #E5E7EB;
    border: 2px solid #D1D5DB;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #6B7280;
    font-size: 20px;
    transition: all 0.3s;
}

.step-item.active .step-circle,
.step-item.completed .step-circle {
    background: #F97316;
    border-color: #F97316;
    color: white;
}

.step-item.completed .step-circle i {
    display: none;
}

.step-item.completed .step-circle::after {
    content: '✓';
    font-size: 20px;
    font-weight: bold;
}

.step-info {
    margin-left: 12px;
    display: none;
}

.step-number {
    font-size: 13px;
    font-weight: 500;
    color: #6B7280;
    font-family: "PBold", sans-serif;
}

.step-item.active .step-number {
    color: #F97316;
}

.step-title {
    font-size: 12px;
    color: #9CA3AF;
    font-family: "PRegular", sans-serif;
}

.step-item.active .step-title {
    color: #F97316;
}

.step-connector {
    width: 40px;
    height: 2px;
    background: #D1D5DB;
    margin: 0 8px;
    transition: background 0.3s;
    flex-shrink: 0;
}

.step-item.completed .step-connector {
    background: #F97316;
}

/* Form Content */
.form-content {
    background: white;
    padding: 32px;
    border-radius: 12px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}

.step-panel {
    display: none;
}

.step-panel.active {
    display: block;
}

.step-heading {
    font-size: 20px;
    font-weight: 700;
    color: #000000;
    margin-bottom: 24px;
    font-family: "PBold", sans-serif;
}

.form-fields {
    display: flex;
    flex-direction: column;
    gap: 24px;
}

.form-field {
    display: flex;
    flex-direction: column;
}

.form-field label {
    font-size: 14px;
    font-weight: 500;
    color: #374151;
    margin-bottom: 8px;
    font-family: "PBold", sans-serif;
}

.form-input,
.form-select,
.form-textarea {
    padding: 12px 16px;
    border: 1px solid #D1D5DB;
    border-radius: 8px;
    font-size: 15px;
    font-family: "PRegular", sans-serif;
    transition: border-color 0.2s;
}

.form-input:focus,
.form-select:focus,
.form-textarea:focus {
    outline: none;
    border-color: #F97316;
    border-width: 2px;
}

.form-textarea {
    resize: vertical;
    min-height: 120px;
}

.form-row {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 24px;
}

/* File Upload */
.file-upload-area {
    border: 2px dashed #D1D5DB;
    border-radius: 8px;
    padding: 32px;
    text-align: center;
    cursor: pointer;
    transition: border-color 0.2s;
}

.file-upload-area:hover {
    border-color: #F97316;
}

.file-upload-area.compact {
    padding: 24px;
}

.upload-content {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 16px;
}

.upload-icon {
    font-size: 48px;
    color: #9CA3AF;
}

.file-upload-area.compact .upload-icon {
    font-size: 32px;
}

.upload-title {
    font-size: 18px;
    font-weight: 500;
    color: #111827;
    font-family: "PRegular", sans-serif;
}

.upload-subtitle {
    font-size: 14px;
    color: #6B7280;
    font-family: "PRegular", sans-serif;
}

.upload-btn {
    background: #F97316;
    color: white;
    padding: 22px 24px;
    border: none;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 500;
    cursor: pointer;
    font-family: "PRegular", sans-serif;
    transition: background 0.2s;
}

.upload-btn:hover {
    background: #EA580C;
}

.file-status {
    margin-top: 16px;
    color: #10B981;
    font-weight: 500;
    font-size: 14px;
}

/* Cover Preview */
.cover-upload-section {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 32px;
    align-items: start;
}

.cover-preview-section {
    display: flex;
    flex-direction: column;
}

.preview-title {
    font-size: 16px;
    font-weight: 500;
    color: #111827;
    margin-bottom: 16px;
    font-family: "PBold", sans-serif;
}

.cover-preview {
    padding: 16px;
    background: #F3F4F6;
    border-radius: 8px;
    aspect-ratio: 3/4;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    color: #6B7280;
}

.cover-preview img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    border-radius: 8px;
}

.cover-preview i {
    font-size: 48px;
    margin-bottom: 8px;
}

/* Info Box */
.info-box {
    padding: 16px;
    background: #EFF6FF;
    border-radius: 8px;
}

.info-box.yellow {
    background: #FEF3C7;
}

.info-title {
    font-size: 16px;
    font-weight: 500;
    color: #111827;
    margin-bottom: 8px;
    font-family: "PBold", sans-serif;
}

.info-list {
    list-style: none;
    padding: 0;
    margin: 0;
}

.info-list li {
    padding: 4px 0;
    font-size: 14px;
    color: #374151;
    font-family: "PRegular", sans-serif;
}

.info-list li::before {
    content: '• ';
    margin-right: 8px;
}

/* Plans Grid */
.plans-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 24px;
}

.plan-card.plan-international {
    grid-column: 1 / -1;
    max-width: 500px;
    margin: 0 auto;
}

.plan-card {
    padding: 24px;
    border: 1px solid #E5E7EB;
    border-radius: 12px;
    cursor: pointer;
    transition: all 0.2s;
}

.plan-card:hover {
    border-color: #F97316;
}

.plan-card.selected {
    border: 2px solid #F97316;
}

.plan-name {
    font-size: 18px;
    font-weight: 700;
    color: #000000;
    text-align: center;
    margin-bottom: 8px;
    font-family: "PBold", sans-serif;
}

.plan-price {
    font-size: 22px;
    font-weight: 700;
    color: #F97316;
    text-align: center;
    margin-bottom: 16px;
    font-family: "PBold", sans-serif;
}

.plan-features {
    list-style: none;
    padding: 0;
    margin: 0;
}

.plan-features li {
    display: flex;
    align-items: flex-start;
    gap: 8px;
    padding: 8px 0;
    font-size: 14px;
    color: #374151;
    font-family: "PRegular", sans-serif;
}

.plan-features li i {
    color: #10B981;
    font-size: 16px;
    margin-top: 2px;
}

/* Author Profile */
.author-profile-section {
    display: grid;
    grid-template-columns: 200px 1fr;
    gap: 32px;
}

.author-photo-section {
    display: flex;
    flex-direction: column;
}

.photo-preview {
    margin-top: 16px;
    width: 120px;
    height: 120px;
    border-radius: 8px;
    overflow: hidden;
    background: #E5E7EB;
    display: none;
}

.photo-preview img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

/* Summary Box */
.summary-box {
    padding: 24px;
    background: #F0FDF4;
    border: 1px solid #BBF7D0;
    border-radius: 8px;
}

.summary-title {
    font-size: 16px;
    font-weight: 500;
    color: #14532D;
    margin-bottom: 12px;
    font-family: "PBold", sans-serif;
}

.summary-content {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 16px;
}

.summary-column p {
    font-size: 14px;
    color: #374151;
    margin-bottom: 8px;
    font-family: "PRegular", sans-serif;
}

.field-hint {
    font-size: 14px;
    color: #6B7280;
    margin-top: 6px;
    font-family: "PRegular", sans-serif;
}

/* Navigation Buttons */
.navigation-buttons {
    margin-top: 32px;
    padding-top: 24px;
    border-top: 1px solid #E5E7EB;
    display: flex;
    justify-content: space-between;
}

.btn-nav {
    padding: 12px 24px;
    border: none;
    border-radius: 8px;
    font-size: 15px;
    font-weight: 500;
    cursor: pointer;
    font-family: "PRegular", sans-serif;
    transition: all 0.2s;
    display: flex;
    align-items: center;
    gap: 8px;
}

.btn-prev {
    background: transparent;
    color: #6B7280;
}

.btn-prev:not(:disabled):hover {
    color: #374151;
}

.btn-prev:disabled {
    color: #9CA3AF;
    cursor: not-allowed;
}

.btn-next,
.btn-submit {
    background: #F97316;
    color: white;
}

.btn-next:hover,
.btn-submit:hover {
    background: #EA580C;
}

.btn-submit {
    background: #10B981;
}

.btn-submit:hover {
    background: #059669;
}

/* Loading Overlay */
.loading-overlay {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0, 0, 0, 0.3);
    display: flex;
    flex-direction: column;
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

.loading-text {
    margin-top: 16px;
    color: white;
    font-size: 16px;
    font-family: "PRegular", sans-serif;
}

@keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
}

/* Restricted Page */
.restricted-page {
    min-height: calc(100vh - 200px);
    display: flex;
    align-items: center;
    justify-content: center;
    background: #F9FAFB;
}

.restricted-container {
    text-align: center;
    padding: 48px;
}

.restricted-title {
    font-size: 24px;
    font-weight: 700;
    color: #000000;
    margin-bottom: 16px;
    font-family: "PBold", sans-serif;
}

.restricted-text {
    font-size: 16px;
    color: #6B7280;
    margin-bottom: 24px;
    font-family: "PRegular", sans-serif;
}

.restricted-btn {
    display: inline-block;
    padding: 22px 24px;
    background: #F97316;
    color: white;
    text-decoration: none;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 500;
    font-family: "PRegular", sans-serif;
    transition: background 0.2s;
}

.restricted-btn:hover {
    background: #EA580C;
}

/* Responsive */
@media (max-width: 1024px) {
    .author-profile-section {
        grid-template-columns: 1fr;
    }
    
    .cover-upload-section {
        grid-template-columns: 1fr;
    }
    
    .cover-preview-section {
        order: -1;
    }
}

@media (max-width: 768px) {
    .publish-container {
        padding: 0 8px;
    }
    
    .progress-steps {
        padding: 8px;
    }
    
    .step-info {
        display: none;
    }
    
    .step-circle {
        width: 28px;
        height: 28px;
        font-size: 16px;
    }
    
    .step-connector {
        margin: 0 8px;
    }
    
    .form-content {
        padding: 8px;
    }
    
    .form-row {
        grid-template-columns: 1fr;
        gap: 16px;
    }
    
    .plans-grid {
        grid-template-columns: 1fr;
    }
    
    .summary-content {
        grid-template-columns: 1fr;
    }
    
    .navigation-buttons {
        flex-direction: column;
        gap: 12px;
    }
    
    .btn-nav {
        width: 100%;
        justify-content: center;
    }
}
</style>
@endpush

@push('scripts')
<script>
const baseUrl = 'https://takaafrica.com/pharmaRh/taka';
let currentStep = 1;
let formData = {
    title: '',
    genre: '',
    language: 'Français', // Langue par défaut
    priceType: 'gratuit',
    price: '',
    summary: '',
    file: null,
    cover: null,
    plan: '',
    authorBio: '',
    authorPhoto: null,
    authorLinks: '',
    excerpt: '',
    quote: ''
};

const plans = @json($plans);
const userId = {{ auth()->user()->api_id ?? auth()->id() }};
const userEmail = '{{ auth()->user()->email }}';
const userName = '{{ auth()->user()->name }}';
let bookToEdit = null;
let oldPlanAmount = null;

// Initialize
document.addEventListener('DOMContentLoaded', function() {
    // Charger les données du livre à modifier depuis sessionStorage
    const savedBook = sessionStorage.getItem('bookToEdit');
    if (savedBook) {
        try {
            bookToEdit = JSON.parse(savedBook);
            loadBookData(bookToEdit);
            // Nettoyer sessionStorage après chargement
            sessionStorage.removeItem('bookToEdit');
        } catch (e) {
            console.error('Erreur lors du chargement des données du livre:', e);
        }
    }
    
    updateStepDisplay();
    setupEventListeners();
    updateSummary();
});

// Fonction pour vérifier si on est en mode édition
function isEditMode() {
    return bookToEdit && bookToEdit.id ? true : false;
}

function loadBookData(book) {
    // Remplir le formulaire avec les données du livre
    formData.title = book.title || '';
    formData.genre = book.genre || '';
    formData.language = book.language || 'Français'; // Langue par défaut
    formData.summary = book.summary || '';
    formData.plan = book.plan || '';
    formData.authorBio = book.author_bio || '';
    formData.authorLinks = book.author_links || '';
    formData.excerpt = book.excerpt || '';
    formData.quote = book.quote || '';
    formData.priceType = book.price_type || 'gratuit';
    formData.price = book.price ? book.price.toString() : '';
    
    // Remplir les champs du formulaire
    if (document.getElementById('bookTitle')) document.getElementById('bookTitle').value = formData.title;
    if (document.getElementById('bookGenre')) document.getElementById('bookGenre').value = formData.genre;
    // Langue fixée à "Français" par défaut, pas de champ à remplir
    if (document.getElementById('bookSummary')) document.getElementById('bookSummary').value = formData.summary;
    // Les champs authorBio, authorLinks, bookExcerpt, bookQuote n'existent plus (étapes 5 et 6 supprimées)
    if (document.getElementById('priceType')) {
        document.getElementById('priceType').value = formData.priceType;
        const priceInput = document.getElementById('bookPrice');
        if (formData.priceType === 'payant') {
            priceInput.style.display = 'block';
            if (priceInput) priceInput.value = formData.price;
        }
    }
    if (document.getElementById('bookPrice')) document.getElementById('bookPrice').value = formData.price;
    
    // Sélectionner le plan
    if (formData.plan) {
        selectPlan(formData.plan);
    }
    
    // Calculer l'ancien montant du plan
    const oldPlan = plans.find(p => p.id === book.plan);
    if (oldPlan) {
        oldPlanAmount = parseInt(oldPlan.price.replace(/\./g, '').replace(' FCFA', '')) || 0;
    }
    
    // Charger la couverture si elle existe
    if (book.cover_path) {
        const coverUrl = book.cover_path.startsWith('http') 
            ? book.cover_path 
            : baseUrl + '/' + book.cover_path;
        const preview = document.getElementById('coverPreview');
        if (preview) {
            preview.innerHTML = `<img src="${coverUrl}" alt="Cover preview">`;
        }
        const coverStatus = document.getElementById('coverStatus');
        if (coverStatus) coverStatus.textContent = '✓ Couverture existante';
    }
    
    // Charger la photo auteur si elle existe
    if (book.author_photo_path) {
        const photoUrl = book.author_photo_path.startsWith('http') 
            ? book.author_photo_path 
            : baseUrl + '/' + book.author_photo_path;
        // Photo auteur supprimée (étape 5 supprimée)
    }
    
    // Indiquer le statut du fichier
    const fileStatus = document.getElementById('fileStatus');
    if (fileStatus && book.file_path) {
        fileStatus.textContent = '✓ Fichier existant (optionnel: télécharger un nouveau fichier pour le remplacer)';
    }
    
    updateSummary();
}

function setupEventListeners() {
    // Price type change
    document.getElementById('priceType').addEventListener('change', function() {
        const priceInput = document.getElementById('bookPrice');
        if (this.value === 'payant') {
            priceInput.style.display = 'block';
        } else {
            priceInput.style.display = 'none';
            priceInput.value = '';
        }
        formData.priceType = this.value;
        updateSummary();
    });

    // File inputs
    document.getElementById('bookFile').addEventListener('change', handleFileSelect);
    document.getElementById('bookCover').addEventListener('change', handleCoverSelect);
    // Les champs authorPhoto, authorBio, authorLinks, bookExcerpt, bookQuote sont supprimés (étapes 5 et 6)

    // Form inputs
    document.getElementById('bookTitle').addEventListener('input', function() {
        formData.title = this.value;
        updateSummary();
    });
    document.getElementById('bookGenre').addEventListener('change', function() {
        formData.genre = this.value;
        updateSummary();
    });
    // Langue fixée à "Français" par défaut, pas de champ ni listener nécessaire
    document.getElementById('bookPrice').addEventListener('input', function() {
        formData.price = this.value;
    });
    document.getElementById('bookSummary').addEventListener('input', function() {
        formData.summary = this.value;
    });
}

function handleFileSelect(e) {
    const file = e.target.files[0];
    if (file) {
        formData.file = file;
        document.getElementById('fileStatus').textContent = '✓ ' + file.name;
        updateSummary();
    }
}

function handleCoverSelect(e) {
    const file = e.target.files[0];
    if (file) {
        formData.cover = file;
        document.getElementById('coverStatus').textContent = '✓ ' + file.name;
        
        // Preview
        const reader = new FileReader();
        reader.onload = function(e) {
            const preview = document.getElementById('coverPreview');
            preview.innerHTML = `<img src="${e.target.result}" alt="Cover preview">`;
        };
        reader.readAsDataURL(file);
        updateSummary();
    }
}

// Fonction handleAuthorPhotoSelect supprimée (étape 5 supprimée)

function selectPlan(planId) {
    formData.plan = planId;
    document.querySelectorAll('.plan-card').forEach(card => {
        card.classList.remove('selected');
    });
    document.querySelector(`[data-plan-id="${planId}"]`).classList.add('selected');
    updateSummary();
}

function nextStep() {
    // Valider l'étape actuelle avant de passer à la suivante
    if (!validateCurrentStep()) {
        return;
    }
    
    if (currentStep < 4) {
        currentStep++;
        updateStepDisplay();
    }
}

function validateCurrentStep() {
    const editMode = isEditMode();
    
    switch(currentStep) {
        case 1:
            // Valider Step 1: Informations du livre
            const title = document.getElementById('bookTitle')?.value.trim() || '';
            const genre = document.getElementById('bookGenre')?.value.trim() || '';
            const summary = document.getElementById('bookSummary')?.value.trim() || '';
            const priceType = document.getElementById('priceType')?.value || '';
            const price = document.getElementById('bookPrice')?.value.trim() || '';
            
            if (!title) {
                alert('Veuillez remplir le titre du livre.');
                document.getElementById('bookTitle')?.focus();
                return false;
            }
            if (!genre) {
                alert('Veuillez sélectionner une thématique.');
                document.getElementById('bookGenre')?.focus();
                return false;
            }
            if (!summary) {
                alert('Veuillez remplir la description du livre.');
                document.getElementById('bookSummary')?.focus();
                return false;
            }
            if (priceType === 'payant' && (!price || parseFloat(price) <= 0)) {
                alert('Veuillez entrer un prix valide pour un livre payant.');
                document.getElementById('bookPrice')?.focus();
                return false;
            }
            return true;
            
        case 2:
            // Valider Step 2: Fichier du livre
            const file = document.getElementById('bookFile')?.files?.[0];
            if (!file && !editMode) {
                alert('Veuillez télécharger le fichier du livre.');
                return false;
            }
            return true;
            
        case 3:
            // Valider Step 3: Couverture
            const cover = document.getElementById('bookCover')?.files?.[0];
            if (!cover && !editMode) {
                alert('Veuillez télécharger la couverture du livre.');
                return false;
            }
            return true;
            
        case 4:
            // Valider Step 4: Plan de publication
            if (!formData.plan) {
                alert('Veuillez sélectionner un plan de publication.');
                return false;
            }
            return true;
            
        default:
            return true;
    }
}

function prevStep() {
    if (currentStep > 1) {
        currentStep--;
        updateStepDisplay();
    }
}

function updateStepDisplay() {
    // Update panels
    document.querySelectorAll('.step-panel').forEach((panel, index) => {
        if (index + 1 === currentStep) {
            panel.classList.add('active');
        } else {
            panel.classList.remove('active');
        }
    });

    // Update steps
    document.querySelectorAll('.step-item').forEach((item, index) => {
        const stepNum = index + 1;
        if (stepNum < currentStep) {
            item.classList.add('completed');
            item.classList.remove('active');
        } else if (stepNum === currentStep) {
            item.classList.add('active');
            item.classList.remove('completed');
        } else {
            item.classList.remove('active', 'completed');
        }
    });

    // Update buttons
    document.getElementById('prevBtn').disabled = currentStep === 1;
    if (currentStep < 4) {
        document.getElementById('nextBtn').style.display = 'flex';
        document.getElementById('submitBtn').style.display = 'none';
    } else {
        document.getElementById('nextBtn').style.display = 'none';
        document.getElementById('submitBtn').style.display = 'flex';
    }
}

function updateSummary() {
    document.getElementById('summaryTitle').textContent = formData.title || 'Non renseigné';
    document.getElementById('summaryGenre').textContent = formData.genre || 'Non renseigné';
    
    const selectedPlan = plans.find(p => p.id === formData.plan);
    document.getElementById('summaryPlan').textContent = selectedPlan ? selectedPlan.name : 'Non sélectionné';
    document.getElementById('summaryFile').textContent = formData.file ? '✓ Ajouté' : '✗ Manquant';
    document.getElementById('summaryCover').textContent = formData.cover ? '✓ Ajoutée' : '✗ Manquante';
}

async function handleSubmit() {
    const isEditMode = bookToEdit && bookToEdit.id;
    
    // S'assurer que la langue est toujours définie
    if (!formData.language || formData.language.trim() === '') {
        formData.language = 'Français';
    }
    
    // Validation
    if (!formData.title || !formData.title.trim() || !formData.genre || !formData.genre.trim() || !formData.summary || !formData.summary.trim()) {
        alert('Veuillez remplir tous les champs obligatoires de l\'étape 1 (Titre, Thématique et Description).');
        currentStep = 1;
        updateStepDisplay();
        return;
    }
    
    // En mode édition, le fichier n'est pas obligatoire (on garde l'ancien si pas de nouveau)
    if (!isEditMode && !formData.file) {
        alert('Veuillez télécharger le fichier du livre.');
        currentStep = 2;
        updateStepDisplay();
        return;
    }
    
    // En mode édition, la couverture n'est pas obligatoire (on garde l'ancienne si pas de nouvelle)
    if (!isEditMode && !formData.cover) {
        alert('Veuillez télécharger la couverture.');
        currentStep = 3;
        updateStepDisplay();
        return;
    }
    
    if (!formData.plan) {
        alert('Veuillez sélectionner un plan de publication.');
        currentStep = 4;
        updateStepDisplay();
        return;
    }
    
    // Les champs authorBio, authorLinks, authorPhoto, excerpt et quote sont maintenant optionnels

    const selectedPlan = plans.find(p => p.id === formData.plan);
    const isPaidPlan = selectedPlan.price !== '0 FCFA';
    const planAmount = parseInt(selectedPlan.price.replace(/\./g, '').replace(' FCFA', '')) || 0;

    // Gérer le paiement si nécessaire (uniquement pour les nouveaux livres ou changement de plan payant)
    if (isPaidPlan && planAmount > 0) {
        if (!isEditMode || (oldPlanAmount !== null && planAmount !== oldPlanAmount)) {
            // Process payment (qui gère aussi la publication pour les nouveaux livres)
            const paid = await processPublicationPayment(planAmount, selectedPlan.name);
            if (!paid) {
                document.getElementById('loadingOverlay').style.display = 'none';
                alert('Paiement non effectué ou publication non validée.');
                return;
            }
            // Si le paiement réussit, la publication a déjà été effectuée par l'API de paiement
            // On redirige directement vers le dashboard
            if (!isEditMode) {
                alert('Livre publié avec succès après paiement !');
                window.location.href = '{{ route("dashboard") }}';
                return;
            }
            // En mode édition, après paiement réussi, on continue pour mettre à jour les autres champs
        }
    }

    // Submit or update book (sauf si nouveau livre avec paiement réussi, car déjà publié)
    document.getElementById('loadingOverlay').style.display = 'flex';
    
    try {
        const formDataToSend = new FormData();
        formDataToSend.append('title', formData.title);
        formDataToSend.append('genre', formData.genre);
        // Langue toujours en français par défaut
        formDataToSend.append('language', 'Français');
        formDataToSend.append('summary', formData.summary);
        formDataToSend.append('plan', formData.plan);
        // Les champs authorBio, authorLinks, excerpt, quote sont optionnels maintenant
        // Mais l'API les exige, donc on envoie des valeurs par défaut si vides
        formDataToSend.append('authorBio', formData.authorBio && formData.authorBio.trim() ? formData.authorBio : 'Non renseigné');
        formDataToSend.append('authorLinks', formData.authorLinks || '');
        formDataToSend.append('excerpt', formData.excerpt && formData.excerpt.trim() ? formData.excerpt : 'Non renseigné');
        formDataToSend.append('quote', formData.quote || '');
        formDataToSend.append('priceType', formData.priceType);
        formDataToSend.append('price', formData.price || '0');
        formDataToSend.append('user_id', userId);
        
        // En mode édition, ajouter l'ID du livre
        if (isEditMode) {
            formDataToSend.append('id', bookToEdit.id);
        }
        
        // Les fichiers sont optionnels en mode édition
        if (formData.file) {
            formDataToSend.append('file', formData.file);
        }
        if (formData.cover) {
            formDataToSend.append('cover', formData.cover);
        }
        // Photo auteur optionnelle (étape 5 supprimée)
        if (formData.authorPhoto) {
            formDataToSend.append('authorPhoto', formData.authorPhoto);
        }

        // Utiliser l'API update si en mode édition, sinon publish
        const apiEndpoint = isEditMode ? '/taka_api_update_book.php' : '/taka_api_publish.php';
        const response = await fetch(baseUrl + apiEndpoint, {
            method: 'POST',
            body: formDataToSend
        });

        // Récupérer le texte de la réponse d'abord pour vérifier si c'est du JSON
        const responseText = await response.text();
        
        // Vérifier si la réponse est du HTML (erreur serveur)
        if (responseText.trim().startsWith('<!DOCTYPE') || responseText.trim().startsWith('<html') || responseText.trim().startsWith('<?php')) {
            console.error('Erreur: Le serveur a renvoyé du HTML au lieu de JSON:', responseText.substring(0, 200));
            document.getElementById('loadingOverlay').style.display = 'none';
            alert('Erreur serveur: L\'API n\'est pas accessible. Veuillez contacter le support technique.');
            return;
        }

        // Parser le JSON
        let result;
        try {
            result = JSON.parse(responseText);
        } catch (e) {
            console.error('Erreur de parsing JSON:', e, 'Réponse reçue:', responseText.substring(0, 200));
            document.getElementById('loadingOverlay').style.display = 'none';
            alert('Erreur: Réponse invalide du serveur. Veuillez réessayer ou contacter le support.');
            return;
        }
        
        document.getElementById('loadingOverlay').style.display = 'none';

        if (result.success) {
            if (isEditMode) {
                alert('Livre mis à jour avec succès !');
            } else {
                alert('Livre soumis avec succès ! Vous recevrez une confirmation par email.');
            }
            window.location.href = '{{ route("dashboard") }}';
        } else {
            const errorMsg = result.error || 'Erreur lors de la ' + (isEditMode ? 'mise à jour' : 'soumission') + '. Veuillez réessayer.';
            alert(errorMsg);
        }
    } catch (error) {
        document.getElementById('loadingOverlay').style.display = 'none';
        console.error('Erreur:', error);
        alert('Erreur réseau: ' + error.message);
    }
}

async function processPublicationPayment(amount, planName) {
    try {
        const currency = localStorage.getItem('currency') || 'XOF';
        const country = localStorage.getItem('country') || 'Bénin';
        
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
        const finalAmount = Math.round(amount);
        
        if (finalAmount <= 0) {
            return false;
        }
        
        const payload = {
            amount: finalAmount,
            currency: currency,
            country: country,
            description: 'Publication plan ' + planName,
            email: userEmail,
            first_name: firstName,
            last_name: lastName,
            user_id: userId,
            plan: planName,
            title: formData.title,
            genre: formData.genre,
            language: 'Français', // Langue toujours en français
            summary: formData.summary,
            authorBio: formData.authorBio && formData.authorBio.trim() ? formData.authorBio : 'Non renseigné',
            authorLinks: formData.authorLinks || '',
            excerpt: formData.excerpt && formData.excerpt.trim() ? formData.excerpt : 'Non renseigné',
            quote: formData.quote || '',
            priceType: formData.priceType,
            price: formData.price,
            return_url: 'https://takaafrica.com',
        };

        const response = await fetch(baseUrl + '/moneroo_publish_init.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(payload),
        });

        // Récupérer le texte de la réponse d'abord pour vérifier si c'est du JSON
        const responseText = await response.text();
        
        // Vérifier si la réponse est du HTML (erreur serveur)
        if (responseText.trim().startsWith('<!DOCTYPE') || responseText.trim().startsWith('<html') || responseText.trim().startsWith('<?php')) {
            console.error('Erreur: Le serveur a renvoyé du HTML au lieu de JSON:', responseText.substring(0, 200));
            alert('Erreur serveur: L\'API de paiement n\'est pas accessible. Veuillez contacter le support technique.');
            return false;
        }

        // Vérifier si la réponse est OK avant de parser le JSON
        let data;
        try {
            data = JSON.parse(responseText);
        } catch (e) {
            console.error('Erreur de parsing JSON:', e, 'Réponse reçue:', responseText.substring(0, 200));
            alert('Erreur: Réponse invalide du serveur. Veuillez réessayer ou contacter le support.');
            return false;
        }

        if (!response.ok || data.error) {
            console.error('Erreur API:', data);
            
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
            return false;
        }

        if (data.checkout_url && data.transaction_ref) {
            window.open(data.checkout_url, '_blank');
            
            // Polling pour vérifier la publication
            let published = false;
            let retry = 0;
            while (!published && retry < 60) {
                await new Promise(resolve => setTimeout(resolve, 2000));
                
                try {
                    const pollResp = await fetch(`${baseUrl}/taka_api_publish_status.php?transaction_ref=${data.transaction_ref}`);
                    const pollData = await pollResp.json();
                    if (pollData.status === 'published') {
                        published = true;
                        break;
                    }
                } catch (e) {
                    console.error('Erreur polling:', e);
                }
                retry++;
            }
            return published;
        } else {
            return false;
        }
    } catch (e) {
        console.error('Erreur Moneroo:', e);
        return false;
    }
}
</script>
@endpush
@endsection
@endif
