function burpchrome
    set -l profile /tmp/burp-chrome-instance-1
    mkdir -p $profile
    
    # We must explicitly pass the user-data-dir and tell Chrome it's a proxy environment
            nohup /home/kamal/.BurpSuite/burpbrowser/150.0.7871.186/chrome \
                        --user-data-dir=$profile \
                        --ignore-certificate-errors \
                        --no-first-run \
                        --no-default-browser-check >/dev/null 2>&1 &
        
            # Capture the PID immediately before any other command runs
            set -l pid $last_pid
            
            disown
            echo "burpchrome started, PID $pid, profile $profile"
end
