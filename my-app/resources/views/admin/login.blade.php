@extends('layouts.app')

@section('title', 'Connexion Admin - TAKA')

@section('content')
<div class="admin-login-page">
    <div class="admin-login-container">
        <div class="admin-login-card">
            <div class="admin-login-header">
                <h1>Administration TAKA</h1>
                <p>Connexion à l'espace d'administration</p>
            </div>

            @if(session('success'))
                <div class="alert alert-success">
                    {{ session('success') }}
                </div>
            @endif

            @if($errors->any())
                <div class="alert alert-error">
                    {{ $errors->first() }}
                </div>
            @endif

            <form method="POST" action="{{ route('admin.login.post') }}" class="admin-login-form">
                @csrf
                
                <div class="form-group">
                    <label for="email">Email</label>
                    <input 
                        type="email" 
                        id="email" 
                        name="email" 
                        value="{{ old('email') }}" 
                        required 
                        autofocus
                        placeholder="admin@gmail.com"
                        class="form-control @error('email') is-invalid @enderror"
                    >
                </div>

                <div class="form-group">
                    <label for="password">Mot de passe</label>
                    <input 
                        type="password" 
                        id="password" 
                        name="password" 
                        required
                        placeholder="••••••••"
                        class="form-control @error('password') is-invalid @enderror"
                    >
                </div>

                <button type="submit" class="btn-login">
                    Se connecter
                </button>
            </form>
        </div>
    </div>
</div>

@push('styles')
<style>
.admin-login-page {
    min-height: calc(100vh - 200px);
    display: flex;
    align-items: center;
    justify-content: center;
    background: linear-gradient(135deg, #F9FAFB 0%, #E5E7EB 100%);
    padding: 40px 20px;
}

.admin-login-container {
    width: 100%;
    max-width: 450px;
}

.admin-login-card {
    background: white;
    border-radius: 16px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
    padding: 40px;
}

.admin-login-header {
    text-align: center;
    margin-bottom: 32px;
}

.admin-login-header h1 {
    font-size: 28px;
    font-weight: 700;
    color: #F97316;
    margin-bottom: 8px;
    font-family: 'Inter', sans-serif;
}

.admin-login-header p {
    font-size: 14px;
    color: #6B7280;
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

.admin-login-form {
    width: 100%;
}

.form-group {
    margin-bottom: 24px;
}

.form-group label {
    display: block;
    font-size: 14px;
    font-weight: 500;
    color: #374151;
    margin-bottom: 8px;
    font-family: 'Inter', sans-serif;
}

.form-control {
    width: 100%;
    padding: 12px 16px;
    font-size: 14px;
    border: 1px solid #D1D5DB;
    border-radius: 8px;
    background: white;
    transition: border-color 0.2s, box-shadow 0.2s;
    font-family: 'Inter', sans-serif;
}

.form-control:focus {
    outline: none;
    border-color: #F97316;
    box-shadow: 0 0 0 3px rgba(249, 115, 22, 0.1);
}

.form-control.is-invalid {
    border-color: #EF4444;
}

.btn-login {
    width: 100%;
    padding: 14px;
    background: #F97316;
    color: white;
    border: none;
    border-radius: 8px;
    font-size: 16px;
    font-weight: 600;
    cursor: pointer;
    transition: background 0.2s, transform 0.1s;
    font-family: 'Inter', sans-serif;
}

.btn-login:hover {
    background: #EA580C;
}

.btn-login:active {
    transform: scale(0.98);
}

/* Responsive */
@media (max-width: 768px) {
    .admin-login-page {
        padding: 20px;
        min-height: calc(100vh - 150px);
    }

    .admin-login-card {
        padding: 32px 24px;
    }

    .admin-login-header h1 {
        font-size: 24px;
    }
}
</style>
@endpush
@endsection

