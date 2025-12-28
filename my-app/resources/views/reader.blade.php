@extends('layouts.app', ['hideHeader' => true, 'hideFooter' => true])

@section('title', ($bookTitle ?? 'Livre') . ' - Lecteur TAKA')

@section('content')
<div class="reader-page" id="readerPage">
    <!-- Header -->
    <div class="reader-header" id="readerHeader">
        <div class="reader-header-content">
            <button onclick="goBack()" class="reader-btn-back">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M19 12H5M12 19l-7-7 7-7"/>
                </svg>
                <span>Retour</span>
            </button>
            
            <div class="reader-title-section">
                <h2 class="reader-book-title" id="readerBookTitle">{{ $bookTitle ?? '' }}</h2>
                <p class="reader-book-author" id="readerBookAuthor">{{ $bookAuthor ?? '' }}</p>
            </div>
            
            <div class="reader-header-actions">
                <button class="reader-icon-btn" onclick="toggleSettings()" title="Paramètres">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <circle cx="12" cy="12" r="3"/>
                        <path d="M12 1v6m0 6v6m9-9h-6m-6 0H3m15.364 6.364l-4.243-4.243m-4.242 0l-4.243 4.243m8.485 0l-4.243-4.243m-4.242 0l4.243-4.243"/>
                    </svg>
                </button>
                <button class="reader-icon-btn" onclick="toggleNotes()" title="Annotations">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M3 6h18M3 12h18M3 18h18"/>
                    </svg>
                </button>
            </div>
        </div>
        
        <!-- Progress Bar -->
        <div class="reader-progress-bar">
            <div class="reader-progress-fill" id="progressFill" style="width: 0%"></div>
        </div>
    </div>

    <!-- Main Content -->
    <div class="reader-main">
        <!-- PDF Viewer -->
        <div class="reader-content-wrapper">
            <!-- Reading Controls -->
            <div class="reader-controls" id="readingControls">
                <button class="reader-control-btn" onclick="previousPage()" id="prevPageBtn">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M19 12H5M12 19l-7-7 7-7"/>
                    </svg>
                    <span>Page précédente</span>
                </button>
                
                <span class="reader-page-info" id="pageInfo">Page 1 sur {{ $totalPages }}</span>
                
                <button class="reader-control-btn" onclick="nextPage()" id="nextPageBtn">
                    <span>Page suivante</span>
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M5 12h14M12 5l7 7-7 7"/>
                    </svg>
                </button>
            </div>
            
            <!-- PDF Container -->
            <div class="reader-pdf-container" id="pdfContainer">
                @if(!empty($pdfUrl))
                    <!-- Overlay to hide toolbar -->
                    <div class="pdf-toolbar-overlay"></div>
                    <!-- Using iframe with PDF.js viewer for navigation control -->
                    <iframe 
                        id="pdfViewer" 
                        src="https://mozilla.github.io/pdf.js/web/viewer.html?file={{ urlencode($pdfUrl) }}" 
                        class="pdf-viewer-iframe"
                        frameborder="0">
                    </iframe>
                @else
                    <div class="reader-error">
                        <p>Fichier PDF non disponible</p>
                    </div>
                @endif
            </div>
            
            <!-- Warning Message -->
            <div class="reader-warning">
                <span class="reader-warning-icon">📚</span>
                <p class="reader-warning-text">Lecture uniquement possible via l'application – aucun téléchargement autorisé</p>
            </div>
        </div>

        <!-- Settings Panel -->
        <div class="reader-panel reader-settings-panel" id="settingsPanel">
            <div class="reader-panel-header">
                <h3>Paramètres de lecture</h3>
                <button class="reader-panel-close" onclick="toggleSettings()">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <line x1="18" y1="6" x2="6" y2="18"/>
                        <line x1="6" y1="6" x2="18" y2="18"/>
                    </svg>
                </button>
            </div>
            
            <div class="reader-panel-content">
                <!-- Theme Toggle -->
                <div class="reader-setting-section">
                    <label class="reader-setting-label">Thème</label>
                    <div class="reader-theme-buttons">
                        <button class="reader-theme-btn" id="lightThemeBtn" onclick="setTheme('light')">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <circle cx="12" cy="12" r="5"/>
                                <line x1="12" y1="1" x2="12" y2="3"/>
                                <line x1="12" y1="21" x2="12" y2="23"/>
                                <line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/>
                                <line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/>
                                <line x1="1" y1="12" x2="3" y2="12"/>
                                <line x1="21" y1="12" x2="23" y2="12"/>
                                <line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/>
                                <line x1="18.36" y1="5.64" x2="19.78" y2="4.22"/>
                            </svg>
                            <span>Jour</span>
                        </button>
                        <button class="reader-theme-btn" id="darkThemeBtn" onclick="setTheme('dark')">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/>
                            </svg>
                            <span>Nuit</span>
                        </button>
                    </div>
                </div>

                <!-- Font Size -->
                <div class="reader-setting-section">
                    <label class="reader-setting-label">Taille de police (UI)</label>
                    <div class="reader-font-size-control">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <text x="12" y="16" text-anchor="middle" font-size="12" fill="currentColor">A</text>
                        </svg>
                        <input type="range" min="12" max="24" value="16" step="1" id="fontSizeSlider" oninput="updateFontSize(this.value)">
                        <span class="reader-font-size-value" id="fontSizeValue">16px</span>
                    </div>
                </div>

                <!-- Progress -->
                <div class="reader-setting-section">
                    <label class="reader-setting-label">Progression</label>
                    <div class="reader-progress-info">
                        <span id="progressPageInfo">Page 1 / {{ $totalPages }}</span>
                        <span id="progressPercent">0%</span>
                    </div>
                    <div class="reader-progress-track">
                        <div class="reader-progress-fill-small" id="progressFillSmall" style="width: 0%"></div>
                    </div>
                </div>

                <!-- Quick Actions -->
                <div class="reader-setting-section">
                    <button class="reader-quick-action-btn" onclick="addBookmark()">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/>
                        </svg>
                        <span>Ajouter un signet</span>
                    </button>
                </div>
            </div>
        </div>

        <!-- Notes Panel -->
        <div class="reader-panel reader-notes-panel" id="notesPanel">
            <div class="reader-panel-header">
                <h3>Mes annotations</h3>
                <button class="reader-panel-close" onclick="toggleNotes()">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <line x1="18" y1="6" x2="6" y2="18"/>
                        <line x1="6" y1="6" x2="18" y2="18"/>
                    </svg>
                </button>
            </div>
            
            <div class="reader-panel-content">
                <!-- Bookmarks Section -->
                <div class="reader-notes-section">
                    <div class="reader-notes-section-header">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/>
                        </svg>
                        <h4>Signets (<span id="bookmarksCount">0</span>)</h4>
                    </div>
                    <div id="bookmarksList" class="reader-notes-list"></div>
                </div>

                <!-- Highlights Section -->
                <div class="reader-notes-section">
                    <div class="reader-notes-section-header">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/>
                        </svg>
                        <h4>Surlignages (<span id="highlightsCount">0</span>)</h4>
                    </div>
                    <div id="highlightsList" class="reader-notes-list"></div>
                </div>

                <!-- Notes Section -->
                <div class="reader-notes-section">
                    <div class="reader-notes-section-header">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                            <polyline points="14 2 14 8 20 8"/>
                            <line x1="16" y1="13" x2="8" y2="13"/>
                            <line x1="16" y1="17" x2="8" y2="17"/>
                            <polyline points="10 9 9 9 8 9"/>
                        </svg>
                        <h4>Notes (<span id="notesCount">0</span>)</h4>
                    </div>
                    <div id="notesList" class="reader-notes-list"></div>
                </div>
            </div>
        </div>
    </div>
