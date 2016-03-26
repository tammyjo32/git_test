#
# whatisontwitter.sh
# A toy script to do analysis of the most used words in twitter messages
#

#!/bin/tcsh

echo "Welcome!"
startover:
echo " "

if (-e existurl.txt) then
  echo "The following are the existing twitter URLs:"
  cat existurl.txt
else
  echo "You haven't captured anything, and there is currently no existing twitter URL."
endif

echo " "
echo "Press 1 if you want to enter a new twitter URL (not in the above list of existing URLs!)."
echo "Press 2 if you want to choose from the above existing URLs (only if there exists at least one!)."
echo "Press 3 if you want to see a summary of top 20 words for the data of the last 5 captures (if current number of captures is less than 5, print the summary for the data of all captures)."
echo "Press 4 if you want to look at the capture log file."
echo "Press 5 if you want to exit."

set option = $<

# if a new URL is entered, it must go the twitter page and do new analysis, record this capture to logfile, finally add the message file name to reportfilename.txt, add the new url to the existurl.txt

if ($option == 1) then
  echo "Please enter a new twitter URL (https://twitter.com/i/streams/stream/[1-59])"

  # go to the page, download html, save log infor, extract data and summarize it
  set urlsite = $<
  wget -o download.log -O twitter.html "$urlsite"
  # save in logfile.txt
  echo -n `sed -n '1s/--//gp' download.log` >> logfile.txt
  awk '/Length/{print "",$2 >> "logfile.txt"}' download.log

  # extract message and save the file, keep the topic and date
  set filedate = "`date +"%m%d%Y"`"
  set filetopic = "`grep 'StreamsHero-header' twitter.html | sed  's/<[^>]*>//g' | sed  's/ //g' | sed 's/\&amp;/\&/g'`"

  # for one day ad one topic, can only have one twitter messages file, rewrite it if already exsits
  # create twitter messages file
  echo -n `date +"%D"` > "${filetopic}_${filedate}.txt"
  echo " - `grep 'StreamsHero-header' twitter.html | sed 's/<[^>]*>//g' | sed 's/^[ \t]*//g' | sed 's/\&amp;/\&/g'`" >> "${filetopic}_${filedate}.txt"
  echo "Messages"  >> "${filetopic}_${filedate}.txt"
  echo "-------------"  >> "${filetopic}_${filedate}.txt"
  grep 'TweetTextSize' twitter.html | sed  's/<[^>]*>//g' | sed "s/\&\#39;/'/g" |sed 's/http.*$//g'| sed 's/\&quot;/\"/g' | sed 's/\&amp;/\&/g' | sed 's/pic.twitter.com.*$//g' | sed  's/^[ \t]*//g' >> "${filetopic}_${filedate}.txt"

  # for one day and one topic, can only have one top 20 word report file, rewrite it if already exists
  # create top 20 word report file
  echo -n `date +"%D"` > "${filetopic}_${filedate}_report.txt"
  echo -n " Top-20-words" >> "${filetopic}_${filedate}_report.txt"
  echo " `grep 'StreamsHero-header' twitter.html | sed 's/<[^>]*>//g' | sed 's/^[ \t]*//g'| sed 's/\&amp;/\&/g'`" >> "${filetopic}_${filedate}_report.txt"
  echo "Words Frequency" >> "${filetopic}_${filedate}_report.txt"
  echo "------ ------"  >> "${filetopic}_${filedate}_report.txt"
  sed -n '4,$p' "${filetopic}_${filedate}.txt" | tr -d '[:punct:]' | tr -d '[:digit:]' | tr ' ' '\n' | tr '[:upper:]' '[:lower:]' |sed '/^\s*$/d' | sort | uniq -c | sort -n -r -k1 | awk '{print $2, $1}' >>  "${filetopic}_${filedate}_report.txt"

  # give user option to add excluding word at this point
  echo "Press 1 if you want to add excluding words. Press 2 if you decide to use existing exluding words."
  set suboption = $<
  if ($suboption == 1) then
  	echo "Enter all the words you want to add (separated by white space)."
  	set addwords = "$<"
  	echo -n "$addwords" >> excludingword.txt
  endif

  # delete excluding words in the report file
  foreach exclude (`cat excludingword.txt`)
  	sed -i "/^$exclude/d" "${filetopic}_${filedate}_report.txt"
  end
  # delete the words ranking after 20
  sed -i '24,$d' "${filetopic}_${filedate}_report.txt"
  column -t "${filetopic}_${filedate}_report.txt"
  # save the new url to the existurl.txt, also add the new message file name to the reportfilename.txt
  echo -n "`grep 'StreamsHero-header' twitter.html | sed 's/<[^>]*>//g' | sed 's/^[ \t]*//g' | sed 's/\&amp;/\&/g'`:" >> existurl.txt
  echo " $urlsite" >> existurl.txt
  # Since this is a new url (new topic), it could not have the same name in the reportnamefile
  echo "${filetopic}_${filedate}.txt" >> reportfilename.txt
  sleep 2
  goto startover
