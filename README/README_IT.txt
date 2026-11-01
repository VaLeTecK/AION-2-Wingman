=====================================================================
  AION 2 WINGMAN 1.0                                        by VaLeTecK
  Strumento QoL per AION 2: assistente Teleport veloce + HUD overlay
=====================================================================

COS'È
  Un programma AutoHotkey v2 che gira accanto ad AION 2 e aggiunge:
  - HUD overlay: mirino, barre e icone LOOT / COMBAT che si
    accendono con i segnali delle tue macro (F9 / F10).
  - Hidden Cube: quando si apre la finestra degli Hidden Cube porta il
    mouse su "Open with Key" e ce lo tiene.
  - Assistente Teleport veloce (Field Boss): con la mappa aperta mostra
    un pannello con tutti i boss (A-Z, gradi, attivi / non attivi).
    ULTRA-FAST MODE (predefinita): clicchi il boss, Wingman trova e
    scrolla da solo il suo Teleport nella lista Kibelisk, lo clicchi e
    premi F due volte. Poi una freccia ti indica la direzione di volo.
    NORMAL MODE: percorso guidato completo fino al Teleport più vicino.
  - Finestra Impostazioni completa, preset di risoluzione, profili di
    prestazioni, 12 lingue e 22 temi (8 delle classi, 7 di eventi e
    festività) più i tuoi temi personalizzati salvati con nome.

  Lo script NON clicca e NON preme tasti al posto tuo nel gioco:
  sposta solo il cursore e ti mostra cosa fare. I click li fai tu.

CONTENUTO DEL PACCHETTO
  Setup AION 2 Wingman.bat   setup del primo avvio (dipendenze)
  AION 2 Wingman.ahk         il programma
  OCR.ahk                    libreria OCR (serve al tool Field Boss)
  README\                    queste istruzioni in più lingue

REQUISITI
  - Windows 10 o 11
  - AutoHotkey v2 (lo installa il setup)
  - OCR di Windows in inglese (lo installa il setup)
  - AION 2 in lingua inglese (il Field Boss legge i nomi in inglese)

INSTALLAZIONE
  1. Prima di estrarre: tasto destro sullo zip > Proprietà > spunta
     "Annulla blocco" > OK. (Evita gli avvisi di Windows.)
  2. Estrai lo zip in una cartella fissa, es. Documenti\AION 2 Wingman.
     NON avviare i file da dentro lo zip.
  3. Doppio click su "Setup AION 2 Wingman.bat" e accetta la richiesta
     di amministratore. Il setup controlla e installa tutto e alla fine
     può creare un collegamento sul desktop e avviare Wingman.
     Se compare "Windows ha protetto il PC": "Ulteriori informazioni" >
     "Esegui comunque".
     Durante il setup una configurazione guidata imposta lingua,
     risoluzione, prestazioni e funzioni ON/OFF.
  4. Le volte successive avvia "AION 2 Wingman.ahk" (o il collegamento).
     Chiede da solo i permessi di amministratore: servono per leggere i
     tasti mentre il gioco è in primo piano.

PRIMO AVVIO: DA FARE SUBITO
  - Apri le Impostazioni: Ctrl+Shift+F12 (o doppio click sull'icona
    verde "H" nella barra di Windows).
  - 📦 Preset: applica FullHD (1080p), 2K (1440p) o 4K (2160p) in base
    al tuo schermo, così l'HUD ha le misure giuste.
  - La lingua la scegli già nel setup (si cambia in ⚙️ Generale > Lingua).
  - "Salva e riavvia" per confermare. Con "ANTEPRIMA DAL VIVO" vedi le
    modifiche in tempo reale anche senza il gioco aperto.

TASTI PREDEFINITI (si cambiano in Impostazioni > ⌨️ Tasti)
  Ctrl+Shift+\      HUD overlay ON/OFF
  Ctrl+Shift+1      Hidden Cube ON/OFF
  Ctrl+Shift+2      Field Boss ON/OFF
  Ctrl+Shift+F12    Impostazioni (funziona anche fuori dal gioco)
  Esc               annulla la guida Field Boss in corso
  M / F             tasti Mappa e Travel del gioco (lo script li "ascolta")
  F9 / F10          segnali delle tue macro per l'HUD (vedi sotto)
  Ctrl+F11, Ctrl+Shift+F6/F7/F8   diagnosi (solo se qualcosa non va)

COME COLLEGARE LE MACRO ALL'HUD
  - Macro di combattimento: metti F9 in spam per tutta la macro.
  - Macro di loot: inserisci F10 con un'attesa di 1350 ms.
  I tasti arrivano comunque anche al gioco.

COME USARE IL FIELD BOSS
  1. Apri la mappa (M). In alto compare la leggenda dei tasti, a destra
     il pannello dei boss (filtri per grado e stato, ▲/▼ per ridurlo).
  2. Clicca un boss nel pannello. Da qui parte la guida a fasi: il
     mouse viene portato (e bloccato) sul punto giusto, in basso c'è
     l'istruzione grande "FASE n". Tu clicchi.
  3. Dopo il click sul Teleport premi F due volte (Travel). Il mouse si
     sblocca e in alto compare la freccia con la direzione del boss.
  Esc annulla in qualsiasi momento.

PROBLEMI FREQUENTI
  - Non succede niente in gioco: lo script lavora solo con la finestra
    di AION2.exe in primo piano. Controlla l'icona "H" nella barra.
  - Field Boss "non disponibile": manca OCR.ahk nella cartella o l'OCR
    inglese di Windows. Rilancia il setup.
  - HUD troppo grande/piccolo o spostato: applica il preset giusto.
  - Antivirus che blocca lo script: è un falso positivo comune per
    AutoHotkey; aggiungi la cartella alle eccezioni.
  - Se qualcosa si rompe dopo una modifica: accanto allo script c'è la
    copia di sicurezza "AION 2 Wingman.ahk.bak".

AGGIORNAMENTI E IMPOSTAZIONI PERSONALI
  Per aggiornare basta sovrascrivere lo script con quello nuovo: le tue
  impostazioni (anche elenco boss e preset) sono salvate in
  %AppData%\AION 2 Wingman e vengono rimesse da sole al primo avvio.
  Per ripartire da zero cancella quella cartella.

MANUTENZIONE E CHIUSURA
  Impostazioni > 🛠️ Manutenzione: rilancia l'installazione guidata, apre la
  cartella di Wingman e quella delle impostazioni personali.
  Il pulsante rosso "⏻ Termina Wingman" in alto chiude l'intero programma,
  non solo la finestra delle impostazioni.
  La casella 🔍 sopra il menu cerca tra tutte le impostazioni.

DISINSTALLAZIONE
  Chiudi Wingman ("⏻ Termina Wingman" o icona "H" > Exit), cancella la cartella e il
  collegamento sul desktop. AutoHotkey si disinstalla da
  Impostazioni di Windows > App.

CREDITI E AVVERTENZE
  AION 2 Wingman - by VaLeTecK.
  OCR.ahk - by Descolada (github.com/Descolada/OCR)
  AION 2 è un marchio dei rispettivi proprietari; questo progetto non
  è affiliato né approvato da loro. È un tool esterno: usalo a tuo
  rischio e nel rispetto dei termini di servizio del gioco.
