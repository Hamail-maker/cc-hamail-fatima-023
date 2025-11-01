Name: Hamail Fatima
Roll No: 2023-BSE-023

🧪 Lab 5 – Java, apt vs apt-get, snap, GUI, Vim on Ubuntu Server
Estimated Duration: 3 hours
Instructions: Complete all practical tasks in a repository named Lab5. When finished, push your work to a repository named CC_<student_Name>_<student_roll_number>.

🎯 Objective
This lab demonstrates package discovery and management on an Ubuntu Server (CLI) and installing/configuring a lightweight GUI for remote access. You will:

Discover how the system suggests packages when a command is not installed (example: java).
Install and remove Java using both apt and apt-get.
Learn the difference between apt update and apt upgrade.
Install an application with snap on a headless server and verify installation.
Install and configure a lightweight GUI (XFCE) and XRDP for remote desktop access, and control GUI login behavior at boot.
Launch and visually verify Visual Studio Code in the GUI (Task 5 & Task 6).
Add a third‑party apt repository and signing key to install Google Chrome (Task 7).
Add PPAs and install GUI apps (Task 8).
Create a simple Kubernetes Pod manifest using vim (Task 9).
Edit the Kubernetes manifest to add an annotation and practice discarding edits (Task 10).
Practice basic vim editing commands (Task 11).
Practice vim search, navigation, substitution and undo (Task 12).
By the end of this lab you will be able to:

Follow the package suggestion workflow when a command is missing.
Install and remove packages with apt and apt-get, and clear terminal command caches.
Distinguish apt update from apt upgrade.
Install snap packages on a headless server and verify installation.
Install and configure XFCE + XRDP and control whether the system boots to GUI or CLI.
Start the GUI, launch VS Code (installed earlier), visually confirm it opens.
Add third‑party apt sources and keys to install Google Chrome and other apps via PPA.
Use vim to create and save a Kubernetes sample YAML file and practice adding annotations, discarding edits, and basic navigation/undo operations.
Use vim search, navigate matches, add matches, perform substitutions, and undo changes.
🧩 Prerequisites
An Ubuntu Server VM (the same VM used in Lab 4 is fine).
SSH access to the VM from your host terminal.
Sudo privileges on the VM.
Note: Installing a GUI and third‑party packages increases disk and memory usage. Ensure the VM has sufficient resources.
📋 Task List
Task 1: Discover missing command & install Java using apt suggestion
Task 2: Install & remove Java using apt-get (explicitly)
Task 3: apt update vs apt upgrade — run & explain
Task 4: Install Visual Studio Code via snap on CLI and verify (DO NOT remove Code)
Task 5: Install XFCE GUI + XRDP — minimal desktop and remote access (GUI) and launch VS Code
Task 6 - Install lightdm-gtk-greeter and GUI verification - start GUI, open VS Code, take snapshot, then end (GUI)
Task 7: Install Google Chrome by adding its apt source & key (Chrome)
Task 8: Install applications via PPA (Audacity & OBS) and launch
Task 9: Create a Kubernetes sample YAML using vim
Task 10: Edit the Kubernetes YAML — add annotation, verify, then discard temporary change
Task 11: Vim editing practice — delete, undo, numeric deletes, navigation
Task 12: Vim search, add matches, substitute, undo
Exam Evaluation Question
Submission
Checklist (for students)
Task 1 - Discover missing command & install Java using apt suggestion
Goal: Run the java command when it's not installed, follow the system suggestion to install a Java package using apt, verify, then remove and clear shell cache.

Steps (inside the VM terminal)
Run the java command to see what the system suggests:
java
Expected: message similar to "The program 'java' can be found in the following packages: ... Try: sudo apt install "
Save screenshot as: task1_java_suggestion.png
Use the suggested apt command (copy the exact package name suggested by the system). Example (replace with the name shown on your VM):
sudo apt install <suggested-package> -y
Save screenshot of the apt install progress (or final lines) as: task1_java_install.png
Verify Java is installed and check version:
java --version
Save screenshot as: task1_java_version.png
Remove the Java package using apt remove (use the same package name you installed):
sudo apt remove <suggested-package> -y
Save screenshot as: task1_java_remove.png
Confirm java is no longer available (run java again) — it should again indicate "not found" or suggest installation:
java
Save screenshot as: task1_java_not_found.png
Clear the shell's command hash cache so the shell forgets cached command locations (run as your regular user — no sudo required):
hash -r
java
Save screenshot showing hash -r followed by java result as: task1_hash_clear.png
📸 Screenshot Required:

