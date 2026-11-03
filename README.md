# KDE Taskbar Hover Peek (Estilo Windows)

Script para **KDE Plasma 6 (Wayland/X11)** que exibe automaticamente as janelas abertas na tela ao passar o mouse diretamente sobre o ícone na barra de tarefas (sem precisar subir o mouse até a miniatura).

## Recursos
- **Hover direto no ícone:** Mostra a janela após `500ms` com o mouse sobre o ícone e limpa suavemente (`300ms`) ao sair.
- **Suporte a múltiplas janelas (ex: Steam, Dolphin):** Mostra todas as janelas do aplicativo simultaneamente na posição original e eleva automaticamente janelas menores (como Chat e Lista de Amigos) para que a janela principal maior não as cubra.
- **Transição limpa:** Configura `AnimationDurationFactor=0.5` e desativa efeitos de deformação (`magiclamp`, `scale`, `squash`).

## Como instalar em outro computador (KDE Plasma 6)
```bash
chmod +x install.sh uninstall.sh
./install.sh
```

## Como editar os tempos (delays)
1. Edite o arquivo `~/.config/taskbarhoverpeek.qml` (altere `interval: 500` em `showTimer` ou `interval: 300` em `clearTimer`).
2. Aplique na hora sem precisar reiniciar a sessão rodando:
```bash
recarregar-peek
```

## Como desinstalar
```bash
./uninstall.sh
```
