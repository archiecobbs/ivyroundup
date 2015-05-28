#!/bin/sh


# Copyright 2012 Stephen Lynn

# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

usage(){

    echo >&2 "$1"
    echo >&2 ""
    echo >&2 "Usage: $0 <command>"
    echo >&2 ""
    echo >&2 "Available Commands:"
    echo >&2 "  test <organisation> <module> <revision>"
    echo >&2 "    - Performs a test resolve of a module"
    echo >&2 ""
    echo >&2 "  addmod [-e] <organisation> <module> <revision>"
    echo >&2 "    - Starts a new module based on the boilerplate"
    echo >&2 "    Options:"
    echo >&2 "      -e  : Opens the new files for editing in the system's default editor"
    echo >&2 ""
    echo >&2 "  addrev [-e] <organisation> <module> <previous-revision> <new-revision>"
    echo >&2 "    - Starts a new revision of an existing module"
    echo >&2 "    Options:"
    echo >&2 "      -e  : Opens the new files for editing in the system's default editor"
    echo >&2 ""
    echo >&2 "  help"
    echo >&2 "    - Prints this usage guide"
    echo >&2 ""
    echo >&2 " *note on default editor: The script will use the EDITOR environment variable"
    echo >&2 "   if it exists, otherwise defalts to 'vi'"
    echo >&2 ""
    exit 1;

}

if [[ "$#" -lt 1 ]]; then
    usage
fi

if [ -z "$EDITOR" ]; then
    EDITOR="vi"
fi



COMMAND=$1
shift

if [[ ("$COMMAND" == "help") ]]; then
    usage

elif [[ ("$COMMAND" == "test") ]]; then

    if [[ ! ("$#" -eq 3) ]]; then   
        usage "Wrong number of arguments for test command"
    fi

    ant -Dresolve.org=$1 -Dresolve.mod=$2 -Dresolve.rev=$3 get-xalan clean repo resolve

elif [[ ("$COMMAND" == "addmod") ]]; then

    EDIT=n
    if [[ ("$1" == "-e") ]]; then
        EDIT=y
        shift
    fi

    if [[ ! ("$#" -eq 3 ) ]]; then
        usage "Wrong number of arguments for addmod command"
    fi 

    echo "cp -a src/boilerplate src/modules/$1/$2/$3"
    cp -a src/boilerplate src/modules/$1/$2/$3

    if [[ ("$EDIT" == "y") ]]; then
        $EDITOR src/modules/$1/$2/$3/*
    fi

elif [[ ("$COMMAND" == "addrev") ]]; then

    if [[ ("$1" == "-e") ]]; then
        EDIT=y
        shift
    fi

    if [[ ! ("$#" -eq 4) ]]; then
        usage "Wrong number of arguments for addrev command"
    fi

    echo "cp -a src/modules/$1/$2/$3 src/modules/$1/$2/$4"
    cp -a src/modules/$1/$2/$3 src/modules/$1/$2/$4
    
    if [[ ("$EDIT" == "y") ]]; then
        `$EDITOR src/modules/$1/$2/$4/*`
    fi

else
    usage "Unknown command '$COMMAND'"
fi
