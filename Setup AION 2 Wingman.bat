<# : ---- parte batch: si eleva ad amministratore e passa il resto a PowerShell ----
@echo off
setlocal
title AION 2 Wingman - Setup (by VaLeTecK)
set "SETUP_SELF=%~f0"
fltmc >nul 2>&1 || (
    echo Richiedo i permessi di amministratore / Requesting administrator rights...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath $env:SETUP_SELF -Verb RunAs"
    exit /b
)
powershell -NoProfile -ExecutionPolicy Bypass -Command "$s = [IO.File]::ReadAllText($env:SETUP_SELF); Invoke-Expression $s"
exit /b
#>

# ##############################################################################
#  AION 2 WINGMAN - SETUP PRIMO AVVIO                                 by VaLeTecK
#  0. Lingua del setup e di Wingman
#  1-5. Controlla e, se serve, installa: Windows 10/11, winget, AutoHotkey v2,
#       file di Wingman (OCR.ahk), OCR di Windows in inglese
#  6. Configurazione guidata: lingua, risoluzione, prestazioni, funzioni ON/OFF,
#     tastiera. Scrive i valori nella CONFIG dello script (con copia .bak).
#  7. Collegamento sul desktop e primo avvio.
# ##############################################################################

$ErrorActionPreference = 'Continue'
$Dir        = Split-Path -Parent $env:SETUP_SELF
$MainScript = Join-Path $Dir 'AION 2 Wingman.ahk'
$OcrLib     = Join-Path $Dir 'OCR.ahk'
$Results    = [ordered]@{}
$script:EN  = $false

function L($it, $en) { if ($script:EN) { $en } else { $it } }
function Say($text, $color = 'Gray') { Write-Host $text -ForegroundColor $color }
function Ok($name, $msg)   { $Results[$name] = "OK      $msg"; Say "   [OK] $msg" Green }
function Warn($name, $msg) { $Results[$name] = "!!      $msg"; Say "   [!]  $msg" Yellow }
function Fail($name, $msg) { $Results[$name] = "XX      $msg"; Say "   [X]  $msg" Red }
function Step($n, $text)   { Say ""; Say "[$n/7] $text" Cyan }

# risposta S/N (Y/N) con valore predefinito
function Ask-YesNo($question, [bool]$default) {
    $hint = if ($default) { L '[S/n]' '[Y/n]' } else { L '[s/N]' '[y/N]' }
    while ($true) {
        $a = (Read-Host "   $question $hint").Trim()
        if ($a -eq '') { return $default }
        if ($a -match '^[sSyY]') { return $true }
        if ($a -match '^[nN]')   { return $false }
    }
}

# scelta numerata con valore predefinito (indice da 1)
function Ask-Choice($question, [string[]]$options, [int]$default) {
    Say "   $question" White
    for ($i = 0; $i -lt $options.Count; $i++) {
        $mark = if ($i + 1 -eq $default) { '>' } else { ' ' }
        Say ("    {0} {1}) {2}" -f $mark, ($i + 1), $options[$i])
    }
    while ($true) {
        $a = (Read-Host ("   " + (L "Scelta" "Choice") + " [$default]")).Trim()
        if ($a -eq '') { return $default }
        $n = 0
        if ([int]::TryParse($a, [ref]$n) -and $n -ge 1 -and $n -le $options.Count) { return $n }
    }
}

function Find-AhkV2 {
    $cands = @()
    foreach ($root in @("HKLM:\SOFTWARE\AutoHotkey", "HKCU:\SOFTWARE\AutoHotkey", "HKLM:\SOFTWARE\WOW6432Node\AutoHotkey")) {
        try {
            $d = (Get-ItemProperty -Path $root -ErrorAction Stop).InstallDir
            if ($d) { $cands += (Join-Path $d 'v2\AutoHotkey64.exe'), (Join-Path $d 'v2\AutoHotkey32.exe'), (Join-Path $d 'AutoHotkey64.exe'), (Join-Path $d 'AutoHotkey.exe') }
        } catch {}
    }
    $cands += "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe",
              "$env:ProgramFiles\AutoHotkey\AutoHotkey64.exe",
              "$env:LOCALAPPDATA\Programs\AutoHotkey\v2\AutoHotkey64.exe",
              "${env:ProgramFiles(x86)}\AutoHotkey\v2\AutoHotkey32.exe"
    foreach ($c in $cands) {
        if ($c -and (Test-Path -LiteralPath $c)) {
            $v = (Get-Item -LiteralPath $c).VersionInfo.FileVersion
            if ($v -match '^\s*2\.') { return [pscustomobject]@{ Path = $c; Version = $v.Trim() } }
        }
    }
    return $null
}

