#!/bin/bash

#
#  Created by Marc Griffith on 15/02/15.
#
#  take all the jpgs in the directory, and average the frames.  1st 3 2nd 3 etc. making new frames.
#
#  combine_frames.sh
#
#  rolling average is not really correct,  rolling window.
#  more like combine frames.
#
#
#
#    to do update to videotoolbox to use hardware accellerated encoding  eg..
#    
#  ffmpeg -r 30 -f image2 -start_number 9842 -i "frame_%08d.jpg" -codec:v prores_videotoolbox -profile:v 3 -pix_fmt uyvy422 out_vtbx_422HQ.mov
#  ffmpeg -r 30 -f image2 -start_number 9842 -i "frame_%08d.png" -codec:v prores_videotoolbox -pix_fmt yuva444p10le -profile:v 4444 out_vtbx_4444.mov
#
#
#  consider switching to tiff to preserve pixel format while transcoding.
#
#
#
#single line replacement for whole script.
#ffmpeg -i 20251221154633_cardo_mic_bogans_sandy_DJI_20251221154632_0012_D.MP4 -vf "tmix=frames=30,select='not(mod(n,30))',setpts=1/30*PTS" -c:v prores_videotoolbox -profile:v 3 -an averaged_30x_speed.mov

if (($# == 0)); then
  echo ""
  echo "usage"
  echo "   -m [file] run on a movie file"
  echo "   -i [extension] run on list of images eg JPG or jpg"
  echo "   -a average"
  echo "   -e enfuse"
  echo "   -d skip making of movie with ffmpeg (ffmpeg fails for images larger than 5000px)"
  echo "   -nX number of frames"
  echo "   -r do 6 extra recursive passes eg with n3 also do n 6 12 24 48 96 and 192 <<< experimental >>>"
  echo "   -cX override number of cores (default: all of them)"
  echo "   -fX override output framerate (default: 30fps)"
  echo ""
  echo "requires ffmpeg, enblend and ImageMagick installed (ffmpeg, enfuse, convert)"
  echo "     packages: ffmpeg, enfuse and imagemagick "
  echo ""
  exit 1
fi

##don t cleanup = 1

while getopts ":m:i:aedn:c:f:r" opt; do
    case $opt in
        m)
            echo "-m movie input : $OPTARG" >&2
            movie=$OPTARG
            ;;
        i)
            echo "-i images input : $OPTARG" >&2
            extension=$OPTARG
            ;;
        a)
            echo "-a average selected" >&2
            #echo "-a was triggered, Parameter: $OPTARG" >&2
            doaverage=1
            ;;
        e)
            echo "-e enfuse selected" >&2
            doenfuse=1
            ;;
        d)
            echo "-d do not make movie with ffmpeg" >&2
            donotdoffmpeg=1
            ;;

        n)
            echo "-n number of frames : $OPTARG" >&2
            number_of_frames=$OPTARG
            ;;
        r)
            echo "-r do 6 additional recursive steps" >&2
            dorecursive=1
            ;;

        c)
            echo "-c override number of cores : $OPTARG" >&2
            override_of_cores=$OPTARG
            ;;
        f)
            echo "-c override framerate : $OPTARG" >&2
            framerate=$OPTARG
            ;;
        e)
            echo "-e enfuse selected" >&2
            dontcleanup=1
            ;;

        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done


green='\033[0;32m' # '\e[1;32m' is too bright for white bg.
endColor='\033[0m'
red='\033[0;31m'
blue='\033[0;34;47m'

if [ -z "$override_of_cores" ]; then  #if cores has not been set
    CORES=$(sysctl -n hw.ncpu)
    printf "${green}Running on $CORES cores\n\n${endColor}"
else
    CORES=$override_of_cores
    printf "${green}Overridden to $CORES cores\n\n${endColor}"
fi


if [ -z "$doaverage" ]; then   #if doaverage has not been set
    if [ -z "$doenfuse" ]; then    #and if do enfuse has not been set
        printf "${red}Average or enfuse not set defaulting to averaging frames together.${endColor}\n"
        doaverage=1
    fi
fi

if [ -n "$doenfuse" ]; then
    printf "Enfusing frames together.\n\n"
fi

if [ -n "$doaverage" ]; then
    printf "Averaging frames together.\n\n"
fi




if [ -z "$number_of_frames" ]; then      #if number of frames has not been set
number_of_frames=2
printf "${red}Default setting: Combining $number_of_frames frames into one.${endColor}\n\n"
else
printf "${green}Combining $number_of_frames frames into one.${endColor}\n\n"
fi

