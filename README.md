


# 🌍 Seeker — One-Command Auto Installer (Ubuntu / Azure VM)

> **For Educational & Lab Use Only**  
> This repository provides a one-command installer for [thewhiteh4t/seeker](https://github.com/thewhiteh4t/seeker) —  
> a geolocation-aware web lab used to study browser location APIs and user consent behavior.

---

## ⚙️ Features

✅ One-line installation for Ubuntu (22.04 / 24.04)  
✅ Auto-setup Python venv + dependencies  
✅ PHP + Flask installed automatically  
✅ HTTPS tunneling via [localhost.run](https://localhost.run) (no signup needed)  
✅ Works great on Azure VM, VirtualBox, VMware, or local Ubuntu  

---

## 🧠 1. Install (One-Line Setup)

```bash
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/PleaseCompile/seeker-installer/main/install_all.sh)"
````

> 🧩 *This command will automatically:*
>
> * update system packages
> * install `git`, `python3`, `php`, and related dependencies
> * clone `seeker`
> * create Python virtual environment
> * install `requests`, `packaging`, `psutil`, `flask`, `pyngrok`
> * ready to run immediately

If you already cloned this repository manually:

```bash
git clone https://github.com/<YOUR_GITHUB_USER>/<YOUR_REPO_NAME>.git
cd <YOUR_REPO_NAME>
sudo bash install_all.sh
```

---

## 🚀 2. Run Seeker

```bash
cd ~/seeker
source .venv/bin/activate
python3 seeker.py
```

Select a template (e.g. `[0] NearYou`, `[7] Custom Link Preview`) and wait until you see:

```
[+] Starting PHP Server... [ ✔ ]
[+] Waiting for Client...[ctrl+c to exit]
```

---

## 🌐 3. Open Your Lab Publicly (HTTPS via localhost.run)

From a **new terminal** on the same VM:

```bash
ssh -R 80:127.0.0.1:8080 nokey@localhost.run
```

You’ll receive a message like:

```
Forwarding HTTP traffic from https://abcd-1234.lhr.life
```

Copy that HTTPS URL and open it on your **mobile phone browser** (not VPNed).

When prompted:

> **Allow this site to access your location?**
> Tap **Allow**

---

## 📱 4. Verify the Result

Back on your VM (where Seeker runs), you’ll see output like:

```
[+] Public IP  : 1.47.139.231
[+] Country    : Thailand
[+] City       : Bangkok
[+] Latitude   : 13.7563
[+] Longitude  : 100.5018
[+] Accuracy   : 8.34 m
[+] Google Maps: https://maps.google.com/?q=13.7563,100.5018
```

Result data is also saved to:

```bash
~/seeker/db/results.csv
```

Check logs anytime:

```bash
tail -n 50 ~/seeker/db/results.csv
```

---

## 🧰 5. Optional Tools

### 🔁 Make tunnel persistent (auto reconnect)

Install [autossh](https://www.harding.motd.ca/autossh/):

```bash
sudo apt install -y autossh
autossh -M 0 -N -R 80:127.0.0.1:8080 nokey@localhost.run
```

### 🧱 Remove everything (reset lab)

```bash
deactivate 2>/dev/null || true
cd ~ && rm -rf seeker
```

---

## 📖 6. Summary Commands

| Purpose             | Command                                                         |
| ------------------- | --------------------------------------------------------------- |
| Install all         | `sudo bash install_all.sh`                                      |
| Run seeker          | `cd ~/seeker && source .venv/bin/activate && python3 seeker.py` |
| Create HTTPS tunnel | `ssh -R 80:127.0.0.1:8080 nokey@localhost.run`                  |
| View results        | `tail -n 50 ~/seeker/db/results.csv`                            |
| Reset everything    | `rm -rf ~/seeker`                                               |

---

## ⚠️ Legal & Ethical Notice

Seeker is a **research and educational tool**.
You may **only** use it in a controlled lab environment, on your own devices, or with explicit permission.
Unauthorized collection of geolocation data may violate privacy laws such as **PDPA** / **GDPR**.

---

## 🧩 Credits

* Project: [thewhiteh4t/seeker](https://github.com/thewhiteh4t/seeker)
* Maintainer of this installer: [@PleaseCompile](https://github.com/PleaseCompile)
* Tunnel: [localhost.run](https://localhost.run)

---

### 💡 Example Usage Flow (for lab testing)

1. Deploy VM on Azure
2. Run one-line installer
3. Run `python3 seeker.py`
4. Start tunnel: `ssh -R 80:127.0.0.1:8080 nokey@localhost.run`
5. Open HTTPS link on your phone
6. Allow location → check results

🎯 Done — end-to-end Seeker lab setup in under 3 minutes!

````

---

