<?php
header('Content-Type: application/json');
$user_id = $_GET['user_id'] ?? '';
$plan_id = $_GET['plan_id'] ?? '';
// Connecte-toi à ta base et récupère le dernier abonnement pour cet user/plan
// Exemple :
$conn = new PDO('mysql:host=localhost;dbname=ta_db', 'user', 'pass');
$stmt = $conn->prepare("SELECT status FROM subscriptions WHERE user_id=? AND plan=? ORDER BY id DESC LIMIT 1");
$stmt->execute([$user_id, $plan_id]);
$row = $stmt->fetch(PDO::FETCH_ASSOC);
if ($row) {
    echo json_encode(['status' => $row['status']]);
} else {
    echo json_encode(['status' => 'none']);
}