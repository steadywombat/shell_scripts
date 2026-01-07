# shell_scripts
# 🎬 Steady Wombat Video Production Shell Scripts

A collection of shell scripts for assisting with my video workflows on macOS.

---
### videopre.sh
The first part of my workflow involves putting all source files, usally videos and audio clips into a directory.
I then run videopre.sh to prepend them with meaningful dates and add a meaningful description on each file.
I use the same script to organise my images as well.

```bash
videopre.sh chopping_logs
```
folder name becomes:
```bash
20230325_chopping_logs
```
and the files..
```bash
20230325153613_chopping_logs_IMG_0566.MOV
20230325153752_chopping_logs_IMG_0567.MOV
```

with the DateGroup makes it easy to sort files from multiple cameras or devices and makes each file unique.
I'd rather organise my files in the filesystem first before I import it into any software. Apple Aperture went bust and was a real shit to sort my files again.




---
### ai_transcribe.sh
Next step in the project I run ai_transcribe.sh to get an idea of what was said.
Although this can be run at any time. It doesnt rename any files just creates some temporary wavs and final output is in one text file.

It scans each video and audio file in a directory with an ai model and creates a single text file with all engish it can decode along with simple sounds etc.
I use it on a directory of files so I can assess how much voice over I need to make and what topic the video might be on.
currently just MOV,MP4 and WAV files but can be easily changed.

```plaintext
--- FILE: 20251122125335_action5_DJI_20251122125335_0018_D.MP4 ---

[00:00:00.000 --> 00:00:07.000]   That's a little key.
[00:00:30.000 --> 00:00:40.000]   [SOUND]
[00:01:00.000 --> 00:01:10.000]   [BLANK_AUDIO]
[00:01:30.000 --> 00:01:40.000]   [BLANK_AUDIO]
[00:02:00.000 --> 00:02:05.000]   [SOUND]
[00:02:05.000 --> 00:02:12.000]   All righty-o, I've done a lot of changes, first ride with all these changes.
[00:02:12.000 --> 00:02:15.000]   [BLANK_AUDIO]
[00:02:15.000 --> 00:02:17.000]   I've had a little rider in the backyard.
[00:02:17.000 --> 00:02:19.000]   [BLANK_AUDIO]
[00:02:19.000 --> 00:02:22.000]   Just to make sure the tire pressure monitoring was going.
[00:02:22.000 --> 00:02:25.000]   [BLANK_AUDIO]
[00:02:25.000 --> 00:02:27.000]   So it's just a night to self.
[00:02:27.000 --> 00:02:30.000]   How's it rain?
[00:02:30.000 --> 00:02:33.000]   [BLANK_AUDIO]
[00:02:33.000 --> 00:02:36.000]   That totally blue sky and it's raining.
[00:02:36.000 --> 00:02:48.000]   [BLANK_AUDIO]
[00:02:48.000 --> 00:02:50.000]   We are, Rod.
[00:02:50.000 --> 00:02:55.000]   [BLANK_AUDIO]
[00:02:55.000 --> 00:03:03.000]   Let's see how this phone works in the full sun, hey?
[00:03:03.000 --> 00:03:06.000]   [BLANK_AUDIO]
[00:03:06.000 --> 00:03:09.000]   Lots of new goodies.
[00:03:09.000 --> 00:03:19.000]   [BLANK_AUDIO]
[00:03:19.000 --> 00:03:21.000]   Okay, picture it down.
[00:03:21.000 --> 00:03:29.000]   [BLANK_AUDIO]
[00:03:29.000 --> 00:03:30.000]   Yeah, probably won't.
[00:03:30.000 --> 00:03:37.000]   [BLANK_AUDIO]
[00:03:37.000 --> 00:03:40.000]   That camera's wobbling a crazy.


--- FILE: 20251122131139_action5_DJI_20251122131139_0019_D.MP4 ---

[00:01:53.680 --> 00:01:56.180]   (tense music)
[00:02:23.680 --> 00:02:26.440]   (engine revving)
[00:02:53.680 --> 00:02:56.420]   (engine revving)
[00:03:23.680 --> 00:03:26.420]   (engine revving)
[00:03:53.680 --> 00:03:56.440]   (engine revving)
[00:03:56.440 --> 00:04:21.920]   Yeah, run in field.
[00:04:21.920 --> 00:04:22.760]   We ate.
[00:04:24.040 --> 00:04:27.040]   - I'm gonna run. - I'm gonna run.
```

---
### prepend_dates_on_folders.sh
similar to videopre.sh but used when i have multiple folders with descriptive names and clips inside them. it scans through for the first video in each folder gets its date then prepends it to the folder name. 

---


I used these scripts to make one of my latest videos:
<https://www.youtube.com/watch?v=Kds9Z_a3eXs>



## 🚀 Quick Start (after you read all that above)
To use these scripts, ensure you have **FFmpeg** installed via Homebrew and make the scripts executable:
```bash
brew install ffmpeg
chmod +x *.sh
```

Thanks for reading, keep your wombat steady. :)

