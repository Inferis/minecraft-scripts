#!/usr/local/bin/fish

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

function generate_file --argument-names color do_color do_heightmap do_textureset 
    set -l color_source_file 
    set -l heightmap_source_file 

    if [ "plain" = "$color" ] 
        set color_source_file source/glass.tga
    else
        if [ -z $color ] 
            echo "No color specified"
            return
        end
        set color_source_file source/glass_{$color}.tga
    end

    if [ ! -f $color_source_file ] 
        echo "No color file ($color_source_file) for $color."
        return
    end    

    set -l heightmap_source_file source/glass_heightmap.png
    if [ ! -f $heightmap_source_file ] 
        echo "No heightmap file ($heightmap_source_file)."
        return
    end    

    echo
    set_color -o white
    echo "Generating files for $color from $color_source_file & $heightmap_source_file."
    set_color
    for key in (dict_enumerate permutations) 
        set -l elements (dict_get permutations $key)
        generate_permutation "$color" "$color_source_file" "$heightmap_source_file" "$key" "$do_color" "$do_heightmap" "$do_textureset" (string split ',' "$elements") 
    end 
    set_color normal
end

function generate_permutation --argument-names color color_source_file heightmap_source_file permutation do_color do_heightmap do_textureset 
    if [ -z "$color" ]
        set color (basename -s .png "$color_file" | string split '_')[2]
    end
    set -l permutation_file dest/imc_glass_"$color"_"$permutation".tga # includes extension
    set -l heightmap_file dest/imc_glass_"$color"_"$permutation"_heightmap.png # includes extension
    set -l values $argv[7..]

    set -l saved_texture
    set -l saved_heightmap
    set -l saved_texture_set

    if [ -n "$do_color" ] || [ -n "$do_heightmap" ]
        # prepare the source image
        set -l work_colorfile .colorfile.tga
        set -l work_heightmapfile .heightmapfile.png
        
        cp "$color_source_file" $work_colorfile
        cp "$heightmap_source_file" $work_heightmapfile

        if contains "up_left" (string split ',' $values)
            # up-left corner
            convert $work_colorfile \( +clone -crop 1x1+0+0 -geometry +0+0 \) -compose subtract -composite \( +clone -crop 1x1+1+1 -geometry +0+0 \) -compose src_over -composite $work_colorfile
            convert $work_heightmapfile \( +clone -crop 1x1+0+0 -geometry +0+0 \) -compose subtract -composite \( +clone -crop 1x1+1+1 -geometry +0+0 \) -compose src_over -composite $work_heightmapfile
            end
        if contains "up" (string split ',' $values) ]
            # up
            convert $work_colorfile \( +clone -crop 14x1+1+0 -geometry +1+0 \) -compose subtract -composite \( +clone -crop 14x1+1+1 -geometry +1+0 \) -compose src_over -composite $work_colorfile
            convert $work_heightmapfile \( +clone -crop 14x1+1+0 -geometry +1+0 \) -compose subtract -composite \( +clone -crop 14x1+1+1 -geometry +1+0 \) -compose src_over -composite $work_heightmapfile
        end
        if contains "up_right" (string split ',' $values)
            # up-right corner
            convert $work_colorfile \( +clone -crop 1x1+15+0 -geometry +15+0 \) -compose subtract -composite \( +clone -crop 1x1+14+1 -geometry +15+0 \) -compose src_over -composite $work_colorfile
            convert $work_heightmapfile \( +clone -crop 1x1+15+0 -geometry +15+0 \) -compose subtract -composite \( +clone -crop 1x1+14+1 -geometry +15+0 \) -compose src_over -composite $work_heightmapfile
        end
        if contains "right" (string split ',' $values)
            # right
            convert $work_colorfile \( +clone -crop 1x14+15+1 -geometry +15+1 \) -compose subtract -geometry +15+1 -composite \( +clone -crop 1x14+14+1 -geometry +15+1 \) -compose src_over -composite $work_colorfile
            convert $work_heightmapfile \( +clone -crop 1x14+15+1 -geometry +15+1 \) -compose subtract -geometry +15+1 -composite \( +clone -crop 1x14+14+1 -geometry +15+1 \) -compose src_over -composite $work_heightmapfile
        end
        if contains "down_right" (string split ',' $values)
            # down-right corner
            convert $work_colorfile \( +clone -crop 1x1+15+15 -geometry +15+15 \) -compose subtract -composite \( +clone -crop 1x1+14+14 -geometry +15+15 \) -compose src_over -composite $work_colorfile
            convert $work_heightmapfile \( +clone -crop 1x1+15+15 -geometry +15+15 \) -compose subtract -composite \( +clone -crop 1x1+14+14 -geometry +15+15 \) -compose src_over -composite $work_heightmapfile
        end
        if contains "down" (string split ',' $values)
            # down
            convert $work_colorfile \( +clone -crop 14x1+1+15 -geometry +1+15 \) -compose subtract -composite \( +clone -crop 14x1+1+1 -geometry +1+15 \) -compose src_over -composite $work_colorfile
            convert $work_heightmapfile \( +clone -crop 14x1+1+15 -geometry +1+15 \) -compose subtract -composite \( +clone -crop 14x1+1+1 -geometry +1+15 \) -compose src_over -composite $work_heightmapfile
        end
        if contains "down_left" (string split ',' $values)
            # down-left corner
            convert $work_colorfile \( +clone -crop 1x1+0+15 -geometry +0+15 \) -compose subtract -composite \( +clone -crop 1x1+1+14 -geometry +0+15 \) -compose src_over -composite $work_colorfile
            convert $work_heightmapfile \( +clone -crop 1x1+0+15 -geometry +0+15 \) -compose subtract -composite \( +clone -crop 1x1+1+14 -geometry +0+15 \) -compose src_over -composite $work_heightmapfile
        end
        if contains "left" (string split ',' $values)
            # left
            convert $work_colorfile \( +clone -crop 1x14+0+1 -geometry +0+1 \) -compose subtract -composite \( +clone -crop 1x14+1+1 -geometry +0+1 \) -compose src_over -composite $work_colorfile
            convert $work_heightmapfile \( +clone -crop 1x14+0+1 -geometry +0+1 \) -compose subtract -composite \( +clone -crop 1x14+1+1 -geometry +0+1 \) -compose src_over -composite $work_heightmapfile
        end

        if [ -n "$do_color" ]
            convert $work_colorfile -define png:color-type=6 -strip TGA:$permutation_file
            set saved_texture "  texture: $permutation_file"
        end

        if [ -n "$do_heightmap" ]
            # convert $work_heightmapfile -colorspace LinearGray -brightness-contrast 50x-20 \( +clone -background black -alpha remove \) -compose over -composite -alpha off +antialias -draw 'fill #888888 color +1+1 floodfill' -draw 'stroke #555555 line 12,13,13,12' -draw 'stroke #666666 line 4,2,2,4' -define png:color-type=0 -strip \
            convert $work_heightmapfile -colorspace LinearGray -alpha remove +antialias -draw 'stroke #999999 line 12,13,13,12' -draw 'stroke #999999 line 4,2,2,4' -define png:color-type=0 -strip PNG:$heightmap_file
            set saved_heightmap "  heightmap: $heightmap_file"
        end

        rm $work_colorfile
        rm $work_heightmapfile
    end

    if [ -n "$do_textureset" ]
        generate_texture_set imc_glass_"$color"_"$permutation" 
        set saved_texture_set "  texture set: dest/imc_glass_"$color"_"$permutation".textureset.json"
    end

    set_color -o white
    echo -n "# "
    set_color -o green 
    echo -n "$color"
    set_color -o white
    echo -n " + "
    set_color yellow 
    echo -n $permutation
    set_color -o white
    echo " ->"
    set_color normal
    if [ -n "$saved_texture" ]; echo $saved_texture; end
    if [ -n "$saved_heightmap" ]; echo $saved_heightmap; end
    if [ -n "$saved_texture_set" ]; echo $saved_texture_set; end
