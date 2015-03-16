if [ $# -eq 0 ]; then
	echo "$0 [Flex IPAddr] [FPS]"
	exit 1
fi

cat > flex.expect << EOF
#!/usr/bin/expect   
spawn telnet -e ! $1 4992
expect "V1.2.0.0"   
send "c1|display pan s 0x40000000 fps=$2\n"
send "c2|display pan s 0x40000001 fps=$2\n"
send "c3|display pan s 0x40000002 fps=$2\n"
send "c4|display pan s 0x40000003 fps=$2\n"
send "c5|display pan s 0x40000004 fps=$2\n"
send "c6|display pan s 0x40000005 fps=$2\n"
send "c7|display pan s 0x40000006 fps=$2\n"
send "c8|display pan s 0x40000007 fps=$2\n"
expect "R8"
send "!"
EOF

expect -f flex.expect
rm flex.expect
