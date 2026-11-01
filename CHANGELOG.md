# Changelog

Ogni versione ha la sua sezione `## vX.Y` (in inglese e italiano): se la descrizione della release
è vuota, l'automazione la riempie con questo testo, che Wingman mostra come "Novità".
A ogni release l'automazione aggiunge anche il link alla scansione VirusTotal del pacchetto.

## v1.05

### 🇬🇧 English
- **Quality of life first**: the new **Fast Teleport Assistant** takes you from the map to any Field Boss in 3 moves: click the boss, click the Teleport, press F twice.
- New **ULTRA-FAST MODE** for the Assisted Teleport, now the default (Settings > Field Boss > Search and Teleport, switch between NORMAL MODE and ULTRA-FAST MODE). Click the boss in the panel and Wingman finds that boss's reference Teleport right away in the Kibelisk list on the left: click it and press F twice. Wingman scrolls the list by itself until it finds the Teleport (36 scrolls per step by default, adjustable in the same menu). NORMAL MODE works as before and can be chosen in the same menu; the Home page shows which mode is in use.
- Flight direction after the Teleport: in ULTRA-FAST MODE it is calculated on the fly from the boss icon nearest to the Teleport. The directions of 20 Altgard bosses are already set, so the arrow is ready right away; for every boss you can also choose it yourself (Automatic or one of the 8 directions), and that choice applies in both modes.
- Boss list editor: new **Teleport** and **Direction** fields for every boss, with the reference Teleports of all Altgard bosses already filled in.
- Settings got a more modern look: taller lists without grid lines, alternating rows, values highlighted in the theme color, a full-row menu on the left, and with dark themes also dark headers, scrollbars, buttons, drop-down menus and title bar.
- Readability: values, status and messages in Settings automatically get enough contrast with every theme (for example the gold of the "principale" theme on white).
- Your settings and theme now really survive every new version: Wingman remembers which values you chose yourself (in Settings, in the Setup or by editing the CONFIG) and carries only those over, while everything else gets the new defaults. Fixes the theme and settings going back to default after an update, especially when the Setup had been used.
- Setup: new question to choose the Teleport assistant (ULTRA-FAST or NORMAL); questions now suggest what you already chose (theme, profile, features on at startup), including a theme of your own, and its choices are saved as yours.
- README and quick-guide infographics updated for the Fast Teleport Assistant in all 10 languages.

### 🇮🇹 Italiano
- **Prima di tutto la qualità della vita**: il nuovo **Assistente Teleport veloce** ti porta dalla mappa a qualsiasi Field Boss in 3 mosse: click sul boss, click sul Teleport, F due volte.
- Nuova **ULTRA-FAST MODE** per il Teleport assistito, ora predefinita (Impostazioni > Field Boss > Ricerca e Teleport, scelta tra NORMAL MODE e ULTRA-FAST MODE). Clicchi il boss nel pannello e Wingman trova subito nella lista Kibelisk a sinistra il Teleport di riferimento di quel boss: lo clicchi e premi F due volte. Wingman scorre da solo la lista finché non trova il Teleport (36 scrollate per volta di default, regolabili nello stesso menu). La NORMAL MODE funziona come prima e si sceglie nello stesso menu; la Home mostra la modalità in uso.
- Direzione di volo dopo il Teleport: in ULTRA-FAST MODE si calcola al volo dall'icona del boss più vicina al Teleport. Le direzioni di 20 boss di Altgard sono già impostate, così la freccia è subito pronta; per ogni boss puoi anche sceglierla tu (Automatica o una delle 8 direzioni), e la scelta vale in entrambe le modalità.
- Editor dell'elenco boss: nuovi campi **Teleport** e **Direzione** per ogni boss, con i Teleport di riferimento di tutti i boss di Altgard già inseriti.
- Impostazioni con un aspetto più moderno: elenchi con righe più alte e senza griglia, righe alternate, valori evidenziati con il colore del tema, menu a sinistra con selezione a riga intera e, con i temi scuri, anche intestazioni, barre di scorrimento, pulsanti, menu a tendina e barra del titolo scuri.
- Leggibilità: valori, stato e messaggi delle Impostazioni hanno automaticamente il contrasto giusto con ogni tema (per esempio l'oro del tema "principale" sul bianco).
- Le tue impostazioni e il tema ora restano davvero a ogni nuova versione: Wingman ricorda quali valori hai scelto tu (nelle Impostazioni, nel Setup o modificando la CONFIG) e porta avanti solo quelli, mentre il resto prende i nuovi valori predefiniti. Risolve il ritorno di tema e impostazioni ai valori di default dopo un aggiornamento, soprattutto se era stato usato il Setup.
- Setup: nuova domanda per scegliere l'assistente Teleport (ULTRA-FAST o NORMAL); le domande propongono quello che hai già scelto (tema, profilo, funzioni accese all'avvio), anche un tema tuo, e le sue scelte vengono salvate come tue.
- README e infografiche della guida rapida aggiornati per l'Assistente Teleport veloce in tutte le 10 lingue.

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
