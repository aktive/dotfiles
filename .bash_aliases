if [ -n "$AKTIVE_ALIASES_LOADED" ]; then return; fi
export AKTIVE_ALIASES_LOADED=1
echo "🔥 aktivated $HOSTNAME..."
echo ""
alias rcp="rsync -avP"
alias rmv="rsync -avP --remove-source-files"
alias mounts="findmnt -t nfs,nfs4"
alias ll="ls -alF"
alias hdd="lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT,LABEL,MODEL"
alias hdd-health="sudo smartctl -H /dev/nvme0n1 && sudo smartctl -H /dev/nvme1n1"
alias hdd-usage="df -hT --exclude-type=tmpfs --exclude-type=overlay --exclude-type=squashfs"

# 'hog': takes a pig to find a pig
# usage:
#   hog           -> top 10 in current folder
#   hog 5         -> top 5 in current folder
#   hog sys       -> top 10 system-wide (- mounts)
#   hog sys 20    -> top 20 system-wide (- mounts)
#   hog all       -> top 10 EVERYTHING (+ mounts/nas)
function hog() {
    local mode="local"
    local count=10
    if [[ "$1" == "sys" || "$1" == "all" ]]; then
        mode="$1"
        count=${2:-10}
    else
        mode="local"
        count=${1:-10}
    fi
    case "$mode" in
        "sys")
            echo "🖥️ scanning system disks for top $count... (- /mnt)"
            sudo find / -path /proc -prune -o -path /sys -prune -o -path /dev -prune -o -path /run -prune -o -path /mnt -prune -o -type f -printf '%s %p\n' 2>/dev/null | \
            sort -nr 2>/dev/null | head -n "$count" | awk '{print $1/1073741824 " GB: " $2}'
            ;;
        "all")
            echo "✳️ scanning system for top $count... (+ mnt & usb)"
            sudo find / -path /proc -prune -o -path /sys -prune -o -path /dev -prune -o -path /run -prune -o -type f -printf '%s %p\n' 2>/dev/null | \
            sort -nr 2>/dev/null | head -n "$count" | awk '{print $1/1073741824 " GB: " $2}'
            ;;
        *)
            echo "📂 scanning folder for top $count..."
            du -ah --max-depth=1 2>/dev/null | sort -hr | head -n "$count"
            ;;
    esac
}

# pull dots from gh
pull-dots() {
    current_dir=$(pwd)
    echo "pull from gh..."
    cd ~/dotfiles && git pull && source ~/.bashrc
    cd "$current_dir"
    echo "gh pull complete... shell reloaded"
}
