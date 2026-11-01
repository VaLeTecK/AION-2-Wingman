=====================================================================
  AION 2 WINGMAN 1.0                                        by VaLeTecK
  QoL-Tool für AION 2: schneller Teleport-Assistent + HUD-Overlay
=====================================================================

WAS IST DAS
  Ein AutoHotkey-v2-Programm, das neben AION 2 läuft und Folgendes bietet:
  - HUD-Overlay: Fadenkreuz, Balken und LOOT- / COMBAT-Symbole,
    die durch die Signale deiner Makros (F9 / F10) aufleuchten.
  - Hidden Cube: Öffnet sich das Hidden-Cube-Fenster, wird die Maus auf
    „Open with Key" gesetzt und dort gehalten.
  - Schneller Teleport-Assistent (Field Boss): Bei offener Karte zeigt
    ein Panel alle Bosse (A-Z, Ränge, aktiv / inaktiv).
    ULTRA-FAST MODE (Standard): Boss anklicken, Wingman findet seinen
    Teleport selbst in der Kibelisk-Liste, du klickst ihn an und
    drückst zweimal F. Danach zeigt ein Pfeil die Flugrichtung.
    NORMAL MODE: vollständige geführte Route zum nächsten Teleport.
  - Vollständiges Einstellungsfenster, Auflösungs-Presets,
    Leistungsprofile, 12 Oberflächensprachen und 22 Designs (8 Klassen, 7 Feiertage)
    und eigene Designs.

  Das Skript klickt NICHT und drückt KEINE Tasten für dich im Spiel:
  Es bewegt nur den Mauszeiger und zeigt dir, was zu tun ist.

PAKETINHALT
  Setup AION 2 Wingman.bat   Ersteinrichtung (Abhängigkeiten)
  AION 2 Wingman.ahk         das Programm
  OCR.ahk                    OCR-Bibliothek (für Field Boss)
  README\                    diese Anleitung in mehreren Sprachen

VORAUSSETZUNGEN
  - Windows 10 oder 11
  - AutoHotkey v2 (wird vom Setup installiert)
  - Windows-OCR für Englisch (wird vom Setup installiert)
  - AION-2-Client auf Englisch (Field Boss liest die englischen Namen)

INSTALLATION
  1. Vor dem Entpacken: Rechtsklick auf die ZIP > Eigenschaften >
     „Zulassen" anhaken > OK. (Vermeidet Windows-Warnungen.)
  2. ZIP in einen festen Ordner entpacken, z. B. Dokumente\AION 2 Wingman.
     Die Dateien NICHT direkt aus der ZIP starten.
  3. Doppelklick auf „Setup AION 2 Wingman.bat" und die
     Administratorabfrage bestätigen. Das Setup prüft und installiert
     alles und kann am Ende eine Desktopverknüpfung anlegen und die
     Wingman starten. Bei „Der Computer wurde durch Windows geschützt":
     „Weitere Informationen" > „Trotzdem ausführen".
     Während des Setups stellt ein Assistent Sprache, Auflösung,
     Leistung und EIN/AUS-Funktionen ein.
  4. Danach „AION 2 Wingman.ahk" (oder die Verknüpfung) starten. Es
     fordert selbst Administratorrechte an: nötig, um Tasten zu lesen,
     während das Spiel im Vordergrund ist.

