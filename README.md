# d2

A system utility tool to provide easy cloning, access, and management for projects. [Inspired by the `dev` tool at Shopify](https://devproductivity.io/dev-shopifys-all-purpose-development-tool/index.html).

WIP.

## How to Install?

1. Add `source /path/to/d2/exe/d2.sh` to your `.bash_profile`, `.bashrc`, `.zshrc`, etc.
2. Restart your terminal.
3. Run `d2 help` to see what is available.

## Caveats

Assumes that all code is managed in a Go-Compatible way.

When you first start `d2`, it will ask for a `base_path`. `base_path` is your `GO_HOME` in this case, or in other words where your code is stored.

The code is organized in `base_path/PROVIDER/ORG/REPO`. For example, this repo would be found at `base_path/github.com/jules2689/d2`. A BitBucket repo called `my_repo` under the user `jane` would be found at `base_path/bitbucket.org/jane/my_repo`.

This makes sure everything can work nicely with `Go` if you need to. It also keeps things nicely organized to avoid filesystem slowdowns in the case you have many repos cloned.

`d2 clone` will clone based on this schema, and `d2 cd` will change directory based on this schema.
