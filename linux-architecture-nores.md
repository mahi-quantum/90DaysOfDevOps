[200~# Linux Architecture, Processes & systemd — Day 02

## 1. The core components of Linux (kernel, user space, init/systemd)
- Kernel: (apne words me — hardware se baat karta hai...)
kernel is the core of LinUx. It acts as a bridge between user programs(shell,app) and hardware.
- User space: (tum/apps yahan...)

this layer contains all user applications, program and commands.
They don't access hardware directly — they request the kernel through system calls. If a program crashes here, the whole system stays safe."


- systemd: (manager, PID 1...)
It checks whether all services are availble 
t is the firts process in linux (PID1) and act as the system manager. It starts, sto
ps and restarts services (like network, docker, ssh) ,auto restarts crashed services, and keeps logs. In devops we use systemctl to manage and debug services.
## 2.How processes are created and managed
- (program chalta hua = process, har ek ka PID...)

Process: A process is a running program loaded in memory. Each process has a unique ID called PID. Every process is created by a parent process, and the first process is systemd (PID 1).
Each process uses system resources (cpu, memoryect). process has its own memory space.Process states: Running (R) – executing or ready; Sleeping (S) – waiting for something, most common; Zombie (Z) – finished but entry still in process table; Stopped (T) – paused."



## 3. Process states
- Running: ...
- Sleeping: ...
- Zombie: ...
Process states: Running (R) – executing or ready to run; Sleeping (S) – waiting for input/resource, most common; Stopped (T) – paused by user; Zombie (Z) – finished but its entry still stays in the process table until the parent clears it."

## 4. List commands


- uname -r : shows kernel version
- ps aux : lists all running processs
- systemctl status : shows services health
- free -h :show memory (RAM)usage
- df -h : shows disk space
