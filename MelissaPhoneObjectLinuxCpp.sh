#!/bin/bash

# MelissaPhoneObjectLinuxCpp
#
# Downloads the required components and then builds and runs MelissaPhoneObjectLinuxCpp.
#
# This script uses the Melissa Updater to fetch the data file(s), the shared object(s), and
# the C++ headers, verifies the shared object(s) and headers arrived, then builds the project
# with make and runs it against the supplied phone number.
#
# Overall flow:
#   1. Read parameters / prompt for the license and data path.
#   2. Download the data file(s) into the data folder, the shared object(s) into the Build
#      folder, and the C++ headers into the project folder via the Melissa Updater.
#   3. Confirm the shared object(s) and headers are present (data files are not checked).
#   4. Build with make, then run it (single test phone or interactive).
#
# Options:
#   --phone <value>     Phone number to look up.
#   --dataPath <value>  Path to an existing data files directory. If omitted, the script
#                       prompts for a path; pressing Enter at that prompt skips it and
#                       downloads the data files into the project's Data folder via the
#                       Melissa Updater. A path that does not exist aborts the script.
#   --license <value>   License string. Resolved in this order:
#                         1. This option.
#                         2. An interactive prompt, if the option was not supplied.
#                         3. The MD_LICENSE environment variable, if the prompt was left blank.
#                       Note that the environment variable is the last resort, not the first:
#                       running without --license always prompts, even when MD_LICENSE is set.
#   --quiet             Suppresses the Melissa Updater console output during downloads.
#
# Examples:
#   ./MelissaPhoneObjectLinuxCpp.sh --license "your-license"
#   ./MelissaPhoneObjectLinuxCpp.sh --phone "800-800-6245" --license "your-license"

######################### Constants ##########################

RED='\033[0;31m' #RED
NC='\033[0m' # No Color

######################### Parameters ##########################

phone=""
dataPath=""
license=""
quiet="false"

while [ $# -gt 0 ] ; do
    case $1 in
        --phone) 
            phone="$2"
            
            if [ "$phone" == "--dataPath" ] || [ "$phone" == "--license" ] || [ "$phone" == "--quiet" ] || [ -z "$phone" ];
            then
                printf "${RED}Error: Missing an argument for parameter \'phone\'.${NC}\n"  
                exit 1
            fi 
            ;;
        --dataPath) 
            dataPath="$2"
            
            if [ "$dataPath" == "--phone" ] || [ "$dataPath" == "--license" ] || [ "$dataPath" == "--quiet" ] || [ -z "$dataPath" ];
            then
                printf "${RED}Error: Missing an argument for parameter \'dataPath\'.${NC}\n"  
                exit 1
            fi 
            ;;
        --license) 
            license="$2"
            
            if [ "$license" == "--quiet" ] || [ "$license" == "--phone" ] || [ "$license" == "--dataPath" ] || [ -z "$license" ];
            then
                printf "${RED}Error: Missing an argument for parameter \'license\'.${NC}\n"  
                exit 1
            fi  
            ;;
        --quiet) 
            quiet="true" 
            ;;
    esac
    shift
done

# ######################### Config ###########################
# Product release the updater pulls files for
RELEASE_VERSION='2026.08'
ProductName="DQ_PHONE_DATA"

# Uses the location of the .sh file 
CurrentPath=$(pwd)
ProjectPath="$CurrentPath/MelissaPhoneObjectLinuxCpp"

BuildPath="$ProjectPath/Build"
if [ ! -d "$BuildPath" ]; 
then
  mkdir -p "$BuildPath"
fi

if [ -z "$dataPath" ];
then
    DataPath="$ProjectPath/Data"
else
    DataPath=$dataPath
fi

if [ ! -d "$DataPath" ] && [ "$DataPath" == "$ProjectPath/Data" ];
then
    mkdir "$DataPath"
elif [ ! -d "$DataPath" ] && [ "$DataPath" != "$ProjectPath/Data" ];
then
    printf "\nData file path does not exist. Please check that your file path is correct.\n"
    printf "\nAborting program, see above.\n"
    exit 1
fi

