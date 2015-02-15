########################################################################################################
# setup multiple site
########################################################################################################

multi_tunnel() {
	NODE=$1
	SRC01=$2
	DST01=$3
	SRC02=$4
	DST02=$5

	print_title_small " - Start multi tunnel at $NODE"
	ssh $NODE "$CAP_HOME/start_multi.sh \
			$(get_IP $SRC01) $(get_IP $DST01) \
			$(get_IP $SRC02) $(get_IP $DST02)" &> $MNG_ROOT/logs/$NODE.log &
	sleep 3
}

single_tunnel() {
	NODE=$1
	SRC=$2
	DST=$3

	print_title_small " - Start single tunnel at $NODE"
	ssh $NODE "$CAP_HOME/start_single.sh $(get_PRIV_IFNAME $NODE) \
			$(get_IP $SRC) $(get_IP $DST)" &> $MNG_ROOT/logs/$NODE.log &
	sleep 3
}

check() {
	sleep 10
	$MNG_ROOT/process.sh
	
	#$MNG_ROOT/ping-e2e.sh 1
}

one_to_multi() {
	TE1=$1
	TE2=$2
	TE3=$3
	TE12_DATA=$4
	TE2_DATA=$5
	TE13_DATA=$6
	TE3_DATA=$7

	print_title " - ($TE1) === ($TE2, $TE3)"
	multi_tunnel $TE1 $TE12_DATA $TE2_DATA $TE13_DATA $TE3_DATA
 	single_tunnel $TE2 $TE2_DATA $TE12_DATA
 	single_tunnel $TE3 $TE3_DATA $TE13_DATA
	

	echo $TE1 >> $CAP_CFG
	echo $TE2 >> $CAP_CFG
	echo $TE3 >> $CAP_CFG
}

one_to_multi_bidir() {
	TE1=$1
	TE2=$2
	TE3=$3
	TE12_DATA=$4
	TE2_DATA=$5
	TE13_DATA=$6
	TE3_DATA=$7

	print_title " - ($TE1) === ($TE2, $TE3)"
	multi_tunnel $TE1 $TE12_DATA $TE2_DATA $TE13_DATA $TE3_DATA
 	single_tunnel $TE2 $TE2_DATA $TE12_DATA

	echo $TE1 >> $CAP_CFG
	echo $TE2 >> $CAP_CFG
}

one_to_one() {
	TE1=$1
	TE2=$2
	TE1_DATA=$3
	TE2_DATA=$4

	print_title " - $TE1 --- $TE2"
	single_tunnel $TE1 $TE1_DATA $TE2_DATA
 	single_tunnel $TE2 $TE2_DATA $TE1_DATA	

	echo $TE1 >> $CAP_CFG
	echo $TE2 >> $CAP_CFG
}

gist01_to_khu() {
	one_to_one 'cap01.gist' 'cap01.khu' 'cap01.gist.koren01' 'cap01.khu.koren'
}

gist01_to_cnu() {
	one_to_one 'cap01.gist' 'cap01.cnu' 'cap01.gist.koren01' 'cap01.cnu.koren'
}

gist01_to_postech() {
	one_to_one 'cap01.gist' 'cap01.postech' 'cap01.gist.koren01' 'cap01.postech.koren'
}

gist02_to_khu() {
	one_to_one 'cap02.gist' 'cap01.khu' 'cap02.gist.koren' 'cap01.khu.koren'
}

gist02_to_cnu() {
	one_to_one 'cap02.gist' 'cap01.cnu' 'cap02.gist.koren' 'cap01.cnu.koren'
}

gist02_to_postech() {
	one_to_one 'cap02.gist' 'cap01.postech' 'cap02.gist.koren' 'cap01.postech.koren'
}

gist03_to_cnu() {
	one_to_one 'nf04.gist' 'cap01.cnu' 'nf04.gist.koren01' 'cap01.cnu.koren'
}

connect_singles() {
	gist01_to_cnu
	gist02_to_khu

	cp $CAP_CFG $CAP_CFG_BAK

	echo "end01.gist end01.cnu end01.khu" >> $END_CFG

	check
}

connect_PK() {
	gist01_to_postech
	gist02_to_khu

	cp $CAP_CFG $CAP_CFG_BAK

	echo "end01.gist end01.postech end01.khu" >> $END_CFG

	check
}

