#!/bin/bash
clear
cd /home/pi/ProjectAlice
echo ''
echo '  +-------------------------------------------------------------+'
echo -e "  | \e[48;5;2m\e[38;5;228m                    Docker Alice x86                       \e[39m\e[49m |"
echo '  |-------------------------------------------------------------|'
echo -e '  |                                                             |'
echo "  |  Creating venv.                                             |"
echo '  |-------------------------------------------------------------|'
echo "  |                                                             |"
echo "  |  Takes a little time.                                       |"
echo '  +-------------------------------------------------------------+'
echo ''


if [ $USE_PRE_BUILD_TGZ == true ]; then
  if [ -e /misc/ProjectAliceSkills.tgz ] ; then
    # created with  cd ProjectAlice &&  tar -czf ProjectAliceSkills.tgz skills
    cd /misc &&  tar -xzf ProjectAliceSkills.tgz -C /home/pi/ProjectAlice
  fi

  if [ -e /misc/data.db ] ; then
    cd /misc && cp -a data.db /home/pi/ProjectAlice/system/database/
  fi

  if [ -e /misc/hotwords.tgz ] ; then
    # created with  cd ProjectAlice/trained &&  tar -czf hotwords.tgz hotwords
    cd /misc && tar -xzf hotwords.tgz -C /home/pi/ProjectAlice/trained/hotwords
  fi

  if [ -e /misc/trainingData.tgz ] ; then
    cd /misc && tar -xzf trainingData.tgz -C /home/pi/ProjectAlice/var/cache/nlu/trainingData
  fi

  if [ -e /misc/amazon.tgz ] ; then
    # created with   cd ProjectAlice/var/cache && tar -czf amazon.tgz amazon
    cd /misc && tar -xzf amazon.tgz -C /home/pi/ProjectAlice/var/cache/
  fi

  if [ -e /misc/deepspeech-0.6.1-models.tar.gz ] ; then
    # Takes about 15 secs. to untar
    echo 'untar deepspeech, Takes about 15 secs.'
    mkdir -p /home/pi/ProjectAlice/trained/asr/deepspeech/en
    cd /misc && tar -xzf deepspeech-0.6.1-models.tar.gz -C /home/pi/ProjectAlice/trained/asr/deepspeech/en
  fi
fi

if [ -e /misc/venv.tgz ] && [ $USE_PRE_BUILD_TGZ == true ]; then
  # created with  cd ProjectAlice &&  time tar -czf venv.tgz venv
  cd /misc && tar -xzf venv.tgz  -C /home/pi/ProjectAlice/
else
  cd /home/pi/ProjectAlice/
  python3 -m venv ./venv
  venv/bin/pip install --upgrade pip


REQUIREMENTS_TEXT=$(cat <<'END_HEREDOC'
snips-nlu==0.20.2
watchdog
beautifulsoup4==4.9.3
lxml==4.5.2
python-musicpd==0.4.4
sounddevice==0.4.1
END_HEREDOC
)


  echo "$REQUIREMENTS_TEXT" > requirements-new.txt

  venv/bin/pip install -r requirements-new.txt
  venv/bin/pip install -r requirements.txt
  venv/bin/python -m snips_nlu download en
fi



# Be sure we start a new training session
echo '{}' > /home/pi/ProjectAlice/var/cache/dialogTemplates/checksums.json
# rm /home/pi/ProjectAlice/var/cache/nlu/trainingData/*
# rm /home/pi/ProjectAlice/assistant/assistant.json
# rm /home/pi/ProjectAlice/assistant/nlu_engine/nlu_engine.json

# Start a watchdog there react when the training is finished. Killing main.py
sudo chmod +x /start-scripts/system_do_not_touch/shutdown_installer.py
/start-scripts/system_do_not_touch/shutdown_installer.py &

~/bin/sed_all.sh
cd ~/ProjectAlice
venv/bin/python main.py


clear
echo ''
echo '  +-----------------------------------------------------------------------------------------------------------------+'
echo -e "  | \e[48;5;2m\e[38;5;228m                                             Docker Alice x86                                                  \e[39m\e[49m |"
echo '  |-----------------------------------------------------------------------------------------------------------------|'
echo -e '  |                                                                                                                 |'
echo "  |  Creation of venv finish!                                                                                       |"
echo "  | First time traning is acomplished. Congratulation!                                                            |"
echo "  |                                                                                                                 |"
echo "  |                                                                                                                 |"
echo "  | The message below are okay, here by the first training.                                                         |"
echo "  | Now you shall enter 'ctrl-c' followed by 'docker-composse down'.                                                |"
echo "  | The container are ready to use.                                                                                 |"
echo "  |                                                                                                                 |"
echo "  | [Project Alice]           An unhandled exception occured                                                        |"
echo "  |                                                                                                                 |"
echo "  | alice-amd    |   File \"/usr/local/lib/python3.7/subprocess.py\", line 512, in run                                |"
echo "  | alice-amd    |     output=stdout, stderr=stderr)                                                                |"
echo "  | alice-amd    | subprocess.CalledProcessError: Command '['pidof', 'snips-nlu']' returned non-zero exit status 1. |"
echo '  |-----------------------------------------------------------------------------------------------------------------|'
echo "  |                                                                                                                 |"
echo "  |  You can now run the container with:                                                                            |"
echo "  |    docker-compose up -d                                                                                         |"
echo "  |  And pull it down with:                                                                                         |"
echo "  |    docker-compose down                                                                                          |"
echo "  |                                                                                                                 |"
echo "  |  Go inside the container with 'docker-compose exec alice-amd bash'                                              |"
echo "  |  and 'alice'start'.                                                                                               |"
echo "  |                                                                                                                 |"
echo "  |  The system is now at your service.                                                                             |"
echo "  |  Good luck!                                                                                                     |"
echo '  +-------------------------------------------------------------------------------------------------------------- ---+'
echo ''

# sleep 2
# print("sudo kill -9 7")
# sudo kill -9 7
