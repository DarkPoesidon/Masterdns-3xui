# MasterDNS + 3x-ui Installer

Beginner-friendly installer and manager for running MasterDnsVPN and the original 3x-ui/Xray panel on the same Linux server.

## Easy Install

Run this on a fresh Linux server as a sudo/root user:

```bash
sudo bash <(curl -Ls https://raw.githubusercontent.com/DarkPoesidon/Masterdns-3xui/main/install.sh)
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

The combined manager also has:

```text
2) Open original 3x-ui admin menu
3) WARP Management
```

## WARP

WARP is optional. It is not enabled by default.

Open:

```bash
sudo masterdns-3xui
```

Then choose:

```text
3) WARP Management
1) Turn WARP ON for both MasterDNS and 3x-ui
```

The manager will:

- create or reuse a Cloudflare WARP account for 3x-ui,
- add an Xray `wireguard` outbound tagged `warp`,
- add a local-only SOCKS bridge on `127.0.0.1:40000` for MasterDnsVPN,
- set MasterDnsVPN to use that SOCKS bridge,
- restart services,
- let you test the public IP path.

You can turn WARP off from the same menu.

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