connect() {
#	one_to_multi 'cap01.gist' 'cap01.postech' 'cap01.cnu' \
#					'cap01.gist.koren01' 'cap01.postech.koren' \
#					'cap01.gist.koren02' 'cap01.cnu.koren'
#	one_to_one 'cap02.gist' 'cap01.khu' \
#				 'cap02.gist.koren' 'cap01.khu.koren'
	one_to_multi_bidir 'cap01.gist' 'cap01.postech' 'cap02.gist' \
					'cap01.gist.koren01' 'cap01.postech.koren' \
					'cap01.gist.koren02' 'cap02.gist.koren'
#	one_to_multi 'cap01.gist' 'cap01.postech' 'cap02.gist' \
#					'cap01.gist.koren01' 'cap01.postech.koren' \
#					'cap01.gist.koren02' 'cap02.gist.koren02'
#	one_to_multi_bidir 'cap02.gist' 'cap01.khu' 'cap01.gist' \
#				 	'cap02.gist.koren02' 'cap01.khu.koren' \
#					'cap02.gist.koren' 'cap01.gist.koren02'
	one_to_one 'cap02.gist' 'cap01.khu' \
				 'cap02.gist.koren' 'cap01.khu.koren'
	
	cp $CAP_CFG $CAP_CFG_BAK

#	echo "end01.gist end01.cnu end01.postech end01.khu" > $END_CFG
	echo "end01.gist end01.postech end01.khu" > $END_CFG

	check
}

connect_beta() {
	one_to_multi 'cap01.gist' 'cap01.postech' 'cap01.cnu' \
					'cap01.gist.koren01' 'cap01.postech.koren' \
					'cap01.gist.koren02' 'cap01.cnu.koren'
	one_to_one 'cap02.gist' 'cap01.khu' \
				 'cap02.gist.koren' 'cap01.khu.koren'
	
	cp $CAP_CFG $CAP_CFG_BAK

	echo "end01.gist end01.cnu end01.postech end01.khu" > $END_CFG

	check
}

connect_beta_gist01() {
	one_to_multi 'cap01.gist' 'cap01.postech' 'cap01.cnu' \
					'cap01.gist.koren01' 'cap01.postech.koren' \
					'cap01.gist.koren02' 'cap01.cnu.koren'
	
	cp $CAP_CFG $CAP_CFG_BAK

	echo "end01.gist end01.cnu end01.postech" > $END_CFG

	check
}

connect_beta_gist02() {
	one_to_one 'cap02.gist' 'cap01.khu' \
				 'cap02.gist.koren' 'cap01.khu.koren'
	
	cp $CAP_CFG $CAP_CFG_BAK

	echo "end01.gist end01.khu" > $END_CFG

	check
}

connect_loop_in_gist() {
#	one_to_multi 'cap01.gist' 'cap01.postech' 'cap02.gist' \
#					'cap01.gist.koren01' 'cap01.postech.koren' \
#					'cap01.gist.koren02' 'cap02.gist.koren02'
	one_to_multi 'cap02.gist' 'cap01.khu' 'cap01.gist' \
				 	'cap02.gist.koren' 'cap01.khu.koren' \
					'cap02.gist.koren02' 'cap01.gist.koren02'

	one_to_one 'cap01.gist' 'cap01.postech' \
				 	'cap01.gist.koren01' 'cap01.postech.koren'
	

	cp $CAP_CFG $CAP_CFG_BAK

	echo "end01.gist end01.postech end01.khu" > $END_CFG

#	check
}


get_endlist() {
	ARG=$1

	declare -A endlist

	endlist["gist01_to_cnu"]="end01.gist end01.cnu"	
	endlist["gist01_to_postech"]="end01.gist end01.postech"	
	endlist["gist01_to_khu"]="end01.gist end01.khu"

	endlist["gist02_to_cnu"]="end01.gist end01.cnu"	
	endlist["gist02_to_postech"]="end01.gist end01.postech"	
	endlist["gist02_to_khu"]="end01.gist end01.khu"
	
	echo ${endlist[$ARG]}
}

unit_test() {
	UNIT=$1

	eval $UNIT

	endlist=$(get_endlist $UNIT)
	echo $endlist >> $END_CFG

	#gist01_to_cnu
	#echo "end01.gist end01.cnu" >> $END_CFG

	#gist01_to_postech
	#echo "end01.gist end01.postech" >> $END_CFG

	#gist01_to_khu
	#echo "end01.gist end01.khu" >> $END_CFG

	#gist02_to_cnu
	#echo "end01.gist end01.cnu" >> $END_CFG

	#gist02_to_postech
	#echo "end01.gist end01.postech" >> $END_CFG

	#gist02_to_khu
	#echo "end01.gist end01.khu" >> $END_CFG
	
	#one_to_multi 'cap01.gist' 'cap01.postech' 'cap01.cnu' \
	#				'cap01.gist.koren01' 'cap01.postech.koren' \
	#				'cap01.gist.koren02' 'cap01.cnu.koren'
	#echo "end01.gist end01.cnu end01.postech" > $END_CFG

	cp $CAP_CFG $CAP_CFG_BAK
	
	check
}

stop_capsulator() {
	$MNG_ROOT/stop.sh
}
