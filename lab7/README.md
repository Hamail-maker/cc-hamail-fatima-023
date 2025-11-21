# Cloud Computing – Lab 7  
**Name:** Hamail Fatima  
**Roll No:** 023  
**Section:** 5A  
**Course:** Cloud Computing  

---

# **Lab 7 – Complete Documentation (Tasks 1–6 + Exam Evaluation Q1–Q4)**

This README contains all commands, explanations, and screenshot requirements for Lab 7 and the Exam Evaluation.

---

# --------------------------------------------------------------
# **Task 6 — Configure SSH Key-Based Login From Windows Host**
# --------------------------------------------------------------

## **Windows Host (Client)**

### **1. Generate ed25519 SSH Key**
**PowerShell:**
```powershell
ssh-keygen -t ed25519 -f $env:USERPROFILE\.ssh\id_lab7 -C "lab_key"
ls $env:USERPROFILE\.ssh
```
📸 Save screenshot as: **task6_windows_sshkey_and_list.png**

---

### **2. Display Public Key**
```powershell
type $env:USERPROFILE\.ssh\id_lab7.pub
```
📸 Save screenshot as: **task6_windows_public_key.png**

---

### **3. Clear known_hosts**
```powershell
Clear-Content $env:USERPROFILE\.ssh\known_hosts
type $env:USERPROFILE\.ssh\known_hosts
```
📸 Save screenshot as: **task6_windows_known_hosts_cleared_and_empty.png**

---

### **4. Connect to Ubuntu server**
```powershell
ssh hamail@192.168.114.129
```
- Accept host key (yes)
- Enter password

📸 Save screenshot: **task6_windows_ssh_accept_hostkey_and_login.png**

---

### **5. View known_hosts after connection**
```powershell
type $env:USERPROFILE\.ssh\known_hosts
```
📸 Save screenshot: **task6_windows_known_hosts_after_connect.png**

---

# **Ubuntu Server (Server-Side Steps)**

### **6. Prepare ~/.ssh directory**
```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
> ~/.ssh/authorized_keys
```
📸 Save screenshot: **task6_server_clear_authorized_keys.png**

---

### **7. Add Public Key**
Use your public key:

```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEBacn+hxPYWhO9VVR3TEnjdlThv+4QKAjqoXfVBcWNR lab_key
```

Run:
```bash
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEBacn+hxPYWhO9VVR3TEnjdlThv+4QKAjqoXfVBcWNR lab_key" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
cat ~/.ssh/authorized_keys
```
📸 Save screenshot: **task6_server_add_key_and_show.png**

---

### **8. Test passwordless SSH from Windows**
**PowerShell:**
```powershell
ssh hamail@192.168.114.129
```
📸 Save screenshot: **task6_ssh_passwordless_login.png**

---

### **9. Test explicit identity file**
```powershell
ssh -i $env:USERPROFILE\.ssh\id_lab7 hamail@192.168.114.129
```
📸 Save screenshot: **task6_ssh_with_identity_file.png**

---

# ===================================================================
# **EXAM EVALUATION QUESTIONS**
# ===================================================================

# --------------------------------------------------------------
# **Q1 — Quick Environment Audit**
# --------------------------------------------------------------

### **1. Show all environment variables**
**Ubuntu Terminal:**
```bash
printenv
```
📸 **EE_q1_env_all.png**

---

### **2. Show PATH, LANG, PWD**
```bash
echo $PATH
echo $LANG
echo $PWD
```
📸 **EE_q1_env_filters.png**

---

# --------------------------------------------------------------
# **Q2 — Short-Lived Student Info (Temporary Vars)**
# --------------------------------------------------------------

### **1. Set variables**
```bash
export STUDENT_NAME="Hamail"
export STUDENT_ROLL_NUMBER="023"
export STUDENT_SEMESTER="5A"
```
📸 **EE_q2_exports.png**

---

### **2. View variables**
```bash
echo $STUDENT_NAME
echo $STUDENT_ROLL_NUMBER
echo $STUDENT_SEMESTER
```
📸 **EE_q2_echoes.png**

---

### **3. printenv with grep**
```bash
printenv | grep STUDENT_
```
📸 **EE_q2_printenv_grep.png**

---

### **4. After terminal restart (variables disappear)**
```bash
echo $STUDENT_NAME
printenv | grep STUDENT_
```
📸 **EE_q2_after_restart.png**

---

# --------------------------------------------------------------
# **Q3 — Make Variables Persistent (Add to ~/.bashrc)**
# --------------------------------------------------------------

### **1. Edit ~/.bashrc**
```bash
nano ~/.bashrc
```

Add at bottom:
```bash
export STUDENT_NAME="Hamail"
export STUDENT_ROLL_NUMBER="023"
export STUDENT_SEMESTER="5A"
```

📸 **EE_q3_bashrc_editor.png**

---

### **2. Reload & verify**
```bash
source ~/.bashrc
echo $STUDENT_NAME
echo $STUDENT_ROLL_NUMBER
echo $STUDENT_SEMESTER
printenv | grep '^STUDENT_'
```
📸 **EE_q3_after_source.png**

---

### **3. Restart terminal & verify persistence**
```bash
echo $STUDENT_NAME
printenv | grep '^STUDENT_'
```
📸 **EE_q3_after_restart.png**

---

# --------------------------------------------------------------
# **Q4 — Firewall: Block & Allow Ping (ICMP)**
# --------------------------------------------------------------

### **1. Enable UFW**
```bash
sudo ufw enable
sudo ufw status
```
📸 **EE_q5_ufw_enable_status.png**

---

### **2. Block ping**
```bash
sudo ufw deny proto icmp from any to any
sudo ufw status numbered
```
📸 **EE_q5_ufw_deny_ping_status.png**

---

### **3. Ping test from Windows**
**PowerShell:**
```powershell
ping 192.168.114.129
```
Blocked → 📸 **EE_q5_ping_blocked.png**

---

### **4. Allow ping**
```bash
sudo ufw allow proto icmp from any to any
sudo ufw reload
sudo ufw status
```
📸 **EE_q5_ufw_allow_ping_status.png**

---

### **5. Ping test again (success)**
**PowerShell:**
```powershell
ping 192.168.114.129
```
📸 **EE_q5_ping_success.png**

---

# 🎉 End of README — All Tasks and Exam Evaluation Completed
