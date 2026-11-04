# Changelog

Ogni versione ha la sua sezione `## vX.Y` (in inglese e italiano): se la descrizione della release
è vuota, l'automazione la riempie con questo testo, che Wingman mostra come "Novità".
A ogni release l'automazione aggiunge anche il link alla scansione VirusTotal del pacchetto.

## v1.11

### 🇬🇧 English
ℹ️ Includes 1.10, merged for technical reasons.

- 🎓 **Settings tour** – A tour guides you through the Settings. It is interactive and starts the first time you open them: a dark veil leaves only the explained area lit, with a glowing border and a balloon that tells you what it does; in some steps you try it yourself (switch mode, turn on the preview, search, pick a section or a setting) and the tour moves on by itself once you have done it. You can skip it at any time and take it again from Maintenance.
- 🗺️ **Map tour** – A short tour explains the Field Boss panel. It starts the first time you open the map: a glowing border and a balloon show the boss list, the grade filters and the key legend, then explain the two Teleport modes (NORMAL MODE and ULTRA-FAST MODE, with the active one marked) and offer the quick ULTRA-FAST preparation; it ends when you click your first boss, and you can take it again from Maintenance.
- ⚡ **ULTRA-FAST preparation** – Wingman stars your main bosses' Teleports. It puts them in the game's favorites: it checks which ones are already starred, finds the others in the Kibelisk list by itself and only asks you to click the grey star, keeping mouse and clicks locked everywhere else; then it checks that the star turned gold and ends with a summary. Once you pick a boss in ULTRA-FAST MODE you can also safely spam left click and F until the Teleport is done.
- 🔔 **Updates at startup** – Wingman checks for updates as soon as it starts. If there is one it tells you right away: during the game with a small notice at the bottom right (with "Update now" and "What's new") that does not steal focus from the game, otherwise with the usual window, or it installs it by itself in automatic mode.
- 🗂️ **Grouped menu** – The menu is now split into groups. Dividers separate main settings, features and service pages (updates, maintenance), so you find things faster; they cannot be selected and the arrow keys skip them.
- 📖 **Quick guide after setup** – It opens when the setup ends. It is the "How to use" infographic in your language, with the keys for the HUD and the first steps; you can also open it from Maintenance and from the last step of the tour.
- 🎲 **Truly random numbers** – Numbers now come from Windows' crypto generator. It is the same source used for security keys, unpredictable and without patterns, and every number (or every combination, with more numbers per roll) has exactly the same chance of coming out.
- 🧭 **Kashapa to the north** – Its flight arrow now always points north. Reading the direction from the map got this boss wrong, so the direction is now fixed, even if your saved boss list still says "auto".
- 🎲 **Right-sized die** – The icon now always fits your screen. If Wingman started while the game window was still small (launcher or loading), the icon stayed tiny; now it is rebuilt at the current size every time it appears.
- 🎲 **Die only on the cards** – No more die on other dark screens. The card screen is now recognized only when 3 to 6 cards of the same width, evenly spaced and centered, sit on the black background, and the icon disappears as soon as they are gone.

### 🇮🇹 Italiano
ℹ️ Include la 1.10, unita per motivi tecnici.

