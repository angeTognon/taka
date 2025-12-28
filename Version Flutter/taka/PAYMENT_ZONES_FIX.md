# Correction du problème des zones géographiques dans les API de paiements

## Problème identifié

Les API de paiements (`moneroo_init.php` et `moneroo_publish_init.php`) n'affichaient que le Bénin comme zone géographique disponible, ce qui limitait les utilisateurs à une seule zone géographique.

## Cause du problème

1. **Devise codée en dur** : La devise était codée en dur sur 'XOF' (Franc CFA) dans les appels API
2. **Absence du paramètre pays** : Les appels API ne transmettaient pas le pays sélectionné par l'utilisateur
3. **Configuration côté serveur** : Les API côté serveur n'étaient pas configurées pour gérer plusieurs zones géographiques

## Solutions apportées

### 1. Modification de `subscription_screen.dart`

- ✅ Ajout de la récupération de la devise et du pays sélectionnés par l'utilisateur
- ✅ Remplacement de la devise codée en dur 'XOF' par la devise sélectionnée
- ✅ Ajout du paramètre 'country' dans l'appel API
- ✅ Ajout de l'import SharedPreferences

### 2. Modification de `publish_screen.dart`

- ✅ Ajout de la récupération de la devise et du pays sélectionnés par l'utilisateur
- ✅ Remplacement de la devise codée en dur 'XOF' par la devise sélectionnée
- ✅ Ajout du paramètre 'country' dans l'appel API
- ✅ Ajout de l'import SharedPreferences
- ✅ Suppression des imports inutilisés (kkiapay_flutter_sdk)

## Code modifié

### Avant (subscription_screen.dart)
```dart
body: jsonEncode({
  'amount': amount,
  'currency': 'XOF', // ← Codé en dur
  'description': 'Abonnement ${selectedPlanData['name'] ?? ''}',
  // ... autres paramètres
}),
```

### Après (subscription_screen.dart)
```dart
// Récupérer la devise sélectionnée par l'utilisateur
final prefs = await SharedPreferences.getInstance();
final selectedCurrency = prefs.getString('currency') ?? 'XOF';
final selectedCountry = prefs.getString('country') ?? 'Bénin';

body: jsonEncode({
  'amount': amount,
  'currency': selectedCurrency, // ← Dynamique
  'country': selectedCountry,   // ← Nouveau paramètre
  'description': 'Abonnement ${selectedPlanData['name'] ?? ''}',
  // ... autres paramètres
}),
```

## Configuration côté serveur requise

Pour que cette correction fonctionne complètement, les fichiers PHP côté serveur doivent être mis à jour :

### `moneroo_init.php`
- Accepter le paramètre `country`
- Utiliser la devise dynamique au lieu de 'XOF' codé en dur
- Configurer Moneroo pour accepter les paiements depuis différentes zones géographiques

### `moneroo_publish_init.php`
- Accepter le paramètre `country`
- Utiliser la devise dynamique au lieu de 'XOF' codé en dur
- Configurer Moneroo pour accepter les paiements depuis différentes zones géographiques

## Test de la solution

1. **Sélectionner un pays différent** dans le sélecteur de pays (header)
2. **Vérifier que la devise change** automatiquement
3. **Tester un paiement d'abonnement** avec le nouveau pays/devise
4. **Tester un paiement de publication** avec le nouveau pays/devise
5. **Vérifier que l'API reçoit** les bons paramètres (currency et country)

## Pays et devises supportés

La liste complète des pays est disponible dans `lib/widgets/header.dart` (lignes 32-230) et inclut :
- 🇧🇯 Bénin (XOF)
- 🇨🇮 Côte d'Ivoire (XOF)
- 🇸🇳 Sénégal (XOF)
- 🇲🇱 Mali (XOF)
- 🇳🇪 Niger (XOF)
- 🇧🇫 Burkina Faso (XOF)
- 🇬🇼 Guinée-Bissau (XOF)
- 🇹🇬 Togo (XOF)
- 🇨🇲 Cameroun (XAF)
- 🇨🇫 Centrafrique (XAF)
- 🇨🇬 Congo (XAF)
- 🇬🇶 Guinée équatoriale (XAF)
- 🇬🇦 Gabon (XAF)
- 🇹🇩 Tchad (XAF)
- 🇫🇷 France (EUR)
- 🇺🇸 États-Unis (USD)
- 🇬🇧 Royaume-Uni (GBP)
- Et bien d'autres...

## Correction du problème du dropdown

### Problème identifié
Le dropdown de sélection de pays ne s'affichait plus à cause de :
1. **Liste trop longue** : Plus de 200 pays causaient des problèmes de performance
2. **Erreur de syntaxe** : Espace vide dans la liste des pays
3. **Problèmes de rendu** : PopupMenuButton ne pouvait pas gérer une liste si volumineuse

### Solution appliquée
- ✅ **Optimisation de la liste** : Réduction à 50 pays les plus pertinents
- ✅ **Priorisation africaine** : Pays africains en premier
- ✅ **Correction syntaxe** : Suppression de l'espace vide
- ✅ **Ajout de debug** : Messages de log pour tracer les sélections

### Liste optimisée
La nouvelle liste inclut :
- **Pays africains prioritaires** (XOF, XAF, autres devises africaines)
- **Pays occidentaux importants** (EUR, USD, GBP, CAD)
- **Pays émergents** (BRL, CNY, JPY, INR)

## Prochaines étapes

1. **Tester la solution** avec différents pays
2. **Mettre à jour les API côté serveur** si nécessaire
3. **Configurer Moneroo** pour accepter les paiements depuis toutes les zones géographiques
4. **Documenter les devises supportées** par Moneroo pour chaque pays
5. **Tester le dropdown** pour s'assurer qu'il fonctionne correctement
