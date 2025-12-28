class UserModel {
  final String id;
   String name;
  final String email;
    final String createdAt; // <-- doit contenir la date d'inscription (ex: "2025-08-10 01:39:29")

  final String? phone; // Ajoute ce champ si tu veux le passer à Kkiapay

  UserModel({required this.id, required this.name, required this.email, this.phone, required this.createdAt});
}