iptables명령을 이용해 iptables 내의 모든 rule을 확인한다.  

-S, --list-rules [chain]
              Print all rules in the selected chain.  
              If no chain is selected, all chains are printed like iptables-save. 
              Like every other iptables command, it applies to the specified table (filter is the default).

root@controller:~# iptables -S
-P INPUT ACCEPT
-P FORWARD ACCEPT
-P OUTPUT ACCEPT

-N neutron-filter-top

-N neutron-openvswi-FORWARD
-N neutron-openvswi-INPUT
-N neutron-openvswi-OUTPUT

-N neutron-openvswi-local

-N neutron-openvswi-i4d24fd1b-2
-N neutron-openvswi-i60f06f8b-5
-N neutron-openvswi-ic338b46d-8
-N neutron-openvswi-ic52a2f6e-f
-N neutron-openvswi-ie39a0430-c
-N neutron-openvswi-if6545c06-1

-N neutron-openvswi-o4d24fd1b-2
-N neutron-openvswi-o60f06f8b-5
-N neutron-openvswi-oc338b46d-8
-N neutron-openvswi-oc52a2f6e-f
-N neutron-openvswi-oe39a0430-c
-N neutron-openvswi-of6545c06-1

-N neutron-openvswi-s4d24fd1b-2
-N neutron-openvswi-s60f06f8b-5
-N neutron-openvswi-sc338b46d-8
-N neutron-openvswi-sc52a2f6e-f
-N neutron-openvswi-se39a0430-c
-N neutron-openvswi-sf6545c06-1

-N neutron-openvswi-sg-chain
-N neutron-openvswi-sg-fallback

-N nova-api-FORWARD
-N nova-api-INPUT
-N nova-api-OUTPUT
-N nova-api-local

-N nova-filter-top

-A INPUT -j neutron-openvswi-INPUT
-A INPUT -j nova-api-INPUT

-A FORWARD -j neutron-filter-top
-A FORWARD -j neutron-openvswi-FORWARD
-A FORWARD -j nova-filter-top
-A FORWARD -j nova-api-FORWARD

-A OUTPUT -j neutron-filter-top
-A OUTPUT -j neutron-openvswi-OUTPUT
-A OUTPUT -j nova-filter-top
-A OUTPUT -j nova-api-OUTPUT

-A neutron-filter-top -j neutron-openvswi-local

-A neutron-openvswi-FORWARD -m physdev --physdev-out tap60f06f8b-5d --physdev-is-bridged -j neutron-openvswi-sg-chain
-A neutron-openvswi-FORWARD -m physdev --physdev-in tap60f06f8b-5d --physdev-is-bridged -j neutron-openvswi-sg-chain
-A neutron-openvswi-FORWARD -m physdev --physdev-out tapf6545c06-19 --physdev-is-bridged -j neutron-openvswi-sg-chain
-A neutron-openvswi-FORWARD -m physdev --physdev-in tapf6545c06-19 --physdev-is-bridged -j neutron-openvswi-sg-chain
-A neutron-openvswi-FORWARD -m physdev --physdev-out tap4d24fd1b-2e --physdev-is-bridged -j neutron-openvswi-sg-chain
-A neutron-openvswi-FORWARD -m physdev --physdev-in tap4d24fd1b-2e --physdev-is-bridged -j neutron-openvswi-sg-chain
-A neutron-openvswi-FORWARD -m physdev --physdev-out tapc52a2f6e-f1 --physdev-is-bridged -j neutron-openvswi-sg-chain
-A neutron-openvswi-FORWARD -m physdev --physdev-in tapc52a2f6e-f1 --physdev-is-bridged -j neutron-openvswi-sg-chain
-A neutron-openvswi-FORWARD -m physdev --physdev-out tape39a0430-c8 --physdev-is-bridged -j neutron-openvswi-sg-chain
-A neutron-openvswi-FORWARD -m physdev --physdev-in tape39a0430-c8 --physdev-is-bridged -j neutron-openvswi-sg-chain
-A neutron-openvswi-FORWARD -m physdev --physdev-out tapc338b46d-82 --physdev-is-bridged -j neutron-openvswi-sg-chain
-A neutron-openvswi-FORWARD -m physdev --physdev-in tapc338b46d-82 --physdev-is-bridged -j neutron-openvswi-sg-chain

