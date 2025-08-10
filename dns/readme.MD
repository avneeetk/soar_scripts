# Domain Blocking Script – Windows Test Guide

##  Overview

This script edits the Windows **hosts** file to block a given domain by mapping it to `127.0.0.1`.
It is intended **for testing purposes** and requires **Administrator privileges** to modify the hosts file.

---

##  Requirements

* **Windows 10/11**
* **MinGW** or another C compiler installed (e.g., TDM-GCC, Visual Studio Build Tools)
* Script file (`block_domain.c`)

---

##  Steps to Compile and Run

### 1. **Open Command Prompt as Administrator**

* Press `Windows` → search **cmd** → Right-click → **Run as administrator**
* This is required because the script edits the protected `C:\Windows\System32\drivers\etc\hosts` file.

---

### 2. **Navigate to Script Location**

```cmd
cd path\to\your\script
```

---

### 3. **Compile the Script**

If you have MinGW installed:

```cmd
gcc block_domain.c -o block_domain.exe
```

---

### 4. **Run the Script**

```cmd
block_domain.exe example.com
```

Replace `example.com` with the domain you want to block.

---

##  How It Works

1. Opens the hosts file:

```
C:\Windows\System32\drivers\etc\hosts
```

2. Checks if the domain is already blocked.
3. If not, appends:

```
127.0.0.1 example.com
```

4. Flushes the Windows DNS cache:

```cmd
ipconfig /flushdns
```

---

##  How to Verify the Block

1. **Ping the Domain**:

```cmd
ping example.com
```

Expected result (blocked):

```
Pinging example.com [127.0.0.1] with 32 bytes of data:
Reply from 127.0.0.1: bytes=32 time<1ms TTL=128
```

2. **Browser Test**:

* Clear browser cache.
* Open the domain — it should fail to load.

---

##  How to Unblock

1. Open the hosts file in Notepad as Administrator:

```cmd
notepad C:\Windows\System32\drivers\etc\hosts
```

2. Remove the line:

```
127.0.0.1 example.com
```

3. Save the file and flush DNS:

```cmd
ipconfig /flushdns
```

**Disclaimer:**
Editing the real hosts file affects all applications on your PC. Use a **mock hosts file path** for safe testing if you don’t want to make permanent changes.