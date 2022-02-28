#!/system/bin

# vmapper watchdog version
vm_watchdog="1.0"

[ -f /sdcard/vm_watchdog ] || exit


RUN_EVERY=300
REENABLE_EVERY=1
REBOOT_AFTER=4

check_mitm() {
mitm_running=$(ps | grep -e de.goldjpg.vmapper -e de.vahrmap.vmapper -e com.mad.pogodroid | awk -F. '{ print $NF }')
}

c=0

while true; do
check_mitm
if (( $c > $REBOOT_AFTER )); then
       reboot
    elif [ -z "$mitm_running" ]; then
     echo "No MITM App found running, restarting VMapper"
     am broadcast -n de.vahrmap.vmapper/.RestartService --ez autostart true && am force-stop com.nianticlabs.pokemongo && am broadcast -n de.vahrmap.vmapper/.RestartService && monkey -p com.nianticlabs.pokemongo -c android.intent.category.LAUNCHER 1
     sleep 10
     check_mitm
     [ -z "$mitm_running" ] && 	 c=$((c+1)) && echo "No MITM detected, waiting for next loop to retry." || echo "\$mitm_running restarted successfully, everything is fine" && c=0

 else
     c=0
     echo "\$mitm_running is running, everything is fine."
fi
  sleep $RUN_EVERY
done
