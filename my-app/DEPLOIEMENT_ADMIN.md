# Guide de déploiement - Page Admin

## Script de déploiement

Utilisez le script `deploy-admin.sh` pour mettre à jour le projet Laravel sur le serveur.

### Commande

```bash
cd my-app
./deploy-admin.sh
```

## Ce qui est uploadé

### Fichiers Laravel inclus :
- `app/` - Application Laravel (controllers, modèles, helpers)
- `resources/` - Vues Blade (y compris la nouvelle page admin)
- `routes/` - Routes (y compris les routes admin)
- `config/` - Configuration
- `public/` - Fichiers publics (CSS, JS, images)
- `database/` - Migrations et seeders
- `bootstrap/` - Bootstrap Laravel
- `storage/` - Stockage (structure uniquement, pas les logs/cache)

### Fichiers exclus :
- `vendor/` - Dépendances Composer (déjà sur le serveur)
- `node_modules/` - Dépendances NPM
- `.env` - Variables d'environnement (ne pas remplacer)
- `storage/framework/cache/*` - Cache (généré automatiquement)
- `storage/framework/sessions/*` - Sessions
- `storage/framework/views/*` - Vues compilées
- `storage/logs/*` - Logs
- `bootstrap/cache/*` - Cache bootstrap

### Fichiers publics uploadés :
- `public/images/` → `public_html/images/`

## Structure sur le serveur

```
/home/u914969601/domains/takaafrica.com/
├── laravel/                    # Projet Laravel
│   ├── app/
│   ├── resources/
│   │   └── views/
│   │       └── admin/
│   │           ├── index.blade.php    # Page admin
│   │           └── login.blade.php    # Page de login admin
│   ├── routes/
│   │   └── web.php                    # Routes (admin ajoutées)
│   └── ...
└── public_html/                # Fichiers publics
    ├── index.php              # Point d'entrée Laravel
    └── images/                # Images
```

## Authentification Admin

Après déploiement, accédez à :
- Login : https://takaafrica.com/admin/login
- Admin : https://takaafrica.com/admin

Identifiants :
- Email : `admin@gmail.com`
- Mot de passe : `Taka2025#`

## Vérifications après déploiement

1. ✅ Tester la page de login admin
2. ✅ Se connecter avec les identifiants admin
3. ✅ Vérifier l'affichage de la page admin (stats, livres)
4. ✅ Tester la validation d'un livre
5. ✅ Vérifier les détails d'un livre
6. ✅ Tester le bouton "Voir le livre"
7. ✅ Tester la déconnexion

## Notes importantes

- Le script ne modifie **pas** le fichier `.env` sur le serveur
- Le cache est automatiquement vidé après l'upload
- Les permissions sont automatiquement configurées
- Les nouvelles routes sont automatiquement chargées

