<?php

namespace App\Helpers;

class BookHelper
{
    /**
     * Convertit un titre en slug (identique à la fonction Flutter)
     */
    public static function titleToSlug($title)
    {
        if (empty($title)) {
            return '';
        }
        
        // Décoder les entités HTML (comme &#039; ou &apos; pour l'apostrophe)
        // IMPORTANT: Décoder AVANT la conversion pour gérer correctement les apostrophes
        $title = html_entity_decode($title, ENT_QUOTES | ENT_HTML5, 'UTF-8');
        
        // Convertir en minuscules (identique à Flutter)
        $slug = mb_strtolower($title, 'UTF-8');
        
        // Remplacer les caractères accentués (identique à Flutter)
        // IMPORTANT: Ne PAS supprimer les apostrophes avant, elles seront remplacées par des tirets
        $accents = [
            'à' => 'a', 'á' => 'a', 'â' => 'a', 'ã' => 'a', 'ä' => 'a', 'å' => 'a',
            'è' => 'e', 'é' => 'e', 'ê' => 'e', 'ë' => 'e',
            'ì' => 'i', 'í' => 'i', 'î' => 'i', 'ï' => 'i',
            'ò' => 'o', 'ó' => 'o', 'ô' => 'o', 'õ' => 'o', 'ö' => 'o',
            'ù' => 'u', 'ú' => 'u', 'û' => 'u', 'ü' => 'u',
            'ý' => 'y', 'ÿ' => 'y',
            'ñ' => 'n', 'ç' => 'c',
        ];
        
        $slug = strtr($slug, $accents);
        
        // Remplacer les caractères spéciaux et espaces par des tirets (identique à Flutter)
        // Cela inclut les apostrophes, qui seront remplacées par des tirets
        $slug = preg_replace('/[^a-z0-9]+/', '-', $slug);
        
        // Enlever les tirets en début et fin (identique à Flutter)
        $slug = preg_replace('/^-+|-+$/', '', $slug);
        
        return $slug;
    }
}

