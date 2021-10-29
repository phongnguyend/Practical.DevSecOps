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
  ```bash
  pwd
  ```
- Back to home directory
  ```bash
  cd
  ```
- Back to parent directory
  ```bash
  cd ..
  ```
- Go to root directory
  ```bash
  cd /
  ```
- List files and directories
  ```bash
  ls
  ```
- List files and directories (including hidden)
  ```bash
  ls -a
  ```
- List files and directories (long format)
  ```bash
  ls -l
  ```
- List files and directories (multiple options)
  ```bash
  ls -a -l
  ls -la
  ```
- Read text file
  ```bash
  cat filename
  
  # Create and input a file. Ctrl + D to terminate.
  cat > filename
  
  # Create and input. Enter END to terminate.
  cat > filename << END
  line1
  line2
  END
  
  cat -b file1 file2
  cat -b file file2 > file3
  
  more filename
  less filename
  
  head filename
  head /var/log/syslog
  head -n 20 /var/log/syslog
  
  tail filename
  tail -n 20 /var/log/syslog
  ```
- Edit text file
  ```bash
  nano filename
  vi filename
  ```
- Create a file
  ```bash
  touch <filename>
  ```
- Remove a file
  ```bash
  rm <filename>
  ```
- Create a directory
  ```bash
  mkdir <directory>
  ```
- Move/rename a file
  ```bash
  mv <filename> <directory>
  mv <filename1> <filename2> <filename3> <directory>
  mv <filename> <newfilename>
  ls -l
  ```
- Copy a file
  ```bash
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
  ```bash
  rmdir <directory>
  ```
- Remove directory recursively
  ```bash
  rm -r <directory>
  ```
- Create hard link
  ```bash
  ln file link
  ls -l
  ls -i
  ```
- Create symbolic link
  ```bash
  ln -s file link
  ls -l
  ls -i
  ```
- Search text in text file
  ```bash
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
  ```bash
  wc <filename>
  wc -l <filename>
  wc -w <filename>
  ```
- Search files & directories
  ```bash
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
  ```bash
  sed 's/abc/xyz' file
  ```
- Compare 2 files
  ```bash
  diff file1 file2
  diff -c file1 file2
  diff -u file1 file2
  ```
- Compress files
  ```bash
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
  ```bash
  whoami
  id
  groups
  groups <user>
  ```
- Create/delete User
  ```bash
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
  ```bash
  sudo usermod -aG sudo <user>
  ```
- Create/delete group
  ```bash
  sudo addgroup <group>
  tail -n 1 /etc/group
  sudo delgroup <group>
  ```
- Login
  ```bash
  su - <user>
  exit
  ```
- Change file owner
  ```bash
  ls -l <filename>
  sudo chown <user> <filename>
  ls -l <filename>
  sudo chgrp <group> <filename>
  ls -l <filename>
  ```

#### File permissions:
- View permissions
  ```bash
  ls -l
  ```
- Permission infor:
  + read (r), write (w), execute (x), no (-)
  + user (u), group (g), other (o)
- Change permission: ```chmod [references][operator][modes] filename```
  ```bash
  chmod u+x file1
  chmod u-x file2
  ```

#### Utilities:
- Brace Expansion
  ```bash
  echo file{1..10}.txt
  echo file{01..10}.txt
  echo {a,b,c}{01..10}.txt
  echo {A..Z}{01..10}.txt
  ```
- Environment Variables
  ```bash
  env
  echo $PATH
  echo $HOME
  export PATH="$PATH:$HOME/.dotnet/tools"
  
  # current process id
  echo $$
  
  echo $SSH_CLIENT
  ```
 - Aliases
   ```bash
   alias
   alias ..='cd ..'
   alias ll='ls -lah'
   alias ports='netstat -tulanp'
   
   # check type of command
   type -a ..
   type -a ll
   type -a ports
   
   # remove alias
   unalias ..
   unalias ll
   unalias ports
   ```
 - Default Text Editor:
   ```bash
   echo $EDITOR
   export EDITOR=nano
   export EDITOR=vi
   ```
- Check Bash version:
  ```bash
  bash --version
  echo $BASH_VERSION
  ```
- Check command type:
  ```
  type -a bash
  type -a pwd
  which -a bash
  which -a pwd
  ```

#### Processes and Jobs:
- Processes
  ```bash
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
  ```bash
  ps xao pid,ppid,pgid,sid,comm | head
  ```
