#!/bin/bash

students_file="student_srn.txt"
audio_cache_dir="./student_srn_audio_cache"

if [ ! -f "$students_file" ]; then
	echo "Error: $students_file not found!"
	exit 1
fi

mkdir -p "$audio_cache_dir"

file_contents=$(cat "$students_file")

IFS=',' read -ra students <<<"$file_contents"

generate_audio() {
	student_id="$1"
	roll_number="${student_id##* }"
	srn="${roll_number: -3}"
	# echo "SRN: $srn"
	audio_file="${audio_cache_dir}/${srn}.mp3"

	if [ ! -f "$audio_file" ]; then
		python3 - <<END
from gtts import gTTS
import os

tts = gTTS("$srn", lang='en')
tts.save("$audio_file")
END
		echo "Generated audio for $roll_number"
	else
		echo "Using cached audio for $roll_number"
	fi
}

speak_student() {
	student_id="$1"
	roll_number="${student_id##* }"
	srn="${roll_number: -3}"
	audio_file="${audio_cache_dir}/${srn}.mp3"
	echo "Reading $roll_number"
	mpg123 -q "$audio_file"
}

for student in "${students[@]}"; do
	generate_audio "$student"
done

for student in "${students[@]}"; do
	speak_student "$student"
	for i in {1..2}; do
		echo "tick tick $i"
		sleep 1
	done
done
