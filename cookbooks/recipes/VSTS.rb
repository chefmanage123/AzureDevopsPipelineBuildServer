# Auther: Marcus Felling
# Cookbook:: buildserver
# Recipe:: vsts

##############################
# Install and register agents
##############################

powershell_script 'Download vsts-agent-win-x64-2.126.0.zip' do
  code <<-EOH
  set-location 'C:\\temp'
  read-s3object -bucketname S3BucketName -key vsts-agent-win-x64-2.126.0.zip -file vsts-agent-win-x64-2.126.0.zip -region us-east-1
  EOH
  not_if { ::File.exist?('C:\\temp\\vsts-agent-win-x64-2.126.0.zip') }
end

node['buildserver']['Example_agents'].each do |agentname|
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
    $args = "--unattended --url #{node['buildserver']['vsts_url']} --auth pat --token #{node['buildserver']['vsts_token']} --pool Example --agent #{node['hostname']}-#{agentname} --runAsService --windowsLogonAccount #{node['buildserver']['sv_user']} --windowsLogonPassword #{node['buildserver']['sv_password']}"
    Start-Process H:\\agents\\#{agentname}\\config.cmd -ArgumentList $args -Wait
    EOH
    not_if { ::File.exist?('H:\\agents\\#{agentname}\\config.cmd') }
  end
end


