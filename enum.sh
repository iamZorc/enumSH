#!/bin/bash

clear

cat << "EOF"

  ███████╗███╗   ██╗██╗   ██╗███╗   ███╗███████╗██╗  ██╗
  ██╔════╝████╗  ██║██║   ██║████╗ ████║██╔════╝██║  ██║
  █████╗  ██╔██╗ ██║██║   ██║██╔████╔██║███████╗███████║
  ██╔══╝  ██║╚██╗██║██║   ██║██║╚██╔╝██║╚════██║██╔══██║
  ███████╗██║ ╚████║╚██████╔╝██║ ╚═╝ ██║███████║██║  ██║
  ╚══════╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝
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
subfinder -d "$domain"  -all -recursive -config ~/.config/subfinder/config.yaml -o subdomains3.txt &
github-subdomains -d "$domain" -t "$github_token" -o subdomains4.txt &
curl -H "x-api-key: "$subbdom_token"" "https://api.subbdom.com/v1/search?z=$domain" | jq -r '.[]' > subdomains5.txt &
#amass enum --passive -d "$domain" | grep "\.$domain$" | awk '{print $1}' > subdomains6.txt  &

wait

for file in subdomains*.txt; do
    [ -s "$file" ] || rm -f "$file"
done

cat subdomains*.txt 2>/dev/null | sort -u > all_domains.txt

rm -f subdomains{1..5}.txt

echo "[findomain, assetfinder, subfinder, github-subdomains, subbdom API]"

js_recon() {
    local input_file="$1"
    local output_file="$2"

    subjs -i "$input_file" | grep "$domain" > "$output_file"
    if [ ! -s "$output_file" ]; then
        echo "subjs returned no results"
        rm -f "$output_file"
        return 1
    else
        echo "[subjs]"
    fi

    source ../../.venv/bin/activate
    python3 ../../LinkFinder/linkfinder.py -i "$output_file" -o cli | sort > linkfinder_results.txt
    if [ ! -s linkfinder_results.txt ]; then
        echo "linkfinder returned no results"
        rm -f linkfinder_results.txt
    else
        echo "[linkfinder]"
    fi

    python3 ../../secretfinder/SecretFinder.py -i "$output_file" -o cli | sort > secretfinder_results.txt
    if [ ! -s secretfinder_results.txt ]; then
        echo "secretfinder returned no results"
        rm -f secretfinder_results.txt
    else
        echo "[secretfinder]"
    fi

    deactivate
}

dnsx -l all_domains.txt -r ../resolvers.txt -json -o master_dns.json

echo "running httpx [200 OK]"

httpx -l all_domains.txt -mc 200 -timeout 5 -o 200_OK_subdomains.txt

if [ ! -s 200_OK_subdomains.txt ]; then
    echo "no 200 OK subdomains found"
    rm -f 200_OK_subdomains.txt
    exit 1
else
    echo "[httpx]"
    grep -Ef ../keywords.txt 200_OK_subdomains.txt > important_200_subdomains.txt
    if [ ! -s important_200_subdomains.txt ]; then
        echo "no alive important subdomain found"
        rm -f important_200_subdomains.txt
    else
        echo "alive important subdomains found"
    fi
fi

js_recon "200_OK_subdomains.txt" "200_js.txt"

echo "running paramspider"

paramspider -l 200_OK_subdomains.txt

cat results/*.txt > all_URls.txt
rm -r results/

if [ ! -s all_URls.txt ]; then
    echo "no URLs founs"
    rm -r all_URls.txt
else
    echo "[paramspider]"
fi

echo "running kxss"

cat all_URls.txt | kxss > kxss_results.txt

echo "[kxss]"

echo "running httpx [404]"

httpx -l all_domains.txt -mc 404 -timeout 5 -o 404_subdomains.txt

if [ ! -s 404_subdomains.txt ]; then
    echo "no dead subdomains found"
    rm -f 404_subdomains.txt
else
    echo "[httpx]"
    grep -Ef ../keywords.txt 404_subdomains.txt > important_404_subdomains.txt
    if [ ! -s important_404_subdomains.txt ]; then
        echo "no important subdomain found"
        rm -f important_404_subdomains.txt
    else
        echo "important subdomains found"
    fi
fi

js_recon "404_subdomains.txt" "404_js.txt"

echo -n "do you want to enter phase 2 (port scanning)? (y/n): "
read phase2_choice

phase2_choice_lower=$(echo "$phase2_choice" | tr '[:upper:]' '[:lower:]')

if [[ "$phase2_choice_lower" == "y" || "$phase2_choice_lower" == "yes" ]]; then
    echo "enter targets ASN (starts with 'AS'): "
    read target_ASN

    asnmap -a "$target_ASN" -o CIDR_for_target.txt

    if [ ! -s CIDR_for_target.txt ]; then
        echo "no CIDR found with that ASN found"
        rm -f CIDR_for_target.txt
    else
        echo "found CIDR for that ASN, converting to IPs the script can proccess"
        cidr2ip -f CIDR_for_target.txt > target_IPs.txt
        echo "running naabu"
        naabu -list target_IPs.txt -top-ports 1000 -exclude-cdn -rate 1000 -verify -o naabu_results.txt
        if [ ! -s naabu_results.txt ]; then
            echo "no results found with naabu"
            rm -f naabu_results.txt
            exit 1
        else
            echo "[naabu]"
        fi
        httpx -l naabu_results.txt -sc -cl -ct -title -server -td -mc 200 -t 100 -o httpx_target_IPs.txt
        httpx -l target_IPs.txt -sc -cl -ct -title -server -td -mc 200 -t 100 >> httpx_target_IPs.txt
        if [ ! -s httpx_target_IPs.txt ]; then
            echo "no results found with httpx for target IPs"
            rm -f httpx_target_IPs.txt
        else
            echo "[httpx]"
        fi
    fi

    echo "running dirsearch"

    mkdir -p dirsearch

    source ~/.venv/bin/activate

    python3 "$HOME/dirsearch/dirsearch.py" -l naabu_results.txt -t 30 -i 200 -o dirsearch/200_dirs.txt

    if [ ! -s dirsearch/200_dirs.txt ]; then
        echo "no results found with dirsearch for alive subdomains"
        rm -f dirsearch/200_dirs.txt
    else
        echo "[dirsearch]"
    fi

    deactivate
elif [[ "$phase2_choice_lower" == "n" || "$phase2_choice_lower" == "no" ]]; then
    echo "skipping phase 2, continuing..."
fi

echo "running dnsx again to get subdomains that has CNAME DNS records from the resolved subdomains"

cat master_dns.json | jq -r 'select(.cname != null) | .host' | sort -u > CNAME_subdomains.txt

if [ ! -s CNAME_subdomains.txt ]; then
    echo "no subdomains with CNAME DNS record found, exiting."
    rm -f CNAME_subdomains.txt
else
   echo "step 10 done [dnsx]"
   rm -f master_dns.json
fi