#check combined_frames_output exists.
#if it does stop.
if [ -d "combine_frames_output" ]; then
    printf "${red}WARNING combine_frames_output directory already exists has this been run before?${endColor}\n\n"
fi


read -p "Please check options and press [Enter] to continue or ctrl-c to abort.."

#need to check if exists first

#rm input.txt
#cleanup.
#rm -r combine_frames_output

rm *frame*.txt

mkdir combine_frames_output
mkdir combine_frames_output/average
mkdir combine_frames_output/enfused

#list the jpgs. 




#again an optional argument
#need to account for jpg and other image formats..

if [ -z "$movie" ]; then  #if movie has not been set. (we are dealing with an image list.
    if [ -z "$extension" ]; then  #if the extension has not been set.
        printf "${red}Please enter the extension type of your image files, case sensitive without the .${endColor}\n"
        read extension
    fi
    if [ -z "$framerate" ]; then    #if framerate has not been set
        framerate=30
        printf "${green}Default framerate $framerate FPS\n\n${endColor}\n"
    else
        printf "${green}Video output set to $framerate FPS\n\n${endColor}\n"
    fi
else  #we have specified a movie file.
    #check moviefile exists


    if [ -z "$framerate" ]; then    #if framerate has not been set
        framerate=$(ffmpeg -i "$movie" 2>&1 | sed -n "s/.*, \(.*\) fp.*/\1/p")
        printf "${green}Read video input framerate as $framerate FPS\n\n${endColor}\n"
    else
        printf "${green}Video output set to $framerate FPS\n\n${endColor}\n"
    fi

    #do ffmpeg shit here. then set extension to jpg
    ffmpeg -i "$movie" -an -f image2 -qscale:v 2 ffmpeg_gen_%09d.jpg
    extension=jpg
fi



printf "${green}ls *.$extension > combine_frames_output/input.txt${endColor}\n"

#ls *.$extension > combine_frames_output/input.txt

#find DirsRoot/* -maxdepth 0 -type f #This does not show hidden files
#find -type f -name '*.txt'

rm combine_frames_output/input.txt

for f in *.$extension; do echo "$f" >> combine_frames_output/input.txt; done

fname="combine_frames_output/input.txt"


#x=0
#while [ $x -le $number_of_frames ]
#do

#  exec<$fname
#  value=0
#  while read line
#  do
#  if [ $(( $value % $number_of_frames )) -eq $x ] ; then
    
#     echo -e "$line" >> new_file$(($x+1)).txt
#     #rather should put this onto an array
#  fi
#  let value=value+1
#  done


#x=$(( $x + 1 ))
#done

#convert @myimages.txt mymovie.gif
#convert *.CR2 -average average.jpg
#convert @filelist.txt -average average.tif


#   video to jpg...
#   ffmpeg -i fire\ ants.mov -qscale:v 0 -an -f image2 "fire ants.mov_%05d.jpg"

#  jpg to video
#  ffmpeg -f image2 -start_number 1 -i "frame_average_%05d.JPG" -r 30 -codec:v prores -profile:v 3 blended.mov


#need to switch this around,

frame=1
x=0
exec<$fname
value=1
while read line
do
#check if not exist.

      if [ -n "$doaverage" ]; then
          echo -e \""$line"\" >> avg_frame$(($frame)).txt
      fi
      if [ -n "$doenfuse" ]; then
          echo -e "$line" >> enfuse_frame$(($frame)).txt
      fi

  if [ $(( $value % $number_of_frames )) -eq $x ] ; then
      let frame=frame+1
  fi
  let value=value+1
done

x=1
while [ $x -le $(($frame - 1)) ]
do
    #printf "${green}cat frame$(($x)).txt${endColor}\n"
    #cat frame$(($x)).txt
    #echo frame$(($x)).txt
    wait

    yy=1
while [ $yy -le $CORES ] && [ $x -le $(($frame - 1)) ]
    do
        echo frame:$frame:_:core:$yy
        if [ -n "$doaverage" ]; then
            printf "${green}Executing convert -average for avg_frame$x.txt${endColor}\n"
            cat avg_frame$(($x)).txt
            convert @avg_frame$x.txt -average combine_frames_output/average/frame_average_$(printf %06d $x).jpg &
            #convert -verbose
        fi
        if [ -n "$doenfuse" ]; then
            printf "${green}Executing enfuse with default args for enfuse_frame$x.txt${endColor}\n"
            cat enfuse_frame$(($x)).txt
            enfuse -d 16 --exposure-cutoff=0%:80% -o combine_frames_output/enfused/frame_enfused_$(printf "%06d\n" $x).png @enfuse_frame$x.txt &

