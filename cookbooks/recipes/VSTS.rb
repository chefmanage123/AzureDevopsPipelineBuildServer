# Auther: Marcus Felling
# Cookbook:: buildserver
# Recipe:: VSTS

########################
# Install required gems
########################

chef_gem 'aws-sdk' do
  compile_time true
  action :install
end

chef_gem 'net-http-persistent' do
  compile_time true
  action :install
end

chef_gem 'rubysl-base64' do
  compile_time true
  action :install
end

######################################
# Decryption of sensitive variables
######################################
require 'aws-sdk'
require 'base64'
require 'net/http'
require 'uri'

# Get instance region
metadata_endpoint = 'http://169.254.169.254/latest/meta-data/'
instance_id = Net::HTTP.get( URI.parse( metadata_endpoint + 'instance-id' ) )
instance_region = Net::HTTP.get( URI.parse( metadata_endpoint + 'placement/availability-zone' ) )

# Set the datakey based on Region
if instance_region.include? "us-east-1"
  vsts_sv_pwd_datakey = Base64.decode64(node['kms-vsts-sv-pwd'])
  vsts_token_datakey = Base64.decode64(node['kms-vsts-token'])
else
  vsts_sv_pwd_datakey = Base64.decode64(node['kms-vsts-sv-pwd-DR'])
  vsts_token_datakey = Base64.decode64(node['kms-vsts-token-DR'])
end

kms = Aws::KMS::Client.new()

vsts_sv_pwd = kms.decrypt({ciphertext_blob: vsts_sv_pwd_datakey}).plaintext
vsts_token = kms.decrypt({ciphertext_blob: vsts_token_datakey}).plaintext

##################
# Service Account
##################

group 'Administrators' do
  members node['buildserver']['vsts_sv_user']
  append true
  action :modify
end

##############################
# Install and register agents
##############################

powershell_script 'Download vsts-agent-win-x64-2.126.0.zip' do
  code <<-EOH
  set-location 'C:\\temp'
  read-s3object -bucketname bucketname -key vsts-agent-win-x64-2.126.0.zip -file vsts-agent-win-x64-2.126.0.zip -region us-east-1
  EOH
  not_if { ::File.exist?('C:\\temp\\vsts-agent-win-x64-2.126.0.zip') }
end

# Example Pool
node['buildserver']['DEP_agents'].each do |agentname|
  directory "H:\\agents\\#{agentname}" do
    rights :modify, 'Everyone'
    inherits true
    recursive true
    not_if { ::File.directory?('H:\\Agents\\#{agentname}}') }
  end  
  powershell_script 'Install VSTS Build agent #{agentname}' do
  code <<-EOH
    Set-Location "H:\\agents\\#{agentname}"
    Add-Type -AssemblyName System.IO.Compression.FileSystem ; [System.IO.Compression.ZipFile]::ExtractToDirectory("C:\\temp\\vsts-agent-win-x64-2.126.0.zip", "$PWD")
    $args = "--unattended --url #{node['buildserver']['vsts_url']} --auth pat --token #{vsts_token} --pool Example --agent #{node['hostname']}-#{agentname} --runAsService --windowsLogonAccount #{node['buildserver']['vsts_sv_user']} --windowsLogonPassword #{vsts_sv_pwd}"
    Start-Process H:\\agents\\#{agentname}\\config.cmd -ArgumentList $args -Wait
    EOH
    guard_interpreter :powershell_script
    not_if { ::File.directory?('H:\\Agents\\#{agentname}}') }
  end
end

# Add NuGet source for Package Management
  powershell_script 'Add NuGet source for Package Management' do
  code <<-EOH
    $args = "sources add -name Packages -source 'https://YOURACCOUNT.pkgs.visualstudio.com/_packaging/Packages/nuget/v3/index.json' -username #{node['buildserver']['vsts_sv_user']} -password #{vsts_token} -StorePasswordInClearText"
    Start-Process H:\\NuGet\\NuGet.exe -ArgumentList $args -Wait
    EOH
  end

# Set default region
  powershell_script 'Add NuGet source for Package Management' do
  code <<-EOH
    Initialize-AWSDefaultConfiguration -Region us-east-1
    EOH
  end


# Set time zone
powershell_script 'configure-timezone' do
  code <<-EOH
  TZUTIL /s "Central Standard Time"
  EOH
end