</div>

@push('styles')
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
<style>
:root {
    --reader-bg-light: #FFFFFF;
    --reader-bg-dark: #111827;
    --reader-header-light: #FFFFFF;
    --reader-header-dark: #1F2937;
    --reader-text-light: #000000;
    --reader-text-dark: #FFFFFF;
    --reader-text-secondary-light: #6B7280;
    --reader-text-secondary-dark: #9CA3AF;
    --reader-border-light: #E5E7EB;
    --reader-border-dark: #374151;
    --reader-orange: #F97316;
}

.reader-page {
    min-height: 100vh;
    background: var(--reader-bg-light);
    display: flex;
    flex-direction: column;
    transition: background 0.3s ease;
}

.reader-page.dark-mode {
    background: var(--reader-bg-dark);
}

/* Header */
.reader-header {
    background: var(--reader-header-light);
    border-bottom: 1px solid var(--reader-border-light);
    position: sticky;
    top: 0;
    z-index: 100;
    transition: background 0.3s ease, border-color 0.3s ease;
}

.reader-page.dark-mode .reader-header {
    background: var(--reader-header-dark);
    border-bottom-color: var(--reader-border-dark);
}

.reader-header-content {
    max-width: 1024px;
    margin: 0 auto;
    padding: 12px 16px;
    display: flex;
    align-items: center;
    gap: 16px;
}

.reader-btn-back {
    display: flex;
    align-items: center;
    gap: 4px;
    padding: 8px 12px;
    background: transparent;
    border: none;
    color: var(--reader-orange);
    cursor: pointer;
    font-size: 14px;
    font-weight: 500;
    transition: opacity 0.2s;
}

.reader-btn-back:hover {
    opacity: 0.8;
}

.reader-title-section {
    flex: 1;
    text-align: center;
}

.reader-book-title {
    font-size: 18px;
    font-weight: 600;
    color: var(--reader-text-light);
    margin: 0 0 4px 0;
    font-family: "PBold", sans-serif;
    transition: color 0.3s ease;
}

.reader-page.dark-mode .reader-book-title {
    color: var(--reader-text-dark);
}

.reader-book-author {
    font-size: 14px;
    color: var(--reader-text-secondary-light);
    margin: 0;
    font-family: "PRegular", sans-serif;
    transition: color 0.3s ease;
}

.reader-page.dark-mode .reader-book-author {
    color: var(--reader-text-secondary-dark);
}

.reader-header-actions {
    display: flex;
    gap: 8px;
}

.reader-icon-btn {
    width: 40px;
    height: 40px;
    display: flex;
    align-items: center;
    justify-content: center;
    background: transparent;
    border: none;
    color: var(--reader-text-light);
    cursor: pointer;
    border-radius: 8px;
    transition: background 0.2s, color 0.3s ease;
}

.reader-icon-btn:hover {
    background: rgba(249, 115, 22, 0.1);
}

