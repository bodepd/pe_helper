#!/bin/bash
#
# simple script that installs PE
#
pushd /tmp/

if [ -f /etc/init.d/puppetmaster ]; then
/etc/init.d/puppetmaster stop
fi

REMOTE_PE='https://s3.amazonaws.com/pe-builds/previews/puppet-enterprise-2.5.2rc0-32-g980a064-ubuntu-12.04-amd64.tar.gz'

S3_ANSWERS='https://s3.amazonaws.com/dans_bucket/master_2_5_2.answers'
S3_AGENT_ANSWERS='https://s3.amazonaws.com/dans_bucket/agent_2_5_2.answers'

TARBALL='puppet-enterprise-2.5.2rc0-32-g980a064-ubuntu-12.04-amd64.tar.gz'

PE_DIR='/tmp/puppet-enterprise-2.5.2rc0-32-g980a064-ubuntu-12.04-amd64'

# download pe tarball
wget $REMOTE_PE

# download answer file
wget $S3_ANSWERS

# download agent answers file
wget $S3_AGENT_ANSWERS

# extract tarball
tar -xzvf $TARBALL

# install puppet master using answers file
bash "${PE_DIR}/puppet-enterprise-installer" -a /tmp/master_2_5_2.answers

# move the installer tarball and agent answers to the apache server
cp 'puppet-enterprise-2.5.2rc0-32-g980a064-ubuntu-12.04-amd64.tar.gz' '/var/www'
cp 'agent_2_5_2.answers' '/var/www'

# configure a few things on the master
# configure storeconfigs for the master
awk '{ if ( $0 ~ /\[master\]/ ) {
          printf("%s\n%s\n%s\n", $0,  "    storeconfigs = true", "    allow_duplicate_certs = true");
     } else {
          print $0;
     }
}' /etc/puppetlabs/puppet/puppet.conf > /etc/puppetlabs/puppet/puppet.conf.storeconfig
mv /etc/puppetlabs/puppet/puppet.conf.storeconfig /etc/puppetlabs/puppet/puppet.conf
# enable autosigning
# TODO I should not enable autosigning by default
echo '*' > /etc/puppetlabs/puppet/autosign.conf

popd