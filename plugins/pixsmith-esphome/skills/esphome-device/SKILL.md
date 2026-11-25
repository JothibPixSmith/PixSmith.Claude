---
name: esphome-device
description: Create and edit ESPHome device YAML for ESP32/ESP8266 boards — sensors, filters and calibration, wifi/OTA/web server/API, secrets, and compiling/flashing/logging with the esphome CLI. Use when working in a repo with ESPHome YAML, adding a sensor or component, or when a build or upload fails.
---

# ESPHome devices

## Files

- One `<device-name>.yaml` per device at the repo root; `esphome: name:` matches the filename (lowercase, hyphens).
- `secrets.yaml` holds wifi credentials, API encryption keys, OTA passwords. It is **git-ignored** — never print its contents, never commit it. Reference values with `!secret key_name`.
- Keep a committed `secrets.example.yaml` with every key and placeholder values; update it whenever you add a `!secret`.
- `.esphome/` is build output and is git-ignored. Don't read or search inside it unless debugging the generated C++.
- Shared pieces (wifi, logger, OTA) go in `common/*.yaml` and are pulled in with `packages:` once there is more than one device.

## Writing config

- Check the component docs (esphome.io/components/…) for the current schema before using an option; ESPHome renames and removes options between releases (e.g. `ota:` is now a list of platforms).
- Give every sensor an `id:` if anything else references it; give user-facing entities a `name:`.
- Pin choice: on ESP32 use ADC1 pins (GPIO32–39) for analog when wifi is on — ADC2 is unavailable while wifi runs. GPIO34–39 are input-only.
- Calibration (`calibrate_linear`, `multiply`, `offset`) lives in `filters:` with a comment noting how the reference points were measured.
- Choose `update_interval` deliberately; very short intervals spam the API/logs.
- `api:` with `encryption: key: !secret api_key` if Home Assistant is used; otherwise `web_server:` / MQTT.
- Always keep `ota:` so devices can be updated without USB.

## CLI

```bash
esphome config <device>.yaml        # validate — run after every edit
esphome compile <device>.yaml
esphome upload <device>.yaml        # OTA if reachable, else asks for serial port
esphome run <device>.yaml           # compile + upload + logs
esphome logs <device>.yaml
```

`upload`/`run` change real hardware — ask before running them. `config` and `compile` are safe.

On Linux, serial upload needs the user in the `dialout` group (Fedora: `dialout`) for `/dev/ttyUSB*` / `/dev/ttyACM*`.
