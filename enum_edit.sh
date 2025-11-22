#!/bin/bash

if [ ! -f resolvers.txt ]; then
    echo "no resolvers file found, exiting."
    echo "use this URL to find resolvers -> https://github.com/trickest/resolvers"
    exit 1
fi

echo -n "enter target name (in this format -> target.TLD): "
read domain

mkdir -p "$domain"
cd "$domain"

echo ""

echo "running findomain, assetfinder, subfinder, github-subdomains, subbdom API"

findomain -t "$domain" -u subdomains1.txt &
$HOME/go/bin/assetfinder --subs-only "$domain" > subdomains2.txt &
$HOME/go/bin/subfinder -d "$domain"  -config ~/.config/subfinder/config.yaml -o subdomains3.txt &
$HOME/go/bin/github-subdomains -d "domain" -t $GITHUB_TOKEN -o subdomains4.txt &

wait

if [ ! -s subdomains1.txt ] && [ ! -s subdomains2.txt ] && [ ! -s subdomains3.txt ] && [ ! -s subdomains4.txt ]; then
   echo "subdomain file is empty, exiting."
   rm -f subdomains1.txt subdomains2.txt subdomains3.txt subdomains4.txt
   exit 1
else
   cat subdomains1.txt subdomains2.txt subdomains3.txt subdomains4.txt | sort -u -o subdomains.txt
   curl -H "x-api-key: $SUBBDOM_API_KEY" "https://api.subbdom.com/v1/search?z=$domain" | jq -r '.[]' >> subdomains.txt
   rm -f subdomains1.txt subdomains2.txt subdomains3.txt subdomains4.txt
fi

echo "step 1 done [findomain, assetfinder, subfinder, github-subdomains, subbdom API]"

echo "running alterx"

$HOME/go/bin/alterx -l subdomains.txt -verbose -limit 50000 -o permutations.txt

if [ ! -s permutations.txt ]; then
    echo "no permutations generated"
    rm -f permutations.txt
else
    echo "running dnsx to get dead subdomains"
    cat subdomains.txt permutations.txt | sort -u > all_domains.txt
    $HOME/go/bin/dnsx -l all_domains.txt -r ../resolvers.txt -json -o master_dns.json
    cat master_dns.json | jq -r 'select(.status_code == "NXDOMAIN" or .status_code == "SERVFAIL" or .status_code == "REFUSED") | .host' | sort -u > dead_subdomains.txt
    	if [ ! -s dead_subdomains.txt ]; then
            echo "no dead subdomains found"
            rm -f dead_subdomains.txt
	else
    	    echo "dead subdomains found"
    	    echo "step 2 done [dnsx]"
	fi
    echo "step 3 done [alterx]"
fi

echo "running dnsx to get subdomains that resolve"

cat master_dns.json | jq -r 'select(.status_code == "NOERROR") | .host' | sort -u > resolved_subdomains.txt

if [ ! -s resolved_subdomains.txt ]; then
    echo "no resolved subdomains found, exiting."
    rm -f resolved_subdomains.txt
    exit 1
else
    sort -u resolved_subdomains.txt -o resolved_subdomains.txt
    echo "step 4 done [dnsx]"
fi

echo "running naabu"

$HOME/go/bin/naabu -list resolved_subdomains.txt -p - -exclude-cdn -rate 750 -verify -o naabu_results.txt

if [ ! -s naabu_results.txt ]; then
    echo "no results found with naabu"
    rm -f naabu_results.txt
else
    echo "step 5 done [naabu]"
fi

echo "running httpx"

$HOME/go/bin/httpx -l resolved_subdomains.txt -mc 401,402,301,302,500,200 -timeout 5 -o 200_OK_subdomains.txt

if [ ! -s 200_OK_subdomains.txt ]; then
    echo "no 200 OK subdomains found"
    rm -f 200_OK_subdomains.txt
    exit 1
else
    sort -u 200_OK_subdomains.txt -o 200_OK_subdomains.txt
    echo "step 6 done [httpx]"
fi

echo "running gospider - DISABLED FOR NOW"

#$HOME/go/bin/gospider -S 200_OK_subdomains.txt -o gospider_results -u web -a -r --no-redirect --js false -c 10

echo "running dnsx again to get IPs for live subdomains"

grep -Ff 200_OK_subdomains.txt master_dns.json | jq -r 'select(.a != null) | .a[]' | sort -u > alive_IPs.txt

if [ ! -s alive_IPs.txt ]; then
    echo "no IPs found for live subdomains"
    rm -f alive_IPs.txt
else
    echo "step 7 done [dnsx]"
fi

echo "running VhostFinder"

$HOME/go/bin/VhostFinder -ips alive_IPs.txt -wordlist dead_subdomains.txt -verify > VhostFinder_results.txt

if [ ! -s VhostFinder_results.txt ]; then
    echo "no Vhosts found"
    rm -f VhostFinder_results.txt
else
    echo "step 8 done [VhostFinder]"
fi

echo "starting archive deep dive"

cat 200_OK_subdomains.txt | $HOME/go/bin/gau --o raw_results.txt --threads 15

if [ -s raw_results.txt ]; then
    echo "step 9 done [gau]"
    cat raw_results.txt | grep -vE "\.jpg|\.jpeg|\.png|\.gif|\.svg|\.css|\.ico|\.woff|\.ttf" > clean_urls.txt
    cat clean_urls.txt | uro > unique_urls.txt
    cat unique_urls.txt | grep "=" | $HOME/go/bin/kxss > kxss_results.txt
    if [ -s kxss_results.txt ]; then
        echo "step 10 done [kxss]"
    else
        rm -f kxss_results.txt
    fi
fi

echo "running dnsx again to get subdomains that has CNAME DNS records from the resolved subdomains"

cat master_dns.json | jq -r 'select(.cname != null) | .host' | sort -u > CNAME_subdomains.txt

if [ ! -s CNAME_subdomains.txt ]; then
    echo "no subdomains with CNAME DNS record found, exiting."
    rm -f CNAME_subdomains.txt
    exit 1
else
   echo "step 11 done [dnsx]"
   echo "running subzjack"
   $HOME/go/bin/subjack -w CNAME_subdomains.txt -t 100 -timeout 30 -c ../fingerprints.json -o subjack_results.txt
    if [ ! -s subjack_results.txt ]; then
        echo "no subdomain takeover found"
        rm -f subjack_results.txt
    else
        echo "step 12 done [subjack]"
    fi
fi
