# Userspace Apache + mod_wsgi installer

This is an Apache + mod_wsgi installer.
No compilation is performed - this uses system binaries.

Installation is performed as follows:

    vim config
    ./install.bash

The "`vim config`" step is to set the following options in the **`config`** file:

  - **`STACKNAME`**: The name of this Apache + mod_wsgi stack (usually the same as the "Proxy Port" application name)
  - **`PREFIX`**: The install location where the stack will be installed (usually $HOME/apps/$STACKNAME)
  - **`PORT`**: The port associated with the Proxy Port app created via the Control Panel
  - **`DOMAIN1`**: The domain name that the stack will serve. *(you can add more later in `httpd.conf`)*
  - **`APPDIR1`**: The path to the website files that the stack will serve *(you can add more later with virtualhosts)*

After installation, the following are done for you:

  - `start`, `stop`, and `restart` scripts are created in the `$PREFIX/bin` directory
  - The `start` script is run to start the instance
  - A cronjob is created to start the instance once every 10 minutes if it's not running
