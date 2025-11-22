# enum.sh

> a simple script that automates the initial phase of subdomain reconnaissance by chaining together several popular tools

---

## tools used

### 1 subdomain discovery
* [findomain](https://github.com/findomain/findomain) - for initial subdomain gathering
* [assetfinder](https://github.com/tomnomnom/assetfinder) - for finding associated subdomains
* [subfinder](https://github.com/projectdiscovery/subfinder) - for passive subdomain discovery
* [github-subdomains](https://github.com/gwen001/github-subdomains) - for subdomain gathering using github

### 2 permutation
* [alterx](https://github.com/projectdiscovery/alterx) - creates permutations to find more potential subdomains

### 3 verification
* [httpx](https://github.com/projectdiscovery/httpx) - verifies which subdomains have a working http/https server
* [dnsx](https://github.com/projectdiscovery/dnsx) - gathers subdomains that has certain dns records

### 4 crawling
* [gospider](https://github.com/jaeles-project/gospider) - crawling websites to find js files, pathes, api endpoints, parameteres

### 5 subdomain takeover verification
* [subzy](https://github.com/PentestPad/subzy) - uses it's built in fingerprints to detect possible subdomain takeover bugs

### 6 URL fetching
* [gau](https://github.com/lc/gau) - used to fetch URLs for later proccessing

### 7 parameter fetch and reflection checks
* [arjun](https://github.com/s0md3v/Arjun) - HTTP parameter discovery suite
* [kxss](https://github.com/Emoe/kxss) - checking for what special characters are reflected without encoding

### 8 port scanning
* [naabu](https://github.com/projectdiscovery/naabu) - for active and pssive port scanning

## notes

resolvers.txt is updated on my VPS using cron command to curl the newset resolvers.txt and then override the current resolvers in that file, this ensure i have the least false positives
