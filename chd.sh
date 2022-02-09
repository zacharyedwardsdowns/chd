#!/bin/bash

###
### Handle any input errors.
###

command=$1
name=$2
directory=$3
invalid=$4

# If $command is null then echo error and exit.
if [ -z "$command" ]; then

	echo "No command provided."
	echo "Use 'chd help' for a usage guide."
	return

fi

# If $name is not null then...
if [ ! -z "$name" ]; then

	# If $command is not add or delete then echo error and exit.
	if [ "$command" != "add" ] && [ "$command" != "delete" ]; then

		echo "$command is not a valid command."
		echo "Use 'chd help' to get a usage guide."
		return

	fi

	# If $directory is null and $command is add then set $directory as '.' to add the current director
	if [ -z "$directory" ] && [ "$command" == "add" ]; then

		directory="$PWD"

	fi

	# Not allowed to use 'help', 'list', 'add', or 'delete' as directory names in the add or delete commands.
	if [ "$name" == "help" ] || [ "$name" == "list" ] || [ "$name" == "add" ] || [ "$name" == "delete" ]; then

		echo "'$name' is a command. You are not allowed to use it as a directory name."
		return

	fi

	# Prevent directory names containing a '/' from being added.
	if [[ "$name" == *[/]* ]]; then

		echo "'$name' is an invalid directory name. Cannot contain a '/'."
		return

	fi

# If $name is null then...
else

	# If $command is add or delete then echo an error and exit.
	if [ "$command" == "add" ] || [ "$command" == "delete" ]; then

		echo "Invalid use of the $command command."
		echo "Use 'chd help' to get a usage guide."
		return

	fi

fi

# If $directory is not null then if it's not a directory then echo error and exit.
if [ ! -z "$directory" ]; then

	# If $command is delete then echo an error and exit.
	if [ "$command" == "delete" ]; then

		echo "Invalid use of the $command command."
		echo "Use 'chd help' to get a usage guide."
		return

	fi

	tmp=$(readlink --canonicalize "$directory") # Get the absolute path of directory location $directory.

	if [ ! -d "$tmp" ]; then # If $directory is not a directory then echo error and exit.

		echo "'$directory' is not a valid directory."
		echo "Use 'chd help' for a usage guide."
		return

	elif [[ "$tmp" == *"fCQjEH88ToiQgUnbkMJs-kZamcppqThoNlD92iXpa"* ]]; then # If the pattern used to replace spaces is found in the directory name tell them it's time to stop.

		echo "Nice try but 'fCQjEH88ToiQgUnbkMJs-kZamcppqThoNlD92iXpa' is not allowed in directory names.'"
		return

	fi

fi

# If $invalid is not null, the the command has been used completely wrong. Echo an error then exit.
if [ ! -z $invalid ]; then

	echo "Invalid use of the $command command."
	echo "Use 'chd help' to get a usage guide."
	return

fi

###
### Handle valid inputs
###

# Function to replace spaces with a long random string.
remove_spaces() {
	dirspace=$(echo "$command" | sed 's/ /fCQjEH88ToiQgUnbkMJs-kZamcppqThoNlD92iXpa/g')
}

# Function to put spaces back into long random string.
input_spaces() {
	dirspace=$(echo "$command" | sed 's/fCQjEH88ToiQgUnbkMJs-kZamcppqThoNlD92iXpa/ /g')
}

clpath="$(dirname "${BASH_SOURCE[0]}")" # Get the path of the chd command.
list="/chdlist"                         # Define list with the name of the list file.
clpath="$clpath$list"                   # Concatenate $clpath and $list into clpath.

# If chdlist is not found then create it!
if [ ! -f $clpath ]; then

	touch ${clpath}

fi

length=$(wc -l <$clpath) # Get the length of the directory list (chdlist).

# If the length of the directory list is 0 then echo error and exit if $command is not add or help.
if [ $length == 0 ] && [ "$command" != "add" ] && [ "$command" != "help" ]; then

	echo "No directories set. See 'chd help' on how to add directories."
	return