- Process Groups, Jobs:
  + Foreground Jobs
    ```bash
	ncdu -x /
	Ctrl + Z
	jobs
	fg 1
	fg
	```
  + Background Jobs
    ```bash
	ncdu -x / &
	bg
	```
  + Suspended Jobs
- Change Process Priority
  ```bash
  nice
  htop
  ```
- Signals & Interrupts
  ```bash
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
  ```bash
  cat /etc/profile
  cat ~/.bash_profile
  cat ~/.bash_login
  cat ~/.profile
  cat ~/.bash_logout
  ```
- Bash Config Files: Interactive Non-Login
  ```bash
  cat /etc/bash.bashrc
  cat ~/.bashrc
  ```
- Z-Shell Config Files: Interactive Login
  ```bash
  cat /etc/zshenv
  cat ~/.zshenv
  cat ~/.zprofile
  cat ~/.zshrc
  cat ~/.zlogin
  cat ~/.zlogout
  ```
- Z-Shell Config Files: Interactive Non-Login
  ```bash
  cat /etc/zshenv
  cat ~/.zshenv
  cat /etc/zshrc
  cat ~/.zshrc
  ```
### Scripting:
#### Variables and Arguments:
- Create ```myscript.sh```
  ```bash
  nano myscript.sh
  #!/bin/bash
  ```
- Variables:
  ```bash
  firstName=Phong
  lastName=Nguyen
  echo "${firstName}, $lastName"
  ```
- Save and Run:
  ```bash
  ls -l myscript.sh
  chmod u+x myscript.sh
  ls -l myscript.sh
  ./myscript.sh
  ```
- Arguments:
  ```bash
  echo "The script is: $0"
  echo "The number of arguments is: $#"
  echo "The arguments list is: $*"
  echo "The arguments as an array are: $@"
  firstName=$1
  lastName=$2
  echo "Hello: ${firstName}, $lastName"
  ```
- Save (Ctrl + O, Enter, Ctrl + X) and Run:
  ```bash
  # check file type
  file myscript.sh
  
  # run
  ./myscript.sh Phong Nguyen
  
  # or
  bash myscript.sh Phong Nguyen
  
  # debug
  bash -x myscript.sh Phong Nguyen
  ```
- shift
  ```bash
  #!/bin/bash
  firstName=$1
  shift
  lastName=$1
  echo "Hello: ${firstName}, $lastName"
  ```
- while + shift
  ```bash
  #!/bin/bash
  while (( "$#" ))
  do
    echo "$1"
    shift
  done
  ```
- Options:
  ```bash
  #!/bin/bash
  while getopts ':abc:d:' opt
  do
    case "$opt" in
      a) echo "Option: $opt, Arg: $OPTARG" # $OPTARG is null
  	  break ;;
      b) echo "Option: $opt, Arg: $OPTARG" # $OPTARG is null
  	  break ;;
      c) echo "Option: $opt, Arg: $OPTARG" # $OPTARG is required
  	  break ;;
      d) echo "Option: $opt, Arg: $OPTARG" # $OPTARG is required
  	  break ;;
      *) echo "Usage: $0 [-c|-d] <arg>"
    esac
  done
  ```
- Read Input:
  ```bash
  read
  echo $REPLY
  
  read myVar
  echo $myVar
  
  echo "Enter username: "; read
  echo $REPLY
  
  read -p "Enter username: "
  echo $REPLY
  
  echo "Enter password: "; read -s
  echo $REPLY
  
  read -s -p "Enter password: "
  echo $REPLY
  
  read -n2 myVar
  echo $myVar
  echo "Length: ${#myVar}"
  ```
- Default values:
  ```bash
  read username
  echo $username
  echo ${username:-defaultvalue} # null or unset
  echo ${username-defaultvalue} # unset

  unset username
  echo $username
  echo ${username:-defaultvalue} # null or unset
  echo ${username-defaultvalue} # unset
  ```
- String replacement:
  ```bash
  var1=aabbcc
  echo ${var1/a/A} # Aabbcc
  echo ${var1//a/A} # AAbbcc
  ```

#### Calculation:
```bash
z=1+2
echo $z # 1+2

let z=1+2
echo $z # 3

expr 1 + 2 # 3
z=$(expr 1 + 2)
echo $z # 3

echo $(( 1 + 2 ))
z=$(( 1 + 2 ))
echo $z # 3

x=1
y=2
echo $(( x + y )) # 3

(( x < y )) && echo "x < y"
```

#### Arrays:
```bash
declare -a users
users[0]=bob
users[1]=smith
declare -p users
echo ${users[0]}

declare -a users
users=("bob" "smith")
declare -p users
echo ${users[0]}

declare -a users
users=([0]=bob [1]=smith)
declare -p users
echo ${users[0]}

declare -A map
map=([key1]=value1 [key2]=value2)
declare -p map
echo ${map[key1]}
```

#### Conditional Execution:
- ```if-then-else-fi```
  ```bash
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
  ```bash
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
- Case Statements:
  ```bash
  nano season.sh

  #!/bin/bash
  declare -l month=$(date +%b)
  case $month in
    dec | jan | feb )
      echo "Winter";;
    mar | apr | may )
      echo "Sprint";;
    jun | jul | aug )
      echo "Summer";;
    sep | oct | nov )
      echo "Autum";;
   esac

  chmod u+x season.sh
  ./season.sh
  ```
 #### Functions:
 - List functions:
   ```bash
   declare -f
   declare -f functionName
   declare -F
   ```
- Create function:
  ```bash
  function say_hello () {
    echo hello
  }
  
  # call function
  say_hello
  ```
- Export function:
  ```bash
  function say_hello () {
    echo hello
  }
  
  # call function
  say_hello
  
  # open new shell
  bash
  
  # call function
  say_hello
  
  # exit
  exit
  
  # export function
  declare -xf say_hello
  
  # open new shell
  bash
  
  # call function
  say_hello
  
  # exit
  exit
  ```
- Pass arguments:
  ```bash
  function say_hello () {
    local name=$1
    echo "hello ${name}!"
  }
  
  say_hello Phong
  ```
#### Loops
- while
  ```bash
  declare -i x=0
  while (( x < 10 )); do echo $x; x=x+1; done
  ```
- until
  ```bash
  declare -i x=10
  until (( x == 0 )); do echo $x; x=x-1; done
  ```
- for
  ```bash
  for ((i=0; i<5; i++)); do echo $i; done
  for ((i=5; i>0; i--)); do echo $i; done

  for f in $(ls); do stat -c "%n %F" $f; done
  for i in {1..5}; do echo $i; done

  declare -a users=("bob" "sue" "jake")
  declare -p users
  echo ${#users[*]}
  for ((i=0; i<${#users[*]}; i++)); do echo ${users[$i]}; done
  ```
- continue
  ```bash
  for i in {1..5}; do
    if [[ $i<3 ]]; then continue; 
    fi
    echo $i; 
  done
  ```
- break
  ```bash
  for i in {1..5}; do
    if [[ $i>3 ]]; then break; 
    fi
    echo $i; 
  done
  ```
### Configure Shell Options:
- List Options:
   ```bash
   shopt
   set -o
   ```
- autocd
  ```bash
  # check current status
  shopt autocd
  
  # enable
  shopt -s autocd
  
  # disable
  shopt -u autocd
  ```
- Restricted Shell
  ```bash
  shopt restricted_shell
  rbash
  shopt restricted_shell
  exit
  ```
- noclobber
  ```bash
  # check current status
  set -o | grep noclobber
  
  # enable
  set -o noclobber
  set -o | grep noclobber
  
  # disable
  set +o noclobber
  set -o | grep noclobber
  ```
- Debugging Option
  ```bash
  # check current status
  set -o | grep xtrace
  
  # enable
  set -x
  set -o xtrace
  set -o | grep xtrace
  
  # disable
  set +x
  set +o xtrace
  set -o | grep xtrace
  ```

#### Shell Redirection:
```bash
ls /etc/hosts
ls /etc/host
ls /etc/hosts /etc/host
ls /etc/hosts /etc/host > stdout.txt
ls /etc/hosts /etc/host 2> stderr.txt
ls /etc/hosts /etc/host &> all.txt
cat stdout.txt
cat stderr.txt
cat all.txt
rm stdout.txt stderr.txt all.txt

# group commands
( ls /etc/hosts; ls /etc/host )
( ls /etc/hosts; ls /etc/host ) > stdout.txt
( ls /etc/hosts; ls /etc/host ) 2> stderr.txt
( ls /etc/hosts; ls /etc/host ) &> all.txt
cat stdout.txt
cat stderr.txt
cat all.txt
rm stdout.txt stderr.txt all.txt

bash > shell.out.txt
ls
exit
cat shell.out.txt
rm shell.out.txt
```
