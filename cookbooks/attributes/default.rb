# Required directories
default['buildserver']['directories'] = ['C:\temp', 'H:\Agents', 'H:\_drop', 'H:\_packages']

# Used to install VSTS agents. 
default['buildserver']['sv_user'] = 'service-account-name'
default['buildserver']['sv_password'] = '__sv_password__'
default['buildserver']['install_dir'] = 'H:\\agents'
default['buildserver']['vsts_url'] = 'https://yourcompanyname.visualstudio.com'
default['buildserver']['vsts_user'] = 'vsts-service-account-name'
default['buildserver']['vsts_token'] = '__vsts_token__'

# agents
default['buildserver']['Example_agents'] = ['Example-1', "Example-2", "Example-3", "Example-4", "Example-5", "Example-6"]
