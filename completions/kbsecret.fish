# Things that don't work:
# -h/--help doesn't display command completions
# todo subcommands
# various flag argument completions
# kbsecret generator

## standard utilities

function __fish_needs_command
  set cmd (commandline -opc)
  if [ (count $cmd) -eq 1 -a $cmd[1] = 'kbsecret' ]
    return 0
  end
  return 1
end
   
function __fish_using_command
  set cmd (commandline -opc)
  if [ (count $cmd) -gt 1 ]
    if [ $argv[1] = $cmd[2] ]
      return 0
    end
  end
  return 1
end

## universal flags

complete -f -c kbsecret -s w -l no-warn -d "Suppress warning output"
complete -f -c kbsecret -s V -l verbose -d "Produce more verbose output"
complete -f -c kbsecret -s h -l help -d "Prints the help information"

## kbsecret help

complete -f -c kbsecret -n '__fish_needs_command' -a help -d "Prints the help information"
complete -f -c kbsecret -n '__fish_using_command help' -a "(kbsecret commands)"

## kbsecret version

complete -f -c kbsecret -n '__fish_needs_command' -a version -d "Prints the version information"
complete -f -c kbsecret -s v -l version -d "Prints the version information"

## kbsecret commands

complete -f -c kbsecret -n '__fish_needs_command' -a commands -d "Prints a list of all commands"

## kbsecret types

complete -f -c kbsecret -n '__fish_needs_command' -a types -d "Prints a list of all available kbsecret record types"

## kbsecret conf

complete -f -c kbsecret -n '__fish_needs_command' -a conf -d "Open kbsecret's configuration in \$EDITOR"

## kbsecret login

complete -f -c kbsecret -n '__fish_needs_command' -a login -d "Access login record"
complete -f -c kbsecret -n '__fish_using_command login' -a "(kbsecret list)"
complete -f -c kbsecret -n '__fish_using_command login' -s s -l session -d "The session to list from"
complete -f -c kbsecret -n '__fish_using_command login' -s a -l all -d "Retrieve all login records"
complete -f -c kbsecret -n '__fish_using_command login' -s x -l terse -d "Output in terse format"
complete -f -c kbsecret -n '__fish_using_command login' -s i -l ifs -d "Terse fields seperator"

## kbsecret pass

complete -f -c kbsecret -n '__fish_needs_command' -a pass -d "Retrieve a login record's password"
complete -f -c kbsecret -n '__fish_using_command pass' -a "(kbsecret list)"
complete -f -c kbsecret -n '__fish_using_command pass' -s s -l session -d "The session to search in"
complete -f -c kbsecret -n '__fish_using_command pass' -s c -l clipboard -d "Dump the password in the clipboard"

## kbsecret raw-edit

complete -f -c kbsecret -n '__fish_needs_command' -a raw-edit -d "Open the JSON of a record for editing"
complete -f -c kbsecret -n '__fish_using_command raw-edit' -a "(kbsecret list)"
complete -f -c kbsecret -n '__fish_using_command raw-edit' -s s -l session -d "The session to search in"

## kbsecret new-session

complete -f -c kbsecret -n '__fish_needs_command' -a new-session -d "Create a new session"
complete -f -c kbsecret -n '__fish_using_command new-session' -s l -l lavel -d "The session label"
complete -f -c kbsecret -n '__fish_using_command new-session' -s u -l users -d "The keybase users"
complete -f -c kbsecret -n '__fish_using_command new-session' -s r -l root -d "The secret root directory"
complete -f -c kbsecret -n '__fish_using_command new-session' -s f -l force -d "Force creation"
complete -f -c kbsecret -n '__fish_using_command new-session' -s n -l no-notify -d "Do not send a notification to session members"

## kbsecret generators

complete -f -c kbsecret -n '__fish_needs_command' -a generators -d "List generators"
complete -f -c kbsecret -n '__fish_using_command generators' -s a -l show-all -d "Show generator details"

## kbsecret list 

complete -f -c kbsecret -n '__fish_needs_command' -a list -d "List records"
complete -f -c kbsecret -n '__fish_using_command list' -s s -l session -d "The session to list from"
complete -f -c kbsecret -n '__fish_using_command list' -s t -l type -d "Filter using the given type"

## kbsecret sessions

