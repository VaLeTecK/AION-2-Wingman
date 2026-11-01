# Changelog

Ogni versione ha la sua sezione `## vX.Y` (in inglese e italiano): se la descrizione della release
è vuota, l'automazione la riempie con questo testo, che Wingman mostra come "Novità".
A ogni release l'automazione aggiunge anche il link alla scansione VirusTotal del pacchetto.

## v1.05

### 🇬🇧 English
- 🆕 **Fast Teleport Assistant (ULTRA-FAST MODE)** – Quality of life first: from the map to any Field Boss in 3 moves. Click the boss in the panel, click the Teleport (Wingman has already found it in the Kibelisk list and put the cursor on it), press F twice. It is now the default mode; NORMAL MODE, the full guided route, can be chosen in Settings > Field Boss > Search and Teleport.
- ⚡ **Automatic Teleport search** – Wingman scrolls the Kibelisk list by itself until it finds the boss's Teleport, 36 scrolls per step by default (adjustable in the same menu).
- 🧭 **Flight direction ready after the Travel** – The direction is preset for 20 Altgard bosses; for the others it is calculated from the boss icon (red or grey) nearest to the Teleport. You can choose it per boss, and the choice applies in both modes.
- 👑 **Boss list with Teleport and Direction** – Two new fields for every boss in Settings > Field Boss > Boss list, with the reference Teleports of all Altgard bosses already filled in.
- 🏠 **Mode shown in the Home page** – The Field Boss card and the info line show whether ULTRA-FAST or NORMAL MODE is in use.
- 🎨 **More modern Settings** – Taller lists without grid lines, alternating rows, values in the theme color, full-row menu on the left and column headers drawn in the theme colors. With dark themes, scrollbars, buttons, drop-down menus and title bar are dark too.
- ✨ **Splash screen tied to your theme** – Every theme now has its own animated splash: a glow in the accent color, the theme's emoji next to "by VaLeTecK", the theme name next to the version and themed effects (snow for natale, embers for halloween, hearts, leaves, confetti, fireworks, neon lines, arcane rings, light rays…). Your own themes take the style of the theme they come from. The animation is now one smooth movement (no pause between zoom and fade), with new defaults: size 1.04, time on screen 0 s.
- 👁️ **Readable with every theme** – Values, status and messages automatically get enough contrast (e.g. the gold of the "principale" theme on white).
- 💾 **Settings kept on every update** – Wingman remembers the values you chose yourself (in Settings, in the Setup or by editing the CONFIG) and carries only those over; everything else gets the new defaults. Fixes theme and settings going back to default, especially after using the Setup.
- ⚙️ **Smarter Setup** – New question to choose the Teleport assistant (ULTRA-FAST or NORMAL); every question now suggests what you already chose, including a theme of your own, and the answers are saved as your choices.
- 📖 **Guides updated** – README and quick-guide infographics in all 10 languages now cover the Fast Teleport Assistant.
- 🐞 **Update check fixed** – Long release notes could open a "PCRE execution error -21" window; the background check now never shows errors and simply retries later.

### 🇮🇹 Italiano
- 🆕 **Assistente Teleport veloce (ULTRA-FAST MODE)** – Prima di tutto la qualità della vita: dalla mappa a qualsiasi Field Boss in 3 mosse. Clicchi il boss nel pannello, clicchi il Teleport (Wingman l'ha già trovato nella lista Kibelisk e ci ha portato il cursore), premi F due volte. Ora è la modalità predefinita; la NORMAL MODE, il percorso guidato completo, si sceglie in Impostazioni > Field Boss > Ricerca e Teleport.
- ⚡ **Ricerca automatica del Teleport** – Wingman scorre da solo la lista Kibelisk finché non trova il Teleport del boss, 36 scrollate per volta di default (regolabili nello stesso menu).
- 🧭 **Direzione di volo pronta dopo il Travel** – La direzione è preimpostata per 20 boss di Altgard; per gli altri si calcola dall'icona del boss (rossa o grigia) più vicina al Teleport. Puoi sceglierla per ogni boss, e la scelta vale in entrambe le modalità.
- 👑 **Elenco boss con Teleport e Direzione** – Due nuovi campi per ogni boss in Impostazioni > Field Boss > Elenco boss, con i Teleport di riferimento di tutti i boss di Altgard già inseriti.
- 🏠 **Modalità visibile nella Home** – La scheda Field Boss e la riga informativa mostrano se è attiva la ULTRA-FAST o la NORMAL MODE.
- 🎨 **Impostazioni più moderne** – Elenchi con righe più alte e senza griglia, righe alternate, valori nel colore del tema, menu a sinistra con selezione a riga intera e intestazioni delle colonne nei colori del tema. Con i temi scuri sono scuri anche barre di scorrimento, pulsanti, menu a tendina e barra del titolo.
- ✨ **Splash legato al tuo tema** – Ogni tema ha ora il suo splash animato: alone nel colore d'accento, l'emoji del tema accanto a "by VaLeTecK", il nome del tema accanto alla versione ed effetti a tema (neve per natale, braci per halloween, cuori, foglie, coriandoli, fuochi d'artificio, linee al neon, cerchi arcani, raggi di luce…). I tuoi temi prendono lo stile del tema da cui derivano. L'animazione è ora un unico movimento fluido (nessuna pausa tra zoom e dissolvenza), con nuovi valori predefiniti: dimensione 1.04, durata a schermo 0 s.
- 👁️ **Leggibile con ogni tema** – Valori, stato e messaggi hanno automaticamente il contrasto giusto (es. l'oro del tema "principale" sul bianco).
- 💾 **Impostazioni conservate a ogni aggiornamento** – Wingman ricorda i valori scelti da te (nelle Impostazioni, nel Setup o modificando la CONFIG) e porta avanti solo quelli; il resto prende i nuovi valori predefiniti. Risolve il ritorno di tema e impostazioni ai valori di default, soprattutto dopo aver usato il Setup.
- ⚙️ **Setup più furbo** – Nuova domanda per scegliere l'assistente Teleport (ULTRA-FAST o NORMAL); ogni domanda propone quello che hai già scelto, anche un tema tuo, e le risposte vengono salvate come tue scelte.
- 📖 **Guide aggiornate** – README e infografiche della guida rapida in tutte le 10 lingue ora presentano l'Assistente Teleport veloce.
- 🐞 **Controllo aggiornamenti corretto** – Le note di rilascio lunghe potevano aprire una finestra "PCRE execution error -21"; ora il controllo in background non mostra mai errori e riprova più tardi.

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
