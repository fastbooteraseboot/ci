#!/usr/bin/env bash

# Logging functions
log() {
    echo "[LOG] $*"
}
error() {
    echo "[ERROR] $*" >&2
    exit 1
}

# telegram
send_msg() {
    local text
    text=$(echo -e "$1")
    curl -s -X POST "https://api.telegram.org/bot$TG_BOT_TOKEN/sendMessage" \
        -d "chat_id=$TG_CHAT_ID" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=markdown" \
        -d "text=$text"
}

# create_release <tag name> <release name> <file> [<notes-file>]
create_release() {
    local tag_name="$1"
    local release_name="$2"
    local file="$3"
    local notes_file="$4"
    local args

    # check input
    [ -n "$tag_name" ] || error "Tag name must be set"
    [ -n "$release_name" ] || error "Release name must be set"
    [ -f "$file" ] || error "$file doesn't exist"
    if [ -n "$notes_file" ]; then
        if [ -f "$notes_file" ]; then
            notes=1
        else
            error "notes file doesn't exist"
        fi
    fi

    # setup args
    args=("$tag_name" "$file" --title "$release_name")
    [ "$notes" == "1" ] && args+=(-F "$notes_file")

    # ensure GitHub token is set for gh
    export GH_TOKEN="${GH_TOKEN:-${GITHUB_TOKEN}}"

    # oh yeahh
    gh release create "${args[@]}"

    return $?
}

# setup magiskboot
setup_magiskboot() {
    mkdir -p ~/bin
    export PATH="~/bin:$PATH"
    curl -s "https://raw.githubusercontent.com/TheWildJames/Get_My_Kernel_Format/refs/heads/main/magiskboot" -o ~/bin/magiskboot
    chmod 777 ~/bin/magiskboot
}
