A socket-activated in.fingerd equivalent written in Rust.

## Why?

The usual answer: why not?

## How?

See [nix](nix/) for how I actually run this, or something like:

```ini
# /etc/systemd/system/ringer@.service

[Unit]
Description=Ringer service
Requires=ringer.socket

[Service]
DynamicUser=yes
ExecStart=-/path/to/where/you/put/this/bin/fingerd
ProtectHome=true
StandardInput=socket
StandardOutput=socket

# The files end up under /var/lib/ringer if you do this
StateDirectory=ringer
```

```ini
# /etc/systemd/system/ringer.socket

[Socket]
Accept=yes
ListenStream=79
```
