When cloning VMs from a Photon template, the resulting VMs will all
get the same IP address.
This is due to the /etc/machine-id file, which is copied during the clone process.
When the VM asks DHCP for an IP address, using the UUID in that file as an identifier,
the DHCP server will see this as allcoming from the same VM.
Hence the same IP address.

To fix, two actions are needed:
- add a script to the OSCustomizationSpec
  - remove the copied /etc/machine-id
  - create a new file with a unique UUID
- allow script execution in the Guest OS

Sidenote: the soution that is found online

echo -n > /etc/machine-id

can not be used in an OSCustimzationSpec.
The systemd will fail when the file is not found, so no vNIC connection is made.