ERSTER START: ZUERST ERLEDIGEN
  - Einstellungen öffnen: Strg+Umschalt+F12 (oder Doppelklick auf das
    grüne „H"-Symbol in der Taskleiste).
  - Die Sprache wählst du schon im Setup (änderbar unter ⚙️ Allgemein > Sprache).
  - 📦 Preset: FullHD (1080p), 2K (1440p) oder 4K (2160p) passend zu
    deinem Bildschirm anwenden, damit das HUD die richtige Größe hat.
  - Mit „Speichern+Neustart" bestätigen. Mit „LIVE-VORSCHAU" siehst du
    Änderungen live, auch ohne laufendes Spiel.

STANDARDTASTEN (änderbar unter Einstellungen > ⌨️ Tasten)
  Strg+Umschalt+\     HUD-Overlay EIN/AUS
  Strg+Umschalt+1     Hidden Cube EIN/AUS
  Strg+Umschalt+2     Field Boss EIN/AUS
  Strg+Umschalt+F12   Einstellungen (funktioniert auch außerhalb des Spiels)
  Esc                 laufende Field-Boss-Führung abbrechen
  M / F               Karten- und Travel-Taste des Spiels (werden „mitgehört")
  F9 / F10            Makro-Signale für das HUD (siehe unten)
  Strg+F11, Strg+Umschalt+F6/F7/F8   Diagnose (nur bei Problemen)
  (\ = Taste links neben der 1 auf italienischer Tastatur; auf deutscher
   Tastatur besser eine eigene Taste in den Einstellungen festlegen.)

MAKROS MIT DEM HUD VERBINDEN
  - Kampfmakro: F9 während des ganzen Makros spammen.
  - Loot-Makro: F10 mit 1350 ms Wartezeit einfügen.
  Die Tasten kommen trotzdem im Spiel an.

FIELD BOSS BENUTZEN
  1. Karte öffnen (M). Oben erscheint die Tastenlegende, rechts das
     Boss-Panel (Rang-/Statusfilter, ▲/▼ zum Einklappen).
  2. Einen Boss im Panel anklicken. Die Schritt-Führung startet: Die
     Maus wird an die richtige Stelle gesetzt (und gesperrt), unten
     erscheint die große Anweisung „SCHRITT n". Du klickst selbst.
  3. Nach dem Klick auf den Teleport zweimal F drücken (Travel). Die
     Maus wird freigegeben und oben zeigt ein Pfeil die Boss-Richtung.
  Esc bricht jederzeit ab.

HÄUFIGE PROBLEME
  - Im Spiel passiert nichts: Das Skript arbeitet nur, wenn AION2.exe
    im Vordergrund ist. „H"-Symbol in der Taskleiste prüfen.
  - Field Boss „nicht verfügbar": OCR.ahk fehlt im Ordner oder die
    englische Windows-OCR fehlt. Setup erneut ausführen.
  - HUD zu groß/klein oder verschoben: passendes Preset anwenden.
  - Virenscanner blockiert das Skript: häufiger Fehlalarm bei
    AutoHotkey; Ordner zu den Ausnahmen hinzufügen.
  - Wenn nach einer Änderung etwas kaputt ist: Neben dem Skript liegt
    die Sicherung „AION 2 Wingman.ahk.bak".

UPDATES UND PERSÖNLICHE EINSTELLUNGEN
  Zum Aktualisieren einfach das Skript überschreiben: deine Einstellungen
  (auch Bossliste und Presets) liegen in %AppData%\AION 2 Wingman und
  werden beim ersten Start automatisch wiederhergestellt.
  Für einen Neustart von null diesen Ordner löschen.

WARTUNG UND BEENDEN
  Einstellungen > 🛠️ Wartung: startet die geführte Installation erneut und
  öffnet den Wingman-Ordner und den Ordner der persönlichen Einstellungen.
  Der rote Knopf „⏻ Wingman beenden" oben schließt das ganze Programm,
  nicht nur das Einstellungsfenster.
  Das 🔍-Feld über dem Menü durchsucht alle Einstellungen.

DEINSTALLATION
  Wingman beenden („⏻ Wingman beenden" oder „H"-Symbol > Exit), Ordner und Verknüpfung löschen.
  AutoHotkey über Windows-Einstellungen > Apps entfernen.

CREDITS UND HINWEIS
  AION 2 Wingman - by VaLeTecK.
  OCR.ahk - by Descolada (github.com/Descolada/OCR)
  AION 2 ist eine Marke der jeweiligen Inhaber; dieses Projekt ist mit
  ihnen weder verbunden noch von ihnen unterstützt. Drittanbieter-Tool:
  Nutzung auf eigenes Risiko und im Rahmen der Nutzungsbedingungen.
