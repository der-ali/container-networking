all: setup test teardown

setup_static:
	rm -rf setup-1.complete setup-2.complete
	vagrant ssh node01 -c 'cd /vagrant ; ./setup.sh static > setup-1.log ; touch setup-1.complete' &
	vagrant ssh node02 -c 'cd /vagrant ; ./setup.sh static > setup-2.log ; touch setup-2.complete' &
	until [ -f setup-1.complete ] && [ -f setup-2.complete ]; do sleep 1; done

setup_bgp:
	rm -rf setup-1.complete setup-2.complete
	vagrant ssh node01 -c 'cd /vagrant ; ./setup.sh bgp > setup-1.log ; touch setup-1.complete' &
	vagrant ssh node02 -c 'cd /vagrant ; ./setup.sh bgp > setup-2.log ; touch setup-2.complete' &
	until [ -f setup-1.complete ] && [ -f setup-2.complete ]; do sleep 1; done

test_routing:
	vagrant ssh node02 -c 'cd /vagrant ; ./test.sh'
	vagrant ssh node01 -c 'cd /vagrant ; ./test.sh'
test_udp_server_ebpf:
	vagrant ssh node01 -c 'cd /vagrant ; ./start-udp-server.sh ebpf'
test_udp_server_iptables:
	vagrant ssh node01 -c 'cd /vagrant ; ./start-udp-server.sh iptables'
test_udp_client:	
	vagrant ssh node02 -c 'cd /vagrant ; ./start-udp-client.sh'
teardown:
	rm -rf teardown-1.complete teardown-2.complete
	vagrant ssh node01 -c 'cd /vagrant ; ./teardown.sh > teardown-1.log ; touch teardown-1.complete' &
	vagrant ssh node02 -c 'cd /vagrant ; ./teardown.sh > teardown-2.log ; touch teardown-2.complete' &
	until [ -f teardown-1.complete ] && [ -f teardown-2.complete ]; do sleep 1; done

clean:
	rm -rf *.log *.complete

ssh1:
	vagrant ssh node01

ssh2:
	vagrant ssh node02
