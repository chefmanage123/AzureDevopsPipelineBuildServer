# Auther: Marcus Felling
# Cookbook:: buildserver
# Recipe:: Windows

##############
# Permissions
##############

user node['buildserver']['sv_user'] do
  password node['buildserver']['sv_password']
end

group 'Administrators' do
  members node['buildserver']['sv_user']
  append true
  action :modify
end

##############
# Directories
##############

# Use array in attributes rb to create directories
node['buildserver']['directories'].each do |directory|
  directory directory do
    rights :modify, 'Everyone'
    inherits true
    recursive true
    not_if { ::File.directory?('directory') }
  end
end

# Create share for build drop
windows_share 'Drop' do
  action :create
  path 'H:\_drop'
end

# Create share for Octopus packages
windows_share 'Packages' do
  action :create
  path 'H:\_packages'
end

###########
# Features
###########

powershell_script 'Install features' do
  code <<-EOH
  Install-WindowsFeature  Web-Server,`
                          Web-WebServer,`
                          Web-Asp-Net45,`
                          Web-App-Dev,`
                          Web-Net-Ext45,`
                          NET-Framework-Features,`
                          NET-Framework-Core,`
                          NET-Framework-45-Features,`
                          NET-Framework-45-Core,`
                          NET-Framework-45-ASPNET
  EOH
end

########
# Misc
########

powershell_script 'configure-timezone' do
  code <<-EOH
  TZUTIL /s "Central Standard Time"
  EOH
end