.reader-page.dark-mode .reader-icon-btn {
    color: var(--reader-text-dark);
}

.reader-progress-bar {
    width: 100%;
    height: 4px;
    background: var(--reader-border-light);
    position: relative;
}

.reader-page.dark-mode .reader-progress-bar {
    background: var(--reader-border-dark);
}

.reader-progress-fill {
    height: 100%;
    background: var(--reader-orange);
    transition: width 0.3s ease;
}

/* Main Content */
.reader-main {
    flex: 1;
    display: flex;
    position: relative;
    overflow: hidden;
}

.reader-content-wrapper {
    flex: 1;
    display: flex;
    flex-direction: column;
    max-width: 1024px;
    margin: 0 auto;
    width: 100%;
    padding: 22px;
}

.reader-controls {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 8px 0;
    margin-bottom: 16px;
}

.reader-control-btn {
    display: flex;
    align-items: center;
    gap: 6px;
    padding: 8px 12px;
    background: transparent;
    border: none;
    color: var(--reader-orange);
    cursor: pointer;
    font-size: 14px;
    transition: opacity 0.2s;
}

.reader-control-btn:hover:not(:disabled) {
    opacity: 0.8;
}

.reader-control-btn:disabled {
    color: var(--reader-text-secondary-light);
    cursor: not-allowed;
}

.reader-page.dark-mode .reader-control-btn:disabled {
    color: var(--reader-text-secondary-dark);
}

.reader-page-info {
    font-size: 14px;
    color: var(--reader-text-secondary-light);
    font-family: "PRegular", sans-serif;
    transition: color 0.3s ease;
}

.reader-page.dark-mode .reader-page-info {
    color: var(--reader-text-secondary-dark);
}

.reader-pdf-container {
    flex: 1;
    background: var(--reader-bg-light);
    border-radius: 8px;
    overflow: hidden;
    position: relative;
    min-height: 600px;
    transition: background 0.3s ease;
}

.reader-page.dark-mode .reader-pdf-container {
    background: var(--reader-bg-dark);
}

.pdf-viewer-iframe {
    width: 100%;
    height: 100%;
    min-height: 600px;
    border: none;
    display: block;
}

/* Overlay to hide PDF.js toolbar */
.pdf-toolbar-overlay {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    height: 56px; /* Height of PDF.js toolbar */
    background: var(--reader-bg-light);
    z-index: 10;
    pointer-events: none; /* Allow clicks to pass through, but visually hide toolbar */
    transition: background 0.3s ease;
}

.reader-page.dark-mode .pdf-toolbar-overlay {
    background: var(--reader-bg-dark);
}

/* Sidebar overlay to hide sidebar toggle area */
.pdf-sidebar-overlay {
    position: absolute;
    top: 56px;
    left: 0;
    width: 200px;
    bottom: 0;
    background: var(--reader-bg-light);
    z-index: 9;
    pointer-events: none;
    transition: background 0.3s ease;
    display: none; /* Hide by default, show only if sidebar appears */
}

.reader-page.dark-mode .pdf-sidebar-overlay {
    background: var(--reader-bg-dark);
}

.reader-error {
    display: flex;
    align-items: center;
    justify-content: center;
    height: 400px;
    color: var(--reader-text-secondary-light);
}

.reader-warning {
    margin-top: 24px;
    padding: 16px;
    background: #FFF7ED;
    border: 1px solid #FED7AA;
    border-radius: 8px;
    display: flex;
    align-items: center;
    gap: 8px;
}

.reader-warning-icon {
    font-size: 16px;
}

.reader-warning-text {
    flex: 1;
    font-size: 14px;
    color: #9A3412;
    text-align: center;
    margin: 0;
    font-family: "PRegular", sans-serif;
}

/* Panels */
.reader-panel {
    width: 320px;
    background: var(--reader-header-light);
    border-left: 1px solid var(--reader-border-light);
    display: none;
    flex-direction: column;
    position: absolute;
    right: 0;
    top: 0;
    bottom: 0;
    z-index: 50;
    transition: background 0.3s ease, border-color 0.3s ease;
}

.reader-page.dark-mode .reader-panel {
    background: var(--reader-header-dark);
    border-left-color: var(--reader-border-dark);
}

.reader-panel.active {
    display: flex;
}

.reader-panel-header {
    padding: 24px;
    border-bottom: 1px solid var(--reader-border-light);
    display: flex;
    justify-content: space-between;
    align-items: center;
    transition: border-color 0.3s ease;
}

.reader-page.dark-mode .reader-panel-header {
    border-bottom-color: var(--reader-border-dark);
}

.reader-panel-header h3 {
    font-size: 18px;
    font-weight: 600;
    color: var(--reader-text-light);
    margin: 0;
    font-family: "PBold", sans-serif;
    transition: color 0.3s ease;
}

.reader-page.dark-mode .reader-panel-header h3 {
    color: var(--reader-text-dark);
}

.reader-panel-close {
    width: 32px;
    height: 32px;
    display: flex;
    align-items: center;
    justify-content: center;
    background: transparent;
    border: none;
    color: var(--reader-text-light);
    cursor: pointer;
    border-radius: 8px;
    transition: background 0.2s, color 0.3s ease;
}

.reader-panel-close:hover {
    background: rgba(0, 0, 0, 0.1);
}

