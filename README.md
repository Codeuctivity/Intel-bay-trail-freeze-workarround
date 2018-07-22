# Intel-bay-trail-freeze-workarround
Script to deaktivate c6* states to prevent a baytrail with ubuntu 16.04 and 18.04

This fix164 should work with the following processors :

J2850, J1850, J1750, N3510, N2810, N2805, N2910, N3520, N2920, N2820, N2806, N2815, J2900, J1900, J1800, N3530, N2930, N2830, N2807, N3540, N2940, N2840, N2808

I am currently testing out the script on my N3540. No problems so far.

cstateInfo.sh is to verify the script has worked. The "Disabled" Column will show a "1" for disabled states (or you take a look before running 
the script and after to check whether the offending C6* states have not been used [ie no change in 'time'])
c6off+c7on.sh is the script which will actually disable the C6* states. And enable C7

This will not work if you have booted with any cstate parameters. (remove intel_idle.max_cstate=1)
The script should be run at boot. If it works, make the change permanent by adding it to startup.

If all is well, you should probably also benefit from better power savings than originally. :smiley:



A quick walkthrough here - on systemd you're gonna want to create a service.

Drop the script at "/usr/bin/c6off+c7on.sh"

Make sure it can run with following command

sudo chmod 755 /usr/bin/c6off+c7on.sh

Then create a file "/etc/systemd/system/cstatefix.service"
with following contents:

    [Unit]
    Description=My script

    [Service]
    ExecStart=/usr/bin/c6off+c7on.sh

    [Install]
    WantedBy=multi-user.target

Then enable service with command

systemctl enable cstatefix.service

When you restart, use the info script to see if all is well.
You should get output similar to this:

cpu0 State  Name     Disabled  Latency  Residency         Time     Usage
         0  POLL            0        0          0     40996149     15951
         1  C1-BYT          0        1          1  18934852616  17313916
         2  C6N-BYT         1      300        275        75736       138
         3  C6S-BYT         1      500        560       319588       235
         4  C7-BYT          0     1200       4000   4756954535   1000102
         5  C7S-BYT         0    10000      20000   1638046880     82461

..with 1's in Disabled row for C6*, and the news C7 states available.

References:
https://bugzilla.kernel.org/show_bug.cgi?id=109051#c434
https://www.heise.de/newsticker/meldung/Patch-stabilisiert-Linux-auf-Atom-Celerons-3337456.html
https://forum.manjaro.org/t/intel-bay-trail-freezes-the-linux-kernel/1931/10
