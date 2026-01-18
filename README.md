# enum.sh

> bash script that automates the initial phase of recon by chaining together several popular tools for subdomain enumeration and static javascript files analysis

---

## tools used

* [findomain](https://github.com/findomain/findomain)
* [assetfinder](https://github.com/tomnomnom/assetfinder)
* [subfinder](https://github.com/projectdiscovery/subfinder)
* [github-subdomains](https://github.com/gwen001/github-subdomains)
* [amass](https://github.com/owasp-amass/amass)
* [httpx](https://github.com/projectdiscovery/httpx)
* [dnsx](https://github.com/projectdiscovery/dnsx)
* [naabu](https://github.com/projectdiscovery/naabu)
* [dirsearch](https://github.com/maurosoria/dirsearch)
* [paramspider](https://github.com/devanshbatham/ParamSpider)
* [kxss](https://github.com/Emoe/kxss)
* [cidr2ip](https://github.com/codeexpress/cidr2ip)
* [securitytrails](https://securitytrails.com/app/account/quota)
* [Cewl](https://github.com/digininja/CeWL)

resolvers.txt is updated on my VPS using cron command to curl the newset [resolvers.txt](https://github.com/trickest/resolvers/blob/main/resolvers.txt) and then override the current file with the newst version

keywords.txt file has certain words I'm looking for in subdomains.txt to extract subdomains I'll give priority for, I'll add new words when i find more of em

i'll prob add Cewl to create a wordlist from the target website to get more subdomains, i'll look into it rn
