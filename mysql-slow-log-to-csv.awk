#!/usr/bin/awk
#
# parse mysql slow queries log into csv output
#
# Author: Brent Ashley <bashley@controlcase.com>
#
BEGIN{
        id = 1
	line = ""
        cmd = ""
	
	# header
	print "id,datetime,query_time,lock_time,rows_sent,rows_examined,insert,command" 
}

# does not start with #, collect lines into cmd
/^[^#]/{
        cmd = cmd " " $0
}

# Time line denotes new entry
/^# Time: /{
	# print previous entry 
	if(line != "") {
		# is it an insert command?
		if(index(cmd,"INSERT INTO") != 0){
			ins = 1
		} else {
			ins = 0
		}

		# complete and output line
        	line = line "," ins ",\"" cmd "\""
		print line
		
		# show progress on stderr
		if((id % 1000) == 0){
			print id > "/dev/stderr"
		}
	}	

	# parse date and time
	dt = $3
	yyyy = "20" substr(dt,1,2)
	mm = substr(dt,3,2)
	dd = substr(dt,5,2)
        split($4,tm,":")
	h = tm[1]
	m = tm[2]
	s = tm[3]
	if(length(h) == 1){
		h = "0" h
	}
	datetime = yyyy "-" mm "-" dd "T" h ":" m ":" s ".000Z"
	line = id++ "," datetime
}

/^# Query_/{
	# parse metrics
        line = line "," $3 "," $5 "," $7 "," $9
	# initialize cmd
	cmd = ""
}

END{	
	# print last entry 
	if(line != "") {
		# is it an insert command?
		if(index(cmd,"INSERT INTO") != 0){
			ins = 1
		} else {
			ins = 0
		}

		# complete and output line
        	line = line "," ins ",\"" cmd "\""
		print line
	}	
}