end

function generate_texture_set --argument-names base_name
    set -l texture_set_file dest/$base_name.texture_set.json
    set -l mer "#000000"

    if string match '*void*'
        set mer "#0000FF"
    end

    echo '{' >$texture_set_file
    echo '  "format_version": "1.16.100",' >>$texture_set_file
    echo '  "minecraft:texture_set": {' >>$texture_set_file
    echo '    "color": "'$base_name'",' >>$texture_set_file
    echo '    "heightmap": "'$base_name'_heightmap",' >>$texture_set_file
    echo '    "metalness_emissive_roughness": "'$mer'"' >>$texture_set_file
    echo '  }' >>$texture_set_file
    echo '}' >>$texture_set_file
end

# the values here are the segments to *remove*, not add.
set -l permutations
dict_set permutations all ""
dict_set permutations none "up_left,up,up_right,right,down_right,down,down_left,left"
dict_set permutations all_corners "up,right,down,left"
dict_set permutations up "right,down_right,down,down_left,left"
dict_set permutations down "left,up_left,up,up_right,right"
dict_set permutations left "up,up_right,right,down_right,down"
dict_set permutations right "down,down_left,left,up_left,up"
dict_set permutations up_left "right,down_right,down"
dict_set permutations up_right "down,down_left,left"
dict_set permutations down_left "up,up_right,right"
dict_set permutations down_right "left,up_left,up"
dict_set permutations up_left_right "down"
dict_set permutations down_left_right "up"
dict_set permutations up_down_left "right"
dict_set permutations up_down_right "left"
dict_set permutations up_and_corners "left,right,down"
dict_set permutations down_and_corners "left,up,right"
dict_set permutations left_and_corners "up,right,down"
dict_set permutations right_and_corners "left,up,down"
dict_set permutations up_left_and_corner "right,down"
dict_set permutations up_right_and_corner "left,down"
dict_set permutations down_left_and_corner "up,right"
dict_set permutations down_right_and_corner "left,up"
dict_set permutations up_down "left,right"
dict_set permutations left_right "up,down"


