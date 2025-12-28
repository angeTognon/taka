<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class TakaAdminController extends Controller
{
    private const ADMIN_EMAIL = 'admin@gmail.com';
    private const ADMIN_PASSWORD = 'Taka2025#';

    public function showLogin()
    {
        // Si déjà authentifié, rediriger vers la page admin
        if (session('admin_authenticated')) {
            return redirect()->route('admin');
        }
        
        return view('admin.login');
    }

    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        if ($request->email === self::ADMIN_EMAIL && $request->password === self::ADMIN_PASSWORD) {
            session(['admin_authenticated' => true]);
            return redirect()->route('admin')->with('success', 'Connexion réussie');
        }

        return back()->withErrors([
            'email' => 'Les identifiants fournis ne correspondent pas à nos enregistrements.',
        ])->withInput($request->only('email'));
    }

    public function logout()
    {
        session()->forget('admin_authenticated');
        return redirect()->route('admin.login')->with('success', 'Déconnexion réussie');
    }

    public function index()
    {
        // Vérifier l'authentification
        if (!session('admin_authenticated')) {
            return redirect()->route('admin.login');
        }

        return view('admin.index');
    }
}