function Refresh-Path {
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
}

# ---- lettura/scrittura dei valori nella CONFIG dello script (solo la parte prima di "FINE CONFIG") ----
$script:CfgText = $null
$script:CfgEnd  = 0
function Cfg-Load {
    $script:CfgText = [IO.File]::ReadAllText($MainScript, (New-Object Text.UTF8Encoding($false)))
    $script:CfgEnd  = $script:CfgText.IndexOf('FINE CONFIG')
    if ($script:CfgEnd -lt 0) { $script:CfgEnd = $script:CfgText.Length }
}
function Cfg-Regex($name) { [regex]('(?<![\w])(' + [regex]::Escape($name) + '\s*:=\s*)("[^"\r\n]*"|[^,;\s]+)') }
function Cfg-Get($name) {
    $m = (Cfg-Regex $name).Match($script:CfgText.Substring(0, $script:CfgEnd))
    if ($m.Success) { return $m.Groups[2].Value } else { return $null }
}
function Cfg-Set($name, $value) {
    $head = $script:CfgText.Substring(0, $script:CfgEnd)
    $m = (Cfg-Regex $name).Match($head)
    if (-not $m.Success) { return $false }
    $g = $m.Groups[2]
    $head = $head.Substring(0, $g.Index) + $value + $head.Substring($g.Index + $g.Length)
    $script:CfgText = $head + $script:CfgText.Substring($script:CfgEnd)
    $script:CfgEnd  = $head.Length
    return $true
}

# ---- impostazioni personali di Wingman (%AppData%\AION 2 Wingman\settings.ini) ----
# Le scelte del setup finiscono anche qui, segnate come "tue": cosi' restano a ogni nuova versione.
# E le domande propongono come risposta predefinita quello che hai gia' scelto.
$UserDir = Join-Path $env:APPDATA 'AION 2 Wingman'
$UserIni = Join-Path $UserDir 'settings.ini'
try {
    Add-Type -Namespace Wingman -Name Ini -MemberDefinition @'
[DllImport("kernel32.dll", CharSet = CharSet.Unicode)]
public static extern int GetPrivateProfileString(string s, string k, string d, System.Text.StringBuilder r, int n, string f);
[DllImport("kernel32.dll", CharSet = CharSet.Unicode)]
public static extern bool WritePrivateProfileString(string s, string k, string v, string f);
'@ -ErrorAction Stop
    $script:IniOk = $true
} catch { $script:IniOk = $false }
function Ini-Get($sec, $key) {
    if (-not $script:IniOk -or -not (Test-Path -LiteralPath $UserIni)) { return $null }
    $sb = New-Object Text.StringBuilder 4096
    [void][Wingman.Ini]::GetPrivateProfileString($sec, $key, '', $sb, 4096, $UserIni)
    $v = $sb.ToString()
    if ($v.StartsWith('v:')) { return $v.Substring(2) } else { return $null }
}
function Ini-Set($sec, $key, $val) {
    if (-not $script:IniOk) { return }
    if (-not (Test-Path -LiteralPath $UserIni)) {       # file nuovo in UTF-16 (come lo crea Wingman)
        New-Item -ItemType Directory -Path $UserDir -Force | Out-Null
        [IO.File]::WriteAllBytes($UserIni, [byte[]](0xFF, 0xFE))
    }
    [void][Wingman.Ini]::WritePrivateProfileString($sec, $key, $val, $UserIni)
}
# valore attuale: quello salvato nelle impostazioni personali, altrimenti quello della CONFIG
function Cur-Get($name) {
    $v = Ini-Get 'Config' $name
    if ($null -ne $v) { return $v } else { return (Cfg-Get $name) }
}

