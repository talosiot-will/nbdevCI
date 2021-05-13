- Dont use this to distribute docker images to untrusted people.  It may be possible to get your deploykeys from the docker layers

- This will not work with using other docker containers in the test procedure (e.g https://github.com/talosiot/scylla) because it does not support docker-in-docker (dind)
