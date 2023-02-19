import subprocess, sys, os

HOME=os.environ.get("HOME")

def get(what):
    return subprocess.getoutput(f"python3 {HOME}/software/system-stats-server/client.py {what}")

if sys.argv[1]=="cpu_info_widget":
    freq=float(get("cpu_freq"))
    load=float(get("cpu_load"))
    temp=float(get("cpu_temp"))
    
    freq/=1000
    print(f" {freq:1.1f}GHz  {load:04}%  {temp}°C")
    exit(0)

if sys.argv[1]=="net_info_widget":
    sent=float(get("network_sent_per_second"))
    recv=float(get("network_recv_per_second"))

    sent=int(sent/1000) # kbytes
    if sent<1:
        sent="  0 KB"
    elif sent<10:
        sent=f"  {sent} KB"
    elif sent<100:
        sent=f" {sent} KB"
    elif sent<1000:
        sent=f"{sent} KB"
    elif sent//1000<1:
        sent=f"  1 MB"
    elif sent//1000<10:
        sent=f"  {sent//1000} MB"
    elif sent//1000<100:
        sent=f" {sent//1000} MB"
    else:
        sent=f"{sent//1000} MB"
    
    recv=int(recv/1000) # kbytes
    if recv<1:
        recv="  0 KB"
    elif recv<10:
        recv=f"  {recv} KB"
    elif recv<100:
        recv=f" {recv} KB"
    elif recv<1000:
        recv=f"{recv} KB"
    elif recv//1000<1:
        recv=f"  1 MB"
    elif recv//1000<10:
        recv=f"  {recv//1000} MB"
    elif recv//1000<100:
        recv=f" {recv//1000} MB"
    else:
        recv=f"{recv//1000} MB"
    print(f"🡹 {sent} 🡻 {recv}")
    exit(0)

if sys.argv[1]=="memory_info_widget":
    mem=int(get("used_memory"))
    swap=int(get("used_swap")) 

    mem/=1e9
    swap/=1e9


    print(f" {mem:.1f}GB | {swap:.1f}GB")
    exit(0)

if sys.argv[1]=="os_info_widget":
    kernel=get("kernel")
    uptime=int(float(get("uptime")))
    h=uptime//3600
    m=(uptime%3600)//60
    print(f"{kernel}, {h:02}:{m:02}")
    exit(0)

if sys.argv[1]=="battery_info_widget":
    percentage=float(get("battery_percentage"))
    charging=get("battery_charging")
    if charging=="True":
        charging="🡹"
    else:
        charging="🡻"
    left=int(float(get("battery_left")))
    h=left//3600
    m=(left%3600)//60
    if h>100:
        h=m=99
    print(f"🔋 {percentage:.1f}% {h:02}:{m:02} {charging} ")
    exit(0)

if sys.argv[1]=="disks_info_widget":
    write=float(get("disks_write_per_second"))
    read=float(get("disks_read_per_second"))

    write=int(write/1000) # kbytes
    if write<1:
        write="  0 KB"
    elif write<10:
        write=f"  {write} KB"
    elif write<100:
        write=f" {write} KB"
    elif write<1000:
        write=f"{write} KB"
    elif write//1000<1:
        write=f"  1 MB"
    elif write//1000<10:
        write=f"  {write//1000} MB"
    elif write//1000<100:
        write=f" {write//1000} MB"
    elif write//1000000<1:
        write=f"  1 GB"
    elif write//1000000<10:
        write=f"  {write//1000000} GB"
    elif write//1000000<100:
        write=f" {write//1000000} GB"
    elif write//1000000<1000:
        write=f"{write//1000000} GB"
    
    read=int(read/1000) # kbytes
    if read<1:
        read="  0 KB"
    elif read<10:
        read=f"  {read} KB"
    elif read<100:
        read=f" {read} KB"
    elif read<1000:
        read=f"{read} KB"
    elif read//1000<1:
        read=f"  1 MB"
    elif read//1000<10:
        read=f"  {read//1000} MB"
    elif read//1000<100:
        read=f" {read//1000} MB"
    elif read//1000000<1:
        read=f"  1 GB"
    elif read//1000000<10:
        read=f"  {read//1000000} GB"
    elif read//1000000<100:
        read=f" {read//1000000} GB"
    elif read//1000000<1000:
        read=f"{read//1000000} GB"
    
    used=int(float(get("disks_used")))//1000000000
    total=int(float(get("disks_total")))//1000000000
    print(f"🖴 {used} GB / {total} GB, 🡹 {write} 🡻 {read}")
    exit(0)