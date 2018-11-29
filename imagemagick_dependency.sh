#!/bin/sh

#give an error if the download fails.
set -e

imagemagick_fetch_and_build () {
    local version=$1

    im_dir=${HOME}/im/imagemagick-${version}

    echo "version is ${version}, im_dir=${im_dir}"

    case $version in
        git7)
            ;;
        git6)
            ;;
        dev)
            ;;
        *)
    # Both individual commits, and tagged versions are cacheable
        if [ -d "${im_dir}" ]; then
            echo "Using cached directory ${im_dir}"
            return
        else
            echo "No cache available. Need to download and compile IM."
        fi
        ;;
    esac


    case $version in

    git7)
        wget -O ImageMagick-7.tar.gz https://github.com/ImageMagick/ImageMagick/archive/master.tar.gz
        tar xvfz ImageMagick-7.tar.gz
        cd ImageMagick-master
        ;;
    git6)
        wget -O ImageMagick-6.tar.gz https://github.com/ImageMagick/ImageMagick6/archive/master.tar.gz
        tar xvfz ImageMagick-6.tar.gz
        cd ImageMagick6-master
        ;;
    dev)
        svn co https://www.imagemagick.org/subversion/ImageMagick/branches/ImageMagick-6/ imagemagick-dev
        cd imagemagick-dev
        ;;
    *)
        set +e
        #this can error
        start_str=${version:0:6}
        set -e
        
        if [ "${start_str}" == "commit" ]; then
        
            sha=${version:7:47}
            wget -O "ImageMagick-${sha}.tar.gz" "https://github.com/ImageMagick/ImageMagick/archive/${sha}.tar.gz"
            tar xvfz ImageMagick-${sha}.tar.gz
            
            cd "ImageMagick-${sha}"
        else
            set +e
            #this can error
            major_version=${version:0:1}
            set -e

            echo "Major version is ${major_version}"

            if [ $major_version == "7" ]; then
                echo "Fetching from IM7 repo"
                wget "https://github.com/ImageMagick/ImageMagick/archive/${version}.tar.gz" -O ImageMagick-${version}.tar.gz
            else
                echo "Fetching from IM6 repo"
                wget "https://launchpad.net/imagemagick/main/${version}/+download/ImageMagick-${version}.tar.gz"
                # Not all of the old releases are available through github, as some releases pre-date
                # ImageMagick being available on Github.
                # wget "https://github.com/ImageMagick/ImageMagick6/archive/${version}.tar.gz" -O ImageMagick-${version}.tar.gz
            fi

            tar xvfz ImageMagick-${version}.tar.gz
            ls -l
            cd ImageMagick-*
        fi
        ;;
    esac

#ignore compile warnings/errors
set +e


    ./configure --prefix="${HOME}/im/imagemagick-${version}" --without-magick-plus-plus --without-perl --disable-openmp --with-gvc=no
    make -j 8
    make install
    cd ..

}

imagemagick_fetch_and_build $1