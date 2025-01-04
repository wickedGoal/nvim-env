# nvim-env
Isolated [lazy.nvim](https://github.com/folke/lazy.nvim) Neovim environment.

## Features

- All environments(plugins, configs) are stored in one working directory

## Usage

First, you make an environment in a new directory.
```bash
./init.sh
# creates a new environment in a new directory with given name
<env_name>/v.sh
```

You can add more pre-defined plugins to the environment.

```bash
./add_env.sh
```

After all is set, you can move the environment directory anywhere you want.
