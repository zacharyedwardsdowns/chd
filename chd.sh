#!/bin/bash

###
### Handle any input errors.
###

# If $1 is null then echo error and exit.
if [ -z $1 ]; then

	echo "No directory provided."
	echo "Use 'chd help' for a usage guide."
	return

fi

# If $2 is not null then...
if [ ! -z $2 ]; then

	# If $1 is not add or delete then echo error and exit.
	if [ $1 != "add" ] && [ $1 != "delete" ]; then

        	echo "$1 is not a valid command."
		echo "Use 'chd help' to get a usage guide."
        	return
	
	fi

	# If $3 is null and $1 is add then echo error and exit.
	if [ -z $3 ] && [ $1 == "add" ]; then

		echo "No directory provided for add."
		echo "Use 'chd help' to get a usage guide."
		return

	fi

# If $2 is null then...
else

	# If $1 is add or delete then echo an error and exit.
	if [ $1 == "add" ] || [ $1 == "delete" ]; then

		echo "Ivalid use of the $1 command."
		echo "Use 'chd help' to get a usage guide."
		return

	fi

fi

# If $3 is not null then if it's not a directory then echo error and exit.
if [ ! -z $3 ]; then

	# If $1 is delete then echo an error and exit.
	if [ $1 == "delete" ]; then

		echo "Ivalid use of the $1 command."
		echo "Use 'chd help' to get a usage guide."
		return

	fi
		
	if [ ! -d $3 ]; then # If $3 is not a directory then echo error and exit.

		echo "'$3' is not a valid directory."
		echo "Use 'chd help' for a usage guide."
		return

	fi

fi

# If $4 is not null, the the command has been used completley wrong. Echo an error then exit.
if [ ! -z $4 ]; then

	echo "Ivalid use of the $1 command."
	echo "Use 'chd help' to get a usage guide."
	return

fi



###
### Handle valid inputs
###

clpath=$(type -a chd.sh) # Get the path of the chd command.

# Retrieve the path from type -a output.
for val in $clpath
do
	if [ $val != "chd" ] && [ $val != "is" ]; then

		clpath=$val

	fi
done

clpath=${clpath%.sh} # Remove .sh from the end of clpath.
list="list" # Define list with a value of list.
clpath="$clpath$list" # Concatenate $clpath and $list into clpath.

length=$(wc -l < $clpath) # Get the length of the directory list (chdlist).

# If the length of the directory list is 0 then echo error and exit if $1 is not add or help.
if [ $length == 0 ] && [ $1 != "add" ] && [ $1 != "help" ]; then

	echo "No directories set. See 'chd help' on how to add directories."
	return

# ElIf $1 is list then echo the supported directories.
elif [ $1 == "list" ]; then

	i=0 # Incrimentor variable

	echo "---------------------"
	echo "Supported Directories"
	echo "---------------------"

	for val in $(<$clpath) 	# Loop to display supported directories.
	do
		if ! (($i % 2)); then # If $i mod 2 is 0 then set direc to $val.

			direc="$val:" # Get the directory name when even.

		else # If $i mod 2 is 1 then echo $direc with $val.

			echo "$direc $val" # Echo directory name and location.

		fi

		i=$(($i + 1)) # Incriment i.
	done 

	echo "---------------------"

# Elif $1 is help then echo out a usage guide.
elif [ $1 == "help" ]; then

	echo "This command is used to shorten 'cd' to certain directories."
	echo "It is used by specifying a directory after chd: 'chd directory'"
	echo "A list of valid directories can be viewed with: 'chd list'"
	echo "Directories can be added with 'chd add name directory':"
	echo "chd add space ~/Documents/space"
	echo "Now 'chd space' will cd to the directory '~/Documents/space'"
	echo "Directories can be deleted with: 'chd delete name'"
	echo "chd delete space"

# Elif $1 is add then add the directroy to chdlist unless the directory name is already in use or
# the directory is already pointed to by another directory name. Unless specified by the user to add anyways.
elif [ $1 == "add" ]; then

	i=0 # Incrimentor variable.

	for val in $(<$clpath) 	# Loop to search for existing directories.
	do
		if ! (($i % 2)); then # If the mod of $i is 0 then...

			if [ $2 == $val ]; then # If $2 is equal to $val output error then exit.

				echo "$2 is already in use as a directory name."
				echo "Use a different name for the directory: '$3'"
				return

			fi

			tmp=$val # Store $val in tmp for error usage.

		else # If the mod of $i is 1 then...

			if [ $3 == $val ]; then # If $3 is equal to $val then ask user for input on whether to add anyways.

				echo "'$3' is already listed under the directory name: $tmp."
				read -p "Would you like to have it under both names? (Y/N): " response

				if [ ${response,,} != "y" ] && [ ${response,,} != "yes" ]; then # If the user doesn't respond 'y' or 'yes' then exit.


					echo "'$3' not created under the name $2."
					return

				fi

			fi

		fi

		i=$(($i + 1)) # Incriment i.
	done 

	stordir="$2 $3" # Seperate the directory name and location by a space.

	echo $stordir >> $clpath # Store them into chdlist.

	echo "You may now use 'chd $2' to cd to '$3'" # Notifty the user that the directory has been adeded. 

# Elif $1 is delete then delete the specified directory from chdlist if it exists.
elif [ $1 == "delete" ]; then

	i=0 # Incrimtentor variable.
	found=false # Used to tell if the specified directory was found.

	cldpath=${clpath%chdlist} # Remove chdlist from the end of clpath and store in cldpath.
	cldel="cldel" # Define cldel with a value of cldel.
	cldpath="$cldpath$cldel" # Concatenate $cldel to the end of $cldpath.

	for val in $(<$clpath) 	# Loop for directory to delete.
	do
		# If a found is true and $val is a directory name set found to false.
		if $found && ! (($i % 2)); then

			found=false

		fi

		# If $val is $2 then set found to true.
		if [ $val == $2 ]; then

			found=true

		fi

		# If found is false and $val is a directory name set last to $val.
		if ! (($i % 2)) && ! $found; then

			last=$val

		# If $val is a directory location and found is false then echo $last and $val to cldel.
		elif ! $found; then

			echo "$last $val"

		fi

		i=$(($i + 1)) # Incriment i.
	done <$clpath> $cldpath # Output echo statements to cldel.

	# If the length of chdlist is the same as cldel then directory name $2 doesn't exist. Remove cldel.
	if [ $length == $(wc -l < $cldpath) ];then

		echo "$2 is not a directory name. Nothing deleted."
		rm $cldpath

	# Else the specified directory name and directory location were removed. Make cldel into chdlist.
	else

		echo "$2 was removed from supported directories."
		mv $cldpath $clpath

	fi

# Else attempt to change directories if $1 is a directory name in chdlist.
else

	found=false # Use to tell if directory exists.

	for val in $(<$clpath) 	# Loop to search for the directory.
	do
		if [ $val == $1 ]; then # If directory found then set found to true and loop one more time to get the directory location.

			found=true

		elif $found; then # If directory found then...

			val="cd $val" # Add 'cd ' infront of $val.
			eval $val # Evaluate $val without any quotes. (This changes to the specified directory.)
			break # Break the loop.

		fi
	done 

	# If the directory was not found then echo error and exit.
	if ! $found; then

		echo "$1 is not a supported directory. See directories with 'chd list'."
		return

	fi

fi