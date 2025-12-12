# enum.sh

> a simple script that automates the initial phase of recon by chaining together several popular tools

---

## tools used

### 1 subdomain discovery
* [findomain](https://github.com/findomain/findomain) - for initial subdomain gathering
* [assetfinder](https://github.com/tomnomnom/assetfinder) - for finding associated subdomains
* [subfinder](https://github.com/projectdiscovery/subfinder) - for passive subdomain discovery
* [github-subdomains](https://github.com/gwen001/github-subdomains) - for subdomain gathering using github

### 2 verification
* [httpx](https://github.com/projectdiscovery/httpx) - verifies which subdomains have a working http/https server
* [dnsx](https://github.com/projectdiscovery/dnsx) - gathers subdomains that has certain dns records

### 3 subdomain takeover verification
* [subjack](https://github.com/haccer/subjack) - uses it's built in fingerprints to detect possible subdomain takeover bugs

### 4 port scanning
* [naabu](https://github.com/projectdiscovery/naabu) - for active and pssive port scanning

### 5 content discovery
* [dirsearch](https://github.com/maurosoria/dirsearch) - for content discovery using it's built in wordlists

### 6 url mining
* [paramspider](https://github.com/devanshbatham/ParamSpider) - for url mining

### 7 injection checking
* [kxss](https://github.com/Emoe/kxss) - for checking reflection

### 8 CIDR to IP
* [cidr2ip](https://github.com/codeexpress/cidr2ip) - for converting CIDR to a list of IPs so i can use it later

===

## - javascript Analysis
### 9 gathering javascript files
* [subjs](https://github.com/lc/subjs) - for gathering javascript files from a list of subdomains or URLs

### 10 static javascript file analysis
* [linkfinder](https://github.com/GerbenJavado/LinkFinder) - for finding endpoints in javascript files
* [secretfinder](https://github.com/m4ll0k/SecretFinder) for searching for sensitive data in javascript files

===

## notes

resolvers.txt is updated on my VPS using cron command to curl the newset resolvers.txt and then override the current resolvers in that file, this ensure i have the least false positives

keywords.txt file has keywords I'm looking for in the subdomains.txt file to extract important files, I'll update this file when i find a new keyword that suits the file purpose
