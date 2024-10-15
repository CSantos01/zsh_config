# zsh_config

![Custom Theme Screenshot](./Pictures/Theme.gif)

This repository contains custom configurations for the Zsh (Z Shell) environment and [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh/tree/master) customization. These configurations aim to enhance the user experience by providing useful aliases, functions, and theme.

## Preliminary steps

**Install Zsh**:
```sh
wget -O zsh.tar.xz https://sourceforge.net/projects/zsh/files/latest/download
mkdir zsh && unxz zsh.tar.xz && tar -xvf zsh.tar -C zsh --strip-components 1
cd zsh
./configure
make
make install
```

**Set Zsh as the default shell**:
```sh
chsh -s $(which zsh)
```

**Install oh-my-zsh**:
```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

## Installation of the .zshrc file

1. Clone the repository:
```sh
git clone https://github.com/yourusername/zsh_config.git
```

2. Navigate to the repository directory:
```sh
cd zsh_config
```

3. Copy the configuration files to your home directory:
```sh
cp .zshrc ~/
```

4. Reload the Zsh configuration:
```sh
source ~/.zshrc
```

## Installation of the custom theme

1. Put the custom theme in the `~/.oh-my-zsh/custom/themes` directory.

### To do only once in your terminal:

2. Install [Nerd-fonts](https://github.com/ryanoasis/nerd-fonts):
```sh
git clone --depth 1 https://github.com/ryanoasis/nerd-fonts.git
cd nerd-fonts
./install.sh
```
(or you can just install the font you want).

3. Set the font in the terminal emulator to the custom font.

## Features

- **Aliases**: Shortcuts for common commands.
- **Functions**: Custom functions to automate tasks.
- **Theme**: Custom theme to personalize the terminal appearance.

## Customization

- Colors are taken from the `spectrum_ls` command.
- Symbols are taken from the [Nerd-fonts cheatsheet](https://www.nerdfonts.com/cheat-sheet)

## Contributing

Feel free to fork this repository, make improvements, and submit pull requests. Contributions are welcome!

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