endif

# choose from an existing URL
if ($option == 2) then
  echo "Choose one from the above listed URLs, type the number after the last slash in the URL."
  set urlnum = $<
  set urlsite = "https://twitter.com/i/streams/stream/${urlnum}"
  echo "Press 1 if you want to execute a new analysis of this twitter site, Press 2 if you want to take a look at data from previous executions of this twitter site"
  set suboption = $<
  # let user execute a new analysis from the exsiting URL.
  if ($suboption == 1) then
    wget -o download.log -O twitter.html "$urlsite"
    # save in logfile.txt
    echo -n `sed -n '1s/--//gp' download.log` >> logfile.txt
    awk '/Length/{print "",$2 >> "logfile.txt"}' download.log

    # extract messages and save the file, keep the topic and date
    set filedate = "`date +"%m%d%Y"`"
    set filetopic = "`grep 'StreamsHero-header' twitter.html | sed  's/<[^>]*>//g' | sed  's/ //g' | sed 's/\&amp;/\&/g'`"
    # for one day and one topic, can only have one messages file, rewrite it if already exsits
    # create the message file
    echo -n `date +"%D"` > "${filetopic}_${filedate}.txt"
    echo " - `grep 'StreamsHero-header' twitter.html | sed 's/<[^>]*>//g' | sed 's/^[ \t]*//g' | sed 's/\&amp;/\&/g'`" >> "${filetopic}_${filedate}.txt"
    echo "Messages"  >> "${filetopic}_${filedate}.txt"
    echo "-------------"  >> "${filetopic}_${filedate}.txt"
    grep 'TweetTextSize' twitter.html | sed  's/<[^>]*>//g' | sed "s/\&\#39;/'/g" |sed 's/http.*$//g'| sed 's/\&quot;/\"/g' | sed 's/\&amp;/\&/g' | sed 's/pic.twitter.com.*$//g' | sed  's/^[ \t]*//g' >> "${filetopic}_${filedate}.txt"
    # for one day and one topic, can only have one top 20 word report file, rewrite it if already exists
    # create top 20 word report file
    echo -n `date +"%D"` > "${filetopic}_${filedate}_report.txt"
    echo -n " Top-20-words" >> "${filetopic}_${filedate}_report.txt"
    echo " `grep 'StreamsHero-header' twitter.html | sed 's/<[^>]*>//g' | sed 's/^[ \t]*//g'| sed 's/\&amp;/\&/g'`" >> "${filetopic}_${filedate}_report.txt"
    echo "Words Frequency" >> "${filetopic}_${filedate}_report.txt"
    echo "------ ------"  >> "${filetopic}_${filedate}_report.txt"
    sed -n '4,$p' "${filetopic}_${filedate}.txt" | tr -d '[:punct:]' | tr -d '[:digit:]' | tr ' ' '\n' | tr '[:upper:]' '[:lower:]' |sed '/^\s*$/d' | sort | uniq -c | sort -n -r -k1 | awk '{print $2, $1}' >>  "${filetopic}_${filedate}_report.txt"

    # give user option to add new excluding words at this point
    echo "Press 1 if you want to add excluding words. Press 2 if you decide to use existing exluding words."
    set subminioption = $<
    if ($subminioption == 1) then
      echo "Enter all the words you want to add (separated by white space)."
      set addwords = "$<"
      echo -n "$addwords" >> excludingword.txt
    endif
    # delete excluding words in report file
    foreach exclude (`cat excludingword.txt`)
      sed -i "/^$exclude/d" "${filetopic}_${filedate}_report.txt"
    end
    # delete the words ranking after 20
    sed -i '24,$d' "${filetopic}_${filedate}_report.txt"
    column -t "${filetopic}_${filedate}_report.txt"

    # since this is an existing url, no need to add this url to existurl.txt
    # it's possible that this file name already exists (if for same topic and same day, already captured), if so, delete the existing one from reportfilename.txt and add the new one to the last line of the reportfilename.txt. If it does not exist, add it to the last line of the reportfilename.txt.
    set thisfile = "${filetopic}_${filedate}.txt"
    grep -q "$thisfile" reportfilename.txt
    if ($status == 0) then  # this file name already exsits in reportfilename.txt
      sed -i "/^$thisfile/d" reportfilename.txt
      echo "$thisfile" >> reportfilename.txt
    else  # this file name doesn't exsit or reportfilename.txt hasn't created yet
      echo "$thisfile" >> reportfilename.txt
    endif
    sleep 2
    goto startover
  endif

  # let user take a look at top-20-words report from previous executions
  if ($suboption == 2) then
    set topic = `grep "$urlsite" existurl.txt | sed -n 's/:.*$//gp' | sed 's/ //g'`
    echo "The previous executions of this site are listed as follows:"
    grep "$topic" reportfilename.txt
    echo " "
    echo "Please enter the specific date of previous executions from the above list (enter the sequence of numbers after the underscore)."
    set date = $<
    set selectfile = "${topic}_${date}_report.txt"
    echo "The following is the top-20-words report from the previous execution you selected:"
    column -t "$selectfile"
    sleep 2
    goto startover
  endif
