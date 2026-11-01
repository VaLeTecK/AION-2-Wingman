# Changelog

Ogni versione ha la sua sezione `## vX.Y` (in inglese e italiano): se la descrizione della release
è vuota, l'automazione la riempie con questo testo, che Wingman mostra come "Novità".
A ogni release l'automazione aggiunge anche il link alla scansione VirusTotal del pacchetto.

## v1.06

### 🇬🇧 English
- 🎲 **Random number** – A big 1–5 roll on screen with an animation. Press Ctrl+Shift+- (the - key next to the period) or click the die icon: the numbers spin, slow down and the result "pops" with a glow in your theme color. Range, size, time on screen and position (bottom center-right by default) are in Settings > Random number.
- 🖱️ **Clickable random icon** – A die icon that rolls the number with one click. It shows the key combination under it, lights up when the mouse passes over it and only appears while the game is in the foreground; it can be turned off and moved anywhere from the Settings.
- 🏰 **Teleport menu in dungeons** – One click on a dungeon boss and its Teleport is ready. In Krao Cave, Draupnir, Urugugu Canyon, Vakron Sky Island, Fire Temple and Ferocious Horn Den a Field Boss-style panel lists the bosses: click one, then click the Teleport Wingman found and press F twice. Where there are alternatives (Thamon, Fire Temple) it uses the first unlocked one. Can be turned off in Settings > Field Boss > General.
- 🔒 **Locked Teleport check** – Teleports you haven't unlocked yet are recognized. Wingman reads "Bind Complete" / "Binding Incomplete" under each Teleport; in ULTRA-FAST MODE, if the boss's Teleport is still locked it switches by itself to NORMAL MODE and uses the nearest unlocked one.
- 🖼️ **Boss images** – Portraits of all 43 bosses in the menus and guides. Hovering a boss shows a preview card next to the menu (portrait with a glow in your theme color, name and Teleport); once you pick it, its portrait stays in the on-screen instructions and in the flight arrow. BOSSES folder; can be turned off in Settings > Field Boss > General.
- ⌨️ **Key remapping on the fly** – Click the key box and press the new combination. Every key option in Settings now has this box: the combination is recorded right away (Esc = cancel, Del = no key), no more typing codes like ^+-.
- ✨ **Hover and zoom in the menus** – Boss names light up and grow under the mouse. Works in both the Field Boss and the dungeon menus.

### 🇮🇹 Italiano
- 🎲 **Numero random** – Un numero da 1 a 5 grande a schermo, con animazione di roll. Premi Ctrl+Shift+- (il tasto - accanto al punto) o clicca l'icona del dado: i numeri girano, rallentano e il risultato "esplode" con un alone nel colore del tema. Intervallo, dimensione, durata e posizione (di default in basso al centro-destra) sono in Impostazioni > Numero random.
- 🖱️ **Icona del random cliccabile** – Un dado che tira il numero con un click. Mostra sotto la combinazione di tasti, si illumina al passaggio del mouse e compare solo con il gioco in primo piano; si può spegnere e spostare dove vuoi dalle Impostazioni.
- 🏰 **Menu Teleport nei dungeon** – Un click sul boss del dungeon e il suo Teleport è pronto. In Krao Cave, Draupnir, Urugugu Canyon, Vakron Sky Island, Fire Temple e Ferocious Horn Den un pannello in stile Field Boss elenca i boss: ne clicchi uno, poi il Teleport trovato da Wingman e premi F due volte. Dove ci sono alternative (Thamon, Fire Temple) usa il primo sbloccato. Disattivabile in Impostazioni > Field Boss > Generale.
- 🔒 **Controllo dei Teleport non sbloccati** – I Teleport non ancora sbloccati vengono riconosciuti. Wingman legge "Bind Complete" / "Binding Incomplete" sotto ogni Teleport; in ULTRA-FAST MODE, se il Teleport del boss è ancora bloccato passa da solo alla NORMAL MODE e usa quello sbloccato più vicino.
- 🖼️ **Immagini dei boss** – I ritratti di tutti i 43 boss nei menu e nelle guide. Passando il mouse su un boss compare accanto al menu una scheda di anteprima (ritratto con alone nel colore del tema, nome e Teleport); scelto il boss, il suo ritratto resta nelle istruzioni a schermo e nella freccia di volo. Cartella BOSSES; disattivabile in Impostazioni > Field Boss > Generale.
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
