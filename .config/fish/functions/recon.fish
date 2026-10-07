function recon
    # ============================================================
    # Recon Automation Engine
    #
    # Real-time beautified verbose terminal UI with live loading
    # spinners, color-coded stage streams, and clean Markdown reports.
    #
    # Default pipeline:
    #   Amass -> Subfinder -> Merge Assets -> HTTPX -> recon.md & overall_scan.md
    #
    # Optional flags:
    #   --ffuf           Active directory fuzzing via ffuf
    #   --urls           Historical URL discovery via gau
    #   --js             Endpoint & JS crawler via katana
    #   --all            Run all optional discovery modules
    #   -w / --wordlist  Custom wordlist for ffuf
    #
    # Example:
    #   recon https://careers.powerbridge.in/jobs/Careers -d PowerBridge_Active
    # ============================================================

    set -l target ""
    set -l outdir ""
    set -l wordlist ""

    set -l do_ffuf 0
    set -l do_urls 0
    set -l do_js 0

    # ------------------------------------------------------------
    # Argument Parsing
    # ------------------------------------------------------------
    set -l i 1
    while test $i -le (count $argv)
        set -l arg $argv[$i]

        switch $arg
            case "-d" "--dir"
                set i (math $i + 1)
                if test $i -gt (count $argv)
                    echo -e "\033[1;31m[!] Missing directory value for $arg\033[0m"
                    return 1
                end
                set outdir $argv[$i]

            case "-w" "--wordlist"
                set i (math $i + 1)
                if test $i -gt (count $argv)
                    echo -e "\033[1;31m[!] Missing wordlist path for $arg\033[0m"
                    return 1
                end
                set wordlist $argv[$i]

            case "--ffuf"
                set do_ffuf 1

            case "--urls"
                set do_urls 1

            case "--js"
                set do_js 1

            case "--all"
                set do_ffuf 1
                set do_urls 1
                set do_js 1

            case "-h" "--help"
                echo
                echo -e "\033[1;38;5;51m⚡ Recon Automation Engine\033[0m"
                echo
                echo "Usage:"
                echo "  recon <target> -d <directory> [options]"
                echo
                echo "Options:"
                echo "  -d, --dir <dir>       Output directory for markdown reports (required)"
                echo "  -w, --wordlist <path> Custom wordlist path for ffuf"
                echo "  --ffuf                Run directory and endpoint fuzzing"
                echo "  --urls                Fetch historical URLs via gau"
                echo "  --js                  Crawl endpoints and JavaScript via katana"
                echo "  --all                 Run all discovery modules"
                echo "  -h, --help            Show this help menu"
                echo
                echo "Example:"
                echo "  recon https://careers.powerbridge.in/jobs/Careers -d PowerBridge_Active"
                echo
                return 0

            case '-*'
                echo -e "\033[1;31m[!] Unknown option: $arg\033[0m"
                echo
                echo "Usage:"
                echo "  recon <target> -d <directory> [--ffuf] [--urls] [--js] [--all]"
                echo
                return 1

            case '*'
                if test -z "$target"
                    set target $arg
                end
        end

        set i (math $i + 1)
    end

    # ------------------------------------------------------------
    # Validation
    # ------------------------------------------------------------
    if test -z "$target"; or test -z "$outdir"
        echo
        echo -e "\033[1;31m[!] Error: Both target and output directory (-d) are required.\033[0m"
        echo
        echo "Usage:"
        echo "  recon <target> -d <directory> [--ffuf] [--urls] [--js] [--all]"
        echo
        echo "Example:"
        echo "  recon https://careers.powerbridge.in/jobs/Careers -d PowerBridge_Active"
        echo
        return 1
    end

    # ------------------------------------------------------------
    # Tool Verification
    # ------------------------------------------------------------
    set -l httpx_bin "httpx-toolkit"
    if not command -q httpx-toolkit
        if command -q httpx
            set httpx_bin "httpx"
        else
            echo -e "\033[1;31m[!] Missing dependency: httpx / httpx-toolkit\033[0m"
            return 1
        end
    end

    for tool in amass subfinder jq python3
        if not command -q $tool
            echo -e "\033[1;31m[!] Missing dependency: $tool\033[0m"
            return 1
        end
    end

    if test $do_ffuf -eq 1; and not command -q ffuf
        echo -e "\033[1;31m[!] Missing dependency: ffuf\033[0m"
        return 1
    end

    if test $do_urls -eq 1; and not command -q gau
        echo -e "\033[1;31m[!] Missing dependency: gau\033[0m"
        return 1
    end

    if test $do_js -eq 1; and not command -q katana
        echo -e "\033[1;31m[!] Missing dependency: katana\033[0m"
        return 1
    end

    # ------------------------------------------------------------
    # Domain Normalization
    # ------------------------------------------------------------
    set -l domain $target
    set domain (string replace -r '^https?://' '' $domain)
    set domain (string split '/' $domain)[1]
    set domain (string split ':' $domain)[1]

    # Calculate total stages
    set -l total_stages 5
    if test $do_ffuf -eq 1
        set total_stages (math $total_stages + 1)
    end
    if test $do_urls -eq 1
        set total_stages (math $total_stages + 1)
    end
    if test $do_js -eq 1
        set total_stages (math $total_stages + 1)
    end

    # ------------------------------------------------------------
    # Output Setup & Temporary Workspace
    # ------------------------------------------------------------
    mkdir -p "$outdir"
    set -l tmpdir (mktemp -d)
    set -l start_time (date '+%Y-%m-%d %H:%M:%S')
    set -l start_epoch (date +%s)

    set -l amass_md "$outdir/amass.md"
    set -l subfinder_md "$outdir/subfinder.md"
    set -l combined_md "$outdir/combined_assets.md"
    set -l httpx_md "$outdir/httpx.md"
    set -l ffuf_md "$outdir/ffuf.md"
    set -l urls_md "$outdir/urls.md"
    set -l js_md "$outdir/js.md"
    set -l overall_md "$outdir/overall_scan.md"
    set -l recon_md "$outdir/recon.md"

    set -l amass_result "$tmpdir/amass.txt"
    set -l amass_error "$tmpdir/amass.err"

    set -l sub_result "$tmpdir/subfinder.txt"
    set -l sub_error "$tmpdir/subfinder.err"

    set -l combined "$tmpdir/combined.txt"

    set -l httpx_input "$tmpdir/httpx_input.txt"
    set -l httpx_json "$tmpdir/httpx.jsonl"
    set -l httpx_error "$tmpdir/httpx.err"

    # ------------------------------------------------------------
    # Generate Embedded Real-Time UI Engine
    # ------------------------------------------------------------
    set -l ui_script "$tmpdir/stream_ui.py"
    echo "aW1wb3J0IHN5cywgb3MsIHRpbWUsIGpzb24sIHRocmVhZGluZywgcmUsIGFyZ3BhcnNlCgpkZWYgc3RyaXBfYW5zaSh0ZXh0KToKICAgIHJldHVybiByZS5zdWIocidceDFCKD86W0AtWlxcLV9dfFxbWzAtP10qWyAtL10qW0Atfl0pJywgJycsIHRleHQpCgpkZWYgZm9ybWF0X2JveCh0aXRsZV90ZXh0LCByb3dzLCBib3JkZXJfY29sb3IsIHRpdGxlX2NvbG9yKToKICAgIHcgPSA3MAogICAgc3lzLnN0ZGVyci53cml0ZShmIlxue2JvcmRlcl9jb2xvcn3ila17J+KUgCcgKiAodyAtIDIpfeKVrlwwMzNbMG1cbiIpCiAgICBwYWRfdGl0bGUgPSB3IC0gNiAtIGxlbihzdHJpcF9hbnNpKHRpdGxlX3RleHQpKQogICAgc3lzLnN0ZGVyci53cml0ZShmIntib3JkZXJfY29sb3J94pSCXDAzM1swbSAgIHt0aXRsZV9jb2xvcn17dGl0bGVfdGV4dH1cMDMzWzBteycgJyAqIG1heCgxLCBwYWRfdGl0bGUpfXtib3JkZXJfY29sb3J94pSCXDAzM1swbVxuIikKICAgIHN5cy5zdGRlcnIud3JpdGUoZiJ7Ym9yZGVyX2NvbG9yfeKUnHsn4pSAJyAqICh3IC0gMil94pSkXDAzM1swbVxuIikKICAgIGZvciBsYWJlbCwgdmFsLCB2YWxfY29sb3IgaW4gcm93czoKICAgICAgICB2YWxfY2xlYW4gPSBzdHJpcF9hbnNpKHN0cih2YWwpKQogICAgICAgIHZpc19sZW4gPSAzICsgMTIgKyAzICsgbGVuKHZhbF9jbGVhbikKICAgICAgICBwYWQgPSB3IC0gMiAtIHZpc19sZW4KICAgICAgICBsaW5lX3N0ciA9IGYiICAgXDAzM1sxOzM3bXtsYWJlbDo8MTJ9XDAzM1swbSA6IHt2YWxfY29sb3J9e3ZhbH1cMDMzWzBtIgogICAgICAgIHN5cy5zdGRlcnIud3JpdGUoZiJ7Ym9yZGVyX2NvbG9yfeKUglwwMzNbMG17bGluZV9zdHJ9eycgJyAqIG1heCgxLCBwYWQpfXtib3JkZXJfY29sb3J94pSCXDAzM1swbVxuIikKICAgIHN5cy5zdGRlcnIud3JpdGUoZiJ7Ym9yZGVyX2NvbG9yfeKVsHsn4pSAJyAqICh3IC0gMil94pWvXDAzM1swbVxuXG4iKQogICAgc3lzLnN0ZGVyci5mbHVzaCgpCgpjbGFzcyBMaXZlU3RyZWFtVUk6CiAgICBkZWYgX19pbml0X18oc2VsZiwgc3RhZ2UsIHN0YWdlX251bSwgdG90YWxfc3RhZ2VzLCBkZXNjLCBvdXRfZmlsZT1Ob25lKToKICAgICAgICBzZWxmLnN0YWdlID0gc3RhZ2UubG93ZXIoKQogICAgICAgIHNlbGYuc3RhZ2VfbnVtID0gc3RhZ2VfbnVtCiAgICAgICAgc2VsZi50b3RhbF9zdGFnZXMgPSB0b3RhbF9zdGFnZXMKICAgICAgICBzZWxmLmRlc2MgPSBkZXNjCiAgICAgICAgc2VsZi5vdXRfcGF0aCA9IG91dF9maWxlCiAgICAgICAgc2VsZi5vdXRfZmlsZSA9IG9wZW4ob3V0X2ZpbGUsICJ3IikgaWYgb3V0X2ZpbGUgZWxzZSBOb25lCiAgICAgICAgc2VsZi5zdGFydF90aW1lID0gdGltZS50aW1lKCkKICAgICAgICBzZWxmLnN0b3BfZXZlbnQgPSB0aHJlYWRpbmcuRXZlbnQoKQogICAgICAgIHNlbGYubG9jayA9IHRocmVhZGluZy5Mb2NrKCkKICAgICAgICBzZWxmLmNvdW50ID0gMAogICAgICAgIHNlbGYuaXNfdHR5ID0gc3lzLnN0ZGVyci5pc2F0dHkoKQogICAgICAgIHNlbGYuZnJhbWVzID0gWyLioIsiLCAi4qCZIiwgIuKguSIsICLioLgiLCAi4qC8IiwgIuKgtCIsICLioKYiLCAi4qCnIiwgIuKghyIsICLioI8iXQogICAgICAgIHNlbGYuc3RhZ2VfbmFtZXMgPSB7CiAgICAgICAgICAgICJhbWFzcyI6ICJBbWFzcyBTdWJkb21haW4gRW51bWVyYXRpb24iLAogICAgICAgICAgICAic3ViZmluZGVyIjogIlN1YmZpbmRlciBETlMgRGlzY292ZXJ5IiwKICAgICAgICAgICAgImh0dHB4IjogIkhUVFBYIFNlcnZpY2UgUHJvYmluZyIsCiAgICAgICAgICAgICJmZnVmIjogIkZGVUYgQ29udGVudCBEaXNjb3ZlcnkiLAogICAgICAgICAgICAidXJscyI6ICJIaXN0b3JpY2FsIFVSTHMgKGdhdSkiLAogICAgICAgICAgICAianMiOiAiS2F0YW5hIEphdmFTY3JpcHQgQ3Jhd2wiCiAgICAgICAgfQogICAgICAgIHNlbGYudGl0bGUgPSBzZWxmLnN0YWdlX25hbWVzLmdldChzZWxmLnN0YWdlLCBzZWxmLnN0YWdlLnVwcGVyKCkpCgogICAgZGVmIHN0YXJ0KHNlbGYpOgogICAgICAgIHN5cy5zdGRlcnIud3JpdGUoZiJcblwwMzNbMTszODs1OzM5beKVreKUgOKUgFwwMzNbMG0gXDAzM1sxOzM3bVt7c2VsZi5zdGFnZV9udW19L3tzZWxmLnRvdGFsX3N0YWdlc31dXDAzM1swbSBcMDMzWzE7Mzg7NTs1MW17c2VsZi50aXRsZX1cMDMzWzBtXG4iKQogICAgICAgIHN5cy5zdGRlcnIuZmx1c2goKQogICAgICAgIHNlbGYudGhyZWFkID0gdGhyZWFkaW5nLlRocmVhZCh0YXJnZXQ9c2VsZi5fc3BpbiwgZGFlbW9uPVRydWUpCiAgICAgICAgc2VsZi50aHJlYWQuc3RhcnQoKQoKICAgIGRlZiBfc3BpbihzZWxmKToKICAgICAgICBpZHggPSAwCiAgICAgICAgd2hpbGUgbm90IHNlbGYuc3RvcF9ldmVudC5pc19zZXQoKToKICAgICAgICAgICAgaWYgc2VsZi5pc190dHk6CiAgICAgICAgICAgICAgICBlbGFwc2VkID0gaW50KHRpbWUudGltZSgpIC0gc2VsZi5zdGFydF90aW1lKQogICAgICAgICAgICAgICAgZnJhbWUgPSBzZWxmLmZyYW1lc1tpZHggJSBsZW4oc2VsZi5mcmFtZXMpXQogICAgICAgICAgICAgICAgd2l0aCBzZWxmLmxvY2s6CiAgICAgICAgICAgICAgICAgICAgbGluZSA9IGYiXHJcMDMzWzJLICBcMDMzWzE7Mzg7NTs1MW17ZnJhbWV9XDAzM1swbSBcMDMzWzM4OzU7MjUwbXtzZWxmLmRlc2N9Li4uXDAzM1swbSBcMDMzWzM4OzU7MjQ0bSh7c2VsZi5jb3VudH0gZm91bmQsIHtlbGFwc2VkfXMpXDAzM1swbSIKICAgICAgICAgICAgICAgICAgICBzeXMuc3RkZXJyLndyaXRlKGxpbmUpCiAgICAgICAgICAgICAgICAgICAgc3lzLnN0ZGVyci5mbHVzaCgpCiAgICAgICAgICAgIGlkeCArPSAxCiAgICAgICAgICAgIHRpbWUuc2xlZXAoMC4wOCkKCiAgICBkZWYgcHJpbnRfaXRlbShzZWxmLCBmb3JtYXR0ZWQsIHJhd19saW5lPU5vbmUpOgogICAgICAgIHdpdGggc2VsZi5sb2NrOgogICAgICAgICAgICBzZWxmLmNvdW50ICs9IDEKICAgICAgICAgICAgaWYgc2VsZi5pc190dHk6CiAgICAgICAgICAgICAgICBzeXMuc3RkZXJyLndyaXRlKCJcclwwMzNbMksiKQogICAgICAgICAgICBzeXMuc3RkZXJyLndyaXRlKGYie2Zvcm1hdHRlZH1cbiIpCiAgICAgICAgICAgIHN5cy5zdGRlcnIuZmx1c2goKQogICAgICAgICAgICBpZiBzZWxmLm91dF9maWxlIGFuZCByYXdfbGluZSBpcyBub3QgTm9uZToKICAgICAgICAgICAgICAgIHNlbGYub3V0X2ZpbGUud3JpdGUoc3RyaXBfYW5zaShyYXdfbGluZSkucnN0cmlwKCkgKyAiXG4iKQogICAgICAgICAgICAgICAgc2VsZi5vdXRfZmlsZS5mbHVzaCgpCgogICAgZGVmIGZpbmlzaChzZWxmLCBjdXN0b21fbXNnPU5vbmUpOgogICAgICAgIHNlbGYuc3RvcF9ldmVudC5zZXQoKQogICAgICAgIHNlbGYudGhyZWFkLmpvaW4oKQogICAgICAgIGVsYXBzZWQgPSBmInt0aW1lLnRpbWUoKSAtIHNlbGYuc3RhcnRfdGltZTouMWZ9cyIKICAgICAgICB3aXRoIHNlbGYubG9jazoKICAgICAgICAgICAgaWYgc2VsZi5pc190dHk6CiAgICAgICAgICAgICAgICBzeXMuc3RkZXJyLndyaXRlKCJcclwwMzNbMksiKQogICAgICAgICAgICBpZiBjdXN0b21fbXNnOgogICAgICAgICAgICAgICAgbXNnID0gY3VzdG9tX21zZwogICAgICAgICAgICBlbHNlOgogICAgICAgICAgICAgICAgdW5pdCA9ICJsaXZlIHJlc3BvbnNlcyBjYXB0dXJlZCIgaWYgc2VsZi5zdGFnZSA9PSAiaHR0cHgiIGVsc2UgImRpc2NvdmVyZWQiCiAgICAgICAgICAgICAgICBtc2cgPSBmIntzZWxmLnRpdGxlfSBjb21wbGV0ZWQgaW4ge2VsYXBzZWR9IOKAlCB7c2VsZi5jb3VudH0ge3VuaXR9IgogICAgICAgICAgICBzeXMuc3RkZXJyLndyaXRlKGYiICBcMDMzWzE7Mzg7NTs4Mm3inJRcMDMzWzBtIFwwMzNbMTszN217bXNnfVwwMzNbMG1cbiIpCiAgICAgICAgICAgIHN5cy5zdGRlcnIuZmx1c2goKQogICAgICAgICAgICBpZiBzZWxmLm91dF9maWxlOgogICAgICAgICAgICAgICAgc2VsZi5vdXRfZmlsZS5jbG9zZSgpCgpkZWYgbWFpbigpOgogICAgcGFyc2VyID0gYXJncGFyc2UuQXJndW1lbnRQYXJzZXIoKQogICAgc3VicGFyc2VycyA9IHBhcnNlci5hZGRfc3VicGFyc2VycyhkZXN0PSJjbWQiKQoKICAgICMgYmFubmVyIGNvbW1hbmQKICAgIHBfYmFubmVyID0gc3VicGFyc2Vycy5hZGRfcGFyc2VyKCJiYW5uZXIiKQogICAgcF9iYW5uZXIuYWRkX2FyZ3VtZW50KCItLXRhcmdldCIsIHJlcXVpcmVkPVRydWUpCiAgICBwX2Jhbm5lci5hZGRfYXJndW1lbnQoIi0tZG9tYWluIiwgcmVxdWlyZWQ9VHJ1ZSkKICAgIHBfYmFubmVyLmFkZF9hcmd1bWVudCgiLS1vdXRkaXIiLCByZXF1aXJlZD1UcnVlKQogICAgcF9iYW5uZXIuYWRkX2FyZ3VtZW50KCItLW1vZHVsZXMiLCByZXF1aXJlZD1UcnVlKQoKICAgICMgbm90aWNlIGNvbW1hbmQKICAgIHBfbm90aWNlID0gc3VicGFyc2Vycy5hZGRfcGFyc2VyKCJub3RpY2UiKQogICAgcF9ub3RpY2UuYWRkX2FyZ3VtZW50KCItLW51bSIsIHR5cGU9aW50LCByZXF1aXJlZD1UcnVlKQogICAgcF9ub3RpY2UuYWRkX2FyZ3VtZW50KCItLXRvdGFsIiwgdHlwZT1pbnQsIHJlcXVpcmVkPVRydWUpCiAgICBwX25vdGljZS5hZGRfYXJndW1lbnQoIi0tdGl0bGUiLCByZXF1aXJlZD1UcnVlKQogICAgcF9ub3RpY2UuYWRkX2FyZ3VtZW50KCItLW1zZyIsIHJlcXVpcmVkPVRydWUpCgogICAgIyBza2lwIGNvbW1hbmQKICAgIHBfc2tpcCA9IHN1YnBhcnNlcnMuYWRkX3BhcnNlcigic2tpcCIpCiAgICBwX3NraXAuYWRkX2FyZ3VtZW50KCItLW51bSIsIHR5cGU9aW50LCByZXF1aXJlZD1UcnVlKQogICAgcF9za2lwLmFkZF9hcmd1bWVudCgiLS10b3RhbCIsIHR5cGU9aW50LCByZXF1aXJlZD1UcnVlKQogICAgcF9za2lwLmFkZF9hcmd1bWVudCgiLS10aXRsZSIsIHJlcXVpcmVkPVRydWUpCgogICAgIyBzdHJlYW0gY29tbWFuZAogICAgcF9zdHJlYW0gPSBzdWJwYXJzZXJzLmFkZF9wYXJzZXIoInN0cmVhbSIpCiAgICBwX3N0cmVhbS5hZGRfYXJndW1lbnQoIi0tc3RhZ2UiLCByZXF1aXJlZD1UcnVlKQogICAgcF9zdHJlYW0uYWRkX2FyZ3VtZW50KCItLW51bSIsIHR5cGU9aW50LCByZXF1aXJlZD1UcnVlKQogICAgcF9zdHJlYW0uYWRkX2FyZ3VtZW50KCItLXRvdGFsIiwgdHlwZT1pbnQsIHJlcXVpcmVkPVRydWUpCiAgICBwX3N0cmVhbS5hZGRfYXJndW1lbnQoIi0tZGVzYyIsIHJlcXVpcmVkPVRydWUpCiAgICBwX3N0cmVhbS5hZGRfYXJndW1lbnQoIi0tb3V0IiwgcmVxdWlyZWQ9VHJ1ZSkKCiAgICAjIHN1bW1hcnkgY29tbWFuZAogICAgcF9zdW0gPSBzdWJwYXJzZXJzLmFkZF9wYXJzZXIoInN1bW1hcnkiKQogICAgcF9zdW0uYWRkX2FyZ3VtZW50KCItLXRhcmdldCIsIHJlcXVpcmVkPVRydWUpCiAgICBwX3N1bS5hZGRfYXJndW1lbnQoIi0tYXNzZXRzIiwgcmVxdWlyZWQ9VHJ1ZSkKICAgIHBfc3VtLmFkZF9hcmd1bWVudCgiLS1saXZlIiwgcmVxdWlyZWQ9VHJ1ZSkKICAgIHBfc3VtLmFkZF9hcmd1bWVudCgiLS1yZXBvcnQiLCByZXF1aXJlZD1UcnVlKQogICAgcF9zdW0uYWRkX2FyZ3VtZW50KCItLWR1cmF0aW9uIiwgcmVxdWlyZWQ9VHJ1ZSkKCiAgICAjIHJlcG9ydHMgY29tbWFuZAogICAgcF9yZXAgPSBzdWJwYXJzZXJzLmFkZF9wYXJzZXIoImJ1aWxkX3JlcG9ydHMiKQogICAgcF9yZXAuYWRkX2FyZ3VtZW50KCItLXRhcmdldCIsIHJlcXVpcmVkPVRydWUpCiAgICBwX3JlcC5hZGRfYXJndW1lbnQoIi0tZG9tYWluIiwgcmVxdWlyZWQ9VHJ1ZSkKICAgIHBfcmVwLmFkZF9hcmd1bWVudCgiLS1vdXRkaXIiLCByZXF1aXJlZD1UcnVlKQogICAgcF9yZXAuYWRkX2FyZ3VtZW50KCItLWFtYXNzLXJlcyIsIHJlcXVpcmVkPVRydWUpCiAgICBwX3JlcC5hZGRfYXJndW1lbnQoIi0tc3ViLXJlcyIsIHJlcXVpcmVkPVRydWUpCiAgICBwX3JlcC5hZGRfYXJndW1lbnQoIi0tY29tYmluZWQtcmVzIiwgcmVxdWlyZWQ9VHJ1ZSkKICAgIHBfcmVwLmFkZF9hcmd1bWVudCgiLS1odHRweC1qc29uIiwgcmVxdWlyZWQ9VHJ1ZSkKICAgIHBfcmVwLmFkZF9hcmd1bWVudCgiLS1zdGFydC10aW1lIiwgcmVxdWlyZWQ9VHJ1ZSkKICAgIHBfcmVwLmFkZF9hcmd1bWVudCgiLS1maW5pc2gtdGltZSIsIHJlcXVpcmVkPVRydWUpCiAgICBwX3JlcC5hZGRfYXJndW1lbnQoIi0tZG8tZmZ1ZiIsIHR5cGU9aW50LCBkZWZhdWx0PTApCiAgICBwX3JlcC5hZGRfYXJndW1lbnQoIi0tZG8tdXJscyIsIHR5cGU9aW50LCBkZWZhdWx0PTApCiAgICBwX3JlcC5hZGRfYXJndW1lbnQoIi0tZG8tanMiLCB0eXBlPWludCwgZGVmYXVsdD0wKQoKICAgIGFyZ3MgPSBwYXJzZXIucGFyc2VfYXJncygpCgogICAgaWYgYXJncy5jbWQgPT0gImJhbm5lciI6CiAgICAgICAgZm9ybWF0X2JveCgKICAgICAgICAgICAgIuKaoSBSRUNPTiBBVVRPTUFUSU9OIEVOR0lORSIsCiAgICAgICAgICAgIFsKICAgICAgICAgICAgICAgICgiVGFyZ2V0IiwgYXJncy50YXJnZXQsICJcMDMzWzM4OzU7MjIybSIpLAogICAgICAgICAgICAgICAgKCJEb21haW4iLCBhcmdzLmRvbWFpbiwgIlwwMzNbMzg7NTs4MW0iKSwKICAgICAgICAgICAgICAgICgiT3V0cHV0IiwgZiJ7YXJncy5vdXRkaXJ9LyIsICJcMDMzWzM4OzU7MTQ3bSIpLAogICAgICAgICAgICAgICAgKCJNb2R1bGVzIiwgYXJncy5tb2R1bGVzLCAiXDAzM1szODs1OzI1MG0iKSwKICAgICAgICAgICAgXSwKICAgICAgICAgICAgIlwwMzNbMzg7NTszOW0iLAogICAgICAgICAgICAiXDAzM1sxOzM4OzU7NTFtIgogICAgICAgICkKCiAgICBlbGlmIGFyZ3MuY21kID09ICJub3RpY2UiOgogICAgICAgIHN5cy5zdGRlcnIud3JpdGUoZiJcblwwMzNbMTszODs1OzM5beKVreKUgOKUgFwwMzNbMG0gXDAzM1sxOzM3bVt7YXJncy5udW19L3thcmdzLnRvdGFsfV1cMDMzWzBtIFwwMzNbMTszODs1OzUxbXthcmdzLnRpdGxlfVwwMzNbMG1cbiIpCiAgICAgICAgc3lzLnN0ZGVyci53cml0ZShmIiAgXDAzM1sxOzM4OzU7ODJt4pyUXDAzM1swbSBcMDMzWzE7Mzdte2FyZ3MubXNnfVwwMzNbMG1cbiIpCiAgICAgICAgc3lzLnN0ZGVyci5mbHVzaCgpCgogICAgZWxpZiBhcmdzLmNtZCA9PSAic2tpcCI6CiAgICAgICAgc3lzLnN0ZGVyci53cml0ZShmIlxuXDAzM1sxOzM4OzU7MjQybeKVreKUgOKUgFwwMzNbMG0gXDAzM1szODs1OzI0Mm1be2FyZ3MubnVtfS97YXJncy50b3RhbH1dIHthcmdzLnRpdGxlfSAoc2tpcHBlZClcMDMzWzBtXG4iKQogICAgICAgIHN5cy5zdGRlcnIuZmx1c2goKQoKICAgIGVsaWYgYXJncy5jbWQgPT0gInN1bW1hcnkiOgogICAgICAgIGZvcm1hdF9ib3goCiAgICAgICAgICAgICLinJQgUkVDT04gQ09NUExFVEVEIFNVQ0NFU1NGVUxMWSIsCiAgICAgICAgICAgIFsKICAgICAgICAgICAgICAgICgiVGFyZ2V0IiwgYXJncy50YXJnZXQsICJcMDMzWzM4OzU7MjIybSIpLAogICAgICAgICAgICAgICAgKCJBc3NldHMiLCBmInthcmdzLmFzc2V0c30gZGlzY292ZXJlZCIsICJcMDMzWzE7Mzg7NTs1MW0iKSwKICAgICAgICAgICAgICAgICgiTGl2ZSBIb3N0cyIsIGYie2FyZ3MubGl2ZX0gcmVzcG9uZGluZyIsICJcMDMzWzE7Mzg7NTs4Mm0iKSwKICAgICAgICAgICAgICAgICgiUmVwb3J0IiwgYXJncy5yZXBvcnQsICJcMDMzWzE7Mzg7NTsyMjBtIiksCiAgICAgICAgICAgICAgICAoIkR1cmF0aW9uIiwgYXJncy5kdXJhdGlvbiwgIlwwMzNbMzg7NTsyNTBtIiksCiAgICAgICAgICAgIF0sCiAgICAgICAgICAgICJcMDMzWzM4OzU7ODJtIiwKICAgICAgICAgICAgIlwwMzNbMTszODs1OzgybSIKICAgICAgICApCgogICAgZWxpZiBhcmdzLmNtZCA9PSAic3RyZWFtIjoKICAgICAgICB1aSA9IExpdmVTdHJlYW1VSShhcmdzLnN0YWdlLCBhcmdzLm51bSwgYXJncy50b3RhbCwgYXJncy5kZXNjLCBhcmdzLm91dCkKICAgICAgICB1aS5zdGFydCgpCgogICAgICAgIGlmIGFyZ3Muc3RhZ2UgaW4gKCJhbWFzcyIsICJzdWJmaW5kZXIiKToKICAgICAgICAgICAgc2VlbiA9IHNldCgpCiAgICAgICAgICAgIGJhZGdlX2NvbG9yID0gIlwwMzNbMTszODs1OzE0MW1bQU1BU1NdXDAzM1swbSIgaWYgYXJncy5zdGFnZSA9PSAiYW1hc3MiIGVsc2UgIlwwMzNbMTszODs1OzM5bVtTVUJGSU5ERVJdXDAzM1swbSIKICAgICAgICAgICAgZm9yIGxpbmUgaW4gc3lzLnN0ZGluOgogICAgICAgICAgICAgICAgY2xlYW4gPSBsaW5lLnN0cmlwKCkKICAgICAgICAgICAgICAgIGlmIG5vdCBjbGVhbiBvciBjbGVhbi5zdGFydHN3aXRoKCJbIikgb3IgIlN0YXJ0aW5nIiBpbiBjbGVhbjoKICAgICAgICAgICAgICAgICAgICBjb250aW51ZQogICAgICAgICAgICAgICAgY2xlYW4gPSBzdHJpcF9hbnNpKGNsZWFuKQogICAgICAgICAgICAgICAgaWYgY2xlYW4gaW4gc2VlbjoKICAgICAgICAgICAgICAgICAgICBjb250aW51ZQogICAgICAgICAgICAgICAgc2Vlbi5hZGQoY2xlYW4pCiAgICAgICAgICAgICAgICBmbXQgPSBmIiAgXDAzM1szODs1OzgybeKclFwwMzNbMG0ge2JhZGdlX2NvbG9yfSBcMDMzWzM4OzU7NTFte2NsZWFufVwwMzNbMG0iCiAgICAgICAgICAgICAgICB1aS5wcmludF9pdGVtKGZtdCwgY2xlYW4pCgogICAgICAgIGVsaWYgYXJncy5zdGFnZSA9PSAiaHR0cHgiOgogICAgICAgICAgICBzZWVuX2VudHJpZXMgPSBzZXQoKQogICAgICAgICAgICBmb3IgbGluZSBpbiBzeXMuc3RkaW46CiAgICAgICAgICAgICAgICBjbGVhbiA9IGxpbmUuc3RyaXAoKQogICAgICAgICAgICAgICAgaWYgbm90IGNsZWFuOgogICAgICAgICAgICAgICAgICAgIGNvbnRpbnVlCiAgICAgICAgICAgICAgICBjbGVhbl9ub19hbnNpID0gc3RyaXBfYW5zaShjbGVhbikKICAgICAgICAgICAgICAgIHRyeToKICAgICAgICAgICAgICAgICAgICBkYXRhID0ganNvbi5sb2FkcyhjbGVhbl9ub19hbnNpKQogICAgICAgICAgICAgICAgZXhjZXB0IEV4Y2VwdGlvbjoKICAgICAgICAgICAgICAgICAgICBjb250aW51ZQoKICAgICAgICAgICAgICAgIHVybCA9IGRhdGEuZ2V0KCJ1cmwiKSBvciBkYXRhLmdldCgiaW5wdXQiKSBvciAiIgogICAgICAgICAgICAgICAgc3RhdHVzID0gZGF0YS5nZXQoInN0YXR1c19jb2RlIiwgMCkKICAgICAgICAgICAgICAgIGVudHJ5X2tleSA9ICh1cmwsIHN0YXR1cykKICAgICAgICAgICAgICAgIGlmIGVudHJ5X2tleSBpbiBzZWVuX2VudHJpZXM6CiAgICAgICAgICAgICAgICAgICAgY29udGludWUKICAgICAgICAgICAgICAgIHNlZW5fZW50cmllcy5hZGQoZW50cnlfa2V5KQoKICAgICAgICAgICAgICAgIHRpdGxlID0gKGRhdGEuZ2V0KCJ0aXRsZSIpIG9yICIiKS5zdHJpcCgpCiAgICAgICAgICAgICAgICBjbCA9IGRhdGEuZ2V0KCJjb250ZW50X2xlbmd0aCIsIDApCiAgICAgICAgICAgICAgICBzZXJ2ZXIgPSAoZGF0YS5nZXQoIndlYnNlcnZlciIpIG9yICIiKS5zdHJpcCgpCiAgICAgICAgICAgICAgICB0ZWNoID0gZGF0YS5nZXQoInRlY2giKSBvciBbXQogICAgICAgICAgICAgICAgbG9jID0gKGRhdGEuZ2V0KCJsb2NhdGlvbiIpIG9yICIiKS5zdHJpcCgpCgogICAgICAgICAgICAgICAgaWYgMjAwIDw9IHN0YXR1cyA8IDMwMDoKICAgICAgICAgICAgICAgICAgICBiYWRnZSA9IGYiXDAzM1sxOzMwOzQ4OzU7ODJtIHtzdGF0dXN9IE9LIFwwMzNbMG0iCiAgICAgICAgICAgICAgICBlbGlmIDMwMCA8PSBzdGF0dXMgPCA0MDA6CiAgICAgICAgICAgICAgICAgICAgYmFkZ2UgPSBmIlwwMzNbMTszMDs0ODs1OzIyMG0ge3N0YXR1c30gUkVEIFwwMzNbMG0iCiAgICAgICAgICAgICAgICBlbGlmIDQwMCA8PSBzdGF0dXMgPCA1MDA6CiAgICAgICAgICAgICAgICAgICAgYmFkZ2UgPSBmIlwwMzNbMTszNzs0ODs1OzE5Nm0ge3N0YXR1c30gRVJSIFwwMzNbMG0iCiAgICAgICAgICAgICAgICBlbGlmIHN0YXR1cyA+PSA1MDA6CiAgICAgICAgICAgICAgICAgICAgYmFkZ2UgPSBmIlwwMzNbMTszNzs0ODs1OzEyNW0ge3N0YXR1c30gU1JWIFwwMzNbMG0iCiAgICAgICAgICAgICAgICBlbHNlOgogICAgICAgICAgICAgICAgICAgIGJhZGdlID0gZiJcMDMzWzE7Mzc7NDg7NTsyNDBtIHtzdGF0dXN9ID8/PyBcMDMzWzBtIgoKICAgICAgICAgICAgICAgIGlmIGNsID4gMTA0ODU3NjoKICAgICAgICAgICAgICAgICAgICBzaXplX3N0ciA9IGYie2NsLzEwNDg1NzY6LjFmfU1CIgogICAgICAgICAgICAgICAgZWxpZiBjbCA+IDEwMjQ6CiAgICAgICAgICAgICAgICAgICAgc2l6ZV9zdHIgPSBmIntjbC8xMDI0Oi4xZn1LQiIKICAgICAgICAgICAgICAgIGVsaWYgY2wgPiAwOgogICAgICAgICAgICAgICAgICAgIHNpemVfc3RyID0gZiJ7Y2x9QiIKICAgICAgICAgICAgICAgIGVsc2U6CiAgICAgICAgICAgICAgICAgICAgc2l6ZV9zdHIgPSAiIgoKICAgICAgICAgICAgICAgIHBhcnRzID0gW2YiICB7YmFkZ2V9IFwwMzNbMTszODs1OzUxbXt1cmx9XDAzM1swbSJdCiAgICAgICAgICAgICAgICBpZiBsb2MgYW5kIGxvYyAhPSB1cmw6CiAgICAgICAgICAgICAgICAgICAgcGFydHMuYXBwZW5kKGYiXDAzM1szODs1OzI0NW3ihpIge2xvY31cMDMzWzBtIikKICAgICAgICAgICAgICAgIGlmIHNpemVfc3RyOgogICAgICAgICAgICAgICAgICAgIHBhcnRzLmFwcGVuZChmIlwwMzNbMzg7NTsxNDFtW3tzaXplX3N0cn1dXDAzM1swbSIpCiAgICAgICAgICAgICAgICBpZiB0aXRsZToKICAgICAgICAgICAgICAgICAgICBwYXJ0cy5hcHBlbmQoZiJcMDMzWzE7MzdtXCJ7dGl0bGV9XCJcMDMzWzBtIikKICAgICAgICAgICAgICAgIGlmIHNlcnZlcjoKICAgICAgICAgICAgICAgICAgICBwYXJ0cy5hcHBlbmQoZiJcMDMzWzM4OzU7MjQ4bVt7c2VydmVyfV1cMDMzWzBtIikKICAgICAgICAgICAgICAgIGlmIHRlY2g6CiAgICAgICAgICAgICAgICAgICAgcGFydHMuYXBwZW5kKGYiXDAzM1szODs1OzIyMm0oeycsICcuam9pbih0ZWNoKX0pXDAzM1swbSIpCgogICAgICAgICAgICAgICAgdWkucHJpbnRfaXRlbSgiICIuam9pbihwYXJ0cyksIGNsZWFuX25vX2Fuc2kpCgogICAgICAgIGVsaWYgYXJncy5zdGFnZSA9PSAiZmZ1ZiI6CiAgICAgICAgICAgIGZvciBsaW5lIGluIHN5cy5zdGRpbjoKICAgICAgICAgICAgICAgIGNsZWFuID0gbGluZS5zdHJpcCgpCiAgICAgICAgICAgICAgICBpZiBub3QgY2xlYW46CiAgICAgICAgICAgICAgICAgICAgY29udGludWUKICAgICAgICAgICAgICAgIGNsZWFuID0gc3RyaXBfYW5zaShjbGVhbikKICAgICAgICAgICAgICAgIGZtdCA9IGYiICBcMDMzWzM4OzU7ODJt4pyUXDAzM1swbSBcMDMzWzE7Mzg7NTsyMTNtW0ZGVUZdXDAzM1swbSBcMDMzWzM4OzU7MjUzbXtjbGVhbn1cMDMzWzBtIgogICAgICAgICAgICAgICAgdWkucHJpbnRfaXRlbShmbXQsIGNsZWFuKQoKICAgICAgICBlbGlmIGFyZ3Muc3RhZ2UgPT0gInVybHMiOgogICAgICAgICAgICBmb3IgbGluZSBpbiBzeXMuc3RkaW46CiAgICAgICAgICAgICAgICBjbGVhbiA9IGxpbmUuc3RyaXAoKQogICAgICAgICAgICAgICAgaWYgbm90IGNsZWFuOgogICAgICAgICAgICAgICAgICAgIGNvbnRpbnVlCiAgICAgICAgICAgICAgICBjbGVhbiA9IHN0cmlwX2Fuc2koY2xlYW4pCiAgICAgICAgICAgICAgICBmbXQgPSBmIiAgXDAzM1szODs1OzgybeKclFwwMzNbMG0gXDAzM1sxOzM4OzU7MjIwbVtHQVVdXDAzM1swbSBcMDMzWzM4OzU7MjUzbXtjbGVhbn1cMDMzWzBtIgogICAgICAgICAgICAgICAgdWkucHJpbnRfaXRlbShmbXQsIGNsZWFuKQoKICAgICAgICBlbGlmIGFyZ3Muc3RhZ2UgPT0gImpzIjoKICAgICAgICAgICAgZm9yIGxpbmUgaW4gc3lzLnN0ZGluOgogICAgICAgICAgICAgICAgY2xlYW4gPSBsaW5lLnN0cmlwKCkKICAgICAgICAgICAgICAgIGlmIG5vdCBjbGVhbjoKICAgICAgICAgICAgICAgICAgICBjb250aW51ZQogICAgICAgICAgICAgICAgY2xlYW4gPSBzdHJpcF9hbnNpKGNsZWFuKQogICAgICAgICAgICAgICAgZm10ID0gZiIgIFwwMzNbMzg7NTs4Mm3inJRcMDMzWzBtIFwwMzNbMTszODs1OzIwOG1bS0FUQU5BXVwwMzNbMG0gXDAzM1szODs1OzI1M217Y2xlYW59XDAzM1swbSIKICAgICAgICAgICAgICAgIHVpLnByaW50X2l0ZW0oZm10LCBjbGVhbikKCiAgICAgICAgdWkuZmluaXNoKCkKCiAgICBlbGlmIGFyZ3MuY21kID09ICJidWlsZF9yZXBvcnRzIjoKICAgICAgICBzdWJkb21haW5zID0gW10KICAgICAgICBpZiBvcy5wYXRoLmV4aXN0cyhhcmdzLnN1Yl9yZXMpOgogICAgICAgICAgICB3aXRoIG9wZW4oYXJncy5zdWJfcmVzKSBhcyBmOgogICAgICAgICAgICAgICAgc3ViZG9tYWlucyA9IFtsLnN0cmlwKCkgZm9yIGwgaW4gZiBpZiBsLnN0cmlwKCldCgogICAgICAgIGFtYXNzX2l0ZW1zID0gW10KICAgICAgICBpZiBvcy5wYXRoLmV4aXN0cyhhcmdzLmFtYXNzX3Jlcyk6CiAgICAgICAgICAgIHdpdGggb3BlbihhcmdzLmFtYXNzX3JlcykgYXMgZjoKICAgICAgICAgICAgICAgIGFtYXNzX2l0ZW1zID0gW2wuc3RyaXAoKSBmb3IgbCBpbiBmIGlmIGwuc3RyaXAoKV0KCiAgICAgICAgY29tYmluZWRfaXRlbXMgPSBbXQogICAgICAgIGlmIG9zLnBhdGguZXhpc3RzKGFyZ3MuY29tYmluZWRfcmVzKToKICAgICAgICAgICAgd2l0aCBvcGVuKGFyZ3MuY29tYmluZWRfcmVzKSBhcyBmOgogICAgICAgICAgICAgICAgY29tYmluZWRfaXRlbXMgPSBbbC5zdHJpcCgpIGZvciBsIGluIGYgaWYgbC5zdHJpcCgpXQoKICAgICAgICByYXdfaHR0cHggPSBbXQogICAgICAgIGlmIG9zLnBhdGguZXhpc3RzKGFyZ3MuaHR0cHhfanNvbik6CiAgICAgICAgICAgIHdpdGggb3BlbihhcmdzLmh0dHB4X2pzb24pIGFzIGY6CiAgICAgICAgICAgICAgICBmb3IgbGluZSBpbiBmOgogICAgICAgICAgICAgICAgICAgIGxpbmUgPSBsaW5lLnN0cmlwKCkKICAgICAgICAgICAgICAgICAgICBpZiBub3QgbGluZToKICAgICAgICAgICAgICAgICAgICAgICAgY29udGludWUKICAgICAgICAgICAgICAgICAgICB0cnk6CiAgICAgICAgICAgICAgICAgICAgICAgIHJhd19odHRweC5hcHBlbmQoanNvbi5sb2FkcyhsaW5lKSkKICAgICAgICAgICAgICAgICAgICBleGNlcHQgRXhjZXB0aW9uOgogICAgICAgICAgICAgICAgICAgICAgICBwYXNzCgogICAgICAgICMgRGVkdXBsaWNhdGUgaHR0cHggcm93cyBieSAodXJsLCBzdGF0dXNfY29kZSkKICAgICAgICBzZWVuX2hvc3RzID0gc2V0KCkKICAgICAgICBodHRweF9yb3dzID0gW10KICAgICAgICAjIFNvcnQgc28gMjAwIHJlc3BvbnNlcyB0YWtlIHByaW9yaXR5IG92ZXIgcmVkaXJlY3RzCiAgICAgICAgcmF3X2h0dHB4LnNvcnQoa2V5PWxhbWJkYSByOiAoMCBpZiByLmdldCgic3RhdHVzX2NvZGUiLCAwKSA9PSAyMDAgZWxzZSAxLCByLmdldCgidXJsIiwgIiIpKSkKICAgICAgICBmb3IgciBpbiByYXdfaHR0cHg6CiAgICAgICAgICAgIGsgPSAoci5nZXQoInVybCIsICIiKSwgci5nZXQoInN0YXR1c19jb2RlIiwgMCkpCiAgICAgICAgICAgIGlmIGsgbm90IGluIHNlZW5faG9zdHM6CiAgICAgICAgICAgICAgICBzZWVuX2hvc3RzLmFkZChrKQogICAgICAgICAgICAgICAgaHR0cHhfcm93cy5hcHBlbmQocikKCiAgICAgICAgbGluZXMgPSBbXQogICAgICAgIGxpbmVzLmFwcGVuZCgiIyBSZWNvblxuIikKICAgICAgICBsaW5lcy5hcHBlbmQoIiMjIFRhcmdldFxuIikKICAgICAgICBsaW5lcy5hcHBlbmQoZiJge2FyZ3MudGFyZ2V0fWBcbiIpCiAgICAgICAgbGluZXMuYXBwZW5kKCIjIyBEb21haW5cbiIpCiAgICAgICAgbGluZXMuYXBwZW5kKGYiYHthcmdzLmRvbWFpbn1gXG4iKQogICAgICAgIGxpbmVzLmFwcGVuZChmIioqU3RhcnRlZDoqKiB7YXJncy5zdGFydF90aW1lfVxuIikKCiAgICAgICAgbGluZXMuYXBwZW5kKCIjIyBTY2FuIENvdmVyYWdlXG4iKQogICAgICAgIGxpbmVzLmFwcGVuZCgifCBNb2R1bGUgfCBTdGF0dXMgfCBSZXN1bHQgfCBSZXBvcnQgfCIpCiAgICAgICAgbGluZXMuYXBwZW5kKCJ8LS0tfC0tLXwtLS06fC0tLXwiKQogICAgICAgIGxpbmVzLmFwcGVuZChmInwgQW1hc3MgfCBDb21wbGV0ZWQgfCB7bGVuKGFtYXNzX2l0ZW1zKX0gfCBbYW1hc3MubWRdKGFtYXNzLm1kKSB8IikKICAgICAgICBsaW5lcy5hcHBlbmQoZiJ8IFN1YmZpbmRlciB8IENvbXBsZXRlZCB8IHtsZW4oc3ViZG9tYWlucyl9IHwgW3N1YmZpbmRlci5tZF0oc3ViZmluZGVyLm1kKSB8IikKICAgICAgICBsaW5lcy5hcHBlbmQoZiJ8IENvbWJpbmVkIGFzc2V0cyB8IENvbXBsZXRlZCB8IHtsZW4oY29tYmluZWRfaXRlbXMpfSB8IFtjb21iaW5lZF9hc3NldHMubWRdKGNvbWJpbmVkX2Fzc2V0cy5tZCkgfCIpCiAgICAgICAgbGluZXMuYXBwZW5kKGYifCBIVFRQWCB8IENvbXBsZXRlZCB8IHtsZW4oaHR0cHhfcm93cyl9IGxpdmUgfCBbaHR0cHgubWRdKGh0dHB4Lm1kKSB8IikKICAgICAgICBpZiBhcmdzLmRvX2ZmdWY6CiAgICAgICAgICAgIGxpbmVzLmFwcGVuZCgifCBGRlVGIHwgQ29tcGxldGVkIHwg4oCUIHwgW2ZmdWYubWRdKGZmdWYubWQpIHwiKQogICAgICAgIGVsc2U6CiAgICAgICAgICAgIGxpbmVzLmFwcGVuZCgifCBGRlVGIHwgU2tpcHBlZCB8IOKAlCB8IOKAlCB8IikKICAgICAgICBpZiBhcmdzLmRvX3VybHM6CiAgICAgICAgICAgIGxpbmVzLmFwcGVuZCgifCBVUkwgZGlzY292ZXJ5IHwgQ29tcGxldGVkIHwg4oCUIHwgW3VybHMubWRdKHVybHMubWQpIHwiKQogICAgICAgIGVsc2U6CiAgICAgICAgICAgIGxpbmVzLmFwcGVuZCgifCBVUkwgZGlzY292ZXJ5IHwgU2tpcHBlZCB8IOKAlCB8IOKAlCB8IikKICAgICAgICBpZiBhcmdzLmRvX2pzOgogICAgICAgICAgICBsaW5lcy5hcHBlbmQoInwgSlMgLyBDcmF3bCB8IENvbXBsZXRlZCB8IOKAlCB8IFtqcy5tZF0oanMubWQpIHwiKQogICAgICAgIGVsc2U6CiAgICAgICAgICAgIGxpbmVzLmFwcGVuZCgifCBKUyAvIENyYXdsIHwgU2tpcHBlZCB8IOKAlCB8IOKAlCB8IikKICAgICAgICBsaW5lcy5hcHBlbmQoIiIpCgogICAgICAgIGxpbmVzLmFwcGVuZCgiIyMgU3ViZmluZGVyXG4iKQogICAgICAgIGlmIHN1YmRvbWFpbnM6CiAgICAgICAgICAgIGZvciBzIGluIHN1YmRvbWFpbnM6CiAgICAgICAgICAgICAgICBsaW5lcy5hcHBlbmQoZiItIGB7c31gIikKICAgICAgICBlbHNlOgogICAgICAgICAgICBsaW5lcy5hcHBlbmQoIk5vIHN1YmRvbWFpbnMgZm91bmQuIikKICAgICAgICBsaW5lcy5hcHBlbmQoZiJcbioqU3ViZG9tYWlucyBmb3VuZDoqKiB7bGVuKHN1YmRvbWFpbnMpfVxuIikKCiAgICAgICAgbGluZXMuYXBwZW5kKCIjIyBodHRweC10b29sa2l0XG4iKQogICAgICAgIGlmIGh0dHB4X3Jvd3M6CiAgICAgICAgICAgIGZvciByIGluIGh0dHB4X3Jvd3M6CiAgICAgICAgICAgICAgICB1ID0gci5nZXQoInVybCIsICIiKQogICAgICAgICAgICAgICAgc3QgPSByLmdldCgic3RhdHVzX2NvZGUiLCAwKQogICAgICAgICAgICAgICAgc3ogPSByLmdldCgiY29udGVudF9sZW5ndGgiLCAwKQogICAgICAgICAgICAgICAgdGl0ID0gKHIuZ2V0KCJ0aXRsZSIpIG9yICIiKS5yZXBsYWNlKCJbIiwgIigiKS5yZXBsYWNlKCJdIiwgIikiKQogICAgICAgICAgICAgICAgd3MgPSByLmdldCgid2Vic2VydmVyIikgb3IgIiIKICAgICAgICAgICAgICAgIHRlY2hfbGlzdCA9IHIuZ2V0KCJ0ZWNoIikgb3IgW10KICAgICAgICAgICAgICAgIHRjID0gIiwgIi5qb2luKHRlY2hfbGlzdCkKICAgICAgICAgICAgICAgIHBhcnRzID0gW2Yie3V9IFt7c3R9XSBbe3N6fV0iXQogICAgICAgICAgICAgICAgaWYgdGl0OgogICAgICAgICAgICAgICAgICAgIHBhcnRzLmFwcGVuZChmIlt7dGl0fV0iKQogICAgICAgICAgICAgICAgaWYgd3M6CiAgICAgICAgICAgICAgICAgICAgcGFydHMuYXBwZW5kKGYiW3t3c31dIikKICAgICAgICAgICAgICAgIGlmIHRjOgogICAgICAgICAgICAgICAgICAgIHBhcnRzLmFwcGVuZChmIlt7dGN9XSIpCiAgICAgICAgICAgICAgICBsaW5lcy5hcHBlbmQoIiAiLmpvaW4ocGFydHMpKQogICAgICAgIGVsc2U6CiAgICAgICAgICAgIGxpbmVzLmFwcGVuZCgiTm8gbGl2ZSBIVFRQIHNlcnZpY2VzIGZvdW5kLiIpCiAgICAgICAgbGluZXMuYXBwZW5kKGYiXG4qKkxpdmUgaG9zdHM6Kioge2xlbihodHRweF9yb3dzKX1cbiIpCgogICAgICAgIGxpbmVzLmFwcGVuZCgiIyMgTGl2ZSBEb21haW5zXG4iKQogICAgICAgIGlmIGh0dHB4X3Jvd3M6CiAgICAgICAgICAgIGxpbmVzLmFwcGVuZCgifCBVUkwgfCBTdGF0dXMgfCBUaXRsZSB8IFRlY2hub2xvZ2llcyB8IFNlcnZlciB8IFNpemUgfCIpCiAgICAgICAgICAgIGxpbmVzLmFwcGVuZCgifC0tLXwtLS06fC0tLXwtLS18LS0tfC0tLTp8IikKICAgICAgICAgICAgZm9yIHIgaW4gaHR0cHhfcm93czoKICAgICAgICAgICAgICAgIHUgPSByLmdldCgidXJsIiwgIiIpCiAgICAgICAgICAgICAgICBzdCA9IHIuZ2V0KCJzdGF0dXNfY29kZSIsICIiKQogICAgICAgICAgICAgICAgdGl0ID0gKHIuZ2V0KCJ0aXRsZSIpIG9yICIiKS5yZXBsYWNlKCJ8IiwgIlxcfCIpCiAgICAgICAgICAgICAgICB0YyA9ICgiLCAiLmpvaW4oci5nZXQoInRlY2giKSBvciBbXSkpLnJlcGxhY2UoInwiLCAiXFx8IikKICAgICAgICAgICAgICAgIHdzID0gKHIuZ2V0KCJ3ZWJzZXJ2ZXIiKSBvciAiIikucmVwbGFjZSgifCIsICJcXHwiKQogICAgICAgICAgICAgICAgc3ogPSByLmdldCgiY29udGVudF9sZW5ndGgiLCAiIikKICAgICAgICAgICAgICAgIGxpbmVzLmFwcGVuZChmInwge3V9IHwge3N0fSB8IHt0aXR9IHwge3RjfSB8IHt3c30gfCB7c3p9IHwiKQogICAgICAgIGVsc2U6CiAgICAgICAgICAgIGxpbmVzLmFwcGVuZCgiTm8gbGl2ZSBIVFRQIGhvc3RzLiIpCiAgICAgICAgbGluZXMuYXBwZW5kKCIiKQoKICAgICAgICBsaW5lcy5hcHBlbmQoIiMjIFRlY2hub2xvZ3kgU3RhY2tcbiIpCiAgICAgICAgbGluZXMuYXBwZW5kKCJ8IFRlY2hub2xvZ3kgfCBPYnNlcnZlZCBPbiB8IFJlZmVyZW5jZSB8IikKICAgICAgICBsaW5lcy5hcHBlbmQoInwtLS18LS0tfC0tLXwiKQogICAgICAgIHNlZW5fdGVjaCA9IHNldCgpCiAgICAgICAgZm9yIHIgaW4gaHR0cHhfcm93czoKICAgICAgICAgICAgdSA9IHIuZ2V0KCJ1cmwiLCAiIikKICAgICAgICAgICAgZm9yIHQgaW4gKHIuZ2V0KCJ0ZWNoIikgb3IgW10pOgogICAgICAgICAgICAgICAgaWYgdCBhbmQgdCBub3QgaW4gc2Vlbl90ZWNoOgogICAgICAgICAgICAgICAgICAgIHNlZW5fdGVjaC5hZGQodCkKICAgICAgICAgICAgICAgICAgICBsaW5lcy5hcHBlbmQoZiJ8IGB7dH1gIHwgYHt1fWAgfCBbaHR0cHgubWRdKGh0dHB4Lm1kKSB8IikKICAgICAgICAgICAgd3MgPSByLmdldCgid2Vic2VydmVyIikKICAgICAgICAgICAgaWYgd3MgYW5kIHdzIG5vdCBpbiBzZWVuX3RlY2g6CiAgICAgICAgICAgICAgICBzZWVuX3RlY2guYWRkKHdzKQogICAgICAgICAgICAgICAgbGluZXMuYXBwZW5kKGYifCBge3dzfWAgfCBge3V9YCB8IFtodHRweC5tZF0oaHR0cHgubWQpIHwiKQogICAgICAgIGlmIG5vdCBzZWVuX3RlY2g6CiAgICAgICAgICAgIGxpbmVzLmFwcGVuZCgifCBOb25lIGlkZW50aWZpZWQgfCDigJQgfCDigJQgfCIpCiAgICAgICAgbGluZXMuYXBwZW5kKCIiKQoKICAgICAgICBsaW5lcy5hcHBlbmQoIiMjIEludGVyZXN0aW5nIC8gU2Vuc2l0aXZlIEtleXdvcmRzXG4iKQogICAgICAgIGxpbmVzLmFwcGVuZCgiPiBUaGVzZSBhcmUgaW5kaWNhdG9ycyBmb3IgbWFudWFsIHJldmlldywgbm90IGNvbmZpcm1lZCB2dWxuZXJhYmlsaXRpZXMuXG4iKQogICAgICAgIGt3X3JlID0gcmUuY29tcGlsZShyJ2FkbWlufGFkbWluaXN0cmF0b3J8YXBpfGF1dGh8YXV0aGVudGljYXRpb258bG9naW58c2lnbmlufHNpZ251cHxhY2NvdW50fHVzZXJ8aW50ZXJuYWx8c3RhZ2luZ3xzdGFnZXxkZXZ8ZGV2ZWxvcG1lbnR8dGVzdHxkZWJ1Z3xjb25maWd8Y29uZmlndXJhdGlvbnx0b2tlbnxzZWNyZXR8cGFzc3dvcmR8cGFzc3dkfGFwaWtleXxhcGkta2V5fGtleXxjcmVkZW50aWFsfGdyYXBocWx8c3dhZ2dlcnxvcGVuYXBpfGJhY2t1cHxwcml2YXRlfHVwbG9hZHxkb3dubG9hZHxyZXNldHx2ZXJpZnknLCByZS5JKQogICAgICAgIG1hdGNoZXMgPSBbXQogICAgICAgIGZvciByIGluIGh0dHB4X3Jvd3M6CiAgICAgICAgICAgIHRhcmdldF9zdHIgPSBmIntyLmdldCgndXJsJywnJyl9IHtyLmdldCgndGl0bGUnLCcnKX0geycgJy5qb2luKHIuZ2V0KCd0ZWNoJykgb3IgW10pfSIKICAgICAgICAgICAgbSA9IGt3X3JlLnNlYXJjaCh0YXJnZXRfc3RyKQogICAgICAgICAgICBpZiBtOgogICAgICAgICAgICAgICAga3cgPSBtLmdyb3VwKDApLmxvd2VyKCkKICAgICAgICAgICAgICAgIG1hdGNoZXMuYXBwZW5kKGYifCBge2t3fWAg4oCUIHtyLmdldCgndXJsJywnJyl9ICh7ci5nZXQoJ3RpdGxlJywnJyl9KSB8IFtodHRweC5tZF0oaHR0cHgubWQpIHwiKQogICAgICAgIGlmIG1hdGNoZXM6CiAgICAgICAgICAgIGxpbmVzLmFwcGVuZCgifCBNYXRjaCB8IFNvdXJjZSB8IikKICAgICAgICAgICAgbGluZXMuYXBwZW5kKCJ8LS0tfC0tLXwiKQogICAgICAgICAgICBsaW5lcy5leHRlbmQobWF0Y2hlc1s6NTBdKQogICAgICAgIGVsc2U6CiAgICAgICAgICAgIGxpbmVzLmFwcGVuZCgifCBNYXRjaCB8IFNvdXJjZSB8IikKICAgICAgICAgICAgbGluZXMuYXBwZW5kKCJ8LS0tfC0tLXwiKQogICAgICAgICAgICBsaW5lcy5hcHBlbmQoInwgTm9uZSBkZXRlY3RlZCB8IOKAlCB8IikKICAgICAgICBsaW5lcy5hcHBlbmQoIiIpCgogICAgICAgIGxpbmVzLmFwcGVuZCgiIyMgRXZpZGVuY2UgRmlsZXNcbiIpCiAgICAgICAgbGluZXMuYXBwZW5kKCItIFtBbWFzc10oYW1hc3MubWQpIikKICAgICAgICBsaW5lcy5hcHBlbmQoIi0gW1N1YmZpbmRlcl0oc3ViZmluZGVyLm1kKSIpCiAgICAgICAgbGluZXMuYXBwZW5kKCItIFtDb21iaW5lZCBBc3NldHNdKGNvbWJpbmVkX2Fzc2V0cy5tZCkiKQogICAgICAgIGxpbmVzLmFwcGVuZCgiLSBbSFRUUFhdKGh0dHB4Lm1kKSIpCiAgICAgICAgaWYgYXJncy5kb19mZnVmOgogICAgICAgICAgICBsaW5lcy5hcHBlbmQoIi0gW0ZGVUZdKGZmdWYubWQpIikKICAgICAgICBpZiBhcmdzLmRvX3VybHM6CiAgICAgICAgICAgIGxpbmVzLmFwcGVuZCgiLSBbVVJMIERpc2NvdmVyeV0odXJscy5tZCkiKQogICAgICAgIGlmIGFyZ3MuZG9fanM6CiAgICAgICAgICAgIGxpbmVzLmFwcGVuZCgiLSBbSlMgLyBDcmF3bF0oanMubWQpIikKICAgICAgICBsaW5lcy5hcHBlbmQoIiIpCiAgICAgICAgbGluZXMuYXBwZW5kKCItLS0iKQogICAgICAgIGxpbmVzLmFwcGVuZChmIlxuKipGaW5pc2hlZDoqKiB7YXJncy5maW5pc2hfdGltZX1cbiIpCgogICAgICAgIGZ1bGxfY29udGVudCA9ICJcbiIuam9pbihsaW5lcykKCiAgICAgICAgcmVjb25fcGF0aCA9IG9zLnBhdGguam9pbihhcmdzLm91dGRpciwgInJlY29uLm1kIikKICAgICAgICBvdmVyYWxsX3BhdGggPSBvcy5wYXRoLmpvaW4oYXJncy5vdXRkaXIsICJvdmVyYWxsX3NjYW4ubWQiKQogICAgICAgIHdpdGggb3BlbihyZWNvbl9wYXRoLCAidyIpIGFzIGY6CiAgICAgICAgICAgIGYud3JpdGUoZnVsbF9jb250ZW50KQogICAgICAgIHdpdGggb3BlbihvdmVyYWxsX3BhdGgsICJ3IikgYXMgZjoKICAgICAgICAgICAgZi53cml0ZShmdWxsX2NvbnRlbnQpCgppZiBfX25hbWVfXyA9PSAiX19tYWluX18iOgogICAgbWFpbigpCg==" | base64 -d > "$ui_script"

    # ------------------------------------------------------------
    # Display Banner
    # ------------------------------------------------------------
    set -l modules_str "Amass, Subfinder, HTTPX"
    if test $do_ffuf -eq 1
        set modules_str "$modules_str, FFUF"
    end
    if test $do_urls -eq 1
        set modules_str "$modules_str, URLs"
    end
    if test $do_js -eq 1
        set modules_str "$modules_str, JS"
    end

    python3 "$ui_script" banner \
        --target "$target" \
        --domain "$domain" \
        --outdir "$outdir" \
        --modules "$modules_str"

    # ============================================================
    # STAGE 1: AMASS
    # ============================================================
    amass enum \
        -passive \
        -d "$domain" \
        -silent \
        2>"$amass_error" \
        | python3 "$ui_script" stream \
            --stage amass \
            --num 1 \
            --total $total_stages \
            --desc "Passive OSINT & DNS enumeration" \
            --out "$amass_result"

    if test -f "$amass_result"
        sort -u "$amass_result" -o "$amass_result"
        set -l amass_count (wc -l <"$amass_result" | string trim)
    else
        touch "$amass_result"
        set -l amass_count 0
    end
    set -l amass_count (wc -l <"$amass_result" | string trim)

    # Write amass.md
    begin
        echo "# Amass"
        echo
        echo "**Target:** \`$domain\`"
        echo
        echo "**Mode:** Passive enumeration"
        echo
        echo "**Found:** $amass_count"
        echo
        echo "## Results"
        echo
        if test $amass_count -gt 0
            for item in (cat "$amass_result")
                echo "- \`$item\`"
            end
        else
            echo "No results."
        end
        if test -s "$amass_error"
            echo
            echo "## Diagnostics"
            echo
            echo '```text'
            cat "$amass_error"
            echo '```'
        end
    end >"$amass_md"

    # ============================================================
    # STAGE 2: SUBFINDER
    # ============================================================
    subfinder \
        -d "$domain" \
        -silent \
        2>"$sub_error" \
        | python3 "$ui_script" stream \
            --stage subfinder \
            --num 2 \
            --total $total_stages \
            --desc "Querying passive DNS sources" \
            --out "$sub_result"

    if test -f "$sub_result"
        sort -u "$sub_result" -o "$sub_result"
        set -l sub_count (wc -l <"$sub_result" | string trim)
    else
        touch "$sub_result"
        set -l sub_count 0
    end
    set -l sub_count (wc -l <"$sub_result" | string trim)

    # Write subfinder.md
    begin
        echo "# Subfinder"
        echo
        echo "**Target:** \`$domain\`"
        echo
        echo "**Found:** $sub_count"
        echo
        echo "## Results"
        echo
        if test $sub_count -gt 0
            for item in (cat "$sub_result")
                echo "- \`$item\`"
            end
        else
            echo "No results."
        end
        if test -s "$sub_error"
            echo
            echo "## Diagnostics"
            echo
            echo '```text'
            cat "$sub_error"
            echo '```'
        end
    end >"$subfinder_md"

    # ============================================================
    # STAGE 3: ASSET CONSOLIDATION
    # ============================================================
    cat "$amass_result" "$sub_result" \
        | string match -r '^[A-Za-z0-9._-]+\.[A-Za-z]{2,}$' \
        | sort -u \
        >"$combined"

    # Always ensure domain is included
    echo "$domain" >>"$combined"
    sort -u "$combined" -o "$combined"

    set -l combined_count (wc -l <"$combined" | string trim)

    # Write combined_assets.md
    begin
        echo "# Combined Assets"
        echo
        echo "**Source:** Amass + Subfinder"
        echo
        echo "**Unique assets:** $combined_count"
        echo
        echo "## Results"
        echo
        for item in (cat "$combined")
            echo "- \`$item\`"
        end
    end >"$combined_md"

    python3 "$ui_script" notice \
        --num 3 \
        --total $total_stages \
        --title "Asset Consolidation" \
        --msg "Consolidated $combined_count unique asset(s)"

    # ============================================================
    # STAGE 4: HTTPX PROBING
    # ============================================================
    # Include original target URL (crucial when path is provided), domain, and assets
    if string match -q 'http*' "$target"
        echo "$target" >"$httpx_input"
    else
        echo "https://$target" >"$httpx_input"
        echo "http://$target" >>"$httpx_input"
    end

    echo "https://$domain" >>"$httpx_input"
    echo "http://$domain" >>"$httpx_input"

    if test -f "$combined"
        for asset in (cat "$combined")
            echo "$asset" >>"$httpx_input"
            echo "https://$asset" >>"$httpx_input"
        end
    end

    sort -u "$httpx_input" -o "$httpx_input"

    $httpx_bin \
        -l "$httpx_input" \
        -silent \
        -status-code \
        -title \
        -tech-detect \
        -web-server \
        -content-length \
        -json \
        2>"$httpx_error" \
        | python3 "$ui_script" stream \
            --stage httpx \
            --num 4 \
            --total $total_stages \
            --desc "Probing HTTP/HTTPS services" \
            --out "$httpx_json"

    if not test -f "$httpx_json"
        touch "$httpx_json"
    end
    set -l live_count (wc -l <"$httpx_json" | string trim)

    # Write httpx.md
    begin
        echo "# HTTPX"
        echo
        echo "**Input assets:** $combined_count"
        echo
        echo "**Live HTTP responses:** $live_count"
        echo
        echo "## Results"
        echo
        echo "| URL | Status | Title | Technologies | Server | Size |"
        echo "|---|---:|---|---|---|---:|"
        while read -l row
            set -l url (echo "$row" | jq -r '.url // ""')
            set -l status_code (echo "$row" | jq -r '.status_code // ""')
            set -l title (echo "$row" | jq -r '.title // ""')
            set -l tech (echo "$row" | jq -r '(.tech // []) | join(", ")')
            set -l server (echo "$row" | jq -r '.webserver // ""')
            set -l size (echo "$row" | jq -r '.content_length // ""')

            set title (string replace -a '|' '\|' -- "$title")
            set tech (string replace -a '|' '\|' -- "$tech")
            set server (string replace -a '|' '\|' -- "$server")

            echo "| $url | $status_code | $title | $tech | $server | $size |"
        end <"$httpx_json"

        if test -s "$httpx_error"
            echo
            echo "## Diagnostics"
            echo
            echo '```text'
            cat "$httpx_error"
            echo '```'
        end
    end >"$httpx_md"

    # ============================================================
    # OPTIONAL STAGES: FFUF, URLS, JS
    # ============================================================
    set -l current_stage 4

    if test $do_ffuf -eq 1
        set current_stage (math $current_stage + 1)
        if test -z "$wordlist"
            if test -f /usr/share/seclists/Discovery/Web-Content/common.txt
                set wordlist /usr/share/seclists/Discovery/Web-Content/common.txt
            else if test -f /usr/share/wordlists/dirb/common.txt
                set wordlist /usr/share/wordlists/dirb/common.txt
            else
                set wordlist "/tmp/quick_wordlist.txt"
                printf "admin\napi\nlogin\nupload\nconfig\nrobots.txt\nsitemap.xml\n" > "$wordlist"
            end
        end

        begin
            echo "# FFUF"
            echo
            echo "**Wordlist:** \`$wordlist\`"
            echo
        end >"$ffuf_md"

        set -l ffuf_targets (jq -r '.url // empty' "$httpx_json")
        for base in $ffuf_targets
            set base (string replace -r '/$' '' "$base")
            set -l ffuf_file "$tmpdir/ffuf-"(string replace -a '/' '_' -- "$base")".md"
            set -l ffuf_err "$tmpdir/ffuf-"(string replace -a '/' '_' -- "$base")".err"

            ffuf \
                -u "$base/FUZZ" \
                -w "$wordlist" \
                -mc 200,204,301,302,307,308,401,403 \
                -rate 50 \
                -t 20 \
                -s \
                -noninteractive \
                -of md \
                -o "$ffuf_file" \
                2>"$ffuf_err" \
                | python3 "$ui_script" stream \
                    --stage ffuf \
                    --num $current_stage \
                    --total $total_stages \
                    --desc "Fuzzing paths on $base" \
                    --out "$tmpdir/ffuf_stream.txt"

            if test -s "$ffuf_file"
                cat "$ffuf_file" >>"$ffuf_md"
            end
        end
    end

    if test $do_urls -eq 1
        set current_stage (math $current_stage + 1)
        set -l urls_result "$tmpdir/urls.txt"
        gau --subs "$domain" 2>/dev/null \
            | python3 "$ui_script" stream \
                --stage urls \
                --num $current_stage \
                --total $total_stages \
                --desc "Historical URL discovery" \
                --out "$urls_result"

        sort -u "$urls_result" -o "$urls_result"
        set -l url_count (wc -l <"$urls_result" | string trim)
        begin
            echo "# URL Discovery"
            echo
            echo "**Source:** gau"
            echo
            echo "**URLs found:** $url_count"
            echo
            echo "## Results"
            echo
            for url in (cat "$urls_result")
                echo "- \`$url\`"
            end
        end >"$urls_md"
    end

    if test $do_js -eq 1
        set current_stage (math $current_stage + 1)
        set -l js_result "$tmpdir/js.txt"
        katana \
            -u "$target" \
            -silent \
            -jc \
            -d 3 \
            2>/dev/null \
            | python3 "$ui_script" stream \
                --stage js \
                --num $current_stage \
                --total $total_stages \
                --desc "Crawling JavaScript & endpoints" \
                --out "$js_result"

        sort -u "$js_result" -o "$js_result"
        set -l js_count (wc -l <"$js_result" | string trim)
        begin
            echo "# JavaScript / Crawl"
            echo
            echo "**Source:** katana"
            echo
            echo "**URLs discovered:** $js_count"
            echo
            echo "## Results"
            echo
            for url in (cat "$js_result")
                echo "- \`$url\`"
            end
        end >"$js_md"
    end

    # ============================================================
    # STAGE: REPORT GENERATION
    # ============================================================
    set -l report_stage (math $current_stage + 1)
    python3 "$ui_script" notice \
        --num $report_stage \
        --total $total_stages \
        --title "Report Generation" \
        --msg "Building structured Markdown reports (recon.md & overall_scan.md)"

    set -l finish_time (date '+%Y-%m-%d %H:%M:%S')

    python3 "$ui_script" build_reports \
        --target "$target" \
        --domain "$domain" \
        --outdir "$outdir" \
        --amass-res "$amass_result" \
        --sub-res "$sub_result" \
        --combined-res "$combined" \
        --httpx-json "$httpx_json" \
        --start-time "$start_time" \
        --finish-time "$finish_time" \
        --do-ffuf "$do_ffuf" \
        --do-urls "$do_urls" \
        --do-js "$do_js"

    # ============================================================
    # SUMMARY & CLEANUP
    # ============================================================
    set -l end_epoch (date +%s)
    set -l duration_sec (math $end_epoch - $start_epoch)
    set -l duration_str "$duration_sec"s

    python3 "$ui_script" summary \
        --target "$target" \
        --assets "$combined_count" \
        --live "$live_count" \
        --report "$outdir/recon.md" \
        --duration "$duration_str"

    # Cleanup temporary workspace
    rm -rf "$tmpdir"
    return 0
end