task1_java_suggestion.png
task1_java_install.png
task1_java_version.png
task1_java_remove.png
task1_java_not_found.png
task1_hash_clear.png
Notes:

Use the exact package the VM suggests. Typical suggestions include default-jre, openjdk-11-jre-headless, or similar.
Task 2 - Install & remove Java using apt-get (explicitly)
Goal: Repeat install/remove using the apt-get tool to show both package managers.

Steps (inside VM terminal)
Install Java using apt-get (choose a common package, e.g., default-jre — or the same package you used in Task 1):
sudo apt-get update
sudo apt-get install default-jre -y
Save screenshot(s) as: task2_aptget_install.png
Verify Java version again:
java --version
Save screenshot as: task2_java_version_after_aptget.png
Remove Java using apt-get remove:
sudo apt-get remove default-jre -y
Save screenshot as: task2_aptget_remove.png
Clear the terminal hash cache and confirm java is missing:
hash -r
java
Save screenshot as: task2_hash_after_remove.png
📸 Screenshot Required:

task2_aptget_install.png
task2_java_version_after_aptget.png
task2_aptget_remove.png
task2_hash_after_remove.png
Notes:

If you installed a different package in Task 1, use the same package name here to avoid leftover files.
Task 3 - apt update vs apt upgrade - run & explain
Goal: Run the commands and document the difference.

Steps (inside VM terminal)
Update the package index (this downloads the latest lists of available packages):
sudo apt update
Save screenshot as: task3_apt_update.png
Upgrade installed packages (this installs available updates for currently installed packages):
sudo apt upgrade
Save screenshot as: task3_apt_upgrade.png
Write a short 3–5 sentence explanation describing the difference between apt update and apt upgrade. Put your text into a small file and capture it as a screenshot (do not upload the text file; provide the screenshot):
nano ~/apt_update_vs_upgrade.md
# write 3-5 sentences, save and exit
Open the file or show it on screen and save screenshot as: task3_explanation.png
📸 Screenshot Required:

task3_apt_update.png
task3_apt_upgrade.png
task3_explanation.png
Hint (what to mention):

apt update refreshes the local package index — it does not change installed packages.
apt upgrade looks at the updated index and installs newer versions of already-installed packages.
Without apt update, apt upgrade would use outdated package lists and might not find the newest updates.
Task 4 - Install Visual Studio Code via snap on CLI and verify (DO NOT remove Code)
Goal: Install a snap package (example: VS Code) on a CLI-only server and verify installation using commands that work without a GUI. Keep Code installed for later GUI tasks.

Steps (inside VM terminal)
Install VS Code via snap (snap may require sudo):
sudo snap install --classic code
Save screenshot as: task4_snap_install.png
Verify snap shows the package is installed:
snap list code
Save screenshot as: task4_snap_list.png
Check the installed application's version. On some systems code --version is available; also check snap info:
code --version
Save screenshot(s) as: task4_code_version_or_info.png
If the code binary is not in PATH, show where the snap placed it:
ls -l /snap/bin | grep code
Save screenshot as: task4_snap_bin_location.png
IMPORTANT: Do NOT remove VS Code at the end of this task — keep it installed. It will be launched later in Task 5 and Task 6.
📸 Screenshot Required:

task4_snap_install.png
task4_snap_list.png
task4_code_version_or_info.png
task4_snap_bin_location.png
Notes:

