#!/bin/bash

students_file="student_names.txt"
audio_cache_dir="./student_audio_cache"

if [ ! -f "$students_file" ]; then
	echo "Error: $students_file not found!"
	exit 1
fi

mkdir -p "$audio_cache_dir"

IFS=',' read -r -a students <"$students_file"

generate_audio() {
	student_name="$1"
	audio_file="${audio_cache_dir}/${student_name// /_}.mp3"

	if [ ! -f "$audio_file" ]; then
		python3 - <<END
from gtts import gTTS
import os

tts = gTTS("$student_name", lang='en', tld='co.in')
tts.save("$audio_file")
END
		echo "Generated audio for $student_name"
	else
		echo "Using cached audio for $student_name"
	fi
}

speak_student() {
	student_name="$1"
	echo "Reading $student_name"
	audio_file="${audio_cache_dir}/${student_name// /_}.mp3"
	mpg123 -q "$audio_file"
}

for student in "${students[@]}"; do
	generate_audio "$student"
done

for student in "${students[@]}"; do
	speak_student "$student"
	for i in {1..2}; do
		echo "$i"
		sleep 1
	done
done
