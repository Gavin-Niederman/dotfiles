for folder in $(find ./config -mindepth 1 -type d | grep -v "git")
do
    mkdir "${folder/"./config"/"/home/gavin/.config"}";
done

for file in $(find ./config -type f | grep -v "git" | grep -v "dotfiler") 
do
    ln -f $file "${file/"./config"/"/home/gavin/.config"}"; 
done

for folder in $(find ./nixfiles -mindepth 1 -type d | grep -v "git")
do
    mkdir "${folder/"./nixfiles"/"/etc/nixos"}";
done

for file in $(find ./nixfiles -type f | grep -v "git" | grep -v "dotfiler") 
do
    ln -f $file "${file/"./nixfiles"/"/etc/nixos"}"; 
done