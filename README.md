<div align="center">

<img src="docs/images/banner.png" alt="AION 2 Wingman — AutoHotkey v2 companion for AION 2" width="100%">

[**⬇ Download the latest release**](../../releases/latest)

<br>

<img src="docs/images/overview.jpg" alt="AION 2 Wingman: Field Boss panel, flight direction, step-by-step guide, HUD icons and the Settings window with live preview" width="100%">

🇬🇧 [English](#-english) · 🇮🇹 [Italiano](#-italiano) · 🇪🇸 [Español](#-español) · 🇫🇷 [Français](#-français) · 🇩🇪 [Deutsch](#-deutsch) · 🇧🇷 [Português](#-português) · 🇷🇺 [Русский](#-русский) · 🇰🇷 [한국어](#-한국어) · 🇨🇳 [简体中文](#-简体中文) · 🇯🇵 [日本語](#-日本語)

</div>

---

## 🇬🇧 English

**AION 2 Wingman** is a Windows program written in **AutoHotkey v2** that runs next to AION 2 and gives you a clearer HUD and a few smart helpers.

> **AION 2 Wingman never clicks or presses keys for you in the game.** It only draws on screen, moves the cursor to the right spot and tells you what to do: every click is yours.

### ✨ Features

**🎯 HUD overlay**
- Crosshair, two bars and two status icons, **LOOT** and **COMBAT**, that light up from your macros' signals (F9 = combat, F10 = loot).
- Each icon has its own shape, size, position, text, emoji, animated effects (pulse, ring, spin, glow) and fade-in/out. It can mirror the other icon automatically.
- Text and emoji fit inside the icon shape by themselves.

<img src="docs/images/hud.png" alt="HUD overlay in game with the Classic, GTA VI and Halloween themes" width="760">

**👑 Field Boss**
- When you open the map, a panel lists every field boss (A–Z) with grade colors, active / inactive status and filters.
- Click a boss and a **step-by-step guide** moves the cursor to Exploration, Field Boss, the boss and the nearest Teleport. Big on-screen instructions tell you what to click.
- After Travel, an arrow shows the **flight direction** to the boss.
- Inside **dungeons** the panel stays hidden: it is detected from the map tabs and from the dungeon name.
- Uses the Windows OCR, so it reads the English game client.

<img src="docs/images/guide-step1.jpg" alt="Field Boss guide, step 1: click the boss" width="100%">
<img src="docs/images/guide-teleport.jpg" alt="Field Boss guide: click the nearest Teleport" width="100%">

<details><summary>🖼️ Field Boss panel in three themes</summary>

<img src="docs/images/fieldboss-panels.png" alt="Field Boss panel in the Classic, Halloween and Sorcerer themes" width="760">
</details>

**🧊 Hidden Cube**
- When the Hidden Cube window opens, it moves the mouse to "Open with Key" and keeps it there.

**⚙️ Settings window** (Ctrl+Shift+F12)
- A menu for every function, a **search box**, a description and an example for each option, and a **live preview** of the HUD without the game.
- **Resolution presets**: FullHD, 2K and 4K.
- **Performance profiles**, from "potato" to "gigachad".
- Your own presets.
- A Maintenance menu and a clear **Quit Wingman** button.
- **12 languages**: English, Italiano, Español, Français, Deutsch, Português, Русский, 한국어, 简体中文, 日本語, plus two bonus meme languages.

**🎨 Themes**
- **22 ready-made themes**:
  - classics: dark, bright, cuddle, pinkhaze, e-girl and a GTA VI one with a release countdown;
  - **8 AION 2 class themes**, each with its own crosshair and icon shapes, animations, effects and emoji;
  - **7 event themes**: Halloween, Christmas, New Year, Valentine's Day, Carnival, Easter and St. Patrick's Day.
- **Theme editor**: press *Customize this theme* and you get your own copy ("… Custom"), editable in every detail. Ready-made themes never change.

<details><summary>🎨 See all the themes</summary>

<img src="docs/images/themes.png" alt="All 22 ready-made themes with their colors, icon shapes and emoji" width="100%">
</details>

**🔄 Updates and personal settings**
- Checks this repository for new releases and installs them when you agree, or automatically. It never interrupts you while you play.
- Your settings, presets and themes are stored in `%AppData%\AION 2 Wingman` and **survive every update**.

### 💻 Requirements
- Windows 10 or 11
- AutoHotkey v2 and the English Windows OCR (both installed by the setup)
- English AION 2 client (for Field Boss)

### 📦 Installation
1. Download **`AION-2-Wingman.zip`** from the [latest release](../../releases/latest).
2. Right-click the zip > **Properties** > tick **Unblock** > OK. This avoids Windows warnings.
3. Extract it to a **permanent folder**, for example `Documents\AION 2 Wingman`. Do not run it from inside the zip.
4. Double-click **`Setup AION 2 Wingman.bat`** and accept the administrator prompt. It checks and installs what is missing, then guides you through language, resolution, performance, theme and features. It can also create a desktop shortcut.
5. From then on, start **`AION 2 Wingman.ahk`** or the shortcut.

### ⌨️ Default keys
| Keys | Action |
|---|---|
| `Ctrl+Shift+\` | HUD overlay ON/OFF |
| `Ctrl+Shift+1` | Hidden Cube ON/OFF |
| `Ctrl+Shift+2` | Field Boss ON/OFF |
| `Ctrl+Shift+F12` | Settings (also outside the game) |
| `Esc` | Cancel the Field Boss guide |
| `M` / `F` | Game Map / Travel keys (Wingman listens to them) |
| `F9` / `F10` | Macro signals for the HUD |

All keys can be changed in Settings > Keys.

### 🎮 Connect your macros to the HUD
- **Combat macro**: spam `F9` for the whole macro.
- **Loot macro**: add `F10` with a 1350 ms wait.

The keys still reach the game as usual.

### ❓ FAQ
- **Nothing happens in game:** Wingman works only while `AION2.exe` is in the foreground. Check the green "H" icon in the taskbar.
- **Field Boss "not available":** `OCR.ahk` or the English Windows OCR is missing. Run the setup again.
- **HUD too big or too small:** apply the right resolution preset in Settings.
- **Antivirus warning:** this is a common false positive with AutoHotkey scripts. Add the folder to the exclusions.

---

## 🇮🇹 Italiano

**AION 2 Wingman** è un programma per Windows scritto in **AutoHotkey v2**. Gira accanto ad AION 2 e ti dà un HUD più chiaro e qualche aiuto intelligente.

> **AION 2 Wingman non clicca e non preme tasti al posto tuo nel gioco.** Disegna a schermo, porta il cursore sul punto giusto e ti dice cosa fare: ogni click è tuo.

### ✨ Funzioni

**🎯 HUD overlay**
- Mirino, due barre e due icone di stato, **LOOT** e **COMBAT**, che si accendono con i segnali delle tue macro (F9 = combat, F10 = loot).
- Ogni icona ha forma, grandezza, posizione, testi, emoji, effetti animati (pulse, ring, spin, glow) e dissolvenze propri. Può anche essere speculare all'altra.
- Testi ed emoji si adattano da soli alla forma dell'icona.

<img src="docs/images/hud.png" alt="HUD overlay in gioco con i temi Classic, GTA VI e Halloween" width="760">

**👑 Field Boss**
- Aprendo la mappa compare un pannello con tutti i field boss (A–Z), colori del grado, stato attivo / non attivo e filtri.
- Clicchi un boss e una **guida a fasi** porta il cursore su Exploration, Field Boss, il boss e il Teleport più vicino. Istruzioni grandi a schermo ti dicono cosa cliccare.
- Dopo il Travel, una freccia indica la **direzione di volo** verso il boss.
- Nei **dungeon** il pannello resta nascosto: li riconosce dai tab della mappa e dal nome del dungeon.
- Usa l'OCR di Windows, quindi legge il client del gioco in inglese.

<img src="docs/images/guide-step1.jpg" alt="Guida Field Boss, fase 1: clicca il boss" width="100%">
<img src="docs/images/guide-teleport.jpg" alt="Guida Field Boss: clicca il Teleport più vicino" width="100%">

<details><summary>🖼️ Il pannello Field Boss in tre temi</summary>

<img src="docs/images/fieldboss-panels.png" alt="Pannello Field Boss con i temi Classic, Halloween e Sorcerer" width="760">
</details>

**🧊 Hidden Cube**
- Quando si apre la finestra degli Hidden Cube porta il mouse su "Open with Key" e ce lo tiene.

**⚙️ Finestra Impostazioni** (Ctrl+Shift+F12)
- Un menu per ogni funzione, una **casella di ricerca**, descrizione ed esempio per ogni opzione e l'**anteprima dal vivo** dell'HUD anche senza gioco.
- **Preset di risoluzione**: FullHD, 2K e 4K.
- **Profili prestazioni**, da "potato" a "gigachad".
- Preset tuoi.
- Un menu Manutenzione e un pulsante **Termina Wingman** ben chiaro.
- **12 lingue**: English, Italiano, Español, Français, Deutsch, Português, Русский, 한국어, 简体中文, 日本語, più due lingue bonus meme.

**🎨 Temi**
- **22 temi pronti**:
  - classici: dark, bright, cuddle, pinkhaze, e-girl e uno GTA VI con il conto alla rovescia all'uscita;
  - **8 temi delle classi di AION 2**, ognuno con forme di mirino e icone, animazioni, effetti ed emoji propri;
  - **7 temi di eventi**: Halloween, Natale, Capodanno, San Valentino, Carnevale, Pasqua e San Patrizio.
- **Editor temi**: premi *Personalizza questo tema* e ottieni una tua copia ("… Custom"), modificabile in ogni dettaglio. I temi pronti non cambiano mai.

<details><summary>🎨 Guarda tutti i temi</summary>

<img src="docs/images/themes.png" alt="Tutti i 22 temi pronti con colori, forme delle icone ed emoji" width="100%">
</details>

**🔄 Aggiornamenti e impostazioni personali**
- Controlla le nuove release di questa repository e le installa quando sei d'accordo, oppure in automatico. Non ti interrompe mai mentre giochi.
- Impostazioni, preset e temi sono salvati in `%AppData%\AION 2 Wingman` e **restano dopo ogni aggiornamento**.

### 💻 Requisiti
- Windows 10 o 11
- AutoHotkey v2 e l'OCR inglese di Windows (li installa il setup)
- Client di AION 2 in inglese (per il Field Boss)

### 📦 Installazione
1. Scarica **`AION-2-Wingman.zip`** dall'[ultima release](../../releases/latest).
2. Tasto destro sullo zip > **Proprietà** > spunta **Annulla blocco** > OK. Così eviti gli avvisi di Windows.
3. Estrailo in una **cartella fissa**, ad esempio `Documenti\AION 2 Wingman`. Non avviarlo da dentro lo zip.
4. Doppio click su **`Setup AION 2 Wingman.bat`** e accetta la richiesta di amministratore. Controlla e installa ciò che manca, poi ti guida in lingua, risoluzione, prestazioni, tema e funzioni. Può anche creare un collegamento sul desktop.
5. Da lì in poi avvia **`AION 2 Wingman.ahk`** o il collegamento.

### ⌨️ Tasti predefiniti
| Tasti | Azione |
|---|---|
| `Ctrl+Shift+\` | HUD overlay ON/OFF |
| `Ctrl+Shift+1` | Hidden Cube ON/OFF |
| `Ctrl+Shift+2` | Field Boss ON/OFF |
| `Ctrl+Shift+F12` | Impostazioni (anche fuori dal gioco) |
| `Esc` | Annulla la guida del Field Boss |
| `M` / `F` | Tasti Mappa / Travel del gioco (Wingman li "ascolta") |
| `F9` / `F10` | Segnali delle macro per l'HUD |

Tutti i tasti si cambiano in Impostazioni > Tasti.

### 🎮 Collegare le macro all'HUD
- **Macro di combat**: `F9` in spam per tutta la macro.
- **Macro di loot**: inserisci `F10` con un wait di 1350 ms.

I tasti arrivano comunque al gioco.

### ❓ Domande frequenti
- **In gioco non succede nulla:** Wingman funziona solo con `AION2.exe` in primo piano. Controlla l'icona verde "H" nella barra di Windows.
- **Field Boss "non disponibile":** manca `OCR.ahk` o l'OCR inglese di Windows. Rilancia il setup.
- **HUD troppo grande o piccolo:** applica il preset di risoluzione giusto nelle Impostazioni.
- **Avviso dell'antivirus:** è un falso positivo comune con gli script AutoHotkey. Aggiungi la cartella alle esclusioni.

---

## 🇪🇸 Español

**AION 2 Wingman** es un programa para Windows escrito en **AutoHotkey v2**. Funciona junto a AION 2 y te da un HUD más claro y algunas ayudas inteligentes.

> **AION 2 Wingman nunca hace clic ni pulsa teclas por ti en el juego.** Dibuja en pantalla, lleva el cursor al punto correcto y te dice qué hacer: cada clic es tuyo.

### ✨ Funciones
- **🎯 HUD overlay:**
  - mira, dos barras e iconos **LOOT** / **COMBAT** que se encienden con las señales de tus macros (F9 / F10);
  - cada icono tiene su forma, tamaño, posición, textos, emoji y efectos animados, y puede reflejar al otro;
  - textos y emoji se ajustan solos a la forma del icono.
- **👑 Field Boss:**
  - panel con todos los jefes en el mapa, con grado, estado y filtros;
  - **guía paso a paso** hasta el Teleport más cercano y **dirección de vuelo** después del Travel;
  - el panel se oculta en las **mazmorras**.
- **🧊 Hidden Cube:** lleva el ratón a "Open with Key" cuando se abre la ventana.
- **⚙️ Ajustes** (Ctrl+Shift+F12):
  - búsqueda, **vista previa en vivo**, presets de resolución (FullHD / 2K / 4K), perfiles de rendimiento y presets propios;
  - menú Mantenimiento y botón **Cerrar Wingman**;
  - **12 idiomas**.
- **🎨 Temas:**
  - **22 temas listos**: clásicos, **8 de clase de AION 2** y **7 de eventos** (Halloween, Navidad, Año Nuevo, San Valentín, Carnaval, Pascua y San Patricio);
  - **Editor de temas**: *Personalizar este tema* crea tu copia "… Custom", editable en cada detalle.
- **🔄 Actualizaciones:** comprueba e instala las nuevas releases sin interrumpirte mientras juegas. Tus ajustes, presets y temas (`%AppData%\AION 2 Wingman`) **se mantienen**.

### 💻 Requisitos
- Windows 10 u 11
- AutoHotkey v2 y el OCR inglés de Windows (los instala el setup)
- Cliente de AION 2 en inglés

### 📦 Instalación
1. Descarga **`AION-2-Wingman.zip`** de la [última release](../../releases/latest).
2. Clic derecho > **Propiedades** > marca **Desbloquear** > Aceptar.
3. Extráelo en una carpeta fija.
4. Ejecuta **`Setup AION 2 Wingman.bat`** como administrador: instala lo que falta y te guía en la primera configuración.
5. Después, inicia **`AION 2 Wingman.ahk`** o el acceso directo.

### ⌨️ Teclas predeterminadas
`Ctrl+Shift+\` HUD · `Ctrl+Shift+1` Hidden Cube · `Ctrl+Shift+2` Field Boss · `Ctrl+Shift+F12` Ajustes · `Esc` cancelar guía · `F9` / `F10` señales de las macros (combat: F9 en spam; loot: F10 con espera de 1350 ms).

---

## 🇫🇷 Français

**AION 2 Wingman** est un programme Windows écrit en **AutoHotkey v2**. Il tourne à côté d'AION 2 et t'offre un HUD plus clair et quelques aides intelligentes.

> **AION 2 Wingman ne clique jamais et n'appuie jamais sur les touches à ta place dans le jeu.** Il dessine à l'écran, place le curseur au bon endroit et te dit quoi faire : chaque clic est le tien.

### ✨ Fonctions
- **🎯 HUD overlay :**
  - viseur, deux barres et icônes **LOOT** / **COMBAT** qui s'allument avec les signaux de tes macros (F9 / F10) ;
  - chaque icône a sa forme, sa taille, sa position, ses textes, son emoji et ses effets animés, et peut se placer en miroir de l'autre ;
  - textes et emoji s'adaptent seuls à la forme.
- **👑 Field Boss :**
  - panneau de tous les boss de la carte, avec grade, état et filtres ;
  - **guide pas à pas** jusqu'au Teleport le plus proche et **direction de vol** après le Travel ;
  - le panneau est masqué dans les **donjons**.
- **🧊 Hidden Cube :** place la souris sur "Open with Key" quand la fenêtre s'ouvre.
- **⚙️ Paramètres** (Ctrl+Shift+F12) :
  - recherche, **aperçu en direct**, presets de résolution (FullHD / 2K / 4K), profils de performance et presets perso ;
  - menu Maintenance et bouton **Quitter Wingman** ;
  - **12 langues**.
- **🎨 Thèmes :**
  - **22 thèmes prêts** : classiques, **8 de classe AION 2** et **7 de fêtes** (Halloween, Noël, Nouvel An, Saint-Valentin, Carnaval, Pâques et Saint-Patrick) ;
  - **Éditeur de thèmes** : *Personnaliser ce thème* crée ta copie "… Custom", modifiable dans les moindres détails.
- **🔄 Mises à jour :** vérifie et installe les nouvelles releases sans jamais te déranger en jeu. Tes paramètres, presets et thèmes (`%AppData%\AION 2 Wingman`) **sont conservés**.

### 💻 Configuration requise
- Windows 10 ou 11
- AutoHotkey v2 et l'OCR anglais de Windows (installés par le setup)
- Client AION 2 en anglais

### 📦 Installation
1. Télécharge **`AION-2-Wingman.zip`** depuis la [dernière release](../../releases/latest).
2. Clic droit > **Propriétés** > coche **Débloquer** > OK.
3. Extrais-le dans un dossier fixe.
4. Lance **`Setup AION 2 Wingman.bat`** en administrateur : il installe ce qui manque et te guide dans la première configuration.
5. Ensuite, lance **`AION 2 Wingman.ahk`** ou le raccourci.

### ⌨️ Touches par défaut
`Ctrl+Shift+\` HUD · `Ctrl+Shift+1` Hidden Cube · `Ctrl+Shift+2` Field Boss · `Ctrl+Shift+F12` Paramètres · `Esc` annuler le guide · `F9` / `F10` signaux des macros (combat : F9 en spam ; loot : F10 avec une attente de 1350 ms).

---

## 🇩🇪 Deutsch

**AION 2 Wingman** ist ein Windows-Programm in **AutoHotkey v2**. Es läuft neben AION 2 und bietet ein klareres HUD sowie einige smarte Helfer.

> **AION 2 Wingman klickt und drückt im Spiel niemals Tasten für dich.** Es zeichnet auf den Bildschirm, bringt den Cursor an die richtige Stelle und sagt dir, was zu tun ist: Jeder Klick ist deiner.

### ✨ Funktionen
- **🎯 HUD-Overlay:**
  - Fadenkreuz, zwei Balken und **LOOT**- / **COMBAT**-Symbole, die durch die Signale deiner Makros (F9 / F10) aufleuchten;
  - jedes Symbol hat eigene Form, Größe, Position, Texte, Emoji und animierte Effekte und kann das andere spiegeln;
  - Text und Emoji passen sich der Form selbst an.
- **👑 Field Boss:**
  - Panel mit allen Bossen auf der Karte, mit Grad, Status und Filtern;
  - **Schritt-für-Schritt-Führung** zum nächsten Teleport und **Flugrichtung** nach dem Travel;
  - in **Dungeons** bleibt das Panel ausgeblendet.
- **🧊 Hidden Cube:** bringt die Maus auf "Open with Key", sobald sich das Fenster öffnet.
- **⚙️ Einstellungen** (Ctrl+Shift+F12):
  - Suche, **Live-Vorschau**, Auflösungs-Presets (FullHD / 2K / 4K), Leistungsprofile und eigene Presets;
  - Wartungsmenü und Knopf **Wingman beenden**;
  - **12 Sprachen**.
- **🎨 Designs:**
  - **22 fertige Designs**: Klassiker, **8 AION-2-Klassen** und **7 Feiertage** (Halloween, Weihnachten, Neujahr, Valentinstag, Karneval, Ostern und St. Patrick's Day);
  - **Design-Editor**: *Dieses Design anpassen* erstellt deine eigene Kopie "… Custom", die du in jedem Detail ändern kannst.
- **🔄 Updates:** prüft und installiert neue Releases, ohne dich beim Spielen zu stören. Einstellungen, Presets und Designs (`%AppData%\AION 2 Wingman`) **bleiben erhalten**.

### 💻 Voraussetzungen
- Windows 10 oder 11
- AutoHotkey v2 und die englische Windows-OCR (installiert das Setup)
- Englischer AION-2-Client

### 📦 Installation
1. **`AION-2-Wingman.zip`** aus der [neuesten Release](../../releases/latest) herunterladen.
2. Rechtsklick > **Eigenschaften** > **Zulassen** anhaken > OK.
3. In einen festen Ordner entpacken.
4. **`Setup AION 2 Wingman.bat`** als Administrator starten: Es installiert Fehlendes und führt durch die Ersteinrichtung.
5. Danach **`AION 2 Wingman.ahk`** oder die Verknüpfung starten.

### ⌨️ Standardtasten
`Ctrl+Shift+\` HUD · `Ctrl+Shift+1` Hidden Cube · `Ctrl+Shift+2` Field Boss · `Ctrl+Shift+F12` Einstellungen · `Esc` Führung abbrechen · `F9` / `F10` Makro-Signale (Kampf: F9 dauerhaft drücken; Loot: F10 mit 1350 ms Wartezeit).

---

## 🇧🇷 Português

**AION 2 Wingman** é um programa para Windows escrito em **AutoHotkey v2**. Ele roda junto com o AION 2 e oferece um HUD mais claro e algumas ajudas inteligentes.

> **O AION 2 Wingman nunca clica nem aperta teclas por você no jogo.** Ele desenha na tela, leva o cursor ao ponto certo e diz o que fazer: cada clique é seu.

### ✨ Funções
- **🎯 HUD overlay:**
  - mira, duas barras e ícones **LOOT** / **COMBAT** que acendem com os sinais das suas macros (F9 / F10);
  - cada ícone tem forma, tamanho, posição, textos, emoji e efeitos animados próprios, e pode espelhar o outro;
  - textos e emoji se ajustam sozinhos à forma.
- **👑 Field Boss:**
  - painel com todos os chefes do mapa, com grau, estado e filtros;
  - **guia passo a passo** até o Teleport mais próximo e **direção de voo** após o Travel;
  - o painel fica oculto nas **masmorras**.
- **🧊 Hidden Cube:** leva o mouse até "Open with Key" quando a janela abre.
- **⚙️ Configurações** (Ctrl+Shift+F12):
  - busca, **prévia ao vivo**, presets de resolução (FullHD / 2K / 4K), perfis de desempenho e presets próprios;
  - menu Manutenção e botão **Encerrar Wingman**;
  - **12 idiomas**.
- **🎨 Temas:**
  - **22 temas prontos**: clássicos, **8 de classe do AION 2** e **7 de datas comemorativas** (Halloween, Natal, Ano Novo, Dia dos Namorados, Carnaval, Páscoa e Dia de São Patrício);
  - **Editor de temas**: *Personalizar este tema* cria a sua cópia "… Custom", editável em cada detalhe.
- **🔄 Atualizações:** verifica e instala as novas releases sem atrapalhar enquanto você joga. Configurações, presets e temas (`%AppData%\AION 2 Wingman`) **são mantidos**.

### 💻 Requisitos
- Windows 10 ou 11
- AutoHotkey v2 e o OCR em inglês do Windows (instalados pelo setup)
- Cliente do AION 2 em inglês

### 📦 Instalação
1. Baixe **`AION-2-Wingman.zip`** da [última release](../../releases/latest).
2. Botão direito > **Propriedades** > marque **Desbloquear** > OK.
3. Extraia em uma pasta fixa.
4. Execute **`Setup AION 2 Wingman.bat`** como administrador: ele instala o que falta e guia a primeira configuração.
5. Depois, abra **`AION 2 Wingman.ahk`** ou o atalho.

### ⌨️ Teclas padrão
`Ctrl+Shift+\` HUD · `Ctrl+Shift+1` Hidden Cube · `Ctrl+Shift+2` Field Boss · `Ctrl+Shift+F12` Configurações · `Esc` cancelar guia · `F9` / `F10` sinais das macros (combate: F9 em spam; loot: F10 com espera de 1350 ms).

---

## 🇷🇺 Русский

**AION 2 Wingman** — программа для Windows на **AutoHotkey v2**. Она работает рядом с AION 2 и добавляет понятный HUD и несколько умных помощников.

> **AION 2 Wingman никогда не кликает и не нажимает клавиши за вас в игре.** Он рисует на экране, переносит курсор в нужную точку и подсказывает, что делать: каждый клик — ваш.

### ✨ Возможности
- **🎯 HUD-оверлей:**
  - прицел, две полосы и значки **LOOT** / **COMBAT**, которые загораются по сигналам ваших макросов (F9 / F10);
  - у каждого значка своя форма, размер, позиция, текст, эмодзи и анимированные эффекты; значки могут располагаться зеркально друг к другу;
  - текст и эмодзи сами подстраиваются под форму значка.
- **👑 Field Boss:**
  - панель со всеми боссами на карте: грейд, статус и фильтры;
  - **пошаговая подсказка** до ближайшего Teleport и **направление полёта** после Travel;
  - в **подземельях** панель скрыта.
- **🧊 Hidden Cube:** когда открывается окно, переносит мышь на «Open with Key».
- **⚙️ Настройки** (Ctrl+Shift+F12):
  - поиск, **живой предпросмотр**, пресеты разрешения (FullHD / 2K / 4K), профили производительности и свои пресеты;
  - меню «Обслуживание» и кнопка **Выйти из Wingman**;
  - **12 языков**.
- **🎨 Темы:**
  - **22 готовые темы**: классические, **8 классов AION 2** и **7 праздничных** (Хэллоуин, Рождество, Новый год, День святого Валентина, Карнавал, Пасха и День святого Патрика);
  - **Редактор тем**: кнопка «Настроить эту тему» создаёт вашу копию «… Custom», которую можно менять до мелочей.
- **🔄 Обновления:** проверяет и устанавливает новые релизы, не мешая игре. Настройки, пресеты и темы (`%AppData%\AION 2 Wingman`) **сохраняются**.

### 💻 Требования
- Windows 10 или 11
- AutoHotkey v2 и английский OCR Windows (их ставит setup)
- Клиент AION 2 на английском

### 📦 Установка
1. Скачайте **`AION-2-Wingman.zip`** из [последнего релиза](../../releases/latest).
2. Правый клик > **Свойства** > отметьте **Разблокировать** > OK.
3. Распакуйте в постоянную папку.
4. Запустите **`Setup AION 2 Wingman.bat`** от имени администратора: он установит недостающее и проведёт через первую настройку.
5. Дальше запускайте **`AION 2 Wingman.ahk`** или ярлык.

### ⌨️ Клавиши по умолчанию
`Ctrl+Shift+\` HUD · `Ctrl+Shift+1` Hidden Cube · `Ctrl+Shift+2` Field Boss · `Ctrl+Shift+F12` Настройки · `Esc` отменить подсказку · `F9` / `F10` сигналы макросов (бой: спам F9; лут: F10 с ожиданием 1350 мс).

---

## 🇰🇷 한국어

**AION 2 Wingman**은 **AutoHotkey v2**로 만든 Windows 프로그램입니다. AION 2와 함께 실행되며 더 보기 쉬운 HUD와 몇 가지 똑똑한 보조 기능을 제공합니다.

> **AION 2 Wingman은 게임에서 대신 클릭하거나 키를 누르지 않습니다.** 화면에 표시하고, 커서를 알맞은 위치로 옮기고, 할 일을 알려 줄 뿐입니다. 클릭은 모두 직접 합니다.

### ✨ 기능
- **🎯 HUD 오버레이:**
  - 조준선, 두 개의 바, 매크로 신호(F9 / F10)에 맞춰 켜지는 **LOOT** / **COMBAT** 아이콘;
  - 아이콘마다 모양, 크기, 위치, 텍스트, 이모지, 애니메이션 효과를 따로 정할 수 있고, 서로 대칭으로 배치할 수도 있습니다;
  - 텍스트와 이모지가 아이콘 모양에 자동으로 맞춰집니다.
- **👑 Field Boss:**
  - 지도에 모든 보스를 등급, 상태, 필터와 함께 보여 주는 패널;
  - 가장 가까운 Teleport까지 **단계별 안내**, Travel 후에는 **비행 방향** 표시;
  - **던전**에서는 패널이 나타나지 않습니다.
- **🧊 Hidden Cube:** 창이 열리면 마우스를 "Open with Key"로 옮깁니다.
- **⚙️ 설정** (Ctrl+Shift+F12):
  - 검색, **실시간 미리보기**, 해상도 프리셋(FullHD / 2K / 4K), 성능 프로필, 나만의 프리셋;
  - 유지 관리 메뉴와 **Wingman 종료** 버튼;
  - **12개 언어**.
- **🎨 테마:**
  - **22가지 기본 테마**: 클래식, **AION 2 클래스 8종**, **이벤트 7종**(할로윈, 크리스마스, 새해, 밸런타인데이, 카니발, 부활절, 성 패트릭의 날);
  - **테마 편집기**: "이 테마 꾸미기"를 누르면 모든 부분을 바꿀 수 있는 "… Custom" 복사본이 만들어집니다.
- **🔄 업데이트:** 게임 중에는 방해하지 않고 새 릴리스를 확인·설치합니다. 설정, 프리셋, 테마(`%AppData%\AION 2 Wingman`)는 **그대로 유지**됩니다.

### 💻 요구 사항
- Windows 10 또는 11
- AutoHotkey v2와 Windows 영어 OCR (설치 프로그램이 설치)
- 영어 AION 2 클라이언트

### 📦 설치
1. [최신 릴리스](../../releases/latest)에서 **`AION-2-Wingman.zip`**을 받습니다.
2. 우클릭 > **속성** > **차단 해제** 체크 > 확인.
3. 고정된 폴더에 압축을 풉니다.
4. **`Setup AION 2 Wingman.bat`**을 관리자 권한으로 실행합니다. 없는 구성 요소를 설치하고 첫 설정을 안내합니다.
5. 이후에는 **`AION 2 Wingman.ahk`** 또는 바로 가기로 실행합니다.

### ⌨️ 기본 키
`Ctrl+Shift+\` HUD · `Ctrl+Shift+1` Hidden Cube · `Ctrl+Shift+2` Field Boss · `Ctrl+Shift+F12` 설정 · `Esc` 안내 취소 · `F9` / `F10` 매크로 신호 (전투: F9 반복 입력, 루팅: F10 후 1350 ms 대기).

---

## 🇨🇳 简体中文

**AION 2 Wingman** 是一个用 **AutoHotkey v2** 编写的 Windows 程序，与 AION 2 同时运行，提供更清晰的 HUD 和一些实用的辅助功能。

> **AION 2 Wingman 绝不会替你在游戏中点击或按键。** 它只在屏幕上显示内容、把光标移到正确位置并提示你该做什么：每一次点击都由你完成。

### ✨ 功能
- **🎯 HUD 叠加层：**
  - 准星、两条横条，以及随宏信号（F9 / F10）点亮的 **LOOT** / **COMBAT** 图标；
  - 每个图标都有独立的形状、大小、位置、文字、表情和动画效果，也可以与另一个图标镜像对称；
  - 文字和表情会自动适配图标形状。
- **👑 Field Boss：**
  - 地图上显示所有首领的面板，带品级、状态和筛选；
  - **分步引导**你到最近的 Teleport，Travel 后显示**飞行方向**；
  - 在**副本**中面板不会出现。
- **🧊 Hidden Cube：** 窗口打开时把鼠标移到 "Open with Key"。
- **⚙️ 设置**（Ctrl+Shift+F12）：
  - 搜索、**实时预览**、分辨率预设（FullHD / 2K / 4K）、性能配置和自定义预设；
  - 维护菜单和**退出 Wingman**按钮；
  - **12 种语言**。
- **🎨 主题：**
  - **22 个预设主题**：经典主题、**8 个 AION 2 职业主题**和 **7 个节日主题**（万圣节、圣诞节、新年、情人节、狂欢节、复活节、圣帕特里克节）；
  - **主题编辑器**："自定义此主题"会生成你自己的 "… Custom" 副本，每个细节都能修改。
- **🔄 更新：** 检查并安装新版本，游戏时绝不打扰。设置、预设和主题（`%AppData%\AION 2 Wingman`）**会被保留**。

### 💻 系统要求
- Windows 10 或 11
- AutoHotkey v2 和 Windows 英语 OCR（由安装程序安装）
- 英文版 AION 2 客户端

### 📦 安装
1. 从[最新发布](../../releases/latest)下载 **`AION-2-Wingman.zip`**。
2. 右键 > **属性** > 勾选**解除锁定** > 确定。
3. 解压到固定文件夹。
4. 以管理员身份运行 **`Setup AION 2 Wingman.bat`**：它会安装缺少的组件并引导首次设置。
5. 之后运行 **`AION 2 Wingman.ahk`** 或快捷方式。

### ⌨️ 默认按键
`Ctrl+Shift+\` HUD · `Ctrl+Shift+1` Hidden Cube · `Ctrl+Shift+2` Field Boss · `Ctrl+Shift+F12` 设置 · `Esc` 取消引导 · `F9` / `F10` 宏信号（战斗：连续按 F9；拾取：F10 后等待 1350 毫秒）。

---

## 🇯🇵 日本語

**AION 2 Wingman** は **AutoHotkey v2** で作られた Windows プログラムです。AION 2 と一緒に動き、見やすい HUD と便利な補助機能を追加します。

> **AION 2 Wingman はゲーム内であなたの代わりにクリックやキー入力をしません。** 画面に表示し、カーソルを正しい位置に動かし、やることを案内するだけです。クリックはすべてご自身で。

### ✨ 機能
- **🎯 HUD オーバーレイ：**
  - 照準、2 本のバー、マクロの信号（F9 / F10）で点灯する **LOOT** / **COMBAT** アイコン；
  - アイコンごとに形・サイズ・位置・テキスト・絵文字・アニメーション効果を個別に設定でき、左右対称にもできます；
  - テキストと絵文字はアイコンの形に自動で収まります。
- **👑 Field Boss：**
  - マップ上の全ボスをグレード・状態・フィルター付きで表示するパネル；
  - 最寄りの Teleport までの**手順ガイド**と、Travel 後の**飛行方向**；
  - **ダンジョン**ではパネルを表示しません。
- **🧊 Hidden Cube：** ウィンドウが開くとマウスを「Open with Key」へ移動します。
- **⚙️ 設定**（Ctrl+Shift+F12）：
  - 検索、**ライブプレビュー**、解像度プリセット（FullHD / 2K / 4K）、パフォーマンスプロファイル、自作プリセット；
  - メンテナンスメニューと **Wingman を終了** ボタン；
  - **12 言語**。
- **🎨 テーマ：**
  - **22 種類の既成テーマ**：定番、**AION 2 のクラス 8 種**、**イベント 7 種**（ハロウィン、クリスマス、お正月、バレンタイン、カーニバル、イースター、聖パトリックの日）；
  - **テーマエディター**：「このテーマをカスタマイズ」で、細部まで変更できる自分のコピー「… Custom」が作られます。
- **🔄 アップデート：** プレイ中は邪魔せずに新しいリリースを確認・インストールします。設定・プリセット・テーマ（`%AppData%\AION 2 Wingman`）は**そのまま残ります**。

### 💻 動作環境
- Windows 10 または 11
- AutoHotkey v2 と Windows の英語 OCR（セットアップがインストール）
- 英語版 AION 2 クライアント

### 📦 インストール
1. [最新リリース](../../releases/latest)から **`AION-2-Wingman.zip`** をダウンロード。
2. 右クリック > **プロパティ** > **許可する** にチェック > OK。
3. 固定のフォルダーに展開。
4. **`Setup AION 2 Wingman.bat`** を管理者として実行：足りないものをインストールし、初期設定を案内します。
5. 以降は **`AION 2 Wingman.ahk`** またはショートカットで起動。

### ⌨️ 既定のキー
`Ctrl+Shift+\` HUD · `Ctrl+Shift+1` Hidden Cube · `Ctrl+Shift+2` Field Boss · `Ctrl+Shift+F12` 設定 · `Esc` ガイドを取消 · `F9` / `F10` マクロ信号（戦闘：F9 を連打、ルート：F10 のあと 1350 ms 待機）。

---

<div align="center">

**AION 2 Wingman** — by VaLeTecK

OCR.ahk by [Descolada](https://github.com/Descolada/OCR) · Built with [AutoHotkey v2](https://www.autohotkey.com)

<sub>AION 2 is a trademark of its respective owners. This project is not affiliated with or endorsed by them. It is a third-party tool: use it at your own risk and within the game's terms of service.</sub>

</div>
