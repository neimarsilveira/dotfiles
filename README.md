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

If the config files already exist in the new machine, you might run into a conflict issue. To addres that, you can use
the `--adopt` flag, which will both i) link the target, and ii) **replace the content of the source with the content of the target**.
This is particularly useful because we are using git, which means we can use diff to decide which version we want to keep: the one 
existing in the new machine or the one available in the repo. 

If you want to keep the new machine version, just commit and push to the repo. If you want to keep the repo version, you can use
git restore:
```bash
git restore . # restore the whole repo, useful if you want to keep the repo version for all files at once.
git restore path/to/file
```

## Adding a new 'package' to the repo

Remember: the file tree inside each stow package must resemble the location of the files relative to the home directory.
For example, suppose you want to stow the dotfiles of `your_app`. The files are located in `~/some_folder/some_file`.
Then, you want to create a directory called `your_app` inside our stow root:
```bash
mkdir ~/Repos/dotfiles/your_app
```

Now, you need to move `your_app` config files to that folder **keeping the same file structure**:
```bash
mkdir ~/Repos/dotfiles/your_app/some_folder
mv ~/some_folder/some_file ~/Repos/dotfiles/your_app/some_folder/some_file
```

1. Move the dotfiles to the repo directory. Assuming the repo is in `~/Repos/dotfiles`, that would look like:
```bash
mv -f ~/.tmux.conf ~/Repos/dotfiles/tmux # example: file in home
mv -f ~/.config/zoom.conf ~/Repos/dotfiles/zoom/.config # example: file in ~/.config/
mv -f ~/.config/texstudio ~/Repos/dotfiles/texstudio/.config/texstudio # example: app folder in ~/.config/
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
