
# Cloud Computing Lab 1

## Submitted To:
- Sir Shoaib
- Sir Waqas Saleem

## Submitted By:
- **Hamail Fatima**  
- Roll No: 2023-BSE-023  
- Section: 5(A)  

---

## Task 1: Installation of Ubuntu in VMware

### Steps:

1. **Download Ubuntu ISO**
   - Go to [https://ubuntu.com/download/server](https://ubuntu.com/download/server)
   - Choose the latest Ubuntu Server ISO and download it.

2. **Install VMware Workstation / VMware Player**
   - Download VMware Workstation or Player from the official VMware website.
   - Install it on your computer.

3. **Create a New Virtual Machine**
   - Open VMware → Click **"Create a New Virtual Machine"**.
   - Select **"Installer disc image file (ISO)"** and browse to the Ubuntu ISO you downloaded.
   - Click **Next**.

4. **Configure VM Settings**
   - Name: Ubuntu VM
   - Location: Choose a folder
   - Disk Size: At least **20 GB**
   - Memory (RAM): Allocate at least **2 GB (2048 MB)**
   - Processors: Minimum 1 (recommended 2 if available)

5. **Start the VM**
   - Click **"Power on this virtual machine"**.
   - Ubuntu installation will start.

6. **Follow Installation Wizard**
   - Choose **Language** (English recommended).
   - Select **"Install Ubuntu Server"**.
   - Configure **Keyboard Layout**.
   - Set **Hostname** (e.g., ubuntu-server).
   - Create a **Username and Password**.
   - Choose **"Guided – use entire disk"** for disk partitioning.
   - Continue installation until it finishes.

7. **Restart and Login**
   - After installation, restart the VM.
   - Login using the username and password you created.

8. **Check Internet Connection**
   - Open the terminal and type:
     ```bash
     ping google.com
     ```
   - If replies appear, internet is working.

---

✅ Ubuntu installation in VMware completed successfully!

```
