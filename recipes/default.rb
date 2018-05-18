#
# Cookbook Name:: ssh_auth_keys
# Recipe:: default
#
# Author : Bipin Bachhao
#
# Apache 2.0 license
#

ruby_block 'ssh_auth_keys_copying' do
  block do
    if node['ssh_auth_keys']
      node['ssh_auth_keys'].each do |target_user, data_users|
        next unless target_user
        next unless data_users

        # Getting node user data
        if node['etc'].nil?
          # if ohai passwd plugin is disabled try lookup it manually
          require 'etc'
          user = Etc.getpwnam(target_user)
        else
          user = node['etc']['passwd'][target_user]
        end

        user = { 'uid' => target_user, 'gid' => target_user, 'dir' => "/home/#{target_user}" } unless user

        next unless user && user['dir'] && user['dir'] != '/dev/null'
        ssh_keys = []
        user_list = []

        user_list = if data_users.is_a? String
                      Array(data_users)
                    elsif data_users.is_a? Array
                      data_users
                    else
                      data_users['users']
                    end

        Array(user_list).each do |bag_user|
          data = if node['encrypted_data_bag']
                   Chef::EncryptedDataBagItem.load('users', bag_user)
                 else
                   data_bag_item('users', bag_user)
                 end

          if data && data['ssh_keys']
            ssh_keys += Array(data['ssh_keys'])
            ssh_keys += Array(data['ssh_keys']).map { |x| (data['ssh_options'] ? data['ssh_options'] + ' ' + x : x) }
          end
        end

        # Saving SSH keys
        next if ssh_keys.empty?
        home_dir = user['dir']

        next if node['skip_if_missing_home'] && !File.exist?(home_dir)

        authorized_keys_file = "#{home_dir}/.ssh/authorized_keys"

        if node['keep_existing_keys'] && File.exist?(authorized_keys_file)
          Chef::Log.info("Keep authorized old keys entries from: #{authorized_keys_file} ")

          valid_key_regexp = /
          ^((?<ssh_options>(command=|          # match valid ssh-option
                            tunnel=|
                            no-pty|
                            environment=|
                            from=|
                            tunnel=|
                            permitopen=|
                            no-port-forwarding)
            ([^\s,]*|"[^"]*")[,]*)*\s|)       # match options values either with no space, or surrounded by "
           (?<ssh_key>(ssh-dss|               # match ssh key in any format
                       ssh-rsa|
                       ssh-ed25519|
                       ecdsa-sha2-nistp256|
                       ecdsa-sha2-nistp384|
                       ecdsa-sha2-nistp521)
            \s([^\s]*)
           )
           (.*)  # match remainder, e.g. comments
         /x

          # Loading existing keys in an Array
          File.open(authorized_keys_file).each do |line|
            valid_key = valid_key_regexp.match(line)
            if valid_key && !ssh_keys.find_index { |x| x.include?(valid_key[:ssh_key]) } # Only load valid keys and not previously loaded ones, ignoring options
              ssh_keys += Array(line.delete("\n"))
              Chef::Log.debug("[ssh-keys] Keeping key from #{authorized_keys_file}: #{line}")
            else
              Chef::Log.debug("[ssh-keys] Dropping key from #{authorized_keys_file}: #{line}")
            end
          end
          ssh_keys.uniq!
        else
          if node['create_home_if_missing']
            Chef::Log.info("Creating missing home dir and .ssh folder for the #{user['uid']}")
            hdir = Chef::Resource::Directory.new('HOME_DIR_Creation', run_context)
            hdir.path = "#{home_dir}/.ssh"
            hdir.owner user['uid']
            hdir.group user['gid'] || user['uid']
            hdir.mode '0700'
            hdir.recursive true
            hdir.run_action :create
          else
            Chef::Log.info("home_dir is present creating .ssh folder inside home_dir for #{user['uid']}")
            hdir = Chef::Resource::Directory.new('SSH_DIR_Creation', run_context)
            hdir.path = "#{home_dir}/.ssh"
            hdir.owner user['uid']
            hdir.group user['gid'] || user['uid']
            hdir.mode '0700'
            hdir.run_action :create
          end
        end
        # Create authorized_keys file using template
        templ = Chef::Resource::Template.new('Creating_authorized_keys_file', run_context)
        templ.path authorized_keys_file
        templ.source 'authorized_keys.erb'
        templ.cookbook 'ssh_auth_keys'
        templ.owner user['uid']
        templ.group user['gid'] || user['uid']
        templ.mode '0600'
        templ.sensitive true
        templ.variables ssh_auth_keys: ssh_keys
        templ.run_action :create
      end
    end
  end
end