complete -f -c kbsecret -n '__fish_needs_command' -a sessions -d "List sessions"
complete -f -c kbsecret -n '__fish_using_command sessions' -s a -l show-all -d "Show session details"

## kbsecret todo

complete -f -c kbsecret -n '__fish_needs_command' -a todo -d "Control 'to do' records"
complete -f -c kbsecret -n '__fish_using_command todo' -a start -d "Mark task as started"
complete -f -c kbsecret -n '__fish_using_command todo' -a suspend -d "Mark task as suspended"
complete -f -c kbsecret -n '__fish_using_command todo' -a complete -d "Mark task as completed"

## kbsecret rm

complete -f -c kbsecret -n '__fish_needs_command' -a rm -d "Deletes a record"
complete -f -c kbsecret -n '__fish_using_command rm' -a "(kbsecret list)"
complete -f -c kbsecret -n '__fish_using_command rm' -s s -l session -d "The session to search in"
complete -f -c kbsecret -n '__fish_using_command rm' -s i -l interactive -d "Confirm deletion interactively"

## kbsecret env

complete -f -c kbsecret -n '__fish_needs_command' -a env -d "Access environment records"
complete -f -c kbsecret -n '__fish_using_command env' -a "(kbsecret list)"
complete -f -c kbsecret -n '__fish_using_command env' -s s -l session -d "The session the records are under"
complete -f -c kbsecret -n '__fish_using_command env' -s a -l all -d "Retrieve all environment records"
complete -f -c kbsecret -n '__fish_using_command env' -s v -l value-only -d "Print only the value"

## kbsecret new

complete -f -c kbsecret -n '__fish_needs_command' -a new -d "Create a new record"
complete -f -c kbsecret -n '__fish_using_command new' -s s -l session -d "The session to create the record under"
complete -f -c kbsecret -n '__fish_using_command new' -s f -l force -d "Force creation"
complete -f -c kbsecret -n '__fish_using_command new' -s a -l args -d "Take record fields from the trailing arguments"
complete -f -c kbsecret -n '__fish_using_command new' -s e -l echo -d "Echo all input to the terminal"
complete -f -c kbsecret -n '__fish_using_command new' -s G -l generate -d "Generate sensitive fields"
complete -f -c kbsecret -n '__fish_using_command new' -s g -l generator -d "Use the given generator"
complete -f -c kbsecret -n '__fish_using_command new' -s x -l terse -d "Read in terse format"
complete -f -c kbsecret -n '__fish_using_command new' -s i -l ifs -d "Terse fields seperator"

## kbsecret rm-session

complete -f -c kbsecret -n '__fish_needs_command' -a rm-session -d "Deletes a session"
complete -f -c kbsecret -n '__fish_using_command rm-session' -a "(kbsecret sessions)" -d "Access given record"
complete -f -c kbsecret -n '__fish_using_command rm-session' -s d -l delete -d "Delete all records"

## kbsecret generator

complete -f -c kbsecret -n '__fish_needs_command' -a generator -d "Manage generators"
complete -f -c kbsecret -n '__fish_using_command todo' -a new -d "Add generator"
complete -f -c kbsecret -n '__fish_using_command todo' -a rm -d "Remove generator"

## kbsecret dump-fields

complete -f -c kbsecret -n '__fish_needs_command' -a dump-fields -d "Dump the fields of a record"
complete -f -c kbsecret -n '__fish_using_command dump-fields' -a "(kbsecret list)"
complete -f -c kbsecret -n '__fish_using_command dump-fields' -s s -l session -d "The session the record is in"
complete -f -c kbsecret -n '__fish_using_command dump-fields' -s x -l terse -d "Output in terse format"
complete -f -c kbsecret -n '__fish_using_command dump-fields' -s i -l ifs -d "Terse fields seperator"

## kbsecret stash-file

complete -f -c kbsecret -n '__fish_needs_command' -a stash-file -d "Store a file in a record"
complete -f -c kbsecret -n '__fish_using_command stash-file' -a "(kbsecret list)"
complete -f -c kbsecret -n '__fish_using_command stash-file' -s f -l force -d "Force creation"
complete -f -c kbsecret -n '__fish_using_command stash-file' -s b -l base64 -d "Base64 encode the file"
complete -f -c kbsecret -n '__fish_using_command stash-file' -s s -l session -d "The session to create the record under"
