function fm
    echo -e "\nBefore:"
    free -h
    echo -e "\nRestarting swap..."
    sudo swapoff -a; and sudo swapon -a
    echo 3 | sudo tee /proc/sys/vm/drop_caches >/dev/null
    echo -e "\nAfter:"
    free -h
end
