#!/bin/bash

make_runfile_linux() {
  touch $env_name/v.sh
  chmod +x $env_name/v.sh
  echo "#!/bin/bash" >>$env_name/v.sh
  echo "" >>$env_name/v.sh
  echo "export BASE_DIR=\$(dirname \$(readlink -f \"\$0\"))" >>$env_name/v.sh
  echo "" >>$env_name/v.sh
  echo "export NVIM_APPNAME=$env_name" >>$env_name/v.sh
  echo "" >>$env_name/v.sh
  echo "export XDG_CONFIG_HOME=\$BASE_DIR/.config" >>$env_name/v.sh
  echo "export XDG_DATA_HOME=\$BASE_DIR/.local/share" >>$env_name/v.sh
  echo "export XDG_STATE_HOME=\$BASE_DIR/.local/state" >>$env_name/v.sh
  echo "export NVIM_LOG_FILE=\$BASE_DIR/.local/state/\$NVIM_APPNAME/log" >>$env_name/v.sh
  echo "" >>$env_name/v.sh
  echo "nvim \"\$@\"" >>$env_name/v.sh
}

make_runfile_windows() {
  touch $env_name/v.ps1
  cat <<EOF >>$env_name/v.ps1
& {
\$BASE_DIR = \$PSScriptRoot

\$env:NVIM_APPNAME="flutter-nvenv"

\$env:XDG_CONFIG_HOME= Join-Path \$BASE_DIR ".config"
\$env:XDG_DATA_HOME= Join-Path \$BASE_DIR ".local\\share"
\$env:XDG_STATE_HOME= Join-Path \$BASE_DIR ".local\\state"
\$env:NVIM_LOG_FILE= Join-Path \$BASE_DIR ".local\\state\\\$NVIM_APPNAME\\log"
}

& nvim.exe \$args
EOF

}

make_init_lua() {
  touch $env_name/.config/$env_name/init.lua
  echo "require('config.lazy')" >>$env_name/.config/$env_name/init.lua
}

make_lazy_lua_install_part() {
  touch $env_name/.config/$env_name/lua/config/lazy.lua
  cat <<EOF >>$env_name/.config/$env_name/lua/config/lazy.lua
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup \$(mapleader) and \$(maplocalleader) before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = " "
EOF

}

make_lazy_lua_setup_part() {
  cat <<EOF >>$env_name/.config/$env_name/lua/config/lazy.lua

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- import your plugins
    { import = "plugins" },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },

  -- automatically check for plugin updates
  -- checker = { enabled = true },
})
EOF
}

make_tokyonight_plugin() {
  touch $env_name/.config/$env_name/lua/plugins/tokyonight.lua
  cat <<EOF >>$env_name/.config/$env_name/lua/plugins/tokyonight.lua
return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		init = function()
			vim.cmd.colorscheme("tokyonight")
		end,
	},
}
EOF
}

read -p "Do you want to init a vim environment? (Y/n) " answer

if [[ -z $answer ]]; then
  answer="Y"
fi

# Doesn't work on zsh
# if [[ ${answer,,} = "y" ]]; then
if [[ "$answer" == "Y" ]] || [[ "$answer" == "y" ]]; then
  read -p "What is the name of your vim environment? " env_name

  if [ $env_name ]; then
    echo "Creating environment $env_name"
    mkdir $env_name
    INIT_BASE_DIR=$(dirname $(readlink -f "$0"))
    mkdir -p $env_name/.config/$env_name/lua/config
    mkdir -p $env_name/.config/$env_name/lua/plugins
    make_runfile_linux
    make_runfile_windows
    make_init_lua
    make_lazy_lua_install_part
    make_tokyonight_plugin

    read -p "Do you want to install minimal options/keymaps? (Y/n) " core_answer

    if [[ -z $core_answer ]]; then
      core_answer="Y"
    fi

    if [[ "$core_answer" == "Y" ]] || [[ "$core_answer" == "y" ]]; then
      echo "Installing minimal options/keymaps..."
      cp -r $INIT_BASE_DIR/envs/core/* $env_name/.config/$env_name/lua
      cat <<EOF >>$env_name/.config/$env_name/lua/config/lazy.lua

require("config.options")
require("config.keymaps")
EOF
    else
      echo "Skipping core packages..."
    fi

    make_lazy_lua_setup_part

    read -p "Do you want to install additional plugins? (Y/n) " plugins_answer

    if [[ -z $plugins_answer ]]; then
      plugins_answer="Y"
    fi

    if [[ "$plugins_answer" == "Y" ]] || [[ "$plugins_answer" == "y" ]]; then
      RUNNING_DIR=$env_name . $INIT_BASE_DIR/add_env.sh
      echo -e '\n'
    fi

    echo "Done! Run $env_name/v.sh"
  else
    exit 0
  fi

else
  exit 0
fi
