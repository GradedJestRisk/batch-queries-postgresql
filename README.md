# batch-queries-postgresql

## Pre-requisite

Check if you'll use :
- linux : good;
- MacOS: okay ; 
- Windows: be prepared for some difficulties.

Create a Github account. 

Ask the owner to be added as a collaborator.

Create an SSH key.

Clone the repository.

Create a branch. 
```shell
git switch --create mybranch
```

Try rebasing
```shell
git fetch
git rebase origin/main
```

## Install

If you have PostgreSQL installed locally (as service), stop/deactivate/uninstall it.

Install
- [curl]()
- [git](https://git-scm.com/)
- [docker and docker-compose](https://docs.docker.com/engine/install/) > v
- [psql client](https://askubuntu.com/questions/1040765/how-to-install-psql-without-postgres)
- [direnv](https://direnv.net/)

`psql` can be install in MacOS through `libpq`.
```shell
brew install libpq
echo 'export PATH="/usr/local/opt/libpq/bin:$PATH"' >> ~/.zshrc
```

## direnv

`direnv` can be installed easily with `oh-my-zsh` plugin for `direnv`.
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

## docker-compose

If you get an error message
```shell
docker compose up
`compose` is not a docker command.
```

Make sure `docker compose` is available by upgrading docker.

## Install extras

Install :
- [glances](https://github.com/nicolargo/glances)
- [just](https://github.com/casey/just)


````shell
brew install just
````