# misure in px dell'HUD che i preset di risoluzione riscalano (stesse del menu Preset delle Impostazioni)
$ScaleVars = @('OffsetX','OffsetY','ChevronGap','ChevronWidthOff','ChevronWidthOn','ChevronHeightOff','ChevronHeightOn',
    'ChevronThicknessOff','ChevronThicknessOn','ChevronSpacingOff','ChevronSpacingOn',
    'Bar1MaxWidth','Bar2MaxWidth','Bar1MaxHeight','Bar2MaxHeight','Bar1BorderSize','Bar2BorderSize',
    'Bar1OffsetX','Bar2OffsetX','Bar1OffsetY','Bar2OffsetY','Bar1CenterGap','Bar2CenterGap','Bar1Skew','Bar2Skew',
    'LootSize','LootBorderSize','LootEmojiSize','LootOffsetX','LootOffsetY',
    'LootLine1OffsetX','LootLine1OffsetY','LootEmojiOffsetX','LootEmojiOffsetY',
    'LootLine3OffsetX','LootLine3OffsetY',
    'CombatOffsetX','CombatOffsetY','CombatEmojiSize',
    'CombatLine1OffsetX','CombatLine1OffsetY','CombatEmojiOffsetX','CombatEmojiOffsetY',
    'CombatLine3OffsetX','CombatLine3OffsetY',
    'LootFxPadding','LootPulseSize','LootRingDistance','LootRingThickness','LootSpinThickness',
    'CombatSize','CombatBorderSize',
    'CombatFxPadding','CombatPulseSize','CombatRingDistance','CombatRingThickness','CombatSpinThickness')

# =============================================================================== 0. Lingua
Clear-Host
Say "=================================================================" DarkYellow
Say "   AION 2 WINGMAN 1.0  -  Setup                        by VaLeTecK" Yellow
Say "=================================================================" DarkYellow
Say ""
$langCodes = @('english', 'italiano', 'spanish', 'french', 'german', 'portuguese', 'russian', 'korean', 'chinese', 'japanese', 'napoletano', 'bro')
$langIdx = Ask-Choice "Language / Lingua" @('[EN] English', '[IT] Italiano', '[ES] Espanol', '[FR] Francais', '[DE] Deutsch', '[PT] Portugues',
    '[RU] Russian', '[KO] Korean', '[ZH] Chinese (simplified)', '[JA] Japanese', '[bonus] Napulitano', '[bonus] Bro - Gen Z') 1
$Lang = $langCodes[$langIdx - 1]
# il setup parla italiano o inglese; Wingman usera' la lingua scelta
$script:EN = -not (@('italiano', 'napoletano', 'bro') -contains $Lang)
Say ""
Say ((L "Cartella: " "Folder: ") + $Dir) DarkGray

# =============================================================================== 1. Windows
Step 1 (L "Versione di Windows" "Windows version")
$os = [Environment]::OSVersion.Version
if ($os.Major -ge 10) { Ok 'Windows' "Windows $($os.Major) (build $($os.Build))" }
else { Fail 'Windows' (L "Serve Windows 10 o 11 (trovato $os)" "Windows 10 or 11 required (found $os)") }

