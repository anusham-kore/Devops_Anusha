# Linux Interview Preparation Guide

This README is a focused roadmap for Linux interview preparation at around the 4-year experience level. It covers the core Linux administration topics, command-line skills, troubleshooting areas, and DevOps-oriented Linux knowledge commonly expected in system administration, production support, and DevOps interviews.

## Target Profile

This guide is best for:
- Engineers with around 4 years of Linux or DevOps experience
- Candidates preparing for Linux Administrator, DevOps Engineer, Cloud Support, or Production Support interviews
- Learners who want practical command-level confidence, not only theory

## Linux Interview Topics

### 1. Core Foundation Topics
- Topic file: [1.Core Foundation Topics.md](Linux-Topics/1.Core%20Foundation%20Topics.md)
- Linux architecture basics
- Boot process overview
- Kernel and shell basics
- File System Hierarchy Standard
- Users, groups, and permissions
- Process and job control
- Package management
- Editors like `vi` or `vim`
- Basic shell scripting
- Environment variables and profiles

### 2. Command Line Mastery
- Topic file: [2.Command Line Mastery.md](Linux-Topics/2.Command%20Line%20Mastery.md)
- Navigation commands
- File and directory operations
- Searching with `find`, `locate`, and `grep`
- Text processing with `cut`, `awk`, `sed`, `sort`, and `uniq`
- Archiving and compression with `tar`, `gzip`, and `zip`
- Redirection and pipes
- Command substitution
- History, aliases, and shell customization

### 3. File Systems and Storage
- Topic file: [3.File Systems and Storage.md](Linux-Topics/3.File%20Systems%20and%20Storage.md)
- File system types such as `ext4`, `xfs`, and `tmpfs`
- Mounting and unmounting
- `/etc/fstab`
- Disk partition basics
- LVM basics
- Swap management
- Disk usage analysis with `df`, `du`, and `lsblk`
- Inodes
- ACL basics

### 4. User and Access Management
- Topic file: [4.User and Access Management.md](Linux-Topics/4.User%20and%20Access%20Management.md)
- User creation and modification
- Group management
- Password policies
- `sudo` configuration
- Account locking and expiry
- PAM basics
- SSH configuration
- Key-based authentication

### 5. Process Management
- Topic file: [5.Process Management.md](Linux-Topics/5.Process%20Management.md)
- Process lifecycle
- `ps`, `top`, and `htop`
- `kill`, `pkill`, and `killall`
- Foreground and background jobs
- `nice` and `renice`
- Process priorities
- Service troubleshooting basics

### 6. Service and System Management
- Topic file: [6.Service and System Management.md](Linux-Topics/6.Service%20and%20System%20Management.md)
- `systemctl`
- `journalctl`
- Service command basics
- System targets and runlevels
- Startup services
- Cron jobs
- `at` command
- Log rotation basics

### 7. Networking Topics
- Topic file: [7.Networking Topics.md](Linux-Topics/7.Networking%20Topics.md)
- OSI and TCP/IP basics
- IP addressing and subnetting
- Routing basics
- DNS basics
- SSH, SCP, and SFTP
- Network troubleshooting with `ping`, `traceroute`, `ss`, `curl`, `telnet`, and `nc`
- Interface configuration basics
- `/etc/hosts`
- Firewall basics with `iptables` or `firewalld`

### 8. Logs and Troubleshooting
- Topic file: [8.Logs and Troubleshooting.md](Linux-Topics/8.Logs%20and%20Troubleshooting.md)
- System log locations
- Application log analysis
- `journalctl`
- Boot issue basics
- High CPU troubleshooting
- High memory troubleshooting
- Disk full troubleshooting
- Service failure troubleshooting
- Network issue debugging

### 9. Security Topics
- Topic file: [9.Security Topics.md](Linux-Topics/9.Security%20Topics.md)
- Linux permission model
- `chmod`, `chown`, and `umask`
- SUID, SGID, and sticky bit
- SSH hardening basics
- Firewall management basics
- SELinux or AppArmor basics
- File integrity and access awareness
- Basic hardening practices

### 10. Performance and Monitoring
- Topic file: [10.Performance and Monitoring.md](Linux-Topics/10.Performance%20and%20Monitoring.md)
- CPU usage analysis
- Memory usage analysis
- Disk I/O basics
- Load average
- Monitoring tools such as `top`, `vmstat`, `iostat`, `sar`, and `free`
- Capacity checks
- Bottleneck identification

## Must-Know DevOps-Oriented Linux Topics

- Linux usage in CI/CD servers
- Permissions for deployment users
- Log monitoring during deployments
- Linux basics for Docker hosts
- Linux basics for Kubernetes nodes
- Package installation and dependency troubleshooting
- Environment variable management for applications
- Shell scripts for repeatable administration tasks

## Scenario-Based Topics Frequently Asked in Interviews

Be ready to explain how you would troubleshoot scenarios like:
- A server is slow
- Disk space is full
- A service is not starting
- SSH is not working
- A port is not reachable
- CPU usage is high because of one process
- Memory usage keeps increasing
- A cron job is not running
- A user cannot access a file or run `sudo`
- A system rebooted unexpectedly

## Suggested Learning Order

1. Linux architecture and file system basics
2. Command line and text processing
3. Users, groups, and permissions
4. Processes and services
5. Storage and file systems
6. Networking
7. Logs and troubleshooting
8. Security
9. Shell scripting
10. Performance monitoring
11. Real-time administration scenarios

## High-Priority Interview Focus Areas

- Permissions
- Process management
- Service management
- Networking basics
- SSH
- File systems and storage
- Logs
- Troubleshooting scenarios
- Shell scripting
- Performance commands

## Interview Preparation Tips

- Learn each concept with a command example
- Practice troubleshooting step by step instead of memorizing only definitions
- Prepare short answers for common interview questions
- Use real incidents or support examples from your experience
- Explain what you would check first, second, and third in a scenario
- Practice reading logs, checking services, and validating permissions on a real Linux system

## Final Goal

By covering these topics, you should be able to:
- Explain Linux concepts clearly
- Use common administration commands confidently
- Troubleshoot server, service, network, storage, and access issues
- Discuss Linux usage in DevOps and cloud environments
- Answer practical interview questions expected from a 4-year experienced candidate
