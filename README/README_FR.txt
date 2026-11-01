=====================================================================
  AION 2 WINGMAN 1.0                                        by VaLeTecK
  Outil QoL pour AION 2 : assistant Teleport rapide + HUD overlay
=====================================================================

DE QUOI S'AGIT-IL
  Un programme AutoHotkey v2 qui tourne à côté d'AION 2 et ajoute :
  - HUD overlay : viseur, barres et icônes LOOT / COMBAT qui
    s'allument avec les signaux de vos macros (F9 / F10).
  - Hidden Cube : quand la fenêtre des Hidden Cube s'ouvre, il place la
    souris sur « Open with Key » et l'y maintient.
  - Assistant Teleport rapide (Field Boss) : carte ouverte, un panneau
    affiche tous les boss (A-Z, rangs, actifs / inactifs).
    ULTRA-FAST MODE (par défaut) : tu cliques le boss, Wingman trouve
    tout seul son Teleport dans la liste Kibelisk, tu le cliques et tu
    appuies deux fois sur F. Une flèche indique ensuite la direction.
    NORMAL MODE : parcours guidé complet jusqu'au Teleport le plus proche.
  - Fenêtre de Paramètres complète, presets de résolution, profils de
    performance, 12 langues d'interface et 22 thèmes (8 de classe, 7 de fêtes)
    et vos propres thèmes.

  Le script NE clique PAS et N'appuie PAS sur les touches à votre place :
  il déplace seulement le curseur et vous montre quoi faire.

CONTENU DU PAQUET
  Setup AION 2 Wingman.bat   installation du premier lancement (dépendances)
  AION 2 Wingman.ahk         le programme
  OCR.ahk                    bibliothèque OCR (utilisée par Field Boss)
  README\                    ces instructions en plusieurs langues

CONFIGURATION REQUISE
  - Windows 10 ou 11
  - AutoHotkey v2 (installé par le setup)
  - OCR Windows en anglais (installé par le setup)
  - Client AION 2 en anglais (Field Boss lit les noms en anglais)

INSTALLATION
  1. Avant d'extraire : clic droit sur le zip > Propriétés > cochez
     « Débloquer » > OK. (Évite les avertissements de Windows.)
  2. Extrayez le zip dans un dossier fixe, ex. Documents\AION 2 Wingman.
     NE lancez PAS les fichiers depuis l'intérieur du zip.
  3. Double-cliquez sur « Setup AION 2 Wingman.bat » et acceptez la
     demande administrateur. Le setup vérifie et installe tout, puis
     peut créer un raccourci sur le bureau et lancer Wingman.
     Si « Windows a protégé votre ordinateur » apparaît :
     « Informations complémentaires » > « Exécuter quand même ».
     Pendant le setup, une configuration guidée règle la langue,
     la résolution, les performances et les fonctions ON/OFF.
  4. Ensuite, lancez « AION 2 Wingman.ahk » (ou le raccourci). Il
     demande lui-même les droits administrateur : nécessaires pour lire
     les touches quand le jeu est au premier plan.

PREMIER LANCEMENT : À FAIRE D'ABORD
  - Ouvrez les Paramètres : Ctrl+Shift+F12 (ou double-clic sur l'icône
    verte « H » de la barre des tâches).
  - La langue se choisit déjà dans le setup (modifiable dans ⚙️ Général > Langue).
  - 📦 Preset : appliquez FullHD (1080p), 2K (1440p) ou 4K (2160p)
    selon votre écran, pour que le HUD ait la bonne taille.
  - « Sauver et relancer » pour valider. Avec « APERÇU EN DIRECT » vous voyez
    les changements en direct, même sans le jeu.

TOUCHES PAR DÉFAUT (modifiables dans Paramètres > ⌨️ Touches)
  Ctrl+Shift+\      HUD overlay ON/OFF
  Ctrl+Shift+1      Hidden Cube ON/OFF
  Ctrl+Shift+2      Field Boss ON/OFF
  Ctrl+Shift+F12    Paramètres (fonctionne aussi hors du jeu)
  Échap             annule le guide Field Boss en cours
  M / F             touches Carte et Travel du jeu (le script les « écoute »)
  F9 / F10          signaux de vos macros pour le HUD (voir plus bas)
  Ctrl+F11, Ctrl+Shift+F6/F7/F8   diagnostic (seulement en cas de souci)
  (\ = touche à gauche du 1 sur un clavier italien ; sur AZERTY ou autre,
   choisissez votre propre touche dans les Paramètres.)

RELIER VOS MACROS AU HUD
  - Macro de combat : mettez F9 en spam pendant toute la macro.
  - Macro d'loot : insérez F10 avec une attente de 1350 ms.
  Les touches arrivent quand même au jeu.

UTILISER FIELD BOSS
  1. Ouvrez la carte (M). La légende des touches apparaît en haut, le
     panneau des boss à droite (filtres rang/état, ▲/▼ pour le réduire).
  2. Cliquez sur un boss. Le guide par étapes démarre : la souris est
     placée (et bloquée) au bon endroit et une grande consigne
     « ÉTAPE n » s'affiche en bas. C'est vous qui cliquez.
  3. Après le clic sur le Teleport, appuyez deux fois sur F (Travel). La
     souris est libérée et une flèche indique la direction du boss.
  Échap annule à tout moment.

PROBLÈMES FRÉQUENTS
  - Rien ne se passe en jeu : le script ne fonctionne qu'avec AION2.exe
    au premier plan. Vérifiez l'icône « H » dans la barre des tâches.
  - Field Boss « non disponible » : OCR.ahk absent du dossier ou OCR
    anglais de Windows manquant. Relancez le setup.
  - HUD trop grand/petit ou décalé : appliquez le bon preset.
  - Antivirus qui bloque le script : faux positif courant avec
    AutoHotkey ; ajoutez le dossier aux exclusions.
  - En cas de problème après une modification : une copie de secours
    « AION 2 Wingman.ahk.bak » se trouve à côté du script.

MISES À JOUR ET RÉGLAGES PERSONNELS
  Pour mettre à jour, écrasez simplement le script : vos réglages
  (liste des boss et presets compris) sont dans %AppData%\AION 2 Wingman
  et sont restaurés automatiquement au premier lancement.
  Pour repartir de zéro, supprimez ce dossier.

MAINTENANCE ET FERMETURE
  Paramètres > 🛠️ Maintenance : relance l'installation guidée et ouvre le
  dossier de Wingman et celui des paramètres personnels.
  Le bouton rouge « ⏻ Quitter Wingman » en haut ferme tout le programme,
  pas seulement la fenêtre des paramètres.
  La case 🔍 au-dessus du menu cherche dans tous les paramètres.

DÉSINSTALLATION
  Fermez Wingman (« ⏻ Quitter Wingman » ou icône « H » > Exit), supprimez le dossier et le
  raccourci. AutoHotkey se désinstalle via Paramètres Windows >
  Applications.

CRÉDITS ET AVERTISSEMENT
  AION 2 Wingman - by VaLeTecK.
  OCR.ahk - by Descolada (github.com/Descolada/OCR)
  AION 2 est une marque de ses propriétaires respectifs ; ce projet n'est
  ni affilié ni approuvé par eux. Outil tiers : utilisez-le à vos
  risques et dans le respect des conditions d'utilisation du jeu.
