function multicd2 --description 'Change cd.. to cd ../'
    echo cd (string repeat -n (math (string length -- (string replace -r 'cd' '' -- $argv[1])) - 1) ../)
end