# --saturation-weight=0 --exposure-weight=100  --contrast-weight=0 --exposure-cutoff=0%:100%
            #enfuse -v6  #version option
        fi
        x=$(( $x + 1 ))
        yy=$(( $yy+1 ))
    done
    #x=$(( $x + 1 ))
done

wait

if [ -n "$movie" ]; then

    #brutalcleanup=true
    echo "deleting ffmpeg_gen_*"
    for f in ffmpeg_gen_*.jpg; do rm $f; done
else
    movie="../${PWD##*/}"
fi

cd combine_frames_output
  if [ -z "$donotdoffmpeg" ]; then
    if [ -n "$doaverage" ]; then
        cd average
         #ffmpeg -r 60 -f image2 -start_number 1 -i frame_average_%06d.jpg -vf scale=1920:-1 -codec:v prores -profile:v 2 "../../${movie}_combined_$(($number_of_frames))_average_60fps_1920.mov"
        #ffmpeg -r $framerate -f image2 -start_number 1 -i frame_average_%06d.jpg -codec:v prores -profile:v 2 "../../${movie}_combined_$(($number_of_frames))_average_${framerate}fps.mov"

        ffmpeg -r $framerate -f image2 -start_number 1 -i frame_average_%06d.jpg -codec:v prores_ks -pix_fmt yuva444p10le -profile:v 4444 "../../${movie}_combined_$(($number_of_frames))_average_${framerate}fps_4444.mov"
        #open "../../${movie}_combined_$(($number_of_frames))_average_${framerate}fps_4444.mov"
        #say -vV "${number_of_frames} frame averaging complete, thank you for your patience."
        cd ..
    fi
    if [ -n "$doenfuse" ]; then
        cd enfused

        ffmpeg -r $framerate -f image2 -start_number 1 -i frame_enfused_%06d.png -vf scale=1920:-1 -codec:v prores -profile:v 2 "../../${movie}_combined_$(($number_of_frames))_enfused_60fps_1920.mov"
        #ffmpeg -r $framerate -f image2 -start_number 1 -i frame_enfused_%06d.jpg -codec:v prores -profile:v 2 "../../${movie}_combined_$(($number_of_frames))_enfused_${framerate}fps_442.mov"
        ffmpeg -r $framerate -f image2 -start_number 1 -i frame_enfused_%06d.png -codec:v prores_ks -pix_fmt yuva444p10le -profile:v 4444 "../../${movie}_combined_$(($number_of_frames))_enfused_${framerate}fps_4444.mov"
        #open "../../${movie}_combined_$(($number_of_frames))_enfused_${framerate}fps_4444.mov"
        #say -vV "${number_of_frames} frame enfusion complete, thank you for your patience."
        cd ..
    fi
  fi
cd ..

echo -e '\a'

#if [ -n "$dontcleanup"]; then
#   echo "not cleaning up"
#else

if [ -n "$brutalcleanup" ]; then
        echo "brutal cleanup"
        rm -r combine_frames_output
fi

#fi

#rm ffmpeg_gen_*.jpg
rm *frame*.txt


