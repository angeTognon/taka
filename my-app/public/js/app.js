// TAKA App JavaScript
// Global JavaScript functions

// Password toggle
function togglePassword(inputId) {
    const input = document.getElementById(inputId);
    if (input) {
        input.type = input.type === 'password' ? 'text' : 'password';
    }
}

// Mobile menu toggle
function toggleMobileMenu() {
    const menu = document.getElementById('mobileMenu');
    const icon = document.getElementById('menuIcon');
    if (menu) {
        menu.classList.toggle('show');
    }
    if (icon) {
        icon.classList.toggle('icon-close');
    }
}

// User menu toggle
function toggleUserMenu() {
    const menu = document.getElementById('userMenu');
    if (menu) {
        menu.classList.toggle('show');
    }
}

// Tab switching
function showTab(tabName) {
    // Hide all tabs
    document.querySelectorAll('.tab-panel').forEach(panel => {
        panel.classList.remove('active');
    });
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    
    // Show selected tab
    const tabPanel = document.getElementById(tabName + 'Tab');
    if (tabPanel) {
        tabPanel.classList.add('active');
    }
    if (event && event.target) {
        event.target.classList.add('active');
    }
}

// Close mobile menu when clicking outside
document.addEventListener('click', function(event) {
    const mobileMenu = document.getElementById('mobileMenu');
    const menuBtn = document.querySelector('.mobile-menu-btn');
    
    if (mobileMenu && menuBtn && !mobileMenu.contains(event.target) && !menuBtn.contains(event.target)) {
        mobileMenu.classList.remove('show');
    }
});

// Country/Currency selector
document.addEventListener('DOMContentLoaded', function() {
    const countrySelect = document.getElementById('countryCurrency');
    if (countrySelect) {
        // Load saved country/currency
        const savedCountry = localStorage.getItem('country');
        const savedCurrency = localStorage.getItem('currency');
        if (savedCountry && savedCurrency) {
            const value = `${savedCountry}|${savedCurrency}`;
            countrySelect.value = value;
        }
        
        // Save on change
        countrySelect.addEventListener('change', function(e) {
            const [country, currency] = e.target.value.split('|');
            localStorage.setItem('country', country);
            localStorage.setItem('currency', currency);
        });
    }
});

