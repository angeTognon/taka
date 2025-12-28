<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\HomeController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\ExploreController;
use App\Http\Controllers\BookController;
use App\Http\Controllers\ReaderController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\PublishController;
use App\Http\Controllers\SubscriptionController;
use App\Http\Controllers\AffiliateController;
use App\Http\Controllers\WalletController;
use App\Http\Controllers\AboutController;
use App\Http\Controllers\ContactController;
use App\Http\Controllers\FaqController;
use App\Http\Controllers\PolitiqueController;
use App\Http\Controllers\ConditionsController;
use App\Http\Controllers\TakaAdminController;
use App\Http\Controllers\AffiliateProgramController;

// Public routes
Route::get('/', [HomeController::class, 'index'])->name('home');
Route::get('/explore', [ExploreController::class, 'index'])->name('explore');

// Public content routes (must be before book route)
Route::get('/subscription', [SubscriptionController::class, 'index'])->name('subscription');
Route::get('/affiliate', [AffiliateController::class, 'index'])->name('affiliate');
Route::get('/affiliate-program', [AffiliateProgramController::class, 'index'])->name('affiliate.program');
Route::get('/about', [AboutController::class, 'index'])->name('about');
Route::get('/contact', [ContactController::class, 'index'])->name('contact');
Route::get('/faq/authors', [FaqController::class, 'authors'])->name('faq.authors');
Route::get('/faq/readers', [FaqController::class, 'readers'])->name('faq.readers');
Route::get('/politique', [PolitiqueController::class, 'index'])->name('politique');
Route::get('/conditions', [ConditionsController::class, 'index'])->name('conditions');
Route::get('/takaadmin', [TakaAdminController::class, 'index'])->name('admin.index');
Route::get('/admin/login', [TakaAdminController::class, 'showLogin'])->name('admin.login');
Route::post('/admin/login', [TakaAdminController::class, 'login'])->name('admin.login.post');
Route::post('/admin/logout', [TakaAdminController::class, 'logout'])->name('admin.logout');
Route::get('/admin', [TakaAdminController::class, 'index'])->name('admin');

// Authentication routes
Route::get('/login', [AuthController::class, 'showLogin'])->name('login');
Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register'])->name('register');
Route::post('/logout', [AuthController::class, 'logout'])->name('logout');

// Protected routes
Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'index'])->name('profile');
    Route::post('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::get('/dashboard', [DashboardController::class, 'index'])->name('dashboard');
    Route::post('/dashboard/delete-book', [DashboardController::class, 'deleteBook'])->name('dashboard.delete');
    Route::get('/publish', [PublishController::class, 'index'])->name('publish');
    Route::post('/publish', [PublishController::class, 'store'])->name('publish.store');
    Route::get('/wallet', [WalletController::class, 'index'])->name('wallet');
    Route::get('/wallet/withdrawal-status', [WalletController::class, 'checkWithdrawalStatus'])->name('wallet.withdrawal-status');
    Route::post('/wallet/request-withdrawal', [WalletController::class, 'requestWithdrawal'])->name('wallet.request-withdrawal');
    Route::get('/reader/{slug}', [ReaderController::class, 'show'])->name('reader.show');
    
    // Affiliate routes
    Route::post('/affiliate/create-link', [AffiliateController::class, 'createLink'])->name('affiliate.create');
    Route::post('/affiliate/edit-link', [AffiliateController::class, 'editLink'])->name('affiliate.edit');
    Route::post('/affiliate/delete-link', [AffiliateController::class, 'deleteLink'])->name('affiliate.delete');
    Route::get('/affiliate/author-books', [AffiliateController::class, 'getAuthorBooks'])->name('affiliate.author-books');
});

// Book routes (slug-based) - MUST be last to avoid route conflicts
Route::get('/{slug}', [BookController::class, 'show'])->name('book.show');
