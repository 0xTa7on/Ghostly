
# **Ghostly v1**

**A Stealthy, Concurrent, and Flexible Web Content Discovery Tool**

Ghostly is a powerful web fuzzer designed for the modern web. It performs content discovery with a focus on stealth and speed, allowing you to find hidden directories and files without being easily detected and blocked by Web Application Firewalls (WAFs) or rate limiters.

This tool is created for ethical security testing and research purposes.

##  **Features**

* **High-Level Stealth:** Evades detection by rotating User-Agents, HTTP headers, and proxy addresses for each request.  
* **Concurrent & Fast:** Uses parallel processing to send multiple requests at once, dramatically speeding up scans.  
* **Full Proxy Support:** Route traffic through a single proxy, a list of proxies, or the Tor network (--tor).  
* **Extensible:** Automatically appends custom extensions (-x .php,.html) to every word in your wordlist.  
* **Robust & Reliable:** Built with strong input validation to prevent common errors and ensure stable scanning.  
* **User-Friendly Output:** Features a clean, color-coded output to easily spot interesting status codes.

##  **Author & Support**

This tool was created by **0xTa7on**.

If this tool helped get you a bounty or you'd just like to buy me a coffee:\!  
[![][image1]](http://ko-fi.com/0xta7on)

## **🛠️ Installation**

Ghostly is a Bash script and works on Linux, Mac OS, and Windows Subsystem for Linux (WSL).

\# 1\. Clone the repository  
git clone \[https://github.com/your-username/ghostly.git\](https://github.com/your-username/ghostly.git)  
cd ghostly

\# 2\. Make the script executable  
chmod \+x ghostly\_merged.sh install.sh

\# 3\. Run the installer to make the command available system-wide  
sudo ./install.sh

\# You can now run the tool from anywhere\!  
ghostly \-h

## **kullanım (Usage)**

ghostly \-u \<URL\> \-w \<WORDLIST\> \[OPTIONS\]

### **Examples**

**Basic Scan:**

ghostly \-u "\[http://example.com/FUZZ\](http://example.com/FUZZ)" \-w /usr/share/wordlists/dirb/common.txt

**Fast Scan with Extensions:**

ghostly \-u "\[http://example.com/FUZZ\](http://example.com/FUZZ)" \-w common.txt \-t 50 \-x .php,.bak  


[image1]: <data:image/png;base64,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>
