#RESOURCES
#https://phoenixnap.com/kb/linux-commands-check-memory-usage

MEM_USED=$(free -m | sed -n 2p | awk '{print $3)')
MEM_TOTAL=$(free -m | sed -n 2p | awk '{print $2}')

CPU usage
mpstat | sed -n 4p | awk '{print $6}'

Last Boot
who -b | sed -n 1p | awk '{print $3,$4}'

SUDO LOG

grep -a sudo /var/log/auth.log | grep COMMAND | wc -l

#HERE IS THE WHOLE SCRIPT

printf "#Architecture: %s\n" "$(uname -a)"


THREADS=$(lscpu | grep Thread | tr -d -c 0-9)
CORES=$(lscpu | grep Core | sed -n 1p | tr -d -c 0-9)
SOCKETS=$(lscpu | grep Socket | tr -d -c 0-9)
PCPU=$((THREADS * CORES * SOCKETS))
VCPU=$PCPU

printf "#CPU physical: %d\n" "$(echo $PCPU)"

printf "#vCPU: %d\n" "$(echo $VCPU)"

MEM_USED=$(free -m | sed -n 2p | awk '{print $3}')
MEM_TOT=$(free -m | sed -n 2p | awk '{print $2}')
PCNT1=$(bc <<< "scale=5 ; $MEM_USED / $MEM_TOT")
PCNT2=$(bc <<< "scale=3 ; $PCNT1 * 100")
MEM_PCNT=$(bc <<< "scale=2 ; $PCNT2")

printf "#Memory Usage: %d/%dMB (%.2f%%)\n" "$(echo $MEM_USED)" "$(echo $MEM_TOT)" "$(echo $MEM_PCNT)"

DISK_USED=$(df -m | grep root | awk '{print $3}')
TOT1=$(df -m | grep root | awk '{print $2}')
DISK_TOT=$(bc <<< "scale=1 ; $TOT1 / 1000")
PCNT1=$(bc <<< "scale=5 ; $DISK_USED / $TOT1")
DISK_PCNT=$(bc <<< "scale=0 ; $PCNT1 * 100")

printf "#Disk Usage: %d/%.1fGb (%.1f%%\n" "$(echo $DISK_USED)" "$(echo $DISK_TOT)" "$(echo $DISK_PCNT)"

CPU_LOAD=$(mpstat | sed -n 4p | awk '{print $6}')

printf "#CPU Load: %.2f%%\n" "$(echo CPU_LOAD)"

printf "#Last boot: %s\n" "$(who -b | sed -n 1p | awk '{print $3,$4}')"

if lvscan | grep -q 'ACTIVE';
then
	echo "#LVM use: yes"
else
	echo "LVM use: no"
fi

TCP_NUM=$(netstat -natp | grep LISTEN | wc -l)
printf "#Connections TCP: %d ESTABLISHED\n" "$(echo $TCP_NUM)"

USER_CNT=$(who | wc -l)
printf "#User log: %d\n" "$(echo $USER_CNT)"


IP=$(hostname -I)
MAC=$(ifconfig | grep ether | awk '{print $2}')
printf "#Network: IP %s (%s)\n" "$(echo $IP)" "$(echo $MAC)"

SUDO_NUM=$(grep -a suo /var/log/auth.log | grep COMMAND | wc -l)

printf "#Sudo: %d cmd\n" "$(echo $SUDO_NUM)"

