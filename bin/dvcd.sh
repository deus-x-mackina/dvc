# Paste this script into your favorite shell's "profile" file
# For Mac users, this may be ~/.zshrc or ~/.bash_profile.
# For Linux users, this may be ~/.bashrc or ~/.profile.
# You can execute `dvcd` to change into DVC's managed directory,
# or `dvcd <user>/<repo>` to change into a specific repository. 
function dvcd() {
    if /usr/bin/which dvc >/dev/null; then
        cd $(dvc --prefix)
        if [[ $1 ]]; then
            cd $1
        fi
    else
        echo "DVC is not installed."
        echo "Visit the repo at https://github.com/deus-x-mackina/dvc.git"
    fi
}