- 🎓 **Tour delle Impostazioni** – Un tour ti guida nelle Impostazioni. È interattivo e parte la prima volta che le apri: un velo scuro lascia illuminata solo la zona spiegata, con un bordo luminoso e un fumetto che dice a cosa serve; in alcuni passi provi tu (cambi modalità, accendi l'anteprima, cerchi, scegli una sezione o un'impostazione) e il tour va avanti da solo quando l'hai fatto. Puoi saltarlo quando vuoi e rifarlo da Manutenzione.
- 🗺️ **Tour della mappa** – Un breve tour spiega il pannello Field Boss. Parte la prima volta che apri la mappa: un bordo luminoso e un fumetto mostrano l'elenco dei boss, i filtri dei gradi e la leggenda dei tasti, poi spiegano le due modalità di Teleport (NORMAL MODE e ULTRA-FAST MODE, con quella attiva segnata) e propongono la preparazione accelerata della ULTRA-FAST; finisce quando clicchi il tuo primo boss, e si rifà da Manutenzione.
- ⚡ **Preparazione ULTRA-FAST** – Wingman mette nei preferiti i Teleport dei boss principali. Controlla quali hanno già la stellina, trova gli altri da solo nella lista Kibelisk e ti chiede solo il click sulla stellina grigia, tenendo mouse e click bloccati altrove; poi verifica che sia diventata dorata e chiude con un riepilogo. Scelto un boss in ULTRA-FAST MODE puoi anche spammare tranquillamente click sinistro e F fino a Teleport compiuto.
- 🔔 **Aggiornamenti all'avvio** – Wingman cerca aggiornamenti appena si avvia. Se c'è te lo dice subito: durante il gioco con un piccolo avviso in basso a destra (con "Aggiorna ora" e "Cosa c'è di nuovo") che non toglie il focus al gioco, altrimenti con la solita finestra, oppure la installa da solo in modalità automatica.
- 🗂️ **Menu a gruppi** – Il menu ora è diviso in gruppi. I divisori separano impostazioni principali, funzioni e pagine di servizio (aggiornamenti, manutenzione), così trovi tutto prima; non si selezionano e le frecce della tastiera li saltano.
- 📖 **Guida rapida a fine setup** – Si apre a fine setup. È l'infografica "Come si usa" nella tua lingua, con i tasti per l'HUD e i primi passi; la apri anche da Manutenzione e dall'ultimo passo del tour.
- 🎲 **Numeri davvero casuali** – Ora vengono dal generatore crittografico di Windows. È la stessa fonte usata per le chiavi di sicurezza, imprevedibile e senza schemi, e ogni numero (o ogni combinazione, con più numeri per tiro) ha esattamente la stessa probabilità di uscire.
- 🧭 **Kashapa sempre a nord** – La sua freccia di volo ora indica sempre il nord. La lettura della direzione dalla mappa sbagliava questo boss, quindi la direzione ora è fissa, anche se l'elenco boss salvato dice ancora "auto".
- 🎲 **Dado della misura giusta** – L'icona ora ha sempre la misura giusta. Se Wingman partiva quando la finestra del gioco era ancora piccola (launcher o caricamento), l'icona restava minuscola; ora viene rifatta alla misura attuale ogni volta che compare.
- 🎲 **Dado solo sulle carte** – Niente più dado su altre schermate scure. La schermata delle carte ora viene riconosciuta solo quando sullo sfondo nero ci sono da 3 a 6 carte della stessa larghezza, a distanza regolare e centrate, e l'icona sparisce appena non ci sono più.

## v1.09

### 🇬🇧 English
- ↶ **EDIT OVERLAY: undo, redo and layouts** – Every move in the editor can now be undone and redone. "↶ Undo" / "↷ Redo" (or Ctrl+Z / Ctrl+Y) walk through the history of the editing session; the "📐 Layout" menu lists your saved layouts, saves the current one under the name you choose as an "A2W_name.ini" file in the HUD LAYOUTS folder, and opens that folder so you can share layouts or drop in someone else's.
- ✥ **Movable toolbar** – The EDIT OVERLAY toolbar can be dragged anywhere on the screen. It remembers where you left it, so it never covers the part of the HUD you are working on.
- 🎲 **Multiple random numbers** – A single roll can now draw from 1 to 4 numbers at once. The new "Numbers per roll" setting (RandomCount) picks how many, always all different from each other, shown side by side in the order they came out.
- 🧲 **Gentler snap** – Elements follow the mouse freely and snap only near the grid lines. The snap now works like a magnet that grabs only when you pass close to a line, instead of locking the element to the grid at every step.
- ☄️ **Bar effects** – The bars now have animated effects in ON state too. They are mirrored, both halves pointing toward the center: light trails with a spark at the head ("comet", on by default), a halo breathing around the bars ("pulse") or the bar lighting up intermittently ("glow"); they can be combined, and speed and color are adjustable in Settings > HUD overlay > Bars.
- 🧭 **Direction of the new boss** – Picking another boss replaces the old flight direction right away. If you teleport to a boss and quickly move on to another one, the arrow of the previous boss disappears as soon as you choose the new one and only the new direction is shown.
- 🎲 **More reliable die icon** – The die now shows up every time on the Shugo reward cards. Wingman recognizes the card screen from two lines of pixels (the black background above the cards and the cards themselves), without waiting for text to be read; the text reading stays only as a backup, and the check remains very light.

