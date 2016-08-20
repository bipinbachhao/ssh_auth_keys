# ssh_auth_keys Cookbook

## Description
This recipe reads public ssh authorized keys from data bag and appends those in $HOME/.ssh/authorized_keys file
It supports encrypted data baf supported

## Requirements

## Attributes

It Expects node[:ssh_auth_keys] to be a hash containing user name as key and data bag user name as value.

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><tt>[:ssh_auth_keys]</tt></td>
    <td>Ruby Hash</td>
    <td>Ruby hash specifying user_name => databag_name </td>
  </tr>
</table>


You can define hash in wrapper cookbook's default attributes as follows
```
default['ssh_auth_keys']['user_name'] = ["databag1", "databag2",.....]
```
Additional attributes can be tweaked see attributes/default.rb for Additional self explanatory attributes

.....wrapper_cookbook/attributes/default.rb
```
default['ssh_auth_keys']['root'] = ["user1", "user2", "bipin"]

default["ssh_auth_keys"]['bips'] = ["bipin"]
```

### Platforms

- Centos-6.8
- Centos-7.1
- Centos-7.2

### Chef

- Chef 12.0 or later

### Cookbooks

### ssh_auth_keys::default

## Usage

You can define hash in wrapper cookbook's default attributes as follows
```
default['ssh_auth_keys']['user_name'] = ["databag1", "databag2",.....]
```

.....wrapper_cookbook/attributes/default.rb
```
default['ssh_auth_keys']['root'] = ["user1", "user2", "bipin"]

default["ssh_auth_keys"]['bips'] = ["bipin"]

And just include `ssh_auth_keys` in your wrapper recipe:

include_recipe "ssh_auth_keys"
```

Node Configuration and run_list can be defined in json format:

Node configuration example to create authorized_keys for user root from data bag user1 user2 and bipin:
```
{    
  "ssh_auth_keys": {     
    "root": ["user1", "user2", "bipin"]    
  },     
  "run_list": [
    "recipe[ssh_auth_keys]"
  ]
}
```
```
{   
  "ssh_auth_keys": {    
    "root": "user1"   
  },  
  "run_list": [  
    "recipe[ssh_auth_keys]"  
  ]   
}
```
Use knife to create a data bag named "users"

` knife data bag create users`

```
knife data bag users user1
{  
  "id": "user1",  
  "ssh_keys": "ssh-rsa BAASSS3Nz...YYYhCw== user1"  
}
```
SSH options can be given with "ssh_options". They will prepend every given ssh-key.

```
knife data bag users bipin
{
  "id": "bipin",
  "ssh_keys": "ssh-rsa AAAAB3Nz...5D8F== bipin",
  "ssh_options": "environment=\"REMOTE_USER=Foo Bar\""
}
```

## Contributing

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

## License and Authors

TODO:
- Work on FC014: Consider extracting long ruby_block to library
- convert recipe to a Resource
