# batch-queries-postgresql

## Pre-requisite

### OS

Check if you'll use :
- linux : good;
- MacOS : okay ; 
- Windows : be prepared for some difficulties with environment variables.

### Virtualisation

Check if you'll use :
- native docker engine / docker desktop : good;
- colima : you may not been able to resize your VM;
- orbstack : okay.


### Postgresql local instance

If you have PostgreSQL installed locally (as linux service in systemd), stop or deactivate (or uninstall) it.

## Install

### terminal

We'll use the terminal extensively.

If you use the terminal in your IDE (Vscode, IntelliJ), you may have trouble with so much windows. 

In Linux, I'll use [Terminator](https://github.com/gnome-terminator).

```shell
sudo apt install terminator
```

It is available in MacOS too.
```shell
brew install terminator
```

If you want to stock to native MacOS terminal, `ITerm`, make you're able to create tab and split your screen.

### curl

We'll use [curl](https://curl.se) once to download a dump file.

Linux
```shell
sudo snap install curl
```

MacOS
```shell
brew install curl
```

[Windows](https://curl.se/windows/)

### docker and docker-compose

You'll need to install [docker and docker-compose](https://docs.docker.com/engine/install/), at least version.

If using prior versions, you'll the following error message.
```shell
docker: 'compose' is not a docker command.
```

### psql client

`psql` is a command-line client for Postgresql, used extensively here.

It's distributed with the the database client, but we'll need the standalone version. 

`psql` can be installed in MacOS from `libpq` package.
```shell
brew install libpq
echo 'export PATH="/opt/homebrew/opt/libpq/bin:$PATH"' >> ~/.zshrc
```

`psql` can be installed in linux from `postgresql-client` package.
```shell
sudo apt-get install -y postgresql-client
```

### direnv

We'll use `direnv` to load environement variables. 

In Linux and MaxOS, `direnv` is easily integrated with `oh-my-zsh`.

Install `direnv` with brew.
````shell
brew install direnv
````

Add `direnv` plugin.
````shell
brew install direnv
vi ~/.zshrc   
plugins+=(direnv)
````

You can skip allowing changes by using `whitelist`.
```shell
mkdir ~/.config/direnv
cp direnv.toml ~/.config/direnv/direnv.toml
vi ~/.config/direnv/direnv.toml
```

### watch

To repeat a command, we'll use `watch`.

It's already install in Linux.

MacOS
```shell
brew install watch
```

### just

To launch long command many times, we'll use [just](https://github.com/casey/just?tab=readme-ov-file#installation).

Linux
```shell
snap install --edge --classic just
```

MacOS
````shell
brew install just
````

## Resources and collaboration

Create a [GitHub](https://github.com/) account.

Create an SSH key and upload it to GitHub.

Ask the owner of this repository to be added as a collaborator, so you can create your own branch.

Clone this repository.
```shell
git clone git@github.com:GradedJestRisk/batch-queries-postgresql.git
```

Create a branch.
```shell
git switch --create mybranch
```

Try rebasing.
```shell
git fetch
git rebase origin/main
```

You'll need some configuration.
```shell
git config --local include.path "$PWD/.gitconfig"
```