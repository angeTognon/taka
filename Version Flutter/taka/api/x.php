<?php
require('fpdf.php');

class PDF extends FPDF {
    function Header() {
        $this->SetFont('Arial', 'B', 12);
        $this->Cell(0, 10, 'Liste des Salariés', 0, 1, 'C');
        $this->Ln(10);
    }
}

$pdf = new PDF();
$pdf->AddPage();
$pdf->SetFont('Arial', '', 12);

// Connexion à la base de données
$conn = new mysqli('localhost', 'u145148450_pharma_rh', 'Pharmarh02@', 'u145148450_pharma_rh');
 
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Requête pour récupérer les données
$sql = "SELECT nom, prenom,email, mp FROM salarie"; // Adaptez la requête selon vos besoins
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $pdf->Cell(0, 10, 'Nom: ' . $row['nom'] . ' - Poste: ' . $row['poste'], 0, 1);
    }
} else {
    $pdf->Cell(0, 10, 'Aucun salarié trouvé.', 0, 1);
}

$conn->close();
$pdf->Output('D', 'Salariés.pdf'); // Télécharge le PDF
?>