# =============================================================================== 2. winget
Step 2 "winget"
Refresh-Path
$winget = Get-Command winget -ErrorAction SilentlyContinue
if ($winget) {
    $wv = (& winget --version) 2>$null
    Ok 'winget' (L "winget presente ($wv)" "winget found ($wv)")
} else {
    Warn 'winget' (L "winget non trovato: installa/aggiorna 'App Installer' dal Microsoft Store (si apre ora), poi rilancia il setup" `
                     "winget not found: install/update 'App Installer' from the Microsoft Store (opening now), then run the setup again")
    try { Start-Process 'ms-windows-store://pdp/?productid=9NBLGGH4NNS1' } catch {}
}

# =============================================================================== 3. AutoHotkey v2
Step 3 "AutoHotkey v2"
$ahk = Find-AhkV2
if ($ahk) {
    Ok 'AutoHotkey' (L "AutoHotkey $($ahk.Version) gia' installato" "AutoHotkey $($ahk.Version) already installed")
} elseif ($winget) {
    Say (L "   AutoHotkey v2 non trovato: lo installo con winget (silenzioso)..." "   AutoHotkey v2 not found: installing it with winget (silent)...") White
    & winget install --id AutoHotkey.AutoHotkey -e --silent --scope machine --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) {
        & winget install --id AutoHotkey.AutoHotkey -e --silent --accept-package-agreements --accept-source-agreements
    }
    $ahk = Find-AhkV2
    if ($ahk) { Ok 'AutoHotkey' (L "AutoHotkey $($ahk.Version) installato" "AutoHotkey $($ahk.Version) installed") }
    else { Fail 'AutoHotkey' (L "Installazione non riuscita: scaricalo da https://www.autohotkey.com (versione 2)" "Install failed: download it from https://www.autohotkey.com (version 2)") }
} else {
    Fail 'AutoHotkey' (L "AutoHotkey v2 mancante e winget non disponibile: https://www.autohotkey.com" "AutoHotkey v2 missing and winget unavailable: https://www.autohotkey.com")
}

# =============================================================================== 4. File di Wingman
Step 4 (L "File di Wingman" "Wingman files")
# vecchio nome con la versione ("AION 2 Wingman 1.0.ahk"): si rinomina se e' l'unico, altrimenti si elimina
$legacy = @(Get-ChildItem -LiteralPath $Dir -Filter 'AION 2 Wingman *.ahk' -ErrorAction SilentlyContinue)
foreach ($old in $legacy) {
    try {
        if (-not (Test-Path -LiteralPath $MainScript)) {
            Move-Item -LiteralPath $old.FullName -Destination $MainScript -Force -ErrorAction Stop
        } else {
            Remove-Item -LiteralPath $old.FullName -Force -ErrorAction Stop
        }
        Remove-Item -LiteralPath ($old.FullName + '.bak') -Force -ErrorAction SilentlyContinue
        Say ((L "   Vecchio file sistemato: " "   Old file cleaned up: ") + $old.Name) DarkGray
    } catch {}
}
if (Test-Path -LiteralPath $MainScript) { Ok 'Script' (L "AION 2 Wingman.ahk presente" "AION 2 Wingman.ahk found") }
else { Fail 'Script' (L "Manca 'AION 2 Wingman.ahk' in questa cartella" "'AION 2 Wingman.ahk' is missing from this folder") }

$ocrOk = (Test-Path -LiteralPath $OcrLib) -and ((Get-Content -LiteralPath $OcrLib -Raw) -match 'class\s+OCR')
if ($ocrOk) {
    Ok 'OCR.ahk' (L "OCR.ahk presente" "OCR.ahk found")
} else {
    Say (L "   OCR.ahk mancante: provo a scaricarlo da GitHub (Descolada/OCR)..." "   OCR.ahk missing: trying to download it from GitHub (Descolada/OCR)...") White
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $urls = 'https://raw.githubusercontent.com/Descolada/OCR/main/Lib/OCR.ahk',
            'https://raw.githubusercontent.com/Descolada/OCR/main/OCR.ahk',
            'https://raw.githubusercontent.com/Descolada/OCR/master/Lib/OCR.ahk'
    foreach ($u in $urls) {
        try {
            $txt = (Invoke-WebRequest -Uri $u -UseBasicParsing -TimeoutSec 30).Content
            if ($txt -match 'class\s+OCR') {
                [IO.File]::WriteAllText($OcrLib, $txt, (New-Object Text.UTF8Encoding($true)))
                $ocrOk = $true
                break
            }
        } catch {}
    }
    if ($ocrOk) { Ok 'OCR.ahk' (L "OCR.ahk scaricato" "OCR.ahk downloaded") }
    else { Warn 'OCR.ahk' (L "Download non riuscito: copia OCR.ahk accanto allo script (senza, Field Boss resta spento)" "Download failed: copy OCR.ahk next to the script (without it Field Boss stays off)") }
}
Get-ChildItem -LiteralPath $Dir -Filter '*.ahk' -ErrorAction SilentlyContinue | Unblock-File -ErrorAction SilentlyContinue

# =============================================================================== 5. OCR di Windows
Step 5 (L "OCR di Windows in inglese (per Field Boss)" "Windows OCR for English (for Field Boss)")
$capName = 'Language.OCR~~~en-US~0.0.1.0'
try {
    $cap = Get-WindowsCapability -Online -Name $capName -ErrorAction Stop
    if ($cap.State -eq 'Installed') {
        Ok 'OCR Windows' (L "OCR inglese (en-US) presente" "English OCR (en-US) found")
    } else {
        Say (L "   OCR inglese mancante: lo installo (serve internet, qualche minuto)..." "   English OCR missing: installing it (needs internet, a few minutes)...") White
        Add-WindowsCapability -Online -Name $capName -ErrorAction Stop | Out-Null
        $cap = Get-WindowsCapability -Online -Name $capName
        if ($cap.State -eq 'Installed') { Ok 'OCR Windows' (L "OCR inglese (en-US) installato" "English OCR (en-US) installed") }
        else { Warn 'OCR Windows' (L "Stato OCR: $($cap.State) - potrebbe servire un riavvio" "OCR state: $($cap.State) - a reboot may be needed") }
    }
} catch {
    Warn 'OCR Windows' (L "Controllo non riuscito. Se Field Boss non legge il gioco: Impostazioni > Ora e lingua > Lingua > aggiungi Inglese (Stati Uniti)" `
                          "Check failed. If Field Boss can't read the game: Settings > Time & language > Language > add English (United States)")
}

