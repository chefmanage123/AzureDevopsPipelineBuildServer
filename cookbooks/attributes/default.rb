# Required directories
default['buildserver']['directories'] = ['C:\temp', 'H:\Agents', 'H:\_drop', 'H:\_packages']

# Used to install VSTS agents.
default['buildserver']['vsts_sv_user'] = 'serviceaccountname'
default['buildserver']['vsts_url'] = 'https://YOURACCOUNT.visualstudio.com'

# agents
default['buildserver']['Example_agents'] = ['Example-1', "Example-2", "Example-3", "Example-4", "Example-5", "Example-6"]
