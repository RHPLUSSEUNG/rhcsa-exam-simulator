# Reference solution — Configure a user-scoped Flatpak remote and application

Both remote creation and installation must run as student with --user. A system-wide install does not satisfy this exercise. The offline fixture tests scope and origin without requiring Flathub access.

```bash
home="$(getent passwd student | cut -d: -f6)"
runuser -u student -- env HOME="$home" flatpak --user remote-add --if-not-exists --no-gpg-verify flatdb file:///opt/rhcsa-b04/flatpak/repo
runuser -u student -- env HOME="$home" flatpak --user install -y flatdb com.example.CodiumPractice
```

## Verify

```bash
runuser -u student -- env HOME="$home" flatpak --user remotes
runuser -u student -- env HOME="$home" flatpak --user list --app
```