The main point is to show that snap installs and can be verified from the CLI even if you cannot start the GUI.
Task 5 - Install XFCE GUI + XRDP - minimal desktop and remote access (GUI) and launch VS Code
Goal: Install a lightweight GUI (XFCE), enable XRDP for remote desktop access, and learn how to control whether the GUI login screen appears at boot. After starting the GUI, launch the VS Code installed in Task 4 to verify GUI app launch. This task is for this lab.

Warning: Installing a GUI on a server consumes additional disk space and memory. Perform on a VM with sufficient resources.

Steps (inside the host terminal / via SSH)
From your host, open your preferred terminal (for example: Windows Command Prompt, PowerShell, macOS Terminal, or Linux Terminal) and connect to the VM using SSH. Example:
ssh student@<vm-ip-address>
Update the server (download package lists and apply upgrades):
sudo apt update && sudo apt upgrade -y
Save screenshot as: task5_update.png
Install XFCE and XFCE goodies (lightweight desktop):
sudo apt install xfce4 xfce4-goodies -y
Save screenshot as: task5_xfce_install.png
Install and enable XRDP (Remote Desktop Protocol server):
sudo apt install xrdp -y
sudo systemctl enable --now xrdp
Save screenshot as: task5_xrdp_enable.png
Verify XRDP status:
sudo systemctl status xrdp
Save screenshot as: task5_xrdp_status.png
Configure XRDP to use XFCE session:
echo xfce4-session > ~/.xsession
Save screenshot as: task5_xsession.png
From a Windows host or RDP client, connect with Remote Desktop (mstsc) to your server IP and login using your Ubuntu username/password. Capture a screenshot of the remote desktop or the RDP session window (if allowed by your environment) and save it as: task5_rdp_connect.png
If you cannot capture a screenshot from the client, show ss -ltnp or ps evidence that the session was established and save as an alternative.

After you are in the GUI (local console or RDP session), launch Visual Studio Code (installed in Task 4) from the GUI menu or a terminal inside the GUI. Example command from a GUI terminal:
code 
Save a screenshot of VS Code running in the GUI as: task5_vscode_launch.png

(Optional) From inside VS Code you may open a file or explore the UI — but DO NOT need to create or save files here for Task 5.

Log out of the Ubuntu server, close the session, and exit the remote desktop program.

📸 Screenshot Required:

task5_update.png
task5_xfce_install.png
task5_xrdp_enable.png
task5_xrdp_status.png
task5_xsession.png
task5_rdp_connect.png
task5_vscode_launch.png
Task 6 - Install lightdm-gtk-greeter and GUI verification - start GUI, open VS Code, take snapshot, then end (GUI)
Steps (inside the host terminal / via SSH)
Fix GUI login screen issues (if lightdm / greeter problems appear)
Install LightDM and greeter using Host Terminal:
sudo apt install lightdm lightdm-gtk-greeter -y
Save screenshot as: task6_lightdm_install.png

Create LightDM config to use XFCE:

sudo mkdir -p /etc/lightdm/lightdm.conf.d
echo -e "[Seat:*]\ngreeter-session=lightdm-gtk-greeter\nuser-session=xfce\nautologin-user-timeout=0" | sudo tee /etc/lightdm/lightdm.conf.d/99-xfce.conf
Save screenshot as: task6_lightdm_config.png

Clean up problematic session files and permissions:

sudo rm -f /var/lib/lightdm/.Xauthority
sudo rm -f ~/.Xauthority
sudo rm -rf ~/.cache/sessions
sudo chown -R $USER:$USER /home/$USER
Save screenshot as: task6_lightdm_cleanup.png

Restart LightDM:

sudo systemctl restart lightdm
Save screenshot as: task6_lightdm_restart.png
Control GUI login at boot — ENABLE first, then DISABLE (observe and understand terminal/GUI behavior after each reboot)
Important: students MUST perform the reboot after each target change to observe the boot-time behavior. The sequence below has been adjusted so you ENABLE the GUI boot target first, reboot and observe GUI, then DISABLE the GUI boot target, reboot and observe the CLI.

Enable GUI Login Screen (Boot to GUI)
Re-enable LightDM and set the graphical target as default:
sudo systemctl enable lightdm
sudo systemctl set-default graphical.target
Save a screenshot immediately after running the commands as: task6_gui_enable_boot.png