# ElIf $command is list then echo the supported directories.
elif [ "$command" == "list" ]; then

	i=0        # Incrementor variable.
	notsupp=() # Array for storing no longer valid directories.

	echo "---------------------"
	echo "Supported Directories"
	echo "---------------------"

	# Loop to display supported directories.
	for val in $(<$clpath); do
		if ! (($i % 2)); then # If $i mod 2 is 0 then set direc to $val.

			direc="$val:" # Get the directory name when even.

		else # If $i mod 2 is 1 then echo $direc with $val.

			if [[ $val == *"fCQjEH88ToiQgUnbkMJs-kZamcppqThoNlD92iXpa"* ]]; then # If val contains pattern then replace it with spaces.

				input_spaces "$val"
				val="$dirspace"

			fi

			if [ ! -d "$val" ]; then # If val is no longer a directory then append the directory name and location to notsupp.

				notsupp+=("$direc") # Append directory name.
				notsupp+=("$val")   # Append directory location.

			else

				echo "$direc $val" # Echo directory name and location.

			fi

		fi

		i=$(($i + 1)) # Increment i.
	done

	echo "---------------------"

	# If any no longer valid directories were found then echo them.
	if [ ${#notsupp[@]} -ne 0 ]; then

		i=0 # Reset $i to 0 for incrementing.

		echo ""
		echo "---------------------"
		echo " Invalid Directories "
		echo "---------------------"

		for notvalid in "${notsupp[@]}"; do # Iterate through notsupp and echo invalid directories.
			if ! (($i % 2)); then              # If $i mod 2 is 0 then store $notvalid into $direc.

				direc=$notvalid

			else # If $i mod 2 is 1 then echo $direc with $val as invalid directories.

				echo "$direc $notvalid" # Echo directory name and location.

			fi

			i=$(($i + 1)) # Increment i.
		done

		echo ""
		echo "Remove them with 'chd delete'"
		echo "---------------------"

	fi

# Elif $command is help then echo out a usage guide.
elif [ "$command" == "help" ]; then

	echo "--------------------------------------------------------------------------------------------
'chd name'			To change to a directory linked by a name.
'chd list'			To list supported directories and their linked name(s).
'chd help'			To view the usage guide you are seeing right now.
'chd add name directory'	To add support for a directory with a name.
'chd delete name'		To delete support for a directory using a name.
'sh chduninstall'		To remove chd from your system at anytime.
--------------------------------------------------------------------------------------------"

# Elif $command is add then add the directory to chdlist unless the directory name is already in use or
# the directory is already pointed to by another directory name. Unless specified by the user to add anyways.
elif [ "$command" == "add" ]; then

	i=0 # Incrementor variable.

	abspath=$(readlink --canonicalize "$directory") # Get the absolute path of directory location $directory.

	# Loop to search for existing directories.
	for val in $(<$clpath); do
		if ! (($i % 2)); then # If the mod of $i is 0 then...

			if [ $name == $val ]; then # If $name is equal to $val output error then exit.

				echo "$name is already in use as a directory name."
				echo "Use a different name for the directory: '$abspath'"
				return

			fi

			tmp=$val # Store $val in tmp for error usage.

		else # If the mod of $i is 1 then...

			if [[ $val == *"fCQjEH88ToiQgUnbkMJs-kZamcppqThoNlD92iXpa"* ]]; then # If val contains pattern then replace it with spaces.

				input_spaces "$val"
				val="$dirspace"

			fi

			if [ "$abspath" == "$val" ]; then # If $abspath is equal to $val then ask user for input on whether to add anyways.

				echo "'$abspath' is already listed under the directory name: $tmp."
				read -p "Would you like to have it under both names? (Y/N): " response

				if [ ${response,,} != "y" ] && [ ${response,,} != "yes" ]; then # If the user doesn't respond 'y' or 'yes' then exit.

					echo "'$abspath' not created under the name $name."
					return

				fi

			fi

		fi

		i=$(($i + 1)) # Increment i.
	done

	tmp="$abspath"

	if [[ "$abspath" == *" "* ]]; then # If val contains space(s) then replace it with pattern.

		remove_spaces "$abspath"
		abspath="$dirspace"

	fi

	stordir="$name $abspath" # Separate the directory name and location by a space.

	echo "$stordir" >>$clpath # Store them into chdlist.

	echo "You may now use 'chd $name' to cd to '$tmp'" # Notify the user that the directory has been added.

# Elif $command is delete then delete the specified directory from chdlist if it exists.
elif [ "$command" == "delete" ]; then

	i=0         # Incrementor variable.
	found=false # Used to tell if the specified directory was found.

	cldpath=${clpath%chdlist} # Remove chdlist from the end of clpath and store in cldpath.
	cldel="cldel"             # Define cldel with a value of cldel.
	cldpath="$cldpath$cldel"  # Concatenate $cldel to the end of $cldpath.

	# Loop for directory to delete.
	for val in $(<$clpath); do
		# If a found is true and $val is a directory name set found to false.
		if $found && ! (($i % 2)); then

			found=false

		fi

		# If $val is $name then set found to true.
		if [ $val == $name ]; then

			found=true

		fi

		# If found is false and $val is a directory name set last to $val.
		if ! (($i % 2)) && ! $found; then

			last=$val

		# If $val is a directory location and found is false then echo $last and $val to cldel.
		elif ! $found; then

			echo "$last $val"

		fi

		i=$(($i + 1))          # Increment i.
	done <$clpath >$cldpath # Output echo statements to cldel.

	# If the length of chdlist is the same as cldel then directory name $name doesn't exist. Remove cldel.
	if [ $length == $(wc -l <$cldpath) ]; then

		echo "$name is not a directory name. Nothing deleted."
		rm $cldpath

	# Else the specified directory name and directory location were removed. Make cldel into chdlist.
	else

		echo "$name was removed from supported directories."
		mv $cldpath $clpath

	fi

# Elif $command is uninstall then remove the alias from ~/.bash_profile.
elif [ "$command" == "uninstall" ]; then

	# Removes the path from ~/.bash_profile.
	eval 'sed -i "/alias chd=/d" ~/.bash_profile'

	# Tell the user a terminal restart is needed.
	echo 'Removed chd from ~/.bash_profile'
	echo 'Restart your terminal to complete uninstall.'

# Else attempt to change directories if $command is a directory name in chdlist.
else

	found=false    # Use to tell if directory exists.
	dname=$command # Set the directory name to search for.
	subd="null"    # Initialize subd as null.

	# If there is a '/' in $command prepare for cd to directories under specified one.
	if [[ $command == *[/]* ]]; then

		dname=$(echo "$command" | cut -d "/" -f1) # Grabs directory name before the first '/''.
		subd=$(echo "$command" | cut -d "/" -f2-) # Grabs the directory location after the first '/'.

	fi

	# Loop to search for the directory.
	for val in $(<$clpath); do
		if [ $val == $dname ]; then # If directory found then set found to true and loop one more time to get the directory location.

			found=true
			last=$val

		elif $found; then # If directory found then...

			if [[ $val == *"fCQjEH88ToiQgUnbkMJs-kZamcppqThoNlD92iXpa"* ]]; then # If val contains pattern then replace it with spaces.

				input_spaces "$val"
				val="$dirspace"

			fi

			if [ ! -d "$val" ]; then # If the specified directory no longer exists then notify the user and exit.

				echo "'$val' is no longer a valid directory."
				echo "Use 'chd delete $last' to remove it."
				return

			else

				val="cd '$val'" # Add 'cd ' in front of $val.
				eval $val       # Evaluate $val without any quotes. (This changes to the specified directory.)

				if [ "$subd" != "null" ]; then # If a sub directory was provided then attempt to cd to it.

					if [ -d "$subd" ]; then # If the sub directory is a valid directory then cd to it.

						val="cd '$subd'"
						eval $val

					else # If the sub-directory is not under $dname then echo an error and exit.

						echo "'$subd' is not a valid sub-directory of '$val'"
						return

					fi

				fi

				break # Break the loop.

			fi
		fi
	done

	# If the directory was not found then echo error and exit.
	if ! $found; then

		echo "$dname is not a supported directory. See directories with 'chd list'."
		return

	fi

fi
