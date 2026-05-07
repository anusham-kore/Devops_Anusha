# Linux Fundamentals

Focus: Basics, troubleshooting.

## Key Concepts
- **File System**: /etc, /var, /home. Permissions: chmod, chown.
- **Processes**: ps, top, kill.
- **Networking**: ifconfig/ip, netstat/ss, ping.
- **Package Management**: apt/yum for installs.

## Commands
- Navigation: cd, ls, pwd
- Files: touch, cp, mv, rm
- Monitoring: df, du, free
- Logs: tail -f /var/log/syslog

## Real-Time Scenarios
- **Scenario 1**: Disk full. Use df to check, rm old files.
- **Scenario 2**: High CPU. top to identify process, kill if needed.
- **Scenario 3**: Network issue. ping to test connectivity, ss for ports.
- **Scenario 4**: Service not starting. Check logs, systemctl status.