# =============================================================================== 6. Configurazione guidata
Step 6 (L "Configurazione guidata" "Guided configuration")
$scriptOk = Test-Path -LiteralPath $MainScript
if ($scriptOk -and (Ask-YesNo (L "Imposto ora i settaggi principali? (consigliato)" "Set up the main settings now? (recommended)") $true)) {
    Cfg-Load
    $isOn = { param($n) (Cur-Get $n) -eq 'true' }
    $set  = [ordered]@{}

    # --- lingua
    $set['Language'] = '"' + $Lang + '"'

    # --- risoluzione (altezza reale dello schermo principale)
    $h = 0
    try { $h = [int]((Get-CimInstance Win32_VideoController | Where-Object CurrentVerticalResolution | Sort-Object CurrentVerticalResolution -Descending | Select-Object -First 1).CurrentVerticalResolution) } catch {}
    if ($h -le 0) { try { Add-Type -AssemblyName System.Windows.Forms; $h = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height } catch {} }
    $resList = @(1080, 1440, 2160)
    $resDef  = if ($h -ge 1800) { 3 } elseif ($h -ge 1260) { 2 } else { 1 }
    Say ""
    if ($h -gt 0) { Say ((L "   Schermo rilevato: " "   Detected screen: ") + "$h px") DarkGray }
    $r = Ask-Choice (L "Risoluzione del tuo schermo (dimensioni dell'HUD)" "Your screen resolution (HUD size)") `
        @('FullHD (1080p)', '2K / QHD (1440p)', '4K / UHD (2160p)') $resDef
    $target = $resList[$r - 1]
    $base = 0; [void][int]::TryParse(([string](Cur-Get 'HudBaseHeight')), [ref]$base)
    if ($base -le 0) { $base = 2160 }
    if ($target -ne $base) {
        $f = $target / $base
        foreach ($v in $ScaleVars) {
            $cur = Cur-Get $v
            if ($cur -notmatch '^-?\d+(\.\d+)?$') { continue }        # valori collegati (es. -LootOffsetX) restano tali
            $n = [double]$cur
            $m = [math]::Round($n * $f)
            if ($n -gt 0 -and $m -lt 1) { $m = 1 }
            $set[$v] = [string][int]$m
        }
        $set['HudBaseHeight'] = [string]$target
    }

    # --- prestazioni (suggerimento in base ai core della CPU)
    $cores = [Environment]::ProcessorCount
    $perfDef = if ($cores -le 4) { 2 } elseif ($cores -le 8) { 3 } else { 4 }
    $curPerf = [array]::IndexOf(@('potato','base','bilanciato','performante','gigachad'), ([string](Cur-Get 'PerfProfile')).Trim('"'))
    if ($curPerf -ge 0) { $perfDef = $curPerf + 1 }
    Say ""
    Say ((L "   CPU: $cores thread logici - suggerito: " "   CPU: $cores logical threads - suggested: ") + @('potato','base','bilanciato','performante','gigachad')[$perfDef - 1]) DarkGray
    $p = Ask-Choice (L "Profilo prestazioni" "Performance profile") @(
        (L "potato      - PC molto datati, minimo uso CPU"      "potato      - very old PCs, minimum CPU use"),
        (L "base        - PC di fascia bassa"                   "base        - low-end PCs"),
        (L "bilanciato  - consigliato per la maggior parte dei PC" "bilanciato  - recommended for most PCs"),
        (L "performante - PC di fascia alta, piu' reattivo"     "performante - high-end PCs, more responsive"),
        (L "gigachad    - PC top, tutto iperreattivo"           "gigachad    - top PCs, everything hyper-responsive")) $perfDef
    $set['PerfProfile'] = '"' + @('potato','base','bilanciato','performante','gigachad')[$p - 1] + '"'

    # --- tema dei colori
    Say ""
    $themes = @('principale', 'dark', 'bright', 'cuddle', 'pinkhaze', 'egirl', 'vi',
                'gladiator', 'templar', 'assassin', 'ranger', 'sorcerer', 'spiritmaster', 'cleric', 'chanter',
                'halloween', 'natale', 'capodanno', 'sanvalentino', 'carnevale', 'pasqua', 'sanpatrizio')
    $thOpts = @(
        (L "principale - classico scuro e oro" "principale - classic dark and gold"),
        (L "dark       - nero grafite e azzurro ghiaccio" "dark       - graphite black and ice blue"),
        (L "bright     - chiaro, pannelli bianchi" "bright     - light, white panels"),
        (L "cuddle     - pastelli coccolosi" "cuddle     - cuddly pastels"),
        (L "pinkhaze   - foschia rosa e viola" "pinkhaze   - pink and purple haze"),
        (L "egirl      - rosa shocking e nero" "egirl      - hot pink and black"),
        (L "vi         - Vice City, stile GTA VI" "vi         - Vice City, GTA VI style"),
        (L "gladiator  - classe: rosso e bronzo, blocchi pesanti" "gladiator  - class: red and bronze, heavy blocks"),
        (L "templar    - classe: oro e blu, scudo e aura" "templar    - class: gold and blue, shield and aura"),
        (L "assassin   - classe: viola e veleno, lame rapide" "assassin   - class: purple and poison, fast blades"),
        (L "ranger     - classe: verde bosco, raffica di frecce" "ranger     - class: forest green, arrow volley"),
        (L "sorcerer   - classe: blu arcano e fuoco" "sorcerer   - class: arcane blue and fire"),
        (L "spiritmaster - classe: turchese e spiriti" "spiritmaster - class: teal and spirits"),
        (L "cleric     - classe: luce bianca e oro" "cleric     - class: white light and gold"),
        (L "chanter    - classe: ambra e mantra" "chanter    - class: amber and mantras"),
        (L "halloween  - evento: zucca arancione e viola notte" "halloween  - event: pumpkin orange and night purple"),
        (L "natale     - evento: rosso, verde abete e oro" "natale     - event (Christmas): red, fir green and gold"),
        (L "capodanno  - evento: nero, oro e argento" "capodanno  - event (New Year): black, gold and silver"),
        (L "sanvalentino - evento: rosa e rosso vino" "sanvalentino - event (Valentine's): pink and wine red"),
        (L "carnevale  - evento: viola, giallo e verde" "carnevale  - event (Carnival): purple, yellow and green"),
        (L "pasqua     - evento: pastelli di primavera" "pasqua     - event (Easter): spring pastels"),
        (L "sanpatrizio - evento: verde trifoglio e oro" "sanpatrizio - event (St. Patrick's): clover green and gold"))
    # risposta predefinita: il tema che usi gia' (anche uno tuo, salvato con l'Editor temi)
    $curTheme = ([string](Cur-Get 'Theme')).Trim('"')
    $thDef = [array]::IndexOf($themes, $curTheme) + 1
    if ($thDef -le 0 -and $curTheme -ne '') {
        $themes = @($curTheme) + $themes
        $thOpts = @((L "tieni il tema attuale: " "keep the current theme: ") + $curTheme) + $thOpts
        $thDef  = 1
    }
    if ($thDef -le 0) { $thDef = 1 }
    $th = Ask-Choice (L "Tema dei colori (si cambia quando vuoi; nelle Impostazioni > Editor temi crei i tuoi)" "Color theme (change it any time; create your own in Settings > Theme editor)") $thOpts $thDef
    $set['Theme'] = '"' + $themes[$th - 1] + '"'

    # --- funzioni accese all'avvio
    Say ""
    Say (L "   Funzioni accese all'avvio (si possono sempre accendere/spegnere con i tasti):" "   Features on at startup (you can always toggle them with the keys):") White
    $set['HudEnabled']        = if (Ask-YesNo (L "HUD overlay (mirino, barre, icone LOOT / COMBAT)?" "HUD overlay (crosshair, bars, LOOT / COMBAT icons)?") (& $isOn 'HudEnabled')) { 'true' } else { 'false' }
    $set['HiddenCubeEnabled'] = if (Ask-YesNo (L "Hidden Cube (mouse su 'Open with Key')?" "Hidden Cube (mouse on 'Open with Key')?") (& $isOn 'HiddenCubeEnabled')) { 'true' } else { 'false' }
    $set['FieldBossEnabled']  = if (Ask-YesNo (L "Field Boss (pannello boss e guida al Teleport)?" "Field Boss (boss panel and Teleport guide)?") (& $isOn 'FieldBossEnabled')) { 'true' } else { 'false' }
    if ($set['FieldBossEnabled'] -eq 'true') {
        $set['FieldBossLockMouse']  = if (Ask-YesNo (L "  Field Boss: blocca il mouse sul punto da cliccare?" "  Field Boss: lock the mouse on the spot to click?") (& $isOn 'FieldBossLockMouse')) { 'true' } else { 'false' }
        $set['FieldBossDirHint']    = if (Ask-YesNo (L "  Field Boss: freccia con la direzione del boss dopo il Teleport?" "  Field Boss: arrow with the boss direction after the Teleport?") (& $isOn 'FieldBossDirHint')) { 'true' } else { 'false' }
        $set['FieldBossShowLegend'] = if (Ask-YesNo (L "  Leggenda dei tasti in alto con la mappa aperta?" "  Key legend at the top while the map is open?") (& $isOn 'FieldBossShowLegend')) { 'true' } else { 'false' }
        $curMode = ([string](Cur-Get 'FieldBossTeleportMode')).Trim('"')
        $mDef = if ($curMode -eq 'normal') { 2 } else { 1 }
        $mo = Ask-Choice (L "  Field Boss: assistente Teleport" "  Field Boss: Teleport assistant") @(
            (L "ULTRA-FAST - click sul boss, click sul Teleport, F due volte (consigliata)" "ULTRA-FAST - click the boss, click the Teleport, F twice (recommended)"),
            (L "NORMAL     - percorso guidato completo (Exploration > Field Boss > Teleport)" "NORMAL     - full guided route (Exploration > Field Boss > Teleport)")) $mDef
        $set['FieldBossTeleportMode'] = if ($mo -eq 2) { '"normal"' } else { '"ultrafast"' }
    }
    $set['SplashEnabled'] = if (Ask-YesNo (L "Splash con il logo all'avvio?" "Logo splash at startup?") (& $isOn 'SplashEnabled')) { 'true' } else { 'false' }

    # --- tastiera: Ctrl+Shift+\ esiste solo sulla tastiera italiana
    Say ""
    if (-not (Ask-YesNo (L "La tua tastiera e' italiana? (serve per il tasto HUD Ctrl+Shift+\)" "Is your keyboard Italian? (needed for the HUD key Ctrl+Shift+\)") $true)) {
        $set['HudToggleKey'] = '"^+3"'
        Say (L "   HUD overlay ON/OFF spostato su Ctrl+Shift+3" "   HUD overlay ON/OFF moved to Ctrl+Shift+3") DarkGray
    }

    # --- riepilogo e scrittura
    Say ""
    Say (L "   Valori da scrivere nella CONFIG:" "   Values to write into the CONFIG:") White
    $show = @('Language','Theme','HudBaseHeight','PerfProfile','HudEnabled','HiddenCubeEnabled','FieldBossEnabled','FieldBossLockMouse','FieldBossDirHint','FieldBossShowLegend','FieldBossTeleportMode','SplashEnabled','HudToggleKey')
    foreach ($k in $show) { if ($set.Contains($k)) { Say ("     {0,-20} {1}" -f $k, $set[$k]) } }
    if ($set.Contains('HudBaseHeight')) { Say ((L "     + misure HUD riscalate da ${base}p a ${target}p" "     + HUD sizes rescaled from ${base}p to ${target}p")) DarkGray }
    if (Ask-YesNo (L "Salvo?" "Save?") $true) {
        $written = 0
        foreach ($k in $set.Keys) { if (Cfg-Set $k $set[$k]) { $written++ } }
        try {
            Copy-Item -LiteralPath $MainScript -Destination ($MainScript + '.bak') -Force
            [IO.File]::WriteAllText($MainScript, $script:CfgText, (New-Object Text.UTF8Encoding($false)))
            foreach ($k in $set.Keys) {                  # anche nelle impostazioni personali, come scelte tue
                Ini-Set 'Config' $k ('v:' + $set[$k])
                Ini-Set 'Custom' $k '1'
            }
            Ok 'Config' (L "$written impostazioni salvate (copia di sicurezza: .bak)" "$written settings saved (backup: .bak)")
        } catch {
            Fail 'Config' ((L "Salvataggio non riuscito: " "Save failed: ") + $_.Exception.Message)
        }
    } else { Warn 'Config' (L "Configurazione non salvata" "Configuration not saved") }
} elseif ($scriptOk) {
    Warn 'Config' (L "Configurazione saltata: si fa dalle Impostazioni (Ctrl+Shift+F12)" "Configuration skipped: use the Settings (Ctrl+Shift+F12)")
}

# =============================================================================== Riepilogo
Say ""
Say "=================================================================" DarkYellow
Say (L "   RIEPILOGO" "   SUMMARY") Yellow
Say "=================================================================" DarkYellow
foreach ($k in $Results.Keys) {
    $col = if ($Results[$k] -like 'OK*') { 'Green' } elseif ($Results[$k] -like 'XX*') { 'Red' } else { 'Yellow' }
    Say ("   {0,-13} {1}" -f $k, $Results[$k]) $col
}

# =============================================================================== 7. Collegamento e avvio
Step 7 (L "Collegamento e primo avvio" "Shortcut and first launch")
$ready = $ahk -and $scriptOk
if ($ready) {
    if (Ask-YesNo (L "Creo un collegamento 'AION 2 Wingman' sul desktop?" "Create an 'AION 2 Wingman' shortcut on the desktop?") $true) {
        try {
            $lnk = Join-Path ([Environment]::GetFolderPath('Desktop')) 'AION 2 Wingman.lnk'
            $sh = New-Object -ComObject WScript.Shell
            $sc = $sh.CreateShortcut($lnk)
            $sc.TargetPath       = $ahk.Path
            $sc.Arguments        = '"' + $MainScript + '"'
            $sc.WorkingDirectory = $Dir
            $sc.IconLocation     = $ahk.Path + ',0'
            $sc.Description      = 'AION 2 Wingman - by VaLeTecK'
            $sc.Save()
            Say ((L "   Collegamento creato: " "   Shortcut created: ") + $lnk) Green
        } catch { Say ((L "   Collegamento non creato: " "   Shortcut not created: ") + $_.Exception.Message) Yellow }
    }
    if (Ask-YesNo (L "Avvio AION 2 Wingman adesso?" "Start AION 2 Wingman now?") $true) {
        # avvio senza Start-Process: i suoi percorsi trattano [ ] come caratteri jolly
        # e falliscono con cartelle tipo "[1] - APP"
        try {
            $psi = New-Object Diagnostics.ProcessStartInfo
            $psi.FileName         = $ahk.Path
            $psi.Arguments        = '"' + $MainScript + '"'
            $psi.WorkingDirectory = $Dir
            $psi.UseShellExecute  = $true
            [void][Diagnostics.Process]::Start($psi)
            Say (L "   Avviata! Impostazioni complete: Ctrl+Shift+F12 (o doppio click sull'icona 'H')." `
                   "   Started! Full settings: Ctrl+Shift+F12 (or double-click the 'H' icon).") Green
        } catch {
            Say ((L "   Avvio non riuscito: " "   Could not start: ") + $_.Exception.Message) Red
            Say (L "   Avviala a mano con il collegamento sul desktop o con doppio click su 'AION 2 Wingman.ahk'." `
                   "   Start it manually from the desktop shortcut or by double-clicking 'AION 2 Wingman.ahk'.") Yellow
        }
    }
} else {
    Say (L "Sistema i punti in rosso e rilancia il setup." "Fix the red items and run the setup again.") Red
}

Say ""
Say (L "Setup terminato - by VaLeTecK" "Setup finished - by VaLeTecK") DarkGray
Read-Host (L "Premi Invio per chiudere" "Press Enter to close") | Out-Null
