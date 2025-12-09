#!/bin/bash

################################################################################
# CyberRecon Toolkit by ch3sda
# Dark Hacker Neon Edition
#
# EDUCATIONAL USE ONLY – legal disclaimer included before execution.
################################################################################

#==============================
# COLORS
#==============================
RED="\e[91m"; GREEN="\e[92m"; YELLOW="\e[93m"
BLUE="\e[94m"; PURPLE="\e[95m"; CYAN="\e[96m"
RESET="\e[0m"; BOLD="\e[1m"


#==============================
# INSTALL CHECK
#==============================
check_install(){
  command -v $1 &>/dev/null || {
    echo -e "${YELLOW}[+] Installing $1 ...${RESET}"
    sudo apt install -y $1
  }
}

install_dependencies(){
  tools=("figlet" "nmap" "gobuster" "sqlmap" "hydra" "nikto" "whatweb" "wafw00f" \
  "dirsearch" "ffuf" "nuclei" "subfinder" "assetfinder" "whois" "dnsenum" "msfconsole")

  for t in "${tools[@]}"; do
    check_install "$t"
  done
}


#==============================
# LEGAL DISCLAIMER
#==============================
disclaimer(){
  clear
  echo -e "${RED}${BOLD}⚠ LEGAL DISCLAIMER ⚠${RESET}"
  echo -e "${CYAN}"
  echo "This toolkit (CyberRecon) MUST only be used for:"
  echo " - Your own servers"
  echo " - Lab testing"
  echo " - Explicitly authorized pentests"
  echo ""
  echo "You are fully responsible for your actions."
  echo ""
  read -p "Press ENTER if you AGREE..."
}


#==============================
# BANNER
#==============================
banner(){
  clear
  echo -e "${PURPLE}"
  figlet -f slant "Recon Toolkit" 2>/dev/null
  echo -e "${RESET}${CYAN}${BOLD}"
  echo "=============================================="
  echo "           EDUCATION EDITION"
  echo "          CyberRecon by ch3sda"
  echo "=============================================="
  echo -e "${RESET}"
}

pause(){ read -p "Press ENTER..."; }


################################################################################
###########################   NMAP   ##########################################
################################################################################

menu_nmap(){
banner
read -p "Target: " t
echo "
1) Quick Scan
2) Top Ports
3) OS Detect
4) Full Scan
5) Vuln Scan
6) CUSTOM
"
read -p "Select: " c
case $c in
1) nmap -T4 $t;;
2) nmap --top-ports 100 $t;;
3) sudo nmap -O $t;;
4) sudo nmap -p- -A -T4 $t;;
5) sudo nmap --script vuln $t;;
6) read -p "Command: " cmd; eval nmap $cmd;;
esac
pause
}


################################################################################
###########################   GOBUSTER   ######################################
################################################################################

menu_gobuster(){
banner
read -p "URL: " u
echo "
1) Common
2) Medium
3) Big
4) CUSTOM
"
read -p "Select: " c
case $c in
1) gobuster dir -u $u -w /usr/share/seclists/Discovery/Web-Content/common.txt;;
2) gobuster dir -u $u -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt;;
3) gobuster dir -u $u -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-big.txt;;
4) read -p "Cmd: " cmd; eval $cmd;;
esac
pause
}

################################################################################
############################  SQLMAP   ########################################
################################################################################

menu_sqlmap(){
banner
read -p "URL: " u
echo "
1) Auto
2) Level3
3) Dump DBs
4) CUSTOM
"
read -p "Select: " c
case $c in
1) sqlmap -u $u --batch;;
2) sqlmap -u $u --level 3 --batch;;
3) sqlmap -u $u --dbs --batch;;
4) read -p "Cmd: " cmd; eval $cmd;;
esac
pause
}

################################################################################
############################  HYDRA   #########################################
################################################################################

