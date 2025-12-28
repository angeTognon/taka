@extends('layouts.app')

@section('title', 'Connexion - TAKA')

@section('content')
<div class="login-page">
    <div class="login-container">
        <div class="login-card">
            <!-- Logo -->
            <div class="login-logo">
                <a href="{{ route('home') }}">
                    <h1 class="logo-text">TAKA</h1>
                    <div class="logo-underline"></div>
                </a>
            </div>

            <h2 class="login-title" id="loginTitle">Connectez-vous à votre compte</h2>
            <p class="login-subtitle" id="loginSubtitle">Retrouvez votre bibliothèque personnelle</p>

            @if(session('success'))
                <div class="alert alert-success">
                    {{ session('success') }}
                </div>
            @endif

            <!-- Toggle between login and register -->
            <div class="auth-toggle">
                <button class="toggle-btn active" id="loginToggle" onclick="showLogin()">Connexion</button>
                <button class="toggle-btn" id="registerToggle" onclick="showRegister()">Inscription</button>
            </div>

            <!-- Login Form -->
            <form method="POST" action="{{ route('login') }}" id="loginForm" class="auth-form">
                @csrf
                
                <div class="form-group">
                    <label>Adresse email</label>
                    <input type="email" name="email" required 
                           value="{{ old('email') }}"
                           class="form-input @error('email') error @enderror">
                    @error('email')
                        <span class="error-message">{{ $message }}</span>
                    @enderror
                </div>

                <div class="form-group">
                    <label>Mot de passe</label>
                    <div class="password-input-wrapper">
                        <input type="password" name="password" required 
                               class="form-input @error('password') error @enderror" 
                               id="loginPassword">
                        <button type="button" class="password-toggle" onclick="togglePassword('loginPassword')">
                            👁️
                        </button>
                    </div>
                    @error('password')
                        <span class="error-message">{{ $message }}</span>
                    @enderror
                </div>

                <div class="form-options">
                    <label class="checkbox-label">
                        <input type="checkbox" name="remember">
                        <span>Se souvenir de moi</span>
                    </label>
                    <a href="#" class="forgot-password">Mot de passe oublié ?</a>
                </div>

                <button type="submit" class="btn-submit">Se connecter</button>
            </form>

            <!-- Register Form -->
            <form method="POST" action="{{ route('register') }}" id="registerForm" class="auth-form" style="display: none;">
                @csrf
                
                @php
                    // Récupérer le paramètre ref depuis l'URL pour l'affiliation
                    $ref = request()->query('ref');
                @endphp
                @if($ref)
                    <input type="hidden" name="ref" value="{{ $ref }}">
                @endif
                
                <div class="form-group">
                    <label>Nom complet</label>
                    <input type="text" name="full_name" required 
                           value="{{ old('full_name') }}"
                           class="form-input @error('full_name') error @enderror">
                    @error('full_name')
                        <span class="error-message">{{ $message }}</span>
                    @enderror
                </div>

                <div class="form-group">
                    <label>Adresse email</label>
                    <input type="email" name="email" required 
                           value="{{ old('email') }}"
                           class="form-input @error('email') error @enderror">
                    @error('email')
                        <span class="error-message">{{ $message }}</span>
                    @enderror
                </div>

                <div class="form-group">
                    <label>Mot de passe</label>
                    <div class="password-input-wrapper">
                        <input type="password" name="password" required 
                               class="form-input @error('password') error @enderror" 
                               id="registerPassword">
                        <button type="button" class="password-toggle" onclick="togglePassword('registerPassword')">
                            👁️
                        </button>
                    </div>
                    @error('password')
                        <span class="error-message">{{ $message }}</span>
                    @enderror
                </div>

                <div class="form-group">
                    <label>Confirmer le mot de passe</label>
                    <div class="password-input-wrapper">
                        <input type="password" name="password_confirmation" required 
                               class="form-input" id="registerPasswordConfirm">
                        <button type="button" class="password-toggle" onclick="togglePassword('registerPasswordConfirm')">
                            👁️
                        </button>
                    </div>
                </div>

                <label class="checkbox-label">
                    <input type="checkbox" required>
                    <span>J'accepte les conditions d'utilisation et la politique de confidentialité</span>
                </label>

                <button type="submit" class="btn-submit">Créer mon compte</button>
            </form>

            <!-- Benefits for registration -->
            <div class="benefits-card" id="benefitsCard" style="display: none;">
                <h3>Pourquoi rejoindre TAKA ?</h3>
                <ul class="benefits-list">
                    <li>Accès à des milliers de livres africains</li>
                    <li>Recommandations personnalisées</li>
                    <li>Lecture hors ligne sur tous vos appareils</li>
                    <li>Soutenez les auteurs africains</li>
                </ul>
            </div>
        </div>
    </div>
</div>

