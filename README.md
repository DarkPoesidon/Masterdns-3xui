# MasterDNS + 3x-ui Installer

Beginner-friendly installer and manager for running MasterDnsVPN and the original 3x-ui/Xray panel on the same Linux server.

## Easy Install

Run this on a fresh Linux server as a sudo/root user:

```bash
curl -fsSL https://raw.githubusercontent.com/DarkPoesidon/Masterdns-3xui/main/install.sh -o /tmp/masterdns-3xui-install.sh && sudo bash /tmp/masterdns-3xui-install.sh
```

The installer will:

- install required dependencies automatically,
- install the original 3x-ui panel,
- install MasterDnsVPN,
- install the combined manager command.

After it finishes, open the combined menu:

```bash
sudo masterdns-3xui
```

Do not type menu numbers like `3` directly in the Linux shell. First open the manager with `sudo masterdns-3xui`, then choose the menu number inside the manager.

For certificate, domain, panel, firewall, and other 3x-ui settings, open the original 3x-ui admin menu:

```bash
sudo x-ui
```

Use the original 3x-ui menu for certificate, domain, panel port, firewall, logs, and Xray management:

```text
19) SSL Certificate Management
20) Cloudflare SSL Certificate
22) Firewall Management
23) SSH Port Forwarding Management
```

The combined manager also has MasterDnsVPN service/config tools and optional WARP/SOCKS routing for MasterDnsVPN only:

```text
2) MasterDnsVPN service
3) MasterDnsVPN config, domain, key, backups
4) WARP / SOCKS for MasterDnsVPN only
```

## WARP

WARP is optional. It is not enabled by default.

Open:

```bash
sudo masterdns-3xui
```

Then choose:

```text
4) WARP / SOCKS for MasterDnsVPN only
1) Enable MasterDnsVPN through Cloudflare WARP
```

The manager will:

- install and register the official Cloudflare WARP Linux client,
- set WARP to local proxy mode on `127.0.0.1:40000`,
- set MasterDnsVPN to use that local WARP SOCKS proxy,
- restart MasterDnsVPN,
- let you test the public IP path.

It does not enable WARP for 3x-ui. Use the original 3x-ui panel if you want 3x-ui routing changes.

If you previously used an older version of this manager and Xray does not start, update the manager and clean the old generated 3x-ui WARP entries:

```bash
curl -fsSL https://raw.githubusercontent.com/DarkPoesidon/Masterdns-3xui/main/masterdns-3xui -o /usr/local/bin/masterdns-3xui && chmod +x /usr/local/bin/masterdns-3xui
sudo masterdns-3xui clean-xui-warp
```

## Ports

MasterDnsVPN uses:

```text
53/udp
53/tcp
```

3x-ui uses its own panel port, usually generated during the original 3x-ui install. User-created Xray/V2Ray inbounds use the ports you create in the panel.

Do not create a 3x-ui/Xray inbound on port `53`, because MasterDnsVPN needs it.

## Service Commands

```bash
sudo systemctl status x-ui
sudo systemctl status masterdnsvpn
sudo journalctl -u x-ui -f
sudo journalctl -u masterdnsvpn -f
```
