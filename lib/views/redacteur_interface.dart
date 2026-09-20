import 'package:flutter/material.dart';
import '../modele/redacteur.dart';
import '../services/database_manager.dart';

class RedacteurInterface extends StatefulWidget {
  const RedacteurInterface({super.key});

  @override
  State<RedacteurInterface> createState() => _RedacteurInterfaceState();
}

class _RedacteurInterfaceState extends State<RedacteurInterface> {
  final DatabaseManager _dbManager = DatabaseManager();

  // Contrôleurs pour le formulaire d'ajout
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  List<Redacteur> _redacteurs = [];

  @override
  void initState() {
    super.initState();
    _chargerRedacteurs(); // charge les rédacteurs déjà enregistrés au démarrage
  }

  // Récupère la liste des rédacteurs depuis la base et met à jour l'écran
  Future<void> _chargerRedacteurs() async {
    final liste = await _dbManager.getAllRedacteurs();
    setState(() {
      _redacteurs = liste;
    });
  }

  // Ajoute un nouveau rédacteur à partir des champs du formulaire
  Future<void> _ajouterRedacteur() async {
    final nom = _nomController.text.trim();
    final prenom = _prenomController.text.trim();
    final email = _emailController.text.trim();

    if (nom.isEmpty || prenom.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs.')),
      );
      return;
    }

    final nouveauRedacteur = Redacteur.sansId(
      nom: nom,
      prenom: prenom,
      email: email,
    );

    await _dbManager.insertRedacteur(nouveauRedacteur);

    _nomController.clear();
    _prenomController.clear();
    _emailController.clear();

    await _chargerRedacteurs();
  }

  // Affiche la boîte de dialogue de modification, pré-remplie avec les valeurs actuelles
  void _afficherDialogueModification(Redacteur redacteur) {
    final nomModifController = TextEditingController(text: redacteur.nom);
    final prenomModifController = TextEditingController(text: redacteur.prenom);
    final emailModifController = TextEditingController(text: redacteur.email);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Modifier Rédacteur'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomModifController,
                decoration: const InputDecoration(labelText: 'Nouveau Nom'),
              ),
              TextField(
                controller: prenomModifController,
                decoration: const InputDecoration(labelText: 'Nouveau Prénom'),
              ),
              TextField(
                controller: emailModifController,
                decoration: const InputDecoration(labelText: 'Nouvel Email'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                final redacteurModifie = Redacteur(
                  id: redacteur.id,
                  nom: nomModifController.text.trim(),
                  prenom: prenomModifController.text.trim(),
                  email: emailModifController.text.trim(),
                );

                await _dbManager.updateRedacteur(redacteurModifie);
                await _chargerRedacteurs();

                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  // Affiche la boîte de dialogue de confirmation avant suppression
  void _afficherDialogueSuppression(Redacteur redacteur) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: Text(
            'Voulez-vous vraiment supprimer ${redacteur.prenom} ${redacteur.nom} ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                await _dbManager.deleteRedacteur(redacteur.id!);
                await _chargerRedacteurs();

                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Zone supérieure : formulaire d'ajout
          TextField(
            controller: _nomController,
            decoration: const InputDecoration(labelText: 'Nom'),
          ),
          TextField(
            controller: _prenomController,
            decoration: const InputDecoration(labelText: 'Prénom'),
          ),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _ajouterRedacteur,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un Rédacteur'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(45),
            ),
          ),
          const SizedBox(height: 16),

          // Zone inférieure : liste des rédacteurs
          Expanded(
            child: _redacteurs.isEmpty
                ? const Center(child: Text('Aucun rédacteur enregistré.'))
                : ListView.builder(
                    itemCount: _redacteurs.length,
                    itemBuilder: (context, index) {
                      final redacteur = _redacteurs[index];
                      return Card(
                        child: ListTile(
                          title: Text('${redacteur.prenom} ${redacteur.nom}'),
                          subtitle: Text(redacteur.email),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () =>
                                    _afficherDialogueModification(redacteur),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () =>
                                    _afficherDialogueSuppression(redacteur),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}