function kickoff
    argparse "help" "p/permutations=+" "a/all" "c/color" "h/heightmap" "t/texture_set" "k/keep" "v/void" -- $argv

    if [ -n "$_flag_help" ]
        echo "Help! (todo)"
        return
    end
    
    if [ -n "$_flag_permutations" ]
        echo "Permutations not supported yet. Using all."
    end

    # make sure the destination folder exists
    if [ ! -e dest ] 
        mkdir dest
    end 
    
    if [ -z "$_flag_keep" ] && [ -e "dest/*" ] 
        rm dest/*
    end
    
    if [ -z "$_flag_color" ] && [ -z "$_flag_heightmap" ] && [ -z "$_flag_texture_set" ] && [ -z "$_flag_void" ] 
        set _flag_color 1 
        set _flag_heightmap 1 
        set _flag_texture_set 1 
        set _flag_void 1 
    else
        if [ -n "$_flag_color" ]
            set _flag_color 1 
        end
    
        if [ -n "$_flag_heightmap" ]
            set _flag_heightmap 1 
        end
    
        if [ -n "$_flag_texture_set" ]
            set _flag_texture_set 1 
        end
    end

    # we need to do color anyway because the heightmap depends on that file
    for color in $argv
        generate_file "$color" "$_flag_color" "$_flag_heightmap" "$_flag_texture_set"
    end
    
    # void 
    if [ -n "$_flag_void" ] 
        set_color -o white
        echo "Generating void files..."
        set_color normal
        convert canvas:transparent -size 16x16 -colorspace LinearGray -strip PNG:dest/imc_glass_void.png
        convert canvas:black -size 16x16 -colorspace LinearGray -alpha remove -define png:color-type=0 -strip dest/imc_glass_void_heightmap.png
        generate_texture_set "imc_glass_void"
    end 
end

kickoff $argv

