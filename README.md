# emacs.d

This is a fork of
[a mentor's Emacs config](https://github.com/sandhu/emacs.d). The
changes to the core code are merely to update things for newer
versions or be less opinionated.

## Overriding configuration

In order to override parts of the configuration, create a directory
named the same as your user name in .emacs.d and add .el files
containing the overrides. All files in this directory will be loaded
after the rest of the configuration has been loaded.

## Requirements

* Emacs 25.1 or greater

## Installation

To install, clone this repo to `~/.emacs.d`, i.e. ensure that the
`init.el` contained in this repo ends up at `~/.emacs.d/init.el`.
Create a symlink from profiles.clj to `~/.lein/profiles.clj`.

The easiest way is to do this is:

````
git clone https://github.com/MatthewDarling/sandhu-emacs ~/.emacs.d
ln -s ~/.emacs.d/profiles.clj ~/.lein/profiles.clj
````

Upon starting up Emacs for the first time, the third-party packages
will be automatically downloaded and installed.

## References
This config has been heavily inspired by:
* Achint Sandhu - https://github.com/sandhu/emacs.d
