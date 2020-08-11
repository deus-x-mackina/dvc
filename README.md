# DVC: A GitHub Repo Manager

**DVC** (*Done Very Clean*) is a simple tool to assist in managing your
locally-cloned GitHub repositories in one place. It functions very similarly to
your favorite command line package managers such as `npm`, `brew`, or `apt`, but
is meant to be much simpler.

```
$ dvc clone attaswift/bigint
...
$ dvc clone trekhleb/javascript-algorithms
...
$ dvc ls
attaswift/bigint
trekhleb/javascript-algorithms
$ dvc rm attaswift/bigint
Deleted cloned repo: /Users/Me/DVC_repos/attaswift/bigint
$ dvc ls
trekhleb/javascript-algorithms
```

## Requirements

As far as I know, DVC only requires that `git` be installed on your machine, and
that you have the latest version of Swift installed, so you can build the binary.

## Environment Variables

Before getting to the exciting stuff, it is worth mentioning that DVC
preferentially configures itself based on two shell environment variables:

- `DVC_GIT`: The absolute path to your `git` executable. If this isn't
  specified, DVC searches for a `git` executable by querying the system with
  `which git`. If this behavior is undesirable (or it is failing), be sure to
   set this variable.
- `DVC_ROOT`: The absolute path to the directory that you want DVC to operate
  in. If this variable is not set, DVC works in $HOME/DVC_repos. If this
  directory does not exist upon invocation of `dvc` (besides asking for help,
  version, or prefix), DVC will create the directory for you.

Be sure to configure these variables within your appropriate shell configuration
file, such as `~/.bash_profile`, `~/.bashrc`, `.zshrc`, etc.

```shell script
export DVC_GIT=/path/to/git
export DVC_ROOT=/path/to/directory
```

## Installation

Installing the binary is fairly painless. First download the repository (a bit
ironic, I know!)

```shell script
$ git clone https://github.com/deus-x-mackina/dvc.git
$ cd dvc
```

Once inside the repository, ask Swift to build the package for you.

```shell script
$ swift build -c release
```

Now the binary will be located within the `./.build` directory. Copy the binary
to a directory that is included in your shells $PATH.

```shell script
# View the current PATH
$ echo $PATH
# Copy the binary to a directory in PATH
$ cp .build/release/dvc /path/to/directory
```

Personally, I prefer to put it in `~/bin`. Now, you may need to restart your
shell.

```shell script
$ exec -l $SHELL
```

You should be good to go!

### Completion Scripts

If typing out shell commands without autocomplete is a drag for you, there's
good news! Binaries made with Apple's `ArgumentParser` library come bundled with
a subcommand for doing just that.

```shell script
$ dvc --generate-completion-script <shell> > /path/to/completion/_dvc
```

For example, I use ZSH with [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh), so
I run `dvc --generate-completion-script zsh > ~/.oh-my-zsh/completions/_dvc`.

It's important that you put the completion script in a file named `_dvc`. For
more information about this command, [see here](https://github.com/apple/swift-argument-parser/blob/master/Documentation/07%20Completion%20Scripts.md).

## Commands

### `dvc`

```
OVERVIEW: Manage cloned GitHub repos.

USAGE: dvc [--prefix] <subcommand>

OPTIONS:
  --prefix                Print the path of the directory that DVC manages.
  --version               Show the version.
  -h, --help              Show help information.

SUBCOMMANDS:
  clone                   Clone a repository.
  rm                      Remove a cloned repository.
  ls                      List the currently cloned repos.

  See 'dvc help <subcommand>' for detailed help.
```

### `dvc clone`

```
OVERVIEW: Clone a repository.

USAGE: dvc clone <repo>

ARGUMENTS:
  <repo>                  The repository to clone.
                          Can be a full URL: https://github.com/<account>/<repo>.git
                          or a shorthand: <account>/<repo>

OPTIONS:
  --prefix                Print the path of the directory that DVC manages.
  --version               Show the version.
  -h, --help              Show help information.
```

### `dvc ls`

```
OVERVIEW: List the currently cloned repos.

USAGE: dvc ls [--display <display>]

OPTIONS:
  --prefix                Print the path of the directory that DVC manages.
  --display <display>     Display repos as rows or columns. (default: rows)
  --version               Show the version.
  -h, --help              Show help information.
```

### `dvc rm`

```
OVERVIEW: Remove a cloned repository.

USAGE: dvc rm <repo> [--aggressive-clean]

ARGUMENTS:
  <repo>                  The repository to remove. Should be in the form <account>/<repo>

OPTIONS:
  --prefix                Print the path of the directory that DVC manages.
  --aggressive-clean      By default, DVC will remove an account directory if
                          it not longer contains anything after a repo removal.
                          However, this is blocked if the account directory
                          contains any files or subdirectories in it (whether
                          they are git repos or not). On MacOS systems, .DS_Store
                          files in the account directory may also cause this
                          behavior. Add this flag to remove the account directory
                          only if it doesn't contain any git repos, ignoring
                          other files and subdirectories.
  --version               Show the version.
  -h, --help              Show help information.
```

### Tip: Changing into a DVC Repo

Suppose `dvc ls` returns something like the following:

```shell script
$ dvc ls
foo/bar
someuser/somerepo
```

DVC can't directory change directories of your shell for you, but you can
execute a quick workaround. To change into `foo/bar` simply execute:

```shell script
$ cd $(dvc --prefix)/foo/bar
```

## Acknowledgements

As with most things that I have on GitHub, this program was meant to be a
personal project, but feel free to use DVC (subject to the terms of the MIT
license) if you find it useful, and also contribute if you like!

## Todo

I need to add tests, though it's tricky to write unit tests for executables in
Swift.