### 🇮🇹 Italiano
- ↶ **EDIT OVERLAY: annulla, ripeti e layout** – Ogni spostamento nell'editor ora si può annullare e ripetere. "↶ Indietro" / "↷ Avanti" (o Ctrl+Z / Ctrl+Y) percorrono lo storico della sessione di modifica; il menu "📐 Layout" elenca i layout salvati, salva quello attuale col nome che scegli come file "A2W_nome.ini" nella cartella HUD LAYOUTS, e apre quella cartella per condividere i layout o aggiungerne di altri.
- ✥ **Barra spostabile** – La barra degli strumenti di EDIT OVERLAY si può trascinare in qualsiasi punto dello schermo. Ricorda dove l'hai lasciata, così non copre mai la parte dell'HUD su cui stai lavorando.
- 🎲 **Più numeri random** – Un solo tiro ora può estrarre da 1 a 4 numeri insieme. La nuova impostazione "Numeri per tiro" (RandomCount) sceglie quanti, sempre diversi tra loro, mostrati affiancati nell'ordine in cui sono usciti.
- 🧲 **Snap più morbido** – Gli elementi seguono liberamente il mouse e si agganciano solo vicino alle linee della griglia. Lo snap ora funziona come una calamita che afferra solo quando passi vicino a una linea, invece di bloccare l'elemento sulla griglia a ogni passo.
- ☄️ **Effetti delle barre** – Ora anche le barre hanno effetti animati nello stato ON. Sono speculari, con le due metà che puntano verso il centro: scie luminose con una scintilla in testa ("comet", acceso di default), alone che respira attorno alle barre ("pulse") oppure la barra che si illumina a intermittenza ("glow"); si possono combinare, e velocità e colore si regolano in Impostazioni > HUD overlay > Barre.
- 🧭 **Direzione del nuovo boss** – Scegliendo un altro boss la vecchia direzione di volo viene sostituita subito. Se ti teletrasporti da un boss e poco dopo passi a un altro, la freccia del boss precedente sparisce appena scegli il nuovo e compare solo la nuova direzione.
- 🎲 **Icona del dado più affidabile** – Il dado ora compare ogni volta sulle carte premio degli Shugo. Wingman riconosce la schermata delle carte da due righe di pixel (lo sfondo nero sopra le carte e le carte stesse), senza aspettare la lettura del testo; la lettura del testo resta solo come riserva, e il controllo rimane leggerissimo.

## v1.08

### 🇬🇧 English
- ✥ **EDIT OVERLAY** – Move the on-screen elements by dragging them. Press "✥ Edit" in the live preview box of Settings: a colored handle appears on the crosshair, bars, Loot and Combat icons, Field Boss panel, key legend, instructions, flight arrow, random number and its icon; drag them where you want and the matching settings update by themselves. A see-through guide grid (square size adjustable in px) and a Snap switch help you line everything up. "Done" (or Esc) keeps the changes to save, "Cancel" puts everything back.
- 🖼️ **Boss preview styles** – Choose how the boss preview appears on hover. Settings > Field Boss > General > "Boss preview style": card next to the menu (as before), just the boss silhouette, big, at the bottom center of the screen with a fade in and out (all 43 images upscaled to HD with soft edges, no hard cuts), or a wide card with level, area and main drops (loot chest, Artwork, armor set, notable materials) for all 43 bosses.
- 🦅 **Wingman icons** – Wingman has its own icons. Settings > General > "Wingman icon": five emblems with golden wings, the golden diamond and the HUD crosshair; it's used in the notification area and in the desktop shortcut, which updates by itself.
- ✨ **Logo in the splash screen** – The startup splash now shows the Wingman logo. It's recolored with your theme's accent color and floats gently inside a glowing halo, above the name.
- 🎛️ **Wingman button in the game menu** – Open Settings straight from the game menu. When you open the game menu (Esc) the Wingman icon fades in at the top right, under the X, and fades out as soon as you close it; it grows and glows under the mouse, and one click opens Settings; it can be turned off in Settings > General.
- 🔄 **Restart button** – Wingman can be restarted with one click. A small ⟳ button next to "Quit Wingman" in Settings restarts it (it asks first if there are unsaved changes).
- 🐞 **Bugs & suggestions** – Reporting a bug or sending an idea takes one click. A small "🐞 Bugs & Suggestions" button at the bottom of Settings (with a green glow on hover) and a new entry in Maintenance open the GitHub issue form.
- ⚡ **Smoother animations** – Wingman reads the screen much less often. The die icon check uses a single thin line of pixels, the text is read only on dark card-like screens and ever less often if it's not them, and the game-menu button only looks after you press Esc.
- 🧹 **Boss status removed** – The active / inactive check and its filters are gone. They were rarely useful; the map panel is simpler and Wingman no longer reads the boss list every couple of seconds while the map is open.