# Shared object(s) and headers needed to build and run the example
Config_FileName1="libmdPhone.so"
Config_ReleaseVersion1=$RELEASE_VERSION
Config_OS1="LINUX"
Config_Compiler1="GCC48"
Config_Architecture1="64BIT"
Config_Type1="BINARY"

Config_FileName2="mdEnums.h"
Config_ReleaseVersion2=$RELEASE_VERSION
Config_OS2="ANY"
Config_Compiler2="C"
Config_Architecture2="ANY"
Config_Type2="INTERFACE"

Config_FileName3="mdPhone.h"
Config_ReleaseVersion3=$RELEASE_VERSION
Config_OS3="ANY"
Config_Compiler3="C"
Config_Architecture3="ANY"
Config_Type3="INTERFACE"

# ######################## Functions #########################
# Download the product data file(s) into $DataPath via the Melissa Updater.
DownloadDataFiles()
{
    printf "========================== MELISSA UPDATER =========================\n"
    printf "MELISSA UPDATER IS DOWNLOADING DATA FILE(S)...\n"

    ./MelissaUpdater/MelissaUpdater manifest -p $ProductName -r $RELEASE_VERSION -l $1 -t $DataPath 

    if [ $? -ne 0 ];
    then
        printf "\nCannot run Melissa Updater. Please check your license string!\n"
        exit 1
    fi     
    
    printf "Melissa Updater finished downloading data file(s)!\n"
}

# Download the shared object(s) into the Build folder and the C++ headers into
# the project folder.
DownloadSO() 
{
    printf "\nMELISSA UPDATER IS DOWNLOADING SO(S)...\n"
    
    # Check for quiet mode
    if [ $quiet == "true" ];
    then
        ./MelissaUpdater/MelissaUpdater file --filename $Config_FileName1 --release_version $Config_ReleaseVersion1 --license $1 --os $Config_OS1 --compiler $Config_Compiler1 --architecture $Config_Architecture1 --type $Config_Type1 --target_directory $BuildPath  &> /dev/null
        
        if [ $? -ne 0 ];
        then
            printf "\nCannot run Melissa Updater. Please check your license string!\n"
            exit 1
        fi
        
        printf "Melissa Updater finished downloading $Config_FileName1!\n"

        ./MelissaUpdater/MelissaUpdater file --filename $Config_FileName2 --release_version $Config_ReleaseVersion2 --license $1 --os $Config_OS2 --compiler $Config_Compiler2 --architecture $Config_Architecture2 --type $Config_Type2 --target_directory $ProjectPath  &> /dev/null
        
        if [ $? -ne 0 ];
        then
            printf "\nCannot run Melissa Updater. Please check your license string!\n"
            exit 1
        fi
        
        printf "Melissa Updater finished downloading $Config_FileName2!\n"

        ./MelissaUpdater/MelissaUpdater file --filename $Config_FileName3 --release_version $Config_ReleaseVersion3 --license $1 --os $Config_OS3 --compiler $Config_Compiler3 --architecture $Config_Architecture3 --type $Config_Type3 --target_directory $ProjectPath  &> /dev/null
        
        if [ $? -ne 0 ];
        then
            printf "\nCannot run Melissa Updater. Please check your license string!\n"
            exit 1
        fi

        printf "Melissa Updater finished downloading $Config_FileName3!\n"
    else
        ./MelissaUpdater/MelissaUpdater file --filename $Config_FileName1 --release_version $Config_ReleaseVersion1 --license $1 --os $Config_OS1 --compiler $Config_Compiler1 --architecture $Config_Architecture1 --type $Config_Type1 --target_directory $BuildPath  

        if [ $? -ne 0 ];
        then
            printf "\nCannot run Melissa Updater. Please check your license string!\n"
            exit 1
        fi

        printf "Melissa Updater finished downloading $Config_FileName1!\n"
        
        ./MelissaUpdater/MelissaUpdater file --filename $Config_FileName2 --release_version $Config_ReleaseVersion2 --license $1 --os $Config_OS2 --compiler $Config_Compiler2 --architecture $Config_Architecture2 --type $Config_Type2 --target_directory $ProjectPath  
        
        if [ $? -ne 0 ];
        then
            printf "\nCannot run Melissa Updater. Please check your license string!\n"
            exit 1
        fi
        
        printf "Melissa Updater finished downloading $Config_FileName2!\n"
        
        ./MelissaUpdater/MelissaUpdater file --filename $Config_FileName3 --release_version $Config_ReleaseVersion3 --license $1 --os $Config_OS3 --compiler $Config_Compiler3 --architecture $Config_Architecture3 --type $Config_Type3 --target_directory $ProjectPath

        if [ $? -ne 0 ];
        then
            printf "\nCannot run Melissa Updater. Please check your license string!\n"
            exit 1
        fi
    
        printf "Melissa Updater finished downloading $Config_FileName3!\n"
    fi
}

