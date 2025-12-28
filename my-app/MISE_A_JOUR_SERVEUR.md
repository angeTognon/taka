# 🔄 Mise à jour facile sur le serveur Hostinger

## Méthode 1 : Via SSH (la plus rapide) ⚡

### Option A : Éditer directement sur le serveur

```bash
# Se connecter en SSH
ssh -p 65002 u914969601@194.164.74.243

# Aller dans le dossier laravel
cd ~/domains/takaafrica.com/laravel

# Éditer le fichier avec nano
nano app/Http/Controllers/ExploreController.php
```

Dans nano :
1. Utilisez les flèches pour naviguer jusqu'à la ligne 250-264
2. Remplacez l'ancienne liste des genres par la nouvelle
3. Appuyez sur `Ctrl + O` pour sauvegarder
4. Appuyez sur `Enter` pour confirmer
5. Appuyez sur `Ctrl + X` pour quitter

Puis :
```bash
# Vider les caches
php artisan config:clear
php artisan route:clear
```

---

### Option B : Uploader le fichier via SFTP/FTP

1. **Sur votre Mac**, copiez le fichier modifié :
   ```bash
   # Le fichier est dans : /Users/koffiangetognon/Documents/Taka/my-app/app/Http/Controllers/ExploreController.php
   ```

2. **Connectez-vous via FileZilla ou Cyberduck** :
   - Hôte : `sftp://194.164.74.243` (port 65002)
   - Utilisateur : `u914969601`
   - Mot de passe : Votre mot de passe

3. **Naviguez vers** :
   ```
   /domains/takaafrica.com/laravel/app/Http/Controllers/
   ```

4. **Glissez-déposez** le fichier `ExploreController.php` (remplacez l'ancien)

5. **Via SSH**, videz les caches :
   ```bash
   ssh -p 65002 u914969601@194.164.74.243
   cd ~/domains/takaafrica.com/laravel
   php artisan config:clear
   php artisan route:clear
   ```

---

## Méthode 2 : Via le gestionnaire de fichiers Hostinger (hPanel) 🖥️

1. **Connectez-vous à hPanel** : https://hpanel.hostinger.com

2. **Allez dans "Gestionnaire de fichiers"**

3. **Naviguez vers** :
   ```
   domains → takaafrica.com → laravel → app → Http → Controllers
   ```

4. **Trouvez** `ExploreController.php` et cliquez dessus

5. **Cliquez sur "Éditer"** (icône crayon)

6. **Remplacez les lignes 250-264** par :
   ```php
   // Genres disponibles (thématiques)
   $genres = [
       'Tous',
       'Argent & Richesse',
       'Business & Entrepreneuriat',
       'Leadership & Pouvoir',
       'Psychologie & Comportement humain',
       'Spiritualité & Conscience',
       'Philosophie & Sagesse',
       'Histoire & Géopolitique',
       'Sociétés & Civilisations',
       'Science & Connaissance',
       'Développement personnel',
       'Relations & Sexualité',
       'Politique & Stratégie',
       'Ésotérisme & Savoirs cachés',
       'Religion & Textes sacrés',
       'Afrique & Identité',
       'Livres rares & interdits',
   ];
   ```

7. **Sauvegardez** (Ctrl+S ou bouton Sauvegarder)

8. **Via SSH**, videz les caches :
   ```bash
   ssh -p 65002 u914969601@194.164.74.243
   cd ~/domains/takaafrica.com/laravel
   php artisan config:clear
   php artisan route:clear
   ```

---

## Méthode 3 : Script automatique via SCP (copie directe) 📋

Sur votre Mac, dans le terminal :

```bash
# Copier le fichier directement sur le serveur
scp -P 65002 /Users/koffiangetognon/Documents/Taka/my-app/app/Http/Controllers/ExploreController.php u914969601@194.164.74.243:~/domains/takaafrica.com/laravel/app/Http/Controllers/ExploreController.php

# Se connecter et vider les caches
ssh -p 65002 u914969601@194.164.74.243 "cd ~/domains/takaafrica.com/laravel && php artisan config:clear && php artisan route:clear"
```

---

## ⚡ Méthode la plus rapide (recommandée)

**Via SSH avec nano** (Méthode 1 - Option A) :

```bash
ssh -p 65002 u914969601@194.164.74.243
cd ~/domains/takaafrica.com/laravel
nano app/Http/Controllers/ExploreController.php
```

Puis :
1. Trouvez la ligne 250-264
2. Remplacez la liste des genres
3. Sauvegardez (Ctrl+O, Enter, Ctrl+X)
4. Videz les caches : `php artisan config:clear && php artisan route:clear`

---

## ✅ Après la mise à jour

1. Visitez `https://takaafrica.com/explore`
2. Ouvrez le filtre "Genre"
3. Vérifiez que la nouvelle liste s'affiche

