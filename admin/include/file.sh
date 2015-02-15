get_line() {
	SEARCH_FILE=$1
	SEARCH_STR=$2

	sed -n '{/'$SEARCH_STR'/ { =;} }' $SEARCH_FILE
}

comment_a_line() {
	SEARCH_FILE=$1
	LINE_NO=$2

	echo "comment a line= $LINE_NO"
	sed -i ''$LINE_NO' s/^/#/' $SEARCH_FILE
}

insert_a_line() {
	SEARCH_FILE=$1
	SEARCH_STR=$2
	LINE_TO_ADD=$3

	echo "insert line= $LINE_TO_ADD"
	sed -i '/'$SEARCH_STR'/a '$LINE_TO_ADD'' $SEARCH_FILE
}

comment_and_insert_a_line() {
	SEARCH_FILE=$1
	SEARCH_STR=$2
	LINE_TO_ADD=$3

	MATCH_LINE=$(get_line $SEARCH_FILE ^$SEARCH_STR)
	comment_a_line $SEARCH_FILE $MATCH_LINE 
	insert_a_line $SEARCH_FILE ^#$SEARCH_STR $LINE_TO_ADD
}

