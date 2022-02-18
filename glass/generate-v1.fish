function dict_set --argument-names dict key value
    set -g $dict'__'$key $value
    set -ga $dict'___keys' "($key)"
end

function dict_get --argument-names dict key
    eval echo \$$dict'__'$key
end

function dict_enumerate --argument-names dict
    set -l name $dict'___keys'

    string trim -c "()" "$$name" | string split ') ('
end

function generate_file
    set -l color $argv[1]
    set -l color_file 

    if [ "plain" = "$color" ] 
        set color_file source/glass.png
    else
        if [ -z $color ] 
            echo "No color specified"
            return
        end
    
        set color_file source/glass_{$color}.png
    end

    if [ ! -f $color_file ] 
        echo "No color file ($color_file) for $color."
        return
    end    

    echo "Generating files for $color from $color_file."
    for key in (dict_enumerate permutations) 
        set -l elements (dict_get permutations $key)
        generate_permutation "$color" "$color_file" "$key" (string split ',' $elements)
    end 
end

function generate_permutation --argument-names color color_file permutation
    if [ -z "$color" ]
        set color (basename -s .png "$color_file" | string split '_')[2]
    end
    set -l permutation_file dest/imc_glass_"$color"_"$permutation".png # includes extension
    set -l values $argv[3..]

    # make sure the destination folder exists
    if [ ! -e dest ] 
        mkdir dest
    end

    # the 'all' permutation is just the source file
    cp "$color_file" dest/imc_glass_"$color"_all.png

    # prepare the source image
    cp "$color_file" .workfile.png

    # rip out sides
    convert .workfile.png -crop 14x14+1+1 .workfile.png
    convert -size 16x16 canvas:transparent \( .workfile.png -crop 14x14+1+1 \) -geometry +1+1 -composite .workfile.png
    convert .workfile.png -colorspace sRGB \
        \( +clone -crop 1x1+1+1 -resize 16x1! \) -geometry +0+0 -compose src-over -composite \
        \( +clone -crop 1x1+1+1 -resize 16x1! \) -geometry +0+15 -compose src-over -composite \
        \( +clone  -crop 1x1+1+1 -resize 1x14! \) -geometry +0+1 -compose src-over -composite \
        \( +clone  -crop 1x1+1+1 -resize 1x14! \) -geometry +15+1 -compose src-over -composite \
        .workfile.png

    if contains "up_left" (string split ',' $values)
        # up-left corner
        convert .workfile.png \( +clone -crop 1x1+1+1 \) -geometry +0+0 -composite .workfile.png
    end
    if contains "up" (string split ',' $values) ]
        # up
        convert .workfile.png \( +clone -crop 1x1+1+1 -resize 14x1! \) -geometry +1+0 -composite .workfile.png
    end
    if contains "up_right" (string split ',' $values)
        # up-right corner
        convert .workfile.png \( +clone -crop 1x1+1+1 \) -geometry +15+0 -composite .workfile.png
    end
    if contains "right" (string split ',' $values)
        # right
        convert .workfile.png \( +clone -crop 1x1+1+1 -resize 1x14! \) -geometry +15+1 -composite .workfile.png
    end
    if contains "down_right" (string split ',' $values)
        # down-right corner
        convert .workfile.png \( +clone -crop 1x1+1+1 \) -geometry +15+15 -composite .workfile.png
    end
    if contains "down" (string split ',' $values)
        # down
        convert .workfile.png \( +clone -crop 1x1+1+1 -resize 14x1! \) -geometry +1+15 -composite .workfile.png
    end
    if contains "down_left" (string split ',' $values)
        # down-left corner
        convert .workfile.png \( +clone -crop 1x1+1+1 \) -geometry +0+15 -composite .workfile.png
    end
    if contains "left" (string split ',' $values)
        # right
        convert .workfile.png \( +clone -crop 1x1+1+1 -resize 1x14! \) -geometry +0+1 -composite .workfile.png
    end

    if [ -f .workfile.png ] 
        mv .workfile.png $permutation_file
        echo "Saved $permutation to $permutation_file"
    else 
        echo "Couldn't generate $permutation_file"
    end
end

set -l permutations

dict_set permutations none ""
# dict_set permutations all_corners "up_left,up_right,down_left,down_right"
# dict_set permutations left "up_left,left,down_left"
# dict_set permutations right "up_right,right,down_right"
# dict_set permutations up "up_left,up,up_right"
# dict_set permutations up_left "up_left,up,up_right,left,down_left"
# dict_set permutations up_right "up_left,left,down_left,right,down_right"
# dict_set permutations down "down_left,down,down_right"
# dict_set permutations down_left "down_left,down,down_right,up_left,left"
# dict_set permutations down_right "up_right,right,down_right,up_right,right"
dict_set permutations up_left_right "up_left,up,up_right,left,down_left,right,down_right"
dict_set permutations down_left_right "up_left,left,down_left,down,down_right,right,up_right"
dict_set permutations up_down_left "up_left,up,up_right,left,down_left,down,down_right"
dict_set permutations up_down_right "up_left,up,up_right,right,down_right,down,down_left"
# dict_set permutations up_and_corners "up_left,up,up_right,down_left,down_right"
# dict_set permutations down_and_corners "down_left,down,down_right,up_left,up_right"
# dict_set permutations left_and_corners "up_left,left,down_left,up_right,down_right"
# dict_set permutations right_and_corners "up_right,right,down_right,up_left,down_left"
# dict_set permutations up_left_and_corner "up_left,up,up_right,left,down_left,down_right"
# dict_set permutations up_right_and_corner "up_left,up,up_right,right,down_right,down_left"
# dict_set permutations down_left_and_corner "down_left,down,down_right,left,up_left,up_right"
# dict_set permutations down_right_and_corner "down_left,down,down_right,right,up_right,up_left"
# dict_set permutations left_right "up_left,left,down_left,up_right,right,down_right"
# dict_set permutations up_down "up_left,up,up_right,down_left,down,down_right"

for color in $argv
    generate_file $color
end