Reboot the VM to observe that it boots to the GUI login screen:

sudo reboot
After the VM boots, capture a screenshot of the GUI login screen (or remote desktop showing the greeter) and save it as: task6_after_reboot_gui.png

Disable GUI Login Screen (Boot to CLI)

Set the default boot target to multi-user (text mode) and disable LightDM so the system boots to the terminal:
sudo systemctl set-default multi-user.target
sudo systemctl disable lightdm
Save a screenshot immediately after running the commands as: task6_gui_disable_boot.png

Reboot the VM to observe that it boots to the terminal (CLI):

sudo reboot
After the VM boots, capture a screenshot of the login prompt or terminal session showing CLI-only behavior and save it as: task6_after_reboot_cli.png

Start/Stop GUI manually (no reboot)

You can start the GUI session without changing the boot target. This is useful if you want to keep the boot target as CLI but run GUI temporarily:
Save screenshot(s) showing the start commands and any immediate status output as: task6_gui_start.png
sudo systemctl start lightdm   # start GUI now
Press Ctrl + Alt + F3 to switch back to TTY. You can stop the GUI session without changing the boot target.
sudo systemctl stop lightdm   # stop GUI now
Save screenshot(s) showing the start/stop commands and any immediate status output as: task6_gui_stop.png
Start the GUI (if the system is currently set to CLI or the GUI is not running):
sudo systemctl start lightdm
Save a screenshot immediately after running the command as: task6_gui_start_command.png
In the GUI session launch Visual Studio Code (installed earlier in Task 4). From a GUI terminal inside the desktop, run:
code
Save a screenshot of VS Code running in the GUI as: task6_vscode_launch.png
Close VS Code using the GUI window controls. Task 6 ends here.
📸 Screenshot Required:

task6_lightdm_install.png
task6_lightdm_config.png
task6_lightdm_cleanup.png
task6_lightdm_restart.png
task6_gui_enable_boot.png
task6_after_reboot_gui.png
task6_gui_disable_boot.png
task6_after_reboot_cli.png
task6_gui_start.png
task6_gui_stop.png
task6_gui_start_command.png
task6_vscode_launch.png
Task 7 - Install Google Chrome by adding its apt source & key (Chrome)
Goal: Add Google's apt source and signing key so that sudo apt install google-chrome-stable succeeds. This task intentionally begins by attempting to install Chrome directly (the install will fail if the repository/key are not yet configured) — capture that failure as evidence, then proceed to add the repository/key and install successfully. Also includes an alternate (preferred) one-line list method.

IMPORTANT: Third-party repositories require trusted signing keys. Only add keys from official vendor URLs. Some systems require /etc/apt/keyrings to exist — create it if missing with sudo mkdir -p /etc/apt/keyrings.

Steps (inside the VM terminal or GUI terminal or host terminal / via SSH)
(Learning step — first command must be the install attempt) Attempt to install Google Chrome directly to see the failure when the repo/key are missing:
sudo apt install google-chrome-stable -y
Expected: this will typically fail with "Unable to locate package google-chrome-stable" or similar because the Google repo/key are not yet configured.
Save a screenshot of the error output as: task7_install_chrome_error.png
Inspect apt configuration so you understand why install failed. List the /etc/apt directory:
ls -la /etc/apt
Save screenshot as: task7_ls_etc_apt.png
View the main /etc/apt/sources.list:
cat /etc/apt/sources.list
Save screenshot as: task7_cat_sources_list.png
List files under /etc/apt/sources.list.d:
ls -la /etc/apt/sources.list.d/
Save screenshot as: task7_ls_sources_list_d.png
If there is a file named ubuntu.sources (or similarly named source file), display it to see whether Chrome's repo is present:
cat /etc/apt/sources.list.d/ubuntu.sources
Save screenshot as: task7_cat_ubuntu_sources.png
Add Chrome repository metadata to a sources file (method A — using ubuntu.sources). Open or create the file and append the stanza (you can alternatively use the preferred one-line method in step 11):
sudo nano /etc/apt/sources.list.d/ubuntu.sources
Append these exact lines at the end of the file:
Types: deb
URIs:  http://dl.google.com/linux/chrome/deb/
Suites: stable
Components: main
Architectures: amd64
Signed-By: /etc/apt/keyrings/google.gpg
Save the file (Ctrl+O → Enter) and exit (Ctrl+X).
Save a screenshot after editing (or show the file contents with cat) as: task7_edit_ubuntu_sources.png
Ensure the keyrings directory exists and import Google's signing key:
curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /etc/apt/keyrings/google.gpg
Save screenshot as: task7_add_key.png
Update apt and attempt to install Chrome again (now that repo + key are added):
sudo apt update
sudo apt install google-chrome-stable -y
Save screenshots as: task7_apt_update.png and task7_install_chrome.png
Alternate (preferred, cleaner) method — create a single google-chrome.list entry