# Verify the expected shared object(s) and headers landed in their target folders
CheckSOs() 
{
    printf "\nDouble checking SO file(s) were downloaded...\n"
    FileMissing=0
    if [ ! -f $BuildPath/$Config_FileName1 ];
    then
        printf "\n$Config_FileName1 not found\n"
        FileMissing=1
    fi
    if [ ! -f $ProjectPath/$Config_FileName2 ];
    then
        printf "\n$Config_FileName2 not found\n"
        FileMissing=1
    fi
    if [ ! -f $ProjectPath/$Config_FileName3 ];
    then
        printf "\n$Config_FileName3 not found\n"
        FileMissing=1
    fi

    if [ $FileMissing -eq 1 ];
    then
        printf "\nMissing the above data file(s).  Please check that your license string and directory are correct."
        echo 0
    else
        echo 1
    fi
}

########################## Main ############################
printf "\n===================== Melissa Data Phone Object ====================\n                       [ C++ | Linux | 64BIT ]\n"
# Get license (either from parameters or user input)
if [ -z "$license" ];
then
    printf "Please enter your license string: "
    read license
fi

# Check license from Environment Variables 
if [ -z "$license" ];
then
    license=`echo $MD_LICENSE` 
fi

if [ -z "$license" ];
then
    printf "\nLicense String is invalid!\n"
    exit 1
fi

# Get data file path (either from parameters or user input)
if [ "$DataPath" = "$ProjectPath/Data" ]; then
    printf "Please enter your data files path directory if you have already downloaded the release zip.\nOtherwise, the data files will be downloaded using the Melissa Updater (Enter to skip): "
    read dataPathInput

    if [ ! -z "$dataPathInput" ]; then  
        if [ ! -d "$dataPathInput" ]; then  
            printf "\nData file path does not exist. Please check that your file path is correct.\n"
            printf "\nAborting program, see above.\n"
            exit 1
        else
            DataPath=$dataPathInput
        fi
    fi
fi

# Use Melissa Updater to download data file(s) 
# Download data file(s) 
DownloadDataFiles $license # Comment out this line if using own DQS release

# Download SO(s)
DownloadSO $license 

# Check if all SO(s) have been downloaded. Exit script if missing
SOsAreDownloaded=$(CheckSOs)

if echo "$SOsAreDownloaded" | grep -q "0";
then
    echo "$SOsAreDownloaded" | sed 's/0$//'
    printf "\nAborting program, see above.\n"
    exit 1
fi

printf "\nAll file(s) have been downloaded/updated!\n"

# Start program
# Build project
# Point the makefile's LDFLAGS at the Build folder, then compile with make.
printf "\n=========================== BUILD PROJECT ==========================\n"

# Setting the path to the lib in the makefile
LibPath=`grep 'LDFLAGS = ' $ProjectPath/makefile`
NewLibPath="LDFLAGS = -L$ProjectPath/Build"

sed -i -e "s|$LibPath|$NewLibPath|g" $ProjectPath/makefile

# Generate the executable file
cd MelissaPhoneObjectLinuxCpp
make &> /dev/null
cd ..

# Export the path to the lib so that the executable knows where to look
export LD_LIBRARY_PATH=$BuildPath

# Run project
# No phone number supplied -> run interactively; otherwise pass the number in.
if [ -z "$phone" ];
then
    $BuildPath/MelissaPhoneObjectLinuxCpp --license $license  --dataPath $DataPath
else
    $BuildPath/MelissaPhoneObjectLinuxCpp --license $license  --dataPath $DataPath --phone "$phone"
fi
