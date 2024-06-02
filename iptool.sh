#!/bin/bash

# Fancy header
echo "╔══════════════════════════════════════════════════════════╗"
echo "║                  HELLO HACKERS                           ║"
echo "║                                                          ║"
echo "║      Made on Youtube live check it out                   ║"
echo "║      Youtube: https://www.youtube.com/@LinuxbyVikku      ║"
echo "║                                                          ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
echo ""

# Check if domain is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <domain>"
  exit 1
fi

DOMAIN=$1

# Run subfinder to find subdomains and save to subd.txt
subfinder -d $DOMAIN -silent -o subd.txt

echo "Subdomains saved to subd.txt"

# Check if subd.txt is not empty
if [ ! -s subd.txt ]; then
  echo "No subdomains found in subd.txt"
  exit 1
fi

# Run the shodan command to search for IPs and save to shodan.txt
shodan search "hostname:$DOMAIN" --fields ip_str > shodan.txt

echo "IPs saved to shodan.txt"

# Check if shodan.txt is not empty
if [ ! -s shodan.txt ]; then
  echo "No IPs found in shodan.txt"
  exit 1
fi

# Run rustscan on the IPs from shodan.txt and save the open ports to rustresult.txt
rustscan -a shodan.txt -r 1-65535 | tee rustresult.txt

echo "Open ports saved to rustresult.txt"

# Extract IPs with ports from rustresult.txt and save to ips_with_ports.txt
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}:[0-9]+' rustresult.txt | sort -u > ips_with_ports.txt

echo "Extracted IPs with ports saved to ips_with_ports.txt"

# Merge ips_with_ports.txt and subd.txt into raw.txt
cat ips_with_ports.txt subd.txt | sort -u > raw.txt

echo "Merged IPs with ports and subdomains saved to raw.txt"

# Run httpx on the raw.txt and save the output to htpx.txt
httpx -l raw.txt -o htpx.txt

echo "HTTPX results saved to htpx.txt"

# Run Nuclei on htpx.txt and save the output to nuke.txt
nuclei -l htpx.txt -o nuke.txt

echo "Nuclei results saved to nuke.txt"


# Run ffuf using the specified command
cat ips_with_ports.txt | xargs -I@ sh -c 'ffuf -w wordlists.txt -u http://@/FUZZ -mc 200' > ffufout.txt

echo "FFUF results saved to ffufout.txt"

grep -iE 'wordpress' nuke.txt | grep -oE 'https?://[^[:space:]]+' > wordpress_urls.txt
grep -iE 'aem' nuke.txt | grep -oE 'https?://[^[:space:]]+' > aem_urls.txt
grep -iE 'nginx' nuke.txt | grep -oE 'https?://[^[:space:]]+' > nginx_urls.txt
grep -iE 'cloudflare' nuke.txt | grep -oE 'https?://[^[:space:]]+' > cloudflare_urls.txt
grep -iE 'akamai' nuke.txt | grep -oE 'https?://[^[:space:]]+' > akamai_urls.txt
grep -iE 'amazon' nuke.txt | grep -oE 'https?://[^[:space:]]+' > amazon_urls.txt
grep -iE 'cisco' nuke.txt | grep -oE 'https?://[^[:space:]]+' > cisco_urls.txt
grep -iE 'jira' nuke.txt | grep -oE 'https?://[^[:space:]]+' > jira_urls.txt
grep -iE 'jenkins' nuke.txt | grep -oE 'https?://[^[:space:]]+' > jenkins_urls.txt
grep -iE 'contentful' nuke.txt | grep -oE 'https?://[^[:space:]]+' > contentful_urls.txt
grep -iE 'hubspot' nuke.txt | grep -oE 'https?://[^[:space:]]+' > hubspot_urls.txt
grep -iE 'apache' nuke.txt | grep -oE 'https?://[^[:space:]]+' > apache_urls.txt
grep -iE 'drupal' nuke.txt | grep -oE 'https?://[^[:space:]]+' > drupal_urls.txt
grep -iE 'phpmyadmin' nuke.txt | grep -oE 'https?://[^[:space:]]+' > phpmyadmin_urls.txt
grep -iE 'grafana' nuke.txt | grep -oE 'https?://[^[:space:]]+' > grafana_urls.txt
grep -iE 'graphql' nuke.txt | grep -oE 'https?://[^[:space:]]+' > graphql_urls.txt


