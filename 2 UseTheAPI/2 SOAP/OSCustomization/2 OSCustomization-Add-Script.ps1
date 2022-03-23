$script = @'
#!/bin/sh
if [ x$1 == x"precustomization" ]; then
    echo Do Precustomization tasks
    rm -f /etc/machine-id
    dbus-uuidgen --ensure=/etc/machine-id
elif [ x$1 == x"postcustomization" ]; then
    echo Do Postcustomization tasks
fi
'@
$osCustName = 'PhotonCust'

$custMgr = Get-View CustomizationSpecManager

# Add script to Spec
$p = $custMgr.GetCustomizationSpec($osCustName)
$p.Spec.Identity.ScriptText = $script
$custMgr.OverwriteCustomizationSpec($p)