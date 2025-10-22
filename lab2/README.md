# 💻 LAB 2 – Hands-On Git & Version Control

**Name:** Hamail Fatima  
**Reg No:** 2023-BSE-023  
**Class:** BSE-5A  
**Subject:** CC  
**Lab Title:** Hands-On Git & Version Control Lab  

---

## 🧩 Task Overview
This lab demonstrates essential Git and GitHub operations — from installation to repository management, branching, merging, and collaboration.

---

## 🧰 Task 1: Install Git
Download and install Git for your operating system from the official website:  
🔗 [https://git-scm.com/downloads](https://git-scm.com/downloads)

---

## 🗂️ Task 2: Create a Private GitHub Repository
- Create a **new private repository** on GitHub named **`Lab2`**.

---

## 🔑 Task 3: Connect Repository via SSH
1. Generate a new SSH key using PowerShell:
   ```bash
   ssh-keygen -t ed25519 -C "your_email@example.com"
   ```
2. Add your SSH public key to GitHub:  
   **Settings → SSH and GPG Keys → New SSH Key**
3. Clone your repository using SSH:
   ```bash
   git clone git@github.com:<yourusername>/Lab2.git
   ```

---

## 🧭 Task 4: Explore the `.git` Folder
1. Navigate into your cloned repository folder.  
2. Show hidden files and locate the `.git` directory.  
3. Explore its contents:
   ```bash
   ls -a .git
   ```
⚠️ **Note:** Do not modify `.git` contents manually; it stores your repository’s history and configuration.

---

## 🧾 Task 5: Configure Git Username and Email
1. Set up your Git identity:
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your_email@example.com"
   ```
2. Verify configuration:
   ```bash
   git config --list
   ```

---

## 🗃️ Task 6: Local Repository Management
1. Delete the existing `.git` folder:
   ```bash
   rm -rf .git
   ```
2. Reinitialize the Git repository:
   ```bash
   git init
   ```
3. Add and commit a README file:
   ```bash
   echo "# Lab2 Git Practice" > README.md
   git add README.md
   git commit -m "Initial commit"
   ```
4. Connect to remote repository and push:
   ```bash
   git remote add origin git@github.com:<yourusername>/Lab2.git
   git push -u origin main
   ```

---

## 📝 Task 7: File Status & Staging
1. Create a file `notes.txt` and write some notes.  
2. Check file status:
   ```bash
   git status
   ```
3. Stage and commit:
   ```bash
   git add notes.txt
   git commit -m "Add notes.txt"
   ```
4. Edit `notes.txt` again and repeat commit steps.

---

## 🌿 Task 8: Branch Creation Using GitHub GUI
1. On GitHub, create a branch named **`bugfix/user-auth-error`**.  
2. Pull the branch locally:
   ```bash
   git pull origin bugfix/user-auth-error
   ```

---

## 🌱 Task 9: Branch Creation and Push Using Git Bash
1. Create a branch named **`feature/db-connection`**:
   ```bash
   git checkout -b feature/db-connection
   ```
2. Push the branch to remote:
   ```bash
   git push origin feature/db-connection
   ```

---

## 🔀 Task 10: Branching & Merging
1. Create and switch to a new branch:
   ```bash
   git checkout -b feature-1
   ```
2. Modify `main.py` (add a function) and commit:
   ```bash
   git add main.py
   git commit -m "Add new function to main.py"
   ```
3. Merge changes into main:
   ```bash
   git checkout main
   git merge feature-1
   ```
4. Push both branches:
   ```bash
   git push origin main
   git push origin feature-1
   ```

---

## 🔁 Task 11: Pull Request and Branch Review (GitHub GUI)
1. Create a **Pull Request** from `feature/db-connection` → `main`.  
2. Review and merge the Pull Request via GitHub GUI.  
3. Delete the merged branch (`feature/db-connection`) after merging.

---

## 🧠 Task 12: Detailed Branch Strategy
Create the following branches to simulate a professional Git workflow:
- `develop`
- `staging`
- `feature/*`
- `bugfix/*`

---

## 🤝 Bonus Task: Simulated Team Collaboration
1. Create a branch named **`collab`**.  
2. Add a collaborator to your GitHub repo.  
3. Both users:
   - Pull the latest changes.
   - Add their name and a fun fact to `notes.txt`.
   - Commit and push to `collab` branch.
4. Merge collaboration branch into main:
   ```bash
   git checkout main
   git merge collab
   git push origin main
   ```

---

## 📤 Submission
Ensure your repository contains:
- All commits, branches, and merges as per tasks.
- Proper commit messages.
- Final push to **`main`** branch.

---

**✅ End of Lab 2 – Git & Version Control**

