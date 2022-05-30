# Generic Jupyter Lab Template

Jupyter Lab generic template

## Jupyter Server Password
Default is `jupyterlab`.
Note: the jupyter server is exposed to local network at `<host-ip>:8886`.

### How to change Jupyter Server password
Change the hash in `config.json`.

To create a new hashed password:
```python
from notebook.auth import passwd

passwd(algorithm='sha1')
```

you need to install the python module **notebook** with
```pip install notebook```


## Project Structure

```text
 /project-root
 |- data
 |- notebooks
 |- source
```