Cleanup before alternate method you added the chrome earlier and want to switch to the preferred method:

sudo apt remove google-chrome-stable -y
sudo nano /etc/apt/sources.list.d/ubuntu.sources   # remove the chrome stanza you added earlier, save and exit
sudo rm -f /etc/apt/keyrings/google.gpg
Save screenshots as: task7_alternate_remove.png, task7_alternate_edit.png, and task7_remove_key.png
Create a dedicated one-line list file for Google Chrome (preferred):
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list > /dev/null
Save screenshot as: task7_create_google_chrome_list.png
Verify the new file exists:
ls -la /etc/apt/sources.list.d/
Save screenshot as: task7_list_sources_after_create.png
Re-add the Google signing key (if removed previously or not present):
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /etc/apt/keyrings/google.gpg
Save screenshot as: task7_add_key_alt.png
Update apt and install Chrome (preferred flow):
sudo apt update
sudo apt install google-chrome-stable -y
Save screenshots as: task7_apt_update_alt.png and task7_install_chrome_alt.png
📸 Screenshot Required:

task7_install_chrome_error.png
task7_ls_etc_apt.png
task7_cat_sources_list.png
task7_ls_sources_list_d.png
task7_cat_ubuntu_sources.png
task7_edit_ubuntu_sources.png
task7_add_key.png
task7_apt_update.png
task7_install_chrome.png
task7_alternate_remove.png
task7_alternate_edit.png
task7_remove_key.png
task7_create_google_chrome_list.png
task7_list_sources_after_create.png
task7_add_key_alt.png
task7_apt_update_alt.png
task7_install_chrome_alt.png
Task 8 - Install applications via PPA (Audacity & OBS) and launch
Goal: Add PPAs for Audacity and OBS Studio, update apt, install the packages, and launch them (or verify installation) from the CLI/GUI. Capture screenshots for each step.

NOTE: Performing these steps will add third‑party PPAs to the system. Only add PPAs from trusted sources (these are common community PPAs). If your VM environment restricts PPAs, document any errors.

Steps (inside the VM terminal or GUI terminal)
Add the Audacity PPA, update apt and install audacity:
sudo add-apt-repository ppa:ubuntuhandbook1/audacity -y
sudo apt update
sudo apt install audacity -y
Save screenshots as:
task8_add_ppa_audacity.png (output of add-apt-repository)
task8_apt_update_audacity.png (apt update after adding PPA)
task8_install_audacity.png (apt install output)
Launch Audacity (from GUI or CLI). On a headless server you may not get a GUI window — if you are using the XFCE GUI session, launch from a GUI terminal or run check for binary:
audacity --version
audacity
Save screenshots as:
task8_audacity_launch.png (GUI launch screenshot if possible) or task8_audacity_version.png (CLI verification)
Add the OBS Studio PPA, update apt and install obs-studio:
sudo add-apt-repository ppa:obsproject/obs-studio -y
sudo apt update
sudo apt install obs-studio -y
Save screenshots as:
task8_add_ppa_obs.png (output of add-apt-repository)
task8_apt_update_obs.png (apt update after adding PPA)
task8_install_obs.png (apt install output)
Launch OBS Studio (from GUI or verify binary presence):
obs --version
obs
Save screenshots as:
task8_obs_launch.png (GUI launch screenshot if possible) or task8_obs_version.png (CLI verification)
📸 Screenshot Required:

