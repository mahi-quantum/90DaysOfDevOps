Day 04 – Linux Practice: Processes and Services

Hands-on practice: running real commands on my system (Ubuntu / WSL2) and capturing the output. Service inspected: cron.

Process checks
1. ps aux | head

Lists the top running processes with user, PID, CPU, memory and state.

USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.0  0.3  22052 12356 ?        Ss   Oct08   1:53 /sbin/init
root           2  0.0  0.0   3072  1664 ?        Sl   Oct08   0:00 /init
root          45  0.0  0.4  50360 16512 ?        S<s  Oct08   1:41 /usr/lib/systemd/systemd-journald
root          96  0.1  0.1  25548  6528 ?        Ss   Oct08   3:41 /usr/lib/systemd/systemd-udevd
systemd+     143  0.0  0.3  21344 12416 ?        Ss   Oct08   0:29 /usr/lib/systemd/systemd-resolved
systemd+     146  0.0  0.1  91036  7424 ?        Ssl  Oct08   1:23 /usr/lib/systemd/systemd-timesyncd
root         172  0.0  0.0   4240  2560 ?        Ss   Oct08   0:18 /usr/sbin/cron -f -P
message+     173  0.0  0.1   9652  4736 ?        Ss   Oct08   0:28 dbus-daemon --system ...
2. pgrep -l cron

Finds a process by name and lists its PID + name.

172 cron
Service checks
3. systemctl status cron

Shows the health of the cron service.

● cron.service - Regular background program processing daemon
     Loaded: loaded (/usr/lib/systemd/system/cron.service; enabled; preset: enabled)
     Active: active (running) since Wed 2026-10-07 10:23:35 UTC; 2 days ago
       Docs: man:cron(8)
   Main PID: 172 (cron)
      Tasks: 1 (limit: 4505)
     Memory: 428.0K (peak: 4.6M)
        CPU: 25.395s
     CGroup: /system.slice/cron.service
             └─172 /usr/sbin/cron -f -P
Active: active (running) → service is up and running fine
enabled → it will start automatically on boot
Main PID: 172 → the process ID of the service
4. systemctl list-units --type=service | head

Lists all loaded services and whether they are running.

UNIT                         LOAD   ACTIVE SUB     DESCRIPTION
console-getty.service        loaded active running Console Getty
console-setup.service        loaded active exited  Set console font and keymap
cron.service                 loaded active running Regular background program processing daemon
dbus.service                 loaded active running D-Bus System Message Bus
getty@tty1.service           loaded active running Getty on tty1
keyboard-setup.service       loaded active exited  Set the console keyboard layout
kmod-static-nodes.service    loaded active exited  Create List of Static Device Nodes
nginx.service                loaded active running A high performance web server and a reverse proxy server
polkit.service               loaded active running Authorization Manager
running = currently active (cron, nginx, dbus)
exited = ran once and finished cleanly (keyboard-setup) — this is normal, not a failure
Log checks
5. journalctl -u cron -n 15 --no-pager

Shows the last 15 log lines for the cron service only.

Oct 10 04:17:01 Mahi CRON[9457]: pam_unix(cron:session): session opened for user root(uid=0) by root(uid=0)
Oct 10 04:17:01 Mahi CRON[9458]: (root) CMD (cd / && run-parts --report /etc/cron.hourly)
Oct 10 04:17:01 Mahi CRON[9457]: pam_unix(cron:session): session closed for user root
Oct 10 07:27:39 Mahi CRON[9712]: (root) CMD (test -x /usr/sbin/anacron || { cd / && run-parts --report /etc/cron.daily; })
Oct 10 08:17:01 Mahi CRON[9992]: (root) CMD (cd / && run-parts --report /etc/cron.hourly)

Reading a line: date time | hostname | SERVICE[PID] | what it did. Here cron opened a session every hour, ran its scheduled job, and closed it — all healthy, no errors.

6. tail -n 20 /var/log/syslog

Shows the last 20 lines of the main system log (all services).

2026-10-10T07:38:28 Mahi systemd[1]: Starting wsl-pro.service - Bridge to Ubuntu Pro agent on Windows...
2026-10-10T07:38:31 Mahi wsl-pro-service[9754]: WARNING Daemon: could not connect to Windows Agent: could not read agent port file ".ubuntupro/.address": no such file or directory
2026-10-10T08:09:35 Mahi systemd[1]: wsl-pro.service: Scheduled restart job, restart counter is at 50.
2026-10-10T08:17:01 Mahi CRON[9992]: (root) CMD (cd / && run-parts --report /etc/cron.hourly)
2026-10-10T08:20:45 Mahi systemd[1]: wsl-pro.service: Deactivated successfully.

Here I found a real WARNING: wsl-pro.service keeps failing to connect to the Windows Ubuntu Pro agent (a missing file) and restarts repeatedly (restart counter 50). It does not affect my Linux practice, but it is a good example of spotting an issue in logs.

Mini troubleshooting steps

When a service is down, the flow I would follow:

systemctl status <service> .