endif

# let user look at the summary of top-20-words report from the data set of the last 5 different captures
if ($option == 3) then
  if (! -e reportfilename.txt) then
    echo "You haven't captured anything."
    sleep 2
    goto startover
  endif
  set numlines = "`wc -l < reportfilename.txt`"

  # if the number of different captures is less than 5, summarize over all the different captures.
  if ( $numlines < 5) then
    echo "The total number of different captures (either different topic or different date) is ${numlines}."
    echo "The following is the summary for the data of all ${numlines} different captures:"
    echo -n "Top-20-words" > summary.txt
    echo " Summary" >> summary.txt
    echo "Words Frequency" >> summary.txt
    echo "------- ------" >> summary.txt
    foreach message (`cat reportfilename.txt`)
      sed -n '4,$p' "$message" | tr -d '[:punct:]' | tr -d '[:digit:]' | tr ' ' '\n' | tr '[:upper:]' '[:lower:]' |sed '/^\s*$/d' >> combineword.txt
    end
    sort < combineword.txt | uniq -c | sort -n -r -k1 | awk '{print $2, $1}' > temp.txt
    foreach exclude (`cat excludingword.txt`)
      sed -i "/^$exclude/d" temp.txt
    end
    # delete the words ranking after 20
    sed -n '1,20p' temp.txt >> summary.txt

    column -t summary.txt
    rm combineword.txt temp.txt
    sleep 2
    goto startover

  # if the number of different captures is greater than or equal to 5, summarize over the last 5 captures.
  else
    echo "The total number of different captures (either different topic or differnt date) is ${numlines}."
    echo "The following is the summary for the data of the last 5 different captures:"
    echo -n "Top-20-words" > summary.txt
    echo " Summary" >> summary.txt
    echo "Words Frequency" >> summary.txt
    echo "------- ------" >> summary.txt
    foreach message (`tail -n 5 reportfilename.txt`)
      sed -n '4,$p' "$message" | tr -d '[:punct:]' | tr -d '[:digit:]' | tr ' ' '\n' | tr '[:upper:]' '[:lower:]' |sed '/^\s*$/d' >> combineword.txt
    end
    sort < combineword.txt | uniq -c | sort -n -r -k1 | awk '{print $2, $1}' > temp.txt

    foreach exclude (`cat excludingword.txt`)
    	sed -i "/^$exclude/d" temp.txt
    end
    # extract the top 20 words
    sed -n '1,20p' temp.txt >> summary.txt
    column -t summary.txt
    rm combineword.txt temp.txt
    sleep 2
    goto startover
  endif
endif

# let user look at the capture log file of all captures till now.
if ($option == 4) then
  set numlines = "`wc -l < logfile.txt`"
  if ($numlines < 4) then 
    echo "You haven't captured anything."
    sleep 2
    goto startover
  else
    column -t logfile.txt
    sleep 2
    goto startover
  endif
endif

# exit option
if ($option == 5) then
  exit
endif