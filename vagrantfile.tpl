Vagrant.configure("2") do |config|
  config.ssh.shell = "sh"
  config.ssh.username = "docker"

  # Used on Vagrant >= 1.7.x to disable the ssh key regeneration
  config.ssh.insert_key = false

  # Use NFS folder sync if env variable B2D_NFS_SYNC is set
  if ENV['B2D_NFS_SYNC']
    config.vm.synced_folder ".", "/vagrant", type: "nfs", mount_options: ["nolock", "vers=3", "udp"], id: "nfs-sync"
  end

  # Virtualbox configuration
  config.vm.provider "virtualbox" do |v, override|
    # Expose the Docker ports (non secured AND secured)
    override.vm.network "forwarded_port", guest: 2375, host: 2375, host_ip: "127.0.0.1", auto_correct: true, id: "docker"
    override.vm.network "forwarded_port", guest: 2376, host: 2376, host_ip: "127.0.0.1", auto_correct: true, id: "docker-ssl"
  end

  # Add bootlocal support
  if File.file?('./bootlocal.sh')
    config.vm.provision "shell", path: "bootlocal.sh", run: "always"
  end

end
