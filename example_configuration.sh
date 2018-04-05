#!/bin/sh
# SUMMARY:      CMakeLists.txt
# USAGE:        Part of DHSVM

# AUTHOR:       William A. Perkins
# ORG:          Pacific Northwest National Laboratory
# E-MAIL:       william.perkins@pnl.gov
# ORIG-DATE:    Dec-2016
# DESCRIPTION:  Example DHSVM CMake configuration for some systems
# DESCRIP-END.
# COMMENTS:
#
# Last Change: 2018-03-30 11:47:00 d3g096

set -xue

# -------------------------------------------------------------
# handle command line options
# -------------------------------------------------------------
usage="$0 [-d|-r] [name]"

set -- `getopt dr $*`
if [ $? != 0 ]; then
    echo $usage >&2
    exit 2
fi

build="RelWithDebInfo"
for o in $*; do
    case $o in
        -d)
            build="Debug"
            shift
            ;;
        -r)
            build="Release"
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "$0: error: $o: unknown option" >&2
            echo $usage >&2
            exit 2
    esac
done

if [ $# -gt 0 ]; then
    host="$1"
else
    host=`uname -n`
fi

rm -rf CMakeCache.txt CMakeFiles

options="-Wdev --debug-trycompile"

# useful build types: Debug, Release, RelWithDebInfo
common_flags="\
        -D CMAKE_BUILD_TYPE:STRING=$build \
        -D DHSVM_SNOW_ONLY:BOOL=ON \
        -D DHSVM_BUILD_TESTS:BOOL=ON \
        -D DHSVM_USE_RBM:BOOL=OFF \
        -D DHSVM_DUMP_TOPO:BOOL=OFF \
        -D CMAKE_VERBOSE_MAKEFILE:BOOL=TRUE \
"

if [ $host == "flophouse" ]; then

    CC=/usr/bin/gcc
    CXX=/usr/bin/g++
    export CC

    prefix="/net/flophouse/files0/perksoft/linux64"
    cmake $options \
        -D MPI_C_COMPILER:STRING="/usr/lib64/openmpi/bin/mpicc" \
        -D MPI_CXX_COMPILER:STRING="/usr/lib64/openmpi/bin/mpicxx" \
        -D MPIEXEC:STRING="/usr/lib64/openmpi/bin/mpiexec" \
        -D GA_DIR:STRING="$prefix/ga-c++" \
	-D GA_EXTRA_LIBS:STRING="-lm" \
        -D DHSVM_USE_NETCDF:BOOL=ON \
        -D CMAKE_INSTALL_PREFIX:PATH="$prefix/dhsvm" \
        $common_flags \
        ..

elif [ $host == "WE32673" ]; then

    # this is a Mac system with MPI and NetCDF installed using
    # MacPorts.  You cannot use the Apple CLang because Global Arrays
    # does not work with it.
    
    prefix="/opt/local"
    CC="$prefix/bin/clang-mp-3.8"
    CXX="$prefix/bin/clang++-mp-3.8"
    export CC CXX

    cmake $options \
        -D MPI_C_COMPILER:STRING="$prefix/bin/mpicc-openmpi-clang38" \
        -D MPIEXEC:STRING="$prefix/bin/mpiexec-openmpi-clang38" \
        -D GA_DIR:PATH="/Users/d3g096/Projects/GridPACK" \
        -D NETCDF_DIR:PATH="$prefix/include" \
        -D DHSVM_USE_X11:BOOL=OFF \
        -D DHSVM_USE_NETCDF:BOOL=ON \
        $common_flags \
        ..

elif [ $host == "WE32673-gnu" ]; then

    # this is a Mac system with MPI and NetCDF installed using
    # MacPorts.  

    prefix="/opt/local"
    CC="$prefix/bin/gcc-mp-6"
    CXX="$prefix/bin/g++-mp-6"
    export CC CXX

    cmake $options \
        -D MPI_C_COMPILER:STRING="$prefix/bin/mpicc-openmpi-gcc6" \
        -D MPIEXEC:STRING="$prefix/bin/mpicxx-openmpi-gcc6" \
        -D NETCDF_DIR:PATH="$prefix/include" \
        -D DHSVM_USE_X11:BOOL=OFF \
        -D DHSVM_USE_NETCDF:BOOL=ON \
        $common_flags \
        ..

elif [ $host == "WE32673-clang" ]; then

    # this is a Mac system with NetCDF installed using MacPorts
    # using the system (XCode) compiler

    CC=/usr/bin/clang
    CXX=/usr/bin/clang++
    export CC CXX

    cmake $options \
        -D CMAKE_VERBOSE_MAKEFILE:BOOL=TRUE \
        -D NETCDF_DIR:PATH=/opt/local/include \
        -D DHSVM_USE_X11:BOOL=ON \
        -D DHSVM_USE_NETCDF:BOOL=ON \
        -D DHSVM_USE_RBM:BOOL=OFF \
        $common_flags \
        ..

elif [ $host == "pe10900" ]; then
    
    # this is an older Mac system with Intel compilers and NetCDF
    # installed via MacPorts. This is how you use non-default compilers. 
    CC=icc
    FC=ifort
    export CC FC
    cmake $options \
        -D DHSVM_USE_X11:BOOL=ON \
        -D DHSVM_USE_NETCDF:BOOL=ON \
        -D NETCDF_DIR:PATH=/opt/local/include \
        $common_flags \
        ..

elif [ $host = "briareus" ]; then

    # with these modules (default compilers:

    # module load gcc
    # module load mpi/openmpi/1.4.3/gnu

    prefix=/files0/dhsvm

    CC="/share/apps/gcc/4.5.0/bin/gcc"
    export CC

    cmake \
    -D DHSVM_USE_NETCDF:BOOL=OFF \
    -D MPI_C_COMPILER:STRING="/share/apps/openmpi/1.4.3/gnu/bin/mpicc" \
    -D GA_DIR:STRING="/files0/dhsvm" \
    -D CMAKE_INSTALL_PREFIX:PATH="/files0/dhsvm" \
    ..


elif [ $host = "constance" ]; then

    # with these modules (default compilers:

    # module load precision/i4
    # module load intel/15.0.1
    # module load intelmpi/2017.1.132
    # module load netcdf/4.3.2
    # module load cmake/2.8.12
    
    # GA installed here:

    prefix=/pic/projects/informed_hydro/dhsvm-intel
    CC=/share/apps/intel/2015u1/composer_xe_2015/bin/icc
    CXX=/share/apps/intel/2015u1/composer_xe_2015/bin/icpc
    export CC CXX

    cmake $options \
        -D MPI_C_COMPILER:STRING="/share/apps/intel/2017u1/impi/2017.1.132/intel64/bin/mpicc" \
        -D MPIEXEC:STRING="/share/apps/intel/2017u1/impi/2017.1.132/intel64/bin/mpiexec" \
        -D GA_DIR:STRING="$prefix" \
	-D GA_EXTRA_LIBS:STRING="-libverbs -lm" \
        -D DHSVM_USE_X11:BOOL=OFF \
        -D DHSVM_USE_NETCDF:BOOL=OFF \
        -D NETCDF_INCLUDES:PATH="${NETCDF_INCLUDE}" \
        -D CMAKE_INSTALL_PREFIX:PATH="$prefix" \
        $common_flags \
        ..

elif [ $host = "constance-gnu" ]; then

    # with these modules (default compilers:

    # module load precision/i4
    # module load gcc/4.8.2
    # module load openmpi/1.8.3
    # module load netcdf/4.3.2
    
    # GA installed here:

    prefix=/pic/projects/informed_hydro/dhsvm-gnu
    CC=/share/apps/gcc/4.8.2/bin/gcc
    CXX=/share/apps/gcc/4.8.2/bin/g++
    export CC CXX

    cmake $options \
        -D MPI_C_COMPILER:STRING="/share/apps/openmpi/1.8.3/gcc/4.8.2/bin/mpicc" \
        -D MPIEXEC:STRING="/share/apps/openmpi/1.8.3/gcc/4.8.2/bin/mpiexec" \
        -D GA_DIR:STRING="$prefix" \
	-D GA_EXTRA_LIBS:STRING="-libverbs -lm -lpthread" \
        -D DHSVM_USE_X11:BOOL=OFF \
        -D DHSVM_USE_NETCDF:BOOL=OFF \
        -D NETCDF_INCLUDES:PATH="${NETCDF_INCLUDE}" \
        -D CMAKE_INSTALL_PREFIX:PATH="$prefix" \
        $common_flags \
        ..

elif [ $host = "constance-gnu-pr" ]; then

    # with these modules (default compilers:

    # module load precision/i4
    # module load gcc/4.8.2
    # module load openmpi/1.8.3
    # module load netcdf/4.3.2
    
    # GA installed here:

    prefix=/pic/projects/informed_hydro/dhsvm-gnu-pr
    CC=/share/apps/gcc/4.8.2/bin/gcc
    CXX=/share/apps/gcc/4.8.2/bin/g++
    export CC CXX

    cmake $options \
        -D MPI_C_COMPILER:STRING="/share/apps/openmpi/1.8.3/gcc/4.8.2/bin/mpicc" \
        -D MPIEXEC:STRING="/share/apps/openmpi/1.8.3/gcc/4.8.2/bin/mpiexec" \
        -D GA_DIR:STRING="$prefix" \
	-D GA_EXTRA_LIBS:STRING="-lm -lpthread" \
        -D DHSVM_USE_X11:BOOL=OFF \
        -D DHSVM_USE_NETCDF:BOOL=OFF \
        -D NETCDF_INCLUDES:PATH="${NETCDF_INCLUDE}" \
        -D CMAKE_INSTALL_PREFIX:PATH="$prefix" \
        $common_flags \
        ..

else

    # For an unknown system, turn most options off
    cmake $options \
        -D DHSVM_SNOW_ONLY:BOOL=OFF \
        -D DHSVM_USE_X11:BOOL=OFF \
        -D DHSVM_USE_NETCDF:BOOL=OFF \
        -D DHSVM_BUILD_TESTS:BOOL=OFF \
        ..

    echo "Unknown host: $host"
    exit 2
    
fi
