# Turris Omnia LXC init
Scripts to simplify creating LXC containers on [Turris Omnia] router.

## Usage
1. define env vars
    - Linux distribution
        ```sh
        $ export lxc_dist=Debian
        ```
    - release version of aforementioned Linux distribution
        ```sh
        $ export lxc_release=Bookworm
        ```
    - name of container (is set as hostname in it too)
        ```sh
        $ export lxc_app=my-app
        ```
    - OPTIONAL: MAC address to be given to container (i.e. for assigning stable IP/hostname)
        ```sh
        $ export lxc_mac='XX:XX:XX:XX:XX:XX:'
        ```
1. OPTIONAL: \
in `./${lxc_app}/`, create any files that should be copied inside the container after its creation \
If there is `./${lxc_app}/usr/sbin/init.sh` executable file it will be run inside the container after it is created. \
If there is `./${lxc_app}/usr/sbin/post-init.sh` executable file it will be run inside the container after init is finished and container rebooted.
1. run the script
    ```sh
    $ ./init-container.sh
    ```

[turris omnia]: <https://www.turris.com/en/omnia/>