menu_hydra(){
banner
read -p "IP: " ip
read -p "Service: " svc
read -p "Userlist: " u
read -p "Passlist: " p
hydra -L $u -P $p $ip $svc
pause
}


################################################################################
# Other simple menus
################################################################################

menu_nikto(){ banner; read -p "URL: " u; nikto -h $u; pause; }
menu_whatweb(){ banner; read -p "URL: " u; whatweb $u; pause; }
menu_waf(){ banner; read -p "Domain: " d; wafw00f $d; pause; }
menu_wayback(){ banner; read -p "Domain: " d; echo $d | waybackurls; pause; }
menu_whois(){ banner; read -p "Domain: " d; whois $d; pause; }
menu_dns(){ banner; read -p "Domain: " d; dnsenum $d; pause; }
menu_ping(){ banner; read -p "Host: " h; ping -c 4 $h; pause; }
menu_trace(){ banner; read -p "Host: " h; traceroute $h; pause; }
menu_msf(){ banner; msfconsole; pause; }


################################################################################
# Dirsearch / ffuf / nuclei / subs
################################################################################

menu_dirsearch(){
banner
read -p "URL: " u
echo "
1) Small
2) Medium
3) Big
4) CUSTOM
"
read -p "Select: " c
case $c in
1) dirsearch -u $u -w /usr/share/wordlists/dirbuster/directory-list-2.3-small.txt;;
2) dirsearch -u $u -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt;;
3) dirsearch -u $u -w /usr/share/wordlists/dirb/big.txt;;
4) read -p "Cmd: " cmd; eval $cmd;;
esac
pause
}


menu_ffuf(){
banner
read -p "URL: " u
echo "
1) Common
2) Medium
3) Big
4) CUSTOM
"
read -p "Select: " c
case $c in
1) ffuf -u $u/FUZZ -w /usr/share/seclists/Discovery/Web-Content/common.txt;;
2) ffuf -u $u/FUZZ -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt;;
3) ffuf -u $u/FUZZ -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-big.txt;;
4) read -p "Cmd: " cmd; eval $cmd;;
esac
pause
}


menu_nuclei(){
banner
read -p "Target: " t
echo "
1) Basic
2) Full Templates
3) CVEs
4) CUSTOM
"
read -p "Select: " c
case $c in
1) nuclei -u $t;;
2) nuclei -u $t -t /root/nuclei-templates/;;
3) nuclei -u $t -t cves;;
4) read -p "Cmd: " cmd; eval $cmd;;
esac
pause
}


menu_quicksubs(){
banner
read -p "Domain: " d
subfinder -d $d | tee subfinder_$d.txt
assetfinder --subs-only $d | tee assetfinder_$d.txt
cat subfinder_$d.txt assetfinder_$d.txt | sort -u | tee subs_$d.txt
pause
}



################################################################################
#### MAIN
################################################################################

install_dependencies
disclaimer

while true; do
banner
echo -e "${PURPLE}${BOLD}
1) Nmap
2) Gobuster
3) SQLmap
4) Hydra
5) Nikto
6) Whatweb
7) WAFW00F
8) Dirsearch
9) FFUF
10) Nuclei
11) Waybackurls
12) Subdomain Quick
13) Whois
14) DNS Enum
15) Ping
16) Traceroute
17) Metasploit
0) EXIT
${RESET}"
read -p "> " x

case $x in
1) menu_nmap ;;
2) menu_gobuster ;;
3) menu_sqlmap ;;
4) menu_hydra ;;
5) menu_nikto ;;
6) menu_whatweb ;;
7) menu_waf ;;
8) menu_dirsearch ;;
9) menu_ffuf ;;
10) menu_nuclei ;;
11) menu_wayback ;;
12) menu_quicksubs ;;
13) menu_whois ;;
14) menu_dns ;;
15) menu_ping ;;
16) menu_trace ;;
17) menu_msf ;;
0) exit ;;
*) echo "Invalid!";;
esac
done
