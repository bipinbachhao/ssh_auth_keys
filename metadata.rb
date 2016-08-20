name             'ssh_auth_keys'
maintainer       'Bipin Bachhao'
maintainer_email 'bipinbachhao@gmail.com'
license          'Apache 2.0'
description      'This recipe reads public ssh authorized keys from data bag and appends those in $HOME/.ssh/authorized_keys file'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.1'
