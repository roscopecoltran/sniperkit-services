echo "starting log downloader (30 second interval) 🤗🤗🤗🤗🤗🤗"
echo "press CTRL+C to stop 🛑"
echo "SETTING UP KERBEROS"

read -p "Input INT account (GXXXXX):" gnumber
add="@INT.SYS.SHARED.FORTIS"
read -s -p "Input password for INT:" pass
extension=".keytab"
keytabname=$gnumber$extension
echo "Logging in."
printf "%b" "addent -password -p $gnumber$add -k 1 -e arcfour-hmac-md5\n$pass\nwrite_kt $keytabname" | ktutil
kinit -k -t $keytabname $gnumber$add

while :
do
  nrlogurls=$(grep -vc '^$' /tmp/configurls.txt)
  echo "Found $nrlogurls log URLs"
  counter=1
  while [  $counter -lt $(($nrlogurls + 1)) ]; do
    echo "Checking log URL number: $counter "
    configline=$(sed "${counter}q;d" /tmp/configurls.txt)
    application=${configline%%:*}
    echo "Downloading applications logs for application: $application"
    downloadurl=${configline#*:}
    echo "Downloading URL: $downloadurl"

    echo "Downloading $application logs... 👷‍👷"
    curl -s -l -k --location-trusted --negotiate -u : -b ~/cookiejar.txt -c ~/cookiejar.txt $downloadurl -o /tmp/${application}-dl.log
    echo "👌 ok 👌"
    FILE=/tmp/${application}-old.log
    if [ -s $FILE ]; then
       echo "Found previously downloaded logs, only sending new lines."
       grep -vf /tmp/${application}-old.log /tmp/${application}-dl.log > /tmp/${application}-diff.log
       rm /tmp/${application}-old.log
    else
       echo "File $FILE does not exist, sending entire log."
       cp /tmp/${application}-dl.log /tmp/${application}-diff.log
    fi

    FILE2=/tmp/${application}-diff.log
    if [ -s $FILE2 ]; then
      echo "Selecting only WAS codes"
      cat /tmp/${application}-diff.log | grep 'WAS[0-9]\{4\}' > /tmp/${application}-diff-was.log
      rm /tmp/${application}-diff.log
    else
       echo "No new events"
    fi

    FILE3=/tmp/${application}-diff-was.log
    if [ -s $FILE3 ]; then
      echo "👌 ok 👌"
      tag="###$application"
      echo "Tagging log lines with ${tag}... 👷‍👷"
      sed "s|$|${tag}|" /tmp/${application}-diff-was.log > /tmp/${application}-diff-was-tagged.log
      rm /tmp/${application}-diff-was.log
      echo "👌 ok 👌"
      echo "Feeding ${application} logs to Logstash... 👷‍👷"
      nc -q 0 logstash 5000 < /tmp/${application}-diff-was-tagged.log
      rm /tmp/${application}-diff-was-tagged.log
      echo "👌 ok 👌"

    else
      echo "No new WAS events found."
    fi

    mv /tmp/${application}-dl.log /tmp/${application}-old.log
    let counter=counter+1

    echo "Waiting 30 seconds, to avoid overloading elasticsearch"
    sleep 30
  done


sleep 60
done
echo "Something went wrong while downloading the logs, please review the script and rebuild."
#if you add a line, add update echo as well to represent what it is downloading
#update what you download here in the Dockerfile inside the polling folder
#for questions/feedback send a mail to tijs.gommmeren@bnpparibasfortis.com
