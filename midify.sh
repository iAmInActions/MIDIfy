#!/bin/bash

# MIDIfy, a FOSS Spotify-inspired MIDI-based Music Playlist streaming service.
# made by mueller_minki in 2022
# Licensed under the DO WHAT THE FUCK YOU WANT TO Public License.
# All default midi sources are credited at http://muellers-software.org/midify/sources.txt

# ---- CONFIGURATION ----

# Change the default midi player.
# 1 = timidity
# 2 = pioplemidi-cli
# 3 = custom command
MIDIPLAYER=1

# Custom MIDI player command (in case 3 is selected):
# File URL is passed as an argument behind the command.
MIDIPROG="someprogramname -argument1 --argument 2 -h -xyz"

# Change this if you want to use a 3rd party MIDIfy server.
# If this variable gets changed I am not responsible for any errors, faults, security issues or lack of source declaration. You will be entirely on your own.
MIDIFYSERVER="http://muellers-software.org/midify"

# Change this to specify a different path to your local library.
MIDIFYLOCAL="$(pwd)/library"

# Change default folder for extra files:
STUFF="$(pwd)/stuff"

# Change default folder for temporary files:
TEMP="$(pwd)/tmp"

# ---- CONFIGURATION END ----


# Cleaning up before doing anything else:
rm -r $TEMP
mkdir $TEMP

# Define Functions:

# Get a random line of a file
# Usage: $(getlineoffile <file>)
getlineoffile () {
  MAXLINE=$(sed -n '$=' "$1")
  LINE=$(shuf -i 1-$MAXLINE -n 1)
  echo $(sed "${LINE}q;d" "$1")
}

# Run in offline mode
run_offline () {
  clear && cat $MIDIFYLOCAL/playlists.txt | more
  read -p "Enter a playlist name: " PLIST
  if test -f "$MIDIFYLOCAL/lists/$PLIST.mm3u"
  then
    echo "Found the playlist."
    echo "Starting playback..."
    play_playlist
  else
    echo "Invalid playlist. Try again."
    sleep 2
    run_offline
  fi
}

# Run in online mode
run_online () {
  clear && curl -q "$MIDIFYSERVER/playlists.txt" | more
  read -p "Enter a playlist name: " PLIST
  status=$(curl --head --silent "$MIDIFYSERVER/lists/$PLIST.mm3u" | head -n 1)
  if echo "$status" | grep -q 404
  then
    echo "Invalid playlist. Try again."
    sleep 2
    run_online
  else
    echo "Found the playlist. Caching to disk..."
    curl -q "$MIDIFYSERVER/lists/$PLIST.mm3u" > $TEMP/playlist.mm3u
    echo "Starting playback..."
    play_playlist
  fi
}

# Play the playlist
play_playlist () {
  if [ "$mode" = "l" ]
  then
    # Local mode
    while true
    do
      PLFILE="$MIDIFYLOCAL/lists/$PLIST.mm3u"
      MAXLINE=$(sed -n '$=' "$PLFILE")
      LINE=$(shuf -i 1-$MAXLINE -n 1)
      MFILE=$(sed "${LINE}q;d" "$PLFILE")
      play_song $MIDIFYLOCAL/midi/$MFILE
      sleep 1
    done
  elif [ "$mode" = "o" ]
  then
    # Online mode
    while true
    do
      PLFILE=$TEMP/playlist.mm3u
      MAXLINE=$(sed -n '$=' "$PLFILE")
      LINE=$(shuf -i 1-$MAXLINE -n 1)
      MFILE=$(sed "${LINE}q;d" "$PLFILE")
      curl -q $MIDIFYSERVER/midi/$MFILE > $TEMP/$MFILE
      play_song $TEMP/$MFILE
      rm $TEMP/$MFILE
      sleep 1
    done
  fi
}

play_song () {
  echo "Now Playing: $MFILE"
  if [ "$MIDIPLAYER" = "1" ]
  then
    timidity -A 50 "$1" >/dev/null
  elif [ "$MIDIPLAYER" = "2" ]
  then
    pioplemidi-cli "$1" -nl -fp -frb -s
  elif [ "$MIDIPLAYER" = "3" ]
  then
    $MIDIPROG "$1"
  else
    echo "Internal misconfiguration. Exiting."
    exit 2
  fi
}

# Main process:

# Splash screen:
clear
echo '           __  __ _____ _____ _____  __       
          |  \/  |_   _|  __ \_   _|/ _|      
          | \  / | | | | |  | || | | |_ _   _ 
          | |\/| | | | | |  | || | |  _| | | |
          | |  | |_| |_| |__| || |_| | | |_| |
          |_|  |_|_____|_____/_____|_|  \__, |
                                         __/ |
v1.0, created by mueller_minki in 2022. |___/ '
echo $(getlineoffile "$STUFF/splash.txt")

# Initial selection:
read -n 1 -p "Do you want to use (l)ocal or (o)nline mode?" mode

if [ "$mode" = "l" ]
then
  run_offline
elif [ "$mode" = "o" ]
then
  run_online
else
  echo "Not a valid mode. Exiting."
  exit 1
fi


exit 0
