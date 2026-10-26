# my dotfiles

![code size](https://img.shields.io/github/languages/code-size/ivaquero/backup.svg)
![repo size](https://img.shields.io/github/repo-size/ivaquero/backup.svg)

跨 Windows / macOS / Linux 的个人配置与软件清单备份仓。目标只有一个：新机器重装后，能按同一套约定把开发环境恢复到可用状态。

仓库只存纯文本配置、工具导出的软件清单和少量应用级设置：不含密钥，不含大体积二进制（未启用 Git LFS）。

## 目录结构

| 路径 | 内容 |
| --- | --- |
| `win/` | Windows 侧配置：PowerShell profile、Scoop 与 winget 清单、winget 设置、Windows Terminal 设置、VcXsrv 启动配置 |
| `unix/` | macOS / Linux 侧配置：zsh、vim、tmux、zellij、wezterm、Homebrew Brewfile，以及两台系统的整机初始化脚本 |
| `conda/` | `.condarc`（USTC 镜像、`channel_priority: strict`、禁用 `anaconda` channel）与 5 份分环境包清单 |
| `espanso/` | 文本扩展工具 espanso：全局配置、102 条自定义触发器、7 个随仓固定的扩展包 |
| `obsidian/` | Obsidian 插件清单与 5 个插件的 `data.json` 偏好设置 |
| `vscode/` | VSCode 用户设置、快捷键、12 种语言的代码片段、扩展清单 |
| `apps/` | 应用级配置导出：Winhance 系统精简方案、北航学位论文 CSL、drawio 与 Vimium 设置 |
| `docker/` | Docker daemon 配置（国内镜像加速）与常用镜像清单 |
| `julia/` | `startup.jl`（8 线程、PKU 镜像源）与包清单 |
| `javascript/` | npm 全局包清单 |
| `rust/` | Cargo 配置（`sccache` 编译缓存、重试策略） |
| `projects/` | 项目脚手架通用件：ruff / pyproject 规则、Doxyfile、TeX Live 包清单、uv 全局工具清单 |

## 环境恢复

### Windows

```powershell
# 包管理：Scoop 与 winget 各自导入
scoop import win/Scoopfile.json
winget import -i win/Wingetfile.json --accept-package-agreements
```

配置文件按工具默认名存放，直接落位即可：

| 仓库文件 | 目标位置 |
| --- | --- |
| `win/Profile.ps1` | `$PROFILE` |
| `win/winget.jsonc` | `%LOCALAPPDATA%\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json` |
| `win/terminal.jsonc` | `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json` |
| `espanso/config/`、`espanso/match/` | `%APPDATA%\espanso\` |
| `vscode/` | `%APPDATA%\Code\User\` |
| `obsidian/` | `<vault>\.obsidian\` |

`Profile.ps1` 提供统一的命令别名（`cat` → `bat`、`ls` → `lsd`、`man` → `tldr`、`rr`、`g` 等）与 oxidizer 的 `oxf` / `rdf` / `clzf` 封装，和 `unix/.zshrc` 的别名集保持一致，跨平台操作习惯不因系统切换而变。

### macOS / Linux

```bash
# 二选一：跑整机初始化脚本，或只装包
bash unix/macos.sh     # macOS
bash unix/ubuntu.sh    # Ubuntu / Debian
brew bundle install --file=unix/Brewfile
```

dotfiles 用软链接接管（示例 macOS，Linux 同理改路径）：

```bash
ln -sf ~/backup/unix/.zshrc      ~/.zshrc
ln -sf ~/backup/unix/.vimrc      ~/.vimrc
ln -sf ~/backup/unix/.tmux.conf  ~/.tmux.conf
ln -sf ~/backup/unix/wezterm.lua ~/.config/wezterm/wezterm.lua
ln -sf ~/backup/unix/zellij.kdl  ~/.config/zellij/config.kdl
```

## 包清单

清单文件均由工具导出后直接提交，不手工编辑，因此可以原样喂回对应包管理器：

| 清单 | 适用范围 | 应用方式 |
| --- | --- | --- |
| `win/Scoopfile.json` | Scoop 已装包与 bucket（含自定义仓库） | `scoop import` |
| `win/Wingetfile.json` | winget 已装包 | `winget import -i` |
| `vscode/vscode-exts.txt` | VSCode 扩展 | `code --install-extension` 逐条 |
| `conda/conda-*.txt` | 分环境包清单：base / cpp / kaggle / ros / rstupid | `conda install -n <env> --file <清单>` |
| `julia/julia-base.txt`、`julia/julia-tut.txt` | Julia 包 | `Pkg.add` 逐条 |
| `javascript/npm-pkgs.txt` | npm 全局包 | `npm i -g` |
| `projects/uv.txt` | uv 全局工具 | `uv tool install` |
| `projects/texlive-pkgs.txt` | TeX Live 额外包 | `tlmgr install` |
| `docker/docker-img.txt` | 常用镜像 | `docker pull` |

## 文本扩展（espanso）

`espanso/match/base.yml` 收录 102 条触发器，集中在三类：时间戳（`:now`、`:date`）、数学符号（上下标 `:^0`、`:^int`、关系符，以及希腊字母）、以及配套的 Unicode 变体。7 个扩展包（`actually-all-emojis`、`encircled-numbers`、`espanso-pinyin-tones`、`greek-letters-improved`、`mac-symbols`、`math-symbols`、`script-letters`）以源码形式随仓固定，恢复时不依赖 espanso hub 在线拉取。

## 应用级配置（`apps/`）

- `winhance.json` 与两份按日期归档的 `Winhance_Config_*.winhance`：Windows 系统精简与隐私项方案
- `chinese-buaa.csl`：北航学位论文参考文献样式，供 Zotero 等 CSL 渲染器使用
- `drawio.json`：draw.io 编辑器偏好（界面语言、图形库、导出宽度）
- `vimium.json`：浏览器键盘操作配置与站点排除规则
