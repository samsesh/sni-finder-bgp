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
echo $domain_list
#domain_list=("xbox.com" "yahoo.com" "nadia.net")
# Function to check TLS version for a domain
# check_tls_version() {
#     local domain="$1"
#     local tls_output
#     local tls_version

#     tls_output=$(openssl s_client -connect "$domain":443 -tls1_3 2>&1)
#     tls_version=$(echo "$tls_output" | grep "Protocol" | awk '{print $2}')

#     echo "TLS check for $domain:"
#     echo "$tls_output"

#     if [[ "$tls_version" == "TLSv1.3" ]]; then
#         echo "TLS version 1.3 is supported for $domain."
#         echo "$domain" >> $usl.txt
#     else
#         echo "TLS version 1.3 is not supported for $domain."
#     fi

#     echo
# }

# # Loop through the domain list and check TLS version for each domain
# for domain in "${domain_list[@]}"; do
#     check_tls_version "$domain"
# done
# Function to check TLS version for a domain
# check_tls_version() {
#     local domain="$1"
#     local tls_version

#     # Perform the TLS handshake and capture the output in a variable
#     tls_output=$(openssl s_client -connect "$domain":443 -tls1_3 2>&1  | grep "TLSv1.3")
#     echo $tls_output
#     # Extract the TLS version from the output
#     #tls_version=$(echo "$tls_output" | grep "TLSv1.3")

#     # Check if TLS version was found and print the result
#     if [[ -n "$tls_output" ]]; then
#         echo "TLS version 1.3 is supported for $domain."
#         $domain >> $url.txt
#     else
#         echo "TLS version 1.3 is not supported for $domain."
#     fi

#     echo
# }

# # Loop through the domain list and check TLS version for each domain
# for domain in "${domain_list[@]}"; do
#     check_tls_version "$domain"
# done
# Output directory for TLS 1.3 enabled domains
output_directory="tls1.3_$url"

# Create the output directory if it doesn't exist
mkdir -p "$output_directory"

# Loop through the array of domains
for domain in "${domain_list[@]}"; do
    # Check TLS version using curl
    tls_version=$(curl -sIiv --tlsv1.3 "$domain" 2>&1 | grep -o 'TLSv1.3')

    # If TLS version is found, save the file
    if [[ "$tls_version" == "TLSv1.3" ]]; then
        echo "Domain $domain supports TLS 1.3. Downloading..."
        curl -s -o "$output_directory/$domain.html" "$domain"
        echo "File saved as $output_directory/$domain.html"
    else
        echo "Domain $domain does not support TLS 1.3."
    fi
done