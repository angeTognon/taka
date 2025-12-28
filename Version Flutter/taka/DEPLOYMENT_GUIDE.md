# Guide de déploiement - Correction des zones géographiques Moneroo

## 🚨 Problème identifié

L'interface de paiement Moneroo n'affichait que le Bénin comme option de pays car :
1. Les fichiers PHP ne géraient que la devise XOF (Bénin)
2. Les autres devises étaient commentées ou manquantes
3. Le système revenait automatiquement à XOF par défaut

## ✅ Solution

### Fichiers à remplacer sur le serveur

1. **Remplacer `moneroo_init.php`** par `moneroo_init_fixed.php`
2. **Remplacer `moneroo_publish_init.php`** par `moneroo_publish_init_fixed.php`
3. **Remplacer `moneroo_init_book.php`** par `moneroo_init_book_fixed.php` ⚠️ **IMPORTANT**

### Changements apportés

#### 1. Liste complète des méthodes de paiement par devise

```php
$methods_by_currency = [
    // Zone UEMOA (XOF) - 8 pays
    "XOF" => [
        "moov_bj", "mtn_bj",           // Bénin
        "moov_bf", "mtn_bf",           // Burkina Faso
        "moov_ci", "mtn_ci",           // Côte d'Ivoire
        "moov_ml", "mtn_ml",           // Mali
        "moov_ne", "mtn_ne",           // Niger
        "moov_sn", "mtn_sn",           // Sénégal
        "moov_tg", "mtn_tg",           // Togo
        "moov_gw", "mtn_gw"            // Guinée-Bissau
    ],
    
    // Zone CEMAC (XAF) - 6 pays
    "XAF" => [
        "mtn_cm", "orange_cm",         // Cameroun
        "mtn_cf", "orange_cf",         // Centrafrique
        "mtn_cg", "orange_cg",         // Congo
        "mtn_gq", "orange_gq",         // Guinée équatoriale
        "mtn_ga", "orange_ga",         // Gabon
        "mtn_td", "orange_td"          // Tchad
    ],
    
    // Autres pays africains
    "NGN" => ["airtel_ng", "mtn_ng"],  // Nigeria
    "GHS" => ["mtn_gh", "tigo_gh", "vodafone_gh"], // Ghana
    "KES" => ["mpesa_ke"],             // Kenya
    "TZS" => ["airtel_tz", "halopesa_tz", "mpesa_tz", "tigo_tz"], // Tanzanie
    "UGX" => ["airtel_ug", "mtn_ug"],  // Ouganda
    "RWF" => ["airtel_rw", "mtn_rw"],  // Rwanda
    "ZMW" => ["airtel_zm", "mtn_zm", "zamtel_zm"], // Zambie
    "MWK" => ["airtel_mw", "tnm_mw"],  // Malawi
    "CDF" => ["airtel_cd", "orange_cd", "vodacom_cd"], // RDC
    "ETB" => ["telebirr_et"],          // Éthiopie
    "ZAR" => ["mtn_za", "vodacom_za"], // Afrique du Sud
    
    // Pays occidentaux
    "EUR" => ["card"],                 // Europe
    "USD" => ["card"],                 // États-Unis
    "GBP" => ["card"],                 // Royaume-Uni
    "CAD" => ["card"],                 // Canada
    "CHF" => ["card"],                 // Suisse
    
    // Autres devises
    "BRL" => ["card"],                 // Brésil
    "CNY" => ["card"],                 // Chine
    "JPY" => ["card"],                 // Japon
    "INR" => ["card"],                 // Inde
    "AUD" => ["card"],                 // Australie
    "NZD" => ["card"],                 // Nouvelle-Zélande
];
```

#### 2. Gestion du paramètre pays

```php
// Récupération de la devise et du pays
$currency = isset($input['currency']) && !empty($input['currency']) ? $input['currency'] : "XOF";
$country = isset($input['country']) ? $input['country'] : "Bénin";

// Log pour debug
error_log("Moneroo Init - Devise: $currency, Pays: $country");
```

#### 3. Métadonnées enrichies

```php
$metadata = [
    "user_id" => $user_id,
    "currency" => $currency,
    "country" => $country
];
```

#### 4. Logs de debug améliorés

```php
// Log des données envoyées pour debug
error_log("Moneroo Init - Données envoyées: " . json_encode($data));
```

## 📋 Instructions de déploiement

### Étape 1 : Sauvegarde
```bash
# Sauvegarder les fichiers existants
cp moneroo_init.php moneroo_init.php.backup
cp moneroo_publish_init.php moneroo_publish_init.php.backup
cp moneroo_init_book.php moneroo_init_book.php.backup
```

### Étape 2 : Remplacement
```bash
# Remplacer par les versions corrigées
cp moneroo_init_fixed.php moneroo_init.php
cp moneroo_publish_init_fixed.php moneroo_publish_init.php
cp moneroo_init_book_fixed.php moneroo_init_book.php
```

### Étape 3 : Permissions
```bash
# S'assurer que les fichiers ont les bonnes permissions
chmod 644 moneroo_init.php
chmod 644 moneroo_publish_init.php
chmod 644 moneroo_init_book.php
```

### Étape 4 : Test
1. Tester avec différents pays dans l'application Flutter
2. Vérifier les logs du serveur pour s'assurer que les bonnes devises sont utilisées
3. Tester un paiement complet avec un pays non-Bénin

## 🧪 Tests à effectuer

### Test 1 : Sénégal (XOF)
- Sélectionner Sénégal dans l'app
- Vérifier que la devise XOF est envoyée
- Vérifier que les méthodes moov_sn et mtn_sn sont disponibles

### Test 2 : Cameroun (XAF)
- Sélectionner Cameroun dans l'app
- Vérifier que la devise XAF est envoyée
- Vérifier que les méthodes mtn_cm et orange_cm sont disponibles

### Test 3 : France (EUR)
- Sélectionner France dans l'app
- Vérifier que la devise EUR est envoyée
- Vérifier que la méthode card est disponible

### Test 4 : Nigeria (NGN)
- Sélectionner Nigeria dans l'app
- Vérifier que la devise NGN est envoyée
- Vérifier que les méthodes airtel_ng et mtn_ng sont disponibles

## 🔍 Vérification des logs

Après déploiement, vérifier les logs du serveur pour s'assurer que :
1. Les bonnes devises sont reçues
2. Les bonnes méthodes de paiement sont sélectionnées
3. Aucune erreur n'est générée

## ⚠️ Notes importantes

1. **Méthodes de paiement** : Certaines méthodes peuvent ne pas être disponibles selon la configuration Moneroo
2. **Devises** : Toutes les devises listées doivent être supportées par Moneroo
3. **Fallback** : En cas de devise non supportée, le système revient à XOF
4. **Logs** : Les logs de debug peuvent être désactivés en production

## 🎯 Résultat attendu

Après déploiement, l'interface de paiement Moneroo devrait :
1. Afficher le bon pays selon la sélection de l'utilisateur
2. Proposer les bonnes méthodes de paiement pour chaque pays
3. Permettre les paiements depuis tous les pays configurés
4. Ne plus être limité au seul Bénin