if [ -n "$dorecursive" ]; then
        unset dorecursive
        cd combine_frames_output

        actual_frames_multiplication=($number_of_frames)
        number_of_frames=2  #always multiplying by two

        if [ -n "$doaverage" ]; then

            actual_frames_multiplication=($actual_frames_multiplication*2)
            cd average
            combine_frames.sh -i jpg -a -n2 -f"${framerate}"
            pwd
            mv "../average_combined_$(($number_of_frames))_average_${framerate}fps_4444.mov" "../../${movie}_combined_$(($actual_frames_multiplication))_average_${framerate}fps_4444.mov"


            actual_frames_multiplication=($actual_frames_multiplication*2)
            cd combine_frames_output
            cd average
            combine_frames.sh -i jpg -a -n2 -f"${framerate}"
            mv "../average_combined_$(($number_of_frames))_average_${framerate}fps_4444.mov" "../../../../${movie}_combined_$(($actual_frames_multiplication))_average_${framerate}fps_4444.mov"


            actual_frames_multiplication=($actual_frames_multiplication*2)
            cd combine_frames_output
            cd average
            combine_frames.sh -i jpg -a -n2 -f"${framerate}"
            mv "../average_combined_$(($number_of_frames))_average_${framerate}fps_4444.mov" "../../../../../../${movie}_combined_$(($actual_frames_multiplication))_average_${framerate}fps_4444.mov"


            actual_frames_multiplication=($actual_frames_multiplication*2)
            cd combine_frames_output
            cd average
            combine_frames.sh -i jpg -a -n2 -f"${framerate}"
            mv "../average_combined_$(($number_of_frames))_average_${framerate}fps_4444.mov" "../../../../../../../../${movie}_combined_$(($actual_frames_multiplication))_average_${framerate}fps_4444.mov"


            actual_frames_multiplication=($actual_frames_multiplication*2)
            cd combine_frames_output
            cd average
            combine_frames.sh -i jpg -a -n2 -f"${framerate}"
            mv "../average_combined_$(($number_of_frames))_average_${framerate}fps_4444.mov" "../../../../../../../../../../${movie}_combined_$(($actual_frames_multiplication))_average_${framerate}fps_4444.mov"


            actual_frames_multiplication=($actual_frames_multiplication*2)
            cd combine_frames_output
            cd average
            combine_frames.sh -i jpg -a -n2 -f"${framerate}"
            mv "../average_combined_$(($number_of_frames))_average_${framerate}fps_4444.mov" "../../../../../../../../../../../../${movie}_combined_$(($actual_frames_multiplication))_average_${framerate}fps_4444.mov"


            pwd
            open "../../../../../../../../../../../.."

            say -v Vicki "Combine frames recursive is finished."

        fi

        if [ -n "$doenfuse" ]; then

            actual_frames_multiplication=($actual_frames_multiplication*2)
            cd enfused
            combine_frames.sh -i png -e -n2 -f"${framerate}"
            pwd
            mv "../enfused_combined_$(($number_of_frames))_enfused_${framerate}fps_4444.mov" "../../${movie}_combined_$(($actual_frames_multiplication))_enfused_${framerate}fps_4444.mov"

            actual_frames_multiplication=($actual_frames_multiplication*2)
            cd combine_frames_output
            cd enfused
            combine_frames.sh -i png -e -n2 -f"${framerate}"
            pwd
            mv "../enfused_combined_$(($number_of_frames))_enfused_${framerate}fps_4444.mov" "../../../../${movie}_combined_$(($actual_frames_multiplication))_enfused_${framerate}fps_4444.mov"

            actual_frames_multiplication=($actual_frames_multiplication*2)
            cd combine_frames_output
            cd enfused
            combine_frames.sh -i png -e -n2 -f"${framerate}"
            pwd
            mv "../enfused_combined_$(($number_of_frames))_enfused_${framerate}fps_4444.mov" "../../../../../../${movie}_combined_$(($actual_frames_multiplication))_enfused_${framerate}fps_4444.mov"

            actual_frames_multiplication=($actual_frames_multiplication*2)
            cd combine_frames_output
            cd enfused
            combine_frames.sh -i png -e -n2 -f"${framerate}"
            pwd
            mv "../enfused_combined_$(($number_of_frames))_enfused_${framerate}fps_4444.mov" "../../../../../../../../${movie}_combined_$(($actual_frames_multiplication))_enfused_${framerate}fps_4444.mov"

            actual_frames_multiplication=($actual_frames_multiplication*2)
            cd combine_frames_output
            cd enfused
            combine_frames.sh -i png -e -n2 -f"${framerate}"
            pwd
            mv "../enfused_combined_$(($number_of_frames))_enfused_${framerate}fps_4444.mov" "../../../../../../../../../../${movie}_combined_$(($actual_frames_multiplication))_enfused_${framerate}fps_4444.mov"

            actual_frames_multiplication=($actual_frames_multiplication*2)
            cd combine_frames_output
            cd enfused
            combine_frames.sh -i png -e -n2 -f"${framerate}"
            pwd
            mv "../enfused_combined_$(($number_of_frames))_enfused_${framerate}fps_4444.mov" "../../../../../../../../../../../../${movie}_combined_$(($actual_frames_multiplication))_enfused_${framerate}fps_4444.mov"

            pwd
            open "../../../../../../../../../../../.."

            say -v Fiona "Combine frames recursive is finished."

       fi
fi












