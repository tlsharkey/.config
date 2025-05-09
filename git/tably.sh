# Edit your color/style preferences here or use empty values for git auto style
tag_style="1;38;5;222"
head_style="1;3;5;1;38;5;196"
branch_style="38;5;214"

# Determine the max character length of your git tree
while IFS=+ read -r graph;do
  chars_count=$(sed -nl1000 'l' <<< "$graph" | grep -Eo '\\\\|\||\/|\ |\*|_' | wc -l)
  [[ $chars_count -gt ${max_chars:-0} ]] && max_chars=$chars_count
done < <(cd "${1:-"$PWD"}" && git log --all --graph --pretty=format:' ')

# Create the columns for your preferred table-like git graph output
while IFS=+ read -r graph hash time branch message;do

  # Count needed amount of white spaces and create them
  whitespaces=$(($max_chars-$(sed -nl1000 'l' <<< "$graph" | grep -Eo '\\\\|\||\/|\ |\*|_' | wc -l)))
  whitespaces=$(seq -s' ' $whitespaces|tr -d '[:digit:]')

  # Show hashes besides the tree ...
  #graph_all="$graph_all$graph$(printf '%7s' "$hash")$whitespaces \n"

  # ... or in an own column
  graph_all="$graph_all$graph$whitespaces\n"
  hash_all="$hash_all$(printf '%7s' "$hash")  \n"

  # Format all other columns
  time_all="$time_all$(printf '%12s' "$time") \n"
  branch=${branch//1;32m/${branch_style:-1;32}m}
  branch=${branch//1;36m/${head_style:-1;36}m}
  branch=${branch//1;33m/${tag_style:-1;33}m}
  branch_all="$branch_all$(printf '%15s' "$branch")\n"
  message_all="$message_all$message\n"

done < <(cd "${1:-"$PWD"}" && git log --all --graph --decorate=short --color --pretty=format:'+%C(bold 214)%<(7,trunc)%h%C(reset)+%C(dim white)%>(12,trunc)%cr%C(reset)+%C(auto)%>(15,trunc)%D%C(reset)+%C(white)%s%C(reset)' && echo);

# Paste the columns together and show the table-like output
paste -d' ' <(echo -e "$time_all") <(echo -e "$branch_all") <(echo -e "$graph_all") <(echo -e "$hash_all") <(echo -e "$message_all")