-A neutron-openvswi-INPUT -m physdev --physdev-in tap60f06f8b-5d --physdev-is-bridged -j neutron-openvswi-o60f06f8b-5
-A neutron-openvswi-INPUT -m physdev --physdev-in tapf6545c06-19 --physdev-is-bridged -j neutron-openvswi-of6545c06-1
-A neutron-openvswi-INPUT -m physdev --physdev-in tap4d24fd1b-2e --physdev-is-bridged -j neutron-openvswi-o4d24fd1b-2
-A neutron-openvswi-INPUT -m physdev --physdev-in tapc52a2f6e-f1 --physdev-is-bridged -j neutron-openvswi-oc52a2f6e-f
-A neutron-openvswi-INPUT -m physdev --physdev-in tape39a0430-c8 --physdev-is-bridged -j neutron-openvswi-oe39a0430-c
-A neutron-openvswi-INPUT -m physdev --physdev-in tapc338b46d-82 --physdev-is-bridged -j neutron-openvswi-oc338b46d-8

-A neutron-openvswi-i4d24fd1b-2 -m state --state INVALID -j DROP
-A neutron-openvswi-i4d24fd1b-2 -m state --state RELATED,ESTABLISHED -j RETURN
-A neutron-openvswi-i4d24fd1b-2 -p icmp -j RETURN
-A neutron-openvswi-i4d24fd1b-2 -p tcp -m tcp --dport 22 -j RETURN
-A neutron-openvswi-i4d24fd1b-2 -s 10.10.10.8/32 -j RETURN
-A neutron-openvswi-i4d24fd1b-2 -s 10.10.10.4/32 -j RETURN
-A neutron-openvswi-i4d24fd1b-2 -s 10.10.10.2/32 -j RETURN
-A neutron-openvswi-i4d24fd1b-2 -s 10.10.10.5/32 -j RETURN
-A neutron-openvswi-i4d24fd1b-2 -s 10.10.10.7/32 -j RETURN
-A neutron-openvswi-i4d24fd1b-2 -s 10.10.10.3/32 -p udp -m udp --sport 67 --dport 68 -j RETURN
-A neutron-openvswi-i4d24fd1b-2 -j neutron-openvswi-sg-fallback

-A neutron-openvswi-i60f06f8b-5 -m state --state INVALID -j DROP
-A neutron-openvswi-i60f06f8b-5 -m state --state RELATED,ESTABLISHED -j RETURN
-A neutron-openvswi-i60f06f8b-5 -p tcp -m tcp --dport 22 -j RETURN
-A neutron-openvswi-i60f06f8b-5 -s 10.10.10.6/32 -j RETURN
-A neutron-openvswi-i60f06f8b-5 -s 10.10.10.4/32 -j RETURN
-A neutron-openvswi-i60f06f8b-5 -s 10.10.10.2/32 -j RETURN
-A neutron-openvswi-i60f06f8b-5 -s 10.10.10.5/32 -j RETURN
-A neutron-openvswi-i60f06f8b-5 -s 10.10.10.7/32 -j RETURN
-A neutron-openvswi-i60f06f8b-5 -p icmp -j RETURN
-A neutron-openvswi-i60f06f8b-5 -s 10.10.10.3/32 -p udp -m udp --sport 67 --dport 68 -j RETURN
-A neutron-openvswi-i60f06f8b-5 -j neutron-openvswi-sg-fallback

