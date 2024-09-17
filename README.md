# My dotfiles

This is a collection of dotfiles I use daily.

They are managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Usage

- Install Stow

```console
brew install stow
```

(or with [1-click](https://software.opensuse.org/package/stow) install)

- Checkout this repo in your $HOME

```console
git clone https://github.com/shakedhagag/dotfiles.git
```

- Symlink modules

For example, if you want to use my nvim dotfiles:

```console
cd dotfiles
stow nvim
```

And that is all.
Stow will take care of symlinking the files to your $HOME.

Good Luck
