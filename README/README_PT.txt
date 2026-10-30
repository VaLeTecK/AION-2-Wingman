=====================================================================
  AION 2 WINGMAN 1.0                                        by VaLeTecK
  HUD overlay + ferramentas de apoio para AION 2
=====================================================================

O QUE É
  Um programa AutoHotkey v2 que roda junto com o AION 2 e adiciona:
  - HUD overlay: mira, barras e ícones LOOT / COMBAT que
    acendem com os sinais das suas macros (F9 / F10).
  - Hidden Cube: quando a janela dos Hidden Cube abre, leva o mouse até
    "Open with Key" e o mantém lá.
  - Field Boss: com o mapa aberto mostra um painel com todos os chefes
    (A-Z, cores de grau, ativos / inativos). Escolha um chefe e o script
    guia você passo a passo até o Teleport mais próximo e depois mostra
    a direção de voo.
  - Janela de Configurações completa, presets de resolução, perfis de
    desempenho, 12 idiomas de interface e 23 temas (8 de classe, 7 de datas
    comemorativas) e temas próprios.

  O script NÃO clica nem aperta teclas por você no jogo: só move o
  cursor e mostra o que fazer. Os cliques são seus.

CONTEÚDO DO PACOTE
  Setup AION 2 Wingman.bat   configuração do primeiro uso (dependências)
  AION 2 Wingman.ahk         o programa
  OCR.ahk                    biblioteca OCR (usada pelo Field Boss)
  README\                    estas instruções em vários idiomas

REQUISITOS
  - Windows 10 ou 11
  - AutoHotkey v2 (instalado pelo setup)
  - OCR do Windows em inglês (instalado pelo setup)
  - Cliente do AION 2 em inglês (o Field Boss lê os nomes em inglês)

INSTALAÇÃO
  1. Antes de extrair: clique direito no zip > Propriedades > marque
     "Desbloquear" > OK. (Evita avisos do Windows.)
  2. Extraia o zip numa pasta fixa, ex. Documentos\AION 2 Wingman.
     NÃO execute os arquivos de dentro do zip.
  3. Clique duas vezes em "Setup AION 2 Wingman.bat" e aceite o pedido de
     administrador. O setup verifica e instala tudo e no final pode
     criar um atalho na área de trabalho e iniciar o Wingman.
     Se aparecer "O Windows protegeu o computador": "Mais informações" >
     "Executar assim mesmo".
     Durante o setup, uma configuração guiada define idioma,
     resolução, desempenho e funções ON/OFF.
  4. Nas próximas vezes, abra "AION 2 Wingman.ahk" (ou o atalho). Ele
     pede permissão de administrador sozinho: é necessária para ler as
     teclas com o jogo em primeiro plano.

PRIMEIRO USO: FAÇA ISTO PRIMEIRO
  - Abra as Configurações: Ctrl+Shift+F12 (ou clique duas vezes no
    ícone verde "H" na barra de tarefas).
  - O idioma já é escolhido no setup (mude em ⚙️ Geral > Idioma).
  - 📦 Preset: aplique FullHD (1080p), 2K (1440p) ou 4K (2160p) conforme
    sua tela, para o HUD ficar do tamanho certo.
  - "Salvar e reiniciar" para confirmar. Com "PRÉVIA AO VIVO" você vê as
    mudanças ao vivo, mesmo sem o jogo aberto.

TECLAS PADRÃO (mude em Configurações > ⌨️ Teclas)
  Ctrl+Shift+\      HUD overlay ON/OFF
  Ctrl+Shift+1      Hidden Cube ON/OFF
  Ctrl+Shift+2      Field Boss ON/OFF
  Ctrl+Shift+F12    Configurações (funciona também fora do jogo)
  Esc               cancela o guia do Field Boss em andamento
  M / F             teclas de Mapa e Travel do jogo (o script as "escuta")
  F9 / F10          sinais das suas macros para o HUD (veja abaixo)
  Ctrl+F11, Ctrl+Shift+F6/F7/F8   diagnóstico (só se algo der errado)
  (\ = tecla à esquerda do 1 no teclado italiano; em outros teclados
   defina sua própria tecla nas Configurações.)

COMO LIGAR SUAS MACROS AO HUD
  - Macro de combate: coloque F9 em spam durante toda a macro.
  - Macro de loot: insira F10 com uma espera de 1350 ms.
  As teclas continuam chegando ao jogo.

COMO USAR O FIELD BOSS
  1. Abra o mapa (M). No topo aparece a legenda das teclas e à direita
     o painel dos chefes (filtros de grau/estado, ▲/▼ para recolher).
  2. Clique num chefe do painel. O guia por etapas começa: o mouse é
     levado (e travado) ao ponto certo e embaixo aparece a instrução
     grande "PASSO n". Você clica.
  3. Depois do clique no Teleport, aperte F duas vezes (Travel). O mouse
     é liberado e no topo aparece uma seta com a direção do chefe.
  Esc cancela a qualquer momento.

PROBLEMAS COMUNS
  - Nada acontece no jogo: o script só funciona com o AION2.exe em
    primeiro plano. Verifique o ícone "H" na barra de tarefas.
  - Field Boss "não disponível": falta o OCR.ahk na pasta ou o OCR em
    inglês do Windows. Rode o setup de novo.
  - HUD grande/pequeno demais ou deslocado: aplique o preset certo.
  - Antivírus bloqueando o script: falso positivo comum com AutoHotkey;
    adicione a pasta às exclusões.
  - Se algo quebrar depois de uma mudança: ao lado do script há a cópia
    de segurança "AION 2 Wingman.ahk.bak".

ATUALIZAÇÕES E CONFIGURAÇÕES PESSOAIS
  Para atualizar, basta sobrescrever o script: suas configurações
  (lista de chefes e presets também) ficam em %AppData%\AION 2 Wingman
  e são restauradas sozinhas no primeiro uso. Para começar do zero,
  apague essa pasta.

MANUTENÇÃO E ENCERRAMENTO
  Configurações > 🛠️ Manutenção: executa de novo a instalação guiada e
  abre a pasta do Wingman e a das configurações pessoais.
  O botão vermelho "⏻ Encerrar Wingman" no topo fecha o programa inteiro,
  não só a janela de configurações.
  A caixa 🔍 acima do menu busca em todas as configurações.

DESINSTALAR
  Feche o Wingman ("⏻ Encerrar Wingman" ou ícone "H" > Exit), apague a pasta e o atalho. O
  AutoHotkey se remove em Configurações do Windows > Aplicativos.

CRÉDITOS E AVISO
  AION 2 Wingman - by VaLeTecK.
  OCR.ahk - by Descolada (github.com/Descolada/OCR)
  AION 2 é marca de seus respectivos donos; este projeto não é afiliado
  nem aprovado por eles. É uma ferramenta de terceiros: use por sua
  conta e risco e respeitando os termos de serviço do jogo.