### 🇮🇹 Italiano
- ✥ **EDIT OVERLAY** – Sposti gli elementi a schermo trascinandoli. Premi "✥ Edit" nel riquadro dell'anteprima dal vivo delle Impostazioni: su mirino, barre, icone Loot e Combat, pannello Field Boss, leggenda dei tasti, istruzioni, freccia di volo, numero random e la sua icona compare una maniglia colorata; trascinali dove vuoi e le impostazioni corrispondenti si aggiornano da sole. Una griglia guida semitrasparente (misura dei riquadri regolabile in px) e l'interruttore Snap ti aiutano ad allineare tutto. "Fine" (o Esc) tiene le modifiche da salvare, "Annulla" rimette tutto com'era.
- 🖼️ **Stili dell'anteprima del boss** – Scegli come compare l'anteprima del boss al passaggio del mouse. Impostazioni > Field Boss > Generale > "Stile dell'anteprima del boss": scheda accanto al menu (come prima), solo la sagoma del boss, grande, in basso al centro dello schermo con dissolvenza in entrata e in uscita (tutte le 43 immagini ingrandite in HD con bordi sfumati, niente tagli netti), oppure scheda larga con livello, zona e drop principali (forziere, Artwork, set di armatura, materiali importanti) per tutti i 43 boss.
- 🦅 **Icone di Wingman** – Wingman ha le sue icone. Impostazioni > Generale > "Icona di Wingman": cinque emblemi con ali d'oro, rombo d'oro e mirino dell'HUD; si usa nell'area di notifica e nel collegamento sul desktop, che si aggiorna da solo.
- ✨ **Logo nello splash** – Lo splash all'avvio ora mostra il logo di Wingman. È ricolorato con il colore d'accento del tema e fluttua piano dentro un alone luminoso, sopra il nome.
- 🎛️ **Pulsante di Wingman nel menu del gioco** – Apri le Impostazioni direttamente dal menu del gioco. Quando apri il menu del gioco (Esc) l'icona di Wingman compare in dissolvenza in alto a destra, sotto la X, e sparisce appena lo chiudi; sotto il mouse si ingrandisce e si illumina, e un click apre le Impostazioni; si può spegnere in Impostazioni > Generale.
- 🔄 **Pulsante per riavviare** – Wingman si riavvia con un click. Un pulsantino ⟳ accanto a "Termina Wingman" nelle Impostazioni lo riavvia (chiede prima se ci sono modifiche non salvate).
- 🐞 **Bug & Consigli** – Segnalare un bug o proporre un'idea ora richiede un click. Un pulsantino "🐞 Bug & Consigli" in fondo alle Impostazioni (con alone verde al passaggio del mouse) e una nuova voce in Manutenzione aprono il modulo delle issue su GitHub.
- ⚡ **Animazioni più fluide** – Wingman legge lo schermo molto meno spesso. Il controllo per l'icona del dado usa una sola riga sottile di pixel, il testo si legge solo su schermate scure come quella delle carte e sempre più di rado se non lo sono, e il pulsante del menu del gioco guarda solo dopo Esc.
- 🧹 **Stato dei boss rimosso** – Il controllo attivo / non attivo e i suoi filtri non ci sono più. Erano poco utili; il pannello della mappa è più semplice e Wingman non rilegge più la lista dei boss ogni paio di secondi a mappa aperta.

## v1.07

### 🇬🇧 English
- ⭐ **Teleports in favorites (ULTRA-FAST)** – Your top-priority Teleports now sit at the top of the list. Wingman reads the game's Favorites (max 10, the slots in use are checked) and the star next to each Teleport: if it's grey, the first time it asks you to click it, then that Teleport is found straight away at the top with no scrolling. Teleports are chosen by boss priority (👑 > 💎 > 🔥 > ⭐); can be turned off in Settings > Field Boss > Search and Teleport.
- 🔎 **More reliable Teleport recognition** – Teleports are found even when the OCR misreads a letter. Similar letters ("ldun's" = "Idun's"), misread numbers ("S4." = 54) and names cut by the game are tolerated, the most similar row wins, and right before the click the list is read again so the ring never lands on the wrong row (e.g. after adding a favorite or while the list is still moving).
- 🎲 **Die icon only on the Shugo cards** – The die appears only on the Shugo reward cards. The rest of the time it stays out of the way (Settings > Random number > "When the icon is shown": only on the Shugo cards or always); the Ctrl+Shift+- key still works everywhere.
- 🏰 **Boss order in dungeons** – The dungeon menu shows which boss it is before the name. E.g. "(1st boss) Neglected Gadioton" … "(Final boss) Ultimate Berk"; the menu is a bit wider so the names fit.
- 🖥️ **Live preview box** – The live preview controls have their own framed menu. Switch, Elements and HUD state ON/OFF are in one place at the top of Settings; the Elements menu now stays attached under it and follows the window when you move it.
- 🧙 **FIRST RUN QUICK-SETUP** – The setup has a new name. The file is now "FIRST RUN QUICK-SETUP.bat" (the old "Setup AION 2 Wingman.bat" is removed by itself after the update); READMEs and infographics are updated.
- 🐞 **Crash fixes** – No more errors on boss hover or with the live preview. Fixed "Parameter #4 of Format requires a String" (boss preview card, Field Boss and dungeon menus) and "Hud has not been assigned a value".
- ⚡ **Lighter and faster** – Full code review with many optimizations. The boss list is read less often while the map is open, the preview card is drawn once and only fades, cached colors, texts and outlines, fewer OCR reads at the start of the Teleport search, update check never while you're playing, presets and themes saved in one go.
- 🛠️ **Smaller fixes** – Many small fixes found in the review. Boss images no longer lock the files during updates, the preview card disappears when the mouse leaves the menu, the mouse lock is kept in the Kibelisk guide, a key being recorded can no longer end up in another setting, exact numeric values typed by hand, theme colors can be typed without the window redrawing at every letter, no square flash on the click ring.

