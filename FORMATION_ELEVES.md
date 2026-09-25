# Formation en ligne des élèves

## Parcours livré

- Connexion avec l’identifiant scolaire Smart-Kelasi, ou lecture du QR-code puis confirmation. Les zéros initiaux de l’identifiant sont conservés.
- Logo officiel identique à celui de l’application enseignant et suppression du lien de création de compte. L’élève doit posséder un profil rattaché à une école.
- Même connexion depuis l’application élève autonome et depuis **EPST mobile → Ma classe en ligne**.
- Trois onglets : **Mes cours**, **Progression**, **Direct**. Les cours sont filtrés selon la classe scolaire, avec prise en charge des variantes telles que « 1ère » et « 1er ».
- Lecture SCORM 1.2/2004, sauvegarde locale de la position et des données de reprise, affichage du score et de l’avancement, reprise depuis les données synchronisées. La synchronisation différée reste attachée à son élève, même après un changement de compte.
- Côté administration, consultation des progressions par école, élève et cours. Les résultats des enseignants présents dans la même table sont écartés de cette vue.

## Donner un cours vidéo en direct

1. Dans l’administration Windows, créer ou modifier l’agent et choisir **Inspecteur video streaming** (rôle 21).
2. Lui attribuer les classes dans la gestion des cours à distance.
3. L’inspecteur se connecte dans **EPST mobile**, qui ouvre le module **inspecteur_cours_distant**.
4. Il choisit l’audience : élèves, enseignants ou les deux, puis ses classes et démarre le direct.
5. Il partage la clé du direct. L’élève connecté saisit cette clé dans **Direct** et choisit sa classe.
6. Le serveur vérifie l’inscription et la classe de l’élève, l’audience du direct et les places disponibles. À la fin du direct, l’écran élève se ferme après détection de la fin de session.

La caméra et le microphone sont utilisés sur le téléphone de l’inspecteur. L’administration Windows sert à attribuer les rôles/classes et à consulter les sessions et participants.

## Projets concernés

| Projet | Modifications |
| --- | --- |
| `enseignement_en_ligne` | Connexion/QR, interface, progression et reprise SCORM, accès au direct, configuration Android/iOS et tests |
| `epst_mobile_app` | Intégration du nouveau login élève, accès des inspecteurs de rôle 21, permissions iOS et test d’intégration |
| `inspecteur_cours_distant` | Rôle 21, choix de l’audience, cycle de vie du direct et tests |
| `epst_windows` | Raccord du suivi des élèves, cohérence des identités et informations sur la diffusion mobile |
| `epst_serveur_app` | Vérification des élèves/classes, admission aux directs, fin des sessions et ordre des progressions SCORM |

Les projets enseignants et Smart-Kelasi servent de référence ; leurs sources n’ont pas été modifiées dans cette intervention. Les modifications déjà présentes dans les autres projets ont été conservées.

## Mise en service

Les changements sont locaux. Déployer le serveur EPST modifié et distribuer les nouvelles applications pour les utiliser ensemble. La variable `school.server.base-url` reste configurable ; sa valeur par défaut pointe sur le serveur Smart-Kelasi déjà utilisé par les applications.

La connexion conserve le fonctionnement demandé par identifiant scolaire. Elle dépend de la disponibilité du service Smart-Kelasi. Un cours déjà téléchargé peut être poursuivi hors connexion ; la progression en attente doit ensuite être synchronisée.

Avant diffusion aux écoles, réaliser un essai sur deux téléphones : un inspecteur avec caméra/microphone et un élève, puis ouvrir un vrai paquet SCORM, quitter, reprendre et contrôler la progression dans Windows. Les tests automatisés ne valident pas la capture audiovisuelle réelle ni le contenu de chaque paquet SCORM.

## Vérifications automatisées

- Application élève : 13 tests réussis (ID/QR, inscription scolaire, isolation des élèves, reprise, synchronisation et interface à deux tailles).
- Module inspecteur : 4 tests réussis (affichage, rôle 21, audience et requête de démarrage).
- Intégration EPST mobile : 1 test réussi (login et chargement du logo depuis le package élève).
- Moteur JavaScript SCORM : 3 tests réussis (SCORM 1.2, SCORM 2004, sauvegarde à la fermeture).
- Serveur : compilation propre réussie et 3 tests réussis de contrôle d’accès et de correspondance des classes.

Les analyses des fichiers modifiés ne remplacent pas une recette complète de tous les autres modules des applications existantes.

Compilations Android réussies (APK de test) :

- `enseignement_en_ligne/build/app/outputs/flutter-apk/app-debug.apk`
- `epst_mobile_app/build/app/outputs/flutter-apk/app-debug.apk`

Les anciens écrans de création de compte/récupération de mot de passe, désormais inutilisés dans le parcours élève, conservent des avertissements d’analyse. Des remarques de style préexistantes subsistent aussi dans l’administration et le contrôleur d’identification mobile ; elles ne bloquent pas les compilations ci-dessus.

## Correctif : cours absents en deuxième primaire

Le catalogue en ligne contient bien « français » (PDF, 21452) et « math » (ZIP, 21453) pour la deuxième primaire. Leurs fiches stockent `idClasse`, mais pas `niveau` (`cls` vaut 0). L’onglet « Mes cours » déduisait auparavant le niveau uniquement depuis ces fiches et rejetait donc la classe lors du filtrage.

Le module élève relie maintenant les cours au catalogue `/classes` par `idClasse`, comme la bibliothèque mobile. Cette correspondance est mise en cache pour le mode hors connexion. Le libellé de classe ne contient plus le faux niveau « 0e » et les répétitions de « Primaire » sont éliminées pour la comparaison. Les cours d’autres niveaux et ceux des professeurs restent exclus.

L’administration transmet également les informations de classe lors des prochains ajouts. Les cours déjà publiés fonctionnent avec la correction mobile, sans réimportation ni nouveau déploiement serveur pour ce correctif.

Validation : les cinq tests de régression couvrent les deux supports réels, les variantes du libellé de classe, le cache hors connexion, l’ajout d’un nouveau ZIP après actualisation et les anciens cours sans catalogue disponible. Les 18 tests Flutter élèves passent.

Les APK de test EPST mobile et élève autonome ont été recompilés avec ce correctif. L’analyse des quatre fichiers Dart concernés ne signale aucun problème. Installer la nouvelle version, ouvrir « Mes cours », choisir la deuxième primaire puis actualiser la liste.
