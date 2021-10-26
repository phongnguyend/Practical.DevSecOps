### Linux:
- [Ubuntu](https://ubuntu.com/)
- [Red Hat](https://www.redhat.com/en)
- [CentOS](https://www.centos.org/)
- [Debian ](https://www.debian.org/)
- [Oracle Linux](https://www.oracle.com/linux/)
- [Kali Linux](https://www.kali.org/)
- [SUSE](https://www.suse.com/)

### Linux Bash Commands:
#### Files and Directories:
- Print current location
  ```
  pwd
  ```
- Back to home directory
  ```
  cd
  ```
- Back to parent directory
  ```
  cd ..
  ```
- Go to root directory
  ```
  cd /
  ```
- List files and directories
  ```
  ls
  ```
- List files and directories (including hidden)
  ```
  ls -a
  ```
- List files and directories (long format)
  ```
  ls -l
  ```
- List files and directories (multiple options)
  ```
  ls -a -l
  ls -la
  ```
- Read text file
  ```
  cat <filename>
  
  # Create and input a file. Ctrl + D to terminate.
  cat > <filename>
  
  cat -b file1 file2
  cat -b file file2 > file3
  
  more <filename>
  less <filename>
  
  head <filename>
  head /var/log/syslog
  head -n 20 /var/log/syslog
  
  tail <filename>
  tail -n 20 /var/log/syslog
  ```
- Edit text file
  ```
  nano <filename>
  vi <filename>
  ```
- Create a file
  ```
  touch <filename>
  ```
- Remove a file
  ```
  rm <filename>
  ```
- Create a directory
  ```
  mkdir <directory>
  ```
- Move/rename a file
  ```
  mv <filename> <directory>
  mv <filename1> <filename2> <filename3> <directory>
  mv <filename> <newfilename>
  ls -l
  ```
- Copy a file
  ```
  cp <filename> <newfilename>
  ls -l
  cp <filename> <directory>/
  cp <filename> <directory>/<newfilename>
  cp <filename1> <filename2> <filename3> <directory>/
  ls -l <directory>/
  cp <directory>/* <directory>/
  cp -r <directory>/ <directory>/
  ```
- Remove non-empty directory
  ```
  rmdir <directory>
  ```
- Remove directory recursively
  ```
  rm -r <directory>
  ```
- Create hard link
  ```
  ln file link
  ls -l
  ls -i
  ```
- Create symbolic link
  ```
  ln -s file link
  ls -l
  ls -i
  ```
- Search text in text file
  ```
  grep <text> <filename>
  
  grep "System" /var/log/syslog
  
  # case insensitive
  grep -i "System" /var/log/syslog
  
  # word
  grep -i -w "System" /var/log/syslog 
  
  # -n: line number
  grep -i -n "System" /var/log/syslog 
  
  # -B: before, -A: after
  grep -i -n -B 3 -A 3 "System" /var/log/syslog 
  
  # count
  grep -c "System" /var/log/syslog 
  
  # recursive
  grep -r "System" /var/log/
  
  # list file names only
  grep -r -l "System" /var/log/
  
  # pipe
  grep <text> <filename> | sort
  grep <text> <filename> | sort > out.txt
  ```
- Count lines, words in text file
  ```
  wc <filename>
  wc -l <filename>
  wc -w <filename>
  ```
- Search files & directories
  ```
  find ./ -type f -name *.txt
  find ./ -type f -name '.*' # find hidden files
  find ./ -type d -name bin
  find ./ -type d -empty
  find ./ -user <user>
  find ./ -group <group>
  find /var/log -type f -amin -60
  find /var/log -type f -cmin -60
  find /var/log -type f -size +1024M
  ```
- Transform text: replace text
  ```
  sed 's/abc/xyz' file
  ```
- Compare 2 files
  ```
  diff file1 file2
  diff -c file1 file2
  diff -u file1 file2
  ```
- Compress files
  ```
  tar cvf images.tar *jpeg
  tar tvf images.tar
  tar xvf images.tar
  
  tar cvfz images.tar.gz *jpeg
  tar tvfz images.tar.gz
  tar xvfz images.tar.gz
  
  tar cvfj images.tar.bz2 *jpeg
  tar tvfj images.tar.bz2
  tar xvfj images.tar.bz2
  ```

#### Users and Groups:
- Current User
  ```
  whoami
  id
  groups
  groups <user>
  ```
- Create/delete User
  ```
  sudo useradd <user> -m -d /home/<user>
  sudo passwd <user>
  sudo chage -maxdays 90 <user>
  ls /home
  cat /etc/passwd
  tail -n 1 /etc/passwd
  tail -n 1 /etc/group
  sudo tail -n 1 /etc/shadow
  sudo userdel <user>
  ```
- Add user to the sudo group
  ```
  sudo usermod -aG sudo <user>
  ```
- Create/delete group
  ```
  sudo addgroup <group>
  tail -n 1 /etc/group
  sudo delgroup <group>
  ```
- Login
  ```
  su - <user>
  exit
  ```
- Change file owner
  ```
  ls -l <filename>
  sudo chown <user> <filename>
  ls -l <filename>
  sudo chgrp <group> <filename>
  ls -l <filename>
  ```

#### File permissions:
- View permissions
  ```
  ls -l
  ```
- Permission infor:
  + read (r), write (w), execute (x), no (-)
  + user (u), group (g), other (o)
- Change permission: ```chmod [references][operator][modes] filename```
  ```
  chmod u+x file1
  chmod u-x file2
  ```

#### Utilities:
- Brace Expansion
  ```
  echo file{1..10}.txt
  echo file{01..10}.txt
  echo {a,b,c}{01..10}.txt
  echo {A..Z}{01..10}.txt
  ```
- Environment Variables
  ```
  env
  echo $PATH
  echo $HOME
  export PATH="$PATH:$HOME/.dotnet/tools"
  ```
 - Aliases
   ```
   alias
   alias ..='cd ..'
   alias ll='ls -lah'
   alias ports='netstat -tulanp'
   ```
 - Default Text Editor:
   ```
   echo $EDITOR
   export EDITOR=nano
   export EDITOR=vi
   ```

#### Processes and Jobs:
- Processes
  ```
  ps
  ps aux
  ps aux | head
  ps aux | grep python
  pgrep python
  pgrep -a python
  pgrep -fa python
  pgrep -u root
  top
  htop
  ```
- Process Id, Parent Process Id, Process Group Id, Session Id:
  ```
  ps xao pid,ppid,pgid,sid,comm | head
  ```
- Process Groups, Jobs:
  + Foreground Jobs
    ```
	ncdu -x /
	Ctrl + Z
	jobs
	fg 1
	fg
	```
  + Background Jobs
    ```
	ncdu -x / &
	bg
	```
  + Suspended Jobs
- Change Process Priority
  ```
  nice
  htop
  ```
- Signals & Interrupts
  ```
  kill -INT <PID> # Ctrl + C
  kill -KILL <PID>
  kill -STOP <PID>
  kill -CONT <PID>
  kill -QUIT <PID>
  htop
  killall
  sudo killall --user <user> --signal STOP
  pkill
  xkill # UI
  ```

#### Bash & Z-Shell Config Files:
- Bash Config Files: Interactive Login
  ```
  cat /etc/profile
  cat ~/.bash_profile
  cat ~/.bash_login
  cat ~/.profile
  cat ~/.bash_logout
  ```
- Bash Config Files: Interactive Non-Login
  ```
  cat /etc/bash.bashrc
  cat ~/.bashrc
  ```
- Z-Shell Config Files: Interactive Login
  ```
  cat /etc/zshenv
  cat ~/.zshenv
  cat ~/.zprofile
  cat ~/.zshrc
  cat ~/.zlogin
  cat ~/.zlogout
  ```
- Z-Shell Config Files: Interactive Non-Login
  ```
  cat /etc/zshenv
  cat ~/.zshenv
  cat /etc/zshrc
  cat ~/.zshrc
  ```
### Scripting:
#### Variables and Arguments:
- Create ```myscript.sh```
  ```
  nano myscript.sh
  #!/bin/bash
  ```
- Variables:
  ```
  firstName=Phong
  lastName=Nguyen
  echo "${firstName}, $lastName"
  ```
- Save and Run:
  ```
  ls -l myscript.sh
  chmod u+x myscript.sh
  ls -l myscript.sh
  ./myscript.sh
  ```
- Arguments:
  ```
  firstName=$1
  lastName=$2
  echo "Hello: ${firstName}, $lastName"
  ```
- Save and Run:
  ```
  ./myscript.sh Phong Nguyen
  ```
#### Conditional Execution:
- ```if-then-else-fi```
  ```
  nano myscript.sh
  
  if [[ ! $1 ]]; then
    echo "First Name is required."
    exit 1
  else
    firstName=$1
  fi
  
  if [[ ! $2 ]]; then
    echo "Last Name is required."
    exit 1
  else
    lastName=$2
  fi
  
  echo "Hello: ${firstName}, $lastName"
  ```
- Expressions:
  ```
  [[ $str ]] # string is not empty
  [[ $str="something" ]] # string equals "something"
  [[ -e $filename ]] # file exists
  [[ -d $dirname ]] # directory exists
  
  [[ ! $str ]] # string is empty
  [[ ! $str="something" ]] # string does not equal "something"
  [[ ! -e $filename ]] # file does not exist
  [[ ! -d $dirname ]] # directory does not exist
  
  [[ $1 && $2]] # and
  [[ $1 || $2]] # or
  
  # Create if exists:
  [[ -e test_dir ]] || mkdir test_dir
  
  # Create file if has write permission:
  [[ -w test_dir ]] && touch test_dir/test_file
  
  # Check result of previous command:
  echo $?
  ```
