Vagrant.configure("2") do |config|
	config.vm.define "server1" do |web|
		web.vm.box = "generic/centos8s"
		web.vm.network "forwarded_port", id: "ssh", host: 2122 , guest: 22
		web.vm.network "private_network", ip: "10.11.10.10", virtualbox__intnet: true
		web.vm.hostname = "server1"

		web.vm.provision "shell", path: "script.sh"

		web.vm.provider "virtualbox" do |v|
			v.name = "server1"
			v.memory = 16384
			v.cpus = 8

		end
	end
end 
