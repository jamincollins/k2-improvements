#!/bin/ash

# Use our common install script, to keep things consistent.
# We can't pipe it directly into sh, because it breaks the input prompts.
curl -s https://octoeverywhere.com/k2.sh -o ./octoeverywhere-installer.sh
sh ./octoeverywhere-installer.sh
rm ./octoeverywhere-installer.sh