-A neutron-openvswi-ic338b46d-8 -m state --state INVALID -j DROP
-A neutron-openvswi-ic338b46d-8 -m state --state RELATED,ESTABLISHED -j RETURN
-A neutron-openvswi-ic338b46d-8 -p tcp -m tcp --dport 22 -j RETURN
-A neutron-openvswi-ic338b46d-8 -s 10.10.10.6/32 -j RETURN
-A neutron-openvswi-ic338b46d-8 -s 10.10.10.8/32 -j RETURN
-A neutron-openvswi-ic338b46d-8 -s 10.10.10.2/32 -j RETURN
-A neutron-openvswi-ic338b46d-8 -s 10.10.10.5/32 -j RETURN
-A neutron-openvswi-ic338b46d-8 -s 10.10.10.7/32 -j RETURN
-A neutron-openvswi-ic338b46d-8 -p icmp -j RETURN
-A neutron-openvswi-ic338b46d-8 -s 10.10.10.3/32 -p udp -m udp --sport 67 --dport 68 -j RETURN
-A neutron-openvswi-ic338b46d-8 -j neutron-openvswi-sg-fallback

-A neutron-openvswi-ic52a2f6e-f -m state --state INVALID -j DROP
-A neutron-openvswi-ic52a2f6e-f -m state --state RELATED,ESTABLISHED -j RETURN
-A neutron-openvswi-ic52a2f6e-f -p tcp -m tcp --dport 22 -j RETURN
-A neutron-openvswi-ic52a2f6e-f -s 10.10.10.6/32 -j RETURN
-A neutron-openvswi-ic52a2f6e-f -s 10.10.10.8/32 -j RETURN
-A neutron-openvswi-ic52a2f6e-f -s 10.10.10.4/32 -j RETURN
-A neutron-openvswi-ic52a2f6e-f -s 10.10.10.5/32 -j RETURN
-A neutron-openvswi-ic52a2f6e-f -s 10.10.10.7/32 -j RETURN
-A neutron-openvswi-ic52a2f6e-f -p icmp -j RETURN
-A neutron-openvswi-ic52a2f6e-f -s 10.10.10.3/32 -p udp -m udp --sport 67 --dport 68 -j RETURN
-A neutron-openvswi-ic52a2f6e-f -j neutron-openvswi-sg-fallback

-A neutron-openvswi-ie39a0430-c -m state --state INVALID -j DROP
-A neutron-openvswi-ie39a0430-c -m state --state RELATED,ESTABLISHED -j RETURN
-A neutron-openvswi-ie39a0430-c -p tcp -m tcp --dport 22 -j RETURN
-A neutron-openvswi-ie39a0430-c -s 10.10.10.6/32 -j RETURN
-A neutron-openvswi-ie39a0430-c -s 10.10.10.8/32 -j RETURN
-A neutron-openvswi-ie39a0430-c -s 10.10.10.4/32 -j RETURN
-A neutron-openvswi-ie39a0430-c -s 10.10.10.2/32 -j RETURN
-A neutron-openvswi-ie39a0430-c -s 10.10.10.7/32 -j RETURN
-A neutron-openvswi-ie39a0430-c -p icmp -j RETURN
-A neutron-openvswi-ie39a0430-c -s 10.10.10.3/32 -p udp -m udp --sport 67 --dport 68 -j RETURN
-A neutron-openvswi-ie39a0430-c -j neutron-openvswi-sg-fallback

-A neutron-openvswi-if6545c06-1 -m state --state INVALID -j DROP
-A neutron-openvswi-if6545c06-1 -m state --state RELATED,ESTABLISHED -j RETURN
-A neutron-openvswi-if6545c06-1 -p tcp -m tcp --dport 22 -j RETURN
-A neutron-openvswi-if6545c06-1 -s 10.10.10.6/32 -j RETURN
-A neutron-openvswi-if6545c06-1 -s 10.10.10.8/32 -j RETURN
-A neutron-openvswi-if6545c06-1 -s 10.10.10.4/32 -j RETURN
-A neutron-openvswi-if6545c06-1 -s 10.10.10.2/32 -j RETURN
-A neutron-openvswi-if6545c06-1 -s 10.10.10.5/32 -j RETURN
-A neutron-openvswi-if6545c06-1 -p icmp -j RETURN
-A neutron-openvswi-if6545c06-1 -s 10.10.10.3/32 -p udp -m udp --sport 67 --dport 68 -j RETURN
-A neutron-openvswi-if6545c06-1 -j neutron-openvswi-sg-fallback

