# Turris Omnia LXC init
Scripts to simplify creating LXC containers on [Turris Omnia] router.

## Usage
1. define env vars
    - Linux distribution
        ```sh
        $ export lxc_dist=Alpine
        ```
    - release version of aforementioned Linux distribution
        ```sh
        $ export lxc_release=Edge
        ```
    - MAC address to be given to container (i.e. for assigning stable IP/hostname)
        ```sh
        $ export lxc_mac='92:61:34:CE:55:F1'
        ```
    - name of container (is set as hostname in it too)
        ```sh
        $ export lxc_app=redis
        ```
1. in `./${lxc_app}/`, create any files that should be copied inside the container after its creation \
If there is `./${lxc_app}/usr/sbin/init.sh` executable file it will be run inside the container after it is created.
1. run the script
    ```sh
    $ ./init-container.sh
    ```

[turris omnia]: <https://www.turris.com/en/omnia/>