.reader-page.dark-mode .reader-panel-close {
    color: var(--reader-text-dark);
}

.reader-page.dark-mode .reader-panel-close:hover {
    background: rgba(255, 255, 255, 0.1);
}

.reader-panel-content {
    flex: 1;
    overflow-y: auto;
    padding: 24px;
}

.reader-setting-section {
    margin-bottom: 24px;
}

.reader-setting-label {
    display: block;
    font-size: 16px;
    font-weight: 500;
    color: var(--reader-text-light);
    margin-bottom: 12px;
    font-family: "PBold", sans-serif;
    transition: color 0.3s ease;
}

.reader-page.dark-mode .reader-setting-label {
    color: var(--reader-text-dark);
}

.reader-theme-buttons {
    display: flex;
    gap: 12px;
}

.reader-theme-btn {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 6px;
    padding: 10px;
    background: #F3F4F6;
    border: none;
    border-radius: 8px;
    color: #374151;
    cursor: pointer;
    font-size: 14px;
    font-weight: 500;
    transition: all 0.2s;
}

.reader-theme-btn.active {
    background: var(--reader-orange);
    color: white;
}

.reader-page.dark-mode .reader-theme-btn {
    background: #374151;
    color: #9CA3AF;
}

.reader-page.dark-mode .reader-theme-btn.active {
    background: var(--reader-orange);
    color: white;
}

.reader-font-size-control {
    display: flex;
    align-items: center;
    gap: 12px;
}

.reader-font-size-control svg {
    color: var(--reader-text-light);
    transition: color 0.3s ease;
}

.reader-page.dark-mode .reader-font-size-control svg {
    color: var(--reader-text-dark);
}

.reader-font-size-control input[type="range"] {
    flex: 1;
    height: 4px;
    background: #E5E7EB;
    border-radius: 2px;
    outline: none;
    -webkit-appearance: none;
}

.reader-page.dark-mode .reader-font-size-control input[type="range"] {
    background: #374151;
}

.reader-font-size-control input[type="range"]::-webkit-slider-thumb {
    -webkit-appearance: none;
    width: 16px;
    height: 16px;
    background: var(--reader-orange);
    border-radius: 50%;
    cursor: pointer;
}

.reader-font-size-control input[type="range"]::-moz-range-thumb {
    width: 16px;
    height: 16px;
    background: var(--reader-orange);
    border-radius: 50%;
    cursor: pointer;
    border: none;
}

.reader-font-size-value {
    width: 40px;
    text-align: right;
    font-size: 14px;
    color: var(--reader-text-light);
    font-family: "PRegular", sans-serif;
    transition: color 0.3s ease;
}

.reader-page.dark-mode .reader-font-size-value {
    color: var(--reader-text-dark);
}

.reader-progress-info {
    display: flex;
    justify-content: space-between;
    margin-bottom: 8px;
    font-size: 14px;
    color: var(--reader-text-secondary-light);
    font-family: "PRegular", sans-serif;
    transition: color 0.3s ease;
}

.reader-page.dark-mode .reader-progress-info {
    color: var(--reader-text-secondary-dark);
}

.reader-progress-track {
    width: 100%;
    height: 8px;
    background: #E5E7EB;
    border-radius: 4px;
    overflow: hidden;
}

.reader-page.dark-mode .reader-progress-track {
    background: #374151;
}

.reader-progress-fill-small {
    height: 100%;
    background: var(--reader-orange);
    transition: width 0.3s ease;
}

/* Notes Sections */
.reader-notes-section {
    margin-bottom: 24px;
}

.reader-notes-section-header {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-bottom: 12px;
}

.reader-notes-section-header svg {
    color: var(--reader-text-light);
    transition: color 0.3s ease;
}

.reader-page.dark-mode .reader-notes-section-header svg {
    color: var(--reader-text-dark);
}

.reader-notes-section-header h4 {
    font-size: 16px;
    font-weight: 500;
    color: var(--reader-text-light);
    margin: 0;
    font-family: "PBold", sans-serif;
    transition: color 0.3s ease;
}

.reader-page.dark-mode .reader-notes-section-header h4 {
    color: var(--reader-text-dark);
}

.reader-notes-list {
    display: flex;
    flex-direction: column;
    gap: 8px;
}

.reader-note-item {
    padding: 12px;
    background: #DBEAFE;
    border-radius: 8px;
    border: 1px solid #BFDBFE;
    transition: background 0.3s ease, border-color 0.3s ease;
}

.reader-page.dark-mode .reader-note-item {
    background: #374151;
    border-color: #4B5563;
}

.reader-note-item-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 8px;
}

.reader-note-item-page {
    font-size: 14px;
    font-weight: 500;
    color: var(--reader-text-light);
    font-family: "PBold", sans-serif;
    transition: color 0.3s ease;
}

.reader-page.dark-mode .reader-note-item-page {
    color: var(--reader-text-dark);
}

.reader-note-item-actions {
    display: flex;
    gap: 4px;
}

.reader-note-item-btn {
    width: 28px;
    height: 28px;
    display: flex;
    align-items: center;
    justify-content: center;
    background: transparent;
    border: none;
    color: var(--reader-text-light);
    cursor: pointer;
    border-radius: 4px;
    transition: background 0.2s, color 0.3s ease;
}

