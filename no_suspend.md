# Suppress suspend on laptop lid close for Ubuntu

```console
$ sudo vi /etc/systemd/logind.conf
```

Change:

```
HandleLidSwitch=ignore
HandleLidSwitchDocked=ignore
```

```console
$ sudo systemctl restart systemd-logind
```
