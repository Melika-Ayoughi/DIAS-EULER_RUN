#!/bin/bash
EXP_NAME="delayExperiment"
MAIN_PATH="/cluster/project/gess/coss/projects/DIASexperiments/SIMULATION/melika"
START=211
END=217
SRC_ADDR="/cluster/project/gess/coss/projects/DIASexperiments/SIMULATION"
POSS_ADR="/cluster/project/gess/coss/projects/DIASexperiments/SIMULATION/all_possible_states/PossibleStates/dias/possibleStates"
TRAN_ADR="/cluster/project/gess/coss/projects/DIASexperiments/SIMULATION/all_transmissions/Transmissions/dias/transitions"
CONF_ADR="$SRC_ADDR"/"$EXP_NAME"/conf
LIB_ADR="$SRC_ADDR"/"$EXP_NAME"/lib
module load java/1.8.0_91
cd "$MAIN_PATH"
for (( i=$START; i<=$END; i++ ));
do
   echo "day: $i"
   mkdir -p "$MAIN_PATH"/"$EXP_NAME"/"day$i"
   xargs -I, mkdir -p "$MAIN_PATH"/"$EXP_NAME"/"day$i"/, <list.txt
   cd "$MAIN_PATH"/"$EXP_NAME"/"day$i"/
   for d in ./*/;
   do
   		cd "$d"
   		mkdir -p possibleStates/
   		mkdir -p transitions/
   		pwd
   		HERE=$(pwd)
   		CUR_FOLDER=${PWD##*/}
   		LAST_CHAR=$(sed -e "s/^.*\(.\)$/\1/" <<< $CUR_FOLDER)
   		#linking possible states
   		ln -sf "$POSS_ADR"/"day$i" "$HERE"/possibleStates/
   		#linking transitions
   		ln -sf "$TRAN_ADR"/"day$i" "$HERE"/transitions/
   		#linking conf
   		ln -sf "$CONF_ADR" "$HERE"/
   		#linking lib
   		ln -sf "$LIB_ADR" "$HERE"/
   		#linking dias.jar
   		ln -sf "$SRC_ADDR"/"$EXP_NAME"/"$CUR_FOLDER"/"dias$LAST_CHAR.jar" "$HERE"/
   		#run dias.jar
   		#-B send email to job owner when BEGINS
   		#-N send email to job owner when ENDS
   		bsub -J "$EXP_NAME:day$i:$CUR_FOLDER" -B -N -o of.txt -W 24:00 -R "rusage[mem=90000]" java -Xmx45g -jar "dias$LAST_CHAR.jar" -name "day$i" -N 3000 -runDuration 800 -numOfSessions 40
   		cd "$MAIN_PATH"/"$EXP_NAME"/"day$i"/
   done
   cd "$MAIN_PATH"
done