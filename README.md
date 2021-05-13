# nbdevCI
> CI tools for nbdev projects

## Uses
Use in a `.github/workflows` file.  There are a few different patterns you can use to invoke the script.


No docker is used in testing

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: nbdev CI steps
      uses: talosiot-will/nbdevCI@master
```


Docker is used in testing.  Because we don't support docker-in-docker we have to use the scripts directly.
```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Clone nbdevCI
      run: git clone https://github.com/talosiot-will/nbdevCI.git nbdevCI

    - name: Install requirements
      run: nbdevCI/install_requirements
    - name: Run nbdevCI
      run: nbdevCI/entrypoint.sh
    - name: Remove nbdevCI
      run: rm -rf nbdevCI
```

This will attempt to clone private repos by grabbing deploy keys from AWS secrets (see https://github.com/talosiot/vera).

## Notes
- Dont use this to distribute docker images to untrusted people.  It may be possible to get your deploykeys from the docker layers.  I have not tested this attack.

- This will not work with using other docker containers in the test procedure (e.g https://github.com/talosiot/scylla) because it does not support docker-in-docker (dind)
