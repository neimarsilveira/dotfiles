My personal dotfiles repo to be used with GNU stow.

## Setting up a new machine

Create a `dotfiles` folder somewhere in your machine:
```bash
mkdir ~/Repos/dotfiles
```

Go ahead and clone this repo:
```bash
cd ~/Repos/dotfiles
git clone git@github.com:neimarsilveira/dotfiles.git
```

Now you can stow the files you want. For example, to bring bash configuration you can do:
```bash
stow -d ~/Repos/dotfiles -t ~ bash
```

## Adding a new 'package' to the repo

1. Move the dotfiles to the repo directory. Assuming the repo is in `~/Repos/dotfiles`, that would look like:
```bash
mv -f ~/.tmux.conf ~/Repos/dotfiles/tmux # example: file in home
mv -f ~/.config/zoom.conf ~/Repos/dotfiles/zoom # example: file in ~/.config/
mv -f ~/.config/texstudio ~/Repos/dotfiles/texstudio # example: app folder in ~/.config/
```
2. Now you use stow to manage the links:
```bash
stow -d ~/Repos/dotfiles -t ~ tmux
stow -d ~/Repos/dotfiles -t ~ zoom
stow -d ~/Repos/dotfiles -t ~ texstudio
```
3. And don't forget to push the changes to the repo
```bash
cd ~/Repos/dotfiles
git push -u origin master
```
