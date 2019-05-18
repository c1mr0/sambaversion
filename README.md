# Description
Samaversion.sh is a (Linux) shell script for detecting which version of Samba is running on a remote host.
This can be useful in situations where tools like Nmap, Metasploit etc. are either reporting no results or cannot be used for whatever reason.

# Usage
`sambaversion.sh <host> ['username%password']"`

When username%password is not supplied, a null session will be attempted.

# Examples
```shell
sambaversion.sh 10.0.0.1  
sambaversion.sh 192.168.1.1 'john%secret123456'
```

# Notes
The script relies on smbclient and tcpdump.
