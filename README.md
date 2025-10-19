 
<h3 align="left">Ghostly V1</h3>


Ghostly is a fast and stealthy web fuzzer built for modern web reconnaissance. It focuses on discovering hidden directories and files while minimizing detection by WAFs, rate-limiters, and IDS/IPS systems.


<h3 align="left">Features:</h3>

<b>High-Level Stealth</b>: Evades detection by rotating User-Agents, HTTP headers, and proxy addresses for each request.
<br> </br><b>Concurrent & Fast</b>: Uses parallel processing to send multiple requests at once, dramatically speeding up scans.
<br> </br><b>Full Proxy Support</b>: Route traffic through a single proxy, a list of proxies, or the Tor network (--tor).
<br> </br><b>Extensible</b>: Automatically appends custom extensions (-x .php,.html) to every word in your wordlist.




 
<h3 align="left">Support:</h3>

This tool was created by 0xTa7on.
If this tool helped get you a bounty or you'd just like to buy me a coffee:!
<p><a href="https://ko-fi.com/0xTa7on"> <img align="left" src="https://cdn.ko-fi.com/cdn/kofi3.png?v=3" height="50" width="210" alt="0xTa7on" /></a></p>                                                                           


<br> 
</br>












<h3 align="left">Installation:</h3>


Ghostly is a Bash script and works on Linux, Mac OS, and Windows Subsystem for Linux (WSL).
# 1. Clone the repository
git clone [https://github.com/0xta7on/ghostly.git](https://github.com/0xta7on/ghostly.git)<br></br>
cd ghostly

# 2. Make the script executable
chmod +x ghostly.sh install.sh

# 3. Run the installer to make the command available system-wide
sudo ./install.sh

# You can now run the tool from anywhere!
ghostly -h


<b> <h3 align="left">(Usage)</h3> </b>
ghostly -u <URL> -w <WORDLIST> [OPTIONS]<br></br>


<b> Examples </b><br></br>
Basic Scan:<br></br>
ghostly -u [http://example.com/FUZZ](http://example.com/FUZZ) -w  /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt -a user-Agents.txt


Fast Scan with Extensions: <br></br>
ghostly -u [http://example.com/FUZZ](http://example.com/FUZZ) -w /usr/share/wordlists/dirb/common.txt -a user-Agents.txt -t 50 -x .php,.bak


