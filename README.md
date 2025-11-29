# enum.sh

> a simple script that automates the initial phase of subdomain enumeration by chaining together several popular tools

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

## notes

resolvers.txt is updated on my VPS using cron command to curl the newset resolvers.txt and then override the current resolvers in that file, this ensure i have the least false positives
