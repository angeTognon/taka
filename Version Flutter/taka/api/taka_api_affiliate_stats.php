<?php
// filepath: /Users/mac/Documents/taka2/taka_api_affiliate_stats.php

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') exit;

include 'db.php'; // $pdo

$user_id = isset($_GET['user_id']) ? intval($_GET['user_id']) : 0;
if (!$user_id) {
    echo json_encode(['error' => 'user_id requis']);
    exit;
}

// Total earnings
$stmt = $pdo->prepare("SELECT SUM(amount) as total FROM taka_affiliate_earnings WHERE user_id = ?");
$stmt->execute([$user_id]);
$totalEarnings = (int)($stmt->fetchColumn() ?: 0);

// Earnings this month
$stmt = $pdo->prepare("SELECT SUM(amount) as month FROM taka_affiliate_earnings WHERE user_id = ? AND MONTH(created_at) = MONTH(NOW()) AND YEAR(created_at) = YEAR(NOW())");
$stmt->execute([$user_id]);
$thisMonthEarnings = (int)($stmt->fetchColumn() ?: 0);

// Pending payment (pas de colonne status, donc même chose que total)
$stmt = $pdo->prepare("SELECT SUM(amount) as pending FROM taka_affiliate_earnings WHERE user_id = ?");
$stmt->execute([$user_id]);
$pendingPayment = (int)($stmt->fetchColumn() ?: 0);

// Nombre de conversions (nombre de lignes)
$stmt = $pdo->prepare("SELECT COUNT(*) FROM taka_affiliate_earnings WHERE user_id = ?");
$stmt->execute([$user_id]);
$conversions = (int)$stmt->fetchColumn();

// Nombre de clics (si tu as une table dédiée, sinon laisse à 0)
$totalClicks = 0;

// Conversion rate (exemple simple)
$conversionRate = $totalClicks > 0 ? round($conversions / $totalClicks * 100, 1) : 0.0;

echo json_encode([
    'totalClicks' => $totalClicks,
    'conversions' => $conversions,
    'conversionRate' => $conversionRate,
    'totalEarnings' => $totalEarnings,
    'pendingPayment' => $pendingPayment,
    'thisMonthEarnings' => $thisMonthEarnings,
]);