task8_add_ppa_audacity.png
task8_apt_update_audacity.png
task8_install_audacity.png
task8_audacity_launch.png or task8_audacity_version.png
task8_add_ppa_obs.png
task8_apt_update_obs.png
task8_install_obs.png
task8_obs_launch.png or task8_obs_version.png
Task 9 - Create a Kubernetes sample YAML using vim
Goal: Confirm vim availability, create a working directory for Lab5, and use vim to create and save a Kubernetes Pod manifest named k8s-sample.yaml.

NOTE: The first command in Task 9 is to run vim to confirm whether vim is installed.

Steps (inside the VM terminal or host terminal / via SSH)
Check whether vim is installed by running:
vim
If vim opens, you will see the vim interface; if not installed you will see a command-not-found error.
Save a screenshot of the result (either the vim splash screen or the error) as: task9_vim_check.png
If vim is not installed, install it:
sudo apt update
sudo apt install vim -y
Save screenshot of the installation as: task9_vim_install.png (only if you installed it).
Create the Lab5 working directory in your home and change into it:
mkdir -p ~/Lab5
cd ~/Lab5
Save screenshot showing mkdir and cd or pwd output as: task9_mkdir_cd.png
Create the Kubernetes sample file using vim:
vim k8s-sample.yaml
Once vim opens, enable insert mode by pressing i, then paste the following YAML exactly:
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
spec:
  containers:
  - name: nginx
    image: nginx:1.19
    ports:
    - containerPort: 80
  restartPolicy: Always
Save a screenshot of the vim editor showing the file contents before saving as task9_vim_edit.png
Exit insert mode by pressing Esc, then save and quit vim with:
:wq
Save a screenshot of the ls -la output showing the file exists task9_k8s_saved.png
📸 Screenshot Required:

task9_vim_check.png
task9_vim_install.png (only if you installed vim)
task9_mkdir_cd.png
task9_vim_edit.png
task9_k8s_saved.png
Task 10 - Edit the Kubernetes YAML - add annotation, verify, then discard temporary change
Goal: Practice vim edits: add a permanent annotation under metadata, verify it, then open the file again, make a temporary edit and discard it (no save). This demonstrates saving and discarding changes in vim.

Steps (inside the VM terminal or host terminal / via SSH)
Open the manifest with vim:
cd ~/Lab5
vim k8s-sample.yaml
When vim opens, ensure you are in command mode (press Esc) then press i to enter insert mode.
Add the annotation under the metadata section (indentation must match YAML). Example (insert these lines under metadata:):
annotations:
  lab: lesson11
After adding the lines, press Esc to return to command mode and save & quit:
:wq
Save a screenshot showing the saved file contents (using cat) as: task10_verify_annotation.png
Example verify command:

cat k8s-sample.yaml
Discard changes (practice: make a temporary edit and exit without saving)
Open the file again:
vim k8s-sample.yaml
Enter insert mode (i) and add a temporary comment line anywhere, for example:
# temp: do-not-keep
Save a screenshot showing vim editor having temp data as: task10_verify_entering_temp_data.png
Do NOT save. Press Esc to go back to command mode, then force quit without saving:
:q!
Verify the file does NOT contain the temporary comment:
cat k8s-sample.yaml
Save a screenshot of the cat output proving the temporary comment is not present as: task10_verify_no_temp_comment.png
📸 Screenshot Required:

task10_verify_annotation.png
task10_verify_entering_temp_data.png
task10_verify_no_temp_comment.png
Notes:

Make sure indentation and YAML formatting are correct when adding the annotation.
If you perform these steps in a GUI terminal inside XFCE, include the GUI terminal screenshots.
Task 11 - Vim editing practice - delete, undo, numeric deletes, navigation
Goal: Practice common vim commands: delete a single line with dd, undo with u, delete multiple lines with a numeric prefix, undo again, and practice basic navigation commands (1G, G, $, 0). Capture verification screenshots showing the file before/after where appropriate.

