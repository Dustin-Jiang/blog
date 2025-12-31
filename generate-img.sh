#!/bin/bash

# \> in the end means it will only be resized if original image is bigger
export SIZE='2500x2500>'

process_avif() {
    img="$1"
    echo "Converting $img..."
    new_path=${img/'./img/'/'./assets/img/'}
    mkdir -p "$(dirname "$new_path")"
    # Generate minified JPG
    if [[ ! -e ${new_path/'.avif'/'.jpg'} ]]; then
        convert "$img" -resize "$SIZE" -strip -interlace Plane -gaussian-blur 0.05 -quality 60% "${new_path/'.avif'/'.jpg'}"
    fi
    # Generate WebP
    if [[ ! -e ${new_path/'.avif'/'.webp'} ]]; then
        convert "$img" -resize "$SIZE" -strip -quality 80 -define webp:lossless=false -define webp:method=6 "${new_path/'.avif'/'.webp'}"
    fi
    # Generate minified AVIF
    if [[ ! -e $new_path ]]; then
        convert "$img" -resize "$SIZE" -strip -quality 80 "$new_path"
    fi
}
export -f process_avif

process_jpg() {
    img="$1"
    echo "Converting $img..."
    new_path=${img/'./img/'/'./assets/img/'}
    mkdir -p "$(dirname "$new_path")"
    # Generate minified JPG
    if [[ ! -e $new_path ]]; then
        convert "$img" -resize "$SIZE" -strip -interlace Plane -gaussian-blur 0.05 -quality 60% "$new_path"
    fi
    # Generate WebP
    if [[ ! -e ${new_path/'.jpg'/'.webp'} ]]; then
        convert "$img" -resize "$SIZE" -strip -quality 80 -define webp:lossless=false -define webp:method=6 "${new_path/'.jpg'/'.webp'}"
    fi
    # Generate AVIF
    if [[ ! -e ${new_path/'.jpg'/'.avif'} ]]; then
        convert "$img" -resize "$SIZE" -strip -quality 80 "${new_path/'.jpg'/'.avif'}"
    fi
}
export -f process_jpg

process_png() {
    img="$1"
    echo "Converting $img..."
    new_path=${img/'./img/'/'./assets/img/'}
    mkdir -p "$(dirname "$new_path")"
    # Copy original PNG
    if [[ ! -e $new_path ]]; then
        convert "$img" -resize "$SIZE" -strip "$new_path"
        # Use OptiPNG to minimize the result
        optipng "$new_path"
    fi
    # Generate lossless WebP
    if [[ ! -e ${new_path/'.png'/'.webp'} ]]; then
        convert "$img" -resize "$SIZE" -strip -define webp:lossless=true "${new_path/'.png'/'.webp'}"
    fi
    # Generate AVIF
    if [[ ! -e ${new_path/'.png'/'.avif'} ]]; then
        convert "$img" -resize "$SIZE" -strip "${new_path/'.png'/'.avif'}"
    fi
}
export -f process_png

process_heic() {
    img="$1"
    echo "Converting $img..."
    new_path=${img/'./img/'/'./assets/img/'}
    mkdir -p "$(dirname "$new_path")"
    # Generate minified JPG
    if [[ ! -e $new_path ]]; then
        convert "$img" -resize "$SIZE" -strip -interlace Plane -gaussian-blur 0.05 -quality 60% "${new_path/'.heic'/'.jpg'}"
    fi

    # Generate lossless WebP
    if [[ ! -e ${new_path/'.heic'/'.webp'} ]]; then
        convert "$img" -resize "$SIZE" -strip -define webp:lossless=true "${new_path/'.heic'/'.webp'}"
    fi
    # Generate AVIF
    if [[ ! -e ${new_path/'.heic'/'.avif'} ]]; then
        convert "$img" -resize "$SIZE" -strip "${new_path/'.heic'/'.avif'}"
    fi
}
export -f process_heic

# Determine number of parallel jobs
JOBS=$(nproc 2>/dev/null || echo 4)

# Process images in parallel
find ./img -name "*.avif" -print0 | xargs -0 -P "$JOBS" -I {} bash -c 'process_avif "$@"' _ {}
find ./img -name "*.jpg" -print0 | xargs -0 -P "$JOBS" -I {} bash -c 'process_jpg "$@"' _ {}
find ./img -name "*.png" -print0 | xargs -0 -P "$JOBS" -I {} bash -c 'process_png "$@"' _ {}
find ./img -name "*.heic" -print0 | xargs -0 -P "$JOBS" -I {} bash -c 'process_heic "$@"' _ {}