-A neutron-openvswi-o4d24fd1b-2 -p udp -m udp --sport 68 --dport 67 -j RETURN
-A neutron-openvswi-o4d24fd1b-2 -j neutron-openvswi-s4d24fd1b-2
-A neutron-openvswi-o4d24fd1b-2 -p udp -m udp --sport 67 --dport 68 -j DROP
-A neutron-openvswi-o4d24fd1b-2 -m state --state INVALID -j DROP
-A neutron-openvswi-o4d24fd1b-2 -m state --state RELATED,ESTABLISHED -j RETURN
-A neutron-openvswi-o4d24fd1b-2 -j RETURN
-A neutron-openvswi-o4d24fd1b-2 -j neutron-openvswi-sg-fallback

-A neutron-openvswi-o60f06f8b-5 -p udp -m udp --sport 68 --dport 67 -j RETURN
-A neutron-openvswi-o60f06f8b-5 -j neutron-openvswi-s60f06f8b-5
-A neutron-openvswi-o60f06f8b-5 -p udp -m udp --sport 67 --dport 68 -j DROP
-A neutron-openvswi-o60f06f8b-5 -m state --state INVALID -j DROP
-A neutron-openvswi-o60f06f8b-5 -m state --state RELATED,ESTABLISHED -j RETURN
-A neutron-openvswi-o60f06f8b-5 -j RETURN
-A neutron-openvswi-o60f06f8b-5 -j neutron-openvswi-sg-fallback

-A neutron-openvswi-oc338b46d-8 -p udp -m udp --sport 68 --dport 67 -j RETURN
-A neutron-openvswi-oc338b46d-8 -j neutron-openvswi-sc338b46d-8
-A neutron-openvswi-oc338b46d-8 -p udp -m udp --sport 67 --dport 68 -j DROP
-A neutron-openvswi-oc338b46d-8 -m state --state INVALID -j DROP
-A neutron-openvswi-oc338b46d-8 -m state --state RELATED,ESTABLISHED -j RETURN
-A neutron-openvswi-oc338b46d-8 -j RETURN
-A neutron-openvswi-oc338b46d-8 -j neutron-openvswi-sg-fallback

-A neutron-openvswi-oc52a2f6e-f -p udp -m udp --sport 68 --dport 67 -j RETURN
-A neutron-openvswi-oc52a2f6e-f -j neutron-openvswi-sc52a2f6e-f
-A neutron-openvswi-oc52a2f6e-f -p udp -m udp --sport 67 --dport 68 -j DROP
-A neutron-openvswi-oc52a2f6e-f -m state --state INVALID -j DROP
-A neutron-openvswi-oc52a2f6e-f -m state --state RELATED,ESTABLISHED -j RETURN
-A neutron-openvswi-oc52a2f6e-f -j RETURN
-A neutron-openvswi-oc52a2f6e-f -j neutron-openvswi-sg-fallback

-A neutron-openvswi-oe39a0430-c -p udp -m udp --sport 68 --dport 67 -j RETURN
-A neutron-openvswi-oe39a0430-c -j neutron-openvswi-se39a0430-c
-A neutron-openvswi-oe39a0430-c -p udp -m udp --sport 67 --dport 68 -j DROP
-A neutron-openvswi-oe39a0430-c -m state --state INVALID -j DROP
-A neutron-openvswi-oe39a0430-c -m state --state RELATED,ESTABLISHED -j RETURN
-A neutron-openvswi-oe39a0430-c -j RETURN
-A neutron-openvswi-oe39a0430-c -j neutron-openvswi-sg-fallback

-A neutron-openvswi-of6545c06-1 -p udp -m udp --sport 68 --dport 67 -j RETURN
-A neutron-openvswi-of6545c06-1 -j neutron-openvswi-sf6545c06-1
-A neutron-openvswi-of6545c06-1 -p udp -m udp --sport 67 --dport 68 -j DROP
-A neutron-openvswi-of6545c06-1 -m state --state INVALID -j DROP
-A neutron-openvswi-of6545c06-1 -m state --state RELATED,ESTABLISHED -j RETURN
-A neutron-openvswi-of6545c06-1 -j RETURN
-A neutron-openvswi-of6545c06-1 -j neutron-openvswi-sg-fallback

