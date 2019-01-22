# Intel-bay-trail-freeze-workarround

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/3429ae89d23a46c98f936934c46fe933)](https://app.codacy.com/app/stesee/Intel-bay-trail-freeze-workarround?utm_source=github.com&utm_medium=referral&utm_content=Codeuctivity/Intel-bay-trail-freeze-workarround&utm_campaign=Badge_Grade_Settings)

Script to deactivate c6* states to prevent a freezing baytrail with ubuntu 16.04, 18.04 and probably any other linux running on baytrail that keeps freezing in cause of <https://bugzilla.kernel.org/show_bug.cgi?id=109051#c434>

This fix should work with the following processors :

J2850, J1850, J1750, N3510, N2810, N2805, N2910, N3520, N2920, N2820, N2806, N2815, J2900, J1900, J1800, N3530, N2930, N2830, N2807, N3540, N2940, N2840, N2808

I am currently using this script on a N3540.

cstateInfo.sh is to verify the script has worked. The "Disabled" Column will show a "1" for disabled states (or you take a look before running
the script and after to check whether the offending C6* states have not been used (ie no change in 'time'))
c6off+c7on.sh is the script which will actually disable the C6* states. And enable C7

This will not work if you have booted with any cstate parameters. (remove intel_idle.max_cstate=1)
The script should be run at boot. If it works, make the change permanent by adding it to startup.

If all is well, you should probably also benefit from better power savings than originally. :smiley:

A quick walkthrough here - on systemd you're gonna want to create a service.

Drop the script at "/usr/bin/c6off+c7on.sh"

Make sure it can run with following command

```shell
sudo chmod 755 /usr/bin/c6off+c7on.sh
```
Then create a file "/etc/systemd/system/cstatefix.service"
with following contents:
```shell
    [Unit]
    Description=My script

    [Service]
    ExecStart=/usr/bin/c6off+c7on.sh

    [Install]
    WantedBy=multi-user.target
```
Then enable service with command
```shell
systemctl enable cstatefix.service
```

When you restart, use the info script to see if all is well.
You should get output similar to this:
```shell
username@host:~$ /usr/bin/cstateInfo.sh
cpu0 State  Name  Disabled  Latency  Residency        Time     Usage
         0  POLL         0        0          0     9132365      2865
         1  C1           0        1          1  2757941110   1887178
         2  C6N          1      300        275     3711301       849
         3  C6S          1      500        560     9173193      1915
         4  C7           0     1200       4000  3024534798    419933
         5  C7S          0    10000      20000  3159737561    110653
```
..with 1's in Disabled row for C6*, and the news C7 states available.

References:
<https://bugzilla.kernel.org/show_bug.cgi?id=109051#c434>
<https://www.heise.de/newsticker/meldung/Patch-stabilisiert-Linux-auf-Atom-Celerons-3337456.html>
<https://forum.manjaro.org/t/intel-bay-trail-freezes-the-linux-kernel/1931/10>
