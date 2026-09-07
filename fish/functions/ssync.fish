function ssync
    sudo systemctl start syncthing@kamal.service
    
    sudo systemd-run \
        --unit=syncthing-auto-stop \
        --on-active=1h \
        /usr/bin/systemctl stop syncthing@kamal.service
    
    echo "Syncthing started — will stop automatically in 1 hour."
end
