#!/bin/bash

clear
cat << "EOF"
   _____ _   _ _   _ __  __   _____ _    _
  | ____| \ | | | | |  \/  | / ____| |  | |
  | |__ |  \| | | | | \  / | (___  | |__| |
  | ___|| . ` | | | | |\/| | \___\ |  __  |
  | |   | |\  | |_| | |  | |_____) | |  | |
  |_____|_| \_| \_/ |_|  |_|_____/ |_|  |_|

EOF
echo -e "                              with <3 by y0ussefelgohre"
echo

if [ ! -f resolvers.txt ]; then
    echo "no resolvers file found, exiting."
    echo "use this URL to find resolvers -> https://github.com/trickest/resolvers"
    exit 1
fi

echo -n "enter target name (in this format -> target.TLD): "

read domain

mkdir -p "$domain"

cd "$domain"

echo "running findomain, assetfinder, subfinder, github-subdomains, subbdom API"

findomain -t "$domain" -u subdomains1.txt &
assetfinder --subs-only "$domain" > subdomains2.txt &
subfinder -d "$domain"  -config ~/.config/subfinder/config.yaml -o subdomains3.txt &
github-subdomains -d "$domain" -t "$github_token" -o subdomains4.txt &
curl -H "x-api-key: "$subbdom_token"" "https://api.subbdom.com/v1/search?z=$domain" | jq -r '.[]' > subdomains5.txt &

wait

for file in subdomains*.txt; do
    [ -s "$file" ] || rm -f "$file"
done

cat subdomains*.txt 2>/dev/null | sort -u > subdomains.txt

rm -f subdomains{1..5}.txt

echo "[findomain, assetfinder, subfinder, github-subdomains, subbdom API]"

cat subdomains.txt | sort -u > all_domains.txt

dnsx -l all_domains.txt -r ../resolvers.txt -json -o master_dns.json

echo "running dnsx to get subdomains that resolve"

cat master_dns.json | jq -r 'select(.status_code == "NOERROR") | .host' | sort -u > resolved_subdomains.txt

if [ ! -s resolved_subdomains.txt ]; then
    echo "no resolved subdomains found, exiting."
    rm -f resolved_subdomains.txt
    exit 1
else
    echo "[dnsx]"
fi

echo "running httpx [200 OK]"

httpx -l resolved_subdomains.txt -mc 200 -timeout 5 -o 200_OK_subdomains.txt

if [ ! -s 200_OK_subdomains.txt ]; then
    echo "no 200 OK subdomains found"
    rm -f 200_OK_subdomains.txt
    exit 1
else
    echo "[httpx]"
    grep -Ef ../keywords.txt 200_OK_subdomains.txt > important_200_subdomains.txt
    if[ ! -s important_200_subdomains.txt ]; then
        echo "no alive important subdomain"
        rm -f important_200_subdomains.txt
    else
        echo "important subdomains found"
    fi
fi

echo "running paramspider"

paramspider -l 200_OK_subdomains.txt

echo "paramspider found URLs"

cat results/*.txt > all_URls.txt

rm -r results/

echo "running kxss"

cat all_URls.txt | kxss > kxss_results.txt

echo "running httpx [404]"

httpx -l resolved_subdomains.txt -mc 404 -timeout 5 -o 404_subdomains.txt

if [ ! -s 404_subdomains.txt ]; then
    echo "no dead subdomains found"
    rm -f 404_subdomains.txt
else
    echo "[httpx]"
    grep -Ef ../keywords.txt 404_subdomains.txt > important_404_subdomains.txt
    if[ ! -s important_404_subdomains.txt ]; then
        echo "no important subdomain"
        rm -f important_404_subdomains.txt
    else
        echo "important subdomains found"
    fi
fi

rm -f resolved_subdomains.txt

echo "running dnsx again to get IPs for live subdomains"

cat master_dns.json | jq -r 'select(.a != null) | .a[]' | sort -u > alive_IPs.txt

if [ ! -s alive_IPs.txt ]; then
    echo "no IPs found for live subdomains"
    rm -f alive_IPs.txt
else
    echo "[dnsx]"
fi

echo "running naabu"

naabu -list alive_IPs.txt -top-ports 1000 -exclude-cdn -rate 750 -verify -o naabu_results.txt

if [ ! -s naabu_results.txt ]; then
    echo "no results found with naabu"
    rm -f naabu_results.txt
else
    echo "[naabu]"
fi

echo "running dnsx again to get subdomains that has CNAME DNS records from the resolved subdomains"

cat master_dns.json | jq -r 'select(.cname != null) | .host' | sort -u > CNAME_subdomains.txt

if [ ! -s CNAME_subdomains.txt ]; then
    echo "no subdomains with CNAME DNS record found, exiting."
    rm -f CNAME_subdomains.txt
else
   echo "step 10 done [dnsx]"
   rm -f master_dns.json
   echo "running subjack"
   subjack -w CNAME_subdomains.txt -t 100 -timeout 30 -c ../fingerprints.json -o subjack_results.txt
    if [ ! -s subjack_results.txt ]; then
        echo "no subdomain takeover found"
        rm -f subjack_results.txt
    else
        echo "[subjack]"
    fi
fi

echo "running dirsearch"

mkdir -p dirsearch

source ~/.venv/bin/activate

python3 "$HOME/dirsearch/dirsearch.py" -l 200_OK_subdomains.txt -t 30 -i 200 -o dirsearch/dirsearch_results.txt

deactivate