NOTE: Perform these steps in the ~/Lab5 directory on the previously created k8s-sample.yaml.

Steps (inside the VM terminal or host terminal / via SSH)
Open the file with vim:
cd ~/Lab5
vim k8s-sample.yaml
Delete the line containing image: nginx:1.19 with a single command:
Ensure you are in command mode (press Esc), move the cursor to the line with image: nginx:1.19, then delete that line with:
dd
Immediately undo the deletion with:
u
Capture a screenshot showing the file after the undo (or a cat output after saving) as: task11_dd_delete_and_undo.png
Delete 3 lines at once using the numeric delete command:
In command mode, position the cursor on the first line of the three you want to delete (for example start at the image: line again), then run:
d3d
(or 3dd or d3<enter> — either numeric prefix form is acceptable; document which you used)

Immediately undo the deletion with:
u
Capture a screenshot showing the file after the undo (or a cat output) as: task11_delete3_and_undo.png
Navigation practice (from command mode)
Jump to the first line:
1G
Note the line contents capture a screenshot saved as: task11_line1.png

Jump to the last line:

G
On the line containing containerPort: 80 press $ to move to end of line, then 0 to move back to the start of the line. Capture a brief terminal screenshot showing you on the line and the commands capture the screenshot as: task11_navigation.png
Exit vim (no changes should remain if you undid properly):
:q
📸 Screenshot Required:

task11_dd_delete_and_undo.png
task11_delete3_and_undo.png
task11_line1.png
task11_navigation.png
Notes:

You may perform the deletion/undo steps either visually inside vim and capture GUI terminal screenshots, or perform the edits and save then use cat to demonstrate the file state — ensure screenshots clearly show the before/after or the undo effect.
If you accidentally saved unwanted changes, restore the file to the correct contents (re-edit and save) before taking verification screenshots.
Task 12 - Vim search, add matches, substitute, undo
Goal: Practice searching in vim with /, navigate matches with n and N, add additional matches, substitute across the file, undo, and exit without saving. Capture screenshots to show each verification step.

NOTE: Perform these steps in the ~/Lab5 directory on the previously created k8s-sample.yaml.

Steps (inside the VM terminal / in the ~/Lab5 directory)
Open the file with vim:
cd ~/Lab5
vim k8s-sample.yaml
Search for the string nginx using the forward search command:
From command mode type:
/nginx
and press Enter.

