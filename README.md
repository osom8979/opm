```
+------------------------------------------------------------+
| This file is part of the:                                  |
|     ____  __    ___   ________ __ __  ______  __    ______ |
|    / __ )/ /   /   | / ____/ //_// / / / __ \/ /   / ____/ |
|   / __  / /   / /| |/ /   / ,<  / /_/ / / / / /   / __/    |
|  / /_/ / /___/ ___ / /___/ /| |/ __  / /_/ / /___/ /___    |
| /_____/_____/_/  |_\____/_/ |_/_/ /_/\____/_____/_____/    |
|                                                   PROJECT. |
| Author:  Changwoo lee (zer0).                              |
| E-Mail:  osom8979@gmail.com                                |
| Website: http://www.blackhole-project.com                  |
+------------------------------------------------------------+
```

# OPM

## ABOUT

OSOM PACKAGE MANAGER.

## How to install

```bash
mkdir $HOME/Project
cd $HOME/Project
git clone https://github.com/osom8979/opm.git
cd $HOME/Project/opm
./install.sh

sudo apt-get install make build-essential wget curl llvm
sudo apt-get install libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev
sudo apt-get install libncurses5-dev xz-utils tk-dev

vim +NeoBundleInstall +qall

sudo apt-get install neovim exuberant-ctags cscope

sudo apt-get install llvm libpython-dev
cd "$HOME/.vim/bundle/YouCompleteMe" && git submodule update --init --recursive
cd "$HOME/.vim/bundle/YouCompleteMe" && ./install.sh --clang-completer
```

## LICENSE

Compatible with zlib license.