.reader-note-item-btn:hover {
    background: rgba(0, 0, 0, 0.1);
}

.reader-page.dark-mode .reader-note-item-btn {
    color: var(--reader-text-dark);
}

.reader-page.dark-mode .reader-note-item-btn:hover {
    background: rgba(255, 255, 255, 0.1);
}

.reader-note-item-text {
    font-size: 12px;
    color: var(--reader-text-secondary-light);
    margin-bottom: 8px;
    font-family: "PRegular", sans-serif;
    transition: color 0.3s ease;
}

.reader-page.dark-mode .reader-note-item-text {
    color: var(--reader-text-secondary-dark);
}

.reader-note-item-content {
    font-size: 14px;
    color: var(--reader-text-light);
    font-family: "PRegular", sans-serif;
    transition: color 0.3s ease;
}

.reader-page.dark-mode .reader-note-item-content {
    color: var(--reader-text-dark);
}

.reader-empty-notes {
    font-size: 14px;
    color: var(--reader-text-secondary-light);
    font-family: "PRegular", sans-serif;
    transition: color 0.3s ease;
}

.reader-page.dark-mode .reader-empty-notes {
    color: var(--reader-text-secondary-dark);
}

.reader-quick-action-btn {
    width: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    padding: 10px;
    background: var(--reader-orange);
    color: white;
    border: none;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 500;
    font-family: "PBold", sans-serif;
    cursor: pointer;
    transition: background 0.2s;
}

.reader-quick-action-btn:hover {
    background: #EA580C;
}

/* Toast Animation */
@keyframes slideIn {
    from {
        transform: translateX(100%);
        opacity: 0;
    }
    to {
        transform: translateX(0);
        opacity: 1;
    }
}

/* Mobile Responsive */
@media (max-width: 700px) {
    .reader-header-content {
        padding: 8px;
    }
    
    .reader-book-title {
        font-size: 15px;
    }
    
    .reader-book-author {
        font-size: 12px;
    }
    
    .reader-content-wrapper {
        padding: 10px;
    }
    
    .reader-control-btn span {
        display: none;
    }
    
    .reader-page-info {
        font-size: 12px;
    }
    
    .reader-pdf-container {
        min-height: 400px;
    }
    
    .pdf-viewer-iframe {
        min-height: 400px;
    }
    
    .reader-panel {
        width: 100%;
        position: fixed;
        left: 0;
        right: 0;
        top: 0;
        bottom: 0;
        z-index: 200;
    }
    
    .reader-panel-header {
        padding: 16px;
    }
    
    .reader-panel-header h3 {
        font-size: 15px;
    }
    
    .reader-panel-content {
        padding: 16px;
    }
    
    .reader-setting-section {
        margin-bottom: 16px;
    }
    
    .reader-setting-label {
        font-size: 13px;
    }
    
    .reader-warning {
        padding: 10px;
    }
    
    .reader-warning-text {
        font-size: 12px;
    }
}
</style>
@endpush

@push('scripts')
<script>
// Configuration
const bookData = {
    id: '{{ $slug }}',
    title: '{{ addslashes($bookTitle ?? '') }}',
    author: '{{ addslashes($bookAuthor ?? '') }}',
    totalPages: {{ $totalPages }},
    pdfUrl: '{{ $pdfUrl }}'
};

// State
let currentPage = 1;
let isDarkMode = false;
let fontSize = 16;
let bookmarks = [];
let highlights = [];
let notes = [];
let previousUrl = null; // Store the URL to go back to
let pageChangeTracking = true; // Flag to prevent recursive updates

// Initialize
document.addEventListener('DOMContentLoaded', function() {
    // Store the previous URL before loading reader
    const referrer = document.referrer;
    if (referrer && !referrer.includes('/reader/')) {
        previousUrl = referrer;
    } else {
        // If no referrer, try to get from sessionStorage
        previousUrl = sessionStorage.getItem('readerPreviousUrl') || '/explore';
    }
    sessionStorage.setItem('readerPreviousUrl', previousUrl);
    
    restoreReadingState();
    updateUI();
    setupPDFViewer();
});

let pdfViewerReady = false;
let pdfViewerWindow = null;

function setupPDFViewer() {
    const iframe = document.getElementById('pdfViewer');
    
    iframe.onload = function() {
        try {
            pdfViewerWindow = iframe.contentWindow;
            
            // Wait a bit for PDF.js to fully load
            setTimeout(() => {
                hidePDFToolbarElements();
                pdfViewerReady = true;
                
                // Setup page change detection on scroll
                setupPageChangeDetection();
            }, 1500);
        } catch (e) {
            console.log('Cannot access iframe content (CORS) - using alternative method');
            // Still try to setup page detection via URL hash changes
            setupPageChangeDetectionViaHash();
        }
    };
}