-A neutron-openvswi-s4d24fd1b-2 -s 10.10.10.6/32 -m mac --mac-source FA:16:3E:3A:D5:CC -j RETURN
-A neutron-openvswi-s4d24fd1b-2 -j DROP

-A neutron-openvswi-s60f06f8b-5 -s 10.10.10.8/32 -m mac --mac-source FA:16:3E:CA:BC:BF -j RETURN
-A neutron-openvswi-s60f06f8b-5 -j DROP

-A neutron-openvswi-sc338b46d-8 -s 10.10.10.4/32 -m mac --mac-source FA:16:3E:3A:A9:43 -j RETURN
-A neutron-openvswi-sc338b46d-8 -j DROP

-A neutron-openvswi-sc52a2f6e-f -s 10.10.10.2/32 -m mac --mac-source FA:16:3E:A9:2D:34 -j RETURN
-A neutron-openvswi-sc52a2f6e-f -j DROP

-A neutron-openvswi-se39a0430-c -s 10.10.10.5/32 -m mac --mac-source FA:16:3E:52:37:1B -j RETURN
-A neutron-openvswi-se39a0430-c -j DROP

-A neutron-openvswi-sf6545c06-1 -s 10.10.10.7/32 -m mac --mac-source FA:16:3E:55:CF:5C -j RETURN
-A neutron-openvswi-sf6545c06-1 -j DROP

-A neutron-openvswi-sg-chain -m physdev --physdev-out tap60f06f8b-5d --physdev-is-bridged -j neutron-openvswi-i60f06f8b-5
-A neutron-openvswi-sg-chain -m physdev --physdev-in tap60f06f8b-5d --physdev-is-bridged -j neutron-openvswi-o60f06f8b-5

-A neutron-openvswi-sg-chain -m physdev --physdev-out tapf6545c06-19 --physdev-is-bridged -j neutron-openvswi-if6545c06-1
-A neutron-openvswi-sg-chain -m physdev --physdev-in tapf6545c06-19 --physdev-is-bridged -j neutron-openvswi-of6545c06-1

-A neutron-openvswi-sg-chain -m physdev --physdev-out tap4d24fd1b-2e --physdev-is-bridged -j neutron-openvswi-i4d24fd1b-2
-A neutron-openvswi-sg-chain -m physdev --physdev-in tap4d24fd1b-2e --physdev-is-bridged -j neutron-openvswi-o4d24fd1b-2

-A neutron-openvswi-sg-chain -m physdev --physdev-out tapc52a2f6e-f1 --physdev-is-bridged -j neutron-openvswi-ic52a2f6e-f
-A neutron-openvswi-sg-chain -m physdev --physdev-in tapc52a2f6e-f1 --physdev-is-bridged -j neutron-openvswi-oc52a2f6e-f

-A neutron-openvswi-sg-chain -m physdev --physdev-out tape39a0430-c8 --physdev-is-bridged -j neutron-openvswi-ie39a0430-c
-A neutron-openvswi-sg-chain -m physdev --physdev-in tape39a0430-c8 --physdev-is-bridged -j neutron-openvswi-oe39a0430-c

-A neutron-openvswi-sg-chain -m physdev --physdev-out tapc338b46d-82 --physdev-is-bridged -j neutron-openvswi-ic338b46d-8
-A neutron-openvswi-sg-chain -m physdev --physdev-in tapc338b46d-82 --physdev-is-bridged -j neutron-openvswi-oc338b46d-8

-A neutron-openvswi-sg-chain -j ACCEPT
-A neutron-openvswi-sg-fallback -j DROP

-A nova-api-INPUT -d 10.0.0.101/32 -p tcp -m tcp --dport 8775 -j ACCEPT

-A nova-filter-top -j nova-api-local