@push('styles')
<style>
.login-page {
    min-height: calc(100vh - 200px);
    background: linear-gradient(135deg, #FFF7ED 0%, #FFFFFF 100%);
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 40px 20px;
}

.login-container {
    width: 100%;
    max-width: 448px;
}

.login-card {
    background: white;
    padding: 32px;
    border-radius: 16px;
    box-shadow: 0 4px 16px rgba(0,0,0,0.1);
}

.login-logo {
    text-align: center;
    margin-bottom: 32px;
}

.logo-text {
    font-size: 32px;
    font-weight: 700;
    color: #000;
    letter-spacing: 0.5px;
    position: relative;
    display: inline-block;
}

.logo-underline {
    height: 4px;
    background: linear-gradient(90deg, #F97316, #FB923C);
    border-radius: 2px;
    margin-top: -2px;
    transform: rotate(1deg);
}

.login-title {
    font-size: 24px;
    font-weight: 700;
    color: #111827;
    text-align: center;
    margin-bottom: 8px;
}

.login-subtitle {
    font-size: 14px;
    color: #6B7280;
    text-align: center;
    margin-bottom: 32px;
}

.auth-toggle {
    display: flex;
    gap: 8px;
    margin-bottom: 32px;
}

.toggle-btn {
    flex: 1;
    padding: 12px;
    border: 2px solid #E5E7EB;
    background: white;
    border-radius: 8px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s;
}

.toggle-btn.active {
    background: #F97316;
    color: white;
    border-color: #F97316;
}

.auth-form {
    display: flex;
    flex-direction: column;
    gap: 24px;
}

.form-group {
    display: flex;
    flex-direction: column;
    gap: 8px;
}

.form-group label {
    font-size: 14px;
    font-weight: 500;
    color: #374151;
}

.form-input {
    padding: 12px 16px;
    border: 1px solid #D1D5DB;
    border-radius: 8px;
    font-size: 14px;
    transition: border-color 0.2s;
}

.form-input:focus {
    outline: none;
    border-color: #F97316;
    border-width: 2px;
}

.form-input.error {
    border-color: #EF4444;
}

.error-message {
    color: #EF4444;
    font-size: 12px;
}

.password-input-wrapper {
    position: relative;
}

.password-toggle {
    position: absolute;
    right: 12px;
    top: 50%;
    transform: translateY(-50%);
    background: none;
    border: none;
    cursor: pointer;
    font-size: 18px;
}

.form-options {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.checkbox-label {
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 14px;
    color: #6B7280;
    cursor: pointer;
}

.checkbox-label input[type="checkbox"] {
    width: 16px;
    height: 16px;
    accent-color: #F97316;
}

.forgot-password {
    font-size: 14px;
    color: #F97316;
    text-decoration: none;
}

.btn-submit {
    width: 100%;
    padding: 22px;
    background: #F97316;
    color: white;
    border: none;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 500;
    cursor: pointer;
    transition: background 0.2s;
}

.btn-submit:hover {
    background: #EA580C;
}

.benefits-card {
    margin-top: 32px;
    padding: 24px;
    background: white;
    border-radius: 16px;
    box-shadow: 0 4px 16px rgba(0,0,0,0.1);
}

.benefits-card h3 {
    font-size: 18px;
    font-weight: 600;
    color: #000;
    margin-bottom: 16px;
    text-align: center;
}

.benefits-list {
    list-style: none;
    padding: 0;
}

.benefits-list li {
    padding: 8px 0;
    font-size: 14px;
    color: #374151;
    display: flex;
    align-items: center;
    gap: 12px;
}

.benefits-list li::before {
    content: '';
    width: 8px;
    height: 8px;
    background: #F97316;
    border-radius: 50%;
}

.alert {
    padding: 12px 16px;
    border-radius: 8px;
    margin-bottom: 24px;
    font-size: 14px;
}

.alert-success {
    background: #D1FAE5;
    color: #065F46;
    border: 1px solid #10B981;
}

.alert-error {
    background: #FEE2E2;
    color: #991B1B;
    border: 1px solid #EF4444;
}

@media (max-width: 600px) {
    .login-card {
        padding: 24px;
    }
    
    .login-title {
        font-size: 18px;
    }
}
</style>
@endpush

@push('scripts')
<script>
function showLogin() {
    document.getElementById('loginForm').style.display = 'flex';
    document.getElementById('registerForm').style.display = 'none';
    document.getElementById('benefitsCard').style.display = 'none';
    document.getElementById('loginToggle').classList.add('active');
    document.getElementById('registerToggle').classList.remove('active');
    document.getElementById('loginTitle').textContent = 'Connectez-vous à votre compte';
    document.getElementById('loginSubtitle').textContent = 'Retrouvez votre bibliothèque personnelle';
}

function showRegister() {
    document.getElementById('loginForm').style.display = 'none';
    document.getElementById('registerForm').style.display = 'flex';
    document.getElementById('benefitsCard').style.display = 'block';
    document.getElementById('loginToggle').classList.remove('active');
    document.getElementById('registerToggle').classList.add('active');
    document.getElementById('loginTitle').textContent = 'Créez votre compte TAKA';
    document.getElementById('loginSubtitle').textContent = 'Rejoignez la communauté des lecteurs africains';
}

function togglePassword(inputId) {
    const input = document.getElementById(inputId);
    input.type = input.type === 'password' ? 'text' : 'password';
}
</script>
@endpush
@endsection

