# Paste this script into your favorite shell's "profile" file
# For Mac users, this may be ~/.zshrc or ~/.bash_profile.
# For Linux users, this may be ~/.bashrc or ~/.profile.
# You can execute `dvcd` to change into DVC's managed directory,
# or `dvcd <account>` or `dvcd <account>/<repo>` to change into a specific
# account folder or repo belonging to said account.
function dvcd() {
    if command -v dvc >/dev/null; then
        cd "$(dvc --prefix)" || (echo "Could not change into managed directory." ; exit 1)
        if [[ -n $1 ]]; then
            cd "$1" || (echo "Could not change into subdirectory: $1." ; exit 2)
        fi
    else
        echo "DVC is not installed."
        echo "Visit the repo at https://github.com/deus-x-mackina/dvc.git"
    fi
}
