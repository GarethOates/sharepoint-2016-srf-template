# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'yaml'
require 'json'

error = Vagrant::Errors::VagrantError

machines = YAML.load_file 'vagrant-machines.yaml'

File.exists? "ansible/hosts_dev_env.yaml"

File.open("ansible/hosts_dev_env.yaml" ,'w') do |f|
  machines.each do |machine|
    f.write "#{machine[0]}:\n"
    f.write "    hosts:\n"
    f.write "        #{machine[1]['name']}:\n"
    f.write "            ansible_ssh_host: #{machine[1]['ip_address']}\n"
    f.write "            ansible_user: vagrant\n"
    f.write "            ansible_password: vagrant\n"
    f.write "            hostname: #{machine[1]['hostname']}\n"
  end
end

Vagrant.configure(2) do |config|
  config.vm.box_check_update = false

  machines.each do |machine|
    name = machine[1]['name']
    box =  machine[1]['box']
    role = machine[1]['role']
    hostname = machine[1]['hostname']

    providers = machine[1]['providers']
    memory = machine[1]['memory'] || '512'
    default = machine[1]['default'] || false
    ip_address = machine[1]['ip_address']

    fail error.new, 'machines must contain a name' if name.nil?
    faile error.new, 'box must be defined' if box.nil?

    config.vm.define name, primary: default, autostart: default do |cfg|
      cfg.vm.hostname = hostname
      cfg.vm.box = box

      # credentials
      cfg.winrm.username = "vagrant"
      cfg.winrm.password = "vagrant"
      cfg.vm.guest = :windows
      cfg.vm.communicator = "winrm"
      cfg.windows.halt_timeout = 35
      cfg.vm.boot_timeout = 800

      cfg.vm.network "private_network", ip: ip_address
      cfg.vm.network :forwarded_port, guest: 5985, host: 5985, id: "winrm", auto_correct: true
      cfg.vm.network :forwarded_port, guest: 3389, host: 3389, id: "rdp", auto_correct: true

      if providers == 'virtualbox'
        cfg.vm.provider :virtualbox do |v|
          v.gui = false
          v.customize ["modifyvm", :id, "--memory", memory]
          v.customize ["modifyvm", :id, "--cpus", 2]
          v.customize ["modifyvm", :id, "--vram", 128]
          v.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
          v.customize ["modifyvm", :id, "--accelerate3d", "on"]
          v.customize ["modifyvm", :id, "--accelerate2dvideo", "on"]
        end
      end

      if ARGV.length >= 2
        if ARGV[1].start_with?('DomainController')
          cfg.vm.provision :ansible do |ansible|
              ansible.limit = "DomainControllers"
              ansible.playbook = "ansible/plays/domaincontroller.yml"
              ansible.inventory_path = "ansible/hosts_dev_env.yaml"
              ansible.tags = "all-environments,local-only"
              ansible.extra_vars = {
                "cloud_host" => "#{machine[1]['hostname']}"
              }
            end

        elsif ARGV[1].start_with?('SharePoint')
          cfg.vm.provision :ansible do |ansible|
            ansible.limit = "Webservers"
            ansible.playbook = "ansible/plays/sharepoint.yml"
            ansible.inventory_path = "ansible/hosts_dev_env.yaml"
            ansible.extra_vars = {
              "cloud_host" => "#{machine[1]['hostname']}"
            }
          end

        elsif ARGV[1].start_with?('Database')
          cfg.vm.provision :ansible do |ansible|
            ansible.limit = "Databases"
            ansible.playbook = "ansible/plays/databaseservers.yml"
            ansible.inventory_path = "ansible/hosts_dev_env.yaml"
            ansible.extra_vars = {
              "cloud_host" => "#{machine[1]['hostname']}"
            }
          end
        end
      end
    end
  end
end
