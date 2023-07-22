#!/bin/bash

# Check if $1 (first argument) is provided
if [[ -n "$1" ]]; then
    url="$1"
else
    # Prompt the user for input
    read -p "Enter the URL: " url
fi

ip=$(curl -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.63 Safari/537.36" -sSL https://bgp.tools/dns/$url | grep -E -o "/([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}") 
#echo $ip
all_domian=$(curl -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.63 Safari/537.36" -sSL https://bgp.tools/prefix$ip\#dns | grep -Pzo '(?s)<table id="fdnstable" class="full-width-table">.*?</table>' | grep -E -o '\b[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b')
domain_list=($(echo "$all_domian" | sed 's/\(\S\+\)/"\1"/g'))
# Function to check TLS version for a domain
check_tls_version() {
    local domain="$1"
    local tls_version

    # Perform the TLS handshake and capture the verbose output in a variable
    tls_output=$(curl -sIv --connect-timeout 5 "https://$domain" 2>&1)

    # Extract the TLS version from the verbose output
    tls_version=$(echo "$tls_output" | grep -i "TLSv1\.[12]\|TLSv1\.3")

    # Check if TLS version was found and print the result
    if [[ -n "$tls_version" ]]; then
        echo "TLS version supported for $domain: $tls_version"
    else
        echo "TLS version not supported for $domain"
    fi

    echo
}

# Loop through the domain list and check TLS version for each domain
for domain in "${domain_list[@]}"; do
    check_tls_version "$domain"
done