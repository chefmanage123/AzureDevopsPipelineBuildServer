# Auther: Marcus Felling
# Cookbook:: buildserver
# Recipe:: Software

# Build Tools for Visual Studio 2017
powershell_script 'Download Build Tools for Visual Studio 2017' do
  code <<-EOH
  set-location c:/temp
  read-s3object -bucketname S3BucketName -key vs_BuildTools.exe -file vs_BuildTools.exe -region us-east-1
  get-childitem c:/temp
  EOH
  not_if { ::File.exist?('C:/temp/SSDT-Setup-ENU.exe') }
end

powershell_script 'Install Build Tools for Visual Studio 2017' do
  code <<-EOH
  $myarg = "--add Microsoft.VisualStudio.Workload.MSBuildTools --add Microsoft.VisualStudio.Workload.NetCoreBuildTools --add Microsoft.VisualStudio.Workload.WebBuildTools --includeoptional --quiet --norestart --noUpdateInstaller --force"
  Start-Process C:\\temp\\vs_BuildTools.exe -ArgumentList $myarg -Wait
  EOH
  guard_interpreter :powershell_script
  not_if { ::File.exist?('C:/Program Files (x86)/Microsoft Visual Studio/2017/BuildTools/MSBuild/15.0/Bin/Microsoft.Build.Tasks.Core.dll') }
end

# Download SSISMSBuild, custom project to build SSIS projects
powershell_script 'Download SSISMSBuild.zip' do
  code <<-EOH
  set-location c:/temp
  read-s3object -bucketname S3BucketName -key SSISMSBuild.zip -file SSISMSBuild.zip -region us-east-1
  EOH
  not_if { ::File.exist?('c:/temp/SSISMSBuild.zip') }
end

# Extract SSISMSBuild.zip
windows_zipfile 'H:/' do
  source 'c:/temp/SSISMSBuild.zip'
  action :unzip
  not_if { ::File.exist?('H:/SSISMSBuild/Microsoft.SqlServer.IntegrationServices.Build.dll') }
end

# SSDT for Visual Studio 2017 (preview)
powershell_script 'Download SSDT for Visual Studio 2017' do
  code <<-EOH
  set-location c:/temp
  read-s3object -bucketname S3BucketName -key SSDT-Setup-ENU.exe -file SSDT-Setup-ENU.exe -region us-east-1
  EOH
  not_if { ::File.exist?('C:/temp/SSDT-Setup-ENU.exe') }
end

powershell_script 'Install SSDT for Visual Studio 2017' do
  code <<-EOH
  $myarg = "/quiet /norestart INSTALLVSSQL"
  Start-Process C:\\temp\\SSDT-Setup-ENU.exe -ArgumentList $myarg -Wait
  EOH
  guard_interpreter :powershell_script
  not_if { ::File.exist?('C:/Program Files (x86)/Microsoft Visual Studio/2017/Enterprise/MSBuild/Microsoft/VisualStudio/v15.0/SSDT/Microsoft.Data.Tools.Schema.SqlTasks.targets') }
end

# AWS CLI 
# Note: SDK comes installed with AMI
powershell_script 'Download AWS CLI' do
  code <<-EOH
  set-location c:/temp
  read-s3object -bucketname S3BucketName/chef/installers -key AWSCLI64.msi -file AWSCLI64.msi -region us-east-1
  EOH
  not_if { ::File.exist?('C:/temp/AWSCLI64.msi') }
end

windows_package 'Install AWS CLI' do
  source "C:/temp/AWSCLI64.msi"
  options "/qn"
  installer_type :msi
  action :install
  not_if { ::File.exist?('C:/Program Files/Amazon/AWSCLI/aws.exe') }
end

# 7-Zip
powershell_script 'Download 7Zip Installer' do
  code <<-EOH
  set-location c:/temp
  read-s3object -bucketname S3BucketName/chef/installers -key 7z920-x64.msi -file 7z920-x64.msi -region us-east-1
  EOH
  not_if { File.exist?('C:/temp/7z920-x64.msi') }
end

windows_package 'Install 7Zip' do
  action :install
  source 'c:/temp/7z920-x64.msi'
  not_if { ::File.exist?('C:/Program Files/7-Zip/7z.exe') }
end

# NuGet
powershell_script 'Download nuget.exe' do
  code <<-EOH
  set-location H:/NuGet
  read-s3object -bucketname S3BucketName -key nuget.exe -file nuget.exe -region us-east-1
  EOH
  not_if { ::File.exist?('H:/NuGet/nuget.exe') }
end

# Node.Js
powershell_script 'Download Node.js MSI' do
  code <<-EOH
  set-location c:/temp
  read-s3object -bucketname S3BucketName -key node-v8.9.3-x64.msi -file node-v8.9.3-x64.msi  -region us-east-1
  EOH
  not_if { ::File.exist?('C:/temp/node-v8.9.3-x64.msi') }
end

windows_package 'Install Node.js' do
  source "C:/temp/node-v8.9.3-x64.msi"
  options "/quiet /norestart"
  installer_type :msi
  action :install
  not_if { ::File.exist?('C:/Program Files/nodejs/node.exe') }
end

# Git
powershell_script 'Download Git exe' do
  code <<-EOH
  set-location c:/temp
  read-s3object -bucketname S3BucketName -key Git64-bit.exe -file Git64-bit.exe -region us-east-1
  EOH
  not_if { ::File.exist?('C:/temp/Git-2.15.1.2-64-bit.exe') }
end

windows_package 'Install Git' do
  source "C:/temp/Git64-bit.exe"
  options "/sp- /verysilent /suppressmsgboxes /norestart /restartapplications /noicons"
  installer_type :custom
  action :install
  not_if { ::File.exist?('C:/Program Files/Git/git-cmd.exe') }
end

# Web Deploy (3.6)
powershell_script 'Download Web Deploy' do
  code <<-EOH
  set-location c:/temp
  read-s3object -bucketname S3BucketName -key WebDeploy_amd64_en-US.msi -file WebDeploy_amd64_en-US.msi -region us-east-1
  EOH
  not_if { ::File.exist?('C:/temp/WebDeploy_amd64_en-US.msi') }
end

windows_package 'Install WebDeploy' do
  source 'c:/temp/WebDeploy_amd64_en-US.msi'
  options 'ADDLOCAL=ALL /qn /norestart LicenseAccepted=\"0\"'
  installer_type :msi
  action :install
  guard_interpreter :powershell_script
  not_if '((gwmi -class win32_service | Where-Object {$_.Name -eq "MsDeploySvc"}).Name -eq "MsDeploySvc")'
end

########
# End
########

powershell_script 'Remove installers from temp folder' do
  code <<-EOH
  remove-item -recurse -force c:/temp
  EOH
end
