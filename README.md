# enum.sh

> bash script that automates the initial phase of recon by chaining together several popular tools for subdomain enumeration and static javascript files analysis

---

## tools used

* [findomain](https://github.com/findomain/findomain)
* [assetfinder](https://github.com/tomnomnom/assetfinder)
* [subfinder](https://github.com/projectdiscovery/subfinder)
* [github-subdomains](https://github.com/gwen001/github-subdomains) 
* [httpx](https://github.com/projectdiscovery/httpx)
* [dnsx](https://github.com/projectdiscovery/dnsx)
* [naabu](https://github.com/projectdiscovery/naabu)
* [dirsearch](https://github.com/maurosoria/dirsearch)
* [paramspider](https://github.com/devanshbatham/ParamSpider)
* [kxss](https://github.com/Emoe/kxss)
* [cidr2ip](https://github.com/codeexpress/cidr2ip)
* [subjs](https://github.com/lc/subjs)
* [linkfinder](https://github.com/GerbenJavado/LinkFinder)
* [secretfinder](https://github.com/m4ll0k/SecretFinder)
* [securitytrails](https://securitytrails.com/app/account/quota)

resolvers.txt is updated on my VPS using cron command to curl the newset [resolvers.txt](https://github.com/trickest/resolvers/blob/main/resolvers.txt) and then override the current file with the newst version

keywords.txt file has certain words I'm looking for in subdomains.txt to extract subdomains I'll give priority for, I'll add new words when i find more words that suits the file purposes