function setupPageChangeDetection() {
    // Try to listen for page changes in PDF.js viewer
    try {
        if (pdfViewerWindow) {
            const viewerApp = pdfViewerWindow.PDFViewerApplication;
            if (viewerApp) {
                // Listen for page changes
                pdfViewerWindow.addEventListener('pagesinit', function() {
                    if (viewerApp.eventBus) {
                        viewerApp.eventBus.on('pagechanging', function(evt) {
                            if (pageChangeTracking && evt.pageNumber) {
                                const newPage = evt.pageNumber;
                                if (newPage !== currentPage) {
                                    pageChangeTracking = false;
                                    currentPage = newPage;
                                    updateUI();
                                    saveReadingProgress();
                                    setTimeout(() => {
                                        pageChangeTracking = true;
                                    }, 100);
                                }
                            }
                        });
                    }
                });
                
                // Also listen for scroll events to detect page changes
                const viewerDoc = pdfViewerWindow.document;
                if (viewerDoc) {
                    const viewerContainer = viewerDoc.querySelector('#viewerContainer') || viewerDoc.body;
                    if (viewerContainer) {
                        viewerContainer.addEventListener('scroll', debounce(function() {
                            if (pageChangeTracking && viewerApp.page !== currentPage) {
                                pageChangeTracking = false;
                                currentPage = viewerApp.page;
                                updateUI();
                                saveReadingProgress();
                                setTimeout(() => {
                                    pageChangeTracking = true;
                                }, 100);
                            }
                        }, 300));
                    }
                }
            }
        }
    } catch (e) {
        console.log('Cannot setup page detection via PDF.js API - using hash method');
        setupPageChangeDetectionViaHash();
    }
}

function setupPageChangeDetectionViaHash() {
    // Fallback: detect page changes via URL hash in iframe
    const iframe = document.getElementById('pdfViewer');
    let lastHash = '';
    
    setInterval(function() {
        try {
            if (iframe.contentWindow && iframe.contentWindow.location.hash) {
                const hash = iframe.contentWindow.location.hash;
                const pageMatch = hash.match(/page=(\d+)/);
                if (pageMatch && hash !== lastHash) {
                    const newPage = parseInt(pageMatch[1]);
                    if (newPage !== currentPage && pageChangeTracking) {
                        pageChangeTracking = false;
                        currentPage = newPage;
                        updateUI();
                        saveReadingProgress();
                        lastHash = hash;
                        setTimeout(() => {
                            pageChangeTracking = true;
                        }, 100);
                    }
                }
            }
        } catch (e) {
            // CORS - can't access iframe location
        }
    }, 500);
}

function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

function hidePDFToolbarElements() {
    try {
        if (!pdfViewerWindow) return;
        
        const viewerDoc = pdfViewerWindow.document;
        
        // Hide print button
        const printBtn = viewerDoc.getElementById('print');
        if (printBtn) printBtn.style.display = 'none';
        
        // Hide download button
        const downloadBtn = viewerDoc.getElementById('download');
        if (downloadBtn) downloadBtn.style.display = 'none';
        
        // Hide sidebar toggle
        const sidebarToggle = viewerDoc.getElementById('sidebarToggle');
        if (sidebarToggle) sidebarToggle.style.display = 'none';
        
        // Hide entire toolbar if possible
        const toolbar = viewerDoc.querySelector('.toolbar');
        if (toolbar) {
            // Hide specific buttons only
            const buttonsToHide = ['print', 'download', 'sidebarToggle', 'secondaryToolbarToggle'];
            buttonsToHide.forEach(btnId => {
                const btn = viewerDoc.getElementById(btnId);
                if (btn) btn.style.display = 'none';
            });
        }
    } catch (e) {
        // CORS restriction - can't access iframe content
        console.log('Cannot modify PDF viewer toolbar (CORS restriction)');
    }
}

function restoreReadingState() {
    // Restore from localStorage
    const stored = localStorage.getItem('currentlyReading');
    if (stored) {
        try {
            const readingList = JSON.parse(stored);
            const bookState = readingList.find(b => b.id === bookData.id || b.title === bookData.title);
            if (bookState && bookState.page) {
                currentPage = parseInt(bookState.page) || 1;
                // Update PDF viewer to the saved page
                if (bookData.pdfUrl) {
                    const iframe = document.getElementById('pdfViewer');
                    if (iframe) {
                        const encodedUrl = encodeURIComponent(bookData.pdfUrl);
                        iframe.src = 'https://mozilla.github.io/pdf.js/web/viewer.html?file=' + encodedUrl + '#page=' + currentPage;
                        setTimeout(() => {
                            hidePDFToolbarElements();
                        }, 1500);
                    }
                }
            }
        } catch (e) {
            console.error('Error restoring reading state:', e);
        }
    }
    
    // Restore theme
    const savedTheme = localStorage.getItem('readerTheme');
    if (savedTheme) {
        isDarkMode = savedTheme === 'dark';
    }
    
    // Restore font size
    const savedFontSize = localStorage.getItem('readerFontSize');
    if (savedFontSize) {
        fontSize = parseInt(savedFontSize) || 16;
        document.getElementById('fontSizeSlider').value = fontSize;
        document.getElementById('fontSizeValue').textContent = fontSize + 'px';
    }
    
    // Restore bookmarks, highlights, notes
    const savedBookmarks = localStorage.getItem('readerBookmarks_' + bookData.id);
    if (savedBookmarks) {
        try {
            bookmarks = JSON.parse(savedBookmarks);
        } catch (e) {
            bookmarks = [];
        }
    }
    
    const savedHighlights = localStorage.getItem('readerHighlights_' + bookData.id);
    if (savedHighlights) {
        try {
            highlights = JSON.parse(savedHighlights);
        } catch (e) {
            highlights = [];
        }
    }
    
    const savedNotes = localStorage.getItem('readerNotes_' + bookData.id);
    if (savedNotes) {
        try {
            notes = JSON.parse(savedNotes);
        } catch (e) {
            notes = [];
        }
    }
}