Note the first match is highlighted and the cursor is placed on it. Save a screenshot showing the first match in vim as: task12_search_nginx.png
Move to the next match and previous match:
Press n to jump to the next match (capture screenshot if desired) and press N to jump back to the previous match. Save a screenshot showing navigation between matches as: task12_n_and_N_navigation.png
Add two more occurrences of the word nginx in the file:
Enter insert mode (i) at an appropriate place (for example add two new comment lines or add them under metadata as comments), type two new occurrences of nginx, then press Esc to return to command mode and save the file with :w.
Save a screenshot showing the added occurrences (or cat output) as: task12_added_occurrences.png
Demonstrate that n cycles forward through all matches:
In vim command mode press /nginx Enter, then repeatedly press n to cycle forward through each match. Capture a short sequence (or a terminal screenshot showing the cursor on a later match) as: task12_cycle_matches.png
Substitute all occurrences of nginx with webapp:
From command mode execute the substitute command:
:%s/nginx/webapp
This will replace all occurrences in the file (note: this changes the buffer). Save a screenshot showing the substitution result (or cat k8s-sample.yaml) as: task12_substitute_result.png
Immediately undo the substitution using u:
Press u in command mode to undo the last change. Save a screenshot showing the file restored to the previous state as: task12_undo_and_quit.png
Quit vim without saving any accidental changes (if you didn't already save after substitution and want to discard):
If you want to ensure no changes were written, exit with:
:q!
If you intentionally saved the substitution and then undid it and wish to quit normally, use :q.
📸 Screenshot Required:

task12_search_nginx.png
task12_n_and_N_navigation.png
task12_added_occurrences.png
task12_cycle_matches.png
task12_substitute_result.png
task12_undo_and_quit.png
Notes:

If you perform the edits in a GUI terminal inside XFCE, include GUI terminal screenshots.
If you accidentally left the substitution saved and want to revert to the original file, re-open and restore the content as needed.
Exam Evaluation Question
Goal: This is an exam-style evaluation prompt. Students are asked to install Docker Desktop as part of the evaluation exercise on VM. No commands, solutions, hints, or step-by-step instructions are provided here — install Docker Desktop using your own knowledge and research.

Instructions for students:

Install Docker Desktop on your VMWare Workstation Ubuntu Server. No commands or solutions are provided in this lab — treat this as an evaluation/exam question.
Verify Docker Desktop is installed by launching the Docker Desktop application and confirming it runs.
Capture a screenshot of Docker Desktop running (or other clear evidence that Docker Desktop is installed and started) and save it as: exam_evaluation_docker_desktop.png
Notes:

This task intentionally provides no commands, package names, or step-by-step instructions. You must research and determine the correct installation steps for your OS/environment.
📸 Screenshot Required:

exam_evaluation_docker_desktop.png
Troubleshooting & notes
If any apt commands fail due to networking, capture the error output as screenshots and include them in your submission.
When working with vim, remember i to enter insert mode, Esc to return to command mode, :wq to save and quit, and :q! to quit without saving. For undo use u, for redo use Ctrl-R, and numeric deletes can be 3dd or d3d. For search use /pattern, navigate with n and N, and substitute with :%s/pattern/replacement.
Submission
Create a repository named CC_<YourName>_<YourRollNumber>/Lab5 and add the following structure:
Upload a Word file and PDF or .md file containing:
Step outputs or terminal screenshots for each task
Your answers to the hands-on practical exam questions
Repository look like
Lab5/
  workspace/                    # any sample files you used (optional for this lab)
  screenshots/                  # include all screenshots listed above
  Word file and PDF or .md file # Student generated file
  Lab5-instructions.md          # this lab file (the one you are reading)
Checklist (for students)
 Ran java and followed apt suggestion — saved screenshots.
 Installed Java via apt, verified version, removed it, ran hash -r — saved screenshots.
 Installed Java via apt-get, verified, removed, cleared cache — saved screenshots.
 Ran sudo apt update and sudo apt upgrade and wrote explanation — saved screenshot.
 Installed VS Code using snap and did NOT remove it — saved screenshots.
 Installed XFCE + XRDP, launched VS Code in GUI, verified visual launch — saved screenshots.
 Enabled GUI boot target, rebooted and captured GUI screenshot (task5_after_reboot_gui.png), then disabled GUI boot target, rebooted and captured CLI screenshot (task5_after_reboot_cli.png).
 Performed Task 6 GUI verification: started GUI, launched VS Code, took a screenshot of VS Code running, and closed VS Code — saved screenshots.
 Performed Task 7: attempted sudo apt install google-chrome-stable (captured error), inspected /etc/apt, added Chrome apt entry and key, updated apt and installed Google Chrome (and optionally the alternate method) — saved screenshots.
 Performed Task 8: added PPAs for Audacity and OBS, installed the apps, and launched or verified them — saved screenshots.
 Performed Task 9: confirmed vim availability, created ~/Lab5, created k8s-sample.yaml with vim and saved it — saved screenshots.
 Performed Task 10: added annotations: lab: lesson11 to k8s-sample.yaml and verified it, then made a temporary edit and discarded it — saved screenshots.
 Performed Task 11: practiced dd/u, numeric deletes, and navigation commands in vim — saved screenshots.
 Performed Task 12: searched nginx, navigated matches with n/N, added matches, substituted, undid, and exited — saved screenshots.
 Performed Task 13 (Exam Evaluation): installed Docker Desktop (or documented inability) and saved screenshot — saved screenshot.
 Pushed repository CC_<YourName>_<YourRollNumber> with Lab5 content and screenshots.
