#Requires AutoHotkey v2.0
#SingleInstance Force

; ##############################################################################
; #  AION 2 WINGMAN 1.0  -  HUD overlay + Tools                 by VaLeTecK     #
; #                                                                             #
; #  File richiesti nella stessa cartella:                                      #
; #    - questo script (AION 2 Wingman.ahk)                                     #
; #    - OCR.ahk  (serve solo al tool Field Boss; senza, tutto il resto va)     #
; #                                                                             #
; #  Si avvia da solo come amministratore (serve per leggere i tasti nel gioco).#
; #  Per chiuderlo: icona "H" verde nella barra di Windows > Exit.              #
; ##############################################################################

; --- Avvio come amministratore (necessario per intercettare i tasti dentro il gioco) ---
if !A_IsAdmin {
    try Run(A_IsCompiled
        ? '*RunAs "' A_ScriptFullPath '" /restart'
        : '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"')
    ExitApp
}

global AppVersion := "1.02"                ; versione dell'applicazione (solo nelle interfacce: il file si chiama sempre "AION 2 Wingman.ahk")
A_IconTip := "AION 2 Wingman " AppVersion " - by VaLeTecK"   ; testo dell'icona nella barra di Windows
ListLines false
KeyHistory 0                 ; nessuno storico dei tasti in memoria
CoordMode "Pixel", "Screen"  ; coordinate dello schermo intero per pixel, mouse e tooltip
CoordMode "Mouse", "Screen"
CoordMode "ToolTip", "Screen"

; Timer di sistema a 1 ms: senza questo un timer da 16 ms a volte scatta dopo 31 ms
; e le animazioni "saltano" un fotogramma. Ripristinato all'uscita dello script.
DllCall("winmm\timeBeginPeriod", "UInt", 1)
OnExit((*) => DllCall("winmm\timeEndPeriod", "UInt", 1))

; Le prime versioni si chiamavano "AION 2 Wingman 1.0.ahk": chi aggiorna copiando il nuovo file
; si ritroverebbe due script e un collegamento che punta al vecchio. Qui si chiude l'eventuale
; vecchio processo, il vecchio file va nel Cestino e il collegamento sul desktop viene corretto.
LegacyCleanup() {
    if (A_ScriptName != "AION 2 Wingman.ahk")
        return
    prev := A_DetectHiddenWindows
    DetectHiddenWindows(true)
    for hwnd in WinGetList("ahk_class AutoHotkey")
        try if (hwnd != A_ScriptHwnd && InStr(WinGetTitle(hwnd), A_ScriptDir "\AION 2 Wingman ")
                && !InStr(WinGetTitle(hwnd), A_ScriptFullPath))
            WinClose(hwnd)
    DetectHiddenWindows(prev)
    loop files A_ScriptDir "\AION 2 Wingman *.ahk" {
        if (A_LoopFileFullPath = A_ScriptFullPath)
            continue
        try FileRecycle(A_LoopFileFullPath)
        try FileRecycle(A_LoopFileFullPath ".bak")
    }
    lnk := A_Desktop "\AION 2 Wingman.lnk"
    if FileExist(lnk) {
        try {
            FileGetShortcut(lnk, , , &args)
            if !InStr(args, A_ScriptFullPath)
                FileCreateShortcut(A_AhkPath, lnk, A_ScriptDir, '"' A_ScriptFullPath '"', "AION 2 Wingman - by VaLeTecK", A_AhkPath)
        }
    }
}


; ==============================================================================
; ===                              CONFIG                                    ===
; ===                   AION 2 Wingman 1.0 - by VaLeTecK                     ===
; ==============================================================================
;
;  PIÙ COMODO: apri la finestra IMPOSTAZIONI con Ctrl+Shift+F12 (o doppio click sull'icona "H"
;  nella barra di Windows): menu per funzione, descrizione ed esempio di ogni opzione,
;  "Salva e riavvia" scrive i valori qui sotto da solo (con copia di sicurezza .bak).
;
;  COME SI LEGGE
;   - Modifica solo il valore dopo  :=   e salva. Poi riavvia lo script
;     (tasto destro sull'icona "H" > Reload Script).
;   - Il testo dopo il  ;  è un commento: spiega l'opzione, non viene eseguito.
;   - true / false      = acceso / spento
;   - "testo"           = va scritto tra virgolette
;   - ms                = millisecondi (1000 ms = 1 secondo)
;   - s                 = secondi (si possono usare i decimali: 0.5 = mezzo secondo)
;   - Colori            = nome inglese ("Red", "Lime", "White"...) oppure codice
;                         esadecimale RRGGBB senza # ("CC4400" = arancione scuro)
;   - Opacità 0..255    = 0 invisibile, 255 del tutto opaco
;
;  UNITÀ DELLE POSIZIONI (cambiano da sezione a sezione, sono indicate ogni volta)
;   - HUD:          pixel reali dello schermo, rispetto al centro
;   - Hidden Cube:  pixel misurati in 4K, si adattano da soli alla tua risoluzione
;   - Field Boss:   pixel misurati a 1440p, si adattano da soli alla tua risoluzione
;
;  SEZIONI
;   [GENERALE]  [TASTI]  [HUD] x6  [TOOL 1] Hidden Cube  [TOOL 2] Field Boss
; ==============================================================================

; ------------------------------------------------------------------------------
; [GENERALE]
; ------------------------------------------------------------------------------
global GameExe        := "AION2.exe"   ; nome del processo del gioco. HUD e tool funzionano
                                       ; solo quando questa finestra è in primo piano.
global ClickThrough   := true          ; true  = i click del mouse "attraversano" l'HUD e arrivano al gioco
                                       ; false = l'HUD blocca i click nei punti dove è disegnato
global Language       := "italiano"    ; lingua di impostazioni, avvisi e istruzioni a schermo:
                                       ; "english" | "italiano" | "spanish" | "french" | "german" | "portuguese" | "russian" | "korean" | "chinese" | "japanese" | "napoletano" | "bro"
; Splash all'avvio: al centro dello schermo il nome dell'app, "by VaLeTecK" e, in piccolo, la versione crescono da piccoli
; a grandi passando da trasparenti (20%) a pieni (100%), restano un attimo e poi svaniscono.
global SplashEnabled  := true          ; false = nessuno splash all'avvio
global SplashHold     := 0.25           ; s in cui resta pieno a schermo prima di svanire
global SplashScale    := 1.4           ; dimensione (1.0 = normale)

; ------------------------------------------------------------------------------
; [AGGIORNAMENTI]  Nuove versioni pubblicate come "release" su GitHub.
;   L'aggiornamento sostituisce i file del programma: le tue impostazioni, i preset e i tuoi temi
;   (in %AppData%\AION 2 Wingman) restano. Lo script attuale resta come copia "AION 2 Wingman.ahk.bak".
; ------------------------------------------------------------------------------
global UpdateRepo       := "VaLeTecK/AION-2-Wingman"   ; repository GitHub del progetto: "utente/nome-repo"
global UpdateMode       := "automatico" ; "chiedi"     = se c'è una versione nuova te lo chiede (mai mentre giochi)
                                       ; "automatico" = la installa da solo appena il gioco non è in primo piano
                                       ; "spento"     = nessun controllo automatico (resta il pulsante in Manutenzione)
global UpdateCheckHours := 1           ; ogni quante ore controllare (all'avvio e poi di continuo mentre lo script è aperto)

; ------------------------------------------------------------------------------
; [TEMA]  Colori di tutta la suite: HUD, pannello Field Boss, istruzioni, leggenda,
;   freccia di direzione, finestra Impostazioni e splash.
; ------------------------------------------------------------------------------
; Tema dei colori:
;   "principale" = il tema classico (scuro e oro); l'HUD usa i colori della sezione [HUD] Colori
;   "dark"       = nero grafite e azzurro ghiaccio, contrasto alto
;   "bright"     = chiaro: pannelli bianchi e testi scuri, HUD giallo
;   "cuddle"     = colori coccolosi: pesca, crema e pastelli morbidi
;   "pinkhaze"   = foschia rosa e viola su fondo scuro
;   "egirl"      = rosa shocking e nero, neon
;   "vi"         = Vice City: tramonto rosa/arancio, viola e turchese (stile GTA VI)
; Temi di classe (AION 2): oltre ai colori cambiano forme di mirino e icone, animazione,
; effetti ed emoji delle icone (al posto dei valori delle sezioni [HUD]):
;   "gladiator"    = rosso sangue e bronzo, blocchi pesanti che avanzano a marcia, ascia
;   "templar"      = oro e blu reale, scudo: rombi -> triangoli che pulsano lenti, aura dorata
;   "assassin"     = viola notte e verde veleno, lame sottili in sequenza rapida, pugnale
;   "ranger"       = verde bosco, 5 frecce in marcia come una raffica, arco
;   "sorcerer"     = blu arcano e fuoco, cerchi -> rombi pulsanti, sfera magica
;   "spiritmaster" = turchese spirituale, rombi -> sfere in sequenza, vortice degli spiriti
;   "cleric"       = luce bianca e oro (tema chiaro), sfere che respirano piano, cuore
;   "chanter"      = ambra e oro dei mantra, triangoli -> blocchi a ritmo, note musicali
;   "halloween"    = (evento) zucca arancione e viola notte, zucca e fantasmino
;   "natale"       = (evento) rosso, verde abete e oro, regalo e albero
;   "capodanno"    = (evento) nero, oro e argento, brindisi e fuochi d'artificio
;   "sanvalentino" = (evento) rosa e rosso vino, cuori che battono
;   "carnevale"    = (evento) viola, giallo e verde, maschera e coriandoli
;   "pasqua"       = (evento) pastelli chiari di primavera, uovo e pulcino
;   "sanpatrizio"  = (evento) verde trifoglio e oro, quadrifoglio e boccale
;   "custom"       = tutti i colori qui sotto (ThemeColor...) + i colori HUD della sezione [HUD] Colori
; I temi pronti non cambiano mai. I tuoi temi, creati con "Editor temi" nelle Impostazioni, si chiamano "user:Nome".
global Theme          := "principale"   ; uno dei nomi qui sopra, "custom" oppure "user:Nome"
; Easter egg del tema "vi": in alto al centro (a pochi px dal bordo) il conto alla rovescia
; giorni:ore:minuti:secondi all'uscita di GTA VI. Si vede solo con il gioco in primo piano
; (o in anteprima) e si nasconde quando c'è la leggenda della mappa.
global ViCountdown         := false              ; acceso solo col tema "vi"; negli altri temi è spento (nei tuoi temi scegli tu)
global ViCountdownDate     := "20261119000000"   ; uscita di GTA VI: AAAAMMGGhhmmss (19/11/2026 00:00, ora del PC)
; Colori del tema "custom" (usati solo con Theme := "custom")
global ThemeColorBg        := "14171C"   ; sfondo di pannello, intestazioni e leggenda
global ThemeColorRow       := "1E232B"   ; sfondo delle righe e dei pulsanti del pannello
global ThemeColorHover     := "2C3440"   ; riga sotto il mouse
global ThemeColorLine      := "2E3540"   ; linee di separazione
global ThemeColorAccent    := "E8D9A8"   ; titoli e nome dell'app
global ThemeColorText      := "FFFFFF"   ; testo principale
global ThemeColorSubText   := "C9CED6"   ; testo secondario (dettagli delle istruzioni)
global ThemeColorMuted     := "8A93A0"   ; testo spento (filtri disattivi, "by VaLeTecK")
global ThemeColorDeep      := "0B0E13"   ; sfondo di istruzioni grandi e freccia di direzione
global ThemeColorGo        := "F2B84B"   ; istruzione "da fare" e anello sul punto da cliccare
global ThemeColorWait      := "4FA3FF"   ; istruzione "attendi"
global ThemeColorOk        := "5FD068"   ; fatto / ON
global ThemeColorErr       := "FF5A4F"   ; errore / OFF
global ThemeColorInfo      := "7FD4FF"   ; freccia della direzione del boss
global ThemeColorWinBg     := "F4F5F7"   ; sfondo della finestra Impostazioni
global ThemeColorWinText   := "1B1F26"   ; testo della finestra Impostazioni
global ThemeColorWinSub    := "555D6B"   ; testo secondario della finestra Impostazioni
global ThemeColorWinField  := "FFFFFF"   ; sfondo di elenchi e caselle della finestra Impostazioni

; ------------------------------------------------------------------------------
; [PRESTAZIONI]  Quanto spesso lo script controlla lo schermo e ridisegna l'HUD.
;   Cicli più lunghi = meno CPU ma reazioni più lente; cicli più corti = iperreattivo ma più CPU.
; ------------------------------------------------------------------------------
;   Valori di ogni profilo:
;                     HUD fps   Hidden Cube   Blocco cubo   Mappa   Field Boss   Blocco mouse   Attese   Anello   OCR
;   potato              20 fps     300 ms        50 ms      1000 ms     120 ms        40 ms       30 ms    80 ms   1.5
;   base                30 fps     200 ms        30 ms       600 ms      80 ms        25 ms       20 ms    60 ms   1.75
;   bilanciato          60 fps     100 ms        15 ms       300 ms      50 ms        15 ms       15 ms    50 ms   2
;   performante         90 fps      60 ms        10 ms       200 ms      30 ms        10 ms       10 ms    33 ms   2.25
;   gigachad           144 fps      30 ms         5 ms       120 ms      15 ms         5 ms        5 ms    16 ms   2.5
;   HUD fps = fluidità delle animazioni     Hidden Cube = controllo della finestra del cubo
;   Mappa = controllo "mappa aperta?" (lettura OCR, il più pesante)     Field Boss = ciclo di lavoro del tool
;   Blocco mouse = rigidità del blocco nelle fasi Field Boss     Attese = reattività ai tuoi click e tasti
;   Anello = fluidità dell'anello pulsante     OCR = qualità della lettura (più alta = più precisa ma più pesante)

; Profilo prestazioni: scegli quello adatto al tuo PC.
;   "potato"      = PC molto datati o portatili: minimo uso della CPU, reazioni più lente
;   "base"        = PC di fascia bassa: leggero ma ancora scorrevole
;   "bilanciato"  = consigliato per la maggior parte dei PC (i valori classici)
;   "performante" = PC di fascia alta: più fluido e reattivo
;   "gigachad"    = PC top di gamma: tutto iperreattivo, massimo uso della CPU
;   "manuale"     = valgono i singoli valori dell'elenco, modificabili uno per uno
global PerfProfile      := "bilanciato"   ; "potato" | "base" | "bilanciato" | "performante" | "gigachad" | "manuale"
; Valori usati solo con PerfProfile "manuale":
global PerfWorkerTick   := 50     ; ms del ciclo di lavoro del tool Field Boss
global PerfLockTick     := 15     ; ms tra un controllo e l'altro del blocco del mouse (Field Boss)
global PerfPollMs       := 15     ; ms tra un controllo e l'altro mentre aspetta un tuo click o un tasto
global PerfRingTick     := 50     ; ms tra un fotogramma e l'altro dell'anello pulsante
global PerfOcrQuality   := 2      ; ingrandimento dell'immagine per l'OCR a 1440p (1 = leggero, 3 = preciso)

; ------------------------------------------------------------------------------
; [TASTI]  Tutti i tasti in un unico posto.
;
;   Come si scrive un tasto:  ^ = Ctrl    + = Shift    ! = Alt    # = Win
;     esempi:  "F9"   "^F11" (Ctrl+F11)   "^+1" (Ctrl+Shift+1)   "!q" (Alt+Q)
;   ""  = nessun tasto (funzione disattivata)
;   Funzionano solo con il gioco in primo piano.
;   Evita combinazioni con F9 e F10 (es. Ctrl+F9): l'HUD le intercetta già.
; ------------------------------------------------------------------------------
; HUD - segnali inviati dalle tue macro (il tasto arriva comunque anche al gioco).
;       Come impostare le macro: vedi [HUD] Comportamento e colori, qui sotto.
global CombatKey            := "F9"     ; accende mirino + barre + icona Combat
global LootKey          := "F10"    ; accende l'icona Loot

; Accensione/spegnimento mentre giochi (compare un avviso ON/OFF, la leggenda sulla mappa
; mostra lo stato di ognuno)
global HiddenCubeToggleKey  := "^+1"    ; Ctrl+Shift+1 = Hidden Cube ON/OFF
global FieldBossToggleKey   := "^+2"    ; Ctrl+Shift+2 = Field Boss ON/OFF
global HudToggleKey         := "^+\"    ; Ctrl+Shift+\ = HUD overlay ON/OFF (mirino, barre e icone)
                                        ; (\ = tasto a sinistra dell'1 sulla tastiera italiana;
                                        ;  se non risponde prova "^+SC029", lo stesso tasto per posizione)

; Field Boss
global FieldBossMapKey      := "m"      ; il tasto con cui apri la mappa in gioco. Lo script lo
                                        ; "ascolta" (arriva comunque al gioco) per far comparire
                                        ; subito pannello e leggenda.
global FieldBossTravelKey    := "f"      ; il tasto Travel del gioco. Lo script lo "ascolta" (arriva comunque
                                        ; al gioco) per sapere quando parti, e mostrarti poi la direzione del boss.
;                              Esc      = annulla la guida o la ricerca in corso (fisso, non modificabile)

; Impostazioni - finestra con tutte le opzioni di questa CONFIG (funziona anche fuori dal gioco).
; Si apre anche dal menu dell'icona "H" nella barra di Windows o con un doppio click sull'icona.
global SettingsKey          := "^+F12"  ; Ctrl+Shift+F12 = apri le impostazioni

; Diagnosi - servono solo se qualcosa non viene riconosciuto
global HiddenCubeTestKey    := "^F11"   ; con la finestra del cubo aperta: mostra cosa vede lo script
global FieldBossCoordKey    := "^+F6"   ; mostra e copia negli appunti le coordinate del mouse (base 1440p)
global FieldBossMapTestKey  := "^+F7"   ; segna sulla mappa per 3 s: Teleport (viola), teschi attivi (rosso), boss (giallo)
global FieldBossScanKey     := "^+F8"   ; mostra cosa legge l'OCR nella lista boss (nome, stato, posizione)

; ------------------------------------------------------------------------------
; [HUD] Comportamento e colori
;   Ogni pressione di F9/F10 accende la sua parte di HUD; quando smetti di premerlo,
;   dopo un breve tempo torna allo stato "inattivo" (colore spento, poi dissolvenza).
;
;   >>> IMPOSTAZIONE DELLE MACRO (necessaria perché l'HUD segua le tue macro) <<<
;     COMBAT   (mirino, barre, icona COMBAT):
;              nella macro di combattimento metti F9 IN SPAM, cioè ripetuto di continuo
;              per tutta la durata della macro. Finché arriva F9 l'HUD resta attivo;
;              quando la macro si ferma, dopo CombatTimeout ms torna inattivo.
;     LOOT (icona LOOT):
;              nella macro di Loot inserisci F10 con un wait di 1350 ms
;              (F10 giù > attesa 1350 ms > F10 su). Mentre F10 è tenuto premuto l'icona
;              resta attiva; dopo il rilascio torna inattiva trascorsi LootTimeout ms.
;     Se la tua macro usa pause più lunghe tra un segnale e l'altro, alza il Timeout
;     corrispondente qui sotto, altrimenti l'HUD si spegnerà a metà.
;   HUD spento con Ctrl+Shift+\: i segnali F9/F10 vengono ignorati (arrivano solo al gioco).
; ------------------------------------------------------------------------------
global HudEnabled        := true       ; true = HUD overlay attivo all'avvio dello script
global HudBaseHeight     := 2160       ; risoluzione (altezza in px) per cui sono pensati i valori in px dell'HUD:
                                       ; 1080 = FullHD, 1440 = 2K, 2160 = 4K. La usano i preset delle Impostazioni
                                       ; per riscalare l'HUD da una risoluzione all'altra.
global CombatTimeout     := 150        ; ms senza F9 prima di tornare inattivo
global LootTimeout   := 400        ; ms dopo il RILASCIO di F10 prima di tornare inattivo
                                       ; (copre la pausa tra la fine di un ciclo della macro e il successivo)
global CombatGrace       := 600        ; ms minimi in cui F9 resta ON dopo l'accensione
                                       ; (copre la pausa di Windows prima della ripetizione automatica del tasto)
global LootGrace     := 0          ; come sopra, per F10
global ColorActive       := "Lime"     ; colore di tutto l'HUD quando è attivo (F9 e F10)
global ColorIdleCombat   := "Red"      ; colore di mirino e barre quando sono inattivi
global ColorIdleLoot := "CC4400"   ; colore dell'icona Loot quando è inattiva (arancione scuro)
global ColorBorder       := "Black"    ; colore delle cornici di barre e icone

; ------------------------------------------------------------------------------
; [HUD] Mirino centrale (F9)
;   Frecce contrapposte al centro dello schermo.
;     inattivo (OFF) = frecce verso l'esterno   <<<  >>>
;     attivo   (ON)  = frecce verso l'interno   >>>  <<<   con animazione
;   La finestra del mirino si dimensiona da sola in base a questi valori.
; ------------------------------------------------------------------------------
global OffsetX             := 0        ; spostamento orizzontale dal centro (px, + = destra)
global OffsetY             := -135     ; spostamento verticale dal centro (px, - = più in alto)
global ChevronGap          := 40        ; spazio vuoto tra il gruppo di frecce sinistro e quello destro (px)
global ChevronCount        := 3        ; numero di frecce per lato

; Forma delle frecce: a sinistra lo stato OFF, a destra lo stato ON (px)
global ChevronWidthOff     := 1,  ChevronWidthOn     := 30   ; larghezza di una freccia
global ChevronHeightOff    := 30,  ChevronHeightOn    := 38   ; altezza di una freccia
global ChevronThicknessOff := 8,   ChevronThicknessOn := 10   ; spessore delle linee
global ChevronSpacingOff   := 11,  ChevronSpacingOn   := 18   ; distanza tra una freccia e la successiva

; Forma degli elementi del mirino (una per lo stato OFF e una per lo stato ON;
; nel passaggio tra i due stati la forma cambia a metà):
;   "freccia"   = chevron  >  (classica)
;   "triangolo" = triangolo pieno, punta nella direzione delle frecce
;   "barra"     = barretta verticale  |  (spessore = Thickness)
;   "rombo"     = rombo pieno  ◆
;   "cerchio"   = pallino / ovale pieno  ●
;   "blocco"    = rettangolo pieno  ■
; Larghezza, altezza e distanza usano i valori qui sopra. Le forme simmetriche
; (barra, rombo, cerchio, blocco) non cambiano verso tra OFF e ON.
global ChevronShapeOff     := "freccia"   ; forma a riposo (OFF)
global ChevronShapeOn      := "freccia"   ; forma in combattimento (ON): "freccia" | "triangolo" | "barra" |
                                          ; "rombo" | "cerchio" | "blocco" (vedi la spiegazione sopra)

; Animazione in stato ON
;   "pulse"    = un'onda di ingrandimento scorre dall'esterno verso il centro
;   "march"    = le frecce scorrono verso il centro come un nastro continuo
;   "sequence" = le frecce si accendono una dopo l'altra, dall'esterno al centro
;   "none"     = frecce ferme
global ChevronAnimMode     := "pulse"
global ChevronAnimCycle    := 500      ; ms per un ciclo completo (più basso = più veloce)
global ChevronPulseMin     := 0.5      ; solo "pulse": grandezza minima della freccia (1 = normale)
global ChevronPulseMax     := 1.15     ; solo "pulse": grandezza massima della freccia

; Passaggio tra OFF e ON: le frecce si "ribaltano" gradualmente
global ChevronMorphInTime  := 0.15     ; s per passare da OFF a ON (0 = istantaneo)
global ChevronMorphOutTime := 0.45     ; s per passare da ON a OFF

; ------------------------------------------------------------------------------
; [HUD] Barre inferiori (F9)
;   Due barre orizzontali sotto il centro, ognuna divisa in due metà a trapezio.
;   Posizioni in px rispetto a un punto a 3/4 dell'altezza dello schermo.
; ------------------------------------------------------------------------------
;                          Barra 1 (sopra)       Barra 2 (sotto)
global Bar1Enabled    := true,          Bar2Enabled    := true    ; true = mostrata, false = nascosta
global Bar1MaxWidth   := 874,           Bar2MaxWidth   := 948     ; larghezza totale
global Bar1MaxHeight  := 10,            Bar2MaxHeight  := 2       ; altezza (spessore)
global Bar1BorderSize := 3,             Bar2BorderSize := 1       ; cornice nera attorno
global Bar1OffsetY    := 216,           Bar2OffsetY    := 259     ; posizione verticale (+ = più giù)
global Bar1OffsetX    := 2,             Bar2OffsetX    := 2       ; posizione orizzontale (+ = destra)
global Bar1CenterGap  := 82,            Bar2CenterGap  := 170     ; spazio vuoto tra le due metà
global Bar1Skew       := 12,            Bar2Skew       := 5       ; inclinazione dei lati (0 = rettangolo)

; ------------------------------------------------------------------------------
; [HUD] Icone di stato
;   Loot (F10) a sinistra, Combat (F9) a destra.
;   Ogni icona ha i suoi valori: forma, grandezza, posizione, testi, effetti e transizioni.
; ------------------------------------------------------------------------------
global IconAutoFit           := true   ; true = testo ed emoji si adattano da soli alla forma e alla grandezza
                                       ; dell'icona (le dimensioni di testo ed emoji non servono)
                                       ; false = dimensioni fisse di testo ed emoji (impilati senza sovrapporsi)
global IconMirror            := true   ; true = l'icona Combat è speculare al Loot: stessa altezza, lato opposto
                                       ; (sposti il Loot e il Combat lo segue). false = ognuna nella sua posizione

; Icona Loot (F10)
global LootOffsetX       := -520   ; posizione rispetto al centro schermo (px, - = sinistra)
global LootOffsetY       := 920    ; (px, + = più in basso)
global LootTextLine1     := ""     ; testo in alto
global LootEmoji         := "👋🏻"   ; emoji al centro
global LootTextLine3     := "LOOT" ; testo in basso
; Testo ed emoji dell'icona Loot (spostamenti in px: + = destra / più in basso)
global LootBaseFontSize  := 11     ; dimensione del testo (righe in alto e in basso)
global LootEmojiSize     := 38     ; dimensione dell'emoji centrale
global LootLine1OffsetX  := 0,     LootLine1OffsetY := -3     ; spostamento del testo in alto
global LootEmojiOffsetX  := -1,     LootEmojiOffsetY := -18   ; spostamento dell'emoji (- = più in alto)
global LootLine3OffsetX  := 0,     LootLine3OffsetY := 4     ; spostamento del testo in basso
global LootTextColor     := "White"   ; colore del testo
global LootOutlineColor  := "Black"   ; colore del contorno del testo (1 px)
; Forma dell'icona (il "diametro" LootSize diventa la sua altezza):
;   "cerchio"    = rotonda (classica)
;   "quadrato"   = quadrata
;   "rettangolo" = rettangolare, più larga che alta (1,5 : 1)
;   "triangolo"  = triangolare con la punta in alto (il testo in alto scende un po')
;   "trapezio"   = trapezio, più stretto in alto
; Effetti (pulse, ring, spin, glow) e cornice seguono la forma scelta.
global LootShape         := "quadrato"
global LootSize          := 106    ; grandezza dell'icona: altezza della forma (px)
global LootBorderSize    := 4      ; spessore del bordino nero esterno (px)

; Icona Combat (F9)
global CombatIconEnabled := true             ; false = icona non mostrata
global CombatOffsetX     := 520    ; posizione rispetto al centro schermo (px). Usata solo con IconMirror := false
global CombatOffsetY     := 920    ; (px, + = più in basso). Usata solo con IconMirror := false
global CombatTextLine1   := ""
global CombatEmoji       := "⚔️"
global CombatTextLine3   := "COMBAT"
; Testo ed emoji dell'icona Combat. Un nome Loot (es. LootEmojiSize) = uguale al Loot;
; oppure scrivi un numero per renderla indipendente.
global CombatFontSize    := 8   ; dimensione del testo
global CombatEmojiSize   := 32      ; dimensione dell'emoji
global CombatLine1OffsetX := 0,    CombatLine1OffsetY := 0     ; spostamento del testo in alto
global CombatEmojiOffsetX := 0,    CombatEmojiOffsetY := -20   ; spostamento dell'emoji
global CombatLine3OffsetX := 0,    CombatLine3OffsetY := 5     ; spostamento del testo in basso
global CombatTextColor   := "White"   ; colore del testo
global CombatOutlineColor := "Black"  ; colore del contorno del testo
global CombatIdleColor   := "064FC6"         ; colore quando inattiva (attiva = ColorActive)
global CombatShape       := "triangolo"        ; forma: "cerchio" | "quadrato" | "rettangolo" | "triangolo" | "trapezio"
                                                 ; (le stesse dell'icona Loot, vedi sopra)
global CombatSize        := 106    ; grandezza dell'icona: altezza della forma (px)
global CombatBorderSize  := 4      ; spessore del bordino nero esterno (px)

; ---- Effetti dell'icona Loot (F10) ----
; Effetti animati in stato ON. Si possono combinare: metti uno o più nomi tra [ ].
;   "pulse" = alone luminoso che "respira" attorno al cerchio
;   "ring"  = onde ad anello che partono dal bordo e si allargano svanendo (sonar)
;   "spin"  = arco luminoso con scia che gira sul bordo (caricamento)
;   "glow"  = il cerchio si illumina a intermittenza
;   []      = nessun effetto
global LootAnim          := ["ring", "pulse", "spin"]
global LootFxPadding     := 38     ; spazio attorno al cerchio riservato agli effetti (px).
                                       ; Aumentalo se gli effetti risultano tagliati.
; "pulse"
global LootPulseCycle    := 1200   ; ms per un respiro completo
global LootPulseSize     := 18     ; quanto si allarga l'alone (px)
global LootPulseOpacity  := 0.5    ; intensità (0..1)
global LootPulseColor    := "F8FE01"
; "ring"
global LootRingCycle     := 1400   ; ms di vita di un'onda
global LootRingCount     := 2      ; onde presenti insieme (sfasate)
global LootRingDistance  := 32     ; px percorsi dall'onda prima di svanire
global LootRingThickness := 4      ; spessore dell'anello (px)
global LootRingOpacity   := 0.9    ; intensità (0..1)
global LootRingColor     := "FDBE02"
; "spin"
global LootSpinCycle     := 800    ; ms per un giro completo
global LootSpinArc       := 120    ; lunghezza dell'arco con la scia (gradi, 360 = cerchio intero)
global LootSpinThickness := 10      ; spessore dell'arco (px)
global LootSpinColor     := "FFFFFF"
; "glow"
global LootGlowCycle     := 1000   ; ms per una pulsazione
global LootGlowColor     := "FFFFFF"
global LootGlowAmount    := 0.3    ; intensità (0..1)

; ---- Effetti dell'icona Combat (F9) ----
; Effetti animati in stato ON. Si possono combinare: metti uno o più nomi tra [ ].
;   "pulse" = alone luminoso che "respira" attorno al cerchio
;   "ring"  = onde ad anello che partono dal bordo e si allargano svanendo (sonar)
;   "spin"  = arco luminoso con scia che gira sul bordo (caricamento)
;   "glow"  = il cerchio si illumina a intermittenza
;   []      = nessun effetto
global CombatAnim        := ["ring", "pulse", "spin"]
global CombatFxPadding   := 38     ; spazio attorno al cerchio riservato agli effetti (px).
                                       ; Aumentalo se gli effetti risultano tagliati.
; "pulse"
global CombatPulseCycle  := 1200   ; ms per un respiro completo
global CombatPulseSize   := 18     ; quanto si allarga l'alone (px)
global CombatPulseOpacity  := 0.5    ; intensità (0..1)
global CombatPulseColor  := "F8FE01"
; "ring"
global CombatRingCycle   := 1400   ; ms di vita di un'onda
global CombatRingCount   := 2      ; onde presenti insieme (sfasate)
global CombatRingDistance  := 32     ; px percorsi dall'onda prima di svanire
global CombatRingThickness := 4      ; spessore dell'anello (px)
global CombatRingOpacity := 0.9    ; intensità (0..1)
global CombatRingColor   := "FDBE02"
; "spin"
global CombatSpinCycle   := 800    ; ms per un giro completo
global CombatSpinArc     := 120    ; lunghezza dell'arco con la scia (gradi, 360 = cerchio intero)
global CombatSpinThickness := 10      ; spessore dell'arco (px)
global CombatSpinColor   := "FFFFFF"
; "glow"
global CombatGlowCycle   := 1000   ; ms per una pulsazione
global CombatGlowColor   := "FFFFFF"
global CombatGlowAmount  := 0.3    ; intensità (0..1)

; ---- Accensione e spegnimento dell'icona Loot ----
; Accensione/spegnimento delle icone
global LootMorphInTime      := 0.15   ; s per accendere gli effetti
global LootMorphOutTime     := 0.6    ; s per spegnere gli effetti
global LootFadeOutTime      := 0.8    ; s di dissolvenza dell'icona quando torna inattiva
global LootColorFadeOutTime := 0.5    ; s per sfumare dal colore attivo a quello inattivo

; ---- Accensione e spegnimento dell'icona Combat ----
; Accensione/spegnimento delle icone
global CombatMorphInTime    := 0.15   ; s per accendere gli effetti
global CombatMorphOutTime   := 0.6    ; s per spegnere gli effetti
global CombatFadeOutTime    := 0.8    ; s di dissolvenza dell'icona quando torna inattiva
global CombatColorFadeOutTime := 0.5    ; s per sfumare dal colore attivo a quello inattivo

; ------------------------------------------------------------------------------
; [HUD] Transizioni generali (mirino e barre)
; ------------------------------------------------------------------------------
global AnimInterval     := 16     ; ms tra un fotogramma e l'altro di tutte le animazioni (16 ≈ 60 fps)
                                  ; (usato solo con PerfProfile "manuale", vedi [PRESTAZIONI])
global FadeInTime       := 0.3    ; s di dissolvenza quando l'HUD compare
global FadeOutTime      := 3.0    ; s di dissolvenza quando l'HUD torna inattivo
global FadeEasing       := true   ; true = dissolvenze morbide (partono e finiscono rallentando)
global ColorFadeInTime  := 0      ; s per passare al colore attivo (0 = istantaneo)
global ColorFadeOutTime := 1.5    ; s per sfumare verso il colore inattivo

; Dissolvenze accese/spente per ogni elemento.
; Con una dissolvenza spenta l'elemento appare/resta pienamente visibile, senza sfumare.
;                               in entrata                    in uscita
global EnableCrosshairFadeIn := true,  EnableCrosshairFadeOut := true    ; mirino
global EnableBar1FadeIn      := true,  EnableBar1FadeOut      := true    ; barra 1
global EnableBar2FadeIn      := true,  EnableBar2FadeOut      := true    ; barra 2
global EnableLootFadeIn  := true,  EnableLootFadeOut  := true    ; icona Loot
global EnableCombatFadeIn := true, EnableCombatFadeOut := true    ; icona Combat

; ------------------------------------------------------------------------------
; [TOOL 1] HIDDEN CUBE
;   Cosa fa: quando compare la finestra di apertura degli Hidden Cube, porta il mouse
;   sul pulsante "Open with Key". Con il blocco attivo il mouse resta lì finché la
;   finestra è aperta, così non manchi il pulsante. Il click lo fai tu (oppure AutoClick).
;   Plug&play: funziona a qualsiasi risoluzione, senza calibrazione.
;   Riconoscimento: controlla pochi punti di colore (pulsante dorato, "Cancel" blu,
;   slot turchese della chiave). Accensione/spegnimento in gioco: Ctrl+Shift+1.
; ------------------------------------------------------------------------------
global HiddenCubeEnabled    := true    ; true = attivo all'avvio dello script
global HiddenCubeInterval   := 100     ; ms tra un controllo e l'altro mentre aspetta la finestra
                                       ; (usato solo con PerfProfile "manuale", vedi [PRESTAZIONI])
global HiddenCubeCheckSlot  := true    ; true = richiede anche lo slot turchese della chiave
                                       ; (evita di scattare su altri popup con pulsanti simili)
; Punto del mouse
global HiddenCubeOffsetX    := 0       ; correzione fine del punto (px misurati in 4K, si adattano da soli)
global HiddenCubeOffsetY    := 0       ; es. HiddenCubeOffsetY := -10 = un po' più in alto
; Blocco del mouse
global HiddenCubeLockMouse  := true    ; true  = finché la finestra è aperta il mouse viene riportato
                                       ;         sul pulsante appena si sposta (blocco)
                                       ; false = il mouse viene spostato una volta sola, poi è libero
global HiddenCubeLockInterval := 15    ; ms tra un controllo e l'altro durante il blocco
                                       ; (più basso = blocco più rigido, 30-50 = più morbido)
                                       ; (usato solo con PerfProfile "manuale", vedi [PRESTAZIONI])
global HiddenCubeRearmTime  := 400     ; ms in cui la finestra deve restare chiusa prima che il tool
                                       ; si riattivi per la successiva (evita doppi scatti)
; Click automatico
global HiddenCubeAutoClick  := false   ; true = dopo lo spostamento clicca anche "Open with Key"
                                       ; (se il gioco blocca i click simulati non ha effetto)
global HiddenCubeClickDelay := 50      ; ms tra lo spostamento e il click (solo con AutoClick)
global HiddenCubeDebug      := false   ; true = avviso a schermo ogni volta che la finestra viene riconosciuta

; ------------------------------------------------------------------------------
; [TOOL 2] FIELD BOSS   (richiede OCR.ahk nella stessa cartella)
;
;   Cosa fa, passo per passo:
;    1. Apri la mappa (M). Il mouse resta libero. Se scegli un boss quando la lista
;       Field Boss non è a schermo, il cursore va su "Exploration" e poi su "Field Boss"
;       (clicchi tu), poi la ricerca continua.
;    2. Sul lato destro compare il pannello con tutti i boss in ordine A-Z:
;         colore della barra/nome = grado          simbolo = importanza
;         ● rosso = attivo (Spawned)               ○ grigio = non attivo (Time Left)
;       In alto ci sono i filtri per grado e per stato (clic per accenderli/spegnerli).
;       Il pulsante ▲/▼ riduce/riapre il pannello.
;    3. Clicchi un boss nel pannello: lo script lo trova nella lista del gioco (anche se
;       è più in basso, scrollando da solo) e ci porta il cursore. Clicchi tu il nome.
;    4. La mappa si centra sul boss: lo script trova il Teleport (icona viola) più vicino
;       e ci porta il cursore. Se la mappa è troppo zoomata e non ne vede, fa zoom indietro
;       e ti fa cliccare un punto vuoto per chiudere il riquadro dei loot che li copre.
;       Clicchi tu il Teleport, poi premi F per il Travel.
;
;   Perché "clicchi tu": AION 2 blocca click e tasti simulati, quindi lo script può
;   solo spostare il cursore. Gli stati attivo/non attivo si aggiornano quando i boss
;   sono visibili nella lista del gioco.
;   Il pannello e la leggenda compaiono SOLO con la mappa aperta (riconosciuta dai tab
;   Kibelisk / Map Pin). Esc annulla in ogni momento. Accensione/spegnimento: Ctrl+Shift+2.
; ------------------------------------------------------------------------------
global FieldBossEnabled      := true     ; true = attivo all'avvio dello script
global FieldBossGuideOnOpen  := false    ; true = all'apertura della mappa porta subito il cursore su
                                         ; Exploration > Field Boss; false = mouse libero (consigliato)
global FieldBossHideInDungeon := true    ; true = nei dungeon (mappa senza i tab Exploration / Map Pin, oppure
                                         ; con il nome di un dungeon nel titolo) il pannello dei boss non compare
global FieldBossDungeons     := "Krao Cave|Draupnir|Urugugu Canyon|Vakron Sky Island|Fire Temple|Ferocious Horn"
                                         ; nomi dei dungeon (come nel titolo "Map: ..."), separati da |.
                                         ; Basta l'inizio del nome. Aggiungi qui i dungeon nuovi.

; Fasi di click (dopo la scelta di un boss: Exploration, Field Boss, nome del boss,
; punto vuoto per chiudere i loot, Teleport). Lo script porta il cursore sul punto giusto,
; tu clicchi: come in un minigioco, con un'istruzione grande in basso al centro.
global FieldBossLockMouse    := true     ; true  = appena scegli un boss il mouse si blocca: lo muove solo lo
                                         ;         script e in ogni fase resta fermo sul punto da cliccare
                                         ;         (non puoi mancarlo). Si sblocca dopo il Travel (doppia F),
                                         ;         con Esc, chiudendo la mappa o passando a un'altra finestra.
                                         ; false = il cursore viene portato sui punti ma resta libero
global FieldBossBlockClicks  := true     ; true  = dalla scelta del boss fino al Travel i click (sinistro e destro)
                                         ;         arrivano al gioco SOLO nelle fasi in cui devi cliccare;
                                         ;         nelle altre vengono bloccati, così non sbagli nulla.
                                         ;         Tutto si sblocca dopo il Travel (F premuto le volte
                                         ;         indicate sotto), con Esc, o chiudendo la mappa.
                                         ;         Il pannello Field Boss resta sempre cliccabile.
                                         ; false = nessun blocco dei click
global FieldBossHints        := true     ; true = istruzioni grandi in basso al centro + anello sul punto
                                         ; false = piccoli tooltip vicino al cursore (come prima)
global FieldBossHintScale    := 1.0      ; dimensione del riquadro delle istruzioni (1.0 = normale)
global FieldBossHintBottom   := 130      ; distanza dal bordo inferiore dello schermo (px a 1440p)

; Direzione del boss dopo il Teleport: quando premi F (Travel) e la mappa si chiude, in alto
; al centro compare per qualche secondo una freccia grande con la direzione in cui volare
; per raggiungere il boss, calcolata dalla posizione del Teleport rispetto al boss sulla mappa.
; La direzione è quella della mappa (Nord = in alto), come la bussola della minimappa.
global FieldBossDirHint      := true     ; false = nessuna indicazione
global FieldBossDirSeconds   := 25       ; per quanti secondi resta a schermo (con conto alla rovescia)
global FieldBossDirDelay     := 3333        ; ms di attesa dopo la chiusura della mappa prima di mostrarla
                                         ; (alzalo, es. 3000, se il caricamento del Teleport la copre)
global FieldBossDirTop       := 110      ; distanza dal bordo superiore dello schermo (px a 1440p)
global FieldBossDirScale     := 1.0      ; dimensione (1.0 = normale)
global FieldBossTravelWait   := 15       ; secondi in cui aspetta che tu prema F dopo il click sul Teleport
global FieldBossTravelPresses := 2       ; quante volte va premuto F per partire (2 = doppia pressione).
                                         ; Raggiunto questo numero il Teleport è considerato fatto:
                                         ; click sbloccati e indicazione della direzione.

; Pannello
global FieldBossPanelScale   := 1.45     ; dimensione: 1.0 piccolo | 1.3 medio | 1.6 grande
global FieldBossPanelMarginR := 500      ; distanza dal bordo destro (px a 1440p). Il valore attuale
                                         ; lascia libero il riquadro dei drop che il gioco apre a destra.
global FieldBossPanelOffsetY := 0        ; spostamento dal centro verticale (px a 1440p, + = più giù)
global FieldBossStartCollapsed := false  ; true = all'avvio il pannello è ridotto alla barra del titolo

; Cosa fa il pannello quando scegli un boss:
;   "fade"     = diventa quasi trasparente; torna opaco quando ci ripassi sopra col mouse
;   "collapse" = si riduce alla barra del titolo (riapribile con ▼)
;   "none"     = resta com'è
; In ogni caso, chiudendo e riaprendo la mappa il pannello torna aperto e opaco.
; (Se invece lo riduci tu con ▲, resta ridotto finché non lo riapri.)
global FieldBossPickAction   := "collapse"
global FieldBossFadeAlpha    := 100      ; opacità in modalità "fade" (0 invisibile ... 255 opaco)

; Leggenda dei tasti: barra in cima allo schermo con HUD, Hidden Cube e Field Boss ON/OFF,
; tasto delle Impostazioni ed Esc. Compare con la mappa aperta anche se il tool Field Boss è spento (OFF).
global FieldBossShowLegend   := true     ; false = leggenda nascosta
global FieldBossLegendScale  := 1.0      ; dimensione (1.0 = normale)
global FieldBossLegendY      := 10       ; distanza dal bordo superiore (px a 1440p).
                                         ; Non superare ~25: sotto ci sono i tab che lo script legge.
global FieldBossLegendAlpha  := 215      ; opacità (0 invisibile ... 255 opaca)

; Ricerca del boss e del Teleport
global FieldBossListScroll   := 36       ; scrollate necessarie per andare da un capo all'altro della
                                         ; lista boss del gioco. Troppe = il gioco fa un "beep" a fine
                                         ; lista; troppo poche = i boss in fondo non vengono trovati.
global FieldBossFindTeleport := true     ; true = dopo il click sul boss cerca il Teleport più vicino
global FieldBossAutoZoomOut  := true     ; true = se sulla mappa non c'è nessun Teleport, fa zoom indietro
                                         ; centrato sul boss (e riduce il pannello per non coprire la mappa)
global FieldBossZoomOut      := 7        ; scrollate di zoom indietro...
global FieldBossZoomBack     := 1        ; ...e poi in avanti: allo zoom minimo i Teleport spariscono
global FieldBossZoomOutWheel := "WheelDown"  ; direzione della rotellina che fa zoom INDIETRO sulla mappa
                                             ; ("WheelDown" o "WheelUp")

; Pannello dei loot del gioco: quando selezioni un boss il gioco apre a destra il riquadro
; con i drop, che può coprire il Teleport più vicino. Per chiuderlo basta un click su un
; punto vuoto della mappa (un click semplice non sposta la mappa).
; Lo script porta il cursore su un punto vuoto accanto all'icona del boss (grigia o rossa),
; aspetta il TUO click (il gioco blocca i click simulati) e SOLO DOPO cerca il Teleport.
;   "zoom"   = solo quando ha dovuto fare lo zoom indietro (casi come Vishwada, Lagta)
;   "always" = ogni volta, prima di cercare il Teleport
;   "never"  = mai
global FieldBossCloseLoot    := "zoom"
global FieldBossLootClickDist := 90      ; distanza del punto vuoto dall'icona del boss (px a 1440p).
                                         ; Lo script sceglie da solo la direzione libera da altre icone
                                         ; (prima a sinistra, poi in basso, ecc.).
global FieldBossCheckEvery   := 300      ; ms tra un controllo "mappa aperta?" e l'altro.
                                         ; Più basso = pannello e leggenda più reattivi (un po' più CPU).
                                         ; (usato solo con PerfProfile "manuale", vedi [PRESTAZIONI])

; Elenco boss (Altgard). L'ordine non conta: il pannello li ordina dalla A alla Z.
;   Nome:        come appare nel gioco (anche se il gioco lo tronca con "...", scrivilo intero)
;   Grado:       "verde" | "blu" | "oro"  = colore della prima icona dei drop del boss
;   Importanza:  0 = nessun simbolo
;                1 = 👑 massima   2 = 💎 superiore   3 = 🔥 importante   4 = ⭐ minore
;   Per aggiungere un boss: copia una riga, cambia i valori, lascia la virgola alla fine
;   (tranne l'ultima riga della lista).
;    Nome boss                            Grado     Importanza
global FieldBossList := [
    ["Black Warrior Aed",                 "verde",  0],
    ["Berserker Vargor",                  "verde",  0],
    ["Blood Warrior Lannar",              "verde",  0],
    ["Faithful Rajit",                    "verde",  0],
    ["Melted Danar",                      "verde",  0],
    ["High Overseer Nutah",               "blu",    0],
    ["Blue Wave Kelpina",                 "blu",    0],
    ["Deceiver Trid",                     "blu",    0],
    ["Predator Garsan",                   "blu",    0],
    ["Addicted Hardirun",                 "blu",    0],
    ["Special Operations Leader Linx",    "blu",    0],
    ["Advisor Resana",                    "blu",    0],
    ["Veteran Shujakan",                  "blu",    0],
    ["Immortal Gartua",                   "oro",    1],
    ["High Commander Lagta",              "oro",    2],
    ["Silent Dartan",                     "oro",    3],
    ["Soul Ruler Kashapa",                "oro",    3],
    ["Sharp Shylak",                      "oro",    3],
    ["Dark Shadow Vishwada",              "oro",    3],
    ["Drakan Battalion Weapon Guruta",    "oro",    3],
    ["Desecrator Newbold",                "oro",    4],
    ["Visionary Karuka",                  "oro",    4],
    ["Specter Archon Axios",              "oro",    4],
    ["Executioner Barthien",              "oro",    4]
]
; Aspetto avanzato del pannello (colori dei gradi, simboli di importanza e di stato,
; coordinate di riferimento, tempi interni): in fondo allo script, classe FieldBossTool.
; Di solito non serve toccarlo.

; ==============================================================================
; ===                          FINE CONFIG                                   ===
; ==============================================================================

; ==============================================================================
; === COSTRUZIONE HUD ===
; ==============================================================================

global ChevPi   := 3.14159265358979
global GameActive := ""                  ; ultimo stato "gioco in primo piano" (per avviare/fermare i tool)
global HudShown := false                 ; true quando il gioco è in primo piano e l'HUD è visibile
global HudBuilding := false              ; true mentre BuildHud ricostruisce le finestre dell'HUD

; Profilo prestazioni: sovrascrive i cicli in ms con quelli del profilo scelto ([PRESTAZIONI])
; Variabili gestite dai profili, nello stesso ordine dei valori qui sotto
global PerfVars := ["AnimInterval", "HiddenCubeInterval", "HiddenCubeLockInterval", "FieldBossCheckEvery"
                  , "PerfWorkerTick", "PerfLockTick", "PerfPollMs", "PerfRingTick", "PerfOcrQuality"]

; Valori di un profilo ("" se il profilo è "manuale" o sconosciuto)
PerfProfileValues(profile) {
    static P := Map(   ;  HUD   Cubo  BloccoC  Mappa  Lavoro  BloccoM  Attese  Anello  OCR
        "potato",      [50,   300,   50,     1000,  120,    40,      30,     80,     1.5],
        "base",        [33,   200,   30,      600,   80,    25,      20,     60,     1.75],
        "bilanciato",  [16,   100,   15,      300,   50,    15,      15,     50,     2],
        "performante", [11,    60,   10,      200,   30,    10,      10,     33,     2.25],
        "gigachad",    [7,     30,    5,      120,   15,     5,       5,     16,     2.5])
    key := StrLower(Trim(profile))
    return P.Has(key) ? P[key] : ""
}

ApplyPerfProfile() {
    vals := PerfProfileValues(PerfProfile)
    if !IsObject(vals)                       ; "manuale": restano i valori scritti nella CONFIG
        return
    for i, name in PerfVars
        SetGlobalVar(name, vals[i])
}

; Riavvia i timer già in corso con i cicli attuali (dopo un cambio di profilo dall'anteprima)
RestartPerfTimers() {
    if (Ticker.Items.Count)
        SetTimer(Ticker.Fn, AnimInterval)
    if (IsSet(HiddenCube) && IsObject(HiddenCube) && HiddenCube.Running)
        SetTimer(HiddenCube.Fn, (HiddenCube.Seen && HiddenCubeLockMouse) ? HiddenCubeLockInterval : HiddenCubeInterval)
    if (IsSet(FieldBoss) && IsObject(FieldBoss) && FieldBoss.Running)
        SetTimer(FieldBoss.WorkFn, PerfWorkerTick)
}

LegacyCleanup()                              ; via le copie col vecchio nome "AION 2 Wingman 1.0.ahk"
UserData.Restore()                           ; impostazioni personali (anche dopo un aggiornamento dello script)
ApplyPerfProfile()

; ==============================================================================
; === TEMI DEI COLORI ===
; ==============================================================================
; Ogni tema ha i colori delle interfacce (UI) e, tranne "principale" e "custom", anche
; quelli dell'HUD. UiC("ruolo") e HudC("NomeVariabile") restituiscono il colore giusto:
; così cambiare tema non tocca i colori scritti nella CONFIG.
global ThemeRoles := ["Bg", "Row", "Hover", "Line", "Accent", "Text", "SubText", "Muted", "Deep", "Go", "Wait", "Ok", "Err", "Info"
                    , "WinBg", "WinText", "WinSub", "WinField"]
global ThemeHudVars := ["ColorActive", "ColorIdleCombat", "ColorIdleLoot", "CombatIdleColor", "ColorBorder"
                      , "LootPulseColor", "LootRingColor", "LootSpinColor", "LootGlowColor"
                      , "LootTextColor", "LootOutlineColor", "CombatTextColor", "CombatOutlineColor"]
global ThemeUi := Map(), ThemeHud := Map()

ThemeDefs() {
    ;            Bg     Row    Hover  Line   Accent Text   SubTxt Muted  Deep   Go     Wait   Ok     Err    Info   WinBg  WinTxt WinSub WinFld
    static U := Map(
        "principale", "14171C 1E232B 2C3440 2E3540 E8D9A8 FFFFFF C9CED6 8A93A0 0B0E13 F2B84B 4FA3FF 5FD068 FF5A4F 7FD4FF F4F5F7 1B1F26 555D6B FFFFFF",
        "dark",       "0B0B0D 17181C 25262D 2A2C33 F5F5F5 FFFFFF B8BCC6 6B7080 050506 FFC857 5AA9FF 4ADE80 F87171 93C5FD 17181C EDEEF2 9AA0AC 202127",
        "bright",     "F7F8FA EDEFF3 DCE3EC D3D8E0 1F2937 111827 4B5563 9CA3AF FFFFFF D97706 2563EB 16A34A DC2626 0284C7 FFFFFF 111827 6B7280 F9FAFB",
        "cuddle",     "FFF4F0 FCE8E3 F9D5D3 F2C9C9 B5687A 5B3A47 8C6873 C3A3AC FFF9F5 F4A261 7FB3F5 6CC48A F28B82 8FB8FF FFF8F5 5B3A47 9C7A85 FFFFFF",
        "pinkhaze",   "241726 33203A 4A2D52 4D3352 FFB3D9 FFE9F5 E3B7D0 9C7A93 1A0F1C FF8FC7 B39DFF 9EF0C8 FF6B8B D6A4FF 2B1C2E F8E6F1 C9A3BC 382440",
        "egirl",      "0E0A0F 1C1220 2E1A33 3A2140 FF4FA3 FFFFFF FFB6DA 8A6A82 000000 FF4FA3 9B5CFF 5CFFB1 FF3B6B FF8AD8 140D16 FDEFF7 E39CC2 21142A",
        "vi",         "1A0B2E 2A1240 3D1A5C 4A2470 FFB347 FFFFFF FFC9E3 9A7FB8 12061F FF7A00 2DE2E6 3DFFB8 FF2A6D 2DE2E6 1F0E33 FFEAF5 D9A6E0 2B1546",
        "gladiator",  "1A0E0C 2A1714 3D211C 4A2A22 E0B060 FFFFFF E8C9B8 9A7D72 120806 FF5A36 4FA3FF 5FD068 FF2E2E FFB060 1C110F F5E8E2 B89A8E 2A1915",
        "templar",    "101828 1A2438 26334D 2E3D5A F5D27A FFFFFF D8DFEA 8C97AB 0A101C F5D27A 6FA8FF 5FD068 FF5A4F BFE0FF F2F5FA 14203A 5A6A85 FFFFFF",
        "assassin",   "0D0A12 19131F 2A1F33 30243B B57CFF EDE6F7 BFAFD6 6E6382 06040A 9CFF5C 8A7BFF 9CFF5C FF4D6D C08CFF 120E18 EDE6F7 9C8FB5 1C1626",
        "ranger",     "0F1A10 182A1A 233D26 2C4A2F C9E07A F2F7EA C2D6B4 7E9472 081009 C9E07A 7FB8FF 8FE070 E06A4A A8D88A EEF4E6 1B2A1C 5F7A5A FFFFFF",
        "sorcerer",   "0B0F24 141A38 202A55 28335F 7FD4FF F0F4FF B8C4EC 7280B0 060818 FF8A3D 7FD4FF 6CE0B0 FF5A6E A78BFF 0F1430 EEF2FF 8E9AC8 18204A",
        "spiritmaster", "0C1A1A 132828 1D3A3A 244545 7FFFD4 E8FFFA B0D8D0 6A9690 061010 FFC24D 6FD0FF 7FFFD4 FF6A5A C4A0FF 0F2020 E6FAF6 86B0AA 173030",
        "cleric",     "FBFAF4 F2EFE2 E6E0C8 DDD5B8 B8902E 2A2618 5E5840 A89E80 FFFFFF D9A520 4A90D9 3CB371 D9534F 6CC3A0 FFFFFF 2A2618 7A7258 FFFDF6",
        "chanter",    "1A1408 2A2010 3D2E16 4A3A1C FFD45C FFF8E6 E6D3A8 9E8A62 100C04 FFB020 6FB0FF 7FE07A FF6050 FFE08A 1E180C FFF4DC B8A27A 2C2414",
        ; eventi e festività
        "halloween",  "140A1A 22122A 34203F 3A2546 FF8C1A FFF4E6 E8C9A8 8F7A8F 0A0510 FF8C1A 9B6BFF 7CFF5C FF3B3B B98CFF 1A0F22 FFEBD6 C9A98A 26162F",
        "natale",     "0E1A12 16281C 21382A 2A4433 F2C14E FFFFFF D8E8DC 7F9A88 07100A F2C14E 6FB7FF 4CD47A E2363C F5E6A8 F7F3EA 1C2A20 5E7466 FFFFFF",
        "capodanno",  "0B0B12 16161F 24243A 2A2A3A FFD700 FFFFFF D9D9E6 85859A 05050A FFD700 7FB2FF 6EE7A0 FF5C7A E0C3FF 12121A F2F2F7 A8A8BC 1C1C28",
        "sanvalentino", "1F0A12 2E101C 45182B 4F1E31 FF5C8A FFF0F4 F5C2D2 A07A88 14060B FF5C8A FF9EC4 7FE0A8 FF2E4D FFB3CF 25101A FFE8EF D99AAE 351421",
        "carnevale",  "1A0E2E 28164A 3A2066 452878 FFD23F FFFFFF E0D0FF 9488B8 0F0820 3BCEAC 7C5CFF 3BCEAC EE4266 FFD23F 20123A FFF6E0 C4B0F0 2E1A55",
        "pasqua",     "FFFBEF FDF3D8 F8E6B8 F0DDB0 8E6CC4 3F3550 6E6280 B3A8C2 FFFFFF F4A63A 7EB6F5 6CC48A F07A7A A88BE0 FFFDF5 3F3550 857A96 FFFFFF",
        "sanpatrizio", "0B1A10 12281A 1B3A25 22462D 7CFC6A F2FFF0 C8E8C0 7E9A78 06100A FFC94D 6FC2FF 7CFC6A FF6A5A D9B86A 0F2016 EBF8E6 8BAA84 163020")
    ;            Active IdleCmb IdleLoot IdleAC Border Pulse  Ring   Spin   Glow   LootTxt LootOut ACTxt ACOut
    static H := Map(
        "principale", "Lime Red CC4400 064FC6 Black F8FE01 FDBE02 FFFFFF FFFFFF White Black White Black",
        "dark",       "00E5FF 3A3F4B 4B3A2A 2A3A55 000000 00E5FF 00E5FF FFFFFF 00E5FF FFFFFF 000000 FFFFFF 000000",
        "bright",     "FFD400 F2F4F7 FFB37A 9CC3FF 1F2937 FFE680 FFFFFF FFD400 FFF3B0 111827 FFFFFF 111827 FFFFFF",
        "cuddle",     "FFB5C5 FFE5D9 FFD6A5 CDE7FF 7A5560 FFC8DD BDE0FE FFAFCC FFF1E6 5B3A47 FFFFFF 5B3A47 FFFFFF",
        "pinkhaze",   "FF6EC7 5B3A5E 7A4A6A 4E3F7A 1A0F1C FF9AD5 D6A4FF FFFFFF FF6EC7 FFFFFF 2A1030 FFFFFF 2A1030",
        "egirl",      "FF2E97 3D1F33 5A2347 3A1F5A 000000 FF7AC6 FF2E97 FFFFFF FF4FA3 FFFFFF 000000 FFFFFF 000000",
        "vi",         "FF2A6D 3B1E5C 6B2E1A 0E4A5C 12061F FF7A00 2DE2E6 FFB347 FF2A6D FFFFFF 12061F FFFFFF 12061F",
        "gladiator",  "FF3B2F 4A2622 5A3A1E 3A2A2A 120806 FF6A3D FF3B2F FFB060 FF3B2F FFFFFF 120806 FFFFFF 120806",
        "templar",    "F5D27A 2E3D5A 6B5A2E 3A4A6A 0A101C FFF2C2 BFE0FF F5D27A FFF2C2 FFFFFF 0A101C FFFFFF 0A101C",
        "assassin",   "9CFF5C 2A1F33 3A2A4A 1F2A1A 06040A B57CFF 9CFF5C C08CFF 9CFF5C FFFFFF 06040A FFFFFF 06040A",
        "ranger",     "8FE070 2C4A2F 5A4A2A 2A3A2A 081009 C9E07A 8FE070 F2F7EA A8D88A FFFFFF 081009 FFFFFF 081009",
        "sorcerer",   "4FC3FF 1E2550 4A2A1A 2A2A5A 060818 A78BFF 4FC3FF FF8A3D 7FD4FF FFFFFF 060818 FFFFFF 060818",
        "spiritmaster", "3DFFD0 1D3A3A 3A3A1E 2A2A4A 061010 C4A0FF 3DFFD0 FFC24D 7FFFD4 FFFFFF 061010 FFFFFF 061010",
        "cleric",     "FFE27A F4EFD8 FFE9B0 D8F0E4 6B5A2A FFF6C8 FFFFFF FFE27A FFFBE0 3A3218 FFFFFF 3A3218 FFFFFF",
        "chanter",    "FFB020 3D2E16 5A3A10 2A3A2A 100C04 FFE08A FFB020 FFF8E6 FFD45C FFFFFF 100C04 FFFFFF 100C04",
        "halloween",  "FF8C1A 3A2546 5A2E0A 2E1F4A 0A0510 FFB347 9B6BFF FF8C1A FFB347 FFFFFF 0A0510 FFFFFF 0A0510",
        "natale",     "E2363C 21382A 5A1A1C 1E3A2A 07100A F2C14E 4CD47A FFFFFF F2C14E FFFFFF 07100A FFFFFF 07100A",
        "capodanno",  "FFD700 24243A 4A3A10 2A2A4A 05050A FFF0A0 E0C3FF FFFFFF FFD700 FFFFFF 05050A FFFFFF 05050A",
        "sanvalentino", "FF2E63 45182B 5A1A2A 3A1A3A 14060B FF8FB1 FF5C8A FFFFFF FF8FB1 FFFFFF 14060B FFFFFF 14060B",
        "carnevale",  "FFD23F 3A2066 6A2A50 1F4A44 0F0820 EE4266 3BCEAC FFD23F 7C5CFF FFFFFF 0F0820 FFFFFF 0F0820",
        "pasqua",     "B8E986 FFF3C4 FFD6E0 D6EFFF 6E6280 FFE38A C7B3FF FFFFFF FFF3C4 3F3550 FFFFFF 3F3550 FFFFFF",
        "sanpatrizio", "3DDC5A 1B3A25 4A3A12 1E3A2A 06100A A8FF8A 3DDC5A FFC94D 7CFC6A FFFFFF 06100A FFFFFF 06100A")
    ; Temi di classe e di eventi: forme e personalizzazioni uniche (sostituiscono quelle delle sezioni [HUD])
    ;   mirino OFF | mirino ON | animazione | frecce | ciclo ms | icona Loot | icona Combat | effetti | emoji loot | emoji combat
    static K := Map(
        "principale",   "freccia|freccia|pulse|3|500|quadrato|triangolo|ring,pulse,spin|👋🏻|⚔️",
        "gladiator",    "barra|blocco|march|3|600|quadrato|trapezio|pulse,ring|💰|🪓",
        "templar",      "rombo|triangolo|pulse|2|1400|trapezio|quadrato|glow,ring|🏆|🛡️",
        "assassin",     "freccia|barra|sequence|4|450|rettangolo|triangolo|spin|💎|🗡️",
        "ranger",       "freccia|freccia|march|5|700|triangolo|trapezio|ring,spin|🍃|🏹",
        "sorcerer",     "cerchio|rombo|pulse|3|1100|cerchio|triangolo|spin,glow,pulse|🔮|🔥",
        "spiritmaster", "rombo|cerchio|sequence|4|900|cerchio|cerchio|pulse,spin|✨|🌀",
        "cleric",       "cerchio|cerchio|pulse|2|1600|quadrato|cerchio|glow,pulse|🪙|💖",
        "chanter",      "triangolo|blocco|march|3|800|trapezio|rettangolo|ring,glow|🎁|🎶",
        ; eventi e festività
        "halloween",    "triangolo|triangolo|pulse|3|900|cerchio|triangolo|pulse,glow|🎃|👻",
        "natale",       "rombo|freccia|sequence|3|800|cerchio|triangolo|spin,glow|🎁|🎄",
        "capodanno",    "cerchio|rombo|pulse|4|700|cerchio|rettangolo|ring,spin,glow|🥂|🎆",
        "sanvalentino", "freccia|cerchio|pulse|2|1300|cerchio|cerchio|pulse,glow|💝|💘",
        "carnevale",    "rombo|blocco|sequence|5|500|trapezio|rettangolo|spin,ring,pulse|🎭|🎉",
        "pasqua",       "cerchio|triangolo|pulse|3|1500|cerchio|trapezio|glow,pulse|🥚|🐣",
        "sanpatrizio",  "freccia|rombo|march|3|750|cerchio|trapezio|ring,glow|🍀|🍺")
    return {U: U, H: H, K: K}
}

; Cosa decide un tema (e cosa si salva in un tema personalizzato): colori dei pannelli,
; colori dell'HUD, forme e animazione del mirino, forme, effetti ed emoji delle icone.
global ThemeLookVars := ["ChevronShapeOff", "ChevronShapeOn", "ChevronAnimMode", "ChevronCount", "ChevronAnimCycle"
                       , "LootShape", "CombatShape", "LootAnim", "LootEmoji", "CombatEmoji"]
ThemeKeys() {
    static k := ""
    if !IsObject(k) {
        k := []
        for r in ThemeRoles
            k.Push("ThemeColor" r)
        for v in ThemeHudVars
            k.Push(v)
        for v in ["CombatPulseColor", "CombatRingColor", "CombatSpinColor", "CombatGlowColor"]
            k.Push(v)
        for v in ThemeLookVars
            k.Push(v)
        k.Push("CombatAnim")
        k.Push("ViCountdown")
    }
    return k
}

; Temi pronti, nell'ordine dell'elenco (i temi salvati vanno prima di "custom", che è sempre l'ultimo)
; (funzione e non variabile: serve già quando le Impostazioni vengono lette all'avvio, prima di questa sezione)
ThemeBuiltin() {
    static l := ["principale", "dark", "bright", "cuddle", "pinkhaze", "egirl", "vi"
        , "gladiator", "templar", "assassin", "ranger", "sorcerer", "spiritmaster", "cleric", "chanter"
        , "halloween", "natale", "capodanno", "sanvalentino", "carnevale", "pasqua", "sanpatrizio"]
    return l
}
global ThemeEvents := Map("halloween", 1, "natale", 1, "capodanno", 1, "sanvalentino", 1, "carnevale", 1, "pasqua", 1, "sanpatrizio", 1)

; nomi dei temi salvati dall'utente (%AppData%\AION 2 Wingman\themes.ini, una sezione per tema)
UserThemes() {
    out := []
    try for name in StrSplit(IniRead(UserData.Themes), "`n")
        if (Trim(name) != "")
            out.Push(name)
    return out
}

; Valori del tema t, scritti come nella CONFIG ("FF0000" tra virgolette, ["ring", "pulse"], 3).
; Tema pronto: tutti (non cambiano mai). Tema dell'utente ("user:Nome"): quelli salvati nel suo file. "custom": nessuno.
; Un tema dell'utente in uso vive nelle impostazioni (si modifica dal vivo e "Salva e riavvia" aggiorna anche il tema).
ThemeOverrides(t) {
    out := Map(), d := ThemeDefs(), t := Trim(t), tl := StrLower(t)
    if (SubStr(tl, 1, 5) = "user:") {
        name := SubStr(t, 6)
        for v in ThemeKeys() {
            x := ""
            try x := IniRead(UserData.Themes, name, v, "")
            if (SubStr(x, 1, 2) = "v:")                  ; il prefisso protegge le virgolette dei testi
                out[v] := SubStr(x, 3)
        }
        return out
    }
    if (tl = "custom")
        return out
    out["ViCountdown"] := tl = "vi" ? "true" : "false"   ; easter egg GTA VI: acceso solo col tema "vi"
    for i, c in StrSplit(d.U.Has(tl) ? d.U[tl] : d.U["principale"], " ")
        out["ThemeColor" ThemeRoles[i]] := '"' c '"'
    ; ogni tema pronto decide tutto: quello che non definisce lo prende dal tema classico "principale"
    for i, c in StrSplit(d.H.Has(tl) ? d.H[tl] : d.H["principale"], " ")
        out[ThemeHudVars[i]] := '"' c '"'
    k := StrSplit(d.K.Has(tl) ? d.K[tl] : d.K["principale"], "|")
    for i, name in ThemeLookVars {
        if (name = "LootAnim") {
            lst := ""
            for a in StrSplit(k[i], ",")
                lst .= (lst = "" ? "" : ", ") '"' Trim(a) '"'
            out[name] := "[" lst "]"
        } else
            out[name] := (i = 4 || i = 5) ? k[i] : '"' k[i] '"'
    }
    for x in ["PulseColor", "RingColor", "SpinColor", "GlowColor", "Anim"]   ; il tema vale per entrambe le icone
        if out.Has("Loot" x)
            out["Combat" x] := out["Loot" x]
    return out
}

; testo della CONFIG -> valore ("abc" -> abc, ["a", "b"] -> array, 3 -> numero)
CfgLiteral(x) {
    x := Trim(x)
    if (SubStr(x, 1, 1) = "[") {
        arr := [], pos := 1
        while (pos := RegExMatch(x, '"([^"]*)"', &m, pos))
            arr.Push(m[1]), pos += m.Len
        return arr
    }
    if (x = "true" || x = "false")
        return x = "true"
    if (StrLen(x) >= 2 && SubStr(x, 1, 1) = '"' && SubStr(x, -1) = '"')
        return StrReplace(SubStr(x, 2, -1), '``"', '"')
    return IsNumber(x) ? x + 0 : x
}

; Prepara i colori del tema scelto (all'avvio e a ogni cambio dalle Impostazioni)
ThemeApply() {
    global ThemeUi := Map(), ThemeHud := Map()
    d := ThemeDefs(), t := Trim(Theme)
    if (StrLower(t) = "custom" || SubStr(StrLower(t), 1, 5) = "user:") {   ; temi modificabili: i valori della CONFIG
        for r in ThemeRoles
            try ThemeUi[r] := Format("{:06X}", ColorToRGB(GetGlobalVar("ThemeColor" r)))
    } else
        for v, x in ThemeOverrides(t) {
            val := CfgLiteral(x)
            if (SubStr(v, 1, 10) = "ThemeColor") {
                try ThemeUi[SubStr(v, 11)] := Format("{:06X}", ColorToRGB(val))
            } else
                ThemeHud[v] := val
        }
    for i, c in StrSplit(d.U["principale"], " ")   ; ruoli mancanti o non validi: tema classico
        if !ThemeUi.Has(ThemeRoles[i])
            ThemeUi[ThemeRoles[i]] := c
}

UiC(role) => ThemeUi.Has(role) ? ThemeUi[role] : "FF00FF"
HudC(name) => ThemeHud.Has(name) ? ThemeHud[name] : GetGlobalVar(name)

ThemeApply()

; valori a scelta fissa scritti a mano con maiuscole ("Pulse"): resi minuscoli come si aspetta il codice
for _n in ["ChevronAnimMode", "ChevronShapeOff", "ChevronShapeOn", "LootShape", "CombatShape", "FieldBossPickAction", "FieldBossCloseLoot"]
    SetGlobalVar(_n, StrLower(Trim(GetGlobalVar(_n))))

global PreviewMode := false              ; true = anteprima dal vivo aperta dalla finestra Impostazioni
global PreviewHudOn := true              ; anteprima: true = HUD attivo (ON), false = HUD inattivo (OFF)
; anteprima: quali elementi mostrare (si scelgono nel menu "Elementi" della finestra Impostazioni)
global PreviewElemOrder := [["crosshair", "Mirino"], ["bar1", "Barra 1"], ["bar2", "Barra 2"], ["loot", "Icona Loot"]
    , ["combat", "Icona Combat"], ["panel", "Pannello Field Boss"], ["legend", "Leggenda dei tasti"]
    , ["hint", "Istruzioni e anello"], ["dir", "Freccia di direzione"], ["vi", "Countdown GTA VI"]]
global PreviewElems := Map()
for _e in PreviewElemOrder
    PreviewElems[_e[1]] := true
PreviewAllows(key) => !PreviewMode || !PreviewElems.Has(key) || PreviewElems[key]
; elementi dell'HUD (creati da BuildHud)
global ChevW := 0, ChevH := 0, ChevCX := 0, ChevCY := 0
global Crosshair := "", ChevronAnim := "", Bar1 := "", Bar2 := "", LootIcon := "", LootFx := ""
global CombatIcon := "", CombatFx := "", AllGroups := "", CombatGroups := "", CombatHUD := "", LootHUD := ""

; L'HUD è costruito da questa funzione, così la finestra Impostazioni può ricostruirlo
; al volo con i nuovi valori (anteprima dal vivo).
BuildHud() {
    global                                   ; tutte le variabili qui sono globali
    Critical "On"                            ; nessun fotogramma durante la ricostruzione
    HudBuilding := true                      ; il cambio di finestra in primo piano (callback) può arrivare anche qui
    DestroyHud()

    ; 1. Mirino centrale (dimensione finestra calcolata per contenere ON, OFF e animazione)
    ChevReachOn  := ChevronGap / 2 + HudC("ChevronCount") * ChevronSpacingOn + ChevronWidthOn * Max(1, ChevronPulseMax)
    ChevReachOff := ChevronGap / 2 + (HudC("ChevronCount") - 1) * ChevronSpacingOff + ChevronWidthOff
    ChevW  := Ceil(2 * Max(ChevReachOn, ChevReachOff)) + 4
    ChevH  := Ceil(Max(ChevronHeightOn * Max(1, ChevronPulseMax), ChevronHeightOff)) + 4
    ChevCX := ChevW / 2
    ChevCY := ChevH / 2

    Crosshair := FadeGroup(EnableCrosshairFadeIn, EnableCrosshairFadeOut)
    Crosshair.PvKey := "crosshair"
    chevWin := NewOverlay(HudC("ColorIdleCombat"), "Combat Chevrons Target")
    ChevronAnim := ChevronHud(chevWin)
    Crosshair.Add(chevWin
        , (A_ScreenWidth - ChevW) // 2 + OffsetX
        , (A_ScreenHeight - ChevH) // 2 + OffsetY
        , ChevW, ChevH, true)

    ; 2-3. Barre inferiori divise al centro
    ;     (una barra disattivata in CONFIG non viene nemmeno creata)
    Bar1 := Bar1Enabled ? BuildSplitBar(Bar1MaxWidth, Bar1MaxHeight, Bar1BorderSize, Bar1OffsetX, Bar1OffsetY, Bar1CenterGap, Bar1Skew, EnableBar1FadeIn, EnableBar1FadeOut) : ""
    Bar2 := Bar2Enabled ? BuildSplitBar(Bar2MaxWidth, Bar2MaxHeight, Bar2BorderSize, Bar2OffsetX, Bar2OffsetY, Bar2CenterGap, Bar2Skew, EnableBar2FadeIn, EnableBar2FadeOut) : ""

    ; 4. Icone di stato (stesso stile, effetti animati): Loot a sinistra, Combat a destra
    al := BuildStatusIcon("Loot", LootOffsetX, LootOffsetY
        , LootTextLine1, HudC("LootEmoji"), LootTextLine3, HudC("ColorIdleLoot"), HudC("LootShape")
        , {font: LootBaseFontSize, emoji: LootEmojiSize
         , l1x: LootLine1OffsetX, l1y: LootLine1OffsetY, ex: LootEmojiOffsetX, ey: LootEmojiOffsetY
         , l3x: LootLine3OffsetX, l3y: LootLine3OffsetY, color: HudC("LootTextColor"), outline: HudC("LootOutlineColor")})
    LootIcon   := al.Group
    LootIcon.PvKey := "loot"
    LootFx := al.Fx

    AllGroups    := [Crosshair]                        ; ordine di visualizzazione
    CombatGroups := [Crosshair]
    for i, bar in [Bar1, Bar2]
        if IsObject(bar)
            bar.PvKey := "bar" i, AllGroups.Push(bar), CombatGroups.Push(bar)
    AllGroups.Push(LootIcon)

    if CombatIconEnabled {
        ac := BuildStatusIcon("Combat", IconMirror ? -LootOffsetX : CombatOffsetX, IconMirror ? LootOffsetY : CombatOffsetY
            , CombatTextLine1, HudC("CombatEmoji"), CombatTextLine3, HudC("CombatIdleColor"), HudC("CombatShape")
            , {font: CombatFontSize, emoji: CombatEmojiSize
             , l1x: CombatLine1OffsetX, l1y: CombatLine1OffsetY, ex: CombatEmojiOffsetX, ey: CombatEmojiOffsetY
             , l3x: CombatLine3OffsetX, l3y: CombatLine3OffsetY, color: HudC("CombatTextColor"), outline: HudC("CombatOutlineColor")})
        CombatIcon := ac.Group
        CombatIcon.PvKey := "combat"
        CombatFx   := ac.Fx
        AllGroups.Push(CombatIcon)
        CombatGroups.Push(CombatIcon)
    }


    ; Canali di input: ogni tasto guida i propri elementi
    CombatHUD   := HudChannel(CombatKey, CombatTimeout, CombatGrace, HudC("ColorIdleCombat"), CombatGroups, OnCombatChange)
    LootHUD := HudChannel(LootKey, LootTimeout, LootGrace, HudC("ColorIdleLoot"), [LootIcon], (on) => LootFx.SetActive(on))

    HudShown := false                        ; le nuove finestre partono nascoste: UpdateVisibility le mostra
    HudBuilding := false
}

; Distrugge le finestre dell'HUD e libera le risorse grafiche (prima di una ricostruzione)
DestroyHud() {
    global
    if !IsObject(AllGroups)
        return
    SetTimer(Ticker.Fn, 0), Ticker.Items := Map()
    old := AllGroups
    AllGroups := [], CombatGroups := []           ; prima di distruggere: nessuno le usa più (es. cambio di finestra in primo piano)
    for grp in old {
        grp.Dead := true
        for item in grp.Windows
            try item.Win.Destroy()
    }
    for name in ["LootFx", "CombatFx"]
        if IsObject(%name%)
            %name%.Free()
}

OnCombatChange(on) {
    ChevronAnim.SetActive(on)
    if CombatIconEnabled
        CombatFx.SetActive(on)
}

BuildHud()

; HUD overlay accendibile/spegnibile come i tool (Ctrl+Shift+\)
Hud := HudTool()

; Tasti attivi solo con il gioco in primo piano (il tasto arriva comunque al gioco).
; Con l'HUD spento i segnali vengono ignorati.
HotIfWinActive("ahk_exe " GameExe)
if (CombatKey != "")
    Hotkey("~*" CombatKey, (*) => Hud.On && CombatHUD.Signal())
if (LootKey != "")
    Hotkey("~*" LootKey, (*) => Hud.On && LootHUD.Signal())
HotIfWinActive()

; Tools: controlli sullo schermo attivi solo con il gioco in primo piano
HiddenCube := HiddenCubeTool()
FieldBoss  := FieldBossTool()

HotIfWinActive("ahk_exe " GameExe)
if (HiddenCubeTestKey != "")
    Hotkey(HiddenCubeTestKey, (*) => HiddenCube.Test())
if (HiddenCubeToggleKey != "")
    Hotkey(HiddenCubeToggleKey, (*) => ToggleTool(HiddenCube, "Hidden Cube"))
if (FieldBossToggleKey != "")
    Hotkey(FieldBossToggleKey, (*) => ToggleTool(FieldBoss, "Field Boss"))
if (HudToggleKey != "")
    Hotkey(HudToggleKey, (*) => ToggleTool(Hud, "HUD overlay"))
HotIfWinActive()

; Finestra delle impostazioni: tasto (ovunque), voce del menu dell'icona e doppio click sull'icona
if (SettingsKey != "")
    Hotkey(SettingsKey, (*) => SettingsEditor.Open())
A_TrayMenu.Insert("1&", Tr("Impostazioni AION 2 Wingman"), (*) => SettingsEditor.Open())
A_TrayMenu.Insert("2&", Tr("Controlla aggiornamenti"), (*) => Updater.CheckNow())
A_TrayMenu.Insert("3&")
A_TrayMenu.Default := Tr("Impostazioni AION 2 Wingman")

; Accende/spegne un tool mentre giochi e lo conferma con un avviso
ToggleTool(tool, label) {
    if !tool.Ready {
        ShowTip(label ": " Tr("non disponibile") (tool.HasProp("Why") ? " (" tool.Why ")" : ""), 2500)
        return
    }
    tool.SetOn(!tool.On)
    ShowTip(label ": " (tool.On ? "ON" : "OFF") "`nAION 2 Wingman " AppVersion " - by VaLeTecK", 1500)
    FieldBoss.RefreshLegend()              ; la leggenda mostra lo stato aggiornato dei tool
}

; Avviso temporaneo vicino al mouse
ShowTip(msg, ms := 2500, x?, y?) {
    static hide := (*) => ToolTip()          ; un solo timer: un avviso nuovo non viene chiuso da uno vecchio
    ToolTip(msg, x?, y?)
    SetTimer(hide, -ms)
}

; Visibilità a eventi: Windows avvisa lo script quando cambia la finestra in primo piano
; (nessun controllo periodico, HUD mostrato/nascosto all'istante)
global ForegroundHook := DllCall("SetWinEventHook", "UInt", 0x3, "UInt", 0x3, "Ptr", 0   ; EVENT_SYSTEM_FOREGROUND
    , "Ptr", CallbackCreate((*) => UpdateVisibility(), , 7), "UInt", 0, "UInt", 0, "UInt", 0, "Ptr")
UpdateVisibility()

; Splash all'avvio (nome dell'app e "by VaLeTecK")
if SplashEnabled
    SplashScreen.Show()

ViCountdownBar.Start()                       ; easter egg del tema "vi" (acceso di default solo con quel tema)

; Primo avvio: apre da sola la finestra Impostazioni (dopo lo splash). Il segno "già avviato" è in
; %AppData%\AION 2 Wingman\settings.ini (sopravvive agli aggiornamenti dello script).
FirstRunCheck() {
    done := ""
    try done := IniRead(UserData.File, "App", "FirstRunDone", "")
    if (done = "1")
        return
    try IniWrite("1", UserData.File, "App", "FirstRunDone")
    SetTimer(() => SettingsEditor.Open(), SplashEnabled ? -2500 : -500)
}
FirstRunCheck()
Updater.Startup()                            ; aggiornamenti da GitHub (vedi [AGGIORNAMENTI])


; ==============================================================================
; === VISIBILITÀ IN BASE AL FOCUS DEL GIOCO ===
; ==============================================================================

; HUD visibile = gioco in primo piano E HUD acceso. I tool seguono solo il gioco.
UpdateVisibility() {
    global HudShown, GameActive
    if HudBuilding                              ; l'HUD si sta ricostruendo: ci pensa BuildHud alla fine
        return
    game := WinActive("ahk_exe " GameExe) != 0
    show := (game && Hud.On) || PreviewMode     ; in anteprima l'HUD si vede sempre
    if (show != HudShown) {
        HudShown := show
        for grp in AllGroups {
            if (show && PreviewAllows(grp.HasOwnProp("PvKey") ? grp.PvKey : ""))
                grp.Show()
            else
                grp.Hide()
        }
    }
    if (game != GameActive) {
        GameActive := game
        HiddenCube.SetRunning(game)       ; i tool girano solo mentre si gioca
        FieldBoss.SetRunning(game)
    }
}

; Interruttore dell'HUD overlay (stessa interfaccia dei tool: Ready / On / SetOn)
class HudTool {
    __New() {
        this.Ready := true
        this.On    := HudEnabled
    }
    SetOn(on) {
        this.On := on
        UpdateVisibility()
    }
}


; ==============================================================================
; === CLASSI ===
; ==============================================================================

; Funzioni di sistema usate a ogni fotogramma: indirizzi risolti una sola volta all'avvio
; (chiamarle per nome costringe AutoHotkey a cercarle di nuovo a ogni chiamata).
class Api {
    static __New() {
        if (this != Api)
            return
        DllCall("LoadLibrary", "Str", "gdiplus", "Ptr")
        si := Buffer(24, 0)
        NumPut("UInt", 1, si, 0)
        DllCall("gdiplus\GdiplusStartup", "Ptr*", &token := 0, "Ptr", si, "Ptr", 0)

        funcs := Map(
            "user32",   ["SetWindowRgn", "UpdateLayeredWindow", "SetLayeredWindowAttributes"],
            "gdi32",    ["CreatePolygonRgn", "CreateRectRgn", "CombineRgn", "DeleteObject"],
            "kernel32", ["QueryPerformanceCounter"],
            "gdiplus",  ["GdipGraphicsClear", "GdipFlush", "GdipFillEllipse", "GdipDrawEllipse", "GdipDrawArc"
                       , "GdipSetPenColor", "GdipSetPenWidth", "GdipSetSolidFillColor"])
        for dll, names in funcs {
            hMod := DllCall("GetModuleHandle", "Str", dll, "Ptr")
            for name in names
                this.%name% := DllCall("GetProcAddress", "Ptr", hMod, "AStr", name, "Ptr")
        }
        DllCall("QueryPerformanceFrequency", "Int64*", &freq := 0)
        this.MsPerCount := 1000 / freq
    }
}

; Un unico timer per tutte le animazioni: ogni oggetto registrato riceve Tick(now)
; e restituisce true quando non ha più nulla da fare. Il timer si ferma da solo a riposo.
class Ticker {
    static Items := Map()
    static Fn    := ObjBindMethod(this, "Run")

    static Add(obj) {
        this.Items[obj] := true
        if (this.Items.Count = 1)
            SetTimer(this.Fn, AnimInterval)
    }

    static Run() {
        Critical "On"                       ; un fotogramma alla volta, senza interruzioni
        now := NowMs()
        for obj in this.Items.Clone() {          ; copia: durante il giro altri oggetti possono registrarsi
            this.Items[obj] := false
            if !obj.Tick(now)
                this.Items[obj] := true
        }
        for obj, keep in this.Items.Clone()
            if !keep
                this.Items.Delete(obj)
        if !this.Items.Count
            SetTimer(this.Fn, 0)
    }
}

; Un tasto (F9 / F10): passa allo stato attivo a ogni segnale e torna inattivo
; dopo un periodo senza segnali, gestendo colori e dissolvenze dei propri gruppi.
class HudChannel {
    __New(key, timeoutMs, graceMs, idleColor, groups, onChange := "", fadeOutSec := "", colorOutSec := "") {
        this.Key         := key
        this.Timeout     := timeoutMs
        this.Grace       := graceMs
        this.ActiveRGB   := ColorToRGB(HudC("ColorActive"))
        this.IdleRGB     := ColorToRGB(idleColor)
        this.FadeOut     := fadeOutSec  = "" ? FadeOutTime      : fadeOutSec    ; vuoto = valori globali
        this.ColorOut    := colorOutSec = "" ? ColorFadeOutTime : colorOutSec
        this.Groups      := groups
        this.OnChange    := onChange
        this.IsActive    := false
        this.LastSignal  := 0
        this.ActivatedAt := 0

        ; All'avvio gli elementi partono già nello stato inattivo, come dopo una dissolvenza in uscita
        for grp in groups {
            grp.SetColor(grp.IdleRGB != "" ? grp.IdleRGB : this.IdleRGB)
            grp.InitAlpha((grp.FadeOutEnabled && !PreviewMode) ? 0 : 255)   ; in anteprima: visibile
        }
    }

    Signal() {
        now := NowMs()
        this.LastSignal := now
        if this.IsActive
            return
        this.IsActive    := true
        this.ActivatedAt := now
        if this.OnChange
            this.OnChange.Call(true)
        UpdateVisibility()                 ; mostra subito l'HUD
        this.Transition(true)
    }

    Transition(on) {
        for grp in this.Groups {
            ; Un gruppo può avere colore inattivo e tempi di uscita propri (es. le icone di stato)
            idle     := grp.IdleRGB     != "" ? grp.IdleRGB     : this.IdleRGB
            colorOut := grp.ColorOutSec != "" ? grp.ColorOutSec : this.ColorOut
            fadeOut  := grp.FadeOutSec  != "" ? grp.FadeOutSec  : this.FadeOut
            grp.SetColor(on ? this.ActiveRGB : idle, on ? ColorFadeInTime : colorOut)
            if on
                grp.FadeTo(255, grp.FadeInEnabled, FadeInTime)
            else
                grp.FadeTo(0, grp.FadeOutEnabled, fadeOut)
        }
        Ticker.Add(this)
    }

    Tick(now) {
        if this.IsActive {
            ; Tasto ancora tenuto premuto: resta ON anche nella pausa che Windows fa prima dell'autorepeat
            try if GetKeyState(this.Key)                ; (try: tasto vuoto o scritto male nella CONFIG)
                this.LastSignal := now
            if (now - this.ActivatedAt >= this.Grace && now - this.LastSignal > this.Timeout) {
                this.IsActive := false
                if this.OnChange
                    this.OnChange.Call(false)
                this.Transition(false)
            }
        }
        done := true
        for grp in this.Groups
            if !grp.Step(now)
                done := false
        return done && !this.IsActive
    }
}

; Mirino a frecce: forma OFF (verso l'esterno) e forma ON (verso l'interno, animata).
; "Morph" va da 0 (ON) a 1 (OFF): tutto ciò che sta in mezzo è la transizione graduale.
class ChevronHud {
    __New(win) {
        this.Win         := win
        this.Active      := false
        this.Morph       := 1.0
        this.MorphFrom   := 1.0
        this.MorphTarget := 1.0
        this.MorphStart  := 0
        this.MorphDur    := 0
        this.AnimStart   := NowMs()
        this.Redraw(this.AnimStart)
    }

    SetActive(active) {
        now := NowMs()
        if (active && this.Morph >= 1)
            this.AnimStart := now                ; l'animazione riparte da capo solo se era del tutto OFF
        this.Active      := active
        this.MorphFrom   := this.Morph           ; se interrotta a metà, riparte dal punto in cui si trova
        this.MorphTarget := active ? 0 : 1
        this.MorphStart  := now
        this.MorphDur    := (active ? ChevronMorphInTime : ChevronMorphOutTime) * 1000
                          * Abs(this.MorphTarget - this.MorphFrom)
        this.Tick(now)                           ; primo fotogramma subito
        Ticker.Add(this)
    }

    Tick(now) {
        if (this.Morph != this.MorphTarget) {
            t := this.MorphDur > 0 ? Min(1, (now - this.MorphStart) / this.MorphDur) : 1
            this.Morph := t >= 1 ? this.MorphTarget : Lerp(this.MorphFrom, this.MorphTarget, t)
        }
        ; A riposo quando non c'è più nulla da muovere (OFF raggiunto, oppure ON senza animazione)
        idle := (this.Morph = this.MorphTarget) && (!this.Active || HudC("ChevronAnimMode") = "none")
        if (idle || HudShown)                    ; con l'HUD nascosto non si disegna
            this.Redraw(now)
        return idle
    }

    Redraw(now) => SetWindowRegion(this.Win, this.BuildRgn(now))

    BuildRgn(now) {
        hRgn := DllCall(Api.CreateRectRgn, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "Ptr")
        n := HudC("ChevronCount"), mode := HudC("ChevronAnimMode")      ; (il tema di classe può cambiarli)
        shOn := HudC("ChevronShapeOn"), shOff := HudC("ChevronShapeOff")
        e := Smoothstep(this.Morph)                                   ; transizione con accelerazione morbida
        p := Mod((now - this.AnimStart) / Max(1, HudC("ChevronAnimCycle")), 1)   ; fase animazione 0..1

        flip := 2 * e - 1          ; -1 = verso l'interno, 0 = barra verticale, +1 = verso l'esterno
        w := Lerp(ChevronWidthOn,     ChevronWidthOff,     e)
        h := Lerp(ChevronHeightOn,    ChevronHeightOff,    e)
        t := Lerp(ChevronThicknessOn, ChevronThicknessOff, e)

        loop n + 1 {
            k  := A_Index - 1
            on := ChevronOnState(k, n, p, mode)                             ; [posizione, scala] in stato ON
            s  := Lerp(on[2], k < n ? 1 : 0, e)
            if (s <= 0.05)
                continue
            dist := Lerp(ChevronGap / 2 + ChevronWidthOn  / 2 + on[1] * ChevronSpacingOn
                       , ChevronGap / 2 + ChevronWidthOff / 2 + k     * ChevronSpacingOff, e)
            AddChevronPair(hRgn, dist, w * s, h * s, Max(1, Min(t, t * s)), flip, e < 0.5 ? shOn : shOff)
        }
        return hRgn
    }
}

; Icona di stato (Loot o Combat) disegnata con GDI+ (antialiasing) su un livello a trasparenza per pixel:
; cornice, riempimento colorato ed effetti. I testi stanno in una finestra separata che non
; viene mai ridisegnata. "Morph" va da 0 (ON) a 1 (OFF): l'intensità degli effetti lo segue.
class LootEffects {
    __New(grp, fxWin, winW, winH, idleRGB, shape := "cerchio", bw := 0, bh := 0, p := "Loot") {
        ; valori dell'icona (prefisso "Loot" o "Combat"), letti una volta: l'HUD si ricostruisce se cambiano
        this.S := GetGlobalVar(p "Size"), this.B := GetGlobalVar(p "BorderSize")
        for n in ["PulseCycle", "PulseSize", "PulseOpacity", "RingCycle", "RingCount", "RingDistance", "RingThickness"
                , "RingOpacity", "SpinCycle", "SpinArc", "SpinThickness", "GlowCycle", "GlowAmount", "MorphInTime", "MorphOutTime"]
            this.%n% := GetGlobalVar(p n)
        this.Grp  := grp
        this.Win  := fxWin
        this.CX   := winW / 2, this.CY := winH / 2
        this.C    := Min(winW, winH) / 2                             ; limite per gli effetti (cerchio)
        this.R0   := (this.S + this.B * 2) / 2    ; raggio esterno della cornice
        this.Shape := shape
        this.BW   := bw ? bw : this.S, this.BH := bh ? bh : this.S
        this.Pad  := GetGlobalVar(p "FxPadding")
        this.Poly := IconPolygon(shape)
        this.PtBuf := Buffer(8 * 8)                                  ; punti (float) per i poligoni
        this.Active      := false
        this.Running     := false
        this.Morph       := 1.0
        this.MorphFrom   := 1.0
        this.MorphTarget := 1.0
        this.MorphStart  := 0
        this.MorphDur    := 0
        this.AnimStart   := NowMs()

        ; Effetti scelti (calcolati una volta sola)
        used := Map()
        for name in HudC(p "Anim")
            used[StrLower(name)] := true
        this.Animated := used.Count > 0
        this.DoPulse  := used.Has("pulse")
        this.DoRing   := used.Has("ring")
        this.DoSpin   := used.Has("spin")
        this.DoGlow   := used.Has("glow")

        this.PulseRGB  := ColorToRGB(HudC(p "PulseColor"))
        this.RingRGB   := ColorToRGB(HudC(p "RingColor"))
        this.SpinRGB   := ColorToRGB(HudC(p "SpinColor"))
        this.GlowRGB   := ColorToRGB(HudC(p "GlowColor"))
        this.IdleRGB   := idleRGB
        this.FrameARGB := 0xFF000000 | ColorToRGB(HudC("ColorBorder"))

        ; Superficie di disegno a 32 bit (creata una volta sola)
        this.hdc := DllCall("CreateCompatibleDC", "Ptr", 0, "Ptr")
        bi := Buffer(40, 0)
        NumPut("UInt", 40, bi, 0), NumPut("Int", winW, bi, 4), NumPut("Int", -winH, bi, 8)
        NumPut("UShort", 1, bi, 12), NumPut("UShort", 32, bi, 14)
        this.hbm := DllCall("CreateDIBSection", "Ptr", this.hdc, "Ptr", bi, "UInt", 0, "Ptr*", &bits := 0, "Ptr", 0, "UInt", 0, "Ptr")
        DllCall("SelectObject", "Ptr", this.hdc, "Ptr", this.hbm)
        DllCall("gdiplus\GdipCreateFromHDC", "Ptr", this.hdc, "Ptr*", &g := 0)
        this.G := g
        DllCall("gdiplus\GdipSetSmoothingMode", "Ptr", g, "Int", 4)      ; antialiasing
        DllCall("gdiplus\GdipSetPixelOffsetMode", "Ptr", g, "Int", 2)    ; alta qualità (sotto-pixel)

        ; Penne e pennello riutilizzati: a ogni fotogramma cambiano solo colore e spessore
        DllCall("gdiplus\GdipCreatePen1", "UInt", 0, "Float", 1, "Int", 2, "Ptr*", &pen := 0)
        DllCall("gdiplus\GdipCreatePen1", "UInt", 0, "Float", 1, "Int", 2, "Ptr*", &capPen := 0)
        DllCall("gdiplus\GdipSetPenEndCap", "Ptr", capPen, "Int", 2)    ; punta arrotondata (testa dello spin)
        for p in [pen, capPen]
            DllCall("gdiplus\GdipSetPenLineJoin", "Ptr", p, "Int", 2)  ; angoli arrotondati (forme poligonali)
        DllCall("gdiplus\GdipCreateSolidFill", "UInt", 0, "Ptr*", &brush := 0)
        this.Pen := pen, this.CapPen := capPen, this.Brush := brush

        ; Parametri fissi per UpdateLayeredWindow
        this.SizeBuf := Buffer(8), NumPut("Int", winW, "Int", winH, this.SizeBuf)
        this.PtSrc   := Buffer(8, 0)

        ; Colore e dissolvenza del gruppo: ridisegno solo se serve (se gli effetti sono fermi)
        grp.OnColor := ObjBindMethod(this, "Invalidate")
        grp.OnAlpha := ObjBindMethod(this, "Refresh")
        this.Draw(this.AnimStart)
    }

    ; libera penne, pennello e superficie di disegno (usato quando l'HUD viene ricostruito)
    Free() {
        Critical "On"                       ; non può interrompere un disegno in corso (e viceversa)
        if !this.G
            return
        for h in [this.Pen, this.CapPen]
            DllCall("gdiplus\GdipDeletePen", "Ptr", h)
        DllCall("gdiplus\GdipDeleteBrush", "Ptr", this.Brush)
        DllCall("gdiplus\GdipDeleteGraphics", "Ptr", this.G)
        DllCall("DeleteDC", "Ptr", this.hdc)
        DllCall("DeleteObject", "Ptr", this.hbm)
        this.G := 0
    }

    SetActive(active) {
        now := NowMs()
        if (active && this.Morph >= 1)
            this.AnimStart := now
        this.Active      := active
        this.MorphFrom   := this.Morph
        this.MorphTarget := active ? 0 : 1
        this.MorphStart  := now
        this.MorphDur    := (active ? this.MorphInTime : this.MorphOutTime) * 1000
                          * Abs(this.MorphTarget - this.MorphFrom)
        this.Running := true
        Ticker.Add(this)
    }

    Tick(now) {
        if (this.Morph != this.MorphTarget) {
            t := this.MorphDur > 0 ? Min(1, (now - this.MorphStart) / this.MorphDur) : 1
            this.Morph := t >= 1 ? this.MorphTarget : Lerp(this.MorphFrom, this.MorphTarget, t)
        }
        idle := (this.Morph = this.MorphTarget) && (!this.Active || !this.Animated)
        if (idle || HudShown)
            this.Draw(now)
        if idle
            this.Running := false
        return idle
    }

    Invalidate() {                           ; cambiato il colore: serve un nuovo disegno
        if !this.Running
            this.Draw(NowMs())
    }

    Refresh() {                              ; cambiata solo l'opacità: basta ripresentare l'immagine
        if !this.Running
            this.Present()
    }

    Intensity() => 1 - Smoothstep(this.Morph)
    Phase(cycle, now, offset := 0) => Mod((now - this.AnimStart) / Max(1, cycle) + offset, 1)
    Wave(cycle, now) => 0.5 - 0.5 * Cos(2 * ChevPi * this.Phase(cycle, now))   ; 0 → 1 → 0, morbido

    ; Disegna in un colpo solo: effetti esterni, cornice, riempimento colorato ed effetti sul bordo
    Draw(now) {
        Critical "On"                       ; un disegno non viene mai interrotto a metà (es. dalla
        if !this.G                          ; ricostruzione dell'anteprima che libera penne e superfici)
            return
        k := this.Intensity()
        DllCall(Api.GdipGraphicsClear, "Ptr", this.G, "UInt", 0)
        if (k > 0 && this.DoPulse)
            this.DrawPulse(k, now)
        if (k > 0 && this.DoRing)
            this.DrawRings(k, now)

        ; Cornice e riempimento (il colore segue la sfumatura del gruppo, più l'eventuale "glow")
        fill := this.Grp.ColorCur = "" ? this.IdleRGB : this.Grp.ColorCur
        if (k > 0 && this.DoGlow)
            fill := LerpRGB(fill, this.GlowRGB, this.GlowAmount * k * this.Wave(this.GlowCycle, now))
        if (this.Shape = "cerchio") {
            this.Disc(this.R0, this.FrameARGB)
            this.Disc(this.S / 2, 0xFF000000 | fill)
        } else {
            this.FillShape(this.B, this.FrameARGB)
            this.FillShape(0, 0xFF000000 | fill)
        }

        if (k > 0 && this.DoSpin)
            this.DrawSpin(k, now)
        DllCall(Api.GdipFlush, "Ptr", this.G, "Int", 1)
        this.Present()
    }

    ; Mostra l'immagine pronta applicando l'opacità del gruppo (dissolvenza)
    Present() {
        if !this.G
            return
        DllCall(Api.UpdateLayeredWindow, "Ptr", this.Win.Hwnd, "Ptr", 0, "Ptr", 0
            , "Ptr", this.SizeBuf, "Ptr", this.hdc, "Ptr", this.PtSrc
            , "UInt", 0, "UInt*", (Round(this.Grp.Alpha) << 16) | 0x1000000, "UInt", 2)   ; AC_SRC_ALPHA, ULW_ALPHA
    }

    ; Alone morbido fatto di strati concentrici sempre più trasparenti, che si allarga e si ritira
    DrawPulse(k, now) {
        w      := this.Wave(this.PulseCycle, now)
        extent := this.PulseSize * (0.55 + 0.45 * w)
        layers := 10
        step   := extent / layers
        base   := 255 * k * this.PulseOpacity * (0.35 + 0.65 * w)
        loop layers {
            f := (A_Index - 1) / layers
            if (this.Shape = "cerchio")
                this.Circle(this.R0 + step * (A_Index - 0.5), step + 0.6, Argb(this.PulseRGB, base * (1 - f) ** 2))
            else
                this.Outline(this.B + step * (A_Index - 0.5), step + 0.6, Argb(this.PulseRGB, base * (1 - f) ** 2))
        }
    }

    ; Onde ad anello sfasate: partono veloci dal bordo, rallentano e svaniscono
    DrawRings(k, now) {
        n := Max(1, this.RingCount)
        loop n {
            p := this.Phase(this.RingCycle, now, (A_Index - 1) / n)
            e := 1 - (1 - p) ** 2
            w := this.RingThickness * (1 - 0.5 * p)
            a := Argb(this.RingRGB, 255 * k * this.RingOpacity * (1 - p) ** 1.5)
            if (this.Shape = "cerchio")
                this.Circle(Min(this.R0 + w / 2 + this.RingDistance * e, this.C - w / 2 - 1), w, a)
            else
                this.Outline(Min(this.B + w / 2 + this.RingDistance * e
                               , this.B + this.Pad - w / 2 - 1), w, a)
        }
    }

    ; Arco rotante sulla cornice con scia che sfuma; si accorcia fino a sparire passando a OFF
    DrawSpin(k, now) {
        span := this.SpinArc * k
        if (span < 1)
            return
        if (this.Shape != "cerchio")
            return this.SpinShape(k, now, span)
        r    := this.S / 2 + this.B / 2
        head := this.Phase(this.SpinCycle, now) * 360 - 90
        segs := 16
        loop segs {
            start := head - span + span * (A_Index - 1) / segs
            this.Arc(r, this.SpinThickness, start, span / segs + 0.8
                , Argb(this.SpinRGB, 255 * k * (A_Index / segs) ** 1.5), A_Index = segs)
        }
    }

    ; --- Forme poligonali (quadrato, rettangolo, triangolo, trapezio) ---
    ; vertici della forma allargata di d px per lato (d = 0: forma interna)
    Verts(d) {
        sx := (this.BW + d * 2) / 2, sy := (this.BH + d * 2) / 2, out := []   ; metà larghezza/altezza
        for v in this.Poly
            out.Push([this.CX + v[1] * 2 * sx, this.CY + v[2] * 2 * sy])
        return out
    }

    PutPts(pts) {
        for i, p in pts
            NumPut("Float", p[1], this.PtBuf, (i - 1) * 8), NumPut("Float", p[2], this.PtBuf, (i - 1) * 8 + 4)
        return pts.Length
    }

    FillShape(d, argb) {
        n := this.PutPts(this.Verts(d))
        DllCall(Api.GdipSetSolidFillColor, "Ptr", this.Brush, "UInt", argb)
        DllCall("gdiplus\GdipFillPolygon", "Ptr", this.G, "Ptr", this.Brush, "Ptr", this.PtBuf, "Int", n, "Int", 0)
    }

    Outline(d, width, argb) {
        if (argb < 0x1000000)
            return
        n := this.PutPts(this.Verts(d))
        DllCall(Api.GdipSetPenColor, "Ptr", this.Pen, "UInt", argb)
        DllCall(Api.GdipSetPenWidth, "Ptr", this.Pen, "Float", width)
        DllCall("gdiplus\GdipDrawPolygon", "Ptr", this.G, "Ptr", this.Pen, "Ptr", this.PtBuf, "Int", n)
    }

    ; Spin sulle forme poligonali: una "cometa" che percorre il bordo, con scia che sfuma
    SpinShape(k, now, span) {
        V := this.Verts(this.B / 2), n := V.Length
        cum := [0]                                              ; distanze progressive lungo il bordo
        loop n {
            a := V[A_Index], b := V[Mod(A_Index, n) + 1]
            cum.Push(cum[A_Index] + Sqrt((b[1] - a[1]) ** 2 + (b[2] - a[2]) ** 2))
        }
        L := cum[n + 1]
        if (L <= 0)
            return
        trail := L * span / 360
        head  := this.Phase(this.SpinCycle, now) * L
        segs  := 16
        loop segs {
            a := head - trail + trail * (A_Index - 1) / segs
            a := Mod(Mod(a, L) + L, L)
            pts := this.PathPoints(V, cum, L, a, a + trail / segs + 0.8)
            col := Argb(this.SpinRGB, 255 * k * (A_Index / segs) ** 1.5)   ; (non "argb": è il nome della funzione)
            pen := A_Index = segs ? this.CapPen : this.Pen
            DllCall(Api.GdipSetPenColor, "Ptr", pen, "UInt", col)
            DllCall(Api.GdipSetPenWidth, "Ptr", pen, "Float", this.SpinThickness)
            cnt := this.PutPts(pts)
            DllCall("gdiplus\GdipDrawLines", "Ptr", this.G, "Ptr", pen, "Ptr", this.PtBuf, "Int", cnt)
        }
    }

    ; punti del bordo tra le distanze a e b (b può superare il giro: riparte dall'inizio)
    PathPoints(V, cum, L, a, b) {
        n := V.Length, pts := [this.PerimAt(V, cum, L, a)]
        t := a
        loop n + 1 {
            lap := Floor(t / L) * L, rel := t - lap
            seg := 1
            while (seg < n && cum[seg + 1] <= rel)
                seg++
            nxt := lap + cum[seg + 1]
            if (nxt >= b || pts.Length >= 7)
                break
            pts.Push(V[Mod(seg, n) + 1])
            t := nxt + 0.001
        }
        pts.Push(this.PerimAt(V, cum, L, b))
        return pts
    }

    PerimAt(V, cum, L, t) {
        n := V.Length, t := Mod(t, L)
        seg := 1
        while (seg < n && cum[seg + 1] <= t)
            seg++
        a := V[seg], b := V[Mod(seg, n) + 1]
        len := cum[seg + 1] - cum[seg]
        f := len > 0 ? (t - cum[seg]) / len : 0
        return [a[1] + (b[1] - a[1]) * f, a[2] + (b[2] - a[2]) * f]
    }

    ; --- Primitive di disegno (riusano penne e pennello) ---
    Circle(r, width, argb) {
        if (r <= 0 || argb < 0x1000000)
            return
        DllCall(Api.GdipSetPenColor, "Ptr", this.Pen, "UInt", argb)
        DllCall(Api.GdipSetPenWidth, "Ptr", this.Pen, "Float", width)
        DllCall(Api.GdipDrawEllipse, "Ptr", this.G, "Ptr", this.Pen
            , "Float", this.CX - r, "Float", this.CY - r, "Float", r * 2, "Float", r * 2)
    }

    Disc(r, argb) {
        DllCall(Api.GdipSetSolidFillColor, "Ptr", this.Brush, "UInt", argb)
        DllCall(Api.GdipFillEllipse, "Ptr", this.G, "Ptr", this.Brush
            , "Float", this.CX - r, "Float", this.CY - r, "Float", r * 2, "Float", r * 2)
    }

    Arc(r, width, startDeg, sweepDeg, argb, roundEnd) {        ; angoli in gradi, 0° = destra, senso orario
        if (argb < 0x1000000)
            return
        pen := roundEnd ? this.CapPen : this.Pen
        DllCall(Api.GdipSetPenColor, "Ptr", pen, "UInt", argb)
        DllCall(Api.GdipSetPenWidth, "Ptr", pen, "Float", width)
        DllCall(Api.GdipDrawArc, "Ptr", this.G, "Ptr", pen
            , "Float", this.CX - r, "Float", this.CY - r, "Float", r * 2, "Float", r * 2
            , "Float", startDeg, "Float", sweepDeg)
    }
}

; Posizione (in "slot") e scala della freccia k in stato ON, secondo l'animazione scelta.
; k va da 0 (la più interna) a n (freccia extra, usata solo da "march").
ChevronOnState(k, n, p, mode := "") {
    switch (mode != "" ? mode : ChevronAnimMode) {
    case "pulse":
        if (k >= n)
            return [k, 0]
        wave := 0.5 + 0.5 * Sin(2 * ChevPi * (p + k / n))   ; la freccia esterna raggiunge il massimo per prima
        return [k, ChevronPulseMin + (ChevronPulseMax - ChevronPulseMin) * wave]
    case "march":
        return [k - p, Max(0, Min(1, k + 1 - p, n - k + p))]  ; entra crescendo fuori, esce rimpicciolendo al centro
    case "sequence":
        if (k >= n)
            return [k, 0]
        lit := Floor(p * n) + 1                               ; accensione progressiva dall'esterno
        return [k, k >= n - lit ? 1 : 0]
    default:
        return [k, k < n ? 1 : 0]
    }
}

; Insieme di finestre che condividono trasparenza e dissolvenze
; (es. una barra = 2 cornici + 2 riempimenti). Solo i "riempimenti" cambiano colore.
class FadeGroup {
    __New(fadeInEnabled, fadeOutEnabled) {
        this.FadeInEnabled  := fadeInEnabled
        this.FadeOutEnabled := fadeOutEnabled
        this.Windows    := []
        this.Fills      := []
        this.Alpha      := 255   ; valore preciso (decimale) usato per l'animazione
        this.Applied    := 255   ; ultimo valore effettivamente applicato alle finestre
        this.From       := 255
        this.Target     := 255
        this.StartTick  := 0
        this.Duration   := 0
        this.ColorCur   := ""    ; colore attuale (RGB intero)
        this.ColorFrom  := 0
        this.ColorTo    := 0
        this.ColorStart := 0
        this.ColorDur   := 0
        this.OnColor    := ""    ; funzione opzionale chiamata quando cambia il colore
        this.OnAlpha    := ""    ; funzione opzionale chiamata quando cambia la trasparenza
        this.IdleRGB     := ""   ; opzionali: se vuoti valgono quelli del canale (tasto)
        this.FadeOutSec  := ""
        this.ColorOutSec := ""
    }

    ; ownAlpha = true: la finestra gestisce da sola la propria trasparenza (livello GDI+)
    ; colorKey: colore (COLORREF) reso invisibile, per finestre che devono mostrare solo il testo
    Add(win, x, y, w, h, isFill := false, ownAlpha := false, colorKey := "") {
        this.Windows.Push({Win: win, OwnAlpha: ownAlpha, Key: colorKey, Opts: Format("x{} y{} w{} h{} NoActivate", x, y, w, h)})
        if isFill
            this.Fills.Push(win)
        if (colorKey != "")
            SetLayerAlpha(win.Hwnd, this.Applied, colorKey)
    }

    ; (try: un gruppo appena distrutto da una ricostruzione dell'HUD non deve mai bloccare lo script)
    Show() {
        if this.HasOwnProp("Dead")
            return
        for item in this.Windows
            try item.Win.Show(item.Opts)
    }

    Hide() {
        if this.HasOwnProp("Dead")
            return
        for item in this.Windows
            try item.Win.Hide()
    }

    ; Cambia il colore dei riempimenti (RGB intero), istantaneamente o con una sfumatura
    SetColor(rgb, durationSec := 0) {
        this.ColorTo := rgb
        if (durationSec <= 0 || this.ColorCur = "") {
            this.ApplyColor(rgb)
            return
        }
        this.ColorFrom  := this.ColorCur
        this.ColorStart := NowMs()
        this.ColorDur   := durationSec * 1000
    }

    ApplyColor(rgb) {
        if (rgb = this.ColorCur)
            return
        this.ColorCur := rgb
        if this.Fills.Length {
            hex := Format("{:06X}", rgb)
            for win in this.Fills
                win.BackColor := hex
        }
        if this.OnColor
            this.OnColor.Call()
    }

    ; Avvia una dissolvenza (durata proporzionale al tratto da percorrere se interrotta a metà).
    ; Con la dissolvenza disattivata l'elemento resta pienamente visibile.
    FadeTo(target, enabled, durationSec) {
        if (!enabled || PreviewMode)        ; in anteprima resta visibile anche da inattivo
            target := 255
        this.Target := target
        if (!enabled || durationSec <= 0) {
            this.SetAlpha(target)
            return
        }
        this.From      := this.Alpha
        this.StartTick := NowMs()
        this.Duration  := durationSec * 1000 * Abs(target - this.Alpha) / 255
    }

    ; Avanza trasparenza e colore; restituisce true quando entrambi hanno finito.
    Step(now) {
        alphaDone := this.StepAlpha(now)
        colorDone := this.StepColor(now)
        return alphaDone && colorDone
    }

    StepAlpha(now) {
        if (this.Alpha = this.Target)
            return true
        t := this.Duration > 0 ? Min(1, (now - this.StartTick) / this.Duration) : 1
        if FadeEasing
            t := Smoothstep(t)
        this.SetAlpha(t >= 1 ? this.Target : Lerp(this.From, this.Target, t))
        return this.Alpha = this.Target
    }

    StepColor(now) {
        if (this.ColorCur = this.ColorTo)
            return true
        t := this.ColorDur > 0 ? Min(1, (now - this.ColorStart) / this.ColorDur) : 1
        this.ApplyColor(t >= 1 ? this.ColorTo : LerpRGB(this.ColorFrom, this.ColorTo, Smoothstep(t)))
        return t >= 1
    }

    ; Imposta subito un'opacità di partenza, senza dissolvenza
    InitAlpha(alpha) {
        this.From   := alpha
        this.Target := alpha
        this.SetAlpha(alpha)
    }

    SetAlpha(alpha) {
        this.Alpha := alpha
        rounded := Round(alpha)
        if (rounded = this.Applied)
            return
        this.Applied := rounded
        for item in this.Windows
            if !item.OwnAlpha
                SetLayerAlpha(item.Win.Hwnd, rounded, item.Key)
        if this.OnAlpha
            this.OnAlpha.Call()
    }
}

; Tool Hidden Cube: riconosce la finestra dell'Hidden Cube controllando pochi punti di colore.
; Tutte le coordinate sono misurate su uno screenshot 4K (3840x2160) e vengono riportate
; all'area di gioco reale in proporzione, partendo dal centro: funziona a qualsiasi risoluzione.
; A ogni controllo si copia solo il rettangolo che contiene i punti (un'unica operazione leggera).
; Quando la finestra compare porta il mouse su "Open with Key" UNA volta sola, così puoi comunque
; spostarlo; si riarma quando la finestra è sparita da almeno HiddenCubeRearmTime ms.
class HiddenCubeTool {    ; Hidden Cube - by VaLeTecK
    ; --- Riferimenti in 4K ---
    static Target := [2105, 1287]                                           ; centro di "Open with Key"
    static GoldPts := [[1950, 1259], [2010, 1259], [2070, 1259], [2130, 1259], [2190, 1259], [2250, 1259]
                     , [1950, 1315], [2010, 1315], [2070, 1315], [2130, 1315], [2190, 1315], [2250, 1315]]
    static BluePts := [[1580, 1259], [1640, 1259], [1700, 1259], [1760, 1259], [1820, 1259], [1880, 1259]
                     , [1580, 1315], [1640, 1315], [1700, 1315], [1760, 1315], [1820, 1315], [1880, 1315]]
    static TealPts := [[1860, 997], [1954, 997], [1860, 1091]]              ; angoli interni dello slot della chiave

    __New() {
        this.On       := HiddenCubeEnabled   ; acceso/spento (anche durante il gioco, con il tasto toggle)
        this.Wanted   := false     ; true quando il gioco è in primo piano
        this.Running  := false     ; true quando il timer di controllo è attivo
        this.Seen     := false
        this.LastSeen := 0
        this.Geo      := ""        ; ultima area di gioco usata (per ricalcolare solo se cambia)
        this.hbm      := 0
        this.Fn       := ObjBindMethod(this, "Scan")
        this.mdc      := DllCall("CreateCompatibleDC", "Ptr", 0, "Ptr")
        OnExit((*) => this.FreeBitmap())
        this.Ready    := true
    }

    SetOn(on) {
        this.On := on
        this.SetRunning(this.Wanted)
    }

    ; Ricalcola punti e rettangolo di cattura in base all'area di gioco (client della finestra)
    Setup() {
        Critical "On"                      ; il timer di Scan non deve leggere la bitmap mentre cambia
        if !WinExist("ahk_exe " GameExe)
            return false
        WinGetClientPos(&gx, &gy, &gw, &gh, "ahk_exe " GameExe)
        if (gw < 100 || gh < 100)
            return false
        geo := gx "," gy "," gw "," gh
        if (geo = this.Geo)
            return true
        this.Geo := geo

        k  := Min(gw / 3840, gh / 2160)    ; scala dell'interfaccia rispetto al 4K
        cx := gx + gw / 2, cy := gy + gh / 2
        toScr := (p) => [Round(cx + (p[1] - 1920) * k), Round(cy + (p[2] - 1080) * k)]

        pts := Map("gold", [], "blue", [], "teal", [])
        for name, src in Map("gold", HiddenCubeTool.GoldPts, "blue", HiddenCubeTool.BluePts, "teal", HiddenCubeTool.TealPts)
            for p in src
                pts[name].Push(toScr(p))

        ; Rettangolo minimo che contiene tutti i punti
        x1 := y1 := 1e9, x2 := y2 := -1e9
        for name, list in pts
            for p in list
                x1 := Min(x1, p[1]), y1 := Min(y1, p[2]), x2 := Max(x2, p[1]), y2 := Max(y2, p[2])
        this.X1 := x1, this.Y1 := y1, this.CW := x2 - x1 + 1, this.CH := y2 - y1 + 1

        ; Punti convertiti in posizione (byte) dentro l'immagine catturata
        for name, list in pts {
            offs := []
            for p in list
                offs.Push(((p[2] - y1) * this.CW + (p[1] - x1)) * 4)
            this.%name% := offs
        }

        t := toScr(HiddenCubeTool.Target)
        this.TX := t[1] + Round(HiddenCubeOffsetX * k)
        this.TY := t[2] + Round(HiddenCubeOffsetY * k)

        ; Superficie a 32 bit dove copiare il rettangolo
        this.FreeBitmap()
        bi := Buffer(40, 0)
        NumPut("UInt", 40, bi, 0), NumPut("Int", this.CW, bi, 4), NumPut("Int", -this.CH, bi, 8)
        NumPut("UShort", 1, bi, 12), NumPut("UShort", 32, bi, 14)
        this.hbm := DllCall("CreateDIBSection", "Ptr", this.mdc, "Ptr", bi, "UInt", 0, "Ptr*", &bits := 0, "Ptr", 0, "UInt", 0, "Ptr")
        this.Bits := bits
        this.OldBmp := DllCall("SelectObject", "Ptr", this.mdc, "Ptr", this.hbm, "Ptr")
        return true
    }

    FreeBitmap() {
        if this.hbm {
            DllCall("SelectObject", "Ptr", this.mdc, "Ptr", this.OldBmp)
            DllCall("DeleteObject", "Ptr", this.hbm)
            this.hbm := 0
        }
    }

    SetRunning(on) {
        this.Wanted := on
        if (on && this.On)
            this.Setup()                   ; la finestra del gioco potrebbe essere stata spostata o ridimensionata
        run := this.Ready && this.On && this.Wanted       ; la geometria la ricontrolla Scan()
        if (run = this.Running)
            return
        this.Running := run
        this.Seen    := false
        SetTimer(this.Fn, run ? HiddenCubeInterval : 0)
    }

    ; Copia il rettangolo dallo schermo e conta quanti punti hanno il colore atteso
    Detect() {
        Critical "On"
        if !this.hbm
            return (Critical("Off"), false)
        sdc := DllCall("GetDC", "Ptr", 0, "Ptr")
        DllCall("gdi32\BitBlt", "Ptr", this.mdc, "Int", 0, "Int", 0, "Int", this.CW, "Int", this.CH
            , "Ptr", sdc, "Int", this.X1, "Int", this.Y1, "UInt", 0x00CC0020)       ; SRCCOPY
        DllCall("ReleaseDC", "Ptr", 0, "Ptr", sdc)
        g := this.CountMatches(this.gold, IsCubeGold)
        b := this.CountMatches(this.blue, IsCubeBlue)
        t := this.CountMatches(this.teal, IsCubeTeal)
        this.Last := [g, b, t]
        Critical "Off"
        return g >= Ceil(this.gold.Length * 0.75)
            && b >= Ceil(this.blue.Length * 0.75)
            && (!HiddenCubeCheckSlot || t >= 2)
    }

    CountMatches(offs, test) {
        n := 0
        for o in offs {
            c := NumGet(this.Bits, o, "UInt")                   ; 0xAARRGGBB
            if test((c >> 16) & 0xFF, (c >> 8) & 0xFF, c & 0xFF)
                n++
        }
        return n
    }

    Scan() {
        ; ogni secondo (o se manca la bitmap) ricontrolla posizione e dimensione della finestra del gioco
        if (!this.hbm || A_TickCount - (this.HasOwnProp("LastSetup") ? this.LastSetup : 0) > 1000) {
            this.LastSetup := A_TickCount
            ok := this.Setup() && this.hbm
            Critical "Off"
            if !ok
                return
        }
        found := this.Detect()
        now := A_TickCount
        if found {
            this.LastSeen := now
            if this.Seen {
                ; blocco: se il mouse si è spostato lo riporta subito sul pulsante
                if HiddenCubeLockMouse {
                    MouseGetPos(&mx, &my)
                    if (mx != this.TX || my != this.TY)
                        MouseMove(this.TX, this.TY, 0)
                }
                return
            }
            this.Seen := true
            MouseMove(this.TX, this.TY, 0)
            if HiddenCubeLockMouse
                SetTimer(this.Fn, HiddenCubeLockInterval)   ; controlli rapidi finché la finestra è aperta
            if HiddenCubeAutoClick {
                Sleep(HiddenCubeClickDelay)
                Click()
            }
            if HiddenCubeDebug {
                ToolTip(Tr("Hidden Cube trovato ({1}, {2})", this.TX, this.TY))
                SetTimer(() => ToolTip(), -1500)
            }
        } else if (this.Seen && now - this.LastSeen > HiddenCubeRearmTime) {
            this.Seen := false
            if HiddenCubeLockMouse
                SetTimer(this.Fn, HiddenCubeInterval)       ; finestra chiusa: blocco tolto, ritmo normale
        }
    }

    ; Tasto di prova: mostra quanti punti corrispondono (utile se non riconosce la finestra)
    Test() {
        if !this.Setup() {
            ToolTip(Tr("Hidden Cube: finestra del gioco non trovata"))
        } else {
            ok := this.Detect()
            ToolTip(Format(Tr("Hidden Cube: {}`nDorato {}/{}   Blu {}/{}   Slot {}/{}`nPulsante in ({}, {})")
                , ok ? Tr("RICONOSCIUTO") : Tr("non riconosciuto")
                , this.Last[1], this.gold.Length, this.Last[2], this.blue.Length, this.Last[3], this.teal.Length
                , this.TX, this.TY))
        }
        SetTimer(() => ToolTip(), -4000)
    }
}

; Colori attesi (tolleranti: il pulsante dorato cambia luminosità con i riflessi e al passaggio del mouse)
IsCubeGold(r, g, b) => r >= 90 && r - b >= 70 && g >= r * 0.45 && g <= r
IsCubeBlue(r, g, b) => b >= 50 && b - r >= 20 && b >= g
IsCubeTeal(r, g, b) => r < 60 && g >= 80 && b >= 80

; ==============================================================================
; === COSTRUTTORI DEGLI ELEMENTI ===
; ==============================================================================

; Finestra HUD: sempre in primo piano, senza bordi, "layered" (trasparenza gestita direttamente)
NewOverlay(color, title, pixels := false) {   ; pixels = coordinate in pixel reali (-DPIScale)
    win := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x80000" (pixels ? " -DPIScale" : "") (ClickThrough ? " +E0x20" : ""), title)
    win.BackColor := color
    SetLayerAlpha(win.Hwnd, 255)
    return win
}

BuildSplitBar(maxW, maxH, border, offX, offY, gap, skew, fadeIn, fadeOut) {
    half   := (maxW - gap) // 2
    totW   := half + border * 2
    totH   := maxH + border * 2
    baseX  := A_ScreenWidth // 2 + offX
    posY   := A_ScreenHeight // 2 + A_ScreenHeight // 4 + offY
    leftX  := baseX - gap // 2 - totW
    rightX := baseX + gap // 2

    grp := FadeGroup(fadeIn, fadeOut)
    for side in [[leftX, TrapezoidLeftRgn], [rightX, TrapezoidRightRgn]] {
        x := side[1], shape := side[2]

        frame := NewOverlay(HudC("ColorBorder"), "Bar Border")
        SetWindowRegion(frame, shape(totW, totH, skew))
        grp.Add(frame, x, posY, totW, totH)

        fill := NewOverlay(HudC("ColorIdleCombat"), "Bar Status")
        SetWindowRegion(fill, shape(half, maxH, skew))
        grp.Add(fill, x + border, posY + border, half, maxH, true)
    }
    return grp
}

; Icona di stato: name = "Loot" o "Combat" (prefisso dei valori della CONFIG: grandezza, cornice,
; effetti e transizioni), offX/offY = centro rispetto al centro schermo.
BuildStatusIcon(name, offX, offY, line1, emoji, line3, idleColor, shape := "cerchio", t := "") {
    if !IsObject(t)                          ; testo ed emoji: dimensioni, spostamenti, colori
        t := {font: LootBaseFontSize, emoji: LootEmojiSize, l1x: 0, l1y: 0, ex: 0, ey: LootEmojiOffsetY
            , l3x: 0, l3y: 0, color: "White", outline: "Black"}
    S     := GetGlobalVar(name "Size")      ; altezza della forma di questa icona
    shape := IconShape(shape)
    box   := IconBox(shape, S)                  ; [larghezza, altezza] della forma interna
    bw    := box[1], bh := box[2]
    B     := GetGlobalVar(name "BorderSize")
    pad   := GetGlobalVar(name "FxPadding")
    totW  := bw + B * 2, totH := bh + B * 2
    winW  := totW + pad * 2, winH := totH + pad * 2   ; finestre più grandi della forma: spazio per gli effetti
    cx    := winW / 2, cy := winH / 2
    posX  := (A_ScreenWidth - totW) // 2 + offX - pad
    posY  := (A_ScreenHeight - totH) // 2 + offY - pad
    grp   := FadeGroup(GetGlobalVar("Enable" name "FadeIn"), GetGlobalVar("Enable" name "FadeOut"))
    grp.IdleRGB     := ColorToRGB(idleColor)
    grp.FadeOutSec  := GetGlobalVar(name "FadeOutTime")
    grp.ColorOutSec := GetGlobalVar(name "ColorFadeOutTime")

    ; Livello grafico GDI+: cornice, riempimento colorato ed effetti (antialiasing)
    fxWin := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x80000" (ClickThrough ? " +E0x20" : ""), name " HUD")
    grp.Add(fxWin, posX, posY, winW, winH, false, true)

    ; Testi ed emoji in una finestra separata, con sfondo reso invisibile:
    ; non viene mai ridisegnata durante le transizioni (cambia solo la sua opacità), quindi niente sfarfallio
    keyRGB := 0x0A0B0C                       ; colore "chiave" quasi nero, ai bordi del contorno nero non si nota
    textWin := NewOverlay(Format("{:06X}", keyRGB), name " Text", true)   ; in pixel, come la forma
    if (shape = "cerchio")
        SetWindowRegion(textWin, CircleRgnAt(cx, cy, S))
    else {
        pts := []
        for v in IconPolygon(shape)
            pts.Push(cx + v[1] * bw, cy + v[2] * bh)
        SetWindowRegion(textWin, PolygonRgn(pts*))
    }
    fontSize := Max(4, Round(t.font * (S / 70)))
    emojiSz  := Max(4, Round(t.emoji))
    left  := Round(cx - bw / 2), top := Round(cy - bh / 2)
    textW := bw - 4, textH := bh - 4
    ; Impaginazione automatica: testo in alto, emoji, testo in basso impilati senza sovrapporsi,
    ; alla grandezza più alta che sta dentro la forma (che è più stretta verso i bordi in
    ; cerchio, triangolo e trapezio). Gli spostamenti della CONFIG restano come ritocchi fini.
    lay := IconLayout(line1, emoji, line3, fontSize, emojiSz, shape, bw, bh)
    if IconAutoFit                           ; impaginazione automatica: gli spostamenti a mano (pensati per
        t := {l1x: 0, l1y: 0, ex: 0, ey: 0, l3x: 0, l3y: 0, color: t.color, outline: t.outline}   ; le grandezze fisse) non servono
    tc := "c" t.color, oc := "c" t.outline
    if lay.Has("l1")
        AddOutlinedText(textWin, line1, left + 2 + t.l1x, top + lay["l1"].y + t.l1y, textW, lay["l1"].h + 4, "s" lay["l1"].size " Bold", "Segoe UI", tc, oc)
    if lay.Has("em")
        AddOutlinedText(textWin, emoji, left + 2 + t.ex, top + lay["em"].y + t.ey, textW, lay["em"].h + 4, "s" lay["em"].size, "Segoe UI Emoji", tc, oc)
    if lay.Has("l3")
        AddOutlinedText(textWin, line3, left + 2 + t.l3x, top + lay["l3"].y + t.l3y, textW, lay["l3"].h + 4, "s" lay["l3"].size " Bold", "Segoe UI", tc, oc)
    grp.Add(textWin, posX, posY, winW, winH, false, false, RgbToColorRef(keyRGB))

    fx := LootEffects(grp, fxWin, winW, winH, grp.IdleRGB, shape, bw, bh, name)
    return {Group: grp, Fx: fx}
}

; Larghezza della forma all'altezza y (0 = bordo alto, bh = bordo basso)
IconWidthAt(shape, bw, bh, y) {
    y := Min(Max(y, 0), bh)
    switch shape {
        case "cerchio":
            r := bh / 2, d := y - r
            return 2 * Sqrt(Max(0, r * r - d * d))
        case "triangolo": return bw * y / bh
        case "trapezio":  return bw * (0.64 + 0.36 * y / bh)
        default:          return bw
    }
}

; Impagina testo in alto, emoji e testo in basso dentro la forma, alla grandezza più alta possibile.
; Parte dal massimo (testo fino al 30% dell'altezza della forma, emoji fino al 55%) e rimpicciolisce
; solo l'elemento che non ci sta: il testo se è troppo largo per la forma alla sua altezza, l'emoji
; (o il testo) se la pila non entra in altezza. Le due righe di testo hanno sempre la stessa grandezza.
; Restituisce Map("l1"|"em"|"l3" -> {size (punti), h (px), y (px dal bordo alto della forma)}).
IconLayout(line1, emoji, line3, textPt, emojiPt, shape, bw, bh) {
    items := []
    if (line1 != "")
        items.Push({key: "l1", text: line1, emo: false})
    if (emoji != "")
        items.Push({key: "em", text: emoji, emo: true})
    if (line3 != "")
        items.Push({key: "l3", text: line3, emo: false})
    out := Map()
    if !items.Length
        return out
    gap := Max(2, Round(bh * 0.04))
    if !IconAutoFit {                                 ; grandezze fisse della CONFIG: solo impilate e centrate
        hs := [], total := gap * (items.Length - 1)
        for it in items
            hs.Push(e := it.emo ? TextExtentPx(it.text, emojiPt, false, "Segoe UI Emoji") : TextExtentPx(it.text, textPt, true, "Segoe UI"))
            , total += e[2]
        y := (bh - total) / 2 + (shape = "triangolo" ? bh * 0.12 : 0)
        for i, it in items
            out[it.key] := {size: it.emo ? emojiPt : textPt, h: hs[i][2], y: Round(y)}, y += hs[i][2] + gap
        return out
    }
    ; zona verticale utile della forma (il triangolo ha la punta in alto)
    yMin := shape = "triangolo" ? bh * 0.33 : shape = "cerchio" ? bh * 0.08 : bh * 0.07
    yMax := shape = "triangolo" ? bh * 0.96 : shape = "cerchio" ? bh * 0.92 : bh * 0.94
    margin := Max(3, Round(bw * 0.05))
    tp := 60, ep := 90                                ; punti di partenza di testo ed emoji
    while (tp > 4 && TextExtentPx("Ag", tp, true, "Segoe UI")[2] > bh * 0.30)
        tp--
    while (ep > 4 && TextExtentPx(emoji != "" ? emoji : "x", ep, false, "Segoe UI Emoji")[2] > bh * 0.55)
        ep--
    loop 300 {
        hs := [], total := 0, maxText := 0, emoH := 0
        for it in items {
            e := it.emo ? TextExtentPx(it.text, ep, false, "Segoe UI Emoji") : TextExtentPx(it.text, tp, true, "Segoe UI")
            hs.Push(e), total += e[2]
            if it.emo
                emoH := e[2]
            else
                maxText := Max(maxText, e[2])
        }
        total += gap * (items.Length - 1)
        if (total > yMax - yMin) {                    ; troppo alta: rimpicciolisce l'elemento più ingombrante
            if (emoH && (!maxText || emoH >= 1.6 * maxText) && ep > 4)
                ep--
            else if (tp > 4)
                tp--
            else if (ep > 4)
                ep--
            else
                break
            continue
        }
        y := yMin + (yMax - yMin - total) / 2         ; pila centrata nella zona utile
        ys := [], bad := ""
        for i, it in items {
            h := hs[i][2]
            room := Min(IconWidthAt(shape, bw, bh, y + h * 0.18), IconWidthAt(shape, bw, bh, y + h * 0.82)) - margin * 2
            if (hs[i][1] > room) {
                bad := it.emo ? "e" : "t"
                break
            }
            ys.Push(Round(y)), y += h + gap
        }
        if (bad = "") {
            for i, it in items
                out[it.key] := {size: it.emo ? ep : tp, h: hs[i][2], y: ys[i]}
            return out
        }
        if (bad = "t" && tp > 4)
            tp--
        else if (bad = "e" && ep > 4)
            ep--
        else
            break
    }
    ; minimo raggiunto: pila semplice dall'alto con le grandezze minime
    y := yMin
    for it in items {
        e := it.emo ? TextExtentPx(it.text, ep, false, "Segoe UI Emoji") : TextExtentPx(it.text, tp, true, "Segoe UI")
        out[it.key] := {size: it.emo ? ep : tp, h: e[2], y: Round(y)}, y += e[2] + gap
    }
    return out
}

; Larghezza e altezza in pixel di un testo con il font indicato (punti, come nelle Gui)
TextExtentPx(text, size, bold, font) {
    hdc := DllCall("GetDC", "Ptr", 0, "Ptr")
    hf  := DllCall("CreateFontW", "Int", -Round(size * A_ScreenDPI / 72), "Int", 0, "Int", 0, "Int", 0
        , "Int", bold ? 700 : 400, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 1, "UInt", 0, "UInt", 0
        , "UInt", 5, "UInt", 0, "Str", font, "Ptr")
    old := DllCall("SelectObject", "Ptr", hdc, "Ptr", hf, "Ptr")
    sz  := Buffer(8, 0)
    DllCall("GetTextExtentPoint32W", "Ptr", hdc, "Str", text, "Int", StrLen(text), "Ptr", sz)
    DllCall("SelectObject", "Ptr", hdc, "Ptr", old)
    DllCall("DeleteObject", "Ptr", hf)
    DllCall("ReleaseDC", "Ptr", 0, "Ptr", hdc)
    return [NumGet(sz, 0, "Int") + 2, NumGet(sz, 4, "Int")]       ; +2: contorno di 1 px per lato
}

; Nome della forma (accetta anche i nomi inglesi); sconosciuta = cerchio
IconShape(s) {
    static alias := Map("circle", "cerchio", "square", "quadrato", "rectangle", "rettangolo"
                      , "triangle", "triangolo", "trapezoid", "trapezio")
    s := StrLower(Trim(s))
    s := alias.Has(s) ? alias[s] : s
    return (s = "quadrato" || s = "rettangolo" || s = "triangolo" || s = "trapezio") ? s : "cerchio"
}

; Larghezza e altezza della forma interna (S = altezza, la "grandezza" dell'icona)
IconBox(shape, S := LootSize) {
    switch shape {
        case "rettangolo": return [Round(S * 1.5), S]
        case "triangolo":  return [Round(S * 1.25), S]
        case "trapezio":   return [Round(S * 1.2), S]
        default:           return [S, S]
    }
}

; Vertici della forma in un riquadro unitario centrato (-0.5 .. 0.5), in senso orario dall'alto
IconPolygon(shape) {
    switch shape {
        case "triangolo": return [[0, -0.5], [0.5, 0.5], [-0.5, 0.5]]
        case "trapezio":  return [[-0.32, -0.5], [0.32, -0.5], [0.5, 0.5], [-0.5, 0.5]]
        default:          return [[-0.5, -0.5], [0.5, -0.5], [0.5, 0.5], [-0.5, 0.5]]
    }
}

; Testo bianco con contorno nero di 1 px (4 copie nere sfalsate + 1 bianca sopra)
AddOutlinedText(win, text, cx, cy, w, h, fontOpts, fontName, textColor := "cWhite", outlineColor := "cBlack") {
    for off in [[-1, 0], [1, 0], [0, -1], [0, 1], [0, 0]] {
        color := (off[1] || off[2]) ? outlineColor : textColor
        win.Add("Text", Format("x{} y{} w{} h{} Center BackgroundTrans {}", cx + off[1], cy + off[2], w, h, color), text)
           .SetFont(fontOpts, fontName)
    }
}


; ==============================================================================
; === FORME GEOMETRICHE (Regioni GDI) ===
; ==============================================================================

SetWindowRegion(win, hRgn) => DllCall(Api.SetWindowRgn, "Ptr", win.Hwnd, "Ptr", hRgn, "Int", true)

; Angoli arrotondati per un controllo (es. la levetta dell'anteprima): r = diametro degli angoli
RoundCtl(ctrl, r) {
    ctrl.GetPos(, , &w, &h)
    DllCall("SetWindowRgn", "Ptr", ctrl.Hwnd, "Ptr", DllCall("CreateRoundRectRgn", "Int", 0, "Int", 0, "Int", w + 1, "Int", h + 1
        , "Int", r, "Int", r, "Ptr"), "Int", true)
}

; Crea una regione poligonale da una lista di coordinate x1, y1, x2, y2, ... (max 8 punti)
PolygonRgn(coords*) {
    static buf := Buffer(64)                 ; riutilizzato: niente allocazioni a ogni fotogramma
    for i, v in coords
        NumPut("Int", Round(v), buf, (i - 1) * 4)
    return DllCall(Api.CreatePolygonRgn, "Ptr", buf, "Int", coords.Length // 2, "Int", 1, "Ptr")  ; 1 = ALTERNATE
}

; Unisce src in dst e libera src (evita perdite di oggetti GDI)
CombineInto(dst, src) {
    DllCall(Api.CombineRgn, "Ptr", dst, "Ptr", dst, "Ptr", src, "Int", 2)  ; 2 = RGN_OR
    DllCall(Api.DeleteObject, "Ptr", src)
}

TrapezoidLeftRgn(w, h, skew)  => PolygonRgn(skew, 0, w, 0, w - skew, h, 0, h)
TrapezoidRightRgn(w, h, skew) => PolygonRgn(0, 0, w - skew, 0, w, h, skew, h)

; Cerchio di diametro d centrato in (cx, cy)
CircleRgnAt(cx, cy, d) => DllCall("CreateEllipticRgn"
    , "Int", Round(cx - d / 2), "Int", Round(cy - d / 2)
    , "Int", Round(cx + d / 2), "Int", Round(cy + d / 2), "Ptr")

RectRgn(x1, y1, x2, y2) => DllCall(Api.CreateRectRgn, "Int", Round(x1), "Int", Round(y1), "Int", Round(x2), "Int", Round(y2), "Ptr")

; Singola freccia: punta in tipX, apertura in baseX (funziona in entrambe le direzioni)
ChevronShapeRgn(tipX, baseX, cy, halfH, t) {
    dir := baseX > tipX ? 1 : -1
    return PolygonRgn(tipX, cy, baseX, cy - halfH, baseX, cy - halfH + t
                    , tipX + dir * t, cy, baseX, cy + halfH - t, baseX, cy + halfH)
}

; Coppia speculare di frecce a distanza "dist" (centro freccia) dal centro del mirino.
; flip: -1 = punta verso il centro, +1 = punta verso l'esterno, valori intermedi = ribaltamento.
AddChevronPair(hRgn, dist, w, h, t, flip, shape := "freccia") {
    t := Max(1, Min(t, h / 2 - 1))
    cy := ChevCY
    for s in [-1, 1] {                       ; -1 = lato sinistro, 1 = lato destro
        c    := ChevCX + s * dist
        half := s * flip * w / 2
        tip  := c + half
        back := c - half
        switch shape {
            case "barra":
                CombineInto(hRgn, RectRgn(c - t / 2, cy - h / 2, c + t / 2, cy + h / 2))
            case "blocco":
                CombineInto(hRgn, RectRgn(c - w / 2, cy - h / 2, c + w / 2, cy + h / 2))
            case "rombo":
                CombineInto(hRgn, PolygonRgn(c - w / 2, cy, c, cy - h / 2, c + w / 2, cy, c, cy + h / 2))
            case "cerchio":
                CombineInto(hRgn, DllCall("CreateEllipticRgn", "Int", Round(c - w / 2), "Int", Round(cy - h / 2)
                                        , "Int", Round(c + w / 2) + 1, "Int", Round(cy + h / 2) + 1, "Ptr"))
            case "triangolo":
                if (Abs(tip - back) < t)     ; a metà del ribaltamento diventa una barra "|"
                    CombineInto(hRgn, RectRgn(c - t / 2, cy - h / 2, c + t / 2, cy + h / 2))
                else
                    CombineInto(hRgn, PolygonRgn(tip, cy, back, cy - h / 2, back, cy + h / 2))
            default:                         ; "freccia"
                if (Abs(tip - back) < t)     ; a metà del ribaltamento la freccia diventa una barra "|"
                    CombineInto(hRgn, RectRgn(c - t / 2, cy - h / 2, c + t / 2, cy + h / 2))
                else
                    CombineInto(hRgn, ChevronShapeRgn(tip, back, cy, h / 2, t))
        }
    }
}


; ==============================================================================
; === UTILITÀ (tempo, interpolazioni e colori) ===
; ==============================================================================

; Tempo in millisecondi ad alta precisione (A_TickCount avanza a scatti di ~15,6 ms)
NowMs() => (DllCall(Api.QueryPerformanceCounter, "Int64*", &count := 0), count * Api.MsPerCount)

Lerp(a, b, t) => a + (b - a) * t
Smoothstep(t) => t * t * (3 - 2 * t)

LerpRGB(a, b, t) {
    r := Round(Lerp((a >> 16) & 0xFF, (b >> 16) & 0xFF, t))
    g := Round(Lerp((a >> 8)  & 0xFF, (b >> 8)  & 0xFF, t))
    v := Round(Lerp(a & 0xFF,         b & 0xFF,         t))
    return (r << 16) | (g << 8) | v
}

; Converte un colore AHK (nome come "Lime" o esadecimale come "CC4400") in RGB intero
ColorToRGB(color) {
    static names := Map("black", 0x000000, "silver", 0xC0C0C0, "gray", 0x808080, "white", 0xFFFFFF
        , "maroon", 0x800000, "red", 0xFF0000, "purple", 0x800080, "fuchsia", 0xFF00FF
        , "green", 0x008000, "lime", 0x00FF00, "olive", 0x808000, "yellow", 0xFFFF00
        , "navy", 0x000080, "blue", 0x0000FF, "teal", 0x008080, "aqua", 0x00FFFF)
    c := StrLower(Trim(color))
    if names.Has(c)
        return names[c]
    return Integer("0x" RegExReplace(c, "^(0x|#)"))
}

; RGB (0xRRGGBB) → COLORREF di Windows (0x00BBGGRR)
RgbToColorRef(rgb) => ((rgb & 0xFF) << 16) | (rgb & 0xFF00) | ((rgb >> 16) & 0xFF)

; Colore RGB + opacità (0..255) → ARGB per GDI+
Argb(rgb, alpha) => (Round(Max(0, Min(255, alpha))) << 24) | (rgb & 0xFFFFFF)

; Opacità di una finestra "layered", con colore chiave opzionale (LWA_ALPHA / LWA_COLORKEY | LWA_ALPHA)
SetLayerAlpha(hwnd, alpha, colorKey := "") => colorKey = ""
    ? DllCall(Api.SetLayeredWindowAttributes, "Ptr", hwnd, "UInt", 0, "UChar", alpha, "UInt", 2)
    : DllCall(Api.SetLayeredWindowAttributes, "Ptr", hwnd, "UInt", colorKey, "UChar", alpha, "UInt", 3)


; ==============================================================================
; === TOOL 2: FIELD BOSS (pannello mappa + ricerca boss + Teleport più vicino) ===
; ==============================================================================
; Tutte le letture OCR e le azioni passano da UN SOLO timer ("worker"): due letture
; non si sovrappongono mai (niente errori "AsyncInfo") e l'HUD resta fluido.
; Il pannello si vede solo con il gioco in primo piano e la mappa aperta (qualsiasi tab).
class FieldBossTool {     ; Field Boss - by VaLeTecK
    ; --- Riferimenti misurati su 2560x1440. Ancoraggio: "L" = sinistra, "C" = centro.
    ;     Tutto si scala sull'altezza della finestra: 1080p, 1440p, 4K e ultrawide.
    static BaseW := 2560
    static BaseH := 1440
    static PtExploration := [1288,  93, "C"]
    static PtFieldBoss   := [1461, 150, "C"]
    static PtBossCenter  := [1280, 720, "C"]          ; il gioco centra qui il boss selezionato
    static RcList        := [30, 190, 360, 1225, "L"] ; colonna dei boss (x, y, w, h)
    static RcTabs        := [960, 60, 640, 70, "C"]   ; tab Kibelisk / Exploration / Map Pin
    static RcMapTitle    := [60, 12, 820, 72, "L"]    ; titolo in alto a sinistra ("Map: Urugugu Canyon")
    static MapMargins    := [420, 170, 20, 10]        ; zona mappa analizzata: margini sx, alto, dx, basso

    ; --- Tempi (ms) e soglie
    static MapOpenDelay := 800
    static GuideClickSec := 8
    static ScrollWaitSec := 10
    static ScrollSettle := 250
    static MapPanDelay := 700
    static ZoomSettle := 500
    static LootCloseDelay := 300
    static BossSnapRadius := 260
    static IconRadius := 60
    static NameTolerance := 28

    ; --- Aspetto del pannello
    ; colori dal tema scelto ([TEMA])
    static Col => {bg: UiC("Bg"), row: UiC("Row"), hover: UiC("Hover"), off: UiC("Row"), offTxt: UiC("Muted")
                 , title: UiC("Accent"), btn: UiC("SubText"), sep: UiC("Line")}
    static GradeOrder  := ["verde", "blu", "oro"]
    static Grades      := Map("verde", {label: "Verde", color: "5FD068", dim: "1E3A22"}
                            , "blu",   {label: "Blu",   color: "4FA3FF", dim: "18304D"}
                            , "oro",   {label: "Oro",   color: "F2B84B", dim: "4A3714"})
    static StatusOrder := ["on", "off"]
    static StatusInfo  := Map("on",  {label: "Attivi",     sym: "●", color: "FF5A4F", dim: "4A1C1A"}
                            , "off", {label: "Non attivi", sym: "○", color: "8A93A0", dim: "2A3038"})
    static Tiers       := Map(1, {sym: "👑", color: "FFD54A"}
                            , 2, {sym: "💎", color: "7FD4FF"}
                            , 3, {sym: "🔥", color: "FF7A3D"}
                            , 4, {sym: "⭐", color: "C9A35A"})

    __New() {
        this.Win     := "ahk_exe " GameExe
        this.On      := FieldBossEnabled
        this.Ready   := false
        this.Why     := ""
        this.Wanted  := false
        this.Running := false
        this.Busy    := false
        this.Cancel  := false
        this.Pending := ""
        this.NextCheck := 0
        this.Misses  := 0

        ; pannello
        this.Panel := "", this.BuiltFor := 0, this.Shown := false
        ; tipo di mappa aperta: "field" / "dungeon" / "" (non ancora chiaro), azzerato alla chiusura
        this.MapKind := "", this.TabsField := false, this.TitleAt := 0
        this.PW := 0, this.PH := 0, this.PHFull := 0
        this.Rows := [], this.RowByHwnd := Map(), this.Chips := Map(), this.Extras := []
        this.Hover := "", this.BtnToggle := "", this.TitleH := 0
        this.Legend := "", this.LegendFor := 0, this.LegendShown := false
        this.Footer := "", this.FooterH := 0, this.FooterGap := 0
        this.Hint := "", this.HintFor := 0, this.HintTimed := false, this.Ring := "", this.RingT0 := 0, this.Step := 0
        this.HintHideFn := ObjBindMethod(this, "HintHide")
        this.Dir := "", this.DirFor := 0, this.DirLeft := 0
        this.BlockClicks := false
        this.LockPt := "", this.LockFn := ObjBindMethod(this, "LockTick")
        this.DirTickFn := ObjBindMethod(this, "DirTick")
        this.RingFn     := ObjBindMethod(this, "RingPulse")
        this.RowsY0 := 0, this.RowH := 0, this.RowGap := 0, this.PadY := 0
        this.Collapsed := FieldBossStartCollapsed, this.AutoCollapsed := false
        this.Faded := false, this.FadeArmed := false
        this.Filter       := Map("verde", true, "blu", true, "oro", true)
        this.StatusFilter := Map("on", true, "off", true)

        ; boss
        this.Status := Map()
        this.LoadBossList()

        this.WorkFn := ObjBindMethod(this, "Worker")
        this.FadeFn := ObjBindMethod(this, "FadeCheck")

        ; OCR di Windows (libreria OCR.ahk). Senza, il tool resta spento e il resto funziona.
        if !IsSet(OCR) {
            this.Why := Tr("manca OCR.ahk")
            return
        }
        try langs := OCR.GetAvailableLanguages()
        catch {
            this.Why := Tr("OCR di Windows non disponibile")
            return
        }
        this.OcrLang := InStr(langs, "en-US") ? "en-US" : "FirstFromAvailableLanguages"
        this.Ready := true

        InstallMouseHook()                                  ; stato fisico affidabile del tasto sinistro
        InstallKeybdHook()                                  ; ...e del tasto Travel (F)
        OnMessage(0x200, ObjBindMethod(this, "OnMouseMove")) ; hover sulle righe del pannello

        HotIfWinActive(this.Win)
        if (FieldBossMapKey != "")
            Hotkey("~" FieldBossMapKey, (*) => this.OnMapKey())
        Hotkey("~Esc", (*) => this.Cancel := true)
        if (FieldBossMapTestKey != "")
            Hotkey(FieldBossMapTestKey, (*) => this.Request(ObjBindMethod(this, "DebugMap")))
        if (FieldBossScanKey != "")
            Hotkey(FieldBossScanKey, (*) => this.Request(ObjBindMethod(this, "DebugScan")))
        if (FieldBossCoordKey != "")
            Hotkey(FieldBossCoordKey, (*) => this.DebugCoord())
        HotIfWinActive()

        ; Blocco dei click tra una fase e l'altra: attivo solo durante una ricerca, con il gioco in
        ; primo piano e il mouse NON sul pannello (che resta sempre usabile).
        HotIf((*) => this.BlockClicks && WinActive(this.Win) && !this.MouseOnPanel())
        Hotkey("*LButton", (*) => 0)
        Hotkey("*RButton", (*) => 0)
        HotIf()
    }

    MouseOnPanel() {
        MouseGetPos(,, &w)
        return this.IsPanel(w)
    }

    ; ---------------- Blocco del mouse (dalla scelta del boss al Travel) ----------------
    StartLock() {
        if !FieldBossLockMouse
            return
        MouseGetPos(&mx, &my)
        this.LockPt := {x: mx, y: my}
        SetTimer(this.LockFn, PerfLockTick)
    }

    StopLock() {
        SetTimer(this.LockFn, 0)
        this.LockPt := ""
    }

    ; riporta il mouse sul punto bloccato se l'hai mosso (solo con il gioco in primo piano)
    LockTick() {
        if (!IsObject(this.LockPt) || !WinActive(this.Win))
            return
        MouseGetPos(&mx, &my)
        if (mx != this.LockPt.x || my != this.LockPt.y)
            MouseMove(this.LockPt.x, this.LockPt.y, 0)
    }

    ; spostamento fatto dallo script: con il blocco attivo diventa il nuovo punto bloccato
    MoveTo(x, y) {
        if IsObject(this.LockPt)
            this.LockPt := {x: x, y: y}
        MouseMove(x, y, 0)
    }

    ; Legge FieldBossList (anche di nuovo, dall'anteprima delle impostazioni), tenendo gli stati già letti
    LoadBossList() {
        old := this.Status
        this.Bosses := Map(), this.Status := Map(), this.BossNorm := []
        for b in FieldBossList {
            g := StrLower(Trim(b.Length >= 2 ? b[2] : ""))
            if !FieldBossTool.Grades.Has(g)                 ; grado scritto male: oro
                g := "oro"
            this.Bosses[b[1]] := {grade: g, tier: b.Length >= 3 ? b[3] : 0}
            this.Status[b[1]] := old.Has(b[1]) ? old[b[1]] : ""   ; "on" / "off" / "" (non ancora letto)
            this.BossNorm.Push({name: b[1], n: FieldBossTool.Norm(b[1])})
        }
        this.BuiltFor := 0                      ; il pannello va ricostruito
    }

    ; ---------------- Anteprima (dalla finestra Impostazioni) ----------------
    ; Mostra pannello, leggenda, istruzioni, anello e indicazione di volo con i valori attuali.
    PreviewShow() {
        g := this.Geo()
        this.BuiltFor := 0, this.LegendFor := "", this.HintFor := 0, this.DirFor := 0
        this.HidePanel()
        if (IsObject(this.Legend) && this.LegendShown)
            this.Legend.Hide()
        this.LegendShown := false
        if PreviewAllows("panel")
            this.ShowPanel()
        if (FieldBossShowLegend && PreviewAllows("legend"))
            this.ShowLegend(g)
        this.Step := 1
        if (FieldBossHints && PreviewAllows("hint")) {
            this.HintShow(Tr("Clicca il BOSS"), Tr("Anteprima delle istruzioni"), "go")
            this.RingShow({x: g.x + Round(g.w * 0.36), y: g.y + Round(g.h * 0.55)})
        } else
            this.HintHide(), this.RingHide()
        if (FieldBossDirHint && PreviewAllows("dir"))
            this.DirShow(FieldBossTool.Compass(1, -1, 0), Tr("Anteprima"), true)
        else
            this.DirHide()
    }

    ; lingua cambiata: pannello, leggenda, istruzioni e direzione vanno ricostruiti
    ResetUi() {
        this.BuiltFor := 0, this.LegendFor := "", this.HintFor := 0, this.DirFor := 0
    }

    PreviewHide() {
        this.DirHide()
        this.HideAll()
    }

    ; ---------------- Accensione / ciclo di lavoro ----------------
    ; Spento (OFF) il tool non mostra il pannello e non fa ricerche, ma continua a
    ; riconoscere la mappa per mostrare la leggenda dei tasti.
    SetOn(on) {
        this.On := on
        if !on {
            this.Cancel := true, this.Pending := ""
            this.HidePanel()
        }
        this.NextCheck := 0                     ; ricontrolla subito la mappa
    }

    SetRunning(on) {
        this.Wanted := on
        run := this.Ready && on
        if (run = this.Running)
            return
        this.Running := run
        SetTimer(this.WorkFn, run ? PerfWorkerTick : 0)
        if !run {
            this.Cancel := true, this.Pending := ""
            this.HideAll()
            this.DirHide()
        }
    }

    ; Mette in coda un'azione (una sola alla volta; una nuova annulla quella in corso)
    Request(fn, delay := 0) {
        if !(this.Running && this.On)
            return
        if this.Busy
            this.Cancel := true
        this.Pending := {fn: fn, at: A_TickCount + delay}
    }

    ; Unico timer: esegue l'azione in coda, altrimenti ogni FieldBossCheckEvery ms controlla la mappa
    Worker() {
        if (IsObject(this.Pending) && A_TickCount >= this.Pending.at) {
            job := this.Pending, this.Pending := ""
            this.Busy := true, this.Cancel := false
            try job.fn.Call()
            catch as e
                ShowTip(Tr("Field Boss - errore:") " " e.Message, 4000)
            this.RingHide()                     ; fine fase: niente anello e mouse sbloccato
            if !IsObject(this.Pending) {        ; fine ricerca (Travel fatto, annullata o errore): click e
                this.BlockClicks := false       ; mouse liberi (restano bloccati solo se hai già scelto
                this.StopLock()                 ; un altro boss)
            }
            if !this.HintTimed                  ; resta solo un messaggio finale a tempo (es. "Premi F")
                this.HintHide()
            this.Busy := false
            this.NextCheck := 0
            return
        }
        if (A_TickCount < this.NextCheck)
            return
        this.NextCheck := A_TickCount + FieldBossCheckEvery
        try this.Watch()
    }

    Watch() {
        if PreviewMode                          ; anteprima aperta: non nascondere nulla
            return
        if !WinActive(this.Win)
            return (this.DirHide(), this.HideAll())
        if (!this.On && !FieldBossShowLegend)   ; niente da mostrare: nessuna lettura OCR
            return this.HideAll()
        if this.MapVisible() {
            this.ShowLegend(this.Geo())         ; la leggenda c'è anche con il tool spento
            if (this.On && this.InDungeon())    ; dungeon: niente pannello (e nessuna lettura della lista)
                this.HidePanel()
            else if this.On {
                this.ShowPanel()
                this.ReadList()                 ; se c'è la lista Field Boss aggiorna gli stati
            }
        } else {
            this.MapKind := ""                  ; alla prossima apertura si riconosce di nuovo il tipo di mappa
            this.HideAll()                      ; mappa chiusa: leggenda e pannello spariscono subito
        }
        if (this.Hover != "") {
            MouseGetPos(,, &win)
            if (win != this.Panel.Hwnd)
                this.SetHover("")
        }
    }

    OnMapKey() {
        this.NextCheck := A_TickCount + 200     ; mappa aperta/chiusa: ricontrolla quasi subito
        SetTimer(() => this.NextCheck := 0, -500)   ; e di nuovo dopo l'animazione di apertura
        if this.Busy {                          ; M durante una guida = annulla
            this.Cancel := true
            return
        }
        if FieldBossGuideOnOpen                 ; guida automatica all'apertura (disattivata di default)
            this.Step := 0, this.Request(ObjBindMethod(this, "GuideToFieldBoss"), FieldBossTool.MapOpenDelay)
    }

    ; Durante le attese (click, scroll) controlla ogni tanto che la mappa sia ancora aperta:
    ; se l'hai chiusa (X, Esc, Teleport...) annulla tutto e nasconde leggenda e pannello.
    StillOnMap(&lastCheck) {
        if (A_TickCount - lastCheck < 400)
            return true
        lastCheck := A_TickCount
        if this.MapVisible()
            return true
        this.Cancel := true
        this.HideAll()
        return false
    }

    ; ---------------- Flusso principale ----------------
    ; Il gioco blocca i click simulati: lo script porta il cursore su Exploration e
    ; poi su Field Boss e aspetta ogni volta il TUO click.
    GuideToFieldBoss() {
        if (this.MapVisible() && this.InDungeon())      ; nei dungeon non c'è la lista dei Field Boss
            return true
        if this.ListVisible()
            return true
        for step in [[FieldBossTool.PtExploration, "EXPLORATION"], [FieldBossTool.PtFieldBoss, "FIELD BOSS"]] {
            p := this.Pt(step[1], this.Geo())
            ok := this.ClickPhase({x: p[1], y: p[2]}, Tr("Clicca {1}", step[2]), Tr("Apro la lista dei Field Boss")
                                , FieldBossTool.GuideClickSec, (x, y, w) => this.IsPanel(w) ? -1 : true)
            if !ok
                return false
            Sleep(350)
        }
        return true
    }

    FindBoss(name) {
        this.Step := 0                          ; le fasi ripartono da 1 a ogni boss scelto
        if !this.ListVisible() && !this.GuideToFieldBoss()
            return
        this.HintShow(Tr("Cerco {1}...", name), Tr("Scorro la lista dei boss"), "wait")
        it := this.SearchList(name)
        if !it
            return this.HintShow(Tr("Boss non trovato"), Tr("{1} non è nella lista del gioco", name), "err", 3000)

        ; cursore sul nome: il Teleport si cerca SOLO dopo il tuo click su quella riga
        g := this.Geo(), r := this.Rc(FieldBossTool.RcList, g), tol := Round(FieldBossTool.NameTolerance * g.s)
        ok := this.ClickPhase(it, Tr("Clicca il BOSS"), name, 0
            , (x, y, w) => this.IsPanel(w) ? -1 : (x >= r[1] && x <= r[1] + r[3] && Abs(y - it.y) <= tol))
        if (ok && FieldBossFindTeleport) {
            this.HintShow(Tr("Cerco il Teleport più vicino..."), name, "wait")
            Sleep(FieldBossTool.MapPanDelay)
            this.GoToTeleport(name)
        }
    }

    ; Lista a schermo -> salto in fondo -> salto in cima -> riserva: scrolli tu e lo riconosce
    SearchList(name) {
        target := FieldBossTool.Norm(name)
        if (it := this.Locate(target))
            return it
        for dir in ["Down", "Up"] {
            if this.Cancel
                return 0
            this.Wheel(dir, FieldBossListScroll)
            if (it := this.Locate(target))
                return it
        }
        this.HintShow(Tr("Scrolla la lista dei boss"), Tr("Cerco {1}: lo riconosco appena compare", name), "wait")
        deadline := A_TickCount + FieldBossTool.ScrollWaitSec * 1000
        it := 0, chk := A_TickCount
        while (!it && !this.Cancel && A_TickCount < deadline && this.StillOnMap(&chk)) {
            it := this.Locate(target)
            Sleep(150)
        }
        return it
    }

    GoToTeleport(name) {
        d := this.DetectMapIcons()
        zoomed := false
        if (!d.purple.Length && FieldBossAutoZoomOut) {
            this.SetCollapsed(true, true)      ; resta visibile e riapribile con ▼, ma non copre la mappa
            this.ZoomOutOn(d.boss)
            zoomed := true
            d := this.DetectMapIcons()
        }
        ; il riquadro dei loot può coprire il Teleport più vicino: prima lo fa chiudere, poi cerca
        if (FieldBossCloseLoot = "always" || (FieldBossCloseLoot = "zoom" && zoomed)) {
            if !this.CloseLootPanel(d)
                return
            d := this.DetectMapIcons()
        }
        if !d.purple.Length
            return this.HintShow(Tr("Nessun Teleport trovato"), Tr("Prova a spostare o rimpicciolire la mappa"), "err", 3000)

        best := "", bestD := 1e18
        for p in d.purple {
            dd := (p.x - d.boss.x) ** 2 + (p.y - d.boss.y) ** 2
            if (dd < bestD)
                bestD := dd, best := p
        }
        rad := Round(FieldBossTool.IconRadius * this.Geo().s)
        onIcon := this.ClickPhase(best, Tr("Clicca il TELEPORT"), Tr("Il più vicino a {1}", name), 0
            , (x, y, w) => this.IsPanel(w) ? -1 : (Abs(x - best.x) <= rad && Abs(y - best.y) <= rad) ? true : -1)
        if !onIcon
            return
        ; il gioco blocca i tasti simulati: il Travel lo premi tu
        if !FieldBossDirHint {
            this.WaitTravel("", name)                    ; attende comunque il Travel per sbloccare i click
            return
        }
        dir := FieldBossTool.Compass(d.boss.x - best.x, d.boss.y - best.y, this.Geo().s)
        if this.WaitTravel(dir, name) {
            this.HintHide()
            if FieldBossDirDelay
                SetTimer(this.DirDelayFn := ObjBindMethod(this, "DirShow", dir, name), -FieldBossDirDelay)
            else
                this.DirShow(dir, name)
        }
    }

    ; Aspetta il Travel: il tasto F premuto FieldBossTravelPresses volte (= Teleport fatto).
    ; Se la mappa si chiude dopo almeno una pressione, conta come partito. false = annullato/scaduto.
    WaitTravel(dir, name) {
        need := Max(1, FieldBossTravelPresses), key := StrUpper(FieldBossTravelKey)
        times := need = 1 ? "" : Tr("{1} volte", need) " "
        sub := IsObject(dir) ? Tr("Poi vola verso {1} per raggiungere {2}", dir.label, name) : Tr("Buona caccia!")
        this.HintShow(Tr("Premi  {1}  {2}per il Travel", key, times), sub, "ok", 0, true)
        deadline := A_TickCount + FieldBossTravelWait * 1000, presses := 0, down := false, chk := A_TickCount
        while (!this.Cancel && A_TickCount < deadline) {
            isDown := GetKeyState(FieldBossTravelKey, "P")
            if (isDown && !down) {                         ; nuova pressione
                presses += 1
                if (presses >= need)
                    return true
                this.HintShow(Tr("Premi ancora  {1}", key), Tr("Pressione {1} di {2}", presses, need), "ok", 0, true)
            }
            down := isDown
            if (A_TickCount - chk >= 300) {                ; controllo mappa (OCR) ogni 0,3 s
                chk := A_TickCount
                if !WinActive(this.Win)
                    return false
                if !this.MapVisible()
                    return presses > 0                     ; mappa chiusa: partito solo se hai premuto F
            }
            Sleep(PerfPollMs)
        }
        return false
    }

    ; Direzione bussola (8 settori) dal Teleport al boss. Schermo: x verso destra = Est, y verso il basso = Sud.
    static Compass(dx, dy, s) {
        if (Sqrt(dx * dx + dy * dy) < 25 * s)
            return {label: Tr("il boss: è proprio qui"), short: Tr("QUI"), arrow: "◉"}
        static dirs := [["EST", "→"], ["NORD-EST", "↗"], ["NORD", "↑"], ["NORD-OVEST", "↖"]
                      , ["OVEST", "←"], ["SUD-OVEST", "↙"], ["SUD", "↓"], ["SUD-EST", "↘"]]
        ang := DllCall("msvcrt\atan2", "Double", -dy, "Double", dx, "Cdecl Double") * 57.29578   ; gradi, 0 = Est, 90 = Nord
        i := Mod(Round(ang / 45) + 8, 8) + 1
        return {label: Tr(dirs[i][1]), short: Tr(dirs[i][1]), arrow: dirs[i][2]}
    }

    ; ---------------- Indicazione della direzione (in alto al centro) ----------------
    BuildDir(g) {
        if IsObject(this.Dir)
            this.Dir.Destroy()
        s := g.s * FieldBossDirScale
        dw := Round(760 * s), dh := Round(150 * s), pad := Round(22 * s), aw := Round(120 * s)
        tx := pad + aw + Round(20 * s), tw := dw - tx - pad
        dg := Gui("+AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08080020")   ; non attiva, attraversabile
        info := UiC("Info")
        dg.BackColor := UiC("Deep"), dg.MarginX := 0, dg.MarginY := 0
        bar := Max(3, Round(6 * s))
        dg.AddText(Format("x0 y0 w{} h{} Background{}", dw, bar, info))
        dg.AddText(Format("x0 y{} w{} h{} Background{}", dh - bar, dw, bar, info))
        dg.SetFont("s" Round(58 * s) " bold c" info, "Segoe UI Symbol")
        this.DArrow := dg.AddText(Format("x{} y{} w{} h{} Center 0x200 BackgroundTrans", pad, bar, aw, dh - bar * 2), "")
        dg.SetFont("s" Round(13 * s) " bold c" UiC("Muted"), "Segoe UI")
        dg.AddText(Format("x{} y{} w{} h{} BackgroundTrans", tx, Round(18 * s), tw, Round(22 * s)), Tr("VOLA VERSO"))
        dg.SetFont("s" Round(34 * s) " bold c" UiC("Text"), "Segoe UI")
        this.DTitle := dg.AddText(Format("x{} y{} w{} h{} 0x200 BackgroundTrans", tx, Round(40 * s), tw, Round(56 * s)), "")
        dg.SetFont("s" Round(14 * s) " norm c" UiC("SubText"), "Segoe UI")
        this.DSub := dg.AddText(Format("x{} y{} w{} h{} 0x200 BackgroundTrans", tx, Round(98 * s), tw, Round(30 * s)), "")
        this.Dir := dg, this.DirFor := g.h, this.DirW := dw, this.DirH := dh
        dg.Show("Hide w" dw " h" dh)
        WinSetTransparent(238, dg.Hwnd)
    }

    DirShow(dir, name, preview := false) {
        if (!preview && !WinActive(this.Win))
            return
        g := this.Geo()
        if (this.DirFor != g.h || !IsObject(this.Dir))
            this.BuildDir(g)
        this.DArrow.Text := dir.arrow
        this.DTitle.Text := dir.short
        this.DirName := name, this.DirLeft := FieldBossDirSeconds
        this.DSub.Text := name "   ·   " this.DirLeft " s"
        this.Dir.Show(Format("NA x{} y{}", g.x + (g.w - this.DirW) // 2, g.y + Round(FieldBossDirTop * g.s)))
        SetTimer(this.DirTickFn, preview ? 0 : 1000)     ; in anteprima resta ferma
    }

    DirTick() {
        this.DirLeft -= 1
        if (this.DirLeft <= 0 || !IsObject(this.Dir))
            return this.DirHide()
        this.DSub.Text := this.DirName "   ·   " this.DirLeft " s"
    }

    DirHide() {
        SetTimer(this.DirTickFn, 0)
        if (this.HasOwnProp("DirDelayFn") && this.DirDelayFn)      ; freccia in attesa di comparire: annullata
            SetTimer(this.DirDelayFn, 0), this.DirDelayFn := ""
        if IsObject(this.Dir)
            this.Dir.Hide()
    }

    ; Porta il cursore su un punto vuoto vicino all'icona del boss e aspetta il tuo click,
    ; che chiude il riquadro dei loot senza spostare la mappa. false = annullato.
    CloseLootPanel(d) {
        g := this.Geo()
        r := FieldBossLootClickDist * g.s, clear := 45 * g.s
        icons := []                                  ; icone note da evitare (Teleport e teschi rossi)
        for list in [d.purple, d.red]
            for p in list
                icons.Push(p)
        spot := ""
        ; direzioni in ordine di preferenza: sinistra (lontano dal riquadro loot), poi le altre
        for dir in [[-1, 0], [-0.7, 0.7], [0, 1], [-0.7, -0.7], [0, -1], [0.7, 0.7], [0.7, -0.7], [1, 0]] {
            x := Round(d.boss.x + dir[1] * r), y := Round(d.boss.y + dir[2] * r)
            free := true
            for p in icons
                if (Abs(p.x - x) < clear && Abs(p.y - y) < clear) {
                    free := false
                    break
                }
            if free {
                spot := {x: x, y: y}
                break
            }
        }
        if !IsObject(spot)
            spot := {x: Round(d.boss.x - r), y: d.boss.y}
        ok := this.ClickPhase(spot, Tr("Clicca il PUNTO VUOTO"), Tr("Chiude il riquadro dei loot che copre i Teleport"), 0
                            , (x, y, w) => this.IsPanel(w) ? -1 : true)
        if ok
            Sleep(FieldBossTool.LootCloseDelay)      ; attende che il riquadro sparisca
        return ok
    }

    ; Mouse sul boss, N scrollate indietro e alcune avanti (allo zoom massimo i Teleport spariscono)
    ZoomOutOn(boss) {
        back := FieldBossZoomOutWheel = "WheelDown" ? "WheelUp" : "WheelDown"
        this.MoveTo(boss.x, boss.y)
        Sleep(40)
        SendInput("{" FieldBossZoomOutWheel " " FieldBossZoomOut "}")
        Sleep(150)
        if FieldBossZoomBack
            SendInput("{" back " " FieldBossZoomBack "}")
        Sleep(FieldBossTool.ZoomSettle)
    }

    ; Aspetta un click fisico del tasto sinistro (sec = 0: senza limite).
    ; accept(x, y, hwnd) -> true = accettato | false = ignorato, continua ad aspettare | -1 = annulla.
    ; lock = {x, y}: finché aspetta, il mouse viene riportato su quel punto (blocco).
    WaitClick(sec, accept, lock := "") {
        KeyWait("LButton")                     ; ignora un tasto ancora premuto
        deadline := sec ? A_TickCount + sec * 1000 : 0, chk := A_TickCount
        while (!this.Cancel && WinActive(this.Win) && (!deadline || A_TickCount < deadline) && this.StillOnMap(&chk)) {
            if IsObject(lock) {
                MouseGetPos(&lx, &ly)
                if (lx != lock.x || ly != lock.y)
                    MouseMove(lock.x, lock.y, 0)
            }
            if GetKeyState("LButton", "P") {
                MouseGetPos(&mx, &my, &win)
                KeyWait("LButton")
                r := accept(mx, my, win)
                if (r = -1)
                    return false
                if r
                    return true
            }
            Sleep(PerfPollMs)
        }
        return false
    }

    IsPanel(hwnd) => IsObject(this.Panel) && hwnd = this.Panel.Hwnd

    ; Una fase del "minigioco": cursore sul punto (bloccato se FieldBossLockMouse),
    ; istruzione grande in basso, anello pulsante sul punto, attesa del tuo click.
    ClickPhase(pt, title, sub, sec, accept) {
        this.Step += 1
        this.MoveTo(pt.x, pt.y)
        if FieldBossHints {
            this.HintShow(title, sub, "go")
            this.RingShow(pt)
        } else
            ToolTip(title (sub != "" ? "`n" sub : ""), pt.x + 25, pt.y + 20)
        wasBlocked := this.BlockClicks
        this.BlockClicks := false                 ; in questa fase il click deve arrivare al gioco
        ok := this.WaitClick(sec, accept, FieldBossLockMouse ? pt : "")
        Sleep(60)                                 ; lascia arrivare al gioco anche il rilascio del tasto
        this.BlockClicks := wasBlocked && ok      ; di nuovo bloccati fino alla fase successiva
        this.RingHide()
        if !FieldBossHints
            ToolTip()
        return ok
    }

    ; ---------------- Istruzioni a schermo ("minigioco") ----------------
    ; Riquadro grande in basso al centro: badge della fase + istruzione + dettaglio.
    ; kind: "go" = da fare (oro) | "wait" = attendi (blu) | "ok" = fatto (verde) | "err" = errore (rosso)
    static HintKinds => Map("go", UiC("Go"), "wait", UiC("Wait"), "ok", UiC("Ok"), "err", UiC("Err"))

    BuildHint(g) {
        if IsObject(this.Hint)
            this.Hint.Destroy()
        s := g.s * FieldBossHintScale
        hw := Round(920 * s), hh := Round(118 * s), pad := Round(22 * s)
        bw := Round(132 * s), bh := Round(64 * s), tx := pad + bw + Round(24 * s), tw := hw - tx - pad
        hg := Gui("+AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08080020")    ; non attiva, attraversabile
        hg.BackColor := UiC("Deep"), hg.MarginX := 0, hg.MarginY := 0
        this.HBar   := hg.AddText(Format("x0 y0 w{} h{}", hw, Max(3, Round(6 * s))))
        this.HBarB  := hg.AddText(Format("x0 y{} w{} h{}", hh - Max(3, Round(6 * s)), hw, Max(3, Round(6 * s))))
        hg.SetFont("s" Round(15 * s) " bold c" UiC("Deep"), "Segoe UI")
        this.HBadge := hg.AddText(Format("x{} y{} w{} h{} Center 0x200", pad, (hh - bh) // 2, bw, bh), "")
        hg.SetFont("s" Round(27 * s) " bold c" UiC("Text"), "Segoe UI")
        this.HTitle := hg.AddText(Format("x{} y{} w{} h{} 0x200 BackgroundTrans", tx, Round(16 * s), tw, Round(52 * s)), "")
        hg.SetFont("s" Round(14 * s) " norm c" UiC("SubText"), "Segoe UI")
        this.HSub   := hg.AddText(Format("x{} y{} w{} h{} 0x200 BackgroundTrans", tx, Round(70 * s), tw, Round(30 * s)), "")
        this.Hint := hg, this.HintFor := g.h, this.HintW := hw, this.HintH := hh
        hg.Show("Hide w" hw " h" hh)
        WinSetTransparent(238, hg.Hwnd)
    }

    ; ms > 0: sparisce da solo dopo ms. final = messaggio di chiusura (nessun numero di fase).
    HintShow(title, sub := "", kind := "go", ms := 0, final := false) {
        if (!PreviewMode && !WinActive(this.Win))   ; gioco non in primo piano: niente avvisi sopra altre app
            return
        if !FieldBossHints {
            if (kind = "err" || final)
                ShowTip(title (sub != "" ? "`n" sub : ""), ms ? ms : 2500)
            return
        }
        g := this.Geo()
        if (this.HintFor != g.h || !IsObject(this.Hint))
            this.BuildHint(g)
        col := FieldBossTool.HintKinds[kind]
        this.HBar.Opt("+Background" col), this.HBarB.Opt("+Background" col), this.HBadge.Opt("+Background" col)
        this.HBadge.Text := kind = "err" ? "!" : final ? "OK" : kind = "wait" ? "..." : Tr("FASE {1}", this.Step)
        this.HTitle.Text := title
        this.HSub.Text   := sub (kind = "go" ? "     ·     " Tr("Esc = annulla") : "")
        for c in [this.HBar, this.HBarB, this.HBadge]
            c.Redraw()
        this.Hint.Show(Format("NA x{} y{}", g.x + (g.w - this.HintW) // 2
                            , g.y + g.h - this.HintH - Round(FieldBossHintBottom * g.s)))
        this.HintTimed := ms > 0
        SetTimer(this.HintHideFn, ms ? -ms : 0)
    }

    HintHide(*) {
        SetTimer(this.HintHideFn, 0)
        if IsObject(this.Hint)
            this.Hint.Hide()
    }

    ; Anello pulsante attorno al punto da cliccare (attraversabile: il click arriva al gioco)
    RingShow(pt) {
        this.RingHide()
        s := this.Geo().s, rad := Round(30 * s), t := Max(3, Round(5 * s))
        ring := Gui("+AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08080020")
        ring.BackColor := UiC("Go")
        ring.Show(Format("NA x{} y{} w{} h{}", pt.x - rad, pt.y - rad, rad * 2, rad * 2))
        outer := CircleRgnAt(rad, rad, rad * 2), inner := CircleRgnAt(rad, rad, (rad - t) * 2)
        DllCall(Api.CombineRgn, "Ptr", outer, "Ptr", outer, "Ptr", inner, "Int", 4)   ; RGN_DIFF = ciambella
        DllCall(Api.DeleteObject, "Ptr", inner)
        DllCall(Api.SetWindowRgn, "Ptr", ring.Hwnd, "Ptr", outer, "Int", true)
        WinSetTransparent(255, ring.Hwnd)
        this.Ring := ring, this.RingT0 := A_TickCount
        SetTimer(this.RingFn, PerfRingTick)
    }

    RingPulse() {
        if !IsObject(this.Ring)
            return SetTimer(this.RingFn, 0)
        a := Round(150 + 105 * Abs(Sin((A_TickCount - this.RingT0) / 160)))
        try WinSetTransparent(a, this.Ring.Hwnd)
    }

    RingHide() {
        SetTimer(this.RingFn, 0)
        if IsObject(this.Ring)
            this.Ring.Destroy()
        this.Ring := ""
    }

    ; ---------------- Lettura schermo (OCR) ----------------
    Ocr(r, g) {
        q := Max(1, Min(3, PerfOcrQuality / g.s))   ; 1080p -> più zoom, 4K -> meno
        loop 2 {
            try return OCR.FromRect(r[1], r[2], r[3], r[4], {lang: this.OcrLang, scale: q})
            Sleep(60)
        }
        return {Lines: []}
    }

    ; Vero se la mappa è aperta (legge i tab in alto: Kibelisk / Map Pin ci sono solo nella mappa)
    MapVisible() {
        g := this.Geo(), t := ""
        for line in this.Ocr(this.Rc(FieldBossTool.RcTabs, g), g).Lines
            for w in line.Words
                t .= w.Text
        t := FieldBossTool.Norm(t)
        ; nei dungeon c'è solo il tab Kibelisk: Exploration e Map Pin ci sono solo sulla mappa del mondo
        this.TabsField := InStr(t, "explor") || InStr(t, "mappin")
        ; "Exploration" c'è anche negli Achievements: valgono solo i tab esclusivi della mappa
        return InStr(t, "kibelisk") || InStr(t, "mappin")
    }

    ; Vero se la mappa aperta è quella di un dungeon (chiamata subito dopo MapVisible).
    ; Mappa del mondo = si vedono i tab Exploration / Map Pin. Senza, si legge il titolo in alto a
    ; sinistra: un nome di FieldBossDungeons = dungeon sicuro. Finché non è chiaro il pannello resta
    ; nascosto (al massimo un controllo di ritardo sulla mappa del mondo, se l'OCR perde un tab).
    InDungeon() {
        if !FieldBossHideInDungeon
            return false
        if (this.MapKind != "")
            return this.MapKind = "dungeon"
        if this.TabsField {
            this.MapKind := "field"
            return false
        }
        if (A_TickCount - this.TitleAt > 1200) {         ; il titolo si legge al massimo ~1 volta al secondo
            this.TitleAt := A_TickCount
            g := this.Geo(), t := ""
            for line in this.Ocr(this.Rc(FieldBossTool.RcMapTitle, g), g).Lines
                for w in line.Words
                    t .= w.Text
            t := FieldBossTool.Norm(t)
            for name in StrSplit(FieldBossDungeons, "|") {
                n := FieldBossTool.Norm(name)
                if (n != "" && InStr(t, n)) {
                    this.MapKind := "dungeon"
                    return true
                }
            }
        }
        return true
    }

    ; Vero solo se nella colonna ci sono almeno 2 boss conosciuti
    ListVisible() {
        found := 0
        for it in this.ReadList()
            if (it.boss != "" && ++found >= 2)
                return true
        return false
    }

    Locate(target) {
        for it in this.ReadList()
            if FieldBossTool.Matches(FieldBossTool.Norm(it.text), target)
                return it
        return 0
    }

    ; Legge la colonna di sinistra: nomi con stato ("on" = "Spawned", "off" = "Time Left")
    ; e aggiorna i simboli di stato del pannello.
    ReadList() {
        g := this.Geo()
        out := [], last := ""
        for line in this.Ocr(this.Rc(FieldBossTool.RcList, g), g).Lines {
            txt := "", x1 := 1e9, y1 := 1e9, x2 := -1e9, y2 := -1e9
            for w in line.Words {
                if RegExMatch(w.Text, "^[\d.,]+m?$")       ; scarta la distanza (es. 2,096m)
                    continue
                txt .= (txt = "" ? "" : " ") w.Text
                x1 := Min(x1, w.x), y1 := Min(y1, w.y), x2 := Max(x2, w.x + w.w), y2 := Max(y2, w.y + w.h)
            }
            txt := Trim(RegExReplace(txt, "[.…]+$"))
            if (txt = "")
                continue
            if RegExMatch(txt, "i)^spawn") {
                if IsObject(last)
                    last.status := "on"
            } else if RegExMatch(txt, "i)^(time\s*left|\d)") {
                if IsObject(last)
                    last.status := "off"
            } else if (StrLen(txt) >= 4) {
                last := {text: txt, x: (x1 + x2) // 2, y: (y1 + y2) // 2, status: "", boss: this.BossFromText(txt)}
                out.Push(last)
            }
        }
        dirty := false
        for it in out
            if (it.boss != "" && it.status != "" && this.Status[it.boss] != it.status)
                this.Status[it.boss] := it.status, dirty := true
        if (dirty && IsObject(this.Panel) && this.UpdateStatusUI() && !(this.StatusFilter["on"] && this.StatusFilter["off"]))
            this.LayoutRows()
        return out
    }

    BossFromText(t) {
        n := FieldBossTool.Norm(t)
        for b in this.BossNorm
            if FieldBossTool.Matches(n, b.n)
                return b.name
        return ""
    }

    static Norm(t) => StrLower(RegExReplace(t, "[^A-Za-z]"))
    ; confronto per prefisso: riconosce anche i nomi troncati dal gioco ("Special Operations Leade...")
    static Matches(n, target) => (n = target || (StrLen(n) >= 6 && (InStr(target, n) = 1 || InStr(n, target) = 1)))

    ; ---------------- Lettura schermo (colori mappa) ----------------
    ; Cerca gruppi di pixel viola (Teleport) e rossi (teschio boss attivo).
    ; Il boss è dove il gioco centra la mappa; se lì vicino c'è un teschio rosso, usa quello.
    DetectMapIcons() {
        g  := this.Geo(), s := g.s, m := FieldBossTool.MapMargins
        x0 := g.x + Round(m[1] * s), y0 := g.y + Round(m[2] * s)
        w  := g.w - Round((m[1] + m[3]) * s), h := g.h - Round((m[2] + m[4]) * s)
        hint := IsObject(this.Hint) && DllCall("IsWindowVisible", "Ptr", this.Hint.Hwnd)
        if hint                                        ; il riquadro istruzioni non deve coprire i Teleport
            this.Hint.Hide(), Sleep(40)
        buf := FieldBossTool.Capture(x0, y0, w, h)
        if hint
            this.Hint.Show("NA")

        px1 := px2 := py1 := py2 := -1                 ; esclude il pannello
        if (this.Shown && IsObject(this.Panel)) {
            this.Panel.GetPos(&ppx, &ppy, &ppw, &pph)
            px1 := ppx - x0, py1 := ppy - y0, px2 := px1 + ppw, py2 := py1 + pph
        }
        step := Max(2, Round(3 * s)), purple := [], red := [], y := 0
        while (y < h) {
            base := y * w, x := 0, inY := (y >= py1 && y <= py2)
            while (x < w) {
                if !(inY && x >= px1 && x <= px2) {
                    v := NumGet(buf, (base + x) * 4, "UInt")
                    b := v & 0xFF, gg := (v >> 8) & 0xFF, r := (v >> 16) & 0xFF
                    if (r >= 110 && b >= 140 && gg + 45 <= r && gg + 60 <= b)
                        purple.Push(x0 + x, y0 + y)
                    else if (r >= 150 && gg <= 70 && b <= 80 && r - gg >= 100)
                        red.Push(x0 + x, y0 + y)
                }
                x += step
            }
            y += step
        }
        rad := Round(35 * s)
        tele  := FieldBossTool.Cluster(purple, rad, 8)
        skull := FieldBossTool.Cluster(red, rad, 8)

        bp := this.Pt(FieldBossTool.PtBossCenter, g), boss := {x: bp[1], y: bp[2]}
        bestD := (FieldBossTool.BossSnapRadius * s) ** 2
        for c in skull {
            dd := (c.x - bp[1]) ** 2 + (c.y - bp[2]) ** 2
            if (dd <= bestD)
                bestD := dd, boss := c
        }
        return {purple: tele, red: skull, boss: boss}
    }

    ; Raggruppa punti vicini (array piatto x,y,x,y...) e restituisce i centri dei gruppi grandi
    static Cluster(pts, rad, minHits) {
        cl := [], i := 1
        while (i < pts.Length) {
            px := pts[i], py := pts[i + 1], placed := false
            for c in cl
                if (Abs(px - c.sx / c.n) <= rad && Abs(py - c.sy / c.n) <= rad) {
                    c.sx += px, c.sy += py, c.n += 1, placed := true
                    break
                }
            if !placed
                cl.Push({sx: px, sy: py, n: 1})
            i += 2
        }
        out := []
        for c in cl
            if (c.n >= minHits)
                out.Push({x: Round(c.sx / c.n), y: Round(c.sy / c.n), n: c.n})
        return out
    }

    ; Cattura una zona dello schermo in un buffer BGRA a 32 bit
    static Capture(x, y, w, h) {
        sdc := DllCall("GetDC", "Ptr", 0, "Ptr")
        mdc := DllCall("CreateCompatibleDC", "Ptr", sdc, "Ptr")
        bi := Buffer(40, 0)
        NumPut("UInt", 40, bi, 0), NumPut("Int", w, bi, 4), NumPut("Int", -h, bi, 8)
        NumPut("UShort", 1, bi, 12), NumPut("UShort", 32, bi, 14)
        hbm := DllCall("CreateDIBSection", "Ptr", mdc, "Ptr", bi, "UInt", 0, "Ptr*", &bits := 0, "Ptr", 0, "UInt", 0, "Ptr")
        obm := DllCall("SelectObject", "Ptr", mdc, "Ptr", hbm, "Ptr")
        DllCall("gdi32\BitBlt", "Ptr", mdc, "Int", 0, "Int", 0, "Int", w, "Int", h, "Ptr", sdc, "Int", x, "Int", y, "UInt", 0x00CC0020)
        buf := Buffer(w * h * 4)
        DllCall("RtlMoveMemory", "Ptr", buf, "Ptr", bits, "UPtr", w * h * 4)
        DllCall("SelectObject", "Ptr", mdc, "Ptr", obm)
        DllCall("DeleteObject", "Ptr", hbm)
        DllCall("DeleteDC", "Ptr", mdc)
        DllCall("ReleaseDC", "Ptr", 0, "Ptr", sdc)
        return buf
    }

    ; ---------------- Geometria (scala e ancoraggi) ----------------
    Geo() {
        try WinGetClientPos(&x, &y, &w, &h, this.Win)
        if (!IsSet(w) || w < 100 || h < 100)        ; gioco non aperto (es. anteprima): schermo principale
            x := 0, y := 0, w := A_ScreenWidth, h := A_ScreenHeight
        return {x: x, y: y, w: w, h: h, s: h / FieldBossTool.BaseH}
    }

    static AX(bx, anchor, g) {
        switch anchor {
            case "C": return Round(g.w / 2 + (bx - FieldBossTool.BaseW / 2) * g.s)
            case "R": return Round(g.w - (FieldBossTool.BaseW - bx) * g.s)
            default:  return Round(bx * g.s)
        }
    }

    Pt(p, g) => [g.x + FieldBossTool.AX(p[1], p[3], g), g.y + Round(p[2] * g.s)]
    Rc(r, g) => [g.x + FieldBossTool.AX(r[1], r[5], g), g.y + Round(r[2] * g.s), Round(r[3] * g.s), Round(r[4] * g.s)]

    Wheel(dir, n) {
        r := this.Rc(FieldBossTool.RcList, this.Geo())
        this.MoveTo(r[1] + r[3] // 2, r[2] + r[4] // 2)
        Sleep(30)
        SendInput("{Wheel" dir " " n "}")
        Sleep(FieldBossTool.ScrollSettle)
    }

    ; ---------------- Pannello ----------------
    BuildPanel(ch) {
        pal := FieldBossTool.Col
        if IsObject(this.Panel)
            this.Panel.Destroy()
        this.Shown := false, this.Rows := [], this.RowByHwnd := Map(), this.Chips := Map()
        this.Hover := "", this.Extras := []

        s   := ch / FieldBossTool.BaseH * FieldBossPanelScale
        pad := Round(10 * s), w := Round(260 * s), bar := Max(3, Round(4 * s)), stW := Round(24 * s)
        this.RowH := Round(26 * s), this.RowGap := Max(1, Round(3 * s)), this.PadY := pad
        this.PW := w + pad * 2

        P := Gui("+AlwaysOnTop -Caption +ToolWindow +Border -DPIScale +E0x08000000")   ; non ruba il focus
        P.BackColor := pal.bg, P.MarginX := 0, P.MarginY := 0
        this.Panel := P

        ; Titolo + pulsante riduci/espandi
        this.TitleH := Round(22 * s), btnW := Round(26 * s)
        P.SetFont("s" Round(12 * s) " bold c" pal.title, "Segoe UI")
        P.AddText(Format("x{} y{} w{} h{} Center 0x200", pad + btnW, pad, w - btnW * 2, this.TitleH), "FIELD BOSS")
        P.SetFont("s" Round(10 * s) " bold c" pal.btn, "Segoe UI")
        this.BtnToggle := P.AddText(Format("x{} y{} w{} h{} Center 0x200 Background{}", pad + w - btnW, pad, btnW, this.TitleH, pal.row)
                                  , this.Collapsed ? "▼" : "▲")
        this.BtnToggle.OnEvent("Click", (*) => this.SetCollapsed(!this.Collapsed))

        ; Filtri: riga 1 gradi, riga 2 stato
        chipH := Round(23 * s), gap := Round(7 * s)
        P.SetFont("s" Round(9 * s) " bold", "Segoe UI")
        y := pad + this.TitleH + Round(8 * s)
        rows := [[FieldBossTool.GradeOrder, FieldBossTool.Grades, this.Filter, Round(76 * s)]
               , [FieldBossTool.StatusOrder, FieldBossTool.StatusInfo, this.StatusFilter, Round(110 * s)]]
        for rowDef in rows {
            keys := rowDef[1], info := rowDef[2], fmap := rowDef[3], cw := rowDef[4]
            x0 := pad + (w - (cw * keys.Length + gap * (keys.Length - 1))) // 2
            for i, key in keys {
                it := info[key]
                c := P.AddText(Format("x{} y{} w{} h{} Center 0x200", x0 + (i - 1) * (cw + gap), y, cw, chipH)
                             , (it.HasProp("sym") ? it.sym : "●") "  " Tr(it.label))
                c.OnEvent("Click", ObjBindMethod(this, "ToggleFilter", fmap, key))
                this.Chips[key] := {ctrl: c, map: fmap, info: it}
                this.Extras.Push(c)
                this.StyleChip(key)
            }
            y += chipH + Round(6 * s)
        }

        ; Separatore
        sepY := y + Round(3 * s)
        this.Extras.Push(P.AddText(Format("x{} y{} w{} h1 Background{}", pad, sepY, w, pal.sep)))
        this.RowsY0 := sepY + Round(9 * s)

        ; Righe boss (A-Z): barra grado | nome | importanza | stato
        fs := Round(10 * s), y := this.RowsY0, rh := this.RowH
        for name in this.SortedNames() {
            b    := this.Bosses[name]
            col  := FieldBossTool.Grades[b.grade].color
            tier := FieldBossTool.Tiers.Has(b.tier) ? FieldBossTool.Tiers[b.tier] : ""
            bc := P.AddText(Format("x{} y{} w{} h{} Background{}", pad, y, bar, rh, col))
            P.SetFont("s" fs " norm c" col, "Segoe UI")
            tc := P.AddText(Format("x{} y{} w{} h{} 0x200 Background{}", pad + bar, y, w - bar - stW * 2, rh, pal.row), "   " name)
            P.SetFont("s" fs " norm c" (tier ? tier.color : col), "Segoe UI Emoji")
            bd := P.AddText(Format("x{} y{} w{} h{} Center 0x200 Background{}", pad + w - stW * 2, y, stW, rh, pal.row), tier ? tier.sym : "")
            P.SetFont("s" fs " bold", "Segoe UI Symbol")
            st := P.AddText(Format("x{} y{} w{} h{} Center 0x200 Background{}", pad + w - stW, y, stW, rh, pal.row), "")
            row := {name: name, grade: b.grade, ctrls: [bc, tc, bd, st], cells: [tc, bd, st], st: st, cur: "?"}
            for c in row.cells {
                c.OnEvent("Click", ObjBindMethod(this, "PickRow", name))
                this.RowByHwnd[c.Hwnd] := row
            }
            this.Rows.Push(row)
        }
        ; Firma in fondo al pannello
        P.SetFont("s" Round(8 * s) " norm c" pal.offTxt, "Segoe UI")
        this.FooterH := Round(14 * s), this.FooterGap := Round(5 * s)
        this.Footer := P.AddText(Format("x{} y{} w{} h{} Right", pad, y, w, this.FooterH), "Field Boss - by VaLeTecK")
        this.Extras.Push(this.Footer)           ; nascosta quando il pannello è ridotto

        this.BuiltFor := ch
        this.UpdateStatusUI()
        this.LayoutRows()
    }

    SortedNames() {
        s := ""
        for name in this.Bosses
            s .= name "`n"
        return StrSplit(Sort(RTrim(s, "`n")), "`n")
    }

    StyleChip(key) {
        ch := this.Chips[key], c := ch.ctrl
        on := ch.map[key]
        c.Opt("+Background" (on ? ch.info.dim : FieldBossTool.Col.off))
        c.SetFont("c" (on ? ch.info.color : FieldBossTool.Col.offTxt))
        c.Redraw()
    }

    ToggleFilter(fmap, key, *) {
        n := 0
        for k, v in fmap
            n += v
        if (fmap[key] && n = 1)                 ; almeno un filtro per riga resta acceso
            return
        fmap[key] := !fmap[key]
        this.StyleChip(key)
        this.LayoutRows()
    }

    ; auto = riduzione fatta dallo script (zoom indietro, scelta boss): si annulla alla chiusura della mappa
    SetCollapsed(v, auto := false) {
        this.Collapsed := v
        this.AutoCollapsed := v && auto
        if IsObject(this.BtnToggle)
            this.BtnToggle.Text := v ? "▼" : "▲"
        this.LayoutRows()
    }

    RowVisible(r) {
        if !this.Filter[r.grade]
            return false
        st := this.Status[r.name]
        return st = "" ? this.StatusFilter["on"] && this.StatusFilter["off"]   ; non ancora letto
                       : this.StatusFilter[st]
    }

    LayoutRows() {
        if !IsObject(this.Panel)
            return
        y := this.RowsY0, yFull := this.RowsY0
        for r in this.Rows {
            vis := this.RowVisible(r), show := vis && !this.Collapsed
            for c in r.ctrls {
                c.Visible := show
                if show
                    c.Move(, y)
            }
            if vis
                y += this.RowH + this.RowGap
        }
        for c in this.Extras
            c.Visible := !this.Collapsed
        bottom := Max(y - this.RowGap, this.RowsY0)
        this.Footer.Move(, bottom + this.FooterGap)
        this.PHFull := bottom + this.FooterGap + this.FooterH + this.PadY // 2
        this.PH := this.Collapsed ? this.PadY * 2 + this.TitleH : this.PHFull
        if this.Shown {
            this.Panel.Show("NoActivate w" this.PW " h" this.PH)
            this.Reposition()
        }
    }

    ; Aggiorna i simboli di stato (solo quelli cambiati, per non sfarfallare)
    UpdateStatusUI() {
        changed := false
        for r in this.Rows {
            st := this.Status[r.name]
            if (st = r.cur)
                continue
            r.cur := st, changed := true
            if (st != "")
                r.st.SetFont("c" FieldBossTool.StatusInfo[st].color)
            r.st.Text := st = "" ? "" : FieldBossTool.StatusInfo[st].sym
        }
        return changed
    }

    ; Lato destro, centrato in verticale; da ridotto il titolo resta dov'era
    Reposition() {
        g := this.Geo()
        this.Panel.GetPos(,, &pw, &ph)
        border := ph - this.PH
        this.Panel.Move(g.x + g.w - pw - Round(FieldBossPanelMarginR * g.s)
                      , g.y + (g.h - (this.PHFull + border)) // 2 + Round(FieldBossPanelOffsetY * g.s))
    }

    ShowPanel() {
        g := this.Geo()
        if (this.BuiltFor != g.h)
            this.BuildPanel(g.h)
        if this.Shown
            return
        this.Panel.Show("Hide w" this.PW " h" this.PH)
        this.Reposition()
        this.Panel.Show("NoActivate")
        this.Shown := true
        if this.Faded
            WinSetTransparent(FieldBossFadeAlpha, this.Panel.Hwnd)
    }

    ; Mappa chiusa (o gioco non in primo piano): nasconde tutto e rimette il pannello com'era
    ; prima delle modifiche automatiche, così alla riapertura è di nuovo aperto e opaco.
    HideAll() {
        this.HintHide(), this.RingHide()
        this.BlockClicks := false, this.StopLock()
        if (IsObject(this.Legend) && this.LegendShown)
            this.Legend.Hide()
        this.LegendShown := false
        this.HidePanel()
        if this.AutoCollapsed
            this.SetCollapsed(false)
        if this.Faded
            this.SetFaded(false)
    }

    HidePanel() {
        if (IsObject(this.Panel) && this.Shown)
            this.Panel.Hide()
        this.Shown := false
        this.SetHover("")
    }

    ; ---------------- Leggenda dei tasti ----------------
    ; Riga di "tasti" in cima allo schermo, al centro: ON/OFF dei tool e Annulla (niente diagnosi).
    ; Non riceve click e non ruba il focus.
    BuildLegend(g) {
        if IsObject(this.Legend)
            this.Legend.Destroy()
        s  := g.s * FieldBossLegendScale
        fs := Round(9.5 * s), gap := Round(14 * s), pad := Round(8 * s)
        L  := Gui("+AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08000020")   ; attraversabile, non attiva
        L.BackColor := UiC("Deep"), L.MarginX := pad, L.MarginY := Round(5 * s)
        items := [[HudToggleKey, "HUD", Hud.On]
                , [HiddenCubeToggleKey, "Hidden Cube", HiddenCube.On]
                , [FieldBossToggleKey, "Field Boss", this.On]
                , [SettingsKey, Tr("Impostazioni"), ""]
                , ["Esc", Tr("Annulla"), ""]]
        L.SetFont("s" fs " bold c" UiC("Accent"), "Segoe UI")
        L.AddText("xm ym h" Round(20 * s) " 0x200 BackgroundTrans", "AION 2 Wingman " AppVersion)
        L.SetFont("s" Round(8 * s) " norm c" UiC("Muted"), "Segoe UI")
        L.AddText("x+" Round(5 * s) " yp h" Round(20 * s) " 0x200 BackgroundTrans", "by VaLeTecK")
        first := false                                  ; i tasti seguono sempre il titolo "AION 2 Wingman"
        for it in items {
            if (it[1] = "")
                continue
            L.SetFont("s" fs " bold c" UiC("Deep"), "Segoe UI")
            L.AddText((first ? "xm ym" : "x+" gap " yp") " Background" UiC("SubText") " Center 0x200 h" Round(20 * s)
                    , " " FieldBossTool.KeyLabel(it[1]) " ")
            L.SetFont("s" fs " norm c" UiC("Text"), "Segoe UI")
            L.AddText("x+" Round(6 * s) " yp h" Round(20 * s) " 0x200 BackgroundTrans", it[2])
            if (it[3] != "") {
                L.SetFont("s" fs " bold c" (it[3] ? UiC("Ok") : UiC("Err")), "Segoe UI")
                L.AddText("x+" Round(5 * s) " yp h" Round(20 * s) " 0x200 BackgroundTrans", it[3] ? "ON" : "OFF")
            }
            first := false
        }
        this.Legend := L
        L.Show("Hide AutoSize")
        WinSetTransparent(FieldBossLegendAlpha, L.Hwnd)
    }

    ShowLegend(g) {
        if !FieldBossShowLegend
            return
        key := g.h "|" Hud.On "|" HiddenCube.On "|" this.On   ; risoluzione + stato dei tool
        if (this.LegendFor != key || !IsObject(this.Legend))
            this.BuildLegend(g), this.LegendFor := key, this.LegendShown := false
        if this.LegendShown
            return
        this.Legend.GetPos(,, &lw)
        this.Legend.Show("NoActivate x" (g.x + (g.w - lw) // 2) " y" (g.y + Round(FieldBossLegendY * g.s)))
        this.LegendShown := true
    }

    RefreshLegend() {
        if this.LegendShown                  ; se è a schermo si aggiorna subito, altrimenti alla prossima apertura
            try this.ShowLegend(this.Geo())
    }

    ; "^+2" -> "Ctrl+Shift+2", "m" -> "M"
    static KeyLabel(k) {
        mods := Map("^", "Ctrl+", "+", "Shift+", "!", "Alt+", "#", "Win+", "~", "", "*", "")
        out := ""
        while (StrLen(k) > 1 && mods.Has(SubStr(k, 1, 1)))
            out .= mods[SubStr(k, 1, 1)], k := SubStr(k, 2)
        if (k = "SC029")                     ; tasto a sinistra dell'1 indicato per posizione
            k := "\"
        return out (StrLen(k) = 1 ? StrUpper(k) : k)
    }

    PickRow(name, *) {
        switch FieldBossPickAction {
            case "collapse": this.SetCollapsed(true, true)
            case "fade":     this.SetFaded(true)
        }
        this.BlockClicks := FieldBossBlockClicks && this.Running && this.On   ; click bloccati da qui al Travel
        if (this.Running && this.On)
            this.StartLock()                    ; mouse bloccato subito, da qui al Travel
        this.Request(() => this.FindBoss(name))
    }

    ; Trasparenza: torna opaco solo quando il mouse, dopo essere uscito dal pannello, ci rientra
    SetFaded(v) {
        this.Faded := v, this.FadeArmed := false
        if IsObject(this.Panel)
            WinSetTransparent(v ? FieldBossFadeAlpha : "Off", this.Panel.Hwnd)
        SetTimer(this.FadeFn, v ? 100 : 0)
    }

    FadeCheck() {
        if !IsObject(this.Panel)
            return
        MouseGetPos(,, &win)
        if (win != this.Panel.Hwnd)
            this.FadeArmed := true
        else if this.FadeArmed
            this.SetFaded(false)
    }

    OnMouseMove(wParam, lParam, msg, hwnd) {
        this.SetHover(this.RowByHwnd.Has(hwnd) ? this.RowByHwnd[hwnd] : "")
    }

    SetHover(row) {
        if (row = this.Hover)
            return
        for pair in [[this.Hover, FieldBossTool.Col.row], [row, FieldBossTool.Col.hover]]
            if IsObject(pair[1])
                for c in pair[1].cells
                    c.Opt("+Background" pair[2]), c.Redraw()
        this.Hover := row
    }

    ; ---------------- Diagnosi ----------------
    ; Riquadri: viola = Teleport trovati, rosso = teschi attivi, giallo = posizione del boss
    DebugMap() {
        d := this.DetectMapIcons()
        for p in d.purple
            FieldBossTool.Mark(p.x, p.y, "C040FF")
        for p in d.red
            FieldBossTool.Mark(p.x, p.y, "FF3030")
        FieldBossTool.Mark(d.boss.x, d.boss.y, "FFE040", 28)
        ShowTip(Tr("Teleport: {1}   Teschi rossi: {2}", d.purple.Length, d.red.Length), 3000)
    }

    DebugScan() {
        s := Tr("Lingua OCR: {1}`nMappa aperta: {2}", this.OcrLang, this.MapVisible() ? Tr("sì") : Tr("no")) "`n"
        for it in this.ReadList()
            s .= it.text "  [" (it.status = "" ? "?" : it.status) "]  @ " it.x "," it.y "`n"
        ShowTip(s, 6000)
    }

    DebugCoord() {
        MouseGetPos(&mx, &my)
        g := this.Geo()
        by := Round((my - g.y) / g.s)
        bl := Round((mx - g.x) / g.s)
        bc := Round((mx - g.x - g.w / 2) / g.s + FieldBossTool.BaseW / 2)
        A_Clipboard := bc ", " by
        ShowTip(Tr("Ancorato al centro: {1}, {2}  (copiato)`nAncorato a sinistra: {3}, {2}", bc, by, bl), 3000)
    }

    static Mark(x, y, color, r := 20) {
        g := Gui("+AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08000020")   ; attraversabile dai click
        g.BackColor := color
        sz := r * 2, t := 3
        g.Show("NA x" (x - r) " y" (y - r) " w" sz " h" sz)
        WinSetRegion(Format("0-0 {1}-0 {1}-{1} 0-{1} 0-0 {2}-{2} {3}-{2} {3}-{3} {2}-{3} {2}-{2}", sz, t, sz - t), g.Hwnd)
        SetTimer(() => g.Destroy(), -3000)
    }
}

; ==============================================================================
; === IMPOSTAZIONI: interfaccia grafica per la CONFIG ===
; ==============================================================================
; Apre una finestra con il menu delle funzioni (a sinistra), l'elenco delle impostazioni
; della categoria scelta, la descrizione presa dai commenti della CONFIG e un esempio
; visivo. "Salva e riavvia" riscrive i valori direttamente nella CONFIG di questo file
; (prima ne fa una copia .bak) e riavvia lo script.
; Si apre con il tasto SettingsKey, dal menu dell'icona nella barra di Windows o con un
; doppio click sull'icona.
class SettingsEditor {
    ; ---- Menu: [titolo, introduzione, variabili]  oppure  [titolo, introduzione, [sottomenu...]] ----
    static Tree := [
        ["Preset", "", "PRESET"],
        ["Generale", "Impostazioni comuni a tutta la suite.", ["Language", "GameExe", "ClickThrough", "SplashEnabled", "SplashHold", "SplashScale"]],
        ["Tema", "Colori di tutta la suite. I temi pronti non si modificano: per crearne uno tuo partendo da un tema qualsiasi usa Editor temi.",
            ["Theme", "ViCountdown", "ViCountdownDate", "ThemeColorBg", "ThemeColorRow", "ThemeColorHover", "ThemeColorLine", "ThemeColorAccent", "ThemeColorText", "ThemeColorSubText", "ThemeColorMuted", "ThemeColorDeep", "ThemeColorGo", "ThemeColorWait", "ThemeColorOk", "ThemeColorErr", "ThemeColorInfo", "ThemeColorWinBg", "ThemeColorWinText", "ThemeColorWinSub", "ThemeColorWinField"]],
        ["Editor temi", "", "THEMES"],
        ["Prestazioni", "Quanto spesso lo script controlla lo schermo e ridisegna l'HUD. Profili da `"potato`" (PC datati, meno CPU) "
            . "a `"gigachad`" (PC top, tutto iperreattivo). Con `"manuale`" valgono i singoli valori dell'elenco.",
            ["PerfProfile", "AnimInterval", "HiddenCubeInterval", "HiddenCubeLockInterval", "FieldBossCheckEvery",
             "PerfWorkerTick", "PerfLockTick", "PerfPollMs", "PerfRingTick", "PerfOcrQuality"]],
        ["Tasti", "Tutti i tasti in un unico posto.  ^ = Ctrl   + = Shift   ! = Alt   # = Win.  Lascia vuoto per disattivare un tasto.`nI tasti funzionano solo con il gioco in primo piano (tranne quello delle impostazioni).",
            ["CombatKey", "LootKey", "HudToggleKey", "HiddenCubeToggleKey", "FieldBossToggleKey",
             "FieldBossMapKey", "FieldBossTravelKey", "SettingsKey",
             "HiddenCubeTestKey", "FieldBossCoordKey", "FieldBossMapTestKey", "FieldBossScanKey"]],
        ["HUD overlay", "Mirino, barre e icone LOOT / COMBAT. Si accende con i segnali F9 / F10 inviati dalle tue macro.", [
            ["Generale e macro", "MACRO DI COMBAT: metti F9 in spam per tutta la durata della macro.`nMACRO DI LOOT: inserisci F10 con un wait di 1350 ms.`nSe le macro hanno pause più lunghe alza i Timeout.",
                ["HudEnabled", "HudBaseHeight", "CombatTimeout", "LootTimeout", "CombatGrace", "LootGrace"]],
            ["Colori", "Colori dell'HUD da attivo e da inattivo.",
                ["ColorActive", "ColorIdleCombat", "ColorIdleLoot", "CombatIdleColor", "ColorBorder"]],
            ["Mirino", "Frecce al centro dello schermo.   OFF = <<<  >>>      ON = >>>  <<<  (animate)",
                ["OffsetX", "OffsetY", "ChevronGap", "ChevronCount",
                 "ChevronWidthOff", "ChevronWidthOn", "ChevronHeightOff", "ChevronHeightOn",
                 "ChevronThicknessOff", "ChevronThicknessOn", "ChevronSpacingOff", "ChevronSpacingOn",
                 "ChevronShapeOff", "ChevronShapeOn",
                 "ChevronAnimMode", "ChevronAnimCycle", "ChevronPulseMin", "ChevronPulseMax",
                 "ChevronMorphInTime", "ChevronMorphOutTime"]],
            ["Barre", "Due barre a trapezio sotto il centro dello schermo, ognuna divisa in due metà.",
                ["Bar1Enabled", "Bar2Enabled", "Bar1MaxWidth", "Bar2MaxWidth", "Bar1MaxHeight", "Bar2MaxHeight",
                 "Bar1BorderSize", "Bar2BorderSize", "Bar1OffsetX", "Bar2OffsetX", "Bar1OffsetY", "Bar2OffsetY",
                 "Bar1CenterGap", "Bar2CenterGap", "Bar1Skew", "Bar2Skew"]],
            ["Icone - generale", "Opzioni comuni alle due icone. Con le icone speculari sposti il Loot e il Combat lo segue dall'altro lato.",
                ["IconAutoFit", "IconMirror"]],
            ["Icona Loot", "Icona LOOT (F10), a sinistra.",
                ["LootShape", "LootSize", "LootBorderSize", "LootOffsetX", "LootOffsetY", "LootTextLine1", "LootEmoji", "LootTextLine3",
                 "LootBaseFontSize", "LootEmojiSize", "LootLine1OffsetX", "LootLine1OffsetY",
                 "LootEmojiOffsetX", "LootEmojiOffsetY", "LootLine3OffsetX", "LootLine3OffsetY",
                 "LootTextColor", "LootOutlineColor"]],
            ["Icona Combat", "Icona COMBAT (F9), a destra.",
                ["CombatIconEnabled", "CombatShape", "CombatSize", "CombatBorderSize", "CombatOffsetX", "CombatOffsetY",
                 "CombatTextLine1", "CombatEmoji", "CombatTextLine3",
                 "CombatFontSize", "CombatEmojiSize", "CombatLine1OffsetX", "CombatLine1OffsetY",
                 "CombatEmojiOffsetX", "CombatEmojiOffsetY", "CombatLine3OffsetX", "CombatLine3OffsetY",
                 "CombatTextColor", "CombatOutlineColor"]],
            ["Effetti Loot", "Effetti animati dell'icona Loot quando è attiva. Si possono combinare.",
                ["LootAnim", "LootFxPadding",
                 "LootPulseCycle", "LootPulseSize", "LootPulseOpacity", "LootPulseColor",
                 "LootRingCycle", "LootRingCount", "LootRingDistance", "LootRingThickness", "LootRingOpacity", "LootRingColor",
                 "LootSpinCycle", "LootSpinArc", "LootSpinThickness", "LootSpinColor",
                 "LootGlowCycle", "LootGlowColor", "LootGlowAmount"]],
            ["Effetti Combat", "Effetti animati dell'icona Combat quando è attiva. Si possono combinare.",
                ["CombatAnim", "CombatFxPadding",
                 "CombatPulseCycle", "CombatPulseSize", "CombatPulseOpacity", "CombatPulseColor",
                 "CombatRingCycle", "CombatRingCount", "CombatRingDistance", "CombatRingThickness", "CombatRingOpacity", "CombatRingColor",
                 "CombatSpinCycle", "CombatSpinArc", "CombatSpinThickness", "CombatSpinColor",
                 "CombatGlowCycle", "CombatGlowColor", "CombatGlowAmount"]],
            ["Transizioni", "Dissolvenze e passaggi tra stato attivo e inattivo.",
                ["AnimInterval", "FadeInTime", "FadeOutTime", "FadeEasing", "ColorFadeInTime", "ColorFadeOutTime",
                 "LootMorphInTime", "LootMorphOutTime", "LootFadeOutTime", "LootColorFadeOutTime",
                 "CombatMorphInTime", "CombatMorphOutTime", "CombatFadeOutTime", "CombatColorFadeOutTime",
                 "EnableCrosshairFadeIn", "EnableCrosshairFadeOut", "EnableBar1FadeIn", "EnableBar1FadeOut",
                 "EnableBar2FadeIn", "EnableBar2FadeOut", "EnableLootFadeIn", "EnableLootFadeOut",
                 "EnableCombatFadeIn", "EnableCombatFadeOut"]]]],
        ["Hidden Cube", "Quando compare la finestra degli Hidden Cube porta il mouse su `"Open with Key`" e ce lo tiene bloccato.",
            ["HiddenCubeEnabled", "HiddenCubeInterval", "HiddenCubeCheckSlot", "HiddenCubeOffsetX", "HiddenCubeOffsetY",
             "HiddenCubeLockMouse", "HiddenCubeLockInterval", "HiddenCubeRearmTime",
             "HiddenCubeAutoClick", "HiddenCubeClickDelay", "HiddenCubeDebug"]],
        ["Field Boss", "Pannello dei boss sulla mappa, ricerca del boss e del Teleport più vicino, direzione di volo.", [
            ["Generale", "Accensione e comportamento all'apertura della mappa.",
                ["FieldBossEnabled", "FieldBossGuideOnOpen", "FieldBossHideInDungeon", "FieldBossDungeons", "FieldBossCheckEvery"]],
            ["Fasi di click", "Dopo la scelta di un boss: blocco del mouse e dei click, istruzioni grandi in basso al centro.",
                ["FieldBossLockMouse", "FieldBossBlockClicks", "FieldBossHints", "FieldBossHintScale", "FieldBossHintBottom"]],
            ["Pannello", "Il pannello con l'elenco dei boss sul lato destro della mappa.",
                ["FieldBossPanelScale", "FieldBossPanelMarginR", "FieldBossPanelOffsetY", "FieldBossStartCollapsed",
                 "FieldBossPickAction", "FieldBossFadeAlpha"]],
            ["Leggenda", "La barra dei tasti in cima allo schermo con la mappa aperta.",
                ["FieldBossShowLegend", "FieldBossLegendScale", "FieldBossLegendY", "FieldBossLegendAlpha"]],
            ["Ricerca e Teleport", "Come lo script trova il boss nella lista e il Teleport più vicino.",
                ["FieldBossListScroll", "FieldBossFindTeleport", "FieldBossAutoZoomOut", "FieldBossZoomOut",
                 "FieldBossZoomBack", "FieldBossZoomOutWheel", "FieldBossCloseLoot", "FieldBossLootClickDist"]],
            ["Travel e direzione", "Dopo il click sul Teleport: pressioni di F per partire e freccia con la direzione del boss.",
                ["FieldBossTravelPresses", "FieldBossTravelWait", "FieldBossDirHint", "FieldBossDirSeconds",
                 "FieldBossDirDelay", "FieldBossDirTop", "FieldBossDirScale"]],
            ["Elenco boss", "", "BOSS"]]],
        ["Aggiornamenti", "Controllo e installazione delle nuove versioni pubblicate su GitHub. Le tue impostazioni restano dopo ogni aggiornamento.",
            ["UpdateMode", "UpdateCheckHours", "UpdateRepo"]],
        ["Manutenzione", "", "MAINT"]
    ]

    ; ---- Nomi leggibili ----
    static Labels := Map(
        "Language", "Lingua",
        "IconAutoFit", "Testo ed emoji automatici",
        "UpdateMode", "Aggiornamenti automatici", "UpdateCheckHours", "Controlla ogni (ore)", "UpdateRepo", "Repository GitHub", "IconMirror", "Icona Combat speculare al Loot",
        "CombatSize", "Grandezza icona (altezza)", "CombatBorderSize", "Bordino nero",
        "FieldBossHideInDungeon", "Nascondi il pannello nei dungeon", "FieldBossDungeons", "Nomi dei dungeon",
        "ViCountdown", "Easter egg: countdown GTA VI", "ViCountdownDate", "Data di uscita GTA VI",
        "Theme", "Tema dei colori",
        "ThemeColorBg", "Sfondo pannelli",
        "ThemeColorRow", "Sfondo righe e pulsanti",
        "ThemeColorHover", "Riga sotto il mouse",
        "ThemeColorLine", "Linee di separazione",
        "ThemeColorAccent", "Titoli (accento)",
        "ThemeColorText", "Testo principale",
        "ThemeColorSubText", "Testo secondario",
        "ThemeColorMuted", "Testo spento",
        "ThemeColorDeep", "Sfondo istruzioni e freccia",
        "ThemeColorGo", "Istruzione da fare e anello",
        "ThemeColorWait", "Istruzione attendi",
        "ThemeColorOk", "Fatto / ON",
        "ThemeColorErr", "Errore / OFF",
        "ThemeColorInfo", "Freccia di direzione",
        "ThemeColorWinBg", "Finestra: sfondo",
        "ThemeColorWinText", "Finestra: testo",
        "ThemeColorWinSub", "Finestra: testo secondario",
        "ThemeColorWinField", "Finestra: elenchi e caselle",
        "PerfProfile", "Profilo prestazioni", "PerfWorkerTick", "Ciclo di lavoro Field Boss (ms)",
        "PerfLockTick", "Blocco mouse Field Boss (ms)", "PerfPollMs", "Attesa click/tasti (ms)",
        "PerfRingTick", "Anello pulsante (ms)", "PerfOcrQuality", "Qualità OCR",
        "GameExe", "Processo del gioco", "ClickThrough", "Click attraverso l'HUD",
        "SplashEnabled", "Splash all'avvio", "SplashHold", "Splash: durata a schermo (s)", "SplashScale", "Splash: dimensione",
        "CombatKey", "Segnale Combat (macro)", "LootKey", "Segnale Loot (macro)",
        "HudToggleKey", "HUD overlay ON/OFF", "HiddenCubeToggleKey", "Hidden Cube ON/OFF", "FieldBossToggleKey", "Field Boss ON/OFF",
        "FieldBossMapKey", "Tasto mappa del gioco", "FieldBossTravelKey", "Tasto Travel del gioco", "SettingsKey", "Apri impostazioni",
        "HiddenCubeTestKey", "Diagnosi Hidden Cube", "FieldBossCoordKey", "Diagnosi: coordinate mouse",
        "FieldBossMapTestKey", "Diagnosi: icone sulla mappa", "FieldBossScanKey", "Diagnosi: lettura lista boss",
        "HudEnabled", "HUD attivo all'avvio", "HudBaseHeight", "Risoluzione dei valori HUD", "CombatTimeout", "Spegnimento Combat dopo (ms)", "LootTimeout", "Spegnimento Loot dopo (ms)",
        "CombatGrace", "Combat acceso almeno (ms)", "LootGrace", "Loot acceso almeno (ms)",
        "ColorActive", "Colore attivo", "ColorIdleCombat", "Colore inattivo mirino/barre", "ColorIdleLoot", "Colore inattivo Loot",
        "CombatIdleColor", "Colore inattivo Combat", "ColorBorder", "Colore cornici",
        "OffsetX", "Posizione orizzontale", "OffsetY", "Posizione verticale", "ChevronGap", "Spazio centrale", "ChevronCount", "Frecce per lato",
        "ChevronWidthOff", "Larghezza freccia (OFF)", "ChevronWidthOn", "Larghezza freccia (ON)",
        "ChevronHeightOff", "Altezza freccia (OFF)", "ChevronHeightOn", "Altezza freccia (ON)",
        "ChevronThicknessOff", "Spessore linee (OFF)", "ChevronThicknessOn", "Spessore linee (ON)",
        "ChevronSpacingOff", "Distanza tra frecce (OFF)", "ChevronSpacingOn", "Distanza tra frecce (ON)",
        "ChevronShapeOff", "Forma (OFF)", "ChevronShapeOn", "Forma (ON)",
        "ChevronAnimMode", "Animazione", "ChevronAnimCycle", "Durata ciclo animazione (ms)",
        "ChevronPulseMin", "Pulse: grandezza minima", "ChevronPulseMax", "Pulse: grandezza massima",
        "ChevronMorphInTime", "Passaggio OFF > ON (s)", "ChevronMorphOutTime", "Passaggio ON > OFF (s)",
        "Bar1Enabled", "Barra 1 visibile", "Bar2Enabled", "Barra 2 visibile",
        "Bar1MaxWidth", "Barra 1: larghezza", "Bar2MaxWidth", "Barra 2: larghezza",
        "Bar1MaxHeight", "Barra 1: altezza", "Bar2MaxHeight", "Barra 2: altezza",
        "Bar1BorderSize", "Barra 1: cornice", "Bar2BorderSize", "Barra 2: cornice",
        "Bar1OffsetX", "Barra 1: posizione orizzontale", "Bar2OffsetX", "Barra 2: posizione orizzontale",
        "Bar1OffsetY", "Barra 1: posizione verticale", "Bar2OffsetY", "Barra 2: posizione verticale",
        "Bar1CenterGap", "Barra 1: spazio centrale", "Bar2CenterGap", "Barra 2: spazio centrale",
        "Bar1Skew", "Barra 1: inclinazione", "Bar2Skew", "Barra 2: inclinazione",
        "LootSize", "Grandezza icona (altezza)", "LootBorderSize", "Bordino nero", "LootBaseFontSize", "Dimensione testo",
        "LootEmojiSize", "Dimensione emoji", "LootEmojiOffsetY", "Emoji: spostamento verticale",
        "LootEmojiOffsetX", "Emoji: spostamento orizzontale",
        "LootLine1OffsetX", "Testo in alto: spost. orizzontale", "LootLine1OffsetY", "Testo in alto: spost. verticale",
        "LootLine3OffsetX", "Testo in basso: spost. orizzontale", "LootLine3OffsetY", "Testo in basso: spost. verticale",
        "LootTextColor", "Colore testo", "LootOutlineColor", "Colore contorno testo",
        "CombatFontSize", "Dimensione testo", "CombatEmojiSize", "Dimensione emoji",
        "CombatEmojiOffsetX", "Emoji: spostamento orizzontale", "CombatEmojiOffsetY", "Emoji: spostamento verticale",
        "CombatLine1OffsetX", "Testo in alto: spost. orizzontale", "CombatLine1OffsetY", "Testo in alto: spost. verticale",
        "CombatLine3OffsetX", "Testo in basso: spost. orizzontale", "CombatLine3OffsetY", "Testo in basso: spost. verticale",
        "CombatTextColor", "Colore testo", "CombatOutlineColor", "Colore contorno testo",
        "LootOffsetX", "Posizione orizzontale", "LootOffsetY", "Posizione verticale",
        "LootShape", "Forma dell'icona", "CombatShape", "Forma dell'icona",
        "LootTextLine1", "Testo in alto", "LootEmoji", "Emoji", "LootTextLine3", "Testo in basso",
        "CombatIconEnabled", "Icona visibile", "CombatOffsetX", "Posizione orizzontale", "CombatOffsetY", "Posizione verticale",
        "CombatTextLine1", "Testo in alto", "CombatEmoji", "Emoji", "CombatTextLine3", "Testo in basso",
        "LootAnim", "Effetti attivi", "LootFxPadding", "Spazio per gli effetti",
        "LootPulseCycle", "Pulse: durata respiro (ms)", "LootPulseSize", "Pulse: estensione alone",
        "LootPulseOpacity", "Pulse: intensità", "LootPulseColor", "Pulse: colore",
        "LootRingCycle", "Ring: durata onda (ms)", "LootRingCount", "Ring: onde insieme", "LootRingDistance", "Ring: distanza percorsa",
        "LootRingThickness", "Ring: spessore", "LootRingOpacity", "Ring: intensità", "LootRingColor", "Ring: colore",
        "LootSpinCycle", "Spin: durata giro (ms)", "LootSpinArc", "Spin: lunghezza arco (gradi)",
        "LootSpinThickness", "Spin: spessore", "LootSpinColor", "Spin: colore",
        "LootGlowCycle", "Glow: durata pulsazione (ms)", "LootGlowColor", "Glow: colore", "LootGlowAmount", "Glow: intensità",
        "CombatAnim", "Effetti attivi", "CombatFxPadding", "Spazio per gli effetti",
        "CombatPulseCycle", "Pulse: durata respiro (ms)", "CombatPulseSize", "Pulse: estensione alone",
        "CombatPulseOpacity", "Pulse: intensità", "CombatPulseColor", "Pulse: colore",
        "CombatRingCycle", "Ring: durata onda (ms)", "CombatRingCount", "Ring: onde insieme", "CombatRingDistance", "Ring: distanza percorsa",
        "CombatRingThickness", "Ring: spessore", "CombatRingOpacity", "Ring: intensità", "CombatRingColor", "Ring: colore",
        "CombatSpinCycle", "Spin: durata giro (ms)", "CombatSpinArc", "Spin: lunghezza arco (gradi)",
        "CombatSpinThickness", "Spin: spessore", "CombatSpinColor", "Spin: colore",
        "CombatGlowCycle", "Glow: durata pulsazione (ms)", "CombatGlowColor", "Glow: colore", "CombatGlowAmount", "Glow: intensità",
        "AnimInterval", "Intervallo fotogrammi (ms)", "FadeInTime", "Dissolvenza in entrata (s)", "FadeOutTime", "Dissolvenza in uscita (s)",
        "FadeEasing", "Dissolvenze morbide", "ColorFadeInTime", "Sfumatura al colore attivo (s)", "ColorFadeOutTime", "Sfumatura al colore inattivo (s)",
        "LootMorphInTime", "Loot: accensione effetti (s)", "LootMorphOutTime", "Loot: spegnimento effetti (s)",
        "LootFadeOutTime", "Loot: dissolvenza in uscita (s)", "LootColorFadeOutTime", "Loot: sfumatura colore (s)",
        "CombatMorphInTime", "Combat: accensione effetti (s)", "CombatMorphOutTime", "Combat: spegnimento effetti (s)",
        "CombatFadeOutTime", "Combat: dissolvenza in uscita (s)", "CombatColorFadeOutTime", "Combat: sfumatura colore (s)",
        "EnableCrosshairFadeIn", "Mirino: dissolvenza in entrata", "EnableCrosshairFadeOut", "Mirino: dissolvenza in uscita",
        "EnableBar1FadeIn", "Barra 1: dissolvenza in entrata", "EnableBar1FadeOut", "Barra 1: dissolvenza in uscita",
        "EnableBar2FadeIn", "Barra 2: dissolvenza in entrata", "EnableBar2FadeOut", "Barra 2: dissolvenza in uscita",
        "EnableLootFadeIn", "Loot: dissolvenza in entrata", "EnableLootFadeOut", "Loot: dissolvenza in uscita",
        "EnableCombatFadeIn", "Combat: dissolvenza in entrata", "EnableCombatFadeOut", "Combat: dissolvenza in uscita",
        "HiddenCubeEnabled", "Attivo all'avvio", "HiddenCubeInterval", "Controllo ogni (ms)", "HiddenCubeCheckSlot", "Richiedi slot della chiave",
        "HiddenCubeOffsetX", "Correzione punto X", "HiddenCubeOffsetY", "Correzione punto Y",
        "HiddenCubeLockMouse", "Blocca il mouse sul pulsante", "HiddenCubeLockInterval", "Rigidità del blocco (ms)",
        "HiddenCubeRearmTime", "Riattivazione dopo (ms)", "HiddenCubeAutoClick", "Click automatico",
        "HiddenCubeClickDelay", "Ritardo click automatico (ms)", "HiddenCubeDebug", "Avviso di riconoscimento",
        "FieldBossEnabled", "Attivo all'avvio", "FieldBossGuideOnOpen", "Guida all'apertura della mappa", "FieldBossCheckEvery", "Controllo mappa ogni (ms)",
        "FieldBossLockMouse", "Blocca il mouse", "FieldBossBlockClicks", "Blocca i click tra le fasi",
        "FieldBossHints", "Istruzioni grandi a schermo", "FieldBossHintScale", "Dimensione istruzioni", "FieldBossHintBottom", "Distanza dal basso",
        "FieldBossPanelScale", "Dimensione pannello", "FieldBossPanelMarginR", "Distanza dal bordo destro", "FieldBossPanelOffsetY", "Spostamento verticale",
        "FieldBossStartCollapsed", "Parte ridotto", "FieldBossPickAction", "Dopo la scelta di un boss", "FieldBossFadeAlpha", "Opacità in modalità fade",
        "FieldBossShowLegend", "Leggenda visibile", "FieldBossLegendScale", "Dimensione leggenda", "FieldBossLegendY", "Distanza dall'alto",
        "FieldBossLegendAlpha", "Opacità leggenda",
        "FieldBossListScroll", "Scrollate lista boss", "FieldBossFindTeleport", "Cerca il Teleport più vicino",
        "FieldBossAutoZoomOut", "Zoom indietro automatico", "FieldBossZoomOut", "Scrollate di zoom indietro", "FieldBossZoomBack", "Scrollate di ritorno",
        "FieldBossZoomOutWheel", "Rotellina per lo zoom indietro", "FieldBossCloseLoot", "Chiudi il riquadro dei loot",
        "FieldBossLootClickDist", "Distanza del punto vuoto",
        "FieldBossTravelPresses", "Pressioni di F per partire", "FieldBossTravelWait", "Attesa del Travel (s)",
        "FieldBossDirHint", "Mostra la direzione del boss", "FieldBossDirSeconds", "Durata indicazione (s)",
        "FieldBossDirDelay", "Ritardo indicazione (ms)", "FieldBossDirTop", "Distanza dall'alto", "FieldBossDirScale", "Dimensione indicazione"
    )

    ; ---- Scelte fisse ----
    static Enums := Map(
        "Language", ["english", "italiano", "spanish", "french", "german", "portuguese", "russian", "korean", "chinese", "japanese", "napoletano", "bro"],
        "Theme", ["principale", "custom"],          ; riempito da RefreshThemes: temi pronti, temi salvati, "custom"
        "UpdateMode", ["chiedi", "automatico", "spento"],
        "PerfProfile", ["potato", "base", "bilanciato", "performante", "gigachad", "manuale"],
        "ChevronAnimMode", ["pulse", "march", "sequence", "none"],
        "ChevronShapeOff", ["freccia", "triangolo", "barra", "rombo", "cerchio", "blocco"],
        "ChevronShapeOn", ["freccia", "triangolo", "barra", "rombo", "cerchio", "blocco"],
        "LootShape", ["cerchio", "quadrato", "rettangolo", "triangolo", "trapezio"],
        "CombatShape", ["cerchio", "quadrato", "rettangolo", "triangolo", "trapezio"],
        "FieldBossPickAction", ["fade", "collapse", "none"],
        "FieldBossCloseLoot", ["zoom", "always", "never"],
        "FieldBossZoomOutWheel", ["WheelDown", "WheelUp"])
    static Multi := Map("LootAnim", ["ring", "pulse", "spin", "glow"], "CombatAnim", ["ring", "pulse", "spin", "glow"])

    ; Nomi mostrati nei menu a tendina (stesso ordine di Enums): emoji + valore
    static ThemeIcons := Map("principale", "⚜️", "dark", "🌑", "bright", "☀️", "cuddle", "🧸", "pinkhaze", "🌸", "egirl", "🎀", "vi", "🌴"
        , "gladiator", "🪓", "templar", "🛡️", "assassin", "🗡️", "ranger", "🏹", "sorcerer", "🔮", "spiritmaster", "🌀"
        , "cleric", "💖", "chanter", "🎶", "halloween", "🎃", "natale", "🎄", "capodanno", "🎆", "sanvalentino", "💘"
        , "carnevale", "🎭", "pasqua", "🐣", "sanpatrizio", "☘️", "custom", "🎨")
    ; emoji dei valori degli altri elenchi (solo grafica: nella CONFIG resta il valore)
    static ValueIcons := Map(
        "UpdateMode",      Map("chiedi", "🙋", "automatico", "⚡", "spento", "⏸️"),
        "PerfProfile",     Map("potato", "🥔", "base", "🐢", "bilanciato", "⚖️", "performante", "🚀", "gigachad", "💪", "manuale", "🛠️"),
        "ChevronAnimMode", Map("pulse", "💓", "march", "🥁", "sequence", "🔢", "none", "⏸️"),
        "ChevronShape",    Map("freccia", "➡️", "triangolo", "🔺", "barra", "📏", "rombo", "🔷", "cerchio", "⚪", "blocco", "🟥"),
        "IconShape",       Map("cerchio", "⚪", "quadrato", "🟦", "rettangolo", "🎫", "triangolo", "🔺", "trapezio", "⛰️"),
        "FieldBossPickAction", Map("fade", "🌫️", "collapse", "🔽", "none", "⏹️"),
        "FieldBossCloseLoot",  Map("zoom", "🔍", "always", "✅", "never", "🚫"),
        "FieldBossZoomOutWheel", Map("WheelDown", "🔽", "WheelUp", "🔼"),
        "LootAnim",    Map("ring", "💫", "pulse", "💓", "spin", "🌀", "glow", "✨"),
        "Grade",           Map("verde", "🟢", "blu", "🔵", "oro", "🟡"))

    static IconOf(name, value) {
        grp := (name = "ChevronShapeOff" || name = "ChevronShapeOn") ? "ChevronShape"
             : (name = "LootShape" || name = "CombatShape") ? "IconShape" : name = "CombatAnim" ? "LootAnim" : name
        return this.ValueIcons.Has(grp) && this.ValueIcons[grp].Has(value) ? this.ValueIcons[grp][value] : ""
    }

    static EnumText(name, value) {
        if (name = "Language")
            for i, c in this.Enums["Language"]
                if (c = value)
                    return this.LangNames[i]
        if (name = "Theme" && SubStr(value, 1, 5) = "user:")
            return "⭐  " SubStr(value, 6)
        if (name = "Theme" && this.ThemeIcons.Has(value))
            return this.ThemeIcons[value] "  " value
        ico := this.IconOf(name, value)
        return ico != "" ? ico "  " value : value
    }

    ; ---- Valori ammessi per i numeri: [minimo, massimo, solo interi] ----
    static Limits := Map(
        "SplashHold", [0, 10, 0], "SplashScale", [0.3, 3, 0],
        "HudBaseHeight", [480, 4320, 1], "UpdateCheckHours", [1, 168, 1],
        "PerfWorkerTick", [10, 500, 1], "PerfLockTick", [5, 200, 1], "PerfPollMs", [5, 100, 1],
        "PerfRingTick", [10, 200, 1], "PerfOcrQuality", [1, 3, 0],
        "CombatTimeout", [0, 60000, 1], "LootTimeout", [0, 60000, 1], "CombatGrace", [0, 60000, 1], "LootGrace", [0, 60000, 1],
        "OffsetX", [-4000, 4000, 1], "OffsetY", [-4000, 4000, 1], "ChevronGap", [0, 500, 1], "ChevronCount", [1, 10, 1],
        "ChevronWidthOff", [1, 300, 1], "ChevronWidthOn", [1, 300, 1], "ChevronHeightOff", [2, 300, 1], "ChevronHeightOn", [2, 300, 1],
        "ChevronThicknessOff", [1, 100, 1], "ChevronThicknessOn", [1, 100, 1], "ChevronSpacingOff", [0, 300, 1], "ChevronSpacingOn", [0, 300, 1],
        "ChevronAnimCycle", [50, 10000, 1], "ChevronPulseMin", [0.1, 5, 0], "ChevronPulseMax", [0.1, 5, 0],
        "ChevronMorphInTime", [0, 10, 0], "ChevronMorphOutTime", [0, 10, 0],
        "Bar1MaxWidth", [10, 4000, 1], "Bar2MaxWidth", [10, 4000, 1], "Bar1MaxHeight", [1, 200, 1], "Bar2MaxHeight", [1, 200, 1],
        "Bar1BorderSize", [0, 50, 1], "Bar2BorderSize", [0, 50, 1], "Bar1OffsetX", [-4000, 4000, 1], "Bar2OffsetX", [-4000, 4000, 1],
        "Bar1OffsetY", [-4000, 4000, 1], "Bar2OffsetY", [-4000, 4000, 1], "Bar1CenterGap", [0, 2000, 1], "Bar2CenterGap", [0, 2000, 1],
        "Bar1Skew", [0, 200, 1], "Bar2Skew", [0, 200, 1],
        "LootSize", [20, 400, 1], "LootBorderSize", [0, 30, 1], "CombatSize", [20, 400, 1], "CombatBorderSize", [0, 30, 1],
        "CombatOffsetX", [-4000, 4000, 1], "CombatOffsetY", [-4000, 4000, 1], "LootBaseFontSize", [4, 60, 1], "LootEmojiSize", [6, 200, 1],
        "LootEmojiOffsetY", [-200, 200, 1], "LootEmojiOffsetX", [-200, 200, 1],
        "LootLine1OffsetX", [-200, 200, 1], "LootLine1OffsetY", [-200, 200, 1],
        "LootLine3OffsetX", [-200, 200, 1], "LootLine3OffsetY", [-200, 200, 1],
        "CombatFontSize", [4, 60, 1], "CombatEmojiSize", [6, 200, 1],
        "CombatEmojiOffsetX", [-200, 200, 1], "CombatEmojiOffsetY", [-200, 200, 1],
        "CombatLine1OffsetX", [-200, 200, 1], "CombatLine1OffsetY", [-200, 200, 1],
        "CombatLine3OffsetX", [-200, 200, 1], "CombatLine3OffsetY", [-200, 200, 1], "LootOffsetX", [-4000, 4000, 1], "LootOffsetY", [-4000, 4000, 1],
        "LootFxPadding", [0, 200, 1],
        "LootPulseCycle", [100, 10000, 1], "LootPulseSize", [0, 200, 1], "LootPulseOpacity", [0, 1, 0],
        "LootRingCycle", [100, 10000, 1], "LootRingCount", [1, 10, 1], "LootRingDistance", [0, 300, 1],
        "LootRingThickness", [1, 50, 1], "LootRingOpacity", [0, 1, 0],
        "LootSpinCycle", [100, 10000, 1], "LootSpinArc", [1, 360, 1], "LootSpinThickness", [1, 50, 1],
        "LootGlowCycle", [100, 10000, 1], "LootGlowAmount", [0, 1, 0],
        "LootMorphInTime", [0, 30, 0], "LootMorphOutTime", [0, 30, 0], "LootFadeOutTime", [0, 30, 0], "LootColorFadeOutTime", [0, 30, 0],
        "CombatFxPadding", [0, 200, 1],
        "CombatPulseCycle", [100, 10000, 1], "CombatPulseSize", [0, 200, 1], "CombatPulseOpacity", [0, 1, 0],
        "CombatRingCycle", [100, 10000, 1], "CombatRingCount", [1, 10, 1], "CombatRingDistance", [0, 300, 1],
        "CombatRingThickness", [1, 50, 1], "CombatRingOpacity", [0, 1, 0],
        "CombatSpinCycle", [100, 10000, 1], "CombatSpinArc", [1, 360, 1], "CombatSpinThickness", [1, 50, 1],
        "CombatGlowCycle", [100, 10000, 1], "CombatGlowAmount", [0, 1, 0],
        "CombatMorphInTime", [0, 30, 0], "CombatMorphOutTime", [0, 30, 0], "CombatFadeOutTime", [0, 30, 0], "CombatColorFadeOutTime", [0, 30, 0],
        "AnimInterval", [5, 100, 1], "FadeInTime", [0, 30, 0], "FadeOutTime", [0, 30, 0], "ColorFadeInTime", [0, 30, 0], "ColorFadeOutTime", [0, 30, 0],
        "HiddenCubeInterval", [20, 5000, 1], "HiddenCubeOffsetX", [-500, 500, 1], "HiddenCubeOffsetY", [-500, 500, 1],
        "HiddenCubeLockInterval", [5, 500, 1], "HiddenCubeRearmTime", [0, 10000, 1], "HiddenCubeClickDelay", [0, 5000, 1],
        "FieldBossCheckEvery", [100, 5000, 1], "FieldBossHintScale", [0.3, 4, 0], "FieldBossHintBottom", [0, 2000, 1],
        "FieldBossPanelScale", [0.5, 4, 0], "FieldBossPanelMarginR", [0, 3000, 1], "FieldBossPanelOffsetY", [-1500, 1500, 1],
        "FieldBossFadeAlpha", [0, 255, 1], "FieldBossLegendScale", [0.3, 4, 0], "FieldBossLegendY", [0, 100, 1], "FieldBossLegendAlpha", [0, 255, 1],
        "FieldBossListScroll", [1, 200, 1], "FieldBossZoomOut", [0, 50, 1], "FieldBossZoomBack", [0, 50, 1], "FieldBossLootClickDist", [20, 500, 1],
        "FieldBossTravelPresses", [1, 5, 1], "FieldBossTravelWait", [1, 600, 1], "FieldBossDirSeconds", [1, 300, 1],
        "FieldBossDirDelay", [0, 60000, 1], "FieldBossDirTop", [0, 2000, 1], "FieldBossDirScale", [0.3, 4, 0])

    ; "" = valido, altrimenti il motivo (es. "ammessi da 50 a 10000")
    static Invalid(name, v := unset) {
        v := IsSet(v) ? v : this.Val(name)
        t := this.Cfg[name].type
        if (t = "expr") {                                       ; numero oppure nome di un'altra impostazione
            if !RegExMatch(v, "^-?\s*([A-Za-z_]\w*|\d+(\.\d+)?)$", &m)
                return Tr("serve un numero oppure il nome di un'impostazione (es. LootEmojiSize)")
            id := RegExReplace(m[1], "^\d.*")                  ; "" se è un numero
            if (id != "" && !(this.Cfg.Has(id) && this.Cfg[id].line < this.Cfg[name].line
                              && (this.Cfg[id].type = "num" || this.Cfg[id].type = "expr")))
                return Tr("il nome deve essere un'impostazione numerica scritta prima di questa nella CONFIG")
            return ""
        }
        if (name = "ViCountdownDate") {                         ; data AAAAMMGGhhmmss
            u := this.Unq(v)
            if !RegExMatch(u, "^\d{8}(\d{6})?$")
                return Tr("data non valida: scrivila come AAAAMMGGhhmmss (es. 20261119000000)")
            try DateDiff(u, A_Now, "Seconds")
            catch
                return Tr("data non valida: scrivila come AAAAMMGGhhmmss (es. 20261119000000)")
            return ""
        }
        if (t = "color") {                                      ; RRGGBB oppure nome inglese
            try ColorToRGB(this.Unq(v))
            catch
                return Tr("Colore non valido")
            return ""
        }
        if (t = "key") {
            k := this.Unq(v)
            if (k = "")
                return (name = "SettingsKey" || name = "FieldBossMapKey" || name = "FieldBossTravelKey"
                        || name = "CombatKey" || name = "LootKey") ? Tr("serve un tasto") : ""
            base := RegExReplace(k, "^[\^+!#~*$<>]+")
            if (base = "" || GetKeyName(base) = "")
                return Tr("tasto non valido")
            if ((name = "CombatKey" || name = "LootKey" || name = "FieldBossTravelKey" || name = "FieldBossMapKey") && base != k)
                return Tr("serve un solo tasto, senza Ctrl/Shift/Alt/Win")
            return ""
        }
        if (t != "num")
            return ""
        lim := this.Limits.Has(name) ? this.Limits[name] : ""
        if !RegExMatch(v, "^-?\d+(\.\d+)?$")
            return !lim ? Tr("serve un numero") : Tr(lim[3] ? "serve un numero intero, da {1} a {2}" : "serve un numero, da {1} a {2}", lim[1], lim[2])
        if !lim
            return ""
        if (lim[3] && InStr(v, "."))
            return Tr("serve un numero intero, da {1} a {2}", lim[1], lim[2])
        if (v + 0 < lim[1] || v + 0 > lim[2])
            return Tr("ammessi solo valori da {1} a {2}", lim[1], lim[2])
        return ""
    }

    static RangeText(name) {
        if !this.Limits.Has(name)
            return ""
        lim := this.Limits[name]
        return Tr("Valori ammessi: da {1} a {2}", lim[1], lim[2]) (lim[3] ? " " Tr("(solo numeri interi)") : "")
    }

    static LastNode := 0, Win := "", Cfg := Map(), Pending := Map(), Nodes := Map(), Cur := "", Loading := false
    static Search := "", SearchFn := "", MaintCtrls := [], MaintInfo := ""
    static ThemeCtrls := [], ThemeRows := [], OvCache := Map(), ThemeKeyMap := ""
    static Bosses := [], BossDirty := false, BossFrom := 0, BossTo := 0, Lines := [], EOL := "`n"
    static Orig := Map(), RebuildFn := "", PulseFn := ""
    static NumMode := false, NumScale := 1, NumCtrls := [], LastProfile := ""

    ; ======================================================================
    static Open(*) {
        if IsObject(this.Win) {
            this.Win.Show()
            return
        }
        try this.Load()
        catch as e {
            MsgBox(Tr("Impossibile leggere la CONFIG:") "`n" e.Message, "AION 2 Wingman", "Icon!")
            return
        }
        this.Build()
    }

    ; ---------------- Lettura della CONFIG dal file dello script ----------------
    static Load() {
        this.RefreshThemes()
        text := FileRead(A_ScriptFullPath, "UTF-8")
        this.EOL := InStr(text, "`r`n") ? "`r`n" : "`n"
        this.Lines := StrSplit(StrReplace(text, "`r`n", "`n"), "`n")
        this.Cfg := Map(), this.Pending := Map(), this.Bosses := [], this.BossDirty := false
        first := 0, last := 0
        for i, l in this.Lines {
            if (!first && InStr(l, "===                              CONFIG"))
                first := i
            if (first && InStr(l, "FINE CONFIG")) {
                last := i
                break
            }
        }
        if !(first && last)
            throw Error("blocco CONFIG non trovato")
        i := first
        while (i < last) {
            l := this.Lines[i]
            if RegExMatch(l, "^global\s+FieldBossList\s*:=\s*\[") {       ; elenco boss (più righe)
                this.BossFrom := i
                while (++i < last && !RegExMatch(this.Lines[i], "^\]"))
                    if RegExMatch(this.Lines[i], '^\s*\["(.*?)",\s*"(\w+)"(?:,\s*(\d+))?\s*\]', &m)
                        this.Bosses.Push({name: m[1], grade: StrLower(m[2]), tier: m[3] = "" ? 0 : Integer(m[3])})
                this.BossTo := i
            } else if (SubStr(l, 1, 7) = "global ") {
                desc := this.Describe(i)
                for v in this.ParseLine(l)
                    this.Cfg[v.name] := {value: v.value, line: i, start: v.start, len: v.len, desc: desc
                                       , type: this.TypeOf(v.name, v.value)}
            }
            i++
        }
    }

    ; Trova le assegnazioni "Nome := valore" di una riga "global ..." (anche più di una per riga)
    static ParseLine(l) {
        out := [], pos := 8
        loop {
            if !RegExMatch(l, "\G\s*([A-Za-z_]\w*)\s*:=\s*", &m, pos)
                break
            vs := pos + m.Len, i := vs, ch := SubStr(l, i, 1), n := StrLen(l)
            if (ch = '"') {
                ve := i                                 ; fine della stringa: prima " non preceduta da `
                loop {
                    ve := InStr(l, '"', , ve + 1)
                    if (!ve || SubStr(l, ve - 1, 1) != "``")
                        break
                }
                ve := ve ? ve : n
            } else if (ch = "[") {
                depth := 0, q := false
                loop {
                    c := SubStr(l, i, 1)
                    if (c = '"')
                        q := !q
                    else if (!q && c = "[")
                        depth++
                    else if (!q && c = "]" && --depth = 0)
                        break
                    if (++i > n)
                        break
                }
                ve := Min(i, n)
            } else {
                ve := i
                while (ve <= n) {
                    c := SubStr(l, ve, 1)
                    if (c = "," || (c = ";" && ve > 1 && InStr(" `t", SubStr(l, ve - 1, 1))))
                        break
                    ve++
                }
                ve--
                while (ve > vs && InStr(" `t", SubStr(l, ve, 1)))
                    ve--
            }
            out.Push({name: m[1], start: vs, len: ve - vs + 1, value: SubStr(l, vs, ve - vs + 1)})
            if !RegExMatch(l, "\G\s*,", &m2, ve + 1)
                break
            pos := ve + 1 + m2.Len
        }
        return out
    }

    ; Descrizione: commenti sopra la riga + commento sulla riga + righe di commento che la continuano
    static Describe(i) {
        above := []
        j := i - 1
        while (j > 0 && RegExMatch(this.Lines[j], "^;(?!\s*(-{4}|={4}|\[))\s?(.*)$", &m)) {
            above.InsertAt(1, RTrim(m[2]))
            j--
        }
        txt := ""
        for a in above
            txt .= Trim(a) "`n"
        if RegExMatch(this.Lines[i], "\s;\s?(.*)$", &m)
            txt .= Trim(m[1]) "`n"
        k := i + 1
        while (k <= this.Lines.Length && RegExMatch(this.Lines[k], "^\s{8,};\s?(.*)$", &m)) {
            txt .= Trim(m[1]) "`n"
            k++
        }
        return Trim(txt, "`n")
    }

    static TypeOf(name, v) {
        if this.Enums.Has(name)
            return "enum"
        if this.Multi.Has(name)
            return "multi"
        if (v = "true" || v = "false")
            return "bool"
        if (SubStr(name, -3) = "Key")
            return "key"
        if (InStr(name, "Color") && SubStr(v, 1, 1) = '"')
            return "color"
        if RegExMatch(v, "^-?\d+(\.\d+)?$")
            return "num"
        if (SubStr(v, 1, 1) = '"')
            return "text"
        return "expr"
    }

    static Unq(v) => (SubStr(v, 1, 1) = '"' && SubStr(v, -1) = '"') ? StrReplace(SubStr(v, 2, -1), '``"', '"') : v
    static Val(name) => this.Pending.Has(name) ? this.Pending[name] : this.Cfg[name].value
    static Label(name) => this.Labels.Has(name) ? Tr(this.Labels[name]) : name
    static Desc(name) => TrDesc(name, this.Cfg[name].desc)        ; descrizione nella lingua scelta

    ; valore imposto dal profilo prestazioni scelto (unset = nessuno, cioè profilo "manuale")
    static ProfileValue(name, &out) {
        idx := 0
        for i, n in PerfVars
            if (n = name)
                idx := i
        if !idx || !this.Cfg.Has("PerfProfile")
            return false
        vals := PerfProfileValues(this.Unq(this.Val("PerfProfile")))
        if !IsObject(vals)
            return false
        out := vals[idx]
        return true
    }

    ; Posizione dell'icona Combat con "Icona Combat speculare al Loot" attiva: segue il Loot
    static MirrorValue(name, &out) {
        if !((name = "CombatOffsetX" || name = "CombatOffsetY") && this.Cfg.Has("IconMirror") && this.Val("IconMirror") = "true")
            return false
        v := this.Val(name = "CombatOffsetX" ? "LootOffsetX" : "LootOffsetY")
        out := (name = "CombatOffsetX" && RegExMatch(v, "^-?\d+(\.\d+)?$")) ? -v : v
        return true
    }

    static Shown(name) {
        if this.ProfileValue(name, &pv)
            return Tr("{1}   (profilo {2})", pv, this.Unq(this.Val("PerfProfile")))
        if this.MirrorValue(name, &mv)
            return Tr("{1}   (speculare al Loot)", mv)
        if this.ThemeLocked(name, &tv)
            return Tr("{1}   (tema)", this.ThemeShow(tv))
        v := this.Val(name), t := this.Cfg[name].type
        switch t {
            case "bool":  return v = "true" ? Tr("Sì") : Tr("No")
            case "key":   return (k := this.Unq(v)) = "" ? Tr("(nessuno)") : FieldBossTool.KeyLabel(k)
            case "multi":
                out := ""
                for o in this.Multi[name]
                    if InStr(v, '"' o '"')
                        out .= (out = "" ? "" : ", ") this.EnumText(name, o)
                return out
            case "enum":  return this.EnumText(name, this.Unq(v))
            default:      return this.Unq(v)
        }
    }

    ; ---------------- Finestra ----------------
    ; Finestra 1180 x 746: intestazione (64) | ricerca + menu a sinistra (280) | contenuto (862) | barra in basso
    static W := 1180, H := 746
    static Build(px := "", py := "") {
        W := this.W, H := this.H, X := 306, CW := 862        ; colonna del contenuto
        g := Gui("-MaximizeBox", "AION 2 Wingman " AppVersion " - " Tr("Impostazioni"))
        g.BackColor := UiC("WinBg"), g.MarginX := 12, g.MarginY := 10
        g.OnEvent("Close", (*) => this.Close())
        g.OnEvent("Escape", (*) => this.Close())

        ; ---- intestazione ----
        g.AddText("x0 y0 w" W " h64 Background" UiC("Bg"))
        g.SetFont("s16 bold c" UiC("Accent"), "Segoe UI")
        g.AddText("x20 y8 h30 Background" UiC("Bg"), "AION 2 Wingman " AppVersion)
        g.SetFont("s9 norm c" UiC("Muted"), "Segoe UI")
        g.AddText("x22 y40 Background" UiC("Bg"), Tr("Impostazioni") "   ·   by VaLeTecK")
        ; lingua (si applica subito a questa finestra; al gioco dopo "Salva e riavvia")
        g.SetFont("s8 norm c" UiC("Muted"), "Segoe UI")
        g.AddText("x400 y8 w230 h16 Background" UiC("Bg"), Tr("Lingua") "  ·  Language")
        g.SetFont("s10 norm c" UiC("WinText"), "Segoe UI")
        this.LangDdl := g.AddDropDownList("x400 y26 w230", this.LangNames)
        cur := this.Cfg.Has("Language") ? this.Unq(this.Val("Language")) : Language
        for i, code in this.Enums["Language"]
            if (code = cur)
                this.LangDdl.Choose(i)
        this.LangDdl.OnEvent("Change", (*) => this.LangPicked())
        ; anteprima: levetta + menu degli elementi + stato HUD (testi a sfondo pieno: niente "doppio testo")
        this.PrevTrack := g.AddText("x652 y10 w40 h20 Background" UiC("Row"))
        this.PrevKnob  := g.AddText("x654 y12 w16 h16 BackgroundFFFFFF")
        for c in [this.PrevTrack, this.PrevKnob]
            c.OnEvent("Click", (*) => this.PreviewSet(!PreviewMode))
        RoundCtl(this.PrevTrack, 20), RoundCtl(this.PrevKnob, 16)
        g.SetFont("s10 bold", "Segoe UI")
        this.PrevChk := g.AddText("x700 y9 w176 h22 0x200 Background" UiC("Bg"), Tr("ANTEPRIMA DAL VIVO"))
        this.PrevChk.OnEvent("Click", (*) => this.PreviewSet(!PreviewMode))
        g.SetFont("s9 bold", "Segoe UI")
        this.PrevElemBtn := g.AddText("x880 y10 w84 h20 Center 0x200", Tr("Elementi") " ▾")
        this.PrevElemBtn.OnEvent("Click", (*) => PreviewMode ? this.ElemToggle() : 0)
        g.SetFont("s9 norm c" UiC("SubText"), "Segoe UI")
        g.AddText("x652 y38 w82 h18 0x200 Background" UiC("Bg"), Tr("Stato HUD:"))
        g.SetFont("s9 bold", "Segoe UI")
        this.PrevOn  := g.AddText("x738 y36 w110 h20 Center 0x200", Tr("ON (attivo)"))
        this.PrevOff := g.AddText("x854 y36 w110 h20 Center 0x200", Tr("OFF (inattivo)"))
        this.PrevOn.OnEvent("Click", (*) => PreviewMode ? this.PreviewState(true) : 0)
        this.PrevOff.OnEvent("Click", (*) => PreviewMode ? this.PreviewState(false) : 0)
        this.PreviewPaint()
        ; termina il programma (non solo la finestra): pulsante rosso ben distinto
        g.SetFont("s10 bold cFFFFFF", "Segoe UI")
        q := g.AddText("x984 y8 w184 h28 Center 0x200 Background" UiC("Err"), "⏻  " Tr("Termina Wingman"))
        q.OnEvent("Click", (*) => this.QuitApp())
        RoundCtl(q, 10)
        g.SetFont("s7 norm c" UiC("Muted"), "Segoe UI")
        g.AddText("x984 y38 w184 h20 Center Background" UiC("Bg"), Tr("chiude il programma, non solo questa finestra"))

        ; ---- ricerca + menu a sinistra ----
        g.SetFont("s10 norm c" UiC("WinText"), "Segoe UI")
        this.Search := g.AddEdit("x12 y76 w280 h26 Background" UiC("WinField"))
        DllCall("SendMessage", "Ptr", this.Search.Hwnd, "UInt", 0x1501, "Ptr", 1, "WStr", "🔍  " Tr("Cerca un'impostazione..."))   ; EM_SETCUEBANNER
        this.Search.OnEvent("Change", (*) => this.Loading ? 0 : SetTimer(this.SearchFn := ObjBindMethod(this, "RunSearch"), -250))
        this.TV := g.AddTreeView("x12 y110 w280 h570 -Lines Background" UiC("WinField"))
        this.TV.OnEvent("ItemSelect", (c, item) => this.SelectNode(item))
        this.LastNode := 0
        this.Nodes := Map()
        this.AddNodes(this.Tree, 0)
        listed := Map()                                   ; impostazioni non presenti nel menu -> "Altro"
        for id, n in this.Nodes
            for v in this.NodeVars(n)
                listed[v] := true
        extra := []
        for name in this.Cfg
            if !listed.Has(name)
                extra.Push(name)
        if extra.Length {
            id := this.TV.Add(this.Icon("Altro") Tr("Altro"), 0)
            this.Nodes[id] := {title: this.Icon("Altro") Tr("Altro"), intro: Tr("Impostazioni della CONFIG non ancora catalogate nei menu."), content: extra}
        }

        ; ---- titolo e introduzione della categoria ----
        g.SetFont("s14 bold c" UiC("WinText"), "Segoe UI")
        this.Title := g.AddText("x" X " y72 w" CW " h30", "")
        g.SetFont("s9 norm c" UiC("WinSub"), "Segoe UI")
        this.Intro := g.AddText("x" X " y104 w" CW " h44", "")

        ; ---- elenco impostazioni ----
        g.SetFont("s10 norm c" UiC("WinText"), "Segoe UI")
        this.LV := g.AddListView("x" X " y152 w" CW " h252 -Multi Grid NoSortHdr Background" UiC("WinField"), [Tr("Impostazione"), Tr("Valore"), Tr("Variabile"), ""])
        this.LV.ModifyCol(1, 330), this.LV.ModifyCol(2, 260), this.LV.ModifyCol(3, 240), this.LV.ModifyCol(4, 26)
        this.LV.OnEvent("ItemSelect", (c, row, sel) => sel ? this.SelectRow(row) : 0)

        ; ---- dettaglio: nome, descrizione ----
        g.SetFont("s11 bold c" UiC("WinText"), "Segoe UI")
        this.DName := g.AddText("x" X " y414 w" CW " h24", "")
        g.SetFont("s9 norm c" UiC("WinText"), "Segoe UI")
        this.DDesc := g.AddEdit("x" X " y442 w500 h236 ReadOnly -WantReturn +VScroll Background" UiC("WinField"), "")

        ; ---- editor (a destra della descrizione): si mostrano solo i controlli del tipo giusto ----
        EX := 822, EW := 346
        g.SetFont("s9 bold c" UiC("WinSub"), "Segoe UI")
        this.HdrVal := g.AddText("x" EX " y442 w" EW, Tr("VALORE"))
        g.SetFont("s10 norm c" UiC("WinText"), "Segoe UI")
        this.EChk := g.AddCheckbox("x" EX " y462 w" EW " h24", Tr("Attivo"))
        this.EChk.OnEvent("Click", (*) => this.Changed())
        this.EEdit := g.AddEdit("x" EX " y462 w" EW " h26 Background" UiC("WinField"))
        ; numeri: cursore + valore + pulsanti, così il campo non può mai restare vuoto
        this.ESlider := g.AddSlider("x" (EX - 4) " y460 w270 h30 NoTicks")
        this.ESlider.OnEvent("Change", (*) => this.NumChanged())
        g.SetFont("s11 bold c" UiC("WinText"), "Segoe UI")
        this.ENumVal := g.AddText("x" (EX + 270) " y462 w76 h26 Center 0x200 Border Background" UiC("WinField"), "")
        this.EMinus := g.AddButton("x" EX " y494 w44 h28", "−")
        this.EMinus.OnEvent("Click", (*) => this.NumStep(-1))
        this.EPlus := g.AddButton("x" (EX + 48) " y494 w44 h28", "+")
        this.EPlus.OnEvent("Click", (*) => this.NumStep(1))
        g.SetFont("s10 norm c" UiC("WinText"), "Segoe UI")
        this.ETypeNum := g.AddButton("x" (EX + 98) " y494 w248 h28", Tr("Scrivi un valore preciso..."))
        this.ETypeNum.OnEvent("Click", (*) => this.NumWrite())
        this.NumCtrls := [this.ESlider, this.ENumVal, this.EMinus, this.EPlus, this.ETypeNum]
        this.EEdit.OnEvent("Change", (*) => this.Changed())
        this.EDdl := g.AddDropDownList("x" EX " y462 w" EW)
        this.EDdl.OnEvent("Change", (*) => this.Changed())
        this.EMulti := []
        loop 4 {
            c := g.AddCheckbox(Format("x{} y{} w168 h24", EX + Mod(A_Index - 1, 2) * 176, 462 + (A_Index - 1) // 2 * 26), "")
            c.OnEvent("Click", (*) => this.Changed())
            this.EMulti.Push(c)
        }
        this.EPick := g.AddButton("x" EX " y528 w168 h28", Tr("Scegli colore..."))
        this.EPick.OnEvent("Click", (*) => this.PickColor())
        this.EReset := g.AddButton("x" (EX + 178) " y528 w168 h28", Tr("Valore originale"))
        this.EReset.OnEvent("Click", (*) => this.ResetCur())

        ; esempio visivo
        g.SetFont("s9 bold c" UiC("WinSub"), "Segoe UI")
        this.HdrEx := g.AddText("x" EX " y566 w" EW, Tr("ESEMPIO"))
        this.ExSw := g.AddText("x" EX " y588 w56 h56 +Border", "")
        g.SetFont("s12 bold c" UiC("WinText"), "Segoe UI")
        this.ExTxt := g.AddText("x" EX " y588 w" EW " h90", "")

        ; ---- editor dell'elenco boss (nascosto finché non si sceglie "Elenco boss") ----
        g.SetFont("s10 norm c" UiC("WinText"), "Segoe UI")
        this.BLV := g.AddListView("x" X " y152 w" CW " h330 -Multi Grid Background" UiC("WinField"), [Tr("Nome boss"), Tr("Grado"), Tr("Importanza")])
        this.BLV.ModifyCol(1, 440), this.BLV.ModifyCol(2, 160), this.BLV.ModifyCol(3, 236)
        this.BLV.OnEvent("ItemSelect", (c, row, sel) => sel ? this.SelectBoss(row) : 0)
        bl1 := g.AddText("x" X " y498 w60 h26 0x200", Tr("Nome"))
        this.BName := g.AddEdit("x" (X + 64) " y496 w380")
        this.BName.OnEvent("Change", (*) => this.BossChanged())
        bl2 := g.AddText("x" (X + 456) " y498 w62 h26 0x200", Tr("Grado"))
        this.BGrade := g.AddDropDownList("x" (X + 520) " y496 w130", [this.EnumText("Grade", "verde"), this.EnumText("Grade", "blu"), this.EnumText("Grade", "oro")])
        this.BGrade.OnEvent("Change", (*) => this.BossChanged())
        bl3 := g.AddText("x" (X + 660) " y498 w44 h26 0x200", Tr("Imp."))
        g.SetFont("s10 norm", "Segoe UI Emoji")
        this.BTier := g.AddDropDownList("x" (X + 706) " y496 w156", this.TierNames())
        this.BTier.OnEvent("Change", (*) => this.BossChanged())
        g.SetFont("s10 norm c" UiC("WinText"), "Segoe UI")
        this.BAdd := g.AddButton("x" X " y538 w170 h30", Tr("+ Aggiungi boss"))
        this.BAdd.OnEvent("Click", (*) => this.BossAdd())
        this.BDel := g.AddButton("x" (X + 178) " y538 w170 h30", Tr("- Rimuovi boss"))
        this.BDel.OnEvent("Click", (*) => this.BossDel())
        g.SetFont("s9 norm c" UiC("WinSub"), "Segoe UI")
        this.BHelp := g.AddText("x" X " y580 w" CW " h60", Tr("Grado = colore della prima icona dei drop.  Importanza = simbolo nel pannello.`n"
            . "Scrivi il nome intero come in gioco (anche se il gioco lo tronca con `"...`"). Il pannello li ordina dalla A alla Z."))
        this.BossCtrls := [this.BLV, this.BName, this.BGrade, this.BTier, this.BAdd, this.BDel, this.BHelp, bl1, bl2, bl3]

        ; ---- pannello Preset ----
        g.SetFont("s10 norm c" UiC("WinText"), "Segoe UI")
        this.PLV := g.AddListView("x" X " y152 w" CW " h330 -Multi Grid NoSortHdr Background" UiC("WinField"), ["Preset", Tr("Tipo"), Tr("Dettagli")])
        this.PLV.ModifyCol(1, 300), this.PLV.ModifyCol(2, 170), this.PLV.ModifyCol(3, 366)
        this.PLV.OnEvent("DoubleClick", (c, row) => row ? this.PresetApply() : 0)
        this.PApply := g.AddButton("x" X " y494 w190 h32 Default", Tr("Applica preset"))
        this.PApply.OnEvent("Click", (*) => this.PresetApply())
        this.PSave := g.AddButton("x" (X + 198) " y494 w340 h32", Tr("Salva le impostazioni attuali come preset..."))
        this.PSave.OnEvent("Click", (*) => this.PresetSave())
        this.PDel := g.AddButton("x" (X + 546) " y494 w190 h32", Tr("Elimina preset"))
        this.PDel.OnEvent("Click", (*) => this.PresetDelete())
        this.PImport := g.AddButton("x" X " y534 w340 h30", Tr("Importa da un vecchio script..."))
        this.PImport.OnEvent("Click", (*) => this.ImportOld())
        g.SetFont("s9 norm c" UiC("WinSub"), "Segoe UI")
        this.PHelp := g.AddText("x" X " y574 w" CW " h90", "")
        this.PresetCtrls := [this.PLV, this.PApply, this.PSave, this.PDel, this.PImport, this.PHelp]

        ; ---- pannello Editor temi ----
        g.SetFont("s10 norm c" UiC("WinText"), "Segoe UI Emoji")
        this.TLV := g.AddListView("x" X " y152 w" CW " h330 -Multi Grid NoSortHdr Background" UiC("WinField"), [Tr("Tema"), Tr("Tipo"), Tr("Dettagli")])
        this.TLV.ModifyCol(1, 300), this.TLV.ModifyCol(2, 200), this.TLV.ModifyCol(3, 336)
        this.TLV.OnEvent("DoubleClick", (c, row) => row ? this.ThemeUse() : 0)
        g.SetFont("s10 norm c" UiC("WinText"), "Segoe UI")
        this.TUse := g.AddButton("x" X " y494 w220 h32", "✅  " Tr("Usa questo tema"))
        this.TUse.OnEvent("Click", (*) => this.ThemeUse())
        this.TEdit := g.AddButton("x" (X + 228) " y494 w300 h32", "✏️  " Tr("Personalizza questo tema"))
        this.TEdit.OnEvent("Click", (*) => this.ThemeCustomize())
        this.TSave := g.AddButton("x" (X + 536) " y494 w326 h32", "💾  " Tr("Salva il tema attuale con nome..."))
        this.TSave.OnEvent("Click", (*) => this.ThemeSaveAs())
        this.TDel := g.AddButton("x" X " y534 w220 h30", "🗑️  " Tr("Elimina tema"))
        this.TDel.OnEvent("Click", (*) => this.ThemeDelete())
        g.SetFont("s9 norm c" UiC("WinSub"), "Segoe UI")
        this.THelp := g.AddText("x" X " y574 w" CW " h100", "")
        this.ThemeCtrls := [this.TLV, this.TUse, this.TEdit, this.TSave, this.TDel, this.THelp]

        ; ---- pannello Manutenzione ----
        g.SetFont("s10 norm c" UiC("WinText"), "Segoe UI")
        this.MaintCtrls := []
        for it in [["🧙  " Tr("Riesegui l'installazione guidata"), (*) => this.RunSetup()]
                 , ["🔄  " Tr("Controlla aggiornamenti"), (*) => Updater.CheckNow()]
                 , ["🌐  " Tr("Pagina del progetto su GitHub"), (*) => Updater.OpenPage()]
                 , ["📂  " Tr("Apri la cartella delle impostazioni personali"), (*) => Run('explorer.exe "' UserData.Dir '"')]
                 , ["🗂️  " Tr("Apri la cartella di Wingman"), (*) => Run('explorer.exe "' A_ScriptDir '"')]
                 , ["📝  " Tr("Apri il file"), (*) => Run('notepad.exe "' A_ScriptFullPath '"')]] {
            bt := g.AddButton("x" X " y" (160 + (A_Index - 1) * 46) " w420 h36 Left", "   " it[1])
            if IsObject(it[2])
                bt.OnEvent("Click", it[2])
            else
                bt.Enabled := false
            this.MaintCtrls.Push(bt)
        }
        g.SetFont("s9 norm c" UiC("WinSub"), "Segoe UI")
        this.MaintInfo := g.AddEdit("x" (X + 440) " y160 w422 h220 ReadOnly -WantReturn Background" UiC("WinField"), "")
        this.MaintCtrls.Push(this.MaintInfo)

        ; ---- barra in basso ----
        g.SetFont("s10 norm c" UiC("WinText"), "Segoe UI")
        g.AddText("x0 y" (H - 56) " w" W " h1 Background" UiC("Line"))
        this.ChgBtn := g.AddButton("x12 y" (H - 46) " w150 h34", Tr("Vedi modifiche"))
        this.ChgBtn.OnEvent("Click", (*) => this.ShowChanges())
        this.Status := g.AddText("x172 y" (H - 42) " w420 h26 0x200", "")
        b := g.AddButton("x" (W - 482) " y" (H - 46) " w170 h34 Default", Tr("Salva e riavvia"))
        b.OnEvent("Click", (*) => this.Save())
        b := g.AddButton("x" (W - 304) " y" (H - 46) " w160 h34", Tr("Annulla modifiche"))
        b.OnEvent("Click", (*) => this.Discard())
        b := g.AddButton("x" (W - 136) " y" (H - 46) " w124 h34", Tr("Chiudi"))
        b.OnEvent("Click", (*) => this.Close())

        this.Win := g
        this.EditorShow("")
        this.ShowBossEditor(false)
        this.ShowPresetEditor(false)
        this.ShowMaintenance(false)
        this.ShowThemeEditor(false)
        g.Show((px != "" ? "x" px " y" py " " : "") "w" W " h" H)
        this.TV.Modify(this.TV.GetChild(0), "Select")
        this.SelectNode(this.TV.GetChild(0), true)
        this.UpdateStatus()
    }

    ; ---------------- Manutenzione ----------------
    static ShowMaintenance(on) {
        for c in this.MaintCtrls
            c.Visible := on
        if on {
            for c in [this.LV, this.DName, this.DDesc, this.HdrVal, this.HdrEx, this.ExTxt]
                c.Visible := false
            this.EditorShow("")
            this.MaintInfo.Value := StrReplace(Tr("Versione") ":  AION 2 Wingman " AppVersion "`n"
                . "AutoHotkey:  " A_AhkVersion "`n`n"
                . Tr("Script") ":`n" A_ScriptFullPath "`n`n"
                . Tr("Impostazioni personali") ":`n" UserData.Dir "`n`n"
                . Tr("Repository GitHub") ":`n" (Trim(UpdateRepo) != "" ? "github.com/" Trim(UpdateRepo) : "-"), "`n", "`r`n")
        }
    }

    static RunSetup() {
        bat := A_ScriptDir "\Setup AION 2 Wingman.bat"
        if !FileExist(bat)
            return MsgBox(Tr("Installazione guidata non trovata: manca `"{1}`" nella cartella di Wingman.", "Setup AION 2 Wingman.bat"), "AION 2 Wingman", "Icon!")
        Run('"' bat '"', A_ScriptDir)
    }

    ; ---------------- Termina il programma ----------------
    static QuitApp() {
        msg := Tr("Terminare AION 2 Wingman?") "`n" Tr("HUD, Hidden Cube e Field Boss smettono di funzionare finché non lo riavvii.")
        if (this.Pending.Count || this.BossDirty)
            msg .= "`n`n" Tr("Ci sono modifiche non salvate: andranno perse.")
        if (MsgBox(msg, "AION 2 Wingman", "YesNo Icon! Default2") != "Yes")
            return
        ExitApp()
    }

    ; ---------------- Ricerca ----------------
    static RunSearch() {
        if !IsObject(this.Win)
            return
        q := Trim(this.Search.Value)
        if (q = "")                                         ; ricerca vuota: torna alla voce del menu
            return this.SelectNode(this.TV.GetSelection(), true)
        found := []
        for name, it in this.Cfg
            if (InStr(this.Label(name), q) || InStr(name, q) || InStr(this.Desc(name), q) || InStr(this.Shown(name), q))
                found.Push(name)
        this.LastNode := 0
        this.ShowPresetEditor(false), this.ShowMaintenance(false), this.ShowThemeEditor(false), this.ShowBossEditor(false)
        this.Title.Text := "🔍  " Tr("Risultati della ricerca")
        this.Intro.Text := found.Length ? Tr("{1} risultati per `"{2}`"", found.Length, q) : Tr("Nessun risultato per `"{1}`"", q)
        this.LV.Opt("-Redraw")
        this.LV.Delete()
        for v in found
            this.LV.Add(, this.Label(v), this.Shown(v), v, this.Pending.Has(v) ? "●" : "")
        this.LV.Opt("+Redraw")
        this.EditorShow("")
        if this.LV.GetCount()
            this.LV.Modify(1, "Select Focus"), this.SelectRow(1)
    }

    ; emoji davanti a ogni voce del menu (solo grafica: le traduzioni usano il titolo senza emoji)
    static Icons := Map("Preset", "📦", "Generale", "⚙️", "Prestazioni", "🚀", "Tasti", "⌨️",
        "HUD overlay", "🖥️", "Tema", "🌈", "Generale e macro", "🎮", "Colori", "🎨", "Mirino", "🎯", "Barre", "📊",
        "Icone - generale", "🔲", "Icona Loot", "💰", "Icona Combat", "⚔️", "Effetti Loot", "✨", "Effetti Combat", "💥",
        "Transizioni", "🌗", "Hidden Cube", "🧊", "Field Boss", "🐉", "Fasi di click", "🖱️", "Pannello", "📋",
        "Leggenda", "🏷️", "Ricerca e Teleport", "🔍", "Travel e direzione", "🧭", "Elenco boss", "👑", "Aggiornamenti", "🔄", "Manutenzione", "🛠️", "Editor temi", "🖌️", "Altro", "📁")
    static Icon(title) => this.Icons.Has(title) ? this.Icons[title] "  " : ""

    static AddNodes(list, parent) {
        for n in list {
            t := this.Icon(n[1]) Tr(n[1])
            id := this.TV.Add(t, parent, "Expand")
            this.Nodes[id] := {title: t, intro: Tr(n[2]), content: n[3]}
            if (IsObject(n[3]) && n[3].Length && IsObject(n[3][1]))      ; ha dei sottomenu
                this.AddNodes(n[3], id)
        }
    }

    ; tutte le variabili di un nodo (anche dei suoi sottomenu), solo quelle presenti nella CONFIG
    static NodeVars(node) {
        out := []
        if !IsObject(node.content)
            return out
        for x in node.content {
            if IsObject(x) {
                for v in this.NodeVars({content: x[3]})
                    out.Push(v)
            } else if this.Cfg.Has(x)
                out.Push(x)
        }
        return out
    }

    ; Windows a volte non manda l'evento di selezione per le selezioni fatte dallo script
    ; (appena dopo un click): per questo le selezioni via codice chiamano anche direttamente
    ; SelectNode / SelectRow, e SelectNode ignora un secondo evento per la stessa voce.
    static SelectNode(item, force := false) {
        if (!this.Nodes.Has(item) || (!force && item = this.LastNode))
            return
        this.LastNode := item
        node := this.Nodes[item]
        if (this.Search.Value != "") {                     ; scelta dal menu: la ricerca si svuota
            this.Loading := true, this.Search.Value := "", this.Loading := false
        }
        this.Title.Text := node.title
        this.ShowPresetEditor(false)
        this.ShowMaintenance(false)
        this.ShowThemeEditor(false)
        if (node.content = "THEMES") {
            this.Intro.Text := Tr("I temi pronti restano sempre uguali. Scegli un tema e premi `"Personalizza questo tema`": "
                . "viene creato un tuo tema con lo stesso nome più `"Custom`", modificabile in ogni dettaglio.")
            this.ShowBossEditor(false)
            this.ShowThemeEditor(true)
            this.FillThemes()
            return
        }
        if (node.content = "MAINT") {
            this.Intro.Text := Tr("Strumenti per installazione, aggiornamenti e file di Wingman.")
            this.ShowBossEditor(false)
            this.ShowMaintenance(true)
            return
        }
        if (node.content = "PRESET") {
            this.Intro.Text := Tr("Configurazioni pronte da applicare. I preset di risoluzione riscalano tutte le misure in px dell'HUD "
                . "(mirino, barre, icone, effetti); Field Boss e Hidden Cube si adattano già da soli.")
            this.ShowBossEditor(false)
            this.ShowPresetEditor(true)
            this.FillPresets()
            return
        }
        if (node.content = "BOSS") {
            this.Intro.Text := Tr("Boss di Altgard mostrati nel pannello Field Boss. Seleziona una riga per modificarla.")
            this.ShowBossEditor(true)
            this.FillBosses()
            return
        }
        this.ShowBossEditor(false)
        this.Intro.Text := node.intro
        this.LV.Opt("-Redraw")
        this.LV.Delete()
        for v in this.NodeVars(node)
            this.LV.Add(, this.Label(v), this.Shown(v), v, this.Pending.Has(v) ? "●" : "")
        this.LV.Opt("+Redraw")
        this.EditorShow("")
        if this.LV.GetCount()
            this.LV.Modify(1, "Select Focus"), this.SelectRow(1)
    }

    static SelectRow(row) {
        this.Cur := this.LV.GetText(row, 3)
        this.EditorShow(this.Cur)
    }

    ; ---------------- Editor del valore ----------------
    static EditorShow(name) {
        this.Loading := true
        for c in [this.EChk, this.EEdit, this.EDdl, this.EPick, this.EReset, this.ExSw]
            c.Visible := false
        for c in this.EMulti
            c.Visible := false
        for c in this.NumCtrls
            c.Visible := false
        this.NumMode := false
        if (name = "") {
            this.DName.Text := "", this.DDesc.Value := "", this.ExTxt.Text := ""
            this.Loading := false
            return
        }
        it := this.Cfg[name], v := this.Val(name)
        this.DName.Text := this.Label(name) "     (" name ")"
        rng := this.RangeText(name)
        this.DDesc.Value := StrReplace(this.Desc(name), "`n", "`r`n") (rng != "" ? "`r`n`r`n" rng : "")
        if (name = "PerfProfile")
            this.LastProfile := this.Unq(v)
        if this.ProfileValue(name, &pv) {                 ; gestito dal profilo: solo lettura
            prof := this.Unq(this.Val("PerfProfile"))
            this.ExSw.Visible := false
            this.ExTxt.SetFont("s10 bold c" UiC("WinText"))
            this.ExTxt.Text := Tr("Valore {1} impostato dal profilo `"{2}`".`nPer cambiarlo a mano scegli il profilo `"manuale`".", pv, prof)
            this.Loading := false
            return
        }
        if this.MirrorValue(name, &mv) {                  ; icona Combat speculare: la posizione la decide il Loot
            this.ExSw.Visible := false
            this.ExTxt.Move(822)
            this.ExTxt.SetFont("s10 bold c" UiC("WinText"))
            this.ExTxt.Text := Tr("Valore {1} preso dal Loot: è attiva `"Icona Combat speculare al Loot`".`nPer spostare il Combat a mano disattivala in Icone - generale.", mv)
            this.Loading := false
            return
        }
        if this.ThemeLocked(name, &tv) {                  ; lo decide il tema in uso (i temi pronti non si modificano)
            this.ExSw.Visible := false
            this.ExTxt.Move(822)
            this.ExTxt.SetFont("s10 bold c" UiC("WinText"))
            this.ExTxt.Text := Tr("Valore {1} deciso dal tema `"{2}`".`nPer cambiarlo: Editor temi > `"Personalizza questo tema`".", this.ThemeShow(tv), this.EnumText("Theme", this.Unq(this.Val("Theme"))))
            this.Loading := false
            return
        }
        switch it.type {
            case "bool":
                this.EChk.Value := v = "true", this.EChk.Visible := true
            case "enum":
                shown := []
                for o in this.Enums[name]
                    shown.Push(this.EnumText(name, o))
                this.EDdl.Delete(), this.EDdl.Add(shown)
                for i, o in this.Enums[name]
                    if (o = this.Unq(v))
                        this.EDdl.Choose(i)
                this.EDdl.Visible := true
            case "multi":
                for i, o in this.Multi[name] {
                    c := this.EMulti[i]
                    c.Text := this.EnumText(name, o), c.Value := InStr(v, '"' o '"') ? 1 : 0, c.Visible := true
                }
            case "num":
                if this.Limits.Has(name) {
                    lim := this.Limits[name]
                    this.NumScale := lim[3] ? 1 : (lim[2] - lim[1] <= 10 ? 100 : 10)
                    this.NumMode := true
                    this.ESlider.Opt(Format("Range{}-{} Line1 Page{}", Round(lim[1] * this.NumScale), Round(lim[2] * this.NumScale)
                                          , Max(1, Round((lim[2] - lim[1]) * this.NumScale / 20))))
                    n := RegExMatch(v, "^-?\d+(\.\d+)?$") ? v + 0 : lim[1]
                    this.ESlider.Value := Round(Min(Max(n, lim[1]), lim[2]) * this.NumScale)
                    this.ENumVal.Text := v
                    for c in this.NumCtrls
                        c.Visible := true
                } else
                    this.EEdit.Value := this.Unq(v), this.EEdit.Visible := true
            default:
                this.EEdit.Value := this.Unq(v), this.EEdit.Visible := true
                if (it.type = "color")
                    this.EPick.Visible := true
        }
        this.EReset.Visible := true
        this.Loading := false
        this.UpdateExample()
    }

    ; valore dal controllo, nel formato della CONFIG
    static EditorValue() {
        name := this.Cur, t := this.Cfg[name].type
        switch t {
            case "bool":  return this.EChk.Value ? "true" : "false"
            case "enum":  return '"' this.Enums[name][this.EDdl.Value] '"'
            case "multi":
                s := ""
                for i, o in this.Multi[name]                       ; valori dall'elenco, non dal testo (che ha l'emoji)
                    if (this.EMulti[i].Visible && this.EMulti[i].Value)
                        s .= (s = "" ? "" : ", ") '"' o '"'
                return "[" s "]"
            case "num":
                if this.NumMode
                    return this.FmtNum(this.ESlider.Value / this.NumScale)
                return Trim(this.EEdit.Value)
            case "expr": return Trim(this.EEdit.Value)
            default:      return '"' StrReplace(this.EEdit.Value, '"', '``"') '"'
        }
    }

    static Changed() {
        static busy := false
        if (this.Loading || this.Cur = "" || busy)
            return
        busy := true
        try this.ApplyChange()
        catch as e
            MsgBox(Tr("Errore nella modifica:") " " e.Message, "AION 2 Wingman", "Icon!")
        busy := false
    }

    static ApplyChange() {
        name := this.Cur, v := this.EditorValue(), orig := this.Cfg[name].value
        same := v == orig
        if (!same && this.Cfg[name].type = "num" && IsNumber(v) && IsNumber(orig))
            same := (v + 0 = orig + 0)                  ; es. "1" e "1.0" sono lo stesso valore
        if same {
            if this.Pending.Has(name)
                this.Pending.Delete(name)
        }
        else
            this.Pending[name] := v
        row := this.FindRow(name)
        if row
            this.LV.Modify(row, , this.Label(name), this.Shown(name), name, this.Pending.Has(name) ? "●" : "")
        if this.IsLook(name)                              ; lingua o tema: ridisegna la finestra
            this.LookApply()
        if (name = "PerfProfile") {
            if (this.Unq(v) = "manuale" && IsObject(prev := PerfProfileValues(this.LastProfile))) {
                vals := Map()                             ; "manuale" parte dai valori del profilo di prima
                for i, n in PerfVars
                    vals[n] := String(prev[i])
                this.SetValues(vals)
            }
            this.LastProfile := this.Unq(v)
            loop this.LV.GetCount() {                     ; i valori dell'elenco cambiano con il profilo
                n := this.LV.GetText(A_Index, 3)
                this.LV.Modify(A_Index, , this.Label(n), this.Shown(n), n, this.Pending.Has(n) ? "●" : "")
            }
        }
        this.UpdateExample()
        this.UpdateStatus()
        this.Live(name)
    }

    ; ---- numeri ----
    static FmtNum(n) {
        if (this.NumScale = 1)
            return String(Round(n))
        s := RTrim(RTrim(Format("{:.2f}", n), "0"), ".")
        return s = "-0" ? "0" : s
    }

    static NumChanged() {
        if this.Loading
            return
        this.ENumVal.Text := this.FmtNum(this.ESlider.Value / this.NumScale)
        this.Changed()
    }

    static NumStep(dir) {
        this.ESlider.Value := this.ESlider.Value + dir            ; il cursore resta nei limiti da solo
        this.NumChanged()
    }

    static NumWrite() {
        lim := this.Limits[this.Cur]
        r := InputBox(Tr("Nuovo valore per `"{1}`"", this.Label(this.Cur)) "`n" this.RangeText(this.Cur)
                    , "AION 2 Wingman", "w360 h150", this.ENumVal.Text)
        if (r.Result != "OK")
            return
        v := Trim(StrReplace(r.Value, ",", "."))
        if ((why := this.Invalid(this.Cur, v)) != "")
            return MsgBox(Tr("Valore non accettato: {1}.", why), "AION 2 Wingman", "Icon!")
        this.ESlider.Value := Round((v + 0) * this.NumScale)
        this.ENumVal.Text := this.FmtNum(v + 0)
        this.Changed()
    }

    static FindRow(name) {
        loop this.LV.GetCount()
            if (this.LV.GetText(A_Index, 3) = name)
                return A_Index
        return 0
    }

    static ResetCur() {
        if (this.Cur = "")
            return
        if this.Pending.Has(this.Cur)
            this.Pending.Delete(this.Cur)
        row := this.FindRow(this.Cur)
        if row
            this.LV.Modify(row, , this.Label(this.Cur), this.Shown(this.Cur), this.Cur, "")
        this.EditorShow(this.Cur)
        this.UpdateStatus()
        this.Live(this.Cur)
    }

    ; ---------------- Esempio visivo ----------------
    static UpdateExample() {
        name := this.Cur
        if (name = "" || !this.Cfg.Has(name))
            return
        t := this.Cfg[name].type, v := this.Val(name), u := this.Unq(v), desc := this.Desc(name)
        this.ExSw.Visible := false
        this.ExTxt.Move(822)
        this.ExTxt.SetFont("c" UiC("WinText"))
        txt := ""
        if ((why := this.Invalid(name)) != "") {
            this.ExTxt.SetFont("s10 bold c" UiC("Err"))
            this.ExTxt.Text := Tr("Valore non valido:") "`n" why
            return
        }
        switch t {
            case "bool":
                txt := v = "true" ? "●  " Tr("ATTIVO") : "○  " Tr("DISATTIVATO")
                this.ExTxt.SetFont(v = "true" ? "c" UiC("Ok") : "c" UiC("Muted"))
            case "key":
                txt := u = "" ? Tr("(nessun tasto)") : "[ " StrReplace(FieldBossTool.KeyLabel(u), "+", " ] + [ ") " ]"
            case "color":
                try {
                    rgb := ColorToRGB(u)
                    this.ExSw.Opt("+Background" Format("{:06X}", rgb)), this.ExSw.Redraw(), this.ExSw.Visible := true
                    this.ExTxt.Move(886)
                    txt := Format("#{:06X}", rgb)
                } catch
                    txt := Tr("Colore non valido")
            case "enum":
                txt := this.OptionLine(desc, u)
                if (name = "PerfProfile" && IsObject(pv := PerfProfileValues(u)))
                    txt := u "`n" Tr("HUD {1} fps · Cubo {2} ms · Mappa {3} ms`nClick {4} ms · Blocco {5} ms · OCR {6}"
                         , Round(1000 / pv[1]), pv[2], pv[4], pv[7], pv[6], pv[9])
            case "multi":
                for o in this.Multi[name]
                    if InStr(v, '"' o '"')
                        txt .= "✔ " this.OptionLine(desc, o) "`n"
                txt := txt = "" ? Tr("Nessun effetto") : RTrim(txt, "`n")
            case "num":
                txt := this.NumExample(name, u, desc)
            default:
                txt := u
        }
        this.ExTxt.SetFont((t = "enum" || t = "multi") ? "s9 norm" : "s12 bold")
        this.ExTxt.Text := txt
    }

    ; riga della descrizione che spiega un'opzione ("pulse" = ...)
    static OptionLine(desc, opt) {
        for l in StrSplit(desc, "`n")
            if RegExMatch(l, 'i)"' opt '"\s*=\s*(.*)', &m)
                return opt "  =  " m[1]
        return opt
    }

    static NumExample(name, u, desc) {
        n := u + 0
        if RegExMatch(name, "i)Alpha$")
            return u " / 255  =  " Tr("{1}% opaco", Round(n / 2.55))
        if RegExMatch(name, "i)Opacity|Amount$")
            return Tr("{1}% di intensità", Round(n * 100))
        if RegExMatch(name, "i)Scale$")
            return "× " u "   (" Tr("{1}% della grandezza normale", Round(n * 100)) ")"
        if RegExMatch(name, "i)(Time|Seconds|Wait)$")
            return u " s  =  " Round(n * 1000) " ms"
        if RegExMatch(name, "i)(Timeout|Grace|Interval|Cycle|Delay|Every|RearmTime)$")
            return u " ms  =  " Format("{:.2f}", n / 1000) " s"
        if RegExMatch(name, "i)(Offset|Margin|Gap|Width|Height|Size|Dist|Top|Bottom|Thickness|Padding|Skew|Distance|Spacing)")
            return u " px" (InStr(desc, "1440p") ? "  " Tr("(misurati a 1440p)") : InStr(desc, "4K") ? "  " Tr("(misurati in 4K)") : "")
        return u
    }

    static PickColor() {
        static cust := Buffer(64, 0)
        try rgb := ColorToRGB(this.Unq(this.Val(this.Cur)))
        catch
            rgb := 0xFFFFFF
        size := A_PtrSize = 8 ? 72 : 36
        cc := Buffer(size, 0)
        NumPut("UInt", size, cc, 0)
        NumPut("Ptr", this.Win.Hwnd, cc, A_PtrSize)
        NumPut("UInt", RgbToColorRef(rgb), cc, A_PtrSize * 3)
        NumPut("Ptr", cust.Ptr, cc, A_PtrSize * 4)
        NumPut("UInt", 0x3, cc, A_PtrSize * 5)                       ; CC_RGBINIT | CC_FULLOPEN
        if !DllCall("comdlg32\ChooseColorW", "Ptr", cc)
            return
        ref := NumGet(cc, A_PtrSize * 3, "UInt")
        this.EEdit.Value := Format("{:06X}", RgbToColorRef(ref))       ; COLORREF -> RGB (stessa inversione)
        this.Changed()
    }

    ; ---------------- Elenco boss ----------------
    ; ---------------- Preset ----------------
    ; Predefiniti: FullHD / 2K / 4K riscalano le misure in px dell'HUD dalla risoluzione attuale
    ; (HudBaseHeight) a quella scelta. Personalizzati: tutte le impostazioni salvate in un file .ini
    ; accanto allo script. Applicare un preset crea delle modifiche: diventano definitive con "Salva e riavvia".
    static PresetFile := UserData.Presets          ; %AppData%\AION 2 Wingman\presets.ini
    static Builtin := [["FullHD (1080p)", 1080], ["2K (1440p)", 1440], ["4K (2160p)", 2160]]
    static ScaleVars := ["OffsetX", "OffsetY", "ChevronGap", "ChevronWidthOff", "ChevronWidthOn", "ChevronHeightOff", "ChevronHeightOn",
        "ChevronThicknessOff", "ChevronThicknessOn", "ChevronSpacingOff", "ChevronSpacingOn",
        "Bar1MaxWidth", "Bar2MaxWidth", "Bar1MaxHeight", "Bar2MaxHeight", "Bar1BorderSize", "Bar2BorderSize",
        "Bar1OffsetX", "Bar2OffsetX", "Bar1OffsetY", "Bar2OffsetY", "Bar1CenterGap", "Bar2CenterGap", "Bar1Skew", "Bar2Skew",
        "LootSize", "LootBorderSize", "LootEmojiSize", "LootOffsetX", "LootOffsetY",
        "LootLine1OffsetX", "LootLine1OffsetY", "LootEmojiOffsetX", "LootEmojiOffsetY",
        "LootLine3OffsetX", "LootLine3OffsetY",
        "CombatOffsetX", "CombatOffsetY", "CombatEmojiSize",
        "CombatLine1OffsetX", "CombatLine1OffsetY", "CombatEmojiOffsetX", "CombatEmojiOffsetY",
        "CombatLine3OffsetX", "CombatLine3OffsetY",
        "LootFxPadding", "LootPulseSize", "LootRingDistance", "LootRingThickness", "LootSpinThickness",
        "CombatSize", "CombatBorderSize",
        "CombatFxPadding", "CombatPulseSize", "CombatRingDistance", "CombatRingThickness", "CombatSpinThickness"]

    ; Importa i valori della CONFIG da un vecchio script (o dal suo .bak): diventano modifiche da salvare
    static ImportOld() {
        f := FileSelect(1, A_ScriptDir, Tr("Scegli il vecchio script (.ahk o .bak)"), "AutoHotkey (*.ahk; *.bak)")
        if (f = "")
            return
        try text := FileRead(f, "UTF-8")
        catch
            return
        vals := Map()
        for l in StrSplit(StrReplace(text, "`r`n", "`n"), "`n") {
            if InStr(l, "FINE CONFIG")
                break
            if (SubStr(l, 1, 7) != "global " || RegExMatch(l, "^global\s+FieldBossList\b"))
                continue
            for v in this.ParseLine(l) {
                name := UserData.Compat(v.name), val := UserData.Compat(v.value)
                if (this.Cfg.Has(name) && this.Invalid(name, val) = "")
                    vals[name] := val
            }
        }
        n := this.SetValues(vals)
        this.SelectNode(this.TV.GetSelection(), true)
        MsgBox(Tr("Impostazioni importate: {1} valori cambiati.", n) "`n" Tr("Premi `"Salva e riavvia`" per renderlo definitivo."), "AION 2 Wingman", "Iconi")
    }

    ; ---------------- Editor temi ----------------
    ; I temi pronti non cambiano mai. "Personalizza" copia i valori di un tema nel tema "custom"
    ; (le normali impostazioni), che si modifica in ogni dettaglio e si salva con un nome:
    ; i temi salvati stanno in %AppData%\AION 2 Wingman\themes.ini e restano dopo gli aggiornamenti.
    static RefreshThemes() {
        lst := []
        for t in ThemeBuiltin()
            lst.Push(t)
        for n in UserThemes()
            lst.Push("user:" n)
        lst.Push("custom")
        this.Enums["Theme"] := lst
        this.OvCache := Map()
    }

    static ThemeOv(t) {
        if !this.OvCache.Has(t)
            this.OvCache[t] := ThemeOverrides(t)
        return this.OvCache[t]
    }

    ; vero se il valore di "name" lo decide il tema in uso (out = valore del tema, come nella CONFIG)
    static ThemeLocked(name, &out) {
        if !IsObject(this.ThemeKeyMap) {
            this.ThemeKeyMap := Map()
            for v in ThemeKeys()
                this.ThemeKeyMap[v] := true
        }
        if (!this.ThemeKeyMap.Has(name) || !this.Cfg.Has("Theme"))
            return false
        t := this.Unq(this.Val("Theme"))
        if (StrLower(t) = "custom" || SubStr(t, 1, 5) = "user:")   ; i tuoi temi si modificano liberamente
            return false
        ov := this.ThemeOv(t)
        if !ov.Has(name)
            return false
        out := ov[name]
        return true
    }

    static ThemeShow(x) {
        if (x = "true" || x = "false")
            return x = "true" ? Tr("Sì") : Tr("No")
        v := CfgLiteral(x)
        if IsObject(v) {
            out := ""
            for a in v
                out .= (out = "" ? "" : ", ") a
            return out
        }
        return v
    }

    ; tutti i valori del tema t (quelli che non decide restano quelli attuali delle impostazioni)
    static ThemeEffective(t) {
        out := Map()
        for v in ThemeKeys()
            if this.Cfg.Has(v)
                out[v] := this.Val(v)
        for v, x in this.ThemeOv(t)
            if this.Cfg.Has(v)
                out[v] := x
        return out
    }

    static ShowThemeEditor(on) {
        for c in this.ThemeCtrls
            c.Visible := on
        if on {
            for c in [this.LV, this.DName, this.DDesc, this.HdrVal, this.HdrEx, this.ExTxt]
                c.Visible := false
            this.EditorShow("")
        }
    }

    static FillThemes() {
        cur := this.Unq(this.Val("Theme"))
        this.TLV.Opt("-Redraw")
        this.TLV.Delete()
        this.ThemeRows := []
        sel := 1
        for t in this.Enums["Theme"] {
            user := SubStr(t, 1, 5) = "user:"
            kind := user ? "⭐  " Tr("Personalizzato")
                  : t = "custom" ? "✏️  " Tr("In modifica")
                  : ThemeEvents.Has(t) ? "🎉  " Tr("Evento")
                  : (ThemeDefs().K.Has(t) && t != "principale") ? "⚔️  " Tr("Classe") : "🏭  " Tr("Predefinito")
            det := ""
            if user
                try det := Tr("salvato il {1}", IniRead(UserData.Themes, SubStr(t, 6), "_Salvato", ""))
            if (t = cur)
                det := "●  " Tr("in uso") (det != "" ? "  ·  " det : ""), sel := this.ThemeRows.Length + 1
            this.ThemeRows.Push(t)
            this.TLV.Add(, this.EnumText("Theme", t), kind, det)
        }
        this.TLV.Opt("+Redraw")
        this.TLV.Modify(sel, "Select Focus Vis")
        this.THelp.Text := Tr("1. Scegli un tema e premi `"Personalizza questo tema`": nasce `"(nome) Custom`" con i suoi colori, forme, effetti ed emoji, già in uso.`n"
            . "2. Cambia quello che vuoi: colori dei pannelli in Tema, colori dell'HUD in HUD overlay > Colori ed Effetti, forme ed emoji in Mirino e Icone.`n"
            . "3. `"Salva e riavvia`" salva le modifiche anche nel tuo tema. Con `"Salva il tema attuale con nome...`" ne fai una copia con un altro nome.")
    }

    static ThemeSel() => (row := this.TLV.GetNext()) ? this.ThemeRows[row] : ""

    static ThemeUse() {
        if ((t := this.ThemeSel()) = "")
            return
        vals := SubStr(t, 1, 5) = "user:" ? this.ThemeEffective(t) : Map()
        vals["Theme"] := '"' t '"'
        this.SetValues(vals)
        this.LookApply()
    }

    ; scrive i valori attuali nel tema dell'utente "name" (themes.ini)
    static ThemeWrite(name, vals) {
        UserData.Init()
        try IniDelete(UserData.Themes, name)
        for v, x in vals
            IniWrite("v:" x, UserData.Themes, name, v)
        IniWrite(FormatTime(, "dd/MM/yyyy HH:mm"), UserData.Themes, name, "_Salvato")
        this.OvCache := Map()
    }

    ; "Salva e riavvia" con un tema dell'utente in uso: le modifiche finiscono anche nel tema
    static ThemeSyncOnSave() {
        if !this.Cfg.Has("Theme")
            return
        t := this.Unq(this.Val("Theme"))
        if (SubStr(t, 1, 5) != "user:")
            return
        vals := Map()
        for v in ThemeKeys()
            if this.Cfg.Has(v)
                vals[v] := this.Val(v)
        try this.ThemeWrite(SubStr(t, 6), vals)
    }

    static ThemeCustomize() {
        if ((t := this.ThemeSel()) = "")
            return
        base := SubStr(t, 1, 5) = "user:" ? SubStr(t, 6) : t
        base := RegExReplace(base, "i)\s+Custom(\s+\d+)?$")       ; "halloween Custom" -> "halloween Custom 2", non "... Custom Custom"
        existing := Map()
        for n in UserThemes()
            existing[StrLower(n)] := true
        name := base " Custom", i := 1
        while existing.Has(StrLower(name))
            name := base " Custom " (++i)
        vals := this.ThemeEffective(t)
        try this.ThemeWrite(name, vals)
        catch as e
            return MsgBox(Tr("Salvataggio del tema non riuscito:") "`n" e.Message, "AION 2 Wingman", "Icon!")
        this.RefreshThemes()
        vals["Theme"] := '"user:' name '"'
        this.SetValues(vals)
        this.LookApply()
        MsgBox(Tr("Creato il tema `"{1}`", copia di `"{2}`", ed è già in uso.`nOra puoi cambiare ogni dettaglio nelle impostazioni: con `"Salva e riavvia`" le modifiche vengono salvate anche nel tema.", name, this.EnumText("Theme", t))
            , "AION 2 Wingman", "Iconi")
    }

    static ThemeSaveAs() {
        cur := this.Unq(this.Val("Theme"))
        r := InputBox(Tr("Nome del tema (es. `"Il mio tema`"):"), "AION 2 Wingman", "w360 h130", SubStr(cur, 1, 5) = "user:" ? SubStr(cur, 6) : "")
        if (r.Result != "OK")
            return
        name := Trim(RegExReplace(r.Value, "[\[\]=|`"]"))
        if (name = "")
            return
        for t in ThemeBuiltin()
            if (t = name || name = "custom")
                return MsgBox(Tr("Questo nome è già usato da un tema predefinito."), "AION 2 Wingman", "Icon!")
        for n in UserThemes()
            if (n = name && "user:" n != cur && MsgBox(Tr("Esiste già un tema `"{1}`". Sovrascriverlo?", name), "AION 2 Wingman", "YesNo Icon?") != "Yes")
                return
        vals := this.ThemeEffective(cur)
        if (SubStr(cur, 1, 5) = "user:")                     ; tema dell'utente: i valori attuali (anche non salvati)
            for v in ThemeKeys()
                if this.Cfg.Has(v)
                    vals[v] := this.Val(v)
        try this.ThemeWrite(name, vals)
        catch as e
            return MsgBox(Tr("Salvataggio del tema non riuscito:") "`n" e.Message, "AION 2 Wingman", "Icon!")
        this.RefreshThemes()
        vals["Theme"] := '"user:' name '"'
        this.SetValues(vals)
        this.LookApply()
    }

    static ThemeDelete() {
        if ((t := this.ThemeSel()) = "")
            return
        if (SubStr(t, 1, 5) != "user:")
            return MsgBox(Tr("I temi predefiniti non si possono eliminare."), "AION 2 Wingman", "Iconi")
        name := SubStr(t, 6)
        if (MsgBox(Tr("Eliminare il tema `"{1}`"?", name), "AION 2 Wingman", "YesNo Icon?") != "Yes")
            return
        try IniDelete(UserData.Themes, name)
        this.RefreshThemes()
        if (this.Unq(this.Val("Theme")) = t) {           ; era in uso: torna il tema classico
            this.SetValues(Map("Theme", '"principale"'))
            this.LookApply()
        } else
            this.FillThemes()
    }

    static ShowPresetEditor(on) {
        for c in this.PresetCtrls
            c.Visible := on
        if on {
            for c in [this.LV, this.DName, this.DDesc, this.HdrVal, this.HdrEx, this.ExTxt]
                c.Visible := false
            this.EditorShow("")
        }
    }

    static CustomPresets() {
        out := []
        if !FileExist(this.PresetFile)
            return out
        try {
            for name in StrSplit(IniRead(this.PresetFile), "`n")
                if (Trim(name) != "")
                    out.Push(name)
        }
        return out
    }

    static FillPresets() {
        base := this.Val("HudBaseHeight")
        this.PLV.Opt("-Redraw")
        this.PLV.Delete()
        this.PresetRows := []                             ; riga -> [nome vero, predefinito?]
        static resIcon := Map(1080, "📺", 1440, "🖥️", 2160, "💎")
        for b in this.Builtin
            this.PresetRows.Push([b[1], true])
            , this.PLV.Add(, resIcon[b[2]] "  " b[1], "🏭  " Tr("Predefinito"), b[2] = base + 0 ? Tr("risoluzione attuale dei valori HUD") : Tr("HUD riscalato da {1}p a {2}p", base, b[2]))
        for name in this.CustomPresets() {
            when := ""
            try when := IniRead(this.PresetFile, name, "_Salvato", "")
            this.PresetRows.Push([name, false])
            this.PLV.Add(, "⭐  " name, "✏️  " Tr("Personalizzato"), when != "" ? Tr("salvato il {1}", when) : "")
        }
        this.PLV.Opt("+Redraw")
        this.PLV.Modify(1, "Select Focus")
        this.PHelp.Text := Tr("Doppio click o `"Applica preset`" per caricarlo: i valori cambiati compaiono come modifiche "
            . "(vedi `"Vedi modifiche`") e con l'anteprima dal vivo li vedi subito. Diventano definitivi con `"Salva e riavvia`".`n"
            . "I preset personalizzati salvano tutte le impostazioni (non l'elenco boss) nel file `"AION 2 Wingman - preset.ini`" accanto allo script.")
    }

    static PresetApply() {
        row := this.PLV.GetNext()
        if !row
            return
        name := this.PresetRows[row][1], builtin := this.PresetRows[row][2]
        vals := Map()
        if builtin {
            target := 0
            for b in this.Builtin
                if (b[1] = name)
                    target := b[2]
            base := this.Val("HudBaseHeight") + 0
            if (base <= 0)
                base := 2160
            f := target / base
            for v in this.ScaleVars {
                if (!this.Cfg.Has(v) || this.Cfg[v].type != "num")
                    continue                                  ; valori collegati (es. -LootOffsetX) restano tali
                n := this.Val(v) + 0
                m := n > 0 ? Max(1, Round(n * f)) : Round(n * f)
                if this.Limits.Has(v)
                    m := Min(Max(m, this.Limits[v][1]), this.Limits[v][2])
                vals[v] := String(m)
            }
            vals["HudBaseHeight"] := String(target)
        } else {
            for v in this.Cfg {
                ; preset salvati con le versioni precedenti: nomi "Autoloot..." / "AutoCombat..."
                for key in [v, RegExReplace(v, "Loot", "Autoloot", , 1), RegExReplace(v, "^Combat", "AutoCombat")] {
                    x := ""
                    try x := IniRead(this.PresetFile, name, key)
                    if (SubStr(x, 1, 2) = "v:") {             ; il prefisso protegge le virgolette dei testi
                        vals[v] := StrReplace(StrReplace(SubStr(x, 3), "Autoloot", "Loot"), "AutoCombat", "Combat")
                        break
                    }
                }
            }
        }
        n := this.SetValues(vals)
        this.FillPresets()
        MsgBox(Tr(n = 1 ? "Preset `"{1}`" applicato: {2} valore cambiato." : "Preset `"{1}`" applicato: {2} valori cambiati.", name, n) "`n"
             . Tr("Premi `"Salva e riavvia`" per renderlo definitivo."), "AION 2 Wingman", "Iconi")
    }

    ; imposta più valori come modifiche (e in anteprima li applica subito). Restituisce quanti sono cambiati.
    static SetValues(vals) {
        changed := 0
        for name, v in vals {
            if !this.Cfg.Has(name)
                continue
            old := this.Val(name)
            if (v == old)
                continue
            changed++
            if (v == this.Cfg[name].value) {
                if this.Pending.Has(name)
                    this.Pending.Delete(name)
            } else
                this.Pending[name] := v
        }
        this.UpdateStatus()
        if PreviewMode {
            for name in vals
                if (this.Cfg.Has(name) && this.Invalid(name) = "")
                    this.Apply(name)
            for n, it in this.Cfg
                if (it.type = "expr")
                    this.Apply(n)
            ApplyPerfProfile(), RestartPerfTimers()
            SetTimer(this.RebuildFn, -250)
        }
        return changed
    }

    static PresetSave() {
        r := InputBox(Tr("Nome del nuovo preset (es. `"Il mio 4K`"):"), "AION 2 Wingman", "w360 h130")
        if (r.Result != "OK")
            return
        name := Trim(RegExReplace(r.Value, "[\[\]=]"))
        if (name = "")
            return
        for b in this.Builtin
            if (b[1] = name)
                return MsgBox(Tr("Questo nome è già usato da un preset predefinito."), "AION 2 Wingman", "Icon!")
        for x in this.CustomPresets()
            if (x = name && MsgBox(Tr("Esiste già un preset `"{1}`". Sovrascriverlo?", name), "AION 2 Wingman", "YesNo Icon?") != "Yes")
                return
        try {
            try IniDelete(this.PresetFile, name)
            for v, it in this.Cfg                             ; "v:" evita che Windows tolga le virgolette
                IniWrite("v:" this.Val(v), this.PresetFile, name, v)
            IniWrite(FormatTime(, "dd/MM/yyyy HH:mm"), this.PresetFile, name, "_Salvato")
        } catch as e
            return MsgBox(Tr("Salvataggio del preset non riuscito:") "`n" e.Message, "AION 2 Wingman", "Icon!")
        this.FillPresets()
    }

    static PresetDelete() {
        row := this.PLV.GetNext()
        if !row
            return
        name := this.PresetRows[row][1]
        if this.PresetRows[row][2]
            return MsgBox(Tr("I preset predefiniti non si possono eliminare."), "AION 2 Wingman", "Iconi")
        if (MsgBox(Tr("Eliminare il preset `"{1}`"?", name), "AION 2 Wingman", "YesNo Icon?") != "Yes")
            return
        try IniDelete(this.PresetFile, name)
        this.FillPresets()
    }

    static ShowBossEditor(on) {
        for c in this.BossCtrls
            c.Visible := on
        for c in [this.LV, this.DName, this.DDesc]
            c.Visible := !on
        if on
            this.EditorShow("")
        for c in [this.HdrVal, this.HdrEx, this.ExTxt]
            c.Visible := !on
    }

    static FillBosses(sel := 1) {
        tiers := this.TierNames()
        this.BLV.Opt("-Redraw")
        this.BLV.Delete()
        for b in this.Bosses
            this.BLV.Add(, b.name, this.EnumText("Grade", b.grade), tiers[Min(b.tier, 4) + 1])
        this.BLV.Opt("+Redraw")
        if this.Bosses.Length
            this.BLV.Modify(Min(sel, this.Bosses.Length), "Select Focus Vis"), this.SelectBoss(Min(sel, this.Bosses.Length))
    }

    static SelectBoss(row) {
        this.Loading := true
        b := this.Bosses[row]
        this.BRow := row
        this.BName.Value := b.name
        this.BGrade.Choose(b.grade = "verde" ? 1 : b.grade = "blu" ? 2 : 3)
        this.BTier.Choose(Min(b.tier, 4) + 1)
        this.Loading := false
    }

    static BossChanged() {
        if (this.Loading || !this.HasProp("BRow") || !this.Bosses.Has(this.BRow))
            return
        b := this.Bosses[this.BRow]
        b.name := Trim(StrReplace(this.BName.Value, '"')), b.grade := ["verde", "blu", "oro"][Max(1, this.BGrade.Value)], b.tier := this.BTier.Value - 1
        this.BLV.Modify(this.BRow, , b.name, this.EnumText("Grade", b.grade), this.BTier.Text)
        this.BossDirty := true
        this.UpdateStatus()
        this.Live("FieldBossList")
    }

    static BossAdd() {
        this.Bosses.Push({name: Tr("Nuovo boss"), grade: "oro", tier: 0})
        this.BossDirty := true
        this.FillBosses(this.Bosses.Length)
        this.BName.Focus()
        this.UpdateStatus()
        this.Live("FieldBossList")
    }

    static BossDel() {
        if (!this.HasProp("BRow") || !this.Bosses.Has(this.BRow))
            return
        if (MsgBox(Tr("Rimuovere `"{1}`" dall'elenco?", this.Bosses[this.BRow].name), "AION 2 Wingman", "YesNo Icon?") != "Yes")
            return
        this.Bosses.RemoveAt(this.BRow)
        this.BossDirty := true
        this.FillBosses(Max(1, this.BRow - 1))
        this.UpdateStatus()
        this.Live("FieldBossList")
    }

    ; ---------------- Anteprima dal vivo ----------------
    ; Mostra HUD (attivo) e interfacce Field Boss anche senza gioco, e a ogni modifica
    ; applica il nuovo valore e le ricostruisce. Tasti e Hidden Cube si applicano al salvataggio.
    static PreviewSet(on) {
        global PreviewMode := on ? true : false
        if !this.PulseFn
            this.PulseFn := ObjBindMethod(this, "Pulse"), this.RebuildFn := ObjBindMethod(this, "Rebuild")
        if PreviewMode {
            for name in this.Pending                      ; applica le modifiche già fatte (solo valide)
                if (this.Invalid(name) = "")
                    this.Apply(name)
            if this.BossDirty
                this.Apply("FieldBossList")
            ApplyPerfProfile(), RestartPerfTimers()
            this.Rebuild()
            SetTimer(this.PulseFn, 100)
        } else {
            SetTimer(this.PulseFn, 0), SetTimer(this.RebuildFn, 0)
            this.RestoreLive()
            RestartPerfTimers()
            BuildHud()
            UpdateVisibility()
            FieldBoss.LoadBossList()
            FieldBoss.PreviewHide()
        }
        if IsObject(this.Win) {
            this.PreviewPaint()
            if PreviewMode                                ; acceso: si apre subito il menu degli elementi
                this.ElemShow()
            else
                this.ElemHide()
        }
    }

    ; ---------------- Menu "Elementi" dell'anteprima ----------------
    ; Finestrella sotto l'intestazione: un interruttore per ogni elemento dell'HUD e dei tool.
    static ElemWin := "", ElemRows := Map()

    static ElemToggle() {
        if (IsObject(this.ElemWin) && DllCall("IsWindowVisible", "Ptr", this.ElemWin.Hwnd))
            this.ElemHide()
        else
            this.ElemShow()
    }

    static ElemShow() {
        if !IsObject(this.Win)
            return
        if !IsObject(this.ElemWin) || !WinExist(this.ElemWin.Hwnd) {
            e := Gui("+Owner" this.Win.Hwnd " -Caption +Border +ToolWindow", "Preview")
            e.BackColor := UiC("WinBg"), e.MarginX := 10, e.MarginY := 8
            e.SetFont("s9 bold c" UiC("WinSub"), "Segoe UI")
            e.AddText("xm ym w176 h20 0x200", Tr("Elementi nell'anteprima"))
            e.SetFont("s10 bold c" UiC("WinSub"), "Segoe UI")
            e.AddText("x+4 yp w20 h20 Center 0x200", "✕").OnEvent("Click", (*) => this.ElemHide())
            e.SetFont("s10 norm c" UiC("WinText"), "Segoe UI")
            this.ElemRows := Map()
            for it in PreviewElemOrder {
                key := it[1]
                c := e.AddText("xm y+4 w200 h24 0x200 Background" UiC("WinField"), "")
                c.OnEvent("Click", ObjBindMethod(this, "ElemFlip", key))
                this.ElemRows[key] := {ctrl: c, label: Tr(it[2])}
            }
            e.SetFont("s9 bold c" UiC("WinText"), "Segoe UI")
            e.AddText("xm y+8 w98 h22 Center 0x200 Background" UiC("Row"), Tr("Tutti")).OnEvent("Click", (*) => this.ElemAll(true))
            e.AddText("x+4 yp w98 h22 Center 0x200 Background" UiC("Row"), Tr("Nessuno")).OnEvent("Click", (*) => this.ElemAll(false))
            this.ElemWin := e
            this.ElemPaint()
        }
        WinGetPos(&bx, &by, , &bh, this.PrevElemBtn.Hwnd)      ; sotto il pulsante "Elementi"
        this.ElemWin.Show("NA AutoSize x" bx " y" (by + bh + 32))
    }

    static ElemHide() {
        if (IsObject(this.ElemWin) && WinExist(this.ElemWin.Hwnd))
            this.ElemWin.Hide()
    }

    static ElemPaint() {
        for key, r in this.ElemRows {
            on := PreviewElems[key]
            r.ctrl.Text := (on ? "  🟢  " : "  ⚪  ") r.label
            r.ctrl.SetFont(on ? "c" UiC("WinText") : "c" UiC("WinSub"))
        }
    }

    static ElemFlip(key, *) {
        PreviewElems[key] := !PreviewElems[key]
        this.ElemPaint()
        this.PreviewRefresh()
    }

    static ElemAll(on) {
        for key in PreviewElems
            PreviewElems[key] := on
        this.ElemPaint()
        this.PreviewRefresh()
    }

    ; mostra/nasconde subito gli elementi scelti, senza ricostruire nulla
    static PreviewRefresh() {
        if !PreviewMode
            return
        for grp in AllGroups
            if PreviewAllows(grp.HasOwnProp("PvKey") ? grp.PvKey : "")
                grp.Show()
            else
                grp.Hide()
        FieldBoss.PreviewShow()
        ViCountdownBar.Tick()
    }

    ; aggiorna l'aspetto degli interruttori dell'anteprima (acceso/spento, ON/OFF scelto)
    static PreviewPaint() {
        this.PrevChk.SetFont("c" (PreviewMode ? UiC("Accent") : UiC("SubText")))
        this.PrevTrack.Opt("+Background" (PreviewMode ? UiC("Ok") : UiC("Row")))
        this.PrevTrack.GetPos(&tx, &ty, &tw)
        this.PrevKnob.Move(PreviewMode ? tx + tw - 18 : tx + 2)
        this.PrevElemBtn.Opt("+Background" (PreviewMode ? UiC("Row") : UiC("Bg")))
        this.PrevElemBtn.SetFont("c" (PreviewMode ? UiC("Text") : UiC("Muted")))
        for c in [this.PrevTrack, this.PrevKnob, this.PrevChk, this.PrevElemBtn]
            c.Redraw()
        for pair in [[this.PrevOn, PreviewHudOn], [this.PrevOff, !PreviewHudOn]] {
            c := pair[1], sel := pair[2] && PreviewMode
            c.Opt("+Background" (sel ? UiC("Accent") : UiC("Row")))
            c.SetFont("c" (sel ? UiC("Bg") : PreviewMode ? UiC("SubText") : UiC("Muted")))
            c.Redraw()
        }
    }

    ; anteprima dell'HUD attivo (ON) o inattivo (OFF): colori, forme del mirino ed effetti
    static PreviewState(on) {
        global PreviewHudOn := on ? true : false
        if IsObject(this.Win)
            this.PreviewPaint()
        if PreviewMode
            this.Rebuild()                                ; riparte nello stato scelto
    }

    ; tiene accesi mirino, barre e icone come se le macro stessero inviando F9 / F10
    static Pulse() {
        if !PreviewMode
            return SetTimer(this.PulseFn, 0)
        if !PreviewHudOn                                   ; stato OFF: nessun segnale, l'HUD resta inattivo
            return
        try CombatHUD.Signal()
        try LootHUD.Signal()
    }

    ; valore modificato: in anteprima lo applica e ricostruisce le interfacce (dopo una breve pausa)
    static Live(name) {
        if !PreviewMode
            return
        if (name != "FieldBossList" && this.Invalid(name) != "")     ; valore non valido: non lo applica
            return
        this.Apply(name)
        for n, it in this.Cfg                             ; valori calcolati (es. -LootOffsetX)
            if (it.type = "expr")
                this.Apply(n)
        if (SubStr(name, 1, 4) = "Perf" || name = "AnimInterval" || InStr(name, "Interval") || name = "FieldBossCheckEvery") {
            for v in PerfVars                             ; ricorda i valori del file prima del profilo
                if !this.Orig.Has(v)
                    this.Orig[v] := GetGlobalVar(v)
            ApplyPerfProfile()
            RestartPerfTimers()
            return
        }
        if (SubStr(name, 1, 6) = "Splash") {              ; splash: lo rimostra con i nuovi valori
            if SplashEnabled
                SplashScreen.Show()
            return
        }
        SetTimer(this.RebuildFn, -250)
    }

    static Rebuild() {
        if !PreviewMode
            return
        BuildHud()
        UpdateVisibility()
        if PreviewHudOn
            try CombatHUD.Signal(), LootHUD.Signal()
        FieldBoss.LoadBossList()
        FieldBoss.PreviewShow()
    }

    ; scrive il valore (in modifica o del file) nella variabile globale, ricordando l'originale
    static Apply(name) {
        if this.IsLook(name)                              ; lingua e tema li gestisce LookApply
            return
        if (name = "FieldBossList") {
            val := []
            for b in this.Bosses
                val.Push([b.name, b.grade, b.tier])
        } else {
            if !this.Cfg.Has(name)
                return
            if !this.LiveValue(name, &val)
                return
        }
        if !this.Orig.Has(name)
            this.Orig[name] := GetGlobalVar(name)
        SetGlobalVar(name, val)
    }

    static RestoreLive() {
        for name, val in this.Orig
            SetGlobalVar(name, val)
        this.Orig := Map()
    }

    ; converte il testo della CONFIG nel valore vero (false = non convertibile, viene saltato)
    static LiveValue(name, &out) {
        v := this.Val(name), t := this.Cfg[name].type
        switch t {
            case "bool":  out := v = "true"
            case "num":
                if !RegExMatch(v, "^-?\d+(\.\d+)?$")
                    return false
                out := v + 0
            case "multi":
                out := [], pos := 1
                while RegExMatch(v, '"([^"]*)"', &m, pos)
                    out.Push(m[1]), pos := m.Pos + m.Len
            case "expr":
                if RegExMatch(v, "^-?\d+(\.\d+)?$")
                    out := v + 0
                else if RegExMatch(v, "^(-?)\s*([A-Za-z_]\w*)$", &m) {
                    try base := GetGlobalVar(m[2])
                    catch
                        return false
                    out := m[1] = "-" ? -base : base
                } else
                    return false
            default:      out := this.Unq(v)
        }
        return true
    }

    ; ---------------- Salvataggio ----------------
    ; Finestra con l'elenco delle modifiche non salvate: prima e dopo
    static ShowChanges() {
        if (!this.Pending.Count && !this.BossDirty)
            return MsgBox(Tr("Nessuna modifica da salvare."), "AION 2 Wingman", "Iconi")
        c := Gui("+Owner" this.Win.Hwnd " -MinimizeBox", Tr("Modifiche non salvate"))
        c.SetFont("s10", "Segoe UI")
        c.BackColor := UiC("WinBg")
        c.AddText("w640", Tr("Valori cambiati rispetto al file. Doppio click su una riga per andare all'impostazione."))
        lv := c.AddListView("w640 h300 -Multi Grid", [Tr("Impostazione"), Tr("Prima"), Tr("Dopo"), ""])
        names := []                                       ; riga -> variabile (le etichette non sono uniche)
        for name in this.Pending {
            orig := this.Cfg[name].value
            names.Push(name)
            lv.Add(, this.Label(name), this.ShownOf(name, orig), this.ShownOf(name, this.Pending[name])
                 , this.Invalid(name) != "" ? Tr("non valido") : "")
        }
        if this.BossDirty {
            n := 0
            for b in this.Bosses
                n++
            names.Push("FieldBossList")
            lv.Add(, Tr("Elenco boss"), Tr("(come nel file)"), Tr("{1} boss, modificato", n), "")
        }
        lv.ModifyCol(1, 230), lv.ModifyCol(2, 160), lv.ModifyCol(3, 160), lv.ModifyCol(4, 80)
        lv.OnEvent("DoubleClick", (ctrl, row) => (row ? (this.GoTo(names[row]), c.Destroy()) : 0))
        c.AddButton("w120 Default", Tr("Chiudi")).OnEvent("Click", (*) => c.Destroy())
        c.Show()
    }

    ; testo leggibile di un valore qualsiasi (non solo quello attuale)
    static ShownOf(name, v) {
        keep := this.Pending.Has(name) ? this.Pending[name] : ""
        had := this.Pending.Has(name)
        this.Pending[name] := v
        out := this.Shown(name)
        if had
            this.Pending[name] := keep
        else
            this.Pending.Delete(name)
        return out
    }

    ; seleziona nel menu e nell'elenco l'impostazione con questo nome leggibile
    static GoTo(name) {
        for id, n in this.Nodes {
            if (name = "FieldBossList") {
                if (!IsObject(n.content) && n.content = "BOSS")
                    return (this.TV.Modify(id, "Select"), this.SelectNode(id, true))
                continue
            }
            if (IsObject(n.content) && n.content.Length && IsObject(n.content[1]))     ; nodo con sottomenu
                continue
            for v in this.NodeVars(n)
                if (v = name) {
                    this.TV.Modify(id, "Select")
                    this.SelectNode(id, true)
                    if (row := this.FindRow(v))
                        this.LV.Modify(row, "Select Focus Vis"), this.SelectRow(row)
                    return
                }
        }
    }

    static UpdateStatus() {
        n := this.Pending.Count + (this.BossDirty ? 1 : 0)
        this.Status.Text := n ? "● " Tr(n = 1 ? "{1} modifica non salvata" : "{1} modifiche non salvate", n) : Tr("Nessuna modifica")
        this.ChgBtn.Enabled := n > 0
        this.Status.SetFont(n ? "c" UiC("Err") : "c" UiC("WinSub"))
    }

    static Save() {
        if (!this.Pending.Count && !this.BossDirty)
            return this.Close()
        ; controlli
        for name, v in this.Pending
            if ((why := this.Invalid(name)) != "")
                return MsgBox(Tr("`"{1}`": {2}.`nCorreggilo prima di salvare.", this.Label(name), why), "AION 2 Wingman", "Icon!")
        for b in this.Bosses
            if (b.name = "")
                return MsgBox(Tr("C'è un boss senza nome nell'elenco."), "AION 2 Wingman", "Icon!")

        this.ThemeSyncOnSave()                            ; tema dell'utente in uso: aggiorna anche il tema
        if !this.WriteFile()
            return
        UserData.Persist(this.Pending, this.BossDirty ? this.Bosses : "")   ; resta valido anche dopo un aggiornamento
        UserData.Stamp()
        Reload()
    }

    ; Scrive nella CONFIG di questo file le modifiche (Pending) e l'elenco boss (se cambiato).
    static WriteFile(quiet := false) {
        lines := this.Lines.Clone()
        ; valori: per ogni riga dal più a destra al più a sinistra, così le posizioni restano valide
        byLine := Map()
        for name, v in this.Pending {
            c := this.Cfg[name]
            if !byLine.Has(c.line)
                byLine[c.line] := []
            byLine[c.line].Push({start: c.start, len: c.len, v: v})
        }
        for ln, list in byLine {
            loop list.Length - 1                                     ; ordina per posizione decrescente
                loop list.Length - A_Index
                    if (list[A_Index].start < list[A_Index + 1].start)
                        t := list[A_Index], list[A_Index] := list[A_Index + 1], list[A_Index + 1] := t
            l := lines[ln]
            for e in list
                l := SubStr(l, 1, e.start - 1) e.v SubStr(l, e.start + e.len)
            lines[ln] := l
        }
        ; elenco boss: riscrive le righe tra "global FieldBossList := [" e "]"
        if (this.BossDirty && this.BossFrom && this.BossTo) {
            nb := []
            for i, b in this.Bosses {
                q1 := '["' b.name '",', q2 := '"' b.grade '",'
                nb.Push("    " q1 Format("{:" Max(1, 38 - StrLen(q1)) "}", "") q2 Format("{:" Max(1, 10 - StrLen(q2)) "}", "")
                      . b.tier "]" (i < this.Bosses.Length ? "," : ""))
            }
            if (this.BossTo - this.BossFrom - 1 > 0)
                lines.RemoveAt(this.BossFrom + 1, this.BossTo - this.BossFrom - 1)
            for i, l in nb
                lines.InsertAt(this.BossFrom + i, l)
        }
        out := ""
        for i, l in lines
            out .= l (i < lines.Length ? this.EOL : "")
        try {
            FileCopy(A_ScriptFullPath, A_ScriptFullPath ".bak", true)
            f := FileOpen(A_ScriptFullPath, "w", "UTF-8-RAW")
            f.Write(out), f.Close()
        } catch as e {
            if !quiet
                MsgBox(Tr("Salvataggio non riuscito:") "`n" e.Message, "AION 2 Wingman", "Icon!")
            return false
        }
        return true
    }

    static Discard() {
        if (!this.Pending.Count && !this.BossDirty)
            return
        this.Load()
        if PreviewMode                                    ; anteprima: torna ai valori del file
            this.RestoreLive(), ApplyPerfProfile(), RestartPerfTimers(), this.Rebuild()
        if this.LookDiffers()                             ; torna a lingua e tema del file (ridisegna tutto)
            return this.LookApply()
        this.SelectNode(this.TV.GetSelection(), true)
        this.UpdateStatus()
    }

    static Close() {
        if ((this.Pending.Count || this.BossDirty)
            && MsgBox(Tr("Ci sono modifiche non salvate. Chiudere senza salvarle?"), "AION 2 Wingman", "YesNo Icon?") != "Yes")
            return true
        if PreviewMode
            this.PreviewSet(false)                        ; chiude l'anteprima e rimette i valori del file
        this.ElemHide(), this.ElemWin := ""
        this.Win.Destroy()
        this.Win := ""
        this.Pending := Map(), this.BossDirty := false
        if this.LookDiffers() {                           ; lingua/tema non salvati: tornano quelli del file
            this.LookSet()
            FieldBoss.ResetUi()
            BuildHud()                                    ; l'HUD riprende i colori del tema salvato
            UpdateVisibility()
        }
    }

    ; ---------------- Lingua ----------------
    ; stesso ordine di Enums["Language"]: inglese, italiano, le altre lingue, poi le due lingue bonus "meme"
    static LangNames := ["🇬🇧 English", "🇮🇹 Italiano", "🇪🇸 Español", "🇫🇷 Français", "🇩🇪 Deutsch", "🇧🇷 Português", "🇷🇺 Русский"
                       , "🇰🇷 한국어", "🇨🇳 简体中文", "🇯🇵 日本語", "🍕 Napulitano (bonus)", "🤙 Bro - Gen Z (bonus)"]

    static TierNames() => [Tr("nessuna"), "👑 " Tr("massima"), "💎 " Tr("superiore"), "🔥 " Tr("importante"), "⭐ " Tr("minore")]

    ; scelta dal menu a tendina in alto: diventa una modifica di "Language" come le altre
    static LangPicked() {
        if (this.Loading || !this.Cfg.Has("Language"))
            return
        v := '"' this.Enums["Language"][this.LangDdl.Value] '"'
        if (v == this.Cfg["Language"].value) {
            if this.Pending.Has("Language")
                this.Pending.Delete("Language")
        } else
            this.Pending["Language"] := v
        this.LookApply()
    }

    ; ---------------- Lingua e tema ("aspetto") ----------------
    ; Si applicano subito alla finestra (che viene ridisegnata) e all'anteprima; senza salvare,
    ; alla chiusura tornano i valori del file.
    static IsLook(name) => name = "Language" || name = "Theme" || SubStr(name, 1, 10) = "ThemeColor"

    ; scrive nelle variabili globali i valori di lingua e tema (in modifica, oppure quelli del file)
    static LookSet(useFile := true) {
        for name, it in this.Cfg
            if this.IsLook(name)
                SetGlobalVar(name, this.Unq(useFile ? it.value : this.Val(name)))
        ThemeApply()
    }

    static LookDiffers() {
        for name, it in this.Cfg
            if (this.IsLook(name) && this.Unq(it.value) != GetGlobalVar(name))
                return true
        return false
    }

    ; applica lingua e tema scelti (anche non salvati) e ridisegna la finestra al prossimo giro
    static LookApply() {
        this.LookSet(false)
        FieldBoss.ResetUi()
        SetTimer(ObjBindMethod(this, "Redraw"), -10)
    }

    ; ricrea la finestra nella nuova lingua, nella stessa posizione e sulla stessa voce del menu
    static Redraw() {
        if !IsObject(this.Win)
            return
        sel := this.TV.GetSelection(), content := this.Nodes.Has(sel) ? this.Nodes[sel].content : "", cur := this.Cur
        this.Win.GetPos(&wx, &wy)
        elemOpen := IsObject(this.ElemWin) && WinExist(this.ElemWin.Hwnd) && DllCall("IsWindowVisible", "Ptr", this.ElemWin.Hwnd)
        this.ElemHide(), this.ElemWin := ""
        this.Win.Destroy()
        this.Win := ""
        this.Build(wx, wy)
        if elemOpen
            this.ElemShow()
        for id, n in this.Nodes {
            same := IsObject(content) ? (IsObject(n.content) && ObjPtr(n.content) = ObjPtr(content))
                                      : (!IsObject(n.content) && n.content == content)
            if same {
                this.TV.Modify(id, "Select")
                this.SelectNode(id, true)                 ; riempie subito l'elenco (senza aspettare l'evento)
                break
            }
        }
        if (cur != "" && (row := this.FindRow(cur)))
            this.LV.Modify(row, "Select Focus Vis"), this.SelectRow(row)
        if PreviewMode
            this.Rebuild()
    }
}

; ==============================================================================
; === LINGUE: Italiano (predefinita) / English / Napoletano / Bro ===
; ==============================================================================
; Tr("testo in italiano", valori...) restituisce il testo nella lingua scelta (Language);
; {1} {2}... vengono sostituiti dai valori. Se manca una traduzione resta l'italiano.
; TrDesc(nome, descrizione) fa lo stesso per le descrizioni delle opzioni nelle Impostazioni.
; Le traduzioni sono in fondo, in I18n.Data(): una voce per blocco,
;   it=testo italiano   en=English   nap=napulitano   bro=gergo Gen Z     (\n = a capo)
;   @=NomeVariabile     (descrizione di un'opzione; @it= sostituisce quella italiana)
Tr(it, args*) {
    s := it
    if (k := I18n.Col()) > 1 {
        I18n.Load()
        if I18n.Text.Has(it) {
            t := I18n.Text[it][k]
            if (t != "")
                s := t
        }
    }
    return args.Length ? Format(s, args*) : s
}

TrDesc(name, itDesc) {
    I18n.Load()
    if !I18n.Desc.Has(name)
        return itDesc
    d := I18n.Desc[name]
    t := d[I18n.Col()]
    return t != "" ? t : d[1] != "" ? d[1] : itDesc
}

class I18n {
    static Text := "", Desc := ""

    ; lingue: codice in Language -> tag nei dati (la colonna è la posizione nell'elenco, 1 = italiano)
    static Codes := ["italiano", "english", "napoletano", "bro", "spanish", "french", "german", "portuguese", "russian", "korean", "chinese", "japanese"]
    static Tags  := ["it", "en", "nap", "bro", "es", "fr", "de", "pt", "ru", "ko", "zh", "ja"]

    ; colonna della lingua scelta (1 = italiano o lingua sconosciuta)
    static Col() {
        static last := "", col := 1
        if (Language != last) {
            last := Language, col := 1
            for i, c in this.Codes
                if (c = Language)
                    col := i
        }
        return col
    }

    static Load() {
        if IsObject(this.Text)
            return
        this.Text := Map(), this.Desc := Map()
        idx := Map()
        for i, t in this.Tags
            idx[t] := i
        n := this.Tags.Length
        cur := []
        for line in StrSplit(this.Data(), "`n", "`r") {
            if !(p := InStr(line, "="))
                continue
            tag := SubStr(line, 1, p - 1), val := StrReplace(SubStr(line, p + 1), "\n", "`n")
            if (tag = "it" || tag = "@") {
                cur := []
                loop n
                    cur.Push("")
                if (tag = "it")
                    cur[1] := val, this.Text[val] := cur
                else
                    for v in StrSplit(val, " ")
                        if (v != "")
                            this.Desc[v] := cur
            } else if (tag = "@it")
                cur[1] := val
            else if idx.Has(tag)
                cur[idx[tag]] := val
        }
    }

    static Data() {
        s := ""
        s .= "
(
it=Impostazioni AION 2 Wingman
en=AION 2 Wingman settings
nap=Mpustaziune 'e AION 2 Wingman
bro=Settaggi AION 2 Wingman bro
es=Ajustes de AION 2 Wingman
fr=Paramètres d'AION 2 Wingman
de=AION 2 Wingman Einstellungen
pt=Configurações do AION 2 Wingman
ru=Настройки AION 2 Wingman
ko=AION 2 Wingman 설정
zh=AION 2 Wingman 设置
ja=AION 2 Wingman 設定
it=non disponibile
en=not available
nap=nun ce sta
bro=non c'è fra, skill issue
es=no disponible
fr=indisponible
de=nicht verfügbar
pt=não disponível
ru=недоступно
ko=사용할 수 없음
zh=不可用
ja=利用不可
it=Hidden Cube trovato ({1}, {2})
en=Hidden Cube found ({1}, {2})
nap=Hidden Cube truvato ({1}, {2})
bro=Hidden Cube sgamato ({1}, {2}) letteralmente
es=Hidden Cube encontrado ({1}, {2})
fr=Hidden Cube trouvé ({1}, {2})
de=Hidden Cube gefunden ({1}, {2})
pt=Hidden Cube encontrado ({1}, {2})
ru=Hidden Cube найден ({1}, {2})
ko=Hidden Cube 발견 ({1}, {2})
zh=找到 Hidden Cube ({1}, {2})
ja=Hidden Cube を検出 ({1}, {2})
it=Hidden Cube: finestra del gioco non trovata
en=Hidden Cube: game window not found
nap=Hidden Cube: 'a fenesta d'o juoco nun se trova
bro=Hidden Cube: il gioco non c'è zio, boh
es=Hidden Cube: no se encuentra la ventana del juego
fr=Hidden Cube : fenêtre du jeu introuvable
de=Hidden Cube: Spielfenster nicht gefunden
pt=Hidden Cube: janela do jogo não encontrada
ru=Hidden Cube: окно игры не найдено
ko=Hidden Cube: 게임 창을 찾을 수 없어요
zh=Hidden Cube:未找到游戏窗口
ja=Hidden Cube: ゲームウィンドウが見つかりません
it=Hidden Cube: {}\nDorato {}/{}   Blu {}/{}   Slot {}/{}\nPulsante in ({}, {})
en=Hidden Cube: {}\nGold {}/{}   Blue {}/{}   Slot {}/{}\nButton at ({}, {})
nap=Hidden Cube: {}\nOro {}/{}   Blu {}/{}   Slot {}/{}\nPulsante a ({}, {})
bro=Hidden Cube: {}\nOro {}/{}   Blu {}/{}   Slot {}/{}\nBottone in ({}, {})
es=Hidden Cube: {}\nDorado {}/{}   Azul {}/{}   Slot {}/{}\nBotón en ({}, {})
fr=Hidden Cube : {}\nDoré {}/{}   Bleu {}/{}   Slot {}/{}\nBouton en ({}, {})
de=Hidden Cube: {}\nGold {}/{}   Blau {}/{}   Slot {}/{}\nButton bei ({}, {})
pt=Hidden Cube: {}\nDourado {}/{}   Azul {}/{}   Slot {}/{}\nBotão em ({}, {})
ru=Hidden Cube: {}\nЗолотой {}/{}   Синий {}/{}   Слот {}/{}\nКнопка в ({}, {})
ko=Hidden Cube: {}\n골드 {}/{}   블루 {}/{}   슬롯 {}/{}\n버튼 위치 ({}, {})
zh=Hidden Cube: {}\n金色 {}/{}   蓝色 {}/{}   栏位 {}/{}\n按钮位于 ({}, {})
ja=Hidden Cube: {}\nゴールド {}/{}   ブルー {}/{}   スロット {}/{}\nボタン位置 ({}, {})
it=RICONOSCIUTO
en=RECOGNIZED
nap=ARRICANUSCIUTO
bro=SGAMATO FR
es=RECONOCIDO
fr=RECONNU
de=ERKANNT
pt=RECONHECIDO
ru=РАСПОЗНАНО
ko=인식됨
zh=已识别
ja=認識済み
it=non riconosciuto
en=not recognized
nap=nun arricanusciuto
bro=non pervenuto bro
es=no reconocido
fr=non reconnu
de=nicht erkannt
pt=não reconhecido
ru=не распознано
ko=인식 안 됨
zh=未识别
ja=未認識
it=manca OCR.ahk
en=OCR.ahk is missing
nap=manca OCR.ahk
bro=manca OCR.ahk fra, recuperalo
es=falta OCR.ahk
fr=OCR.ahk manquant
de=OCR.ahk fehlt
pt=falta o OCR.ahk
ru=OCR.ahk отсутствует
ko=OCR.ahk가 없어요
zh=缺少 OCR.ahk
ja=OCR.ahk がありません
it=OCR di Windows non disponibile
en=Windows OCR not available
nap=ll'OCR 'e Windows nun ce sta
bro=l'OCR di Windows è sparito, sus
es=OCR de Windows no disponible
fr=OCR Windows indisponible
de=Windows-OCR nicht verfügbar
pt=OCR do Windows não disponível
ru=Windows OCR недоступен
ko=Windows OCR을 사용할 수 없어요
zh=Windows OCR 不可用
ja=Windows OCR は利用できません
it=Clicca il BOSS
en=Click the BOSS
nap=Clicca 'o BOSS
bro=Clicca il BOSS bro
es=Haz clic en el BOSS
fr=Clique sur le BOSS
de=Klicke auf den BOSS
pt=Clique no BOSS
ru=Кликните по БОССУ
ko=BOSS를 클릭하세요
zh=点击首领
ja=ボスをクリック
it=Anteprima delle istruzioni
en=Instructions preview
nap=Anteprima d'e struzziune
bro=Preview delle dritte
es=Vista previa de las instrucciones
fr=Aperçu des instructions
de=Vorschau der Anleitung
pt=Prévia das instruções
ru=Предпросмотр инструкций
ko=안내 미리보기
zh=说明预览
ja=操作ガイドのプレビュー
it=Anteprima
en=Preview
nap=Anteprima
bro=Preview
es=Vista previa
fr=Aperçu
de=Vorschau
pt=Prévia
ru=Предпросмотр
ko=미리보기
zh=预览
ja=プレビュー
it=Field Boss - errore:
en=Field Boss - error:
nap=Field Boss - sbaglio:
bro=Field Boss - è crashato tutto fra:
es=Field Boss - error:
fr=Field Boss - erreur :
de=Field Boss - Fehler:
pt=Field Boss - erro:
ru=Field Boss - ошибка:
ko=Field Boss - 오류:
zh=Field Boss - 错误:
ja=Field Boss - エラー:
it=Clicca {1}
en=Click {1}
nap=Clicca {1}
bro=Spacca {1} bro
es=Haz clic en {1}
fr=Clique sur {1}
de=Klicke auf {1}
pt=Clique em {1}
ru=Кликните {1}
ko={1}을(를) 클릭하세요
zh=点击 {1}
ja={1} をクリック
it=Apro la lista dei Field Boss
en=Opening the Field Boss list
nap=Arapo 'a lista d'e Field Boss
bro=Apro la lista dei Field Boss, tranqui
es=Abriendo la lista de Field Boss
fr=J'ouvre la liste des Field Boss
de=Ich öffne die Field Boss Liste
pt=Abrindo a lista de Field Boss
ru=Открываю список Field Boss
ko=Field Boss 목록을 여는 중
zh=正在打开 Field Boss 列表
ja=Field Boss リストを開いています
it=Cerco {1}...
en=Looking for {1}...
nap=Sto cercanno {1}...
bro=Sto cercando {1} zio...
es=Buscando {1}...
fr=Je cherche {1}...
de=Ich suche {1}...
pt=Procurando {1}...
ru=Ищу {1}...
ko={1} 찾는 중...
zh=正在查找 {1}...
ja={1} を検索中...
it=Scorro la lista dei boss
en=Scrolling the boss list
nap=Scorro 'a lista d'e boss
bro=Scrollo la lista, chill
es=Desplazando la lista de bosses
fr=Je fais défiler la liste des boss
de=Ich scrolle durch die Boss-Liste
pt=Rolando a lista de bosses
ru=Прокручиваю список боссов
ko=보스 목록을 스크롤하는 중
zh=正在滚动首领列表
ja=ボスリストをスクロール中
it=Boss non trovato
en=Boss not found
nap=Boss nun truvato
bro=Boss non pervenuto
es=Boss no encontrado
fr=Boss introuvable
de=Boss nicht gefunden
pt=Boss não encontrado
ru=Босс не найден
ko=보스를 찾을 수 없음
zh=未找到首领
ja=ボスが見つかりません
it={1} non è nella lista del gioco
en={1} is not in the game's list
nap={1} nun sta dint'â lista d'o juoco
bro={1} non sta nella lista del gioco, sus
es={1} no está en la lista del juego
fr={1} n'est pas dans la liste du jeu
de={1} steht nicht in der Spielliste
pt={1} não está na lista do jogo
ru={1} нет в списке игры
ko={1}은(는) 게임 목록에 없어요
zh=游戏列表中没有 {1}
ja={1} はゲーム内のリストにありません
it=Cerco il Teleport più vicino...
en=Looking for the nearest Teleport...
nap=Sto cercanno 'o Teleport cchiù vicino...
bro=Cerco il Teleport più vicino, wait...
es=Buscando el Teleport más cercano...
fr=Je cherche le Teleport le plus proche...
de=Ich suche den nächsten Teleport...
pt=Procurando o Teleport mais próximo...
ru=Ищу ближайший Teleport...
ko=가장 가까운 Teleport를 찾는 중...
zh=正在查找最近的 Teleport...
ja=最寄りの Teleport を検索中...
it=Scrolla la lista dei boss
en=Scroll the boss list
nap=Scrolla 'a lista d'e boss
bro=Scrolla la lista dei boss fra
es=Desplaza la lista de bosses
fr=Fais défiler la liste des boss
de=Scrolle durch die Boss-Liste
pt=Role a lista de bosses
ru=Прокрутите список боссов
ko=보스 목록을 스크롤하세요
zh=滚动首领列表
ja=ボスリストをスクロールしてください
it=Cerco {1}: lo riconosco appena compare
en=Looking for {1}: I'll spot it as soon as it shows up
nap=Sto cercanno {1}: 'o riconosco appena compare
bro=Cerco {1}: appena droppa lo sgamo
es=Buscando {1}: lo reconoceré en cuanto aparezca
fr=Je cherche {1} : je le repère dès qu'il apparaît
de=Ich suche {1}: Ich erkenne es, sobald es erscheint
pt=Procurando {1}: vou reconhecer assim que aparecer
ru=Ищу {1}: распознаю, как только появится
ko={1} 찾는 중: 나타나면 바로 인식해요
zh=正在查找 {1}:出现后我会立刻识别
ja={1} を検索中: 表示され次第認識します
it=Nessun Teleport trovato
en=No Teleport found
nap=Nisciuno Teleport truvato
bro=Zero Teleport, raga
es=No se encontró ningún Teleport
fr=Aucun Teleport trouvé
de=Kein Teleport gefunden
pt=Nenhum Teleport encontrado
ru=Teleport не найден
ko=Teleport를 찾을 수 없음
zh=未找到 Teleport
ja=Teleport が見つかりません
it=Prova a spostare o rimpicciolire la mappa
en=Try moving or zooming out the map
nap=Prova a spustà 'a mappa o a fa' cchiù piccerella
bro=Sposta o zoomma indietro la mappa bro
es=Prueba a mover o alejar el mapa
fr=Essaie de déplacer la carte ou de dézoomer
de=Versuche, die Karte zu verschieben oder herauszuzoomen
pt=Tente mover ou diminuir o zoom do mapa
ru=Попробуйте сдвинуть или отдалить карту
ko=지도를 옮기거나 축소해 보세요
zh=试着移动或缩小地图
ja=マップを動かすか縮小してみてください
it=Clicca il TELEPORT
en=Click the TELEPORT
nap=Clicca 'o TELEPORT
bro=Clicca il TELEPORT bro
es=Haz clic en el TELEPORT
fr=Clique sur le TELEPORT
de=Klicke auf den TELEPORT
pt=Clique no TELEPORT
ru=Кликните по TELEPORT
ko=Teleport를 클릭하세요
zh=点击 TELEPORT
ja=TELEPORT をクリック
it=Il più vicino a {1}
en=The nearest to {1}
nap='O cchiù vicino a {1}
bro=Il più vicino a {1}, ez
es=El más cercano a {1}
fr=Le plus proche de {1}
de=Der nächste zu {1}
pt=O mais próximo de {1}
ru=Ближайший к {1}
ko={1}에서 가장 가까움
zh=离 {1} 最近
ja={1} に最も近い
it={1} volte
en={1} times
nap={1} vote
bro={1} volte
es={1} veces
fr={1} fois
de={1} Mal
pt={1} vezes
ru={1} раз(а)
ko={1}회
zh={1} 次
ja={1}回
)" "`n"
        s .= "
(
it=Poi vola verso {1} per raggiungere {2}
en=Then fly towards {1} to reach {2}
nap=Po' vola verso {1} pe' arrivà a {2}
bro=Poi vola a {1} e vai a shottare {2}
es=Luego vuela hacia {1} para llegar a {2}
fr=Puis vole vers {1} pour rejoindre {2}
de=Flieg dann Richtung {1}, um {2} zu erreichen
pt=Depois voe em direção a {1} para chegar a {2}
ru=Затем летите в сторону {1}, чтобы добраться до {2}
ko=그다음 {1} 방향으로 날아가 {2}에 도착하세요
zh=然后飞向{1},前往{2}
ja=次に {1} へ飛んで {2} に到達します
it=Buona caccia!
en=Happy hunting!
nap=Bona caccia!
bro=GG, vai a farmare bro!
es=¡Buena caza!
fr=Bonne chasse !
de=Viel Erfolg bei der Jagd!
pt=Boa caça!
ru=Удачной охоты!
ko=즐거운 사냥 되세요!
zh=狩猎愉快!
ja=良い狩りを!
it=Premi  {1}  {2}per il Travel
en=Press  {1}  {2}to Travel
nap=Premme  {1}  {2}pe' fa' 'o Travel
bro=Premi  {1}  {2}e si parte fra
es=Pulsa  {1}  {2}para el Travel
fr=Appuie sur  {1}  {2}pour le Travel
de=Drücke  {1}  {2}für den Travel
pt=Pressione  {1}  {2}para o Travel
ru=Нажмите  {1}  {2}для Travel
ko=Travel하려면  {1}  {2}누르세요
zh=按  {1}  {2}进行 Travel
ja={1}  {2}を押して Travel
it=Premi ancora  {1}
en=Press  {1}  again
nap=Premme n'ata vota  {1}
bro=Ancora  {1}  bro, dai
es=Pulsa de nuevo  {1}
fr=Appuie encore sur  {1}
de=Drücke  {1}  noch einmal
pt=Pressione  {1}  de novo
ru=Нажмите  {1}  ещё раз
ko={1}  키를 다시 누르세요
zh=再按一次  {1}
ja=もう一度  {1}  を押す
it=Pressione {1} di {2}
en=Press {1} of {2}
nap=Pressione {1} 'e {2}
bro=Botta {1} di {2}
es=Pulsación {1} de {2}
fr=Appui {1} sur {2}
de=Druck {1} von {2}
pt=Pressão {1} de {2}
ru=Нажатие {1} из {2}
ko={2}번 중 {1}번째 누름
zh=第 {1} 次按键,共 {2} 次
ja={2}回中{1}回目
it=il boss: è proprio qui
en=the boss: it's right here
nap='o boss: sta proprio ccà
bro=il boss: è qua, letteralmente
es=el boss: está justo aquí
fr=le boss : il est juste ici
de=den Boss: Er ist genau hier
pt=o boss: ele está bem aqui
ru=босса: он прямо здесь
ko=보스: 바로 여기 있어요
zh=首领:就在这里
ja=ボスはまさにここです
it=QUI
en=HERE
nap=CCÀ
bro=QUA
es=AQUÍ
fr=ICI
de=HIER
pt=AQUI
ru=ЗДЕСЬ
ko=여기
zh=这里
ja=ここ
it=VOLA VERSO
en=FLY TOWARDS
nap=VULA VERSO
bro=VOLA A
es=VUELA HACIA
fr=VOLE VERS
de=FLIEG RICHTUNG
pt=VOE PARA
ru=ЛЕТИТЕ НА
ko=이동 방향
zh=飞向
ja=飛ぶ方向
it=EST
en=EAST
nap=EST
bro=EST
es=ESTE
fr=EST
de=OSTEN
pt=LESTE
ru=ВОСТОК
ko=동
zh=东
ja=東
it=NORD-EST
en=NORTH-EAST
nap=NORD-EST
bro=NORD-EST
es=NORESTE
fr=NORD-EST
de=NORDOSTEN
pt=NORDESTE
ru=СЕВЕРО-ВОСТОК
ko=북동
zh=东北
ja=北東
it=NORD
en=NORTH
nap=NORD
bro=NORD
es=NORTE
fr=NORD
de=NORDEN
pt=NORTE
ru=СЕВЕР
ko=북
zh=北
ja=北
it=NORD-OVEST
en=NORTH-WEST
nap=NORD-OVEST
bro=NORD-OVEST
es=NOROESTE
fr=NORD-OUEST
de=NORDWESTEN
pt=NOROESTE
ru=СЕВЕРО-ЗАПАД
ko=북서
zh=西北
ja=北西
it=OVEST
en=WEST
nap=OVEST
bro=OVEST
es=OESTE
fr=OUEST
de=WESTEN
pt=OESTE
ru=ЗАПАД
ko=서
zh=西
ja=西
it=SUD-OVEST
en=SOUTH-WEST
nap=SUD-OVEST
bro=SUD-OVEST
es=SUROESTE
fr=SUD-OUEST
de=SÜDWESTEN
pt=SUDOESTE
ru=ЮГО-ЗАПАД
ko=남서
zh=西南
ja=南西
it=SUD
en=SOUTH
nap=SUD
bro=SUD
es=SUR
fr=SUD
de=SÜDEN
pt=SUL
ru=ЮГ
ko=남
zh=南
ja=南
it=SUD-EST
en=SOUTH-EAST
nap=SUD-EST
bro=SUD-EST
es=SURESTE
fr=SUD-EST
de=SÜDOSTEN
pt=SUDESTE
ru=ЮГО-ВОСТОК
ko=남동
zh=东南
ja=南東
it=Clicca il PUNTO VUOTO
en=Click the EMPTY SPOT
nap=Clicca 'o PUNTO VACANTE
bro=Clicca il PUNTO VUOTO bro
es=Haz clic en el PUNTO VACÍO
fr=Clique sur le POINT VIDE
de=Klicke auf die LEERE STELLE
pt=Clique no PONTO VAZIO
ru=Кликните по ПУСТОМУ МЕСТУ
ko=빈 곳을 클릭하세요
zh=点击空白处
ja=空きスペースをクリック
it=Chiude il riquadro dei loot che copre i Teleport
en=Closes the loot box that covers the Teleports
nap=Chiure 'o riquadro d'e loot ca copre 'e Teleport
bro=Chiude il pannello del loot che copre i Teleport, cringe
es=Cierra el recuadro de botín que tapa los Teleport
fr=Ferme la fenêtre de butin qui cache les Teleport
de=Schließt das Loot-Fenster, das die Teleports verdeckt
pt=Fecha a caixa de loot que cobre os Teleports
ru=Закрывает окно добычи, перекрывающее Teleport
ko=Teleport를 가리는 전리품 창을 닫아요
zh=关闭遮住 Teleport 的战利品框
ja=Teleport を覆うドロップ枠を閉じます
it=FASE {1}
en=STEP {1}
nap=FASE {1}
bro=STEP {1}
es=PASO {1}
fr=ÉTAPE {1}
de=SCHRITT {1}
pt=PASSO {1}
ru=ШАГ {1}
ko=단계 {1}
zh=步骤 {1}
ja=ステップ {1}
it=Esc = annulla
en=Esc = cancel
nap=Esc = lassa sta'
bro=Esc = lascia stare
es=Esc = cancelar
fr=Esc = annuler
de=Esc = abbrechen
pt=Esc = cancelar
ru=Esc = отмена
ko=Esc = 취소
zh=Esc = 取消
ja=Esc = キャンセル
it=Impostazioni
en=Settings
nap=Mpustaziune
bro=Settaggi
es=Ajustes
fr=Paramètres
de=Einstellungen
pt=Configurações
ru=Настройки
ko=설정
zh=设置
ja=設定
it=Annulla
en=Cancel
nap=Lassa sta'
bro=Lascia stare
es=Cancelar
fr=Annuler
de=Abbrechen
pt=Cancelar
ru=Отмена
ko=취소
zh=取消
ja=キャンセル
it=Verde
en=Green
nap=Verde
bro=Verde
es=Verde
fr=Vert
de=Grün
pt=Verde
ru=Зелёный
ko=초록
zh=绿色
ja=緑
it=Blu
en=Blue
nap=Blu
bro=Blu
es=Azul
fr=Bleu
de=Blau
pt=Azul
ru=Синий
ko=파랑
zh=蓝色
ja=青
it=Oro
en=Gold
nap=Oro
bro=Oro
es=Oro
fr=Or
de=Gold
pt=Ouro
ru=Золото
ko=금색
zh=金色
ja=金
it=Attivi
en=Active
nap=Attive
bro=Live
es=Activos
fr=Actifs
de=Aktiv
pt=Ativos
ru=Включены
ko=활성
zh=激活
ja=有効
it=Non attivi
en=Inactive
nap=Nun attive
bro=Off
es=Inactivos
fr=Inactifs
de=Inaktiv
pt=Inativos
ru=Выключены
ko=비활성
zh=未激活
ja=無効
it=Teleport: {1}   Teschi rossi: {2}
en=Teleports: {1}   Red skulls: {2}
nap=Teleport: {1}   Cape 'e morte rosse: {2}
bro=Teleport: {1}   Teschi rossi: {2}
es=Teleport: {1}   Calaveras rojas: {2}
fr=Teleport : {1}   Crânes rouges : {2}
de=Teleports: {1}   Rote Totenköpfe: {2}
pt=Teleports: {1}   Caveiras vermelhas: {2}
ru=Teleport: {1}   Красные черепа: {2}
ko=Teleport: {1}   붉은 해골: {2}
zh=Teleport:{1}   红色骷髅:{2}
ja=Teleport: {1}   赤ドクロ: {2}
it=Lingua OCR: {1}\nMappa aperta: {2}
en=OCR language: {1}\nMap open: {2}
nap=Lengua OCR: {1}\nMappa aperta: {2}
bro=Lingua OCR: {1}\nMappa aperta: {2}
es=Idioma OCR: {1}\nMapa abierto: {2}
fr=Langue OCR : {1}\nCarte ouverte : {2}
de=OCR-Sprache: {1}\nKarte offen: {2}
pt=Idioma do OCR: {1}\nMapa aberto: {2}
ru=Язык OCR: {1}\nКарта открыта: {2}
ko=OCR 언어: {1}\n지도 열림: {2}
zh=OCR 语言:{1}\n地图已打开:{2}
ja=OCR言語: {1}\nマップ表示: {2}
it=sì
en=yes
nap=sì
bro=fr
es=sí
fr=oui
de=ja
pt=sim
ru=да
ko=예
zh=是
ja=はい
it=no
en=no
nap=no
bro=nah
es=no
fr=non
de=nein
pt=não
ru=нет
ko=아니요
zh=否
ja=いいえ
it=Ancorato al centro: {1}, {2}  (copiato)\nAncorato a sinistra: {3}, {2}
en=Anchored to center: {1}, {2}  (copied)\nAnchored to left: {3}, {2}
nap=Attaccato 'o miezo: {1}, {2}  (copiato)\nAttaccato a mancina: {3}, {2}
bro=Al centro: {1}, {2}  (copiato bro)\nA sinistra: {3}, {2}
es=Anclado al centro: {1}, {2}  (copiado)\nAnclado a la izquierda: {3}, {2}
fr=Ancré au centre : {1}, {2}  (copié)\nAncré à gauche : {3}, {2}
de=Zentriert verankert: {1}, {2}  (kopiert)\nLinks verankert: {3}, {2}
pt=Ancorado ao centro: {1}, {2}  (copiado)\nAncorado à esquerda: {3}, {2}
ru=Привязка к центру: {1}, {2}  (скопировано)\nПривязка слева: {3}, {2}
ko=중앙 기준: {1}, {2}  (복사됨)\n왼쪽 기준: {3}, {2}
zh=居中锚定:{1}, {2}  (已复制)\n左侧锚定:{3}, {2}
ja=中央基準: {1}, {2}  (コピー済み)\n左基準: {3}, {2}
it=serve un numero oppure il nome di un'impostazione (es. LootEmojiSize)
en=a number or the name of another setting is required (e.g. LootEmojiSize)
nap=ce vo' nu nummero o 'o nomme 'e n'ata mpustazione (p'esempio LootEmojiSize)
bro=bro serve un numero o il nome di un settaggio (tipo LootEmojiSize)
es=se necesita un número o el nombre de otro ajuste (p. ej. LootEmojiSize)
fr=un nombre ou le nom d'un autre paramètre est requis (ex. LootEmojiSize)
de=Es wird eine Zahl oder der Name einer anderen Einstellung benötigt (z. B. LootEmojiSize)
pt=é preciso um número ou o nome de outra configuração (ex.: LootEmojiSize)
ru=нужно число или имя другой настройки (напр. LootEmojiSize)
ko=숫자 또는 다른 설정의 이름이 필요해요 (예: LootEmojiSize)
zh=需要填写数字,或其他设置项的名称(例如 LootEmojiSize)
ja=数値、または別の設定名が必要です (例: LootEmojiSize)
it=serve un numero
en=a number is required
nap=ce vo' nu nummero
bro=bro serve un numero
es=se necesita un número
fr=un nombre est requis
de=Es wird eine Zahl benötigt
pt=é preciso um número
ru=нужно число
ko=숫자가 필요해요
zh=需要填写数字
ja=数値が必要です
it=serve un numero, da {1} a {2}
en=a number is required, from {1} to {2}
nap=ce vo' nu nummero, 'a {1} a {2}
bro=bro serve un numero, da {1} a {2}
es=se necesita un número, de {1} a {2}
fr=un nombre est requis, de {1} à {2}
de=Es wird eine Zahl von {1} bis {2} benötigt
pt=é preciso um número, de {1} a {2}
ru=нужно число от {1} до {2}
ko={1}에서 {2} 사이의 숫자가 필요해요
zh=需要填写数字,范围 {1} 到 {2}
ja={1} から {2} までの数値が必要です
it=serve un numero intero, da {1} a {2}
en=a whole number is required, from {1} to {2}
nap=ce vo' nu nummero sano, 'a {1} a {2}
bro=bro serve un numero intero, da {1} a {2}
es=se necesita un número entero, de {1} a {2}
fr=un nombre entier est requis, de {1} à {2}
de=Es wird eine ganze Zahl von {1} bis {2} benötigt
pt=é preciso um número inteiro, de {1} a {2}
ru=нужно целое число от {1} до {2}
ko={1}에서 {2} 사이의 정수가 필요해요
zh=需要填写整数,范围 {1} 到 {2}
ja={1} から {2} までの整数が必要です
)" "`n"
        s .= "
(
it=ammessi solo valori da {1} a {2}
en=only values from {1} to {2} are allowed
nap=vanno bbuone sulo valure 'a {1} a {2}
bro=solo da {1} a {2} fra, no cap
es=solo se admiten valores de {1} a {2}
fr=seules les valeurs de {1} à {2} sont admises
de=nur Werte von {1} bis {2} erlaubt
pt=só são aceitos valores de {1} a {2}
ru=допустимы только значения от {1} до {2}
ko={1}~{2} 사이의 값만 허용돼요
zh=只允许 {1} 到 {2} 的值
ja={1} から {2} の値のみ使用できます
it=Valori ammessi: da {1} a {2}
en=Allowed values: from {1} to {2}
nap=Valure ca vanno bbuone: 'a {1} a {2}
bro=Valori ok: da {1} a {2}
es=Valores admitidos: de {1} a {2}
fr=Valeurs admises : de {1} à {2}
de=Erlaubte Werte: von {1} bis {2}
pt=Valores aceitos: de {1} a {2}
ru=Допустимые значения: от {1} до {2}
ko=허용 값: {1}~{2}
zh=允许的值:{1} 到 {2}
ja=使用可能な値: {1} から {2}
it=(solo numeri interi)
en=(whole numbers only)
nap=(sulo nummere sane)
bro=(solo numeri interi, niente virgole)
es=(solo números enteros)
fr=(nombres entiers uniquement)
de=(nur ganze Zahlen)
pt=(só números inteiros)
ru=(только целые числа)
ko=(정수만 가능)
zh=(仅限整数)
ja=(整数のみ)
it=Impossibile leggere la CONFIG:
en=Unable to read the CONFIG:
nap=Nun se pò leggere 'a CONFIG:
bro=La CONFIG non si legge zio:
es=No se puede leer la CONFIG:
fr=Impossible de lire la CONFIG :
de=CONFIG kann nicht gelesen werden:
pt=Não foi possível ler a CONFIG:
ru=Не удалось прочитать CONFIG:
ko=CONFIG를 읽을 수 없어요:
zh=无法读取 CONFIG:
ja=CONFIG を読み込めません:
it={1}   (profilo {2})
en={1}   (profile {2})
nap={1}   (prufilo {2})
bro={1}   (profilo {2})
es={1}   (perfil {2})
fr={1}   (profil {2})
de={1}   (Profil {2})
pt={1}   (perfil {2})
ru={1}   (профиль {2})
ko={1}   (프로필 {2})
zh={1}   (配置档 {2})
ja={1}   (プロファイル {2})
it=Sì
en=Yes
nap=Sì
bro=Fr
es=Sí
fr=Oui
de=Ja
pt=Sim
ru=Да
ko=예
zh=是
ja=はい
it=No
en=No
nap=No
bro=Nah
es=No
fr=Non
de=Nein
pt=Não
ru=Нет
ko=아니요
zh=否
ja=いいえ
it=(nessuno)
en=(none)
nap=(nisciuno)
bro=(zero)
es=(ninguno)
fr=(aucun)
de=(keine)
pt=(nenhum)
ru=(нет)
ko=(없음)
zh=(无)
ja=(なし)
it=Lingua
en=Language
nap=Lengua
bro=Lingua
es=Idioma
fr=Langue
de=Sprache
pt=Idioma
ru=Язык
ko=언어
zh=语言
ja=言語
it=ANTEPRIMA DAL VIVO
en=LIVE PREVIEW
nap=ANTEPRIMA 'N DIRETTA
bro=PREVIEW LIVE
es=VISTA PREVIA EN VIVO
fr=APERÇU EN DIRECT
de=LIVE-VORSCHAU
pt=PRÉVIA AO VIVO
ru=ПРЕДПРОСМОТР
ko=실시간 미리보기
zh=实时预览
ja=ライブプレビュー
it=Stato HUD:
en=HUD state:
nap=Stato HUD:
bro=Vibe HUD:
es=Estado HUD:
fr=État HUD :
de=HUD-Status:
pt=Estado do HUD:
ru=Статус HUD:
ko=HUD 상태:
zh=HUD 状态:
ja=HUD状態:
it=ON (attivo)
en=ON (active)
nap=ON (appicciato)
bro=ON (acceso)
es=ON (activo)
fr=ON (actif)
de=ON (aktiv)
pt=ON (ativo)
ru=ON (активно)
ko=ON (활성)
zh=ON (激活)
ja=ON (有効)
it=OFF (inattivo)
en=OFF (idle)
nap=OFF (stutato)
bro=OFF (chill)
es=OFF (inactivo)
fr=OFF (inactif)
de=OFF (inaktiv)
pt=OFF (inativo)
ru=OFF (неактивно)
ko=OFF (비활성)
zh=OFF (未激活)
ja=OFF (無効)
it=Altro
en=Other
nap=Ato
bro=Roba varia
es=Otros
fr=Autre
de=Sonstiges
pt=Outros
ru=Прочее
ko=기타
zh=其他
ja=その他
it=Impostazioni della CONFIG non ancora catalogate nei menu.
en=CONFIG settings not listed in the menus yet.
nap=Mpustaziune d'a CONFIG ca nun stanno ancora dint'ê menù.
bro=Settaggi della CONFIG che non stanno ancora nei menu.
es=Ajustes de la CONFIG que aún no están en los menús.
fr=Paramètres de la CONFIG pas encore classés dans les menus.
de=CONFIG-Einstellungen, die noch nicht in den Menüs stehen.
pt=Configurações da CONFIG ainda não catalogadas nos menus.
ru=Настройки CONFIG, ещё не внесённые в меню.
ko=아직 메뉴에 분류되지 않은 CONFIG 설정이에요.
zh=尚未归入菜单的 CONFIG 设置。
ja=メニューに未分類の CONFIG 設定です。
it=Impostazione
en=Setting
nap=Mpustazione
bro=Settaggio
es=Ajuste
fr=Paramètre
de=Einstellung
pt=Configuração
ru=Настройка
ko=설정
zh=设置项
ja=設定
it=Valore
en=Value
nap=Valore
bro=Valore
es=Valor
fr=Valeur
de=Wert
pt=Valor
ru=Значение
ko=값
zh=值
ja=値
it=Variabile
en=Variable
nap=Variabile
bro=Variabile
es=Variable
fr=Variable
de=Variable
pt=Variável
ru=Переменная
ko=변수
zh=变量
ja=変数
it=VALORE
en=VALUE
nap=VALORE
bro=VALORE
es=VALOR
fr=VALEUR
de=WERT
pt=VALOR
ru=ЗНАЧЕНИЕ
ko=값
zh=值
ja=値
it=Attivo
en=Enabled
nap=Appicciato
bro=Acceso
es=Activo
fr=Activé
de=Aktiv
pt=Ativo
ru=Включено
ko=활성
zh=已启用
ja=有効
it=Scrivi un valore preciso...
en=Type an exact value...
nap=Scrive nu valore preciso...
bro=Scrivi il valore preciso...
es=Escribe un valor exacto...
fr=Saisir une valeur...
de=Genauen Wert eingeben...
pt=Digitar um valor exato...
ru=Ввести значение...
ko=값 직접 입력...
zh=输入精确数值...
ja=値を入力...
it=Scegli colore...
en=Pick color...
nap=Scigli 'o culore...
bro=Scegli il colore...
es=Elige un color...
fr=Choisir couleur...
de=Farbe wählen...
pt=Escolher cor...
ru=Выбрать цвет...
ko=색상 선택...
zh=选择颜色...
ja=色を選択...
it=Valore originale
en=Original value
nap=Valore 'e primma
bro=Valore OG
es=Valor original
fr=Valeur d'origine
de=Originalwert
pt=Valor original
ru=Исходное значение
ko=원래 값
zh=原始值
ja=元の値
it=ESEMPIO
en=EXAMPLE
nap=ESEMPIO
bro=TIPO COSÌ
es=EJEMPLO
fr=EXEMPLE
de=BEISPIEL
pt=EXEMPLO
ru=ПРИМЕР
ko=예시
zh=示例
ja=例
it=Nome boss
en=Boss name
nap=Nomme d'o boss
bro=Nome boss
es=Nombre del boss
fr=Nom du boss
de=Boss-Name
pt=Nome do boss
ru=Имя босса
ko=보스 이름
zh=首领名称
ja=ボス名
it=Grado
en=Grade
nap=Grado
bro=Rarità
es=Grado
fr=Grade
de=Rang
pt=Grau
ru=Ранг
ko=등급
zh=等级
ja=グレード
it=Importanza
en=Importance
nap=Importanza
bro=Hype
es=Importancia
fr=Importance
de=Wichtigkeit
pt=Importância
ru=Важность
ko=중요도
zh=重要度
ja=重要度
it=Nome
en=Name
nap=Nomme
bro=Nome
es=Nombre
fr=Nom
de=Name
pt=Nome
ru=Имя
ko=이름
zh=名称
ja=名前
it=Imp.
en=Imp.
nap=Imp.
bro=Hype
es=Imp.
fr=Imp.
de=Wicht.
pt=Imp.
ru=Важн.
ko=중요
zh=重要
ja=重要
it=nessuna
en=none
nap=nisciuna
bro=zero
es=ninguna
fr=aucune
de=keine
pt=nenhuma
ru=нет
ko=없음
zh=无
ja=なし
it=massima
en=top
nap='a cchiù auta
bro=GOAT
es=máxima
fr=maximale
de=höchste
pt=máxima
ru=макс.
ko=최상
zh=最高
ja=最高
it=superiore
en=superior
nap=superiore
bro=top
es=superior
fr=supérieure
de=höhere
pt=superior
ru=высокая
ko=상위
zh=较高
ja=高
it=importante
en=important
nap=mpurtante
bro=forte
es=importante
fr=importante
de=wichtig
pt=importante
ru=важная
ko=중요
zh=重要
ja=中
it=minore
en=minor
nap=minore
bro=mid
es=menor
fr=mineure
de=geringe
pt=menor
ru=малая
ko=하위
zh=次要
ja=低
it=+ Aggiungi boss
en=+ Add boss
nap=+ Miette boss
bro=+ Aggiungi boss
es=+ Añadir boss
fr=+ Ajouter un boss
de=+ Boss hinzufügen
pt=+ Adicionar boss
ru=+ Добавить босса
ko=+ 보스 추가
zh=+ 添加首领
ja=+ ボス追加
it=- Rimuovi boss
en=- Remove boss
nap=- Leva boss
bro=- Leva boss
es=- Quitar boss
fr=- Retirer un boss
de=- Boss entfernen
pt=- Remover boss
ru=- Убрать босса
ko=- 보스 제거
zh=- 移除首领
ja=- ボス削除
it=Grado = colore della prima icona dei drop.  Importanza = simbolo nel pannello.\nScrivi il nome intero come in gioco (anche se il gioco lo tronca con "..."). Il pannello li ordina dalla A alla Z.
en=Grade = color of the first drop icon.  Importance = symbol in the panel.\nWrite the full name as shown in game (even if the game cuts it with "..."). The panel sorts them from A to Z.
nap=Grado = culore d'a primma icona d'e drop.  Importanza = simbolo dint'ô pannello.\nScrive 'o nomme sano comme int'ô juoco (pure si 'o juoco 'o taglia cu "..."). 'O pannello 'e mette 'a A a Z.
bro=Rarità = colore della prima icona dei drop.  Hype = simbolo nel pannello.\nScrivi il nome intero come nel gioco (anche se il gioco lo taglia con "..."). Il pannello li mette in ordine dalla A alla Z, ez.
es=Grado = color del primer icono de drops.  Importancia = símbolo en el panel.\nEscribe el nombre completo como aparece en el juego (aunque el juego lo corte con "..."). El panel los ordena de la A a la Z.
fr=Grade = couleur de la première icône de butin.  Importance = symbole dans le panneau.\nÉcris le nom complet comme dans le jeu (même si le jeu le coupe avec "..."). Le panneau les trie de A à Z.
de=Rang = Farbe des ersten Drop-Symbols.  Wichtigkeit = Symbol im Panel.\nSchreibe den vollständigen Namen wie im Spiel (auch wenn das Spiel ihn mit "..." kürzt). Das Panel sortiert sie von A bis Z.
pt=Grau = cor do primeiro ícone de drop.  Importância = símbolo no painel.\nEscreva o nome completo como aparece no jogo (mesmo que o jogo o corte com "..."). O painel os ordena de A a Z.
ru=Ранг = цвет первой иконки дропа.  Важность = символ на панели.\nВведите полное имя, как в игре (даже если игра обрезает его до "..."). Панель сортирует их от A до Z.
ko=등급 = 첫 번째 드롭 아이콘의 색상.  중요도 = 패널에 표시되는 기호.\n게임에 표시되는 전체 이름을 그대로 입력하세요 (게임에서 "..."로 잘려 보여도 마찬가지예요). 패널은 A부터 Z 순으로 정렬해요.
zh=等级 = 第一个掉落图标的颜色。  重要度 = 面板中的符号。\n请填写游戏中显示的完整名称(即使游戏用 "..." 截断)。面板按 A 到 Z 排序。
ja=グレード = 最初のドロップアイコンの色。  重要度 = パネル内の記号。\nゲーム内の表示どおりに正式名を入力してください ("..." で省略されていても同様)。パネルは A から Z の順に並べます。
it=Tipo
en=Type
nap=Tipo
bro=Tipo
es=Tipo
fr=Type
de=Typ
pt=Tipo
ru=Тип
ko=유형
zh=类型
ja=種類
it=Dettagli
en=Details
nap=Dettaglie
bro=Info
es=Detalles
fr=Détails
de=Details
pt=Detalhes
ru=Подробности
ko=상세
zh=详情
ja=詳細
it=Applica preset
en=Apply preset
nap=Mette 'o preset
bro=Droppa il preset
es=Aplicar preset
fr=Appliquer preset
de=Preset anwenden
pt=Aplicar preset
ru=Применить пресет
ko=프리셋 적용
zh=应用预设
ja=プリセット適用
)" "`n"
        s .= "
(
it=Salva le impostazioni attuali come preset...
en=Save current settings as preset...
nap=Sarva 'e mpustaziune 'e mo comme preset...
bro=Salva i settaggi di adesso come preset...
es=Guardar los ajustes actuales como preset...
fr=Enregistrer les paramètres actuels comme preset...
de=Aktuelle Einstellungen als Preset speichern...
pt=Salvar configurações atuais como preset...
ru=Сохранить текущие настройки как пресет...
ko=현재 설정을 프리셋으로 저장...
zh=将当前设置保存为预设...
ja=現在の設定をプリセットとして保存...
it=Elimina preset
en=Delete preset
nap=Scancella preset
bro=Bomba il preset
es=Eliminar preset
fr=Supprimer preset
de=Preset löschen
pt=Excluir preset
ru=Удалить пресет
ko=프리셋 삭제
zh=删除预设
ja=プリセット削除
it=Vedi modifiche
en=View changes
nap=Vide cagnamiente
bro=Vedi i cambi
es=Ver cambios
fr=Voir changements
de=Änderungen zeigen
pt=Ver mudanças
ru=Показать правки
ko=변경 보기
zh=查看修改
ja=変更を確認
it=Salva e riavvia
en=Save and restart
nap=Sarva e riparte
bro=Salva e riparti
es=Guardar y reiniciar
fr=Sauver et relancer
de=Speichern+Neustart
pt=Salvar e reiniciar
ru=Сохр. и рестарт
ko=저장 후 재시작
zh=保存并重启
ja=保存して再起動
it=Annulla modifiche
en=Discard changes
nap=Leva 'e cagnamiente
bro=Butta i cambi
es=Descartar cambios
fr=Annuler changements
de=Verwerfen
pt=Descartar mudanças
ru=Отменить изменения
ko=변경 취소
zh=放弃修改
ja=変更を破棄
it=Apri il file
en=Open file
nap=Arape 'o file
bro=Apri il file
es=Abrir archivo
fr=Ouvrir le fichier
de=Datei öffnen
pt=Abrir arquivo
ru=Открыть файл
ko=파일 열기
zh=打开文件
ja=ファイルを開く
it=Chiudi
en=Close
nap=Chiure
bro=Chiudi
es=Cerrar
fr=Fermer
de=Schließen
pt=Fechar
ru=Закрыть
ko=닫기
zh=关闭
ja=閉じる
it=Configurazioni pronte da applicare. I preset di risoluzione riscalano tutte le misure in px dell'HUD (mirino, barre, icone, effetti); Field Boss e Hidden Cube si adattano già da soli.
en=Ready-made configurations. Resolution presets rescale every HUD size in px (crosshair, bars, icons, effects); Field Boss and Hidden Cube already adapt on their own.
nap=Configuraziune pronte pe' essere mise. 'E preset 'e risoluzione riscalano tutte 'e misure in px 'e ll'HUD (mirino, barre, icone, effette); Field Boss e Hidden Cube s'adattano già 'a sule.
bro=Config già pronte, le droppi e via. I preset di risoluzione riscalano tutte le misure in px dell'HUD (mirino, barre, icone, effetti); Field Boss e Hidden Cube si adattano da soli, ez.
es=Configuraciones listas para aplicar. Los presets de resolución reescalan todas las medidas en px del HUD (mira, barras, iconos, efectos); Field Boss y Hidden Cube ya se adaptan solos.
fr=Configurations prêtes à appliquer. Les presets de résolution redimensionnent toutes les mesures en px du HUD (viseur, barres, icônes, effets) ; Field Boss et Hidden Cube s'adaptent déjà tout seuls.
de=Fertige Konfigurationen zum Anwenden. Die Auflösungs-Presets skalieren alle px-Maße des HUD (Fadenkreuz, Balken, Symbole, Effekte); Field Boss und Hidden Cube passen sich schon von selbst an.
pt=Configurações prontas para aplicar. Os presets de resolução reescalam todas as medidas em px do HUD (mira, barras, ícones, efeitos); Field Boss e Hidden Cube já se adaptam sozinhos.
ru=Готовые конфигурации. Пресеты разрешения масштабируют все размеры HUD в px (прицел, полосы, иконки, эффекты); Field Boss и Hidden Cube подстраиваются сами.
ko=바로 적용할 수 있는 기본 구성이에요. 해상도 프리셋은 HUD의 모든 px 크기(조준선, 바, 아이콘, 효과)를 비율에 맞게 조정해요. Field Boss와 Hidden Cube는 알아서 맞춰져요.
zh=现成的配置,可直接应用。分辨率预设会按比例缩放 HUD 所有以 px 为单位的尺寸(准星、条、图标、特效);Field Boss 和 Hidden Cube 本身已能自动适配。
ja=すぐに使える設定セットです。解像度プリセットは HUD の px サイズ (照準、バー、アイコン、エフェクト) をすべて再計算します。Field Boss と Hidden Cube は自動で調整されます。
it=Boss di Altgard mostrati nel pannello Field Boss. Seleziona una riga per modificarla.
en=Altgard bosses shown in the Field Boss panel. Select a row to edit it.
nap='E boss 'e Altgard ca se vedono dint'ô pannello Field Boss. Scigli na riga pe' 'a cagnà.
bro=I boss di Altgard che vedi nel pannello Field Boss. Seleziona una riga per cambiarla bro.
es=Bosses de Altgard mostrados en el panel Field Boss. Selecciona una fila para editarla.
fr=Boss d'Altgard affichés dans le panneau Field Boss. Sélectionne une ligne pour la modifier.
de=Altgard-Bosse, die im Field Boss Panel angezeigt werden. Wähle eine Zeile, um sie zu bearbeiten.
pt=Bosses de Altgard mostrados no painel Field Boss. Selecione uma linha para editá-la.
ru=Боссы Altgard на панели Field Boss. Выберите строку, чтобы изменить её.
ko=Altgard 보스가 Field Boss 패널에 표시돼요. 행을 선택해 수정하세요.
zh=Altgard 的首领会显示在 Field Boss 面板中。选择一行即可编辑。
ja=Altgard のボスを Field Boss パネルに表示します。行を選択して編集できます。
it=Valore {1} impostato dal profilo "{2}".\nPer cambiarlo a mano scegli il profilo "manuale".
en=Value {1} set by the "{2}" profile.\nTo change it by hand choose the "manuale" profile.
nap=Valore {1} miso d'o prufilo "{2}".\nPe' 'o cagnà a mano scigli 'o prufilo "manuale".
bro=Valore {1} messo dal profilo "{2}".\nSe lo vuoi cambiare a mano metti il profilo "manuale" fra.
es=Valor {1} establecido por el perfil "{2}".\nPara cambiarlo a mano elige el perfil "manuale".
fr=Valeur {1} définie par le profil "{2}".\nPour la changer à la main, choisis le profil "manuale".
de=Wert {1} vom Profil "{2}" gesetzt.\nUm ihn von Hand zu ändern, wähle das Profil "manuale".
pt=Valor {1} definido pelo perfil "{2}".\nPara mudá-lo manualmente escolha o perfil "manuale".
ru=Значение {1} задано профилем "{2}".\nЧтобы изменить его вручную, выберите профиль "manuale".
ko=값 {1}은(는) "{2}" 프로필에서 설정됐어요.\n직접 바꾸려면 "manuale" 프로필을 선택하세요.
zh=数值 {1} 由配置档 "{2}" 设定。\n如需手动修改,请选择配置档 "manuale"。
ja=値 {1} はプロファイル "{2}" で設定されています。\n手動で変更するにはプロファイル "manuale" を選択してください。
it=Errore nella modifica:
en=Error while editing:
nap=Sbaglio dint'ô cagnamiento:
bro=Errore nel cambio, sus:
es=Error al editar:
fr=Erreur lors de la modification :
de=Fehler beim Bearbeiten:
pt=Erro ao editar:
ru=Ошибка при изменении:
ko=수정 중 오류:
zh=修改时出错:
ja=編集中にエラーが発生しました:
it=Nuovo valore per "{1}"
en=New value for "{1}"
nap=Valore nuovo pe' "{1}"
bro=Nuovo valore per "{1}"
es=Nuevo valor para "{1}"
fr=Nouvelle valeur pour "{1}"
de=Neuer Wert für "{1}"
pt=Novo valor para "{1}"
ru=Новое значение для "{1}"
ko="{1}"의 새 값
zh="{1}" 的新值
ja="{1}" の新しい値
it=Valore non accettato: {1}.
en=Value not accepted: {1}.
nap=Valore nun accettato: {1}.
bro=Valore rifiutato bro: {1}.
es=Valor no aceptado: {1}.
fr=Valeur refusée : {1}.
de=Wert nicht akzeptiert: {1}.
pt=Valor não aceito: {1}.
ru=Значение не принято: {1}.
ko=허용되지 않는 값: {1}.
zh=数值不被接受:{1}。
ja=値が受け付けられません: {1}。
it=Valore non valido:
en=Invalid value:
nap=Valore ca nun va bbuono:
bro=Valore cringe:
es=Valor no válido:
fr=Valeur invalide :
de=Ungültiger Wert:
pt=Valor inválido:
ru=Недопустимое значение:
ko=잘못된 값:
zh=无效的值:
ja=無効な値:
it=ATTIVO
en=ENABLED
nap=APPICCIATO
bro=ACCESO
es=ACTIVADO
fr=ACTIVÉ
de=AKTIV
pt=ATIVADO
ru=ВКЛЮЧЕНО
ko=활성화
zh=已启用
ja=有効
it=DISATTIVATO
en=DISABLED
nap=STUTATO
bro=SPENTO
es=DESACTIVADO
fr=DÉSACTIVÉ
de=DEAKTIVIERT
pt=DESATIVADO
ru=ВЫКЛЮЧЕНО
ko=비활성화
zh=已禁用
ja=無効
it=(nessun tasto)
en=(no key)
nap=(nisciuno tasto)
bro=(zero tasti)
es=(sin tecla)
fr=(aucune touche)
de=(keine Taste)
pt=(sem tecla)
ru=(нет клавиши)
ko=(키 없음)
zh=(无按键)
ja=(キーなし)
it=Colore non valido
en=Invalid color
nap=Culore ca nun va bbuono
bro=Colore sus
es=Color no válido
fr=Couleur invalide
de=Ungültige Farbe
pt=Cor inválida
ru=Недопустимый цвет
ko=잘못된 색상
zh=无效的颜色
ja=無効な色
it=HUD {1} fps · Cubo {2} ms · Mappa {3} ms\nClick {4} ms · Blocco {5} ms · OCR {6}
en=HUD {1} fps · Cube {2} ms · Map {3} ms\nClick {4} ms · Lock {5} ms · OCR {6}
nap=HUD {1} fps · Cubo {2} ms · Mappa {3} ms\nClick {4} ms · Blocco {5} ms · OCR {6}
bro=HUD {1} fps · Cubo {2} ms · Mappa {3} ms\nClick {4} ms · Lock {5} ms · OCR {6}
es=HUD {1} fps · Cubo {2} ms · Mapa {3} ms\nClic {4} ms · Bloqueo {5} ms · OCR {6}
fr=HUD {1} fps · Cube {2} ms · Carte {3} ms\nClic {4} ms · Verrou {5} ms · OCR {6}
de=HUD {1} fps · Cube {2} ms · Karte {3} ms\nKlick {4} ms · Sperre {5} ms · OCR {6}
pt=HUD {1} fps · Cubo {2} ms · Mapa {3} ms\nClique {4} ms · Trava {5} ms · OCR {6}
ru=HUD {1} fps · Куб {2} ms · Карта {3} ms\nКлик {4} ms · Блок {5} ms · OCR {6}
ko=HUD {1} fps · 큐브 {2} ms · 지도 {3} ms\n클릭 {4} ms · 잠금 {5} ms · OCR {6}
zh=HUD {1} fps · Cube {2} ms · 地图 {3} ms\n点击 {4} ms · 锁定 {5} ms · OCR {6}
ja=HUD {1} fps · キューブ {2} ms · マップ {3} ms\nクリック {4} ms · ロック {5} ms · OCR {6}
it=Nessun effetto
en=No effect
nap=Nisciuno effetto
bro=Zero effetti
es=Sin efecto
fr=Aucun effet
de=Kein Effekt
pt=Nenhum efeito
ru=Без эффекта
ko=효과 없음
zh=无特效
ja=エフェクトなし
it={1}% opaco
en={1}% opaque
nap={1}% opaco
bro={1}% opaco
es={1}% opaco
fr={1}% opaque
de={1}% deckend
pt={1}% opaco
ru={1}% непрозрачности
ko={1}% 불투명
zh=不透明度 {1}%
ja=不透明度 {1}%
it={1}% di intensità
en={1}% intensity
nap={1}% 'e forza
bro={1}% di potenza
es={1}% de intensidad
fr={1}% d'intensité
de={1}% Intensität
pt={1}% de intensidade
ru={1}% интенсивности
ko=강도 {1}%
zh=强度 {1}%
ja=強度 {1}%
)" "`n"
        s .= "
(
it={1}% della grandezza normale
en={1}% of normal size
nap={1}% d'a grandezza normale
bro={1}% della size normale
es={1}% del tamaño normal
fr={1}% de la taille normale
de={1}% der Normalgröße
pt={1}% do tamanho normal
ru={1}% от обычного размера
ko=기본 크기의 {1}%
zh=正常大小的 {1}%
ja=通常サイズの {1}%
it=(misurati a 1440p)
en=(measured at 1440p)
nap=(misurate a 1440p)
bro=(misurati a 1440p)
es=(medidos a 1440p)
fr=(mesurées en 1440p)
de=(gemessen bei 1440p)
pt=(medidos em 1440p)
ru=(замеры в 1440p)
ko=(1440p 기준 측정값)
zh=(按 1440p 测量)
ja=(1440pで計測)
it=(misurati in 4K)
en=(measured in 4K)
nap=(misurate in 4K)
bro=(misurati in 4K)
es=(medidos en 4K)
fr=(mesurées en 4K)
de=(gemessen in 4K)
pt=(medidos em 4K)
ru=(замеры в 4K)
ko=(4K 기준 측정값)
zh=(按 4K 测量)
ja=(4Kで計測)
it=Predefinito
en=Built-in
nap='E fabbrica
bro=Di base
es=Predefinido
fr=Par défaut
de=Standard
pt=Padrão
ru=Встроенный
ko=기본 제공
zh=内置
ja=標準
it=risoluzione attuale dei valori HUD
en=current resolution of the HUD values
nap=risoluzione 'e mo d'e valure HUD
bro=risoluzione attuale dei valori HUD
es=resolución actual de los valores del HUD
fr=résolution actuelle des valeurs du HUD
de=aktuelle Auflösung der HUD-Werte
pt=resolução atual dos valores do HUD
ru=текущее разрешение значений HUD
ko=현재 HUD 값의 해상도
zh=HUD 数值的当前分辨率
ja=HUD 値の現在の解像度
it=HUD riscalato da {1}p a {2}p
en=HUD rescaled from {1}p to {2}p
nap=HUD riscalato 'a {1}p a {2}p
bro=HUD riscalato da {1}p a {2}p
es=HUD reescalado de {1}p a {2}p
fr=HUD redimensionné de {1}p à {2}p
de=HUD von {1}p auf {2}p skaliert
pt=HUD reescalado de {1}p para {2}p
ru=HUD масштабирован с {1}p до {2}p
ko=HUD를 {1}p에서 {2}p로 조정함
zh=HUD 已从 {1}p 缩放到 {2}p
ja=HUD を {1}p から {2}p に再計算しました
it=Personalizzato
en=Custom
nap=Fatto 'a te
bro=Custom
es=Personalizado
fr=Personnalisé
de=Eigene
pt=Personalizado
ru=Свой
ko=사용자 지정
zh=自定义
ja=カスタム
it=salvato il {1}
en=saved on {1}
nap=sarvato 'o {1}
bro=salvato il {1}
es=guardado el {1}
fr=enregistré le {1}
de=gespeichert am {1}
pt=salvo em {1}
ru=сохранено {1}
ko={1}에 저장됨
zh=保存于 {1}
ja={1} に保存
it=Doppio click o "Applica preset" per caricarlo: i valori cambiati compaiono come modifiche (vedi "Vedi modifiche") e con l'anteprima dal vivo li vedi subito. Diventano definitivi con "Salva e riavvia".\nI preset personalizzati salvano tutte le impostazioni (non l'elenco boss) nel file "AION 2 Wingman - preset.ini" accanto allo script.
en=Double-click or "Apply preset" to load it: the changed values show up as edits (see "View changes") and with the live preview you see them right away. They become final with "Save and restart".\nCustom presets store all settings (not the boss list) in the file "AION 2 Wingman - preset.ini" next to the script.
nap=Doppio click o "Mette 'o preset" pe' 'o caricà: 'e valure cagnate compareno comme cagnamiente (vide "Vide cagnamiente") e cu ll'anteprima 'n diretta 'e vide subbito. Addeventano definitive cu "Sarva e riparte".\n'E preset fatte 'a te sarvano tutte 'e mpustaziune (no 'a lista d'e boss) dint'ô file "AION 2 Wingman - preset.ini" vicino a 'o script.
bro=Doppio click o "Droppa il preset" per caricarlo: i valori cambiati escono come modifiche (vedi "Vedi i cambi") e con la preview live li vedi subito. Diventano definitivi con "Salva e riparti".\nI preset custom salvano tutti i settaggi (non la lista boss) nel file "AION 2 Wingman - preset.ini" vicino allo script.
es=Doble clic o "Aplicar preset" para cargarlo: los valores cambiados aparecen como modificaciones (ver "Ver cambios") y con la vista previa en vivo los ves al instante. Se vuelven definitivos con "Guardar y reiniciar".\nLos presets personalizados guardan todos los ajustes (no la lista de bosses) en el archivo "AION 2 Wingman - preset.ini" junto al script.
fr=Double-clic ou "Appliquer preset" pour le charger : les valeurs modifiées apparaissent comme changements (voir "Voir changements") et avec l'aperçu en direct tu les vois tout de suite. Elles deviennent définitives avec "Sauver et relancer".\nLes presets personnalisés enregistrent tous les paramètres (pas la liste des boss) dans le fichier "AION 2 Wingman - preset.ini" à côté du script.
de=Doppelklick oder "Preset anwenden" zum Laden: Die geänderten Werte erscheinen als Änderungen (siehe "Änderungen zeigen") und mit der Live-Vorschau siehst du sie sofort. Endgültig werden sie mit "Speichern+Neustart".\nEigene Presets speichern alle Einstellungen (nicht die Boss-Liste) in der Datei "AION 2 Wingman - preset.ini" neben dem Skript.
pt=Clique duplo ou "Aplicar preset" para carregá-lo: os valores alterados aparecem como mudanças (veja "Ver mudanças") e com a prévia ao vivo você os vê na hora. Ficam definitivos com "Salvar e reiniciar".\nOs presets personalizados salvam todas as configurações (não a lista de bosses) no arquivo "AION 2 Wingman - preset.ini" ao lado do script.
ru=Дважды кликните или нажмите "Применить пресет", чтобы загрузить его: изменённые значения появятся как правки (см. "Показать правки"), а с предпросмотром вы сразу увидите результат. Окончательными они станут после "Сохр. и рестарт".\nСвои пресеты сохраняют все настройки (кроме списка боссов) в файл "AION 2 Wingman - preset.ini" рядом со скриптом.
ko=더블클릭하거나 "프리셋 적용"을 눌러 불러오세요. 바뀐 값은 변경 사항으로 표시되고("변경 보기" 참고), 실시간 미리보기로 바로 확인할 수 있어요. "저장 후 재시작"을 누르면 확정돼요.\n사용자 지정 프리셋은 모든 설정(보스 목록 제외)을 스크립트 옆의 "AION 2 Wingman - preset.ini" 파일에 저장해요.
zh=双击或点击 "应用预设" 即可加载:更改的值会显示为修改项(见 "查看修改"),配合实时预览可立即看到效果。点击 "保存并重启" 后才会正式生效。\n自定义预设会把所有设置(不含首领列表)保存到脚本旁的文件 "AION 2 Wingman - preset.ini" 中。
ja=ダブルクリックまたは "プリセット適用" で読み込みます。変更された値は修正として表示され ("変更を確認" を参照)、ライブプレビューですぐ確認できます。"保存して再起動" で確定します。\nカスタムプリセットは全設定 (ボスリストを除く) をスクリプトの隣の "AION 2 Wingman - preset.ini" に保存します。
it=Preset "{1}" applicato: {2} valore cambiato.
en=Preset "{1}" applied: {2} value changed.
nap=Preset "{1}" miso: {2} valore cagnato.
bro=Preset "{1}" droppato: {2} valore cambiato.
es=Preset "{1}" aplicado: {2} valor cambiado.
fr=Preset "{1}" appliqué : {2} valeur modifiée.
de=Preset "{1}" angewendet: {2} Wert geändert.
pt=Preset "{1}" aplicado: {2} valor alterado.
ru=Пресет "{1}" применён: изменено значений: {2}.
ko=프리셋 "{1}" 적용됨: 값 {2}개 변경.
zh=预设 "{1}" 已应用:{2} 个值已更改。
ja=プリセット "{1}" を適用しました: {2}件の値が変更されました。
it=Preset "{1}" applicato: {2} valori cambiati.
en=Preset "{1}" applied: {2} values changed.
nap=Preset "{1}" miso: {2} valure cagnate.
bro=Preset "{1}" droppato: {2} valori cambiati.
es=Preset "{1}" aplicado: {2} valores cambiados.
fr=Preset "{1}" appliqué : {2} valeurs modifiées.
de=Preset "{1}" angewendet: {2} Werte geändert.
pt=Preset "{1}" aplicado: {2} valores alterados.
ru=Пресет "{1}" применён: изменено значений: {2}.
ko=프리셋 "{1}" 적용됨: 값 {2}개 변경.
zh=预设 "{1}" 已应用:{2} 个值已更改。
ja=プリセット "{1}" を適用しました: {2}件の値が変更されました。
it=Premi "Salva e riavvia" per renderlo definitivo.
en=Press "Save and restart" to make it final.
nap=Premme "Sarva e riparte" pe' 'o fa' definitivo.
bro=Premi "Salva e riparti" per bloccarlo bro.
es=Pulsa "Guardar y reiniciar" para hacerlo definitivo.
fr=Appuie sur "Sauver et relancer" pour le rendre définitif.
de=Drücke "Speichern+Neustart", um es endgültig zu machen.
pt=Pressione "Salvar e reiniciar" para torná-lo definitivo.
ru=Нажмите "Сохр. и рестарт", чтобы закрепить.
ko=확정하려면 "저장 후 재시작"을 누르세요.
zh=点击 "保存并重启" 使其正式生效。
ja="保存して再起動" を押すと確定します。
it=Nome del nuovo preset (es. "Il mio 4K"):
en=Name of the new preset (e.g. "My 4K"):
nap=Nomme d'o preset nuovo (p'esempio "'O 4K mio"):
bro=Nome del nuovo preset (tipo "Il mio 4K"):
es=Nombre del nuevo preset (p. ej. "Mi 4K"):
fr=Nom du nouveau preset (ex. "Mon 4K") :
de=Name des neuen Presets (z. B. "Mein 4K"):
pt=Nome do novo preset (ex.: "Meu 4K"):
ru=Название нового пресета (напр. "Мой 4K"):
ko=새 프리셋 이름 (예: "내 4K"):
zh=新预设名称(例如 "我的 4K"):
ja=新しいプリセットの名前 (例: "My 4K"):
it=Questo nome è già usato da un preset predefinito.
en=This name is already used by a built-in preset.
nap=Chisto nomme 'o tene già nu preset 'e fabbrica.
bro=Questo nome ce l'ha già un preset di base, cambia fra.
es=Este nombre ya lo usa un preset predefinido.
fr=Ce nom est déjà utilisé par un preset par défaut.
de=Dieser Name wird schon von einem Standard-Preset verwendet.
pt=Esse nome já é usado por um preset padrão.
ru=Это имя уже занято встроенным пресетом.
ko=이미 기본 제공 프리셋에서 사용 중인 이름이에요.
zh=该名称已被内置预设使用。
ja=この名前は標準プリセットで使用されています。
it=Esiste già un preset "{1}". Sovrascriverlo?
en=A preset "{1}" already exists. Overwrite it?
nap=Ce sta già nu preset "{1}". 'O scrivo 'ncoppa?
bro=C'è già un preset "{1}". Lo sovrascrivo?
es=Ya existe un preset "{1}". ¿Quieres sobrescribirlo?
fr=Un preset "{1}" existe déjà. Le remplacer ?
de=Es gibt schon ein Preset "{1}". Überschreiben?
pt=Já existe um preset "{1}". Sobrescrever?
ru=Пресет "{1}" уже существует. Перезаписать?
ko="{1}" 프리셋이 이미 있어요. 덮어쓸까요?
zh=预设 "{1}" 已存在。要覆盖吗?
ja=プリセット "{1}" は既に存在します。上書きしますか?
)" "`n"
        s .= "
(
it=Salvataggio del preset non riuscito:
en=Saving the preset failed:
nap='O preset nun s'è pututo sarvà:
bro=Salvataggio del preset fallito, rip:
es=No se pudo guardar el preset:
fr=Échec de l'enregistrement du preset :
de=Speichern des Presets fehlgeschlagen:
pt=Falha ao salvar o preset:
ru=Не удалось сохранить пресет:
ko=프리셋 저장에 실패했어요:
zh=预设保存失败:
ja=プリセットの保存に失敗しました:
it=I preset predefiniti non si possono eliminare.
en=Built-in presets cannot be deleted.
nap='E preset 'e fabbrica nun se ponno scancellà.
bro=I preset di base non si toccano bro.
es=Los presets predefinidos no se pueden eliminar.
fr=Les presets par défaut ne peuvent pas être supprimés.
de=Standard-Presets können nicht gelöscht werden.
pt=Os presets padrão não podem ser excluídos.
ru=Встроенные пресеты нельзя удалить.
ko=기본 제공 프리셋은 삭제할 수 없어요.
zh=内置预设无法删除。
ja=標準プリセットは削除できません。
it=Eliminare il preset "{1}"?
en=Delete the preset "{1}"?
nap=Scancello 'o preset "{1}"?
bro=Bombo il preset "{1}"?
es=¿Eliminar el preset "{1}"?
fr=Supprimer le preset "{1}" ?
de=Preset "{1}" löschen?
pt=Excluir o preset "{1}"?
ru=Удалить пресет "{1}"?
ko="{1}" 프리셋을 삭제할까요?
zh=要删除预设 "{1}" 吗?
ja=プリセット "{1}" を削除しますか?
it=Nuovo boss
en=New boss
nap=Boss nuovo
bro=Boss nuovo
es=Nuevo boss
fr=Nouveau boss
de=Neuer Boss
pt=Novo boss
ru=Новый босс
ko=새 보스
zh=新首领
ja=新規ボス
it=Rimuovere "{1}" dall'elenco?
en=Remove "{1}" from the list?
nap=Levo "{1}" d'a lista?
bro=Levo "{1}" dalla lista?
es=¿Quitar "{1}" de la lista?
fr=Retirer "{1}" de la liste ?
de="{1}" aus der Liste entfernen?
pt=Remover "{1}" da lista?
ru=Убрать "{1}" из списка?
ko="{1}"을(를) 목록에서 제거할까요?
zh=要从列表中移除 "{1}" 吗?
ja="{1}" をリストから削除しますか?
it=Nessuna modifica da salvare.
en=No changes to save.
nap=Nun ce sta niente 'a sarvà.
bro=Niente da salvare fra.
es=No hay cambios que guardar.
fr=Aucun changement à enregistrer.
de=Keine Änderungen zu speichern.
pt=Nenhuma mudança para salvar.
ru=Нет изменений для сохранения.
ko=저장할 변경 사항이 없어요.
zh=没有需要保存的修改。
ja=保存する変更はありません。
it=Modifiche non salvate
en=Unsaved changes
nap=Cagnamiente nun sarvate
bro=Cambi non salvati
es=Cambios sin guardar
fr=Changements non enregistrés
de=Nicht gespeicherte Änderungen
pt=Mudanças não salvas
ru=Несохранённые изменения
ko=저장되지 않은 변경 사항
zh=有未保存的修改
ja=未保存の変更
it=Valori cambiati rispetto al file. Doppio click su una riga per andare all'impostazione.
en=Values changed compared to the file. Double-click a row to go to the setting.
nap=Valure cagnate rispetto a 'o file. Doppio click 'ncopp'a na riga pe' jì â mpustazione.
bro=Valori cambiati rispetto al file. Doppio click su una riga e ci vai dritto.
es=Valores cambiados respecto al archivo. Doble clic en una fila para ir al ajuste.
fr=Valeurs modifiées par rapport au fichier. Double-clic sur une ligne pour aller au paramètre.
de=Gegenüber der Datei geänderte Werte. Doppelklick auf eine Zeile springt zur Einstellung.
pt=Valores alterados em relação ao arquivo. Clique duplo em uma linha para ir até a configuração.
ru=Значения, изменённые относительно файла. Дважды кликните по строке, чтобы перейти к настройке.
ko=파일과 비교해 바뀐 값이에요. 행을 더블클릭하면 해당 설정으로 이동해요.
zh=与文件相比已更改的值。双击某一行可跳转到对应设置。
ja=ファイルとの差異です。行をダブルクリックすると該当の設定に移動します。
it=Prima
en=Before
nap=Primma
bro=Prima
es=Antes
fr=Avant
de=Vorher
pt=Antes
ru=До
ko=이전
zh=之前
ja=変更前
it=Dopo
en=After
nap=Doppo
bro=Dopo
es=Después
fr=Après
de=Nachher
pt=Depois
ru=После
ko=이후
zh=之后
ja=変更後
it=non valido
en=invalid
nap=nun va bbuono
bro=sus
es=no válido
fr=invalide
de=ungültig
pt=inválido
ru=недопустимо
ko=잘못됨
zh=无效
ja=無効
it=Elenco boss
en=Boss list
nap=Lista d'e boss
bro=Lista boss
es=Lista de bosses
fr=Liste des boss
de=Boss-Liste
pt=Lista de bosses
ru=Список боссов
ko=보스 목록
zh=首领列表
ja=ボスリスト
it=(come nel file)
en=(as in the file)
nap=(comme int'ô file)
bro=(come nel file)
es=(como en el archivo)
fr=(comme dans le fichier)
de=(wie in der Datei)
pt=(como no arquivo)
ru=(как в файле)
ko=(파일과 동일)
zh=(与文件一致)
ja=(ファイルのまま)
it={1} boss, modificato
en={1} bosses, edited
nap={1} boss, cagnata
bro={1} boss, cambiata
es={1} bosses, modificado
fr={1} boss, modifié
de={1} Bosse, bearbeitet
pt={1} bosses, editado
ru=боссов: {1}, изменён
ko=보스 {1}개, 수정됨
zh={1} 个首领,已修改
ja=ボス {1}体、編集済み
it=Nessuna modifica
en=No changes
nap=Nisciuno cagnamiento
bro=Tutto chill
es=Sin cambios
fr=Aucun changement
de=Keine Änderungen
pt=Nenhuma mudança
ru=Нет изменений
ko=변경 사항 없음
zh=无修改
ja=変更なし
it={1} modifica non salvata
en={1} unsaved change
nap={1} cagnamiento nun sarvato
bro={1} cambio non salvato
es={1} cambio sin guardar
fr={1} changement non enregistré
de={1} nicht gespeicherte Änderung
pt={1} mudança não salva
ru=несохранённых изменений: {1}
ko=저장되지 않은 변경 {1}건
zh={1} 项修改未保存
ja=未保存の変更 {1}件
it={1} modifiche non salvate
en={1} unsaved changes
nap={1} cagnamiente nun sarvate
bro={1} cambi non salvati
es={1} cambios sin guardar
fr={1} changements non enregistrés
de={1} nicht gespeicherte Änderungen
pt={1} mudanças não salvas
ru=несохранённых изменений: {1}
ko=저장되지 않은 변경 {1}건
zh={1} 项修改未保存
ja=未保存の変更 {1}件
it="{1}": {2}.\nCorreggilo prima di salvare.
en="{1}": {2}.\nFix it before saving.
nap="{1}": {2}.\nAcconcialo primma 'e sarvà.
bro="{1}": {2}.\nSistemalo prima di salvare bro.
es="{1}": {2}.\nCorrígelo antes de guardar.
fr="{1}" : {2}.\nCorrige-le avant d'enregistrer.
de="{1}": {2}.\nKorrigiere das vor dem Speichern.
pt="{1}": {2}.\nCorrija antes de salvar.
ru="{1}": {2}.\nИсправьте это перед сохранением.
ko="{1}": {2}.\n저장하기 전에 수정하세요.
zh="{1}":{2}。\n请先修正再保存。
ja="{1}": {2}。\n保存前に修正してください。
it=C'è un boss senza nome nell'elenco.
en=There is a boss with no name in the list.
nap=Ce sta nu boss senza nomme dint'â lista.
bro=C'è un boss senza nome nella lista, sus.
es=Hay un boss sin nombre en la lista.
fr=Il y a un boss sans nom dans la liste.
de=In der Liste steht ein Boss ohne Namen.
pt=Há um boss sem nome na lista.
ru=В списке есть босс без имени.
ko=목록에 이름 없는 보스가 있어요.
zh=列表中有一个首领没有名称。
ja=リストに名前のないボスがいます。
it=Salvataggio non riuscito:
en=Saving failed:
nap=Nun s'è pututo sarvà:
bro=Salvataggio fallito, rip:
es=No se pudo guardar:
fr=Échec de l'enregistrement :
de=Speichern fehlgeschlagen:
pt=Falha ao salvar:
ru=Не удалось сохранить:
ko=저장에 실패했어요:
zh=保存失败:
ja=保存に失敗しました:
it=Ci sono modifiche non salvate. Chiudere senza salvarle?
en=There are unsaved changes. Close without saving them?
nap=Ce stanno cagnamiente nun sarvate. Chiudo senza 'e sarvà?
bro=Hai cambi non salvati. Chiudo e li butto?
es=Hay cambios sin guardar. ¿Cerrar sin guardarlos?
fr=Il y a des changements non enregistrés. Fermer sans les enregistrer ?
de=Es gibt nicht gespeicherte Änderungen. Schließen, ohne zu speichern?
pt=Há mudanças não salvas. Fechar sem salvá-las?
ru=Есть несохранённые изменения. Закрыть без сохранения?
ko=저장되지 않은 변경 사항이 있어요. 저장하지 않고 닫을까요?
zh=有未保存的修改。不保存直接关闭吗?
ja=未保存の変更があります。保存せずに閉じますか?
it=Preset
en=Presets
nap=Preset
bro=Preset
es=Presets
fr=Presets
de=Presets
pt=Presets
ru=Пресеты
ko=프리셋
zh=预设
ja=プリセット
it=Generale
en=General
nap=Generale
bro=Generale
es=General
fr=Général
de=Allgemein
pt=Geral
ru=Общие
ko=일반
zh=常规
ja=一般
it=Impostazioni comuni a tutta la suite.
en=Settings shared by the whole suite.
nap=Mpustaziune ca valeno pe' tutta 'a suite.
bro=Settaggi che valgono per tutta la suite.
es=Ajustes comunes a toda la suite.
fr=Paramètres communs à toute la suite.
de=Einstellungen für die ganze Suite.
pt=Configurações comuns a toda a suite.
ru=Настройки, общие для всего набора.
ko=모든 기능에 공통으로 적용되는 설정이에요.
zh=整个套件通用的设置。
ja=スイート全体に共通の設定です。
it=Prestazioni
en=Performance
nap=Prestaziune
bro=Performance
es=Rendimiento
fr=Performances
de=Leistung
pt=Desempenho
ru=Производительность
ko=성능
zh=性能
ja=パフォーマンス
)" "`n"
        s .= "
(
it=Quanto spesso lo script controlla lo schermo e ridisegna l'HUD. Profili da "potato" (PC datati, meno CPU) a "gigachad" (PC top, tutto iperreattivo). Con "manuale" valgono i singoli valori dell'elenco.
en=How often the script checks the screen and redraws the HUD. Profiles from "potato" (old PCs, less CPU) to "gigachad" (top PCs, everything hyper-responsive). With "manuale" the single values in the list apply.
nap=Quanto spisso 'o script cuntrolla 'o schermo e ridisegna ll'HUD. Prufile 'a "potato" (PC viecchie, meno CPU) a "gigachad" (PC 'e primma categoria, tutto ca risponne subbito). Cu "manuale" valeno 'e valure singule d'a lista.
bro=Quanto spesso lo script checka lo schermo e ridisegna l'HUD. Profili da "potato" (PC vecchi, poca CPU) a "gigachad" (PC da flex, tutto iperreattivo). Con "manuale" valgono i valori singoli della lista.
es=Con qué frecuencia el script revisa la pantalla y redibuja el HUD. Perfiles desde "potato" (PC antiguos, menos CPU) hasta "gigachad" (PC top, todo hiperreactivo). Con "manuale" valen los valores individuales de la lista.
fr=À quelle fréquence le script vérifie l'écran et redessine le HUD. Profils de "potato" (vieux PC, moins de CPU) à "gigachad" (PC haut de gamme, tout ultra-réactif). Avec "manuale", ce sont les valeurs individuelles de la liste qui comptent.
de=Wie oft das Skript den Bildschirm prüft und das HUD neu zeichnet. Profile von "potato" (alte PCs, weniger CPU) bis "gigachad" (Top-PCs, alles hyperreaktiv). Bei "manuale" gelten die einzelnen Werte der Liste.
pt=Com que frequência o script verifica a tela e redesenha o HUD. Perfis de "potato" (PCs antigos, menos CPU) a "gigachad" (PCs topo de linha, tudo hiper-reativo). Com "manuale" valem os valores individuais da lista.
ru=Как часто скрипт проверяет экран и перерисовывает HUD. Профили от "potato" (старые ПК, меньше нагрузка на CPU) до "gigachad" (мощные ПК, всё сверхотзывчиво). С "manuale" действуют отдельные значения из списка.
ko=스크립트가 화면을 확인하고 HUD를 다시 그리는 빈도예요. "potato"(오래된 PC, CPU 부담 적음)부터 "gigachad"(고사양 PC, 모든 것이 초고반응)까지 있어요. "manuale"에서는 목록의 개별 값이 적용돼요.
zh=脚本检查屏幕和重绘 HUD 的频率。配置档从 "potato"(老旧电脑,占用 CPU 少)到 "gigachad"(顶配电脑,一切极速响应)。选择 "manuale" 时,以列表中的单项数值为准。
ja=スクリプトが画面を確認して HUD を再描画する頻度です。プロファイルは "potato" (古いPC、CPU負荷小) から "gigachad" (ハイエンドPC、すべてが超高反応) まで。"manuale" では一覧の個別の値が適用されます。
it=Tasti
en=Keys
nap=Taste
bro=Tasti
es=Teclas
fr=Touches
de=Tasten
pt=Teclas
ru=Клавиши
ko=키
zh=按键
ja=キー
it=Tutti i tasti in un unico posto.  ^ = Ctrl   + = Shift   ! = Alt   # = Win.  Lascia vuoto per disattivare un tasto.\nI tasti funzionano solo con il gioco in primo piano (tranne quello delle impostazioni).
en=All keys in one place.  ^ = Ctrl   + = Shift   ! = Alt   # = Win.  Leave empty to disable a key.\nKeys only work while the game is in the foreground (except the settings key).
nap='E taste tutte quante int'a nu posto.  ^ = Ctrl   + = Shift   ! = Alt   # = Win.  Lassa vacante pe' stutà nu tasto.\n'E taste funzionano sulo cu 'o juoco annanze (fora chillo d'e mpustaziune).
bro=Tutti i tasti in un posto solo.  ^ = Ctrl   + = Shift   ! = Alt   # = Win.  Lascia vuoto per spegnere un tasto.\nI tasti vanno solo col gioco davanti (tranne quello dei settaggi).
es=Todas las teclas en un solo lugar.  ^ = Ctrl   + = Shift   ! = Alt   # = Win.  Déjalo vacío para desactivar una tecla.\nLas teclas solo funcionan con el juego en primer plano (excepto la de ajustes).
fr=Toutes les touches au même endroit.  ^ = Ctrl   + = Shift   ! = Alt   # = Win.  Laisse vide pour désactiver une touche.\nLes touches ne fonctionnent que si le jeu est au premier plan (sauf celle des paramètres).
de=Alle Tasten an einem Ort.  ^ = Ctrl   + = Shift   ! = Alt   # = Win.  Leer lassen, um eine Taste zu deaktivieren.\nDie Tasten funktionieren nur, wenn das Spiel im Vordergrund ist (außer der Einstellungs-Taste).
pt=Todas as teclas em um só lugar.  ^ = Ctrl   + = Shift   ! = Alt   # = Win.  Deixe vazio para desativar uma tecla.\nAs teclas só funcionam com o jogo em primeiro plano (exceto a das configurações).
ru=Все клавиши в одном месте.  ^ = Ctrl   + = Shift   ! = Alt   # = Win.  Оставьте пустым, чтобы отключить клавишу.\nКлавиши работают только когда игра на переднем плане (кроме клавиши настроек).
ko=모든 키를 한곳에서 설정해요.  ^ = Ctrl   + = Shift   ! = Alt   # = Win.  키를 끄려면 비워 두세요.\n키는 게임이 맨 앞에 있을 때만 작동해요 (설정 키 제외).
zh=所有按键集中在此。  ^ = Ctrl   + = Shift   ! = Alt   # = Win。  留空即可禁用该按键。\n按键仅在游戏位于前台时有效(设置键除外)。
ja=すべてのキーをここにまとめています。  ^ = Ctrl   + = Shift   ! = Alt   # = Win。  空欄にするとキーを無効にします。\nキーはゲームが前面にあるときのみ動作します (設定キーを除く)。
it=HUD overlay
en=HUD overlay
nap=HUD overlay
bro=HUD overlay
es=HUD overlay
fr=HUD overlay
de=HUD overlay
pt=HUD overlay
ru=HUD overlay
ko=HUD overlay
zh=HUD overlay
ja=HUD overlay
it=Mirino, barre e icone LOOT / COMBAT. Si accende con i segnali F9 / F10 inviati dalle tue macro.
en=Crosshair, bars and LOOT / COMBAT icons. It turns on with the F9 / F10 signals sent by your macros.
nap=Mirino, barre e icone LOOT / COMBAT. S'appiccia cu 'e segnale F9 / F10 ca mannano 'e macro toje.
bro=Mirino, barre e icone LOOT / COMBAT. Si accende coi segnali F9 / F10 che mandano le tue macro.
es=Mira, barras e iconos LOOT / COMBAT. Se enciende con las señales F9 / F10 enviadas por tus macros.
fr=Viseur, barres et icônes LOOT / COMBAT. S'active avec les signaux F9 / F10 envoyés par tes macros.
de=Fadenkreuz, Balken und LOOT / COMBAT Symbole. Es geht mit den Signalen F9 / F10 an, die deine Makros senden.
pt=Mira, barras e ícones LOOT / COMBAT. Liga com os sinais F9 / F10 enviados pelas suas macros.
ru=Прицел, полосы и иконки LOOT / COMBAT. Включается сигналами F9 / F10, которые отправляют ваши макросы.
ko=조준선, 바, LOOT / COMBAT 아이콘이에요. 매크로가 보내는 F9 / F10 신호로 켜져요.
zh=准星、条和 LOOT / COMBAT 图标。由你的宏发送的 F9 / F10 信号触发开启。
ja=照準、バー、LOOT / COMBAT アイコン。マクロから送られる F9 / F10 信号で点灯します。
it=Generale e macro
en=General and macros
nap=Generale e macro
bro=Generale e macro
es=General y macros
fr=Général et macros
de=Allgemein und Makros
pt=Geral e macros
ru=Общие и макросы
ko=일반 및 매크로
zh=常规与宏
ja=一般とマクロ
it=MACRO DI COMBAT: metti F9 in spam per tutta la durata della macro.\nMACRO DI LOOT: inserisci F10 con un wait di 1350 ms.\nSe le macro hanno pause più lunghe alza i Timeout.
en=COMBAT MACRO: put F9 on spam for the whole length of the macro.\nLOOT MACRO: insert F10 with a 1350 ms wait.\nIf your macros have longer pauses, raise the Timeouts.
nap=MACRO 'E COMBAT: miette F9 in spam pe' tutta 'a durata d'a macro.\nMACRO 'E LOOT: miette F10 cu nu wait 'e 1350 ms.\nSi 'e macro teneno pause cchiù longhe, aiza 'e Timeout.
bro=MACRO DI COMBAT: spamma F9 per tutta la macro.\nMACRO DI LOOT: metti F10 con un wait di 1350 ms.\nSe le macro hanno pause più lunghe alza i Timeout bro.
es=MACRO DE COMBATE: pon F9 en spam durante toda la duración de la macro.\nMACRO DE LOOT: inserta F10 con una espera de 1350 ms.\nSi tus macros tienen pausas más largas, sube los Timeouts.
fr=MACRO DE COMBAT : mets F9 en spam pendant toute la durée de la macro.\nMACRO D'LOOT : insère F10 avec une attente de 1350 ms.\nSi tes macros ont des pauses plus longues, augmente les Timeout.
de=COMBAT-MAKRO: Setze F9 als Spam für die gesamte Dauer des Makros.\nLOOT-MAKRO: Füge F10 mit einem Wait von 1350 ms ein.\nHaben deine Makros längere Pausen, erhöhe die Timeouts.
pt=MACRO DE COMBATE: coloque F9 em spam durante toda a duração da macro.\nMACRO DE LOOT: insira F10 com um wait de 1350 ms.\nSe suas macros têm pausas mais longas, aumente os Timeouts.
ru=БОЕВОЙ МАКРОС: поставьте F9 на спам на всё время работы макроса.\nМАКРОС LOOT: вставьте F10 с ожиданием 1350 ms.\nЕсли у ваших макросов паузы длиннее, увеличьте таймауты.
ko=전투 매크로: 매크로가 도는 동안 F9을 계속 연타하도록 설정하세요.\nLOOT 매크로: 1350 ms 대기와 함께 F10을 넣으세요.\n매크로에 더 긴 대기가 있다면 Timeout 값을 올리세요.
zh=战斗宏:在宏的整个持续时间内连发 F9。\nLOOT 宏:插入 F10,并等待 1350 ms。\n如果你的宏停顿较长,请调大超时数值。
ja=COMBATマクロ: マクロの実行中ずっと F9 を連打に設定してください。\nLOOTマクロ: 1350 ms の待機を入れて F10 を挿入してください。\nマクロの待機が長い場合は Timeout を上げてください。
it=Colori
en=Colors
nap=Culure
bro=Colori
es=Colores
fr=Couleurs
de=Farben
pt=Cores
ru=Цвета
ko=색상
zh=颜色
ja=色
it=Colori dell'HUD da attivo e da inattivo.
en=HUD colors when active and when idle.
nap=Culure 'e ll'HUD quanno è appicciato e quanno è stutato.
bro=Colori dell'HUD quando è acceso e quando è in chill.
es=Colores del HUD cuando está activo y cuando está inactivo.
fr=Couleurs du HUD à l'état actif et inactif.
de=HUD-Farben im aktiven und im inaktiven Zustand.
pt=Cores do HUD quando ativo e quando inativo.
ru=Цвета HUD в активном и неактивном состоянии.
ko=활성 및 비활성 상태의 HUD 색상이에요.
zh=HUD 激活和未激活时的颜色。
ja=有効時と無効時の HUD の色。
it=Mirino
en=Crosshair
nap=Mirino
bro=Mirino
es=Mira
fr=Viseur
de=Fadenkreuz
pt=Mira
ru=Прицел
ko=조준선
zh=准星
ja=照準
)" "`n"
        s .= "
(
it=Frecce al centro dello schermo.   OFF = <<<  >>>      ON = >>>  <<<  (animate)
en=Arrows in the middle of the screen.   OFF = <<<  >>>      ON = >>>  <<<  (animated)
nap=Frecce 'mmiezo 'o schermo.   OFF = <<<  >>>      ON = >>>  <<<  (animate)
bro=Frecce al centro dello schermo.   OFF = <<<  >>>      ON = >>>  <<<  (animate)
es=Flechas en el centro de la pantalla.   OFF = <<<  >>>      ON = >>>  <<<  (animadas)
fr=Flèches au centre de l'écran.   OFF = <<<  >>>      ON = >>>  <<<  (animées)
de=Pfeile in der Bildschirmmitte.   OFF = <<<  >>>      ON = >>>  <<<  (animiert)
pt=Setas no centro da tela.   OFF = <<<  >>>      ON = >>>  <<<  (animadas)
ru=Стрелки в центре экрана.   OFF = <<<  >>>      ON = >>>  <<<  (анимированные)
ko=화면 중앙의 화살표예요.   OFF = <<<  >>>      ON = >>>  <<<  (애니메이션)
zh=屏幕中央的箭头。   OFF = <<<  >>>      ON = >>>  <<<  (带动画)
ja=画面中央の矢印。   OFF = <<<  >>>      ON = >>>  <<<  (アニメーション)
it=Barre
en=Bars
nap=Barre
bro=Barre
es=Barras
fr=Barres
de=Balken
pt=Barras
ru=Полосы
ko=바
zh=条
ja=バー
it=Due barre a trapezio sotto il centro dello schermo, ognuna divisa in due metà.
en=Two trapezoid bars below the middle of the screen, each split into two halves.
nap=Doje barre a trapezio sotto 'o miezo d'o schermo, ognuna spartuta 'n doje mità.
bro=Due barre a trapezio sotto il centro dello schermo, ognuna spezzata in due.
es=Dos barras trapezoidales bajo el centro de la pantalla, cada una dividida en dos mitades.
fr=Deux barres en trapèze sous le centre de l'écran, chacune divisée en deux moitiés.
de=Zwei Trapezbalken unter der Bildschirmmitte, jeweils in zwei Hälften geteilt.
pt=Duas barras trapezoidais abaixo do centro da tela, cada uma dividida em duas metades.
ru=Две трапециевидные полосы под центром экрана, каждая разделена на две половины.
ko=화면 중앙 아래의 사다리꼴 바 두 개이며, 각각 두 반쪽으로 나뉘어요.
zh=屏幕中心下方的两条梯形条,每条分为左右两半。
ja=画面中央の下にある台形のバー2本。それぞれ左右2つに分かれます。
it=Icone - aspetto
en=Icons - look
nap=Icone - aspetto
bro=Icone - drip
es=Iconos - aspecto
fr=Icônes - aspect
de=Symbole - Aussehen
pt=Ícones - aparência
ru=Иконки - вид
ko=아이콘 - 모양
zh=图标 - 外观
ja=アイコン - 外観
it=Grandezza e cornice delle due icone (valgono per entrambe).
en=Size and frame of the two icons (they apply to both).
nap=Grandezza e curnice d'e doje icone (valeno pe' tutt'e doje).
bro=Size e cornice delle due icone (valgono per tutte e due).
es=Tamaño y marco de los dos iconos (valen para ambos).
fr=Taille et cadre des deux icônes (valables pour les deux).
de=Größe und Rahmen der beiden Symbole (gelten für beide).
pt=Tamanho e moldura dos dois ícones (valem para ambos).
ru=Размер и рамка двух иконок (действуют на обе).
ko=두 아이콘의 크기와 테두리예요 (둘 모두에 적용).
zh=两个图标的大小和边框(对两者都生效)。
ja=2つのアイコンのサイズと枠 (両方に適用)。
it=Icona Loot
en=Loot icon
nap=Icona Loot
bro=Icona Loot
es=Icono Loot
fr=Icône Loot
de=Loot-Symbol
pt=Ícone Loot
ru=Иконка Loot
ko=Loot 아이콘
zh=Loot 图标
ja=Loot アイコン
it=Icona LOOT (F10), a sinistra.
en=LOOT icon (F10), on the left.
nap=Icona LOOT (F10), a mancina.
bro=Icona LOOT (F10), a sinistra.
es=Icono LOOT (F10), a la izquierda.
fr=Icône LOOT (F10), à gauche.
de=LOOT Symbol (F10), links.
pt=Ícone LOOT (F10), à esquerda.
ru=Иконка LOOT (F10), слева.
ko=왼쪽의 LOOT (F10) 아이콘이에요.
zh=LOOT (F10) 图标,位于左侧。
ja=左側の LOOT (F10) アイコン。
it=Icona Combat
en=Combat icon
nap=Icona Combat
bro=Icona Combat
es=Icono Combat
fr=Icône Combat
de=Combat-Symbol
pt=Ícone Combat
ru=Иконка Combat
ko=Combat 아이콘
zh=Combat 图标
ja=Combat アイコン
it=Icona COMBAT (F9), a destra.
en=COMBAT icon (F9), on the right.
nap=Icona COMBAT (F9), a deritta.
bro=Icona COMBAT (F9), a destra.
es=Icono COMBAT (F9), a la derecha.
fr=Icône COMBAT (F9), à droite.
de=COMBAT Symbol (F9), rechts.
pt=Ícone COMBAT (F9), à direita.
ru=Иконка COMBAT (F9), справа.
ko=오른쪽의 COMBAT (F9) 아이콘이에요.
zh=COMBAT (F9) 图标,位于右侧。
ja=右側の COMBAT (F9) アイコン。
it=Icone - effetti
en=Icons - effects
nap=Icone - effette
bro=Icone - effetti
es=Iconos - efectos
fr=Icônes - effets
de=Symbole - Effekte
pt=Ícones - efeitos
ru=Иконки - эффекты
ko=아이콘 - 효과
zh=图标 - 特效
ja=アイコン - エフェクト
it=Effetti animati delle icone quando sono attive. Si possono combinare.
en=Animated effects of the icons while active. They can be combined.
nap=Effette animate d'e icone quanno so' appicciate. Se ponno mmescà.
bro=Effetti animati delle icone quando sono accese. Li puoi mixare.
es=Efectos animados de los iconos mientras están activos. Se pueden combinar.
fr=Effets animés des icônes lorsqu'elles sont actives. Ils peuvent être combinés.
de=Animierte Effekte der Symbole, solange sie aktiv sind. Sie lassen sich kombinieren.
pt=Efeitos animados dos ícones quando ativos. Podem ser combinados.
ru=Анимированные эффекты иконок в активном состоянии. Их можно комбинировать.
ko=아이콘이 활성일 때의 애니메이션 효과예요. 함께 조합할 수 있어요.
zh=图标激活时的动画特效。可以组合使用。
ja=アイコンが有効なときのアニメーション効果です。組み合わせ可能です。
it=Transizioni
en=Transitions
nap=Passaggie
bro=Transizioni
es=Transiciones
fr=Transitions
de=Übergänge
pt=Transições
ru=Переходы
ko=전환
zh=过渡
ja=トランジション
it=Dissolvenze e passaggi tra stato attivo e inattivo.
en=Fades and transitions between active and idle state.
nap=Dissolvenze e passaggie tra appicciato e stutato.
bro=Fade e passaggi tra acceso e chill.
es=Fundidos y transiciones entre estado activo e inactivo.
fr=Fondus et passages entre l'état actif et inactif.
de=Ein- und Ausblenden sowie Übergänge zwischen aktivem und inaktivem Zustand.
pt=Fades e transições entre o estado ativo e inativo.
ru=Плавные появления и переходы между активным и неактивным состоянием.
ko=활성/비활성 상태 사이의 페이드와 전환이에요.
zh=激活与未激活状态之间的淡入淡出和切换。
ja=有効状態と無効状態の間のフェードや切り替え。
it=Hidden Cube
en=Hidden Cube
nap=Hidden Cube
bro=Hidden Cube
es=Hidden Cube
fr=Hidden Cube
de=Hidden Cube
pt=Hidden Cube
ru=Hidden Cube
ko=Hidden Cube
zh=Hidden Cube
ja=Hidden Cube
it=Quando compare la finestra degli Hidden Cube porta il mouse su "Open with Key" e ce lo tiene bloccato.
en=When the Hidden Cube window shows up it moves the mouse onto "Open with Key" and keeps it locked there.
nap=Quanno esce 'a fenesta d'e Hidden Cube porta 'o mouse 'ncopp'a "Open with Key" e 'o tene bloccato llà.
bro=Quando spunta la finestra degli Hidden Cube porta il mouse su "Open with Key" e te lo tiene lì bloccato.
es=Cuando aparece la ventana de los Hidden Cube, lleva el ratón a "Open with Key" y lo mantiene bloqueado ahí.
fr=Quand la fenêtre des Hidden Cube apparaît, il place la souris sur "Open with Key" et l'y maintient verrouillée.
de=Wenn das Hidden-Cube-Fenster erscheint, bewegt es die Maus auf "Open with Key" und hält sie dort fest.
pt=Quando a janela dos Hidden Cube aparece, leva o mouse até "Open with Key" e o mantém travado ali.
ru=Когда появляется окно Hidden Cube, мышь перемещается на "Open with Key" и остаётся зафиксированной там.
ko=Hidden Cube 창이 나타나면 마우스를 "Open with Key" 위로 옮기고 그 자리에 고정해요.
zh=Hidden Cube 窗口出现时,鼠标会移动到 "Open with Key" 上并保持锁定。
ja=Hidden Cube のウィンドウが表示されると、マウスを "Open with Key" に移動して固定します。
it=Field Boss
en=Field Boss
nap=Field Boss
bro=Field Boss
es=Field Boss
fr=Field Boss
de=Field Boss
pt=Field Boss
ru=Field Boss
ko=Field Boss
zh=Field Boss
ja=Field Boss
it=Pannello dei boss sulla mappa, ricerca del boss e del Teleport più vicino, direzione di volo.
en=Boss panel on the map, search for the boss and the nearest Teleport, flight direction.
nap=Pannello d'e boss 'ncopp'â mappa, ricerca d'o boss e d'o Teleport cchiù vicino, direzione 'e volo.
bro=Pannello dei boss sulla mappa, cerca il boss e il Teleport più vicino, direzione di volo.
es=Panel de bosses en el mapa, búsqueda del boss y del Teleport más cercano, dirección de vuelo.
fr=Panneau des boss sur la carte, recherche du boss et du Teleport le plus proche, direction de vol.
de=Boss-Panel auf der Karte, Suche nach dem Boss und dem nächsten Teleport, Flugrichtung.
pt=Painel de bosses no mapa, busca do boss e do Teleport mais próximo, direção de voo.
ru=Панель боссов на карте, поиск босса и ближайшего Teleport, направление полёта.
ko=지도의 보스 패널, 보스와 가장 가까운 Teleport 검색, 비행 방향이에요.
zh=地图上的首领面板,首领及最近 Teleport 的搜索,飞行方向。
ja=マップ上のボスパネル、ボスと最寄り Teleport の検索、飛行方向。
it=Accensione e comportamento all'apertura della mappa.
en=Switching on and behavior when the map opens.
nap=Appicciatura e comme se comporta quanno s'arape 'a mappa.
bro=Accensione e cosa fa quando apri la mappa.
es=Activación y comportamiento al abrir el mapa.
fr=Activation et comportement à l'ouverture de la carte.
de=Einschalten und Verhalten beim Öffnen der Karte.
pt=Ativação e comportamento ao abrir o mapa.
ru=Включение и поведение при открытии карты.
ko=켜기와 지도를 열 때의 동작이에요.
zh=开启方式和地图打开时的行为。
ja=マップを開いたときの起動と動作。
it=Fasi di click
en=Click steps
nap=Fase 'e click
bro=Step di click
es=Pasos de clic
fr=Étapes de clic
de=Klick-Schritte
pt=Passos de clique
ru=Шаги кликов
ko=클릭 단계
zh=点击步骤
ja=クリック手順
)" "`n"
        s .= "
(
it=Dopo la scelta di un boss: blocco del mouse e dei click, istruzioni grandi in basso al centro.
en=After choosing a boss: mouse and click lock, big instructions at the bottom center.
nap=Doppo c'he scigliuto nu boss: blocco d'o mouse e d'e click, struzziune grosse abbascio 'o miezo.
bro=Dopo che scegli un boss: mouse e click bloccati, dritte grosse in basso al centro.
es=Tras elegir un boss: bloqueo del ratón y de los clics, instrucciones grandes abajo en el centro.
fr=Après le choix d'un boss : verrouillage de la souris et des clics, grandes instructions en bas au centre.
de=Nach der Wahl eines Bosses: Maus- und Klicksperre, große Anweisungen unten in der Mitte.
pt=Depois de escolher um boss: trava do mouse e dos cliques, instruções grandes embaixo no centro.
ru=После выбора босса: блокировка мыши и кликов, крупные подсказки внизу по центру.
ko=보스를 선택한 후: 마우스와 클릭 잠금, 화면 하단 중앙의 큰 안내문이에요.
zh=选择首领后:锁定鼠标和点击,屏幕底部中央显示大号指示。
ja=ボス選択後: マウスとクリックのロック、画面下中央の大きな案内。
it=Pannello
en=Panel
nap=Pannello
bro=Pannello
es=Panel
fr=Panneau
de=Panel
pt=Painel
ru=Панель
ko=패널
zh=面板
ja=パネル
it=Il pannello con l'elenco dei boss sul lato destro della mappa.
en=The panel with the boss list on the right side of the map.
nap='O pannello cu 'a lista d'e boss 'ncopp'ô lato deritto d'a mappa.
bro=Il pannello con la lista dei boss a destra sulla mappa.
es=El panel con la lista de bosses en el lado derecho del mapa.
fr=Le panneau avec la liste des boss sur le côté droit de la carte.
de=Das Panel mit der Boss-Liste am rechten Rand der Karte.
pt=O painel com a lista de bosses no lado direito do mapa.
ru=Панель со списком боссов справа на карте.
ko=지도 오른쪽에 표시되는 보스 목록 패널이에요.
zh=地图右侧的首领列表面板。
ja=マップ右側にあるボスリストのパネル。
it=Leggenda
en=Legend
nap=Leggenda
bro=Leggenda
es=Leyenda
fr=Légende
de=Legende
pt=Legenda
ru=Легенда
ko=범례
zh=图例
ja=凡例
it=La barra dei tasti in cima allo schermo con la mappa aperta.
en=The key bar at the top of the screen while the map is open.
nap='A barra d'e taste 'ncoppa 'o schermo cu 'a mappa aperta.
bro=La barra dei tasti in cima allo schermo con la mappa aperta.
es=La barra de teclas en la parte superior de la pantalla con el mapa abierto.
fr=La barre des touches en haut de l'écran quand la carte est ouverte.
de=Die Tastenleiste oben am Bildschirm bei geöffneter Karte.
pt=A barra de teclas no topo da tela com o mapa aberto.
ru=Панель клавиш вверху экрана при открытой карте.
ko=지도를 열었을 때 화면 상단에 표시되는 키 바예요.
zh=地图打开时屏幕顶部的按键栏。
ja=マップを開いている間、画面上部に表示されるキーバー。
it=Ricerca e Teleport
en=Search and Teleport
nap=Ricerca e Teleport
bro=Ricerca e Teleport
es=Búsqueda y Teleport
fr=Recherche et Teleport
de=Suche und Teleport
pt=Busca e Teleport
ru=Поиск и Teleport
ko=검색 및 Teleport
zh=搜索与 Teleport
ja=検索と Teleport
it=Come lo script trova il boss nella lista e il Teleport più vicino.
en=How the script finds the boss in the list and the nearest Teleport.
nap=Comme 'o script trova 'o boss dint'â lista e 'o Teleport cchiù vicino.
bro=Come lo script sgama il boss nella lista e il Teleport più vicino.
es=Cómo encuentra el script al boss en la lista y el Teleport más cercano.
fr=Comment le script trouve le boss dans la liste et le Teleport le plus proche.
de=Wie das Skript den Boss in der Liste und den nächsten Teleport findet.
pt=Como o script encontra o boss na lista e o Teleport mais próximo.
ru=Как скрипт находит босса в списке и ближайший Teleport.
ko=스크립트가 목록에서 보스를, 지도에서 가장 가까운 Teleport를 찾는 방식이에요.
zh=脚本如何在列表中找到首领以及最近的 Teleport。
ja=スクリプトがリストからボスを、最寄りの Teleport を見つける方法。
it=Travel e direzione
en=Travel and direction
nap=Travel e direzione
bro=Travel e direzione
es=Travel y dirección
fr=Travel et direction
de=Travel und Richtung
pt=Travel e direção
ru=Travel и направление
ko=Travel 및 방향
zh=Travel 与方向
ja=Travel と方向
it=Dopo il click sul Teleport: pressioni di F per partire e freccia con la direzione del boss.
en=After clicking the Teleport: F presses to depart and an arrow with the boss direction.
nap=Doppo 'o click 'ncopp'ô Teleport: pressiune 'e F pe' partì e na freccia cu 'a direzione d'o boss.
bro=Dopo il click sul Teleport: botte di F per partire e freccia con la direzione del boss.
es=Tras hacer clic en el Teleport: pulsaciones de F para partir y flecha con la dirección del boss.
fr=Après le clic sur le Teleport : appuis sur F pour partir et flèche indiquant la direction du boss.
de=Nach dem Klick auf den Teleport: F-Drücke zum Start und ein Pfeil mit der Boss-Richtung.
pt=Depois do clique no Teleport: pressões de F para partir e seta com a direção do boss.
ru=После клика по Teleport: нажатия F для отправления и стрелка с направлением к боссу.
ko=Teleport를 클릭한 후: 출발을 위한 F 입력 횟수와 보스 방향 화살표예요.
zh=点击 Teleport 后:按 F 出发,并显示指向首领方向的箭头。
ja=Teleport をクリック後: F キーで出発し、ボスの方向を示す矢印を表示。
it=Profilo prestazioni
en=Performance profile
nap=Prufilo prestaziune
bro=Profilo performance
es=Perfil de rendimiento
fr=Profil de performances
de=Leistungsprofil
pt=Perfil de desempenho
ru=Профиль производительности
ko=성능 프로필
zh=性能配置档
ja=パフォーマンスプロファイル
it=Ciclo di lavoro Field Boss (ms)
en=Field Boss work cycle (ms)
nap=Ciclo 'e fatica Field Boss (ms)
bro=Ciclo Field Boss (ms)
es=Ciclo de trabajo de Field Boss (ms)
fr=Cycle de travail Field Boss (ms)
de=Field Boss Arbeitszyklus (ms)
pt=Ciclo de trabalho do Field Boss (ms)
ru=Цикл работы Field Boss (ms)
ko=Field Boss 작업 주기 (ms)
zh=Field Boss 工作周期 (ms)
ja=Field Boss 処理サイクル (ms)
it=Blocco mouse Field Boss (ms)
en=Field Boss mouse lock (ms)
nap=Blocco d'o mouse Field Boss (ms)
bro=Lock mouse Field Boss (ms)
es=Bloqueo de ratón de Field Boss (ms)
fr=Verrou souris Field Boss (ms)
de=Field Boss Maussperre (ms)
pt=Trava do mouse do Field Boss (ms)
ru=Блокировка мыши Field Boss (ms)
ko=Field Boss 마우스 잠금 (ms)
zh=Field Boss 鼠标锁定 (ms)
ja=Field Boss マウスロック (ms)
it=Attesa click/tasti (ms)
en=Click/key wait (ms)
nap=Attesa click/taste (ms)
bro=Attesa click/tasti (ms)
es=Espera de clic/teclas (ms)
fr=Attente clic/touches (ms)
de=Warten auf Klick/Tasten (ms)
pt=Espera de clique/teclas (ms)
ru=Ожидание кликов/клавиш (ms)
ko=클릭/키 대기 (ms)
zh=点击/按键等待 (ms)
ja=クリック/キー待機 (ms)
it=Anello pulsante (ms)
en=Pulsing ring (ms)
nap=Anello ca pulsa (ms)
bro=Anello che pulsa (ms)
es=Anillo pulsante (ms)
fr=Anneau pulsant (ms)
de=Pulsring (ms)
pt=Anel pulsante (ms)
ru=Пульсирующее кольцо (ms)
ko=펄스 링 (ms)
zh=脉冲圆环 (ms)
ja=パルスリング (ms)
it=Qualità OCR
en=OCR quality
nap=Qualità OCR
bro=Qualità OCR
es=Calidad OCR
fr=Qualité OCR
de=OCR-Qualität
pt=Qualidade do OCR
ru=Качество OCR
ko=OCR 품질
zh=OCR 质量
ja=OCR 品質
it=Processo del gioco
en=Game process
nap=Processo d'o juoco
bro=Processo del gioco
es=Proceso del juego
fr=Processus du jeu
de=Spielprozess
pt=Processo do jogo
ru=Процесс игры
ko=게임 프로세스
zh=游戏进程
ja=ゲームプロセス
it=Click attraverso l'HUD
en=Click through the HUD
nap=Click ca passano pe' ll'HUD
bro=Click che passano l'HUD
es=Clic a través del HUD
fr=Clic à travers le HUD
de=Klick durch das HUD
pt=Clique através do HUD
ru=Клик сквозь HUD
ko=HUD 클릭 통과
zh=点击穿透 HUD
ja=HUD 越しのクリック
it=Splash all'avvio
en=Startup splash
nap=Splash a ll'avvio
bro=Splash all'avvio
es=Splash al inicio
fr=Splash au démarrage
de=Splash beim Start
pt=Splash na inicialização
ru=Заставка при запуске
ko=시작 시 스플래시
zh=启动画面
ja=起動時スプラッシュ
it=Splash: durata a schermo (s)
en=Splash: time on screen (s)
nap=Splash: quanto resta a schermo (s)
bro=Splash: quanto resta (s)
es=Splash: duración en pantalla (s)
fr=Splash : durée à l'écran (s)
de=Splash: Anzeigedauer (s)
pt=Splash: tempo na tela (s)
ru=Заставка: время на экране (s)
ko=스플래시: 화면 표시 시간 (s)
zh=启动画面:显示时长 (s)
ja=スプラッシュ: 表示時間 (s)
it=Splash: dimensione
en=Splash: size
nap=Splash: grandezza
bro=Splash: size
es=Splash: tamaño
fr=Splash : taille
de=Splash: Größe
pt=Splash: tamanho
ru=Заставка: размер
ko=스플래시: 크기
zh=启动画面:大小
ja=スプラッシュ: サイズ
it=Segnale Combat (macro)
en=Combat signal (macro)
nap=Segnale Combat (macro)
bro=Segnale Combat (macro)
es=Señal Combat (macro)
fr=Signal Combat (macro)
de=Combat-Signal (Makro)
pt=Sinal de Combat (macro)
ru=Сигнал Combat (макрос)
ko=Combat 신호 (매크로)
zh=战斗信号 (宏)
ja=Combat 信号 (マクロ)
it=Segnale Loot (macro)
en=Loot signal (macro)
nap=Segnale Loot (macro)
bro=Segnale Loot (macro)
es=Señal Loot (macro)
fr=Signal Loot (macro)
de=Loot-Signal (Makro)
pt=Sinal de Loot (macro)
ru=Сигнал Loot (макрос)
ko=Loot 신호 (매크로)
zh=Loot 信号 (宏)
ja=Loot 信号 (マクロ)
it=Tasto mappa del gioco
en=Game map key
nap=Tasto d'a mappa d'o juoco
bro=Tasto mappa del gioco
es=Tecla de mapa del juego
fr=Touche carte du jeu
de=Kartentaste des Spiels
pt=Tecla de mapa do jogo
ru=Клавиша карты в игре
ko=게임 지도 키
zh=游戏地图键
ja=ゲームのマップキー
it=Tasto Travel del gioco
en=Game Travel key
nap=Tasto Travel d'o juoco
bro=Tasto Travel del gioco
es=Tecla Travel del juego
fr=Touche Travel du jeu
de=Travel-Taste des Spiels
pt=Tecla de Travel do jogo
ru=Клавиша Travel в игре
ko=게임 Travel 키
zh=游戏 Travel 键
ja=ゲームの Travel キー
)" "`n"
        s .= "
(
it=Apri impostazioni
en=Open settings
nap=Arape 'e mpustaziune
bro=Apri settaggi
es=Abrir ajustes
fr=Ouvrir les paramètres
de=Einstellungen öffnen
pt=Abrir configurações
ru=Открыть настройки
ko=설정 열기
zh=打开设置
ja=設定を開く
it=Diagnosi Hidden Cube
en=Hidden Cube diagnostics
nap=Diagnosi Hidden Cube
bro=Debug Hidden Cube
es=Diagnóstico Hidden Cube
fr=Diagnostic Hidden Cube
de=Hidden-Cube-Diagnose
pt=Diagnóstico do Hidden Cube
ru=Диагностика Hidden Cube
ko=Hidden Cube 진단
zh=Hidden Cube 诊断
ja=Hidden Cube 診断
it=Diagnosi: coordinate mouse
en=Diagnostics: mouse coordinates
nap=Diagnosi: coordinate d'o mouse
bro=Debug: coordinate mouse
es=Diagnóstico: coordenadas del ratón
fr=Diagnostic : coordonnées souris
de=Diagnose: Mauskoordinaten
pt=Diagnóstico: coordenadas do mouse
ru=Диагностика: координаты мыши
ko=진단: 마우스 좌표
zh=诊断:鼠标坐标
ja=診断: マウス座標
it=Diagnosi: icone sulla mappa
en=Diagnostics: map icons
nap=Diagnosi: icone 'ncopp'â mappa
bro=Debug: icone sulla mappa
es=Diagnóstico: iconos del mapa
fr=Diagnostic : icônes sur la carte
de=Diagnose: Symbole auf der Karte
pt=Diagnóstico: ícones no mapa
ru=Диагностика: иконки на карте
ko=진단: 지도 아이콘
zh=诊断:地图图标
ja=診断: マップ上のアイコン
it=Diagnosi: lettura lista boss
en=Diagnostics: boss list reading
nap=Diagnosi: lettura d'a lista boss
bro=Debug: lettura lista boss
es=Diagnóstico: lectura de la lista de bosses
fr=Diagnostic : lecture liste des boss
de=Diagnose: Boss-Liste lesen
pt=Diagnóstico: leitura da lista de bosses
ru=Диагностика: чтение списка боссов
ko=진단: 보스 목록 읽기
zh=诊断:首领列表读取
ja=診断: ボスリスト読み取り
it=HUD attivo all'avvio
en=HUD on at startup
nap=HUD appicciato a ll'avvio
bro=HUD acceso all'avvio
es=HUD activo al inicio
fr=HUD actif au démarrage
de=HUD beim Start an
pt=HUD ativo na inicialização
ru=HUD включён при запуске
ko=시작 시 HUD 켜기
zh=启动时开启 HUD
ja=起動時に HUD を有効化
it=Risoluzione dei valori HUD
en=Resolution of the HUD values
nap=Risoluzione d'e valure HUD
bro=Risoluzione dei valori HUD
es=Resolución de los valores del HUD
fr=Résolution des valeurs du HUD
de=Auflösung der HUD-Werte
pt=Resolução dos valores do HUD
ru=Разрешение значений HUD
ko=HUD 값의 해상도
zh=HUD 数值分辨率
ja=HUD 値の解像度
it=Spegnimento Combat dopo (ms)
en=Combat off after (ms)
nap=Combat se stuta doppo (ms)
bro=Combat si spegne dopo (ms)
es=Apagado de Combat tras (ms)
fr=Arrêt Combat après (ms)
de=Combat aus nach (ms)
pt=Desligar Combat após (ms)
ru=Выключение Combat через (ms)
ko=Combat 꺼짐 지연 (ms)
zh=战斗关闭延迟 (ms)
ja=Combat 解除まで (ms)
it=Spegnimento Loot dopo (ms)
en=Loot off after (ms)
nap=Loot se stuta doppo (ms)
bro=Loot si spegne dopo (ms)
es=Apagado de Loot tras (ms)
fr=Arrêt Loot après (ms)
de=Loot aus nach (ms)
pt=Desligar Loot após (ms)
ru=Выключение Loot через (ms)
ko=Loot 꺼짐 지연 (ms)
zh=Loot 关闭延迟 (ms)
ja=Loot 解除まで (ms)
it=Combat acceso almeno (ms)
en=Combat on for at least (ms)
nap=Combat appicciato almeno (ms)
bro=Combat acceso minimo (ms)
es=Combat encendido al menos (ms)
fr=Combat allumé au moins (ms)
de=Combat an mindestens (ms)
pt=Combat ligado por pelo menos (ms)
ru=Combat включён минимум (ms)
ko=Combat 최소 켜짐 시간 (ms)
zh=战斗最短开启时间 (ms)
ja=Combat 最低点灯時間 (ms)
it=Loot acceso almeno (ms)
en=Loot on for at least (ms)
nap=Loot appicciato almeno (ms)
bro=Loot acceso minimo (ms)
es=Loot encendido al menos (ms)
fr=Loot allumé au moins (ms)
de=Loot an mindestens (ms)
pt=Loot ligado por pelo menos (ms)
ru=Loot включён минимум (ms)
ko=Loot 최소 켜짐 시간 (ms)
zh=Loot 最短开启时间 (ms)
ja=Loot 最低点灯時間 (ms)
it=Colore attivo
en=Active color
nap=Culore appicciato
bro=Colore acceso
es=Color activo
fr=Couleur active
de=Aktivfarbe
pt=Cor ativa
ru=Цвет активного состояния
ko=활성 색상
zh=激活颜色
ja=有効時の色
it=Colore inattivo mirino/barre
en=Idle color crosshair/bars
nap=Culore stutato mirino/barre
bro=Colore chill mirino/barre
es=Color inactivo mira/barras
fr=Couleur inactive viseur/barres
de=Inaktivfarbe Fadenkreuz/Balken
pt=Cor inativa mira/barras
ru=Цвет неактивного прицела/полос
ko=조준선/바 비활성 색상
zh=准星/条未激活颜色
ja=照準/バーの無効時の色
it=Colore inattivo Loot
en=Idle color Loot
nap=Culore stutato Loot
bro=Colore chill Loot
es=Color inactivo Loot
fr=Couleur inactive Loot
de=Inaktivfarbe Loot
pt=Cor inativa Loot
ru=Цвет неактивного Loot
ko=Loot 비활성 색상
zh=Loot 未激活颜色
ja=Loot 無効時の色
it=Colore inattivo Combat
en=Idle color Combat
nap=Culore stutato Combat
bro=Colore chill Combat
es=Color inactivo Combat
fr=Couleur inactive Combat
de=Inaktivfarbe Combat
pt=Cor inativa Combat
ru=Цвет неактивного Combat
ko=Combat 비활성 색상
zh=Combat 未激活颜色
ja=Combat 無効時の色
it=Colore cornici
en=Frame color
nap=Culore d'e curnice
bro=Colore cornici
es=Color de marcos
fr=Couleur des cadres
de=Rahmenfarbe
pt=Cor das molduras
ru=Цвет рамок
ko=테두리 색상
zh=边框颜色
ja=枠の色
it=Posizione orizzontale
en=Horizontal position
nap=Pusizione orizzontale
bro=Posizione orizzontale
es=Posición horizontal
fr=Position horizontale
de=Horizontale Position
pt=Posição horizontal
ru=Положение по горизонтали
ko=가로 위치
zh=水平位置
ja=水平位置
it=Posizione verticale
en=Vertical position
nap=Pusizione verticale
bro=Posizione verticale
es=Posición vertical
fr=Position verticale
de=Vertikale Position
pt=Posição vertical
ru=Положение по вертикали
ko=세로 위치
zh=垂直位置
ja=垂直位置
it=Spazio centrale
en=Center gap
nap=Spazio 'mmiezo
bro=Spazio in mezzo
es=Espacio central
fr=Espace central
de=Mittlerer Abstand
pt=Espaço central
ru=Центральный зазор
ko=중앙 간격
zh=中央间距
ja=中央の間隔
it=Frecce per lato
en=Arrows per side
nap=Frecce pe' lato
bro=Frecce per lato
es=Flechas por lado
fr=Flèches par côté
de=Pfeile pro Seite
pt=Setas por lado
ru=Стрелок на сторону
ko=면당 화살표 수
zh=每侧箭头数
ja=片側の矢印数
it=Larghezza freccia (OFF)
en=Arrow width (OFF)
nap=Larghezza d'a freccia (OFF)
bro=Larghezza freccia (OFF)
es=Ancho de flecha (OFF)
fr=Largeur flèche (OFF)
de=Pfeilbreite (OFF)
pt=Largura da seta (OFF)
ru=Ширина стрелки (OFF)
ko=화살표 너비 (OFF)
zh=箭头宽度 (OFF)
ja=矢印の幅 (OFF)
it=Larghezza freccia (ON)
en=Arrow width (ON)
nap=Larghezza d'a freccia (ON)
bro=Larghezza freccia (ON)
es=Ancho de flecha (ON)
fr=Largeur flèche (ON)
de=Pfeilbreite (ON)
pt=Largura da seta (ON)
ru=Ширина стрелки (ON)
ko=화살표 너비 (ON)
zh=箭头宽度 (ON)
ja=矢印の幅 (ON)
it=Altezza freccia (OFF)
en=Arrow height (OFF)
nap=Autezza d'a freccia (OFF)
bro=Altezza freccia (OFF)
es=Alto de flecha (OFF)
fr=Hauteur flèche (OFF)
de=Pfeilhöhe (OFF)
pt=Altura da seta (OFF)
ru=Высота стрелки (OFF)
ko=화살표 높이 (OFF)
zh=箭头高度 (OFF)
ja=矢印の高さ (OFF)
it=Altezza freccia (ON)
en=Arrow height (ON)
nap=Autezza d'a freccia (ON)
bro=Altezza freccia (ON)
es=Alto de flecha (ON)
fr=Hauteur flèche (ON)
de=Pfeilhöhe (ON)
pt=Altura da seta (ON)
ru=Высота стрелки (ON)
ko=화살표 높이 (ON)
zh=箭头高度 (ON)
ja=矢印の高さ (ON)
it=Spessore linee (OFF)
en=Line thickness (OFF)
nap=Spessore d'e linee (OFF)
bro=Spessore linee (OFF)
es=Grosor de líneas (OFF)
fr=Épaisseur traits (OFF)
de=Linienstärke (OFF)
pt=Espessura das linhas (OFF)
ru=Толщина линий (OFF)
ko=선 두께 (OFF)
zh=线条粗细 (OFF)
ja=線の太さ (OFF)
it=Spessore linee (ON)
en=Line thickness (ON)
nap=Spessore d'e linee (ON)
bro=Spessore linee (ON)
es=Grosor de líneas (ON)
fr=Épaisseur traits (ON)
de=Linienstärke (ON)
pt=Espessura das linhas (ON)
ru=Толщина линий (ON)
ko=선 두께 (ON)
zh=线条粗细 (ON)
ja=線の太さ (ON)
it=Distanza tra frecce (OFF)
en=Arrow spacing (OFF)
nap=Distanza tra 'e frecce (OFF)
bro=Distanza tra frecce (OFF)
es=Distancia entre flechas (OFF)
fr=Distance entre flèches (OFF)
de=Pfeilabstand (OFF)
pt=Distância entre setas (OFF)
ru=Расстояние между стрелками (OFF)
ko=화살표 간격 (OFF)
zh=箭头间距 (OFF)
ja=矢印の間隔 (OFF)
it=Distanza tra frecce (ON)
en=Arrow spacing (ON)
nap=Distanza tra 'e frecce (ON)
bro=Distanza tra frecce (ON)
es=Distancia entre flechas (ON)
fr=Distance entre flèches (ON)
de=Pfeilabstand (ON)
pt=Distância entre setas (ON)
ru=Расстояние между стрелками (ON)
ko=화살표 간격 (ON)
zh=箭头间距 (ON)
ja=矢印の間隔 (ON)
it=Forma (OFF)
en=Shape (OFF)
nap=Forma (OFF)
bro=Shape (OFF)
es=Forma (OFF)
fr=Forme (OFF)
de=Form (OFF)
pt=Forma (OFF)
ru=Форма (OFF)
ko=모양 (OFF)
zh=形状 (OFF)
ja=形状 (OFF)
it=Forma (ON)
en=Shape (ON)
nap=Forma (ON)
bro=Shape (ON)
es=Forma (ON)
fr=Forme (ON)
de=Form (ON)
pt=Forma (ON)
ru=Форма (ON)
ko=모양 (ON)
zh=形状 (ON)
ja=形状 (ON)
it=Animazione
en=Animation
nap=Animazione
bro=Animazione
es=Animación
fr=Animation
de=Animation
pt=Animação
ru=Анимация
ko=애니메이션
zh=动画
ja=アニメーション
it=Durata ciclo animazione (ms)
en=Animation cycle length (ms)
nap=Durata d'o ciclo d'animazione (ms)
bro=Durata giro animazione (ms)
es=Duración del ciclo de animación (ms)
fr=Durée du cycle d'animation (ms)
de=Animationszyklus (ms)
pt=Duração do ciclo de animação (ms)
ru=Длительность цикла анимации (ms)
ko=애니메이션 주기 (ms)
zh=动画周期时长 (ms)
ja=アニメーション周期 (ms)
it=Pulse: grandezza minima
en=Pulse: minimum size
nap=Pulse: grandezza minima
bro=Pulse: size minima
es=Pulse: tamaño mínimo
fr=Pulse : taille minimale
de=Pulse: Mindestgröße
pt=Pulse: tamanho mínimo
ru=Pulse: минимальный размер
ko=Pulse: 최소 크기
zh=Pulse:最小尺寸
ja=Pulse: 最小サイズ
)" "`n"
        s .= "
(
it=Pulse: grandezza massima
en=Pulse: maximum size
nap=Pulse: grandezza massima
bro=Pulse: size massima
es=Pulse: tamaño máximo
fr=Pulse : taille maximale
de=Pulse: Maximalgröße
pt=Pulse: tamanho máximo
ru=Pulse: максимальный размер
ko=Pulse: 최대 크기
zh=Pulse:最大尺寸
ja=Pulse: 最大サイズ
it=Passaggio OFF > ON (s)
en=OFF > ON transition (s)
nap=Passaggio OFF > ON (s)
bro=Passaggio OFF > ON (s)
es=Paso de OFF a ON (s)
fr=Passage OFF > ON (s)
de=Übergang OFF > ON (s)
pt=Transição OFF > ON (s)
ru=Переход OFF > ON (s)
ko=OFF > ON 전환 (s)
zh=OFF > ON 过渡 (s)
ja=OFF > ON 切替 (s)
it=Passaggio ON > OFF (s)
en=ON > OFF transition (s)
nap=Passaggio ON > OFF (s)
bro=Passaggio ON > OFF (s)
es=Paso de ON a OFF (s)
fr=Passage ON > OFF (s)
de=Übergang ON > OFF (s)
pt=Transição ON > OFF (s)
ru=Переход ON > OFF (s)
ko=ON > OFF 전환 (s)
zh=ON > OFF 过渡 (s)
ja=ON > OFF 切替 (s)
it=Barra 1 visibile
en=Bar 1 visible
nap=Barra 1 ca se vede
bro=Barra 1 visibile
es=Barra 1 visible
fr=Barre 1 visible
de=Balken 1 sichtbar
pt=Barra 1 visível
ru=Полоса 1 видна
ko=바 1 표시
zh=条 1 可见
ja=バー1 表示
it=Barra 2 visibile
en=Bar 2 visible
nap=Barra 2 ca se vede
bro=Barra 2 visibile
es=Barra 2 visible
fr=Barre 2 visible
de=Balken 2 sichtbar
pt=Barra 2 visível
ru=Полоса 2 видна
ko=바 2 표시
zh=条 2 可见
ja=バー2 表示
it=Barra 1: larghezza
en=Bar 1: width
nap=Barra 1: larghezza
bro=Barra 1: larghezza
es=Barra 1: ancho
fr=Barre 1 : largeur
de=Balken 1: Breite
pt=Barra 1: largura
ru=Полоса 1: ширина
ko=바 1: 너비
zh=条 1:宽度
ja=バー1: 幅
it=Barra 2: larghezza
en=Bar 2: width
nap=Barra 2: larghezza
bro=Barra 2: larghezza
es=Barra 2: ancho
fr=Barre 2 : largeur
de=Balken 2: Breite
pt=Barra 2: largura
ru=Полоса 2: ширина
ko=바 2: 너비
zh=条 2:宽度
ja=バー2: 幅
it=Barra 1: altezza
en=Bar 1: height
nap=Barra 1: autezza
bro=Barra 1: altezza
es=Barra 1: alto
fr=Barre 1 : hauteur
de=Balken 1: Höhe
pt=Barra 1: altura
ru=Полоса 1: высота
ko=바 1: 높이
zh=条 1:高度
ja=バー1: 高さ
it=Barra 2: altezza
en=Bar 2: height
nap=Barra 2: autezza
bro=Barra 2: altezza
es=Barra 2: alto
fr=Barre 2 : hauteur
de=Balken 2: Höhe
pt=Barra 2: altura
ru=Полоса 2: высота
ko=바 2: 높이
zh=条 2:高度
ja=バー2: 高さ
it=Barra 1: cornice
en=Bar 1: frame
nap=Barra 1: curnice
bro=Barra 1: cornice
es=Barra 1: marco
fr=Barre 1 : cadre
de=Balken 1: Rahmen
pt=Barra 1: moldura
ru=Полоса 1: рамка
ko=바 1: 테두리
zh=条 1:边框
ja=バー1: 枠
it=Barra 2: cornice
en=Bar 2: frame
nap=Barra 2: curnice
bro=Barra 2: cornice
es=Barra 2: marco
fr=Barre 2 : cadre
de=Balken 2: Rahmen
pt=Barra 2: moldura
ru=Полоса 2: рамка
ko=바 2: 테두리
zh=条 2:边框
ja=バー2: 枠
it=Barra 1: posizione orizzontale
en=Bar 1: horizontal position
nap=Barra 1: pusizione orizzontale
bro=Barra 1: posizione orizzontale
es=Barra 1: posición horizontal
fr=Barre 1 : position horizontale
de=Balken 1: horizontale Position
pt=Barra 1: posição horizontal
ru=Полоса 1: положение по горизонтали
ko=바 1: 가로 위치
zh=条 1:水平位置
ja=バー1: 水平位置
it=Barra 2: posizione orizzontale
en=Bar 2: horizontal position
nap=Barra 2: pusizione orizzontale
bro=Barra 2: posizione orizzontale
es=Barra 2: posición horizontal
fr=Barre 2 : position horizontale
de=Balken 2: horizontale Position
pt=Barra 2: posição horizontal
ru=Полоса 2: положение по горизонтали
ko=바 2: 가로 위치
zh=条 2:水平位置
ja=バー2: 水平位置
it=Barra 1: posizione verticale
en=Bar 1: vertical position
nap=Barra 1: pusizione verticale
bro=Barra 1: posizione verticale
es=Barra 1: posición vertical
fr=Barre 1 : position verticale
de=Balken 1: vertikale Position
pt=Barra 1: posição vertical
ru=Полоса 1: положение по вертикали
ko=바 1: 세로 위치
zh=条 1:垂直位置
ja=バー1: 垂直位置
it=Barra 2: posizione verticale
en=Bar 2: vertical position
nap=Barra 2: pusizione verticale
bro=Barra 2: posizione verticale
es=Barra 2: posición vertical
fr=Barre 2 : position verticale
de=Balken 2: vertikale Position
pt=Barra 2: posição vertical
ru=Полоса 2: положение по вертикали
ko=바 2: 세로 위치
zh=条 2:垂直位置
ja=バー2: 垂直位置
it=Barra 1: spazio centrale
en=Bar 1: center gap
nap=Barra 1: spazio 'mmiezo
bro=Barra 1: spazio in mezzo
es=Barra 1: espacio central
fr=Barre 1 : espace central
de=Balken 1: mittlerer Abstand
pt=Barra 1: espaço central
ru=Полоса 1: центральный зазор
ko=바 1: 중앙 간격
zh=条 1:中央间距
ja=バー1: 中央の間隔
it=Barra 2: spazio centrale
en=Bar 2: center gap
nap=Barra 2: spazio 'mmiezo
bro=Barra 2: spazio in mezzo
es=Barra 2: espacio central
fr=Barre 2 : espace central
de=Balken 2: mittlerer Abstand
pt=Barra 2: espaço central
ru=Полоса 2: центральный зазор
ko=바 2: 중앙 간격
zh=条 2:中央间距
ja=バー2: 中央の間隔
it=Barra 1: inclinazione
en=Bar 1: slant
nap=Barra 1: pennenza
bro=Barra 1: quanto è storta
es=Barra 1: inclinación
fr=Barre 1 : inclinaison
de=Balken 1: Neigung
pt=Barra 1: inclinação
ru=Полоса 1: наклон
ko=바 1: 기울기
zh=条 1:倾斜度
ja=バー1: 傾き
it=Barra 2: inclinazione
en=Bar 2: slant
nap=Barra 2: pennenza
bro=Barra 2: quanto è storta
es=Barra 2: inclinación
fr=Barre 2 : inclinaison
de=Balken 2: Neigung
pt=Barra 2: inclinação
ru=Полоса 2: наклон
ko=바 2: 기울기
zh=条 2:倾斜度
ja=バー2: 傾き
it=Grandezza icone (altezza)
en=Icon size (height)
nap=Grandezza d'e icone (autezza)
bro=Size icone (altezza)
es=Tamaño de iconos (altura)
fr=Taille des icônes (hauteur)
de=Symbolgröße (Höhe)
pt=Tamanho dos ícones (altura)
ru=Размер иконок (высота)
ko=아이콘 크기 (높이)
zh=图标大小 (高度)
ja=アイコンサイズ (高さ)
it=Bordino nero
en=Black border
nap=Bordino niro
bro=Bordino nero
es=Borde negro
fr=Liseré noir
de=Schwarzer Rand
pt=Borda preta
ru=Чёрная обводка
ko=검은 테두리
zh=黑色描边
ja=黒縁
it=Dimensione testo
en=Text size
nap=Grandezza d'o testo
bro=Size testo
es=Tamaño del texto
fr=Taille du texte
de=Textgröße
pt=Tamanho do texto
ru=Размер текста
ko=텍스트 크기
zh=文字大小
ja=テキストサイズ
it=Dimensione emoji
en=Emoji size
nap=Grandezza d'a emoji
bro=Size emoji
es=Tamaño del emoji
fr=Taille de l'emoji
de=Emoji-Größe
pt=Tamanho do emoji
ru=Размер эмодзи
ko=이모지 크기
zh=Emoji 大小
ja=絵文字サイズ
it=Emoji: spostamento verticale
en=Emoji: vertical offset
nap=Emoji: spustamento verticale
bro=Emoji: sposta su/giù
es=Emoji: desplazamiento vertical
fr=Emoji : décalage vertical
de=Emoji: vertikal verschieben
pt=Emoji: deslocamento vertical
ru=Эмодзи: сдвиг по вертикали
ko=이모지: 세로 이동
zh=Emoji:垂直偏移
ja=絵文字: 垂直オフセット
it=Emoji: spostamento orizzontale
en=Emoji: horizontal offset
nap=Emoji: spustamento orizzontale
bro=Emoji: sposta dx/sx
es=Emoji: desplazamiento horizontal
fr=Emoji : décalage horizontal
de=Emoji: horizontal verschieben
pt=Emoji: deslocamento horizontal
ru=Эмодзи: сдвиг по горизонтали
ko=이모지: 가로 이동
zh=Emoji:水平偏移
ja=絵文字: 水平オフセット
it=Testo in alto: spost. orizzontale
en=Top text: horizontal offset
nap=Testo 'ncoppa: spust. orizzontale
bro=Testo sopra: sposta dx/sx
es=Texto superior: desplaz. horizontal
fr=Texte du haut : décalage horizontal
de=Text oben: horiz. verschieben
pt=Texto de cima: desl. horizontal
ru=Верхний текст: сдвиг по горизонтали
ko=상단 텍스트: 가로 이동
zh=上方文字:水平偏移
ja=上テキスト: 水平オフセット
it=Testo in alto: spost. verticale
en=Top text: vertical offset
nap=Testo 'ncoppa: spust. verticale
bro=Testo sopra: sposta su/giù
es=Texto superior: desplaz. vertical
fr=Texte du haut : décalage vertical
de=Text oben: vert. verschieben
pt=Texto de cima: desl. vertical
ru=Верхний текст: сдвиг по вертикали
ko=상단 텍스트: 세로 이동
zh=上方文字:垂直偏移
ja=上テキスト: 垂直オフセット
it=Testo in basso: spost. orizzontale
en=Bottom text: horizontal offset
nap=Testo abbascio: spust. orizzontale
bro=Testo sotto: sposta dx/sx
es=Texto inferior: desplaz. horizontal
fr=Texte du bas : décalage horizontal
de=Text unten: horiz. verschieben
pt=Texto de baixo: desl. horizontal
ru=Нижний текст: сдвиг по горизонтали
ko=하단 텍스트: 가로 이동
zh=下方文字:水平偏移
ja=下テキスト: 水平オフセット
it=Testo in basso: spost. verticale
en=Bottom text: vertical offset
nap=Testo abbascio: spust. verticale
bro=Testo sotto: sposta su/giù
es=Texto inferior: desplaz. vertical
fr=Texte du bas : décalage vertical
de=Text unten: vert. verschieben
pt=Texto de baixo: desl. vertical
ru=Нижний текст: сдвиг по вертикали
ko=하단 텍스트: 세로 이동
zh=下方文字:垂直偏移
ja=下テキスト: 垂直オフセット
it=Colore testo
en=Text color
nap=Culore d'o testo
bro=Colore testo
es=Color del texto
fr=Couleur du texte
de=Textfarbe
pt=Cor do texto
ru=Цвет текста
ko=텍스트 색상
zh=文字颜色
ja=テキスト色
it=Colore contorno testo
en=Text outline color
nap=Culore d'o cuntorno d'o testo
bro=Colore bordo testo
es=Color del contorno del texto
fr=Couleur du contour du texte
de=Farbe der Textkontur
pt=Cor do contorno do texto
ru=Цвет контура текста
ko=텍스트 외곽선 색상
zh=文字描边颜色
ja=テキスト輪郭色
it=Forma dell'icona
en=Icon shape
nap=Forma d'a icona
bro=Shape dell'icona
es=Forma del icono
fr=Forme de l'icône
de=Symbolform
pt=Forma do ícone
ru=Форма иконки
ko=아이콘 모양
zh=图标形状
ja=アイコン形状
it=Testo in alto
en=Top text
nap=Testo 'ncoppa
bro=Testo sopra
es=Texto superior
fr=Texte du haut
de=Text oben
pt=Texto de cima
ru=Верхний текст
ko=상단 텍스트
zh=上方文字
ja=上テキスト
it=Emoji
en=Emoji
nap=Emoji
bro=Emoji
es=Emoji
fr=Emoji
de=Emoji
pt=Emoji
ru=Эмодзи
ko=이모지
zh=Emoji
ja=絵文字
it=Testo in basso
en=Bottom text
nap=Testo abbascio
bro=Testo sotto
es=Texto inferior
fr=Texte du bas
de=Text unten
pt=Texto de baixo
ru=Нижний текст
ko=하단 텍스트
zh=下方文字
ja=下テキスト
)" "`n"
        s .= "
(
it=Icona visibile
en=Icon visible
nap=Icona ca se vede
bro=Icona visibile
es=Icono visible
fr=Icône visible
de=Symbol sichtbar
pt=Ícone visível
ru=Иконка видна
ko=아이콘 표시
zh=图标可见
ja=アイコン表示
it=Effetti attivi
en=Active effects
nap=Effette appicciate
bro=Effetti accesi
es=Efectos activos
fr=Effets actifs
de=Aktive Effekte
pt=Efeitos ativos
ru=Активные эффекты
ko=활성 효과
zh=启用的特效
ja=有効なエフェクト
it=Spazio per gli effetti
en=Effects padding
nap=Spazio pe' ll'effette
bro=Spazio per gli effetti
es=Espacio para los efectos
fr=Espace pour les effets
de=Platz für Effekte
pt=Espaço para os efeitos
ru=Запас под эффекты
ko=효과 여백
zh=特效边距
ja=エフェクト用余白
it=Pulse: durata respiro (ms)
en=Pulse: breath length (ms)
nap=Pulse: durata d'o rispiro (ms)
bro=Pulse: durata respiro (ms)
es=Pulse: duración de la respiración (ms)
fr=Pulse : durée de la respiration (ms)
de=Pulse: Atemdauer (ms)
pt=Pulse: duração da respiração (ms)
ru=Pulse: длительность вдоха (ms)
ko=Pulse: 호흡 주기 (ms)
zh=Pulse:呼吸时长 (ms)
ja=Pulse: 呼吸時間 (ms)
it=Pulse: estensione alone
en=Pulse: halo size
nap=Pulse: quanto s'allarga ll'alone
bro=Pulse: quanto si allarga
es=Pulse: extensión del halo
fr=Pulse : étendue du halo
de=Pulse: Ausdehnung des Halos
pt=Pulse: extensão do halo
ru=Pulse: размер ореола
ko=Pulse: 후광 크기
zh=Pulse:光晕范围
ja=Pulse: ハローの広がり
it=Pulse: intensità
en=Pulse: intensity
nap=Pulse: forza
bro=Pulse: potenza
es=Pulse: intensidad
fr=Pulse : intensité
de=Pulse: Intensität
pt=Pulse: intensidade
ru=Pulse: интенсивность
ko=Pulse: 강도
zh=Pulse:强度
ja=Pulse: 強度
it=Pulse: colore
en=Pulse: color
nap=Pulse: culore
bro=Pulse: colore
es=Pulse: color
fr=Pulse : couleur
de=Pulse: Farbe
pt=Pulse: cor
ru=Pulse: цвет
ko=Pulse: 색상
zh=Pulse:颜色
ja=Pulse: 色
it=Ring: durata onda (ms)
en=Ring: wave length (ms)
nap=Ring: durata d'a onda (ms)
bro=Ring: durata onda (ms)
es=Ring: duración de la onda (ms)
fr=Ring : durée de l'onde (ms)
de=Ring: Wellendauer (ms)
pt=Ring: duração da onda (ms)
ru=Ring: длительность волны (ms)
ko=Ring: 파동 주기 (ms)
zh=Ring:波纹时长 (ms)
ja=Ring: 波の持続時間 (ms)
it=Ring: onde insieme
en=Ring: waves at once
nap=Ring: onde 'nsieme
bro=Ring: onde insieme
es=Ring: ondas simultáneas
fr=Ring : ondes simultanées
de=Ring: gleichzeitige Wellen
pt=Ring: ondas simultâneas
ru=Ring: волн одновременно
ko=Ring: 동시 파동 수
zh=Ring:同时波纹数
ja=Ring: 同時波数
it=Ring: distanza percorsa
en=Ring: distance traveled
nap=Ring: strada fatta
bro=Ring: quanto va lontano
es=Ring: distancia recorrida
fr=Ring : distance parcourue
de=Ring: zurückgelegte Strecke
pt=Ring: distância percorrida
ru=Ring: пройденное расстояние
ko=Ring: 이동 거리
zh=Ring:扩散距离
ja=Ring: 移動距離
it=Ring: spessore
en=Ring: thickness
nap=Ring: spessore
bro=Ring: spessore
es=Ring: grosor
fr=Ring : épaisseur
de=Ring: Stärke
pt=Ring: espessura
ru=Ring: толщина
ko=Ring: 두께
zh=Ring:粗细
ja=Ring: 太さ
it=Ring: intensità
en=Ring: intensity
nap=Ring: forza
bro=Ring: potenza
es=Ring: intensidad
fr=Ring : intensité
de=Ring: Intensität
pt=Ring: intensidade
ru=Ring: интенсивность
ko=Ring: 강도
zh=Ring:强度
ja=Ring: 強度
it=Ring: colore
en=Ring: color
nap=Ring: culore
bro=Ring: colore
es=Ring: color
fr=Ring : couleur
de=Ring: Farbe
pt=Ring: cor
ru=Ring: цвет
ko=Ring: 색상
zh=Ring:颜色
ja=Ring: 色
it=Spin: durata giro (ms)
en=Spin: lap length (ms)
nap=Spin: durata d'o giro (ms)
bro=Spin: durata giro (ms)
es=Spin: duración de la vuelta (ms)
fr=Spin : durée du tour (ms)
de=Spin: Rundendauer (ms)
pt=Spin: duração da volta (ms)
ru=Spin: длительность оборота (ms)
ko=Spin: 회전 주기 (ms)
zh=Spin:旋转一圈时长 (ms)
ja=Spin: 1周の時間 (ms)
it=Spin: lunghezza arco (gradi)
en=Spin: arc length (degrees)
nap=Spin: lunghezza d'o arco (grade)
bro=Spin: lunghezza arco (gradi)
es=Spin: longitud del arco (grados)
fr=Spin : longueur de l'arc (degrés)
de=Spin: Bogenlänge (Grad)
pt=Spin: comprimento do arco (graus)
ru=Spin: длина дуги (градусы)
ko=Spin: 호 길이 (도)
zh=Spin:弧长 (度)
ja=Spin: 弧の長さ (度)
it=Spin: spessore
en=Spin: thickness
nap=Spin: spessore
bro=Spin: spessore
es=Spin: grosor
fr=Spin : épaisseur
de=Spin: Stärke
pt=Spin: espessura
ru=Spin: толщина
ko=Spin: 두께
zh=Spin:粗细
ja=Spin: 太さ
it=Spin: colore
en=Spin: color
nap=Spin: culore
bro=Spin: colore
es=Spin: color
fr=Spin : couleur
de=Spin: Farbe
pt=Spin: cor
ru=Spin: цвет
ko=Spin: 색상
zh=Spin:颜色
ja=Spin: 色
it=Glow: durata pulsazione (ms)
en=Glow: pulse length (ms)
nap=Glow: durata d'a pulsazione (ms)
bro=Glow: durata pulsazione (ms)
es=Glow: duración del pulso (ms)
fr=Glow : durée de la pulsation (ms)
de=Glow: Pulsdauer (ms)
pt=Glow: duração da pulsação (ms)
ru=Glow: длительность пульсации (ms)
ko=Glow: 점멸 주기 (ms)
zh=Glow:脉动时长 (ms)
ja=Glow: 点滅時間 (ms)
it=Glow: colore
en=Glow: color
nap=Glow: culore
bro=Glow: colore
es=Glow: color
fr=Glow : couleur
de=Glow: Farbe
pt=Glow: cor
ru=Glow: цвет
ko=Glow: 색상
zh=Glow:颜色
ja=Glow: 色
it=Glow: intensità
en=Glow: intensity
nap=Glow: forza
bro=Glow: potenza
es=Glow: intensidad
fr=Glow : intensité
de=Glow: Intensität
pt=Glow: intensidade
ru=Glow: интенсивность
ko=Glow: 강도
zh=Glow:强度
ja=Glow: 強度
it=Intervallo fotogrammi (ms)
en=Frame interval (ms)
nap=Intervallo tra 'e fotogramme (ms)
bro=Intervallo frame (ms)
es=Intervalo de fotogramas (ms)
fr=Intervalle d'images (ms)
de=Bildintervall (ms)
pt=Intervalo de quadros (ms)
ru=Интервал кадров (ms)
ko=프레임 간격 (ms)
zh=帧间隔 (ms)
ja=フレーム間隔 (ms)
it=Dissolvenza in entrata (s)
en=Fade in (s)
nap=Dissolvenza quanno trase (s)
bro=Fade in (s)
es=Fundido de entrada (s)
fr=Fondu d'entrée (s)
de=Einblenden (s)
pt=Fade in (s)
ru=Плавное появление (s)
ko=페이드 인 (s)
zh=淡入 (s)
ja=フェードイン (s)
it=Dissolvenza in uscita (s)
en=Fade out (s)
nap=Dissolvenza quanno esce (s)
bro=Fade out (s)
es=Fundido de salida (s)
fr=Fondu de sortie (s)
de=Ausblenden (s)
pt=Fade out (s)
ru=Плавное исчезновение (s)
ko=페이드 아웃 (s)
zh=淡出 (s)
ja=フェードアウト (s)
it=Dissolvenze morbide
en=Smooth fades
nap=Dissolvenze morbide
bro=Fade smooth
es=Fundidos suaves
fr=Fondus doux
de=Weiche Übergänge
pt=Fades suaves
ru=Мягкие переходы
ko=부드러운 페이드
zh=平滑淡入淡出
ja=滑らかなフェード
it=Sfumatura al colore attivo (s)
en=Fade to active color (s)
nap=Sfumatura â culore appicciato (s)
bro=Fade al colore acceso (s)
es=Transición al color activo (s)
fr=Fondu vers la couleur active (s)
de=Verlauf zur Aktivfarbe (s)
pt=Transição para a cor ativa (s)
ru=Переход к активному цвету (s)
ko=활성 색상으로 전환 (s)
zh=渐变到激活颜色 (s)
ja=有効色へのフェード (s)
it=Sfumatura al colore inattivo (s)
en=Fade to idle color (s)
nap=Sfumatura â culore stutato (s)
bro=Fade al colore chill (s)
es=Transición al color inactivo (s)
fr=Fondu vers la couleur inactive (s)
de=Verlauf zur Inaktivfarbe (s)
pt=Transição para a cor inativa (s)
ru=Переход к неактивному цвету (s)
ko=비활성 색상으로 전환 (s)
zh=渐变到未激活颜色 (s)
ja=無効色へのフェード (s)
it=Icone: accensione effetti (s)
en=Icons: effects on (s)
nap=Icone: appicciatura effette (s)
bro=Icone: effetti on (s)
es=Iconos: encendido de efectos (s)
fr=Icônes : allumage des effets (s)
de=Symbole: Effekte an (s)
pt=Ícones: ativação dos efeitos (s)
ru=Иконки: включение эффектов (s)
ko=아이콘: 효과 켜짐 (s)
zh=图标:特效开启 (s)
ja=アイコン: エフェクト点灯 (s)
it=Icone: spegnimento effetti (s)
en=Icons: effects off (s)
nap=Icone: stutatura effette (s)
bro=Icone: effetti off (s)
es=Iconos: apagado de efectos (s)
fr=Icônes : extinction des effets (s)
de=Symbole: Effekte aus (s)
pt=Ícones: desativação dos efeitos (s)
ru=Иконки: выключение эффектов (s)
ko=아이콘: 효과 꺼짐 (s)
zh=图标:特效关闭 (s)
ja=アイコン: エフェクト消灯 (s)
it=Icone: dissolvenza in uscita (s)
en=Icons: fade out (s)
nap=Icone: dissolvenza quanno esce (s)
bro=Icone: fade out (s)
es=Iconos: fundido de salida (s)
fr=Icônes : fondu de sortie (s)
de=Symbole: Ausblenden (s)
pt=Ícones: fade out (s)
ru=Иконки: плавное исчезновение (s)
ko=아이콘: 페이드 아웃 (s)
zh=图标:淡出 (s)
ja=アイコン: フェードアウト (s)
it=Icone: sfumatura colore (s)
en=Icons: color fade (s)
nap=Icone: sfumatura d'o culore (s)
bro=Icone: fade colore (s)
es=Iconos: transición de color (s)
fr=Icônes : fondu de couleur (s)
de=Symbole: Farbverlauf (s)
pt=Ícones: transição de cor (s)
ru=Иконки: переход цвета (s)
ko=아이콘: 색상 전환 (s)
zh=图标:颜色渐变 (s)
ja=アイコン: 色のフェード (s)
it=Mirino: dissolvenza in entrata
en=Crosshair: fade in
nap=Mirino: dissolvenza quanno trase
bro=Mirino: fade in
es=Mira: fundido de entrada
fr=Viseur : fondu d'entrée
de=Fadenkreuz: Einblenden
pt=Mira: fade in
ru=Прицел: плавное появление
ko=조준선: 페이드 인
zh=准星:淡入
ja=照準: フェードイン
it=Mirino: dissolvenza in uscita
en=Crosshair: fade out
nap=Mirino: dissolvenza quanno esce
bro=Mirino: fade out
es=Mira: fundido de salida
fr=Viseur : fondu de sortie
de=Fadenkreuz: Ausblenden
pt=Mira: fade out
ru=Прицел: плавное исчезновение
ko=조준선: 페이드 아웃
zh=准星:淡出
ja=照準: フェードアウト
it=Barra 1: dissolvenza in entrata
en=Bar 1: fade in
nap=Barra 1: dissolvenza quanno trase
bro=Barra 1: fade in
es=Barra 1: fundido de entrada
fr=Barre 1 : fondu d'entrée
de=Balken 1: Einblenden
pt=Barra 1: fade in
ru=Полоса 1: плавное появление
ko=바 1: 페이드 인
zh=条 1:淡入
ja=バー1: フェードイン
)" "`n"
        s .= "
(
it=Barra 1: dissolvenza in uscita
en=Bar 1: fade out
nap=Barra 1: dissolvenza quanno esce
bro=Barra 1: fade out
es=Barra 1: fundido de salida
fr=Barre 1 : fondu de sortie
de=Balken 1: Ausblenden
pt=Barra 1: fade out
ru=Полоса 1: плавное исчезновение
ko=바 1: 페이드 아웃
zh=条 1:淡出
ja=バー1: フェードアウト
it=Barra 2: dissolvenza in entrata
en=Bar 2: fade in
nap=Barra 2: dissolvenza quanno trase
bro=Barra 2: fade in
es=Barra 2: fundido de entrada
fr=Barre 2 : fondu d'entrée
de=Balken 2: Einblenden
pt=Barra 2: fade in
ru=Полоса 2: плавное появление
ko=바 2: 페이드 인
zh=条 2:淡入
ja=バー2: フェードイン
it=Barra 2: dissolvenza in uscita
en=Bar 2: fade out
nap=Barra 2: dissolvenza quanno esce
bro=Barra 2: fade out
es=Barra 2: fundido de salida
fr=Barre 2 : fondu de sortie
de=Balken 2: Ausblenden
pt=Barra 2: fade out
ru=Полоса 2: плавное исчезновение
ko=바 2: 페이드 아웃
zh=条 2:淡出
ja=バー2: フェードアウト
it=Icone: dissolvenza in entrata
en=Icons: fade in
nap=Icone: dissolvenza quanno trase
bro=Icone: fade in
es=Iconos: fundido de entrada
fr=Icônes : fondu d'entrée
de=Symbole: Einblenden
pt=Ícones: fade in
ru=Иконки: плавное появление
ko=아이콘: 페이드 인
zh=图标:淡入
ja=アイコン: フェードイン
it=Icone: dissolvenza in uscita
en=Icons: fade out
nap=Icone: dissolvenza quanno esce
bro=Icone: fade out
es=Iconos: fundido de salida
fr=Icônes : fondu de sortie
de=Symbole: Ausblenden
pt=Ícones: fade out
ru=Иконки: плавное исчезновение
ko=아이콘: 페이드 아웃
zh=图标:淡出
ja=アイコン: フェードアウト
it=Attivo all'avvio
en=On at startup
nap=Appicciato a ll'avvio
bro=Acceso all'avvio
es=Activo al inicio
fr=Actif au démarrage
de=Beim Start an
pt=Ativo na inicialização
ru=Включено при запуске
ko=시작 시 켜기
zh=启动时开启
ja=起動時に有効
it=Controllo ogni (ms)
en=Check every (ms)
nap=Cuntrollo ogne (ms)
bro=Check ogni (ms)
es=Revisar cada (ms)
fr=Vérification toutes les (ms)
de=Prüfung alle (ms)
pt=Verificar a cada (ms)
ru=Проверять каждые (ms)
ko=확인 주기 (ms)
zh=检查间隔 (ms)
ja=チェック間隔 (ms)
it=Richiedi slot della chiave
en=Require the key slot
nap=Vo' pure 'o slot d'a chiave
bro=Vuole anche lo slot chiave
es=Exigir el slot de la llave
fr=Exiger le slot de la clé
de=Schlüssel-Slot verlangen
pt=Exigir o slot da chave
ru=Требовать слот ключа
ko=열쇠 슬롯 필요
zh=需要钥匙栏位
ja=キースロットを必須にする
it=Correzione punto X
en=Point correction X
nap=Correzione d'o punto X
bro=Ritocco punto X
es=Corrección del punto X
fr=Correction du point X
de=Punktkorrektur X
pt=Correção do ponto X
ru=Поправка точки X
ko=지점 보정 X
zh=X 点位修正
ja=ポイント補正 X
it=Correzione punto Y
en=Point correction Y
nap=Correzione d'o punto Y
bro=Ritocco punto Y
es=Corrección del punto Y
fr=Correction du point Y
de=Punktkorrektur Y
pt=Correção do ponto Y
ru=Поправка точки Y
ko=지점 보정 Y
zh=Y 点位修正
ja=ポイント補正 Y
it=Blocca il mouse sul pulsante
en=Lock the mouse on the button
nap=Blocca 'o mouse 'ncopp'ô pulsante
bro=Lock del mouse sul bottone
es=Bloquear el ratón en el botón
fr=Verrouiller la souris sur le bouton
de=Maus auf dem Button sperren
pt=Travar o mouse no botão
ru=Фиксировать мышь на кнопке
ko=버튼에 마우스 고정
zh=将鼠标锁定在按钮上
ja=ボタンにマウスを固定
it=Rigidità del blocco (ms)
en=Lock stiffness (ms)
nap=Durezza d'o blocco (ms)
bro=Quanto è tosto il lock (ms)
es=Rigidez del bloqueo (ms)
fr=Rigidité du verrou (ms)
de=Härte der Sperre (ms)
pt=Rigidez da trava (ms)
ru=Жёсткость фиксации (ms)
ko=고정 강도 (ms)
zh=锁定灵敏度 (ms)
ja=固定の硬さ (ms)
it=Riattivazione dopo (ms)
en=Re-arm after (ms)
nap=Se riappiccia doppo (ms)
bro=Si riarma dopo (ms)
es=Reactivación tras (ms)
fr=Réactivation après (ms)
de=Neu bereit nach (ms)
pt=Reativação após (ms)
ru=Повторное включение через (ms)
ko=재활성화까지 (ms)
zh=重新待命时间 (ms)
ja=再有効化まで (ms)
it=Click automatico
en=Automatic click
nap=Click automatico
bro=Click automatico
es=Clic automático
fr=Clic automatique
de=Automatischer Klick
pt=Clique automático
ru=Автоклик
ko=자동 클릭
zh=自动点击
ja=自動クリック
it=Ritardo click automatico (ms)
en=Automatic click delay (ms)
nap=Ritardo d'o click automatico (ms)
bro=Ritardo click automatico (ms)
es=Retardo del clic automático (ms)
fr=Délai du clic automatique (ms)
de=Verzögerung Auto-Klick (ms)
pt=Atraso do clique automático (ms)
ru=Задержка автоклика (ms)
ko=자동 클릭 지연 (ms)
zh=自动点击延迟 (ms)
ja=自動クリック遅延 (ms)
it=Avviso di riconoscimento
en=Recognition notice
nap=Avviso quanno 'o riconosce
bro=Avviso quando sgama
es=Aviso de reconocimiento
fr=Avis de reconnaissance
de=Erkennungshinweis
pt=Aviso de reconhecimento
ru=Уведомление о распознавании
ko=인식 알림
zh=识别提示
ja=認識通知
it=Guida all'apertura della mappa
en=Guide when the map opens
nap=Guida quanno s'arape 'a mappa
bro=Guida quando apri la mappa
es=Guía al abrir el mapa
fr=Guide à l'ouverture de la carte
de=Anleitung beim Öffnen der Karte
pt=Guia ao abrir o mapa
ru=Подсказка при открытии карты
ko=지도 열 때 안내
zh=打开地图时的引导
ja=マップを開いた時のガイド
it=Controllo mappa ogni (ms)
en=Map check every (ms)
nap=Cuntrollo d'a mappa ogne (ms)
bro=Check mappa ogni (ms)
es=Revisar el mapa cada (ms)
fr=Vérification carte toutes les (ms)
de=Kartenprüfung alle (ms)
pt=Verificar mapa a cada (ms)
ru=Проверка карты каждые (ms)
ko=지도 확인 주기 (ms)
zh=地图检查间隔 (ms)
ja=マップチェック間隔 (ms)
it=Blocca il mouse
en=Lock the mouse
nap=Blocca 'o mouse
bro=Lock del mouse
es=Bloquear el ratón
fr=Verrouiller la souris
de=Maus sperren
pt=Travar o mouse
ru=Блокировать мышь
ko=마우스 고정
zh=锁定鼠标
ja=マウスをロック
it=Blocca i click tra le fasi
en=Block clicks between steps
nap=Blocca 'e click tra 'e fase
bro=Blocca i click tra gli step
es=Bloquear clics entre pasos
fr=Bloquer les clics entre les étapes
de=Klicks zwischen Schritten sperren
pt=Bloquear cliques entre os passos
ru=Блокировать клики между шагами
ko=단계 사이 클릭 차단
zh=步骤之间屏蔽点击
ja=手順間のクリックをブロック
it=Istruzioni grandi a schermo
en=Big on-screen instructions
nap=Struzziune grosse a schermo
bro=Dritte grosse a schermo
es=Instrucciones grandes en pantalla
fr=Grandes instructions à l'écran
de=Große Anweisungen am Bildschirm
pt=Instruções grandes na tela
ru=Крупные подсказки на экране
ko=화면 큰 안내문
zh=屏幕大号指示
ja=大きな画面内案内
it=Dimensione istruzioni
en=Instructions size
nap=Grandezza d'e struzziune
bro=Size dritte
es=Tamaño de instrucciones
fr=Taille des instructions
de=Anweisungsgröße
pt=Tamanho das instruções
ru=Размер подсказок
ko=안내문 크기
zh=指示大小
ja=案内サイズ
it=Distanza dal basso
en=Distance from bottom
nap=Distanza 'a sotto
bro=Distanza dal fondo
es=Distancia desde abajo
fr=Distance du bas
de=Abstand von unten
pt=Distância de baixo
ru=Расстояние от низа
ko=하단 거리
zh=距底部距离
ja=下端からの距離
it=Dimensione pannello
en=Panel size
nap=Grandezza d'o pannello
bro=Size pannello
es=Tamaño del panel
fr=Taille du panneau
de=Panelgröße
pt=Tamanho do painel
ru=Размер панели
ko=패널 크기
zh=面板大小
ja=パネルサイズ
it=Distanza dal bordo destro
en=Distance from right edge
nap=Distanza d'o bordo deritto
bro=Distanza dal bordo destro
es=Distancia al borde derecho
fr=Distance du bord droit
de=Abstand vom rechten Rand
pt=Distância da borda direita
ru=Расстояние от правого края
ko=오른쪽 가장자리 거리
zh=距右边缘距离
ja=右端からの距離
it=Spostamento verticale
en=Vertical offset
nap=Spustamento verticale
bro=Sposta su/giù
es=Desplazamiento vertical
fr=Décalage vertical
de=Vertikale Verschiebung
pt=Deslocamento vertical
ru=Вертикальный сдвиг
ko=세로 이동
zh=垂直偏移
ja=垂直オフセット
it=Parte ridotto
en=Starts collapsed
nap=Parte stretto
bro=Parte chiuso
es=Empieza contraído
fr=Démarre réduit
de=Startet eingeklappt
pt=Começa recolhido
ru=Запуск свёрнутой
ko=축소된 상태로 시작
zh=默认收起
ja=折りたたんで開始
it=Dopo la scelta di un boss
en=After choosing a boss
nap=Doppo c'he scigliuto nu boss
bro=Dopo che scegli un boss
es=Tras elegir un boss
fr=Après le choix d'un boss
de=Nach der Wahl eines Bosses
pt=Depois de escolher um boss
ru=После выбора босса
ko=보스 선택 후
zh=选择首领后
ja=ボス選択後
it=Opacità in modalità fade
en=Opacity in fade mode
nap=Opacità in modalità fade
bro=Opacità in modalità fade
es=Opacidad en modo fade
fr=Opacité en mode fade
de=Deckkraft im Fade-Modus
pt=Opacidade no modo fade
ru=Непрозрачность в режиме fade
ko=페이드 모드 불투명도
zh=fade 模式不透明度
ja=フェード時の不透明度
it=Leggenda visibile
en=Legend visible
nap=Leggenda ca se vede
bro=Leggenda visibile
es=Leyenda visible
fr=Légende visible
de=Legende sichtbar
pt=Legenda visível
ru=Легенда видна
ko=범례 표시
zh=显示图例
ja=凡例を表示
it=Dimensione leggenda
en=Legend size
nap=Grandezza d'a leggenda
bro=Size leggenda
es=Tamaño de la leyenda
fr=Taille de la légende
de=Legendengröße
pt=Tamanho da legenda
ru=Размер легенды
ko=범례 크기
zh=图例大小
ja=凡例サイズ
it=Distanza dall'alto
en=Distance from top
nap=Distanza 'a coppa
bro=Distanza dall'alto
es=Distancia desde arriba
fr=Distance du haut
de=Abstand von oben
pt=Distância do topo
ru=Расстояние от верха
ko=상단 거리
zh=距顶部距离
ja=上端からの距離
it=Opacità leggenda
en=Legend opacity
nap=Opacità d'a leggenda
bro=Opacità leggenda
es=Opacidad de la leyenda
fr=Opacité de la légende
de=Deckkraft der Legende
pt=Opacidade da legenda
ru=Непрозрачность легенды
ko=범례 불투명도
zh=图例不透明度
ja=凡例の不透明度
)" "`n"
        s .= "
(
it=Scrollate lista boss
en=Boss list scrolls
nap=Scrollate d'a lista boss
bro=Scrollate lista boss
es=Desplazamientos de la lista de bosses
fr=Défilements de la liste des boss
de=Scrolls der Boss-Liste
pt=Rolagens da lista de bosses
ru=Прокруток списка боссов
ko=보스 목록 스크롤 횟수
zh=首领列表滚动次数
ja=ボスリストのスクロール数
it=Cerca il Teleport più vicino
en=Find the nearest Teleport
nap=Cerca 'o Teleport cchiù vicino
bro=Sgama il Teleport più vicino
es=Buscar el Teleport más cercano
fr=Chercher le Teleport le plus proche
de=Nächsten Teleport suchen
pt=Procurar o Teleport mais próximo
ru=Искать ближайший Teleport
ko=가장 가까운 Teleport 찾기
zh=查找最近的 Teleport
ja=最寄りの Teleport を検索
it=Zoom indietro automatico
en=Automatic zoom out
nap=Zoom arreto automatico
bro=Zoom out automatico
es=Alejar el zoom automáticamente
fr=Dézoom automatique
de=Automatisch herauszoomen
pt=Zoom out automático
ru=Автоматическое отдаление
ko=자동 축소
zh=自动缩小地图
ja=自動ズームアウト
it=Scrollate di zoom indietro
en=Zoom-out scrolls
nap=Scrollate 'e zoom arreto
bro=Scrollate di zoom out
es=Desplazamientos para alejar el zoom
fr=Défilements de dézoom
de=Scrolls zum Herauszoomen
pt=Rolagens de zoom out
ru=Прокруток для отдаления
ko=축소 스크롤 횟수
zh=缩小滚动次数
ja=ズームアウトのスクロール数
it=Scrollate di ritorno
en=Return scrolls
nap=Scrollate 'e ritorno
bro=Scrollate di ritorno
es=Desplazamientos de vuelta
fr=Défilements de retour
de=Scrolls zurück
pt=Rolagens de volta
ru=Прокруток обратно
ko=복귀 스크롤 횟수
zh=返回滚动次数
ja=戻しのスクロール数
it=Rotellina per lo zoom indietro
en=Wheel direction for zoom out
nap=Rutella pe' 'o zoom arreto
bro=Rotella per lo zoom out
es=Sentido de la rueda para alejar el zoom
fr=Molette pour le dézoom
de=Mausrad zum Herauszoomen
pt=Direção da roda para zoom out
ru=Направление колеса для отдаления
ko=축소용 휠 방향
zh=缩小地图的滚轮方向
ja=ズームアウトのホイール方向
it=Chiudi il riquadro dei loot
en=Close the loot box
nap=Chiure 'o riquadro d'e loot
bro=Chiudi il pannello loot
es=Cerrar el recuadro de botín
fr=Fermer la fenêtre de butin
de=Loot-Fenster schließen
pt=Fechar a caixa de loot
ru=Закрывать окно добычи
ko=전리품 창 닫기
zh=关闭战利品框
ja=ドロップ枠を閉じる
it=Distanza del punto vuoto
en=Empty spot distance
nap=Distanza d'o punto vacante
bro=Distanza del punto vuoto
es=Distancia del punto vacío
fr=Distance du point vide
de=Abstand der leeren Stelle
pt=Distância do ponto vazio
ru=Расстояние до пустого места
ko=빈 지점 거리
zh=空白点距离
ja=空きスペースまでの距離
it=Pressioni di F per partire
en=F presses to depart
nap=Pressiune 'e F pe' partì
bro=Botte di F per partire
es=Pulsaciones de F para partir
fr=Appuis sur F pour partir
de=F-Drücke zum Start
pt=Pressões de F para partir
ru=Нажатий F для отправления
ko=출발용 F 입력 횟수
zh=出发所需按 F 次数
ja=出発に必要な F の回数
it=Attesa del Travel (s)
en=Travel wait (s)
nap=Attesa d'o Travel (s)
bro=Attesa del Travel (s)
es=Espera del Travel (s)
fr=Attente du Travel (s)
de=Travel-Wartezeit (s)
pt=Espera do Travel (s)
ru=Ожидание Travel (s)
ko=Travel 대기 (s)
zh=Travel 等待时间 (s)
ja=Travel 待機 (s)
it=Mostra la direzione del boss
en=Show the boss direction
nap=Fa' vedé 'a direzione d'o boss
bro=Mostra dove sta il boss
es=Mostrar la dirección del boss
fr=Afficher la direction du boss
de=Boss-Richtung anzeigen
pt=Mostrar a direção do boss
ru=Показывать направление к боссу
ko=보스 방향 표시
zh=显示首领方向
ja=ボスの方向を表示
it=Durata indicazione (s)
en=Indication duration (s)
nap=Durata d'a indicazione (s)
bro=Durata freccia (s)
es=Duración del aviso (s)
fr=Durée de l'indication (s)
de=Anzeigedauer (s)
pt=Duração da indicação (s)
ru=Длительность подсказки (s)
ko=안내 표시 시간 (s)
zh=指示持续时间 (s)
ja=方向表示の時間 (s)
it=Ritardo indicazione (ms)
en=Indication delay (ms)
nap=Ritardo d'a indicazione (ms)
bro=Ritardo freccia (ms)
es=Retardo del aviso (ms)
fr=Délai de l'indication (ms)
de=Anzeigeverzögerung (ms)
pt=Atraso da indicação (ms)
ru=Задержка подсказки (ms)
ko=안내 지연 (ms)
zh=指示延迟 (ms)
ja=方向表示の遅延 (ms)
it=Dimensione indicazione
en=Indication size
nap=Grandezza d'a indicazione
bro=Size freccia
es=Tamaño del aviso
fr=Taille de l'indication
de=Anzeigegröße
pt=Tamanho da indicação
ru=Размер подсказки
ko=안내 크기
zh=指示大小
ja=方向表示のサイズ
@=Language
en=Language of settings, notices and on-screen instructions:\n"english" | "italiano" | "spanish" | "french" | "german" | "portuguese" | "russian" | "korean" | "chinese" | "japanese" | "napoletano" | "bro"\nIn the settings it applies right away; in game after "Save and restart".
nap=Lengua d'e mpustaziune, d'e avvise e d'e struzziune a schermo:\n"english" | "italiano" | "spanish" | "french" | "german" | "portuguese" | "russian" | "korean" | "chinese" | "japanese" | "napoletano" | "bro"\nDint'ê mpustaziune vale subbito; int'ô juoco doppo "Sarva e riparte".
bro=Lingua di settaggi, avvisi e dritte a schermo:\n"english" | "italiano" | "spanish" | "french" | "german" | "portuguese" | "russian" | "korean" | "chinese" | "japanese" | "napoletano" | "bro"\nNei settaggi cambia subito; nel gioco dopo "Salva e riparti".
es=Idioma de los ajustes, avisos e instrucciones en pantalla:\n"english" | "italiano" | "spanish" | "french" | "german" | "portuguese" | "russian" | "korean" | "chinese" | "japanese" | "napoletano" | "bro"\nEn los ajustes se aplica al instante; en el juego tras "Guardar y reiniciar".
fr=Langue des paramètres, avis et instructions à l'écran :\n"english" | "italiano" | "spanish" | "french" | "german" | "portuguese" | "russian" | "korean" | "chinese" | "japanese" | "napoletano" | "bro"\nDans les paramètres elle s'applique tout de suite ; en jeu après "Sauver et relancer".
de=Sprache der Einstellungen, Hinweise und Bildschirmanweisungen:\n"english" | "italiano" | "spanish" | "french" | "german" | "portuguese" | "russian" | "korean" | "chinese" | "japanese" | "napoletano" | "bro"\nIn den Einstellungen gilt sie sofort; im Spiel nach "Speichern+Neustart".
pt=Idioma das configurações, avisos e instruções na tela:\n"english" | "italiano" | "spanish" | "french" | "german" | "portuguese" | "russian" | "korean" | "chinese" | "japanese" | "napoletano" | "bro"\nNas configurações vale na hora; no jogo depois de "Salvar e reiniciar".
ru=Язык настроек, уведомлений и экранных подсказок:\n"english" | "italiano" | "spanish" | "french" | "german" | "portuguese" | "russian" | "korean" | "chinese" | "japanese" | "napoletano" | "bro"\nВ настройках применяется сразу; в игре - после "Сохр. и рестарт".
ko=설정, 알림, 화면 안내의 언어:\n"english" | "italiano" | "spanish" | "french" | "german" | "portuguese" | "russian" | "korean" | "chinese" | "japanese" | "napoletano" | "bro"\n설정에서는 바로 적용되고, 게임에서는 "저장 후 재시작" 후에 적용돼요.
zh=设置、提示和屏幕指示所使用的语言:\n"english" | "italiano" | "spanish" | "french" | "german" | "portuguese" | "russian" | "korean" | "chinese" | "japanese" | "napoletano" | "bro"\n在设置中立即生效;在游戏中需点击 "保存并重启" 后生效。
ja=設定、通知、画面内案内の言語:\n"english" | "italiano" | "spanish" | "french" | "german" | "portuguese" | "russian" | "korean" | "chinese" | "japanese" | "napoletano" | "bro"\n設定画面では即時反映され、ゲーム内では "保存して再起動" の後に反映されます。
@=GameExe
en=Name of the game process. HUD and tools only work\nwhile this window is in the foreground.
nap=Nomme d'o processo d'o juoco. HUD e tool funzionano\nsulo quanno chesta fenesta sta annanze.
bro=Nome del processo del gioco. HUD e tool vanno\nsolo quando questa finestra è davanti, easy.
es=Nombre del proceso del juego. El HUD y las herramientas solo funcionan\ncuando esta ventana está en primer plano.
fr=Nom du processus du jeu. Le HUD et les outils ne fonctionnent\nque lorsque cette fenêtre est au premier plan.
de=Name des Spielprozesses. HUD und Tools funktionieren nur,\nwenn dieses Fenster im Vordergrund ist.
pt=Nome do processo do jogo. O HUD e as ferramentas só funcionam\nenquanto esta janela estiver em primeiro plano.
ru=Имя процесса игры. HUD и инструменты работают только\nкогда это окно на переднем плане.
ko=게임 프로세스 이름이에요. HUD와 도구는 이 창이\n맨 앞에 있을 때만 작동해요.
zh=游戏进程名称。HUD 和工具仅在该窗口位于前台时\n才会工作。
ja=ゲームのプロセス名。HUD とツールは\nこのウィンドウが前面にあるときのみ動作します。
)" "`n"
        s .= "
(
@=ClickThrough
en=true  = mouse clicks "pass through" the HUD and reach the game\nfalse = the HUD blocks clicks where it is drawn
nap=true  = 'e click d'o mouse "passano" pe' ll'HUD e arrivano 'o juoco\nfalse = ll'HUD blocca 'e click addò sta disegnato
bro=true  = i click del mouse "passano" l'HUD e arrivano al gioco\nfalse = l'HUD si mangia i click dove è disegnato
es=true  = los clics del ratón "atraviesan" el HUD y llegan al juego\nfalse = el HUD bloquea los clics donde está dibujado
fr=true  = les clics de souris "traversent" le HUD et arrivent au jeu\nfalse = le HUD bloque les clics là où il est dessiné
de=true  = Mausklicks "gehen durch" das HUD und erreichen das Spiel\nfalse = das HUD blockiert Klicks dort, wo es gezeichnet ist
pt=true  = os cliques do mouse "atravessam" o HUD e chegam ao jogo\nfalse = o HUD bloqueia os cliques onde está desenhado
ru=true  = клики мыши "проходят сквозь" HUD и попадают в игру\nfalse = HUD блокирует клики там, где он нарисован
ko=true  = 마우스 클릭이 HUD를 "통과"해 게임에 전달돼요\nfalse = HUD가 그려진 곳에서는 클릭이 차단돼요
zh=true  = 鼠标点击会 "穿过" HUD 直接作用于游戏\nfalse = HUD 会拦截其绘制区域内的点击
ja=true  = マウスクリックが HUD を "通過" してゲームに届く\nfalse = HUD が描画されている部分ではクリックをブロックする
@=SplashEnabled
en=Startup splash: in the middle of the screen the app name, "by VaLeTecK" and, in small, the version grow from small\nto big going from transparent (20%) to solid (100%), stay for a moment and then fade away.\nfalse = no splash at startup
nap=Splash a ll'avvio: 'mmiezo 'o schermo 'o nomme d'a app, "by VaLeTecK" e, piccerillo, 'a versione crescono 'a piccerille\na gruosse passanno 'a trasparente (20%) a chine (100%), restano nu mumento e po' scumpareno.\nfalse = niente splash a ll'avvio
bro=Splash all'avvio: al centro dello schermo il nome dell'app, "by VaLeTecK" e, in piccolo, la versione crescono\nda piccoli a grandi da trasparenti (20%) a pieni (100%), restano un attimo e poi sparisce tutto. Flex.\nfalse = niente splash
es=Splash de inicio: en el centro de la pantalla el nombre de la app, "by VaLeTecK" y, en pequeño, la versión crecen de pequeño\na grande pasando de transparente (20%) a sólido (100%), se quedan un momento y luego se desvanecen.\nfalse = sin splash al inicio
fr=Splash au démarrage : au milieu de l'écran le nom de l'app, "by VaLeTecK" et, en petit, la version grandissent de petit\nà grand en passant de transparent (20%) à opaque (100%), restent un instant puis disparaissent en fondu.\nfalse = pas de splash au démarrage
de=Splash beim Start: In der Bildschirmmitte wachsen der App-Name, "by VaLeTecK" und, klein, die Version von klein\nzu groß und von transparent (20%) zu deckend (100%), bleiben kurz stehen und blenden dann aus.\nfalse = kein Splash beim Start
pt=Splash na inicialização: no meio da tela o nome do app, "by VaLeTecK" e, pequena, a versão crescem de pequenos\na grandes passando de transparente (20%) a sólido (100%), ficam um instante e depois somem em fade.\nfalse = sem splash na inicialização
ru=Заставка при запуске: в центре экрана название приложения, "by VaLeTecK" и, мелким шрифтом, версия увеличиваются от малого\nк большому, из прозрачных (20%) становясь плотными (100%), задерживаются на миг и затем исчезают.\nfalse = без заставки при запуске
ko=시작 스플래시: 화면 중앙에 앱 이름, "by VaLeTecK", 그리고 작게 버전이 나타나요. 투명(20%)에서 불투명(100%)으로 바뀌며 작은 크기에서\n큰 크기로 커지고, 잠시 머문 뒤 사라져요.\nfalse = 시작 시 스플래시 없음
zh=启动画面:在屏幕中央显示应用名称、"by VaLeTecK" 以及小字号的版本号,\n从小变大,同时由透明 (20%) 变为不透明 (100%),停留片刻后淡出。\nfalse = 启动时不显示启动画面
ja=起動時スプラッシュ: 画面中央にアプリ名、"by VaLeTecK"、小さくバージョンが、小から大へ\n拡大しながら透明 (20%) から不透明 (100%) になり、しばらく表示された後フェードアウトします。\nfalse = 起動時のスプラッシュなし
@=SplashHold
en=seconds it stays fully visible before fading away
nap=secondi ca resta chino a schermo primma 'e scumparì
bro=secondi che resta pieno a schermo prima di sparire
es=segundos que permanece totalmente visible antes de desvanecerse
fr=secondes pendant lesquelles il reste pleinement visible avant de disparaître
de=Sekunden, die er voll sichtbar bleibt, bevor er ausblendet
pt=segundos que fica totalmente visível antes de sumir
ru=секунд полной видимости перед исчезновением
ko=완전히 보이는 상태로 머문 뒤 사라지기까지의 초
zh=完全可见状态保持多少秒,然后淡出
ja=フェードアウトするまで完全に表示される秒数
@=SplashScale
en=size (1.0 = normal)
nap=grandezza (1.0 = normale)
bro=size (1.0 = normale)
es=tamaño (1.0 = normal)
fr=taille (1.0 = normale)
de=Größe (1.0 = normal)
pt=tamanho (1.0 = normal)
ru=размер (1.0 = обычный)
ko=크기 (1.0 = 기본)
zh=大小 (1.0 = 正常)
ja=サイズ (1.0 = 標準)
)" "`n"
        s .= "
(
@=PerfProfile
en=Performance profile: choose the one that fits your PC.\n"potato"      = very old PCs or laptops: minimum CPU use, slower reactions\n"base"        = low-end PCs: light but still smooth\n"bilanciato"  = recommended for most PCs (the classic values)\n"performante" = high-end PCs: smoother and more responsive\n"gigachad"    = top-tier PCs: everything hyper-responsive, maximum CPU use\n"manuale"     = the single values in the list apply, editable one by one
nap=Prufilo prestaziune: scigli chillo ca va bbuono pe' 'o PC tuoio.\n"potato"      = PC assaje viecchie o portatile: CPU quase niente, reazziune cchiù lente\n"base"        = PC 'e fascia bassa: leggero ma ancora scorre bbuono\n"bilanciato"  = consigliato pe' quase tutte 'e PC (e valure classice)\n"performante" = PC 'e fascia auta: cchiù fluido e cchiù pronto\n"gigachad"    = PC 'e primma categoria: tutto risponne subbito, CPU a tutta forza\n"manuale"     = valeno 'e valure singule d'a lista, ca se cagnano uno pe' uno
bro=Profilo performance: scegli quello giusto per il tuo PC bro.\n"potato"      = PC vecchissimi o portatili: CPU quasi zero, reazioni più lente\n"base"        = PC low budget: leggero ma ancora fluido\n"bilanciato"  = va bene per quasi tutti (i valori classici)\n"performante" = PC forti: più smooth e reattivo\n"gigachad"    = PC da flex: tutto iperreattivo, CPU a manetta\n"manuale"     = valgono i valori singoli della lista, li cambi uno per uno
es=Perfil de rendimiento: elige el que mejor le vaya a tu PC.\n"potato"      = PC o portátiles muy antiguos: uso mínimo de CPU, reacciones más lentas\n"base"        = PC de gama baja: ligero pero aún fluido\n"bilanciato"  = recomendado para la mayoría de PC (los valores clásicos)\n"performante" = PC de gama alta: más fluido y más reactivo\n"gigachad"    = PC de gama top: todo hiperreactivo, uso máximo de CPU\n"manuale"     = valen los valores individuales de la lista, editables uno a uno
fr=Profil de performances : choisis celui qui convient à ton PC.\n"potato"      = très vieux PC ou portables : usage CPU minimal, réactions plus lentes\n"base"        = PC d'entrée de gamme : léger mais toujours fluide\n"bilanciato"  = recommandé pour la plupart des PC (les valeurs classiques)\n"performante" = PC haut de gamme : plus fluide et plus réactif\n"gigachad"    = PC de très haut niveau : tout ultra-réactif, usage CPU maximal\n"manuale"     = les valeurs individuelles de la liste s'appliquent, modifiables une par une
de=Leistungsprofil: Wähle das, das zu deinem PC passt.\n"potato"      = sehr alte PCs oder Laptops: minimale CPU-Last, langsamere Reaktionen\n"base"        = schwache PCs: leicht, aber immer noch flüssig\n"bilanciato"  = für die meisten PCs empfohlen (die klassischen Werte)\n"performante" = starke PCs: flüssiger und reaktionsschneller\n"gigachad"    = Top-PCs: alles hyperreaktiv, maximale CPU-Last\n"manuale"     = die einzelnen Werte der Liste gelten, einzeln editierbar
pt=Perfil de desempenho: escolha o que combina com seu PC.\n"potato"      = PCs ou notebooks muito antigos: uso mínimo de CPU, reações mais lentas\n"base"        = PCs de entrada: leve mas ainda fluido\n"bilanciato"  = recomendado para a maioria dos PCs (os valores clássicos)\n"performante" = PCs potentes: mais fluido e mais reativo\n"gigachad"    = PCs topo de linha: tudo hiper-reativo, uso máximo de CPU\n"manuale"     = valem os valores individuais da lista, editáveis um a um
ru=Профиль производительности: выберите тот, что подходит вашему ПК.\n"potato"      = очень старые ПК или ноутбуки: минимум нагрузки на CPU, медленная реакция\n"base"        = слабые ПК: легко, но всё ещё плавно\n"bilanciato"  = рекомендуется для большинства ПК (классические значения)\n"performante" = мощные ПК: плавнее и отзывчивее\n"gigachad"    = топовые ПК: всё сверхотзывчиво, максимальная нагрузка на CPU\n"manuale"     = действуют отдельные значения из списка, редактируемые по одному
ko=성능 프로필: PC에 맞는 것을 고르세요.\n"potato"      = 매우 오래된 PC나 노트북: CPU 사용 최소, 반응 느림\n"base"        = 저사양 PC: 가볍지만 여전히 부드러움\n"bilanciato"  = 대부분의 PC에 권장 (기본 값)\n"performante" = 고사양 PC: 더 부드럽고 반응이 빠름\n"gigachad"    = 최상급 PC: 모든 것이 초고반응, CPU 사용 최대\n"manuale"     = 목록의 개별 값이 적용되며, 하나씩 수정할 수 있음
zh=性能配置档:请选择适合你电脑的档位。\n"potato"      = 非常老旧的电脑或笔记本:占用 CPU 最少,反应较慢\n"base"        = 低配电脑:轻量但依然流畅\n"bilanciato"  = 大多数电脑的推荐档位 (经典数值)\n"performante" = 高配电脑:更流畅、反应更灵敏\n"gigachad"    = 顶配电脑:一切极速响应,占用 CPU 最高\n"manuale"     = 以列表中的单项数值为准,可逐项编辑
ja=パフォーマンスプロファイル: お使いのPCに合ったものを選択します。\n"potato"      = 非常に古いPCやノートPC: CPU使用量最小、反応は遅め\n"base"        = ローエンドPC: 軽量でも滑らか\n"bilanciato"  = 大半のPCに推奨 (標準値)\n"performante" = ハイエンドPC: より滑らかで高反応\n"gigachad"    = 最上位PC: すべてが超高反応、CPU使用量最大\n"manuale"     = 一覧の個別の値が適用され、1つずつ編集可能
@=PerfWorkerTick
en=Values used only with PerfProfile "manuale":\nms of the Field Boss tool work cycle
nap=Valure ca servono sulo cu PerfProfile "manuale":\nms d'o ciclo 'e fatica d'o tool Field Boss
bro=Valori usati solo col PerfProfile "manuale":\nms del ciclo del tool Field Boss
es=Valores usados solo con PerfProfile "manuale":\nms del ciclo de trabajo de la herramienta Field Boss
fr=Valeurs utilisées uniquement avec PerfProfile "manuale" :\nms du cycle de travail de l'outil Field Boss
de=Werte, die nur mit PerfProfile "manuale" verwendet werden:\nms des Arbeitszyklus des Field Boss Tools
pt=Valores usados só com PerfProfile "manuale":\nms do ciclo de trabalho da ferramenta Field Boss
ru=Значения используются только с PerfProfile "manuale":\nms цикла работы инструмента Field Boss
ko=PerfProfile "manuale"에서만 쓰이는 값:\nField Boss 도구의 작업 주기 ms
zh=仅在 PerfProfile 为 "manuale" 时使用的数值:\nField Boss 工具工作周期的毫秒数
ja=PerfProfile "manuale" のときのみ使用する値:\nField Boss ツールの処理サイクル (ms)
@=PerfLockTick
en=ms between one mouse-lock check and the next (Field Boss)
nap=ms tra nu cuntrollo e n'ato d'o blocco d'o mouse (Field Boss)
bro=ms tra un check e l'altro del lock del mouse (Field Boss)
es=ms entre una comprobación del bloqueo del ratón y la siguiente (Field Boss)
fr=ms entre une vérification du verrou souris et la suivante (Field Boss)
de=ms zwischen einer Maussperren-Prüfung und der nächsten (Field Boss)
pt=ms entre uma verificação da trava do mouse e a seguinte (Field Boss)
ru=ms между одной проверкой блокировки мыши и следующей (Field Boss)
ko=마우스 고정 확인 사이의 ms (Field Boss)
zh=两次鼠标锁定检查之间的毫秒数 (Field Boss)
ja=マウスロックのチェック間隔 (ms) (Field Boss)
@=PerfPollMs
en=ms between one check and the next while waiting for your click or key
nap=ms tra nu cuntrollo e n'ato mentre aspetta nu click tuoio o nu tasto
bro=ms tra un check e l'altro mentre aspetta il tuo click o un tasto
es=ms entre una comprobación y la siguiente mientras se espera tu clic o tecla
fr=ms entre une vérification et la suivante en attendant ton clic ou ta touche
de=ms zwischen einer Prüfung und der nächsten, während auf deinen Klick oder deine Taste gewartet wird
pt=ms entre uma verificação e a seguinte enquanto espera seu clique ou tecla
ru=ms между одной проверкой и следующей, пока ждём ваш клик или клавишу
ko=클릭이나 키 입력을 기다리는 동안 확인 사이의 ms
zh=等待你点击或按键时,两次检查之间的毫秒数
ja=クリックまたはキー入力を待つ間のチェック間隔 (ms)
@=PerfRingTick
en=ms between one frame and the next of the pulsing ring
nap=ms tra nu fotogramma e n'ato 'e ll'anello ca pulsa
bro=ms tra un frame e l'altro dell'anello che pulsa
es=ms entre un fotograma y el siguiente del anillo pulsante
fr=ms entre une image et la suivante de l'anneau pulsant
de=ms zwischen einem Bild und dem nächsten des Pulsrings
pt=ms entre um quadro e o seguinte do anel pulsante
ru=ms между одним кадром и следующим у пульсирующего кольца
ko=펄스 링의 프레임 사이 ms
zh=脉冲圆环每帧之间的毫秒数
ja=パルスリングのフレーム間隔 (ms)
@=PerfOcrQuality
en=image magnification for OCR at 1440p (1 = light, 3 = accurate)
nap=quanto se ngrossa ll'immagine pe' ll'OCR a 1440p (1 = leggero, 3 = preciso)
bro=zoom dell'immagine per l'OCR a 1440p (1 = leggero, 3 = preciso)
es=aumento de la imagen para el OCR a 1440p (1 = ligero, 3 = preciso)
fr=grossissement de l'image pour l'OCR en 1440p (1 = léger, 3 = précis)
de=Bildvergrößerung für OCR bei 1440p (1 = leicht, 3 = genau)
pt=ampliação da imagem para o OCR em 1440p (1 = leve, 3 = preciso)
ru=увеличение изображения для OCR при 1440p (1 = быстро, 3 = точно)
ko=1440p에서 OCR용 이미지 확대 배율 (1 = 가벼움, 3 = 정확함)
zh=OCR 在 1440p 下的图像放大倍数 (1 = 轻量,3 = 精确)
ja=1440pでの OCR 用画像拡大率 (1 = 軽量、3 = 高精度)
)" "`n"
        s .= "
(
@=CombatKey
en=HUD - signals sent by your macros (the key still reaches the game too).\nHow to set up the macros: see [HUD] Behavior and colors.\nturns on crosshair + bars + Combat icon
nap=HUD - segnale ca mannano 'e macro toje ('o tasto arriva pure 'o juoco).\nComme se mettono 'e macro: vide [HUD] Comportamento e culure.\nappiccia mirino + barre + icona Combat
bro=HUD - segnali che mandano le tue macro (il tasto arriva lo stesso al gioco).\nCome settare le macro: guarda [HUD] Comportamento e colori.\naccende mirino + barre + icona Combat
es=HUD - señales enviadas por tus macros (la tecla llega también al juego).\nCómo configurar las macros: ver [HUD] General y macros.\nenciende mira + barras + icono Combat
fr=HUD - signaux envoyés par tes macros (la touche arrive quand même au jeu).\nComment configurer les macros : voir [HUD] Comportement et couleurs.\nallume viseur + barres + icône Combat
de=HUD - Signale, die deine Makros senden (die Taste erreicht auch das Spiel).\nSo richtest du die Makros ein: siehe [HUD] Verhalten und Farben.\nschaltet Fadenkreuz + Balken + Combat-Symbol ein
pt=HUD - sinais enviados pelas suas macros (a tecla chega ao jogo também).\nComo configurar as macros: veja [HUD] Comportamento e cores.\nliga mira + barras + ícone Combat
ru=HUD - сигналы, которые отправляют ваши макросы (клавиша всё равно доходит и до игры).\nКак настроить макросы: см. [HUD] Поведение и цвета.\nвключает прицел + полосы + иконку Combat
ko=HUD - 매크로가 보내는 신호예요 (키는 게임에도 그대로 전달돼요).\n매크로 설정 방법: [HUD] 동작과 색상 참고.\n조준선 + 바 + Combat 아이콘을 켜요
zh=HUD - 由你的宏发送的信号 (按键仍会传到游戏中)。\n宏的设置方法:见 [HUD] 行为和颜色。\n开启准星 + 条 + Combat 图标
ja=HUD - マクロから送られる信号 (キーはゲームにも届きます)。\nマクロの設定方法: [HUD] 動作と色 を参照。\n照準 + バー + Combat アイコンを点灯
@=LootKey
en=turns on the Loot icon
nap=appiccia ll'icona Loot
bro=accende l'icona Loot
es=enciende el icono Loot
fr=allume l'icône Loot
de=schaltet das Loot-Symbol ein
pt=liga o ícone Loot
ru=включает иконку Loot
ko=Loot 아이콘을 켜요
zh=开启 Loot 图标
ja=Loot アイコンを点灯
@=HiddenCubeToggleKey
en=On/off while you play (an ON/OFF notice appears, the legend on the map\nshows the state of each one)\nCtrl+Shift+1 = Hidden Cube ON/OFF
nap=Appiccia/stuta mentre juoche (esce n'avviso ON/OFF, 'a leggenda 'ncopp'â mappa\nfa vedé comme sta ognuno)\nCtrl+Shift+1 = Hidden Cube ON/OFF
bro=Accendi/spegni mentre giochi (spunta un avviso ON/OFF, la leggenda sulla mappa\nti fa vedere come sta ognuno)\nCtrl+Shift+1 = Hidden Cube ON/OFF
es=Activar/desactivar mientras juegas (aparece un aviso ON/OFF, la leyenda del mapa\nmuestra el estado de cada uno)\nCtrl+Shift+1 = Hidden Cube ON/OFF
fr=Activé/désactivé en jouant (un avis ON/OFF apparaît, la légende sur la carte\nmontre l'état de chacun)\nCtrl+Shift+1 = Hidden Cube ON/OFF
de=An/Aus während des Spielens (ein ON/OFF-Hinweis erscheint, die Legende auf der Karte\nzeigt den Status jedes Tools)\nCtrl+Shift+1 = Hidden Cube ON/OFF
pt=Liga/desliga enquanto você joga (aparece um aviso ON/OFF, a legenda no mapa\nmostra o estado de cada um)\nCtrl+Shift+1 = Hidden Cube ON/OFF
ru=Вкл/выкл во время игры (появляется уведомление ON/OFF, легенда на карте\nпоказывает состояние каждого инструмента)\nCtrl+Shift+1 = Hidden Cube ON/OFF
ko=플레이 중 켜기/끄기 (ON/OFF 알림이 표시되고, 지도의 범례에\n각각의 상태가 나와요)\nCtrl+Shift+1 = Hidden Cube ON/OFF
zh=游戏过程中开/关 (会弹出 ON/OFF 提示,地图上的图例\n会显示每个功能的状态)\nCtrl+Shift+1 = Hidden Cube ON/OFF
ja=プレイ中のオン/オフ (ON/OFF の通知が表示され、マップの凡例に\nそれぞれの状態が表示されます)\nCtrl+Shift+1 = Hidden Cube ON/OFF
@=FieldBossToggleKey
en=Ctrl+Shift+2 = Field Boss ON/OFF
nap=Ctrl+Shift+2 = Field Boss ON/OFF
bro=Ctrl+Shift+2 = Field Boss ON/OFF
es=Ctrl+Shift+2 = Field Boss ON/OFF
fr=Ctrl+Shift+2 = Field Boss ON/OFF
de=Ctrl+Shift+2 = Field Boss ON/OFF
pt=Ctrl+Shift+2 = Field Boss ON/OFF
ru=Ctrl+Shift+2 = Field Boss ON/OFF
ko=Ctrl+Shift+2 = Field Boss ON/OFF
zh=Ctrl+Shift+2 = Field Boss ON/OFF
ja=Ctrl+Shift+2 = Field Boss ON/OFF
@=HudToggleKey
en=Ctrl+Shift+\ = HUD overlay ON/OFF (crosshair, bars and icons)\n(\ = the key left of 1 on the Italian keyboard;\nif it does not respond try "^+SC029", the same key by position)
nap=Ctrl+Shift+\ = HUD overlay ON/OFF (mirino, barre e icone)\n(\ = 'o tasto a mancina 'e ll'1 'ncopp'â tastiera taliana;\nsi nun risponne prova "^+SC029", 'o stesso tasto pe' pusizione)
bro=Ctrl+Shift+\ = HUD overlay ON/OFF (mirino, barre e icone)\n(\ = il tasto a sinistra dell'1 sulla tastiera italiana;\nse non va prova "^+SC029", è lo stesso tasto per posizione)
es=Ctrl+Shift+\ = HUD overlay ON/OFF (mira, barras e iconos)\n(\ = la tecla a la izquierda del 1 en el teclado italiano;\nsi no responde prueba "^+SC029", la misma tecla por posición)
fr=Ctrl+Shift+\ = HUD overlay ON/OFF (viseur, barres et icônes)\n(\ = la touche à gauche du 1 sur le clavier italien ;\nsi elle ne répond pas, essaie "^+SC029", la même touche par position)
de=Ctrl+Shift+\ = HUD overlay ON/OFF (Fadenkreuz, Balken und Symbole)\n(\ = die Taste links von 1 auf der italienischen Tastatur;\nreagiert sie nicht, probiere "^+SC029", dieselbe Taste nach Position)
pt=Ctrl+Shift+\ = HUD overlay ON/OFF (mira, barras e ícones)\n(\ = a tecla à esquerda do 1 no teclado italiano;\nse não responder tente "^+SC029", a mesma tecla pela posição)
ru=Ctrl+Shift+\ = HUD overlay ON/OFF (прицел, полосы и иконки)\n(\ = клавиша слева от 1 на итальянской клавиатуре;\nесли не срабатывает, попробуйте "^+SC029" - та же клавиша по положению)
ko=Ctrl+Shift+\ = HUD overlay ON/OFF (조준선, 바, 아이콘)\n(\ = 이탈리아 키보드에서 1 왼쪽에 있는 키예요.\n반응이 없으면 같은 위치의 키인 "^+SC029"를 써 보세요)
zh=Ctrl+Shift+\ = HUD overlay ON/OFF (准星、条和图标)\n(\ = 意大利语键盘上 1 左边的那个键;\n如果没有反应,请试试 "^+SC029",即按位置指定的同一个键)
ja=Ctrl+Shift+\ = HUD overlay ON/OFF (照準、バー、アイコン)\n(\ = イタリア語キーボードで 1 の左のキー;\n反応しない場合は "^+SC029" (位置指定の同じキー) を試してください)
@=FieldBossMapKey
en=Field Boss\nthe key you open the map with in game. The script\n"listens" to it (it still reaches the game) to show\npanel and legend right away.
nap=Field Boss\n'o tasto cu cui arape 'a mappa int'ô juoco. 'O script 'o\n"sente" (arriva pure 'o juoco) pe' fa' comparì\nsubbito pannello e leggenda.
bro=Field Boss\nil tasto con cui apri la mappa nel gioco. Lo script\nlo "sente" (arriva lo stesso al gioco) per far spuntare\nsubito pannello e leggenda.
es=Field Boss\nla tecla con la que abres el mapa en el juego. El script\nla "escucha" (sigue llegando al juego) para mostrar\nel panel y la leyenda enseguida.
fr=Field Boss\nla touche avec laquelle tu ouvres la carte en jeu. Le script\nl'"écoute" (elle arrive quand même au jeu) pour afficher\nle panneau et la légende tout de suite.
de=Field Boss\ndie Taste, mit der du im Spiel die Karte öffnest. Das Skript\n"hört" sie mit (sie erreicht trotzdem das Spiel), um\nPanel und Legende sofort anzuzeigen.
pt=Field Boss\na tecla com que você abre o mapa no jogo. O script\n"escuta" essa tecla (ela chega ao jogo também) para mostrar\npainel e legenda na hora.
ru=Field Boss\nклавиша, которой вы открываете карту в игре. Скрипт\n"слушает" её (она всё равно доходит до игры), чтобы сразу показать\nпанель и легенду.
ko=Field Boss\n게임에서 지도를 여는 키예요. 스크립트가\n이 키를 "감지"해서 (게임에도 그대로 전달돼요) 패널과\n범례를 바로 표시해요.
zh=Field Boss\n游戏中用来打开地图的按键。脚本会\n"监听" 该键 (按键仍会传到游戏中),以便立即显示\n面板和图例。
ja=Field Boss\nゲーム内でマップを開くキー。スクリプトはこれを\n"監視" して (ゲームにも届きます)\nすぐにパネルと凡例を表示します。
@=FieldBossTravelKey
en=the game's Travel key. The script "listens" to it (it still reaches\nthe game) to know when you depart, and then show you the boss direction.
nap='o tasto Travel d'o juoco. 'O script 'o "sente" (arriva pure\n'o juoco) pe' sapé quanno parte, e po' te fa vedé 'a direzione d'o boss.
bro=il tasto Travel del gioco. Lo script lo "sente" (arriva lo stesso\nal gioco) per sapere quando parti e poi farti vedere dove sta il boss.
es=la tecla Travel del juego. El script la "escucha" (sigue llegando\nal juego) para saber cuándo partes y mostrarte entonces la dirección del boss.
fr=la touche Travel du jeu. Le script l'"écoute" (elle arrive quand même\nau jeu) pour savoir quand tu pars, et t'afficher ensuite la direction du boss.
de=die Travel-Taste des Spiels. Das Skript "hört" sie mit (sie erreicht trotzdem\ndas Spiel), um zu wissen, wann du losfliegst, und dir dann die Boss-Richtung zu zeigen.
pt=a tecla de Travel do jogo. O script "escuta" essa tecla (ela chega\nao jogo também) para saber quando você parte, e então mostrar a direção do boss.
ru=клавиша Travel в игре. Скрипт "слушает" её (она всё равно доходит до\nигры), чтобы узнать, когда вы отправляетесь, и затем показать направление к боссу.
ko=게임의 Travel 키예요. 스크립트가 이 키를 "감지"해서 (게임에도\n그대로 전달돼요) 출발 시점을 파악하고 보스 방향을 보여 줘요.
zh=游戏的 Travel 键。脚本会 "监听" 该键 (按键仍会传到\n游戏中),以便知道你何时出发,然后向你显示首领的方向。
ja=ゲームの Travel キー。スクリプトはこれを "監視" して (ゲームにも届きます)\n出発を検知し、ボスの方向を表示します。
)" "`n"
        s .= "
(
@=SettingsKey
en=Settings - window with every option of this CONFIG (works outside the game too).\nIt also opens from the menu of the "H" icon in the Windows taskbar or with a double click on the icon.\nCtrl+Shift+F12 = open the settings
nap=Mpustaziune - fenesta cu tutte 'e opziune 'e chesta CONFIG (funziona pure fora d'o juoco).\nS'arape pure d'o menù 'e ll'icona "H" dint'â barra 'e Windows o cu nu doppio click 'ncopp'a ll'icona.\nCtrl+Shift+F12 = arape 'e mpustaziune
bro=Settaggi - finestra con tutte le opzioni di questa CONFIG (va anche fuori dal gioco).\nSi apre anche dal menu dell'icona "H" nella barra di Windows o con doppio click sull'icona.\nCtrl+Shift+F12 = apri i settaggi
es=Ajustes - ventana con todas las opciones de esta CONFIG (funciona también fuera del juego).\nTambién se abre desde el menú del icono "H" en la barra de tareas de Windows o con doble clic en el icono.\nCtrl+Shift+F12 = abrir los ajustes
fr=Paramètres - fenêtre avec toutes les options de cette CONFIG (fonctionne aussi hors du jeu).\nElle s'ouvre aussi depuis le menu de l'icône "H" dans la barre des tâches Windows ou par un double-clic sur l'icône.\nCtrl+Shift+F12 = ouvrir les paramètres
de=Einstellungen - Fenster mit jeder Option dieser CONFIG (funktioniert auch außerhalb des Spiels).\nEs öffnet sich auch über das Menü des "H"-Symbols in der Windows-Taskleiste oder mit einem Doppelklick auf das Symbol.\nCtrl+Shift+F12 = Einstellungen öffnen
pt=Configurações - janela com todas as opções desta CONFIG (funciona também fora do jogo).\nTambém abre pelo menu do ícone "H" na barra de tarefas do Windows ou com clique duplo no ícone.\nCtrl+Shift+F12 = abrir as configurações
ru=Настройки - окно со всеми параметрами этого CONFIG (работает и вне игры).\nТакже открывается из меню значка "H" на панели задач Windows или двойным кликом по значку.\nCtrl+Shift+F12 = открыть настройки
ko=설정 - 이 CONFIG의 모든 옵션이 있는 창이에요 (게임 밖에서도 작동해요).\nWindows 작업 표시줄의 "H" 아이콘 메뉴나 아이콘 더블클릭으로도 열려요.\nCtrl+Shift+F12 = 설정 열기
zh=设置 - 包含此 CONFIG 所有选项的窗口 (在游戏外也可使用)。\n也可以通过 Windows 任务栏中 "H" 图标的菜单打开,或双击该图标打开。\nCtrl+Shift+F12 = 打开设置
ja=設定 - この CONFIG のすべてのオプションを表示するウィンドウ (ゲーム外でも動作)。\nWindows タスクバーの "H" アイコンのメニュー、またはアイコンのダブルクリックでも開けます。\nCtrl+Shift+F12 = 設定を開く
@=HiddenCubeTestKey
en=Diagnostics - only needed if something is not recognized\nwith the cube window open: shows what the script sees
nap=Diagnosi - servono sulo si coccosa nun vene arricanusciuto\ncu 'a fenesta d'o cubo aperta: fa vedé chello ca vede 'o script
bro=Debug - serve solo se qualcosa non viene sgamato\ncon la finestra del cubo aperta: ti fa vedere cosa vede lo script
es=Diagnóstico - solo hace falta si algo no se reconoce\ncon la ventana del cubo abierta: muestra lo que ve el script
fr=Diagnostic - utile uniquement si quelque chose n'est pas reconnu\navec la fenêtre du cube ouverte : montre ce que le script voit
de=Diagnose - nur nötig, wenn etwas nicht erkannt wird\nbei geöffnetem Cube-Fenster: zeigt, was das Skript sieht
pt=Diagnóstico - só serve se algo não for reconhecido\ncom a janela do cubo aberta: mostra o que o script vê
ru=Диагностика - нужна только если что-то не распознаётся\nпри открытом окне куба: показывает, что видит скрипт
ko=진단 - 무언가 인식되지 않을 때만 필요해요.\n큐브 창을 연 상태에서 스크립트가 보는 것을 표시해요
zh=诊断 - 仅在某些内容无法识别时才需要\n在立方体窗口打开的状态下:显示脚本所看到的内容
ja=診断 - 何かが認識されない場合のみ必要\nキューブのウィンドウを開いた状態で、スクリプトに見えているものを表示します
@=FieldBossCoordKey
en=shows and copies to the clipboard the mouse coordinates (1440p base)
nap=fa vedé e copia 'e coordinate d'o mouse (base 1440p)
bro=mostra e copia negli appunti le coordinate del mouse (base 1440p)
es=muestra y copia al portapapeles las coordenadas del ratón (base 1440p)
fr=affiche et copie dans le presse-papiers les coordonnées de la souris (base 1440p)
de=zeigt die Mauskoordinaten an und kopiert sie in die Zwischenablage (Basis 1440p)
pt=mostra e copia para a área de transferência as coordenadas do mouse (base 1440p)
ru=показывает и копирует в буфер обмена координаты мыши (база 1440p)
ko=마우스 좌표(1440p 기준)를 표시하고 클립보드에 복사해요
zh=显示鼠标坐标并复制到剪贴板 (以 1440p 为基准)
ja=マウス座標を表示し、クリップボードにコピーします (1440p基準)
@=FieldBossMapTestKey
en=marks on the map for 3 s: Teleports (purple), active skulls (red), boss (yellow)
nap=segna 'ncopp'â mappa pe' 3 s: Teleport (viola), cape 'e morte attive (rosso), boss (giallo)
bro=segna sulla mappa per 3 s: Teleport (viola), teschi accesi (rosso), boss (giallo)
es=marca en el mapa durante 3 s: Teleports (morado), calaveras activas (rojo), boss (amarillo)
fr=marque sur la carte pendant 3 s : Teleport (violet), crânes actifs (rouge), boss (jaune)
de=markiert die Karte 3 s lang: Teleports (lila), aktive Totenköpfe (rot), Boss (gelb)
pt=marca no mapa por 3 s: Teleports (roxo), caveiras ativas (vermelho), boss (amarelo)
ru=отмечает на карте на 3 s: Teleport (фиолетовые), активные черепа (красные), босс (жёлтый)
ko=3 s 동안 지도에 표시해요: Teleport(보라), 활성 해골(빨강), 보스(노랑)
zh=在地图上标记 3 s:Teleport (紫色)、激活的骷髅 (红色)、首领 (黄色)
ja=マップに 3 s 間マークを表示: Teleport (紫)、有効なドクロ (赤)、ボス (黄)
@=FieldBossScanKey
en=shows what the OCR reads in the boss list (name, state, position)
nap=fa vedé chello ca legge ll'OCR dint'â lista boss (nomme, stato, pusizione)
bro=fa vedere cosa legge l'OCR nella lista boss (nome, stato, posizione)
es=muestra lo que lee el OCR en la lista de bosses (nombre, estado, posición)
fr=affiche ce que l'OCR lit dans la liste des boss (nom, état, position)
de=zeigt, was das OCR in der Boss-Liste liest (Name, Status, Position)
pt=mostra o que o OCR lê na lista de bosses (nome, estado, posição)
ru=показывает, что OCR читает в списке боссов (имя, состояние, позиция)
ko=보스 목록에서 OCR이 읽은 내용(이름, 상태, 위치)을 표시해요
zh=显示 OCR 在首领列表中读取到的内容 (名称、状态、位置)
ja=ボスリストで OCR が読み取った内容 (名前、状態、位置) を表示します
@=HudEnabled
en=true = HUD overlay on when the script starts
nap=true = HUD overlay appicciato quanno parte 'o script
bro=true = HUD overlay acceso appena parte lo script
es=true = HUD overlay activo cuando arranca el script
fr=true = HUD overlay actif au lancement du script
de=true = HUD overlay ist beim Start des Skripts an
pt=true = HUD overlay ligado quando o script inicia
ru=true = HUD overlay включён при запуске скрипта
ko=true = 스크립트가 시작될 때 HUD overlay 켜짐
zh=true = 脚本启动时开启 HUD overlay
ja=true = スクリプト起動時に HUD overlay を有効にする
@=HudBaseHeight
en=resolution (height in px) the HUD px values are made for:\n1080 = FullHD, 1440 = 2K, 2160 = 4K. The Settings presets use it\nto rescale the HUD from one resolution to another.
nap=risoluzione (autezza in px) pe' cui so' pensate 'e valure in px 'e ll'HUD:\n1080 = FullHD, 1440 = 2K, 2160 = 4K. 'A usano 'e preset d'e Mpustaziune\npe' riscalà ll'HUD 'a na risoluzione a n'ata.
bro=risoluzione (altezza in px) per cui sono pensati i valori in px dell'HUD:\n1080 = FullHD, 1440 = 2K, 2160 = 4K. La usano i preset dei Settaggi\nper riscalare l'HUD da una risoluzione all'altra.
es=resolución (altura en px) para la que están hechos los valores en px del HUD:\n1080 = FullHD, 1440 = 2K, 2160 = 4K. Los presets de Ajustes la usan\npara reescalar el HUD de una resolución a otra.
fr=résolution (hauteur en px) pour laquelle sont faites les valeurs en px du HUD :\n1080 = FullHD, 1440 = 2K, 2160 = 4K. Les presets des Paramètres l'utilisent\npour redimensionner le HUD d'une résolution à l'autre.
de=Auflösung (Höhe in px), für die die px-Werte des HUD gemacht sind:\n1080 = FullHD, 1440 = 2K, 2160 = 4K. Die Einstellungs-Presets nutzen sie,\num das HUD von einer Auflösung auf eine andere zu skalieren.
pt=resolução (altura em px) para a qual os valores em px do HUD foram feitos:\n1080 = FullHD, 1440 = 2K, 2160 = 4K. Os presets das Configurações a usam\npara reescalar o HUD de uma resolução para outra.
ru=разрешение (высота в px), под которое сделаны значения HUD в px:\n1080 = FullHD, 1440 = 2K, 2160 = 4K. Пресеты настроек используют его,\nчтобы масштабировать HUD из одного разрешения в другое.
ko=HUD px 값의 기준 해상도(높이, px):\n1080 = FullHD, 1440 = 2K, 2160 = 4K. 설정 프리셋이 이 값을 이용해\nHUD를 한 해상도에서 다른 해상도로 조정해요.
zh=HUD px 数值所对应的分辨率 (高度,单位 px):\n1080 = FullHD,1440 = 2K,2160 = 4K。设置中的预设会据此\n把 HUD 从一种分辨率缩放到另一种。
ja=HUD の px 値の基準解像度 (高さ px):\n1080 = FullHD、1440 = 2K、2160 = 4K。設定のプリセットはこれを使って\nHUD を解像度間で再計算します。
@=CombatTimeout
en=ms without F9 before going back to idle
nap=ms senza F9 primma 'e se stutà
bro=ms senza F9 prima di tornare in chill
es=ms sin F9 antes de volver a inactivo
fr=ms sans F9 avant de repasser à l'état inactif
de=ms ohne F9, bevor es in den Ruhezustand zurückgeht
pt=ms sem F9 antes de voltar a inativo
ru=ms без F9 до возврата в неактивное состояние
ko=F9 입력이 없다가 비활성으로 돌아가기까지의 ms
zh=F9 停止后经过多少 ms 回到未激活状态
ja=F9 が来なくなってから待機に戻るまでの ms
)" "`n"
        s .= "
(
@=LootTimeout
en=ms after RELEASING F10 before going back to idle\n(covers the pause between the end of one macro cycle and the next)
nap=ms doppo c'he LASSATO F10 primma 'e se stutà\n(copre 'a pausa tra 'a fine 'e nu ciclo d'a macro e chillo appriesso)
bro=ms dopo che MOLLI F10 prima di tornare in chill\n(copre la pausa tra la fine di un giro della macro e quello dopo)
es=ms tras SOLTAR F10 antes de volver a inactivo\n(cubre la pausa entre el final de un ciclo de la macro y el siguiente)
fr=ms après le RELÂCHEMENT de F10 avant de repasser à l'état inactif\n(couvre la pause entre la fin d'un cycle de macro et le suivant)
de=ms nach dem LOSLASSEN von F10, bevor es in den Ruhezustand zurückgeht\n(deckt die Pause zwischen dem Ende eines Makrozyklus und dem nächsten ab)
pt=ms depois de SOLTAR F10 antes de voltar a inativo\n(cobre a pausa entre o fim de um ciclo da macro e o seguinte)
ru=ms после ОТПУСКАНИЯ F10 до возврата в неактивное состояние\n(покрывает паузу между концом одного цикла макроса и началом следующего)
ko=F10을 뗀 후 비활성으로 돌아가기까지의 ms\n(매크로 한 사이클이 끝나고 다음 사이클이 시작되기 전의 대기를 커버해요)
zh=松开 F10 后经过多少 ms 回到未激活状态\n(覆盖一轮宏循环结束到下一轮开始之间的停顿)
ja=F10 を離してから待機に戻るまでの ms\n(マクロの1サイクル終了から次の開始までの待ち時間をカバー)
@=CombatGrace
en=minimum ms F9 stays ON after switching on\n(covers the Windows pause before the key auto-repeat)
nap=ms minime ca F9 resta ON doppo ca s'è appicciato\n(copre 'a pausa 'e Windows primma ca 'o tasto se ripete sulo)
bro=ms minimi che F9 resta ON dopo che si accende\n(copre la pausa di Windows prima che il tasto si ripeta da solo)
es=mínimo de ms que F9 permanece ON tras encenderse\n(cubre la pausa de Windows antes de la repetición automática de la tecla)
fr=ms minimum pendant lesquelles F9 reste ON après l'activation\n(couvre la pause de Windows avant la répétition automatique de la touche)
de=minimale ms, die F9 nach dem Einschalten AN bleibt\n(deckt die Windows-Pause vor der Tasten-Wiederholung ab)
pt=ms mínimos que F9 fica ON depois de ligar\n(cobre a pausa do Windows antes do auto-repeat da tecla)
ru=минимум ms, сколько F9 остаётся ON после включения\n(покрывает паузу Windows перед автоповтором клавиши)
ko=켜진 뒤 F9이 ON을 유지하는 최소 ms\n(키 자동 반복 전의 Windows 지연을 커버해요)
zh=F9 开启后至少保持 ON 的毫秒数\n(覆盖按键自动重复之前 Windows 的停顿)
ja=点灯後に F9 が ON を維持する最低 ms\n(キーの自動リピート前の Windows の待ち時間をカバー)
@=LootGrace
en=same as above, for F10
nap=comme 'a coppa, pe' F10
bro=uguale a sopra, ma per F10
es=igual que arriba, para F10
fr=comme ci-dessus, pour F10
de=wie oben, für F10
pt=igual ao anterior, para F10
ru=то же, что выше, для F10
ko=위와 같고, F10용이에요
zh=同上,适用于 F10
ja=上記と同じ、F10 用
@=ColorActive
en=color of the whole HUD when active (F9 and F10)
nap=culore 'e tutto ll'HUD quanno è appicciato (F9 e F10)
bro=colore di tutto l'HUD quando è acceso (F9 e F10)
es=color de todo el HUD cuando está activo (F9 y F10)
fr=couleur de tout le HUD à l'état actif (F9 et F10)
de=Farbe des gesamten HUD, wenn aktiv (F9 und F10)
pt=cor de todo o HUD quando ativo (F9 e F10)
ru=цвет всего HUD в активном состоянии (F9 и F10)
ko=활성 상태일 때 HUD 전체의 색상 (F9 및 F10)
zh=HUD 激活时的整体颜色 (F9 和 F10)
ja=有効時の HUD 全体の色 (F9 と F10)
@=ColorIdleCombat
en=color of crosshair and bars when idle
nap=culore d'o mirino e d'e barre quanno so' stutate
bro=colore di mirino e barre quando sono in chill
es=color de la mira y las barras cuando están inactivas
fr=couleur du viseur et des barres à l'état inactif
de=Farbe von Fadenkreuz und Balken im Ruhezustand
pt=cor da mira e das barras quando inativos
ru=цвет прицела и полос в неактивном состоянии
ko=비활성일 때 조준선과 바의 색상
zh=准星和条未激活时的颜色
ja=無効時の照準とバーの色
@=ColorIdleLoot
en=color of the Loot icon when idle (dark orange)
nap=culore 'e ll'icona Loot quanno è stutata (arancione scuro)
bro=colore dell'icona Loot quando è in chill (arancione scuro)
es=color del icono Loot cuando está inactivo (naranja oscuro)
fr=couleur de l'icône Loot à l'état inactif (orange foncé)
de=Farbe des Loot-Symbols im Ruhezustand (dunkles Orange)
pt=cor do ícone Loot quando inativo (laranja escuro)
ru=цвет иконки Loot в неактивном состоянии (тёмно-оранжевый)
ko=비활성일 때 Loot 아이콘의 색상 (짙은 주황)
zh=Loot 图标未激活时的颜色 (深橙色)
ja=無効時の Loot アイコンの色 (濃いオレンジ)
@=ColorBorder
en=color of the frames of bars and icons
nap=culore d'e curnice 'e barre e icone
bro=colore delle cornici di barre e icone
es=color de los marcos de barras e iconos
fr=couleur des cadres des barres et des icônes
de=Farbe der Rahmen von Balken und Symbolen
pt=cor das molduras de barras e ícones
ru=цвет рамок полос и иконок
ko=바와 아이콘 테두리의 색상
zh=条和图标边框的颜色
ja=バーとアイコンの枠の色
@=OffsetX
en=horizontal offset from the center (px, + = right)
nap=spustamento orizzontale d'o miezo (px, + = a deritta)
bro=spostamento orizzontale dal centro (px, + = destra)
es=desplazamiento horizontal desde el centro (px, + = derecha)
fr=décalage horizontal par rapport au centre (px, + = droite)
de=horizontaler Versatz von der Mitte (px, + = rechts)
pt=deslocamento horizontal em relação ao centro (px, + = direita)
ru=смещение по горизонтали от центра (px, + = вправо)
ko=중앙 기준 가로 오프셋 (px, + = 오른쪽)
zh=相对中心的水平偏移 (px,+ = 向右)
ja=中央からの水平オフセット (px、+ = 右)
@=OffsetY
en=vertical offset from the center (px, - = higher)
nap=spustamento verticale d'o miezo (px, - = cchiù 'ncoppa)
bro=spostamento verticale dal centro (px, - = più su)
es=desplazamiento vertical desde el centro (px, - = más arriba)
fr=décalage vertical par rapport au centre (px, - = plus haut)
de=vertikaler Versatz von der Mitte (px, - = höher)
pt=deslocamento vertical em relação ao centro (px, - = mais alto)
ru=смещение по вертикали от центра (px, - = выше)
ko=중앙 기준 세로 오프셋 (px, - = 위쪽)
zh=相对中心的垂直偏移 (px,- = 更高)
ja=中央からの垂直オフセット (px、- = 上)
@=ChevronGap
en=empty space between the left and the right group of arrows (px)
nap=spazio vacante tra 'o gruppo 'e frecce 'e mancina e chillo 'e deritta (px)
bro=spazio vuoto tra il gruppo di frecce a sinistra e quello a destra (px)
es=espacio vacío entre el grupo de flechas izquierdo y el derecho (px)
fr=espace vide entre le groupe de flèches de gauche et celui de droite (px)
de=leerer Raum zwischen der linken und der rechten Pfeilgruppe (px)
pt=espaço vazio entre o grupo de setas da esquerda e o da direita (px)
ru=пустое пространство между левой и правой группами стрелок (px)
ko=왼쪽 화살표 그룹과 오른쪽 그룹 사이의 빈 공간 (px)
zh=左右两组箭头之间的空隙 (px)
ja=左右の矢印グループ間の空き (px)
@=ChevronCount
en=number of arrows per side
nap=quante frecce pe' lato
bro=quante frecce per lato
es=número de flechas por lado
fr=nombre de flèches par côté
de=Anzahl der Pfeile pro Seite
pt=número de setas por lado
ru=количество стрелок на сторону
ko=면당 화살표 수
zh=每侧箭头的数量
ja=片側の矢印の数
@=ChevronWidthOff ChevronWidthOn
en=Arrow shape: OFF state on the left, ON state on the right (px)\nwidth of one arrow
nap=Forma d'e frecce: a mancina 'o stato OFF, a deritta 'o stato ON (px)\nlarghezza 'e na freccia
bro=Shape delle frecce: a sinistra lo stato OFF, a destra lo stato ON (px)\nlarghezza di una freccia
es=Forma de la flecha: estado OFF a la izquierda, estado ON a la derecha (px)\nancho de una flecha
fr=Forme des flèches : état OFF à gauche, état ON à droite (px)\nlargeur d'une flèche
de=Pfeilform: Zustand OFF links, Zustand ON rechts (px)\nBreite eines Pfeils
pt=Forma da seta: estado OFF à esquerda, estado ON à direita (px)\nlargura de uma seta
ru=Форма стрелки: состояние OFF слева, состояние ON справа (px)\nширина одной стрелки
ko=화살표 모양: 왼쪽은 OFF 상태, 오른쪽은 ON 상태 (px)\n화살표 하나의 너비
zh=箭头形状:左边为 OFF 状态,右边为 ON 状态 (px)\n单个箭头的宽度
ja=矢印の形状: 左が OFF 状態、右が ON 状態 (px)\n矢印1つの幅
@=ChevronHeightOff ChevronHeightOn
en=height of one arrow
nap=autezza 'e na freccia
bro=altezza di una freccia
es=alto de una flecha
fr=hauteur d'une flèche
de=Höhe eines Pfeils
pt=altura de uma seta
ru=высота одной стрелки
ko=화살표 하나의 높이
zh=单个箭头的高度
ja=矢印1つの高さ
@=ChevronThicknessOff ChevronThicknessOn
en=line thickness
nap=spessore d'e linee
bro=spessore delle linee
es=grosor de línea
fr=épaisseur du trait
de=Linienstärke
pt=espessura da linha
ru=толщина линий
ko=선 두께
zh=线条粗细
ja=線の太さ
@=ChevronSpacingOff ChevronSpacingOn
en=distance between one arrow and the next
nap=distanza tra na freccia e chella appriesso
bro=distanza tra una freccia e quella dopo
es=distancia entre una flecha y la siguiente
fr=distance entre une flèche et la suivante
de=Abstand zwischen einem Pfeil und dem nächsten
pt=distância entre uma seta e a seguinte
ru=расстояние между соседними стрелками
ko=화살표 사이의 거리
zh=相邻箭头之间的距离
ja=矢印同士の間隔
)" "`n"
        s .= "
(
@=ChevronShapeOff
en=Shape of the crosshair elements (one for the OFF state and one for the ON state;\nduring the transition the shape switches halfway):\n"freccia"   = chevron  >  (classic)\n"triangolo" = solid triangle, pointing in the arrows' direction\n"barra"     = vertical bar  |  (thickness = Thickness)\n"rombo"     = solid diamond  ◆\n"cerchio"   = solid dot / oval  ●\n"blocco"    = solid rectangle  ■\nWidth, height and spacing use the values above. Symmetric shapes\n(barra, rombo, cerchio, blocco) do not flip between OFF and ON.\nresting shape (OFF)
nap=Forma d'e piezze d'o mirino (una pe' 'o stato OFF e una pe' 'o stato ON;\nint'ô passaggio tra 'e duje stati 'a forma cagna a mità):\n"freccia"   = chevron  >  (classica)\n"triangolo" = triangolo chino, cu 'a ponta verso addò vanno 'e frecce\n"barra"     = barretta verticale  |  (spessore = Thickness)\n"rombo"     = rombo chino  ◆\n"cerchio"   = pallino / ovale chino  ●\n"blocco"    = rettangolo chino  ■\nLarghezza, autezza e distanza pigliano 'e valure 'a coppa. 'E forme simmetriche\n(barra, rombo, cerchio, blocco) nun se girano tra OFF e ON.\nforma a riposo (OFF)
bro=Shape dei pezzi del mirino (una per lo stato OFF e una per lo stato ON;\nnel passaggio tra i due la shape cambia a metà):\n"freccia"   = chevron  >  (classica)\n"triangolo" = triangolo pieno, punta verso dove vanno le frecce\n"barra"     = barretta verticale  |  (spessore = Thickness)\n"rombo"     = rombo pieno  ◆\n"cerchio"   = pallino / ovale pieno  ●\n"blocco"    = rettangolo pieno  ■\nLarghezza, altezza e distanza usano i valori sopra. Le shape simmetriche\n(barra, rombo, cerchio, blocco) non si girano tra OFF e ON.\nshape a riposo (OFF)
es=Forma de los elementos de la mira (una para el estado OFF y otra para el estado ON;\ndurante la transición la forma cambia a mitad de camino):\n"freccia"   = chevron  >  (clásico)\n"triangolo" = triángulo macizo, apuntando en la dirección de las flechas\n"barra"     = barra vertical  |  (grosor de línea)\n"rombo"     = rombo macizo  ◆\n"cerchio"   = punto / óvalo macizo  ●\n"blocco"    = rectángulo macizo  ■\nAncho, alto y distancia usan los valores de arriba. Las formas simétricas\n(barra, rombo, cerchio, blocco) no se giran entre OFF y ON.\nforma en reposo (OFF)
fr=Forme des éléments du viseur (une pour l'état OFF et une pour l'état ON ;\npendant la transition la forme change à mi-chemin) :\n"freccia"   = chevron  >  (classique)\n"triangolo" = triangle plein, orienté dans le sens des flèches\n"barra"     = barre verticale  |  (épaisseur = Thickness)\n"rombo"     = losange plein  ◆\n"cerchio"   = point plein / ovale  ●\n"blocco"    = rectangle plein  ■\nLargeur, hauteur et espacement utilisent les valeurs ci-dessus. Les formes symétriques\n(barra, rombo, cerchio, blocco) ne se retournent pas entre OFF et ON.\nforme au repos (OFF)
de=Form der Fadenkreuz-Elemente (eine für den Zustand OFF und eine für den Zustand ON;\nbeim Übergang wechselt die Form in der Mitte):\n"freccia"   = Chevron  >  (klassisch)\n"triangolo" = gefülltes Dreieck, zeigt in Pfeilrichtung\n"barra"     = senkrechter Balken  |  (Stärke = Thickness)\n"rombo"     = gefüllte Raute  ◆\n"cerchio"   = gefüllter Punkt / Oval  ●\n"blocco"    = gefülltes Rechteck  ■\nBreite, Höhe und Abstand nutzen die obigen Werte. Symmetrische Formen\n(barra, rombo, cerchio, blocco) kippen nicht zwischen OFF und ON.\nRuheform (OFF)
pt=Forma dos elementos da mira (uma para o estado OFF e uma para o ON;\ndurante a transição a forma troca na metade):\n"freccia"   = chevron  >  (clássico)\n"triangolo" = triângulo cheio, apontando na direção das setas\n"barra"     = barra vertical  |  (espessura = Thickness)\n"rombo"     = losango cheio  ◆\n"cerchio"   = ponto / oval cheio  ●\n"blocco"    = retângulo cheio  ■\nLargura, altura e distância usam os valores acima. As formas simétricas\n(barra, rombo, cerchio, blocco) não se invertem entre OFF e ON.\nforma de repouso (OFF)
ru=Форма элементов прицела (одна для состояния OFF и одна для состояния ON;\nво время перехода форма меняется на полпути):\n"freccia"   = шеврон  >  (классика)\n"triangolo" = залитый треугольник, направленный в сторону стрелок\n"barra"     = вертикальная черта  |  (толщина = Thickness)\n"rombo"     = залитый ромб  ◆\n"cerchio"   = залитая точка / овал  ●\n"blocco"    = залитый прямоугольник  ■\nШирина, высота и расстояние берутся из значений выше. Симметричные формы\n(barra, rombo, cerchio, blocco) не отражаются между OFF и ON.\nформа покоя (OFF)
ko=조준선 요소의 모양 (OFF 상태용 하나, ON 상태용 하나;\n전환 중에는 중간에 모양이 바뀌어요):\n"freccia"   = 쉐브론  >  (기본)\n"triangolo" = 화살표 방향을 향한 채워진 삼각형\n"barra"     = 세로 막대  |  (두께 = Thickness)\n"rombo"     = 채워진 마름모  ◆\n"cerchio"   = 채워진 점 / 타원  ●\n"blocco"    = 채워진 직사각형  ■\n너비, 높이, 간격은 위의 값을 사용해요. 대칭 모양\n(barra, rombo, cerchio, blocco)은 OFF와 ON 사이에서 뒤집히지 않아요.\n대기 모양 (OFF)
zh=准星元素的形状 (OFF 状态和 ON 状态各一个;\n过渡期间形状在中途切换):\n"freccia"   = 人字形箭头  >  (经典)\n"triangolo" = 实心三角形,指向箭头方向\n"barra"     = 竖条  |  (粗细 = Thickness)\n"rombo"     = 实心菱形  ◆\n"cerchio"   = 实心圆点 / 椭圆  ●\n"blocco"    = 实心矩形  ■\n宽度、高度和间距使用上面的数值。对称形状\n(barra、rombo、cerchio、blocco) 在 OFF 和 ON 之间不会翻转。\n待机形状 (OFF)
ja=照準要素の形状 (OFF 状態用と ON 状態用に1つずつ;\n切り替え中は途中で形状が切り替わります):\n"freccia"   = シェブロン  >  (標準)\n"triangolo" = 塗りつぶし三角形、矢印の向きを指す\n"barra"     = 縦バー  |  (太さ = Thickness)\n"rombo"     = 塗りつぶしひし形  ◆\n"cerchio"   = 塗りつぶし円 / 楕円  ●\n"blocco"    = 塗りつぶし長方形  ■\n幅、高さ、間隔は上記の値を使用します。対称形状\n(barra、rombo、cerchio、blocco) は OFF と ON で反転しません。\n待機時の形状 (OFF)
@=ChevronShapeOn
en=combat shape (ON): "freccia" | "triangolo" | "barra" |\n"rombo" | "cerchio" | "blocco" (see the explanation above)
nap=forma int'ô combattimento (ON): "freccia" | "triangolo" | "barra" |\n"rombo" | "cerchio" | "blocco" (vide 'a spiegazione 'a coppa)
bro=shape in combat (ON): "freccia" | "triangolo" | "barra" |\n"rombo" | "cerchio" | "blocco" (guarda la spiegazione sopra)
es=forma en combate (ON): "freccia" | "triangolo" | "barra" |\n"rombo" | "cerchio" | "blocco" (ver la explicación de arriba)
fr=forme de combat (ON) : "freccia" | "triangolo" | "barra" |\n"rombo" | "cerchio" | "blocco" (voir l'explication ci-dessus)
de=Kampfform (ON): "freccia" | "triangolo" | "barra" |\n"rombo" | "cerchio" | "blocco" (siehe die Erklärung oben)
pt=forma de combate (ON): "freccia" | "triangolo" | "barra" |\n"rombo" | "cerchio" | "blocco" (veja a explicação acima)
ru=боевая форма (ON): "freccia" | "triangolo" | "barra" |\n"rombo" | "cerchio" | "blocco" (см. пояснение выше)
ko=전투 모양 (ON): "freccia" | "triangolo" | "barra" |\n"rombo" | "cerchio" | "blocco" (위의 설명 참고)
zh=战斗形状 (ON):"freccia" | "triangolo" | "barra" |\n"rombo" | "cerchio" | "blocco" (见上面的说明)
ja=戦闘時の形状 (ON): "freccia" | "triangolo" | "barra" |\n"rombo" | "cerchio" | "blocco" (上の説明を参照)
)" "`n"
        s .= "
(
@=ChevronAnimMode
en=Animation in ON state\n"pulse"    = a wave of enlargement runs from the outside to the center\n"march"    = the arrows flow towards the center like a continuous belt\n"sequence" = the arrows light up one after another, from the outside to the center\n"none"     = still arrows
nap=Animazione int'ô stato ON\n"pulse"    = n'onda ca ngrossa e corre 'a fora verso 'o miezo\n"march"    = 'e frecce scorrono verso 'o miezo comme nu nastro ca nun fernesce maje\n"sequence" = 'e frecce s'appicciano una appriesso a n'ata, 'a fora 'o miezo\n"none"     = frecce ferme
bro=Animazione nello stato ON\n"pulse"    = un'onda che ingrandisce e corre da fuori verso il centro\n"march"    = le frecce scorrono verso il centro tipo nastro infinito\n"sequence" = le frecce si accendono una dopo l'altra, da fuori al centro\n"none"     = frecce ferme, zero sbatti
es=Animación en estado ON\n"pulse"    = una onda de ampliación va del exterior al centro\n"march"    = las flechas fluyen hacia el centro como una cinta continua\n"sequence" = las flechas se encienden una tras otra, del exterior al centro\n"none"     = flechas quietas
fr=Animation à l'état ON\n"pulse"    = une vague d'agrandissement va de l'extérieur vers le centre\n"march"    = les flèches coulent vers le centre comme un tapis roulant continu\n"sequence" = les flèches s'allument l'une après l'autre, de l'extérieur vers le centre\n"none"     = flèches immobiles
de=Animation im Zustand ON\n"pulse"    = eine Vergrößerungswelle läuft von außen zur Mitte\n"march"    = die Pfeile fließen wie ein Förderband zur Mitte\n"sequence" = die Pfeile leuchten nacheinander auf, von außen zur Mitte\n"none"     = stehende Pfeile
pt=Animação no estado ON\n"pulse"    = uma onda de ampliação corre de fora para o centro\n"march"    = as setas fluem em direção ao centro como uma esteira contínua\n"sequence" = as setas acendem uma após a outra, de fora para o centro\n"none"     = setas paradas
ru=Анимация в состоянии ON\n"pulse"    = волна увеличения идёт от внешнего края к центру\n"march"    = стрелки текут к центру, как непрерывная лента\n"sequence" = стрелки загораются одна за другой, от внешнего края к центру\n"none"     = неподвижные стрелки
ko=ON 상태의 애니메이션\n"pulse"    = 확대 파동이 바깥에서 중앙으로 이동해요\n"march"    = 화살표가 컨베이어 벨트처럼 중앙을 향해 계속 흘러가요\n"sequence" = 화살표가 바깥에서 중앙으로 차례로 켜져요\n"none"     = 화살표가 움직이지 않아요
zh=ON 状态下的动画\n"pulse"    = 一道放大的波从外向中心传递\n"march"    = 箭头像传送带一样持续流向中心\n"sequence" = 箭头从外向中心依次亮起\n"none"     = 箭头静止
ja=ON 状態のアニメーション\n"pulse"    = 拡大の波が外側から中央へ走る\n"march"    = 矢印がベルトのように中央へ流れる\n"sequence" = 矢印が外側から中央へ順に点灯する\n"none"     = 矢印は静止
@=ChevronAnimCycle
en=ms for a full cycle (lower = faster)
nap=ms pe' nu ciclo sano (cchiù basso = cchiù ampressa)
bro=ms per un giro completo (più basso = più veloce)
es=ms por ciclo completo (menos = más rápido)
fr=ms pour un cycle complet (plus bas = plus rapide)
de=ms für einen ganzen Zyklus (niedriger = schneller)
pt=ms de um ciclo completo (menor = mais rápido)
ru=ms на полный цикл (меньше = быстрее)
ko=한 사이클의 ms (낮을수록 빨라요)
zh=一个完整周期的 ms 数 (越小越快)
ja=1サイクルの ms (小さいほど速い)
@=ChevronPulseMin
en="pulse" only: minimum arrow size (1 = normal)
nap=sulo "pulse": grandezza minima d'a freccia (1 = normale)
bro=solo "pulse": size minima della freccia (1 = normale)
es=solo "pulse": tamaño mínimo de la flecha (1 = normal)
fr="pulse" uniquement : taille minimale des flèches (1 = normale)
de=nur "pulse": minimale Pfeilgröße (1 = normal)
pt=só "pulse": tamanho mínimo da seta (1 = normal)
ru=только "pulse": минимальный размер стрелки (1 = обычный)
ko="pulse" 전용: 화살표 최소 크기 (1 = 기본)
zh=仅限 "pulse":箭头最小尺寸 (1 = 正常)
ja="pulse" のみ: 矢印の最小サイズ (1 = 標準)
@=ChevronPulseMax
en="pulse" only: maximum arrow size
nap=sulo "pulse": grandezza massima d'a freccia
bro=solo "pulse": size massima della freccia
es=solo "pulse": tamaño máximo de la flecha
fr="pulse" uniquement : taille maximale des flèches
de=nur "pulse": maximale Pfeilgröße
pt=só "pulse": tamanho máximo da seta
ru=только "pulse": максимальный размер стрелки
ko="pulse" 전용: 화살표 최대 크기
zh=仅限 "pulse":箭头最大尺寸
ja="pulse" のみ: 矢印の最大サイズ
@=ChevronMorphInTime
en=Transition between OFF and ON: the arrows gradually "flip"\nseconds to go from OFF to ON (0 = instant)
nap=Passaggio tra OFF e ON: 'e frecce se "votano" chiano chiano\nsecondi pe' passà 'a OFF a ON (0 = subbito)
bro=Passaggio tra OFF e ON: le frecce si "ribaltano" piano piano\nsecondi per passare da OFF a ON (0 = istantaneo)
es=Transición entre OFF y ON: las flechas se "giran" poco a poco\nsegundos para pasar de OFF a ON (0 = instantáneo)
fr=Transition entre OFF et ON : les flèches se "retournent" progressivement\nsecondes pour passer de OFF à ON (0 = instantané)
de=Übergang zwischen OFF und ON: Die Pfeile "kippen" nach und nach\nSekunden von OFF zu ON (0 = sofort)
pt=Transição entre OFF e ON: as setas "viram" gradualmente\nsegundos para ir de OFF a ON (0 = instantâneo)
ru=Переход между OFF и ON: стрелки постепенно "переворачиваются"\nсекунд на переход от OFF к ON (0 = мгновенно)
ko=OFF와 ON 사이의 전환: 화살표가 서서히 "뒤집혀요"\nOFF에서 ON까지 걸리는 초 (0 = 즉시)
zh=OFF 与 ON 之间的过渡:箭头逐渐 "翻转"\n从 OFF 变为 ON 所需的秒数 (0 = 立即)
ja=OFF と ON の間のトランジション: 矢印が徐々に "反転" します\nOFF から ON までの秒数 (0 = 即時)
@=ChevronMorphOutTime
en=seconds to go from ON to OFF
nap=secondi pe' passà 'a ON a OFF
bro=secondi per passare da ON a OFF
es=segundos para pasar de ON a OFF
fr=secondes pour passer de ON à OFF
de=Sekunden von ON zu OFF
pt=segundos para ir de ON a OFF
ru=секунд на переход от ON к OFF
ko=ON에서 OFF까지 걸리는 초
zh=从 ON 变为 OFF 所需的秒数
ja=ON から OFF までの秒数
@=Bar1Enabled Bar2Enabled
en=Bar 1 (top)       Bar 2 (bottom)\ntrue = shown, false = hidden
nap=Barra 1 ('ncoppa)       Barra 2 (abbascio)\ntrue = se vede, false = annascosta
bro=Barra 1 (sopra)       Barra 2 (sotto)\ntrue = si vede, false = nascosta
es=Barra 1 (arriba)       Barra 2 (abajo)\ntrue = visible, false = oculta
fr=Barre 1 (haut)       Barre 2 (bas)\ntrue = affichée, false = masquée
de=Balken 1 (oben)       Balken 2 (unten)\ntrue = angezeigt, false = ausgeblendet
pt=Barra 1 (em cima)       Barra 2 (embaixo)\ntrue = mostrada, false = escondida
ru=Полоса 1 (верхняя)       Полоса 2 (нижняя)\ntrue = показана, false = скрыта
ko=바 1 (위)       바 2 (아래)\ntrue = 표시, false = 숨김
zh=条 1 (上)       条 2 (下)\ntrue = 显示,false = 隐藏
ja=バー1 (上)       バー2 (下)\ntrue = 表示、false = 非表示
@=Bar1MaxWidth Bar2MaxWidth
en=total width
nap=larghezza totale
bro=larghezza totale
es=ancho total
fr=largeur totale
de=Gesamtbreite
pt=largura total
ru=общая ширина
ko=전체 너비
zh=总宽度
ja=全幅
@=Bar1MaxHeight Bar2MaxHeight
en=height (thickness)
nap=autezza (spessore)
bro=altezza (spessore)
es=alto (grosor)
fr=hauteur (épaisseur)
de=Höhe (Stärke)
pt=altura (espessura)
ru=высота (толщина)
ko=높이 (두께)
zh=高度 (粗细)
ja=高さ (太さ)
@=Bar1BorderSize Bar2BorderSize
en=black frame around it
nap=curnice nera attuorno
bro=cornice nera intorno
es=marco negro alrededor
fr=cadre noir autour
de=schwarzer Rahmen darum
pt=moldura preta ao redor
ru=чёрная рамка вокруг
ko=바깥 검은 테두리
zh=外围的黑色边框
ja=周囲の黒い枠
@=Bar1OffsetY Bar2OffsetY
en=vertical position (+ = lower)
nap=pusizione verticale (+ = cchiù abbascio)
bro=posizione verticale (+ = più giù)
es=posición vertical (+ = más abajo)
fr=position verticale (+ = plus bas)
de=vertikale Position (+ = tiefer)
pt=posição vertical (+ = mais baixo)
ru=вертикальное положение (+ = ниже)
ko=세로 위치 (+ = 아래쪽)
zh=垂直位置 (+ = 更低)
ja=垂直位置 (+ = 下)
@=Bar1OffsetX Bar2OffsetX
en=horizontal position (+ = right)
nap=pusizione orizzontale (+ = a deritta)
bro=posizione orizzontale (+ = destra)
es=posición horizontal (+ = derecha)
fr=position horizontale (+ = droite)
de=horizontale Position (+ = rechts)
pt=posição horizontal (+ = direita)
ru=горизонтальное положение (+ = правее)
ko=가로 위치 (+ = 오른쪽)
zh=水平位置 (+ = 向右)
ja=水平位置 (+ = 右)
@=Bar1CenterGap Bar2CenterGap
en=empty space between the two halves
nap=spazio vacante tra 'e doje mità
bro=spazio vuoto tra le due metà
es=espacio vacío entre las dos mitades
fr=espace vide entre les deux moitiés
de=leerer Raum zwischen den beiden Hälften
pt=espaço vazio entre as duas metades
ru=пустое пространство между двумя половинами
ko=두 반쪽 사이의 빈 공간
zh=左右两半之间的空隙
ja=左右の半分の間の空き
@=Bar1Skew Bar2Skew
en=slant of the sides (0 = rectangle)
nap=pennenza d'e lati (0 = rettangolo)
bro=quanto sono storti i lati (0 = rettangolo)
es=inclinación de los lados (0 = rectángulo)
fr=inclinaison des côtés (0 = rectangle)
de=Neigung der Seiten (0 = Rechteck)
pt=inclinação dos lados (0 = retângulo)
ru=наклон боков (0 = прямоугольник)
ko=옆면의 기울기 (0 = 직사각형)
zh=两侧的倾斜度 (0 = 矩形)
ja=側面の傾き (0 = 長方形)
@=LootBorderSize CombatBorderSize
en=thickness of the outer black border (px)
nap=spessore d'o bordino niro 'e fora (px)
bro=spessore del bordino nero fuori (px)
es=grosor del borde negro exterior (px)
fr=épaisseur de la bordure noire extérieure (px)
de=Stärke des äußeren schwarzen Rands (px)
pt=espessura da borda preta externa (px)
ru=толщина внешней чёрной обводки (px)
ko=바깥 검은 테두리의 두께 (px)
zh=外侧黑色描边的粗细 (px)
ja=外側の黒い縁の太さ (px)
)" "`n"
        s .= "
(
@=LootOffsetX
en=Loot icon (F10)\nposition relative to the screen center (px, - = left)
nap=Icona Loot (F10)\npusizione rispetto 'o miezo d'o schermo (px, - = a mancina)
bro=Icona Loot (F10)\nposizione rispetto al centro dello schermo (px, - = sinistra)
es=Icono Loot (F10)\nposición respecto al centro de la pantalla (px, - = izquierda)
fr=Icône Loot (F10)\nposition par rapport au centre de l'écran (px, - = gauche)
de=Loot-Symbol (F10)\nPosition relativ zur Bildschirmmitte (px, - = links)
pt=Ícone Loot (F10)\nposição em relação ao centro da tela (px, - = esquerda)
ru=Иконка Loot (F10)\nположение относительно центра экрана (px, - = левее)
ko=Loot 아이콘 (F10)\n화면 중앙 기준 위치 (px, - = 왼쪽)
zh=Loot 图标 (F10)\n相对屏幕中心的位置 (px,- = 向左)
ja=Loot アイコン (F10)\n画面中央からの位置 (px、- = 左)
@=LootOffsetY
en=(px, + = lower)
nap=(px, + = cchiù abbascio)
bro=(px, + = più giù)
es=(px, + = más abajo)
fr=(px, + = plus bas)
de=(px, + = tiefer)
pt=(px, + = mais baixo)
ru=(px, + = ниже)
ko=(px, + = 아래쪽)
zh=(px,+ = 更低)
ja=(px、+ = 下)
@=LootTextLine1
@it=testo in alto
en=top text
nap=testo 'ncoppa
bro=testo sopra
es=texto superior
fr=texte du haut
de=Text oben
pt=texto de cima
ru=верхний текст
ko=상단 텍스트
zh=上方文字
ja=上テキスト
@=LootEmoji
@it=emoji al centro
en=emoji in the middle
nap=emoji 'mmiezo
bro=emoji in mezzo
es=emoji en el centro
fr=emoji au centre
de=Emoji in der Mitte
pt=emoji no meio
ru=эмодзи в центре
ko=가운데 이모지
zh=中央 emoji
ja=中央の絵文字
@=LootTextLine3
@it=testo in basso
en=bottom text
nap=testo abbascio
bro=testo sotto
es=texto inferior
fr=texte du bas
de=Text unten
pt=texto de baixo
ru=нижний текст
ko=하단 텍스트
zh=下方文字
ja=下テキスト
@=LootBaseFontSize
en=Loot icon text and emoji (offsets in px: + = right / lower)\nsize of the text (top and bottom lines)
nap=Testo ed emoji 'e ll'icona Loot (spustamente in px: + = a deritta / cchiù abbascio)\ngrandezza d'o testo (righe 'ncoppa e abbascio)
bro=Testo ed emoji dell'icona Loot (spostamenti in px: + = destra / più giù)\nsize del testo (righe sopra e sotto)
es=Texto y emoji del icono Loot (desplazamientos en px: + = derecha / más abajo)\ntamaño del texto (líneas superior e inferior)
fr=Texte et emoji de l'icône Loot (décalages en px : + = droite / plus bas)\ntaille du texte (lignes du haut et du bas)
de=Text und Emoji des Loot-Symbols (Versatz in px: + = rechts / tiefer)\nGröße des Textes (obere und untere Zeile)
pt=Texto e emoji do ícone Loot (deslocamentos em px: + = direita / mais baixo)\ntamanho do texto (linhas de cima e de baixo)
ru=Текст и эмодзи иконки Loot (смещения в px: + = правее / ниже)\nразмер текста (верхняя и нижняя строки)
ko=Loot 아이콘 텍스트와 이모지 (오프셋은 px: + = 오른쪽 / 아래쪽)\n텍스트 크기 (상단 및 하단 줄)
zh=Loot 图标的文字和 emoji (偏移单位 px:+ = 向右 / 更低)\n文字大小 (上下两行)
ja=Loot アイコンのテキストと絵文字 (オフセットは px: + = 右 / 下)\nテキストのサイズ (上下の行)
@=LootEmojiSize
en=size of the center emoji
nap=grandezza d'a emoji 'mmiezo
bro=size dell'emoji in mezzo
es=tamaño del emoji central
fr=taille de l'emoji central
de=Größe des Emojis in der Mitte
pt=tamanho do emoji central
ru=размер эмодзи в центре
ko=가운데 이모지 크기
zh=中央 emoji 的大小
ja=中央の絵文字のサイズ
@=LootLine1OffsetX LootLine1OffsetY
en=offset of the top text
nap=spustamento d'o testo 'ncoppa
bro=spostamento del testo sopra
es=desplazamiento del texto superior
fr=décalage du texte du haut
de=Versatz des oberen Textes
pt=deslocamento do texto de cima
ru=смещение верхнего текста
ko=상단 텍스트 오프셋
zh=上方文字的偏移
ja=上テキストのオフセット
@=LootEmojiOffsetX LootEmojiOffsetY
en=offset of the emoji (- = higher)
nap=spustamento d'a emoji (- = cchiù 'ncoppa)
bro=spostamento dell'emoji (- = più su)
es=desplazamiento del emoji (- = más arriba)
fr=décalage de l'emoji (- = plus haut)
de=Versatz des Emojis (- = höher)
pt=deslocamento do emoji (- = mais alto)
ru=смещение эмодзи (- = выше)
ko=이모지 오프셋 (- = 위쪽)
zh=emoji 的偏移 (- = 更高)
ja=絵文字のオフセット (- = 上)
@=LootLine3OffsetX LootLine3OffsetY
en=offset of the bottom text
nap=spustamento d'o testo abbascio
bro=spostamento del testo sotto
es=desplazamiento del texto inferior
fr=décalage du texte du bas
de=Versatz des unteren Textes
pt=deslocamento do texto de baixo
ru=смещение нижнего текста
ko=하단 텍스트 오프셋
zh=下方文字的偏移
ja=下テキストのオフセット
@=LootTextColor
en=text color
nap=culore d'o testo
bro=colore del testo
es=color del texto
fr=couleur du texte
de=Textfarbe
pt=cor do texto
ru=цвет текста
ko=텍스트 색상
zh=文字颜色
ja=テキスト色
@=LootOutlineColor
en=text outline color (1 px)
nap=culore d'o cuntorno d'o testo (1 px)
bro=colore del bordo del testo (1 px)
es=color del contorno del texto (1 px)
fr=couleur du contour du texte (1 px)
de=Farbe der Textkontur (1 px)
pt=cor do contorno do texto (1 px)
ru=цвет контура текста (1 px)
ko=텍스트 외곽선 색상 (1 px)
zh=文字描边颜色 (1 px)
ja=テキスト輪郭色 (1 px)
@=LootShape
en=Icon shape (the "diameter" LootSize becomes its height):\n"cerchio"    = round (classic)\n"quadrato"   = square\n"rettangolo" = rectangular, wider than tall (1.5 : 1)\n"triangolo"  = triangular, tip up (the top text moves down a bit)\n"trapezio"   = trapezoid, narrower at the top\nEffects (pulse, ring, spin, glow) and frame follow the chosen shape.
nap=Forma 'e ll'icona ('o "diametro" LootSize addeventa ll'autezza soja):\n"cerchio"    = tonna (classica)\n"quadrato"   = quadrata\n"rettangolo" = rettangolare, cchiù larga ca auta (1,5 : 1)\n"triangolo"  = triangolare cu 'a ponta 'ncoppa ('o testo 'ncoppa scenne nu poco)\n"trapezio"   = trapezio, cchiù stritto 'ncoppa\nEffette (pulse, ring, spin, glow) e curnice vanno appriesso â forma scigliuta.
bro=Shape dell'icona (il "diametro" LootSize diventa la sua altezza):\n"cerchio"    = tonda (classica)\n"quadrato"   = quadrata\n"rettangolo" = rettangolare, più larga che alta (1,5 : 1)\n"triangolo"  = triangolo con la punta in su (il testo sopra scende un po')\n"trapezio"   = trapezio, più stretto in alto\nEffetti (pulse, ring, spin, glow) e cornice seguono la shape scelta.
es=Forma del icono (el "diámetro" LootSize pasa a ser su altura):\n"cerchio"    = redondo (clásico)\n"quadrato"   = cuadrado\n"rettangolo" = rectangular, más ancho que alto (1.5 : 1)\n"triangolo"  = triangular, con la punta hacia arriba (el texto superior baja un poco)\n"trapezio"   = trapecio, más estrecho arriba\nLos efectos (pulse, ring, spin, glow) y el marco siguen la forma elegida.
fr=Forme de l'icône (le "diamètre" LootSize devient sa hauteur) :\n"cerchio"    = ronde (classique)\n"quadrato"   = carrée\n"rettangolo" = rectangulaire, plus large que haute (1.5 : 1)\n"triangolo"  = triangulaire, pointe en haut (le texte du haut descend un peu)\n"trapezio"   = trapèze, plus étroit en haut\nLes effets (pulse, ring, spin, glow) et le cadre suivent la forme choisie.
de=Symbolform (der "Durchmesser" LootSize wird zu seiner Höhe):\n"cerchio"    = rund (klassisch)\n"quadrato"   = quadratisch\n"rettangolo" = rechteckig, breiter als hoch (1.5 : 1)\n"triangolo"  = dreieckig, Spitze oben (der obere Text rutscht etwas nach unten)\n"trapezio"   = Trapez, oben schmaler\nEffekte (pulse, ring, spin, glow) und Rahmen folgen der gewählten Form.
pt=Forma do ícone (o "diâmetro" LootSize passa a ser a altura):\n"cerchio"    = redondo (clássico)\n"quadrato"   = quadrado\n"rettangolo" = retangular, mais largo que alto (1.5 : 1)\n"triangolo"  = triangular, ponta para cima (o texto de cima desce um pouco)\n"trapezio"   = trapézio, mais estreito em cima\nOs efeitos (pulse, ring, spin, glow) e a moldura seguem a forma escolhida.
ru=Форма иконки ("диаметр" LootSize становится её высотой):\n"cerchio"    = круглая (классика)\n"quadrato"   = квадрат\n"rettangolo" = прямоугольник, шире чем выше (1.5 : 1)\n"triangolo"  = треугольник вершиной вверх (верхний текст немного смещается вниз)\n"trapezio"   = трапеция, сужающаяся кверху\nЭффекты (pulse, ring, spin, glow) и рамка следуют выбранной форме.
ko=아이콘 모양 ("지름" LootSize가 높이가 돼요):\n"cerchio"    = 원형 (기본)\n"quadrato"   = 정사각형\n"rettangolo" = 직사각형, 세로보다 가로가 길어요 (1.5 : 1)\n"triangolo"  = 삼각형, 꼭짓점이 위 (상단 텍스트가 조금 아래로 내려가요)\n"trapezio"   = 사다리꼴, 위쪽이 더 좁아요\n효과 (pulse, ring, spin, glow)와 테두리는 선택한 모양을 따라가요.
zh=图标形状 ("直径" LootSize 即为其高度):\n"cerchio"    = 圆形 (经典)\n"quadrato"   = 正方形\n"rettangolo" = 矩形,宽大于高 (1.5 : 1)\n"triangolo"  = 三角形,尖端向上 (上方文字略微下移)\n"trapezio"   = 梯形,上窄下宽\n特效 (pulse、ring、spin、glow) 和边框会跟随所选形状。
ja=アイコン形状 ("直径" LootSize が高さになります):\n"cerchio"    = 円形 (標準)\n"quadrato"   = 正方形\n"rettangolo" = 長方形、横長 (1.5 : 1)\n"triangolo"  = 三角形、頂点が上 (上テキストは少し下に移動)\n"trapezio"   = 台形、上が狭い\nエフェクト (pulse、ring、spin、glow) と枠は選択した形状に従います。
@=CombatIconEnabled
en=Combat icon (F9)\nfalse = icon not shown
nap=Icona Combat (F9)\nfalse = icona ca nun se vede
bro=Icona Combat (F9)\nfalse = icona nascosta
es=Icono Combat (F9)\nfalse = icono oculto
fr=Icône Combat (F9)\nfalse = icône non affichée
de=Combat-Symbol (F9)\nfalse = Symbol nicht angezeigt
pt=Ícone Combat (F9)\nfalse = ícone não mostrado
ru=Иконка Combat (F9)\nfalse = иконка не показывается
ko=Combat 아이콘 (F9)\nfalse = 아이콘 숨김
zh=Combat 图标 (F9)\nfalse = 不显示图标
ja=Combat アイコン (F9)\nfalse = アイコン非表示
)" "`n"
        s .= "
(
@=CombatTextLine1
@it=testo in alto dell'icona Combat
en=top text of the Combat icon
nap=testo 'ncoppa 'e ll'icona Combat
bro=testo sopra dell'icona Combat
es=texto superior del icono Combat
fr=texte du haut de l'icône Combat
de=oberer Text des Combat-Symbols
pt=texto de cima do ícone Combat
ru=верхний текст иконки Combat
ko=상단 텍스트
zh=Combat 图标的上方文字
ja=Combat アイコンの上テキスト
@=CombatEmoji
@it=emoji al centro dell'icona Combat
en=emoji in the middle of the Combat icon
nap=emoji 'mmiezo 'e ll'icona Combat
bro=emoji in mezzo all'icona Combat
es=emoji en el centro del icono Combat
fr=emoji au centre de l'icône Combat
de=Emoji in der Mitte des Combat-Symbols
pt=emoji no meio do ícone Combat
ru=эмодзи в центре иконки Combat
ko=가운데 이모지
zh=Combat 图标的中央 emoji
ja=Combat アイコン中央の絵文字
@=CombatTextLine3
@it=testo in basso dell'icona Combat
en=bottom text of the Combat icon
nap=testo abbascio 'e ll'icona Combat
bro=testo sotto dell'icona Combat
es=texto inferior del icono Combat
fr=texte du bas de l'icône Combat
de=unterer Text des Combat-Symbols
pt=texto de baixo do ícone Combat
ru=нижний текст иконки Combat
ko=하단 텍스트
zh=Combat 图标的下方文字
ja=Combat アイコンの下テキスト
@=CombatFontSize
en=Combat icon text and emoji. An Loot name (e.g. LootEmojiSize) = same as the Loot;\nor type a number to make it independent.\ntext size
nap=Testo ed emoji 'e ll'icona Combat. Nu nomme Loot (p'esempio LootEmojiSize) = eguale a lil Loot;\no scrive nu nummero pe' 'a fa' indipendente.\ngrandezza d'o testo
bro=Testo ed emoji dell'icona Combat. Un nome Loot (tipo LootEmojiSize) = uguale al Loot;\noppure scrivi un numero per farla indipendente.\nsize del testo
es=Texto y emoji del icono Combat. Un nombre de Loot (p. ej. LootEmojiSize) = igual que el Loot;\no escribe un número para hacerlo independiente.\ntamaño del texto
fr=Texte et emoji de l'icône Combat. Un nom Loot (ex. LootEmojiSize) = identique à il Loot ;\nou saisis un nombre pour la rendre indépendante.\ntaille du texte
de=Text und Emoji des Combat-Symbols. Ein Loot-Name (z. B. LootEmojiSize) = wie beim Loot;\noder gib eine Zahl ein, um es unabhängig zu machen.\nTextgröße
pt=Texto e emoji do ícone Combat. Um nome do Loot (ex.: LootEmojiSize) = igual ao Loot;\nou digite um número para torná-lo independente.\ntamanho do texto
ru=Текст и эмодзи иконки Combat. Имя параметра Loot (напр. LootEmojiSize) = как у Loot;\nили введите число, чтобы сделать независимым.\nразмер текста
ko=Combat 아이콘 텍스트와 이모지. Loot 이름 (예: LootEmojiSize) = Loot과 동일;\n또는 숫자를 입력해 독립적으로 설정해요.\n텍스트 크기
zh=Combat 图标的文字和 emoji。填写 Loot 的名称 (如 LootEmojiSize) = 与 Loot 相同;\n或填写数字使其独立。\n文字大小
ja=Combat アイコンのテキストと絵文字。Loot の名前 (例: LootEmojiSize) = Loot と同じ;\nまたは数値を入力して独立させます。\nテキストサイズ
@=CombatEmojiSize
en=emoji size
nap=grandezza d'a emoji
bro=size dell'emoji
es=tamaño del emoji
fr=taille de l'emoji
de=Emoji-Größe
pt=tamanho do emoji
ru=размер эмодзи
ko=이모지 크기
zh=emoji 大小
ja=絵文字サイズ
@=CombatLine1OffsetX CombatLine1OffsetY
en=offset of the top text
nap=spustamento d'o testo 'ncoppa
bro=spostamento del testo sopra
es=desplazamiento del texto superior
fr=décalage du texte du haut
de=Versatz des oberen Textes
pt=deslocamento do texto de cima
ru=смещение верхнего текста
ko=상단 텍스트 오프셋
zh=上方文字的偏移
ja=上テキストのオフセット
@=CombatEmojiOffsetX CombatEmojiOffsetY
en=offset of the emoji
nap=spustamento d'a emoji
bro=spostamento dell'emoji
es=desplazamiento del emoji
fr=décalage de l'emoji
de=Versatz des Emojis
pt=deslocamento do emoji
ru=смещение эмодзи
ko=이모지 오프셋
zh=emoji 的偏移
ja=絵文字のオフセット
@=CombatLine3OffsetX CombatLine3OffsetY
en=offset of the bottom text
nap=spustamento d'o testo abbascio
bro=spostamento del testo sotto
es=desplazamiento del texto inferior
fr=décalage du texte du bas
de=Versatz des unteren Textes
pt=deslocamento do texto de baixo
ru=смещение нижнего текста
ko=하단 텍스트 오프셋
zh=下方文字的偏移
ja=下テキストのオフセット
@=CombatTextColor
en=text color
nap=culore d'o testo
bro=colore del testo
es=color del texto
fr=couleur du texte
de=Textfarbe
pt=cor do texto
ru=цвет текста
ko=텍스트 색상
zh=文字颜色
ja=テキスト色
@=CombatOutlineColor
en=text outline color
nap=culore d'o cuntorno d'o testo
bro=colore del bordo del testo
es=color del contorno del texto
fr=couleur du contour du texte
de=Farbe der Textkontur
pt=cor do contorno do texto
ru=цвет контура текста
ko=텍스트 외곽선 색상
zh=文字描边颜色
ja=テキスト輪郭色
@=CombatIdleColor
en=color when idle (active = ColorActive)
nap=culore quanno è stutata (appicciata = ColorActive)
bro=colore quando è in chill (acceso = ColorActive)
es=color cuando está inactivo (activo = ColorActive)
fr=couleur à l'état inactif (actif = ColorActive)
de=Farbe im Ruhezustand (aktiv = ColorActive)
pt=cor quando inativo (ativo = ColorActive)
ru=цвет в неактивном состоянии (активный = ColorActive)
ko=비활성일 때의 색상 (활성 = ColorActive)
zh=未激活时的颜色 (激活 = ColorActive)
ja=無効時の色 (有効時 = ColorActive)
@=CombatShape
en=shape: "cerchio" | "quadrato" | "rettangolo" | "triangolo" | "trapezio"\n(the same as the Loot icon, see above)
nap=forma: "cerchio" | "quadrato" | "rettangolo" | "triangolo" | "trapezio"\n('e stesse 'e ll'icona Loot, vide 'a coppa)
bro=shape: "cerchio" | "quadrato" | "rettangolo" | "triangolo" | "trapezio"\n(le stesse dell'icona Loot, guarda sopra)
es=forma: "cerchio" | "quadrato" | "rettangolo" | "triangolo" | "trapezio"\n(igual que el icono Loot, ver arriba)
fr=forme : "cerchio" | "quadrato" | "rettangolo" | "triangolo" | "trapezio"\n(la même que l'icône Loot, voir ci-dessus)
de=Form: "cerchio" | "quadrato" | "rettangolo" | "triangolo" | "trapezio"\n(dieselben wie beim Loot-Symbol, siehe oben)
pt=forma: "cerchio" | "quadrato" | "rettangolo" | "triangolo" | "trapezio"\n(igual ao ícone Loot, veja acima)
ru=форма: "cerchio" | "quadrato" | "rettangolo" | "triangolo" | "trapezio"\n(как у иконки Loot, см. выше)
ko=모양: "cerchio" | "quadrato" | "rettangolo" | "triangolo" | "trapezio"\n(Loot 아이콘과 동일, 위 참고)
zh=形状:"cerchio" | "quadrato" | "rettangolo" | "triangolo" | "trapezio"\n(与 Loot 图标相同,见上文)
ja=形状: "cerchio" | "quadrato" | "rettangolo" | "triangolo" | "trapezio"\n(Loot アイコンと同じ、上記参照)
)" "`n"
        s .= "
(
@=LootAnim CombatAnim
@it=Effetti animati in stato ON. Si possono combinare: spunta uno o più effetti.\n"pulse" = alone luminoso che "respira" attorno al cerchio\n"ring"  = onde ad anello che partono dal bordo e si allargano svanendo (sonar)\n"spin"  = arco luminoso con scia che gira sul bordo (caricamento)\n"glow"  = il cerchio si illumina a intermittenza\nNessuno spuntato = nessun effetto
en=Animated effects in ON state. They can be combined: tick one or more effects.\n"pulse" = glowing halo that "breathes" around the circle\n"ring"  = ring waves starting from the edge and widening as they fade (sonar)\n"spin"  = glowing arc with a trail spinning along the edge (loading)\n"glow"  = the circle lights up intermittently\nNone ticked = no effect
nap=Effette animate int'ô stato ON. Se ponno mmescà: spunta uno o cchiù effette.\n"pulse" = alone luminoso ca "rispira" attuorno 'o cerchio\n"ring"  = onde a anello ca partono d'o bordo e s'allargano scumparenno (sonar)\n"spin"  = arco luminoso cu 'a scia ca gira 'ncopp'ô bordo (caricamento)\n"glow"  = 'o cerchio s'allumma a intermittenza\nNisciuno spuntato = nisciuno effetto
bro=Effetti animati nello stato ON. Li puoi mixare: spunta uno o più effetti.\n"pulse" = alone luminoso che "respira" intorno al cerchio\n"ring"  = onde ad anello che partono dal bordo e si allargano sparendo (sonar)\n"spin"  = arco luminoso con scia che gira sul bordo (caricamento)\n"glow"  = il cerchio si illumina a scatti\nNiente spuntato = zero effetti
es=Efectos animados en estado ON. Se pueden combinar: marca uno o más efectos.\n"pulse" = halo luminoso que "respira" alrededor del círculo\n"ring"  = ondas en forma de anillo que parten del borde y se ensanchan desvaneciéndose (sónar)\n"spin"  = arco luminoso con estela que gira por el borde (carga)\n"glow"  = el círculo se ilumina de forma intermitente\nNinguno marcado = sin efectos
fr=Effets animés à l'état ON. Ils peuvent être combinés : coche un ou plusieurs effets.\n"pulse" = halo lumineux qui "respire" autour du cercle\n"ring"  = ondes en anneau qui partent du bord et s'élargissent en s'estompant (sonar)\n"spin"  = arc lumineux avec traînée qui tourne sur le bord (chargement)\n"glow"  = le cercle s'illumine par intermittence\nRien de coché = aucun effet
de=Animierte Effekte im Zustand ON. Sie lassen sich kombinieren: Hake einen oder mehrere Effekte an.\n"pulse" = leuchtender Halo, der um den Kreis "atmet"\n"ring"  = Ringwellen, die vom Rand ausgehen und sich ausbreitend verblassen (Sonar)\n"spin"  = leuchtender Bogen mit Schweif, der sich am Rand dreht (Ladeanzeige)\n"glow"  = der Kreis leuchtet intermittierend auf\nNichts angehakt = kein Effekt
pt=Efeitos animados no estado ON. Podem ser combinados: marque um ou mais efeitos.\n"pulse" = halo luminoso que "respira" ao redor do círculo\n"ring"  = ondas em anel que saem da borda e se alargam sumindo (sonar)\n"spin"  = arco luminoso com rastro que gira na borda (carregamento)\n"glow"  = o círculo acende de forma intermitente\nNenhum marcado = sem efeito
ru=Анимированные эффекты в состоянии ON. Их можно комбинировать: отметьте один или несколько эффектов.\n"pulse" = светящийся ореол, который "дышит" вокруг круга\n"ring"  = кольцевые волны от края, расходящиеся и затухающие (сонар)\n"spin"  = светящаяся дуга со шлейфом, бегущая по краю (загрузка)\n"glow"  = круг загорается с перебоями\nНичего не отмечено = без эффектов
ko=ON 상태의 애니메이션 효과. 조합할 수 있어요: 효과를 하나 이상 체크하세요.\n"pulse" = 원 주위에서 "숨 쉬듯" 빛나는 후광\n"ring"  = 가장자리에서 시작해 퍼져 나가며 사라지는 링 파동 (소나)\n"spin"  = 꼬리가 달린 빛나는 호가 가장자리를 따라 회전 (로딩)\n"glow"  = 원이 깜빡이며 빛나요\n아무것도 체크하지 않으면 효과 없음
zh=ON 状态下的动画特效。可以组合使用:勾选一个或多个特效。\n"pulse" = 圆圈周围 "呼吸" 的发光光晕\n"ring"  = 从边缘出发、边扩散边消失的环形波 (声呐)\n"spin"  = 沿边缘旋转、带拖尾的发光弧 (加载)\n"glow"  = 圆圈间歇性亮起\n都不勾选 = 无特效
ja=ON 状態のアニメーション効果。組み合わせ可能: 1つ以上の効果にチェックを入れます。\n"pulse" = 円の周りで "呼吸" する発光ハロー\n"ring"  = 縁から広がりながら消えるリング状の波 (ソナー)\n"spin"  = 縁を回る尾を引く発光アーク (ローディング)\n"glow"  = 円が断続的に光る\nチェックなし = エフェクトなし
@=LootFxPadding CombatFxPadding
en=space around the circle reserved for the effects (px).\nRaise it if the effects look cut off.
nap=spazio attuorno 'o cerchio tenuto pe' ll'effette (px).\nAizalo si ll'effette pareno tagliate.
bro=spazio intorno al cerchio tenuto per gli effetti (px).\nAlzalo se gli effetti escono tagliati.
es=espacio alrededor del círculo reservado para los efectos (px).\nSúbelo si los efectos se ven cortados.
fr=espace autour du cercle réservé aux effets (px).\nAugmente-le si les effets semblent coupés.
de=Platz um den Kreis, der für die Effekte reserviert ist (px).\nErhöhe ihn, wenn die Effekte abgeschnitten aussehen.
pt=espaço ao redor do círculo reservado para os efeitos (px).\nAumente se os efeitos parecerem cortados.
ru=пространство вокруг круга, зарезервированное под эффекты (px).\nУвеличьте, если эффекты выглядят обрезанными.
ko=효과를 위해 원 주위에 확보해 둔 공간 (px).\n효과가 잘려 보이면 값을 올리세요.
zh=为特效预留的圆圈周围空间 (px)。\n如果特效看起来被截断,请调大。
ja=エフェクト用に確保する円の周囲の余白 (px)。\nエフェクトが途切れて見える場合は大きくしてください。
@=LootPulseCycle CombatPulseCycle
en="pulse"\nms for one full breath
nap="pulse"\nms pe' nu rispiro sano
bro="pulse"\nms per un respiro completo
es="pulse"\nms de una respiración completa
fr="pulse"\nms pour une respiration complète
de="pulse"\nms für einen ganzen Atemzug
pt="pulse"\nms de uma respiração completa
ru="pulse"\nms на один полный вдох
ko="pulse"\n한 번 숨 쉬는 ms
zh="pulse"\n一次完整呼吸的 ms 数
ja="pulse"\n1回の呼吸の ms
@=LootPulseSize CombatPulseSize
en=how much the halo widens (px)
nap=quanto s'allarga ll'alone (px)
bro=quanto si allarga l'alone (px)
es=cuánto se ensancha el halo (px)
fr=de combien le halo s'élargit (px)
de=wie stark sich der Halo ausdehnt (px)
pt=quanto o halo se alarga (px)
ru=насколько расширяется ореол (px)
ko=후광이 넓어지는 정도 (px)
zh=光晕扩大的幅度 (px)
ja=ハローが広がる幅 (px)
@=LootPulseOpacity CombatPulseOpacity
en=intensity (0..1)
nap=forza (0..1)
bro=potenza (0..1)
es=intensidad (0..1)
fr=intensité (0..1)
de=Intensität (0..1)
pt=intensidade (0..1)
ru=интенсивность (0..1)
ko=강도 (0..1)
zh=强度 (0..1)
ja=強度 (0..1)
@=LootPulseColor CombatPulseColor
@it=colore dell'effetto "pulse"
en=color of the "pulse" effect
nap=culore 'e ll'effetto "pulse"
bro=colore dell'effetto "pulse"
es=color del efecto "pulse"
fr=couleur de l'effet "pulse"
de=Farbe des "pulse"-Effekts
pt=cor do efeito "pulse"
ru=цвет эффекта "pulse"
ko="pulse" 효과의 색상
zh="pulse" 特效的颜色
ja="pulse" エフェクトの色
@=LootRingCycle CombatRingCycle
en="ring"\nms of life of one wave
nap="ring"\nms 'e vita 'e n'onda
bro="ring"\nms di vita di un'onda
es="ring"\nms de vida de una onda
fr="ring"\nms de vie d'une onde
de="ring"\nms Lebensdauer einer Welle
pt="ring"\nms de vida de uma onda
ru="ring"\nms жизни одной волны
ko="ring"\n파동 하나의 지속 시간 ms
zh="ring"\n一道波存在的 ms 数
ja="ring"\n波1つの持続 ms
@=LootRingCount CombatRingCount
en=waves present at once (staggered)
nap=onde ca stanno 'nsieme (sfasate)
bro=onde insieme (sfasate)
es=ondas presentes a la vez (escalonadas)
fr=ondes présentes en même temps (décalées)
de=gleichzeitig vorhandene Wellen (versetzt)
pt=ondas presentes ao mesmo tempo (defasadas)
ru=волн одновременно (со сдвигом)
ko=동시에 존재하는 파동 수 (시차 있음)
zh=同时存在的波数 (错开出现)
ja=同時に存在する波の数 (ずらして発生)
@=LootRingDistance CombatRingDistance
en=px traveled by the wave before fading
nap=px ca fa ll'onda primma 'e scumparì
bro=px che fa l'onda prima di sparire
es=px que recorre la onda antes de desvanecerse
fr=px parcourus par l'onde avant de s'estomper
de=px, die die Welle zurücklegt, bevor sie verblasst
pt=px percorridos pela onda antes de sumir
ru=px, которые проходит волна до исчезновения
ko=사라지기 전 파동이 이동하는 px
zh=波在消失前行进的 px 数
ja=波が消えるまでに進む px
@=LootRingThickness CombatRingThickness
en=ring thickness (px)
nap=spessore 'e ll'anello (px)
bro=spessore dell'anello (px)
es=grosor del anillo (px)
fr=épaisseur de l'anneau (px)
de=Ringstärke (px)
pt=espessura do anel (px)
ru=толщина кольца (px)
ko=링 두께 (px)
zh=环的粗细 (px)
ja=リングの太さ (px)
@=LootRingOpacity CombatRingOpacity
en=intensity (0..1)
nap=forza (0..1)
bro=potenza (0..1)
es=intensidad (0..1)
fr=intensité (0..1)
de=Intensität (0..1)
pt=intensidade (0..1)
ru=интенсивность (0..1)
ko=강도 (0..1)
zh=强度 (0..1)
ja=強度 (0..1)
@=LootRingColor CombatRingColor
@it=colore dell'effetto "ring"
en=color of the "ring" effect
nap=culore 'e ll'effetto "ring"
bro=colore dell'effetto "ring"
es=color del efecto "ring"
fr=couleur de l'effet "ring"
de=Farbe des "ring"-Effekts
pt=cor do efeito "ring"
ru=цвет эффекта "ring"
ko="ring" 효과의 색상
zh="ring" 特效的颜色
ja="ring" エフェクトの色
@=LootSpinCycle CombatSpinCycle
en="spin"\nms for one full lap
nap="spin"\nms pe' nu giro sano
bro="spin"\nms per un giro completo
es="spin"\nms de una vuelta completa
fr="spin"\nms pour un tour complet
de="spin"\nms für eine ganze Runde
pt="spin"\nms de uma volta completa
ru="spin"\nms на один полный оборот
ko="spin"\n한 바퀴 도는 데 걸리는 ms
zh="spin"\n旋转一整圈的 ms 数
ja="spin"\n1周の ms
)" "`n"
        s .= "
(
@=LootSpinArc CombatSpinArc
en=length of the arc with trail (degrees, 360 = full circle)
nap=lunghezza 'e ll'arco cu 'a scia (grade, 360 = cerchio sano)
bro=lunghezza dell'arco con la scia (gradi, 360 = cerchio intero)
es=longitud del arco con estela (grados, 360 = círculo completo)
fr=longueur de l'arc avec traînée (degrés, 360 = cercle complet)
de=Länge des Bogens mit Schweif (Grad, 360 = voller Kreis)
pt=comprimento do arco com rastro (graus, 360 = círculo completo)
ru=длина дуги со шлейфом (градусы, 360 = полный круг)
ko=꼬리가 있는 호의 길이 (도, 360 = 완전한 원)
zh=带拖尾的弧长 (度,360 = 整圆)
ja=尾を含む弧の長さ (度、360 = 全円)
@=LootSpinThickness CombatSpinThickness
en=arc thickness (px)
nap=spessore 'e ll'arco (px)
bro=spessore dell'arco (px)
es=grosor del arco (px)
fr=épaisseur de l'arc (px)
de=Bogenstärke (px)
pt=espessura do arco (px)
ru=толщина дуги (px)
ko=호 두께 (px)
zh=弧的粗细 (px)
ja=弧の太さ (px)
@=LootSpinColor CombatSpinColor
@it=colore dell'effetto "spin"
en=color of the "spin" effect
nap=culore 'e ll'effetto "spin"
bro=colore dell'effetto "spin"
es=color del efecto "spin"
fr=couleur de l'effet "spin"
de=Farbe des "spin"-Effekts
pt=cor do efeito "spin"
ru=цвет эффекта "spin"
ko="spin" 효과의 색상
zh="spin" 特效的颜色
ja="spin" エフェクトの色
@=LootGlowCycle CombatGlowCycle
en="glow"\nms for one pulse
nap="glow"\nms pe' na pulsazione
bro="glow"\nms per una pulsazione
es="glow"\nms de un pulso
fr="glow"\nms pour une pulsation
de="glow"\nms für einen Puls
pt="glow"\nms de uma pulsação
ru="glow"\nms на одну пульсацию
ko="glow"\n한 번 깜빡이는 ms
zh="glow"\n一次脉动的 ms 数
ja="glow"\n1回の点滅の ms
@=LootGlowColor CombatGlowColor
@it=colore dell'effetto "glow"
en=color of the "glow" effect
nap=culore 'e ll'effetto "glow"
bro=colore dell'effetto "glow"
es=color del efecto "glow"
fr=couleur de l'effet "glow"
de=Farbe des "glow"-Effekts
pt=cor do efeito "glow"
ru=цвет эффекта "glow"
ko="glow" 효과의 색상
zh="glow" 特效的颜色
ja="glow" エフェクトの色
@=LootGlowAmount CombatGlowAmount
en=intensity (0..1)
nap=forza (0..1)
bro=potenza (0..1)
es=intensidad (0..1)
fr=intensité (0..1)
de=Intensität (0..1)
pt=intensidade (0..1)
ru=интенсивность (0..1)
ko=강도 (0..1)
zh=强度 (0..1)
ja=強度 (0..1)
@=LootMorphInTime CombatMorphInTime
en=Switching the icons on/off\nseconds to turn the effects on
nap=Appiccia/stuta 'e icone\nsecondi pe' appiccià ll'effette
bro=Accensione/spegnimento delle icone\nsecondi per accendere gli effetti
es=Encendido y apagado de los iconos\nsegundos para encender los efectos
fr=Allumage/extinction des icônes\nsecondes pour allumer les effets
de=Symbole ein-/ausschalten\nSekunden, um die Effekte einzuschalten
pt=Ligar/desligar os ícones\nsegundos para ligar os efeitos
ru=Включение/выключение иконок\nсекунд на включение эффектов
ko=아이콘 켜기/끄기\n효과가 켜지는 데 걸리는 초
zh=图标开/关切换\n开启特效所需的秒数
ja=アイコンのオン/オフ切り替え\nエフェクトを点灯するまでの秒数
@=LootMorphOutTime CombatMorphOutTime
en=seconds to turn the effects off
nap=secondi pe' stutà ll'effette
bro=secondi per spegnere gli effetti
es=segundos para apagar los efectos
fr=secondes pour éteindre les effets
de=Sekunden, um die Effekte auszuschalten
pt=segundos para desligar os efeitos
ru=секунд на выключение эффектов
ko=효과가 꺼지는 데 걸리는 초
zh=关闭特效所需的秒数
ja=エフェクトを消灯するまでの秒数
@=LootFadeOutTime CombatFadeOutTime
en=seconds of fade of the icon when it goes back to idle
nap=secondi 'e dissolvenza 'e ll'icona quanno se stuta
bro=secondi di fade dell'icona quando torna in chill
es=segundos de fundido del icono al volver a inactivo
fr=secondes de fondu de l'icône quand elle repasse à l'état inactif
de=Sekunden Ausblenden des Symbols, wenn es in den Ruhezustand zurückgeht
pt=segundos de fade do ícone quando volta a inativo
ru=секунд плавного исчезновения иконки при возврате в неактивное состояние
ko=아이콘이 비활성으로 돌아갈 때의 페이드 초
zh=图标回到未激活状态时淡出的秒数
ja=アイコンが待機に戻るときのフェード秒数
@=LootColorFadeOutTime CombatColorFadeOutTime
en=seconds to fade from the active color to the idle one
nap=secondi pe' sfumà d'o culore appicciato a chillo stutato
bro=secondi per sfumare dal colore acceso a quello chill
es=segundos para pasar del color activo al inactivo
fr=secondes pour passer de la couleur active à la couleur inactive
de=Sekunden für den Farbverlauf von der Aktivfarbe zur Inaktivfarbe
pt=segundos para passar da cor ativa para a inativa
ru=секунд на переход от активного цвета к неактивному
ko=활성 색상에서 비활성 색상으로 바뀌는 데 걸리는 초
zh=从激活颜色渐变到未激活颜色所需的秒数
ja=有効色から無効色へフェードする秒数
@=AnimInterval
en=ms between one frame and the next of all animations (16 ≈ 60 fps)\n(used only with PerfProfile "manuale", see [PRESTAZIONI])
nap=ms tra nu fotogramma e n'ato 'e tutte ll'animaziune (16 ≈ 60 fps)\n(serve sulo cu PerfProfile "manuale", vide [PRESTAZIONI])
bro=ms tra un frame e l'altro di tutte le animazioni (16 ≈ 60 fps)\n(solo col PerfProfile "manuale", guarda [PRESTAZIONI])
es=ms entre un fotograma y el siguiente de todas las animaciones (16 ≈ 60 fps)\n(usado solo con PerfProfile "manuale", ver [PRESTAZIONI])
fr=ms entre une image et la suivante de toutes les animations (16 ≈ 60 fps)\n(utilisé uniquement avec PerfProfile "manuale", voir [PRESTAZIONI])
de=ms zwischen einem Bild und dem nächsten aller Animationen (16 ≈ 60 fps)\n(nur mit PerfProfile "manuale" verwendet, siehe [PRESTAZIONI])
pt=ms entre um quadro e o seguinte de todas as animações (16 ≈ 60 fps)\n(usado só com PerfProfile "manuale", veja [PRESTAZIONI])
ru=ms между одним кадром и следующим у всех анимаций (16 ≈ 60 fps)\n(используется только с PerfProfile "manuale", см. [PRESTAZIONI])
ko=모든 애니메이션의 프레임 사이 ms (16 ≈ 60 fps)\n(PerfProfile "manuale"에서만 사용, [PRESTAZIONI] 참고)
zh=所有动画每帧之间的 ms 数 (16 ≈ 60 fps)\n(仅在 PerfProfile 为 "manuale" 时使用,见 [PRESTAZIONI])
ja=全アニメーションのフレーム間隔 ms (16 ≈ 60 fps)\n(PerfProfile "manuale" のときのみ使用、[PRESTAZIONI] を参照)
@=FadeInTime
en=seconds of fade when the HUD appears
nap=secondi 'e dissolvenza quanno ll'HUD compare
bro=secondi di fade quando l'HUD spunta
es=segundos de fundido cuando aparece el HUD
fr=secondes de fondu à l'apparition du HUD
de=Sekunden Einblenden, wenn das HUD erscheint
pt=segundos de fade quando o HUD aparece
ru=секунд плавного появления, когда HUD появляется
ko=HUD가 나타날 때의 페이드 초
zh=HUD 出现时淡入的秒数
ja=HUD 表示時のフェード秒数
@=FadeOutTime
en=seconds of fade when the HUD goes back to idle
nap=secondi 'e dissolvenza quanno ll'HUD se stuta
bro=secondi di fade quando l'HUD torna in chill
es=segundos de fundido cuando el HUD vuelve a inactivo
fr=secondes de fondu quand le HUD repasse à l'état inactif
de=Sekunden Ausblenden, wenn das HUD in den Ruhezustand zurückgeht
pt=segundos de fade quando o HUD volta a inativo
ru=секунд плавного исчезновения, когда HUD возвращается в неактивное состояние
ko=HUD가 비활성으로 돌아갈 때의 페이드 초
zh=HUD 回到未激活状态时淡出的秒数
ja=HUD が待機に戻るときのフェード秒数
@=FadeEasing
en=true = smooth fades (they start and end slowing down)
nap=true = dissolvenze morbide (partono e fernesceno chiano chiano)
bro=true = fade smooth (partono e finiscono rallentando)
es=true = fundidos suaves (empiezan y terminan frenando)
fr=true = fondus doux (ils démarrent et finissent en ralentissant)
de=true = weiche Übergänge (sie starten und enden langsamer werdend)
pt=true = fades suaves (começam e terminam desacelerando)
ru=true = мягкие переходы (начинаются и заканчиваются с замедлением)
ko=true = 부드러운 페이드 (시작과 끝에서 느려짐)
zh=true = 平滑淡入淡出 (开始和结束时会减速)
ja=true = 滑らかなフェード (開始と終了でゆっくりになる)
@=ColorFadeInTime
en=seconds to switch to the active color (0 = instant)
nap=secondi pe' passà â culore appicciato (0 = subbito)
bro=secondi per passare al colore acceso (0 = istantaneo)
es=segundos para pasar al color activo (0 = instantáneo)
fr=secondes pour passer à la couleur active (0 = instantané)
de=Sekunden bis zum Wechsel zur Aktivfarbe (0 = sofort)
pt=segundos para mudar para a cor ativa (0 = instantâneo)
ru=секунд на переход к активному цвету (0 = мгновенно)
ko=활성 색상으로 바뀌는 데 걸리는 초 (0 = 즉시)
zh=切换到激活颜色所需的秒数 (0 = 立即)
ja=有効色に切り替える秒数 (0 = 即時)
@=ColorFadeOutTime
en=seconds to fade towards the idle color
nap=secondi pe' sfumà verso 'o culore stutato
bro=secondi per sfumare verso il colore chill
es=segundos para pasar al color inactivo
fr=secondes pour passer à la couleur inactive
de=Sekunden für den Verlauf zur Inaktivfarbe
pt=segundos para esmaecer em direção à cor inativa
ru=секунд на переход к неактивному цвету
ko=비활성 색상으로 서서히 바뀌는 데 걸리는 초
zh=渐变到未激活颜色所需的秒数
ja=無効色へフェードする秒数
)" "`n"
        s .= "
(
@=EnableCrosshairFadeIn EnableCrosshairFadeOut
en=Fades on/off for each element.\nWith a fade turned off the element appears/stays fully visible, without fading.\nfade in                    fade out\ncrosshair
nap=Dissolvenze appicciate/stutate pe' ogne piezzo.\nCu na dissolvenza stutata 'o piezzo compare/resta chino, senza sfumà.\nquanno trase                    quanno esce\nmirino
bro=Fade accesi/spenti per ogni pezzo.\nCon un fade spento il pezzo appare/resta pieno, senza sfumare.\nfade in                    fade out\nmirino
es=Fundidos de entrada/salida para cada elemento.\nCon un fundido desactivado el elemento aparece/permanece totalmente visible, sin fundido.\nfundido de entrada       fundido de salida\nmira
fr=Fondus activés/désactivés pour chaque élément.\nAvec un fondu désactivé, l'élément apparaît/reste pleinement visible, sans fondu.\nfondu d'entrée             fondu de sortie\nviseur
de=Ein-/Ausblenden für jedes Element.\nBei ausgeschaltetem Fade erscheint das Element bzw. bleibt voll sichtbar, ohne Überblendung.\nEinblenden                    Ausblenden\nFadenkreuz
pt=Fades ligados/desligados para cada elemento.\nCom um fade desligado o elemento aparece/permanece totalmente visível, sem fade.\nfade in                    fade out\nmira
ru=Плавное появление/исчезновение для каждого элемента.\nЕсли переход выключен, элемент появляется/остаётся полностью видимым, без плавности.\nпоявление                   исчезновение\nприцел
ko=요소별 페이드 켜기/끄기.\n페이드를 끄면 요소가 페이드 없이 완전히 보이게 나타나거나 유지돼요.\n페이드 인                  페이드 아웃\n조준선
zh=为每个元素开启/关闭淡入淡出。\n关闭淡入淡出后,该元素会直接完整显示/保持完整可见,不做渐变。\n淡入                    淡出\n准星
ja=要素ごとのフェードのオン/オフ。\nフェードをオフにすると、その要素はフェードせず完全に表示されます。\nフェードイン                    フェードアウト\n照準
@=EnableBar1FadeIn EnableBar1FadeOut
en=bar 1
nap=barra 1
bro=barra 1
es=barra 1
fr=barre 1
de=Balken 1
pt=barra 1
ru=полоса 1
ko=바 1
zh=条 1
ja=バー1
@=EnableBar2FadeIn EnableBar2FadeOut
en=bar 2
nap=barra 2
bro=barra 2
es=barra 2
fr=barre 2
de=Balken 2
pt=barra 2
ru=полоса 2
ko=바 2
zh=条 2
ja=バー2
@=HiddenCubeEnabled
en=true = on when the script starts
nap=true = appicciato quanno parte 'o script
bro=true = acceso appena parte lo script
es=true = activo cuando arranca el script
fr=true = actif au lancement du script
de=true = beim Start des Skripts an
pt=true = ligado quando o script inicia
ru=true = включён при запуске скрипта
ko=true = 스크립트가 시작될 때 켜짐
zh=true = 脚本启动时开启
ja=true = スクリプト起動時に有効
@=HiddenCubeInterval
en=ms between one check and the next while waiting for the window\n(used only with PerfProfile "manuale", see [PRESTAZIONI])
nap=ms tra nu cuntrollo e n'ato mentre aspetta 'a fenesta\n(serve sulo cu PerfProfile "manuale", vide [PRESTAZIONI])
bro=ms tra un check e l'altro mentre aspetta la finestra\n(solo col PerfProfile "manuale", guarda [PRESTAZIONI])
es=ms entre una comprobación y la siguiente mientras se espera la ventana\n(usado solo con PerfProfile "manuale", ver [PRESTAZIONI])
fr=ms entre une vérification et la suivante en attendant la fenêtre\n(utilisé uniquement avec PerfProfile "manuale", voir [PRESTAZIONI])
de=ms zwischen einer Prüfung und der nächsten, während auf das Fenster gewartet wird\n(nur mit PerfProfile "manuale" verwendet, siehe [PRESTAZIONI])
pt=ms entre uma verificação e a seguinte enquanto espera a janela\n(usado só com PerfProfile "manuale", veja [PRESTAZIONI])
ru=ms между одной проверкой и следующей, пока ждём окно\n(используется только с PerfProfile "manuale", см. [PRESTAZIONI])
ko=창을 기다리는 동안 확인 사이의 ms\n(PerfProfile "manuale"에서만 사용, [PRESTAZIONI] 참고)
zh=等待窗口出现时,两次检查之间的 ms 数\n(仅在 PerfProfile 为 "manuale" 时使用,见 [PRESTAZIONI])
ja=ウィンドウ待機中のチェック間隔 ms\n(PerfProfile "manuale" のときのみ使用、[PRESTAZIONI] を参照)
@=HiddenCubeCheckSlot
en=true = also requires the turquoise key slot\n(avoids triggering on other popups with similar buttons)
nap=true = vo' pure 'o slot turchese d'a chiave\n(accussì nun scatta 'ncopp'a ati popup cu pulsante simile)
bro=true = vuole anche lo slot turchese della chiave\n(così non scatta su altri popup con bottoni simili)
es=true = exige además el slot turquesa de la llave\n(evita que se active con otros popups con botones parecidos)
fr=true = exige aussi le slot turquoise de la clé\n(évite de se déclencher sur d'autres popups avec des boutons similaires)
de=true = verlangt auch den türkisfarbenen Schlüssel-Slot\n(verhindert Auslösen bei anderen Popups mit ähnlichen Buttons)
pt=true = exige também o slot turquesa da chave\n(evita disparar em outros popups com botões parecidos)
ru=true = также требует бирюзовый слот ключа\n(чтобы не срабатывать на других окнах с похожими кнопками)
ko=true = 터콰이즈색 열쇠 슬롯도 필요해요\n(비슷한 버튼이 있는 다른 팝업에서 작동하는 것을 막아 줘요)
zh=true = 同时要求青绿色的钥匙栏位\n(避免被其他带有相似按钮的弹窗误触发)
ja=true = ターコイズのキースロットも必須にする\n(似たボタンを持つ他のポップアップでの誤作動を防ぐ)
@=HiddenCubeOffsetX
en=Mouse point\nfine correction of the point (px measured in 4K, they adapt on their own)
nap=Punto d'o mouse\ncorrezione fina d'o punto (px misurate in 4K, s'adattano 'a sule)
bro=Punto del mouse\nritocco fine del punto (px misurati in 4K, si adattano da soli)
es=Punto del ratón\ncorrección fina del punto (px medidos en 4K, se adaptan solos)
fr=Point de la souris\ncorrection fine du point (px mesurés en 4K, ils s'adaptent tout seuls)
de=Mauspunkt\nFeinkorrektur des Punktes (px, in 4K gemessen, sie passen sich von selbst an)
pt=Ponto do mouse\ncorreção fina do ponto (px medidos em 4K, adaptam-se sozinhos)
ru=Точка для мыши\nтонкая поправка точки (px, замеренные в 4K, подстраиваются сами)
ko=마우스 지점\n지점 미세 보정 (4K 기준으로 측정한 px, 알아서 맞춰져요)
zh=鼠标定位点\n对该点进行微调 (以 4K 测量的 px,会自动适配)
ja=マウスポイント\nポイントの微調整 (4Kで計測した px、自動で調整されます)
@=HiddenCubeOffsetY
en=e.g. HiddenCubeOffsetY := -10 = a bit higher
nap=p'esempio HiddenCubeOffsetY := -10 = nu poco cchiù 'ncoppa
bro=tipo HiddenCubeOffsetY := -10 = un po' più su
es=p. ej. HiddenCubeOffsetY := -10 = un poco más arriba
fr=ex. HiddenCubeOffsetY := -10 = un peu plus haut
de=z. B. HiddenCubeOffsetY := -10 = etwas höher
pt=ex.: HiddenCubeOffsetY := -10 = um pouco mais alto
ru=напр. HiddenCubeOffsetY := -10 = чуть выше
ko=예: HiddenCubeOffsetY := -10 = 조금 더 위
zh=例如 HiddenCubeOffsetY := -10 = 稍微更高一点
ja=例: HiddenCubeOffsetY := -10 = 少し上
@=HiddenCubeLockMouse
en=Mouse lock\ntrue  = while the window is open the mouse is brought back\nonto the button as soon as it moves (lock)\nfalse = the mouse is moved only once, then it is free
nap=Blocco d'o mouse\ntrue  = nfino a quanno 'a fenesta è aperta 'o mouse torna\n'ncopp'ô pulsante appena se move (blocco)\nfalse = 'o mouse se sposta na vota sola, po' è libero
bro=Lock del mouse\ntrue  = finché la finestra è aperta il mouse torna\nsul bottone appena lo muovi (lock)\nfalse = il mouse viene spostato una volta sola, poi è libero
es=Bloqueo del ratón\ntrue  = mientras la ventana está abierta el ratón vuelve\nal botón en cuanto se mueve (bloqueo)\nfalse = el ratón se mueve solo una vez, luego queda libre
fr=Verrou de la souris\ntrue  = tant que la fenêtre est ouverte, la souris est ramenée\nsur le bouton dès qu'elle bouge (verrou)\nfalse = la souris n'est déplacée qu'une fois, puis elle est libre
de=Maussperre\ntrue  = solange das Fenster offen ist, wird die Maus sofort auf den Button\nzurückgeholt, sobald sie sich bewegt (Sperre)\nfalse = die Maus wird nur einmal bewegt, danach ist sie frei
pt=Trava do mouse\ntrue  = enquanto a janela estiver aberta o mouse é levado de volta\nao botão assim que se mexe (trava)\nfalse = o mouse é movido só uma vez, depois fica livre
ru=Фиксация мыши\ntrue  = пока окно открыто, мышь возвращается\nна кнопку, как только сдвинется (фиксация)\nfalse = мышь перемещается только один раз, потом свободна
ko=마우스 고정\ntrue  = 창이 열려 있는 동안 마우스가 움직이면 바로\n버튼 위로 되돌려 놓아요 (고정)\nfalse = 마우스를 한 번만 옮기고 이후엔 자유로워요
zh=鼠标锁定\ntrue  = 窗口打开期间,鼠标一旦移动就会被拉回\n按钮上 (锁定)\nfalse = 鼠标只移动一次,之后可自由移动
ja=マウスロック\ntrue  = ウィンドウが開いている間、マウスが動くとすぐに\nボタンへ戻されます (ロック)\nfalse = マウスは1回だけ移動し、その後は自由
)" "`n"
        s .= "
(
@=HiddenCubeLockInterval
en=ms between one check and the next during the lock\n(lower = stiffer lock, 30-50 = softer)\n(used only with PerfProfile "manuale", see [PRESTAZIONI])
nap=ms tra nu cuntrollo e n'ato durante 'o blocco\n(cchiù basso = blocco cchiù tuosto, 30-50 = cchiù muscio)\n(serve sulo cu PerfProfile "manuale", vide [PRESTAZIONI])
bro=ms tra un check e l'altro durante il lock\n(più basso = lock più tosto, 30-50 = più morbido)\n(solo col PerfProfile "manuale", guarda [PRESTAZIONI])
es=ms entre una comprobación y la siguiente durante el bloqueo\n(menos = bloqueo más rígido, 30-50 = más suave)\n(usado solo con PerfProfile "manuale", ver [PRESTAZIONI])
fr=ms entre une vérification et la suivante pendant le verrou\n(plus bas = verrou plus rigide, 30-50 = plus souple)\n(utilisé uniquement avec PerfProfile "manuale", voir [PRESTAZIONI])
de=ms zwischen einer Prüfung und der nächsten während der Sperre\n(niedriger = härtere Sperre, 30-50 = weicher)\n(nur mit PerfProfile "manuale" verwendet, siehe [PRESTAZIONI])
pt=ms entre uma verificação e a seguinte durante a trava\n(menor = trava mais rígida, 30-50 = mais suave)\n(usado só com PerfProfile "manuale", veja [PRESTAZIONI])
ru=ms между одной проверкой и следующей во время фиксации\n(меньше = жёстче фиксация, 30-50 = мягче)\n(используется только с PerfProfile "manuale", см. [PRESTAZIONI])
ko=고정 중 확인 사이의 ms\n(낮을수록 단단한 고정, 30-50 = 부드러움)\n(PerfProfile "manuale"에서만 사용, [PRESTAZIONI] 참고)
zh=锁定期间两次检查之间的 ms 数\n(越小锁定越硬,30-50 = 较柔和)\n(仅在 PerfProfile 为 "manuale" 时使用,见 [PRESTAZIONI])
ja=ロック中のチェック間隔 ms\n(小さいほど硬いロック、30-50 = 柔らかめ)\n(PerfProfile "manuale" のときのみ使用、[PRESTAZIONI] を参照)
@=HiddenCubeRearmTime
en=ms the window must stay closed before the tool\nre-arms for the next one (avoids double triggers)
nap=ms ca 'a fenesta adda sta' chiusa primma ca 'o tool\nse riappiccia pe' chella appriesso (accussì nun scatta doje vote)
bro=ms che la finestra deve restare chiusa prima che il tool\nsi riarmi per la prossima (niente doppi scatti)
es=ms que la ventana debe permanecer cerrada antes de que la herramienta\nse rearme para la siguiente (evita dobles activaciones)
fr=ms pendant lesquelles la fenêtre doit rester fermée avant que l'outil\nse réarme pour la suivante (évite les doubles déclenchements)
de=ms, die das Fenster geschlossen bleiben muss, bevor das Tool\nfür das nächste wieder bereit ist (verhindert doppeltes Auslösen)
pt=ms que a janela deve ficar fechada antes de a ferramenta\nse rearmar para a próxima (evita disparos duplos)
ru=ms, сколько окно должно оставаться закрытым, прежде чем инструмент\nснова взведётся для следующего (исключает двойные срабатывания)
ko=다음 큐브를 위해 도구가 다시 준비되기 전에\n창이 닫혀 있어야 하는 ms (중복 작동 방지)
zh=窗口必须保持关闭多少 ms 后,工具才会\n为下一个重新待命 (避免重复触发)
ja=ウィンドウが閉じたままでいる必要がある ms。その後ツールが\n次回に備えて再有効化されます (二重発動防止)
@=HiddenCubeAutoClick
en=Automatic click\ntrue = after moving it also clicks "Open with Key"\n(if the game blocks simulated clicks it has no effect)
nap=Click automatico\ntrue = doppo 'o spustamento clicca pure "Open with Key"\n(si 'o juoco blocca 'e click finte nun fa niente)
bro=Click automatico\ntrue = dopo lo spostamento clicca anche "Open with Key"\n(se il gioco blocca i click finti non fa niente, rip)
es=Clic automático\ntrue = tras moverlo hace también clic en "Open with Key"\n(si el juego bloquea los clics simulados no tiene efecto)
fr=Clic automatique\ntrue = après le déplacement, il clique aussi sur "Open with Key"\n(si le jeu bloque les clics simulés, cela n'a aucun effet)
de=Automatischer Klick\ntrue = nach dem Bewegen klickt es auch auf "Open with Key"\n(blockiert das Spiel simulierte Klicks, bleibt es ohne Wirkung)
pt=Clique automático\ntrue = depois de mover também clica em "Open with Key"\n(se o jogo bloquear cliques simulados não tem efeito)
ru=Автоклик\ntrue = после перемещения ещё и кликает "Open with Key"\n(если игра блокирует имитацию кликов, эффекта нет)
ko=자동 클릭\ntrue = 이동한 뒤 "Open with Key"도 클릭해요\n(게임이 가상 클릭을 막으면 효과가 없어요)
zh=自动点击\ntrue = 移动后还会点击 "Open with Key"\n(如果游戏屏蔽模拟点击,则无效)
ja=自動クリック\ntrue = 移動後に "Open with Key" もクリックする\n(ゲームがシミュレートされたクリックをブロックする場合は効果なし)
@=HiddenCubeClickDelay
en=ms between the move and the click (only with AutoClick)
nap=ms tra 'o spustamento e 'o click (sulo cu AutoClick)
bro=ms tra lo spostamento e il click (solo con AutoClick)
es=ms entre el movimiento y el clic (solo con AutoClick)
fr=ms entre le déplacement et le clic (uniquement avec AutoClick)
de=ms zwischen Bewegung und Klick (nur mit AutoClick)
pt=ms entre o movimento e o clique (só com AutoClick)
ru=ms между перемещением и кликом (только с AutoClick)
ko=이동과 클릭 사이의 ms (AutoClick 사용 시에만)
zh=移动与点击之间的 ms 数 (仅限 AutoClick)
ja=移動からクリックまでの ms (AutoClick 使用時のみ)
@=HiddenCubeDebug
en=true = on-screen notice every time the window is recognized
nap=true = avviso a schermo ogne vota ca 'a fenesta vene arricanusciuta
bro=true = avviso a schermo ogni volta che la finestra viene sgamata
es=true = aviso en pantalla cada vez que se reconoce la ventana
fr=true = avis à l'écran à chaque reconnaissance de la fenêtre
de=true = Hinweis auf dem Bildschirm bei jeder Erkennung des Fensters
pt=true = aviso na tela toda vez que a janela é reconhecida
ru=true = экранное уведомление при каждом распознавании окна
ko=true = 창이 인식될 때마다 화면에 알림 표시
zh=true = 每次识别到窗口时在屏幕上显示提示
ja=true = ウィンドウが認識されるたびに画面に通知を表示
@=FieldBossEnabled
en=true = on when the script starts
nap=true = appicciato quanno parte 'o script
bro=true = acceso appena parte lo script
es=true = activo cuando arranca el script
fr=true = actif au lancement du script
de=true = beim Einschalten des Skripts an
pt=true = ligado quando o script inicia
ru=true = включён при запуске скрипта
ko=true = 스크립트가 시작될 때 켜짐
zh=true = 脚本启动时开启
ja=true = スクリプト起動時に有効
@=FieldBossGuideOnOpen
en=true = when the map opens it brings the cursor straight to\nExploration > Field Boss; false = free mouse (recommended)
nap=true = quanno s'arape 'a mappa porta subbito 'o cursore 'ncopp'a\nExploration > Field Boss; false = mouse libero (consigliato)
bro=true = quando apri la mappa porta subito il cursore su\nExploration > Field Boss; false = mouse libero (consigliato)
es=true = al abrir el mapa lleva el cursor directamente a\nExploration > Field Boss; false = ratón libre (recomendado)
fr=true = à l'ouverture de la carte, il amène le curseur directement sur\nExploration > Field Boss ; false = souris libre (recommandé)
de=true = beim Öffnen der Karte führt es den Cursor direkt zu\nExploration > Field Boss; false = freie Maus (empfohlen)
pt=true = ao abrir o mapa leva o cursor direto para\nExploration > Field Boss; false = mouse livre (recomendado)
ru=true = при открытии карты курсор сразу переходит к\nExploration > Field Boss; false = свободная мышь (рекомендуется)
ko=true = 지도를 열면 커서를 바로\nExploration > Field Boss로 가져가요; false = 마우스 자유 (권장)
zh=true = 打开地图时,直接把光标带到\nExploration > Field Boss;false = 鼠标自由 (推荐)
ja=true = マップを開くと、カーソルを直接\nExploration > Field Boss へ移動します; false = マウスは自由 (推奨)
)" "`n"
        s .= "
(
@=FieldBossLockMouse
en=Click steps (after choosing a boss: Exploration, Field Boss, boss name,\nempty spot to close the loot, Teleport). The script brings the cursor to the right spot,\nyou click: like a minigame, with a big instruction at the bottom center.\ntrue  = as soon as you pick a boss the mouse is locked: only the\nscript moves it and in each step it stays on the spot to click\n(you can't miss it). It unlocks after the Travel (double F),\nwith Esc, by closing the map or switching to another window.\nfalse = the cursor is brought to the spots but stays free
nap=Fase 'e click (doppo c'he scigliuto nu boss: Exploration, Field Boss, nomme d'o boss,\npunto vacante pe' chiudere 'e loot, Teleport). 'O script porta 'o cursore 'ncopp'ô punto giusto,\ntu clicche: comme a nu minigioco, cu na struzzione grossa abbascio 'o miezo.\ntrue  = appena scigli nu boss 'o mouse se blocca: 'o move sulo\n'o script e a ogne fase resta fermo 'ncopp'ô punto 'a cliccà\n(nun 'o può sbaglià). Se sblocca doppo 'o Travel (doppia F),\ncu Esc, chiudenno 'a mappa o passanno a n'ata fenesta.\nfalse = 'o cursore vene purtato 'ncopp'ê punte ma resta libero
bro=Step di click (dopo che scegli un boss: Exploration, Field Boss, nome del boss,\npunto vuoto per chiudere il loot, Teleport). Lo script porta il cursore nel punto giusto,\ntu clicchi: tipo minigioco, con una dritta grossa in basso al centro.\ntrue  = appena scegli un boss il mouse va in lock: lo muove solo\nlo script e a ogni step resta fermo sul punto da cliccare\n(non puoi sbagliare, zero skill issue). Si sblocca dopo il Travel (doppia F),\ncon Esc, chiudendo la mappa o cambiando finestra.\nfalse = il cursore viene portato sui punti ma resta libero
es=Pasos de clic (tras elegir un boss: Exploration, Field Boss, nombre del boss,\npunto vacío para cerrar el botín, Teleport). El script lleva el cursor al sitio correcto,\ntú haces clic: como un minijuego, con una instrucción grande abajo en el centro.\ntrue  = en cuanto eliges un boss el ratón queda bloqueado: solo el\nscript lo mueve y en cada paso se queda en el punto donde hacer clic\n(no puedes fallar). Se desbloquea tras el Travel (doble F),\ncon Esc, al cerrar el mapa o al cambiar a otra ventana.\nfalse = el cursor se lleva a los puntos pero queda libre
fr=Étapes de clic (après le choix d'un boss : Exploration, Field Boss, nom du boss,\npoint vide pour fermer le butin, Teleport). Le script amène le curseur au bon endroit,\ntu cliques : comme un minijeu, avec une grande instruction en bas au centre.\ntrue  = dès que tu choisis un boss, la souris est verrouillée : seul le\nscript la déplace et à chaque étape elle reste sur l'endroit où cliquer\n(impossible de se tromper). Elle se déverrouille après le Travel (double F),\navec Esc, en fermant la carte ou en passant à une autre fenêtre.\nfalse = le curseur est amené aux endroits mais reste libre
de=Klick-Schritte (nach der Wahl eines Bosses: Exploration, Field Boss, Boss-Name,\nleere Stelle zum Schließen des Loots, Teleport). Das Skript führt den Cursor zur richtigen Stelle,\ndu klickst: wie ein Minispiel, mit einer großen Anweisung unten in der Mitte.\ntrue  = sobald du einen Boss wählst, ist die Maus gesperrt: nur das\nSkript bewegt sie, und in jedem Schritt bleibt sie auf der Klickstelle\n(du kannst nicht danebenklicken). Sie wird nach dem Travel (doppeltes F),\nmit Esc, durch Schließen der Karte oder beim Wechsel in ein anderes Fenster freigegeben.\nfalse = der Cursor wird zu den Stellen geführt, bleibt aber frei
pt=Passos de clique (depois de escolher um boss: Exploration, Field Boss, nome do boss,\nponto vazio para fechar o loot, Teleport). O script leva o cursor ao ponto certo,\nvocê clica: como um minigame, com uma instrução grande embaixo no centro.\ntrue  = assim que você escolhe um boss o mouse é travado: só o\nscript o move e em cada passo ele fica no ponto a clicar\n(não dá para errar). Destrava depois do Travel (F duplo),\ncom Esc, fechando o mapa ou trocando para outra janela.\nfalse = o cursor é levado aos pontos mas continua livre
ru=Шаги кликов (после выбора босса: Exploration, Field Boss, имя босса,\nпустое место для закрытия окна добычи, Teleport). Скрипт подводит курсор к нужному месту,\nвы кликаете: как в мини-игре, с крупной подсказкой внизу по центру.\ntrue  = как только вы выбираете босса, мышь блокируется: двигает её\nтолько скрипт, и на каждом шаге она стоит на месте для клика\n(промахнуться нельзя). Разблокируется после Travel (двойное F),\nпо Esc, при закрытии карты или переключении на другое окно.\nfalse = курсор подводится к местам, но остаётся свободным
ko=클릭 단계 (보스 선택 후: Exploration, Field Boss, 보스 이름,\n전리품을 닫는 빈 곳, Teleport). 스크립트가 커서를 알맞은 위치로 옮기고\n클릭은 직접 해요: 미니게임처럼, 화면 하단 중앙에 큰 안내문이 나와요.\ntrue  = 보스를 고르면 바로 마우스가 잠겨요: 스크립트만\n마우스를 움직이고 각 단계에서 클릭할 지점에 머물러요\n(잘못 누를 수 없어요). Travel(F 두 번) 후, Esc를 누르거나,\n지도를 닫거나, 다른 창으로 전환하면 잠금이 풀려요.\nfalse = 커서는 지점으로 이동하지만 자유로운 상태예요
zh=点击步骤 (选择首领后:Exploration、Field Boss、首领名称、\n空白处以关闭战利品、Teleport)。脚本会把光标带到正确位置,\n由你点击:像小游戏一样,屏幕底部中央有大号指示。\ntrue  = 一选中首领,鼠标就被锁定:只有\n脚本能移动它,且每一步它都停在要点击的位置\n(不会点错)。在 Travel (双击 F) 之后、\n按 Esc、关闭地图或切换到其他窗口时解除锁定。\nfalse = 光标会被带到这些位置,但依然可以自由移动
ja=クリック手順 (ボス選択後: Exploration、Field Boss、ボス名、\nドロップ枠を閉じるための空きスペース、Teleport)。スクリプトがカーソルを正しい位置に移動し、\nあなたがクリックします。ミニゲームのように、画面下中央に大きな案内が出ます。\ntrue  = ボスを選ぶとすぐにマウスがロックされます: スクリプトだけが\nマウスを動かし、各手順でクリックすべき位置に留まります\n(押し間違いなし)。Travel (F 2回押し) 後、\nEsc、マップを閉じる、または別のウィンドウへ切り替えるとロック解除されます。\nfalse = カーソルは位置に移動しますが自由なまま
)" "`n"
        s .= "
(
@=FieldBossBlockClicks
en=true  = from choosing the boss until the Travel, clicks (left and right)\nreach the game ONLY in the steps where you have to click;\nin the others they are blocked, so you can't get anything wrong.\nEverything unlocks after the Travel (F pressed the number of times\nset below), with Esc, or by closing the map.\nThe Field Boss panel always stays clickable.\nfalse = no click blocking
nap=true  = d'a scelta d'o boss nfino 'o Travel 'e click (sinistro e destro)\narrivano 'o juoco SULO int'ê fase addò hê 'a cliccà;\nint'ê ati vengono bloccate, accussì nun sbaglie niente.\nTutto se sblocca doppo 'o Travel (F premmuto 'e vote\nscritte 'a sotto), cu Esc, o chiudenno 'a mappa.\n'O pannello Field Boss se pò sempe cliccà.\nfalse = nisciuno blocco d'e click
bro=true  = dalla scelta del boss fino al Travel i click (sinistro e destro)\narrivano al gioco SOLO negli step dove devi cliccare;\nnegli altri vengono bloccati, così non sbagli niente.\nTutto si sblocca dopo il Travel (F premuto le volte\nscritte sotto), con Esc, o chiudendo la mappa.\nIl pannello Field Boss si può sempre cliccare.\nfalse = zero blocchi sui click
es=true  = desde que eliges el boss hasta el Travel, los clics (izquierdo y derecho)\nllegan al juego SOLO en los pasos en los que tienes que hacer clic;\nen los demás se bloquean, así que no puedes equivocarte.\nTodo se desbloquea tras el Travel (F pulsada el número de veces\nindicado abajo), con Esc o al cerrar el mapa.\nEl panel Field Boss siempre se puede pulsar.\nfalse = sin bloqueo de clics
fr=true  = du choix du boss jusqu'au Travel, les clics (gauche et droit)\narrivent au jeu UNIQUEMENT aux étapes où tu dois cliquer ;\naux autres, ils sont bloqués, pour que tu ne puisses rien rater.\nTout se déverrouille après le Travel (F pressé le nombre de fois\ndéfini plus bas), avec Esc, ou en fermant la carte.\nLe panneau Field Boss reste toujours cliquable.\nfalse = pas de blocage des clics
de=true  = von der Wahl des Bosses bis zum Travel erreichen Klicks (links und rechts)\ndas Spiel NUR in den Schritten, in denen du klicken musst;\nin den anderen werden sie blockiert, damit du nichts falsch machen kannst.\nAlles wird nach dem Travel (F so oft gedrückt, wie unten\neingestellt), mit Esc oder durch Schließen der Karte freigegeben.\nDas Field Boss Panel bleibt immer anklickbar.\nfalse = keine Klicksperre
pt=true  = da escolha do boss até o Travel, os cliques (esquerdo e direito)\nchegam ao jogo SÓ nos passos em que você deve clicar;\nnos outros ficam bloqueados, então não dá para errar nada.\nTudo destrava depois do Travel (F pressionado o número de vezes\ndefinido abaixo), com Esc, ou fechando o mapa.\nO painel Field Boss continua sempre clicável.\nfalse = sem bloqueio de cliques
ru=true  = от выбора босса до Travel клики (левый и правый)\nдоходят до игры ТОЛЬКО на шагах, где нужно кликнуть;\nна остальных они блокируются, так что ошибиться нельзя.\nВсё разблокируется после Travel (F нажата столько раз,\nсколько задано ниже), по Esc или при закрытии карты.\nПанель Field Boss всегда остаётся кликабельной.\nfalse = клики не блокируются
ko=true  = 보스를 고른 뒤 Travel까지, 클릭(왼쪽과 오른쪽)은\n클릭해야 하는 단계에서만 게임에 전달돼요.\n다른 단계에서는 차단되어 실수할 수 없어요.\nTravel(아래에 설정한 횟수만큼 F 입력) 후, Esc를 누르거나\n지도를 닫으면 모두 풀려요.\nField Boss 패널은 항상 클릭할 수 있어요.\nfalse = 클릭 차단 없음
zh=true  = 从选择首领到 Travel 之前,点击 (左键和右键)\n只在需要你点击的步骤才会传到游戏中;\n其他步骤会被屏蔽,所以你不会点错任何东西。\nTravel 之后 (按 F 达到下面设定的次数)、按 Esc\n或关闭地图时全部解除。\nField Boss 面板始终可以点击。\nfalse = 不屏蔽点击
ja=true  = ボス選択から Travel まで、クリック (左右) は\nクリックが必要な手順でのみゲームに届きます;\nそれ以外ではブロックされるため、間違えようがありません。\nTravel (下で設定した回数だけ F を押した後)、\nEsc、またはマップを閉じるとすべて解除されます。\nField Boss パネルは常にクリック可能です。\nfalse = クリックをブロックしない
@=FieldBossHints
en=true = big instructions at the bottom center + ring on the spot\nfalse = small tooltips near the cursor (as before)
nap=true = struzziune grosse abbascio 'o miezo + anello 'ncopp'ô punto\nfalse = tooltip piccerille vicino 'o cursore (comme primma)
bro=true = dritte grosse in basso al centro + anello sul punto\nfalse = tooltip piccoli vicino al cursore (old school)
es=true = instrucciones grandes abajo en el centro + anillo en el punto\nfalse = tooltips pequeños junto al cursor (como antes)
fr=true = grandes instructions en bas au centre + anneau sur l'endroit\nfalse = petites infobulles près du curseur (comme avant)
de=true = große Anweisungen unten in der Mitte + Ring auf der Stelle\nfalse = kleine Tooltips neben dem Cursor (wie zuvor)
pt=true = instruções grandes embaixo no centro + anel no ponto\nfalse = tooltips pequenos perto do cursor (como antes)
ru=true = крупные подсказки внизу по центру + кольцо на нужном месте\nfalse = маленькие подсказки у курсора (как раньше)
ko=true = 화면 하단 중앙의 큰 안내문 + 해당 지점의 링\nfalse = 커서 근처의 작은 툴팁 (이전 방식)
zh=true = 屏幕底部中央显示大号指示 + 目标位置上的圆环\nfalse = 光标附近的小提示 (与以前一样)
ja=true = 画面下中央に大きな案内 + 位置にリング\nfalse = カーソル付近に小さなツールチップ (従来方式)
@=FieldBossHintScale
en=size of the instruction box (1.0 = normal)
nap=grandezza d'o riquadro d'e struzziune (1.0 = normale)
bro=size del box delle dritte (1.0 = normale)
es=tamaño del cuadro de instrucciones (1.0 = normal)
fr=taille de la boîte d'instructions (1.0 = normale)
de=Größe des Anweisungsfelds (1.0 = normal)
pt=tamanho da caixa de instruções (1.0 = normal)
ru=размер блока подсказок (1.0 = обычный)
ko=안내 상자 크기 (1.0 = 기본)
zh=指示框的大小 (1.0 = 正常)
ja=案内ボックスのサイズ (1.0 = 標準)
@=FieldBossHintBottom
en=distance from the bottom edge of the screen (px at 1440p)
nap=distanza d'o bordo 'e sotto d'o schermo (px a 1440p)
bro=distanza dal bordo sotto dello schermo (px a 1440p)
es=distancia al borde inferior de la pantalla (px a 1440p)
fr=distance par rapport au bord inférieur de l'écran (px en 1440p)
de=Abstand zum unteren Bildschirmrand (px bei 1440p)
pt=distância da borda de baixo da tela (px em 1440p)
ru=расстояние от нижнего края экрана (px при 1440p)
ko=화면 아래쪽 가장자리로부터의 거리 (1440p 기준 px)
zh=距屏幕底边的距离 (1440p 下的 px)
ja=画面下端からの距離 (1440pでの px)
)" "`n"
        s .= "
(
@=FieldBossDirHint
en=Boss direction after the Teleport: when you press F (Travel) and the map closes, at the top\ncenter a big arrow appears for a few seconds with the direction to fly\nto reach the boss, computed from the Teleport position relative to the boss on the map.\nThe direction is the map's one (North = up), like the minimap compass.\nfalse = no indication
nap=Direzione d'o boss doppo 'o Teleport: quanno premme F (Travel) e 'a mappa se chiure, 'ncoppa\n'mmiezo compare pe' quacche secondo na freccia grossa cu 'a direzione addò vulà\npe' arrivà 'o boss, calculata d'a pusizione d'o Teleport rispetto 'o boss 'ncopp'â mappa.\n'A direzione è chella d'a mappa (Nord = 'ncoppa), comme 'a bussola d'a minimappa.\nfalse = nisciuna indicazione
bro=Direzione del boss dopo il Teleport: quando premi F (Travel) e la mappa si chiude, in alto\nal centro spunta per qualche secondo una freccia grossa con la direzione dove volare\nper arrivare al boss, calcolata dalla posizione del Teleport rispetto al boss sulla mappa.\nLa direzione è quella della mappa (Nord = su), tipo la bussola della minimappa.\nfalse = niente freccia
es=Dirección del boss tras el Teleport: cuando pulsas F (Travel) y se cierra el mapa, arriba\nen el centro aparece durante unos segundos una flecha grande con la dirección en la que volar\npara llegar al boss, calculada a partir de la posición del Teleport respecto al boss en el mapa.\nLa dirección es la del mapa (el Norte está arriba), como la brújula del minimapa.\nfalse = sin indicación
fr=Direction du boss après le Teleport : quand tu appuies sur F (Travel) et que la carte se ferme, en haut\nau centre une grande flèche apparaît pendant quelques secondes avec la direction à suivre en volant\npour rejoindre le boss, calculée à partir de la position du Teleport par rapport au boss sur la carte.\nLa direction est celle de la carte (Nord = haut), comme la boussole de la minicarte.\nfalse = aucune indication
de=Boss-Richtung nach dem Teleport: Wenn du F (Travel) drückst und die Karte sich schließt, erscheint oben\nin der Mitte einige Sekunden lang ein großer Pfeil mit der Flugrichtung,\num den Boss zu erreichen, berechnet aus der Teleport-Position relativ zum Boss auf der Karte.\nDie Richtung ist die der Karte (Norden = oben), wie beim Kompass der Minimap.\nfalse = keine Anzeige
pt=Direção do boss depois do Teleport: quando você pressiona F (Travel) e o mapa fecha, no topo\ncentro aparece por alguns segundos uma seta grande com a direção para voar\naté o boss, calculada pela posição do Teleport em relação ao boss no mapa.\nA direção é a do mapa (Norte = para cima), como a bússola do minimapa.\nfalse = sem indicação
ru=Направление к боссу после Teleport: когда вы нажимаете F (Travel) и карта закрывается, вверху\nпо центру на несколько секунд появляется большая стрелка с направлением полёта\nк боссу, рассчитанным по положению Teleport относительно босса на карте.\nНаправление - как на карте (север = вверх), как компас миникарты.\nfalse = без подсказки
ko=Teleport 후 보스 방향: F(Travel)를 눌러 지도가 닫히면 위쪽\n중앙에 큰 화살표가 몇 초 동안 나타나 보스에게 가려면 어느 쪽으로 날아가야 하는지 알려 줘요.\n방향은 지도에서 보스 기준 Teleport 위치로 계산해요.\n방향은 지도의 방향(북쪽 = 위)이며, 미니맵 나침반과 같아요.\nfalse = 표시 안 함
zh=Teleport 之后的首领方向:按 F (Travel) 且地图关闭后,屏幕顶部\n中央会出现一个大箭头,持续几秒,显示要飞往首领的方向,\n根据地图上 Teleport 相对首领的位置计算得出。\n方向以地图为准 (北 = 上),与小地图指南针相同。\nfalse = 不显示指示
ja=Teleport 後のボスの方向: F (Travel) を押してマップが閉じると、画面上部の\n中央に大きな矢印が数秒間表示され、ボスに到達するために飛ぶ方向を示します。\nマップ上のボスに対する Teleport の位置から計算されます。\n方向はマップ基準です (北 = 上)、ミニマップのコンパスと同じです。\nfalse = 表示なし
@=FieldBossDirSeconds
en=how many seconds it stays on screen (with countdown)
nap=pe' quante secondi resta a schermo (cu 'o cunto â reversa)
bro=quanti secondi resta a schermo (con countdown)
es=cuántos segundos permanece en pantalla (con cuenta atrás)
fr=combien de secondes elle reste à l'écran (avec compte à rebours)
de=wie viele Sekunden sie auf dem Bildschirm bleibt (mit Countdown)
pt=quantos segundos fica na tela (com contagem regressiva)
ru=сколько секунд она остаётся на экране (с обратным отсчётом)
ko=화면에 머무는 시간(초, 카운트다운 표시)
zh=在屏幕上停留多少秒 (带倒计时)
ja=表示される秒数 (カウントダウン付き)
@=FieldBossDirDelay
en=ms to wait after the map closes before showing it\n(raise it, e.g. 3000, if the Teleport loading covers it)
nap=ms 'e attesa doppo ca 'a mappa se chiure primma 'e 'a fa' vedé\n(aizalo, p'esempio 3000, si 'o caricamento d'o Teleport 'a copre)
bro=ms di attesa dopo che si chiude la mappa prima di farla vedere\n(alzalo, tipo 3000, se il caricamento del Teleport la copre)
es=ms de espera tras cerrarse el mapa antes de mostrarla\n(súbelo, p. ej. a 3000, si la carga del Teleport la tapa)
fr=ms d'attente après la fermeture de la carte avant de l'afficher\n(augmente-le, ex. 3000, si le chargement du Teleport la cache)
de=ms Wartezeit nach dem Schließen der Karte, bevor sie angezeigt wird\n(erhöhe sie, z. B. auf 3000, wenn der Teleport-Ladebildschirm sie verdeckt)
pt=ms de espera depois que o mapa fecha antes de mostrá-la\n(aumente, ex.: 3000, se o carregamento do Teleport a cobrir)
ru=ms ожидания после закрытия карты перед показом\n(увеличьте, напр. до 3000, если загрузка Teleport её перекрывает)
ko=지도가 닫힌 뒤 표시하기까지 기다리는 ms\n(Teleport 로딩 화면이 가리면 올리세요. 예: 3000)
zh=地图关闭后等待多少 ms 再显示\n(如果 Teleport 加载画面把它遮住了,请调大,例如 3000)
ja=マップが閉じてから表示するまでの待機 ms\n(Teleport のロード画面で隠れる場合は大きくしてください。例: 3000)
@=FieldBossDirTop
en=distance from the top edge of the screen (px at 1440p)
nap=distanza d'o bordo 'e coppa d'o schermo (px a 1440p)
bro=distanza dal bordo sopra dello schermo (px a 1440p)
es=distancia al borde superior de la pantalla (px a 1440p)
fr=distance par rapport au bord supérieur de l'écran (px en 1440p)
de=Abstand zum oberen Bildschirmrand (px bei 1440p)
pt=distância da borda de cima da tela (px em 1440p)
ru=расстояние от верхнего края экрана (px при 1440p)
ko=화면 위쪽 가장자리로부터의 거리 (1440p 기준 px)
zh=距屏幕顶边的距离 (1440p 下的 px)
ja=画面上端からの距離 (1440pでの px)
@=FieldBossDirScale
en=size (1.0 = normal)
nap=grandezza (1.0 = normale)
bro=size (1.0 = normale)
es=tamaño (1.0 = normal)
fr=taille (1.0 = normale)
de=Größe (1.0 = normal)
pt=tamanho (1.0 = normal)
ru=размер (1.0 = обычный)
ko=크기 (1.0 = 기본)
zh=大小 (1.0 = 正常)
ja=サイズ (1.0 = 標準)
@=FieldBossTravelWait
en=seconds it waits for you to press F after clicking the Teleport
nap=secondi ca aspetta ca tu premme F doppo 'o click 'ncopp'ô Teleport
bro=secondi che aspetta che premi F dopo il click sul Teleport
es=segundos que espera a que pulses F tras hacer clic en el Teleport
fr=secondes pendant lesquelles il attend que tu appuies sur F après avoir cliqué sur le Teleport
de=Sekunden, die es darauf wartet, dass du nach dem Klick auf den Teleport F drückst
pt=segundos que espera você pressionar F depois de clicar no Teleport
ru=секунд ожидания нажатия F после клика по Teleport
ko=Teleport를 클릭한 뒤 F를 누를 때까지 기다리는 시간(초)
zh=点击 Teleport 后等待你按 F 的秒数
ja=Teleport をクリックした後、F を押すのを待つ秒数
@=FieldBossTravelPresses
en=how many times F must be pressed to depart (2 = double press).\nOnce this number is reached the Teleport counts as done:\nclicks unlocked and direction shown.
nap=quante vote s'adda premmere F pe' partì (2 = doppia pressione).\nArrivato a stu nummero 'o Teleport se conta comme fatto:\nclick sbloccate e indicazione d'a direzione.
bro=quante botte di F servono per partire (2 = doppia).\nArrivato a quel numero il Teleport conta come fatto:\nclick sbloccati e freccia della direzione.
es=cuántas veces hay que pulsar F para partir (2 = doble pulsación).\nAl alcanzar este número el Teleport cuenta como hecho:\nclics desbloqueados y dirección mostrada.
fr=combien de fois il faut appuyer sur F pour partir (2 = double appui).\nUne fois ce nombre atteint, le Teleport est considéré comme fait :\nclics déverrouillés et direction affichée.
de=wie oft F zum Start gedrückt werden muss (2 = Doppeldruck).\nSobald diese Zahl erreicht ist, gilt der Teleport als erledigt:\nKlicks freigegeben und Richtung angezeigt.
pt=quantas vezes F deve ser pressionada para partir (2 = pressão dupla).\nAtingido esse número o Teleport conta como feito:\ncliques destravados e direção mostrada.
ru=сколько раз нужно нажать F для отправления (2 = двойное нажатие).\nКак только это число достигнуто, Teleport считается выполненным:\nклики разблокируются, показывается направление.
ko=출발하려면 F를 몇 번 눌러야 하는지 (2 = 두 번 누르기).\n이 횟수에 도달하면 Teleport가 완료된 것으로 간주해요:\n클릭 잠금이 풀리고 방향이 표시돼요.
zh=出发需要按 F 的次数 (2 = 双击)。\n达到该次数后,Teleport 即视为完成:\n点击解除锁定并显示方向。
ja=出発に必要な F の押下回数 (2 = ダブル押し)。\nこの回数に達すると Teleport 完了とみなされ、\nクリックのロックが解除され、方向が表示されます。
)" "`n"
        s .= "
(
@=FieldBossPanelScale
en=Panel\nsize: 1.0 small | 1.3 medium | 1.6 large
nap=Pannello\ngrandezza: 1.0 piccerillo | 1.3 miezo | 1.6 gruosso
bro=Pannello\nsize: 1.0 piccolo | 1.3 medio | 1.6 grande
es=Panel\ntamaño: 1.0 pequeño | 1.3 mediano | 1.6 grande
fr=Panneau\ntaille : 1.0 petit | 1.3 moyen | 1.6 grand
de=Panel\nGröße: 1.0 klein | 1.3 mittel | 1.6 groß
pt=Painel\ntamanho: 1.0 pequeno | 1.3 médio | 1.6 grande
ru=Панель\nразмер: 1.0 малый | 1.3 средний | 1.6 большой
ko=패널\n크기: 1.0 작게 | 1.3 보통 | 1.6 크게
zh=面板\n大小:1.0 小 | 1.3 中 | 1.6 大
ja=パネル\nサイズ: 1.0 小 | 1.3 中 | 1.6 大
@=FieldBossPanelMarginR
en=distance from the right edge (px at 1440p). The current value\nleaves the drop box the game opens on the right uncovered.
nap=distanza d'o bordo deritto (px a 1440p). 'O valore 'e mo\nlassa libero 'o riquadro d'e drop ca 'o juoco arape a deritta.
bro=distanza dal bordo destro (px a 1440p). Il valore di adesso\nlascia libero il pannello dei drop che il gioco apre a destra.
es=distancia al borde derecho (px a 1440p). El valor actual\ndeja libre el cuadro de drops que el juego abre a la derecha.
fr=distance par rapport au bord droit (px en 1440p). La valeur actuelle\nlaisse découverte la boîte de butin que le jeu ouvre à droite.
de=Abstand zum rechten Rand (px bei 1440p). Der aktuelle Wert\nlässt das Drop-Fenster, das das Spiel rechts öffnet, unverdeckt.
pt=distância da borda direita (px em 1440p). O valor atual\ndeixa descoberta a caixa de drops que o jogo abre à direita.
ru=расстояние от правого края (px при 1440p). Текущее значение\nне закрывает окно дропа, которое игра открывает справа.
ko=오른쪽 가장자리로부터의 거리 (1440p 기준 px). 현재 값은\n게임이 오른쪽에 여는 드롭 상자를 가리지 않아요.
zh=距右边缘的距离 (1440p 下的 px)。当前数值\n不会遮住游戏在右侧打开的掉落框。
ja=右端からの距離 (1440pでの px)。現在の値は\nゲームが右側に開くドロップ枠を覆わないようにしています。
@=FieldBossPanelOffsetY
en=offset from the vertical center (px at 1440p, + = lower)
nap=spustamento d'o miezo verticale (px a 1440p, + = cchiù abbascio)
bro=spostamento dal centro verticale (px a 1440p, + = più giù)
es=desplazamiento desde el centro vertical (px a 1440p, + = más abajo)
fr=décalage par rapport au centre vertical (px en 1440p, + = plus bas)
de=Versatz von der vertikalen Mitte (px bei 1440p, + = tiefer)
pt=deslocamento em relação ao centro vertical (px em 1440p, + = mais baixo)
ru=смещение от вертикального центра (px при 1440p, + = ниже)
ko=세로 중앙 기준 오프셋 (1440p 기준 px, + = 아래쪽)
zh=相对垂直中心的偏移 (1440p 下的 px,+ = 更低)
ja=垂直中央からのオフセット (1440pでの px、+ = 下)
@=FieldBossStartCollapsed
en=true = at startup the panel is collapsed to the title bar
nap=true = a ll'avvio 'o pannello è stretto â barra d'o titolo
bro=true = all'avvio il pannello è chiuso sulla barra del titolo
es=true = al arrancar el panel está contraído en la barra de título
fr=true = au démarrage, le panneau est réduit à la barre de titre
de=true = beim Start ist das Panel auf die Titelleiste eingeklappt
pt=true = na inicialização o painel fica recolhido na barra de título
ru=true = при запуске панель свёрнута до заголовка
ko=true = 시작할 때 패널이 제목 바로 접혀 있어요
zh=true = 启动时面板收起为标题栏
ja=true = 起動時にパネルをタイトルバーまで折りたたむ
@=FieldBossPickAction
en=What the panel does when you pick a boss:\n"fade"     = becomes almost transparent; turns opaque again when you hover it with the mouse\n"collapse" = collapses to the title bar (can be reopened with ▼)\n"none"     = stays as it is\nIn any case, closing and reopening the map brings the panel back open and opaque.\n(If instead you collapse it yourself with ▲, it stays collapsed until you reopen it.)
nap=Che fa 'o pannello quanno scigli nu boss:\n"fade"     = addeventa quase trasparente; torna opaco quanno ce passe 'ncoppa cu 'o mouse\n"collapse" = se stregne â barra d'o titolo (se riarape cu ▼)\n"none"     = resta comm'è\nA ogne modo, chiudenno e arapenno n'ata vota 'a mappa 'o pannello torna aperto e opaco.\n(Si invece 'o stringe tu cu ▲, resta stretto nfino a quanno nun 'o riarape.)
bro=Cosa fa il pannello quando scegli un boss:\n"fade"     = diventa quasi trasparente; torna pieno quando ci passi sopra col mouse\n"collapse" = si chiude sulla barra del titolo (lo riapri con ▼)\n"none"     = resta com'è\nComunque, chiudendo e riaprendo la mappa il pannello torna aperto e pieno.\n(Se invece lo chiudi tu con ▲, resta chiuso finché non lo riapri.)
es=Qué hace el panel cuando eliges un boss:\n"fade"     = queda casi transparente; vuelve a ser opaco cuando pasas el ratón por encima\n"collapse" = se contrae en la barra de título (se puede reabrir con ▼)\n"none"     = se queda como está\nEn cualquier caso, al cerrar y reabrir el mapa el panel vuelve abierto y opaco.\n(Si en cambio lo contraes tú con ▲, se queda contraído hasta que reabras el mapa.)
fr=Ce que fait le panneau quand tu choisis un boss :\n"fade"     = devient presque transparent ; redevient opaque quand tu le survoles avec la souris\n"collapse" = se réduit à la barre de titre (peut être rouvert avec ▼)\n"none"     = reste tel quel\nDans tous les cas, fermer et rouvrir la carte remet le panneau ouvert et opaque.\n(Si tu le réduis toi-même avec ▲, il reste réduit jusqu'à la réouverture.)
de=Was das Panel tut, wenn du einen Boss wählst:\n"fade"     = wird fast durchsichtig; wird wieder deckend, wenn du mit der Maus darüberfährst\n"collapse" = klappt auf die Titelleiste ein (mit ▼ wieder aufklappbar)\n"none"     = bleibt, wie es ist\nIn jedem Fall bringt Schließen und erneutes Öffnen der Karte das Panel wieder geöffnet und deckend zurück.\n(Klappst du es dagegen selbst mit ▲ ein, bleibt es eingeklappt, bis du die Karte wieder öffnest.)
pt=O que o painel faz quando você escolhe um boss:\n"fade"     = fica quase transparente; volta opaco quando você passa o mouse por cima\n"collapse" = recolhe na barra de título (pode ser reaberto com ▼)\n"none"     = fica como está\nDe qualquer forma, fechar e reabrir o mapa traz o painel de volta aberto e opaco.\n(Se em vez disso você o recolher com ▲, ele fica recolhido até você reabrir o mapa.)
ru=Что делает панель, когда вы выбираете босса:\n"fade"     = становится почти прозрачной; снова непрозрачная при наведении мыши\n"collapse" = сворачивается до заголовка (можно развернуть через ▼)\n"none"     = остаётся как есть\nВ любом случае, закрытие и повторное открытие карты возвращает панель развёрнутой и непрозрачной.\n(Если же вы сворачиваете её сами через ▲, она остаётся свёрнутой до повторного открытия.)
ko=보스를 고를 때 패널의 동작:\n"fade"     = 거의 투명해지고, 마우스를 올리면 다시 불투명해져요\n"collapse" = 제목 바로 접혀요 (▼로 다시 열 수 있어요)\n"none"     = 그대로 유지돼요\n어느 경우든 지도를 닫았다 다시 열면 패널이 열리고 불투명한 상태로 돌아와요.\n(▲로 직접 접었다면 지도를 다시 열 때까지 접힌 상태로 유지돼요.)
zh=选择首领时面板的行为:\n"fade"     = 变得几乎透明;鼠标悬停时恢复不透明\n"collapse" = 收起为标题栏 (可用 ▼ 重新展开)\n"none"     = 保持原样\n无论哪种,关闭再重新打开地图都会让面板恢复展开且不透明。\n(如果你自己用 ▲ 将其收起,则会一直保持收起,直到你重新打开地图。)
ja=ボス選択時のパネルの動作:\n"fade"     = ほぼ透明になる; マウスを重ねると再び不透明に\n"collapse" = タイトルバーに折りたたむ (▼ で再び開ける)\n"none"     = そのまま\nいずれの場合も、マップを閉じて開き直すとパネルは開いた不透明な状態に戻ります。\n(▲ で自分で折りたたんだ場合は、マップを開き直すまで折りたたまれたままです。)
@=FieldBossFadeAlpha
en=opacity in "fade" mode (0 invisible ... 255 opaque)
nap=opacità in modalità "fade" (0 nun se vede ... 255 opaco)
bro=opacità in modalità "fade" (0 invisibile ... 255 pieno)
es=opacidad en modo "fade" (0 invisible ... 255 opaco)
fr=opacité en mode "fade" (0 invisible ... 255 opaque)
de=Deckkraft im Modus "fade" (0 unsichtbar ... 255 deckend)
pt=opacidade no modo "fade" (0 invisível ... 255 opaco)
ru=непрозрачность в режиме "fade" (0 невидимая ... 255 непрозрачная)
ko="fade" 모드의 불투명도 (0 투명 ... 255 불투명)
zh="fade" 模式下的不透明度 (0 透明 ... 255 不透明)
ja="fade" モードでの不透明度 (0 透明 ... 255 不透明)
)" "`n"
        s .= "
(
@=FieldBossShowLegend
en=Key legend: bar at the top of the screen with HUD, Hidden Cube and Field Boss ON/OFF,\nSettings key and Esc. It appears with the map open even if the Field Boss tool is off (OFF).\nfalse = legend hidden
nap=Leggenda d'e taste: barra 'ncoppa 'o schermo cu HUD, Hidden Cube e Field Boss ON/OFF,\ntasto d'e Mpustaziune ed Esc. Compare cu 'a mappa aperta pure si 'o tool Field Boss è stutato (OFF).\nfalse = leggenda annascosta
bro=Leggenda dei tasti: barra in cima allo schermo con HUD, Hidden Cube e Field Boss ON/OFF,\ntasto dei Settaggi ed Esc. Spunta con la mappa aperta anche se il tool Field Boss è spento (OFF).\nfalse = leggenda nascosta
es=Leyenda de teclas: barra en la parte superior de la pantalla con HUD, Hidden Cube y Field Boss ON/OFF,\ntecla de Ajustes y Esc. Aparece con el mapa abierto aunque la herramienta Field Boss esté apagada (OFF).\nfalse = leyenda oculta
fr=Légende des touches : barre en haut de l'écran avec HUD, Hidden Cube et Field Boss ON/OFF,\ntouche des paramètres et Esc. Elle apparaît avec la carte ouverte même si l'outil Field Boss est désactivé (OFF).\nfalse = légende masquée
de=Tastenlegende: Leiste oben am Bildschirm mit HUD, Hidden Cube und Field Boss ON/OFF,\nEinstellungs-Taste und Esc. Sie erscheint bei geöffneter Karte auch dann, wenn das Field Boss Tool aus ist (OFF).\nfalse = Legende ausgeblendet
pt=Legenda de teclas: barra no topo da tela com HUD, Hidden Cube e Field Boss ON/OFF,\ntecla das Configurações e Esc. Aparece com o mapa aberto mesmo que a ferramenta Field Boss esteja desligada (OFF).\nfalse = legenda escondida
ru=Легенда клавиш: полоса вверху экрана с ON/OFF для HUD, Hidden Cube и Field Boss,\nклавишей настроек и Esc. Появляется при открытой карте, даже если инструмент Field Boss выключен (OFF).\nfalse = легенда скрыта
ko=키 범례: 화면 위쪽의 바로, HUD, Hidden Cube, Field Boss의 ON/OFF,\n설정 키, Esc가 표시돼요. Field Boss 도구가 꺼져 있어도(OFF) 지도를 열면 나타나요.\nfalse = 범례 숨김
zh=按键图例:屏幕顶部的条,显示 HUD、Hidden Cube 和 Field Boss 的 ON/OFF,\n设置键和 Esc。即使 Field Boss 工具关闭 (OFF),地图打开时也会显示。\nfalse = 隐藏图例
ja=キー凡例: 画面上部のバーに HUD、Hidden Cube、Field Boss の ON/OFF、\n設定キーと Esc を表示。Field Boss ツールがオフでもマップを開くと表示されます (OFF)。\nfalse = 凡例を非表示
@=FieldBossLegendScale
en=size (1.0 = normal)
nap=grandezza (1.0 = normale)
bro=size (1.0 = normale)
es=tamaño (1.0 = normal)
fr=taille (1.0 = normale)
de=Größe (1.0 = normal)
pt=tamanho (1.0 = normal)
ru=размер (1.0 = обычный)
ko=크기 (1.0 = 기본)
zh=大小 (1.0 = 正常)
ja=サイズ (1.0 = 標準)
@=FieldBossLegendY
en=distance from the top edge (px at 1440p).\nDon't go above ~25: below it are the tabs the script reads.
nap=distanza d'o bordo 'e coppa (px a 1440p).\nNun passà ~25: sotto ce stanno 'e tab ca 'o script legge.
bro=distanza dal bordo sopra (px a 1440p).\nNon andare oltre ~25: sotto ci sono i tab che lo script legge.
es=distancia al borde superior (px a 1440p).\nNo subas más de ~25: por debajo están las pestañas que lee el script.
fr=distance par rapport au bord supérieur (px en 1440p).\nNe monte pas au-dessus de ~25 : en dessous se trouvent les onglets que le script lit.
de=Abstand zum oberen Rand (px bei 1440p).\nGeh nicht über ~25: darunter liegen die Tabs, die das Skript liest.
pt=distância da borda de cima (px em 1440p).\nNão suba acima de ~25: abaixo dela ficam as abas que o script lê.
ru=расстояние от верхнего края (px при 1440p).\nНе поднимайте выше ~25: под ним вкладки, которые читает скрипт.
ko=위쪽 가장자리로부터의 거리 (1440p 기준 px).\n약 25보다 위로 올리지 마세요. 그 아래에 스크립트가 읽는 탭이 있어요.
zh=距顶边的距离 (1440p 下的 px)。\n不要小于约 25:下方是脚本要读取的标签页。
ja=上端からの距離 (1440pでの px)。\n約25より上には置かないでください: その下にスクリプトが読むタブがあります。
@=FieldBossLegendAlpha
en=opacity (0 invisible ... 255 opaque)
nap=opacità (0 nun se vede ... 255 opaca)
bro=opacità (0 invisibile ... 255 piena)
es=opacidad (0 invisible ... 255 opaca)
fr=opacité (0 invisible ... 255 opaque)
de=Deckkraft (0 unsichtbar ... 255 deckend)
pt=opacidade (0 invisível ... 255 opaco)
ru=непрозрачность (0 невидимая ... 255 непрозрачная)
ko=불투명도 (0 투명 ... 255 불투명)
zh=不透明度 (0 透明 ... 255 不透明)
ja=不透明度 (0 透明 ... 255 不透明)
@=FieldBossListScroll
en=Boss and Teleport search\nscrolls needed to go from one end to the other of the\ngame's boss list. Too many = the game "beeps" at the end of\nthe list; too few = bosses at the bottom are not found.
nap=Ricerca d'o boss e d'o Teleport\nscrollate ca servono pe' jì 'a nu capo a ll'ato d'a\nlista boss d'o juoco. Troppe = 'o juoco fa nu "beep" â fine\nd'a lista; troppo poche = 'e boss abbascio nun se trovano.
bro=Ricerca del boss e del Teleport\nscrollate che servono per andare da una punta all'altra della\nlista boss del gioco. Troppe = il gioco fa "beep" a fine\nlista; troppo poche = i boss in fondo non vengono sgamati.
es=Búsqueda de boss y Teleport\ndesplazamientos necesarios para ir de un extremo al otro de la\nlista de bosses del juego. Demasiados = el juego hace "bip" al final de\nla lista; muy pocos = no se encuentran los bosses de abajo.
fr=Recherche du boss et du Teleport\ndéfilements nécessaires pour aller d'un bout à l'autre de la\nliste des boss du jeu. Trop = le jeu "bipe" en fin de\nliste ; trop peu = les boss du bas ne sont pas trouvés.
de=Boss- und Teleport-Suche\nScrolls, die nötig sind, um von einem Ende der Boss-Liste des Spiels\nzum anderen zu kommen. Zu viele = das Spiel "piept" am Ende der\nListe; zu wenige = Bosse am unteren Ende werden nicht gefunden.
pt=Busca do boss e do Teleport\nrolagens necessárias para ir de uma ponta à outra da\nlista de bosses do jogo. Demais = o jogo dá "bipe" no fim da\nlista; de menos = bosses no fim não são encontrados.
ru=Поиск босса и Teleport\nпрокруток, нужных чтобы пройти от одного конца до другого\nсписка боссов игры. Слишком много = игра "пищит" в конце\nсписка; слишком мало = боссы внизу не находятся.
ko=보스 및 Teleport 검색\n게임의 보스 목록 한쪽 끝에서 다른 쪽 끝까지 가는 데\n필요한 스크롤 횟수예요. 너무 많으면 목록 끝에서 게임이 "삑" 소리를 내고,\n너무 적으면 아래쪽 보스를 찾지 못해요.
zh=首领和 Teleport 搜索\n从游戏首领列表的一端滚到另一端\n所需的滚动次数。太多 = 到列表末尾时游戏会 "嘟" 一声;\n太少 = 找不到列表底部的首领。
ja=ボスと Teleport の検索\nゲームのボスリストの端から端まで移動するのに必要なスクロール数。\n多すぎるとリスト末尾でゲームが "ビープ音" を鳴らし、\n少なすぎると下の方のボスが見つかりません。
@=FieldBossFindTeleport
en=true = after clicking the boss it looks for the nearest Teleport
nap=true = doppo 'o click 'ncopp'ô boss cerca 'o Teleport cchiù vicino
bro=true = dopo il click sul boss sgama il Teleport più vicino
es=true = tras hacer clic en el boss busca el Teleport más cercano
fr=true = après le clic sur le boss, il cherche le Teleport le plus proche
de=true = nach dem Klick auf den Boss sucht es den nächsten Teleport
pt=true = depois de clicar no boss procura o Teleport mais próximo
ru=true = после клика по боссу ищет ближайший Teleport
ko=true = 보스를 클릭한 뒤 가장 가까운 Teleport를 찾아요
zh=true = 点击首领后查找最近的 Teleport
ja=true = ボスをクリック後、最寄りの Teleport を検索する
@=FieldBossAutoZoomOut
en=true = if there is no Teleport on the map, it zooms out\ncentered on the boss (and collapses the panel so it does not cover the map)
nap=true = si 'ncopp'â mappa nun ce sta nisciuno Teleport, fa zoom arreto\ncentrato 'ncopp'ô boss (e stregne 'o pannello pe' nun cummiglià 'a mappa)
bro=true = se sulla mappa non c'è nessun Teleport fa zoom out\ncentrato sul boss (e chiude il pannello per non coprire la mappa)
es=true = si no hay ningún Teleport en el mapa, aleja el zoom\ncentrado en el boss (y contrae el panel para que no tape el mapa)
fr=true = s'il n'y a pas de Teleport sur la carte, il dézoome\ncentré sur le boss (et réduit le panneau pour qu'il ne cache pas la carte)
de=true = gibt es keinen Teleport auf der Karte, zoomt es heraus,\nzentriert auf den Boss (und klappt das Panel ein, damit es die Karte nicht verdeckt)
pt=true = se não houver Teleport no mapa, dá zoom out\ncentrado no boss (e recolhe o painel para não cobrir o mapa)
ru=true = если на карте нет Teleport, отдаляет масштаб\nс центром на боссе (и сворачивает панель, чтобы она не закрывала карту)
ko=true = 지도에 Teleport가 없으면 보스를 중심으로\n축소해요 (지도를 가리지 않도록 패널도 접어요)
zh=true = 如果地图上没有 Teleport,就以首领为中心\n缩小地图 (并收起面板,以免遮住地图)
ja=true = マップ上に Teleport がない場合、ボスを中心にズームアウトする\n(マップを覆わないようパネルも折りたたむ)
@=FieldBossZoomOut
en=zoom-out scrolls...
nap=scrollate 'e zoom arreto...
bro=scrollate di zoom out...
es=desplazamientos para alejar el zoom...
fr=défilements de dézoom...
de=Scrolls zum Herauszoomen...
pt=rolagens de zoom out...
ru=прокруток для отдаления...
ko=축소 스크롤...
zh=缩小滚动次数...
ja=ズームアウトのスクロール数...
@=FieldBossZoomBack
en=...and then forward: at minimum zoom the Teleports disappear
nap=...e po' annanze: a ll'ultimo zoom 'e Teleport scompareno
bro=...e poi avanti: allo zoom minimo i Teleport spariscono
es=...y luego hacia delante: con el zoom mínimo los Teleports desaparecen
fr=...puis en avant : au zoom minimum les Teleport disparaissent
de=...und dann vorwärts: Beim minimalen Zoom verschwinden die Teleports
pt=...e depois para frente: no zoom mínimo os Teleports desaparecem
ru=...и затем обратно: при минимальном масштабе Teleport пропадают
ko=...그다음 되돌리는 스크롤: 최소 줌에서는 Teleport가 사라져요
zh=...然后再向前滚动:缩到最小时 Teleport 会消失
ja=...その後戻す: 最小ズームでは Teleport が消えます
)" "`n"
        s .= "
(
@=FieldBossZoomOutWheel
en=direction of the wheel that zooms OUT on the map\n("WheelDown" or "WheelUp")
nap=direzione d'a rutella ca fa zoom ARRETO 'ncopp'â mappa\n("WheelDown" o "WheelUp")
bro=verso della rotella che fa zoom OUT sulla mappa\n("WheelDown" o "WheelUp")
es=sentido de la rueda que aleja el zoom en el mapa\n("WheelDown" o "WheelUp")
fr=sens de la molette qui DÉZOOME sur la carte\n("WheelDown" ou "WheelUp")
de=Richtung des Mausrads, das auf der Karte HERAUSzoomt\n("WheelDown" oder "WheelUp")
pt=direção da roda que dá zoom OUT no mapa\n("WheelDown" ou "WheelUp")
ru=направление колеса, которое ОТДАЛЯЕТ карту\n("WheelDown" или "WheelUp")
ko=지도를 축소하는 휠 방향\n("WheelDown" 또는 "WheelUp")
zh=在地图上缩小的滚轮方向\n("WheelDown" 或 "WheelUp")
ja=マップをズームアウトするホイールの方向\n("WheelDown" または "WheelUp")
@=FieldBossCloseLoot
en=Game loot panel: when you select a boss the game opens on the right the box\nwith the drops, which can cover the nearest Teleport. To close it a click on an\nempty spot of the map is enough (a simple click does not move the map).\nThe script brings the cursor to an empty spot next to the boss icon (grey or red),\nwaits for YOUR click (the game blocks simulated clicks) and ONLY THEN looks for the Teleport.\n"zoom"   = only when it had to zoom out (cases like Vishwada, Lagta)\n"always" = every time, before looking for the Teleport\n"never"  = never
nap=Pannello d'e loot d'o juoco: quanno scigli nu boss 'o juoco arape a deritta 'o riquadro\ncu 'e drop, ca pò cummiglià 'o Teleport cchiù vicino. Pe' 'o chiudere abbasta nu click 'ncopp'a nu\npunto vacante d'a mappa (nu click semplice nun move 'a mappa).\n'O script porta 'o cursore 'ncopp'a nu punto vacante vicino a ll'icona d'o boss (grigia o rossa),\naspetta 'o click TUOIO ('o juoco blocca 'e click finte) e SULO DOPPO cerca 'o Teleport.\n"zoom"   = sulo quanno ha avuto 'a fa' 'o zoom arreto (casi comme Vishwada, Lagta)\n"always" = ogne vota, primma 'e cercà 'o Teleport\n"never"  = maje
bro=Pannello loot del gioco: quando scegli un boss il gioco apre a destra il box\ncoi drop, che può coprire il Teleport più vicino. Per chiuderlo basta un click su un\npunto vuoto della mappa (un click semplice non sposta la mappa).\nLo script porta il cursore su un punto vuoto vicino all'icona del boss (grigia o rossa),\naspetta il TUO click (il gioco blocca i click finti) e SOLO DOPO cerca il Teleport.\n"zoom"   = solo quando ha dovuto fare zoom out (casi tipo Vishwada, Lagta)\n"always" = ogni volta, prima di cercare il Teleport\n"never"  = mai
es=Panel de botín del juego: cuando seleccionas un boss el juego abre a la derecha el cuadro\ncon los drops, que puede tapar el Teleport más cercano. Para cerrarlo basta un clic en un\npunto vacío del mapa (un simple clic no mueve el mapa).\nEl script lleva el cursor a un punto vacío junto al icono del boss (gris o rojo),\nespera TU clic (el juego bloquea los clics simulados) y SOLO ENTONCES busca el Teleport.\n"zoom"   = solo cuando tuvo que alejar el zoom (casos como Vishwada, Lagta)\n"always" = siempre, antes de buscar el Teleport\n"never"  = nunca
fr=Panneau de butin du jeu : quand tu sélectionnes un boss, le jeu ouvre à droite la boîte\navec les drops, qui peut cacher le Teleport le plus proche. Pour la fermer, un clic sur un\npoint vide de la carte suffit (un simple clic ne déplace pas la carte).\nLe script amène le curseur sur un point vide à côté de l'icône du boss (grise ou rouge),\nattend TON clic (le jeu bloque les clics simulés) et SEULEMENT ENSUITE cherche le Teleport.\n"zoom"   = seulement quand il a dû dézoomer (cas comme Vishwada, Lagta)\n"always" = à chaque fois, avant de chercher le Teleport\n"never"  = jamais
de=Loot-Fenster des Spiels: Wenn du einen Boss auswählst, öffnet das Spiel rechts das Fenster\nmit den Drops, das den nächsten Teleport verdecken kann. Zum Schließen genügt ein Klick auf eine\nleere Stelle der Karte (ein einfacher Klick bewegt die Karte nicht).\nDas Skript führt den Cursor zu einer leeren Stelle neben dem Boss-Symbol (grau oder rot),\nwartet auf DEINEN Klick (das Spiel blockiert simulierte Klicks) und sucht ERST DANN den Teleport.\n"zoom"   = nur wenn es herauszoomen musste (Fälle wie Vishwada, Lagta)\n"always" = jedes Mal, vor der Suche nach dem Teleport\n"never"  = nie
pt=Painel de loot do jogo: quando você seleciona um boss o jogo abre à direita a caixa\ncom os drops, que pode cobrir o Teleport mais próximo. Para fechá-la basta um clique em um\nponto vazio do mapa (um clique simples não move o mapa).\nO script leva o cursor a um ponto vazio ao lado do ícone do boss (cinza ou vermelho),\nespera o SEU clique (o jogo bloqueia cliques simulados) e SÓ ENTÃO procura o Teleport.\n"zoom"   = só quando precisou dar zoom out (casos como Vishwada, Lagta)\n"always" = toda vez, antes de procurar o Teleport\n"never"  = nunca
ru=Панель добычи игры: когда вы выбираете босса, игра открывает справа окно\nс дропом, которое может закрыть ближайший Teleport. Чтобы закрыть его, достаточно клика по\nпустому месту карты (простой клик карту не двигает).\nСкрипт подводит курсор к пустому месту рядом с иконкой босса (серой или красной),\nждёт ВАШЕГО клика (игра блокирует имитацию кликов) и ТОЛЬКО ПОТОМ ищет Teleport.\n"zoom"   = только если пришлось отдалять (случаи вроде Vishwada, Lagta)\n"always" = каждый раз, перед поиском Teleport\n"never"  = никогда
ko=게임 전리품 패널: 보스를 선택하면 게임이 오른쪽에\n드롭 상자를 여는데, 가장 가까운 Teleport를 가릴 수 있어요. 닫으려면 지도의\n빈 곳을 한 번 클릭하면 돼요 (단순 클릭으로는 지도가 움직이지 않아요).\n스크립트가 보스 아이콘 옆의 빈 곳(회색 또는 빨강)으로 커서를 옮기고,\n직접 하는 클릭을 기다린 뒤(게임이 가상 클릭을 막아요) 그 다음에야 Teleport를 찾아요.\n"zoom"   = 축소해야 했을 때만 (Vishwada, Lagta 같은 경우)\n"always" = Teleport를 찾기 전에 매번\n"never"  = 하지 않음
zh=游戏战利品面板:选中首领时,游戏会在右侧打开带有\n掉落物的框,它可能遮住最近的 Teleport。要关闭它,\n在地图的空白处点一下即可 (单击不会移动地图)。\n脚本会把光标带到首领图标旁边的空白处 (灰色或红色),\n等待你自己点击 (游戏会屏蔽模拟点击),然后才去查找 Teleport。\n"zoom"   = 仅在需要缩小地图时 (如 Vishwada、Lagta 的情况)\n"always" = 每次,在查找 Teleport 之前\n"never"  = 从不
ja=ゲームのドロップパネル: ボスを選択すると、ゲームは右側にドロップ枠を開き、\n最寄りの Teleport を覆うことがあります。閉じるにはマップの\n空きスペースを1回クリックするだけです (単なるクリックではマップは動きません)。\nスクリプトはカーソルをボスアイコンの隣の空きスペース (灰色または赤) に移動し、\nあなたのクリックを待ち (ゲームはシミュレートされたクリックをブロックします)、その後にのみ Teleport を探します。\n"zoom"   = ズームアウトが必要だった場合のみ (Vishwada、Lagta のようなケース)\n"always" = 毎回、Teleport を探す前に\n"never"  = 行わない
@=FieldBossLootClickDist
en=distance of the empty spot from the boss icon (px at 1440p).\nThe script picks by itself the direction free of other icons\n(left first, then down, etc.).
nap=distanza d'o punto vacante 'a ll'icona d'o boss (px a 1440p).\n'O script sceglie isso 'a direzione libera 'a ati icone\n(primma a mancina, po' abbascio, e accussì).
bro=distanza del punto vuoto dall'icona del boss (px a 1440p).\nLo script sceglie da solo la direzione libera da altre icone\n(prima a sinistra, poi sotto, ecc.).
es=distancia del punto vacío al icono del boss (px a 1440p).\nEl script elige solo la dirección libre de otros iconos\n(primero izquierda, luego abajo, etc.).
fr=distance du point vide par rapport à l'icône du boss (px en 1440p).\nLe script choisit tout seul la direction libre d'autres icônes\n(d'abord à gauche, puis en bas, etc.).
de=Abstand der leeren Stelle vom Boss-Symbol (px bei 1440p).\nDas Skript wählt selbst die Richtung ohne andere Symbole\n(zuerst links, dann unten usw.).
pt=distância do ponto vazio ao ícone do boss (px em 1440p).\nO script escolhe sozinho a direção livre de outros ícones\n(esquerda primeiro, depois para baixo, etc.).
ru=расстояние от пустого места до иконки босса (px при 1440p).\nСкрипт сам выбирает направление, свободное от других иконок\n(сначала слева, потом вниз и т. д.).
ko=보스 아이콘에서 빈 곳까지의 거리 (1440p 기준 px).\n스크립트가 다른 아이콘이 없는 방향을 알아서 골라요\n(왼쪽 먼저, 그다음 아래쪽 등).
zh=空白点与首领图标的距离 (1440p 下的 px)。\n脚本会自动选择没有其他图标的方向\n(先左,再下,依此类推)。
ja=ボスアイコンから空きスペースまでの距離 (1440pでの px)。\nスクリプトは他のアイコンのない方向を自動で選びます\n(まず左、次に下、など)。
)" "`n"
        s .= "
(
@=FieldBossCheckEvery
en=ms between one "map open?" check and the next.\nLower = more responsive panel and legend (a bit more CPU).\n(used only with PerfProfile "manuale", see [PRESTAZIONI])
nap=ms tra nu cuntrollo "mappa aperta?" e n'ato.\nCchiù basso = pannello e leggenda cchiù pronte (nu poco cchiù CPU).\n(serve sulo cu PerfProfile "manuale", vide [PRESTAZIONI])
bro=ms tra un check "mappa aperta?" e l'altro.\nPiù basso = pannello e leggenda più reattivi (un po' più CPU).\n(solo col PerfProfile "manuale", guarda [PRESTAZIONI])
es=ms entre una comprobación de "¿mapa abierto?" y la siguiente.\nMenos = panel y leyenda más reactivos (algo más de CPU).\n(usado solo con PerfProfile "manuale", ver [PRESTAZIONI])
fr=ms entre une vérification "carte ouverte ?" et la suivante.\nPlus bas = panneau et légende plus réactifs (un peu plus de CPU).\n(utilisé uniquement avec PerfProfile "manuale", voir [PRESTAZIONI])
de=ms zwischen einer "Karte offen?"-Prüfung und der nächsten.\nNiedriger = reaktionsschnelleres Panel und Legende (etwas mehr CPU).\n(nur mit PerfProfile "manuale" verwendet, siehe [PRESTAZIONI])
pt=ms entre uma verificação de "mapa aberto?" e a seguinte.\nMenor = painel e legenda mais reativos (um pouco mais de CPU).\n(usado só com PerfProfile "manuale", veja [PRESTAZIONI])
ru=ms между одной проверкой "карта открыта?" и следующей.\nМеньше = отзывчивее панель и легенда (чуть больше нагрузка на CPU).\n(используется только с PerfProfile "manuale", см. [PRESTAZIONI])
ko="지도가 열려 있나?" 확인 사이의 ms.\n낮을수록 패널과 범례가 더 빨리 반응해요 (CPU를 조금 더 써요).\n(PerfProfile "manuale"에서만 사용, [PRESTAZIONI] 참고)
zh=两次 "地图是否打开?" 检查之间的 ms 数。\n越小 = 面板和图例响应越快 (CPU 占用稍高)。\n(仅在 PerfProfile 为 "manuale" 时使用,见 [PRESTAZIONI])
ja="マップは開いている?" チェックの間隔 ms。\n小さいほどパネルと凡例の反応が良くなります (CPU使用量は少し増加)。\n(PerfProfile "manuale" のときのみ使用、[PRESTAZIONI] を参照)
it=Tema
en=Theme
nap=Tema
bro=Vibe
es=Tema
fr=Thème
de=Design
pt=Tema
ru=Тема
ko=테마
zh=主题
ja=テーマ
it=Colori di tutta la suite. I temi pronti cambiano anche i colori dell'HUD; con "custom" scegli tu ogni colore (quelli dell'HUD sono in HUD overlay > Colori).
en=Colors of the whole suite. Ready-made themes also change the HUD colors; with "custom" you pick every color (the HUD ones are in HUD overlay > Colors).
nap=Culure 'e tutta 'a suite. 'E temi pronte cagnano pure 'e culure 'e ll'HUD; cu "custom" scigli tu ogne culore (chille 'e ll'HUD stanno in HUD overlay > Culure).
bro=I colori di tutta la suite. I temi pronti cambiano anche l'HUD; con "custom" scegli tu ogni colore (quelli dell'HUD stanno in HUD overlay > Colori).
es=Colores de toda la suite. Los temas listos también cambian los colores del HUD; con "custom" eliges cada color (los del HUD están en HUD overlay > Colores).
fr=Couleurs de toute la suite. Les thèmes prêts changent aussi les couleurs du HUD ; avec "custom" tu choisis chaque couleur (celles du HUD sont dans HUD overlay > Couleurs).
de=Farben der ganzen Suite. Fertige Designs ändern auch die HUD-Farben; mit "custom" wählst du jede Farbe selbst (die HUD-Farben stehen unter HUD overlay > Farben).
pt=Cores de toda a suite. Os temas prontos também mudam as cores do HUD; com "custom" você escolhe cada cor (as do HUD ficam em HUD overlay > Cores).
ru=Цвета всего пакета. Готовые темы меняют и цвета HUD; с "custom" вы выбираете каждый цвет сами (цвета HUD — в HUD overlay > Цвета).
ko=스위트 전체의 색상입니다. 기본 테마는 HUD 색상도 바꿉니다. "custom"을 고르면 모든 색을 직접 정합니다 (HUD 색은 HUD overlay > 색상).
zh=整个套件的颜色。预设主题也会改变 HUD 颜色；选择 "custom" 可自定义每种颜色（HUD 的颜色在 HUD overlay > 颜色）。
ja=スイート全体の色です。用意されたテーマは HUD の色も変えます。"custom" ではすべての色を自分で選べます（HUD の色は HUD overlay > 色）。
it=Tema dei colori
en=Color theme
nap=Tema d'e culure
bro=Vibe dei colori
es=Tema de colores
fr=Thème de couleurs
de=Farbdesign
pt=Tema de cores
ru=Цветовая тема
ko=색상 테마
zh=配色主题
ja=カラーテーマ
it=Sfondo pannelli
en=Panel background
nap=Sfunno d'e pannelle
bro=Sfondo pannelli
es=Fondo de paneles
fr=Fond des panneaux
de=Panel-Hintergrund
pt=Fundo dos painéis
ru=Фон панелей
ko=패널 배경
zh=面板背景
ja=パネル背景
it=Sfondo righe e pulsanti
en=Rows and buttons background
nap=Sfunno 'e righe e pulsante
bro=Sfondo righe e bottoni
es=Fondo de filas y botones
fr=Fond des lignes et boutons
de=Zeilen- und Tastenhintergrund
pt=Fundo de linhas e botões
ru=Фон строк и кнопок
ko=행과 버튼 배경
zh=行和按钮背景
ja=行とボタンの背景
it=Riga sotto il mouse
en=Row under the mouse
nap=Riga sotto 'o mouse
bro=Riga sotto il mouse
es=Fila bajo el ratón
fr=Ligne sous la souris
de=Zeile unter der Maus
pt=Linha sob o mouse
ru=Строка под курсором
ko=마우스 아래 행
zh=鼠标所在行
ja=マウス下の行
it=Linee di separazione
en=Separator lines
nap=Linee 'e spartimento
bro=Linee divisorie
es=Líneas separadoras
fr=Lignes de séparation
de=Trennlinien
pt=Linhas separadoras
ru=Разделители
ko=구분선
zh=分隔线
ja=区切り線
it=Titoli (accento)
en=Titles (accent)
nap=Tituli (accento)
bro=Titoli (accento)
es=Títulos (acento)
fr=Titres (accent)
de=Titel (Akzent)
pt=Títulos (destaque)
ru=Заголовки (акцент)
ko=제목 (강조)
zh=标题（强调色）
ja=タイトル（アクセント）
it=Testo principale
en=Main text
nap=Testo principale
bro=Testo principale
es=Texto principal
fr=Texte principal
de=Haupttext
pt=Texto principal
ru=Основной текст
ko=기본 텍스트
zh=主要文字
ja=メインテキスト
it=Testo secondario
en=Secondary text
nap=Testo secondario
bro=Testo secondario
es=Texto secundario
fr=Texte secondaire
de=Nebentext
pt=Texto secundário
ru=Вторичный текст
ko=보조 텍스트
zh=次要文字
ja=サブテキスト
it=Testo spento
en=Dimmed text
nap=Testo stutato
bro=Testo spento
es=Texto atenuado
fr=Texte atténué
de=Gedimmter Text
pt=Texto apagado
ru=Приглушённый текст
ko=흐린 텍스트
zh=暗淡文字
ja=淡いテキスト
it=Sfondo istruzioni e freccia
en=Instructions and arrow background
nap=Sfunno d'e struzziune e d'a freccia
bro=Sfondo dritte e freccia
es=Fondo de instrucciones y flecha
fr=Fond des consignes et de la flèche
de=Hintergrund Anweisungen und Pfeil
pt=Fundo das instruções e da seta
ru=Фон подсказок и стрелки
ko=안내와 화살표 배경
zh=提示和箭头背景
ja=案内と矢印の背景
it=Istruzione da fare e anello
en=To-do instruction and ring
nap=Struzzione 'a fa' e anello
bro=Dritta da fare e anello
es=Instrucción pendiente y anillo
fr=Consigne à faire et anneau
de=Anweisung „tun“ und Ring
pt=Instrução a fazer e anel
ru=Подсказка «сделать» и кольцо
ko=할 일 안내와 링
zh=待办提示和光环
ja=実行する案内とリング
it=Istruzione attendi
en=Wait instruction
nap=Struzzione aspetta
bro=Dritta aspetta
es=Instrucción espera
fr=Consigne attendre
de=Anweisung „warten“
pt=Instrução aguarde
ru=Подсказка «ждите»
ko=대기 안내
zh=等待提示
ja=待機の案内
it=Fatto / ON
en=Done / ON
nap=Fatto / ON
bro=Fatto / ON
es=Hecho / ON
fr=Fait / ON
de=Erledigt / ON
pt=Feito / ON
ru=Готово / ON
ko=완료 / ON
zh=完成 / ON
ja=完了 / ON
it=Errore / OFF
en=Error / OFF
nap=Sbaglio / OFF
bro=Errore / OFF
es=Error / OFF
fr=Erreur / OFF
de=Fehler / OFF
pt=Erro / OFF
ru=Ошибка / OFF
ko=오류 / OFF
zh=错误 / OFF
ja=エラー / OFF
it=Freccia di direzione
en=Direction arrow
nap=Freccia d'a direzione
bro=Freccia direzione
es=Flecha de dirección
fr=Flèche de direction
de=Richtungspfeil
pt=Seta de direção
ru=Стрелка направления
ko=방향 화살표
zh=方向箭头
ja=方向矢印
it=Finestra: sfondo
en=Window: background
nap=Fenesta: sfunno
bro=Finestra: sfondo
es=Ventana: fondo
fr=Fenêtre : fond
de=Fenster: Hintergrund
pt=Janela: fundo
ru=Окно: фон
ko=창: 배경
zh=窗口：背景
ja=ウィンドウ：背景
it=Finestra: testo
en=Window: text
nap=Fenesta: testo
bro=Finestra: testo
es=Ventana: texto
fr=Fenêtre : texte
de=Fenster: Text
pt=Janela: texto
ru=Окно: текст
ko=창: 텍스트
zh=窗口：文字
ja=ウィンドウ：テキスト
it=Finestra: testo secondario
en=Window: secondary text
nap=Fenesta: testo secondario
bro=Finestra: testo secondario
es=Ventana: texto secundario
fr=Fenêtre : texte secondaire
de=Fenster: Nebentext
pt=Janela: texto secundário
ru=Окно: вторичный текст
ko=창: 보조 텍스트
zh=窗口：次要文字
ja=ウィンドウ：サブテキスト
it=Finestra: elenchi e caselle
en=Window: lists and fields
nap=Fenesta: liste e caselle
bro=Finestra: liste e caselle
es=Ventana: listas y campos
fr=Fenêtre : listes et champs
de=Fenster: Listen und Felder
pt=Janela: listas e campos
ru=Окно: списки и поля
ko=창: 목록과 입력란
zh=窗口：列表和输入框
ja=ウィンドウ：リストと入力欄
)" "`n"
        s .= "
(
@=Theme
en=Color theme:\n"principale" = the classic theme (dark and gold); the HUD uses the colors of [HUD] Colors\n"dark"       = graphite black and ice blue, high contrast\n"bright"     = light: white panels and dark text, yellow HUD\n"cuddle"     = cuddly colors: peach, cream and soft pastels\n"pinkhaze"   = pink and purple haze on a dark background\n"egirl"      = hot pink and black, neon\n"vi"         = Vice City: pink/orange sunset, purple and teal (GTA VI style)\nClass themes (AION 2): "gladiator" | "templar" | "assassin" | "ranger" | "sorcerer" | "spiritmaster" | "cleric" | "chanter" = colors plus their own crosshair and icon shapes, animation, effects and emoji (they replace the [HUD] values)\n"halloween"    = (event) pumpkin orange and night purple, pumpkin and little ghost\n"natale"       = (event) red, fir green and gold, gift and tree\n"capodanno"    = (event) black, gold and silver, toast and fireworks\n"sanvalentino" = (event) pink and wine red, beating hearts\n"carnevale"    = (event) purple, yellow and green, mask and confetti\n"pasqua"       = (event) light spring pastels, egg and chick\n"sanpatrizio"  = (event) clover green and gold, four-leaf clover and mug\n"custom"     = every ThemeColor... below + the HUD colors of [HUD] Colors\nReady-made themes never change. Your themes, created with "Theme editor" in the Settings, are called "user:Name".
nap=Tema d'e culure:\n"principale" = 'o tema classico (scuro e oro); ll'HUD piglia 'e culure 'e [HUD] Culure\n"dark"       = niro grafite e celeste ghiaccio, cuntrasto forte\n"bright"     = chiaro: pannelle janche e testi scure, HUD giallo\n"cuddle"     = culure coccolose: pesca, crema e pastelle muscie\n"pinkhaze"   = neglia rosa e viola 'ncopp'a nu sfunno scuro\n"egirl"      = rosa shocking e niro, neon\n"vi"         = Vice City: tramonto rosa/arancio, viola e turchese (stile GTA VI)\nTemi d'e classe (AION 2): "gladiator" | "templar" | "assassin" | "ranger" | "sorcerer" | "spiritmaster" | "cleric" | "chanter" = culure cchiù forme proprie 'e mirino e icone, animazione, effette ed emoji (pigliano 'o posto d'e valure [HUD])\n"halloween"    = (evento) zucca arancione e viola 'e notte, zucca e fantasmiello\n"natale"       = (evento) russo, verde abete e oro, riale e arbero\n"capodanno"    = (evento) niro, oro e argiento, brindisi e fuoche\n"sanvalentino" = (evento) rosa e russo vino, core ca sbattono\n"carnevale"    = (evento) viola, giallo e verde, maschera e coriandole\n"pasqua"       = (evento) pastelle chiare 'e primmavera, ovo e pucino\n"sanpatrizio"  = (evento) verde trifoglio e oro, quadrifoglio e buccale\n"custom"     = tutte 'e ThemeColor... 'a sotto + 'e culure 'e [HUD] Culure\n'E teme pronte nun cagnano maje. 'E teme tuoje, fatte cu "Editor d'e teme" int'e Mpustaziune, se chiammano "user:Nomme".
bro=Vibe dei colori:\n"principale" = il tema classico (scuro e oro); l'HUD usa i colori di [HUD] Colori\n"dark"       = nero grafite e azzurro ghiaccio, contrasto da paura\n"bright"     = chiaro: pannelli bianchi e testi scuri, HUD giallo\n"cuddle"     = colori coccolosi: pesca, crema e pastelli soft\n"pinkhaze"   = nebbiolina rosa e viola su fondo scuro, aesthetic\n"egirl"      = rosa shocking e nero, neon, slay\n"vi"         = Vice City: tramonto rosa/arancio, viola e turchese (vibe GTA VI)\nTemi di classe (AION 2): "gladiator" | "templar" | "assassin" | "ranger" | "sorcerer" | "spiritmaster" | "cleric" | "chanter" = colori + forme di mirino e icone, animazioni, effetti ed emoji tutti loro, drip unico (sostituiscono i valori [HUD])\n"halloween"    = (evento) zucca arancio e viola notte, zucca e fantasmino, spooky\n"natale"       = (evento) rosso, verde abete e oro, regalo e albero\n"capodanno"    = (evento) nero, oro e argento, brindisi e fuochi, party\n"sanvalentino" = (evento) rosa e rosso vino, cuori che battono, love\n"carnevale"    = (evento) viola, giallo e verde, maschera e coriandoli\n"pasqua"       = (evento) pastelli chiari di primavera, uovo e pulcino\n"sanpatrizio"  = (evento) verde trifoglio e oro, quadrifoglio e boccale\n"custom"     = tutti i ThemeColor... qui sotto + i colori di [HUD] Colori\nI temi pronti non cambiano mai. I tuoi temi, fatti col "Theme editor" nei Settaggi, si chiamano "user:Nome".
es=Tema de colores:\n"principale" = el tema clásico (oscuro y dorado); el HUD usa los colores de [HUD] Colores\n"dark"       = negro grafito y azul hielo, alto contraste\n"bright"     = claro: paneles blancos y texto oscuro, HUD amarillo\n"cuddle"     = colores tiernos: melocotón, crema y pasteles suaves\n"pinkhaze"   = bruma rosa y morada sobre fondo oscuro\n"egirl"      = rosa intenso y negro, neón\n"vi"         = Vice City: atardecer rosa/naranja, morado y turquesa (estilo GTA VI)\nTemas de clase (AION 2): "gladiator" | "templar" | "assassin" | "ranger" | "sorcerer" | "spiritmaster" | "cleric" | "chanter" = colores más formas propias de mira e iconos, animación, efectos y emoji (sustituyen los valores de [HUD])\n"halloween"    = (evento) naranja calabaza y morado noche, calabaza y fantasmita\n"natale"       = (evento) rojo, verde abeto y oro, regalo y árbol\n"capodanno"    = (evento) negro, oro y plata, brindis y fuegos artificiales\n"sanvalentino" = (evento) rosa y rojo vino, corazones que laten\n"carnevale"    = (evento) morado, amarillo y verde, máscara y confeti\n"pasqua"       = (evento) pasteles claros de primavera, huevo y pollito\n"sanpatrizio"  = (evento) verde trébol y oro, trébol de cuatro hojas y jarra\n"custom"     = todos los ThemeColor... de abajo + los colores de [HUD] Colores\nLos temas listos nunca cambian. Tus temas, creados con el "Editor de temas" de los Ajustes, se llaman "user:Nombre".
fr=Thème de couleurs :\n"principale" = le thème classique (sombre et or) ; le HUD utilise les couleurs de [HUD] Couleurs\n"dark"       = noir graphite et bleu glacier, fort contraste\n"bright"     = clair : panneaux blancs et texte sombre, HUD jaune\n"cuddle"     = couleurs douces : pêche, crème et pastels\n"pinkhaze"   = brume rose et violette sur fond sombre\n"egirl"      = rose vif et noir, néon\n"vi"         = Vice City : coucher de soleil rose/orange, violet et turquoise (style GTA VI)\nThèmes de classe (AION 2) : "gladiator" | "templar" | "assassin" | "ranger" | "sorcerer" | "spiritmaster" | "cleric" | "chanter" = couleurs plus formes propres du viseur et des icônes, animation, effets et emoji (remplacent les valeurs [HUD])\n"halloween"    = (événement) orange citrouille et violet nuit, citrouille et petit fantôme\n"natale"       = (événement) rouge, vert sapin et or, cadeau et sapin\n"capodanno"    = (événement) noir, or et argent, toast et feux d'artifice\n"sanvalentino" = (événement) rose et rouge vin, cœurs qui battent\n"carnevale"    = (événement) violet, jaune et vert, masque et confettis\n"pasqua"       = (événement) pastels clairs de printemps, œuf et poussin\n"sanpatrizio"  = (événement) vert trèfle et or, trèfle à quatre feuilles et chope\n"custom"     = toutes les ThemeColor... ci-dessous + les couleurs de [HUD] Couleurs\nLes thèmes prêts ne changent jamais. Tes thèmes, créés avec l'"Éditeur de thèmes" des Paramètres, s'appellent "user:Nom".
de=Farbdesign:\n"principale" = das klassische Design (dunkel und gold); das HUD nutzt die Farben aus [HUD] Farben\n"dark"       = Graphitschwarz und Eisblau, hoher Kontrast\n"bright"     = hell: weiße Panels und dunkler Text, gelbes HUD\n"cuddle"     = kuschelige Farben: Pfirsich, Creme und sanfte Pastelltöne\n"pinkhaze"   = rosa-violetter Dunst auf dunklem Grund\n"egirl"      = Pink und Schwarz, Neon\n"vi"         = Vice City: rosa/orange Sonnenuntergang, Lila und Türkis (GTA-VI-Stil)\nKlassen-Designs (AION 2): "gladiator" | "templar" | "assassin" | "ranger" | "sorcerer" | "spiritmaster" | "cleric" | "chanter" = Farben plus eigene Formen für Fadenkreuz und Symbole, Animation, Effekte und Emoji (ersetzen die [HUD]-Werte)\n"halloween"    = (Event) Kürbisorange und Nachtviolett, Kürbis und Gespenst\n"natale"       = (Event) Rot, Tannengrün und Gold, Geschenk und Baum\n"capodanno"    = (Event) Schwarz, Gold und Silber, Anstoßen und Feuerwerk\n"sanvalentino" = (Event) Rosa und Weinrot, schlagende Herzen\n"carnevale"    = (Event) Lila, Gelb und Grün, Maske und Konfetti\n"pasqua"       = (Event) helle Frühlingspastelltöne, Ei und Küken\n"sanpatrizio"  = (Event) Kleegrün und Gold, Glücksklee und Krug\n"custom"     = alle ThemeColor... unten + die Farben aus [HUD] Farben\nFertige Designs ändern sich nie. Deine eigenen Designs, erstellt mit dem "Design-Editor" in den Einstellungen, heißen "user:Name".
pt=Tema de cores:\n"principale" = o tema clássico (escuro e dourado); o HUD usa as cores de [HUD] Cores\n"dark"       = preto grafite e azul gelo, alto contraste\n"bright"     = claro: painéis brancos e texto escuro, HUD amarelo\n"cuddle"     = cores fofas: pêssego, creme e tons pastel\n"pinkhaze"   = névoa rosa e roxa sobre fundo escuro\n"egirl"      = rosa choque e preto, neon\n"vi"         = Vice City: pôr do sol rosa/laranja, roxo e turquesa (estilo GTA VI)\nTemas de classe (AION 2): "gladiator" | "templar" | "assassin" | "ranger" | "sorcerer" | "spiritmaster" | "cleric" | "chanter" = cores mais formas próprias de mira e ícones, animação, efeitos e emoji (substituem os valores de [HUD])\n"halloween"    = (evento) laranja abóbora e roxo noite, abóbora e fantasminha\n"natale"       = (evento) vermelho, verde pinheiro e dourado, presente e árvore\n"capodanno"    = (evento) preto, dourado e prata, brinde e fogos\n"sanvalentino" = (evento) rosa e vermelho vinho, corações batendo\n"carnevale"    = (evento) roxo, amarelo e verde, máscara e confete\n"pasqua"       = (evento) tons pastel claros de primavera, ovo e pintinho\n"sanpatrizio"  = (evento) verde trevo e dourado, trevo de quatro folhas e caneca\n"custom"     = todos os ThemeColor... abaixo + as cores de [HUD] Cores\nOs temas prontos nunca mudam. Seus temas, criados no "Editor de temas" das Configurações, se chamam "user:Nome".
ru=Цветовая тема:\n"principale" = классическая тема (тёмная с золотом); HUD берёт цвета из [HUD] Цвета\n"dark"       = графитовый чёрный и ледяной голубой, высокий контраст\n"bright"     = светлая: белые панели и тёмный текст, жёлтый HUD\n"cuddle"     = уютные цвета: персик, крем и мягкая пастель\n"pinkhaze"   = розово-фиолетовая дымка на тёмном фоне\n"egirl"      = ярко-розовый и чёрный, неон\n"vi"         = Vice City: розово-оранжевый закат, фиолетовый и бирюзовый (стиль GTA VI)\nТемы классов (AION 2): "gladiator" | "templar" | "assassin" | "ranger" | "sorcerer" | "spiritmaster" | "cleric" | "chanter" = цвета плюс свои формы прицела и значков, анимация, эффекты и эмодзи (заменяют значения [HUD])\n"halloween"    = (праздник) тыквенный оранжевый и ночной фиолетовый, тыква и привидение\n"natale"       = (праздник) красный, еловый зелёный и золото, подарок и ёлка\n"capodanno"    = (праздник) чёрный, золото и серебро, тост и фейерверк\n"sanvalentino" = (праздник) розовый и винно-красный, бьющиеся сердца\n"carnevale"    = (праздник) фиолетовый, жёлтый и зелёный, маска и конфетти\n"pasqua"       = (праздник) светлые весенние пастели, яйцо и цыплёнок\n"sanpatrizio"  = (праздник) клеверный зелёный и золото, клевер и кружка\n"custom"     = все ThemeColor... ниже + цвета из [HUD] Цвета\nГотовые темы никогда не меняются. Ваши темы, созданные в "Редакторе тем" в Настройках, называются "user:Имя".
ko=색상 테마:\n"principale" = 기본 테마 (어두운 색과 금색). HUD는 [HUD] 색상의 값을 사용\n"dark"       = 그래파이트 블랙과 아이스 블루, 높은 대비\n"bright"     = 밝은 테마: 흰 패널과 어두운 글자, 노란 HUD\n"cuddle"     = 포근한 색: 피치, 크림, 부드러운 파스텔\n"pinkhaze"   = 어두운 배경 위 분홍·보라 안개\n"egirl"      = 핫핑크와 검정, 네온\n"vi"         = Vice City: 분홍/주황 노을, 보라와 청록 (GTA VI 스타일)\n클래스 테마 (AION 2): "gladiator" | "templar" | "assassin" | "ranger" | "sorcerer" | "spiritmaster" | "cleric" | "chanter" = 색상과 함께 조준선·아이콘 모양, 애니메이션, 효과, 이모지도 클래스 전용 ([HUD] 값을 대신함)\n"halloween"    = (이벤트) 호박 주황과 밤 보라, 호박과 꼬마 유령\n"natale"       = (이벤트) 빨강, 전나무 초록과 금색, 선물과 트리\n"capodanno"    = (이벤트) 검정, 금색과 은색, 건배와 불꽃놀이\n"sanvalentino" = (이벤트) 분홍과 와인 빨강, 두근거리는 하트\n"carnevale"    = (이벤트) 보라, 노랑과 초록, 가면과 색종이\n"pasqua"       = (이벤트) 밝은 봄 파스텔, 달걀과 병아리\n"sanpatrizio"  = (이벤트) 클로버 초록과 금색, 네잎클로버와 맥주잔\n"custom"     = 아래의 모든 ThemeColor... + [HUD] 색상\n기본 테마는 절대 바뀌지 않습니다. 설정의 "테마 편집기"로 만든 내 테마는 "user:이름"으로 불립니다.
zh=配色主题：\n"principale" = 经典主题（深色配金色）；HUD 使用 [HUD] 颜色 中的颜色\n"dark"       = 石墨黑和冰蓝，高对比度\n"bright"     = 浅色：白色面板和深色文字，黄色 HUD\n"cuddle"     = 温柔配色：桃色、奶油色和柔和粉彩\n"pinkhaze"   = 深色背景上的粉紫雾感\n"egirl"      = 亮粉和黑色，霓虹\n"vi"         = Vice City：粉橙色日落、紫色和青绿色（GTA VI 风格）\n职业主题（AION 2）："gladiator" | "templar" | "assassin" | "ranger" | "sorcerer" | "spiritmaster" | "cleric" | "chanter" = 除颜色外，准星和图标的形状、动画、特效和表情都是职业专属（替代 [HUD] 的数值）\n"halloween"    = （节日）南瓜橙与夜紫，南瓜和小幽灵\n"natale"       = （节日）红色、冷杉绿与金色，礼物和圣诞树\n"capodanno"    = （节日）黑、金与银，干杯和烟花\n"sanvalentino" = （节日）粉色与酒红，跳动的心\n"carnevale"    = （节日）紫、黄与绿，面具和彩纸\n"pasqua"       = （节日）明亮的春季粉彩，彩蛋和小鸡\n"sanpatrizio"  = （节日）三叶草绿与金色，四叶草和啤酒杯\n"custom"     = 下方所有 ThemeColor... + [HUD] 颜色\n预设主题永远不变。你在设置的"主题编辑器"中创建的主题名为 "user:名称"。
ja=カラーテーマ：\n"principale" = 定番テーマ（ダークとゴールド）。HUD は [HUD] 色 の色を使用\n"dark"       = グラファイトブラックとアイスブルー、高コントラスト\n"bright"     = 明るいテーマ：白いパネルと濃い文字、黄色い HUD\n"cuddle"     = やさしい色：ピーチ、クリーム、淡いパステル\n"pinkhaze"   = 暗い背景にピンクと紫のもや\n"egirl"      = ホットピンクと黒、ネオン\n"vi"         = Vice City：ピンク/オレンジの夕焼け、紫とターコイズ（GTA VI 風）\nクラステーマ（AION 2）："gladiator" | "templar" | "assassin" | "ranger" | "sorcerer" | "spiritmaster" | "cleric" | "chanter" = 色に加えて照準とアイコンの形、アニメーション、エフェクト、絵文字もクラス専用（[HUD] の値の代わりに使用）\n"halloween"    = （イベント）かぼちゃオレンジと夜の紫、かぼちゃとおばけ\n"natale"       = （イベント）赤、もみの緑と金、プレゼントとツリー\n"capodanno"    = （イベント）黒、金と銀、乾杯と花火\n"sanvalentino" = （イベント）ピンクとワインレッド、鼓動するハート\n"carnevale"    = （イベント）紫、黄と緑、仮面と紙吹雪\n"pasqua"       = （イベント）明るい春のパステル、卵とひよこ\n"sanpatrizio"  = （イベント）クローバーグリーンと金、四つ葉とジョッキ\n"custom"     = 下のすべての ThemeColor... + [HUD] 色\n既成テーマは変わりません。設定の「テーマエディター」で作ったテーマは "user:名前" と呼ばれます。
)" "`n"
        s .= "
(
@=ThemeColorBg ThemeColorRow ThemeColorHover ThemeColorLine ThemeColorAccent ThemeColorText ThemeColorSubText ThemeColorMuted ThemeColorDeep ThemeColorGo ThemeColorWait ThemeColorOk ThemeColorErr ThemeColorInfo ThemeColorWinBg ThemeColorWinText ThemeColorWinSub ThemeColorWinField
en=Color used only with the "custom" theme (Theme := "custom").\nPick it with "Pick color..." or type it as RRGGBB (e.g. 14171C) or as an English name (Red, White...).
nap=Culore ca serve sulo cu 'o tema "custom" (Theme := "custom").\nSciglielo cu "Scigli 'o culore..." o scrivilo comme RRGGBB (p'esempio 14171C) o cu 'o nomme inglese (Red, White...).
bro=Colore usato solo col tema "custom" (Theme := "custom").\nSceglilo con "Scegli il colore..." o scrivilo tipo RRGGBB (es. 14171C) o col nome inglese (Red, White...).
es=Color usado solo con el tema "custom" (Theme := "custom").\nElígelo con el selector de color o escríbelo como RRGGBB (p. ej. 14171C) o con un nombre en inglés (Red, White...).
fr=Couleur utilisée seulement avec le thème "custom" (Theme := "custom").\nChoisis-la avec le sélecteur de couleur ou écris-la en RRGGBB (ex. 14171C) ou en nom anglais (Red, White...).
de=Farbe, die nur mit dem Design "custom" gilt (Theme := "custom").\nMit der Farbauswahl wählen oder als RRGGBB (z. B. 14171C) bzw. englischen Namen (Red, White...) eintragen.
pt=Cor usada só com o tema "custom" (Theme := "custom").\nEscolha com o seletor de cor ou digite como RRGGBB (ex. 14171C) ou nome em inglês (Red, White...).
ru=Цвет используется только с темой "custom" (Theme := "custom").\nВыберите его в палитре или введите как RRGGBB (напр. 14171C) или английским названием (Red, White...).
ko="custom" 테마에서만 쓰이는 색입니다 (Theme := "custom").\n색 선택 버튼으로 고르거나 RRGGBB (예: 14171C) 또는 영어 색 이름 (Red, White...)으로 입력하세요.
zh=仅在 "custom" 主题下使用的颜色（Theme := "custom"）。\n用取色按钮选择，或输入 RRGGBB（如 14171C）或英文颜色名（Red、White...）。
ja="custom" テーマでのみ使う色です（Theme := "custom"）。\n色の選択ボタンで選ぶか、RRGGBB（例：14171C）または英語の色名（Red、White...）で入力します。
it=il nome deve essere un'impostazione numerica scritta prima di questa nella CONFIG
en=the name must be a numeric setting written before this one in the CONFIG
nap='o nomme adda essere na mpustazione numerica scritta primma 'e chesta int'â CONFIG
bro=il nome dev'essere un settaggio numerico scritto prima di questo nella CONFIG
es=el nombre debe ser un ajuste numérico escrito antes de este en la CONFIG
fr=le nom doit être un réglage numérique écrit avant celui-ci dans la CONFIG
de=der Name muss eine Zahleneinstellung sein, die in der CONFIG davor steht
pt=o nome deve ser uma configuração numérica escrita antes desta na CONFIG
ru=имя должно быть числовой настройкой, записанной в CONFIG раньше этой
ko=이름은 CONFIG에서 이 항목보다 앞에 있는 숫자 설정이어야 합니다
zh=名称必须是 CONFIG 中写在此项之前的数值设置
ja=名前は CONFIG でこれより前に書かれた数値の設定である必要があります
it=serve un tasto
en=a key is required
nap=ce vo' nu tasto
bro=serve un tasto bro
es=hace falta una tecla
fr=une touche est nécessaire
de=eine Taste ist nötig
pt=é preciso uma tecla
ru=нужна клавиша
ko=키가 필요합니다
zh=需要一个按键
ja=キーが必要です
it=tasto non valido
en=invalid key
nap=tasto ca nun va bbuono
bro=tasto sus
es=tecla no válida
fr=touche non valide
de=ungültige Taste
pt=tecla inválida
ru=недопустимая клавиша
ko=잘못된 키
zh=无效按键
ja=無効なキー
it=serve un solo tasto, senza Ctrl/Shift/Alt/Win
en=a single key is required, without Ctrl/Shift/Alt/Win
nap=ce vo' nu tasto sulo, senza Ctrl/Shift/Alt/Win
bro=serve un tasto solo, niente Ctrl/Shift/Alt/Win
es=hace falta una sola tecla, sin Ctrl/Shift/Alt/Win
fr=une seule touche, sans Ctrl/Shift/Alt/Win
de=nur eine Taste, ohne Strg/Umschalt/Alt/Win
pt=é preciso uma só tecla, sem Ctrl/Shift/Alt/Win
ru=нужна одна клавиша, без Ctrl/Shift/Alt/Win
ko=Ctrl/Shift/Alt/Win 없이 키 하나만 입력하세요
zh=只能是单个按键，不带 Ctrl/Shift/Alt/Win
ja=Ctrl/Shift/Alt/Win なしのキー 1 つにしてください
it=Easter egg: countdown GTA VI
en=Easter egg: GTA VI countdown
nap=Easter egg: cunto â reversa GTA VI
bro=Easter egg: countdown GTA VI, hype
es=Easter egg: cuenta atrás de GTA VI
fr=Easter egg : compte à rebours GTA VI
de=Easter Egg: GTA-VI-Countdown
pt=Easter egg: contagem regressiva do GTA VI
ru=Пасхалка: обратный отсчёт до GTA VI
ko=이스터에그: GTA VI 카운트다운
zh=彩蛋：GTA VI 倒计时
ja=イースターエッグ：GTA VI カウントダウン
it=Data di uscita GTA VI
en=GTA VI release date
nap=Data d'uscita 'e GTA VI
bro=Data drop GTA VI
es=Fecha de salida de GTA VI
fr=Date de sortie de GTA VI
de=GTA-VI-Erscheinungsdatum
pt=Data de lançamento do GTA VI
ru=Дата выхода GTA VI
ko=GTA VI 출시일
zh=GTA VI 发售日期
ja=GTA VI 発売日
it=data non valida: scrivila come AAAAMMGGhhmmss (es. 20261119000000)
en=invalid date: write it as YYYYMMDDhhmmss (e.g. 20261119000000)
nap=data ca nun va bbuona: scrivila comme AAAAMMGGhhmmss (p'esempio 20261119000000)
bro=data sus: scrivila tipo AAAAMMGGhhmmss (es. 20261119000000)
es=fecha no válida: escríbela como AAAAMMDDhhmmss (p. ej. 20261119000000)
fr=date non valide : écris-la sous la forme AAAAMMJJhhmmss (ex. 20261119000000)
de=ungültiges Datum: als JJJJMMTThhmmss schreiben (z. B. 20261119000000)
pt=data inválida: escreva como AAAAMMDDhhmmss (ex. 20261119000000)
ru=неверная дата: формат ГГГГММДДччммсс (напр. 20261119000000)
ko=잘못된 날짜: YYYYMMDDhhmmss 형식으로 입력하세요 (예: 20261119000000)
zh=日期无效：请写成 YYYYMMDDhhmmss（如 20261119000000）
ja=無効な日付：YYYYMMDDhhmmss の形式で入力（例：20261119000000）
@=ViCountdown
en=Easter egg of the "vi" theme: at the top center (a few px from the edge) a days:hours:minutes:seconds countdown to the GTA VI release.\nIt shows only with the game in the foreground (or in preview) and hides while the map legend is visible.\non only with the "vi" theme; off in the other themes (in your own themes you choose)
nap=Easter egg d'o tema "vi": 'ncoppa 'mmiezo (a quacche px d'o bordo) 'o cunto â reversa juorne:ore:minute:secondi pe' l'uscita 'e GTA VI.\nSe vede sulo cu 'o juoco annanze (o in anteprima) e s'annasconne quanno ce sta 'a leggenda d'a mappa.\nappicciato sulo cu 'o tema "vi"; int'e ate teme è stutato (int'e teme tuoje scigli tu)
bro=Easter egg del tema "vi": in alto al centro (a pochi px dal bordo) il countdown giorni:ore:minuti:secondi al drop di GTA VI, hype assurdo.\nSi vede solo col gioco davanti (o in preview) e sparisce quando c'è la leggenda della mappa.\non solo col tema "vi"; negli altri temi è off (nei tuoi temi decidi tu)
es=Easter egg del tema "vi": arriba en el centro (a pocos px del borde) una cuenta atrás días:horas:minutos:segundos hasta la salida de GTA VI.\nSolo se ve con el juego en primer plano (o en la vista previa) y se oculta cuando está la leyenda del mapa.\nactivado solo con el tema "vi"; desactivado en los demás temas (en tus temas eliges tú)
fr=Easter egg du thème "vi" : en haut au centre (à quelques px du bord), un compte à rebours jours:heures:minutes:secondes jusqu'à la sortie de GTA VI.\nVisible seulement avec le jeu au premier plan (ou en aperçu), masqué quand la légende de la carte est affichée.\nactivé seulement avec le thème "vi" ; désactivé dans les autres thèmes (dans tes thèmes, c'est toi qui choisis)
de=Easter Egg des Designs "vi": oben in der Mitte (wenige px vom Rand) ein Countdown Tage:Stunden:Minuten:Sekunden bis zum Release von GTA VI.\nNur sichtbar, wenn das Spiel im Vordergrund ist (oder in der Vorschau); bei sichtbarer Kartenlegende ausgeblendet.\nnur mit dem Design "vi" an; in den anderen Designs aus (in deinen eigenen Designs entscheidest du)
pt=Easter egg do tema "vi": no alto, ao centro (a poucos px da borda), uma contagem regressiva dias:horas:minutos:segundos até o lançamento do GTA VI.\nSó aparece com o jogo em primeiro plano (ou na prévia) e some quando a legenda do mapa está visível.\nligado só com o tema "vi"; desligado nos outros temas (nos seus temas você escolhe)
ru=Пасхалка темы "vi": вверху по центру (в нескольких px от края) обратный отсчёт дни:часы:минуты:секунды до выхода GTA VI.\nВидна только когда игра на переднем плане (или в предпросмотре) и скрывается при легенде карты.\nвключено только в теме "vi"; в остальных темах выключено (в своих темах решаете вы)
ko="vi" 테마의 이스터에그: 화면 위쪽 가운데(가장자리에서 몇 px)에 GTA VI 출시까지 일:시:분:초 카운트다운을 표시합니다.\n게임이 앞에 있을 때(또는 미리보기)만 보이며 지도 키 안내가 있을 때는 숨겨집니다.\n"vi" 테마에서만 켜짐. 다른 테마에서는 꺼짐 (내 테마에서는 직접 선택)
zh="vi" 主题彩蛋：屏幕顶部居中（距边缘几 px）显示距 GTA VI 发售的 天:时:分:秒 倒计时。\n仅在游戏处于前台（或预览）时显示，地图按键说明出现时隐藏。\n仅在 "vi" 主题中开启；其他主题中关闭（自定义主题由你决定）
ja="vi" テーマのイースターエッグ：画面上部中央（端から数 px）に GTA VI 発売までの 日:時:分:秒 のカウントダウンを表示。\nゲームが前面にあるとき（またはプレビュー中）だけ表示され、マップのキー案内が出ている間は隠れます。\n"vi" テーマでのみオン。他のテーマではオフ（自作テーマでは自由に選べます）
)" "`n"
        s .= "
(
@=ViCountdownDate
en=GTA VI release date and time, as YYYYMMDDhhmmss in your PC's time (20261119000000 = 19 November 2026 at midnight).\nIf the release moves, just change it here.
nap=Data e ora d'uscita 'e GTA VI, comme AAAAMMGGhhmmss cu ll'ora d'o PC (20261119000000 = 19 novembre 2026 a mezanotte).\nSi l'uscita se sposta, cagnala ccà.
bro=Data e ora del drop di GTA VI, tipo AAAAMMGGhhmmss con l'ora del PC (20261119000000 = 19 novembre 2026 a mezzanotte).\nSe lo rimandano (di nuovo...), cambiala qui.
es=Fecha y hora de salida de GTA VI, como AAAAMMDDhhmmss en la hora de tu PC (20261119000000 = 19 de noviembre de 2026 a medianoche).\nSi la salida se mueve, cámbiala aquí.
fr=Date et heure de sortie de GTA VI, au format AAAAMMJJhhmmss à l'heure du PC (20261119000000 = 19 novembre 2026 à minuit).\nSi la sortie est décalée, change-la ici.
de=Datum und Uhrzeit des GTA-VI-Release als JJJJMMTThhmmss in PC-Zeit (20261119000000 = 19. November 2026 um Mitternacht).\nWird der Release verschoben, hier ändern.
pt=Data e hora de lançamento do GTA VI, como AAAAMMDDhhmmss no horário do PC (20261119000000 = 19 de novembro de 2026 à meia-noite).\nSe o lançamento mudar, altere aqui.
ru=Дата и время выхода GTA VI в формате ГГГГММДДччммсс по времени ПК (20261119000000 = 19 ноября 2026, полночь).\nЕсли выход перенесут, поменяйте здесь.
ko=GTA VI 출시 날짜와 시간, PC 시간 기준 YYYYMMDDhhmmss 형식 (20261119000000 = 2026년 11월 19일 자정).\n출시일이 바뀌면 여기서 변경하세요.
zh=GTA VI 发售日期和时间，按电脑时间写成 YYYYMMDDhhmmss（20261119000000 = 2026 年 11 月 19 日零点）。\n如果发售日变更，在这里修改。
ja=GTA VI の発売日時。PC の時刻で YYYYMMDDhhmmss 形式（20261119000000 = 2026 年 11 月 19 日 午前 0 時）。\n発売日が変わったらここを変更します。
it=Testo ed emoji automatici
en=Automatic text and emoji
nap=Testo ed emoji automatice
bro=Testo ed emoji in auto, zero sbatti
es=Texto y emoji automáticos
fr=Texte et emoji automatiques
de=Text und Emoji automatisch
pt=Texto e emoji automáticos
ru=Автоматический текст и эмодзи
ko=텍스트와 이모지 자동 크기
zh=文字和表情自动大小
ja=テキストと絵文字を自動調整
@=IconAutoFit
en=true = text and emoji fit the icon shape and size by themselves: as big as possible, stacked without overlapping (the text and emoji size settings are not used)\nfalse = fixed text and emoji sizes (still stacked without overlapping)
nap=true = testo ed emoji s'adattano 'a sule â forma e â grandezza 'e ll'icona: cchiù gruosse ca se pò, uno sotto a ll'ato senza se sovrapponere (e grandezze 'e testo ed emoji nun servono)\nfalse = grandezze fisse 'e testo ed emoji (sempe uno sotto a ll'ato)
bro=true = testo ed emoji si adattano da soli a forma e size dell'icona: grandi il più possibile, uno sotto l'altro senza accavallarsi (le size di testo ed emoji non contano)\nfalse = size fisse di testo ed emoji (sempre impilati)
es=true = texto y emoji se ajustan solos a la forma y al tamaño del icono: lo más grandes posible, apilados sin superponerse (no se usan los tamaños de texto y emoji)\nfalse = tamaños fijos de texto y emoji (apilados sin superponerse)
fr=true = texte et emoji s'adaptent seuls à la forme et à la taille de l'icône : aussi grands que possible, empilés sans se chevaucher (les tailles de texte et d'emoji ne sont pas utilisées)\nfalse = tailles fixes de texte et d'emoji (empilés sans chevauchement)
de=true = Text und Emoji passen sich selbst an Form und Größe des Symbols an: so groß wie möglich, ohne Überlappung gestapelt (Text- und Emoji-Größen werden nicht verwendet)\nfalse = feste Text- und Emoji-Größen (trotzdem ohne Überlappung gestapelt)
pt=true = texto e emoji se ajustam sozinhos à forma e ao tamanho do ícone: o maior possível, empilhados sem sobrepor (os tamanhos de texto e emoji não são usados)\nfalse = tamanhos fixos de texto e emoji (empilhados sem sobrepor)
ru=true = текст и эмодзи сами подстраиваются под форму и размер значка: максимально крупно, друг под другом без наложения (размеры текста и эмодзи не используются)\nfalse = фиксированные размеры текста и эмодзи (всё равно без наложения)
ko=true = 텍스트와 이모지가 아이콘의 모양과 크기에 맞춰 자동으로 최대한 크게, 겹치지 않게 배치됩니다 (텍스트·이모지 크기 설정은 사용 안 함)\nfalse = 텍스트와 이모지 크기 고정 (겹치지 않게 배치)
zh=true = 文字和表情自动适配图标的形状和大小：尽可能大，上下排列互不重叠（不使用文字和表情大小设置）\nfalse = 文字和表情使用固定大小（仍上下排列不重叠）
ja=true = テキストと絵文字がアイコンの形と大きさに合わせて自動で最大化され、重ならないように縦に並びます（テキスト・絵文字のサイズ設定は使いません）\nfalse = テキストと絵文字のサイズを固定（重ならないように並べます）
it=Barra 1
en=Bar 1
nap=Barra 1
bro=Barra 1
es=Barra 1
fr=Barre 1
de=Balken 1
pt=Barra 1
ru=Полоса 1
ko=바 1
zh=条 1
ja=バー 1
it=Barra 2
en=Bar 2
nap=Barra 2
bro=Barra 2
es=Barra 2
fr=Barre 2
de=Balken 2
pt=Barra 2
ru=Полоса 2
ko=바 2
zh=条 2
ja=バー 2
it=Pannello Field Boss
en=Field Boss panel
nap=Pannello Field Boss
bro=Pannello Field Boss
es=Panel de Field Boss
fr=Panneau Field Boss
de=Field-Boss-Panel
pt=Painel Field Boss
ru=Панель Field Boss
ko=Field Boss 패널
zh=Field Boss 面板
ja=Field Boss パネル
it=Leggenda dei tasti
en=Key legend
nap=Leggenda d'e taste
bro=Leggenda tasti
es=Leyenda de teclas
fr=Légende des touches
de=Tastenlegende
pt=Legenda das teclas
ru=Легенда клавиш
ko=키 안내
zh=按键说明
ja=キーの案内
it=Istruzioni e anello
en=Instructions and ring
nap=Struzziune e anello
bro=Dritte e anello
es=Instrucciones y anillo
fr=Consignes et anneau
de=Anweisungen und Ring
pt=Instruções e anel
ru=Подсказки и кольцо
ko=안내와 링
zh=提示和光环
ja=案内とリング
it=Countdown GTA VI
en=GTA VI countdown
nap=Cunto â reversa GTA VI
bro=Countdown GTA VI
es=Cuenta atrás GTA VI
fr=Compte à rebours GTA VI
de=GTA-VI-Countdown
pt=Contagem GTA VI
ru=Отсчёт до GTA VI
ko=GTA VI 카운트다운
zh=GTA VI 倒计时
ja=GTA VI カウントダウン
it=Elementi
en=Items
nap=Piezze
bro=Roba
es=Elementos
fr=Éléments
de=Elemente
pt=Itens
ru=Элементы
ko=요소
zh=元素
ja=要素
it=Elementi nell'anteprima
en=Items in the preview
nap=Piezze int'a ll'anteprima
bro=Roba nella preview
es=Elementos en la vista previa
fr=Éléments dans l'aperçu
de=Elemente in der Vorschau
pt=Itens na prévia
ru=Элементы в предпросмотре
ko=미리보기 요소
zh=预览中的元素
ja=プレビューの要素
it=Tutti
en=All
nap=Tutte
bro=Tutti
es=Todos
fr=Tous
de=Alle
pt=Todos
ru=Все
ko=모두
zh=全部
ja=すべて
it=Nessuno
en=None
nap=Nisciuno
bro=Zero
es=Ninguno
fr=Aucun
de=Keine
pt=Nenhum
ru=Ничего
ko=없음
zh=无
ja=なし
it=Importa da un vecchio script...
en=Import from an old script...
nap=Piglia 'a nu script viecchio...
bro=Importa da uno script vecchio...
es=Importar de un script antiguo...
fr=Importer d'un ancien script...
de=Aus altem Skript importieren...
pt=Importar de um script antigo...
ru=Импорт из старого скрипта...
ko=이전 스크립트에서 가져오기...
zh=从旧脚本导入...
ja=古いスクリプトから読み込む...
it=Scegli il vecchio script (.ahk o .bak)
en=Choose the old script (.ahk or .bak)
nap=Scigli 'o script viecchio (.ahk o .bak)
bro=Scegli lo script vecchio (.ahk o .bak)
es=Elige el script antiguo (.ahk o .bak)
fr=Choisis l'ancien script (.ahk ou .bak)
de=Altes Skript wählen (.ahk oder .bak)
pt=Escolha o script antigo (.ahk ou .bak)
ru=Выберите старый скрипт (.ahk или .bak)
ko=이전 스크립트 선택 (.ahk 또는 .bak)
zh=选择旧脚本（.ahk 或 .bak）
ja=古いスクリプトを選択（.ahk または .bak）
it=Impostazioni importate: {1} valori cambiati.
en=Settings imported: {1} values changed.
nap=Mpustaziune pigliate: {1} valure cagnate.
bro=Settaggi importati: {1} valori cambiati, ez.
es=Ajustes importados: {1} valores cambiados.
fr=Paramètres importés : {1} valeurs modifiées.
de=Einstellungen importiert: {1} Werte geändert.
pt=Configurações importadas: {1} valores alterados.
ru=Настройки импортированы: изменено значений: {1}.
ko=설정을 가져왔습니다: {1}개 값 변경.
zh=已导入设置：{1} 个值已更改。
ja=設定を読み込みました：{1} 個の値を変更。
it=Manutenzione
en=Maintenance
nap=Manutenzione
bro=Officina
es=Mantenimiento
fr=Maintenance
de=Wartung
pt=Manutenção
ru=Обслуживание
ko=유지 관리
zh=维护
ja=メンテナンス
it=Strumenti per installazione, aggiornamenti e file di Wingman.
en=Tools for Wingman's setup, updates and files.
nap=Attrezze pe' l'installazione, l'aggiornamente e 'e file 'e Wingman.
bro=Roba per setup, update e file di Wingman, tutto qua.
es=Herramientas para la instalación, las actualizaciones y los archivos de Wingman.
fr=Outils pour l'installation, les mises à jour et les fichiers de Wingman.
de=Werkzeuge für Installation, Updates und Dateien von Wingman.
pt=Ferramentas de instalação, atualizações e arquivos do Wingman.
ru=Инструменты для установки, обновлений и файлов Wingman.
ko=Wingman 설치, 업데이트, 파일 관리 도구.
zh=Wingman 的安装、更新和文件工具。
ja=Wingman のインストール、アップデート、ファイル用のツール。
it=Termina Wingman
en=Quit Wingman
nap=Stuta Wingman
bro=Killa Wingman
es=Cerrar Wingman
fr=Quitter Wingman
de=Wingman beenden
pt=Encerrar Wingman
ru=Выйти из Wingman
ko=Wingman 종료
zh=退出 Wingman
ja=Wingman を終了
it=chiude il programma, non solo questa finestra
en=closes the whole program, not just this window
nap=stuta 'o programma, nun sulo sta fenesta
bro=spegne tutto il programma, non solo sta finestra
es=cierra el programa, no solo esta ventana
fr=ferme le programme, pas seulement cette fenêtre
de=beendet das Programm, nicht nur dieses Fenster
pt=fecha o programa, não só esta janela
ru=закрывает программу, а не только окно
ko=이 창이 아니라 프로그램 전체를 종료
zh=关闭整个程序，而不只是此窗口
ja=このウィンドウではなくプログラム全体を終了
)" "`n"
        s .= "
(
it=Cerca un'impostazione...
en=Search a setting...
nap=Cerca n'mpustazione...
bro=Cerca un setting...
es=Buscar un ajuste...
fr=Rechercher un paramètre...
de=Einstellung suchen...
pt=Buscar uma configuração...
ru=Поиск настройки...
ko=설정 검색...
zh=搜索设置...
ja=設定を検索...
it=Riesegui l'installazione guidata
en=Run the guided setup again
nap=Fa' n'ata vota l'installazione guidata
bro=Rilancia il setup guidato
es=Volver a ejecutar la instalación guiada
fr=Relancer l'installation guidée
de=Geführte Installation erneut starten
pt=Executar de novo a instalação guiada
ru=Снова запустить мастер установки
ko=설치 마법사 다시 실행
zh=重新运行安装向导
ja=セットアップウィザードを再実行
it=Controlla aggiornamenti (in arrivo)
en=Check for updates (coming soon)
nap=Guarda si ce stanno aggiornamente (a venì)
bro=Check update (coming soon, fra)
es=Buscar actualizaciones (próximamente)
fr=Rechercher des mises à jour (bientôt)
de=Nach Updates suchen (demnächst)
pt=Verificar atualizações (em breve)
ru=Проверить обновления (скоро)
ko=업데이트 확인 (준비 중)
zh=检查更新（即将推出）
ja=アップデートを確認（近日対応）
it=Apri la cartella delle impostazioni personali
en=Open the personal settings folder
nap=Arape 'a cartella d''e mpustaziune toje
bro=Apri la cartella dei tuoi settaggi
es=Abrir la carpeta de ajustes personales
fr=Ouvrir le dossier des paramètres personnels
de=Ordner mit persönlichen Einstellungen öffnen
pt=Abrir a pasta das configurações pessoais
ru=Открыть папку личных настроек
ko=개인 설정 폴더 열기
zh=打开个人设置文件夹
ja=個人設定フォルダーを開く
it=Apri la cartella di Wingman
en=Open the Wingman folder
nap=Arape 'a cartella 'e Wingman
bro=Apri la cartella di Wingman
es=Abrir la carpeta de Wingman
fr=Ouvrir le dossier de Wingman
de=Wingman-Ordner öffnen
pt=Abrir a pasta do Wingman
ru=Открыть папку Wingman
ko=Wingman 폴더 열기
zh=打开 Wingman 文件夹
ja=Wingman フォルダーを開く
it=Versione
en=Version
nap=Versione
bro=Versione
es=Versión
fr=Version
de=Version
pt=Versão
ru=Версия
ko=버전
zh=版本
ja=バージョン
it=Script
en=Script
nap=Script
bro=Script
es=Script
fr=Script
de=Skript
pt=Script
ru=Скрипт
ko=스크립트
zh=脚本
ja=スクリプト
it=Impostazioni personali
en=Personal settings
nap=Mpustaziune toje
bro=I tuoi settaggi
es=Ajustes personales
fr=Paramètres personnels
de=Persönliche Einstellungen
pt=Configurações pessoais
ru=Личные настройки
ko=개인 설정
zh=个人设置
ja=個人設定
it=Installazione guidata non trovata: manca "{1}" nella cartella di Wingman.
en=Guided setup not found: "{1}" is missing from the Wingman folder.
nap=Installazione guidata nun truvata: manca "{1}" dint''a cartella 'e Wingman.
bro=Setup guidato non trovato: manca "{1}" nella cartella di Wingman, bro.
es=No se encontró la instalación guiada: falta "{1}" en la carpeta de Wingman.
fr=Installation guidée introuvable : "{1}" manque dans le dossier de Wingman.
de=Geführte Installation nicht gefunden: "{1}" fehlt im Wingman-Ordner.
pt=Instalação guiada não encontrada: falta "{1}" na pasta do Wingman.
ru=Мастер установки не найден: в папке Wingman нет "{1}".
ko=설치 마법사를 찾을 수 없습니다: Wingman 폴더에 "{1}" 파일이 없습니다.
zh=未找到安装向导：Wingman 文件夹中缺少 "{1}"。
ja=セットアップが見つかりません：Wingman フォルダーに "{1}" がありません。
it=Terminare AION 2 Wingman?
en=Quit AION 2 Wingman?
nap=Stutammo AION 2 Wingman?
bro=Killiamo AION 2 Wingman?
es=¿Cerrar AION 2 Wingman?
fr=Quitter AION 2 Wingman ?
de=AION 2 Wingman beenden?
pt=Encerrar o AION 2 Wingman?
ru=Выйти из AION 2 Wingman?
ko=AION 2 Wingman을 종료할까요?
zh=要退出 AION 2 Wingman 吗？
ja=AION 2 Wingman を終了しますか？
it=HUD, Hidden Cube e Field Boss smettono di funzionare finché non lo riavvii.
en=HUD, Hidden Cube and Field Boss stop working until you start it again.
nap=HUD, Hidden Cube e Field Boss nun funzionano cchiù fino a quanno nun 'o fai partì n'ata vota.
bro=HUD, Hidden Cube e Field Boss si spengono finché non lo rilanci.
es=El HUD, Hidden Cube y Field Boss dejarán de funcionar hasta que lo vuelvas a iniciar.
fr=Le HUD, Hidden Cube et Field Boss cessent de fonctionner jusqu'au prochain lancement.
de=HUD, Hidden Cube und Field Boss funktionieren erst wieder nach einem Neustart.
pt=HUD, Hidden Cube e Field Boss param de funcionar até você iniciá-lo de novo.
ru=HUD, Hidden Cube и Field Boss перестанут работать до следующего запуска.
ko=다시 실행할 때까지 HUD, Hidden Cube, Field Boss가 작동하지 않습니다.
zh=在重新启动之前，HUD、Hidden Cube 和 Field Boss 将停止工作。
ja=再起動するまで HUD、Hidden Cube、Field Boss は動作しません。
it=Ci sono modifiche non salvate: andranno perse.
en=There are unsaved changes: they will be lost.
nap=Ce stanno cagnamiente nun salvate: se perdono.
bro=Hai modifiche non salvate: vanno perse, occhio.
es=Hay cambios sin guardar: se perderán.
fr=Des modifications ne sont pas enregistrées : elles seront perdues.
de=Es gibt ungespeicherte Änderungen: Sie gehen verloren.
pt=Há alterações não salvas: elas serão perdidas.
ru=Есть несохранённые изменения: они будут потеряны.
ko=저장하지 않은 변경 사항이 있습니다. 모두 사라집니다.
zh=有未保存的更改：它们将会丢失。
ja=保存していない変更があります。失われます。
it=Risultati della ricerca
en=Search results
nap=Chello ch'aggio truvato
bro=Risultati della ricerca
es=Resultados de la búsqueda
fr=Résultats de la recherche
de=Suchergebnisse
pt=Resultados da busca
ru=Результаты поиска
ko=검색 결과
zh=搜索结果
ja=検索結果
it={1} risultati per "{2}"
en={1} results for "{2}"
nap={1} risultate pe' "{2}"
bro={1} risultati per "{2}", easy
es={1} resultados para "{2}"
fr={1} résultats pour "{2}"
de={1} Ergebnisse für "{2}"
pt={1} resultados para "{2}"
ru=Найдено для "{2}": {1}
ko="{2}" 검색 결과 {1}개
zh="{2}" 的结果：{1} 个
ja="{2}" の検索結果：{1} 件
it=Nessun risultato per "{1}"
en=No results for "{1}"
nap=Nun aggio truvato niente pe' "{1}"
bro=Zero risultati per "{1}", sad
es=Sin resultados para "{1}"
fr=Aucun résultat pour "{1}"
de=Keine Ergebnisse für "{1}"
pt=Nenhum resultado para "{1}"
ru=Ничего не найдено для "{1}"
ko="{1}"에 대한 결과 없음
zh=没有 "{1}" 的结果
ja="{1}" の結果はありません
it=Icone - generale
en=Icons - general
nap=Icone - generale
bro=Icone - basics
es=Iconos - general
fr=Icônes - général
de=Symbole - allgemein
pt=Ícones - geral
ru=Значки - общее
ko=아이콘 - 일반
zh=图标 - 通用
ja=アイコン - 全般
it=Opzioni comuni alle due icone. Con le icone speculari sposti il Loot e il Combat lo segue dall'altro lato.
en=Options shared by both icons. With mirrored icons you move the Loot and the Combat follows on the other side.
nap=Opzioni ca valeno pe' tutt'e doje 'e icone. Cu 'e icone a specchio muove 'o Loot e 'o Combat 'o segue 'a ll'ata parte.
bro=Opzioni per tutte e due le icone. Con le icone a specchio muovi il Loot e il Combat lo segue dall'altra parte, ez.
es=Opciones comunes a los dos iconos. Con los iconos reflejados mueves el Loot y el Combat lo sigue en el otro lado.
fr=Options communes aux deux icônes. Avec les icônes en miroir, tu déplaces le Loot et le Combat le suit de l'autre côté.
de=Gemeinsame Optionen beider Symbole. Mit gespiegelten Symbolen verschiebst du das Loot und das Combat folgt auf der anderen Seite.
pt=Opções comuns aos dois ícones. Com os ícones espelhados você move o Loot e o Combat acompanha do outro lado.
ru=Общие настройки обоих значков. При зеркальных значках двигаете Loot, а Combat следует за ним с другой стороны.
ko=두 아이콘 공통 옵션. 대칭을 켜면 Loot를 옮길 때 Combat이 반대쪽에서 따라옵니다.
zh=两个图标的共同选项。开启镜像后移动 Loot，Combat 会在另一侧跟随。
ja=両アイコン共通のオプション。左右対称にすると Loot を動かせば Combat が反対側で追従します。
it=Effetti Loot
en=Loot effects
nap=Effiette d'o Loot
bro=Effetti Loot
es=Efectos Loot
fr=Effets Loot
de=Loot-Effekte
pt=Efeitos Loot
ru=Эффекты Loot
ko=Loot 효과
zh=Loot 效果
ja=Loot エフェクト
it=Effetti animati dell'icona Loot quando è attiva. Si possono combinare.
en=Animated effects of the Loot icon when it is active. They can be combined.
nap=Effiette animate 'e ll'icona Loot quanno è appicciata. Se ponno mettere nzieme.
bro=Effetti animati dell'icona Loot quando è on. Si possono combinare.
es=Efectos animados del icono Loot cuando está activo. Se pueden combinar.
fr=Effets animés de l'icône Loot quand elle est active. Ils peuvent se combiner.
de=Animierte Effekte des Loot-Symbols, wenn es aktiv ist. Sie lassen sich kombinieren.
pt=Efeitos animados do ícone Loot quando está ativo. Podem ser combinados.
ru=Анимированные эффекты значка Loot, когда он активен. Их можно сочетать.
ko=Loot 아이콘이 켜졌을 때의 애니메이션 효과. 함께 쓸 수 있습니다.
zh=Loot 图标激活时的动画效果，可以组合使用。
ja=Loot アイコンがオンのときのアニメーション効果。組み合わせ可能です。
it=Effetti Combat
en=Combat effects
nap=Effiette d'o Combat
bro=Effetti Combat
es=Efectos Combat
fr=Effets Combat
de=Combat-Effekte
pt=Efeitos Combat
ru=Эффекты Combat
ko=Combat 효과
zh=Combat 效果
ja=Combat エフェクト
)" "`n"
        s .= "
(
it=Effetti animati dell'icona Combat quando è attiva. Si possono combinare.
en=Animated effects of the Combat icon when it is active. They can be combined.
nap=Effiette animate 'e ll'icona Combat quanno è appicciata. Se ponno mettere nzieme.
bro=Effetti animati dell'icona Combat quando è on. Si possono combinare.
es=Efectos animados del icono Combat cuando está activo. Se pueden combinar.
fr=Effets animés de l'icône Combat quand elle est active. Ils peuvent se combiner.
de=Animierte Effekte des Combat-Symbols, wenn es aktiv ist. Sie lassen sich kombinieren.
pt=Efeitos animados do ícone Combat quando está ativo. Podem ser combinados.
ru=Анимированные эффекты значка Combat, когда он активен. Их можно сочетать.
ko=Combat 아이콘이 켜졌을 때의 애니메이션 효과. 함께 쓸 수 있습니다.
zh=Combat 图标激活时的动画效果，可以组合使用。
ja=Combat アイコンがオンのときのアニメーション効果。組み合わせ可能です。
it=Icona Combat speculare al Loot
en=Combat icon mirrored to the Loot
nap=Icona Combat a specchio d'o Loot
bro=Icona Combat a specchio del Loot
es=Icono Combat reflejado del Loot
fr=Icône Combat en miroir du Loot
de=Combat-Symbol gespiegelt zum Loot
pt=Ícone Combat espelhado ao Loot
ru=Combat зеркально к Loot
ko=Combat 아이콘을 Loot과 대칭
zh=Combat 图标与 Loot 镜像
ja=Combat アイコンを Loot と左右対称
it=Grandezza icona (altezza)
en=Icon size (height)
nap=Grandezza 'e ll'icona (autezza)
bro=Size icona (altezza)
es=Tamaño del icono (altura)
fr=Taille de l'icône (hauteur)
de=Symbolgröße (Höhe)
pt=Tamanho do ícone (altura)
ru=Размер значка (высота)
ko=아이콘 크기 (높이)
zh=图标大小（高度）
ja=アイコンサイズ（高さ）
it=Nascondi il pannello nei dungeon
en=Hide the panel in dungeons
nap=Annascunne 'o pannello dint'e dungeon
bro=Niente pannello nei dungeon
es=Ocultar el panel en las mazmorras
fr=Masquer le panneau dans les donjons
de=Panel in Dungeons ausblenden
pt=Ocultar o painel nas masmorras
ru=Скрывать панель в подземельях
ko=던전에서 패널 숨기기
zh=在副本中隐藏面板
ja=ダンジョンではパネルを隠す
it=Nomi dei dungeon
en=Dungeon names
nap=Nomme d'e dungeon
bro=Nomi dei dungeon
es=Nombres de las mazmorras
fr=Noms des donjons
de=Dungeon-Namen
pt=Nomes das masmorras
ru=Названия подземелий
ko=던전 이름
zh=副本名称
ja=ダンジョン名
it=Loot: accensione effetti (s)
en=Loot: effects on (s)
nap=Loot: appiccia l'effiette (s)
bro=Loot: effetti on (s)
es=Loot: encendido de efectos (s)
fr=Loot : allumage des effets (s)
de=Loot: Effekte an (s)
pt=Loot: ligar efeitos (s)
ru=Loot: включение эффектов (с)
ko=Loot: 효과 켜짐 (초)
zh=Loot：效果开启 (秒)
ja=Loot：エフェクト点灯 (秒)
it=Loot: spegnimento effetti (s)
en=Loot: effects off (s)
nap=Loot: stuta l'effiette (s)
bro=Loot: effetti off (s)
es=Loot: apagado de efectos (s)
fr=Loot : extinction des effets (s)
de=Loot: Effekte aus (s)
pt=Loot: desligar efeitos (s)
ru=Loot: выключение эффектов (с)
ko=Loot: 효과 꺼짐 (초)
zh=Loot：效果关闭 (秒)
ja=Loot：エフェクト消灯 (秒)
it=Loot: dissolvenza in uscita (s)
en=Loot: fade out (s)
nap=Loot: sfummatura 'e scita (s)
bro=Loot: fade out (s)
es=Loot: desvanecimiento de salida (s)
fr=Loot : fondu de sortie (s)
de=Loot: Ausblenden (s)
pt=Loot: esmaecer na saída (s)
ru=Loot: затухание (с)
ko=Loot: 페이드 아웃 (초)
zh=Loot：淡出 (秒)
ja=Loot：フェードアウト (秒)
it=Loot: sfumatura colore (s)
en=Loot: color blend (s)
nap=Loot: sfummatura d'o culore (s)
bro=Loot: sfumatura colore (s)
es=Loot: transición de color (s)
fr=Loot : fondu de couleur (s)
de=Loot: Farbübergang (s)
pt=Loot: transição de cor (s)
ru=Loot: смена цвета (с)
ko=Loot: 색상 전환 (초)
zh=Loot：颜色过渡 (秒)
ja=Loot：色の移行 (秒)
it=Combat: accensione effetti (s)
en=Combat: effects on (s)
nap=Combat: appiccia l'effiette (s)
bro=Combat: effetti on (s)
es=Combat: encendido de efectos (s)
fr=Combat : allumage des effets (s)
de=Combat: Effekte an (s)
pt=Combat: ligar efeitos (s)
ru=Combat: включение эффектов (с)
ko=Combat: 효과 켜짐 (초)
zh=Combat：效果开启 (秒)
ja=Combat：エフェクト点灯 (秒)
it=Combat: spegnimento effetti (s)
en=Combat: effects off (s)
nap=Combat: stuta l'effiette (s)
bro=Combat: effetti off (s)
es=Combat: apagado de efectos (s)
fr=Combat : extinction des effets (s)
de=Combat: Effekte aus (s)
pt=Combat: desligar efeitos (s)
ru=Combat: выключение эффектов (с)
ko=Combat: 효과 꺼짐 (초)
zh=Combat：效果关闭 (秒)
ja=Combat：エフェクト消灯 (秒)
it=Combat: dissolvenza in uscita (s)
en=Combat: fade out (s)
nap=Combat: sfummatura 'e scita (s)
bro=Combat: fade out (s)
es=Combat: desvanecimiento de salida (s)
fr=Combat : fondu de sortie (s)
de=Combat: Ausblenden (s)
pt=Combat: esmaecer na saída (s)
ru=Combat: затухание (с)
ko=Combat: 페이드 아웃 (초)
zh=Combat：淡出 (秒)
ja=Combat：フェードアウト (秒)
it=Combat: sfumatura colore (s)
en=Combat: color blend (s)
nap=Combat: sfummatura d'o culore (s)
bro=Combat: sfumatura colore (s)
es=Combat: transición de color (s)
fr=Combat : fondu de couleur (s)
de=Combat: Farbübergang (s)
pt=Combat: transição de cor (s)
ru=Combat: смена цвета (с)
ko=Combat: 색상 전환 (초)
zh=Combat：颜色过渡 (秒)
ja=Combat：色の移行 (秒)
it=Loot: dissolvenza in entrata
en=Loot: fade in
nap=Loot: sfummatura 'e trasuta
bro=Loot: fade in
es=Loot: desvanecimiento de entrada
fr=Loot : fondu d'entrée
de=Loot: Einblenden
pt=Loot: esmaecer na entrada
ru=Loot: плавное появление
ko=Loot: 페이드 인
zh=Loot：淡入
ja=Loot：フェードイン
it=Loot: dissolvenza in uscita
en=Loot: fade out
nap=Loot: sfummatura 'e scita
bro=Loot: fade out
es=Loot: desvanecimiento de salida
fr=Loot : fondu de sortie
de=Loot: Ausblenden
pt=Loot: esmaecer na saída
ru=Loot: плавное исчезновение
ko=Loot: 페이드 아웃
zh=Loot：淡出
ja=Loot：フェードアウト
it=Combat: dissolvenza in entrata
en=Combat: fade in
nap=Combat: sfummatura 'e trasuta
bro=Combat: fade in
es=Combat: desvanecimiento de entrada
fr=Combat : fondu d'entrée
de=Combat: Einblenden
pt=Combat: esmaecer na entrada
ru=Combat: плавное появление
ko=Combat: 페이드 인
zh=Combat：淡入
ja=Combat：フェードイン
it=Combat: dissolvenza in uscita
en=Combat: fade out
nap=Combat: sfummatura 'e scita
bro=Combat: fade out
es=Combat: desvanecimiento de salida
fr=Combat : fondu de sortie
de=Combat: Ausblenden
pt=Combat: esmaecer na saída
ru=Combat: плавное исчезновение
ko=Combat: 페이드 아웃
zh=Combat：淡出
ja=Combat：フェードアウト
it={1}   (speculare al Loot)
en={1}   (mirrored to the Loot)
nap={1}   (a specchio d'o Loot)
bro={1}   (a specchio del Loot)
es={1}   (reflejado del Loot)
fr={1}   (en miroir du Loot)
de={1}   (gespiegelt zum Loot)
pt={1}   (espelhado ao Loot)
ru={1}   (зеркально к Loot)
ko={1}   (Loot과 대칭)
zh={1}   （与 Loot 镜像）
ja={1}   （Loot と対称）
it=Valore {1} preso dal Loot: è attiva "Icona Combat speculare al Loot".\nPer spostare il Combat a mano disattivala in Icone - generale.
en=Value {1} taken from the Loot: "Combat icon mirrored to the Loot" is on.\nTo move the Combat by hand, turn it off in Icons - general.
nap=Valore {1} pigliato d'o Loot: è appicciata "Icona Combat a specchio d'o Loot".\nPe' movere 'o Combat a mano, stutala dint'a Icone - generale.
bro=Valore {1} preso dal Loot: è on "Icona Combat a specchio del Loot".\nPer muovere il Combat a mano spegnila in Icone - basics.
es=Valor {1} tomado del Loot: está activo "Icono Combat reflejado del Loot".\nPara mover el Combat a mano, desactívalo en Iconos - general.
fr=Valeur {1} reprise du Loot : "Icône Combat en miroir du Loot" est active.\nPour déplacer le Combat à la main, désactive-la dans Icônes - général.
de=Wert {1} vom Loot übernommen: "Combat-Symbol gespiegelt zum Loot" ist an.\nUm das Combat von Hand zu verschieben, schalte es in Symbole - allgemein aus.
pt=Valor {1} tirado do Loot: "Ícone Combat espelhado ao Loot" está ativo.\nPara mover o Combat à mão, desative em Ícones - geral.
ru=Значение {1} берётся из Loot: включено "Combat зеркально к Loot".\nЧтобы двигать Combat вручную, выключите это в разделе Значки - общее.
ko=값 {1}은 Loot에서 가져옵니다: "Combat 아이콘을 Loot과 대칭"이 켜져 있습니다.\nCombat을 직접 옮기려면 아이콘 - 일반에서 끄세요.
zh=值 {1} 取自 Loot：已开启"Combat 图标与 Loot 镜像"。\n要手动移动 Combat，请在 图标 - 通用 中关闭。
ja=値 {1} は Loot から取得：「Combat アイコンを Loot と左右対称」がオンです。\nCombat を手動で動かすには アイコン - 全般 でオフにしてください。
)" "`n"
        s .= "
(
@=IconMirror
en=true = the Combat icon mirrors the Loot: same height, opposite side\n(move the Loot and the Combat follows). false = each icon keeps its own position
nap=true = ll'icona Combat sta a specchio d'o Loot: stessa autezza, parte opposta\n(muove 'o Loot e 'o Combat 'o segue). false = ognuna sta addò 'a miette tu
bro=true = l'icona Combat è a specchio del Loot: stessa altezza, lato opposto\n(muovi il Loot e il Combat lo segue). false = ognuna nella sua posizione
es=true = el icono Combat es el reflejo del Loot: misma altura, lado opuesto\n(mueves el Loot y el Combat lo sigue). false = cada uno en su posición
fr=true = l'icône Combat est le miroir du Loot : même hauteur, côté opposé\n(tu déplaces le Loot et le Combat suit). false = chacune à sa position
de=true = das Combat-Symbol spiegelt das Loot: gleiche Höhe, gegenüberliegende Seite\n(verschiebst du das Loot, folgt das Combat). false = jedes an seiner eigenen Position
pt=true = o ícone Combat espelha o Loot: mesma altura, lado oposto\n(você move o Loot e o Combat acompanha). false = cada um na sua posição
ru=true = значок Combat зеркален Loot: та же высота, противоположная сторона\n(двигаете Loot, Combat следует). false = у каждого своя позиция
ko=true = Combat 아이콘이 Loot과 대칭: 같은 높이, 반대쪽\n(Loot를 옮기면 Combat이 따라옴). false = 각자 자기 위치
zh=true = Combat 图标与 Loot 镜像：高度相同，位于另一侧\n（移动 Loot，Combat 跟随）。false = 各自独立位置
ja=true = Combat アイコンが Loot と左右対称：同じ高さで反対側\n（Loot を動かすと Combat が追従）。false = それぞれ独自の位置
@=LootSize CombatSize
en=icon size: height of the shape (px)
nap=grandezza 'e ll'icona: autezza d'a forma (px)
bro=size dell'icona: altezza della forma (px)
es=tamaño del icono: altura de la forma (px)
fr=taille de l'icône : hauteur de la forme (px)
de=Symbolgröße: Höhe der Form (px)
pt=tamanho do ícone: altura da forma (px)
ru=размер значка: высота фигуры (px)
ko=아이콘 크기: 도형의 높이 (px)
zh=图标大小：形状的高度 (px)
ja=アイコンサイズ：形の高さ (px)
@=CombatOffsetX
en=position from the screen center (px). Used only with IconMirror := false
nap=pusizione a partì d'o centro d'o schermo (px). Serve sulo cu IconMirror := false
bro=posizione rispetto al centro dello schermo (px). Conta solo con IconMirror := false
es=posición respecto al centro de la pantalla (px). Solo se usa con IconMirror := false
fr=position par rapport au centre de l'écran (px). Utilisée seulement avec IconMirror := false
de=Position relativ zur Bildschirmmitte (px). Nur bei IconMirror := false verwendet
pt=posição em relação ao centro da tela (px). Usada só com IconMirror := false
ru=позиция от центра экрана (px). Используется только при IconMirror := false
ko=화면 중앙 기준 위치 (px). IconMirror := false일 때만 사용
zh=相对屏幕中心的位置 (px)。仅在 IconMirror := false 时使用
ja=画面中央からの位置 (px)。IconMirror := false のときだけ使用
@=CombatOffsetY
en=(px, + = lower). Used only with IconMirror := false
nap=(px, + = cchiù abbascio). Serve sulo cu IconMirror := false
bro=(px, + = più in basso). Conta solo con IconMirror := false
es=(px, + = más abajo). Solo se usa con IconMirror := false
fr=(px, + = plus bas). Utilisée seulement avec IconMirror := false
de=(px, + = weiter unten). Nur bei IconMirror := false verwendet
pt=(px, + = mais para baixo). Usada só com IconMirror := false
ru=(px, + = ниже). Используется только при IconMirror := false
ko=(px, + = 더 아래). IconMirror := false일 때만 사용
zh=(px，+ = 更靠下)。仅在 IconMirror := false 时使用
ja=(px、+ = 下へ)。IconMirror := false のときだけ使用
@=EnableLootFadeIn EnableLootFadeOut
en=Loot icon
nap=icona Loot
bro=icona Loot
es=icono Loot
fr=icône Loot
de=Loot-Symbol
pt=ícone Loot
ru=значок Loot
ko=Loot 아이콘
zh=Loot 图标
ja=Loot アイコン
@=EnableCombatFadeIn EnableCombatFadeOut
en=Combat icon
nap=icona Combat
bro=icona Combat
es=icono Combat
fr=icône Combat
de=Combat-Symbol
pt=ícone Combat
ru=значок Combat
ko=Combat 아이콘
zh=Combat 图标
ja=Combat アイコン
@=FieldBossHideInDungeon
en=true = in dungeons (map without the Exploration / Map Pin tabs, or with a dungeon\nname in the title) the boss panel does not appear
nap=true = dint'e dungeon (mappa senza 'e tab Exploration / Map Pin, o cu 'o nomme 'e nu dungeon\nint'o titolo) 'o pannello d'e boss nun esce
bro=true = nei dungeon (mappa senza i tab Exploration / Map Pin, o con il nome di un dungeon\nnel titolo) il pannello dei boss non spunta
es=true = en las mazmorras (mapa sin las pestañas Exploration / Map Pin, o con el nombre de una mazmorra\nen el título) el panel de jefes no aparece
fr=true = dans les donjons (carte sans les onglets Exploration / Map Pin, ou avec un nom de donjon\ndans le titre) le panneau des boss n'apparaît pas
de=true = in Dungeons (Karte ohne die Tabs Exploration / Map Pin oder mit einem Dungeon-Namen\nim Titel) erscheint das Boss-Panel nicht
pt=true = nas masmorras (mapa sem as abas Exploration / Map Pin, ou com o nome de uma masmorra\nno título) o painel de chefes não aparece
ru=true = в подземельях (карта без вкладок Exploration / Map Pin или с названием подземелья\nв заголовке) панель боссов не появляется
ko=true = 던전에서는 (Exploration / Map Pin 탭이 없는 지도이거나 제목에 던전\n이름이 있으면) 보스 패널이 나타나지 않습니다
zh=true = 在副本中（地图没有 Exploration / Map Pin 标签，或标题中有副本\n名称）不显示首领面板
ja=true = ダンジョンでは（Exploration / Map Pin タブがないマップ、またはタイトルに\nダンジョン名があるマップ）ボスパネルを表示しません
@=FieldBossDungeons
en=dungeon names (as in the "Map: ..." title), separated by |.\nThe beginning of the name is enough. Add new dungeons here.
nap=nomme d'e dungeon (comme int'o titolo "Map: ..."), spartute cu |.\nAbbasta 'o principio d'o nomme. Miette ccà 'e dungeon nuove.
bro=nomi dei dungeon (come nel titolo "Map: ..."), separati da |.\nBasta l'inizio del nome. Aggiungi qui i dungeon nuovi.
es=nombres de las mazmorras (como en el título "Map: ..."), separados por |.\nBasta el comienzo del nombre. Añade aquí las mazmorras nuevas.
fr=noms des donjons (comme dans le titre "Map: ..."), séparés par |.\nLe début du nom suffit. Ajoute ici les nouveaux donjons.
de=Dungeon-Namen (wie im Titel "Map: ..."), getrennt durch |.\nDer Anfang des Namens reicht. Neue Dungeons hier ergänzen.
pt=nomes das masmorras (como no título "Map: ..."), separados por |.\nBasta o começo do nome. Adicione aqui as masmorras novas.
ru=названия подземелий (как в заголовке "Map: ..."), через |.\nДостаточно начала названия. Новые подземелья добавляйте сюда.
ko=던전 이름 ("Map: ..." 제목과 동일), | 로 구분.\n이름의 앞부분만 있어도 됩니다. 새 던전은 여기에 추가하세요.
zh=副本名称（与 "Map: ..." 标题一致），用 | 分隔。\n写出名称开头即可。新副本请添加在这里。
ja=ダンジョン名（「Map: ...」のタイトルと同じ）、| で区切ります。\n名前の先頭だけで十分です。新しいダンジョンはここに追加してください。
it=Editor temi
en=Theme editor
nap=Editor d'e teme
bro=Theme editor
es=Editor de temas
fr=Éditeur de thèmes
de=Design-Editor
pt=Editor de temas
ru=Редактор тем
ko=테마 편집기
zh=主题编辑器
ja=テーマエディター
it=Colori di tutta la suite. I temi pronti non si modificano: per crearne uno tuo partendo da un tema qualsiasi usa Editor temi.
en=Colors of the whole app. Ready-made themes never change: to create your own starting from any theme, use Theme editor.
nap=Culure 'e tutta 'a suite. 'E teme pronte nun se toccano: pe' te ne fà uno tujo partenno 'a nu tema qualsiasi usa Editor d'e teme.
bro=Colori di tutta l'app. I temi pronti non si toccano: per farti il tuo partendo da un tema qualsiasi usa il Theme editor.
es=Colores de toda la app. Los temas listos no cambian: para crear el tuyo a partir de cualquier tema usa el Editor de temas.
fr=Couleurs de toute l'application. Les thèmes prêts ne changent jamais : pour créer le tien à partir de n'importe quel thème, utilise l'Éditeur de thèmes.
de=Farben der ganzen App. Fertige Designs ändern sich nie: Um ausgehend von einem beliebigen Design dein eigenes zu erstellen, nutze den Design-Editor.
pt=Cores de todo o app. Os temas prontos nunca mudam: para criar o seu a partir de qualquer tema, use o Editor de temas.
ru=Цвета всего приложения. Готовые темы не меняются: чтобы создать свою на основе любой темы, используйте Редактор тем.
ko=앱 전체의 색상. 기본 테마는 바뀌지 않습니다. 아무 테마에서 시작해 나만의 테마를 만들려면 테마 편집기를 쓰세요.
zh=整个应用的颜色。预设主题不会改变：想以任意主题为基础制作自己的主题，请使用主题编辑器。
ja=アプリ全体の色。既成テーマは変わりません。好きなテーマから自分のテーマを作るにはテーマエディターを使います。
)" "`n"
        s .= "
(
it=I temi pronti restano sempre uguali. Scegli un tema e premi "Personalizza questo tema": diventa il tuo tema personalizzato, modificabile in ogni dettaglio. Poi salvalo con un nome.
en=Ready-made themes always stay the same. Pick a theme and press "Customize this theme": it becomes your custom theme, editable in every detail. Then save it with a name.
nap='E teme pronte restano sempe uguale. Sceglie nu tema e premme "Personalizza stu tema": addeventa 'o tema tujo, ca può cagnà int'a ogni cosa. Po' salvalo cu nu nomme.
bro=I temi pronti restano sempre uguali. Scegli un tema e premi "Personalizza sto tema": diventa il tuo tema custom, modificabile in ogni dettaglio. Poi salvalo con un nome, ez.
es=Los temas listos siempre se quedan igual. Elige un tema y pulsa "Personalizar este tema": se convierte en tu tema personalizado, editable en cada detalle. Luego guárdalo con un nombre.
fr=Les thèmes prêts restent toujours identiques. Choisis un thème et appuie sur "Personnaliser ce thème" : il devient ton thème personnalisé, modifiable dans les moindres détails. Puis enregistre-le avec un nom.
de=Fertige Designs bleiben immer gleich. Wähle ein Design und drücke "Dieses Design anpassen": Es wird zu deinem eigenen Design, in jedem Detail änderbar. Speichere es dann unter einem Namen.
pt=Os temas prontos ficam sempre iguais. Escolha um tema e aperte "Personalizar este tema": ele vira o seu tema personalizado, editável em cada detalhe. Depois salve com um nome.
ru=Готовые темы всегда остаются прежними. Выберите тему и нажмите "Настроить эту тему": она станет вашей темой, которую можно менять до мелочей. Затем сохраните её под именем.
ko=기본 테마는 항상 그대로입니다. 테마를 고르고 "이 테마 꾸미기"를 누르면 모든 부분을 바꿀 수 있는 내 테마가 됩니다. 그다음 이름을 붙여 저장하세요.
zh=预设主题始终不变。选择一个主题并点击"自定义此主题"：它会成为你的自定义主题，每个细节都能修改。然后为它命名保存。
ja=既成テーマはいつも同じままです。テーマを選んで「このテーマをカスタマイズ」を押すと、細部まで変更できる自分のテーマになります。最後に名前を付けて保存します。
it=Usa questo tema
en=Use this theme
nap=Usa stu tema
bro=Usa sto tema
es=Usar este tema
fr=Utiliser ce thème
de=Dieses Design verwenden
pt=Usar este tema
ru=Использовать тему
ko=이 테마 사용
zh=使用此主题
ja=このテーマを使う
it=Personalizza questo tema
en=Customize this theme
nap=Personalizza stu tema
bro=Personalizza sto tema
es=Personalizar este tema
fr=Personnaliser ce thème
de=Dieses Design anpassen
pt=Personalizar este tema
ru=Настроить эту тему
ko=이 테마 꾸미기
zh=自定义此主题
ja=このテーマをカスタマイズ
it=Salva il tema attuale con nome...
en=Save the current theme as...
nap=Salva 'o tema 'e mo cu nu nomme...
bro=Salva il tema attuale con un nome...
es=Guardar el tema actual con nombre...
fr=Enregistrer le thème actuel sous...
de=Aktuelles Design speichern unter...
pt=Salvar o tema atual com nome...
ru=Сохранить текущую тему как...
ko=현재 테마를 이름 지정해 저장...
zh=将当前主题另存为...
ja=現在のテーマに名前を付けて保存...
it=Elimina tema
en=Delete theme
nap=Scancella tema
bro=Elimina tema
es=Eliminar tema
fr=Supprimer le thème
de=Design löschen
pt=Excluir tema
ru=Удалить тему
ko=테마 삭제
zh=删除主题
ja=テーマを削除
it=In modifica
en=Being edited
nap=Int'a modifica
bro=In editing
es=En edición
fr=En cours de modification
de=In Bearbeitung
pt=Em edição
ru=Редактируется
ko=편집 중
zh=编辑中
ja=編集中
it=Evento
en=Event
nap=Evento
bro=Evento
es=Evento
fr=Événement
de=Event
pt=Evento
ru=Праздник
ko=이벤트
zh=节日
ja=イベント
it=Classe
en=Class
nap=Classe
bro=Classe
es=Clase
fr=Classe
de=Klasse
pt=Classe
ru=Класс
ko=클래스
zh=职业
ja=クラス
it=in uso
en=in use
nap=se sta usanno
bro=in uso
es=en uso
fr=utilisé
de=aktiv
pt=em uso
ru=используется
ko=사용 중
zh=使用中
ja=使用中
it=1. Scegli un tema e premi "Personalizza questo tema": i suoi colori, forme, effetti ed emoji vengono copiati nel tema "custom".\n2. Cambia quello che vuoi: colori dei pannelli in Tema, colori dell'HUD in HUD overlay > Colori ed Effetti, forme ed emoji in Mirino e Icone.\n3. Torna qui e premi "Salva il tema attuale con nome...". Per modificarlo ancora: selezionalo, Personalizza e salvalo con lo stesso nome.
en=1. Pick a theme and press "Customize this theme": its colors, shapes, effects and emoji are copied into the "custom" theme.\n2. Change whatever you like: panel colors in Theme, HUD colors in HUD overlay > Colors and Effects, shapes and emoji in Crosshair and Icons.\n3. Come back here and press "Save the current theme as...". To edit it again: select it, Customize and save it with the same name.
nap=1. Sceglie nu tema e premme "Personalizza stu tema": culure, forme, effiette ed emoji vanno int'o tema "custom".\n2. Cagna chello ca vuò: culure d'e pannelle int'o Tema, culure 'e ll'HUD int'a HUD overlay > Culure ed Effiette, forme ed emoji int'o Mirino e int'e Icone.\n3. Torna ccà e premme "Salva 'o tema 'e mo cu nu nomme...". Pe' 'o cagnà n'ata vota: sceglielo, Personalizza e salvalo cu 'o stesso nomme.
bro=1. Scegli un tema e premi "Personalizza sto tema": colori, forme, effetti ed emoji finiscono nel tema "custom".\n2. Cambia quello che vuoi: colori dei pannelli in Tema, colori dell'HUD in HUD overlay > Colori ed Effetti, forme ed emoji in Mirino e Icone.\n3. Torna qui e premi "Salva il tema attuale con un nome...". Per ritoccarlo: selezionalo, Personalizza e salvalo con lo stesso nome.
es=1. Elige un tema y pulsa "Personalizar este tema": sus colores, formas, efectos y emoji se copian al tema "custom".\n2. Cambia lo que quieras: colores de los paneles en Tema, colores del HUD en HUD overlay > Colores y Efectos, formas y emoji en Mira e Iconos.\n3. Vuelve aquí y pulsa "Guardar el tema actual con nombre...". Para editarlo otra vez: selecciónalo, Personalizar y guárdalo con el mismo nombre.
fr=1. Choisis un thème et appuie sur "Personnaliser ce thème" : ses couleurs, formes, effets et emoji sont copiés dans le thème "custom".\n2. Change ce que tu veux : couleurs des panneaux dans Thème, couleurs du HUD dans HUD overlay > Couleurs et Effets, formes et emoji dans Viseur et Icônes.\n3. Reviens ici et appuie sur "Enregistrer le thème actuel sous...". Pour le modifier encore : sélectionne-le, Personnaliser et enregistre-le sous le même nom.
de=1. Wähle ein Design und drücke "Dieses Design anpassen": Farben, Formen, Effekte und Emoji werden ins Design "custom" kopiert.\n2. Ändere, was du willst: Panelfarben unter Design, HUD-Farben unter HUD overlay > Farben und Effekte, Formen und Emoji unter Fadenkreuz und Symbole.\n3. Komm hierher zurück und drücke "Aktuelles Design speichern unter...". Zum erneuten Bearbeiten: auswählen, Anpassen und unter demselben Namen speichern.
pt=1. Escolha um tema e aperte "Personalizar este tema": cores, formas, efeitos e emoji dele são copiados para o tema "custom".\n2. Mude o que quiser: cores dos painéis em Tema, cores do HUD em HUD overlay > Cores e Efeitos, formas e emoji em Mira e Ícones.\n3. Volte aqui e aperte "Salvar o tema atual com nome...". Para editar de novo: selecione, Personalizar e salve com o mesmo nome.
ru=1. Выберите тему и нажмите "Настроить эту тему": её цвета, формы, эффекты и эмодзи копируются в тему "custom".\n2. Меняйте что угодно: цвета панелей в разделе Тема, цвета HUD в HUD overlay > Цвета и Эффекты, формы и эмодзи в Прицел и Значки.\n3. Вернитесь сюда и нажмите "Сохранить текущую тему как...". Чтобы изменить снова: выберите её, Настроить и сохраните под тем же именем.
ko=1. 테마를 고르고 "이 테마 꾸미기"를 누르면 색상, 모양, 효과, 이모지가 "custom" 테마로 복사됩니다.\n2. 원하는 대로 바꾸세요: 패널 색상은 테마, HUD 색상은 HUD overlay > 색상과 효과, 모양과 이모지는 조준선과 아이콘에서.\n3. 여기로 돌아와 "현재 테마를 이름 지정해 저장..."을 누르세요. 다시 고치려면 선택하고 꾸미기를 누른 뒤 같은 이름으로 저장하세요.
zh=1. 选择一个主题并点击"自定义此主题"：它的颜色、形状、效果和表情会复制到 "custom" 主题。\n2. 随意修改：面板颜色在 主题，HUD 颜色在 HUD overlay > 颜色 和 效果，形状和表情在 准星 和 图标。\n3. 回到这里点击"将当前主题另存为..."。要再次修改：选中它，点自定义，再用同一名称保存。
ja=1. テーマを選んで「このテーマをカスタマイズ」を押すと、色・形・エフェクト・絵文字が "custom" テーマにコピーされます。\n2. 好きなように変更：パネルの色は テーマ、HUD の色は HUD overlay > 色 と エフェクト、形と絵文字は 照準 と アイコン で。\n3. ここに戻って「現在のテーマに名前を付けて保存...」を押します。再編集するには：選んで カスタマイズ し、同じ名前で保存します。
)" "`n"
        s .= "
(
it=Il tema "custom" ora è una copia di "{1}": cambia quello che vuoi nelle impostazioni, poi torna in Editor temi e salvalo con un nome.
en=The "custom" theme is now a copy of "{1}": change whatever you like in the settings, then go back to Theme editor and save it with a name.
nap='O tema "custom" mo è na copia 'e "{1}": cagna chello ca vuò int'e mpustaziune, po' torna int'a Editor d'e teme e salvalo cu nu nomme.
bro=Il tema "custom" ora è una copia di "{1}": cambia quello che vuoi nei settaggi, poi torna nel Theme editor e salvalo con un nome.
es=El tema "custom" ahora es una copia de "{1}": cambia lo que quieras en los ajustes, luego vuelve al Editor de temas y guárdalo con un nombre.
fr=Le thème "custom" est maintenant une copie de "{1}" : change ce que tu veux dans les paramètres, puis reviens dans l'Éditeur de thèmes et enregistre-le avec un nom.
de=Das Design "custom" ist jetzt eine Kopie von "{1}": Ändere in den Einstellungen, was du willst, dann geh zurück zum Design-Editor und speichere es unter einem Namen.
pt=O tema "custom" agora é uma cópia de "{1}": mude o que quiser nas configurações, depois volte ao Editor de temas e salve com um nome.
ru=Тема "custom" теперь копия "{1}": меняйте в настройках что угодно, затем вернитесь в Редактор тем и сохраните её под именем.
ko="custom" 테마가 이제 "{1}"의 복사본입니다. 설정에서 원하는 대로 바꾼 뒤 테마 편집기로 돌아와 이름을 붙여 저장하세요.
zh="custom" 主题现在是 "{1}" 的副本：在设置中随意修改，然后回到主题编辑器为它命名保存。
ja="custom" テーマは "{1}" のコピーになりました。設定で自由に変更し、テーマエディターに戻って名前を付けて保存してください。
it=Nome del tema (es. "Il mio tema"):
en=Theme name (e.g. "My theme"):
nap=Nomme d'o tema (p. es. "'O tema mio"):
bro=Nome del tema (tipo "Il mio tema"):
es=Nombre del tema (p. ej. "Mi tema"):
fr=Nom du thème (ex. "Mon thème") :
de=Name des Designs (z. B. "Mein Design"):
pt=Nome do tema (ex. "Meu tema"):
ru=Название темы (например, "Моя тема"):
ko=테마 이름 (예: "내 테마"):
zh=主题名称（例如 "我的主题"）：
ja=テーマ名（例："マイテーマ"）：
it=Questo nome è già usato da un tema predefinito.
en=This name is already used by a built-in theme.
nap=Stu nomme ce l'ha già nu tema predefinito.
bro=Sto nome ce l'ha già un tema predefinito.
es=Este nombre ya lo usa un tema predefinido.
fr=Ce nom est déjà utilisé par un thème prédéfini.
de=Dieser Name wird bereits von einem fertigen Design verwendet.
pt=Este nome já é usado por um tema predefinido.
ru=Это имя уже занято встроенной темой.
ko=이 이름은 이미 기본 테마가 쓰고 있습니다.
zh=此名称已被预设主题使用。
ja=この名前は既成テーマで使われています。
it=Esiste già un tema "{1}". Sovrascriverlo?
en=A theme "{1}" already exists. Overwrite it?
nap=Ce sta già nu tema "{1}". 'O scrivimmo 'ncoppa?
bro=C'è già un tema "{1}". Lo sovrascrivo?
es=Ya existe un tema "{1}". ¿Sobrescribirlo?
fr=Un thème "{1}" existe déjà. L'écraser ?
de=Ein Design "{1}" existiert bereits. Überschreiben?
pt=Já existe um tema "{1}". Sobrescrever?
ru=Тема "{1}" уже существует. Перезаписать?
ko="{1}" 테마가 이미 있습니다. 덮어쓸까요?
zh=已存在主题 "{1}"。要覆盖吗？
ja=テーマ "{1}" は既にあります。上書きしますか？
it=Salvataggio del tema non riuscito:
en=Could not save the theme:
nap=Nun se pò salvà 'o tema:
bro=Salvataggio del tema fallito:
es=No se pudo guardar el tema:
fr=Impossible d'enregistrer le thème :
de=Design konnte nicht gespeichert werden:
pt=Não foi possível salvar o tema:
ru=Не удалось сохранить тему:
ko=테마를 저장하지 못했습니다:
zh=无法保存主题：
ja=テーマを保存できませんでした：
it=I temi predefiniti non si possono eliminare.
en=Built-in themes cannot be deleted.
nap='E teme predefinite nun se ponno scancellà.
bro=I temi predefiniti non si possono eliminare, sorry.
es=Los temas predefinidos no se pueden eliminar.
fr=Les thèmes prédéfinis ne peuvent pas être supprimés.
de=Fertige Designs können nicht gelöscht werden.
pt=Os temas predefinidos não podem ser excluídos.
ru=Встроенные темы удалить нельзя.
ko=기본 테마는 삭제할 수 없습니다.
zh=预设主题无法删除。
ja=既成テーマは削除できません。
it=Eliminare il tema "{1}"?
en=Delete the theme "{1}"?
nap=Scancellammo 'o tema "{1}"?
bro=Elimino il tema "{1}"?
es=¿Eliminar el tema "{1}"?
fr=Supprimer le thème "{1}" ?
de=Design "{1}" löschen?
pt=Excluir o tema "{1}"?
ru=Удалить тему "{1}"?
ko="{1}" 테마를 삭제할까요?
zh=删除主题 "{1}"？
ja=テーマ "{1}" を削除しますか？
it={1}   (tema)
en={1}   (theme)
nap={1}   (tema)
bro={1}   (tema)
es={1}   (tema)
fr={1}   (thème)
de={1}   (Design)
pt={1}   (tema)
ru={1}   (тема)
ko={1}   (테마)
zh={1}   （主题）
ja={1}   （テーマ）
it=Valore {1} deciso dal tema "{2}".\nPer cambiarlo: Editor temi > "Personalizza questo tema".
en=Value {1} set by the theme "{2}".\nTo change it: Theme editor > "Customize this theme".
nap=Valore {1} deciso d'o tema "{2}".\nPe' 'o cagnà: Editor d'e teme > "Personalizza stu tema".
bro=Valore {1} deciso dal tema "{2}".\nPer cambiarlo: Theme editor > "Personalizza sto tema".
es=Valor {1} fijado por el tema "{2}".\nPara cambiarlo: Editor de temas > "Personalizar este tema".
fr=Valeur {1} imposée par le thème "{2}".\nPour la changer : Éditeur de thèmes > "Personnaliser ce thème".
de=Wert {1} vom Design "{2}" festgelegt.\nZum Ändern: Design-Editor > "Dieses Design anpassen".
pt=Valor {1} definido pelo tema "{2}".\nPara mudar: Editor de temas > "Personalizar este tema".
ru=Значение {1} задано темой "{2}".\nЧтобы изменить: Редактор тем > "Настроить эту тему".
ko=값 {1}은 "{2}" 테마가 정합니다.\n바꾸려면: 테마 편집기 > "이 테마 꾸미기".
zh=值 {1} 由主题 "{2}" 决定。\n要修改：主题编辑器 > "自定义此主题"。
ja=値 {1} はテーマ "{2}" で決まります。\n変更するには：テーマエディター > 「このテーマをカスタマイズ」。
it=I temi pronti restano sempre uguali. Scegli un tema e premi "Personalizza questo tema": viene creato un tuo tema con lo stesso nome più "Custom", modificabile in ogni dettaglio.
en=Ready-made themes always stay the same. Pick a theme and press "Customize this theme": a theme of yours is created with the same name plus "Custom", editable in every detail.
nap='E teme pronte restano sempe uguale. Sceglie nu tema e premme "Personalizza stu tema": nasce nu tema tujo cu 'o stesso nomme cchiù "Custom", ca può cagnà int'a ogni cosa.
bro=I temi pronti restano sempre uguali. Scegli un tema e premi "Personalizza sto tema": nasce un tema tuo con lo stesso nome + "Custom", modificabile in ogni dettaglio.
es=Los temas listos siempre se quedan igual. Elige un tema y pulsa "Personalizar este tema": se crea un tema tuyo con el mismo nombre más "Custom", editable en cada detalle.
fr=Les thèmes prêts restent toujours identiques. Choisis un thème et appuie sur "Personnaliser ce thème" : un thème à toi est créé avec le même nom suivi de "Custom", modifiable dans les moindres détails.
de=Fertige Designs bleiben immer gleich. Wähle ein Design und drücke "Dieses Design anpassen": Es entsteht dein eigenes Design mit demselben Namen plus "Custom", in jedem Detail änderbar.
pt=Os temas prontos ficam sempre iguais. Escolha um tema e aperte "Personalizar este tema": é criado um tema seu com o mesmo nome mais "Custom", editável em cada detalhe.
ru=Готовые темы всегда остаются прежними. Выберите тему и нажмите "Настроить эту тему": будет создана ваша тема с тем же именем и словом "Custom", которую можно менять до мелочей.
ko=기본 테마는 항상 그대로입니다. 테마를 고르고 "이 테마 꾸미기"를 누르면 같은 이름에 "Custom"이 붙은 내 테마가 만들어지고, 모든 부분을 바꿀 수 있습니다.
zh=预设主题始终不变。选择一个主题并点击"自定义此主题"：会创建一个同名加 "Custom" 的你的主题，每个细节都能修改。
ja=既成テーマはいつも同じままです。テーマを選んで「このテーマをカスタマイズ」を押すと、同じ名前に "Custom" が付いた自分のテーマが作られ、細部まで変更できます。
)" "`n"
        s .= "
(
it=1. Scegli un tema e premi "Personalizza questo tema": nasce "(nome) Custom" con i suoi colori, forme, effetti ed emoji, già in uso.\n2. Cambia quello che vuoi: colori dei pannelli in Tema, colori dell'HUD in HUD overlay > Colori ed Effetti, forme ed emoji in Mirino e Icone.\n3. "Salva e riavvia" salva le modifiche anche nel tuo tema. Con "Salva il tema attuale con nome..." ne fai una copia con un altro nome.
en=1. Pick a theme and press "Customize this theme": "(name) Custom" is created with its colors, shapes, effects and emoji, already in use.\n2. Change whatever you like: panel colors in Theme, HUD colors in HUD overlay > Colors and Effects, shapes and emoji in Crosshair and Icons.\n3. "Save and restart" also saves the changes into your theme. With "Save the current theme as..." you make a copy with another name.
nap=1. Sceglie nu tema e premme "Personalizza stu tema": nasce "(nomme) Custom" cu culure, forme, effiette ed emoji suoje, già in uso.\n2. Cagna chello ca vuò: culure d'e pannelle int'o Tema, culure 'e ll'HUD int'a HUD overlay > Culure ed Effiette, forme ed emoji int'o Mirino e int'e Icone.\n3. "Salva e riavvia" salva 'e cagnamiente pure int'o tema tujo. Cu "Salva 'o tema 'e mo cu nu nomme..." ne faje na copia cu n'atu nomme.
bro=1. Scegli un tema e premi "Personalizza sto tema": nasce "(nome) Custom" con colori, forme, effetti ed emoji suoi, già in uso.\n2. Cambia quello che vuoi: colori dei pannelli in Tema, colori dell'HUD in HUD overlay > Colori ed Effetti, forme ed emoji in Mirino e Icone.\n3. "Salva e riavvia" salva le modifiche anche nel tuo tema. Con "Salva il tema attuale con un nome..." ne fai una copia con un altro nome.
es=1. Elige un tema y pulsa "Personalizar este tema": se crea "(nombre) Custom" con sus colores, formas, efectos y emoji, ya en uso.\n2. Cambia lo que quieras: colores de los paneles en Tema, colores del HUD en HUD overlay > Colores y Efectos, formas y emoji en Mira e Iconos.\n3. "Guardar y reiniciar" guarda los cambios también en tu tema. Con "Guardar el tema actual con nombre..." haces una copia con otro nombre.
fr=1. Choisis un thème et appuie sur "Personnaliser ce thème" : "(nom) Custom" est créé avec ses couleurs, formes, effets et emoji, déjà utilisé.\n2. Change ce que tu veux : couleurs des panneaux dans Thème, couleurs du HUD dans HUD overlay > Couleurs et Effets, formes et emoji dans Viseur et Icônes.\n3. "Sauver et relancer" enregistre aussi les modifications dans ton thème. Avec "Enregistrer le thème actuel sous..." tu en fais une copie sous un autre nom.
de=1. Wähle ein Design und drücke "Dieses Design anpassen": "(Name) Custom" entsteht mit seinen Farben, Formen, Effekten und Emoji und ist sofort aktiv.\n2. Ändere, was du willst: Panelfarben unter Design, HUD-Farben unter HUD overlay > Farben und Effekte, Formen und Emoji unter Fadenkreuz und Symbole.\n3. "Speichern+Neustart" speichert die Änderungen auch in deinem Design. Mit "Aktuelles Design speichern unter..." machst du eine Kopie mit anderem Namen.
pt=1. Escolha um tema e aperte "Personalizar este tema": nasce "(nome) Custom" com cores, formas, efeitos e emoji dele, já em uso.\n2. Mude o que quiser: cores dos painéis em Tema, cores do HUD em HUD overlay > Cores e Efeitos, formas e emoji em Mira e Ícones.\n3. "Salvar e reiniciar" salva as mudanças também no seu tema. Com "Salvar o tema atual com nome..." você faz uma cópia com outro nome.
ru=1. Выберите тему и нажмите "Настроить эту тему": появится "(имя) Custom" с её цветами, формами, эффектами и эмодзи, сразу включённая.\n2. Меняйте что угодно: цвета панелей в разделе Тема, цвета HUD в HUD overlay > Цвета и Эффекты, формы и эмодзи в Прицел и Значки.\n3. "Сохр. и рестарт" сохраняет изменения и в вашу тему. "Сохранить текущую тему как..." делает копию под другим именем.
ko=1. 테마를 고르고 "이 테마 꾸미기"를 누르면 색상, 모양, 효과, 이모지를 그대로 가진 "(이름) Custom"이 만들어져 바로 적용됩니다.\n2. 원하는 대로 바꾸세요: 패널 색상은 테마, HUD 색상은 HUD overlay > 색상과 효과, 모양과 이모지는 조준선과 아이콘에서.\n3. "저장 후 재시작"을 누르면 변경 사항이 내 테마에도 저장됩니다. "현재 테마를 이름 지정해 저장..."으로 다른 이름의 복사본을 만들 수 있습니다.
zh=1. 选择一个主题并点击"自定义此主题"：会生成带有其颜色、形状、效果和表情的 "(名称) Custom"，并立即使用。\n2. 随意修改：面板颜色在 主题，HUD 颜色在 HUD overlay > 颜色 和 效果，形状和表情在 准星 和 图标。\n3. "保存并重启"会把修改也保存到你的主题。用"将当前主题另存为..."可另存为其他名称的副本。
ja=1. テーマを選んで「このテーマをカスタマイズ」を押すと、色・形・エフェクト・絵文字を受け継いだ "(名前) Custom" が作られ、すぐ使用されます。\n2. 好きなように変更：パネルの色は テーマ、HUD の色は HUD overlay > 色 と エフェクト、形と絵文字は 照準 と アイコン で。\n3. 「保存して再起動」で変更が自分のテーマにも保存されます。「現在のテーマに名前を付けて保存...」で別名のコピーを作れます。
it=Creato il tema "{1}", copia di "{2}", ed è già in uso.\nOra puoi cambiare ogni dettaglio nelle impostazioni: con "Salva e riavvia" le modifiche vengono salvate anche nel tema.
en=Created the theme "{1}", a copy of "{2}", and it is already in use.\nNow you can change every detail in the settings: "Save and restart" also saves the changes into the theme.
nap=Fatto 'o tema "{1}", copia 'e "{2}", e già se sta usanno.\nMo può cagnà ogni cosa int'e mpustaziune: cu "Salva e riavvia" 'e cagnamiente se salvano pure int'o tema.
bro=Creato il tema "{1}", copia di "{2}", ed è già on.\nOra puoi cambiare ogni dettaglio nei settaggi: con "Salva e riavvia" le modifiche finiscono anche nel tema.
es=Creado el tema "{1}", copia de "{2}", y ya está en uso.\nAhora puedes cambiar cada detalle en los ajustes: con "Guardar y reiniciar" los cambios se guardan también en el tema.
fr=Thème "{1}" créé, copie de "{2}", et déjà utilisé.\nTu peux maintenant changer chaque détail dans les paramètres : "Sauver et relancer" enregistre aussi les modifications dans le thème.
de=Design "{1}" erstellt, eine Kopie von "{2}", und bereits aktiv.\nJetzt kannst du in den Einstellungen jedes Detail ändern: "Speichern+Neustart" speichert die Änderungen auch im Design.
pt=Tema "{1}" criado, cópia de "{2}", e já em uso.\nAgora você pode mudar cada detalhe nas configurações: com "Salvar e reiniciar" as mudanças também são salvas no tema.
ru=Создана тема "{1}" (копия "{2}"), она уже используется.\nТеперь меняйте в настройках любые детали: "Сохр. и рестарт" сохраняет изменения и в тему.
ko="{2}"의 복사본인 "{1}" 테마를 만들어 바로 적용했습니다.\n이제 설정에서 모든 부분을 바꿀 수 있습니다. "저장 후 재시작"을 누르면 변경 사항이 테마에도 저장됩니다.
zh=已创建主题 "{1}"（"{2}" 的副本），并已在使用。\n现在可以在设置中修改每个细节："保存并重启"会把修改也保存到该主题。
ja=テーマ "{1}"（"{2}" のコピー）を作成し、使用中にしました。\n設定で細部まで変更できます。「保存して再起動」で変更がテーマにも保存されます。
it=Aggiornamenti
en=Updates
nap=Aggiornamente
bro=Update
es=Actualizaciones
fr=Mises à jour
de=Updates
pt=Atualizações
ru=Обновления
ko=업데이트
zh=更新
ja=アップデート
it=Controllo e installazione delle nuove versioni pubblicate su GitHub. Le tue impostazioni restano dopo ogni aggiornamento.
en=Checking and installing new versions published on GitHub. Your settings stay after every update.
nap=Controllo e installazione d'e verziune nove pubblicate ncopp'a GitHub. 'E mpustaziune toje restano doppo ogni aggiornamento.
bro=Check e install delle nuove versioni su GitHub. I tuoi settaggi restano dopo ogni update.
es=Comprobación e instalación de las nuevas versiones publicadas en GitHub. Tus ajustes se mantienen tras cada actualización.
fr=Vérification et installation des nouvelles versions publiées sur GitHub. Tes paramètres restent après chaque mise à jour.
de=Prüfen und Installieren neuer Versionen von GitHub. Deine Einstellungen bleiben bei jedem Update erhalten.
pt=Verificação e instalação das novas versões publicadas no GitHub. Suas configurações ficam após cada atualização.
ru=Проверка и установка новых версий, опубликованных на GitHub. Ваши настройки сохраняются после каждого обновления.
ko=GitHub에 올라온 새 버전을 확인하고 설치합니다. 업데이트 후에도 설정은 그대로 유지됩니다.
zh=检查并安装发布在 GitHub 上的新版本。每次更新后你的设置都会保留。
ja=GitHub で公開された新バージョンを確認・インストールします。アップデート後も設定はそのまま残ります。
it=Aggiornamenti automatici
en=Automatic updates
nap=Aggiornamente automatice
bro=Update automatici
es=Actualizaciones automáticas
fr=Mises à jour automatiques
de=Automatische Updates
pt=Atualizações automáticas
ru=Автообновления
ko=자동 업데이트
zh=自动更新
ja=自動アップデート
it=Controlla ogni (ore)
en=Check every (hours)
nap=Cuntrolla ogni (ore)
bro=Check ogni (ore)
es=Comprobar cada (horas)
fr=Vérifier toutes les (heures)
de=Prüfen alle (Stunden)
pt=Verificar a cada (horas)
ru=Проверять каждые (ч)
ko=확인 간격 (시간)
zh=检查间隔（小时）
ja=確認間隔（時間）
it=Repository GitHub
en=GitHub repository
nap=Repository GitHub
bro=Repo GitHub
es=Repositorio de GitHub
fr=Dépôt GitHub
de=GitHub-Repository
pt=Repositório do GitHub
ru=Репозиторий GitHub
ko=GitHub 저장소
zh=GitHub 仓库
ja=GitHub リポジトリ
it=Controlla aggiornamenti
en=Check for updates
nap=Guarda si ce stanno aggiornamente
bro=Check update
es=Buscar actualizaciones
fr=Rechercher des mises à jour
de=Nach Updates suchen
pt=Verificar atualizações
ru=Проверить обновления
ko=업데이트 확인
zh=检查更新
ja=アップデートを確認
it=Pagina del progetto su GitHub
en=Project page on GitHub
nap=Paggena d'o progetto ncopp'a GitHub
bro=Pagina del progetto su GitHub
es=Página del proyecto en GitHub
fr=Page du projet sur GitHub
de=Projektseite auf GitHub
pt=Página do projeto no GitHub
ru=Страница проекта на GitHub
ko=GitHub 프로젝트 페이지
zh=GitHub 项目页面
ja=GitHub のプロジェクトページ
)" "`n"
        s .= "
(
it=Repository GitHub non impostato (Impostazioni > Aggiornamenti).
en=GitHub repository not set (Settings > Updates).
nap=Repository GitHub nun mpustato (Mpustaziune > Aggiornamente).
bro=Repo GitHub non impostata (Settaggi > Update).
es=Repositorio de GitHub no configurado (Ajustes > Actualizaciones).
fr=Dépôt GitHub non défini (Paramètres > Mises à jour).
de=GitHub-Repository nicht festgelegt (Einstellungen > Updates).
pt=Repositório do GitHub não definido (Configurações > Atualizações).
ru=Репозиторий GitHub не задан (Настройки > Обновления).
ko=GitHub 저장소가 설정되지 않았습니다 (설정 > 업데이트).
zh=未设置 GitHub 仓库（设置 > 更新）。
ja=GitHub リポジトリが未設定です（設定 > アップデート）。
it=GitHub non risponde (timeout).
en=GitHub is not responding (timeout).
nap=GitHub nun risponne (timeout).
bro=GitHub non risponde (timeout).
es=GitHub no responde (tiempo de espera agotado).
fr=GitHub ne répond pas (délai dépassé).
de=GitHub antwortet nicht (Zeitüberschreitung).
pt=O GitHub não responde (tempo esgotado).
ru=GitHub не отвечает (тайм-аут).
ko=GitHub가 응답하지 않습니다 (시간 초과).
zh=GitHub 无响应（超时）。
ja=GitHub が応答しません（タイムアウト）。
it=Nessuna release trovata su {1}.
en=No release found on {1}.
nap=Nisciuna release truvata ncopp'a {1}.
bro=Nessuna release su {1}.
es=No se encontró ninguna release en {1}.
fr=Aucune release trouvée sur {1}.
de=Keine Release auf {1} gefunden.
pt=Nenhuma release encontrada em {1}.
ru=На {1} нет релизов.
ko={1}에서 릴리스를 찾지 못했습니다.
zh=在 {1} 上没有找到发布版本。
ja={1} にリリースが見つかりません。
it=Connessione non riuscita:
en=Connection failed:
nap=Cunnessione nun riuscita:
bro=Connessione fallita:
es=La conexión falló:
fr=Échec de la connexion :
de=Verbindung fehlgeschlagen:
pt=Falha na conexão:
ru=Не удалось подключиться:
ko=연결 실패:
zh=连接失败：
ja=接続に失敗しました：
it=Risposta di GitHub non valida.
en=Invalid response from GitHub.
nap=Risposta 'e GitHub nun valida.
bro=Risposta di GitHub strana, non valida.
es=Respuesta de GitHub no válida.
fr=Réponse de GitHub non valide.
de=Ungültige Antwort von GitHub.
pt=Resposta do GitHub inválida.
ru=Некорректный ответ GitHub.
ko=GitHub 응답이 올바르지 않습니다.
zh=GitHub 返回的内容无效。
ja=GitHub からの応答が不正です。
it=Controllo aggiornamenti...
en=Checking for updates...
nap=Sto cuntrullanno 'e aggiornamente...
bro=Check update in corso...
es=Buscando actualizaciones...
fr=Recherche de mises à jour...
de=Suche nach Updates...
pt=Verificando atualizações...
ru=Проверка обновлений...
ko=업데이트 확인 중...
zh=正在检查更新...
ja=アップデートを確認中...
it=Controllo aggiornamenti non riuscito:
en=Update check failed:
nap=Cuntrollo d'e aggiornamente nun riuscito:
bro=Check update fallito:
es=No se pudo comprobar si hay actualizaciones:
fr=Échec de la recherche de mises à jour :
de=Update-Prüfung fehlgeschlagen:
pt=Falha ao verificar atualizações:
ru=Не удалось проверить обновления:
ko=업데이트 확인 실패:
zh=检查更新失败：
ja=アップデートの確認に失敗しました：
it=Hai già l'ultima versione ({1}).
en=You already have the latest version ({1}).
nap=Tiene già l'urdema verzione ({1}).
bro=Hai già l'ultima versione ({1}), sei up to date.
es=Ya tienes la última versión ({1}).
fr=Tu as déjà la dernière version ({1}).
de=Du hast bereits die neueste Version ({1}).
pt=Você já tem a versão mais recente ({1}).
ru=У вас уже последняя версия ({1}).
ko=이미 최신 버전입니다 ({1}).
zh=你已经是最新版本（{1}）。
ja=すでに最新バージョンです（{1}）。
it=È disponibile AION 2 Wingman {1} (tu hai la {2}).
en=AION 2 Wingman {1} is available (you have {2}).
nap=Ce sta AION 2 Wingman {1} (tu tiene 'a {2}).
bro=È uscito AION 2 Wingman {1} (tu hai la {2}).
es=Está disponible AION 2 Wingman {1} (tienes la {2}).
fr=AION 2 Wingman {1} est disponible (tu as la {2}).
de=AION 2 Wingman {1} ist verfügbar (du hast {2}).
pt=O AION 2 Wingman {1} está disponível (você tem a {2}).
ru=Доступна версия AION 2 Wingman {1} (у вас {2}).
ko=AION 2 Wingman {1}이 나왔습니다 (현재 {2}).
zh=AION 2 Wingman {1} 已发布（你的版本是 {2}）。
ja=AION 2 Wingman {1} が利用できます（現在 {2}）。
it=Novità:
en=What's new:
nap=Che ce sta 'e nuovo:
bro=News:
es=Novedades:
fr=Nouveautés :
de=Neu:
pt=Novidades:
ru=Что нового:
ko=새로운 기능:
zh=更新内容：
ja=新機能：
it=Installarlo adesso? Le tue impostazioni restano.
en=Install it now? Your settings stay.
nap='O mettimmo mo? 'E mpustaziune toje restano.
bro=Lo installo ora? I tuoi settaggi restano.
es=¿Instalarla ahora? Tus ajustes se mantienen.
fr=L'installer maintenant ? Tes paramètres restent.
de=Jetzt installieren? Deine Einstellungen bleiben.
pt=Instalar agora? Suas configurações ficam.
ru=Установить сейчас? Ваши настройки сохранятся.
ko=지금 설치할까요? 설정은 그대로 유지됩니다.
zh=现在安装吗？你的设置会保留。
ja=今すぐインストールしますか？設定はそのまま残ります。
it=Salva o annulla prima le modifiche nelle Impostazioni.
en=First save or discard the changes in the Settings.
nap=Primma salva o annulla 'e cagnamiente int'e Mpustaziune.
bro=Prima salva o annulla le modifiche nei Settaggi.
es=Primero guarda o descarta los cambios en los Ajustes.
fr=Enregistre ou annule d'abord les modifications dans les Paramètres.
de=Speichere oder verwirf zuerst die Änderungen in den Einstellungen.
pt=Primeiro salve ou descarte as mudanças nas Configurações.
ru=Сначала сохраните или отмените изменения в Настройках.
ko=먼저 설정에서 변경 사항을 저장하거나 취소하세요.
zh=请先在设置中保存或放弃修改。
ja=先に設定の変更を保存するか破棄してください。
it=Questa release non contiene il pacchetto .zip: si apre la pagina per scaricarlo a mano.
en=This release has no .zip package: the page opens so you can download it by hand.
nap=Sta release nun tene 'o pacchetto .zip: s'arape 'a paggena pe' t' 'o scarricà a mano.
bro=Sta release non ha lo .zip: ti apro la pagina per scaricarlo a mano.
es=Esta release no contiene el paquete .zip: se abre la página para descargarlo a mano.
fr=Cette release ne contient pas le paquet .zip : la page s'ouvre pour le télécharger à la main.
de=Diese Release enthält kein .zip-Paket: Die Seite wird geöffnet, um es von Hand herunterzuladen.
pt=Esta release não tem o pacote .zip: a página será aberta para baixar manualmente.
ru=В этом релизе нет пакета .zip: откроется страница для ручной загрузки.
ko=이 릴리스에는 .zip 패키지가 없습니다. 직접 받을 수 있게 페이지를 엽니다.
zh=此发布版本没有 .zip 包：将打开页面以便手动下载。
ja=このリリースには .zip パッケージがありません。手動でダウンロードするためページを開きます。
it=Scarico l'aggiornamento...
en=Downloading the update...
nap=Sto scarrecanno l'aggiornamento...
bro=Scarico l'update...
es=Descargando la actualización...
fr=Téléchargement de la mise à jour...
de=Update wird heruntergeladen...
pt=Baixando a atualização...
ru=Загрузка обновления...
ko=업데이트 다운로드 중...
zh=正在下载更新...
ja=アップデートをダウンロード中...
it=Pacchetto non valido: manca AION 2 Wingman.ahk.
en=Invalid package: AION 2 Wingman.ahk is missing.
nap=Pacchetto nun valido: manca AION 2 Wingman.ahk.
bro=Pacchetto rotto: manca AION 2 Wingman.ahk.
es=Paquete no válido: falta AION 2 Wingman.ahk.
fr=Paquet non valide : AION 2 Wingman.ahk manque.
de=Ungültiges Paket: AION 2 Wingman.ahk fehlt.
pt=Pacote inválido: falta AION 2 Wingman.ahk.
ru=Неверный пакет: нет AION 2 Wingman.ahk.
ko=잘못된 패키지: AION 2 Wingman.ahk가 없습니다.
zh=安装包无效：缺少 AION 2 Wingman.ahk。
ja=不正なパッケージ：AION 2 Wingman.ahk がありません。
it=Aggiornamento non riuscito:
en=Update failed:
nap=Aggiornamento nun riuscito:
bro=Update fallito:
es=La actualización falló:
fr=Échec de la mise à jour :
de=Update fehlgeschlagen:
pt=Falha na atualização:
ru=Не удалось обновить:
ko=업데이트 실패:
zh=更新失败：
ja=アップデートに失敗しました：
it=Aggiornato alla versione {1}.
en=Updated to version {1}.
nap=Aggiurnato â verzione {1}.
bro=Aggiornato alla versione {1}, let's go.
es=Actualizado a la versión {1}.
fr=Mis à jour vers la version {1}.
de=Auf Version {1} aktualisiert.
pt=Atualizado para a versão {1}.
ru=Обновлено до версии {1}.
ko=버전 {1}로 업데이트했습니다.
zh=已更新到版本 {1}。
ja=バージョン {1} に更新しました。
it=Aggiorna a {1}
en=Update to {1}
nap=Aggiorna â {1}
bro=Aggiorna a {1}
es=Actualizar a {1}
fr=Mettre à jour vers {1}
de=Auf {1} aktualisieren
pt=Atualizar para {1}
ru=Обновить до {1}
ko={1}(으)로 업데이트
zh=更新到 {1}
ja={1} に更新
it=Installazione dell'aggiornamento {1}...
en=Installing update {1}...
nap=Sto mettenno l'aggiornamento {1}...
bro=Installo l'update {1}...
es=Instalando la actualización {1}...
fr=Installation de la mise à jour {1}...
de=Update {1} wird installiert...
pt=Instalando a atualização {1}...
ru=Установка обновления {1}...
ko=업데이트 {1} 설치 중...
zh=正在安装更新 {1}...
ja=アップデート {1} をインストール中...
@=UpdateRepo
en=GitHub repository of the project: "user/repo-name"
nap=repository GitHub d'o progetto: "utente/nomme-repo"
bro=repo GitHub del progetto: "utente/nome-repo"
es=repositorio de GitHub del proyecto: "usuario/nombre-repo"
fr=dépôt GitHub du projet : "utilisateur/nom-depot"
de=GitHub-Repository des Projekts: "benutzer/repo-name"
pt=repositório do GitHub do projeto: "usuario/nome-repo"
ru=репозиторий проекта на GitHub: "пользователь/имя-репо"
ko=프로젝트의 GitHub 저장소: "사용자/저장소-이름"
zh=项目的 GitHub 仓库："用户/仓库名"
ja=プロジェクトの GitHub リポジトリ："ユーザー/リポジトリ名"
)" "`n"
        s .= "
(
@=UpdateMode
en="chiedi"     = if there is a new version it asks you (never while you play)\n"automatico" = installs it by itself as soon as the game is not in the foreground\n"spento"     = no automatic check (the button in Maintenance still works)
nap="chiedi"     = si ce sta na verzione nova t' 'o cerca (maje mentre jucarie)\n"automatico" = s' 'a mette 'a sola appena 'o juoco nun sta annanze\n"spento"     = nisciuno cuntrollo automatico (resta 'o buttone int'a Manutenzione)
bro="chiedi"     = se esce una versione nuova ti chiede (mai mentre giochi)\n"automatico" = la installa da sola appena il gioco non è in primo piano\n"spento"     = niente check automatico (resta il tasto in Manutenzione)
es="chiedi"     = si hay una versión nueva te pregunta (nunca mientras juegas)\n"automatico" = la instala sola en cuanto el juego no está en primer plano\n"spento"     = sin comprobación automática (queda el botón en Mantenimiento)
fr="chiedi"     = s'il y a une nouvelle version, il te le demande (jamais pendant que tu joues)\n"automatico" = l'installe tout seul dès que le jeu n'est plus au premier plan\n"spento"     = aucune vérification automatique (le bouton dans Maintenance reste)
de="chiedi"     = bei einer neuen Version wirst du gefragt (nie während du spielst)\n"automatico" = installiert sie selbst, sobald das Spiel nicht im Vordergrund ist\n"spento"     = keine automatische Prüfung (der Knopf unter Wartung bleibt)
pt="chiedi"     = se houver versão nova, pergunta (nunca enquanto você joga)\n"automatico" = instala sozinho assim que o jogo não estiver em primeiro plano\n"spento"     = sem verificação automática (o botão em Manutenção continua)
ru="chiedi"     = при новой версии спрашивает (никогда во время игры)\n"automatico" = ставит её сам, как только игра не на переднем плане\n"spento"     = без автопроверки (кнопка в Обслуживании остаётся)
ko="chiedi"     = 새 버전이 있으면 물어봅니다 (게임 중에는 절대 안 물어봄)\n"automatico" = 게임이 앞에 없을 때 알아서 설치\n"spento"     = 자동 확인 안 함 (유지 관리의 버튼은 그대로)
zh="chiedi"     = 有新版本时询问你（游戏中绝不打扰）\n"automatico" = 游戏不在前台时自动安装\n"spento"     = 不自动检查（维护中的按钮仍可用）
ja="chiedi"     = 新バージョンがあれば確認します（プレイ中は聞きません）\n"automatico" = ゲームが前面にないときに自動でインストール\n"spento"     = 自動確認なし（メンテナンスのボタンは使えます）
@=UpdateCheckHours
en=how often to check, in hours (at startup and then continuously while the script is running)
nap=ogni quanta ore cuntrullà (quanno parte e po' sempe, mentre 'o script sta apierto)
bro=ogni quante ore fare il check (all'avvio e poi di continuo mentre lo script è aperto)
es=cada cuántas horas comprobar (al iniciar y luego continuamente mientras el script está abierto)
fr=toutes les combien d'heures vérifier (au démarrage puis en continu tant que le script est ouvert)
de=alle wie viele Stunden prüfen (beim Start und danach laufend, solange das Skript läuft)
pt=a cada quantas horas verificar (ao iniciar e depois continuamente enquanto o script está aberto)
ru=как часто проверять, в часах (при запуске и затем постоянно, пока скрипт работает)
ko=몇 시간마다 확인할지 (시작할 때, 그리고 스크립트가 실행되는 동안 계속)
zh=每隔多少小时检查一次（启动时以及脚本运行期间持续检查）
ja=何時間ごとに確認するか（起動時と、スクリプト実行中は継続的に）
)" "`n"
        return s
    }
}

; ==============================================================================
; === IMPOSTAZIONI PERSONALI PERSISTENTI (sopravvivono agli aggiornamenti) ===
; ==============================================================================
; Ogni impostazione salvata dalla finestra Impostazioni (o dal setup) viene copiata anche in
; %AppData%\AION 2 Wingman\settings.ini, insieme all'elenco boss, ai preset e al "primo avvio fatto".
; Quando si sovrascrive lo script con una versione nuova, all'avvio la CONFIG viene riscritta con
; i valori personali e lo script si riavvia una volta da solo. Se invece si modifica a mano la
; CONFIG della stessa versione, è il file settings.ini ad allinearsi allo script.
class UserData {
    static Dir     := A_AppData "\AION 2 Wingman"
    static File    := A_AppData "\AION 2 Wingman\settings.ini"
    static Presets := A_AppData "\AION 2 Wingman\presets.ini"
    static Themes  := A_AppData "\AION 2 Wingman\themes.ini"

    static Init() {
        try DirCreate(this.Dir)
        for f in [this.File, this.Presets, this.Themes]
            this.Unicode(f)
        ; file delle versioni precedenti (accanto allo script, anche col vecchio nome "AION 2 Suite")
        for prefix in ["AION 2 Wingman", "AION 2 Suite"] {
            old := A_ScriptDir "\" prefix " - preset.ini"
            if (FileExist(old) && !FileExist(this.Presets))
                try FileMove(old, this.Presets)
            old := A_ScriptDir "\" prefix " - state.ini"
            if FileExist(old) {
                try if (IniRead(old, "App", "FirstRunDone", "") = "1")
                    IniWrite("1", this.File, "App", "FirstRunDone")
                try FileDelete(old)
            }
        }
    }

    ; I file .ini di Windows restano in ANSI se nascono vuoti: emoji e caratteri speciali diventerebbero "?".
    ; Qui ogni file nasce (o viene convertito una volta) in UTF-16, che Windows legge e scrive senza perdite.
    static Unicode(f) {
        try {
            if FileExist(f) {
                raw := FileRead(f, "RAW")
                if (raw.Size >= 2 && NumGet(raw, 0, "UShort") = 0xFEFF)
                    return
                txt := FileRead(f, "CP0")
            } else
                txt := ""
            h := FileOpen(f, "w", "UTF-16")
            h.Write(txt)
            h.Close()
        }
    }

    ; nomi delle versioni precedenti ("Autoloot...", "AutoCombat...") -> nomi attuali
    static Compat(s) => StrReplace(StrReplace(StrReplace(s, "AutoLoot", "Loot"), "Autoloot", "Loot"), "AutoCombat", "Combat")

    ; lunghezza della parte di codice dopo la CONFIG: cambia con le versioni, non con le impostazioni
    static CodeLen() {
        text := FileRead(A_ScriptFullPath, "UTF-8")
        return StrLen(text) - InStr(text, "FINE CONFIG")
    }

    static Stamp() {
        try IniWrite(this.CodeLen(), this.File, "Meta", "CodeLen")
        try IniWrite(AppVersion, this.File, "Meta", "Version")
    }

    ; salva valori (Map nome -> valore) in una sezione; bosses = elenco boss (o "")
    static Persist(values, bosses := "", section := "Config") {
        for name, v in values
            try IniWrite("v:" v, this.File, section, name)
        if IsObject(bosses)
            try IniWrite("v:" this.BossKey(bosses), this.File, section = "Config" ? "Bosses" : "BossDefaults", "List")
    }

    static CfgValues(E) {
        out := Map()
        for name, it in E.Cfg
            out[name] := it.value
        return out
    }

    static BossKey(list) {
        s := ""
        for b in list
            s .= (s = "" ? "" : "¦") b.name "|" b.grade "|" b.tier
        return s
    }

    static BossList(key) {
        list := []
        for item in StrSplit(key, "¦") {
            f := StrSplit(item, "|")
            if (f.Length >= 3 && f[1] != "")
                list.Push({name: f[1], grade: StrLower(f[2]), tier: Integer(f[3])})
        }
        return list
    }

    static ReadSection(section) {
        out := Map()
        try sec := IniRead(this.File, section)
        catch
            return out
        for line in StrSplit(sec, "`n", "`r") {
            if !(p := InStr(line, "="))
                continue
            v := SubStr(line, p + 1)
            if (SubStr(v, 1, 2) = "v:")
                out[this.Compat(SubStr(line, 1, p - 1))] := this.Compat(SubStr(v, 3))
        }
        return out
    }

    static ReadBossKey(section) {
        v := ""
        try v := IniRead(this.File, section, "List", "")
        return SubStr(v, 1, 2) = "v:" ? SubStr(v, 3) : ""
    }

    ; All'avvio. Tre casi:
    ;  - nessun file personale: fotografa tutte le impostazioni attuali (diventano quelle personali)
    ;  - stessa versione dello script: settings.ini segue la CONFIG (anche se modificata a mano)
    ;  - versione nuova: rimette nella CONFIG i valori personali e riavvia. Un valore uguale al
    ;    predefinito della versione precedente non era stato personalizzato: resta quello nuovo.
    static Restore() {
        this.Init()
        E := SettingsEditor
        try E.Load()
        catch
            return
        saved := this.ReadSection("Config")
        if !saved.Count {
            this.Persist(this.CfgValues(E), E.Bosses)
            this.Stamp()
            return
        }
        stored := ""
        try stored := IniRead(this.File, "Meta", "CodeLen", "")
        if (stored != "" && stored + 0 = this.CodeLen()) {
            for name, it in E.Cfg
                if (!saved.Has(name) || saved[name] !== it.value)
                    try IniWrite("v:" it.value, this.File, "Config", name)
            if (this.ReadBossKey("Bosses") != this.BossKey(E.Bosses))
                this.Persist(Map(), E.Bosses)
            return
        }
        oldDef := this.ReadSection("Defaults"), oldBossDef := this.ReadBossKey("BossDefaults")
        newDef := this.CfgValues(E), newBossDef := this.BossKey(E.Bosses)
        E.Pending := Map(), E.BossDirty := false
        for name, v in saved {
            if !E.Cfg.Has(name) || (oldDef.Has(name) && oldDef[name] == v)
                continue
            if (v !== E.Cfg[name].value && E.Invalid(name, v) = "")
                E.Pending[name] := v
        }
        bk := this.ReadBossKey("Bosses")
        if (bk != "" && bk != newBossDef && bk != oldBossDef)
            E.Bosses := this.BossList(bk), E.BossDirty := true
        ; i valori di questa versione diventano i "predefiniti" con cui confrontare il prossimo aggiornamento
        try IniDelete(this.File, "Defaults")
        this.Persist(newDef, newBossDef = "" ? "" : this.BossList(newBossDef), "Defaults")
        if (E.Pending.Count || E.BossDirty) {
            ok := E.WriteFile(true)
            E.Pending := Map(), E.BossDirty := false
            if ok {
                this.Stamp()
                Reload()
                ExitApp()                       ; (Reload riavvia subito: qui non si arriva)
            }
        }
        this.Stamp()
    }
}

; ==============================================================================
; === AGGIORNAMENTI DA GITHUB (release) ===
; ==============================================================================
; Ogni versione è una "release" del repository UpdateRepo con tag "v1.1" (o "1.1") e, come
; allegato, il pacchetto .zip (lo crea il workflow .github/workflows/release.yml della repo).
; Il controllo legge https://api.github.com/repos/<UpdateRepo>/releases/latest e confronta il tag
; con AppVersion. L'installazione scarica lo zip, lo estrae e copia i file sopra quelli attuali.
class Updater {
    static Latest := "", Err := "", Busy := false, TrayItem := ""

    static Repo() => Trim(UpdateRepo)
    static IsNewer(ver) {
        try return VerCompare(ver, AppVersion) > 0
        return false
    }
    static OpenPage() {
        if RegExMatch(this.Repo(), "^[\w.-]+/[\w.-]+$")
            Run("https://github.com/" this.Repo() "/releases")
        else
            MsgBox(Tr("Repository GitHub non impostato (Impostazioni > Aggiornamenti)."), "AION 2 Wingman", "Icon!")
    }

    ; ultima release: {tag, ver, zip, notes, page} oppure "" (il motivo è in Updater.Err)
    static Fetch() {
        this.Err := ""
        repo := this.Repo()
        if !RegExMatch(repo, "^[\w.-]+/[\w.-]+$")
            return (this.Err := Tr("Repository GitHub non impostato (Impostazioni > Aggiornamenti)."), "")
        try {
            req := ComObject("WinHttp.WinHttpRequest.5.1")
            req.Open("GET", "https://api.github.com/repos/" repo "/releases/latest", true)
            req.SetRequestHeader("User-Agent", "AION-2-Wingman")
            req.SetRequestHeader("Accept", "application/vnd.github+json")
            req.Send()
            if !req.WaitForResponse(15)
                return (this.Err := Tr("GitHub non risponde (timeout)."), "")
            status := req.Status
            if (status = 404)
                return (this.Err := Tr("Nessuna release trovata su {1}.", repo), "")
            if (status != 200)
                return (this.Err := "HTTP " status, "")
            j := req.ResponseText
        } catch as e
            return (this.Err := Tr("Connessione non riuscita:") " " e.Message, "")
        if !RegExMatch(j, '"tag_name"\s*:\s*"([^"]+)"', &m)
            return (this.Err := Tr("Risposta di GitHub non valida."), "")
        tag := m[1], ver := RegExReplace(tag, "i)^v\.?")
        zip := "", pos := 1
        while (pos := RegExMatch(j, '"browser_download_url"\s*:\s*"([^"]+)"', &m, pos)) {
            if RegExMatch(m[1], "i)\.zip$") {
                zip := m[1]
                break
            }
            pos += m.Len
        }
        notes := RegExMatch(j, '"body"\s*:\s*"((?:[^"\\]|\\.)*)"', &m) ? this.Unescape(m[1]) : ""
        page := RegExMatch(j, '"html_url"\s*:\s*"(https://github\.com/[^"]*/releases/[^"]*)"', &m) ? m[1] : "https://github.com/" repo "/releases"
        return {tag: tag, ver: ver, zip: zip, notes: Trim(notes, " `r`n"), page: page}
    }

    static Unescape(s) {
        out := "", i := 1, n := StrLen(s)
        while (i <= n) {
            c := SubStr(s, i, 1)
            if (c != "\" || i = n) {
                out .= c, i++
                continue
            }
            e := SubStr(s, i + 1, 1), i += 2
            switch e, true {
                case "n": out .= "`n"
                case "r": out .= ""
                case "t": out .= "`t"
                case "u":
                    out .= Chr(Integer("0x" SubStr(s, i, 4))), i += 4
                default: out .= e                      ; \" \\ \/
            }
        }
        return out
    }

    ; pulsante "Controlla aggiornamenti" (Manutenzione e menu dell'icona)
    static CheckNow(*) {
        if this.Busy
            return
        this.Busy := true
        ShowTip(Tr("Controllo aggiornamenti..."), 1500)
        info := this.Fetch()
        this.Busy := false
        try IniWrite(A_Now, UserData.File, "Update", "LastCheck")
        if !IsObject(info)
            return MsgBox(Tr("Controllo aggiornamenti non riuscito:") "`n" this.Err, "AION 2 Wingman", "Icon!")
        if !this.IsNewer(info.ver)
            return MsgBox(Tr("Hai già l'ultima versione ({1}).", AppVersion), "AION 2 Wingman", "Iconi")
        this.Offer(info)
    }

    static Offer(info) {
        if (IsObject(SettingsEditor.Win) && (SettingsEditor.Pending.Count || SettingsEditor.BossDirty))
            return MsgBox(Tr("È disponibile AION 2 Wingman {1} (tu hai la {2}).", info.ver, AppVersion) "`n`n"
                . Tr("Salva o annulla prima le modifiche nelle Impostazioni."), "AION 2 Wingman", "Iconi")
        notes := info.notes != "" ? "`n`n" Tr("Novità:") "`n" (StrLen(info.notes) > 900 ? SubStr(info.notes, 1, 900) "..." : info.notes) : ""
        if (MsgBox(Tr("È disponibile AION 2 Wingman {1} (tu hai la {2}).", info.ver, AppVersion) notes "`n`n"
            . Tr("Installarlo adesso? Le tue impostazioni restano."), "AION 2 Wingman", 0x40044) = "Yes")     ; Sì/No + info + sempre in primo piano
            this.Install(info)
    }

    ; scarica, estrae e copia i file della nuova versione, poi riavvia
    static Install(info) {
        if (info.zip = "") {
            MsgBox(Tr("Questa release non contiene il pacchetto .zip: si apre la pagina per scaricarlo a mano."), "AION 2 Wingman", "Icon!")
            return Run(info.page)
        }
        q := (p) => "'" StrReplace(p, "'", "''") "'"
        tmp := A_Temp "\AION2Wingman_update", zip := tmp "\update.zip", out := tmp "\files"
        try {
            try DirDelete(tmp, true)
            DirCreate(tmp)
            ShowTip(Tr("Scarico l'aggiornamento..."), 3000)
            Download(info.zip, zip)
            RunWait('powershell -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -LiteralPath ' q(zip) ' -DestinationPath ' q(out) ' -Force"', , "Hide")
            src := ""
            loop files out "\AION 2 Wingman.ahk", "R" {
                src := A_LoopFileDir
                break
            }
            if (src = "")
                throw Error(Tr("Pacchetto non valido: manca AION 2 Wingman.ahk."))
            FileCopy(A_ScriptFullPath, A_ScriptFullPath ".bak", true)       ; copia di sicurezza dello script attuale
            loop files src "\*", "FR" {
                dest := A_ScriptDir "\" SubStr(A_LoopFileFullPath, StrLen(src) + 2)
                SplitPath(dest, , &dir)
                DirCreate(dir)
                FileCopy(A_LoopFileFullPath, dest, true)
            }
            try DirDelete(tmp, true)
        } catch as e
            return MsgBox(Tr("Aggiornamento non riuscito:") "`n" e.Message, "AION 2 Wingman", "Icon!")
        try IniWrite(info.ver, UserData.File, "Update", "JustUpdated")
        newScript := A_ScriptDir "\AION 2 Wingman.ahk"
        if (A_ScriptFullPath = newScript)
            Reload()
        else {                                          ; script rinominato: si avvia quello nuovo
            Run('"' A_AhkPath '" "' newScript '"', A_ScriptDir)
            ExitApp()
        }
    }

    ; all'avvio: avviso "aggiornato", poi controllo in background ogni UpdateCheckHours ore
    ; (anche mentre lo script resta aperto). Il primo controllo parte 20 s dopo l'avvio, oppure
    ; quando scade l'intervallo se l'ultimo controllo è recente.
    static Startup() {
        done := ""
        try done := IniRead(UserData.File, "Update", "JustUpdated", "")
        if (done != "") {
            try IniDelete(UserData.File, "Update", "JustUpdated")
            SetTimer(() => TrayTip(Tr("Aggiornato alla versione {1}.", AppVersion), "AION 2 Wingman", "Iconi"), -3000)
        }
        if (StrLower(Trim(UpdateMode)) = "spento")
            return
        wait := 20000, last := ""
        try last := IniRead(UserData.File, "Update", "LastCheck", "")
        if (last != "") {
            try {
                left := this.EveryMs() - DateDiff(A_Now, last, "Seconds") * 1000
                wait := Max(20000, left)
            }
        }
        SetTimer(ObjBindMethod(this, "Background"), -wait)
    }

    static EveryMs() => Max(1, UpdateCheckHours) * 3600000

    static Background() {
        SetTimer(ObjBindMethod(this, "Background"), -this.EveryMs())   ; prossimo controllo
        if (StrLower(Trim(UpdateMode)) = "spento" || IsObject(this.Latest))
            return                                     ; spento, oppure aggiornamento già trovato e in attesa
        info := this.Fetch()
        try IniWrite(A_Now, UserData.File, "Update", "LastCheck")
        if (!IsObject(info) || !this.IsNewer(info.ver) || info.zip = "")   ; zip non ancora allegato: si riprova più tardi
            return
        this.Latest := info
        label := Tr("Aggiorna a {1}", info.ver)
        if (this.TrayItem = "") {
            try A_TrayMenu.Insert("1&", label, (*) => this.Install(this.Latest))
            this.TrayItem := label
        }
        this.WhenFree()
    }

    ; mai mentre giochi: aspetta che il gioco non sia in primo piano (e che le Impostazioni siano chiuse)
    static WhenFree() {
        if (WinActive("ahk_exe " GameExe) || PreviewMode || IsObject(SettingsEditor.Win))
            return SetTimer(ObjBindMethod(this, "WhenFree"), -30000)
        if (StrLower(Trim(UpdateMode)) = "automatico") {
            TrayTip(Tr("Installazione dell'aggiornamento {1}...", this.Latest.ver), "AION 2 Wingman", "Iconi")
            this.Install(this.Latest)
        } else
            this.Offer(this.Latest)
    }
}

; ==============================================================================
; === EASTER EGG: CONTO ALLA ROVESCIA GTA VI (tema "vi") ===
; ==============================================================================
class ViCountdownBar {
    static Win := "", TimeCtl := "", BuiltFor := "", Fn := ""

    static Start() {
        this.Fn := ObjBindMethod(this, "Tick")
        SetTimer(this.Fn, 1000)
        this.Tick()
    }

    static Tick() {
        ; acceso o spento lo decide il tema (di default solo con "vi")
        want := HudC("ViCountdown")
            && (PreviewMode || WinActive("ahk_exe " GameExe))
            && !(IsSet(FieldBoss) && IsObject(FieldBoss) && FieldBoss.LegendShown)   ; non copre la leggenda
            && PreviewAllows("vi")
        if !want
            return this.Hide()
        try left := DateDiff(ViCountdownDate, A_Now, "Seconds")
        catch
            return this.Hide()                                   ; data scritta male
        txt := left > 0 ? Format("{:02}:{:02}:{:02}:{:02}", left // 86400, Mod(left, 86400) // 3600, Mod(left, 3600) // 60, Mod(left, 60))
                        : "OUT NOW!"
        if (this.BuiltFor != A_ScreenWidth "x" A_ScreenHeight "|" UiC("Accent") || !IsObject(this.Win))
            this.Build()
        if (this.TimeCtl.Text != txt)
            this.TimeCtl.Text := txt
        if !DllCall("IsWindowVisible", "Ptr", this.Win.Hwnd) {
            this.Win.GetPos(,, &w)
            this.Win.Show("NA x" (A_ScreenWidth - w) // 2 " y" Round(6 * A_ScreenHeight / 1440))
        }
    }

    static Build() {
        if IsObject(this.Win)
            this.Win.Destroy()
        k := A_ScreenHeight / 1440
        g := Gui("+AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08080020")   ; non attiva, attraversabile
        g.BackColor := UiC("Deep"), g.MarginX := Round(14 * k), g.MarginY := Round(3 * k)
        g.SetFont("s" Round(13 * k) " bold c" UiC("Err"), "Segoe UI")
        g.AddText("ym h" Round(26 * k) " 0x200", "GTA VI")
        g.SetFont("s" Round(13 * k) " bold c" UiC("Go"), "Segoe UI")
        g.AddText("x+" Round(10 * k) " yp h" Round(26 * k) " 0x200", "▸")
        g.SetFont("s" Round(14 * k) " bold c" UiC("Text"), "Consolas")
        this.TimeCtl := g.AddText("x+" Round(10 * k) " yp h" Round(26 * k) " w" Round(150 * k) " 0x200", "00:00:00:00")
        g.Show("Hide AutoSize")
        WinSetTransparent(225, g.Hwnd)
        this.Win := g, this.BuiltFor := A_ScreenWidth "x" A_ScreenHeight "|" UiC("Accent")
    }

    static Hide() {
        if (IsObject(this.Win) && DllCall("IsWindowVisible", "Ptr", this.Win.Hwnd))
            this.Win.Hide()
    }
}

; ==============================================================================
; === SPLASH ALL'AVVIO ===
; ==============================================================================
; Nome dell'app e "by VaLeTecK" al centro dello schermo: crescono (scala 0,45 -> 1) mentre
; l'opacità sale dal 20% al 100%, restano per SplashHold secondi e svaniscono allargandosi appena.
; Disegnato con GDI+ (antialiasing, contorno scuro per leggerlo su qualsiasi sfondo), non riceve click.
class SplashScreen {
    static Win := "", Fn := "", T0 := 0

    static Show() {
        this.Close()
        k := A_ScreenHeight / 1440 * SplashScale
        this.W := Round(1100 * k), this.H := Round(330 * k), this.K := k
        x := (A_ScreenWidth - this.W) // 2, y := (A_ScreenHeight - this.H) // 2
        w := Gui("+AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x80000 +E0x20 +E0x08000000")
        w.Show(Format("NA x{} y{} w{} h{}", x, y, this.W, this.H))
        this.Win := w

        ; superficie di disegno a 32 bit
        this.hdc := DllCall("CreateCompatibleDC", "Ptr", 0, "Ptr")
        bi := Buffer(40, 0)
        NumPut("UInt", 40, bi, 0), NumPut("Int", this.W, bi, 4), NumPut("Int", -this.H, bi, 8)
        NumPut("UShort", 1, bi, 12), NumPut("UShort", 32, bi, 14)
        this.hbm := DllCall("CreateDIBSection", "Ptr", this.hdc, "Ptr", bi, "UInt", 0, "Ptr*", &bits := 0, "Ptr", 0, "UInt", 0, "Ptr")
        this.obm := DllCall("SelectObject", "Ptr", this.hdc, "Ptr", this.hbm, "Ptr")
        DllCall("gdiplus\GdipCreateFromHDC", "Ptr", this.hdc, "Ptr*", &g := 0)
        this.G := g
        DllCall("gdiplus\GdipSetSmoothingMode", "Ptr", g, "Int", 4)
        DllCall("gdiplus\GdipSetPixelOffsetMode", "Ptr", g, "Int", 2)

        ; testi già trasformati in contorni (si scalano senza ricostruirli)
        DllCall("gdiplus\GdipCreateFontFamilyFromName", "WStr", "Segoe UI", "Ptr", 0, "Ptr*", &fam := 0)
        DllCall("gdiplus\GdipCreateStringFormat", "Int", 0, "Int", 0, "Ptr*", &fmt := 0)
        DllCall("gdiplus\GdipSetStringFormatAlign", "Ptr", fmt, "Int", 1)        ; centrato
        DllCall("gdiplus\GdipSetStringFormatLineAlign", "Ptr", fmt, "Int", 1)
        this.PTitle := this.TextPath("AION 2 Wingman", fam, fmt, 1, 120 * k, 0, 10 * k, this.W, 180 * k)
        this.PSub   := this.TextPath("by VaLeTecK", fam, fmt, 0, 46 * k, 0, 186 * k, this.W, 70 * k)
        this.PVer   := this.TextPath("v" AppVersion, fam, fmt, 0, 20 * k, 0, 254 * k, this.W, 40 * k)
        DllCall("gdiplus\GdipDeleteStringFormat", "Ptr", fmt)
        DllCall("gdiplus\GdipDeleteFontFamily", "Ptr", fam)

        DllCall("gdiplus\GdipCreatePen1", "UInt", 0, "Float", 10 * k, "Int", 2, "Ptr*", &pen := 0)
        DllCall("gdiplus\GdipSetPenLineJoin", "Ptr", pen, "Int", 2)
        DllCall("gdiplus\GdipCreateSolidFill", "UInt", 0, "Ptr*", &br := 0)
        this.Pen := pen, this.Brush := br
        this.SizeBuf := Buffer(8), NumPut("Int", this.W, "Int", this.H, this.SizeBuf)
        this.PtSrc := Buffer(8, 0)

        this.T0 := A_TickCount
        this.Fn := ObjBindMethod(this, "Tick")
        this.Tick()
        SetTimer(this.Fn, AnimInterval)
    }

    static TextPath(text, fam, fmt, style, size, x, y, w, h) {
        DllCall("gdiplus\GdipCreatePath", "Int", 0, "Ptr*", &path := 0)
        rc := Buffer(16)
        NumPut("Float", x, "Float", y, "Float", w, "Float", h, rc)
        DllCall("gdiplus\GdipAddPathString", "Ptr", path, "WStr", text, "Int", -1, "Ptr", fam
              , "Int", style, "Float", size, "Ptr", rc, "Ptr", fmt)
        return path
    }

    ; fasi: entrata 0,9 s (cresce, 20% -> 100%) | pausa SplashHold s | uscita 0,6 s (svanisce)
    static Tick() {
        Critical "On"
        if !IsObject(this.Win)
            return SetTimer(this.Fn, 0)
        t := (A_TickCount - this.T0) / 1000
        inT := 0.9, hold := Max(0, SplashHold), outT := 0.6
        if (t < inT) {
            p := 1 - (1 - t / inT) ** 3                            ; rallenta all'arrivo
            sc := 0.45 + 0.55 * p, a := 0.2 + 0.8 * p
        } else if (t < inT + hold) {
            sc := 1, a := 1
        } else if (t < inT + hold + outT) {
            p := (t - inT - hold) / outT
            sc := 1 + 0.06 * p, a := 1 - p
        } else
            return this.Close()

        g := this.G, cx := this.W / 2, cy := this.H / 2
        DllCall("gdiplus\GdipGraphicsClear", "Ptr", g, "UInt", 0)
        DllCall("gdiplus\GdipResetWorldTransform", "Ptr", g)
        DllCall("gdiplus\GdipTranslateWorldTransform", "Ptr", g, "Float", cx, "Float", cy, "Int", 0)
        DllCall("gdiplus\GdipScaleWorldTransform", "Ptr", g, "Float", sc, "Float", sc, "Int", 0)
        DllCall("gdiplus\GdipTranslateWorldTransform", "Ptr", g, "Float", -cx, "Float", -cy, "Int", 0)
        for item in [[this.PTitle, 0xFF000000 | ColorToRGB(UiC("Accent")), 12], [this.PSub, 0xFF000000 | ColorToRGB(UiC("SubText")), 7]
                   , [this.PVer, 0xFF000000 | ColorToRGB(UiC("Muted")), 4]] {
            DllCall("gdiplus\GdipSetPenWidth", "Ptr", this.Pen, "Float", item[3] * this.K)
            DllCall("gdiplus\GdipSetPenColor", "Ptr", this.Pen, "UInt", 0xE6000000 | ColorToRGB(UiC("Deep")))   ; contorno scuro
            DllCall("gdiplus\GdipDrawPath", "Ptr", g, "Ptr", this.Pen, "Ptr", item[1])
            DllCall("gdiplus\GdipSetSolidFillColor", "Ptr", this.Brush, "UInt", item[2])
            DllCall("gdiplus\GdipFillPath", "Ptr", g, "Ptr", this.Brush, "Ptr", item[1])
        }
        DllCall("gdiplus\GdipFlush", "Ptr", g, "Int", 1)
        DllCall("UpdateLayeredWindow", "Ptr", this.Win.Hwnd, "Ptr", 0, "Ptr", 0, "Ptr", this.SizeBuf
            , "Ptr", this.hdc, "Ptr", this.PtSrc, "UInt", 0, "UInt*", (Round(255 * a) << 16) | 0x1000000, "UInt", 2)
    }

    static Close() {
        Critical "On"
        if this.Fn
            SetTimer(this.Fn, 0)
        if !IsObject(this.Win)
            return
        for h in [this.PTitle, this.PSub, this.PVer]
            DllCall("gdiplus\GdipDeletePath", "Ptr", h)
        DllCall("gdiplus\GdipDeletePen", "Ptr", this.Pen)
        DllCall("gdiplus\GdipDeleteBrush", "Ptr", this.Brush)
        DllCall("gdiplus\GdipDeleteGraphics", "Ptr", this.G)
        DllCall("SelectObject", "Ptr", this.hdc, "Ptr", this.obm)
        DllCall("DeleteObject", "Ptr", this.hbm)
        DllCall("DeleteDC", "Ptr", this.hdc)
        this.Win.Destroy()
        this.Win := ""
    }
}

; Lettura/scrittura di una variabile globale per nome (usate dall'anteprima delle impostazioni)
GetGlobalVar(name) {
    global
    return %name%
}

SetGlobalVar(name, val) {
    global
    %name% := val
}

; Libreria OCR (Windows.Media.Ocr) - https://github.com/Descolada/OCR
; *i = se il file manca lo script parte comunque, con il tool Field Boss disattivato.
#Include *i %A_ScriptDir%\OCR.ahk