function saveReadingProgress() {
    const progress = Math.round((currentPage / bookData.totalPages) * 100);
    const bookState = {
        id: bookData.id,
        title: bookData.title,
        author: bookData.author,
        progress: progress,
        lastRead: new Date().toISOString(),
        page: currentPage
    };
    
    let readingList = [];
    const stored = localStorage.getItem('currentlyReading');
    if (stored) {
        try {
            readingList = JSON.parse(stored);
            // Remove existing entry for this book
            readingList = readingList.filter(b => (b.id !== bookData.id && b.title !== bookData.title));
        } catch (e) {
            readingList = [];
        }
    }
    
    readingList.push(bookState);
    localStorage.setItem('currentlyReading', JSON.stringify(readingList));
}

function goBack() {
    saveReadingProgress();
    
    // Use replaceState to avoid adding history entries, then navigate
    if (previousUrl) {
        window.location.href = previousUrl;
    } else {
        // Fallback: try to go back but skip reader pages
        const currentHistory = window.history.length;
        window.location.href = '/explore';
    }
}

function previousPage() {
    if (currentPage > 1) {
        currentPage--;
        updatePDFPage();
        updateUI();
        saveReadingProgress();
    }
}

function nextPage() {
    if (currentPage < bookData.totalPages) {
        currentPage++;
        updatePDFPage();
        updateUI();
        saveReadingProgress();
    }
}

function updatePDFPage() {
    pageChangeTracking = false; // Prevent recursive updates
    
    const iframe = document.getElementById('pdfViewer');
    if (iframe && bookData.pdfUrl) {
        // Try to use PDF.js API first (more reliable and doesn't reload)
        try {
            if (pdfViewerWindow) {
                const viewerApp = pdfViewerWindow.PDFViewerApplication;
                if (viewerApp && viewerApp.page !== currentPage) {
                    viewerApp.page = currentPage;
                    setTimeout(() => {
                        pageChangeTracking = true;
                    }, 300);
                    return;
                }
            }
        } catch (e) {
            // CORS restriction - fallback to URL method
        }
        
        // Fallback: Update iframe URL with new page number
        const encodedUrl = encodeURIComponent(bookData.pdfUrl);
        const currentSrc = iframe.src;
        
        // Extract base URL without page fragment
        let baseUrl = currentSrc;
        if (currentSrc.includes('#')) {
            baseUrl = currentSrc.split('#')[0];
        }
        
        // Set new URL with page number (use replaceState to avoid history)
        iframe.src = baseUrl + '#page=' + currentPage;
        
        // Use replaceState to avoid adding to browser history
        if (window.history.replaceState) {
            const currentUrl = window.location.href.split('#')[0];
            window.history.replaceState(null, '', currentUrl);
        }
        
        setTimeout(() => {
            hidePDFToolbarElements();
            pageChangeTracking = true;
        }, 500);
    } else {
        pageChangeTracking = true;
    }
}

function updateUI() {
    // Update page info
    document.getElementById('pageInfo').textContent = `Page ${currentPage} sur ${bookData.totalPages}`;
    document.getElementById('progressPageInfo').textContent = `Page ${currentPage} / ${bookData.totalPages}`;
    
    // Update progress
    const progress = Math.round((currentPage / bookData.totalPages) * 100);
    document.getElementById('progressFill').style.width = progress + '%';
    document.getElementById('progressFillSmall').style.width = progress + '%';
    document.getElementById('progressPercent').textContent = progress + '%';
    
    // Update navigation buttons
    document.getElementById('prevPageBtn').disabled = currentPage <= 1;
    document.getElementById('nextPageBtn').disabled = currentPage >= bookData.totalPages;
    
    // Update theme buttons
    document.getElementById('lightThemeBtn').classList.toggle('active', !isDarkMode);
    document.getElementById('darkThemeBtn').classList.toggle('active', isDarkMode);
    
    // Update notes counts
    document.getElementById('bookmarksCount').textContent = bookmarks.length;
    document.getElementById('highlightsCount').textContent = highlights.length;
    document.getElementById('notesCount').textContent = notes.length;
    
    // Render notes
    renderBookmarks();
    renderHighlights();
    renderNotes();
}

function setTheme(theme) {
    isDarkMode = theme === 'dark';
    document.getElementById('readerPage').classList.toggle('dark-mode', isDarkMode);
    localStorage.setItem('readerTheme', theme);
    updateUI();
}

function updateFontSize(value) {
    fontSize = parseInt(value);
    document.getElementById('fontSizeValue').textContent = fontSize + 'px';
    localStorage.setItem('readerFontSize', fontSize);
    // Note: PDF zoom is handled by the PDF viewer itself
    // We can update the iframe zoom if needed
}

function toggleSettings() {
    const panel = document.getElementById('settingsPanel');
    const notesPanel = document.getElementById('notesPanel');
    
    panel.classList.toggle('active');
    if (panel.classList.contains('active')) {
        notesPanel.classList.remove('active');
    }
}

function toggleNotes() {
    const panel = document.getElementById('notesPanel');
    const settingsPanel = document.getElementById('settingsPanel');
    
    panel.classList.toggle('active');
    if (panel.classList.contains('active')) {
        settingsPanel.classList.remove('active');
    }
}