### 🇮🇹 Italiano
- ⭐ **Teleport nei preferiti (ULTRA-FAST)** – I Teleport con la priorità più alta ora stanno in cima alla lista. Wingman legge i Favorites del gioco (max 10, controlla gli slot già usati) e la stellina accanto a ogni Teleport: se è grigia, la prima volta ti chiede di cliccarla, poi quel Teleport si trova subito in cima senza scroll. I Teleport sono scelti per priorità del boss (👑 > 💎 > 🔥 > ⭐); disattivabile in Impostazioni > Field Boss > Ricerca e Teleport.
- 🔎 **Riconoscimento dei Teleport più affidabile** – I Teleport si trovano anche quando l'OCR legge male una lettera. Lettere simili ("ldun's" = "Idun's"), numeri letti male ("S4." = 54) e nomi tagliati dal gioco sono tollerati, vince la riga più simile, e subito prima del click la lista viene riletta così l'anello non finisce mai sulla riga sbagliata (es. dopo l'aggiunta ai preferiti o con la lista ancora in movimento).
- 🎲 **Icona del dado solo sulle carte Shugo** – Il dado appare solo sulle carte premio Shugo. Il resto del tempo non ingombra (Impostazioni > Numero random > "Quando si vede l'icona": solo sulle carte Shugo o sempre); il tasto Ctrl+Shift+- funziona sempre ovunque.
- 🏰 **Ordine dei boss nei dungeon** – Nel menu dei dungeon c'è il tipo di boss prima del nome. Es. "(1° boss) Neglected Gadioton" … "(Boss finale) Ultimate Berk"; il menu è un po' più largo perché i nomi ci stiano.
- 🖥️ **Riquadro dell'anteprima dal vivo** – I comandi dell'anteprima dal vivo hanno un loro menu incorniciato. Levetta, Elementi e stato HUD ON/OFF stanno insieme in alto nelle Impostazioni; il menu Elementi ora resta agganciato sotto e segue la finestra quando la sposti.
- 🧙 **FIRST RUN QUICK-SETUP** – Il setup ha un nome nuovo. Il file ora si chiama "FIRST RUN QUICK-SETUP.bat" (il vecchio "Setup AION 2 Wingman.bat" viene tolto da solo dopo l'aggiornamento); README e infografiche aggiornati.
- 🐞 **Crash risolti** – Niente più errori sull'hover dei boss o con l'anteprima dal vivo. Risolti "Parameter #4 of Format requires a String" (scheda di anteprima del boss, menu Field Boss e dungeon) e "Hud has not been assigned a value".
- ⚡ **Più leggero e veloce** – Revisione completa del codice con tante ottimizzazioni. Lista dei boss letta meno spesso a mappa aperta, scheda di anteprima disegnata una volta sola e solo sfumata, colori, testi e contorni in memoria, meno letture OCR all'inizio della ricerca del Teleport, controllo aggiornamenti mai mentre giochi, preset e temi salvati in un colpo solo.
- 🛠️ **Correzioni minori** – Tante piccole correzioni trovate nella revisione. Le immagini dei boss non bloccano più i file durante gli aggiornamenti, la scheda di anteprima sparisce quando il mouse lascia il menu, il blocco del mouse resta nella guida Kibelisk, un tasto in registrazione non può più finire in un'altra impostazione, valori numerici scritti a mano esatti, colori del tema scrivibili senza che la finestra si ridisegni a ogni lettera, niente lampo quadrato sull'anello del click.

## v1.06

### 🇬🇧 English
- 🎲 **Random number** – A big 1–5 roll on screen with an animation. Press Ctrl+Shift+- (the - key next to the period) or click the die icon: the numbers spin, slow down and the result "pops" with a glow in your theme color. Range, size, time on screen and position (bottom center-right by default) are in Settings > Random number.
- 🖱️ **Clickable random icon** – A die icon that rolls the number with one click. It shows the key combination under it, lights up when the mouse passes over it and only appears while the game is in the foreground; it can be turned off and moved anywhere from the Settings.
- 🏰 **Teleport menu in dungeons** – One click on a dungeon boss and its Teleport is ready. In Krao Cave, Draupnir, Urugugu Canyon, Vakron Sky Island, Fire Temple and Ferocious Horn Den a Field Boss-style panel lists the bosses: click one, then click the Teleport Wingman found and press F twice. Where there are alternatives (Thamon, Fire Temple) it uses the first unlocked one. Can be turned off in Settings > Field Boss > General.
- 🔒 **Locked Teleport check** – Teleports you haven't unlocked yet are recognized. Wingman reads "Bind Complete" / "Binding Incomplete" under each Teleport; in ULTRA-FAST MODE, if the boss's Teleport is still locked it switches by itself to NORMAL MODE and uses the nearest unlocked one.
- 🖼️ **Boss images** – Portraits of all 43 bosses in the menus and guides. Hovering a boss instantly shows a preview card next to the menu, with a smooth fade-in and fade-out (portrait with a glow in your theme color, name and Teleport); once you pick it, its portrait stays in the on-screen instructions and in the flight arrow. BOSSES folder; can be turned off in Settings > Field Boss > General.
- ⌨️ **Key remapping on the fly** – Click the key box and press the new combination. Every key option in Settings now has this box: the combination is recorded right away (Esc = cancel, Del = no key), no more typing codes like ^+-.
- ✨ **Hover and zoom in the menus** – Boss names light up and grow under the mouse. Works in both the Field Boss and the dungeon menus.

### 🇮🇹 Italiano
- 🎲 **Numero random** – Un numero da 1 a 5 grande a schermo, con animazione di roll. Premi Ctrl+Shift+- (il tasto - accanto al punto) o clicca l'icona del dado: i numeri girano, rallentano e il risultato "esplode" con un alone nel colore del tema. Intervallo, dimensione, durata e posizione (di default in basso al centro-destra) sono in Impostazioni > Numero random.
- 🖱️ **Icona del random cliccabile** – Un dado che tira il numero con un click. Mostra sotto la combinazione di tasti, si illumina al passaggio del mouse e compare solo con il gioco in primo piano; si può spegnere e spostare dove vuoi dalle Impostazioni.
- 🏰 **Menu Teleport nei dungeon** – Un click sul boss del dungeon e il suo Teleport è pronto. In Krao Cave, Draupnir, Urugugu Canyon, Vakron Sky Island, Fire Temple e Ferocious Horn Den un pannello in stile Field Boss elenca i boss: ne clicchi uno, poi il Teleport trovato da Wingman e premi F due volte. Dove ci sono alternative (Thamon, Fire Temple) usa il primo sbloccato. Disattivabile in Impostazioni > Field Boss > Generale.
- 🔒 **Controllo dei Teleport non sbloccati** – I Teleport non ancora sbloccati vengono riconosciuti. Wingman legge "Bind Complete" / "Binding Incomplete" sotto ogni Teleport; in ULTRA-FAST MODE, se il Teleport del boss è ancora bloccato passa da solo alla NORMAL MODE e usa quello sbloccato più vicino.
- 🖼️ **Immagini dei boss** – I ritratti di tutti i 43 boss nei menu e nelle guide. Passando il mouse su un boss compare subito accanto al menu una scheda di anteprima, con dissolvenza morbida in entrata e in uscita (ritratto con alone nel colore del tema, nome e Teleport); scelto il boss, il suo ritratto resta nelle istruzioni a schermo e nella freccia di volo. Cartella BOSSES; disattivabile in Impostazioni > Field Boss > Generale.
- ⌨️ **Rimappatura dei tasti al volo** – Clicchi il riquadro del tasto e premi la nuova combinazione. Ogni opzione dei tasti nelle Impostazioni ha ora questo riquadro: la combinazione viene registrata subito (Esc = annulla, Canc = nessun tasto), niente più codici da scrivere come ^+-.
- ✨ **Hover e zoom nei menu** – I nomi dei boss si illuminano e si ingrandiscono sotto il mouse. Vale sia nel menu Field Boss sia in quello dei dungeon.

## v1.05

### 🇬🇧 English
- 🆕 **Fast Teleport Assistant (ULTRA-FAST MODE)** – Now the default mode: click the boss in the panel, click the Teleport that Wingman has already found in the Kibelisk list, press F twice. NORMAL MODE (full guided route) can still be chosen in Settings > Field Boss > Search and Teleport.
- ⚡ **Automatic Teleport search** – Wingman scrolls the Kibelisk list by itself until it finds the boss's Teleport: 36 scrolls per step by default, adjustable in the same menu.
- 🧭 **Flight direction after the Travel** – Preset for 20 Altgard bosses; for the others it is taken from the boss icon (red or grey) nearest to the Teleport. You can set it per boss, and it applies in both modes.
- 👑 **Boss list with Teleport and Direction** – Two new fields for every boss in Settings > Field Boss > Boss list, with all Altgard reference Teleports already filled in.
- 🏠 **Mode shown in the Home** – The Field Boss card and the info line show whether ULTRA-FAST or NORMAL MODE is in use.
- 🎨 **More modern Settings** – Taller lists without grid lines, alternating rows, values in the theme color, full-row menu and themed column headers; with dark themes, scrollbars, buttons, menus and title bar are dark too.
- ✨ **Splash tied to your theme** – Accent-color glow, theme emoji, theme name and animated effects for every theme (snow, embers, hearts, confetti, fireworks, neon…); your own themes use the style of the theme they come from. One smooth animation, new defaults: size 1.04, 0 s on screen.
- 👁️ **Readable with every theme** – Values, status and messages automatically get enough contrast (e.g. the gold of "principale" on white).
- 💾 **Settings kept on every update** – Wingman carries over only the values you chose (Settings, Setup or CONFIG), everything else gets the new defaults. Fixes theme and settings going back to default after an update.
- ⚙️ **Smarter Setup** – New question for the Teleport mode; every question suggests what you already chose (your own theme too) and saves the answers as your choices.
- 📖 **Guides updated** – README and quick-guide infographics in 10 languages now cover the Fast Teleport Assistant.
- 🐞 **Update check fixed** – Long release notes could open a "PCRE execution error -21" window; the background check now never shows errors and retries later.

### 🇮🇹 Italiano
- 🆕 **Assistente Teleport veloce (ULTRA-FAST MODE)** – Ora è la modalità predefinita: click sul boss nel pannello, click sul Teleport che Wingman ha già trovato nella lista Kibelisk, F due volte. La NORMAL MODE (percorso guidato completo) si può ancora scegliere in Impostazioni > Field Boss > Ricerca e Teleport.
- ⚡ **Ricerca automatica del Teleport** – Wingman scorre da solo la lista Kibelisk finché trova il Teleport del boss: 36 scrollate per volta di default, regolabili nello stesso menu.
- 🧭 **Direzione di volo dopo il Travel** – Preimpostata per 20 boss di Altgard; per gli altri si ricava dall'icona del boss (rossa o grigia) più vicina al Teleport. Puoi impostarla per ogni boss e vale in entrambe le modalità.
- 👑 **Elenco boss con Teleport e Direzione** – Due nuovi campi per ogni boss in Impostazioni > Field Boss > Elenco boss, con tutti i Teleport di riferimento di Altgard già inseriti.
- 🏠 **Modalità visibile nella Home** – La scheda Field Boss e la riga informativa mostrano se è attiva la ULTRA-FAST o la NORMAL MODE.
- 🎨 **Impostazioni più moderne** – Elenchi più alti senza griglia, righe alternate, valori nel colore del tema, menu a riga intera e intestazioni a tema; con i temi scuri sono scuri anche barre di scorrimento, pulsanti, menu e barra del titolo.
- ✨ **Splash legato al tuo tema** – Alone nel colore d'accento, emoji e nome del tema ed effetti animati per ogni tema (neve, braci, cuori, coriandoli, fuochi d'artificio, neon…); i tuoi temi usano lo stile del tema da cui derivano. Animazione unica e fluida, nuovi valori predefiniti: dimensione 1.04, 0 s a schermo.
- 👁️ **Leggibile con ogni tema** – Valori, stato e messaggi hanno automaticamente il contrasto giusto (es. l'oro di "principale" sul bianco).
- 💾 **Impostazioni conservate a ogni aggiornamento** – Wingman porta avanti solo i valori scelti da te (Impostazioni, Setup o CONFIG), il resto prende i nuovi valori predefiniti. Risolve tema e impostazioni che tornavano ai valori di default dopo un aggiornamento.
- ⚙️ **Setup più furbo** – Nuova domanda per la modalità Teleport; ogni domanda propone quello che hai già scelto (anche un tuo tema) e salva le risposte come tue scelte.
- 📖 **Guide aggiornate** – README e infografiche della guida rapida in 10 lingue ora presentano l'Assistente Teleport veloce.
- 🐞 **Controllo aggiornamenti corretto** – Le note di rilascio lunghe potevano aprire la finestra "PCRE execution error -21"; ora il controllo in background non mostra mai errori e riprova più tardi.

## v1.04

### 🇬🇧 English
- New **Home page** in Settings: turn HUD, Hidden Cube and Field Boss on and off with one click, plus shortcuts to resolution presets, theme, keys, updates, online guide and maintenance.
- New **Basic / Advanced** switch at the top of Settings: Basic shows only the essential options (no technical names), Advanced shows every customization option. Search tells you when more results are in Advanced mode.
- Wingman now **closes by itself when you close AION 2** (on by default, can be turned off in Settings > General).
- Clearer statement everywhere: Wingman is 100% free, with no paid or hidden features; donations are entirely optional.
- Every release now links its VirusTotal scan in the release notes.

### 🇮🇹 Italiano
- Nuova pagina **Home** nelle Impostazioni: accendi e spegni HUD, Hidden Cube e Field Boss con un click, con scorciatoie a preset di risoluzione, tema, tasti, aggiornamenti, guida online e manutenzione.
- Nuovo interruttore **Base / Avanzata** in cima alle Impostazioni: Base mostra solo le opzioni essenziali (senza nomi tecnici), Avanzata tutte le opzioni di personalizzazione. La ricerca ti avvisa quando ci sono altri risultati in modalità Avanzata.
- Wingman ora **si chiude da solo quando chiudi AION 2** (attivo di default, disattivabile in Impostazioni > Generale).
- Ovunque è indicato chiaramente che Wingman è gratuito al 100%, senza funzioni a pagamento o nascoste; le donazioni sono del tutto facoltative.
- Ogni release ora collega la sua scansione VirusTotal nelle note.

## v1.03

### 🇬🇧 English
- Assisted Teleport: after you click the Teleport, the mouse stays locked for 5 seconds (movement and clicks) while you press F, so no accidental clicks before departure. Adjustable in Settings > Field Boss > Travel and direction (0 = off); Esc unlocks it right away.
- Field Boss panel: the A–Z list now has a divider with the initial letter before each group of bosses.
- Settings: buttons light up with a glow in your theme's color and zoom in slightly on hover.
- Updates: new "Check at every startup" option (on by default) in Settings > Updates.
- GTA VI countdown (vi theme): smaller and attached to the top edge of the screen.
- New PayPal and Ko-fi donation buttons (Settings bottom bar, Maintenance and tray menu): completely optional.

### 🇮🇹 Italiano
- Teleport assistito: dopo il click sul Teleport il mouse resta bloccato per 5 secondi (movimento e click) mentre premi F, così niente click accidentali prima della partenza. Regolabile in Impostazioni > Field Boss > Travel e direzione (0 = spento); Esc lo sblocca subito.
- Pannello Field Boss: nella lista A–Z c'è ora un divisorio con la lettera iniziale prima di ogni gruppo di boss.
- Impostazioni: i pulsanti si illuminano con un alone del colore del tema e si ingrandiscono leggermente al passaggio del mouse.
- Aggiornamenti: nuova opzione "Controlla a ogni avvio" (attiva di default) in Impostazioni > Aggiornamenti.
- Countdown di GTA VI (tema vi): più piccolo e attaccato al bordo superiore dello schermo.
- Nuovi pulsanti per donare con PayPal e Ko-fi (barra in basso delle Impostazioni, Manutenzione e menu dell'icona): del tutto facoltativi.

🧪 **VirusTotal**: [scan report](https://www.virustotal.com/gui/file/701897983f070662e38a667cef7255fc11575880284ac80c0df40f06fb3ccdfc/detection)

## v1.02

### 🇬🇧 English
- Fixed: turning off the live preview in Settings could stop Wingman with the error "Gui has no window" (the HUD was being rebuilt while Windows reported a window change).

### 🇮🇹 Italiano
- Corretto: spegnendo l'anteprima dal vivo nelle Impostazioni, Wingman poteva bloccarsi con l'errore "Gui has no window" (l'HUD veniva ricostruito proprio mentre Windows segnalava un cambio di finestra).

## v1.01

### 🇬🇧 English
- Automatic updates are now on by default: Wingman installs new versions by itself (never while you play) and keeps your settings.
- Updates are checked every hour, also while Wingman stays open (before: only at startup, every 12 hours).

### 🇮🇹 Italiano
- Aggiornamenti automatici attivi di default: Wingman installa da solo le nuove versioni (mai mentre giochi) e mantiene le tue impostazioni.
- Controllo degli aggiornamenti ogni ora, anche mentre Wingman resta aperto (prima: solo all'avvio, ogni 12 ore).

## v1.0

### 🇬🇧 English
- First public release of AION 2 Wingman.
- HUD overlay (crosshair, bars, separate and customizable LOOT / COMBAT icons), Hidden Cube helper, Field Boss panel with step-by-step guidance and flight direction (the panel stays hidden in dungeons).
- Settings with search, live preview, presets, performance profiles and 12 languages.
- 22 ready-made themes (AION 2 classes, events and holidays) and a Theme editor to create your own.
- Personal settings, presets and themes kept in %AppData%\AION 2 Wingman, even after updates.
- Update check and installation from GitHub.

### 🇮🇹 Italiano
- Prima versione pubblica di AION 2 Wingman.
- HUD overlay (mirino, barre, icone LOOT / COMBAT separate e personalizzabili), Hidden Cube, pannello Field Boss con guida a fasi e direzione di volo (il pannello si nasconde nei dungeon).
- Impostazioni con ricerca, anteprima dal vivo, preset, profili prestazioni e 12 lingue.
- 22 temi pronti (classi AION 2, eventi e festività) ed Editor temi per creare i propri.
- Impostazioni, preset e temi personali conservati in %AppData%\AION 2 Wingman anche dopo gli aggiornamenti.
- Controllo e installazione degli aggiornamenti da GitHub.
