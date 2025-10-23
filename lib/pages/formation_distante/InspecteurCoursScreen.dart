import 'package:epst_windows_app/pages/formation_distante/InspecteurCoursFormScreen.dart';
import 'package:epst_windows_app/pages/formation_distante/inspecteur_cours.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'inspecteur_cours_provider.dart';

class InspecteurCoursScreen extends StatefulWidget {
  InspecteurCoursScreen(this.idInspecteur);
  int idInspecteur;

  @override
  State<InspecteurCoursScreen> createState() => _InspecteurCoursScreenState();
}

class _InspecteurCoursScreenState extends State<InspecteurCoursScreen> {
  final _searchController = TextEditingController();
  int _currentPage = 0;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<InspecteurCoursProvider>(context, listen: false);
      provider.loadAllInspecteurCours(
          pageIndex: _currentPage,
          pageSize: _pageSize,
          idInspecteur: widget.idInspecteur);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: const Text('Gestion Inspecteur Cours'),
        //   actions: [
        //     IconButton(
        //       icon: const Icon(Icons.refresh),
        //       onPressed: _loadData,
        //     ),
        //   ],
        // ),
        body: Column(
          children: [
            _buildSearchBar(),
            _buildStats(),
            Expanded(child: _buildContent()),
            _buildPagination(),
          ],
        ),
        floatingActionButton: Consumer<InspecteurCoursProvider>(
            builder: (context, provider, child) {
          return FloatingActionButton(
            onPressed: () {
              //
              if (provider.inspecteurCoursList.isEmpty) {
                InspecteurCours inspecteurCours = InspecteurCours(
                  idInspecteur: widget.idInspecteur,
                  cours: [],
                  classe: [], // On stocke l'ID de la classe sélectionnée
                );
                widget.idInspecteur;
                //
                print("Valeur data: ${widget.idInspecteur}");
                //
                _navigateToForm(context, inspecteurCours);
              } else {
                InspecteurCours inspecteurCours =
                    provider.inspecteurCoursList[0];
                _navigateToForm(context, inspecteurCours);
              }
            },
            child: const Icon(Icons.add),
          );
        }));
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Rechercher par ID Inspecteur',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              keyboardType: TextInputType.number,
              onSubmitted: (value) {
                final provider = Provider.of<InspecteurCoursProvider>(context,
                    listen: false);
                if (value.isNotEmpty) {
                  provider.loadByInspecteurId(int.parse(value));
                } else {
                  _loadData();
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              _loadData();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Consumer<InspecteurCoursProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: ${provider.inspecteurCoursList.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (provider.isLoading)
                const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return Consumer<InspecteurCoursProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.inspecteurCoursList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Erreur: ${provider.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadData,
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        if (provider.inspecteurCoursList.isEmpty) {
          return const Center(
            child: Text('Aucun inspecteur cours trouvé'),
          );
        }

        return ListView.builder(
          itemCount: provider.inspecteurCoursList.length,
          itemBuilder: (context, index) {
            final inspecteurCours = provider.inspecteurCoursList[index];
            return _buildInspecteurCoursCard(inspecteurCours);
          },
        );
      },
    );
  }

  Widget _buildInspecteurCoursCard(InspecteurCours inspecteurCours) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(inspecteurCours.id.toString()),
        ),
        title: Text('Inspecteur: ${inspecteurCours.idInspecteur}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cours: ${inspecteurCours.cours.length}'),
            Text('Classes: ${inspecteurCours.classe.length}'),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Modifier'),
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete),
                title: Text('Supprimer'),
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              _navigateToForm(context, inspecteurCours);
            } else if (value == 'delete') {
              _showDeleteDialog(context, inspecteurCours);
            }
          },
        ),
        onTap: () => _navigateToForm(context, inspecteurCours),
      ),
    );
  }

  Widget _buildPagination() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _currentPage > 0
                ? () {
                    setState(() {
                      _currentPage--;
                    });
                    _loadData();
                  }
                : null,
          ),
          Text('Page ${_currentPage + 1}'),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              setState(() {
                _currentPage++;
              });
              _loadData();
            },
          ),
        ],
      ),
    );
  }

  void _navigateToForm(BuildContext context,
      [InspecteurCours? inspecteurCours]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InspecteurCoursFormScreen(
          inspecteurCours: inspecteurCours,
        ),
      ),
    ).then((_) => _loadData());
  }

  void _showDeleteDialog(
      BuildContext context, InspecteurCours inspecteurCours) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Supprimer l\'inspecteur cours #${inspecteurCours.id}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final provider =
                  Provider.of<InspecteurCoursProvider>(context, listen: false);
              provider.deleteInspecteurCours(inspecteurCours.id!);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