function addBookmark() {
    if (!bookmarks.includes(currentPage)) {
        bookmarks.push(currentPage);
        bookmarks.sort((a, b) => a - b);
        saveBookmarks();
        updateUI();
        showNotification('Signet ajouté à la page ' + currentPage, 'success');
    } else {
        showNotification('Cette page a déjà un signet', 'error');
    }
}

function removeBookmark(page) {
    bookmarks = bookmarks.filter(p => p !== page);
    saveBookmarks();
    updateUI();
}

function jumpToPage(page) {
    currentPage = page;
    updatePDFPage();
    updateUI();
    saveReadingProgress();
}

function renderBookmarks() {
    const container = document.getElementById('bookmarksList');
    if (bookmarks.length === 0) {
        container.innerHTML = '<p class="reader-empty-notes">Aucun élément</p>';
        return;
    }
    
    container.innerHTML = bookmarks.map(page => `
        <div class="reader-note-item">
            <div class="reader-note-item-header">
                <span class="reader-note-item-page">Page ${page}</span>
                <div class="reader-note-item-actions">
                    <button class="reader-note-item-btn" onclick="jumpToPage(${page})" title="Aller à la page">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"/>
                            <polyline points="15 3 21 3 21 9"/>
                            <line x1="10" y1="14" x2="21" y2="3"/>
                        </svg>
                    </button>
                    <button class="reader-note-item-btn" onclick="removeBookmark(${page})" title="Supprimer">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <polyline points="3 6 5 6 21 6"/>
                            <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/>
                        </svg>
                    </button>
                </div>
            </div>
        </div>
    `).join('');
}

function renderHighlights() {
    const container = document.getElementById('highlightsList');
    if (highlights.length === 0) {
        container.innerHTML = '<p class="reader-empty-notes">Aucun élément</p>';
        return;
    }
    
    container.innerHTML = highlights.map((highlight, index) => `
        <div class="reader-note-item" style="background: #FEF3C7; border-color: #FDE68A;">
            <p class="reader-note-item-content">"${highlight.length > 100 ? highlight.substring(0, 100) + '...' : highlight}"</p>
        </div>
    `).join('');
}

function renderNotes() {
    const container = document.getElementById('notesList');
    if (notes.length === 0) {
        container.innerHTML = '<p class="reader-empty-notes">Aucun élément</p>';
        return;
    }
    
    container.innerHTML = notes.map((note, index) => `
        <div class="reader-note-item">
            <div class="reader-note-item-header">
                <span class="reader-note-item-page">Page ${note.page}</span>
                <div class="reader-note-item-actions">
                    <button class="reader-note-item-btn" onclick="jumpToPage(${note.page})" title="Aller à la page">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"/>
                            <polyline points="15 3 21 3 21 9"/>
                            <line x1="10" y1="14" x2="21" y2="3"/>
                        </svg>
                    </button>
                    <button class="reader-note-item-btn" onclick="removeNote(${index})" title="Supprimer">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <polyline points="3 6 5 6 21 6"/>
                            <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/>
                        </svg>
                    </button>
                </div>
            </div>
            ${note.text ? `<p class="reader-note-item-text">"${note.text.length > 50 ? note.text.substring(0, 50) + '...' : note.text}"</p>` : ''}
            <p class="reader-note-item-content">${note.note}</p>
        </div>
    `).join('');
}

function saveBookmarks() {
    localStorage.setItem('readerBookmarks_' + bookData.id, JSON.stringify(bookmarks));
}

function saveHighlights() {
    localStorage.setItem('readerHighlights_' + bookData.id, JSON.stringify(highlights));
}

function saveNotes() {
    localStorage.setItem('readerNotes_' + bookData.id, JSON.stringify(notes));
}

function removeNote(index) {
    notes.splice(index, 1);
    saveNotes();
    updateUI();
}

function showNotification(message, type = 'info') {
    // Create a toast notification
    const notification = document.createElement('div');
    notification.className = 'reader-toast';
    notification.style.cssText = `
        position: fixed;
        bottom: 24px;
        right: 24px;
        background: ${type === 'error' ? '#EF4444' : type === 'success' ? '#10B981' : '#F97316'};
        color: white;
        padding: 12px 20px;
        border-radius: 8px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        z-index: 10000;
        font-size: 14px;
        font-family: "PRegular", sans-serif;
        max-width: 300px;
        animation: slideIn 0.3s ease;
    `;
    notification.textContent = message;
    document.body.appendChild(notification);
    
    setTimeout(() => {
        notification.style.opacity = '0';
        notification.style.transition = 'opacity 0.3s';
        setTimeout(() => notification.remove(), 300);
    }, 3000);
}

// Keyboard shortcuts
document.addEventListener('keydown', function(e) {
    if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA') {
        return;
    }
    
    if (e.key === 'ArrowLeft' || e.key === 'ArrowUp') {
        e.preventDefault();
        previousPage();
    } else if (e.key === 'ArrowRight' || e.key === 'ArrowDown') {
        e.preventDefault();
        nextPage();
    }
});

// Initialize theme on load
if (localStorage.getItem('readerTheme') === 'dark') {
    document.getElementById('readerPage').classList.add('dark-mode');
    isDarkMode = true;
}
</script>
@endpush
@endsection
