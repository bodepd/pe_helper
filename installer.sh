#!/bin/bash
#
# simple script that installs PE
#

pushd /tmp/

if [ -f /etc/init.d/puppetmaster ]; then
/etc/init.d/puppetmaster stop
fi

#BUILD_ID='2.5.2rc0-89-gafc8fee-ubuntu-12.04-amd64'
BUILD_ID='2.5.2rc1-ubuntu-12.04-amd64'

REMOTE_PE="https://s3.amazonaws.com/pe-builds-ubuntu/puppet-enterprise-${BUILD_ID}.tar.gz"

S3_ANSWERS='https://s3.amazonaws.com/dans_bucket/master_2_5_2.answers'
S3_AGENT_ANSWERS='https://s3.amazonaws.com/dans_bucket/agent_2_5_2.answers'

TARBALL="puppet-enterprise-${BUILD_ID}.tar.gz"

PE_DIR="/tmp/puppet-enterprise-${BUILD_ID}"


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
cp "puppet-enterprise-${BUILD_ID}.tar.gz" '/var/www'
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
