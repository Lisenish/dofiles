#compdef git git-cvsserver git-receive-pack git-upload-archive git-upload-pack git-shell gitk tig

# Some parts of this completion's behaviour are configurable:
#
# Say you got your own git sub-commands (git will run a program `git-foo'
# when you run "git foo") and you want "git f<tab>" to complete that sub
# commands name for you. You can make that sub-command known to the completion
# via the user-command style:
#
#     % zstyle ':completion:*:*:git:*' user-commands foo:'description for foo'
#
# `user-commands' is a list style, so you can add any number of programs there.
# The :description part is optional, so you could add all git-* programs from
# your $path like this:
#
#     % zstyle ':completion:*:*:git:*' user-commands ${${(M)${(k)commands}:#git-*}/git-/}
#
# A better solution is to create a function _git-foo() to handle specific
# completion for that command.  This also allows you to add command-specific
# completion as well.  Place such a function inside an autoloaded #compdef file
# and you should be all set.  You can add a description to such a function by
# adding a line matching
#
#     #description DESCRIPTION
#
# as the second line in the file.  See
# Completion/Debian/Command/_git-buildpackage in the Zsh sources for an
# example.
#
# When _git does not know a given sub-command (say `bar'), it falls back to
# completing file names for all arguments to that sub command. I.e.:
#
#     % git bar <tab>
#
# ...will complete file names. If you do *not* want that fallback to be used,
# use the `use-fallback' style like this:
#
#     % zstyle ':completion:*:*:git*:*' use-fallback false

# TODO: There is still undocumented configurability in here.

# HIGH-LEVEL COMMANDS (PORCELAIN)

# Main Porcelain Commands

(( $+functions[_git-add] )) ||
_git-add () {
  local curcontext=$curcontext state line ret=1
  declare -A opt_args

  local ignore_missing=
  if (( words[(I)-n|--dry-run] )); then
    ignore_missing='--ignore-missing[check if files (even missing) are ignored in dry run]'
  fi

  _arguments -C -S -s $endopt \
    '(-n --dry-run)'{-n,--dry-run}'[do not actually add files; only show which ones would be added]' \
    '(-v --verbose)'{-v,--verbose}'[show files as they are added]' \
    '(-f --force)'{-f,--force}'[allow adding otherwise ignored files]' \
    '(-i --interactive : -)'{-i,--interactive}'[add contents interactively to index]' \
    '(-p --patch)'{-p,--patch}'[like -i but go directly into patch mode for specified files]' \
    '(-e --edit)'{-e,--edit}'[open diff against index in editor]' \
    '(-A --all --no-ignore-removal -u --update --no-all --ignore-removal --renormalize)'{-A,--all,--no-ignore-removal}'[add, modify, and remove index entries to match the working tree]' \
    '(-A --all --no-ignore-removal -u --update --no-all --ignore-removal --renormalize)'{--no-all,--ignore-removal}'[like "--all" but ignore removals]' \
    '(-A --all --no-ignore-removal -u --update --no-all --ignore-removal)'{-u,--update}'[update the index just where it already has an entry matching <pathspec>]' \
    '(-A --all --no-ignore-removal -u --update --no-all --ignore-removal)--renormalize[renormalize EOL of tracked files (implies -u)]' \
    '(-N --intent-to-add)'{-N,--intent-to-add}'[record only that path will be added later]' \
    '--refresh[do not add files, but refresh their stat() info in index]' \
    '--ignore-errors[continue adding if an error occurs]' \
    $ignore_missing \
    '--sparse[allow updating entries outside of sparse-checkout cone]' \
    '--chmod=[override the executable bit of the listed files]:override:(-x +x)' \
    '(*)--pathspec-from-file=[read pathspec from file]:file:_files' \
    '(*)--pathspec-file-nul[pathspec elements are separated with NUL character]' \
    '*:: :->file' && return

  case $state in
    (file)
      declare -a ignored_files_alternatives
      if [[ -n ${opt_args[(I)-f|--force]} ]]; then
        ignored_files_alternatives=(
          'ignored-modified-files:ignored modified file:__git_ignore_line_inside_arguments __git_modified_files --ignored'
          'ignored-other-files:ignored other file:__git_ignore_line_inside_arguments __git_other_files --ignored')
      fi

      _alternative \
        'modified-files::__git_ignore_line_inside_arguments __git_modified_files' \
        'other-files::__git_ignore_line_inside_arguments __git_other_files' \
        $ignored_files_alternatives && ret=0
      ;;
  esac

  return ret
}

(( $+functions[_git-am] )) ||
_git-am () {
  local -a apply_options
  __git_setup_apply_options

  # NOTE: --rebasing and --resolvemsg are only for internal use between git
  # rebase and git am.
  _arguments -s -S $endopt \
    '(-s --signoff)'{-s,--signoff}'[add Signed-off-by: trailer to the commit message]' \
    '(-S --gpg-sign --no-gpg-sign)'{-S-,--gpg-sign=-}'[GPG-sign the commit]::key id' \
    "(-S --gpg-sign --no-gpg-sign)--no-gpg-sign[don't GPG-sign the commit]" \
    '(-k --keep)'{-k,--keep}'[pass -k to git mailinfo]' \
    '--keep-non-patch[pass -b to git mailinfo]' \
    '(-m --message-id)'{-m,--message-id}'[pass -m flag to git-mailinfo]' \
    '(          --no-keep-cr)--keep-cr[pass --keep-cr to git mailsplit]' \
    '(--keep-cr             )--no-keep-cr[do not pass --keep-cr to git mailsplit]' \
    '(-c --scissors --no-scissors)'{-c,--scissors}'[strip everything before a scissors line]' \
    '(-c --scissors --no-scissors)--no-scissors[ignore scissors lines]' \
    '--quoted-cr=[specify action when quoted CR is found]:action [warn]:(nowarn warn strip)' \
    '(-q --quiet)'{-q,--quiet}'[only print error messages]' \
    '(-u --utf8 --no-utf8)'{-u,--utf8}'[pass -u to git mailinfo]' \
    '(-u --utf8 --no-utf8)--no-utf8[pass -n to git mailinfo]' \
    '(-3 --3way)'{-3,--3way}'[use 3-way merge if patch does not apply cleanly]' \
    $apply_options \
    '--quit[abort the patching operation but keep HEAD where it is]' \
    '--show-current-patch=-[show the message being applied]::show [raw]:(diff raw)' \
    '(-i --interactive)'{-i,--interactive}'[apply patches interactively]' \
    '--committer-date-is-author-date[use author date as committer date]' \
    '--ignore-date[use committer date as author date]' \
    '--skip[skip the current patch]' \
    '(--continue -r --resolved)'{--continue,-r,--resolved}'[continue after resolving patch failure by hand]' \
    '--abort[restore the original branch and abort the patching operation]' \
    '--patch-format=-[specify format patches are in]:patch format:((mbox\:"mbox format"
                                                                    stgit-series\:"StGit patch series"
                                                                    stgit\:"stgit format"))' \
    '*:mbox file:_files'
}

(( $+functions[_git-archive] )) ||
_git-archive () {
  local curcontext=$curcontext state line ret=1
  declare -A opt_args

  declare -a backend_args

  if (( words[(b:CURRENT-1:I)--format=*] )); then
    case ${words[$words[(I)--format=*]]#--format=} in
      (zip)
        backend_args=(
          '-0[do not deflate files]'
          '-1[minimum compression]'
          '-2[a little more compression]'
          '-3[slightly more compression]'
          '-4[a bit more compression]'
          '-5[even more compression]'
          '-6[slightly even more compression]'
          '-7[getting there]'
          '-8[close to maximum compression]'
          '-9[maximum compression]')
        ;;
    esac
  fi

  _arguments -C -S -s $endopt \
    '--format=-[format of the resulting archive]:archive format:__git_archive_formats' \
    '(- :)'{-l,--list}'[list available archive formats]' \
    '(-v --verbose)'{-v,--verbose}'[report progress to stderr]' \
    '--prefix=-[prepend the given path prefix to each filename]:path prefix:_directories -r ""' \
    '--add-file=[add untracked file to archive]:file:_files' \
    '(-o --output)'{-o+,--output=}'[write archive to specified file]:archive:_files' \
    '--worktree-attributes[look for attributes in .gitattributes in working directory too]' \
    $backend_args \
    '--remote=[archive remote repository]:remote repository:__git_any_repositories' \
    '--exec=[path to git-receive-pack on remote]:remote path:_files' \
    ': :__git_tree_ishs' \
    '*: :->file' && ret=0

  case $state in
    (file)
      __git_tree_files ${PREFIX:-.} $line[1] && ret=0
      ;;
  esac

  return ret
}

(( $+functions[_git-bisect] )) ||
_git-bisect () {
  local curcontext=$curcontext state line ret=1
  declare -A opt_args
  local good bad

  if good=$(_call_program commands git bisect terms --term-good); then
    bad=$(_call_program commands git bisect terms --term-bad)
  else
    good=( good old ) bad=( new bad )
  fi

  _arguments -C \
    '--help[display git-bisect manual page]' \
    ': :->command' \
    '*:: :->option-or-argument' && ret=0

  case $state in
    (command)
      declare -a commands

      commands=(
        help:'display a short usage description'
        start:'reset bisection state and start a new bisection'
        ${^bad}:'mark current or given revision as bad'
        ${^good}:'mark current or given revision as good'
        skip:'choose a nearby commit'
        next:'find next bisection to test and check it out'
        reset:'finish bisection search and return to the given branch (or master)'
        visualize:'show the remaining revisions in gitk'
        view:'show the remaining revisions in gitk'
        replay:'replay a bisection log'
        terms:'show currently used good/bad terms'
        log:'show log of the current bisection'
        run:'run evaluation script')

      _describe -t commands command commands && ret=0
      ;;
    (option-or-argument)
      curcontext=${curcontext%:*}-$line[1]:

      case $line[1] in
        (start)
          _arguments -C \
	    --term-{good,old}'=[specify alternate term for good revisions]:term' \
	    --term-{bad,new}'=[specify alternate term for bad revisions]:term' \
	    '--no-checkout[set BISECT_HEAD reference instead of doing checkout at each iteration]' \
            '--first-parent[follow only the first parent commit upon seeing a merge commit]' \
            ':bad revision:__git_commits' \
            '*: :->revision-or-path' && ret=0
          case $state in
            (revision-or-path)
              if compset -N '--' || ! __git_is_committish $line[CURRENT-1]; then
                __git_cached_files && ret=0
              else
                _alternative \
                  'revisions::__git_revisions' \
                  'files::__git_cached_files' && ret=0
              fi
              ;;
          esac
          ;;
        (${(~j.|.)bad}|${(~j.|.)good}|skip)
          # TODO: skip can take revlists.
          _arguments \
            '*: :__git_commits' && ret=0
          ;;
        (replay)
          _arguments \
            ':log file:_files' && ret=0
          ;;
        (reset)
          _arguments \
            ': :__git_heads' && ret=0
          ;;
        (run)
          _arguments \
            '*:: : _normal' && ret=0
          ;;
        (terms)
	  _arguments --term-good --term-bad && ret=0
	  ;;
        (view|visualize)
          local -a log_options revision_options
          __git_setup_log_options
          __git_setup_revision_options

          _arguments -C -s \
            $log_options \
            $revision_options && ret=0
        (*)
          _nothing
          ;;
      esac
      ;;
  esac

  return ret
}

(( $+functions[_git-branch] )) ||
_git-branch () {
  declare l c m d e

  l='--color --no-color -r --remotes -a -v --verbose --abbrev --no-abbrev -l --list --points-at --sort'
  c='--create-reflog -f --force -t --track --no-track -u --set-upstream --set-upstream-to --unset-upstream --contains --no-contains --merged --no-merged'
  m='-c --copy -C -m --move -M --edit-description --show-current'
  d='-d --delete -D'

  declare -a dependent_creation_args
  if (( words[(I)(-r|--remotes)] == 0 )); then
    dependent_creation_args=(
      "($l $m $d): :__git_branch_names"
      "::start-point:__git_revisions")
  fi

  declare -a dependent_deletion_args
  if (( words[(I)-d] || words[(I)-D] )); then
    dependent_creation_args=
    dependent_deletion_args=(
      '-r[delete only remote-tracking branches]')
    if (( words[(I)(-r|--remotes)] )); then
      dependent_deletion_args+='*: :__git_ignore_line_inside_arguments __git_remote_branch_names'
    else
      dependent_deletion_args+='*: :__git_ignore_line_inside_arguments __git_branch_names'
    fi
  fi

  declare -a dependent_modification_args
  if (( words[(I)-m] || words[(I)-M] )); then
    dependent_creation_args=
    dependent_modification_args=(
      ':old or new branch name:__git_branch_names'
      '::new branch name:__git_branch_names')
  fi

  _arguments -S -s $endopt \
    "($c $m $d --no-color :)--color=-[turn on branch coloring]:: :__git_color_whens" \
    "($c $m $d : --color)--no-color[turn off branch coloring]" \
    "($c $m $d --no-column)--column=-[display tag listing in columns]:: :_git_column_layouts" \
    "($c $m $d --column)--no-column[don't display in columns]" \
    "($c $m $d)*"{-l,--list}'[list only branches matching glob]:pattern' \
    "($c $m     -a)"{-r,--remotes}'[list or delete only remote-tracking branches]' \
    "($c $m $d : -r --remotes)-a[list both remote-tracking branches and local branches]" \
    "($c $m $d : -v -vv --verbose)"{-v,-vv,--verbose}'[show SHA1 and commit subject line for each head]' \
    "($c $m $d :)--abbrev=[use specified digits to display object names]:digits" \
    "($c $m $d :)--no-abbrev[don't abbreviate sha1s]" \
    "(- :)--show-current[show current branch name]" \
    "($l $m $d)--create-reflog[create the branch's reflog]" \
    "($l $m $d -f --force)"{-f,--force}'[force the creation of a new branch]' \
    "($l $m $d -t --track)"{-t,--track}'[setup configuration so that pull merges from the start point]' \
    "($l $m $d)--no-track[override the branch.autosetupmerge configuration variable]" \
    "($l $m $d -u --set-upstream --set-upstream-to --unset-upstream)"{-u+,--set-upstream-to=}'[set up configuration so that pull merges]:remote branch:__git_remote_branch_names' \
    "($l $m $d -u --set-upstream --set-upstream-to --unset-upstream)--unset-upstream[remove upstream configuration]" \
    "($l $m $d)*--contains=[only list branches that contain the specified commit]: :__git_committishs" \
    "($l $m $d)*--no-contains=[only list branches that don't contain the specified commit]: :__git_committishs" \
    "($l $m $d)--merged=[only list branches that are fully contained by HEAD]: :__git_committishs" \
    "($l $m $d)--no-merged=[don't list branches that are fully contained by HEAD]: :__git_committishs" \
    "($c $l $m $d)--edit-description[edit branch description]" \
    $dependent_creation_args \
    "($l $c $d $m)"{-m,--move}"[rename a branch and the corresponding reflog]" \
    "($l $c $d $m)-M[rename a branch even if the new branch-name already exists]" \
    "($l $c $d $m)"{-c,--copy}"[copy a branch and the corresponding reflog]" \
    "($l $c $d $m)-C[copy a branch even if the new branch-name already exists]" \
    $dependent_modification_args \
    "($l $c $m $d)"{-d,--delete}"[delete a fully merged branch]" \
    "($l $c $m $d)-D[delete a branch]" \
    {-q,--quiet}"[be more quiet]" \
    '*--sort=[specify field to sort on]: :__git_ref_sort_keys' \
    '--points-at=[only list tags of the given object]: :__git_commits' \
    "($c $m $d -i --ignore-case)"{-i,--ignore-case}'[sorting and filtering are case-insensitive]' \
    $dependent_deletion_args
}

(( $+functions[_git-bundle] )) ||
_git-bundle () {
  local curcontext=$curcontext state line ret=1
  declare -A opt_args

  _arguments -C \
    ': :->command' \
    '*:: :->option-or-argument' && ret=0

  case $state in
    (command)
      declare -a commands

      commands=(
        'create:create a bundle'
        'verify:check that a bundle is valid and will apply cleanly'
        'list-heads:list references defined in bundle'
        'unbundle:unbundle a bundle to repository')

      _describe -t commands command commands && ret=0
      ;;
    (option-or-argument)
      curcontext=${curcontext%:*}-$line[1]:

      case $line[1] in
        (create)
          if (( CURRENT == 2 )); then
            _arguments \
              '(-q --quiet)'{-q,--quiet}"[don't show progress]" \
              '--progress[show progress meter]' \
              '--all-progress[show progress meter during object writing phase]' \
              '--all-progress-implied[similar to --all-progress when progress meter is shown]' \
              '--version=[specify bundle format version]:version:(2 3)' \
              ':bundle:_files' && ret=0
          else
            local revision_options
            __git_setup_revision_options

            _arguments -S -s \
              $revision_options \
              ': :_files' \
              '*: :__git_commit_ranges2' && ret=0
          fi
          ;;
        (verify)
          _arguments \
            '(-q --quiet)'{-q,--quiet}"[don't show bundle details]" \
            ':bundle:_files' && ret=0
          ;;
        (list-heads)
          _arguments \
            ':bundle:_files' \
            '*: :__git_references' && ret=0
        ;;
        (unbundle)
          _arguments \
            '--progress[show progress meter]' \
            ':bundle:_files' \
            '*: :__git_references' && ret=0
        ;;
      esac
      ;;
  esac

  return ret
}

(( $+functions[_git-version] )) ||
_git-version () {
  _arguments -S $endopt \
    '--build-options[also print build options]'
}

(( $+functions[_git-check-ignore] )) ||
_git-check-ignore () {
  _arguments -s -S $endopt \
    '(-q --quiet)'{-q,--quiet}'[do not output anything, just set exit status]' \
    '(-v --verbose)'{-v,--verbose}'[output details about the matching pattern (if any) for each pathname]' \
    '--stdin[read file names from stdin instead of from the command-line]' \
    '-z[make output format machine-parseable and treat input-paths as NUL-separated with --stdin]' \
    '(-n --non-matching)'{-n,--non-matching}'[show given paths which do not match any pattern]' \
    '--no-index[do not look in the index when undertaking the checks]' \
    '*:: :_files'
}

(( $+functions[_git-check-mailmap] )) ||
_git-check-mailmap () {
  _arguments -S $endopt \
    '--stdin[read contacts from stdin after those given on the command line]'
}

(( $+functions[_git-checkout] )) ||
_git-checkout () {
  # TODO: __git_tree_ishs is just stupid.  It should be giving us a list of tags
  # and perhaps also allow all that just with ^{tree} and so on.  Not quite sure
  # how to do that, though.
  local new_branch_reflog_opt
  if (( words[(I)-b|-B|--orphan] )); then
    new_branch_reflog_opt="(--patch)-l[create the new branch's reflog]"
  fi

  local curcontext=$curcontext state line ret=1
  declare -A opt_args

  _arguments -C -s \
    '(-q --quiet)'{-q,--quiet}'[suppress progress reporting]' \
    '(-f --force -m --merge --conflict --patch)'{-f,--force}'[force branch switch/ignore unmerged entries]' \
    '(-q --quiet -2 --ours -3 --theirs --patch)'{-2,--ours}'[check out stage #2 for unmerged paths]' \
    '(-q --quiet -2 --ours -3 --theirs --patch)'{-3,--theirs}'[check out stage #3 for unmerged paths]' \
    '(   -B --orphan -2 --ours -3 --theirs --conflict --patch -d --detach)-b+[create a new branch based at given commit]: :__git_branch_names' \
    '(-b    --orphan -2 --ours -3 --theirs --conflict --patch -d --detach)-B+[create or update branch based at given commit]: :__git_branch_names' \
    '(-t --track --orphan --patch -d --detach)'{-t,--track}'[set up configuration so pull merges from the base commit]' \
    '(--patch)--no-track[override the branch.autosetupmerge configuration variable]' \
    $new_branch_reflog_opt \
    '(-b -B -t --track --patch --orphan -d --detach)'{-d,--detach}'[detach the HEAD at named commit]' \
    '(-b -B -t --track --patch -d --detach)--orphan=[create a new orphan branch based at given commit]: :__git_branch_names' \
    '(-q --quiet -f --force -m --merge --conflict --patch)'{-m,--merge}'[3way merge current branch, working tree and new branch]' \
    '(-q --quiet -f --force -m --merge --patch)--conflict=[same as --merge, using given merge style]:style:(merge diff3)' \
    '(-)'{-p,--patch}'[interactively select hunks in diff between given tree-ish and working tree]' \
    "--ignore-skip-worktree-bits[don't limit pathspecs to sparse entries only]" \
    "--no-guess[don't second guess 'git checkout <no-such-branch>']" '!(--no-guess)--guess' \
    "--ignore-other-worktrees[don't check if another worktree is holding the given ref]" \
    '--recurse-submodules=-[control recursive updating of submodules]::checkout:__git_commits' \
    '--no-overlay[remove files from index or working tree that are not in the tree-ish]' \
    '(-q --quiet --progress)--no-progress[suppress progress reporting]' \
    '--progress[force progress reporting]' \
    '(*)--pathspec-from-file=[read pathspec from file]:file:_files' \
    '(*)--pathspec-file-nul[pathspec elements are separated with NUL character]' \
    '(-)--[start file arguments]' \
    '*:: :->branch-or-tree-ish-or-file' && ret=0

  case $state in
    (branch-or-tree-ish-or-file)
      # TODO: Something about *:: brings us here when we complete at "-".  I
      # guess that this makes sense in a way, as we might want to treat it as
      # an argument, but I can't find anything in the documentation about this
      # behavior.
      [[ $line[CURRENT] = -* ]] && return
      if (( CURRENT == 1 )) && [[ -z $opt_args[(I)--] ]]; then
        # TODO: Allow A...B
        local \
              tree_ish_arg='tree-ishs::__git_commits_prefer_recent' \
              file_arg='modified-files::__git_modified_files'

        if [[ -n ${opt_args[(I)-b|-B|--orphan|--detach]} ]]; then
          _alternative $tree_ish_arg && ret=0
        elif [[ -n $opt_args[(I)--track] ]]; then
          _alternative remote-branches::__git_remote_branch_names && ret=0
        elif [[ -n ${opt_args[(I)--ours|--theirs|-m|--conflict|--patch|--no-guess]} ]]; then
          _alternative $tree_ish_arg $file_arg && ret=0
        else
          _alternative \
            $file_arg \
            $tree_ish_arg \
            'remote-branch-names-noprefix::__git_remote_branch_names_noprefix' \
            && ret=0
        fi

      elif [[ -n ${opt_args[(I)-b|-B|-t|--track|--orphan|--detach]} ]]; then
        _nothing
      elif [[ -n $line[1] ]] && __git_is_treeish ${(Q)line[1]}; then
        __git_ignore_line __git_tree_files ${PREFIX:-.} ${(Q)line[1]} && ret=0
      else
        __git_ignore_line __git_modified_files && ret=0
      fi
      ;;
  esac

  return ret
}

(( $+functions[_git-cherry-pick] )) ||
_git-cherry-pick () {
  local -a git_commit_opts
  git_commit_opts=(--all --not HEAD --not)
  _arguments \
    '(- :)--quit[end revert or cherry-pick sequence]' \
    '(- :)--continue[resume revert or cherry-pick sequence]' \
    '(- :)--skip[skip current commit and continue]' \
    '(- :)--abort[cancel revert or cherry-pick sequence]' \
    '--cleanup=[specify how to strip spaces and #comments from message]:mode:_git_cleanup_modes' \
    '--allow-empty[preserve initially empty commits]' \
    '--allow-empty-message[allow replaying a commit with an empty message]' \
    '--keep-redundant-commits[keep cherry-picked commits that will become empty]' \
    '(-e --edit --ff)'{-e,--edit}'[edit commit before committing the cherry-pick]' \
    '(--ff)-x[append information about what commit was cherry-picked]' \
    '(-m --mainline)'{-m+,--mainline=}'[specify mainline when cherry-picking a merge commit]:parent number' \
    '--rerere-autoupdate[update index with reused conflict resolution if possible]' \
    '(-n --no-commit --ff)'{-n,--no-commit}'[do not make the actual commit]' \
    '(-s --signoff --ff)'{-s,--signoff}'[add Signed-off-by trailer at the end of the commit message]' \
    '(-S --gpg-sign --no-gpg-sign)'{-S-,--gpg-sign=-}'[GPG-sign the commit]::key id' \
    "(-S --gpg-sign --no-gpg-sign)--no-gpg-sign[don't GPG-sign the commit]" \
    '*'{-s+,--strategy=}'[use given merge strategy]:merge strategy:__git_merge_strategies' \
    '*'{-X+,--strategy-option=}'[pass merge-strategy-specific option to merge strategy]: :_git_strategy_options' \
    '(-e --edit -x -n --no-commit -s --signoff)--ff[fast forward, if possible]' \
    '*: : __git_commit_ranges -O expl:git_commit_opts'
}

(( $+functions[_git-citool] )) ||
_git-citool () {
  _nothing
}

(( $+functions[_git-clean] )) ||
_git-clean () {
  local curcontext=$curcontext state line ret=1
  declare -A opt_args

  _arguments -C -S -s $endopt \
    '-d[also remove untracked directories]' \
    \*{-f,--force}'[required by default; twice, removes untracked nested repositories]' \
    '(-i --interactive)'{-i,--interactive}'[show what would be done and clean files interactively]' \
    '(-n --dry-run)'{-n,--dry-run}'[only show what would and what would not be removed]' \
    '(-q --quiet)'{-q,--quiet}"[don't print names of files removed]" \
    '*'{-e+,--exclude=}'[skip files matching specified pattern]:pattern' \
    '(-X   )-x[also remove ignored files]' \
    '(   -x)-X[remove only ignored files]' \
    '*: :->file' && ret=0

  case $state in
    (file)
      local exclusion ignored_other_files_alt other_files_alt
      declare -a exclusions
      for spec in $opt_args[-e] $opt_args[--exclude]; do
        integer i
        for (( i = 1; i <= $#spec; i++ )); do
          case $spec[i] in
            (\\)
              if (( i + 1 <=  $#spec )) && [[ $spec[i+1] == : ]]; then
                (( i++ ))
                exclusion+=:
              else
                exclusion+=$spec[i]
              fi
              ;;
            (:)
              exclusions+=(-x $exclusion) exclusion=
              ;;
            (*)
              exclusion+=$spec[i]
              ;;
          esac
        done
      done
      [[ -n $exclusion ]] && exclusions+=(-x $exclusion)
      if [[ -n ${opt_args[(I)-x|-X]} ]]; then
        ignored_other_files_alt="ignored-untracked-files::__git_ignored_other_files $exclusions"
      fi
      if [[ -z ${opt_args[(I)-X]} ]]; then
        other_files_alt="untracked-files::__git_other_files $exclusions"
      fi
      _alternative \
        $ignored_other_files_alt \
        $other_files_alt && ret=0
      ;;
  esac

  return ret
}

(( $+functions[_git-clone] )) ||
_git-clone () {
  local curcontext=$curcontext state line ret=1
  declare -A opt_args

  # TODO: Argument to -o should be a remote name.
  # TODO: Argument to -b should complete branch names in the repository being
  # cloned (see __git_references())
  _arguments -C -S -s $endopt \
    '(-l --local --no-local)'{-l,--local}'[clone locally, hardlink refs and objects if possible]' \
    '(-l --local --no-local)--no-local[override --local, as if file:/// URL was given]' \
    '--no-hardlinks[copy files instead of hardlinking when doing a local clone]' \
    '(-s --shared)'{-s,--shared}'[share the objects with the source repository (warning: see man page)]' \
    '(-j --jobs)'{-j+,--jobs=}'[specify number of submodules cloned in parallel]:jobs' \
    '--reference[reference repository]:repository:_directories' \
    '--reference-if-able[reference repository]:repository:_directories' \
    '--dissociate[make the newly-created repository independent of the --reference repository]' \
    '(-q --quiet)'{-q,--quiet}'[operate quietly]' \
    '(-v --verbose)'{-v,--verbose}'[always display the progressbar]' \
    '--progress[output progress even if stderr is not a terminal]' \
    "--reject-shallow[don't clone shallow repository]" \
    '(-n --no-checkout)'{-n,--no-checkout}'[do not checkout HEAD after clone is complete]' \
    '(-o --origin)--bare[make a bare GIT repository]' \
    '(--bare)--mirror[clone refs into refs/* instead of refs/remotes/origin/*]' \
    '(-o --origin --bare)'{-o+,--origin=}'[use given remote name instead of "origin"]: :__git_guard_branch-name' \
    '(-b --branch)'{-b+,--branch=}'[point HEAD to the given branch]: :__git_guard_branch-name' \
    '(-u --upload-pack)'{-u+,--upload-pack=}'[specify path to git-upload-pack on remote side]:remote path' \
    '--template=[directory to use as a template for the object database]: :_directories' \
    '*'{-c,--config}'[<key>=<value> set a configuration variable in the newly created repository]' \
    '--depth[create a shallow clone, given number of revisions deep]: :__git_guard_number depth' \
    '--shallow-since=[shallow clone since a specific time]:time' \
    '*--shallow-exclude=[shallow clone excluding commits reachable from specified remote revision]:revision' \
    '(--no-single-branch)--single-branch[clone only history leading up to the main branch or the one specified by -b]' \
    '(--single-branch)--no-single-branch[clone history leading up to each branch]' \
    "--no-tags[don't clone any tags and make later fetches not follow them]" \
    '--shallow-submodules[any cloned submodules will be shallow]' \
    '--recursive[initialize all contained submodules]' \
    '(--recursive --recurse-submodules)'{--recursive,--recurse-submodules}'=-[initialize submodules in the clone]::file:__git_files' \
    '--separate-git-dir[place .git dir outside worktree]:path to .git dir:_path_files -/' \
    \*--server-option='[send specified string to the server when using protocol version 2]:option' \
    '(-4 --ipv4 -6 --ipv6)'{-4,--ipv4}'[use IPv4 addresses only]' \
    '(-4 --ipv4 -6 --ipv6)'{-6,--ipv6}'[use IPv6 addresses only]' \
    '--filter=[object filtering]:filter:_git_rev-list_filters' \
    '--remote-submodules[any cloned submodules will use their remote-tracking branch]' \
    '--sparse[initialize the sparse-checkout file to start with only the top-level files]' \
    ': :->repository' \
    ': :_directories' && ret=0

  case $state in
    (repository)
      if [[ -n ${opt_args[(I)-l|--local|--no-hardlinks|-s|--shared|--reference]} ]]; then
        __git_local_repositories && ret=0
      else
        __git_any_repositories && ret=0
      fi
      ;;
  esac

  return ret
}

(( $+functions[_git-column] )) ||
_git-column() {
  _arguments -s \
    '--command=[look up layout mode using in config vars using specified command]:command:(branch clean status tag ui)' \
    '--mode=[specify layout mode]: :_git_column_layouts' \
    '--raw-mode=[same as --mode but take mode encoded as a number]:mode' \
    "--width=[specify the terminal width]:width [${COLUMNS:-80}]" \
    '--indent=[specify string to be printed at the beginning of each line]:string' \
    '--nl=[specify string to be printed at the end of each line, including newline character]:string' \
    '--padding=[specify number of spaces between columns]:spaces [1]'
}

(( $+functions[_git-commit] )) ||
_git-commit () {
  local amend_opt='--amend[amend the tip of the current branch]'
  if __git_is_initial_commit || __git_is_in_middle_of_merge; then
    amend_opt=
  fi

  local reset_author_opt=
  if (( words[(I)-C|--reuse-message(=*|)|-c|--reedit-message(=*|)|--amend] )); then
    reset_author_opt='(--author)--reset-author[make committer the author of the commit]'
  fi

  # TODO: --interactive isn't explicitly listed in the documentation.
  _arguments -S -s $endopt \
    '(-a --all --interactive -o --only -i --include *)'{-a,--all}'[stage all modified and deleted paths]' \
    '--fixup=[construct a commit message for use with rebase --autosquash]:commit to be amended:_git_fixup' \
    '--squash=[construct a commit message for use with rebase --autosquash]:commit to be amended:__git_recent_commits' \
    $reset_author_opt \
    '(        --porcelain --dry-run)--short[dry run with short output format]' \
    '--branch[show branch information]' \
    '!(--no-ahead-behind)--ahead-behind' \
    "--no-ahead-behind[don't display detailed ahead/behind counts relative to upstream branch]" \
    '(--short             --dry-run)--porcelain[dry run with machine-readable output format]' \
    '(--short --porcelain --dry-run -z --null)'{-z,--null}'[dry run with NULL-separated output format]' \
    {-p,--patch}'[use the interactive patch selection interface to chose which changes to commit]' \
    '(--reset-author)--author[override the author name used in the commit]:author name' \
    '--date=[override the author date used in the commit]:date' \
    '*--trailer=[add custom trailer(s)]:trailer' \
    '(-s --signoff)'{-s,--signoff}'[add Signed-off-by trailer at the end of the commit message]' \
    '(-n --no-verify)'{-n,--no-verify}'[bypass pre-commit and commit-msg hooks]' \
    '--allow-empty[allow recording an empty commit]' \
    '--allow-empty-message[allow recording a commit with an empty message]' \
    '--cleanup=[specify how the commit message should be cleaned up]:mode:_git_cleanup_modes' \
    '(-e --edit --no-edit)'{-e,--edit}'[edit the commit message before committing]' \
    '(-e --edit --no-edit)--no-edit[do not edit the commit message before committing]' \
    '--no-post-rewrite[bypass the post-rewrite hook]' \
    '(-a --all --interactive -o --only -i --include)'{-i,--include}'[update the given files and commit the whole index]' \
    '(-a --all --interactive -o --only -i --include)'{-o,--only}'[commit only the given files]' \
    '(-u --untracked-files)'{-u-,--untracked-files=-}'[show files in untracked directories]::mode:((no\:"show no untracked files"
                                                                                                  normal\:"show untracked files and directories"
                                                                                                  all\:"show individual files in untracked directories"))' \
    '(*)--pathspec-from-file=[read pathspec from file]:file:_files' \
    '(*)--pathspec-file-nul[pathspec elements are separated with NUL character]' \
    '(-q --quiet -v --verbose)'{-v,--verbose}'[show unified diff of all file changes]' \
    '(-q --quiet -v --verbose)'{-q,--quiet}'[suppress commit summary message]' \
    '--dry-run[only show list of paths that are to be committed or not, and any untracked]' \
    '(         --no-status)--status[include the output of git status in the commit message template]' \
    '(--status            )--no-status[do not include the output of git status in the commit message template]' \
    '(-S --gpg-sign --no-gpg-sign)'{-S-,--gpg-sign=}'[GPG-sign the commit]::key id' \
    "(-S --gpg-sign --no-gpg-sign)--no-gpg-sign[don't GPG-sign the commit]" \
    '(-a --all --interactive -o --only -i --include *)--interactive[interactively update paths in the index file]' \
    $amend_opt \
    '*: :__git_ignore_line_inside_arguments __git_changed_files' \
    - '(message)' \
      {-C+,--reuse-message=}'[use existing commit object with same log message]: :__git_commits' \
      {-c+,--reedit-message=}'[use existing commit object and edit log message]: :__git_commits' \
      {-F+,--file=}'[read commit message from given file]: :_files' \
      \*{-m+,--message=}'[use the given message as the commit message]:message' \
      {-t+,--template=}'[use file as a template commit message]:template:_files'
}

(( $+functions[_git-describe] )) ||
_git-describe () {
  _arguments -S -s $endopt \
    '(*)--dirty=-[describe HEAD, adding mark if dirty]::mark' \
    '(*)--broken=-[describe HEAD, adding mark if broken]::mark' \
    '--all[use any ref found in "$GIT_DIR/refs/"]' \
    '--tags[use any ref found in "$GIT_DIR/refs/tags"]' \
    '(--tags)--contains[find the tag after the commit instead of before]' \
    '--abbrev=[use specified digits to display object names]:digits' \
    '(             --exact-match)--candidates=[consider up to given number of candidates]: :__git_guard_number "number of candidates"' \
    '(--candidates              )--exact-match[only output exact matches, same as --candidates=0]' \
    '--debug[display information about the searching strategy]' \
    '--long[always show full format, even for exact matches]' \
    '*--match=[only consider tags matching glob pattern]:pattern' \
    "*--exclude=[don't consider tags matching glob pattern]:pattern" \
    '--always[show uniquely abbreviated commit object as fallback]' \
    '--first-parent[follow only the first parent of merge commits]' \
    '*: :__git_committishs'
}

(( $+functions[_git-diff] )) ||
_git-diff () {
  local curcontext=$curcontext state line ret=1
  declare -A opt_args

  local -a diff_options diff_stage_options
  __git_setup_diff_options
  __git_setup_diff_stage_options

  _arguments -C -s $endopt \
    $* \
    $diff_options \
    '(--exit-code)--quiet[disable all output]' \
    $diff_stage_options \
    '(--cached --staged)--no-index[show diff between two paths on the filesystem]' \
    '(--cached --staged --no-index)'{--cached,--staged}'[show diff between index and named commit]' \
    '(-)--[start file arguments]' \
    '*:: :->from-to-file' && ret=0

  case $state in
    (from-to-file)
      # If "--" is part of $opt_args, this means it was specified before any
      # $words arguments. This means that no heads are specified in front, so
      # we need to complete *changed* files only.
      if [[ -n ${opt_args[(I)--]} ]]; then
        if [[ -n ${opt_args[(I)--cached|--staged]} ]]; then
          __git_changed-in-index_files && ret=0
        else
          __git_changed-in-working-tree_files && ret=0
        fi
        return ret
      fi

      # If "--no-index" was given, only file paths need to be completed.
      if [[ -n ${opt_args[(I)--no-index]} ]]; then
        _alternative 'files::_files' && ret=0
        return ret
      fi

      # Otherwise, more complex conditions need to be checked.
      case $CURRENT in
        (1)
          local files_alt='files::__git_changed-in-working-tree_files'
          if [[ -n ${opt_args[(I)--cached|--staged]} ]]; then
            files_alt='files::__git_changed-in-index_files'
          fi

          _alternative \
            'commit-ranges::__git_commit_ranges' \
            'blobs-and-trees-in-treeish::__git_blobs_and_trees_in_treeish' \
            $files_alt \
            'blobs::__git_blobs ' && ret=0
          ;;
        (2)
          # Check if first argument is something special. In case of committish ranges and committishs offer a full list compatible completions.
          if __git_is_committish_range $line[1]; then
            # Example: git diff branch1..branch2 <tab>
            __git_tree_files ${PREFIX:-.} $(__git_committish_range_last $line[1]) && ret=0
          elif __git_is_committish $line[1] || __git_is_treeish $line[1]; then
            local files_alt='files::__git_tree_files ${PREFIX:-.} HEAD'
            [[ $line[1] = (HEAD|@) ]] &&
                files_alt='files::__git_changed_files'
            # Example: git diff branch1 <tab>
            _alternative \
              'commits::__git_commits' \
              'blobs-and-trees-in-treeish::__git_blobs_and_trees_in_treeish' \
              $files_alt && ret=0
          elif __git_is_blob $line[1]; then
            _alternative \
              'files::__git_cached_files' \
              'blobs::__git_blobs' && ret=0
          elif [[ -n ${opt_args[(I)--cached|--staged]} ]]; then
            # Example: git diff --cached file1 <tab>
            __git_changed-in-index_files && ret=0
          else
            # Example: git diff file1 <tab>
            __git_changed-in-working-tree_files && ret=0
          fi
          ;;
        (*)
          if __git_is_committish_range $line[1]; then
            # Example: git diff branch1..branch2 file1 <tab>
            __git_tree_files ${PREFIX:-.} $(__git_committish_range_last $line[1]) && ret=0
          elif { __git_is_committish $line[1] && __git_is_committish $line[2] } ||
              __git_is_treeish $line[2]; then
            # Example: git diff branch1 branch2 <tab>
            __git_tree_files ${PREFIX:-.} $line[2] && ret=0
          elif [[ $line[1] = (HEAD|@) ]]; then
            # Example: git diff @ file1 <tab>
            # Example: git diff HEAD -- <tab>
            __git_ignore_line __git_changed_files && ret=0
          elif __git_is_committish $line[1] || __git_is_treeish $line[1]; then
            # Example: git diff branch file1 <tab>
            # Example: git diff branch -- f<tab>
            __git_tree_files ${PREFIX:-.} HEAD && ret=0
          elif __git_is_blob $line[1] && __git_is_blob $line[2]; then
            _nothing
          elif [[ -n ${opt_args[(I)--cached|--staged]} ]]; then
            # Example: git diff --cached file1 file2 <tab>
            __git_changed-in-index_files && ret=0
          else
            # Example: git diff file1 file2 <tab>
            __git_changed-in-working-tree_files && ret=0
          fi
          ;;
      esac
      ;;
  esac

  return ret
}

(( $+functions[_git-fetch] )) ||
_git-fetch () {
  local curcontext=$curcontext state line ret=1
  declare -A opt_args

  local -a fetch_options
  __git_setup_fetch_options

  _arguments -C -S -s $endopt \
    $fetch_options \
    '--atomic[use atomic transaction to update references]' \
    '(--all -m --multiple)'{-m,--multiple}'[fetch from multiple remotes]' \
    '(-n --no-tags -t --tags)'{-n,--no-tags}'[disable automatic tag following]' \
    '--prefetch[modify the refspec to place all refs within refs/prefetch/]' \
    '(-P --prune-tags)'{-P,--prune-tags}'[prune local tags no longer on remote and clobber changed tags]' \
    '--write-fetch-head[write fetched references to the FETCH_HEAD file]' \
    "--negotiate-only[don't fetch a packfile; instead, print ancestors of negotiation tips]" \
    '--filter=[object filtering]:filter:_git_rev-list_filters' \
    '(--auto-maintenance --auto-gc)'--auto-{maintenance,gc}"[run 'maintenance --auto' after fetching]" \
    '--write-commit-graph[write the commit-graph after fetching]' \
    '--stdin[accept refspecs from stdin]' \
    '*:: :->repository-or-group-or-refspec' && ret=0

  case $state in
    (repository-or-group-or-refspec)
      if (( CURRENT > 1 )) && [[ -z ${opt_args[(I)--multiple]} ]]; then
        __git_ref_specs_fetchy && ret=0
      else
        _alternative \
          'remotes::__git_remotes' \
          'remotes-groups::__git_remotes_groups' \
          'local-repositories::__git_local_repositories' \
          'remote-repositories::__git_remote_repositories' && ret=0
      fi
      ;;
  esac

  return ret
}

(( $+functions[_git-format-patch] )) ||
_git-format-patch () {
  local curcontext=$curcontext state line ret=1
  declare -A opt_args

  local -a diff_options
  __git_setup_diff_options

  # TODO: -- is wrong.
  # TODO: Should filter out --name-only, --name-status, and --check from
  # $diff_options.
  _arguments -C -S -s $endopt \
    $diff_options \
    '--[limit the number of patches to prepare]: :__git_guard_number "number of patches to prepare"' \
    '(-o --output-directory --stdout)'{-o+,--output-directory=}'[store resulting files in given directory]: :_directories' \
    '(-n --numbered -N --no-numbered -k --keep-subject)'{-n,--numbered}'[name output in \[PATCH n/m\] format]' \
    '(-n --numbered -N --no-numbered -k --keep-subject)'{-N,--no-numbered}'[name output in \[PATCH\] format]' \
    '--start-number=[start numbering patches at given number]: :__git_guard_number "patch number"' \
    '--numbered-files[use only number for file name]' \
    '(-n --numbered -N --no-numbered -k --keep-subject --rfc --subject-prefix)'{-k,--keep-subject}"[don't strip/add \[PATCH\] from the first line of the commit message]" \
    '(-s --signoff)'{-s,--signoff}'[add Signed-off-by: trailer to the commit message]' \
    '(-o --output-directory)--stdout[output the generated mbox on standard output (implies --mbox)]' \
    '(         --no-attach --inline)--attach=-[create attachments instead of inlining patches]::boundary' \
    '(--attach             --inline)--no-attach[disable creation of attachments]' \
    '(--attach --no-attach         )--inline=-[inline patches]::boundary' \
    '(         --no-thread)--thread=-[make the second and subsequent mails refer to the first]::style:((shallow\:"all refer to the first"
                                                                                                        deep\:"each refers to the previous"))' \
    '(--thread            )--no-thread[do not thread messages]' \
    '--in-reply-to=[make the first mail a reply to the given message]:message id' \
    '--ignore-if-in-upstream[do not include a patch that matches a commit in the given range]' \
    '(-v --reroll-count)'{-v+,--reroll-count=}'[mark the series as the <n>-th iteration of the topic]: :__git_guard_number iteration' \
    '--filename-max-length=[specify max length of output filename]:length' \
    '(-k --keep-subject --subject-prefix)--rfc[use \[RFC PATCH\] instead of \[PATCH\]]' \
    "--cover-from-description=[generate parts of a cover letter based on a branch's description]:mode:(message default subject auto none)" \
    '(-k --keep-subject --rfc)--subject-prefix=[use the given prefix instead of \[PATCH\]]:prefix' \
    '*--to=[add To: header to email headers]: :_email_addresses' \
    '*--cc=[add Cc: header to email headers]: :_email_addresses' \
    '--from=[add From: header to email headers]: :_email_addresses' \
    '*--add-header=[add an arbitrary header to email headers]:header' \
    '--cover-letter[generate a cover letter template]' \
    '--notes=[append notes for the commit after the three-dash line]:: :__git_notes_refs' \
    '(            --no-signature --signature-file)--signature=[add a signature]:signature' \
    '(--signature                --signature-file)--no-signature[do not add a signature]' \
    '(--signature --no-signature                 )--signature-file=[use contents of file as signature]' \
    '--suffix=[use the given suffix for filenames]:filename suffix' \
    '(-q --quiet)'{-q,--quiet}'[suppress the output of the names of generated files]' \
    '--no-binary[do not output contents of changes in binary files, only note that they differ]' \
    '--root[treat the revision argument as a range]' \
    '--zero-commit[output all-zero hash in From header]' \
    '--progress[show progress while generating patches]' \
    '--interdiff=[insert interdiff against previous patch series in cover letter or single patch]:reference to tip of previous series:__git_revisions' \
    '--range-diff=[insert range-diff against previous patch series in cover letter or single patch]:reference to tip ot previous series:__git_revisions' \
    '--creation-factor=[for range-diff, specify weighting for creation]:weighting (percent)' \
    ': :->commit-or-commit-range' && ret=0

  case $state in
    (commit-or-commit-range)
      if [[ -n ${opt_args[(I)--root]} ]]; then
        __git_commits && ret=0
      else
        __git_commit_ranges && ret=0
      fi
      ;;
  esac

  return ret
}

(( $+functions[_git-gc] )) ||
_git-gc () {
  _arguments -S -s $endopt \
    '--aggressive[more aggressively optimize]' \
    '--auto[check whether housekeeping is required]' \
    '(        --no-prune)--prune=-[prune loose objects older than given date]::date [2 weeks ago]:__git_datetimes' \
    '(--prune           )--no-prune[do not prune any loose objects]' \
    '(-q --quiet)'{-q,--quiet}'[suppress progress reporting]' \
    '--keep-largest-pack[repack all other packs except the largest pack]' \
}

(( $+functions[_git-grep] )) ||
_git-grep () {
  local -a pattern_operators

  # TODO: Need to deal with grouping with ( and )
  if (( words[(I)-e] == CURRENT - 2 )); then
    pattern_operators=(
      '--and[both patterns must match]'
      '--or[either pattern must match]'
      '--not[the following pattern must not match]')
  fi

  local curcontext=$curcontext state line ret=1
  declare -A opt_args

  # TODO: Need to implement -<num> as a shorthand for -C<num>
  _arguments -C -A '-*' $endopt \
    '(-O --open-files-in-pager --no-index)--cached[search blobs registered in index file instead of working tree]' \
    '(--cached)--no-index[search files in current directory, not just tracked files]' \
    '(--exclude-standard)--no-exclude-standard[search also in ignored files]' \
    '(--no-exclude-standard)--exclude-standard[exclude files standard ignore mechanisms]' \
    '--recurse-submodules[recursively search in each submodule]' \
    "--parent-basename=[prepend parent project's basename to output]:basename" \
    '--untracked[search also in untracked files]' \
    '(-a --text)'{-a,--text}'[process binary files as if they were text]' \
    '(--textconv --no-textconv)--textconv[honor textconv filter settings]' \
    "(--textconv --no-textconv)--no-textconv[don't honor textconv filter settings]" \
    '(-i --ignore-case)'{-i,--ignore-case}'[ignore case when matching]' \
    "-I[don't match pattern in binary files]" \
    '!-r' '!--recursive' \
    '--max-depth=[descend at most given levels of directories]: :__git_guard_number depth' \
    '(-w --word-regexp)'{-w,--word-regexp}'[match only whole words]' \
    '(-v --invert-match)'{-v,--invert-match}'[select non-matching lines]' \
    '(-H)-h[suppress output of filenames]' \
    '(-h -c --count)-H[show filenames]' \
    '--full-name[output paths relative to the project top directory]' \
    '(-E --extended-regexp -G --basic-regexp -P --perl-regexp -F --fixed-strings)'{-E,--extended-regexp}'[use extended regular expressions]' \
    '(-E --extended-regexp -G --basic-regexp -P --perl-regexp -F --fixed-strings)'{-G,--basic-regexp}'[use basic regular expressions]' \
    '(-E --extended-regexp -G --basic-regexp -P --perl-regexp -F --fixed-strings)'{-P,--perl-regexp}'[use perl-compatible regexes]' \
    '(-E --extended-regexp -G --basic-regexp -P --perl-regexp -F --fixed-strings)'{-F,--fixed-strings}'[use literal strings]' \
    '(-n --line-number)'{-n,--line-number}'[prefix the line number to matching lines]' \
    '(-c --count)--column[show column number of first match]' \
    '(-c --count -l --files-with-matches --name-only -L --files-without-match -o --only-matching)'{-l,--files-with-matches,--name-only}'[show only names of matching files]' \
    '(-c --count -l --files-with-matches --name-only -L --files-without-match -o --only-matching)'{-L,--files-without-match}'[show only names of non-matching files]' \
    '(-c --count -o --only-matching -n --line-number --color --no-color --cached --heading -O --open-files-in-pager)'{-O,--open-files-in-pager=}'-[open matching files in pager]::pager:_cmdstring' \
    '(-z --null)'{-z,--null}'[output \0 after filenames]' \
    '(-c --count -l --files-with-matches --name-only -L --files-without-match -o --only-matching)'{--only-matching,-o}'[show only matching part of line]' \
    '(-h -c --count -l --files-with-matches --name-only -L --files-without-match -o --only-matching --color --break --heading -p --show-function -W --function-context)'{-c,--count}'[show number of matching lines in files]' \
    '(--no-color -O --open-files-in-pager)--color=-[color matches]:: :__git_color_whens' \
    "(--color -O --open-files-in-pager)--no-color[don't color matches]" \
    '(-c --count -O --open-files-in-pager)--break[print an empty line between matches from different files]' \
    '(-c --count -O --open-files-in-pager)--heading[show the filename above the matches]' \
    '(-A --after-context)'{-A+,--after-context=}'[specify lines of trailing context]: :__git_guard_number lines' \
    '(-B --before-context)'{-B+,--before-context=}'[specify lines of leading context]: :__git_guard_number lines' \
    '(-A --after-context -B --before-context -C --context)'{-C+,--context=}'[specify lines of context]: :__git_guard_number lines' \
    '--threads=[use specified number of threads]:number of threads' \
    '(-c --count -p --show-function)'{-p,--show-function}'[show preceding line containing function name of match]' \
    '(-c --count -W --function-context)'{-W,--function-context}'[show whole function where a match was found]' \
    '(1)*-f+[read patterns from given file]:pattern file:_files' \
    '(1)*-e+[use the given pattern for matching]:pattern' \
    $pattern_operators \
    '--all-match[all patterns must match]' \
    ': :_guard "^-*" pattern' \
    '*:: :->tree-or-file' && ret=0

  # TODO: If --cached, --no-index, -O, or --open-files-in-pager was given,
  # don't complete treeishs.
  case $state in
    (tree-or-file)
      integer first_tree last_tree start end i

      (( start = words[(I)(-f|-e)] > 0 ? 1 : 2 ))
      (( end = $#line - 1 ))

      for (( i = start; i <= end; i++ )); do
        [[ line[i] == '--' ]] && break
        __git_is_treeish $line[i] || break
        if (( first_tree == 0 )); then
          (( first_tree = last_tree = i ))
        else
          (( last_tree = i ))
        fi
      done

      # TODO: Need to respect --cached and --no-index here.
      if (( last_tree == 0 || last_tree == end )); then
        if (( first_tree == 0 )); then
          _alternative \
            'treeishs::__git_tree_ishs' \
            'files::__git_cached_files' && ret=0
        else
          _alternative \
            'treeishs::__git_trees' \
            "files::__git_tree_files ${PREFIX:-.} $line[first_tree,last_tree]" && ret=0
        fi
      else
        if (( first_tree == 0 )); then
          __git_cached_files && ret=0
        else
          __git_tree_files ${PREFIX:-.} $line[first_tree,last_tree] && ret=0
        fi
      fi
      ;;
  esac

  return ret
}

(( $+functions[_git-gui] )) ||
_git-gui () {
  local curcontext=$curcontext state line ret=1
  declare -A opt_args

  _arguments -C \
    '--version[display version information]' \
    ': :->command' \
    '*:: :->arg' && ret=0

  case $state in
    (command)
      local -a commands

      commands=(
        blame:'start a blame viewer'
        browser:'start a tree browser'
        citool:'arrange to make one commit'
        version:'display version information')

      _describe -t commands command commands && ret=0
      ;;
    (arg)
      curcontext=${curcontext%:*}-$line[1]:

      case $line[1] in
        (blame)
          _git-blame && ret=0
          ;;
        (browser)
          _arguments -C \
            ':: :__git_revisions' \
            '*:: :->file' && ret=0

          case $state in
            (file)
              __git_is_treeish $line[1] && __git_tree_files ${PREFIX:-.} $line[1] && ret=0
              ;;
          esac
          ;;
        (citool)
          _git-citool && ret=0
          ;;
        (version)
          _nothing
          ;;
        (*)
          _nothing
          ;;
      esac
      ;;
  esac

  return ret
}

(( $+functions[_git-init] )) ||
_git-init () {
  _arguments -S -s $endopt \
    '(-q --quiet)'{-q,--quiet}'[do not print any results to stdout]' \
    '--bare[create a bare repository]' \
    '--template=[directory to use as a template for the object database]: :_directories' \
    '--shared=[share repository amongst several users]:: :__git_repository_permissions' \
    '--separate-git-dir=[create git dir elsewhere and link it using the gitdir mechanism]:: :_directories' \
    '(-b --initial-branch)'{-b+,--initial-branch=}'[override the name of the initial branch]:branch name' \
    '--object-format=[specify the hash algorithm to use]:algortithm:(sha1 sha256)' \
    ':: :_directories'
}

(( $+functions[_git-interpret-trailers] )) ||
_git-interpret-trailers() {
  _arguments -S $endopt \
    '--in-place[edit files in place]' \
    '--trim-empty[trim empty trailers]' \
    '--where[specify where to place the new trailer]' \
    '--if-exists[specify action if trailer already exists]' \
    '--if-missing[specify action if trailer is missing]' \
    '--only-trailers[output only the trailers]' \
    "--only-input[don't apply config rules]" \
    '--unfold[join whitespace-continued values]' \
    '--parse[set parsing options]' \
    "--no-divider[don't treat --- as the end of the commit message]" \
    '--trailer[specify trailer(s) to add]' \
    '*:file:_files'
}

(( $+functions[_git-log] )) ||
_git-log () {
  local curcontext=$curcontext state line ret=1
  declare -A opt_args

  local -a log_options revision_options diff_options
  __git_setup_log_options
  __git_setup_revision_options

  _arguments -C -s $endopt \
    $log_options \
    $revision_options \
    '(-)--[start file arguments]' \
    '1: :->first-commit-ranges-or-files' \
    '*: :->commit-ranges-or-files' && ret=0

  case $state in
    (first-commit-ranges-or-files)
      if [[ -n ${opt_args[(I)--]} ]]; then
	__git_tree_files ${PREFIX:-.} HEAD && ret=0
      else
	_alternative \
	  'commit-ranges::__git_commit_ranges' \
	  'cached-files::__git_tree_files ${PREFIX:-.} HEAD' && ret=0
      fi
    ;;
    (commit-ranges-or-files)
      # Multiple revspecs are permitted.
      if [[ -z ${opt_args[(I)--]} ]]; then
        __git_commit_ranges "$@" && ret=0
      fi

      # TODO: Write a wrapper function that checks whether we have a
      # committish range or committish and calls __git_tree_files
      # appropriately.
      if __git_is_committish_range $line[1]; then
	__git_tree_files ${PREFIX:-.} $(__git_committish_range_last $line[1]) && ret=0
      elif __git_is_committish $line[1]; then
	__git_tree_files ${PREFIX:-.} $line[1] && ret=0
      else
	__git_tree_files ${PREFIX:-.} HEAD && ret=0
      fi
    ;;
  esac

  return ret
}

(( $+functions[_git-maintenance] )) ||
_git-maintenance() {
  local curcontext="$curcontext" state state_descr line ret=1
  local -A opt_args

  _arguments -C \
    ': :->command' \
    '*::: := ->option-or-argument' && ret=0

  case $state in
    (command)
      local -a commands

      commands=(
        register:'initialize config values to run maintenance on this repository'
        run:'run one or more maintenance tasks'
        start:'start running maintenance on the current repository'
        stop:'halt the background maintenance schedule'
        unregister:'remove the current repository from background maintenance'
      )

      _describe -t commands command commands && ret=0
    ;;
    (option-or-argument)
      curcontext=${curcontext%:*}-$line[1]:
      case $line[1] in
        (run)
          _arguments -S $endopt \
            '--auto[run tasks based on the state of the repository]' \
            '--schedule=[run tasks based on frequency]:frequency (seconds)' \
            "--quiet[don't report progress or other information to stderr]" \
            '*--task=[run a specific task]:task:(gc commit-graph prefetch loose-objects incremental-repack pack-refs)' && ret=0
        ;;
        (start)
          _arguments \
            '--scheduler=:scheduler:(auto crontab systemd-timer launchctl schtasks)'
      esac
    ;;
  esac

  return ret
}

(( $+functions[_git-merge] )) ||
_git-merge () {
  local -a merge_options
  __git_setup_merge_options
  local -a git_commit_opts=(--all --not HEAD --not)

  _arguments -S -s $endopt \
    $merge_options \
    \*{-m+,--message=}'[set the commit message to be used for the merge commit]:merge message' \
    \*{-F+,--file=}'[read commit message from a file]:file' \
    '(--edit --no-edit)-e[open an editor to change the commit message]' \
    '(                    --no-rerere-autoupdate)--rerere-autoupdate[allow the rerere mechanism to update the index]' \
    '(--rerere-autoupdate                       )--no-rerere-autoupdate[do not allow the rerere mechanism to update the index]' \
    '(--quit --continue)--abort[restore the original branch and abort the merge operation]' \
    '(--abort --continue)--quit[--abort but leave index and working tree alone]' \
    '(--abort --quit)--continue[continue the current in-progress merge]' \
    '--progress[force progress reporting]' \
    '--no-verify[verify commit-msg hook]' \
    '*: : __git_commits -O expl:git_commit_opts'
}

(( $+functions[_git-mv] )) ||
_git-mv () {
  local curcontext=$curcontext state line ret=1
  declare -A opt_args

  _arguments -C -S -s $endopt \
    '(-v --verbose)'{-v,--verbose}'[output additional information]' \
    '(-f --force)'{-f,--force}'[rename/move even if targets exist]' \
    '-k[skip rename/move that would lead to errors]' \
    '(-n --dry-run)'{-n,--dry-run}'[only show what would happen]' \
    '--sparse[allow updating entries outside of sparse-checkout cone]' \
    ':source:__git_cached_files' \
    '*:: :->source-or-destination' && ret=0

  case $state in
    (source-or-destination)
      _alternative \
        'cached-files:source:__git_cached_files' \
        'directories:destination directory:_directories' && ret=0
      ;;
  esac

  return ret
}

(( $+functions[_git-notes] )) ||
_git-notes () {
  local curcontext=$curcontext state line ret=1
  declare -A opt_args

  _arguments -C $endopt \
    '--ref=[manipulate the notes tree in given ref]: :__git_notes_refs' \
    ': :->command' \
    '*:: :->option-or-argument' && ret=0

  case $state in
    (command)
      local -a commands

      commands=(
        list:'list notes object for given object'
        add:'add notes for a given object'
        copy:'copy notes from one object to another'
        append:'append notes to a given object'
        edit:'edit notes for a given object'
        merge:'merge the given notes ref into the current ref'
        show:'show notes for a given object'
        remove:'remove notes for a given object'
        prune:'remove all notes for non-existing/unreachable objects'
        get-ref:'print the current notes ref'
      )

      _describe -t commands command commands && ret=0
      ;;
    (option-or-argument)
      curcontext=${curcontext%:*}-$line[1]:

      case $line[1] in
        (list|show)
          _arguments -S $endopt \
            ': :__git_commits' && ret=0
          ;;
        (add)
          # TODO: Only complete commits that don't have notes already, unless
          # -f or --force has been given.
          _arguments -S -s $endopt \
            '*'{-m+,--message=}'[use given note message]:message' \
            '*'{-F+,--file=}'[take note message from given file]:note message file:_files' \
            '(-C --reuse-message)'{-C+,--reuse-message=}'[take note message from given blob object]: :__git_blobs' \
            '(-c --reedit-message)'{-c+,--reedit-message=}'[take note message from given blob object and edit it]: :__git_blobs' \
            '(-f --force)'{-f,--force}'[overwrite existing note]' \
            ': :__git_commits' && ret=0
          ;;
        (copy)
          _arguments -S -s $endopt \
            '(-f --force)'{-f,--force}'[replace existing note]' \
            '(:)--stdin[read objects from stdin]' \
            '(:--stdin)--for-rewrite=[load rewriting config for given command]:command:(amend rebase)' \
            ': :__git_commits' \
            ': :__git_commits' && ret=0
          ;;
	(edit)
	  _arguments -S $endopt --allow-empty ':object:__git_commits' && ret=0
	  ;;
        (merge)
          _arguments -S -s $endopt \
            '(-s --strategy)--abort[abort an in-progress notes merge]' \
            '(-s --strategy)--commit[finalize an in-progress notes merge]' \
	    '(-q --quiet)'{-q,--quiet}'[be quiet]' \
            '(-v --verbose)'{-v,--verbose}'[be more verbose]' \
            '(--abort --commit)'{-s,--strategy=}'[resolve conflicts using the given strategy]' \
            ': :__git_notes_refs' && ret=0
          ;;
	(prune)
	  _arguments -s -S $endopt \
	    '(-v --verbose)'{-v,--verbose}'[be more verbose]' \
	    '(-n --dry-run)'{-n,--dry-run}"[don't remove anything, just report what would be deleted]" && ret=0
          ;;
	(remove)
	  _arguments -S $endopt --ignore-missing --stdin ':object:__git_commits' && ret=0
	  ;;
        (append)
          _arguments -S -s $endopt \
            '*'{-m+,--message=}'[use given note message]:message' \
            '*'{-F+,--file=}'[take note message from given file]:note message file:_files' \
            '(-C --reuse-message)'{-C+,--reuse-message=}'[take note message from given blob object]: :__git_blobs' \
            '(-c --reedit-message)'{-c+,--reedit-message=}'[take note message from given blob object and edit it]: :__git_blobs' \
            ': :__git_commits' && ret=0
          ;;
        (get-ref)
          _nothing
          ;;
        (*)
          _default && ret=0
          ;;
      esac
      ;;
  esac

  return ret
}

(( $+functions[_git-pull] )) ||
_git-pull () {
  local -a merge_options fetch_options
  __git_setup_merge_options
  __git_setup_fetch_options

  _arguments -S -s $endopt \
    $merge_options \
    '(-r --rebase --no-rebase)'{-r=-,--rebase=-}'[perform a rebase after fetching]::rebase after fetching:((
      true\:"rebase after fetching"
      false\:"merge after fetching"
      merges\:"try to rebase merges instead of skipping them"
      preserve\:"rebase and preserve merges"
      interactive\:"allow list of commits to be edited"
    ))' \
    '(-r --rebase            )--no-rebase[do not perform a rebase after fetching]' \
    $fetch_options \
    '(--no-tags -t --tags)--no-tags[disable automatic tag following]' \
    ': :__git_any_repositories' \
    '*: :__git_ref_specs_fetchy'
}

(( $+functions[_git-push] )) ||
_git-push () {
  local ret=1
  local -a sign
  sign=(
    {yes,true}'\:always,\ and\ fail\ if\ unsupported\ by\ server'
    {no,false}'\:never'
    if-asked'\:iff\ supported\ by\ server'
  )
  # NOTE: For --receive-pack we use _files to complete, even though this will
  # only complete files on the local end, not the remote end.  Still, it may be
  # helpful to get some sort of completion going, perhaps modifying the path
  # later on to match the remote end.
  _arguments -S -s $endopt \
    '--all[push all refs under refs/heads/]' \
    '--prune[remove remote branches that do not have a local counterpart]' \
    '--mirror[push all refs under refs/heads/ and refs/tags/ and delete non-existing refs]' \
    '(-n --dry-run)'{-n,--dry-run}'[do everything except actually send the updates]' \
    '--porcelain[produce machine-readable output]' \
    '(-d --delete)'{-d,--delete}'[delete all listed refs from the remote repository]' \
    '--tags[all tags under refs/tags are pushed]' \
    '--follow-tags[also push missing annotated tags reachable from the pushed refs]' \
    '(--receive-pack --exec)'{--receive-pack=-,--exec=-}'[path to git-receive-pack on remote]:remote git-receive-pack:_files' \
    '(--force-with-lease --no-force-with-lease)*--force-with-lease=-[allow refs that are not ancestors to be updated if current ref matches expected value]::ref and expectation:->lease' \
    '(--force-with-lease --no-force-with-lease)--no-force-with-lease[cancel all previous force-with-lease specifications]' \
    '--force-if-includes[require remote updates to be integrated locally]' \
    '(-f --force)'{-f,--force}'[allow refs that are not ancestors to be updated]' \
    '(:)--repo=[default repository to use]:repository:__git_any_repositories' \
    '(-u --set-upstream)'{-u,--set-upstream}'[add upstream reference for each branch that is up to date or pushed]' \
    '(       --no-thin)--thin[try to minimize number of objects to be sent]' \
    '(--thin          )--no-thin[do not try to minimize number of objects to be sent]' \
    '(-q --quiet -v --verbose --progress)'{-q,--quiet}'[suppress all output]' \
    '(-q --quiet -v --verbose)'{-v,--verbose}'[output additional information]' \
    '(-q --quiet)--progress[output progress information]' \
    '(--verify)--no-verify[bypass the pre-push hook]' \
    '--recurse-submodules=[submodule handling]:submodule handling:((
        check\:"refuse to push if submodule commit not to be found on remote"
        on-demand\:"push all changed submodules"
	only\:"submodules will be recursively pushed while the superproject is left unpushed"
	no\:"no submodule handling"))' \
    "(--no-signed --signed)--sign=-[GPG sign the push]::signing enabled:(($^^sign))" \
    '(--no-signed --sign)--signed[GPG sign the push]' \
    "(--sign --signed)--no-signed[don't GPG sign the push]" \
    '--atomic[request atomic transaction on remote side]' \
    '*'{-o+,--push-option=}'[transmit string to server to pass to pre/post-receive hooks]:string' \
    '(-4 --ipv4 -6 --ipv6)'{-4,--ipv4}'[use IPv4 addresses only]' \
    '(-4 --ipv4 -6 --ipv6)'{-6,--ipv6}'[use IPv6 addresses only]' \
    ': :__git_any_repositories' \
    '*: :__git_ref_specs_pushy' && ret=0

  case $state in
    (lease)
       compset -P '*:'
       if [[ -n ${IPREFIX#*=} ]]; then
         _guard '[[:xdigit:]]#' "expected value" && ret=0
       else
         __git_remote_branch_names_noprefix && ret=0
       fi
      ;;
  esac

  return ret
}

(( $+functions[_git-range-diff] )) ||
_git-range-diff () {
  local -a diff_options
  __git_setup_diff_options

  _arguments -s -S $endopt \
    '--creation-factor=[specify weighting for creation]:weighting (percent)' \
    '--no-dual-color[use simple diff colors]' \
    '(--no-notes)*--notes=[show notes that annotate commit, with optional ref argument show this notes ref instead of the default notes ref(s)]:: :__git_notes_refs' \
    '(--right-only)--left-only[only emit output related to the first range]' \
    '(--left-only)--right-only[only emit output related to the second range]' \
    $diff_options \
    '1:range 1:__git_commit_ranges' \
    '2:range 2:__git_commit_ranges' \
    '3:revision 2:__git_commits'
}

(( $+functions[_git-rebase] )) ||
_git-rebase () {
  local -a autosquash_opts

  if (( words[(I)-i|--interactive] )); then
    autosquash_opts=(
      '(             --no-autosquash)--autosquash[check for auto-squash boundaries]'
      '(--autosquash                )--no-autosquash[do not check for auto-squash boundaries]')
  fi

  _arguments -s -S $endopt \
    - actions \
    '(-)--continue[continue after resolving merge conflict]' \
    '(-)--abort[abort current rebase]' \
    '(-)--edit-todo[edit interactive instruction sheet in an editor]' \
    '(-)--skip[skip the current patch]' \
    '(-)--quit[abort but keep HEAD where it is]' \
    '(-)--show-current-patch[show the patch file being applied or merged]' \
    - options \
    '(--onto --root)--keep-base[use the merge-base of upstream and branch as the current base]' \
    '(-S --gpg-sign --no-gpg-sign)'{-S-,--gpg-sign=-}'[GPG-sign the commit]::key id' \
    "(-S --gpg-sign --no-gpg-sign)--no-gpg-sign[don't GPG-sign the commit]" \
    '(-q --quiet -v --verbose --stat -n --no-stat)'{-q,--quiet}'[suppress all output]' \
    '(-q --quiet -v --verbose --stat -n --no-stat)'{-v,--verbose}'[output additional information]' \
    '(-n --no-stat)'{-n,--no-stat}"[don't show diffstat of what changed upstream]" \
    '--rerere-autoupdate[update the index with reused conflict resolution if possible]' \
    '--no-verify[bypass the pre-rebase hook]' \
    '(--apply -m --merge -s --strategy -X --strategy-option --auto-squash --no-auto-squash -r --rebase-merges -i --interactive -x --exec --empty --reapply-cherry-picks --edit-todo --reschedule-failed-exec)-C-[ensure that given lines of surrounding context match]: :__git_guard_number "lines of context"' \
    '(-f --force-rebase)'{-f,--force-rebase}'[force rebase even if current branch descends from commit rebasing onto]' \
    '(-i --interactive)--ignore-whitespace[ignore changes in whitespace]' \
    '(--apply -m --merge -s --strategy -X --strategy-option --auto-squash --no-auto-squash -r --rebase-merges -i --interactive -x --exec --empty --reapply-cherry-picks --edit-todo --reschedule-failed-exec)--whitespace=-[detect a new or modified line that has whitespace errors]: :__git_apply_whitespace_strategies' \
    '(-i --interactive)--committer-date-is-author-date[use author date as committer date]' \
    '(-f --force-rebase)'{--ignore-date,--reset-author-date}'[ignore author date and use current date]' \
    '(-m --merge -s --strategy -X --strategy-option --auto-squash --no-auto-squash -r --rebase-merges -i --interactive -x --exec --empty --reapply-cherry-picks --edit-todo --reschedule-failed-exec)--apply[use apply strategies to rebase]' \
    '(-m --merge --apply --whitespace -C)'{-m,--merge}'[use merging strategies to rebase]' \
    '(-i --interactive --ignore-whitespace --apply --whitespace -C --committer-date-is-author-date)'{-i,--interactive}'[make a list of commits to be rebased and open in $EDITOR]' \
    '(--apply --whitespace -C)--empty=[specify how to handle commits that become empty]:handling:(drop keep ask)' \
    '(--apply --whitespace -C)'{-x+,--exec=}'[with -i\: append "exec <cmd>" after each line]:command:_command_names -e' \
    '(-r --rebase-merges --apply --whitespace -C)'{-r-,--rebase-merges=-}'[try to rebase merges instead of skipping them]::option:(rebase-cousins no-rebase-cousins)' \
    '(--apply --whitespace -C)*'{-s+,--strategy=}'[use given merge strategy]:merge strategy:__git_merge_strategies' \
    '(--apply --whitespace -C)*'{-X+,--strategy-option=}'[pass merge-strategy-specific option to merge strategy]: :_git_strategy_options' \
    '(1 --keep-base --fork-point)--root[rebase all reachable commits]' \
    $autosquash_opts \
    '(--autostash --no-autostash)--autostash[stash uncommitted changes before rebasing and apply them afterwards]' \
    "(--autostash --no-autostash)--no-autostash[don't stash uncommitted changes before rebasing and apply them afterwards]" \
    '(--root)--fork-point[use merge-base --fork-point to refine upstream]' \
    '--signoff[add Signed-off-by: trailer to the commit message]' \
    '--no-ff[cherry-pick all rebased commits with --interactive, otherwise synonymous to --force-rebase]' \
    '(--keep-base)--onto=[start new branch with HEAD equal to given revision]:newbase:__git_revisions' \
    "(--apply --whitespace -C)--reschedule-failed-exec[automatically re-schedule any 'exec' that fails]" \
    '(--apply --whitespace -C)--reapply-cherry-picks[apply all changes, even those already present upstream]' \
    ':upstream branch:__git_revisions' \
    '::working branch:__git_revisions'
}

(( $+functions[_git-reset] )) ||
_git-reset () {
  local curcontext=$curcontext state line ret=1
  typeset -A opt_args

  _arguments -C -s -S $endopt \
      '(       --mixed --hard --merge --keep -p --patch -- *)--soft[do not touch the index file nor the working tree]' \
      '(--soft         --hard --merge --keep -p --patch -- *)--mixed[reset the index but not the working tree (default)]' \
      '(--soft         --hard --merge --keep -p --patch -- *)'{-N,--intent-to-add}'[record only the fact that removed paths will be added later]' \
      '(--soft --mixed        --merge --keep -p --patch -- *)--hard[match the working tree and index to the given tree]' \
      '(--soft --mixed --hard         --keep -p --patch -- *)--merge[reset out of a conflicted merge]' \
      '(--soft --mixed --hard --merge        -p --patch -- *)--keep[like --hard, but keep local working tree changes]' \
      '--recurse-submodules=-[control recursive updating of submodules]::reset:__git_commits' \
      '(-p --patch)'{-p,--patch}'[select diff hunks to remove from the index]' \
      '(-q --quiet)'{-q,--quiet}'[suppress all output]' \
      '(*)--pathspec-from-file=[read pathspec from file]:file:_files' \
      '(*)--pathspec-file-nul[pathspec elements are separated with NUL character]' \
      '(--soft --mixed --hard --merge --keep):: :__git_commits' \
      '(--soft --mixed --hard --merge --keep)*:: :->file' && ret=0

  case $state in
    (file)
      local tree=HEAD
      if zstyle -t :completion:${curcontext}: verbose; then
        if ! tree=$(_call_program headed git rev-parse --verify HEAD); then
          # well-known sha1 of the empty tree
          tree=4b825dc642cb6eb9a060e54bf8d69288fbee4904
        fi
      fi
      if [[ -n $line[1] ]] && __git_is_treeish $line[1]; then
        tree=$line[1]
      fi
      __git_ignore_line __git_treeish-to-index_files $tree && ret=0
  esac

  return ret
}

(( $+functions[_git-restore] )) ||
_git-restore() {
  local curcontext="$curcontext" state line expl ret=1
  local -A opt_args

  _arguments -C -s -S $endopt \
    '(-s --source)'{-s,--source=}'[specify which tree-ish to checkout from]:source tree:->sources' \
    '(-S --staged)'{-S,--staged}'[restore the index]' \
    '(-W --worktree)'{-W,--worktree}'[restore the working tree (default)]' \
    '--ignore-unmerged[ignore unmerged entries]' \
    '--overlay[never remove files when restoring]' '!(--overlay)--no-overlay' \
    '(-q --quiet --no-progress)'{-q,--quiet}'[suppress feedback messages]' \
    '--recurse-submodules=-[control recursive updating of submodules]::checkout:__git_commits' \
    '(-q --quiet --progress)--no-progress[suppress progress reporting]' \
    '(--no-progress)--progress[force progress reporting]' \
    '(-m --merge)'{-m,--merge}'[perform a 3-way merge with the new branch]' \
    '--conflict=[change how conflicting hunks are presented]:conflict style [merge]:(merge diff3)' \
    '(-2 --ours -3 --theirs -m --merge)'{-2,--ours}'[checkout our version for unmerged files]' \
    '(-2 --ours -3 --theirs -m --merge)'{-3,--theirs}'[checkout their version for unmerged files]' \
    '(-p --patch)'{-p,--patch}'[select hunks interactively]' \
    "--ignore-skip-worktree-bits[don't limit pathspecs to sparse entries only]" \
    '(*)--pathspec-from-file=[read pathspec from file]:file:_files' \
    '(*)--pathspec-file-nul[pathspec elements are separated with NUL character]' \
    '*:path spec:->pathspecs' && ret=0

  case $state in
    pathspecs)
      integer opt_S opt_W
      [[ -n ${opt_args[(I)-S|--staged]} ]] && opt_S=1
      [[ -n ${opt_args[(I)-W|--worktree]} ]] && opt_W=1
      if (( opt_S && opt_W ))
      then
        __git_ignore_line __git_changed_files && ret=0
      elif (( opt_S ))
      then
        __git_ignore_line __git_changed-in-index_files && ret=0
      else
        __git_ignore_line __git_changed-in-working-tree_files && ret=0
      fi
    ;;
    sources)
      # if a path has already been specified, use it to select commits
      git_commit_opts=(-- $line)
      __git_commits_prefer_recent -O expl:git_commit_opts && ret=0
    ;;
  esac

  return ret
}

(( $+functions[_git-revert] )) ||
_git-revert () {
  _arguments -S -s $endopt \
    '(- :)--quit[end revert or cherry-pick sequence]' \
    '(- :)--continue[resume revert or cherry-pick sequence]' \
    '(- :)--abort[cancel revert or cherry-pick sequence]' \
    '(- :)--skip[skip current commit and continue]' \
    '--cleanup=[specify how to strip spaces and #comments from message]:mode:_git_cleanup_modes' \
    '(-e --edit --no-edit)'{-e,--edit}'[edit the commit before committing the revert]' \
    '(-e --edit --no-edit)--no-edit[do not edit the commit message before committing the revert]' \
    '(-m --mainline)'{-m+,--mainline=}'[pick which parent is mainline]:parent number' \
    '--rerere-autoupdate[update the index with reused conflict resolution if possible]' \
    '(-n --no-commit)'{-n,--no-commit}'[do not commit the reversion]' \
    '(-s --signoff)'{-s,--signoff}'[add Signed-off-by line at the end of the commit message]' \
    '--strategy=[use given merge strategy]:merge strategy:__git_merge_strategies' \
    '*'{-X+,--strategy-option=}'[pass merge-strategy-specific option to merge strategy]: :_git_strategy_options' \
    '(-S --gpg-sign --no-gpg-sign)'{-S-,--gpg-sign=-}'[GPG-sign the commit]::key id' \
    "(-S --gpg-sign --no-gpg-sign)--no-gpg-sign[don't GPG-sign the commit]" \
    ': :__git_recent_commits'
}

(( $+functions[_git-rm] )) ||
_git-rm () {
  local curcontext=$curcontext state line ret=1
  declare -A opt_args

  _arguments -C -S -s $endopt \
    '(-f --force)'{-f,--force}'[override the up-to-date check]' \
    '(-n --dry-run)'{-n,--dry-run}'[do not actually remove the files, just show if they exist in the index]' \
    '-r[allow recursive removal when a leading directory-name is given]' \
    '--cached[only remove files from the index]' \
    '--ignore-unmatch[exit with 0 status even if no files matched]' \
    '--sparse[allow updating entries outside of sparse-checkout cone]' \
    '(*)--pathspec-from-file=[read pathspec from file]:file:_files' \
    '(*)--pathspec-file-nul[pathspec elements are separated with NUL character]' \
    '(-q --quiet)'{-q,--quiet}"[don't list removed files]" \
    '*:: :->file' && ret=0

  case $state in
    (file)
      __git_cached_files && ret=0
      ;;
  esac

  return ret
}

(( $+functions[_git-shortlog] )) ||
_git-shortlog () {
  local curcontext=$curcontext state line ret=1
  declare -A opt_args

  local -a revision_options
  __git_setup_revision_options

  # TODO: should take all arguments found in setup_revisions() (probably more
  # or less what git-rev-list takes).
  _arguments -C -S -s $endopt \
    '(: -)'{-h,--help}'[print a short usage message and exit]' \
    '(-n --numbered)'{-n,--numbered}'[sort according to number of commits]' \
    '(-s --summary)'{-s,--summary}'[suppress commit description]' \
    '(-e --email)'{-e,--email}'[show email address of each author]' \
    '-w-[linewrap the output]:: :->wrap' \
    '*--group=[group commits by field]: : _values -S\: field author committer trailer\:trailer' \
    '(-c --committer)'{-c,--committer}'[alias for --group=committer]' \
    $revision_options \
    '(-)--[start file arguments]' \
    '*:: :->commit-range-or-file' && ret=0

  case $state in
    (wrap)
      if [[ -prefix [[:digit:]]#,[[:digit:]]#,[[:digit:]]# ]]; then
        compset -P '[[:digit:]]#,[[:digit:]]#,'
        __git_guard_number 'indent of second and subsequent wrapped lines'
      elif [[ -prefix [[:digit:]]#,[[:digit:]]# ]]; then
        compset -P '[[:digit:]]#,'
        compset -S ',[[:digit:]]#'
        __git_guard_number 'indent of first wrapped line'
      else
        compset -S ',[[:digit:]]#,[[:digit:]]#'
        __git_guard_number 'line width'
      fi
      ;;
    (commit-range-or-file)
      case $CURRENT in
        (1)
          if [[ -n ${opt_args[(I)--]} ]]; then
            __git_cached_files && ret=0
          else
            _alternative \
              'commit-ranges::__git_commit_ranges' \
              'cached-files::__git_cached_files' && ret=0
          fi
          ;;
        (*)
          # TODO: Write a wrapper function that checks whether we have a
          # committish range or committish and calls __git_tree_files
          # appropriately.
          if __git_is_committish_range $line[1]; then
            __git_tree_files ${PREFIX:-.} $(__git_committish_range_last $line[1]) && ret=0
          elif __git_is_committish $line[1]; then
            __git_tree_files ${PREFIX:-.} $line[1] && ret=0
          else
            __git_cached_files && ret=0
          fi
          ;;
      esac
  esac

  return ret
}

(( $+functions[_git-show] )) ||
_git-show () {
  local curcontext=$curcontext state line ret=1
  typeset -A opt_args

  local -a log_options revision_options
  __git_setup_log_options
  __git_setup_revision_options

  _arguments -C -s $endopt \
    $log_options \
    $revision_options \
    '(-q --quiet)'{-q,--quiet}'[suppress diff output]' \
    '*:: :->object' && ret=0

  case $state in
    (object)
      _alternative \
        'commits::__git_commits' \
        'tags::__git_tags' \
        'trees::__git_trees' \
        'blobs::__git_blobs' && ret=0
      ;;
  esac

  return ret
}

(( $+functions[_git-sparse-checkout] )) ||
_git-sparse-checkout() {
  local curcontext="$curcontext" state state_descr line ret=1
  local -A opt_args

  _arguments -C \
    ': :->command' \
    '*::: := ->option-or-argument' && ret=0

  case $state in
    (command)
      local -a commands

      commands=(
        list:'describe the patterns in the sparse-checkout file'
        init:'enable the core.sparseCheckout setting'
        set:'write a set of patterns to the sparse-checkout file'
        add:'update the sparse-checkout file to include additional patterns'
        reapply:'reapply the sparsity pattern rules to paths in the working tree'
        disable:'disable the config setting, and restore all files in the working directory'
      )

      _describe -t commands command commands && ret=0
    ;;
    (option-or-argument)
      curcontext=${curcontext%:*}-$line[1]:
      case $line[1] in
        init)
          _arguments \
            '--cone[allow for better performance with a limited set of patterns]' \
            '--no-sparse-index[rewrite index to not be sparse]'
        ;;
        set|add)
          _arguments -S \
            '--stdin[read patterns from input]' \
            '*:pattern:_files' && ret=0
        ;;
      esac
    ;;
  esac

  return ret
}

(( $+functions[_git-stash] )) ||
_git-stash () {
  local curcontext=$curcontext state line ret=1
  declare -A opt_args
  local -a save_arguments

  save_arguments=(
    '(-p --patch -a --all -u --include-untracked)'{-p,--patch}'[interactively select hunks from diff between HEAD and working tree to stash]'
    '(-k --keep-index --no-keep-index)'{-k,--keep-index}'[all changes already added to the index are left intact]'
    '(-k --keep-index)--no-keep-index[all changes already added to the index are undone]'
    '(-q --quiet)'{-q,--quiet}'[suppress all output]'
    '(-p --patch -a --all -u --include-untracked)'{-u,--include-untracked}'[include untracked files]'
    '(-p --patch -a --all -u --include-untracked)'{-a,--all}'[include ignored files]'
    '(* -p --patch)--pathspec-from-file=[read pathspec from file]:file:_files'
    '(* -p --patch)--pathspec-file-nul[pathspec elements are separated with NUL character]'
  )

  _arguments -C \
    '*::: :->args' \
    '(-m --message)'{-m+,--message=}'[specify stash description]:description' \
    ${save_arguments//#\(/(* } && ret=0

  if [[ -n $state ]]; then
    if (( CURRENT == 1 )); then
      local -a commands

      commands=(
        {push,save}:'save your local modifications to a new stash'
        list:'list the stashes that you currently have'
        show:'show the changes recorded in the stash as a diff'
        pop:'remove and apply a single stashed state from the stash list'
        apply:'apply the changes recorded in the stash'
        branch:'branch off at the commit at which the stash was originally created'
        clear:'remove all the stashed states'
        drop:'remove a single stashed state from the stash list'
        create:'create a stash without storing it in the ref namespace'
      )

      _describe -t commands command commands && ret=0
    else
      curcontext=${curcontext%:*}-$line[1]:
      compset -n 1

      case $line[1] in
        (save)
          _arguments -S $endopt \
            $save_arguments \
            ':: :_guard "([^-]?#|)" message' && ret=0
          ;;
        (push)
          _arguments -S $endopt \
            $save_arguments \
            '(-m --message)'{-m+,--message=}'[specify stash description]:description' \
            '*: : __git_ignore_line __git_modified_files' && ret=0
          ;;
        (--)
            __git_modified_files
          ;;
        (list)
          local -a log_options revision_options
          __git_setup_log_options
          __git_setup_revision_options

          _arguments -s \
            $log_options \
            $revision_options && ret=0
          ;;
        (show)
          local diff_options
          __git_setup_diff_options

          _arguments -S -s $endopt \
            $diff_options \
            ':: :__git_stashes' && ret=0
          ;;
        (pop|apply)
          _arguments -S $endopt \
            '--index[try to reinstate the changes added to the index as well]' \
            '(-q --quiet)'{-q,--quiet}'[suppress all output]' \
            ':: :__git_stashes' && ret=0
          ;;
        (branch)
          _arguments \
            ': :__git_guard_branch-name' \
            ':: :__git_stashes' && ret=0
          ;;
        (clear)
          _nothing
          ;;
        (drop)
          _arguments -S $endopt \
            '(-q --quiet)'{-q,--quiet}'[suppress all output]' \
            ':: :__git_stashes' && ret=0
          ;;
        (create)
          _nothing
          ;;
        (*)
          _nothing
          ;;
      esac
    fi
  fi

  return ret
}

(( $+functions[_git-status] )) ||
_git-status () {
  local -a branch_opts

  if (( $words[(I)-s|--short|--porcelain|-z] )); then
    branch_opts=('(-b --branch)'{-b,--branch}'[show branch and tracking info]')
  fi

  _arguments -S -s $endopt \
    '(-s --short --column --no-column --show-stash)'{-s,--short}'[output in short format]' \
    $branch_opts \
    '(-s --short)--porcelain=-[produce machine-readable output]:version:(v1)' \
    '(-s --short)--show-stash[show stash information]' \
    '!(--no-ahead-behind)--ahead-behind' \
    "--no-ahead-behind[don't display detailed ahead/behind counts relative to upstream branch]" \
    '(-u --untracked-files)'{-u-,--untracked-files=-}'[show untracked files]::mode:((no\:"show no untracked files" \
                                                                                     normal\:"show untracked files and directories" \
                                                                                     all\:"also show untracked files in untracked directories (default)"))' \
    '--ignore-submodules[ignore changes to submodules]:: :__git_ignore_submodules_whens' \
    '--ignored=-[show ignored files as well]:mode [traditional]:(traditional matching no)' \
    '(-z --null --column --no-column)'{-z,--null}'[use NUL termination on output]' \
    '(--no-column -z --null)--column=-[display in columns]:: :_git_column_layouts' \
    "(--column)--no-column[don't display in columns]" \
    "(--no-renames -M --find-renames)--no-renames[don't detect renames]" \
    '(--no-renames -M --find-renames)-M[detect renames]' \
    '(--no-renames -M --find-renames)--find-renames=-[detect renames, optionally set similarity index]::similarity' \
    '*: :__git_ignore_line_inside_arguments _files'
}

(( $+functions[_git-submodule] )) ||
_git-submodule () {
  local curcontext=$curcontext state line ret=1
  declare -A opt_args

  _arguments -C \
    '(-q --quiet)'{-q,--quiet}'[suppress all output]' \
    ': :->command' \
    '*:: :->option-or-argument' && ret=0

  case $state in
    (command)
      declare -a commands

      commands=(
        add:'add given repository as a submodule'
        status:'show the status of a submodule'
        init:'initialize a submodule'
        deinit:'unregister a submodule'
        update:'update a submodule'
        set-branch:'set default remote tracking branch for the submodule'
        set-url:'set URL of the specified submodule'
        summary:'show commit summary between given commit and working tree/index'
        foreach:'evaluate shell command in each checked-out submodule'
	absorbgitdirs:'move the git directory of a submodule into its superprojects'
        sync:'synchronize submodule settings')

      _describe -t commands command commands && ret=0
      ;;
    (option-or-argument)
      curcontext=${curcontext%:*}-$line[1]:

      case $line[1] in
        (add)
          # TODO: Second argument should only complete relative paths inside
          # the current repository.
          _arguments -S \
            '(-q --quiet)'{-q,--quiet}'[suppress all output]' \
            '(-b --branch)'{-b,--branch}'[branch of repository to add as submodule]' \
            '(-f --force)'{-f,--force}'[allow adding an otherwise ignored submodule path]' \
            '--name[use given name instead of defaulting to its path]:name' \
            '--reference=[remote repository to clone]: :__git_any_repositories' \
            ': :__git_any_repositories' \
            ':: :_directories' && ret=0
          ;;
        (status)
          _arguments -S \
            '(-q --quiet)'{-q,--quiet}'[suppress all output]' \
            '--cached[use commit stored in the index]' \
            '--recursive[traverse submodules recursively]' \
            '*: :__git_ignore_line_inside_arguments __git_submodules' && ret=0
          ;;
        (init)
          _arguments -S \
            '(-q --quiet)'{-q,--quiet}'[suppress all output]' \
            '*: :__git_ignore_line_inside_arguments __git_submodules' && ret=0
          ;;
        (deinit)
          _arguments -S \
            '(-f --force)'{-f,--force}'[remove submodule worktree even if local modifications are present]' \
	    '(*)--all[remove all submodules]' \
            '*: :__git_ignore_line_inside_arguments __git_submodules' && ret=0
          ;;
        (update)
          # TODO: --init not properly documented.
          _arguments -S \
            '(-q --quiet)'{-q,--quiet}'[suppress all output]' \
            '(-N --no-fetch)'{-N,--no-fetch}'[do not fetch new objects from repository]' \
	    '(--merge --rebase)--checkout[checkout commit recorded in the superproject in the submodule on a detached HEAD]' \
	    '(--checkout --rebase)--merge[merge commit recorded in superproject into current branch of submodule]' \
	    '(--checkout --merge)--rebase[rebase current branch onto commit recorded in superproject]' \
	    '--no-recommend-shallow[ignore submodule.<name>.shallow from .gitmodules]' \
            '--reference=[remote repository to clone]: :__git_any_repositories' \
            '--recursive[traverse submodules recursively]' \
            '--remote[use the status of the submodule''s remote-tracking branch]' \
            '--force[discard local changes by checking out the current up-to-date version]' \
            '--init[initialize uninitialized submodules]' \
            '--single-branch[clone only one branch]' \
            '*: :__git_ignore_line_inside_arguments __git_submodules' && ret=0
	;;
	(set-branch)
          _arguments -C -A '-*' \
	    '(-d --default)'{-d,--default}'[remove config key to cause the tracking branch to default to master]' \
	    '(-b --branch)'{-b,--branch=}'[specify the remote branch]:remote branch' \
	    '1:path:_directories'
        ;;
	(set-url)
          _arguments -C -A '-*' \
            '1:path:_directories' \
            '2:url:_urls' && ret=0
        ;;
        (summary)
          _arguments -C -A '-*' \
            '(-q --quiet)'{-q,--quiet}'[suppress all output]' \
            '(--files)--cached[use commit stored in the index]' \
            '(--cached)--files[compare commit in index with submodule HEAD commit]' \
            '(-n --summary-limit)'{-n,--summary-limit=}'[limit summary size]: :__git_guard_number "limit"' \
            '(-)--[start submodule arguments]' \
            '*:: :->commit-or-submodule' && ret=0

          case $state in
            (commit-or-submodule)
              if (( CURRENT == 1 )) && [[ -z ${opt_args[(I)--]} ]]; then
                _alternative \
                  'commits::__git_commits' \
                  'submodules::__git_submodules' && ret=0
              else
                __git_ignore_line __git_submodules && ret=0
              fi
              ;;
          esac
          ;;
        (foreach)
          _arguments -S \
            '(-q --quiet)'{-q,--quiet}'[suppress all output]' \
            '--recursive[traverse submodules recursively]' \
            '(-):command: _command_names -e' \
            '*::arguments: _normal' && ret=0
          ;;
        (sync)
          _arguments -S \
            '--recursive[traverse submodules recursively]' \
            '(-q --quiet)'{-q,--quiet}'[suppress all output]' \
            '*: :__git_ignore_line_inside_arguments __git_submodules' && ret=0
          ;;
	(absorbgitdirs)
	  _arguments -S \
            '(-q --quiet)'{-q,--quiet}'[suppress all output]' \
	    '*:path:_directories'
	;;
        (*)
          _default
          ;;
      esac
      ;;
  esac

  return ret
}

(( $+functions[_git-subtree] )) ||
_git-subtree () {
  local curcontext="$curcontext" state state_descr line ret=1
  declare -A opt_args

  # TODO: -P should only complete paths inside the current repository.
  _arguments -C \
    '(-q --quiet)'{-q,--quiet}'[suppress progress output]' \
    '(-P --prefix)'{-P+,--prefix=}'[the path to the subtree in the repository to manipulate]: :_directories' \
    '-d[show debug messages]' \
    ': :->command' \
    '*::: := ->option-or-argument' && ret=0

  case $state in
    (command)
      declare -a commands

      commands=(
        add:'create the subtree by importing its contents'
        merge:'merge recent changes up to specified commit into the subtree'
        pull:'fetch from remote repository and merge recent changes into the subtree'
        push:'does a split and `git push`'
        split:'extract a new synthetic project history from a subtree')

      _describe -t commands command commands && ret=0
    ;;
    (option-or-argument)
      curcontext=${curcontext%:*}-$line[1]:
      case $line[1] in
        (add)
          _arguments \
            '(-q --quiet)'{-q,--quiet}'[suppress progress output]' \
            '(-m --message)'{-m+,--message=}'[use the given message as the commit message for the merge commit]:message' \
            '(-P --prefix)'{-P+,--prefix=}'[the path to the subtree in the repository to manipulate]: :_directories' \
            '--squash[import only a single commit from the subproject]' \
            ': :__git_any_repositories_or_references' \
            ':: :__git_ref_specs' && ret=0
          # TODO: the use of __git_ref_specs isn't quite right: it will
          # complete "foo:bar" values which git-subtree(1) doesn't take.  What
          # we should complete here is what's on *one* side of the colon in
          # __git_ref_specs.
	;;
        (merge)
          _arguments -S \
            '(-q --quiet)'{-q,--quiet}'[suppress progress output]' \
            '(-P --prefix)'{-P+,--prefix=}'[the path to the subtree in the repository to manipulate]: :_directories' \
            '(-m --message)'{-m+,--message=}'[use the given message as the commit message for the merge commit]:message' \
            '--squash[import only a single commit from the subproject]' \
            ': :__git_references' && ret=0
	;;
        (pull)
          _arguments -S \
            '(-q --quiet)'{-q,--quiet}'[suppress progress output]' \
            '(-P --prefix)'{-P+,--prefix=}'[the path to the subtree in the repository to manipulate]: :_directories' \
            '(-m --message)'{-m+,--message=}'[use the given message as the commit message for the merge commit]:message' \
            '--squash[import only a single commit from the subproject]' \
            ': :__git_any_repositories' \
            ':: :__git_ref_specs' && ret=0
	;;
        (push)
          _arguments -S \
            '(-q --quiet)'{-q,--quiet}'[suppress progress output]' \
            '(-P --prefix)'{-P+,--prefix=}'[the path to the subtree in the repository to manipulate]: :_directories' \
            '(-m --message)'{-m+,--message=}'[use the given message as the commit message for the merge commit]:message' \
            ': :__git_any_repositories' \
            ':: :__git_ref_specs' && ret=0
	;;
        (split)
          _arguments -S \
	    '--annotate[add a prefix to commit message of new commits]:prefix' \
            '(-q --quiet)'{-q,--quiet}'[suppress progress output]' \
            '(-P --prefix)'{-P+,--prefix=}'[specify path to the subtree in the repository to manipulate]: :_directories' \
            '(-b --branch)'{-b,--branch=}'[create a new branch]' \
            '--onto=[try connecting new tree to an existing one]: :__git_ref_specs' \
            '(-m --message)'{-m+,--message=}'[specify commit message for the merge]:message' \
            '--ignore-joins[ignore prior --rejoin commits]' \
            '--onto=[try connecting new tree to an existing one]: :__git_ref_specs' \
            '--rejoin[merge the new branch back into HEAD]' \
            '*: :__git_references' && ret=0
	;;
        (*)
          _default && ret=0
	;;
      esac
    ;;
  esac

  return ret
}

(( $+functions[_git-switch] )) ||
_git-switch() {
  local curcontext="$curcontext" state line expl ret=1
  local -A opt_args

  _arguments -C -s -S $endopt \
    '(-c --create -C --force-create -d --detach --orphan --ignore-other-worktrees 1)'{-c,--create}'[create and switch to a new branch]:branch:->branches' \
    '(-c --create -C --force-create -d --detach --orphan --ignore-other-worktrees 1)'{-C,--force-create}'[create/reset and switch to a branch]:branch:->branches' \
    "(--guess --orphan 2)--no-guess[don't second guess 'git switch <no-such-branch>']" \
    "(--no-guess -t --track -d --detach --orphan 2)--guess[second guess 'git switch <no-such-branch> (default)]" \
    '(-f --force --discard-changes -m --merge --conflict)'{-f,--force,--discard-changes}'[throw away local modifications]' \
    '(-q --quiet --no-progress)'{-q,--quiet}'[suppress feedback messages]' \
    '--recurse-submodules=-[control recursive updating of submodules]::checkout:__git_commits' \
    '(-q --quiet --progress)--no-progress[suppress progress reporting]' \
    '--progress[force progress reporting]' \
    '(-m --merge --discard-changes --orphan)'{-m,--merge}'[perform a 3-way merge with the new branch]' \
    '(--discard-changes --orphan)--conflict=[change how conflicting hunks are presented]:conflict style [merge]:(merge diff3)' \
    '(-d --detach -c --create -C --force-create --ignore-other-worktrees --orphan --guess --no-guess 1)'{-d,--detach}'[detach HEAD at named commit]' \
    '(-t --track --no-track --guess --orphan 1)'{-t,--track}'[set upstream info for new branch]' \
    "(-t --track --guess --orphan 1)--no-track[don't set upstream info for a new branch]" \
    '(-c --create -C --force-create -d --detach --ignore-other-worktrees -m --merge --conflict -t --track --guess --no-track -t --track)--orphan[create new unparented branch]: :__git_branch_names' \
    '!--overwrite-ignore' \
    "(-c --create -C --force-create -d --detach --orphan)--ignore-other-worktrees[don't check if another worktree is holding the given ref]" \
    '1: :->branches' \
    '2:start point:->start-points' && ret=0

  case $state in
    branches)
      if [[ -n ${opt_args[(i)--guess]} ]]; then
	# --guess is the default but if it has been explicitly specified,
	# we'll only complete remote branches
	__git_remote_branch_names_noprefix && ret=0
      else
	_alternative \
	  'branches::__git_branch_names' \
	  'remote-branch-names-noprefix::__git_remote_branch_names_noprefix' && ret=0
      fi
    ;;
    start-points)
      if [[ -n ${opt_args[(I)-t|--track|--no-track]} ]]; then
	# with an explicit --track, stick to remote branches
	# same for --no-track because it'd be meaningless with anything else
	__git_heads_remote && ret=0
      else
	__git_revisions && ret=0
      fi
    ;;
  esac

  return ret
}

(( $+functions[_git-tag] )) ||
_git-tag () {
  _arguments -s -S $endopt \
    - creation \
      '(-a --annotate -s --sign -u --local-user)'{-a,--annotate}'[create an unsigned, annotated tag]' \
      '(-e --edit)'{-e,--edit}'[force edit of tag message]' \
      '(-a --annotate -s --sign -u --local-user)'{-s,--sign}'[create a signed and annotated tag]' \
      '(-a --annotate -s --sign)'{-u+,--local-user=}'[create a tag, annotated and signed with the given key]: :__git_gpg_secret_keys' \
      '(-f --force)'{-f,--force}'[replace existing tag]' \
      '--create-reflog[create a reflog]' \
      '--cleanup=[specify how to strip spaces and #comments from message]:mode:_git_cleanup_modes' \
      '(-m --message -F --file)'{-F+,--file=}'[read tag message from given file]:message file:_files' \
      '(-m --message -F --file)'{-m+,--message=}'[specify tag message]:message' \
      ': :__git_tags' \
      ':: :__git_commits' \
    - deletion \
      '(-d --delete)'{-d,--delete}'[delete tags]' \
      '*:: :__git_ignore_line_inside_arguments __git_tags' \
    - listing \
      '-n+[limit line output of annotation]: :__git_guard_number "limit"' \
      '(-l --list)'{-l,--list}'[list tags matching pattern]' \
      '(--no-column)--column=-[display tag listing in columns]:: :_git_column_layouts' \
      '(--column)--no-column[do not display in columns]' \
      '*--contains=[only list tags that contain the specified commit]: :__git_commits' \
      "*--no-contains=[only list tags that don't contain the specified commit]: :__git_commits" \
      '--merged=-[print only tags that are merged]:: :__git_commits' \
      '--no-merged=-[print only tags that are not merged]:: :__git_commits' \
      '--sort=[specify how the tags should be sorted]:field:__git_ref_sort_keys' \
      '--points-at=[only list tags of the given object]: :__git_commits' \
      '--format=[specify format to use for the output]:format:__git_format_ref' \
      '--color=-[respect any colors specified in the format]::when:(always never auto)' \
      '(-i --ignore-case)'{-i,--ignore-case}'[sorting and filtering are case-insensitive]' \
      ':: :_guard "^-*" pattern' \
    - verification \
      '(-v --verify)'{-v,--verify}'[verify gpg signature of tags]' \
      '*:: :__git_ignore_line_inside_arguments __git_tags'
}

(( $+functions[_git-worktree] )) ||
_git-worktree() {
  local curcontext="$curcontext" state state_descr line ret=1
  declare -A opt_args

  _arguments -C \
    ': :->command' \
    '*::: := ->option-or-argument' && ret=0

  case $state in
    (command)
      declare -a commands args

      commands=(
        add:'create a new working tree'
        prune:'prune working tree information'
        list:'list details of each worktree'
	lock:'prevent a working tree from being pruned'
	move:'move a working tree to a new location'
	remove:'remove a working tree'
	unlock:'allow working tree to be pruned, moved or deleted'
      )

      _describe -t commands command commands && ret=0
    ;;
    (option-or-argument)
      curcontext=${curcontext%:*}-$line[1]:
      case $line[1] in
        (add)
	  if (( $words[(I)--detach] )); then
	    args=( ':branch:__git_branch_names' )
	  else
	    args=( ':commit:__git_commits' )
	  fi
          _arguments -S $endopt \
	    '(-f --force)'{-f,--force}'[checkout branch even if already checked out in another worktree]' \
	    '(-B --detach)-b+[create a new branch]: :__git_branch_names' \
	    '(-b --detach)-B+[create or reset a branch]: :__git_branch_names' \
	    '(-b -B)--detach[detach HEAD at named commit]' \
	    '--no-checkout[suppress file checkout in new worktree]' \
	    '--lock[keep working tree locked after creation]' \
	    ':path:_directories' $args && ret=0
	;;
        (prune)
          _arguments -S $endopt \
	    '(-n --dry-run)'{-n,--dry-run}"[don't remove, show only]" \
	    '(-v --verbose)'{-v,--verbose}'[report pruned objects]' \
	    '--expire[expire objects older than specified time]:time' && ret=0
	;;
        (list)
	  _arguments -S $endopt '--porcelain[machine-readable output]' && ret=0
	;;
	(lock)
	  _arguments -C -S $endopt '--reason=[specify reason for locking]:reason' ': :->worktrees' && ret=0
	;;
	(move)
	  _arguments -C \
            ': :->worktrees' \
            ':location:_directories' && ret=0
	;;
	(remove)
	  _arguments -C -S $endopt '--force[remove working trees that are not clean or that have submodules]' \
            ': :->worktrees' && ret=0
	;;
	(unlock)
	  state=worktrees
	;;
      esac
      if [[ $state = worktrees ]]; then
        __git_worktrees && ret=0
      fi
    ;;
  esac
  return ret
}

(( $+functions[_gitk] )) ||
_gitk () {
  _git-log
}

(( $+functions[_tig] )) ||
_tig () {
  _git-log
}

# Ancillary Commands (Manipulators)

(( $+functions[_git-config] )) ||
_git-config () {
  local name_arg value_arg
  local curcontext=$curcontext state line ret=1
  declare -A opt_args

  if (( words[(I)--get-regexp] )); then
    name_arg=':name regex'
  elif (( words[(I)--get-colorbool] )); then
    name_arg=':: :->is-a-tty'
  elif (( words[(I)--get-color] )); then
    name_arg='::default'
  elif (( words[(I)--remove-section|--rename-section] )); then
    name_arg=': :->section'
  elif (( words[(I)--get|--get-all] )); then
    name_arg=': :->gettable-option'
  else
    name_arg=': :->option'
  fi

  if (( words[(I)--rename-section] )); then
    value_arg=': :->section'
  else
    value_arg=': :->value'
  fi

  _arguments -C -S -s $endopt \
    '(         --system --local --worktree -f --file --blob)--global[use user-global config file]' \
    '(--global          --local --worktree -f --file --blob)--system[use system-wide config file]' \
    '(--global --system         --worktree -f --file --blob)--local[use local config file]' \
    '(--global --system --local            -f --file --blob)--worktree[use per-worktree config file]' \
    '(--global --system --local --worktree           --blob)'{-f+,--file=}'[use given config file]:config file:_files' \
    '(--global --system --local --worktree -f --file)--blob=[read config from given blob object]:blob:__git_blobs' \
    '(-t --type --bool --int --bool-or-int --bool-or-str --path --expiry-date)'{-t+,--type=}'[ensure that incoming and outgoing values are canonicalize-able as the given type]:type:(bool int bool-or-int bool-or-str path expiry-date color)' \
    '(-t --type --int --bool-or-int --bool-or-str --path --expiry-date)--bool[setting is a boolean]' \
    '(-t --type --bool --bool-or-int --bool-or-str --path --expiry-date)--int[setting is an integer]' \
    '(-t --type --bool --int --bool-or-str --path --expiry-date)--bool-or-int[setting is a boolean or integer]' \
    '(-t --type --bool --int --bool-or-int --path --expiry-date)--bool-or-str[setting is a boolean or string]' \
    '(-t --type --bool --int --bool-or-int --bool-or-str --expiry-date)--path[setting is a path]' \
    '(-t --type --bool --int --bool-or-int --bool-or-str --path)--expiry-date[setting is an expiry date]' \
    '(-z --null)'{-z,--null}'[end values with NUL and newline between key and value]' \
    '--fixed-value[use string equality when comparing values]' \
    '(--get --get-all --get-urlmatch --replace-all --add --unset --unset-all --rename-section --remove-section -e --edit --get-color --get-colorbool)--name-only[show variable names only]' \
    '(--includes)'--no-includes"[don't respect \"include.*\" directives]" \
    '(--no-includes)'--includes'[respect "include.*" directives in config files when looking up values]' \
    '(--global --system --local -f --file --blob --get-urlmatch --replace-all --add --unset --unset-all --rename-section --remove-section -e --edit --get-color --get-colorbool --show-scope)--show-origin[show origin of config]' \
    '(--global --system --local -f --file --blob --get-urlmatch --replace-all --add --unset --unset-all --rename-section --remove-section -e --edit --get-color --get-colorbool --show-origin)--show-scope[show scope of config (worktree, local, global, system, command)]' \
    '(2 --add -e --edit -l --list --name-only --rename-section --remove-section --replace-all --unset --unset-all)--default=[with --get, use specified default value when entry is missing]:default' \
    $name_arg \
    $value_arg \
    '::value regex' \
    - '(actions)' \
      '(2 --name-only)--get[get the first matching value of the key]' \
      '(2 --name-only)--get-all[get all matching values of the key]' \
      '(2)--get-regexp[like "--get-all", but interpret "name" as a regular expression]' \
      '(--name-only --show-origin)--get-urlmatch[get value specific for the URL]' \
      '(-z --null --name-only --show-origin)--replace-all[replace all values of the given key]' \
      '(3 -z --null --name-only --show-origin)--add[add new value without altering any existing ones]' \
      '(2 --bool --int --bool-or-int --bool-or-str --path -z --null --name-only --show-origin)--unset[remove the first matching value of the key]' \
      '(2 --bool --int --bool-or-int --bool-or-str --path -z --null --name-only --show-origin)--unset-all[remove all matching values of the key]' \
      '(3 --bool --int --bool-or-int --bool-or-str --path -z --null --name-only --show-origin)--rename-section[rename the given section]'  \
      '(3 --bool --int --bool-or-int --bool-or-str --path -z --null --name-only --show-origin)--remove-section[remove the given section]' \
      '(: --bool --int --bool-or-int --bool-or-str --path)'{-l,--list}'[list all variables set in config file]' \
      '(-e --edit --bool --int --bool-or-int --bool-or-str --path -z --null --name-only --show-origin)'{-e,--edit}'[open config file for editing]' \
      '(2 3 --bool --int --bool-or-int --bool-or-str --path -z --null --name-only --show-origin)--get-color[find color setting]: :->gettable-color-option' \
      '(2 3 --bool --int --bool-or-int --bool-or-str --path -z --null --name-only --show-origin)--get-colorbool[check if color should be used]: :->gettable-colorbool-option' && ret=0
  __git_config_option-or-value "$@" && ret=0
  return ret
}

(( $+functions[__git_config_option] )) ||
__git_config_option () {
  local -A opt_args=()
  local -a line=( ${words[CURRENT]%%=*} )
  local state=option
  __git_config_option-or-value "$@"
}

(( $+functions[__git_config_value] )) ||
__git_config_value () {
  local -A opt_args=()
  local -a line=( ${words[CURRENT]%%=*} ${words[CURRENT]#*=} )
  local state=value
  __git_config_option-or-value "$@"
}

# Helper to _git-config().  May be called by other functions, too, provided
# that The caller has set $line, $state, and $opt_args as _git-config() would
# set them:
#
# - set $line[1] to the option name being completed (even if completing an
#   option value).
# - set $opt_args to git-config(1) options, as set by _arguments in
#   _git-config().
# - set $state as _arguments in _git-config() would set it.
(( $+functions[__git_config_option-or-value] )) ||
__git_config_option-or-value () {
  local expl ret

  # TODO: Add support for merge.*. (merge driver), diff.*. (diff driver), and filter.*. (filter driver) options
  # (see gitattributes(5)).
  # TODO: .path options should take absolute paths.
  declare -a git_options
  git_options=(
    advice.fetchShowForcedUpdates:'show advice when git-fetch takes time to calculate forced updates::->bool:true'
    advice.pushNonFastForward:'show advice when git push refuses non-fast-forward refs::->bool:true'
    advice.pushUpdateRejected:'combined setting for advice.push*::->bool:true'
    advice.pushNonFFCurrent:'show advice when git push fails due to a non-fast-forward update to the current branch::->bool:true'
    advice.pushNonFFMatching:'show advice when running git-push and pushed matching refs explicitly::->bool:true'
    advice.pushAlreadyExists:'show advice when git-push rejects an update that does not qualify for fast-forwarding::->bool:true'
    advice.pushFetchFirst:'show advice when git-push rejects an update that tries to overwrite a remote ref that points at unknown object::->bool:true'
    advice.pushNeedsForce:'show advice when git-push rejects an update that tries to overwrite a remote ref that points a non-commitish::->bool:true'
    advice.pushUnqualifiedRefname:'show advice when git-push gives up trying to guess a remote ref::->bool:true'
    advice.statusHints:'show advice in output of git status::->bool:true'
    advice.statusUoption:'show advice to consider using the "-u" option to git-status when it takes more than 2 seconds::->bool:true'
    advice.commitBeforeMerge:'show advice when git merge refuses to merge::->bool:true'
    advice.resetQuiet:'show advice to consider using the --quiet option to git-reset::->bool:true'
    advice.resolveConflict:'show advice when conflict prevents operation from being performed::->bool:true'
    advice.sequencerInUse:'show advice shown when a sequencer command is already in progress::->bool:true'
    advice.implicitIdentity:'show advice when identity is guessed from system settings::->bool:true'
    advice.detachedHead:'show advice when entering detached-HEAD state::->bool:true'
    advice.checkoutAmbiguousRemoteBranchName:'show advice when argument for a remote tracking branch is ambiguous::->bool:true'
    advice.amWorkDir:'show the location of the patch file when git-am fails to apply it::->bool:true'
    advice.rmHints:'show directions in case of failure in the output of git-rm(1)::->bool:true'
    advice.addEmbeddedRepo:"show advice on what to do when you’ve accidentally added one git repo inside of another::->bool:true"
    advice.ignoredHook:'show advice if a hook is ignored because the hook is not set as executable::->bool:true'
    advice.waitingForEditor:'print a message to the terminal whenever Git is waiting for editor input from the user::->bool:true'
    advice.nestedTag:'show advice if a user attempts to recursively tag a tag object::->bool:true'
    author.email:'email address used for author in commits::_email_addresses -c'
    author.name:'full name used for author in commits:name:->string'
    am.threeWay:'use 3-way merge if patch does not apply cleanly::->bool:false'
    blame.blankboundary:'show blank SHA-1 for boundary commits::->bool:false'
    blame.coloring:'determine the coloring scheme to be applied to blame output:scheme [none]:->string'
    blame.showEmail:"show author email instead of author name::->bool:false"
    blame.showroot:'show root commits as normal commits::->bool:false'
    blame.ignoreRevsFile:'ignore revisions listed in the file:file:_files'
    blame.date:'date format to use in output::__git_date_formats:iso'
    'branch.*.description:branch description:branch description:->string'
    branch.sort:"default sorting order for 'git branch' output::__git_ref_sort_keys"
    checkout.defaultRemote:'assumed remote name when specifying an unqualified remote branch name:remote name:__git_remotes'
    cvsexportcommit.cvsdir:'the default location of the CVS checkout to use for the export:cvs export dir:_directories'
    column.ui:'specify whether supported commands should output in columns.::->column:never'
    column.branch:'specify whether to output branch listing in git branch in columns::_git_column_layouts:never'
    column.clean:'specify the layout when listing items in git clean -i::_git_column_layouts:never'
    column.status:'specify whether to output untracked files in git status in columns::_git_column_layouts:never'
    column.tag:'specify whether to output tag listing in git tag in columns::_git_column_layouts:never'
    committer.email:'email address used for committer in commits::_email_addresses -c'
    committer.name:'full name used for committer in commits:name:->string'
    core.fileMode:'track changes to the executable bit of files::->bool:true'
    core.attributesfile:'look into this file for attributes in addition to .gitattributes:additional attributes file:_files'
    core.abbrev:'set the length object names are abbreviated to:length:->int:7'
    core.checkRoundtripEncoding:"encodings to UTF-8 round trip check::_guard '' 'comma-separated list of encodings'" # _guard used as a hack because _message doesn't take compadd options
    core.commentchar:'comment character when using an editor::->string'
    core.filesRefLockTimeout:"how long to retry locking a reference:retry time (milliseconds, or -1 for indefinite):->int:100"
    core.ignoreCygwinFSTricks:'use Cygwin stat()/lstat()::->bool:true'
    core.ignorecase:'use workarounds for non-case-sensitive filesystems::->bool:false'
    core.trustctime:'trust inode change time::->bool:true'
    core.quotepath:'escape characters in paths on output::->bool:false'
    core.eol:'line ending type::->core.eol:native'
    core.safecrlf:'verify that CRLF conversion is reversible::->core.safecrlf:false'
    core.autocrlf:'convert CRLFs to and from system specific::->core.autocrlf:false'
    core.symlinks:'create symbolic links for indexed symbolic links upon creation::->bool:true'
    core.gitProxy:'command to execute to establish a connection to remote server:proxy command:_cmdstring'
    core.ignoreStat:'ignore modification times of files::->bool:false'
    core.preferSymlinkRefs:'use symbolic links for symbolic-reference files::->bool:false'
    core.bare:'use a repository without a working tree::->bool:false'
    core.worktree:'path to the root of the work tree:work tree:_directories'
    core.logAllRefUpdates:'log updates of references::->bool:true'
    core.repositoryFormatVersion:'internal variable determining the repository version:version:->string'
    core.sharedRepository:'what kind of sharing is done for this repository::->permission:false'
    core.warnAmbiguousRefs:'warn if a ref name is ambiguous::->bool:true'
    core.compression:'level of compression to apply to packs::->compression:-1'
    core.loosecompression:'level of compression to apply to non-pack files::->compression:1'
    core.packedGitWindowSize:'size of mappings of pack files:pack window size:->bytes'
    core.packedGitLimit:'maximum number of bytes to map from pack files:maximum pack file map size:->bytes'
    core.packedRefsTimeout:"how long to retry locking the packed-refs file:retry time (milliseconds, or -1 for indefinite):->int:1000"
    core.precomposeunicode:'revert the unicode decomposition of filenames done by Mac OS::->bool:false'
    core.deltaBaseCacheLimit:'maximum size of cache for base objects:maximum base objects cache size:->bytes:96m'
    core.bigFileThreshold:'maximum size of files to compress:maximum compress size:->bytes:512m'
    core.excludesfile:'additional file to use for exclusion:excludes file:_files'
    core.askpass:'program to use for asking for passwords:password command:_cmdstring'
    core.editor:'editor to use for editing messages:editor:_cmdstring'
    core.pager:'pager to use for paginating output:pager:_cmdstring'
    core.whitespace:'list of common whitespace problems to notice::->core.whitespace'
    core.fsyncobjectfiles:'fsync() when writing object files::->bool:false'
    core.preloadindex:'use parallel index preload for operations like git diff::->bool:true'
    core.createObject:'take steps to prevent overwriting existing objects::->core.createObject:link'
    core.checkstat:'determine which stat fields to match between the index and work tree::->core.checkstat:default'
    core.notesRef:'show notes in given refs:refs:->string:refs/notes/commits'
    core.sparseCheckoutCone:"enable git-sparse-checkout(1) cone mode::->bool:false"
    core.sparseCheckout:'use sparse checkout::->bool:false'
    core.splitIndex:"enable the split-index feature::->bool:false"
    core.useReplaceRefs:"honour 'replace' refs::->bool:true"
    credential.helper:'external helper to be called when a username or password credential is needed::_cmdstring'
    credential.useHttpPath:'consider the "path" component of an http or https URL to be important::->bool:false'
    credential.username:'If no username is set use this username by default:default username:->string'
    'credential.*.helper:external helper to be called when a username or password credential is needed::_cmdstring'
    'credential.*.useHttpPath:consider the "path" component of an http or https URL to be important::->bool:false'
    'credential.*.username:if no username is set use this username by default:default username:->string'
    credentialCache.ignoreSIGHUP:'ignore SIGHUP in git-credential-cache—daemon::->bool:false'
    add.ignore-errors:'ignore indexing errors when adding files::->bool:false'
    add.ignoreErrors:'ignore indexing errors when adding files::->bool:false'
    am.keepcr:'keep CR characters when splitting mails::->bool:false'
    apply.ignorewhitespace:'ignore whitespace changes::->apply.ignorewhitespace:no'
    apply.whitespace:'default value for the --whitespace option::->apply.whitespace:error'
    branch.autosetupmerge:'set up new branches for git pull::->bool:true'
    branch.autosetuprebase:'rebase new branches of merge for autosetupmerge::->branch.autosetuprebase:never'
    'branch.*.remote:what remote git fetch and git push should fetch form/push to::__git_remotes'
    'branch.*.merge:default refspec to be marked for merging::__git_remote_references'
    'branch.*.mergeoptions:default options for merging::->branch.mergeoptions'
    'branch.*.pushremote:what remote git push should push to::__git_remotes'
    'branch.*.rebase:rebase on top of fetched branch::->bool:false'
    'browser.*.cmd:browser command to use:browser:_cmdstring'
    'browser.*.path:path to use for the browser:absolute browser path:_absolute_command_paths'
    clean.requireForce:'require --force for git clean to actually do something::->bool:true'
    color.branch:'color output of git branch::->color-bool:false'
    color.branch.current:'color of the current branch::->color'
    color.branch.local:'color of a local branch::->color'
    color.branch.remote:'color of a remote branch::->color'
    color.branch.upstream:'color of upstream branches::->color'
    color.branch.plain:'color of other branches::->color'
    color.diff:'color output of git diff::->color-bool:false'
    color.diff.plain:'color of context text::->color'
    color.diff.meta:'color of meta-information::->color'
    color.diff.frag:'color of hunk headers::->color'
    color.diff.func:'color of function in hunk header::->color'
    color.diff.old:'color of removed lines::->color'
    color.diff.oldMoved:'color of lines removed by a move::->color'
    color.diff.oldMovedAlternative:'alternative color of lines removed by a move::->color'
    color.diff.oldMovedAlternativeDimmed:'dimmed alternative color of lines removed by a move::->color'
    color.diff.oldMovedDimmed:'dimmed color of lines removed by a move::->color'
    color.diff.new:'color of added lines::->color'
    color.diff.newMoved:'color of lines added by a move::->color'
    color.diff.newMovedAlternative:'alternative color of lines added by a move::->color'
    color.diff.newMovedAlternativeDimmed:'dimmed alternative color of lines added by a move::->color'
    color.diff.newMovedDimmed:'dimmed color of lines added by a move::->color'
    color.diff.commit:'color of commit headers::->color'
    color.diff.whitespace:'color of whitespace errors::->color'
    color.decorate.branch:'color of branches::->color'
    color.decorate.remoteBranch:'color of remote branches::->color'
    color.decorate.tag:'color of tags::->color'
    color.decorate.stash:'color of stashes::->color'
    color.decorate.HEAD:'color of HEAD::->color'
    color.grep:'whether or not to color output of git grep::->color-bool:false'
    color.grep.context:'color of non-matching text in context lines::->color'
    color.grep.filename:'color of filename prefix::->color'
    color.grep.function:'color of function name lines::->color'
    color.grep.linenumber:'color of line number prefix::->color'
    color.grep.match:'color of matching text::->color'
    color.grep.selected:'color of non-matching text in selected lines::->color'
    color.grep.separator:'color of separators between fields in a line::->color'
    color.interactive:'whether or not to color in interactive mode::->color-bool:false'
    color.interactive.prompt:'color of prompt::->color'
    color.interactive.header:'color of header::->color'
    color.interactive.help:'color of help::->color'
    color.interactive.error:'color of error::->color'
    color.pager:'feed colored output to pager::->bool:true'
    color.showbranch:'color output of git show-branch::->color-bool:false'
    color.status:'color output of git status::->color-bool:false'
    color.status.branch:'color of the current branch::->color'
    color.status.header:'color of header text::->color'
    color.status.added:'color of added, but not yet committed, files::->color'
    color.status.updated:'color of updated, but not yet committed, files::->color'
    color.status.changed:'color of changed, but not yet added in the index, files::->color'
    color.status.untracked:'color of files not currently being tracked::->color'
    color.status.nobranch:'color of no-branch warning::->color'
    color.ui:'color output of capable git commands::->color-bool:auto'
    commit.cleanup:'default --cleanup option::_git_cleanup_modes'
    commit.gpgsign:'always GPG-sign commits::->bool:false'
    commit.status:'include status information in commit message template::->bool:true'
    commit.template:'template file for commit messages:template:_files'
    'diff.*.binary:make the diff driver treat files as binary::->bool:false'
    'diff.*.cachetextconv:make the diff driver cache the text conversion outputs::->bool:false'
    'diff.*.command:custom diff driver command::_cmdstring'
    'diff.*.textconv:command to generate the text-converted version of a file::_cmdstring'
    'diff.*.wordregex:regular expression that the diff driver should use to split words in a line:regular expression:->string'
    'diff.*.xfuncname:regular expression that the diff driver should use to recognize the hunk header:regular expression:->string'
    diff.algorithm:'default diff algorithm::->diff.algorithm:default'
    diff.autorefreshindex:'run git update-index --refresh before git diff::->bool:true'
    diff.colorMoved:"color moved lines in diffs::__git_color_moved"
    diff.colorMovedWS:"ignore whitespace when detecting moved lines::__git_color_movedws"
    diff.wsErrorHighlight:'highlight whitespace errors: :__git_ws_error_highlight'
    diff.context:'default number of context lines::->int:3'
    diff.dirstat:'comma separated list of --dirstat parameters specifying default behaviour:comma-separated list:->string:changes,noncumulative,3'
    diff.external:'command to generate diff with:diff command:_cmdstring'
    diff.indentHeuristic:"heuristically shift hunk boundaries::->bool:true"
    diff.interHunkContext:"combine hunks closer than N lines:number of lines:->int"
    diff.mnemonicprefix:'use mnemonic source and destination prefixes::->bool:false'
    diff.noprefix:'strip source and destination prefixes::->bool:false'
    diff.orderfile:'file to read patch order glob patterns from:order file:_files'
    diff.renameLimit:'number of files to consider when detecting copy/renames:limit (number of files):->int'
    diff.renames:'try to detect renames::->diff.renames:true'
    diff.ignoreSubmodules:'ignore submodules::->bool:false'
    diff.statGraphWidth:'width of the graph part in --stat output:width:->int'
    diff.submodule:'output format for submodule differences::->diff.submodule:short'
    diff.suppressBlankEmpty:'inhibit printing space before empty output lines::->bool:false'
    diff.tool:'diff tool to use::__git_difftools'
    'difftool.*.cmd:command to invoke for the diff tool::_cmdstring'
    'difftool.*.path:path to use for the diff tool:absolute diff tool path:_absolute_command_paths'
    difftool.prompt:'prompt before each invocation of the diff tool::->bool:true'
    diff.wordRegex:'regex used to determine what a word is when performing word-by-word diff:regular expression:->string'
    diff.guitool:'diff tool with gui to use::__git_difftools'
    merge.guitool:'merge tool with gui to use::__git_difftools'
    fastimport.unpackLimit:"whether to import objects as loose object files or as a pack:threshold for packing (number of objects imported):->int"
    feature.experimental:'enable config options that are new to Git::->bool:false'
    feature.manyFiles:'enable config options that optimize for repos with many files::->bool:false'
    fetch.output:'output format:format:compadd compact full'
    fetch.parallel:'specify maximum number of fetch operations to run in parallel:number:->int'
    fetch.prune:'remove any remote tracking branches that no longer exist remotely::->bool:false'
    fetch.pruneTags:"maintain one-to-one correspondence with upstream tag refs::->bool:false"
    fetch.showForcedUpdates:"show forced updates::->bool:true"
    fetch.unpackLimit:'maximum number of objects to unpack when fetching:unpack limit:->int'
    fetch.recurseSubmodules:'recurse into submodules (as needed) when fetching::->fetch.recurseSubmodules:on-demand'
    fetch.fsckObjects:'check all fetched objects::->bool:false'
    fetch.writeCommitGraph:'write a commit-graph after every git fetch command that downloads a pack-file from a remote::->bool:false'
    'filter.*.clean:command which is used to convert the content of a worktree file to a blob upon checkin::_cmdstring'
    'filter.*.smudge:command which is used to convert the content of a blob object to a worktree file upon checkout::_cmdstring'
    format.attach:'use multipart/mixed attachments::->bool:false'
    format.coverLetter:'control whether to generate a cover-letter when format-patch is invoked::->bool:false'
    format.numbered:'use sequence numbers in patch subjects::->format.numbered:auto'
    format.headers:'additional email headers to include in email patches:headers:->string'
    format.to:'additional email recipients of patches::->string'
    format.cc:'additional carbon-copy email recipients of patches:recipients:->string'
    format.subjectprefix:'prefix to use for subjects:prefix:->string'
    format.signature:'signature to use:signature:->string'
    format.suffix:'default suffix for output files from git-format-patch:suffix:->string'
    format.pretty:'pretty format for log/show/whatchanged:format:->string'
    format.thread:'threading style to use::->format.thread:false'
    format.signoff:'enable --signoff by default::->bool:false'
    'gc.*.reflogexpire:grace period for git reflog expire::->days:90'
    'gc.*.reflogexpireunreachable:grace period for git reflog expire for unreachable entries::->days:30'
    gc.aggressiveDepth:'maximum delta depth:maximum delta depth::->int:250'
    gc.aggressiveWindow:'window size used in delta compression algorithm::->int:250'
    gc.auto:'minimum limit for packing loose objects with --auto::->int:6700'
    gc.autoDetach:"make 'git gc --auto' run in the background::->bool:true"
    gc.autopacklimit:'minimum limit for packing packs with --auto::->int:50'
    gc.bigPackThreshold:"keep large packs:size threshold:->bytes"
    gc.packrefs:'allow git gc to run git pack-refs::->gc.packrefs:true'
    gc.pruneexpire:'grace period for pruning:number of days, "now", or "never":->int'
    gc.reflogexpire:'grace period for git reflog expire::->days:90'
    gc.reflogexpireunreachable:'grace period for git reflog expire for unreachable entries::->days:30'
    gc.rerereresolved:'number of days to keep records of resolved merges::->days:60'
    gc.rerereunresolved:'number of days to keep records of unresolved merges::->days:15'
    gc.worktreePruneExpire:'grace period for pruning worktrees:number of days, "now", or "never":->int' # git default: 3.months.ago
    gitcvs.commitmsgannotation:'string to append to each commit message::->string'
    gitcvs.enabled:'enable the cvs server interface::->bool:false'
    gitcvs.logfile:'name of log file for cvs pserver:log file:_files'
    gitcvs.dbname:'name of database to use:database name:->string'
    gitcvs.dbdriver:'name of DBI driver to use::->gitcvs.dbdriver:SQLite'
    gitcvs.dbuser:'username to connect to database as:database user:_users'
    gitcvs.dbpass:'password to use when connecting to database:password:->string'
    gitcvs.dbTableNamePrefix:'database table name prefix:prefix:->string'
    'gitcvs.*.commitmsgannotation:string to append to each commit message:annotation:->string'
    'gitcvs.*.enabled:enable the cvs server interface::->bool:false'
    'gitcvs.*.logfile:name of log file for cvs pserver:log file:_files'
    'gitcvs.*.dbname:name of database to use:database name:->string'
    'gitcvs.*.dbdriver:name of DBI driver to use:DBI driver:->string'
    'gitcvs.*.dbuser:username to connect to database as::_users'
    'gitcvs.*.dbpass:password to use when connecting to database:password:->string'
    'gitcvs.*.dbTableNamePrefix:database table name prefix:prefix:->string'
    gitcvs.usecrlfattr:'use end-of-line conversion attributes::->bool:false'
    gitcvs.allbinary:'treat all files from CVS as binary::->bool:false'
    gpg.format:'private key format for --gpg-sign:format:compadd openpgp x509'
    gpg.minTrustLevel:'minimum trust level for signature verification:trust level:compadd undefined never marginal fully ultimate' # TODO: sort in this order (use compadd -V)
    {gpg.program,gpg.openpgp.program}:'use program instead of "gpg" found on $PATH when making or verifying a PGP signature::_cmdstring'
    gpg.x509.program:'use program instead of "gpgsm" found on $PATH when making or verifying an x509 signature::_cmdstring'
    gui.commitmsgwidth:'width of commit message window:width::->int:75'
    gui.diffcontext:'number of context lines used in diff window:context::->int:5'
    gui.encoding:'encoding to use for displaying file contents::->encoding'
    gui.matchtrackingbranch:'create branches that track remote branches::->bool:false'
    gui.newbranchtemplate:'suggested name for new branches:template:->string'
    gui.pruneduringfetch:'prune tracking branches when performing a fetch::->bool:false'
    gui.trustmtime:'trust file modification timestamp::->bool:false'
    gui.spellingdictionary:'dictionary to use for spell checking commit messages:dictionary:_files'
    gui.fastcopyblame:'try harder during blame detection::->bool:false'
    gui.copyblamethreshold:'threshold to use in blame location detection:threshold:->string'
    gui.blamehistoryctx:'specify radius of history context in days for selected commit::->days'
    'guitool.*.argprompt:prompt for arguments:argument prompt:->string'
    'guitool.*.cmd:shell command line to execute::_cmdstring'
    'guitool.*.confirm:show a confirmation dialog::->bool:false'
    'guitool.*.needsfile:require that a diff is selected for command to be available::->bool:false'
    'guitool.*.noconsole:suppress command output::->bool:false'
    'guitool.*.norescan:skip rescanning for changes to the working directory::->bool:false'
    'guitool.*.revprompt:request a single valid revision from the user, and set the "REVISION" environment variable::->string'
    'guitool.*.prompt:prompt to display:prompt:->string'
    'guitool.*.revunmerged:show only unmerged branches in revprompt::->bool:false'
    'guitool.*.title:title of prompt dialog:prompt title:->string'
    guitool.cmd:'shell command line to execute::_cmdstring'
    guitool.needsfile:'require that a diff is selected for command to be available::->bool:false'
    guitool.noconsole:'suppress command output::->bool:false'
    guitool.norescan:'skip rescanning for changes to the working directory::->bool:false'
    guitool.confirm:'show a confirmation dialog::->bool:false'
    guitool.argprompt:'prompt for arguments:argument prompt:->string'
    guitool.revprompt:'prompt for a single revision:revision prompt:->string'
    guitool.revunmerged:'show only unmerged branches in revprompt::->bool:false'
    guitool.title:'title of prompt dialog:prompt title:->string'
    guitool.prompt:'prompt to display:prompt:->string'
    grep.column:"show column number of first match::->bool:false"
    grep.extendedRegexp:'enable --extended-regexp option by default (ignored when grep.patternType is set)::->bool:false'
    grep.fullname:'enable --full-name option by default::->bool:false'
    grep.lineNumber:'enable -n option by default::->bool:false'
    grep.patternType:'default matching pattern type::->grep.patternType:default'
    grep.threads:"number of worker threads::->int"
    help.browser:'browser used to display help in web format::__git_browsers'
    help.htmlpath:'location of HTML help::->help.htmlpath'
    http.cookiefile:'file containing cookie lines which should be used in the Git http session::_files'
    http.lowSpeedLimit:'limit controlling when to abort an HTTP transfer:speed limit:->int'
    http.lowSpeedTime:'limit controlling when to abort an HTTP transfer:time limit (seconds):->int'
    help.format:'default help format used by git help::->help.format'
    help.autocorrect:'execute corrected mistyped commands::->bool:false'
    http.proxy:'HTTP proxy to use:proxy:_urls'
    http.savecookies:'save cookies to the cookie file::->bool:false'
    http.sslVerify:'verify the SSL certificate for HTTPS::->bool:true'
    http.sslCert:'file containing SSL certificates for HTTPS:SSL certificate file:_files'
    http.sslKey:'file containing the SSL private key for HTTPS:SSL private key file:_files'
    http.sslCertPasswordProtected:'prompt for a password for the SSL certificate::->bool:false'
    http.sslCAInfo:'file containing CA certificates to verify against for HTTPS:CA certificates file:_files'
    http.sslCAPath:'directory containing files with CA certificates to verify against for HTTPS:CA certificates directory:_directories'
    http.sslTry:'attempt to use AUTH SSL/TLS and encrypted data transfers when connecting via regular FTP protocol::->bool:false'
    http.maxRequests:'how many HTTP requests to launch in parallel:maximum number of requests::->int:5'
    http.minSessions:'number of curl sessions to keep across requests:minimum number of sessions::->int:1'
    http.postBuffer:'maximum size of buffer used by smart HTTP transport when POSTing:maximum POST buffer size:->bytes:1m'
    http.lowSpeedLimit:'lower limit for HTTP transfer-speed:low transfer-speed limit:->int'
    http.lowSpeedTime:'duration for http.lowSpeedLimit:time:->int'
    http.noEPSV:'disable the use of the EPSV ftp-command::->bool:false'
    http.useragent:'user agent presented to HTTP server:user agent string:->string'
    http.getanyfile:'allow clients to read any file within repository::->bool:true'
    http.uploadpack:'serve git fetch-pack and git ls-remote clients::->bool:true'
    http.receivepack:'serve git send-pack clients::->bool:true'
    'http.*.cookiefile:file containing cookie lines which should be used in the Git http session::_files'
    'http.*.lowSpeedLimit:limit controlling when to abort an HTTP transfer:speed limit:->int'
    'http.*.lowSpeedTime:limit controlling when to abort an HTTP transfer:time limit (seconds):->int'
    'help.*.format:default help format used by git help::->help.format'
    'help.*.autocorrect:execute corrected mistyped commands::->bool:false'
    'http.*.proxy:HTTP proxy to use:proxy:_urls'
    'http.*.savecookies:save cookies to the cookie file::->bool:false'
    'http.*.sslVerify:verify the SSL certificate for HTTPS::->bool:true'
    'http.*.sslCert:file containing SSL certificates for HTTPS:SSL certificate file:_files'
    'http.*.sslKey:file containing the SSL private key for HTTPS:SSL private key file:_files'
    'http.*.sslCertPasswordProtected:prompt for a password for the SSL certificate::->bool:false'
    'http.*.sslCAInfo:file containing CA certificates to verify against for HTTPS:CA certificates file:_files'
    'http.*.sslCAPath:directory containing files with CA certificates to verify against for HTTPS:CA certificates directory:_directories'
    'http.*.sslTry:attempt to use AUTH SSL/TLS and encrypted data transfers when connecting via regular FTP protocol::->bool:false'
    'http.*.maxRequests:how many HTTP requests to launch in parallel:maximum number of requests::->int:5'
    'http.*.minSessions:number of curl sessions to keep across requests:minimum number of sessions::->int:1'
    'http.*.postBuffer:maximum size of buffer used by smart HTTP transport when POSTing:maximum POST buffer size:->bytes:1m'
    'http.*.lowSpeedLimit:lower limit for HTTP transfer-speed:low transfer-speed limit:->int'
    'http.*.lowSpeedTime:duration for http.lowSpeedLimit:time:->int'
    'http.*.noEPSV:disable the use of the EPSV ftp-command::->bool:false'
    'http.*.useragent:user agent presented to HTTP server:user agent string:->string'
    'http.*.getanyfile:allow clients to read any file within repository::->bool:true'
    'http.*.uploadpack:serve git fetch-pack and git ls-remote clients::->bool:true'
    'http.*.receivepack:serve git send-pack clients::->bool:true'
    i18n.commitEncoding:'character encoding commit messages are stored in::->encoding'
    i18n.logOutputEncoding:'character encoding commit messages are output in::->encoding'
    imap.folder:'IMAP folder to use with git imap-send:IMAP folder name::_mailboxes'
    imap.tunnel:'tunneling command to use for git imap-send:tunnel command:_cmdstring'
    imap.host:'host git imap-send should connect to::_hosts'
    # TODO: If imap.host is set, complete users on that system.
    imap.user:'user git imap-send should log in as::_users'
    imap.pass:'password git imap-send should use when logging in:password:->string'
    imap.port:'port git imap-send should connect on::_ports'
    imap.sslverify:'verify server certificate::->bool:true'
    imap.preformattedHTML:'use HTML encoding when sending a patch::->bool:false'
    imap.authMethod:'authentication method used::->imap.authMethod'
    init.templatedir:'directory from which templates are copied:template directory:_directories'
    instaweb.browser:'browser to use when browsing with gitweb::__git_browsers'
    instaweb.httpd:'HTTP-daemon command-line to execute for instaweb:daemon:_cmdstring'
    instaweb.local:'bind to 127.0.0.1::->bool:false'
    instaweb.modulepath:'module path for the Apache HTTP-daemon for instaweb:module directory:_directories'
    instaweb.port:'port to bind HTTP daemon to for instaweb::_ports'
    interactive.diffFilter:"mark up diffs for human consumption:filter command:_cmdstring"
    interactive.singlekey:'accept one-letter input without Enter::->bool:false'
    log.abbrevCommit:'make git-log, git-show, and git-whatchanged assume --abbrev-commit::->bool:false'
    log.date:'default date-time mode::__git_date_formats'
    log.decorate:'type of ref names to show::__git_log_decorate_formats'
    log.mailmap:'make git-log, git-show, and git-whatchanged assume --use-mailmap:->bool:false'
    log.showroot:'show initial commit as a diff against an empty tree::->bool:true'
    mailinfo.scissors:'remove everything in body before a scissors line::->bool:false'
    mailmap.blob:'like mailmap.file, but consider the value as a reference to a blob in the repository:blob reference:->string'
    mailmap.file:'augmenting mailmap file:mailmap file:_files'
    man.viewer:'man viewer to use for help in man format::__git_man_viewers'
    'man.*.cmd:the command to invoke the specified man viewer:man command:_cmdstring'
    'man.*.path:path to use for the man viewer:absolute man tool path:_absolute_command_paths'
    merge.branchdesc:'populate the log message with the branch description text as well::->bool:false'
    merge.conflictstyle:'style used for conflicted hunks::->merge.conflictstyle:merge'
    merge.defaultToUpstream:'merge the upstream branches configured for the current branch by default::->bool:true'
    merge.ff:'allow fast-forward merges::->merge.ff:true'
    merge.log:'include summaries of merged commits in new merge commit messages::->bool:false'
    merge.directoryRenames:"try to detect directory renames:mode:compadd false true conflict"
    merge.renames:"try to detect renames::->diff.renames"
    merge.renameLimit:'number of files to consider when detecting copy/renames during merge:limit (number of files):->int'
    merge.renormalize:'use canonical representation of files during merge::->bool:false'
    merge.stat:'print the diffstat between ORIG_HEAD and merge at end of merge::->bool:true'
    merge.tool:'tool used by git mergetool during merges::__git_mergetools'
    merge.verbosity:'amount of output shown by recursive merge strategy::->merge.verbosity:2'
    'merge.*.name:human-readable name for custom low-level merge driver:name:->string'
    'merge.*.driver:command that implements a custom low-level merge driver:merge command:_cmdstring'
    'merge.*.recursive:low-level merge driver to use when performing internal merge between common ancestors::__git_builtin_merge_drivers'
    'mergetool.*.path:path to use for the merge tool:absolute merge tool path:_absolute_command_paths'
    'mergetool.*.cmd:command to invoke for the merge tool:merge command:_cmdstring'
    'mergetool.*.trustExitCode:trust the exit code of the merge tool::->bool:false'
    mergetool.keepBackup:'keep the original file with conflict markers::->bool:true'
    mergetool.keepTemporaries:'keep temporary files::->bool:false'
    mergetool.prompt:'prompt before each invocation of the merge tool::->bool:true'
    notes.displayRef:'refname to show notes from::->refname'
    notes.rewrite.amend:'copy notes from original to rewritten commit when running git amend::->bool:true'
    notes.rewrite.rebase:'copy notes from original to rewritten commit when running git rebase::->bool:true'
    notes.rewriteMode:'what to do when target commit already has a not when rewriting::->notes.rewriteMode'
    notes.rewriteRef:'refname to use when rewriting::->refname'
    pack.window:'size of window:window size::->int:10'
    pack.depth:'maximum delta depth:maximum delta depth::->int:50'
    pack.windowMemory:'window size limit:maximum window size:->bytes:0'
    pack.compression:'compression level::->compression:-1'
    pack.deltaCacheSize:'maximum amount of memory for caching deltas:maximum delta cache size:->bytes:256m'
    pack.deltaCacheLimit:'maximum size of deltas:maximum delta size::->int:1000'
    pack.threads:'number of threads to use for searching for best delta matches:number of threads:->int'
    pack.indexVersion:'default pack index version:index version:->string'
    pack.packSizeLimit:'maximum size of packs:maximum size of packs:->bytes'
    pull.ff:'accept fast-forwards only::->bool:false'
    pull.octopus:'default merge strategy to use when pulling multiple branches::__git_merge_strategies'
    pull.rebase:'rebase branches on top of the fetched branch, instead of merging::->pull.rebase:false'
    pull.twohead:'default merge strategy to use when pulling a single branch::__git_merge_strategies'
    push.default:'action git push should take if no refspec is given::->push.default:simple'
    push.followTags:'enable --follow-tags option by default::->bool:false'
    push.gpgSign:'GPG-sign pushes::->bool:false'
    push.recurseSubmodules:'ensure all submodule commits are available on a remote-tracking branch'
    push.pushOption:'transmit strings to server to pass to pre/post-receive hooks::->string'
    rebase.stat:'show a diffstat of what changed upstream since last rebase::->bool:false'
    rebase.autoSquash:'autosquash by default::->bool:false'
    rebase.autoStash:'autostash by default::->bool:false'
    rebase.instructionFormat:'interactive rebase todo list format::__git_format_placeholders'
    rebase.missingCommitsCheck:'print a warning if some commits are removed'
    rebase.rescheduleFailedExec:"automatically re-schedule any 'exec' that fails::->bool"
    receive.autogc:'run git gc --auto after receiving data::->bool:true'
    receive.fsckObjects:'check all received objects::->bool:true'
    receive.hiderefs:'string(s) receive-pack uses to decide which refs to omit from its initial advertisement:hidden refs:->string'
    receive.unpackLimit:'maximum number of objects received for unpacking into loose objects:unpack limit:->int'
    receive.denyDeletes:'deny a ref update that deletes a ref::->bool:false'
    receive.denyDeleteCurrent:'deny a ref update that deletes currently checked out branch::->bool:false'
    receive.denyCurrentBranch:'deny a ref update of currently checked out branch::->receive.denyCurrentBranch'
    receive.denyNonFastForwards:'deny a ref update that is not a fast-forward::->bool:false'
    receive.updateserverinfo:'run git update-server-info after receiving data::->bool:false'
    'remote.pushdefault:URL of a remote repository to pushto::__git_any_repositories'
    'remote.*.url:URL of a remote repository::__git_any_repositories'
    'remote.*.partialclonefilter:filter applied when fetching from this promisor remote:filter:->string'
    'remote.*.promisor:use this remote to fetch promisor objects::->bool:false'
    'remote.*.pushurl:push URL of a remote repository::__git_any_repositories'
    'remote.*.proxy:URL of proxy to use for a remote repository::_urls'
    "remote.*.pruneTags:maintain one-to-one correspondence with remote's tag refs::->bool:false"
    'remote.*.prune:remove any remote tracking branches that no longer exist remotely::->bool:false'
    'remote.*.fetch:default set of refspecs for git fetch::__git_ref_specs_fetchy'
    'remote.*.push:default set of refspecs for git push::__git_ref_specs_pushy'
    'remote.*.mirror:push with --mirror::->bool:false'
    'remote.*.skipDefaultUpdate:skip this remote by default::->bool:false'
    'remote.*.skipFetchAll:skip this remote by default::->bool:false'
    'remote.*.receivepack:default program to execute on remote when pushing:git receive-pack command:_cmdstring'
    'remote.*.uploadpack:default program to execute on remote when fetching:git upload-pack command:_cmdstring'
    'remote.*.tagopt:options for retrieving remote tags::->remote.tagopt'
    'remote.*.vcs:interact with the remote through git-remote helper:remote VCS:->string'
    repack.packKeptObjects:'repack objects in packs marked with .keep::->bool'
    repack.useDeltaIslands:'pass --delta-islands to git-pack-objects::->bool:false'
    repack.usedeltabaseoffset:'use delta-base offsets::->bool:true'
    repack.writeBitmaps:'trade off disk space for faster subsequent repacks::->bool'
    rerere.autoupdate:'update index after resolution::->bool:false'
    rerere.enabled:'record resolved conflicts::->bool'
    reset.quiet:'pass --quiet by default::->bool:false'
    sendemail.identity:'default identity::__git_sendemail_identities'
    sendemail.smtpencryption:'encryption method to use::->sendemail.smtpencryption'
    sendemail.aliasesfile:'file containing email aliases:email aliases file:_files'
    sendemail.aliasfiletype:'format of aliasesfile::->sendemail.aliasfiletype'
    sendemail.annotate:'review and edit each patch you are about to send::->bool:false'
    sendemail.bcc:'value of Bcc\: header::_email_addresses'
    sendemail.cc:'value of Cc\: header::_email_addresses'
    sendemail.cccmd:'command to generate Cc\: header with:Cc\: command:_cmdstring'
    sendemail.tocmd:'command to generate To\: header with:To\: command:_cmdstring'
    sendemail.chainreplyto:'send each email as a reply to the previous one::->bool:false'
    sendemail.confirm:'type of confirmation required before sending::->sendemail.confirm:auto'
    sendemail.envelopesender:'envelope sender to send emails as::_email_addresses'
    sendemail.from:'sender email address::_email_addresses'
    sendemail.multiedit:'edit all files at once::->bool:true'
    sendemail.signedoffbycc:'add Signed-off-by\: or Cc\: lines to Cc\: header::->bool:true'
    sendemail.smtpBatchSize:"number of messages to send per SMTP connection::->int"
    sendemail.smtpReloginDelay:"delay before reconnecting to SMTP server:delay (seconds):->int"
    sendemail.smtppass:'password to use for SMTP-AUTH:password:->string'
    sendemail.suppresscc:'rules for suppressing Cc\:::->sendemail.suppresscc'
    sendemail.suppressfrom:'add From\: address to the Cc\: list::->bool:false'
    sendemail.to:'value of To\: header::_email_addresses'
    sendemail.smtpdomain:'FQDN to use for HELO/EHLO commands to SMTP server:smtp domain:_domains'
    sendemail.smtpserver:'SMTP server to connect to:smtp host: __git_sendmail_smtpserver_values'
    sendemail.smtpserveroption:'specifies the outgoing SMTP server option to use:SMTP server option:->string'
    sendemail.smtpserverport:'port to connect to SMTP server on:smtp port:_ports'
    sendemail.smtpsslcertpath:'path to ca-certificates (directory or file):ca certificates path:_files'
    sendemail.smtpuser:'user to use for SMTP-AUTH:smtp user:_users'
    sendemail.thread:'set In-Reply-To\: and References\: headers::->bool:true'
    sendemail.validate:'perform sanity checks on patches::->bool:true'
    sendemail.xmailer:'add the "X-Mailer" header::->bool:true'
    'sendemail.*.aliasesfile:file containing email aliases::_files'
    'sendemail.*.aliasfiletype:format of aliasesfile::->sendemail.aliasfiletype'
    'sendemail.*.annotate:review and edit each patch you are about to send::bool->false'
    'sendemail.*.bcc:value of Bcc\: header::_email_addresses'
    'sendemail.*.cc:value of Cc\: header::_email_addresses'
    'sendemail.*.cccmd:command to generate Cc\: header with:Cc\: command:_cmdstring'
    'sendemail.*.tocmd:command to generate To\: header with:To\: command:_cmdstring'
    'sendemail.*.chainreplyto:send each email as a reply to the previous one::->bool:false'
    'sendemail.*.confirm:type of confirmation required before sending::->sendemail.confirm:auto'
    'sendemail.*.envelopesender:envelope sender to send emails as::_email_addresses'
    'sendemail.*.from:sender email address::_email_addresses'
    'sendemail.*.multiedit:edit all files at once::->bool:false'
    'sendemail.*.signedoffbycc:add Signed-off-by\: or Cc\: lines to Cc\: header::->bool:true'
    'sendemail.*.smtppass:password to use for SMTP-AUTH:password:->string'
    'sendemail.*.suppresscc:rules for suppressing Cc\:::->sendemail.suppresscc'
    'sendemail.*.suppressfrom:rules for suppressing From\:::->sendemail.suppressfrom'
    'sendemail.*.to:value of To\: header::_email_addresses'
    'sendemail.*.smtpdomain:FQDN to use for HELO/EHLO commands to SMTP server:smtp domain:_domains'
    'sendemail.*.smtpserver:SMTP server to connect to:smtp host: __git_sendmail_smtpserver_values'
    'sendemail.*.smtpserveroption:specifies the outgoing SMTP server option to use:SMTP server option:->string'
    'sendemail.*.smtpserverport:port to connect to SMTP server on:smtp port:_ports'
    'sendemail.*.smtpuser:user to use for SMTP-AUTH:smtp user:_users'
    'sendemail.*.thread:set In-Reply-To\: and References\: headers::->bool:true'
    'sendemail.*.validate:perform sanity checks on patches::->bool:true'
    sendemail.assume8bitEncoding:'encoding to use for non-ASCII messages::__git_encodings'
    sequence.editor:'text editor used by git rebase -i::_cmdstring'
    showbranch.default:'default set of branches for git show-branch::->branch'
    status.aheadBehind:"display detailed ahead/behind counts relative to upstream branch::->bool:true"
    status.relativePaths:'show paths relative to current directory::->bool:false'
    status.showStash:'show number of stashes::->bool:false'
    status.showUntrackedFiles:'show untracked files::->status.showUntrackedFiles:normal'
    status.submodulesummary:'include submodule summary::->bool:false'
    status.branch:'show branch and tracking info in short format::->bool:false'
    status.short:'use short format by default::->bool:false'
    status.renameLimit:'number of files to consider when detecting copy/renames:limit (number of files):->int'
    status.renames:"detect renames in 'status' and 'commit'::->diff.renames"
    'submodule.*.branch:remote branch name for a submodule:branch name:->string'
    'submodule.*.fetchRecurseSubmodules:fetch commits of submodules::->bool'
    'submodule.*.path:path within project:submodule directory:_directories -qS \:'
    'submodule.*.url:URL to update from::__git_any_repositories'
    'submodule.*.update:update strategy to use::->submodule.update:none'
    'submodule.*.ignore:ignore modifications to submodules with git status and git diff-*::->submodule.ignore'
    submodule.recurse:'recurse into submodules by default (for most git commands)::->bool:false'
    ssh.variant:'SSH command flavour:flavour id:compadd ssh simple plink putty tortoiseplink'
    svn.noMetadata:'disable git-svn-id: lines at end of commits::->bool:false'
    svn.useSvmProps:'use remappings of URLs and UUIDs from mirrors::->bool:false'
    svn.useSvnsyncProps:'use remappings of URLs and UUIDs for the svnsync command::->bool:false'
    svn.ignore-paths:'regular expression of paths to not check out:regular expression:->string'
    svn.brokenSymlinkWorkaround:'apply the broken-symlink check::->bool:true'
    svn.pathnameencoding:'encoding to recode pathnames into::->encoding'
    svn.followparent:'follow parent commit::->bool:true'
    svn.authorsFile:'default authors file:authors file:_files'
    svn.quiet:'produce less output::->bool:false'
    'svn-remote.*.automkdirs:attempt to recreate empty directories that are in the Subversion repository::->bool:true'
    'svn-remote.*.noMetadata:disable git-svn-id: lines at end of commits::->bool:false'
    'svn-remote.*.useSvmProps:use remappings of URLs and UUIDs from mirrors::->bool:false'
    'svn-remote.*.useSvnsyncProps:use remappings of URLs and UUIDs for the svnsync command::->bool:false'
    'svn-remote.*.rewriteRoot:alternate root URL to use:root url:_urls'
    'svn-remote.*.rewriteUUID:remap URLs and UUIDs for mirrors manually::->bool:false'
    'svn-remote.*.ignore-paths:regular expression of paths to not check out:regular expression:->string'
    'svn-remote.*.url:URL to connect to::_urls'
    'svn-remote.*.fetch:fetch specification::__git_ref_specs_fetchy' # ### undocumented
    'svn-remote.*.pushurl:URL to push to::_urls'
    'svn-remote.*.branches:branch mappings:branch mapping:->string'
    'svn-remote.*.tags:tag mappings:tag mapping:->string'
    tag.gpgSign:'sign all tags::->bool'
    tag.sort:'default sorting method:sorting method:->string'
    'tar.*.command:specify a shell command through which the tar output generated by git archive should be piped::_cmdstring'
    'tar.*.remote:enable <format> for use by remote clients via git-upload-archive::->bool'
    tar.umask:'umask to apply::->umask'
    transfer.unpackLimit:'default value for fetch.unpackLimit and receive.unpackLimit:unpack limit::->int:100'
    transfer.fsckObjects:'check all objects::->bool:false'
    transfer.hiderefs:'string(s) to decide which refs to omit from initial advertisements:hidden refs:->string'
    uploadpack.hiderefs:'string(s) upload-pack uses to decide which refs to omit from its initial advertisement:hidden refs:->string'
    uploadpack.allowtipsha1inwant:'allow upload-pack to accept a fetch request that asks for an object at the tip of a hidden ref::->bool:false'
    uploadarchive.allowUnreachable:'allow git-upload-archive to accept an archive requests that ask for unreachable objects::->bool:false'
    'url.*.insteadOf:string to start URLs with:prefix:->string'
    'url.*.pushInsteadOf:string to start URLs to push to with:prefix:->string'
    user.email:'email address used for commits::_email_addresses -c'
    user.name:'full name used for commits:name:->string'
    user.useConfigOnly:'avoid guessing defaults for user.email and user.name:->bool:true'
    user.signingkey:'default GPG key to use when creating signed tags::__git_gpg_secret_keys'
    versionsort.suffix:'specify sort order of suffixes applied to tags:suffix'
    web.browser:'web browser to use::__git_browsers'
    worktree.guessRemote:'with add, if branch matches remote track it::->bool:true'

    {fetch.fsck.skipList,receive.fsck.skipList,fsck.skipList}:'ignore objects broken in a non-fatal way:path to a list of objects:_files'
  )

  declare -a git_present_options # 'present' is an adjective
  git_present_options=(
    ${${${(0)"$(_call_program gettable-options git config -z --list)"}%%$'\n'*}//:/\\:}

    # Remove the "'git help config' for more information" line.
    #
    # Change literal 'foo.<bar>.baz' to 'foo.*.baz'. With that, completing
    # at  foo.lorem.<TAB>  will offer foo.lorem.baz.
    ${${${(f)"$(_call_program all-known-options "git help -c")"}:#* *}/<*>/*}
  )

  # Add to $git_options options from the config file, and from 'git help -c',
  # that aren't already in $git_options.
  () {
    local -a -U sections_that_permit_arbitrary_subsection_names=(
      alias
      pager
      pretty
      remotes
      ${(u)${(M)${git_options%%:*}:#*[.][*][.]*}%%.*}
      ${(u)${(M)git_present_options:#*[.][*][.]*}%%.*}
    )
    local key
    for key in $git_present_options ; do
      if (( ${+git_options[(r)(#i)${(b)key}:*]} )); then
        # $key is already in git_options
        continue
      elif (( ${+sections_that_permit_arbitrary_subsection_names[(r)${(b)key%%.*}]} )); then
        if [[ $key == *.*.* ]]; then
          # If $key isn't an instance of a known foo.*.bar:baz $git_options entry...
          if ! (( ${+git_options[(r)(#i)${(b)key%%.*}.[*].${(b)key##*.}:*]} )); then
            # ... then add it.
            git_options+="${key}:unknown option name::->unknown"
          fi
        else
          # $key is of the form "foo.bar" where 'foo' is known
          # No need to add it; "foo.<TAB>' will find 'bar' via another codepath later
          # ### TODO: that "other codepath" will probably run git config -z again, redundantly.
          continue
        fi
      else
        git_options+="${key}:unknown option name::->unknown"
      fi
    done
  }

  case $state in
    (section)
      __git_config_sections -b '(|)' '^' section-names 'section name' $* && ret=0
      ;;
    (is-a-tty)
      declare -a values
      values=(
        true
        false
        auto)
      _describe -t values 'stdout is a tty' values && ret=0
      ;;
    (option)
      local label=option
      declare -a sections sections_and_options options

      [[ -prefix *. ]] && label="${line[1]%.*} option"

      if compset -P '[^.]##.*.'; then
        declare -a match mbegin mend
        # TODO: completing 'gpg.openpgp<TAB>' adds both 'gpg.openpgp.program' and 'gpg.*.program' to $options, so it ends up being listed as 'unknown option name' even though we have a description
        # When completing 'remote.foo.<TAB>', offer 'bar' if $git_options contains 'remote.foo.bar'.
        options+=(${${${${(M)git_options:#(#i)${IPREFIX}[^.:]##:*}#(#i)${IPREFIX}}/#(#b)([^:]##:)([^\\:]#(\\?[^\\:]#)#:[^\\:]#(\\?[^\\:]#)#:->bool)/$match[1]whether or not to $match[2]}/#(#b)([^:]##:([^\\:]#(\\?[^\\:]#)#))*/$match[1]})
        # When completing 'remote.foo.<TAB>', offer 'bar' if $git_options contains 'remote.*.bar'.
        options+=(${${${${(M)git_options:#(#i)${IPREFIX%%.*}.\*.[^.:]##:*}#(#i)${IPREFIX%%.*}.\*.}/#(#b)([^:]##:)([^\\:]#(\\?[^\\:]#)#:[^\\:]#(\\?[^\\:]#)#:->bool)/$match[1]whether or not to $match[2]}/#(#b)([^:]##:([^\\:]#(\\?[^\\:]#)#))*/$match[1]})

        declare -a labels
        labels=(
          'branch.*.:${${line[1]#branch.}%.*} branch option'
          'browser.*.:${${line[1]#browser.}%.*} browser option'
          'color.branch.:branch-specific color option'
          'color.diff.:diff-specific color option'
          'color.decorate.:git-log---decorate-specific color option'
          'color.grep.:git-grep-specific color option'
          'color.interactive.:interaction-specific color option'
          'color.status.:git-status-specific color option'
          'credential.*.:${${line[1]#credential.}%.*}-specific option'
          'filter.*.:${${line[1]#filter.}%.*} driver option'
          'diff.*.:${${line[1]#diff.}%.*} driver option'
          'difftool.*.:${${line[1]#difftool.}%.*}-specific option'
          'gc.*.:${${line[1]#gc.}%.*}-specific gc option'
          'gitcvs.*.:gitcvs ${${line[1]#gitcvs.}%.*}-specific option'
          'guitool.*.:${${line[1]#guitool.}%.*}-specific option'
          'http.*.:${${line[1]#http.}%.*}-specific option'
          'man.*.:${${line[1]#man.}%.*}-specific man option'
          'merge.*.:${${line[1]#merge.}%.*}-specific merge option'
          'mergetool.*.:${${line[1]#mergetool.}%.*}-specific option'
          'sendemail.*.:${${line[1]#sendemail.}%.*}-specific sendemail option'
          'submodule.*.:${${line[1]#submodule.}%.*}-submodule-specific option'
          'url.*.:${${line[1]#url.}%.*}-specific option'
          'svn-remote.*.:git-svn ${${line[1]#svn-remote.}%.*}-specific option')

        local found
        found=${${${(M)labels:#(${IPREFIX}|${IPREFIX%%.*}.\*.):*}[1]}#*:}
        [[ -n $found ]] && label=${(Q)"$(eval "print -rn -- $found")"}
      elif compset -P '[^.]##.'; then
        local opt
        declare -a match mbegin mend
        for opt in ${${${${(M)git_options:#(#i)${IPREFIX}[^.:][^:]#:*}#(#i)${IPREFIX}}/#(#b)([^:]##:)([^\\:]#(\\?[^\\:]#)#:[^\\:]#(\\?[^\\:]#)#:->bool)/$match[1]whether or not to $match[2]}/#(#b)([^:]##:([^\\:]#(\\?[^\\:]#)#))*/$match[1]}; do
          if (( ${git_options[(I)${IPREFIX}${opt%%:*}.*]} )); then
            sections_and_options+=$opt
          else
            options+=$opt
          fi
        done

        declare -a subsections
        subsections=(
          'color.decorate:git log --decorate options'
          'gitcvs.ext:ext-connection-method-specific options'
          'gitcvs.pserver:pserver-connection-method-specific options'
          'notes.rewrite:commands to copy notes from original for when rewriting commits')
        # Set $sections to the applicable subsection names (e.g., 'decorate:...' if $IPREFIX == "color.")
        sections+=(${${(M)subsections:#${IPREFIX}[^.:]##(.|):*}#${IPREFIX}})

        # TODO: Is it fine to use functions like this before _describe below,
        # or do we need a tag loop?
        # TODO: It would be nice to output _message -e TYPE label when the
        # following functions don't generate any output in the case of
        # multi-level options.
        case $IPREFIX in
          # Note: If you add a branch to this 'case' statement,
          # update $sections_that_permit_arbitrary_subsection_names.
          (alias.)
            __git_aliases && ret=0
            ;;
          (branch.)
            __git_branch_names -S . && ret=0
            ;;
          (browser.)
            __git_browsers -S . && ret=0
            ;;
          (credential.)
            _urls && ret=0
            ;;
          (difftool.)
            __git_difftools -S . && ret=0
            ;;
          (gc.)
            __git_config_sections '^gc\..+\.[^.]+$' refpatterns 'ref pattern' -S . && ret=0
            ;;
          (guitool.)
            __git_config_sections '^guitool\..+\.[^.]+$' guitools 'gui tool' -S . && ret=0
            ;;
          (http.)
            __git_config_sections '^http\..+\.[^.]+$' bases base -S . && ret=0
            ;;
          (man.)
            __git_man_viewers -S . && ret=0
            ;;
          (merge.)
            __git_merge_drivers -S . && ret=0
            ;;
          (mergetool.)
            __git_mergetools -S . && ret=0
            ;;
          (pager.)
            _git_commands && ret=0
            ;;
          (pretty.)
            __git_config_sections -a '(|)' '^pretty\..+\.[^.]+$' prettys 'pretty format string' && ret=0
            ;;
          (remote.)
            __git_remotes -S . && ret=0
            ;;
          (remotes.)
            __git_remote-groups && ret=0
            ;;
          (sendemail.)
            __git_sendemail_identities -S . && ret=0
            ;;
          (submodule.)
            __git_submodules -S . && ret=0
            ;;
          (url.)
            __git_config_sections '^url\..+\.[^.]+$' bases base -S . && ret=0
            ;;
          (svn-remote.)
            __git_svn-remotes -S . && ret=0
            ;;
          (*.)
            local -a existing_subsections=( ${${${(M)git_present_options:#${IPREFIX}*.*}#${IPREFIX}}%.*} )
            _describe -t existing-subsections "existing subsection" existing_subsections -S . && ret=0
            ;;
        esac
      else
        sections=(
          advice:'options controlling advice'
          author:'options controlling author identity'
          committer:'options controlling committer identity'
          core:'options controlling git core'
          credential:'credential options'
          add:'git add options'
          alias:'command aliases'
          am:'git am options'
          apply:'git apply options'
          blame:'git blame options'
          branch:'branch options'
          browser:'browser options'
          clean:'git clean options'
          color:'color options'
          column:'column options'
          commit:'git commit options'
          diff:'diff options'
          difftool:'difftools'
          feature:'options modifying defaults for a group of other settings'
          fetch:'git fetch options'
          format:'format options'
          gc:'git gc options'
          gpg:'gpg options'
          gitcvs:'git-cvs options'
          gui:'git gui options'
          guitool:'git gui tool options'
          help:'git help options'
          http:'http options'
          i18n:'internationalization options'
          imap:'IMAP options'
          init:'git init options'
          instaweb:'git web options'
          interactive:'options controlling interactivity'
          log:'git log options'
          mailmap:'mailmap options'
          man:'man options'
          merge:'git merge options'
          mergetool:'mergetools'
          notes:'git notes options'
          pack:'options controlling packing'
          pager:'pager options'
          pretty:'pretty formats'
          pull:'git pull options'
          push:'git push options'
          rebase:'git rebase options'
          receive:'git receive options'
          remote:'remotes'
          remotes:'remotes groups'
          repack:'repack options'
          rerere:'git rerere options'
          sendemail:'git send-email options'
          showbranch:'showbranch options'
          status:'git status options'
          submodule:'git submodule options'
          tar:'git tar-tree options'
          transfer:'options controlling transfers'
          uploadpack:'git upload-pack options'
          uploadarchive:'git upload-archive options'
          url:'URL prefixes'
          user:'options controlling user identity'
          web:'web options'
          versionsort:'tag sorting options'
          worktree:'git worktree options'
          svn:'git svn options'
          svn-remote:'git svn remotes'
        )
        () {
          local i
          for i in ${(u)git_present_options%%.*}; do
            (( ${+sections[(r)(#i)${(b)i}:*]} )) ||
              sections+="${i}:unknown section name"
          done
        }
      fi

      # TODO: Add equivalent of -M 'r:|.=* r:|=*' here so that we can complete
      # b.d.c to browser.dillo.cmd.
      _describe -t option-names $label \
        sections -M 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' -S . -- \
        sections_and_options -M 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' -qS . -- \
        options -M 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' "$@" && ret=0
      ;;
    (gettable-option)
      _wanted git-options expl option compadd -M 'r:|.=* r:|=*' -a - git_present_options && ret=0
      ;;
    (gettable-colorbool-option)
      __git_config_sections -b '(|)' -a '(|)' '^color\.[^.]+$' gettable-colorbool-options option && ret=0
      ;;
    (gettable-color-option)
      __git_config_sections -b '(|)' -a '(|)' '^color\.[^.]+\..*$' gettable-color-options option && ret=0
      ;;
    (value)
      local current=${${(0)"$(_call_program current "git config $opt_args[(I)--system|--global|--local]" ${(kv)opt_args[(I)-f|--file]} "-z --get ${(q)line[1]}")"}#*$'\n'}
      case $line[1] in
        (alias.*)
          if [[ -n $current ]]; then
            compadd - $current && ret=0
          else
            _message 'command'
          fi
          return
          ;;
        (remotes.*)
          # TODO: Use this strategy for all multi-item values.
          compset -P '* '

          local suffix
          if [[ $words[CURRENT] == [\"\']* ]]; then
            suffix=' '
          else
            suffix='\ '
          fi

          # TODO: Should really only complete unique remotes, that is, not the same
          # remote more than once in the list.
          __git_remotes -S $suffix -q && ret=0
          return ret
          ;;
      esac
      local z=$'\0'

      # Set $parts to the $git_options element that corresponds to $line[1]
      # (the option name whose value is currently being completed).  The elements
      # of $parts are the colon-separated elements of the $git_options element.
      declare -a parts
      parts=("${(S@0)${git_options[(r)(#i)${line[1]}:*]}//(#b)(*[^\\]|):/$match[1]$z}")
      if (( $#parts < 2 )) && [[ $line[1] == [^.]##.*.[^.]## ]]; then
        parts=("${(S@0)${git_options[(r)(#i)${line[1]%%.*}.\*.${line[1]##*.}:*]}//(#b)(*[^\\]|):/$match[1]$z}")
      fi

      (( $#parts >= 4 )) || return ret
      case $parts[4] in
        ('->'*)
          case ${parts[4]#->} in
            (apply.ignorewhitespace)
              __git_config_values -- "$current" "$parts[5]" \
                {no,false,never,none}':do not ignore whitespace' \
                change:'ignore changes in whitespace' && ret=0
              ;;
            (apply.whitespace)
              __git_apply_whitespace_strategies && ret=0
              ;;
            (bool)
              __git_config_booleans "$current" "$parts[5]" "$parts[2]" && ret=0
              ;;
            (branch)
              __git_branch_names && ret=0
              ;;
            (branch.autosetuprebase)
              __git_config_values -- "$current" "$parts[5]" \
                never:'never set branch.*.rebase to true' \
                local:'set branch.*.rebase to true for tracked branches of local branches' \
                remote:'set branch.*.rebase to true for tracked branches of remote branches' \
                always:'set branch.*.rebase to true for all tracking branches' && ret=0
              ;;
            (branch.mergeoptions)
              # TODO: Complete options to git-merge(1).
              _message 'git-merge options'
              ;;
            (bytes)
              __git_guard_bytes "$parts[3]" && ret=0
              ;;
            (color)
              compset -P '* '

              case ($words[CURRENT]) in
                (?*' '?*' '*)
                  if [[ $words[CURRENT] == *(bold|dim|ul|blink|reverse)* ]]; then
                    __git_colors && ret=0
                  else
                    __git_color_attributes && ret=0
                  fi
                  ;;
                (*)
                  local suffix q_flag
                  if [[ $words[CURRENT] == [\"\']* ]]; then
                    suffix=' '
                    q_flag=-q
                  else
                    suffix='\ '
                  fi

                  if [[ $words[CURRENT] == *(bold|dim|ul|blink|reverse)* ]]; then
                    __git_colors -S $suffix $q_flag && ret=0
                  else
                    _alternative \
                      'colors::__git_colors -S $suffix $q_flag' \
                      'attributes::__git_color_attributes -S $suffix $q_flag' && ret=0
                  fi
                  ;;
              esac
              ;;
            (color-bool)
              __git_config_values -t booleans -l boolean -- "$current" "$parts[5]" \
                {never,false,no,off}:"do not $parts[2]" \
                always:"always $parts[2]" \
                {auto,true,yes,on}:$parts[2] && ret=0
              ;;
            (compression)
              __git_compression_levels && ret=0
              ;;
            (core.autocrlf)
              __git_config_booleans "$current" "$parts[5]" "$parts[2]" \
                input:'convert CRLFs on input only' && ret=0
              ;;
            (core.checkstat)
              __git_config_values -- "$current" "$parts[5]" \
                default:'check all fields' \
                minimal:'check fewer fields' && ret=0
              ;;
            (core.createObject)
              __git_config_values -- "$current" "$parts[5]" \
                rename:'rename source objects' \
                link:'hardlink, then delete source objects' && ret=0
              ;;
            (core.safecrlf)
              __git_config_booleans "$current" "$parts[5]" "$parts[2]" \
                warn:'only warn about irreversible CRLF conversions' && ret=0
              ;;
            (core.whitespace)
              declare -a values

              values=(
                'blank-at-eol[treat whitespace at the end of the line as an error]'
                'space-before-tab[treat space character before tab character in initial indent as an error]'
                'indent-with-non-tab[treat lines indented with 8 or more space characters as an error]'
                'tab-in-indent[treat lines indented with a tab character as an error]'
                'blank-at-eof[treat blank lines at the end of the files as an error]'
                'cr-at-eol[treat carriage-return at the end of the line as part of line terminator]')

              _values -s , $parts[2] $values && ret=0
              ;;
            (days)
              if [[ -n $current ]]; then
                compadd - $current && ret=0
              elif [[ -n $parts[5] ]]; then
                compadd - $parts[5] && ret=0
              else
                __git_guard_number 'number of days'
              fi
              ;;
            (diff.algorithm)
              __git_config_values -- "$current" "$parts[5]" \
                default:'basic greedy diff algorithm' \
                myers:'basic greedy diff algorithm' \
                minimal:'spend extra time to make sure the smallest possible diff is produced' \
                patience:'generate diffs with patience algorithm' \
                histogram:'generate diffs with histogram algorithm' && ret=0
              ;;
            (diff.renames)
              __git_config_booleans "$current" "$parts[5]" "$parts[2]" \
                {copies,copy}:'try to detect both renames and copies' && ret=0
              ;;
            (diff.submodule)
              __git_config_values -- "$current" "$parts[5]" \
                short:'show pairs of commit name' \
                log:'list commits like git submodule does' && ret=0
              ;;
            (encoding)
              __git_encodings && ret=0
              ;;
            (eol)
              __git_config_values -- "$current" "$parts[5]" \
                lf:'use LF' \
                crlf:'use CR+LF' \
                native:'use line ending of platform' && ret=0
              ;;
            (fetch.recurseSubmodules)
              __git_config_booleans "$current" "$parts[5]" "$parts[2]" \
                on-demand:'only when submodule reference in superproject is updated' && ret=0
              ;;
            (format.numbered)
              __git_config_booleans "$current" "$parts[5]" "$parts[2]" \
                auto:'use sequence numbers if more than one patch' && ret=0
              ;;
            (format.thread)
              __git_config_booleans "$current" "$parts[5]" "$parts[2]" \
                deep:'make every mail a reply to the previous one' \
                shallow:'make every mail a reply to the first one' && ret=0
              ;;
            (gc.packrefs)
              __git_config_booleans "$current" "$parts[5]" "$parts[2]" \
                notbare:'pack references if the repository has a working directory' && ret=0
              ;;
            (gitcvs.dbdriver)
              # TODO: Would be nice to only include those that are installed, but I
              # couldn't figure out a good way of doing that when I wrote this code.
              __git_config_values -t dbi-drivers -l 'DBI driver' -- "$current" "$part[5]" \
                SQLite:'use the SQLite database driver' \
                Pg:'use the Pg database driver' && ret=0
              ;;
            (grep.patternType)
              __git_config_values -- "$current" "$parts[5]" \
                basic:'use --basic-regexp' \
                default:'use default' \
                extended:'use --extended-regexp' \
                fixed:'use --fixed-strings' \
                perl:'use --perl-regexp' && ret=0
              ;;
            (help.format)
              __git_config_values -- "$current" "$parts[5]" \
                man:'use man' \
                info:'use info' \
                {web,html}:'use HTML' && ret=0
              ;;
            (help.htmlpath)
              _alternative \
                'path::_files -/' \
                'url::_urls' && ret=0
              ;;
            (imap.authMethod)
              __git_config_values -- "$current" "$parts[5]" \
                CRAM-MD5:'use CRAM-MD5' && ret=0
              ;;
            (int)
              if [[ -n $current ]]; then
                compadd - $current && ret=0
              elif [[ -n $parts[5] ]]; then
                compadd - $parts[5] && ret=0
              else
                __git_guard_number ${parts[3]:-'integer'}
              fi
              ;;
            (merge.conflictstyle)
              __git_config_values -- "$current" "$parts[5]" \
                merge:'use standard merge style' \
                diff3:'use diff3 style' && ret=0
              ;;
            (merge.ff)
              __git_config_booleans "$current" "$parts[5]" "$parts[2]" \
                only:'only allow fast-forward merges (equivalent to --ff-only)' && ret=0
              ;;
            (merge.verbosity)
              __git_config_values -t verbosity-levels -l 'verbosity level' -- "$current" "$parts[5]" \
                0:'only final error message if conflicts were detected' \
                1:'conflicts' \
                2:'conflicts and file changes' \
                5:'debugging information' && ret=0
              ;;
            (notes.rewriteMode)
              __git_config_values -- "$current" "$parts[5]" \
                overwrite:'overwrite existing notes' \
                concatenate:'add the note to the existing ones' \
                ignore:'ignore the new note' && ret=0
              ;;
            (permission)
              __git_repository_permissions && ret=0
              ;;
            (pull.rebase)
              __git_config_values -- "$current" "$parts[5]" \
                {true,yes,on}:$parts[2] \
                {false,no,off}:"do not $parts[2]" \
                preserve:"rebase and preserve merges" && ret=0
              ;;
            (push.default)
              __git_config_values -- "$current" "$parts[5]" \
                nothing:'do not push anything' \
                matching:'push all matching branches' \
                upstream:'push current branch to its upstream branch' \
                simple:'like upstream, but only if local and remote names are the same' \
                current:'push current branch to branch of same name' && ret=0
              ;;
            (receive.denyCurrentBranch)
              __git_config_values -- "$current" "$parts[5]" \
                {refuse,true,yes,on}:'update ref to current branch of non-bare repository' \
                {warn}:'warn about dangers of pushing, but perform it anyway' \
                {false,no,off}:'do not update ref to current branch of non-bare repository' && ret=0
              ;;
            (remote.tagopt)
              __git_config_values -- "$current" "$parts[5]" \
                --tags:'automatically follow tags' \
                --no-tags:'do not automatically follow tags' && ret=0
              ;;
            (sendemail.aliasfiletype)
              __git_config_values -- "$current" "$parts[5]" \
                elm:'elm(1)' \
                gnus:'gnus(1)' \
                mutt:'mutt(1)' \
                mailrc:'mailrc(5)' \
                pine:'pine(1)' && ret=0
              ;;
            (sendemail.confirm)
              __git_sendemail_confirm_values && ret=0
              ;;
            (sendemail.smtpencryption)
              __git_sendemail_smtpencryption_values && ret=0
              ;;
            (sendemail.suppresscc)
              __git_sendemail_suppresscc_values && ret=0
              ;;
            (status.showUntrackedFiles)
              __git_config_values -- "$current" "$parts[5]" \
                no:'do not show untracked files' \
                normal:'show untracked files and directories' \
                all:'show all individual files in directories' && ret=0
              ;;
            (refname|string)
              # TODO: Something better?
              if [[ -n $current ]]; then
                compadd - $current && ret=0
              elif [[ -n $parts[5] ]]; then
                compadd - $parts[5] && ret=0
              else
              #  _message 'refname'
                _message "${parts[3]:-${parts[2]:-value}}"
              fi
              ;;
            (submodule.update)
              compset -P '*!'
              if [[ -n $IPREFIX ]]; then
                _command_names -e
              else
                __git_config_values -- "$current" "$parts[5]" \
                rebase:'rebase current branch onto commit recorded in superproject' \
                merge:'merge commit recorded in superproject into current branch of submodule' \
                none:'do not merge or rebase' \
                '!:specify command name that takes sha1 to update to as parameter' && ret=0
              fi
              ;;
            (submodule.ignore)
              __git_config_values -- "$current" "$parts[5]" \
                all:'never consider submodules modified' \
                dirty:'ignore all changes to submodule work tree, only take diff between HEAD and recorded commit' \
                untracked:'show modified tracked files' \
                none:'show modified tracked and untracked files' && ret=0
              ;;
            (umask)
              _alternative \
                'values:value:(user)' \
                'umasks: :__git_guard_number umask' && ret=0
              ;;
            (unknown)
              _message "$line[1] option value"
              compadd - $current && ret=0
              ;;
          esac
          ;;
        (*)
          # TODO: Do we need to set up a _requested/_next_label?
          declare -a action
          _description values expl "$parts[3]"
          eval "action=($parts[4])"
          "$action[1]" "$expl[@]" "${(@)action[2,-1]}" && ret=0
          ;;
      esac
      ;;
  esac

  return ret
}

(( $+functions[_git-fast-export] )) ||
_git-fast-export () {
  # TODO: * should be git-rev-arg and git-rev-list arguments.
  _arguments -S -s $endopt \
    '--progress=[insert progress statements]: :__git_guard_number interval' \
    '--signed-tags=[specify how to handle signed tags]:action:((verbatim\:"silently export"
                                                                warn\:"export, but warn"
                                                                warn-strip\:"export as unsigned tags, but warn"
                                                                strip\:"export as unsigned tags instead"
                                                                abort\:"abort on signed tags (default)"))' \
    '--tag-of-filtered-object=[specify how to handle tags whose tagged object is filtered out]:action:((abort\:"abort on such tags"
                                                                                                        drop\:"omit such tags"
                                                                                                        rewrite\:"tag ancestor commit"))' \
    '-M-[detect moving lines in the file as well]: : :__git_guard_number "number of characters"' \
    '-C-[detect copies as well as renames with given scope]: :__git_guard_number size' \
    '--reencode=[specify how to handle encoding header in commit objects]:mode [abort]:(yes no abort)' \
    '--export-marks=[dump internal marks table when complete]: :_files' \
    '--import-marks=[load marks before processing input]: :_files' \
    '--import-marks-if-exists=[load marks from file if it exists]: :_files' \
    '--fake-missing-tagger=[fake a tagger when tags lack them]' \
    '--use-done-feature[start with a "feature done" stanza, and terminate with a "done" command]' \
    "--no-data[skip output of blob objects, instead referring to them via their SHA-1 hash]" \
    '--full-tree[output full tree for each commit]' \
    '(--get --get-all)--name-only[show variable names only]' \
    '*--refspec=[apply refspec to exported refs]:refspec' \
    '--anonymize[anonymize output]' \
    '*--anonymize-map[apply conversion in anonymized output]:from\:to' \
    '--reference-excluded-parents[reference parents not in fast-export stream by object id]' \
    '--show-original-ids[show original object ids of blobs/commits]' \
    '--mark-tags[label tags with mark ids]' \
    '*: :__git_commit_ranges'
}

(( $+functions[_git-fast-import] )) ||
_git-fast-import () {
  _arguments -S -A '-*' $endopt \
    '--cat-blob-fd=-[write responses to cat-blob and ls queries to <fd> instead of stdout]:file descriptor' \
    '--date-format=-[type of dates used in input]:format:((raw\:"native Git format"
                                                           rfc2822\:"standard email format from RFC 2822"
                                                           now\:"use current time and timezone"' \
    '--done[terminate with error if there is no "done" command at the end of the stream]' \
    '--force[force updating modified existing branches]' \
    '--max-pack-size=-[maximum size of each packfile]: : __git_guard_bytes -d unlimited size' \
    '--big-file-threshold=-[maximum size of blob to create deltas for]: : __git_guard_bytes -d 512m size' \
    '--depth=-[maximum delta depth for blob and tree deltification]: :__git_guard_number "maximum delta depth"' \
    '--active-branches=-[maximum number of branches to maintain active at once]: :__git_guard_number "maximum number of branches"' \
    '--export-marks=-[dump internal marks table when complete]: :_files' \
    '--import-marks=-[load marks before processing input]: :_files' \
    '*--relative-marks[paths for export/import are relative to internal directory in current repository]' \
    '*--no-relative-marks[paths for export/import are not relative to internal directory in current repository]' \
    '--export-pack-edges=-[list packfiles and last commit on branches in them in given file]: :_files' \
    '--quiet[disable all non-fatal output]' \
    '--stats[display statistics about object created]'
}

(( $+functions[_git-filter-branch] )) ||
_git-filter-branch () {
  # TODO: --*-filter should take a whole command line.
  # TODO: --original should take subdirectory under .git named refs/* or some
  # such.
  # TODO: * should be git-rev-arg and git-rev-list arguments.
  _arguments -S -A '-*' $endopt \
    '--setup[specify one time setup command]: :_cmdstring' \
    '--env-filter[filter for modifying environment in which commit will be performed]: :_cmdstring' \
    '--tree-filter[filter for rewriting tree and its contents]: :_cmdstring' \
    '--index-filter[filter for rewriting index]: :_cmdstring' \
    '--parent-filter[filter for rewriting parent list of commit]: :_cmdstring' \
    '--msg-filter[filter for rewriting commit messages]: :_cmdstring' \
    '--commit-filter[filter for rewriting commit]: :_cmdstring' \
    '--tag-name-filter[filter for rewriting tag names]: :_cmdstring' \
    '--subdirectory-filter[only look at history that touches given directory]: :_directories' \
    '--prune-empty[ignore empty generated commits]' \
    '--original[namespace where original commits will be stored]:namespace:_directories' \
    '-d[temporary directory used for rewriting]: :_directories' \
    '(-f --force)'{-f,--force}'[force operation]' \
    '--state-branch[load mapping from old to new objects from specified branch]:branch:__git_branch_names' \
    '*: :__git_commit_ranges'
}

(( $+functions[_git-mergetool] )) ||
_git-mergetool () {
  # TODO: Only complete files with merge conflicts.
  _arguments -S -A '-*' \
    '(-t --tool)'{-t,--tool=}'[merge resolution program to use]: :__git_mergetools' \
    '--tool-help[print a list of merge tools that may be used with "--tool"]' \
    '(-y --no-prompt --prompt)'{-y,--no-prompt}'[do not prompt before invocation of merge resolution program]' \
    '(-y --no-prompt)--prompt[prompt before invocation of merge resolution program]' \
    '(-g --gui)'{-g,--gui}'[use merge.guitool variable instead of merge.tool]' \
    '!(-g --gui)--no-gui' \
    '-O-[process files in the order specified in file]:order file:_files' \
    '*:conflicted file:_files'
}

(( $+functions[_git-pack-refs] )) ||
_git-pack-refs () {
  _arguments -S $endopt \
    '(      --no-all)--all[pack all refs]' \
    '(--all         )--no-all[do not pack all refs]' \
    '(        --no-prune)--prune[remove loose refs after packing them]' \
    '(--prune           )--no-prune[do not remove loose refs after packing them]'
}

(( $+functions[_git-prune] )) ||
_git-prune () {
  _arguments -s -S $endopt \
    '(-n --dry-run)'{-n,--dry-run}'[do not remove anything; just report what would be removed]' \
    '(-v --verbose)'{-v,--verbose}'[report all removed objects]' \
    '--progress[show progress]' \
    '--expire=[only expire loose objects older than specified date]: :__git_datetimes' \
    '--exclude-promisor-objects[limit traversal to objects outside promisor packfiles]' \
    '*:: :__git_heads'
}

(( $+functions[_git-reflog] )) ||
_git-reflog () {
  declare -a revision_options
  __git_setup_revision_options

  if [[ $words[2] == --* ]]; then
    _arguments -S \
      $revision_options \
      ':: :__git_references'
  else
    local curcontext=$curcontext state line ret=1
    declare -A opt_args

    # TODO: -h is undocumented.
    _arguments -C -S \
      '(- : *)-h[display usage]' \
      $revision_options \
      ': :->command' \
      '*:: :->option-or-argument' && ret=0

    case $state in
      (command)
        declare -a commands

        commands=(
          'expire:prune old reflog entries'
          'delete:delete entries from reflog'
          'show:show log of ref'
          'exists:check whether a ref has a reflog'
	)

        _alternative \
          'commands:: _describe -t commands command commands' \
          'references:: __git_references' && ret=0
        ;;
      (option-or-argument)
        curcontext=${curcontext%:*}-$line[1]:

        case $line[1] in
          (expire)
            _arguments -S \
              '(-n --dry-run)'{-n,--dry-run}"[don't actually prune any entries; show what would be pruned]" \
              '--stale-fix[prune any reflog entries that point to "broken commits"]' \
              '--expire=-[prune entries older than given time]: :__git_datetimes' \
              '--expire-unreachable=-[prune entries older than given time and unreachable]: :__git_datetimes' \
              '--all[prune all refs]' \
              '--updateref[update ref with SHA-1 of top reflog entry after expiring or deleting]' \
              '--rewrite[adjust reflog entries to ensure old SHA-1 points to new SHA-1 of previous entry after expiring or deleting]' \
              '--verbose[output additional information]' && ret=0
            ;;
          (delete)
            _arguments -C -S \
              '(-n --dry-run)'{-n,--dry-run}"[dpn't update entries; show what would be done]" \
              '--updateref[update ref with SHA-1 of top reflog entry after expiring or deleting]' \
              '--rewrite[adjust reflog entries to ensure old SHA-1 points to new SHA-1 of previous entry after expiring or deleting]' \
              '--verbose[output additional information]' \
              '*:: :->reflog-entry' && ret=0

            case $state in
              (reflog-entry)
                # TODO: __git_ignore_line doesn't work here for some reason.
                __git_ignore_line __git_reflog_entries && ret=0
                ;;
            esac
            ;;
          (show|--*)
            _arguments -S \
              $revision_options \
              ':: :__git_references' && ret=0
            ;;
	  (exists)
	    __git_references && ret=0
	    ;;
        esac
    esac

    return ret
  fi
}

(( $+functions[_git-remote] )) ||
_git-remote () {
  local curcontext=$curcontext state line ret=1
  declare -A opt_args

  _arguments -C \
    '(-v --verbose)'{-v,--verbose}'[show remote url after name]' \
    ': :->command' \
    '*:: :->option-or-argument' && ret=0

  case $state in
    (command)
      declare -a commands

      commands=(
        'add:add a new remote'
	'get-url:retrieves the URLs for a remote'
        'rename:rename a remote and update all associated tracking branches'
	{rm,remove}':remove a remote and all associated tracking branches'
        'set-head:set or delete default branch for a remote'
        'set-branches:change list of branches tracked by a remote'
        'set-url:change URL for a remote'
        'show:show information about a given remote'
        'prune:delete all stale tracking branches for a remote'
        'update:fetch updates for a set of remotes'
      )

      _describe -t commands command commands && ret=0
      ;;
    (option-or-argument)
      curcontext=${curcontext%:*}-$line[1]:

      case $line[1] in
        (add)
          # TODO: -t and --track should really list branches at url.
          _arguments -S -s $endopt \
            '(-f --fetch)'{-f,--fetch}'[run git fetch on new remote after it has been created]' \
            '(       --no-tags)--tags[tell git fetch to import every tag from remote repository]' \
            '(--tags          )--no-tags[tell git fetch to not import every tag from remote repository]' \
            '*'{-t,--track=}'[track given branch instead of default glob refspec]: :__git_branch_names' \
            '(-m --master)'{-m,--master=}'[set HEAD of remote to point to given master branch]: :__git_branch_names' \
	    '--mirror[do not use separate remotes]::mirror type:(fetch pull)' \
            ':name:__git_remotes' \
            ':repository:__git_repositories_or_urls' && ret=0
          ;;
        (get-url)
          _arguments -S -s $endopt \
            '--push[list push URL instead of fetch URL]' \
            '--all[list all URLs for the remote]' \
            ': :__git_remotes' && ret=0
          ;;
        (rename)
          _arguments \
            ':old name:__git_remotes' \
            ':new name:__git_remotes' && ret=0
          ;;
        (set-head)
          # TODO: Second argument should be a branch at url for remote.
          _arguments -S -s $endopt \
            '(- 2)'{-d,--delete}'[delete default branch]' \
            '(- 2)'{-a,--auto}'[determine default branch automatically]' \
            ': :__git_remotes' \
            ': :__git_branch_names' && ret=0
          ;;
        (set-branches)
          # TODO: Branches should be at url.
          _arguments -S -s $endopt \
            '--add[add branches to those already defined]' \
            ': :__git_remotes' \
            '*: :__git_branch_names' && ret=0
          ;;
        (set-url)
          _arguments -S $endopt \
            '--push[manipulate push URLs instead of fetch URLs]' \
            '(3)--add[add URL to those already defined]' \
            '(2)--delete[delete all matching URLs]' \
            '1: :__git_remotes' \
            '2:new url:__git_repositories_or_urls' \
            '3:old url: __git_current_remote_urls ${(k)opt_args[--push]} $line[1]' && ret=0
          ;;
        (show)
          _arguments -S $endopt \
            '-n[do not contact the remote for a list of branches]' \
            '*: :__git_remotes' && ret=0
          ;;
        (prune)
          _arguments -S -s $endopt \
            '(-n --dry-run)'{-n,--dry-run}'[do not actually prune, only list what would be done]' \
            '*: :__git_remotes' && ret=0
          ;;
        (update)
          _arguments -S -s $endopt \
            '(-p --prune)'{-p,--prune}'[prune all updated remotes]' \
            ': :__git_remote-groups' && ret=0
          ;;
	(*) # rm, remove and fallback for any new subcommands
	  __git_remotes && ret=0
	  ;;
      esac
      ;;
  esac

  return ret
}

(( $+functions[_git-repack] )) ||
_git-repack () {
  _arguments -s \
    '(-A --unpack-unreachable)-a[pack all objects into a single pack]' \
    '(-a -k --keep-unreachable)-A[pack all objects into a single pack, but unreachable objects become loose]' \
    '-d[remove redundant packs after packing]' \
    "--unpack-unreachable=[with -A, don't loosen objects older than specified date]:date" \
    '-f[pass --no-reuse-delta option to git pack-objects]' \
    '-F[pass --no-reuse-object option to git pack-objects]' \
    "-n[don't update server information]" \
    '(-q --quiet)'{-q,--quiet}'[pass -q option to git pack-objects]' \
    '(-l --local)'{-l,--local}'[pass --local option to git pack-objects]' \
    '(-b --write-bitmap-index)'{-b,--write-bitmap-index}'[write a bitmap index]' \
    '(-i --delta-islands)'{-i,--delta-islands}'[pass --delta-islands to git-pack-objects]' \
    "--unpack-unreachable=[with -A, don't loosen objects older than specified time]:time" \
    '(-k --keep-unreachable)'{-k,--keep-unreachable}'[with -a, repack unreachable objects]' \
    '--window=[number of objects to consider when doing delta compression]:number of objects' \
    '--window-memory=[scale window size dynamically to not use more than specified amount of memory]: : __git_guard_bytes' \
    '--depth=[maximum delta depth]:maximum delta depth' \
    '--threads=[limit maximum number of threads]:threads' \
    '--max-pack-size=-[maximum size of each output packfile]: : __git_guard_bytes "maximum pack size"' \
    '--pack-kept-objects[repack objects in packs marked with .keep]' \
    '--keep-pack=[ignore named pack]:pack' \
    '(-g --geometric)'{-g+,--geometric=}'[find a geometric progression with specified factor]:factor' \
    '(-m --write-midx)'{-m,--write-midx}'[write a multi-pack index of the resulting packs]'
}

(( $+functions[_git-replace] )) ||
_git-replace () {
  _arguments -S -s $endopt \
    '(-d --delete -l --list -g --graft *)'{-f,--force}'[overwrite existing replace ref]' \
    "(-d --delete -l --list -g --graft 2 *)--raw[don't pretty-print contents for --edit]" \
    '(-d --delete -e --edit -g --graft --raw)--format=[use specified format]:format:(short medium long)' \
    ': :__git_objects' \
    ':replacement:__git_objects' \
    '*: :__git_objects' \
    - '(actions)' \
    '(: * --raw -f --force)'{-l,--list}'[list replace refs]:pattern' \
    {-d,--delete}'[delete existing replace refs]:*:replacement:__git_objects' \
    '(* 2 --format)'{-e,--edit}'[edit existing object and replace it with the new one]' \
    '(--raw --format)'{-g,--graft}'[rewrite the parents of a commit]' \
    '--convert-graft-file[convert existing graft file]'
}

# Ancillary Commands (Interrogators)

(( $+functions[_git-annotate] )) ||
_git-annotate() {
  _git-blame "$@"
}

(( $+functions[_git-blame] )) ||
_git-blame () {
  local curcontext=$curcontext state line ret=1
  declare -A opt_args

  declare -a revision_options
  __git_setup_revision_options

  # TODO: Not sure about __git_cached_files.
  _arguments -C -S -s $endopt \
    '-b[show blank SHA-1 for boundary commits]' \
    '--root[do not treat root commits as boundaries]' \
    '--show-stats[include additional statistics at the end of blame output]' \
    '--progress[force progress reporting]' \
    '*-L[annotate only the given line range]: :->line-range' \
    '-l[show long rev]' \
    '-t[show raw timestamp]' \
    '-S[use revs from revs-file]:revs-file:_files' \
    '--reverse[walk history forward instead of backward]' \
    '(-p --porcelain)'{-p,--porcelain}'[show results designed for machine processing]' \
    '--line-porcelain[show results designed for machine processing but show commit information for every line]' \
    '--incremental[show results incrementally for machine processing]' \
    '--contents[annotate against the given file if no rev is specified]: :_files' \
    '(-h --help)'{-h,--help}'[show help message]' \
    '-c[use same output format as git annotate]' \
    '--score-debug[output debugging information relating to -C and -M line movement]' \
    '(-e --show-email)'{-e,--show-email}'[show the author email instead of the author name]' \
    '(-f --show-name)'{-f,--show-name}'[show the filename of the original commit]' \
    '(-n --show-number)'{-n,--show-number}'[show the line number in the original commit]' \
    '-s[suppress author name and timestamp]' \
    '-w[ignore whitespace when finding lines]' \
    '--ignore-rev=[ignore specified revision when blaming]:revision:__git_revisions' \
    '--ignore-revs-file=[ignore revisions from file]:file:_files' \
    '(--color-by-age)--color-lines[color redundant metadata from previous line differently]' \
    '(--color-lines)--color-by-age[color lines by age]' \
    $revision_options \
    ':: :__git_revisions' \
    ': :__git_cached_files' && ret=0

  case $state in
    (line-range)
      if compset -P '([[:digit:]]#|/[^/]#(\\?[^/]#)#/),'; then
        _alternative \
          'line-numbers: :__git_guard_number "line number"' \
          'regexes::_guard "(/[^/]#(\\?[^/]#)#(/|)|)" regex' \
          'offsets::_guard "([+-][[:digit:]]#|)" "line offset"' && ret=0
      else
        _alternative \
          'line-numbers: :__git_guard_number "line number"' \
          'regexes::_guard "(/[^/]#(\\?[^/]#)#(/|)|)" regex' && ret=0
      fi
      ;;
  esac

  return ret
}

(( $+functions[_git-bugreport] )) ||
_git-bugreport() {
  _arguments \
    '(-o --output-directory)'{-o+,--output-directory=}'[specify a destination for the bugreport file]:directory:_directories' \
    '(-s --suffix)'{-s+,--suffix=}'[specify a strftime format suffix for the filename]:format:_date_formats'
}

(( $+functions[_git-cherry] )) ||
_git-cherry () {
  _arguments -S $endopt \
    '(-v --verbose)'{-v,--verbose}'[output additional information]' \
    '--abbrev=[use specified digits to display object names]:digits' \
    ':upstream commit:__git_commits' \
    '::head commit:__git_commits' \
    '::limit commit:__git_commits'
}

(( $+functions[_git-count-objects] )) ||
_git-count-objects () {
  _arguments -s -S $endopt \
    '(-v --verbose)'{-v,--verbose}'[also report number of in-pack objects and objects that can be removed]' \
    {-H,--human-readable}'[print sizes in human readable format]'
}

(( $+functions[_git-difftool] )) ||
_git-difftool () {
  # TODO: Is this fine, or do we need to modify the context or similar?
  _git-diff \
    '(-d --dir-diff --no-index)'{-d,--dir-diff}'[diff a whole tree by preparing a temporary copy]' \
    '(-y --no-prompt --prompt)'{-y,--no-prompt}'[do not prompt before invocation of diff tool]' \
    '(-y --no-prompt)--prompt[prompt before invocation of diff tool]' \
    '(-t --tool -x --extcmd)'{-t,--tool=-}'[merge resolution program to use]: :__git_difftools' \
    '(-t --tool -x --extcmd)'{-x,--extcmd=-}'[custom diff command to use]: :_cmdstring' \
    '--tool-help[print a list of diff tools that may be used with --tool]' \
    '(--symlinks)--no-symlinks[make copies of instead of symlinks to the working tree]' \
    '(---no-symlinks)--symlinks[make symlinks to instead of copies of the working tree]' \
    '(-g --gui)'{-g,--gui}'[use diff.guitool instead of diff.tool]' \
    '--trust-exit-code[make git-difftool exit when diff tool returns a non-zero exit code]'
}

(( $+functions[_git-fsck] )) ||
_git-fsck () {
  _arguments -S -s $endopt \
    '--unreachable[show objects that are unreferenced in the object database]' \
    '(--dangling --no-dangling)--dangling[print dangling objects (default)]' \
    '(--dangling --no-dangling)--no-dangling[do not print dangling objects]' \
    '--root[show root nodes]' \
    '--tags[show tags]' \
    '--cache[consider objects recorded in the index as head nodes for reachability traces]' \
    '--no-reflogs[do not consider commits referenced only by reflog entries to be reachable]' \
    '--full[check all object directories]' \
    '--connectivity-only[check only connectivity]' \
    '--strict[do strict checking]' \
    '(-v --verbose)'{-v,--verbose}'[output additional information]' \
    '--lost-found[write dangling objects into .git/lost-found]' \
    '--progress[show progress]' \
    '--name-objects[show verbose names for reachable objects]' \
    '*: :__git_objects'
}

(( $+functions[_git-get-tar-commit-id] )) ||
_git-get-tar-commit-id () {
  _message 'no arguments allowed; accepts tar-file on standard input'
}

(( $+functions[_git-help] )) ||
_git-help () {
  _arguments -S -s \
    '(-c --config -i --info -m --man -w --web)'{-a,--all}'[show all available commands]' \
    '(-)'{-c,--config}'[print all configuration variable names]' \
    '(-a --all -g --guides -c --config -m --man -w --web)'{-i,--info}'[display manual for the command in info format]' \
    '(-a --all -g --guides -c --config -i --info -w --web)'{-m,--man}'[display manual for the command in man format]' \
    '(-a --all -g --guides -c --config -i --info -m --man)'{-w,--web}'[display manual for the command in HTML format]' \
    '(-g --guides -c --config -i --info -m --man -w --web)'{-g,--guides}'[prints a list of useful guides on the standard output]' \
    '(-v --verbose)'{-v,--verbose}'[print command descriptions]' \
    ': : _alternative commands:command:_git_commands "guides:git guide:(attributes cli core-tutorial cvs-migration diffcore everyday glossary hooks ignore modules namespaces repository-layout revisions tutorial tutorial-2 workflows)"'
}

(( $+functions[_git-instaweb] )) ||
_git-instaweb () {
  local curcontext=$curcontext state line ret=1
  declare -A opt_args

  _arguments -C -S -s $endopt \
    '(-l --local)'{-l,--local}'[bind the web server to 127.0.0.1]' \
    '(-d --httpd)'{-d,--httpd=}'[HTTP-daemon command-line that will be executed]:command line' \
    '(-m --module-path)'{-m,--module-path=}'[module path for the Apache HTTP-daemon]:module path:_directories' \
    '(-p --port)'{-p,--port=}'[port to bind web server to]: :__git_guard_number port' \
    '(-b --browser)'{-b,--browser=}'[web-browser command-line that will be executed]:command line' \
    '(:)--start[start the HTTP-daemon and exit]' \
    '(:)--stop[stop the HTTP-daemon and exit]' \
    '(:)--restart[restart the HTTP-daemon and exit]' \
    ': :->command' && ret=0

  case $state in
    (command)
      declare -a commands

      commands=(
        start:'start the HTTP-daemon and exit'
        stop:'stop the HTTP-daemon and exit'
        restart:'restart the HTTP-daemon and exit')

      _describe -t commands command commands && ret=0
      ;;
  esac

  return ret
}

(( $+functions[_git-merge-tree] )) ||
_git-merge-tree () {
  _arguments \
    ':base-tree:__git_tree_ishs' \
    ':branch 1:__git_tree_ishs' \
    ':branch 2:__git_tree_ishs'
}

(( $+functions[_git-rerere] )) ||
_git-rerere () {
  local curcontext=$curcontext state line ret=1
  declare -A opt_args

  _arguments -C -S -s $endopt \
    '--rerere-autoupdate[register clean resolutions in index]' \
    ': :->command' && ret=0

  case $state in
    (command)
      # TODO: This isn't optimal, as forget get confused.
      _values command \
        'clear[reset metadata used by rerere]' \
        'forget[resets metadata used by rerere for specific conflict]: :__git_cached_files' \
        'diff[output diffs for the current state of the resolution]' \
        'status[print paths with conflicts whose merge resolution rerere will record]' \
        'remaining[print paths with conflicts that have not been autoresolved by rerere]' \
        'gc[prune old records of conflicted merges]' && ret=0
      ;;
  esac

  return ret
}

(( $+functions[_git-rev-parse] )) ||
_git-rev-parse () {
  local parseopt_opt= sq_quote_opt= local_env_vars_opt= h_opt=
  declare -a quiet_opts
  if (( CURRENT == 2 )); then
    parseopt_opt='--parseopt[use git rev-parse in option parsing mode]'
    sq_quote_opt='--sq-quote[use git rev-parse in shell quoting mode]'
    local_env_vars_opt='--local-env-vars[list git environment variables local to repository]'
    h_opt='-h[display usage]'
  fi

  if (( words[(I)--verify] )); then
    quiet_opts=({-q,--quiet}'[do not output error messages]')
  fi

  local ret=0

  if (( words[(I)--parseopt] )); then
    if (( words[(I)--] )); then
      _message 'argument'
    else
      # TODO: Parse option specification?
      _arguments -S -s \
        '(- *)'{-h,--help}'[display usage]' \
        '--keep-dashdash[do not skip first -- option]' \
        '--stop-at-non-option[stop parsing options at first non-option argument]' \
        '--stuck-long[output options in long form if available, and with their arguments stuck]' \
        '*:option specification' && ret=0
    fi
  elif (( words[(I)--sq-quote] )); then
    _message 'argument'
  elif (( words[(I)--local-env-vars|-h] )); then
    _message 'no more arguments'
  else
    _arguments \
      $parseopt_opt \
      $sq_quote_opt \
      $local_env_vars_opt \
      $h_opt \
      '(            --no-revs --verify --short)--revs-only[do not output flags and parameters not meant for git rev-list]' \
      '(--revs-only           --verify --short)--no-revs[do not output flags and parameters meant for git rev-list]' \
      '(        --no-flags --verify --short)--flags[do not output non-flag parameters]' \
      '(--flags            --verify --short)--no-flags[do not output flag parameters]' \
      '--default[use given argument if there is no parameter given]:argument' \
      '(--revs-only --no-revs --flags --no-flags --short)--verify[verify parameter to be usable]' \
      '(-q --quiet)'{-q,--quiet}'[suppress all output]' \
      '--sq[output single shell-quoted line]' \
      '--not[toggle ^ prefix of object names]' \
      '(           --symbolic-full-name)--symbolic[output in a format as true to input as possible]' \
      '(--symbolic                     )--symbolic-full-name[same as --symbolic, but omit non-ref inputs]' \
      '--abbrev-ref=-[a non-ambiguous short name of object]::mode:(strict loose)' \
      '--disambiguate=-[show every object whose name begins with the given prefix]:prefix' \
      '--all[show all refs found in refs/]' \
      '--branches=-[show branch refs found in refs/heads/]::shell glob pattern' \
      '--tags=-[show tag refs found in refs/tags/]::shell glob pattern' \
      '--remotes=-[show tag refs found in refs/remotes/]::shell glob pattern' \
      '--glob=-[show all matching refs]::shell glob pattern' \
      '--show-toplevel[show absolute path of top-level directory]' \
      '--show-prefix[show path of current directory relative to top-level directory]' \
      '--show-cdup[show path of top-level directory relative to current directory]' \
      '--git-dir[show $GIT_DIR if defined else show path to .git directory]' \
      '--is-inside-git-dir[show whether or not current working directory is below repository directory]' \
      '--is-inside-work-tree[show whether or not current working directory is inside work tree]' \
      '--is-bare-repository[show whether or not repository is bare]' \
      '(--revs-only --no-revs --flags --no-flags --verify)--short=-[show only shorter unique name]:: :__git_guard_number length' \
      '(--since --after)'{--since=-,--after=-}'[show --max-age= parameter corresponding given date string]:datestring' \
      '(--until --before)'{--until=-,--before=-}'[show --min-age= parameter corresponding given date string]:datestring' \
      '--resolve-git-dir[check if <path> is a valid repository or gitfile and print location]:git dir:_files -/' \
      '*: :__git_objects' && ret=0
  fi

  return ret
}

(( $+functions[_git-show-branch] )) ||
_git-show-branch () {
  local curcontext=$curcontext state line ret=1
  declare -A opt_args

  _arguments -C -S -s $endopt \
    '(--more        --merge-base --independent)--list[do not show any ancestry (--more=-1)]' \
    - branches \
      '(-r --remotes -a --all)'{-r,--remotes}'[show remote-tracking branches]' \
      '(-r --remotes -a --all)'{-a,--all}'[show both remote-tracking branches and local branches]' \
      '--current[include current branch to the list of revs]' \
      '(             --date-order)--topo-order[show commits in topological order]' \
      '(--topo-order             )--date-order[show commits in commit-date order]' \
      '--sparse[output merges that are reachable from multiple tips being shown]' \
      '(       --list --merge-base --independent)--more=[go given number of commit beyond common ancestor (no ancestry if negative)]:: :_guard "(-|)[[\:digit\:]]#" limit' \
      '(--more --list              --independent)--merge-base[act like git merge-base -a, but with two heads]' \
      '(--more --list --merge-base              )--independent[show only the reference that can not be reached from any of the other]' \
      '(          --sha1-name)--no-name[do not show naming strings for each commit]' \
      '(--no-name            )--sha1-name[name commits with unique prefix of object names]' \
      '--topics[show only commits that are NOT on the first branch given]' \
      '(        --no-color)--color[color status sign of commits]:: :__git_color_whens' \
      '(--color           )--no-color[do not color status sign of commits]' \
      '*: :__git_revisions' \
    - reflogs \
      '(-g --reflog)'{-g,--reflog=}'[show reflog entries for given ref]:: :->limit-and-base' \
      ': :__git_references' && ret=0

  case $state in
    (limit-and-base)
      if compset -P '[[:digit:]]##,'; then
        _alternative \
          'counts: :__git_guard_number count' \
          'dates::__git_datetimes' && ret=0
      else
        __git_guard_number limit
      fi
      ;;
  esac

  return ret
}

(( $+functions[_git-verify-commit] )) ||
_git-verify-commit () {
  _arguments -S -s $endopt \
    '(-v --verbose)'{-v,--verbose}'[print contents of the commit object before validating it]' \
    '--raw[print raw gpg status output]' \
    '*: :__git_commits'
}

(( $+functions[_git-verify-tag] )) ||
_git-verify-tag () {
  _arguments -S -s $endopt \
    '(-v --verbose)'{-v,--verbose}'[print contents of the tag object before validating it]' \
    '--raw[print raw gpg status output]' \
    '--format=[specify format to use for the output]:format:__git_format_ref' \
    '*: :__git_tags'
}

(( $+functions[_git-whatchanged] )) ||
_git-whatchanged () {
  local -a revision_options
  __git_setup_revision_options

  _arguments -s -S $endopt \
    $revision_options \
    '1:: :__git_commits' \
    '*: :__git_cached_files'
}

# Interacting With Others

(( $+functions[_git-archimport] )) ||
_git-archimport () {
  # TODO: archive/branch can perhaps use _arch_archives.  It should also allow
  # an optional colon followed by a __git_branches.
  _arguments \
    '-h[display usage]' \
    '-v[verbose output]' \
    '-T[create tag for every commit]' \
    '-f[use fast patchset import strategy]' \
    '-o[use old-style branch names]' \
    '-D[attempt to import trees that have been merged from]: :__git_guard_number depth' \
    '-a[auto-register archives at http://mirrors.sourcecontrol.net]' \
    '-t[use given directory as temporary directory]: :_directories' \
    '*:archive/branch'
}

(( $+functions[_git-cvsexportcommit] )) ||
_git-cvsexportcommit () {
  # TODO: Could use _cvs_root from _cvs for completing argument to -d.
  _arguments \
    '-c[commit automatically if patch applied cleanly]' \
    '-p[be pedantic (paranoid) when applying patches]' \
    '-a[add authorship information]' \
    '-d[set an alternative CVSROOT to use]:cvsroot' \
    '-f[force the merge, even if files are not up to date]' \
    '-P[force the parent commit, even if it is not a direct parent]' \
    '-m[prepend the commit message with the provided prefix]:message prefix' \
    '-u[update affected files from CVS repository before attempting export]' \
    '-k[reverse CVS keyword expansion]' \
    '-w[specify location of CVS checkout to use for export]' \
    '-W[use current working directory for bot Git and CVS checkout]' \
    '-v[verbose output]' \
    '-h[display usage]' \
    ':: :__git_commits' \
    ': :__git_commits'
}

(( $+functions[_git-cvsimport] )) ||
_git-cvsimport () {
  # TODO: _cvs_root for -d would be nice
  _arguments \
    '-v[verbose output]' \
    '-d[specify the root of the CVS archive]:cvsroot' \
    '-C[specify the git repository to import into]:directory:_directories' \
    '-r[the git remote to import into]:remote' \
    '-o[specify the branch into which you wish to import]: :__git_branch_names' \
    '-i[do not perform a checkout after importing]' \
    '-k[remove keywords from source files in the CVS archive]' \
    '-u[convert underscores in tag and branch names to dots]' \
    '-s[substitute the "/" character in branch names with given substitution]:substitute' \
    '-p[specify additional options for cvsps]:cvsps-options' \
    '-z[specify timestamp fuzz factor to cvsps]:fuzz-factor' \
    '-P[read cvsps output file]:file:_files' \
    '-m[attempt to detect merges based on the commit message]' \
    '*-M[attempt to detect merges based on the commit message with custom pattern]:pattern' \
    '-S[skip paths matching given regex]:regex' \
    '-a[import all commits, including recent ones]' \
    '-L[limit the number of commits imported]:limit' \
    '-A[specify author-conversion file]:author-conversion file:_files' \
    '-R[generate cvs-revisions file mapping CVS revision numbers to commit IDs]' \
    '-h[display usage information]' \
    ':cvsmodule'
}

(( $+functions[_git-cvsserver] )) ||
_git-cvsserver () {
  _arguments -S -s \
    '--base-path[path to prepend to requested CVSROOT]: :_directories' \
    '--strict-paths[do not allow recursing into subdirectories]' \
    '--export-all[do not check for gitcvs.enabled]' \
    '(- * -V --version)'{-V,--version}'[display version information]' \
    '(- * -h --help)'{-h,-H,--help}'[display usage information]' \
    '::type:(pserver server)' \
    '*: :_directories'
}

(( $+functions[_git-imap-send] )) ||
_git-imap-send () {
  _arguments -S $endopt \
    '--curl[use libcurl to communicate with the IMAP server]' \
    - '(out)' \
    {-v,--verbose}'[be more verbose]' \
    {-q,--quiet}'[be more quiet]'
}

(( $+functions[_git-quiltimport] )) ||
_git-quiltimport () {
  _arguments -S $endopt \
    '(-n --dry-run)'{-n,--dry-run}'[check patches and warn if they cannot be imported]' \
    '--author[default author name and email address to use for patches]: :_email_addresses' \
    '--patches[set directory containing patches]:patch directory:_directories' \
    '--series[specify quilt series file]:series file:_files' \
    '--keep-non-patch[pass -b to git mailinfo]'
}

(( $+functions[_git-request-pull] )) ||
_git-request-pull () {
  _arguments -S $endopt \
    '-p[display patch text]' \
    ':start commit:__git_commits' \
    ': :_urls' \
    '::end commit:__git_commits'
}

(( $+functions[_git-send-email] )) ||
_git-send-email () {
  _arguments -S $endopt \
    '--annotate[review and edit each patch before sending it]' \
    '--bcc=[Bcc: value for each email]: :_email_addresses' \
    '--cc=[starting Cc: value for each email]: :_email_addresses' \
    '--to-cover[copy the To: list from the first file to the rest]' \
    '--cc-cover[copy the Cc: list from the first file to the rest]' \
    '--compose[edit introductory message for patch series]' \
    '--from=[specify sender]:email address:_email_addresses' \
    '--reply-to=[specify Reply-To address]:email address:_email_addresses' \
    '--in-reply-to=[specify contents of first In-Reply-To header]:message-id' \
    '--subject=[specify the initial subject of the email thread]:subject' \
    '--to=[specify the primary recipient of the emails]: :_email_addresses' \
    "--no-xmailer[don't add X-Mailer header]" \
    '--8bit-encoding=[encoding to use for non-ASCII messages]: :__git_encodings' \
    '--compose-encoding=[encoding to use for compose messages]: :__git_encodings' \
    '--transfer-encoding=[specify transfer encoding to use]:transfer encoding:(quoted-printable 8bit base64)' \
    '--envelope-sender=[specify the envelope sender used to send the emails]: :_email_addresses' \
    '--sendmail-cmd=[specify command to run to send email]:command:_cmdstring' \
    '--smtp-encryption=[specify encryption method to use]: :__git_sendemail_smtpencryption_values' \
    '--smtp-domain=[specify FQDN used in HELO/EHLO]: :_domains' \
    '--smtp-pass=[specify password to use for SMTP-AUTH]::password' \
    '--smtp-server=[specify SMTP server to connect to, or sendmail command]: : __git_sendmail_smtpserver_values' \
    '--smtp-server-port=[specify port to connect to SMTP server on]:smtp port:_ports' \
    '--smtp-server-option=[specify the outgoing SMTP server option to use]:SMTP server option' \
    '--smtp-ssl-cert-path=[path to ca-certificates (directory or file)]:ca certificates path:_files' \
    '--smtp-user=[specify user to use for SMTP-AUTH]:smtp user:_users' \
    '(--no-smtp-auth)--smtp-auth=[specify allowed AUTH mechanisms]:space-separated list of mechanisms' \
    '(--smtp-auth)--no-smtp-auth[disable SMTP authentication]' \
    '--smtp-debug=[enable or disable debug output]:smtp debug:((0\:"disable" 1\:"enable"))' \
    '--batch-size=[specify maximum number of messages per connection]:number' \
    '--relogin-delay=[specify delay between successive logins]:delay (seconds)' \
    '--cc-cmd=[specify command to generate Cc\: header with]:Cc\: command:_cmdstring' \
    '--to-cmd=[specify command to generate To\: header with]:To\: command:_cmdstring' \
    '(                 --no-chain-reply-to)--chain-reply-to[send each email as a reply to previous one]' \
    '(--chain-reply-to                    )--no-chain-reply-to[send all emails after first as replies to first one]' \
    '--identity=[specify configuration identity]: :__git_sendemail_identities' \
    '(                   --no-signed-off-by-cc)--signed-off-by-cc[add emails found in Signed-off-by: lines to the Cc: list]' \
    '(--signed-off-by-cc                      )--no-signed-off-by-cc[do not add emails found in Signed-off-by: lines to the Cc: list]' \
    '--suppress-cc=[specify rules for suppressing Cc:]: :__git_sendemail_suppresscc_values' \
    '(                --no-suppress-from)--suppress-from[do not add the From: address to the Cc: list]' \
    '(--suppress-from                   )--no-suppress-from[add the From: address to the Cc: list]' \
    '(         --no-thread)--thread[set In-Reply-To: and References: headers]' \
    '(--thread            )--no-thread[do not set In-Reply-To: and References: headers]' \
    '--confirm[specify type of confirmation required before sending]: :__git_sendemail_confirm_values' \
    '--dry-run[do everything except actually sending the emails]' \
    '(               --no-format-patch)--format-patch[interpret ambiguous arguments as format-patch arguments]' \
    '(--format-patch                  )--no-format-patch[interpret ambiguous arguments file-name arguments]' \
    '--quiet[be less verbose]' \
    '(           --no-validate)--validate[perform sanity checks on patches]' \
    '(--validate              )--no-validate[do not perform sanity checks on patches]' \
    '--force[send emails even if safety checks would prevent it]' \
    '(- *)--dump-aliases[dump configured aliases and exit]' \
    '*: : _alternative -O expl
      "files:file:_files"
      "commits:recent commit object name:__git_commit_objects_prefer_recent"'
}

(( $+functions[_git-svn] )) ||
_git-svn () {
  local curcontext=$curcontext state line ret=1
  declare -A opt_args

  _arguments -C \
    '(- :)'{-V,--version}'[display version information]' \
    '(- :)'{-h,-H,--help}'[display usage information]' \
    ': :->command' \
    '*:: :->option-or-argument' && ret=0

  case $state in
    (command)
      declare -a commands

      commands=(
        blame:'show what revision and author last modified each line of a file'
        branch:'create a branch in the SVN repository'
        clone:'same as init, followed by fetch'
        commit-diff:'commit diff of two tree-ishs'
        create-ignore:'recursively finds the svn:ignore property and creates .gitignore files'
        dcommit:'commit diffs from given head onto SVN repository'
        fetch:'fetch revisions from the SVN remote'
        find-rev:'output git commit corresponding to the given SVN revision'\''s hash'
        gc:'compress git-svn-related information'
        info:'show information about a file or directory'
        init:'initialize an empty git repository with additional svn data'
        log:'output SVN log-messages'
        migrate:'migrate configuration/metadata/layout from previous versions of git-svn'
        mkdirs:'recreate empty directories that Git cannot track'
        propget:'get a given SVN property for a file'
        proplist:'list the SVN properties stored for a file or directory'
        propset:'set the value of a property on a file or directory - will be set on commit'
        rebase:'fetch revs from SVN parent of HEAD and rebase current work on it'
        reset:'undo effect of fetch back to specific revision'
        set-tree:'commit given commit or tree to SVN repository'
        show-externals:'show the subversion externals'
        show-ignore:'output svn:ignore in format of a toplevel .gitignore file'
        tag:'create a tag in the SVN repository'
      )

      _describe -t commands command commands && ret=0
      ;;
    (option-or-argument)
      curcontext=${curcontext%:*}-$line[1]:
      declare -a opts

      case $line[1] in
        (clone|dcommit|fetch|init|migrate|rebase|set-tree)
	  # TODO: --no-auth-cache is undocumented.
	  # TODO: --config-dir is undocumented.
	  opts+=(
	    '--config-dir=:configuration directory:_directories'
	    '--ignore-paths[regular expression of paths to not check out]:perl regex'
	    '--include-paths[regular expression of paths to check out]:perl regex'
	    '--ignore-refs:ref'
	    '--no-auth-cache'
	    '--username=[username to use for SVN transport]: :_users'
	  )
	;|
        (clone|dcommit|fetch|log|rebase|set-tree)
	  opts+=(
	    '(-A --authors-file)'{-A,--authors-file}'[specify author-conversion file]:author-conversion file:_files'
	  )
	;|
        (clone|dcommit|fetch|rebase|set-tree)
	  # TODO: --repack-flags can be improved by actually completing the legal
	  # flags to git-repack.
	  # TODO: --no-checkout is undocumented.
	  opts+=(
	    "--add-author-from[when committing to svn, append a From: line based on the git commit's author string]"
	    '--authors-prog=[specify program used to generate authors]: :_cmdstring'
	    '(--no-follow-parent)--follow-parent[follow parent commit]'
	    "(--follow-parent)--no-follow-parent[don't follow parent commit]"
	    '--localtime[store Git commit times in local timezone]'
	    '--log-window-size=[fetch specified number of log entries per-request]:entries [100]'
	    '--no-checkout'
	    '(-q --quiet)'{-q,--quiet}'[make git-svn less verbose]'
	    '(--repack-flags --repack-args --repack-opts)'{--repack-flags=,--repack-args=,--repack-opts=}'[flags to pass to git-repack]:git-repack flags'
	    '--repack=[repack files (for given number of revisions)]:: :__git_guard_number "revision limit"'
	    '--use-log-author[use author from the first From: or Signed-Off-By: line, when fetching into git]'
	  )
	;|
	(clone|init)
	  opts+=(
	    '(-T --trunk)'{-T-,--trunk=}'[set trunk sub-directory]:trunk sub-directory:->subdirectory'
	    '(-t --tags)*'{-t-,--tags=}'[add tags sub-directory]:tags sub-directory:->subdirectory'
	    '(-b --branches)*'{-b-,--branches=}'[add branches sub-directory]:branches sub-directory:->subdirectory'
	    '(-s --stdlayout)'{-s,--stdlayout}'[shorthand for setting trunk, tags, branches as relative paths, the SVN default]'
	    '--no-metadata[get rid of git-svn-id: lines at the end of every commit]'
	    '--rewrite-root=[set svn-remote.*.rewriteRoot]:new root:_urls'
	    '--rewrite-uuid=[set svn-remote.*.rewriteUUID]:uuid'
	    '--prefix=[prefix to use for names of remotes]:path prefix:_directories -r ""'
	    '(               --no-minimize-url)--minimize-url[minimize URLs]'
	    "(--minimize-url                  )--no-minimize-url[don't minimize URLs]"
	    '--shared=[share repository amongst several users]:: :__git_repository_permissions'
	    '--template=[directory to use as a template for the object database]: :_directories'
	    '--use-svm-props[re-map repository URLs and UUIDs from mirrors created with SVN::Mirror]'
	    '--use-svnsync-props[re-map repository URLs and UUIDs from mirrors created with svnsync]'
	  )
	;|
	(commitdiff|dcommit|set-tree)
	  # TODO: -C and --copy-similarity are undocumented.
	  opts+=(
	    '(-C --copy-similarity)'{-C-,--copy-similarity=}': :_guard "[[\:digit:\]]#" number'
	    '(-e --edit)'{-e,--edit}'[edit commit message before committing]'
	    '-l-[limit number of rename/copy targets to run]: :__git_guard_number'
	    '--find-copies-harder[try harder to find copies]'
	    '--rmdir[remove empty directories from SVN tree after commit]'
	    ':: :__git_svn-remotes'
	  )
	;|
	(fetch|clone)
	  opts+=(
	    '(-r --revision)'{-r,--revision}'[only fetch given revision or revision range]: :__git_svn_revisions'
	    ':: :__git_svn-remotes'
	  )
        ;|
        (fetch|rebase|dcommit)
	  # TODO: --fetch-all and --all are undocumented.
	  opts+=( '(--fetch-all --all)'{--fetch-all,--all} )
        ;|
        (rebase|dcommit)
	  opts+=(
	    '(-M -m --merge)'{-M,-m,--merge}'[use merging strategies, if necessary]'
	    '*'{-s,--strategy=-}'[use given merge strategy]:merge strategy:__git_merge_strategies'
	  )
        ;|
        (rebase|dcommit|branch|tag)
	  opts+=(
	    '(-n --dry-run)'{-n,--dry-run}'[only display what would be done]'
	  )
        ;|
        (rebase|dcommit|log)
	  opts+=( '(-v --verbose)'{-v,--verbose}'[display extra information]' )
        ;|
        (branch|tag)
          # TODO: -d/--destination should complete output of
          # git config --get-all svn-remote.*.branches
          # git config --get-all svn-remote.*.tags
          # TODO: --username should probably use something from _svn.
          # TODO: --commit-url should complete output of
          # git config --get-all svn-remote.*.commiturl
          opts+=(
            '(-m --message)'{-m,--message}'[specify the commit message]:message'
            '(-d --destination)'{-d,--destination}"[location of $line[1] to create in SVN repository]: :_directories"
            '--username[specify SVN username to perform commit as]: :_users'
            '--commit-url[specify URL to connect to destination SVN repository]: :_urls'
	    '--parents[create parent folders]'
	  )
	;|
        (commit-diff|create-ignore|dcommit|show-ignore|mkdirs|proplist|propget|show-externals)
          # TODO: -r and --revision is undocumented for dcommit, show-ignore and mkdirs.
          opts+=(
            '(-r --revision)'{-r,--revision}'[specify SVN revision]: :__git_svn_revisions'
	  )
	;|
	(propset|propget)
	  opts+=( '1:property:(svn:ignore svn:keywords svn:executable svn:eol-style svn:mime-type svn:externals svn:needs-lock)' )
        ;|

	# ;| style fall-throughs end; here on each command covered once
        (blame)
          opts+=(
            '--git-format[produce output in git-blame format, with SVN revision numbers instead of git commit hashes]'
	    '*:file:__git_cached_files'
	  )
	;;
        (branch)
	  opts+=( '(-t --tag)'{-t,--tag}'[create a tag]' )
	;;
        (clone)
          opts+=(
	    '--preserve-empty-dirs[create a placeholder file for each empty directory]'
	    '--placeholder-filename=[specify name of placeholder files created by --preserve-empty-dirs]:filename [.gitignore]:_files'
            ':url:_urls'
            '::directory:_directories'
	  )
	;;
        (commit-diff)
          # TODO: -m and --message is undocumented.
          # TODO: -F and --file is undocumented.
          opts+=(
            '(-m --message)'{-m-,--message=}':message'
            '(-F --file)'{-F-,--file=}':file:_files'
	    ':original tree:__git_tree_ishs'
	    ':new tree result:__git_tree_ishs'
	    ':target:_urls'
	  )
	;;
        (dcommit)
	  # TODO: --set-svn-props is undocumented
          opts+=(
            '--commit-url[commit to a different SVN url]:SVN URL:_url'
	    '(-i --interactive)'{-i,--interactive}'[ask for confirmation that a patch should be sent to SVN]'
	    '--mergeinfo[add specified merge information during the dcommit]:mergeinfo' \
            "--no-rebase[don't rebase or reset after committing]"
	    '--set-svn-props:arg'
	  )
	;;
        (fetch)
          opts+=(
	    '(-p --parent)'{-p,--parent}'[fetch only from SVN parent of current HEAD]'
	  )
	;;
        (info)
          opts+=(
	    '--url[output only value of URL field]'
	    ':file:__git_cached_files'
	  )
	;;
        (init)
	  opts+=( ':SVN URL:_urls' ':target directory:_directories' )
        ;;
	(find-rev)
	  opts+=(
	    '(-A --after -B --before)'{-B,--before}'[with no exact match, find last commit for current branch]'
	    '(-A --after -B --before)'{-A,--after}'[with no exact match, find closest match searching forwards]'
	    ':revision: _alternative "svn-revisions\:svn revision number\:__git_svn_revision_numbers -p r" "git-revisions\:git revision\:__git_revisions"'
	  )
	;;
        (log)
          declare -a revision_options
          __git_setup_revision_options

          # TODO: --color is undocumented.
          # TODO: --pager is undocumented.
          # TODO: --non-recursive is undocumented.
          opts+=(
            $revision_options
            '(-r --revision)'{-r-,--revision=}'[revisions to output log information for]: :__git_svn_revision_numbers'
            '--limit=[like --max-count, but not counting merged/excluded commits]: :__git_guard_number limit'
            '--incremental[give output suitable for concatenation]'
            '--show-commit[output git commit SHA-1, as well]'
            '--color'
            '--pager:pager:_cmdstring'
            '--non-recursive'
	    ':file:__git_cached_files'
	  )
	;;
        (migrate)
          opts+=( '--minimize' )
        ;;
	(propset)
	  opts+=( ':value' )
	;&
	(proplist|propget)
          opts+=( '*:file:__git_cached_files' )
	;;
        (rebase)
          opts+=(
            '(-l --local)'{-l,--local}"[don't fetch remotely, rebase against the last fetched commit from SVN]"
            '!--preserve-merges'
            '(--rebase-merges -p)'{--rebase-merges,-p}'[try to recreate merges instead of ignoring them]'
	  )
	;;
        (reset)
          opts+=(
            '(-r --revision)'{-r,--revision}'[specify most recent SVN revision to keep]: :__git_svn_revisions'
            '(-p --parent)'{-p,--parent}'[discard specified revision as well, keeping nearest parent instead]'
	  )
	;;
        (set-tree)
          opts+=( '--stdin[read list of commits to commit from stdin]' )
	;;
	(create-ignore|gc|mkdirs|show-externals|show-ignore|tag) ;;
        (*) # fallback to files on any new/unrecognised commands
          opts+=( '*:file:_files' )
        ;;
      esac

      _arguments -C -S -s \
        '(-)'{-h,-H}'[display usage information]' \
        '(-)'{-V,--version}'[display version information]' \
        '--minimize-connections' \
        '(-R --svn-remote --remote)'{-R,--svn-remote,--remote}'[svn remote to use]:svn remote:__git_svn-remotes' \
        '(-i --id)'{-i,--id}'[set GIT_SVN_ID]:GIT_SVN_ID' \
        $opts && ret=0

      case $state in
        (subdirectory)
          _alternative \
            'sub-directories:sub-directory:_directories' \
            'urls: :_urls' && ret=0
          ;;
      esac
      ;;
  esac

  return ret
}

# LOW-LEVEL COMMANDS (PLUMBING)

# Manipulation commands

(( $+functions[_git-apply] )) ||
_git-apply () {
  local -a apply_options
  __git_setup_apply_options

  _arguments -S -s $endopt \
    $apply_options \
    '(--index --cached --reject)'{-3,--3way}'[fall back on 3-way merge if patch fails]' \
    '--stat[output diffstat for input (turns off "apply")]' \
    '--numstat[same as --stat but in decimal notation and complete pathnames (turns off "apply")]' \
    '--summary[output summary of git-diff extended headers (turns off "apply")]' \
    '--check[check if patches are applicable (turns off "apply")]' \
    '(        --cached)--index[make sure that patch is applicable to index]' \
    '(--index         )--cached[apply patches without touching working tree]' \
    '--build-fake-ancestor[build temporary index for blobs with ambiguous origin]:index:_files' \
    '(-R --reverse)'{-R,--reverse}'[apply patches in reverse]' \
    '-z[use NUL termination on output]' \
    '--unidiff-zero[disable unified-diff-context check]' \
    '--apply[apply patches that would otherwise not be applied]' \
    '--no-add[ignore additions made by the patch]' \
    '--allow-overlap[allow overlapping hunks]' \
    '--inaccurate-eof[work around missing-new-line-at-EOF bugs]' \
    '(-v --verbose)'{-v,--verbose}'[display progress on stderr]' \
    '--recount[do not trust line counts in hunk headers]' \
    '*:patch:_files'
}

(( $+functions[_git-checkout-index] )) ||
_git-checkout-index () {
  local z_opt=

  if (( words[(I)--stdin] )); then
    z_opt='-z[paths are separated with NUL character when reading from standard input]'
  fi

  _arguments -S -s $endopt \
    '(-u --index)'{-u,--index}'[update stat information in index]' \
    '(-q --quiet)'{-q,--quiet}'[no warning for existing files and files not in index]' \
    '(-f --force)'{-f,--force}'[force overwrite of existing files]' \
    '(-a --all --stdin *)'{-a,--all}'[check out all files in index]' \
    '(-n --no-create)'{-n,--no-create}'[do not checkout new files]' \
    '--temp[write content to temporary files]' \
    '(-a --all *)--stdin[read list of paths from the standard input]' \
    '--prefix=[prefix to use when creating files]:directory:_directories' \
    '--stage=[check out files from named stage]:stage:(1 2 3 all)' \
    $z_opt \
    '*: :__git_cached_files'
}

(( $+functions[_git-commit-graph] )) ||
_git-commit-graph() {
  local -a args progress
  progress=( "--no-progress[don't show progress]" )
  if [[ $words[2] = write ]]; then
    args=( $progress
      '(--split --size-multiple --max-commits --expire-time)--append[include all commits present in existing commit-graph file]'
      '--changed-paths[enable computation for changed paths]'
      '(--append)--split=-[write the commit-graph as a chain of multiple commit-graph files]::strategy:(no-merge replace)'
      '(--stdin-packs --stdin-commits)--reachable[walk commits starting at all refs]'
      '(--reachable --stdin-commits)--stdin-packs[only walk objects in pack-indexes read from input]'
      '(--reachable --stdin-packs)--stdin-commits[walk commits starting at commits read from input]'
      '(--append)--size-multiple=:commits [2]'
      '(--append)--max-commits=:commits'
      '(--append)--expire-time=:date/time:__git_datetimes'
      '--max-new-filters=[specify maximum number of changed-path bloom filters to compute]:'
    )
  elif [[ $words[2] = verify ]]; then
    args=( $progress
      '--shallow[only check the tip commit-graph file in a chain of split commit-graphs]'
    )
  fi

  _arguments -S $endopt $args \
    '--object-dir=[specify location of packfiles and commit-graph file]:directory:_directories' \
    '(-h)1:verb:(verify write)'
}

(( $+functions[_git-commit-tree] )) ||
_git-commit-tree () {
  _arguments -S $endopt \
    '-h[display usage]' \
    '*-p+[specify parent commit]:parent commit:__git_objects' \
    '(-S --gpg-sign --no-gpg-sign)'{-S-,--gpg-sign=-}'[GPG-sign the commit]::key id' \
    "(-S --gpg-sign --no-gpg-sign)--no-gpg-sign[don't GPG-sign the commit]" \
    '-F+[read commit log from specified file]:file:_files' \
    '*-m+[specify paragraph of commit log message]:message' \
    ': :__git_trees'
}

(( $+functions[_git-hash-object] )) ||
_git-hash-object () {
  _arguments -s -S $endopt \
    '-t[type of object to create]:object type:((blob\:"a blob of data"
                                                commit\:"a tree with parent commits"
                                                tag\:"a symbolic name for another object"
                                                tree\:"a recursive tree of blobs"))' \
    '-w[write object to object database]' \
    '(: --stdin-paths)--stdin[read object from standard input]' \
    '(: --stdin --path)--stdin-paths[read file names from standard input instead of from command line]' \
    '--literally[just hash any random garbage to create corrupt objects for debugging Git]' \
    '(       --no-filters)--path=[hash object as if it were located at given path]: :_files' \
    '(--path             )--no-filters[hash contents as is, ignoring any input filters]' \
    '(--stdin --stdin-paths):file:_files'
}

(( $+functions[_git-index-pack] )) ||
_git-index-pack () {
  local -a stdin_opts

  if (( words[(I)--stdin] )); then
    stdin_opts=(
      '--fix-thin[record deltified objects, based on objects not included]'
      '--keep=-[create .keep file]::reason')
  fi

  # NOTE: --index-version is only used by the Git test suite.
  # TODO: --pack_header is undocumented.
  _arguments \
    '-v[display progress on stderr]' \
    '-o[write generated pack index into specified file]: :_files' \
    '(--no-rev-index)--rev-index[generate a reverse index corresponding to the given pack]' \
    "(--rev-index)--no-rev-index[don't generate a reverse index corresponding to the given pack]" \
    '--stdin[read pack from stdin and instead write to specified file]' \
    $stdin_opts \
    '--strict[die if the pack contains broken objects or links]' \
    '--threads=[specify number of threads to use]:number of threads' \
    ':pack file:_files -g "*.pack(-.)"'
}

(( $+functions[_git-merge-file] )) ||
_git-merge-file () {
  integer n_labels=${#${(M)words[1,CURRENT-1]:#-L}}
  local label_opt=

  if (( n_labels < 3 )) || [[ $words[CURRENT-1] == -L ]]; then
    local -a ordinals

    ordinals=(first second third)

    label_opt="*-L[label to use for the $ordinals[n_labels+1] file]:label"
  fi

  _arguments \
    $label_opt \
    '(-p --stdout)'{-p,--stdout}'[send merged file to standard output instead of overwriting first file]' \
    '(-q --quiet)'{-q,--quiet}'[do not warn about conflicts]' \
    '(       --theirs --union)--ours[resolve conflicts favoring our side of the lines]' \
    '(--ours          --union)--theirs[resolve conflicts favoring their side of the lines]' \
    '(--ours --theirs        )--union[resolve conflicts favoring both sides of the lines]' \
    '--marker-size[specify length of conflict markers]: :__git_guard_number "marker length"' \
    '--diff3[use a diff3 based merge]' \
    ':current file:_files' \
    ':base file:_files' \
    ':other file:_files'
}

(( $+functions[_git-merge-index] )) ||
_git-merge-index () {
  if (( CURRENT > 2 )) && [[ $words[CURRENT-1] != -[oq] ]]; then
    _arguments -S \
      '(:)-a[run merge against all files in index that need merging]' \
      '*: :__git_cached_files'
  else
    declare -a arguments

    (( CURRENT == 2 )) && arguments+='-o[skip failed merges]'
    (( CURRENT == 2 || CURRENT == 3 )) && arguments+='(-o)-q[do not complain about failed merges]'
    (( 2 <= CURRENT && CURRENT <= 4 )) && arguments+='*:merge program:_files -g "*(*)"'

    _arguments -S $arguments
  fi
}

(( $+functions[_git-mktag] )) ||
_git-mktag () {
  _arguments --no-strict
}

(( $+functions[_git-mktree] )) ||
_git-mktree () {
  _arguments -S -s \
    '-z[read NUL-terminated ls-tree -z output]' \
    '--missing[allow missing objects]' \
    '--batch[allow creation of more than one tree]'
}

(( $+functions[_git-multi-pack-index] )) ||
_git-multi-pack-index() {
  _arguments \
    '--object-dir=[specify location of git objects]:directory:_directories' \
    '(--progress)--no-progress[turn progress off]' '!(--no-progress)--progress' \
    '--stdin-packs[write a multi-pack index containing only pack index basenames provided on stdin]' \
    '--refs-snapshot=[specify a file which contains a "refs snapshot" taken prior to repacking]:file:_files' \
    '--batch-size=[during repack, select packs so as to have pack files of at least the specified size]:size' \
    '1:verb:(write verify expire repack)'
}

(( $+functions[_git-pack-objects] )) ||
_git-pack-objects () {
  local thin_opt=

  if (( words[(I)--stdout] )); then
    thin_opt='--thin[create a thin pack]'
  fi

  # NOTE: --index-version is only used by the Git test suite.
  _arguments \
    '(-q --quiet)'{-q,--quiet}"[don't report progress]" \
    '(-q --quiet --all-progress)--progress[show progress meter]' \
    '(-q --quiet --progress --all-progress-implied)--all-progress[show progress meter during object writing phase]' \
    '(-q --quiet --all-progress)--all-progress-implied[like --all-progress, but only if --progress was also passed]' \
    '(--stdout)--max-pack-size=[specify maximum size of each output pack file]: : __git_guard_bytes "maximum pack size"' \
    '(--incremental)--local[similar to --incremental, but only ignore unpacked non-local objects]' \
    '(--local)--incremental[ignore objects that have already been packed]' \
    '--window=-[limit pack window by objects]: :__git_guard_number "window size"' \
    '--window-memory=-[specify window size in memory]: : __git_guard_bytes "window size"' \
    '--depth=-[maximum delta depth]: :__git_guard_number "maximum delta depth"' \
    "--no-reuse-delta[don't reuse existing deltas, but compute them from scratch]" \
    "--no-reuse-object[don't reuse existing object data]" \
    '--delta-base-offset[use delta-base-offset packing]' \
    '--threads=-[specify number of threads for searching for best delta matches]: :__git_guard_number "number of threads"' \
    '--non-empty[only create a package if it contains at least one object]' \
    '(--stdin-packs)--revs[read revision arguments from standard input]' \
    '(--revs)--unpacked[limit objects to pack to those not already packed]' \
    '(--revs --stdin-packs)--all[include all refs as well as revisions already specified]' \
    '--reflog[include objects referred by reflog entries]' \
    '--indexed-objects[include objects referred to by the index]' \
    '(--revs --all --keep-unreachable --pack-loose-unreachable --unpack-unreachable)--stdin-packs[read packs from stdin]' \
    '(: --max-pack-size)--stdout[output pack to stdout]' \
    '--include-tag[include unasked-for annotated tags if object they reference is included]' \
    '(--revs --stdin-packs --unpack-unreachable)--keep-unreachable[add objects unreachable from refs in packs named with --unpacked to resulting pack]' \
    '(--revs --stdin-packs)--pack-loose-unreachable[pack unreachable loose objects]' \
    '(--revs --stdin-packs --keep-unreachable)--unpack-unreachable=-[keep unreachable objects in loose form]::time' \
    '--sparse[use sparse reachability algorithm]' \
    '--include-tag[include tag objects that refer to objects to be packed]' \
    $thin_opt \
    '--shallow[create packs suitable for shallow fetches]' \
    '--honor-pack-keep[ignore objects in local pack with .keep file]' \
    '--keep-pack=[ignore named pack]:pack' \
    '--compression=-[specify compression level]: :__git_compression_levels' \
    '--keep-true-parents[pack parents hidden by grafts]' \
    '--use-bitmap-index[use a bitmap index if available to speed up counting objects]' \
    '--write-bitmap-index[write a bitmap index together with the pack index]' \
    '--filter=[omit certain objects from pack file]:filter:_git_rev-list_filters' \
    '--missing=[specify how missing objects are handled]:action:(error allow-any allow-promisor print)' \
    "--exclude-promisor-objects[don't pack objects in promisor packfiles]" \
    '--delta-islands[respect islands during delta compression]' \
    '--uri-protocol=[exclude any configured uploadpack.blobpackfileuri with given protocol]:protocol' \
    ':base-name:_files'
}

(( $+functions[_git-prune-packed] )) ||
_git-prune-packed () {
  _arguments -S -s \
    '(-n --dry-run)'{-n,--dry-run}'[only list objects that would be removed]' \
    '(-q --quiet)'{-q,--quiet}'[do not display progress on standard error]'
}

(( $+functions[_git-read-tree] )) ||
_git-read-tree () {
  local trivial_opt= aggressive_opt= dryrun_opt=

  if (( words[(I)-m] )); then
    dryrun_opt='--dry-run[report if a merge would fail without touching the index or the working tree]'
    trivial_opt='--trivial[restrict three-way merge to only happen if no file-level merging is required]'
    aggressive_opt='--aggressive[try harder to resolve merge conflicts]'
  fi

  local -a ui_opts

  if (( words[(I)(-m|--reset|--prefix)] )); then
    ui_opts=(
      '(   -i)-u[update the work tree after successful merge]'
      '(-u   )-i[update only the index; ignore changes in work tree]')
  fi

  local exclude_per_directory_opt

  if (( words[(I)-u] )); then
    exclude_per_directory_opt='--exclude-per-directory=-[specify .gitignore file]:.gitignore file:_files'
  fi

  _arguments -S -s \
    '(   --reset --prefix)-m[perform a merge, not just a read]' \
    '(-m         --prefix)--reset[perform a merge, not just a read, ignoring unmerged entries]' \
    '(-m --reset          2 3)--prefix=-[read the contents of specified tree-ish under specified directory]:prefix:_directories -r ""' \
    $ui_opts \
    $dryrun_opt \
    '-v[display progress on standard error]' \
    $trivial_opt \
    $aggressive_opt \
    $exclude_per_directory_opt \
    '--index-output=[write index in the named file instead of $GIT_INDEX_FILE]: :_files' \
    '--no-sparse-checkout[display sparse checkout support]' \
    '--debug-unpack[debug unpack-trees]' \
    '--recurse-submodules=-[control recursive updating of submodules]::checkout:__git_commits' \
    '(-q --quiet)'{-q,--quiet}'[suppress feedback messages]' \
    '--empty[instead of reading tree object(s) into the index, just empty it]' \
    '1:first tree-ish to be read/merged:__git_tree_ishs' \
    '2::second tree-ish to be read/merged:__git_tree_ishs' \
    '3::third tree-ish to be read/merged:__git_tree_ishs'
}

(( $+functions[_git-symbolic-ref] )) ||
_git-symbolic-ref () {
  _arguments -S -s \
    '(-d --delete)'{-d,--delete}'[delete symbolic ref]' \
    '(-q --quiet)'{-q,--quiet}'[do not issue error if specified name is not a symbolic ref]' \
    '--short[shorten the ref name (eg. refs/heads/master -> master)]' \
    '-m[update reflog for specified name with specified reason]:reason for update' \
    ':symbolic reference:__git_heads' \
    ':: :__git_references'
}

(( $+functions[_git-unpack-objects] )) ||
_git-unpack-objects () {
  _arguments \
    '-n[only list the objects that would be unpacked]' \
    '-q[run quietly]' \
    '-r[try recovering objects from corrupt packs]' \
    '--strict[do not write objects with broken content or links]'
}

(( $+functions[_git-update-index] )) ||
_git-update-index () {
  local z_opt

  if (( words[(I)--stdin|--index-info] )); then
    z_opt='-z[paths are separated with NUL character when reading from stdin]'
  fi

  _arguments -S \
    '(-)'{-h,--help}'[display usage information]' \
    '-q[continue refresh even when index needs update]' \
    '--add[add files not already in index]' \
    '(--force-remove)--remove[remove files that are in the index but are missing from the work tree]' \
    '(-q --unmerged --ignore-missing --really-refresh)--refresh[refresh index]' \
    '--ignore-submodules[do not try to update submodules]' \
    '--unmerged[if unmerged changes exists, ignore them instead of exiting]' \
    '--ignore-missing[ignore missing files when refreshing the index]' \
    '*--cacheinfo[insert information directly into the cache]: :_guard "[0-7]#" "octal file mode": :_guard "[[\:xdigit\:]]#" "object id": :_files' \
    '(: -)--index-info[read index information from stdin]' \
    '--chmod=-[set execute permissions on updated files]:permission:((+x\:executable -x\:"not executable"))' \
    '(                   --no-assume-unchanged)--assume-unchanged[set "assume unchanged" bit for given paths]' \
    '(--assume-unchanged                      )--no-assume-unchanged[unset "assume unchanged" bit for given paths]' \
    '(-q --unmerged --ignore-missing --refresh)--really-refresh[refresh index, unconditionally checking stat information]' \
    '(                --no-skip-worktree)--skip-worktree[set "skip-worktree" bit for given paths]' \
    '(--skip-worktree                   )--no-skip-worktree[unset "skip-worktree" bit for given paths]' \
    "--ignore-skip-worktree-entries[don't touch index-only entries]" \
    '(-)'{-g,--again}'[run git-update-index on differing index entries]' \
    '(-)--unresolve[restore "unmerged" or "needs updating" state of files]' \
    '--info-only[only insert files object-IDs into index]' \
    '--replace[replace files already in index, if necessary]' \
    '(--remove)--force-remove[remove named paths even if present in worktree]' \
    '(: -)--stdin[read list of paths from standard input]' \
    '--verbose[report what is being added and removed from the index]' \
    '--clear-resolve-undo[forget saved unresolved conflicts]' \
    '--index-version=[write index in specified on-disk format version]:version:(2 3 4)' \
    '--split-index[enable/disable split index]' \
    '--untracked-cache[enable/disable untracked cache]' \
    '--test-untracked-cache[test if the filesystem supports untracked cache]' \
    '--force-untracked-cache[enable untracked cache without testing the filesystem]' \
    '--force-write-index[write out the index even if is not flagged as changed]' \
    '--fsmonitor[enable or disable file system monitor]' \
    '--fsmonitor-valid[mark files as fsmonitor valid]' \
    '--no-fsmonitor-valid[clear fsmonitor valid bit]' \
    $z_opt \
    '*:: :_files'
}

(( $+functions[_git-update-ref] )) ||
_git-update-ref () {
  local z_opt

  if (( words[(I)--stdin] )); then
    z_opt='-z[values are separated with NUL character when reading from stdin]'
  fi

  _arguments -S -s \
    '-m[update reflog for specified name with specified reason]:reason for update' \
    '(:)-d[delete given reference after verifying its value]:symbolic reference:__git_revisions:old reference:__git_revisions' \
    '(-d --no-deref)--stdin[reads instructions from standard input]' \
    $z_opt \
    '(-d -z --stdin)--no-deref[overwrite ref itself, not what it points to]' \
    '--create-reflog[create a reflog]' \
    ':symbolic reference:__git_revisions' \
    ':new reference:__git_revisions' \
    '::old reference:__git_revisions'
}

(( $+functions[_git-write-tree] )) ||
_git-write-tree () {
  # NOTE: --ignore-cache-tree is only used for debugging.
  _arguments -S -s \
    '--missing-ok[ignore objects in index that are missing in object database]' \
    '--prefix=[write tree representing given sub-directory]:sub-directory:_directories -r ""'
}

# Interrogation commands

(( $+functions[_git-cat-file] )) ||
_git-cat-file () {
  _arguments -S -s \
    '(-t -s -e -p --allow-unknown-type 1)--textconv[show content as transformed by a textconv filter]' \
    '(-t -s -e -p --allow-unknown-type 1)--filters[show content as transformed by filters]' \
    '(-t -s -e -p --allow-unknown-type 1)--path=[use a specific path for --textconv/--filters]:path:_directories' \
    - query \
    '(-s -e -p --textconv --filters 1)-t[show type of given object]' \
    '(-t -e -p --textconv --filters 1)-s[show size of given object]' \
    '(-e -p --textconv --filters 1)--allow-unknown-type[allow query of broken/corrupt objects of unknown type]' \
    '(-t -s -p -textconv --filters --allow-unknown-type 1)-e[exit with zero status if object exists]' \
    '(-t -s -e -textconv --filters --allow-unknown-type 1)-p[pretty-print given object]' \
    '(-):object type:(blob commit tag tree)' \
    ': :__git_objects' \
    - batch \
    '(--batch-check)--batch=-[print SHA1, type, size and contents (or in specified format)]::format' \
    '(--batch)--batch-check=-[print SHA1, type and size (or in specified format)]::format' \
    '--follow-symlinks[follow in-tree symlinks (used with --batch or --batch-check)]' \
    '--batch-all-objects[show all objects with --batch or --batch-check]' \
    "--unordered[don't order --batch-all-objects output]" \
    '--buffer[disable flushing of output after each object]'
}

(( $+functions[_git-diff-files] )) ||
_git-diff-files () {
  local -a revision_options diff_stage_options
  __git_setup_revision_options
  __git_setup_diff_stage_options

  _arguments -S -s \
    $revision_options \
    $diff_stage_options \
    ': :__git_changed-in-working-tree_files' \
    ': :__git_changed-in-working-tree_files' \
    '*: :__git_changed-in-working-tree_files'
}

(( $+functions[_git-diff-index] )) ||
_git-diff-index () {
  local -a revision_options
  __git_setup_revision_options

  # TODO: Description of -m doesn't match that for git-rev-list.  What's going
  # on here?
  # TODO: With --cached, shouldn't we only list files changed in index compared
  # to given tree-ish?  This should be done for git-diff as well, in that case.
  _arguments -S \
    $revision_options \
    "--cached[don't consider the work tree at all]" \
    '-m[flag non-checked-out files as up-to-date]' \
    ': :__git_tree_ishs' \
    '*: :__git_cached_files'
}

(( $+functions[_git-diff-tree] )) ||
_git-diff-tree () {
  local curcontext=$curcontext state line ret=1
  declare -A opt_args

  declare -a revision_options
  __git_setup_revision_options

  # NOTE: -r, -t, --root are actually parsed for all
  # __git_setup_revision_options, but only used by this command, so only have
  # them here.
  _arguments -C -S -s \
    $revision_options \
    '-r[recurse into subdirectories]' \
    '(-r   )-t[display tree objects in diff output]' \
    '--root[display root diff]' \
    '-m[do not ignore merges]' \
    '-s[do not show differences]' \
    '(--pretty --header)-v[display commit message before differences]' \
    '--no-commit-id[do not display commit IDs]' \
    '(-c --cc)-c[show differences from each of parents to merge result]' \
    '(-c --cc)--cc[how differences from each of parents and omit differences from only one parent]' \
    '--combined-all-paths[show name of file in all parents for combined diffs]' \
    '--always[always show commit itself and commit log message]' \
    ': :__git_tree_ishs' \
    '*:: :->files' && ret=0

  case $state in
    (files)
      if (( $#line > 2 )); then
        # TODO: It would be better to output something like
        #
        # common files:
        #   ...
        # original tree:
        #   ...
        # new tree:
        #   ...
        _alternative \
          "original-tree-files:original tree:__git_tree_files ${PREFIX:-.} $line[1]" \
          "new-tree-files:new tree:__git_tree_files ${PREFIX:-.} $line[2]" && ret=0
      else
        _alternative \
          'tree-ishs::__git_tree_ishs' \
          "tree-files::__git_tree_files ${PREFIX:-.} $line[1]" && ret=0
      fi
      ;;
  esac

  return ret
}

(( $+functions[_git-for-each-ref] )) ||
_git-for-each-ref () {
  # TODO: Better completion for --format: should complete %(field) stuff, that
  # is, %(refname), %(objecttype), %(objectsize), %(objectname) with optional '*'
  # in front.
  _arguments -S -s \
    '--count=[maximum number of refs to iterate over]: :__git_guard_number "maximum number of refs"' \
    '*--sort=[key to sort refs by]: :__git_ref_sort_keys' \
    '--format=-[output format of ref information]:format:__git_format_ref' \
    '--color=-[respect any colors specified in the format]::when:(always never auto)' \
    '*--points-at=[print only refs which point at the given object]:object:__git_commits' \
    '*--merged=[print only refs that are merged]:object:__git_commits' \
    '*--no-merged=[print only refs that are not merged]:object:__git_commits' \
    '*--contains=[print only refs that contain specified commit]:object:__git_commits' \
    "*--no-contains=[print only refs that don't contain specified commit]:object:__git_commits" \
    '--ignore-case[sorting and filtering are case-insensitive]' \
    '(-s --shell -p --perl --python --tcl)'{-s,--shell}'[use string literals suitable for sh]' \
    '(-s --shell -p --perl --python --tcl)'{-p,--perl}'[use string literals suitable for Perl]' \
    '(-s --shell -p --perl          --tcl)'--python'[use string literals suitable for Python]' \
    '(-s --shell -p --perl --python      )'--tcl'[use string literals suitable for Tcl]' \
    ':: :_guard "([^-]?#|)" pattern'
}

(( $+functions[_git-for-each-repo] )) ||
_git-for-each-repo() {
  _arguments -S \
    '(-C --config)'{-C,--config=}'[specify config variable for list of paths]:config variable' \
    ':git command:_git_commands' \
    '*:: := _git'
}

(( $+functions[_git-ls-files] )) ||
_git-ls-files () {
  local no_empty_directory_opt=

  if (( words[(I)--directory] )); then
    no_empty_directory_opt="--no-empty-directory[don't list empty directories]"
  fi

  # TODO: Replace _files with something more intelligent based on seen options.
  # TODO: Apply excludes like we do for git-clean.
  _arguments -S -s $endopt \
    '(-c --cached)'{-c,--cached}'[show cached files in output]' \
    '(-d --deleted)'{-d,--deleted}'[show deleted files in output]' \
    '(-m --modified)'{-m,--modified}'[show modified files in output]' \
    '(-o --others)'{-o,--others}'[show other files in output]' \
    '(-i --ignored)'{-i,--ignored}'[show ignored files in output]' \
    '(-s --stage --with-tree)'{-s,--stage}'[show stage files in output]' \
    '--directory[if a whole directory is classified as "other", show just its name]' \
    '--eol[show line endings of files]' \
    $no_empty_directory_opt \
    '(-s --stage -u --unmerged --with-tree)'{-u,--unmerged}'[show unmerged files in output]' \
    '--resolve-undo[show resolve-undo information]' \
    '(-k --killed)'{-k,--killed}'[show killed files in output]' \
    '-z[separate paths with the NUL character]' \
    '*'{-x,--exclude=-}'[skip files matching given pattern]:file pattern' \
    '*'{-X,--exclude-from=-}'[skip files matching patterns in given file]: :_files' \
    '*--exclude-per-directory=-[skip directories matching patterns in given file]: :_files' \
    '--exclude-standard[skip files in standard Git exclusion lists]' \
    '--error-unmatch[if any file does not appear in index, treat this as an error]' \
    '(-s --stage -u --unmerged)--with-tree=[treat paths removed since given tree-ish as still present]: :__git_tree_ishs' \
    '(-f)-v[indicate status of each file using lowercase for assume changed files]' \
    '(-v)-f[indicate status of each file using lowercase for fsmonitor clean files]' \
    '--full-name[force paths to be output relative to the project top directory]' \
    '--recurse-submodules[recurse through submodules]' \
    '--abbrev=[use specified digits to display object names]:digits' \
    '--debug[show debugging data]' \
    '--deduplicate[suppress duplicate entries]' \
    '*:: :_files'
}

(( $+functions[_git-ls-remote] )) ||
_git-ls-remote () {
  # TODO: repository needs fixing
  _arguments -S -s $endopt \
    '(-q --quiet)'{-q,--quiet}"[don't print remote URL]" \
    '--upload-pack=[specify path to git-upload-pack on remote side]:remote path' \
    '(-h --heads)'{-h,--heads}'[show only refs under refs/heads]' \
    '(-t --tags)'{-t,--tags}'[show only refs under refs/tags]' \
    "--refs[don't show peeled tags]" \
    '--exit-code[exit with status 2 when no matching refs are found in the remote repository]' \
    '--get-url[expand the URL of the given repository taking into account any "url.<base>.insteadOf" config setting]' \
    '*--sort=[specify field name to sort on]:field:__git_ref_sort_keys' \
    '--symref[show underlying ref in addition to the object pointed by it]' \
    \*{-o+,--server-option=}'[send specified string to the server when using protocol version 2]:option' \
    ': :__git_any_repositories' \
    '*: :__git_references'
}

(( $+functions[_git-ls-tree] )) ||
_git-ls-tree () {
  local curcontext=$curcontext state line ret=1
  declare -A opt_args

  _arguments -C -S -s $endopt \
    '(-t)-d[do not show children of given tree (implies -t)]' \
    '-r[recurse into subdirectories]' \
    '-t[show tree entries even when going to recurse them]' \
    '(-l --long --name-only --name-status)'{-l,--long}'[show object size of blob entries]' \
    '-z[use NUL termination on output]' \
    '(--name-only --name-status --abbrev)'{--name-only,--name-status}'[list only filenames, one per line]' \
    '(--name-only --name-status)--abbrev=[use specified digits to display object names]:digits' \
    '--full-name[output full path-names]' \
    '(--full-name)--full-tree[do not limit listing to current working-directory]' \
    ': :__git_tree_ishs' \
    '*:: :->file' && ret=0

  case $state in
    (file)
      __git_ignore_line __git_tree_files ${PREFIX:-.} $line[1] && ret=0
      ;;
  esac

  return ret
}

(( $+functions[_git-merge-base] )) ||
_git-merge-base () {
  _arguments -S -s $endopt \
    '(-a --all)'{-a,--all}'[display all common ancestors]' \
    '--octopus[compute best common ancestors of all supplied commits]' \
    '--is-ancestor[tell if A is ancestor of B (by exit status)]' \
    '(-)--independent[display minimal subset of supplied commits with same ancestors]' \
    '--fork-point[find the point at which B forked from ref A (uses reflog)]' \
    ': :__git_commits' \
    '*: :__git_commits'
}

(( $+functions[_git-name-rev] )) ||
_git-name-rev () {
  _arguments -S $endopt \
    '--tags[only use tags to name commits]' \
    '*--refs=[only use refs matching given pattern]: :_guard "?#" "shell pattern"' \
    '--no-refs[clear any previous ref patterns given]' \
    '*--exclude=[ignore refs matching specified pattern]:pattern' \
    '(--stdin :)--all[list all commits reachable from all refs]' \
    '(--all :)--stdin[read from stdin and append revision-name]' \
    '--name-only[display only name of commits]' \
    '--no-undefined[die with non-zero return when a reference is undefined]' \
    '--always[show uniquely abbreviated commit object as fallback]' \
    '(--stdin --all)*: :__git_commits'
}

(( $+functions[_git-pack-redundant] )) ||
_git-pack-redundant () {
  _arguments -S -A '-*' \
    '(:)--all[process all packs]' \
    '--alt-odb[do not require objects to be present in local packs]' \
    '--verbose[output some statistics to standard error]' \
    '(--all)*::pack:_files -g "*.pack(-.)"'
}

(( $+functions[_git-rev-list] )) ||
_git-rev-list () {
  local curcontext=$curcontext state line ret=1
  declare -A opt_args

  declare -a revision_options
  __git_setup_revision_options

  _arguments -C -S $endopt \
    $revision_options \
    '--no-filter[turn off any previous --filter argument]' \
    '--filter-print-omitted[print a list of objects omitted by --filter]' \
    '--filter=[omit certain objects from pack file]:filter:_git_rev-list_filters' \
    '--missing=[specify how missing objects are handled]:action:(error allow-any allow-promisor print)' \
    '(--count --pretty --header --left-right --abbrev-commit --abbrev --parent --children)--quiet[print nothing; exit status indicates if objects are fully connected]' \
    '--use-bitmap-index[try to speed traversal using pack bitmap index if available]' \
    '--progress=-[show progress reports as objects are considered]:header' \
    '(--pretty --quiet)--header[display contents of commit in raw-format]' \
    "--no-object-names[don't print the names of the object IDs that are found]" \
    '!(--no-object-names)--object-names)' \
    '--timestamp[print raw commit timestamp]' \
    '(         --bisect-vars --bisect-all)--bisect[show only middlemost commit object]' \
    '(--bisect)--bisect-vars[same as --bisect, displaying shell-evalable code]' \
    '(--bisect)--bisect-all[display all commit objects between included and excluded commits]' \
    '*:: :->commit-or-path' && ret=0

  case $state in
    (commit-or-path)
      # TODO: What paths should we be completing here?
      if [[ -n ${opt_args[(I)--]} ]]; then
        __git_cached_files && ret=0
      else
        _alternative \
          'commit-ranges::__git_commit_ranges' \
          'cached-files::__git_cached_files' && ret=0
      fi
      ;;
  esac

  return ret
}

(( $+functions[_git_rev-list_filters] )) ||
_git_rev-list_filters() {
  _values 'filter' \
    'blob\:none[omit all blobs]' \
    'blob\:limit[omit blobs larger than specified size]:size' \
    'sparse\:oid[uses a sparse-checkout specification contained in the blob]:blob-ish' \
    'tree\:0[omit blobs and trees with depth exceeding limit]'
}

(( $+functions[_git-show-index] )) ||
_git-show-index() {
  _arguments \
    '--object-format=[specify the hash algorithm to use]:algortithm:(sha1 sha256)'
}

(( $+functions[_git-show-ref] )) ||
_git-show-ref () {
  _arguments -S $endopt \
    - list \
      '--head[show the HEAD reference, even if it would normally be filtered out]' \
      '--tags[show only refs/tags]' \
      '--heads[show only refs/heads]' \
      '(-d --dereference)'{-d,--dereference}'[dereference tags into object IDs as well]' \
      '(-s --hash)'{-s+,--hash=-}'[only show the SHA-1 hash, not the reference name]:: :__git_guard_number length' \
      '--verify[enable stricter reference checking]' \
      '--abbrev=[use specified digits to display object names]:digits' \
      '(-q --quiet)'{-q,--quiet}'[do not print any results]' \
      '*: :_guard "([^-]?#|)" pattern' \
    - exclude \
      '--exclude-existing=-[filter out existing refs from stdin]:: :_guard "([^-]?#|)" pattern'
}

(( $+functions[_git-unpack-file] )) ||
_git-unpack-file () {
  _arguments \
    '(:)-h[display usage information]' \
    '(-): :__git_blobs'
}

(( $+functions[_git-var] )) ||
_git-var () {
  _arguments \
    '(:)-l[show logical variables]' \
    '(-):variable:((GIT_AUTHOR_IDENT\:"name and email of author" \
                    GIT_COMMITTER_IDENT\:"name and email of committer" \
                    GIT_EDITOR\:"text editor used by git commands" \
                    GIT_PAGER\:"text viewer used by git commands"))'
}

(( $+functions[_git-verify-pack] )) ||
_git-verify-pack () {
  _arguments -S -s $endopt \
    '(-v --verbose)'{-v,--verbose}'[show objects contained in pack]' \
    '(-s --stat-only)'{-s,--stat-only}'[do not verify pack contents; only display histogram of delta chain length]' \
    '--object-format=[specify the hash algorithm to use]:algortithm:(sha1 sha256)' \
    '*:index file:_files -g "*.idx(-.)"'
}

# Syncing Repositories

(( $+functions[_git-daemon] )) ||
_git-daemon () {
  # TODO: do better than _directories?  The directory needs to be a git-repository,
  # so one could check for a required file in the given directory.
  # TODO: --interpolated-path should complete %H, %CH, %IP, %P, and %D.
  _arguments -S \
    '--strict-paths[match paths exactly]' \
    '--access-hook=-[allow an external tool to accept or decline service]:path:_directories' \
    '--base-path=-[remap all the path requests as relative to the given path]:path:_directories' \
    '--base-path-relaxed[allow lookup of base path without prefix]' \
    '--interpolated-path=-[dynamically construct alternate paths]:path:_directories' \
    '--export-all[allow pulling from all repositories without verification]' \
    '(--port --listen --user --group)--inetd[run server as an inetd service]' \
    '(--inetd)--listen=-[listen on a specific IP address or hostname]: :_hosts' \
    '(--inetd)--port=-[specify port to listen to]: :_ports' \
    '--init-timeout=-[specify timeout between connection and request]: :__git_guard_number timeout' \
    '--timeout=-[specify timeout for sub-requests]: :__git_guard_number timeout' \
    '--max-connections=-[specify maximum number of concurrent clients]: :__git_guard_number "connection limit"' \
    '--syslog[log to syslog instead of standard error]' \
    '--user-path=-[allow ~user notation to be used in requests]::path:_directories' \
    '--verbose[log details about incoming connections and requested files]' \
    '--reuseaddr[reuse addresses when already bound]' \
    '(--syslog)--detach[detach from the shell]' \
    '--pid-file=-[save the process id in given file]:pid file:_files' \
    '--user=-[set uid of daemon]: :_users' \
    '--group=-[set gid of daemon]: :_groups' \
    '--enable=-[enable site-wide service]: :__git_daemon_service' \
    '--disable=-[disable site-wide service]: :__git_daemon_service' \
    '--allow-override[allow overriding site-wide service]: :__git_daemon_service' \
    '--forbid-override[forbid overriding site-wide service]: :__git_daemon_service' \
    '(--no-informative-errors)--informative-errors[report more verbose errors to the client]' \
    '(--informative-errors)--no-informative-errors[report all errors as "access denied" to the client]' \
    '--log-destination=[send log messages to the specified destination]:destination:(stderr syslog none)' \
    '*:repository:_directories'
}

(( $+functions[_git-fetch-pack] )) ||
_git-fetch-pack () {
  # TODO: Limit * to __git_head_references?
  _arguments -A '-*' \
    '--all[fetch all remote refs]' \
    '--stdin[take the list of refs from stdin]' \
    '(-q --quiet)'{-q,--quiet}'[make output less verbose]' \
    '(-k --keep)'{-k,--keep}'[do not invoke git-unpack-objects on received data]' \
    '--thin[fetch a thin pack]' \
    '--include-tag[download referenced annotated tags]' \
    '(--upload-pack --exec)'{--upload-pack=-,--exec=-}'[specify path to git-upload-pack on remote side]:remote path' \
    '--depth=-[limit fetching to ancestor-chains not longer than given number]: :__git_guard_number "maximum ancestor-chain length"' \
    '--no-progress[do not display progress]' \
    '--diag-url' \
    '-v[produce verbose output]' \
    ': :__git_any_repositories' \
    '*: :__git_references'
}

(( $+functions[_git-http-backend] )) ||
_git-http-backend () {
  _nothing
}

(( $+functions[_git-send-pack] )) ||
_git-send-pack () {
  local -a sign
  sign=(
    {yes,true}'\:always,\ and\ fail\ if\ unsupported\ by\ server'
    {no,false}'\:never'
    if-asked'\:iff\ supported\ by\ server'
  )
  _arguments -S -A '-*' $endopt \
    '(-v --verbose)'{-v,--verbose}'[produce verbose output]' \
    '(-q --quiet)'{-q,--quiet}'[be more quiet]' \
    '(--receive-pack --exec)'{--receive-pack=-,--exec=-}'[specify path to git-receive-pack on remote side]:remote path' \
    '--remote[specify remote name]:remote' \
    '(*)--all[update all refs that exist locally]' \
    '(-n --dry-run)'{-n,--dry-run}'[do everything except actually sending the updates]' \
    '--mirror[mirror all refs]' \
    '(-f --force)'{-f,--force}'[update remote orphaned refs]' \
    "(--no-signed --signed)--sign=-[GPG sign the push]::signing enabled:(($^^sign))" \
    '(--no-signed --sign)--signed[GPG sign the push]' \
    "(--sign --signed)--no-signed[don't GPG sign the push]" \
    '*--push-option=[specify option to transmit]:option' \
    '--progress[force progress reporting]' \
    '--thin[send a thin pack]' \
    '--atomic[request atomic transaction on remote side]' \
    '--stateless-rpc[use stateless RPC protocol]' \
    '--stdin[read refs from stdin]' \
    '--helper-status[print status from remote helper]' \
    '--force-with-lease=[require old value of ref to be at specified value]:refname\:expect' \
    '--force-if-includes[require remote updates to be integrated locally]' \
    ': :__git_any_repositories' \
    '*: :__git_remote_references'
}

(( $+functions[_git-update-server-info] )) ||
_git-update-server-info () {
  _arguments -S -s $endopt \
    '(-f --force)'{-f,--force}'[update the info files from scratch]'
}

(( $+functions[_git-http-fetch] )) ||
_git-http-fetch () {
  _arguments -s \
    '-c[fetch commit objects]' \
    '-t[fetch trees associated with commit objects]' \
    '-a[fetch all objects]' \
    '-v[report what is downloaded]' \
    '-w[write commit-id into the filename under "$GIT_DIR/refs/<filename>"]:filename' \
    '--recover[recover from a failed fetch]' \
    '(1 --packfile)--stdin[read commit ids and refs from standard input]' \
    '!(1 --stdin)--packfile=:hash' \
    '!--index-pack-args=:args' \
    '1: :__git_commits' \
    ': :_urls'
}

(( $+functions[_git-http-push] )) ||
_git-http-push () {
  _arguments \
    '--all[verify that all objects in local ref history exist remotely]' \
    '--force[allow refs that are not ancestors to be updated]' \
    '--dry-run[do everything except actually sending the updates]' \
    '--verbose[report the list of objects being walked locally and sent to remote]' \
    '(   -D)-d[remove refs from remote repository]' \
    '(-d   )-D[forcefully remove refs from remote repository]' \
    ': :_urls' \
    '*: :__git_remote_references'
}

# NOTE: git-parse-remote isn't a user command.

(( $+functions[_git-receive-pack] )) ||
_git-receive-pack () {
  _arguments -S -A '-*' $endopt \
    '(-q --quiet)'{-q,--quiet}'[be quiet]' \
    '--stateless-rpc[quit after a single request/response exchange]' \
    ':directory to sync into:_directories'
}

(( $+functions[_git-shell] )) ||
_git-shell () {
  local curcontext=$curcontext state line ret=1
  declare -A opt_args

  _arguments -C \
    '-c[command to execute]: :->command' \
    ': :->argument' && ret=0

  case $state in
    (command)
      declare -a commands

      commands=(
        git-receive-pack
        git-upload-pack
        git-upload-archive
        cvs)

      _describe -t commands command commands && ret=0
      ;;
    (argument)
      case $line[1] in
        (git-receive-pack)
          local expl

          _description directories expl 'directory to sync into'
          _directories $expl && ret=0
          ;;
        (git-upload-pack|git-upload-archive)
          local expl

          _description directories expl 'directory to sync from'
          _directories $expl && ret=0
          ;;
        (cvs)
          compadd - server && ret=0
      esac
      ;;
  esac

  return ret
}


(( $+functions[_git-upload-archive] )) ||
_git-upload-archive () {
  _arguments \
    ':directory to get tar archive from:_directories'
}

(( $+functions[_git-upload-pack] )) ||
_git-upload-pack () {
  _arguments -S -A '-*' $endopt \
    '--stateless-rpc[quit after a single request/response exchange]' \
    '--advertise-refs[exit immediately after initial ref advertisement]' \
    "--strict[don't try <directory>/.git/ if <directory> is not a git directory]" \
    '--timeout=-[interrupt transfer after period of inactivity]: :__git_guard_number "inactivity timeout (seconds)"' \
    ': :_directories'
}

# Internal Helper Commands

(( $+functions[_git-check-attr] )) ||
_git-check-attr () {
  local z_opt=

  local curcontext=$curcontext state line ret=1
  declare -A opt_args

  if (( words[(I)--stdin] )); then
    z_opt='-z[paths are separated with NUL character when reading from stdin]'
  fi

  _arguments -C \
    {-a,--all}'[list all attributes that are associated with the specified paths]' \
    '--stdin[read file names from stdin instead of from command line]' \
    '--cached[consider .gitattributes in the index only, ignoring the working tree.]' \
    '-z[terminate input and output records by a NUL character]' \
    $z_opt \
    '(-)--[interpret preceding arguments as attributes and following arguments as path names]' \
    '*:: :->attribute-or-file' && ret=0

  case $state in
    (attribute-or-file)
      local -a attributes

      attributes=(crlf ident filter diff merge)

      local only_attributes=1
      for (( i = 2; i < $#words; i++ )); do
        if (( attributes[(I)$words[i]] == 0 )); then
          only_attributes=0
          break
        fi
      done

      if (( !only_attributes )) || [[ -n ${opt_args[(I)--]} ]]; then
        __git_cached_files && ret=0
      else
        _alternative \
          'attributes::__git_attributes' \
          'files::__git_cached_files' && ret=0
      fi
      ;;
  esac

  return ret
}

(( $+functions[_git-check-ref-format] )) ||
_git-check-ref-format () {
  _arguments \
    '-h[display usage information]' \
    '(--no-allow-onelevel)--allow-onelevel[accept one-level refnames]' \
    '(--allow-onelevel)--no-allow-onelevel[do not accept one-level refnames]' \
    '--refspec-pattern[interpret <refname> as a reference name pattern for a refspec]' \
    '--normalize[normalize refname by removing leading slashes]' \
    '--branch[expand previous branch syntax]' \
    ': :__git_references'
}

(( $+functions[_git-fmt-merge-msg] )) ||
_git-fmt-merge-msg () {
  _arguments -S -s $endopt \
    '(      --no-log)--log=-[display one-line descriptions from actual commits being merged]::number of commits [20]' \
    '(--log         )--no-log[do not display one-line descriptions from actual commits being merged]' \
    '(-m --message)'{-m+,--message=}'[use given message instead of branch names for first line in log message]:message' \
    '(-F --file)'{-F,--file}'[specify list of merged objects from file]: :_files'
}

(( $+functions[_git-mailinfo] )) ||
_git-mailinfo () {
  # TODO: --no-inbody-headers is undocumented.
  _arguments -A '-*' \
    '(-b)-k[prevent removal of cruft from Subject: header]' \
    '(-k)-b[limit stripping of bracketed strings to the word PATCH]' \
    '(-u --encoding)-u[encode commit information in UTF-8]' \
    '(-u --encoding)--encoding=-[encode commit information in given encoding]: :__git_encodings' \
    '-n[disable all charset re-coding of metadata]' \
    '(-m --message-id)'{-m,--message-id}'[copy the Message-ID header at the end of the commit message]' \
    '-n[disable charset re-coding of metadata]' \
    '(           --no-scissors)--scissors[remove everything in body before a scissors line]' \
    '(--scissors              )--no-scissors[do not remove everything in body before a scissors line]' \
    '--quoted-cr=[specify action when quoted CR is found]:action [warn]:(nowarn warn strip)' \
    '--no-inbody-headers[undocumented]' \
    ':message file:_files' \
    ':patch file:_files'
}

(( $+functions[_git-mailsplit] )) ||
_git-mailsplit () {
  _arguments -S -A '-*' \
    '-o-[directory in which to place individual messages]:directory:_directories' \
    '-b[if file does not begin with "From " line, assume it is a single mail message]' \
    '-d-[specify number of leading zeros]: :__git_guard_number precision' \
    '-f-[skip the first N numbers]: :__git_guard_number' \
    '--keep-cr[do not remove CR from lines ending with CR+LF]' \
    '*::mbox file:_files'
}

(( $+functions[_git-merge-one-file] )) ||
_git-merge-one-file () {
  _message 'you probably should not be issuing this command'
}

(( $+functions[_git-patch-id] )) ||
_git-patch-id () {
   _arguments \
     '--stable[use a sum of hashes unaffected by diff ordering]' \
     '--unstable[use patch-id compatible with git 1.9 and older]'
}

# NOTE: git-sh-setup isn't a user command.

(( $+functions[_git-stripspace] )) ||
_git-stripspace () {
  _arguments \
    '(-s --strip-comments -c --comment-lines)'{-s,--strip-comments}'[also strip lines starting with #]' \
    '(-c --comment-lines -s --strip-comments)'{-c,--comment-lines}'[prepend comment character and blank to each line]'
}

# INTERNAL GIT COMPLETION FUNCTIONS

# Generic Helpers

(( $+functions[__git_command_successful] )) ||
__git_command_successful () {
  if (( ${#*:#0} > 0 )); then
    _message 'not a git repository'
    return 1
  fi
  return 0
}

(( $+functions[__git_committish_range_first] )) ||
__git_committish_range_first () {
  print -r -- ${${${1%..*}%.}:-HEAD}
}

(( $+functions[__git_committish_range_last] )) ||
__git_committish_range_last () {
  print -r -- ${${${1#*..}#.}:-HEAD}
}

(( $+functions[__git_pattern_escape] )) ||
__git_pattern_escape () {
  print -r -n - ${(b)1}
}

(( $+functions[__git_is_type] )) ||
__git_is_type () {
  git rev-parse -q --verify "$2^{$1}" 2>/dev/null >/dev/null
}

(( $+functions[__git_is_blob] )) ||
__git_is_blob () {
  __git_is_type blob $1
}
(( $+functions[__git_is_committish] )) ||
__git_is_committish () {
  __git_is_type commit $1
}

(( $+functions[__git_is_treeish] )) ||
__git_is_treeish () {
  __git_is_type tree $1
}

(( $+functions[__git_is_committish_range] )) ||
__git_is_committish_range () {
  [[ $1 == *..(.|)* ]] || return 1
  local first="$(__git_committish_range_first $1)"
  local last="$(__git_committish_range_last $1)"
  [[ $first != *..* && $last != *..* ]] && \
    __git_is_committish $first && \
    __git_is_committish $last
}

(( $+functions[__git_is_initial_commit] )) ||
__git_is_initial_commit () {
  git rev-parse -q --verify HEAD >/dev/null 2>/dev/null
  (( $? == 1 ))
}

(( $+functions[__git_is_in_middle_of_merge] )) ||
__git_is_in_middle_of_merge () {
  local gitdir

  gitdir=$(_call_program gitdir git rev-parse --git-dir 2>/dev/null)
  __git_command_successful $pipestatus || return

  [[ -f $gitdir/MERGE_HEAD ]]
}

(( $+functions[__git_describe_branch] )) ||
__git_describe_branch () {
  local __commits_in=$1
  local __tag=$2
  local __desc=$3
  shift 3

  integer maxverbose
  if zstyle -s :completion:$curcontext: max-verbose maxverbose &&
    (( ${compstate[nmatches]} <= maxverbose )); then
    local __c
    local -a __commits
    for __c in ${(P)__commits_in}; do
      __commits+=("${__c}:${$(_call_program describe git rev-list -1 --oneline $__c)//:/\\:}")
    done
    _describe -t $__tag $__desc __commits "$@"
  else
    local expl
    _wanted $__tag expl $__desc compadd "$@" -a - $__commits_in
  fi
}

(( $+functions[__git_describe_commit] )) ||
__git_describe_commit () {
  __git_describe_branch $1 $2 $3 -M 'r:|/=* r:|=*' "${(@)argv[4,-1]}"
}

# Completion Wrappers

# '__git_ignore_line $callee "${callee_args[@]}" "${callee_compadd_args[@]}"'
# invokes '$callee "${callee_args[@]}" "${callee_compadd_args[@]}"' with
# callee_compadd_args modified to exclude positional parameters to the completed
# command from being completed.  This causes 'git add foo <TAB>' not to offer
# 'foo' again.
#
# Note: This function can't be used to wrap bare 'compadd' calls that use a '--'
# argument terminator.  It can wrap functions of the form
#     f() { shift $N; compadd "$@" -a - mymatches }
# .
(( $+functions[__git_ignore_line] )) ||
__git_ignore_line () {
  local -a ignored=(${line:#${words[CURRENT]}})
  $* -F ignored
}

(( $+functions[__git_ignore_line_inside_arguments] )) ||
__git_ignore_line_inside_arguments () {
  declare -a compadd_opts

  zparseopts -D -E -a compadd_opts V+: J+: 1 2 o+: n f x+: X+: M+: P: S: r: R: q F:

  __git_ignore_line $* $compadd_opts
}

# Common Argument Types

(( $+functions[_git_commands] )) ||
_git_commands () {
  local -a cmdtypes
  cmdtypes=( main_porcelain_commands user_commands
    third_party_commands ancillary_manipulator_commands
    ancillary_interrogator_commands interaction_commands
    plumbing_manipulator_commands plumbing_interrogator_commands
    plumbing_sync_commands plumbing_sync_helper_commands
    plumbing_internal_helper_commands
  )
  local -a $cmdtypes

  main_porcelain_commands=(
    add:'add file contents to index'
    am:'apply patches from a mailbox'
    archive:'create archive of files from named tree'
    bisect:'find, by binary search, change that introduced a bug'
    branch:'list, create, or delete branches'
    bundle:'move objects and refs by archive'
    checkout:'checkout branch or paths to working tree'
    cherry-pick:'apply changes introduced by some existing commits'
    citool:'graphical alternative to git commit'
    clean:'remove untracked files from working tree'
    clone:'clone repository into new directory'
    commit:'record changes to repository'
    describe:'show most recent tag that is reachable from a commit'
    diff:'show changes between commits, commit and working tree, etc.'
    fetch:'download objects and refs from another repository'
    format-patch:'prepare patches for e-mail submission'
    gc:'cleanup unnecessary files and optimize local repository'
    grep:'print lines matching a pattern'
    gui:'run portable graphical interface to git'
    init:'create empty git repository or re-initialize an existing one'
    log:'show commit logs'
    maintenance:'run tasks to optimize Git repository data'
    merge:'join two or more development histories together'
    mv:'move or rename file, directory, or symlink'
    notes:'add or inspect object notes'
    pull:'fetch from and merge with another repository or local branch'
    push:'update remote refs along with associated objects'
    range-diff:'compare two commit ranges'
    rebase:'forward-port local commits to the updated upstream head'
    reset:'reset current HEAD to specified state'
    restore:'restore working tree files'
    revert:'revert existing commits'
    rm:'remove files from the working tree and from the index'
    shortlog:'summarize git log output'
    show:'show various types of objects'
    sparse-checkout:'initialize and modify the sparse-checkout'
    stash:'stash away changes to dirty working directory'
    status:'show working-tree status'
    submodule:'initialize, update, or inspect submodules'
    subtree:'split repository into subtrees and merge them'
    switch:'switch branches'
    tag:'create, list, delete or verify tag object signed with GPG'
    worktree:'manage multiple working dirs attached to the same repository'
  )
  ancillary_manipulator_commands=(
    config:'get and set repository or global options'
    fast-export:'data exporter'
    fast-import:'import information into git directly'
    filter-branch:'rewrite branches'
    mergetool:'run merge conflict resolution tools to resolve merge conflicts'
    pack-refs:'pack heads and tags for efficient repository access'
    prune:'prune all unreachable objects from the object database'
    reflog:'manage reflog information'
    remote:'manage set of tracked repositories'
    repack:'pack unpacked objects in a repository'
    replace:'create, list, delete refs to replace objects')

  ancillary_interrogator_commands=(
    blame:'show what revision and author last modified each line of a file'
    bugreport:'collect information for user to file a bug report'
    count-objects:'count unpacked objects and display their disk consumption'
    difftool:'show changes using common diff tools'
    fsck:'verify connectivity and validity of objects in database'
    help:'display help information about git'
    instaweb:'instantly browse your working repository in gitweb'
    interpret-trailers:'add or parse structured information in commit messages'
    merge-tree:'show three-way merge without touching index'
    rerere:'reuse recorded resolution of conflicted merges'
    show-branch:'show branches and their commits'
    verify-commit:'check GPG signature of commits'
    verify-tag:'check GPG signature of tags'
    whatchanged:'show commit-logs and differences they introduce'
    version:'show git version')

  interaction_commands=(
    archimport:'import an Arch repository into git'
    cvsexportcommit:'export a single commit to a CVS checkout'
    cvsimport:'import a CVS "repository" into a git repository'
    cvsserver:'run a CVS server emulator for git'
    imap-send:'send a collection of patches to an IMAP folder'
    quiltimport:'apply a quilt patchset'
    request-pull:'generate summary of pending changes'
    send-email:'send collection of patches as emails'
    svn:'bidirectional operation between a Subversion repository and git')

  plumbing_manipulator_commands=(
    apply:'apply patch to files and/or to index'
    checkout-index:'copy files from index to working directory'
    commit-graph:'write and verify Git commit-graph files'
    commit-tree:'create new commit object'
    hash-object:'compute object ID and optionally create a blob from a file'
    index-pack:'build pack index file for an existing packed archive'
    merge-file:'run a three-way file merge'
    merge-index:'run merge for files needing merging'
    mktag:'create tag object with extra validation'
    mktree:'build tree-object from git ls-tree formatted text'
    multi-pack-index:'write and verify multi-pack-indexes'
    pack-objects:'create packed archive of objects'
    prune-packed:'remove extra objects that are already in pack files'
    read-tree:'read tree information into directory index'
    symbolic-ref:'read and modify symbolic references'
    unpack-objects:'unpack objects from packed archive'
    update-index:'register file contents in the working directory to the index'
    update-ref:'update object name stored in a reference safely'
    write-tree:'create tree from the current index')

  plumbing_interrogator_commands=(
    cat-file:'provide content or type information for repository objects'
    cherry:'find commits not merged upstream'
    diff-files:'compare files in working tree and index'
    diff-index:'compare content and mode of blobs between index and repository'
    diff-tree:'compare content and mode of blobs found via two tree objects'
    for-each-ref:'output information on each ref'
    for-each-repo:'run a git command on a list of repositories'
    get-tar-commit-id:'extract commit ID from an archive created using git archive'
    ls-files:'information about files in index/working directory'
    ls-remote:'show references in a remote repository'
    ls-tree:'list contents of a tree object'
    merge-base:'find as good a common ancestor as possible for a merge'
    name-rev:'find symbolic names for given revisions'
    pack-redundant:'find redundant pack files'
    rev-list:'list commit object in reverse chronological order'
    rev-parse:'pick out and massage parameters for other git commands'
    show-index:'show packed archive index'
    show-ref:'list references in a local repository'
    unpack-file:'create temporary file with blob'\''s contents'
    var:'show git logical variable'
    verify-pack:'validate packed git archive files')

  plumbing_sync_commands=(
    daemon:'run a really simple server for git repositories'
    fetch-pack:'receive missing objects from another repository'
    http-backend:'run a server side implementation of Git over HTTP'
    send-pack:'push objects over git protocol to another repository'
    update-server-info:'update auxiliary information file to help dumb servers')

  plumbing_sync_helper_commands=(
    http-fetch:'download from remote git repository via HTTP'
    http-push:'push objects over HTTP/DAV to another repository'
    parse-remote:'routines to help parsing remote repository access parameters'
    receive-pack:'receive what is pushed into repository'
    shell:'restricted login shell for GIT-only SSH access'
    upload-archive:'send archive back to git-archive'
    upload-pack:'send objects packed back to git fetch-pack')

  plumbing_internal_helper_commands=(
    check-attr:'display gitattributes information'
    check-ignore:'debug gitignore/exclude files'
    check-mailmap:'show canonical names and email addresses of contacts'
    check-ref-format:'ensure that a reference name is well formed'
    column:'display data in columns'
    fmt-merge-msg:'produce merge commit message'
    mailinfo:'extract patch and authorship from a single email message'
    mailsplit:'split mbox file into a list of files'
    merge-one-file:'standard helper-program to use with git merge-index'
    patch-id:'compute unique ID for a patch'
    stripspace:'filter out empty lines')

  zstyle -a :completion:$curcontext: user-commands user_commands

  local command
  for command in ${(k)_git_third_party_commands}; do
    (( $+commands[git-${command}] )) && third_party_commands+=$command$_git_third_party_commands[$command]
  done

  local -a aliases
  __git_extract_aliases
  local cmdtype len dup sep
  local -a allcmds allmatching alts disp expl

  zstyle -s ":completion:${curcontext}:" list-separator sep || sep=--
  for cmdtype in $cmdtypes aliases; do
    if [[ $cmdtype = aliases ]]; then
      for dup in ${${aliases%:*}:*allcmds}; do
	aliases=( ${aliases:#$dup:*} )
      done
    fi
    local -a ${cmdtype}_m
    set -A ${cmdtype}_m ${(P)cmdtype%%:*}
    allcmds+=( ${(P)${:-${cmdtype}_m}} )
  done
  zstyle -T ":completion:${curcontext}:" verbose && disp=(-ld '${cmdtype}_d')
  _description '' expl '' # get applicable matchers
  compadd "$expl[@]" -O allmatching -a allcmds
  len=${#${(O)allmatching//?/.}[1]} # length of longest match
  for cmdtype in aliases $cmdtypes; do
    local -a ${cmdtype}_d
    (( $#disp )) && set -A ${cmdtype}_d \
        ${${(r.COLUMNS-4.)${(P)cmdtype}/(#s)(#m)[^:]##:/${(r.len.)MATCH[1,-2]} $sep }%% #}
    alts+=( "${cmdtype//_/-}:${${cmdtype//_/ }%%(e|)s}:compadd ${(e)disp} -a ${cmdtype}_m" )
  done

  _alternative $alts
}

(( $+functions[__git_aliases] )) ||
__git_aliases () {
  local -a aliases
  __git_extract_aliases

  _describe -t aliases alias aliases $*
}

(( $+functions[__git_extract_aliases] )) ||
__git_extract_aliases () {
  local -a tmp
  tmp=(${${(0)"$(_call_program aliases "git config -z --get-regexp '^alias.'")"}#alias.})
  if (( ${#tmp} > 0 )); then
      aliases=(${^tmp/$'\n'/:alias for \'}\')
  else
      aliases=()
  fi
}

(( $+functions[_git_column_layouts] )) ||
_git_column_layouts() {
  _values -s , 'column layout [always,column,nodense]' \
    '(never auto)always[always show in columns]' \
    '(always auto)never[never show in columns]' \
    '(always never)auto[show in columns if the output is to the terminal]' \
    '(row plain)column[fill columns before rows]' \
    '(column plain)row[fill rows before columns]' \
    '(column row)plain[show in one column]' \
    '(nodense)dense[make unequal size columns to utilize more space]' \
    '(dense)nodense[make equal size columns]'
}

(( $+functions[__git_date_formats] )) ||
__git_date_formats () {
  declare -a date_formats

  if compset -P 'format(-local|):'; then
    _strftime
    return
  fi

  date_formats=(
    relative:'show dates relative to the current time'
    local:'show timestamps in the local timezone'
    iso{,8601}:'show timestamps in ISO 8601 format'
    iso{,8601}-local:'show timestamps in ISO 8601 format in the local timezone'
    iso-strict:'show timestamps in strict ISO 8601 format'
    iso-strict-local:'show timestamps in strict ISO 8601 format in the local timezone'
    rfc{,2822}:'show timestamps in RFC 2822 format'
    rfc{,2822}-local:'show timestamps in RFC 2822 format in the local timezone'
    short:'show only date but not time'
    short-local:'show only date but not time in the local timezone'
    raw:'show date in internal raw git format (%s %z)'
    raw-local:'show date in internal raw git format (%s %z) in the local timezone'
    human:'elide some current and recent date elements'
    human-local:'elide some current and recent date elements in the local timezone'
    unix:'show date as a Unix epoch timestamp'
    default:'show timestamp in rfc-like format'
    default-local:'show timestamp in rfc-like format in the local timezone'
  )

  _describe -t date-formats 'date format' date_formats -- '( format\:custom\ format )' -S :
}

(( $+functions[_git_diff_filters] )) ||
_git_diff_filters() {
  local sep
  local -a dispinc dispexc exclude
  typeset -A filters
  exclude=( ${(s..)PREFIX:u} ${(s..)SUFFIX:u} ${(s..)PREFIX:l} ${(s..)SUFFIX:l} )
  compset -P \*
  compset -S \*
  filters=( A added C copied D deleted M modified R renamed T changed  b "pairing broken" )
  if zstyle -T ":completion:${curcontext}:" verbose; then
    zstyle -s ":completion:${curcontext}:" list-separator sep || sep=--
    print -v dispinc -f "%s $sep %s" ${(kv)filters}
    print -v dispexc -f "%s $sep %s" ${(kv)filters:l}
  else
    dispinc=()
  fi
  _alternative \
    "included-file-types:included file type:compadd -S '' -d dispinc -F exclude -k filters" \
    "excluded-file-types:excluded file type:compadd -S '' -d dispexc -F exclude ${(k)filters:l}"
}

(( $+functions[_git_dirstat_params] )) ||
_git_dirstat_params() {

  _alternative \
    "limits: :_guard '(*,|)[0-9]#' 'minimum cut-off limit (percent)'" \
    "parameters: :_values -s , 'method for computing stats [changes]'
      '(lines files)changes[count added/removed lines, ignoring moves]'
      '(changes files)lines[count added/removed lines]'
      '(changes lines)files[count number of files changed]'
      'cumulative[count changes in a child directory for the parent directory as well]'"
}

(( $+functions[_git_cleanup_modes] )) ||
_git_cleanup_modes() {
  declare -a cleanup_modes
  cleanup_modes=(
     strip:'remove both whitespace and commentary lines'
     whitespace:'remove leading and trailing whitespace lines'
     verbatim:"don't change the commit message at all"
     scissors:"same as whitespace but cut from scissor line"
     default:'act as '\''strip'\'' if the message is to be edited and as '\''whitespace'\'' otherwise'
  )
  _describe -t modes mode cleanup_modes
}

(( $+functions[__git_gpg_secret_keys] )) ||
__git_gpg_secret_keys () {
  local expl

  _wanted secret-keys expl 'secret key' compadd \
    ${${(Mo)$(_call_program secret-keys gpg --list-secret-keys 2>/dev/null):%<*>}//(<|>)/}
}

(( $+functions[__git_merge_strategies] )) ||
__git_merge_strategies () {
  local expl

  _wanted merge-strategies expl 'merge strategy' compadd "$@" - \
      ${=${${${(M)${(f)"$(_call_program merge-strategies \
      "git merge -s '' 2>&1")"}:#[Aa]vailable (custom )#strategies are: *}#[Aa]vailable (custom )#strategies are: }%.}:-octopus ours recursive resolve subtree}
}

(( $+functions[_git_strategy_options] )) ||
_git_strategy_options() {
  _values "strategy option" ours theirs ignore-space-change \
    ignore-all-space ignore-space-at-eol ignore-cr-at-eol \
    renormalize no-renormalize \
    'find-renames::similarity threshold' \
    subtree:path \
    'diff-algorithm:algorithm:(patience minimal histogram myers)'
}

(( $+functions[__git_encodings] )) ||
__git_encodings () {
  # TODO: Use better algorithm, as shown in iconv completer (separate it to a
  # new Type).
  local expl
  _wanted encodings expl 'encoding' compadd "$@" \
    -M 'm:{a-zA-Z}={A-Za-z} r:|-=* r:|=*' \
    ${${${(f)"$(_call_program encodings iconv --list)"}## #}%//}
}

(( $+functions[__git_apply_whitespace_strategies] )) ||
__git_apply_whitespace_strategies () {
  declare -a strategies

  strategies=(
    'nowarn:turn off the trailing-whitespace warning'
    'warn:output trailing-whitespace warning, but apply patch'
    'fix:output trailing-whitespace warning and strip trailing whitespace'
    'error:output trailing-whitespace warning and refuse to apply patch'
    'error-all:same as "error", but output warnings for all files')

  _describe -t strategies 'trailing-whitespace resolution strategy' strategies $*
}

(( $+functions[__git_remotes] )) ||
__git_remotes () {
  local remotes expl

  remotes=(${(f)"$(_call_program remotes git remote 2>/dev/null)"})
  __git_command_successful $pipestatus || return 1

  _wanted remotes expl remote compadd "$@" -a - remotes
}

(( $+functions[__git_ref_specs_pushy] )) ||
__git_ref_specs_pushy () {
  # TODO: This needs to deal with a lot more types of things.
  if compset -P '*:'; then
    # TODO: have the caller supply the correct remote name, restrict to refs/remotes/${that_remote}/* only
    __git_remote_branch_names_noprefix
  else
    compset -P '+'
    if compset -S ':*'; then
      __git_heads
    else
      _alternative \
       'commit-tags::__git_commit_tags' \
       'heads::__git_heads -qS :'
    fi
  fi
}

(( $+functions[__git_ref_specs_fetchy] )) ||
__git_ref_specs_fetchy () {
  # TODO: This needs to deal with a lot more types of things.
  if compset -P '*:'; then
    __git_heads_local
  else
    compset -P '+'
    if compset -S ':*'; then
      # TODO: have the caller supply the correct remote name, restrict to refs/remotes/${that_remote}/* only
      __git_remote_branch_names_noprefix
    else
      # TODO: have the caller supply the correct remote name, restrict to refs/remotes/${that_remote}/* only
      __git_remote_branch_names_noprefix -qS :
    fi
  fi
}

(( $+functions[__git_ref_specs] )) ||
__git_ref_specs () {
  # Backwards compatibility: define this function to support user dotfiles that
  # define custom _git-${subcommand} completions in terms of this function.
  # ### We may want to warn here "use _pushy() or _fetchy()".
  __git_ref_specs_pushy "$@"
}

(( $+functions[__git_color_whens] )) ||
__git_color_whens () {
  local -a whens

  whens=(
    'always:always use colors'
    'never:never use colors'
    'auto:use colors if output is to a terminal')

  _describe -t whens when whens $*
}

(( $+functions[__git_ignore_submodules_whens] )) ||
__git_ignore_submodules_whens () {
  local -a whens

  whens=(
    none:'submodule is dirty when it contains untracked or modified files'
    untracked:'submodule is dirty when it contains untracked files'
    dirty:'ignore all changes to submodules, showing only changes to commits stored in superproject'
    all:'ignore all changes to submodules (default)')

  _describe -t whens when whens $*
}

# (Currently) Command-specific Argument Types
(( $+functions[__git_archive_formats] )) ||
__git_archive_formats () {
  local expl

  _wanted archive-formats expl 'archive format' \
    compadd $* - ${${(f)"$(_call_program archive-formats git archive --list)"}}
}

(( $+functions[__git_compression_levels] )) ||
__git_compression_levels () {
  __git_config_values -t compression-levels -l 'compression level' -- "$current" "$parts[5]" \
    '-1:default level of compression' \
    '0:do not deflate files' \
    '1:minimum compression' \
    '2:a little more compression' \
    '3:slightly more compression' \
    '4:a bit more compression' \
    '5:even more compression' \
    '6:slightly even more compression' \
    '7:getting there' \
    '8:close to maximum compression' \
    '9:maximum compression'
}

(( $+functions[__git_attributes] )) ||
__git_attributes () {
  local -a attributes

  attributes=(
    'crlf:line-ending convention'
    'ident:ident substitution'
    'filter:filters'
    'diff:textual diff'
    'merge:merging strategy')

  _describe -t attributes attribute attributes $*
}

(( $+functions[__git_daemon_service] )) ||
__git_daemon_service () {
  local -a services

  services=(
    'upload-pack:serve git fetch-pack and git ls-remote clients'
    'upload-archive:serve git archive --remote clients')

  _describe -t services service services $*
}

(( $+functions[_git_log_line_ranges] )) ||
_git_log_line_ranges() {
  local sep pos=start op=( / : )
  if compset -P '*[^,^]:'; then
    __git_tree_files ${PREFIX:-.} HEAD
  else
    compset -P 1 '*,' && pos=end
    if compset -P '(^|):'; then
      _message -e functions function
    elif compset -P '(^|)/'; then
      _message -e patterns regex
    else
      zstyle -s ":completion:${curcontext}:forms" list-separator sep || sep=--
      sep=' -- '
      sep="${(q)sep}"
      _guard "[0-9]#" "$pos line number" && return
      compset -P \^ || op+=( \^ )
      _wanted forms expl form compadd -S '' -d "(
        /\ $sep\ regex
        :\ $sep\ function
        ^\ $sep\ search\ from\ start\ of\ file )" $op
    fi
  fi
}

(( $+functions[__git_log_decorate_formats] )) ||
__git_log_decorate_formats () {
  declare -a log_decorate_formats

  log_decorate_formats=(
    short:'do not show ref name prefixes'
    full:'show ref name prefixes'
    no:'do not show ref names')

  _describe -t log-decorate-formats 'log decorate format' log_decorate_formats $*
}

(( $+functions[__git_repository_permissions] )) ||
__git_repository_permissions () {
  if [[ -prefix [0-7] ]]; then
    _message -e number 'numeric mode'
  else
    declare -a permissions

    permissions=(
      {umask,false,no,off}':use permissions reported by umask()'
      {group,true,yes,on}':files and objects are group-writable'
      {all,world,everybody}':files and objects are readable by all users and group-shareable')

    _describe -t permissions permission permissions $*
  fi
}

(( $+functions[__git_reflog_entries] )) ||
__git_reflog_entries () {
  local expl
  declare -a reflog_entries

  # Repeat the %gD on the RHS due to uniquify the matches, to avoid bad
  # completion list layout.  (Compare workers/34768)
  reflog_entries=(${(f)"$(_call_program reflog-entries "git reflog -1000 --pretty='%gD:[%h] %gs (%gD)'" 2>/dev/null)"})
  reflog_entries=( ${reflog_entries/HEAD@$'\x7b'/@$'\x7b'} )
  __git_command_successful $pipestatus || return 1

  _describe -Vx -t reflog-entries 'reflog entry' reflog_entries
}

(( $+functions[__git_ref_sort_keys] )) ||
__git_ref_sort_keys () {
  compset -P '-'

  __git_ref_fields "$@"
}

(( $+functions[__git_ref_fields] )) ||
__git_ref_fields () {
  # pass -a to complete all fields, otherwise only fields relevant to sorting
  local match mbegin mend
  local -a cfields fields append opts all

  zparseopts -D -E -a opts M+: x+: X+: J+: V+: o+: 1 2 a=all

  if compset -P 1 '(#b)(*):'; then
    case $match[1] in
      push|upstream)
	append=(
	  'trackshort[show terse version: > (ahead) < (behind) = (in sync)]'
	  'track[print gone whenever unknown upstream ref is encountered]'
	  'track,nobracket[tracking information without brackets]'
        )
      ;&
      refname|upstream|symref)
	append+=(
	  {strip,lstrip}'[strip elements from the left]:elements to strip / -remain'
	  'rstrip[strip elements from the right]:elements to strip / -remain'
	  'short[strip to non-ambiguous short name]'
	)
      ;;
      objectname)
        append=(
	  'short[strip to non-ambiguous short name]:length'
	)
      ;;
      color)
	_alternative \
	  'colors::__git_colors' \
	  'attributes::__git_color_attributes'
	return
      ;;
      align)
	append=(
	  'width[specify width]:width'
	  'position[specify alignment]:alignment:(left right middle)'
	)
      ;;
      if) append=( {,not}'equals:string' ) ;;
      contents) append=( subject body signature lines:lines ) ;;
      tailers) append=( only unfold ) ;;
      v|version)
	append=(
	  'refname[sort by versions]'
	)
      ;;
    esac
    (( $#append )) || return 1
    _values 'interpolation modifier' $append
    return
  fi

  cfields=(
    'refname:name of the ref'
    'objectname:object name (SHA-1)'
    'upstream:name of a local ref which can be considered “upstream” from the displayed ref'
    'push:name of a local ref which represents the @{push} location for the displayed ref'
    'symref:the ref which the given symbolic ref refers to'
    'contents:complete message'
    'trailers:structured information in commit messages'
  )
  fields=(
    'objecttype:the type of the object'
    'objectsize:the size of the object'
    'deltabase:object name of the delta base of the object'
    'HEAD:* if HEAD matches ref or space otherwise'
    'tree:the tree header-field'
    'parent:the parent header-field'
    'numparent:number of parent objects'
    'object:the object header-field'
    'type:the type header-field'
    'tag:the tag header-field'
    'author:the author header-field'
    'authorname:the name component of the author header-field'
    'authoremail:the email component of the author header-field'
    'authordate:the date component of the author header-field'
    'committer:the committer header-field'
    'committername:the name component of the committer header-field'
    'committeremail:the email component of the committer header-field'
    'committerdate:the date component of the committer header-field'
    'tagger:the tagger header-field'
    'taggername:the name component of the tagger header-field'
    'taggeremail:the email component of the tagger header-field'
    'taggerdate:the date component of the tagger header-field'
    'creator:the creator header-field'
    'creatordate:the date component of the creator header-field'
    'subject:the subject of the message'
    'body:the body of the message'
    'version\:refname:sort by versions'
  )
  if (( $#all )); then
    cfields+=(
      'color:change output color'
      'align:set alignment'
      'if:conditional'
    )
    fields+=(
      'then:true branch'
      'else:false branch'
      'end:end if or align block'
    )
  fi

  _describe -t fields 'field' cfields -S : -r ':\\) \t\n\-' -- fields "$@"
}

(( $+functions[__git_format_ref] )) ||
__git_format_ref() {
  local expl
  compset -P '(%\\\([^)]#\\\)|[^%]|%%|%[[:xdigit:]][[:xdigit:]])#'
  if compset -P '%\\\((\*|)'; then
    __git_ref_fields -S '\)' -a
  else
    _wanted -x formats expl format compadd -S '' '%('
  fi
}

(( $+functions[__git_signoff_file] )) ||
__git_signoff_file () {
  _alternative \
    'signoffs:signoff:(yes true me please)' \
    'files:signoff file:_files'
}

(( $+functions[__git_stashes] )) ||
__git_stashes () {
  local expl
  declare -a interleaved
  declare -a stashes
  declare -a descriptions

  interleaved=(${(ps:\0:)"$(_call_program stashes git stash list -z --pretty='format:%gd%x00%s%x00\(%cr\)' 2>/dev/null)"})
  __git_command_successful $pipestatus || return 1
  () {
    local i j k
    for i j k in $interleaved; do
      stashes+=($i)
      descriptions+=("$i: $j $k")
    done
  }

  _wanted stashes expl 'stash' compadd -Vx -d descriptions -a - stashes
}

(( $+functions[__git_svn_revisions] )) ||
__git_svn_revisions () {
  if [[ -prefix *: ]]; then
    compset -P '*:'

    _alternative \
      'revision-numbers::__git_svn_revision_numbers' \
      'symbolic-revisions:symbolic revision:((HEAD:"the topmost revision of the SVN repository"))'
  else
    _alternative \
      'revision-numbers::__git_svn_revision_numbers' \
      'symbolic-revisions:symbolic revision:__git_svn_base_revisions'
  fi
}

(( $+functions[__git_svn_base_revisions] )) ||
__git_svn_base_revisions () {
  declare -a symbolic_revisions

  symbolic_revisions=(
    'BASE:the bottommost revision of the SVN repository')

  # TODO: How do we deal with $*?
  _describe -t symbolic-revisions 'symbolic revision' symbolic_revisions -S ':' -r ': '
}

# Object Type Argument Types

(( $+functions[__git_branch_names] )) ||
__git_branch_names () {
  local expl
  declare -a branch_names

  branch_names=(${${(f)"$(_call_program branchrefs git for-each-ref --format='"%(refname)"' refs/heads 2>/dev/null)"}#refs/heads/})
  __git_command_successful $pipestatus || return 1

  __git_describe_commit branch_names branch-names 'branch name' "$@"
}

(( $+functions[__git_remote_branch_names] )) ||
__git_remote_branch_names () {
  declare -a branch_names

  branch_names=(${${(f)"$(_call_program remote-branch-refs git for-each-ref --format='"%(refname)"' refs/remotes 2>/dev/null)"}#refs/remotes/})
  __git_command_successful $pipestatus || return 1

  __git_describe_commit branch_names remote-branch-names 'remote branch name' "$@"
}

(( $+functions[__git_remote_branch_names_noprefix] )) ||
__git_remote_branch_names_noprefix () {
  declare -a heads

  branch_names=(${${${${(f)"$(_call_program remote-branch-refs-noprefix git for-each-ref --format='"%(refname)"' refs/remotes 2>/dev/null)"}#refs/remotes/}#*/}:#HEAD})
  __git_command_successful $pipestatus || return 1

  __git_describe_commit branch_names remote-branch-names-noprefix 'remote branch name' "$@"
}

(( $+functions[__git_commit_objects_prefer_recent] )) ||
__git_commit_objects_prefer_recent () {
  local -a argument_array_names
  zparseopts -D -E O:=argument_array_names

  __git_recent_commits $argument_array_names || __git_commit_objects
}

# This function returns in $reply recently-checked-out refs' names, in order
# from most to least recent.
(( $+functions[__git_recent_branches__names] )) ||
__git_recent_branches__names()
{
  # This parameter expansion does the following:
  # 1. Obtains the last 1000 'checkout' operations from the reflog
  # 2. Extracts the move-source from each
  # 3. Eliminates duplicates
  # 4. Eliminates commit hashes (leaving only ref names)
  #    [This step is done again by the caller.]
  #
  # See workers/38592 for an equivalent long-hand implementation, and the rest
  # of that thread for why this implementation was chosen instead.
  #
  # Note: since we obtain the "from" part of the reflog, we only obtain heads, not tags.
  reply=(${${(u)${${(M)${(0)"$(_call_program reflog git reflog -1000 -z --pretty='%gs')"}:#(#s)checkout: moving from *}#checkout: moving from }%% *}:#[0-9a-f](#c40)})
}

(( $+functions[__git_recent_branches] )) ||
__git_recent_branches() {
  local -a branches
  local -A descriptions
  local -a reply
  local -aU valid_ref_names_munged=( ${"${(f)"$(_call_program valid-ref-names 'git for-each-ref --format="%(refname)" refs/heads/')"}"#refs/heads/} )

  # 1. Obtain names of recently-checked-out branches from the reflog.
  # 2. Remove ref names that no longer exist from the list.
  #    (We must do this because #3 would otherwise croak on them.)
  __git_recent_branches__names; branches=( ${(@)reply:*valid_ref_names_munged} )

  # 3. Early out if no matches.
  if ! (( $+branches[1] )); then
    # This can happen in a fresh repository (immediately after 'clone' or 'init') before
    # any 'checkout' commands were run in it.
    return 1
  fi

  # 4. Obtain log messages for all of them in one shot.
  # TODO: we'd really like --sort=none here...  but git doesn't support such a thing.
  local z=$'\0'
  descriptions=( "${(0)"$(_call_program all-descriptions "git --no-pager for-each-ref --format='%(refname)%00%(subject)'" refs/heads/${(q)^branches} "--")"//$'\n'/$z}" )

  # 5. Synthesize the data structure _describe wants.
  local -a branches_colon_descriptions
  local branch
  for branch in ${branches} ; do
    branches_colon_descriptions+="${branch//:/\:}:${descriptions[refs/heads/${(b)branch}]}"
  done

  _describe -V -t recent-branches "recent branches" branches_colon_descriptions
}

(( $+functions[__git_commits_prefer_recent] )) ||
__git_commits_prefer_recent () {
  local -a argument_array_names
  zparseopts -D -E O:=argument_array_names

  _alternative \
    'recent-branches::__git_recent_branches' \
    "commits::__git_commits $argument_array_names"
}

(( $+functions[__git_commits] )) ||
__git_commits () {
  local -a argument_array_names
  zparseopts -D -E O:=argument_array_names
  # Turn (-O foo:bar) to (foo bar)
  (( $#argument_array_names )) && argument_array_names=( "${(@s/:/)argument_array_names[2]}" )
  set -- "${(@P)argument_array_names[1]}"
  local commit_opts__argument_name=$argument_array_names[2]

  # TODO: deal with things that __git_heads and __git_tags has in common (i.e.,
  # if both exists, they need to be completed to heads/x and tags/x.
  local -a sopts ropt expl
  zparseopts -E -a sopts S: r:=ropt R: q
  sopts+=( $ropt:q )
  expl=( "$@" )
  _alternative \
    "heads::__git_heads $sopts" \
    "commit-tags::__git_commit_tags $sopts" \
    'commit-objects:: __git_commit_objects_prefer_recent -O expl:$commit_opts__argument_name'
}

(( $+functions[__git_heads] )) ||
__git_heads () {
  _alternative 'heads-local::__git_heads_local' 'heads-remote::__git_heads_remote'
}

(( $+functions[__git_heads_local] )) ||
__git_heads_local () {
  local f gitdir
  declare -a heads

  heads=(${(f)"$(_call_program headrefs git for-each-ref --format='"%(refname:short)"' refs/heads refs/bisect refs/stash 2>/dev/null)"})
  gitdir=$(_call_program gitdir git rev-parse --git-dir 2>/dev/null)
  if __git_command_successful $pipestatus; then
    for f in HEAD FETCH_HEAD ORIG_HEAD MERGE_HEAD; do
      [[ -f $gitdir/$f ]] && heads+=$f
    done
  fi

  __git_describe_commit heads heads-local "local head" "$@"
}

(( $+functions[__git_heads_remote] )) ||
__git_heads_remote () {
  declare -a heads

  heads=(${(f)"$(_call_program headrefs git for-each-ref --format='"%(refname:short)"' refs/remotes 2>/dev/null)"})

  __git_describe_commit heads heads-remote "remote head" "$@"
}

(( $+functions[__git_commit_objects] )) ||
__git_commit_objects () {
  local gitdir expl start
  declare -a commits

  if [[ -n $PREFIX[(r)@] ]] || [[ -n $SUFFIX[(r)@] ]]; then
    # doesn't match a commit hash, but might be a reflog entry
    __git_reflog_entries; return $?
  elif ! [[ "$PREFIX$SUFFIX" == [[:xdigit:]](#c1,40) ]]; then
    # Abort if the argument does not match a commit hash (including empty).
    return 1
  fi

  # Note: the after-the-colon part must be unique across the entire array;
  # see workers/34768
  commits=(${(f)"$(_call_program commits git --no-pager rev-list -1000 --all --reflog --format='%h:\[%h\]\ %s\ \(%cr\)' HEAD)"})
  __git_command_successful $pipestatus || return 1
  commits=(${commits:#commit [[:xdigit:]](#c40,)})

  _describe -Vx -t commits 'commit object name' commits
}

(( $+functions[__git_recent_commits] )) ||
__git_recent_commits () {
  local gitdir expl start
  declare -a descr tags heads commits argument_array_names commit_opts
  local h i j k ret
  integer distance_from_head
  local label
  local parents
  local next_first_parent_ancestral_line_commit

  zparseopts -D -E O:=argument_array_names
  # Turn (-O foo:bar) to (foo bar)
  (( $#argument_array_names )) && argument_array_names=( "${(@s/:/)argument_array_names[2]}" )
  (( $#argument_array_names > 1 )) && (( ${(P)+argument_array_names[2]} )) &&
    commit_opts=( "${(@P)argument_array_names[2]}" )

  # Careful: most %d will expand to the empty string.  Quote properly!
  # NOTE: we could use %D directly, but it's not available in git 1.9.1 at least.
  commits=("${(f)"$(_call_program commits git --no-pager rev-list -20 --format='%h%n%d%n%s\ \(%cr\)%n%p' HEAD ${(q)commit_opts})"}")
  __git_command_successful $pipestatus || return 1

  # h => hard-coded 'commit abcdef1234567890...' -- just discarded
  for h i j k parents in "$commits[@]" ; do
    # Note: the after-the-colon part must be unique across the entire array;
    # see workers/34768
    if (( $#commit_opts )); then
      # $commit_opts is set, so the commits we receive might not be in order,
      # or might not be ancestors of HEAD.  However, we must make the
      # description unique (due to workers/34768), which we do by including the
      # hash.  Git always prints enough hash digits to make the output unique.)
      label="[$i]"
    elif (( distance_from_head )) && [[ $i != $next_first_parent_ancestral_line_commit ]]; then
      # The first commit (HEAD), and its ancestors along the first-parent line,
      # get HEAD~$n labels.
      #
      # For other commits, we just print the hash.  (${parents} does provide enough
      # information to compute HEAD~3^2~4 -style labels, though, if somebody cared
      # enough to implement that.)
      label="[$i]"
    else
      # Compute a first-parent-ancestry commit's label.
      if false ; then
      elif (( distance_from_head == 0 )); then
        label="[HEAD]   "
      elif (( distance_from_head == 1 )); then
        label="[HEAD^]  "
      elif (( distance_from_head == 2 )); then
        label="[HEAD^^] "
      elif (( distance_from_head < 10 )); then
        label="[HEAD~$distance_from_head] "
      else
        label="[HEAD~$distance_from_head]"
      fi
      ## Disabled because _describe renders the output unhelpfully when this function
      ## is called twice during a single completion operation, and list-grouped is
      ## in its default setting (enabled).
      #descr+=("@~${distance_from_head}":"${label} $k") # CROSSREF: use the same label as below

      # Prepare for the next first-parent-ancestry commit.
      (( ++distance_from_head ))
      next_first_parent_ancestral_line_commit=${parents%% *}
    fi
    # label is now 9 bytes, so the descriptions ($k) will be aligned.
    descr+=($i:"${label} $k") # CROSSREF: use the same label as above

    j=${${j# \(}%\)} # strip leading ' (' and trailing ')'
    j=${j/ ->/,}  # Convert " -> master, origin/master".
    for j in ${(s:, :)j}; do
      if [[ $j == 'tag: '* ]] ; then
        tags+=( ${j#tag: } )
      else
        heads+=( $j )
      fi
    done
  done

  ret=1
  # Resetting expl to avoid it 'leaking' from one line to the next.
  expl=()
  _describe -V -t commits 'recent commit object name' descr && ret=0
  expl=()
  _wanted commit-tags expl 'commit tag' compadd "$@" -a - tags && ret=0
  expl=()
  _wanted heads expl 'head' compadd -M "r:|/=* r:|=*" "$@" -a - heads && ret=0
  return ret
}

(( $+functions[_git_fixup] )) ||
_git_fixup() {
  local alts
  alts=( 'commits: :__git_recent_commits' )
  if ! compset -P '(amend|reword):'; then
    alts+=( 'actions:action:compadd -S: amend reword' )
  fi
  _alternative $alts
}

(( $+functions[__git_blob_objects] )) ||
__git_blob_objects () {
  _guard '[[:xdigit:]](#c,40)' 'blob object name'
}

(( $+functions[__git_blobs] )) ||
__git_blobs () {
  _alternative \
    'blob-tags::__git_blob_tags' \
    'blob-objects::__git_blob_objects'
}

(( $+functions[__git_blobs_and_trees_in_treeish] )) ||
__git_blobs_and_trees_in_treeish () {
  compset -P '*:'
  [[ -n ${IPREFIX} ]] || return 1
  if [[ -n ${IPREFIX%:} ]]; then
    __git_is_treeish ${IPREFIX%:} && __git_tree_files ${PREFIX:-.} ${IPREFIX%:}
  else
    __git_changed-in-index_files
  fi
}

(( $+functions[__git_committishs] )) ||
__git_committishs () {
  __git_commits
}

(( $+functions[__git_revisions] )) ||
__git_revisions () {
  # TODO: deal with prefixes and suffixes listed in git-rev-parse
  __git_commits $*
}

(( $+functions[__git_commits2] )) ||
__git_commits2 () {
  compset -P '\\\^'
  __git_commits
}

(( $+functions[__git_commit_ranges] )) ||
__git_commit_ranges () {
  local -a argument_array_names
  zparseopts -D -E O:=argument_array_names
  # Turn (-O foo:bar) to (foo bar)
  (( $#argument_array_names )) && argument_array_names=( "${(@s/:/)argument_array_names[2]}" )
  set -- "${(@P)argument_array_names[1]}"
  local commit_opts__argument_name=$argument_array_names[2]

  local -a suf
  local -a expl
  if compset -P '*..(.|)'; then
    expl=( $* )
  else
    if ! compset -S '..*'; then
      local match mbegin mend
      if [[ ${PREFIX} = (#b)((\\|)\^)* ]]; then
	compset -p ${#match[1]}
      else
	suf=( -S .. -r '@~ \^:\t\n\-' )
      fi
    fi
    expl=( $* $suf )
  fi

  __git_commits -O expl:$commit_opts__argument_name
}

(( $+functions[__git_commit_ranges2] )) ||
__git_commit_ranges2 () {
  _alternative \
    'commits::__git_commits2' \
    'ranges::__git_commit_ranges'
}

(( $+functions[__git_trees] )) ||
__git_trees () {
  __git_objects
}

(( $+functions[__git_tree_ishs] )) ||
__git_tree_ishs () {
  __git_commits
}

(( $+functions[__git_objects] )) ||
__git_objects () {
  compset -P '*:'
  if [[ -n $IPREFIX ]]; then
    if compset -P ./ ; then
      __git_tree_files                 "$PREFIX" "${IPREFIX%:./}"
    else
      __git_tree_files --root-relative "$PREFIX" "${IPREFIX%:}"
    fi
  else
    _alternative \
      'revisions::__git_revisions' \
      'files::__git_cached_files'
  fi
}

(( $+functions[__git_submodules] )) ||
__git_submodules () {
  local expl
  declare -a submodules

  submodules=( ${${${(f)"$(_call_program submodules git submodule)"}#?* }%% *} )

  _wanted submodules expl submodule compadd "$@" -a - submodules
}

# Tag Argument Types

(( $+functions[__git_tags] )) ||
__git_tags () {
  local expl
  declare -a tags

  tags=(${${(f)"$(_call_program tagrefs git for-each-ref --format='"%(refname)"' refs/tags 2>/dev/null)"}#refs/tags/})
  __git_command_successful $pipestatus || return 1

  _wanted tags expl tag compadd -M 'r:|/=* r:|=*' "$@" -a - tags
}

(( $+functions[__git_commit_tags] )) ||
__git_commit_tags () {
  __git_tags_of_type commit $*
}

(( $+functions[__git_blob_tags] )) ||
__git_blob_tags () {
  __git_tags_of_type blob $*
}

(( $+functions[__git_tags_of_type] )) ||
__git_tags_of_type () {
  local type expl
  declare -a tags

  type=$1; shift

  tags=(${${(M)${(f)"$(_call_program ${(q)type}-tag-refs "git for-each-ref --format='%(*objecttype)%(objecttype) %(refname)' refs/tags 2>/dev/null")"}:#$type(tag|) *}#$type(tag|) refs/tags/})
  __git_command_successful $pipestatus || return 1

  _wanted $type-tags expl "$type tag" compadd -M 'r:|/=* r:|=*' "$@" -o numeric -a - tags
}

# Reference Argument Types

(( $+functions[__git_references] )) ||
__git_references () {
  local expl

  # TODO: depending on what options are on the command-line already, complete
  # only tags or heads
  # TODO: perhaps caching is unnecessary.  usually won't contain that much data
  # TODO: perhaps provide alternative here for both heads and tags (and use
  # __git_heads and __git_tags)
  # TODO: instead of "./.", we should be looking in the repository specified as
  # an argument to the command (but default to "./." I suppose (why not "."?))
  # TODO: deal with GIT_DIR
  if [[ $_git_refs_cache_pwd != $PWD ]]; then
    _git_refs_cache=(${${${(f)"$(_call_program references git ls-remote ./. 2>/dev/null)"}#*$'\t'}#refs/(heads|tags)/})
    __git_command_successful $pipestatus || return 1
    _git_refs_cache_pwd=$PWD
  fi

  _wanted references expl 'reference' compadd -M 'r:|/=* r:|=*' -a - _git_refs_cache
}

# ### currently unused; are some callers of __git_references supposed to call this function?
(( $+functions[__git_local_references] )) ||
__git_local_references () {
  local expl

  if [[ $_git_local_refs_cache_pwd != $PWD ]]; then
    _git_local_refs_cache=(${${${(f)"$(_call_program references git ls-remote ./. 2>/dev/null)"}#*$'\t'}#refs/})
    __git_command_successful $pipestatus || return 1
    _git_local_refs_cache_pwd=$PWD
  fi

  _wanted references expl 'reference' compadd -M 'r:|/=* r:|=*' -a - _git_local_refs_cache
}

(( $+functions[__git_remote_references] )) ||
__git_remote_references () {
  __git_references
}

(( $+functions[__git_notes_refs] )) ||
__git_notes_refs () {
  local expl
  declare -a notes_refs

  notes_refs=(${${(f)"$(_call_program notes-refs git for-each-ref --format='"%(refname)"' refs/notes 2>/dev/null)"}#$type refs/notes/})
  __git_command_successful $pipestatus || return 1

  _wanted notes-refs expl 'notes ref' compadd "$@" -a - notes_refs
}

# File Argument Types

(( $+functions[__git_files_relative] )) ||
__git_files_relative () {
  local files file f_parts prefix p_parts tmp

  prefix=$(_call_program gitprefix git rev-parse --show-prefix 2>/dev/null)
  __git_command_successful $pipestatus || return 1

  if (( $#prefix == 0 )); then
    print $1
    return
  fi

  files=()

  # Collapse "//" and "/./" into "/". Strip any remaining "/." and "/".
  for file in ${${${${${(0)1}//\/\///}//\/.\///}%/.}%/}; do
    integer i n
    (( n = $#file > $#prefix ? $#file : $#prefix ))
    for (( i = 1; i <= n; i++ )); do
      if [[ $file[i] != $prefix[i] ]]; then
        while (( i > 0 )) && [[ $file[i-1] != / ]]; do
          (( i-- ))
        done
        break
      fi
    done

    files+=${(l@${#prefix[i,-1]//[^\/]}*3@@../@)}${file[i,-1]}
  done

  print ${(pj:\0:)files}
}

(( $+functions[__git_files] )) ||
__git_files () {
  local compadd_opts opts tag description gittoplevel gitprefix files expl

  zparseopts -D -E -a compadd_opts V+: J+: 1 2 o+: n f x+: X+: M+: P: S: r: R: q F:
  zparseopts -D -E -a opts -- -cached -deleted -modified -others -ignored -unmerged -killed x+: --exclude+:
  tag=$1 description=$2; shift 2

  gittoplevel=$(_call_program toplevel git rev-parse --show-toplevel 2>/dev/null)
  __git_command_successful $pipestatus || return 1
  [[ -n $gittoplevel ]] && gittoplevel+="/"

  gitprefix=$(_call_program gitprefix git rev-parse --show-prefix 2>/dev/null)
  __git_command_successful $pipestatus || return 1

  # TODO: --directory should probably be added to $opts when --others is given.

  local pref=${(Q)${~PREFIX}}
  [[ $pref[1] == '/' ]] || pref=$gittoplevel$gitprefix$pref

  # First allow ls-files to pattern-match in case of remote repository. Use the
  # icase pathspec magic word to ensure that we support case-insensitive path
  # completion for users with the appropriate matcher configuration
  files=(${(0)"$(_call_program files git ls-files -z --exclude-standard ${(q)opts} -- ${(q)${pref:+:\(icase\)$pref\*}:-.} 2>/dev/null)"})
  __git_command_successful $pipestatus || return

  # If ls-files succeeded but returned nothing, try again with no pattern. Note
  # that ls-files defaults to the CWD if not given a path, so if the file we
  # were trying to add is in an *adjacent* directory, this won't return anything
  # helpful either
  if [[ -z "$files" && -n "$pref" ]]; then
    files=(${(0)"$(_call_program files git ls-files -z --exclude-standard ${(q)opts} -- 2>/dev/null)"})
    __git_command_successful $pipestatus || return
  fi

#  _wanted $tag expl $description _files -g '{'${(j:,:)files}'}' $compadd_opts -
  _wanted $tag expl $description _multi_parts -f $compadd_opts - / files
}

(( $+functions[__git_cached_files] )) ||
__git_cached_files () {
  __git_files --cached cached-files 'cached file' $*
}

(( $+functions[__git_deleted_files] )) ||
__git_deleted_files () {
  __git_files --deleted deleted-files 'deleted file' $*
}

(( $+functions[__git_modified_files] )) ||
__git_modified_files () {
  __git_files --modified modified-files 'modified file' $*
}

(( $+functions[__git_other_files] )) ||
__git_other_files () {
  __git_files --others untracked-files 'untracked file' $*
}

(( $+functions[__git_ignored_cached_files] )) ||
__git_ignored_cached_files () {
  __git_files --ignored --cached ignored-cached-files 'ignored cached file' $*
}

(( $+functions[__git_ignored_other_files] )) ||
__git_ignored_other_files () {
  __git_files --ignored --others ignored-untracked-files 'ignored untracked file' $*
}

(( $+functions[__git_unmerged_files] )) ||
__git_unmerged_files () {
  __git_files --unmerged unmerged-files 'unmerged file' $*
}

(( $+functions[__git_killed_files] )) ||
__git_killed_files () {
  __git_files --killed killed-files 'killed file' $*
}

(( $+functions[__git_diff-index_files] )) ||
__git_diff-index_files () {
  local tree=$1 description=$2 tag=$3; shift 3
  local files expl

  # $tree needs to be escaped for _call_program; matters for $tree = "HEAD^"
  files=$(_call_program files git diff-index -z --name-only --no-color --cached ${(q)tree} 2>/dev/null)
  __git_command_successful $pipestatus || return 1
  files=(${(0)"$(__git_files_relative $files)"})
  __git_command_successful $pipestatus || return 1

  _wanted $tag expl $description _multi_parts $@ - / files
}

(( $+functions[__git_changed-in-index_files] )) ||
__git_changed-in-index_files () {
  __git_diff-index_files HEAD 'changed in index file' changed-in-index-files "$@"
}

(( $+functions[__git_treeish-to-index_files] )) ||
__git_treeish-to-index_files () {
  local tree=$1; shift
  __git_diff-index_files $tree "files different between ${(qq)tree} and the index" treeish-to-index-files "$@"
}

(( $+functions[__git_changed-in-working-tree_files] )) ||
__git_changed-in-working-tree_files () {
  local files expl

  files=$(_call_program changed-in-working-tree-files git diff -z --name-only --no-color 2>/dev/null)
  __git_command_successful $pipestatus || return 1
  files=(${(0)"$(__git_files_relative $files)"})
  __git_command_successful $pipestatus || return 1

  _wanted changed-in-working-tree-files expl 'changed in working tree file' _multi_parts $@ -f - / files
}

(( $+functions[__git_changed_files] )) ||
__git_changed_files () {
  _alternative \
    'changed-in-index-files::__git_changed-in-index_files' \
    'changed-in-working-tree-files::__git_changed-in-working-tree_files'
}

#     __git_tree_files [--root-relative] FSPATH TREEISH [TREEISH...] [COMPADD OPTIONS]
#
# Complete [presently: a single level of] repository files under FSPATH.
# FSPATH is interpreted as a directory path within each TREEISH.
# FSPATH is relative to cwd, unless --root-relative is specified, in
# which case it is relative to the repository root.
(( $+functions[__git_tree_files] )) ||
__git_tree_files () {
  local tree Path
  integer at_least_one_tree_added
  local -a tree_files compadd_opts
  local -a extra_args

  if [[ $1 == --root-relative ]]; then
    extra_args+=(--full-tree)
    shift
  fi

  zparseopts -D -E -a compadd_opts V+: J+: 1 2 o+: n f x+: X+: M+: P: S: r: R: q F:

  Path=${(M)1##(../)#}
  [[ ${1##(../)#} = */* ]] && extra_args+=( -r )
  shift
  (( at_least_one_tree_added = 0 ))
  for tree; do
    tree_files+=(${(ps:\0:)"$(_call_program tree-files git ls-tree $extra_args --name-only -z ${(q)tree} $Path 2>/dev/null)"})
    __git_command_successful $pipestatus && (( at_least_one_tree_added = 1 ))
  done

  if (( !at_least_one_tree_added )); then
    return 1
  fi

  local expl
  _wanted files expl 'tree file' _multi_parts -f $compadd_opts -- / tree_files
}

# Repository Argument Types

(( $+functions[__git_remote_repositories] )) ||
__git_remote_repositories () {
  if compset -P '*:'; then
    _remote_files -/ -- ssh
  else
    _ssh_hosts -S:
  fi
}

(( $+functions[__git_repositories] )) ||
__git_repositories () {
  _alternative \
    'local-repositories::__git_local_repositories' \
    'remote-repositories::__git_remote_repositories'
}

(( $+functions[__git_local_repositories] )) ||
__git_local_repositories () {
  local expl

  _wanted local-repositories expl 'local repository' _directories
}

(( $+functions[__git_repositories_or_urls] )) ||
__git_repositories_or_urls () {
  _alternative \
    'repositories::__git_repositories' \
    'urls::_urls'
}

(( $+functions[__git_current_remote_urls] )) ||
__git_current_remote_urls () {
  local expl
  _description remote-urls expl 'current url'
  compadd "$expl[@]" -M 'r:|/=* r:|=*' - ${(f)"$(_call_program remote-urls
      git remote get-url "$@" --all)"}
}

(( $+functions[__git_any_repositories] )) ||
__git_any_repositories () {
  # TODO: should also be $GIT_DIR/remotes/origin
  _alternative \
    'local-repositories::__git_local_repositories' \
    'remotes: :__git_remotes' \
    'remote-repositories::__git_remote_repositories'
}

(( $+functions[__git_any_repositories_or_references] )) ||
__git_any_repositories_or_references () {
  _alternative \
    'repositories::__git_any_repositories' \
    'references::__git_references'
}

# Common Guards

(( $+functions[__git_guard] )) ||
__git_guard () {
  declare -A opts

  zparseopts -K -D -A opts M+: J+: V+: 1 2 o+: n F: x+: X+:

  [[ "$PREFIX$SUFFIX" != $~1 ]] && return 1

  if (( $+opts[-X] )); then
    _message -r $opts[-X]
  else
    _message -e $2
  fi

  [[ -n "$PREFIX$SUFFIX" ]]
}

__git_guard_branch-name () {
  if [[ -n $PREFIX$SUFFIX ]]; then
    _call_program check-ref-format git check-ref-format "refs/heads/"${(q)PREFIX}${(q)SUFFIX} &>/dev/null
    (( ${#pipestatus:#0} > 0 )) && return 1
  fi

  _message -e 'branch name'

  [[ -n $PREFIX$SUFFIX ]]
}

__git_guard_diff-stat-width () {
  if [[ $PREFIX == *,* ]]; then
    compset -P '*,'
    __git_guard_number 'filename width'
  else
    compset -S ',*'
    __git_guard_number width
  fi
}

(( $+functions[__git_guard_number] )) ||
__git_guard_number () {
  declare -A opts

  zparseopts -K -D -A opts M+: J+: V+: 1 2 o+: n F: x+: X+:

  _guard '[[:digit:]]#' ${1:-number}
}

(( $+functions[__git_guard_bytes] )) ||
__git_guard_bytes () {
  _numbers -u bytes ${*:-size} k m g
}

(( $+functions[__git_datetimes] )) ||
__git_datetimes () {
  # TODO: Use this in more places.
  _guard '*' 'time specification'
}

(( $+functions[__git_stages] )) ||
__git_stages () {
  __git_guard $* '[[:digit:]]#' 'stage'
}

(( $+functions[__git_svn_revision_numbers] )) ||
__git_svn_revision_numbers () {
  __git_guard_number 'revision number'
}

# _arguments Helpers

(( $+functions[__git_setup_log_options] )) ||
__git_setup_log_options () {
  # TODO: Need to implement -<n> for limiting the number of commits to show.
  log_options=(
    '(- *)-h[display help]'
    '--decorate-refs=[only decorate refs that match pattern]:pattern'
    "--decorate-refs-exclude=[don't decorate refs that match pattern]:pattern"
    '(           --no-decorate)--decorate=-[print out ref names of any commits that are shown]: :__git_log_decorate_formats'
    '(--decorate              )--no-decorate[do not print out ref names of any commits that are shown]'
    '(          --no-follow)--follow[follow renames]'
    '(--follow             )--no-follow[do not follow renames]'
    '--source[show which ref each commit is reached from]'
    '*-L+[trace evolution of line range, function or regex within a file]: :_git_log_line_ranges'
  )
}

(( $+functions[__git_ws_error_highlight] )) ||
__git_ws_error_highlight() {
  _values -s , "kind of line" all default none context old new
}

(( $+functions[__git_color_moved] )) ||
__git_color_moved() {
  local -a __git_color_moved=(
    no:"do not highlight moved lines"
    default:"like zebra"
    plain:"highlight moved lines with color"
    blocks:"greedily detect blocks of moved text of at least 20 characters"
    zebra:"like blocks, with alternating colors between different blocks"
    dimmed-zebra:"like zebra, uninteresting parts are dimmed"
  )
  _describe "mode" __git_color_moved
}

(( $+functions[__git_color_movedws] )) ||
__git_color_movedws() {
  _sequence compadd - no ignore-space-at-eol ignore-space-change ignore-all-space allow-indentation-change
}

(( $+functions[__git_setup_diff_options] )) ||
__git_setup_diff_options () {
  # According to Git: "fatal: --name-only, --name-status, --check and -s are mutually exclusive"
  local exclusive_diff_options='(--name-only --name-status --check -s --no-patch)'

  diff_options=(
    {-p,-u,--patch}'[generate diff in patch format]'
    {-U,--unified=}'[generate diff with given lines of context]: :__git_guard_number lines'
    '--raw[generate default raw diff output]'
    '--patch-with-raw[generate patch but also keep the default raw diff output]'
    $exclusive_diff_options{-s,--no-patch}'[suppress diff output]'
    '(--minimal --patience --histogram --diff-algorithm)--minimal[spend extra time to make sure the smallest possible diff is produced]'
    '(--minimal --patience --histogram --diff-algorithm)--patience[generate diffs with patience algorithm]'
    '(--minimal --patience --histogram --diff-algorithm)--histogram[generate diffs with histogram algorithm]'
    '(--minimal --patience --histogram --diff-algorithm)*--anchored=[generate diffs using the "anchored diff" algorithm]:text'
    '(--minimal --patience --histogram --diff-algorithm)--diff-algorithm=[choose a diff algorithm]:diff algorithm:((default\:"basic greedy diff algorithm"
                                                                                                                    myers\:"basic greedy diff algorithm"
                                                                                                                    minimal\:"spend extra time to make sure the smallest possible diff is produced"
                                                                                                                    patience\:"generate diffs with patience algorithm"
                                                                                                                    histogram\:"generate diffs with histogram algorithm"))'
    '--stat=-[generate diffstat instead of patch]:: :__git_guard_diff-stat-width'
    '--stat-width=-[generate diffstat with a given width]:width'
    '--stat-graph-width=-[generate diffstat with a given graph width]:width'
    '--stat-count=[generate diffstat with limited lines]:lines'
    '--compact-summary[generate compact summary in diffstat]'
    '--numstat[generate more machine-friendly diffstat]'
    '--shortstat[generate summary diffstat]'
    '--dirstat=-[generate dirstat by amount of changes]:: :_git_dirstat_params'
    '--cumulative[synonym for --dirstat=cumulative]'
    '--dirstat-by-file=-[generate dirstat by number of files]:: :__git_guard_number limit'
    '--summary[generate condensed summary of extended header information]'
    '--patch-with-stat[generate patch and prepend its diffstat]'
    '-z[use NUL termination on output]'
    $exclusive_diff_options'--name-only[show only names of changed files]'
    $exclusive_diff_options'--name-status[show only names and status of changed files]'
    '--submodule=-[select output format for submodule differences]::format:((short\:"show pairs of commit names"
                                                                             log\:"list commits like git submodule does"
                                                                             diff\:"show differences"))'
    '(        --no-color --color-words --color-moved)--color=-[show colored diff]:: :__git_color_whens'
    '(--color            --color-words --color-moved)--no-color[turn off colored diff]'
    '--word-diff=-[show word diff]::mode:((color\:"highlight changed words using color"
                                          plain\:"wrap deletions and insertions with markers"
                                          porcelain\:"use special line-based format for scripts"
                                          none\:"disable word diff"))'
    '--word-diff-regex=-[specify what constitutes a word]:word regex'
    '(--color --no-color                            )--color-words=-[show colored-word diff]::word regex'
    '(--color --no-color                            )--color-moved=-[color moved lines differently]::mode:__git_color_moved'
    '(--no-color-moved-ws)--color-moved-ws=[configure how whitespace is ignored when performing move detection for --color-moved]:mode:__git_color_movedws'
    "(--color-moved-ws)--no-color-moved-ws=[don't ignore whitespace when performing move detection]"
    "--ita-invisible-in-index[hide 'git add -N' entries from the index]"
    "!(--ita-invisible-in-index)--ita-visible-in-index"
    '--no-renames[turn off rename detection]'
    $exclusive_diff_options'--check[warn if changes introduce trailing whitespace or space/tab indents]'
    '--full-index[show full object name of pre- and post-image blob]'
    '(--full-index)--binary[in addition to --full-index, output binary diffs for git-apply]'
    '--ws-error-highlight=[specify where to highlight whitespace errors]: :__git_ws_error_highlight'
    '--abbrev=[use specified digits to display object names]:digits'
    '(-B --break-rewrites)'{-B-,--break-rewrites=-}'[break complete rewrite changes into pairs of given size]:: :__git_guard_number size'
    '(-M --find-renames)'{-M-,--find-renames=-}'[detect renames with given scope]:: :__git_guard_number size'
    '(-C --find-copies)'{-C-,--find-copies=-}'[detect copies as well as renames with given scope]:: :__git_guard_number size'
    '--find-copies-harder[try harder to find copies]'
    '(-D --irreversible-delete)'{-D,--irreversible-delete}'[omit the preimage for deletes]'
    '--rename-empty[use empty blobs as rename source]'
    '--follow[continue listing the history of a file beyond renames]'
    '-l-[limit number of rename/copy targets to run]: :__git_guard_number'
    '--diff-filter=-[select certain kinds of files for diff]: :_git_diff_filters'
    '-S-[look for differences that add or remove the given string]:string'
    '-G-[look for differences whose added or removed line matches the given regex]:pattern'
    '--pickaxe-all[when -S finds a change, show all changes in that changeset]'
    '--pickaxe-regex[treat argument of -S as regular expression]'
    '-O-[output patch in the order of glob-pattern lines in given file]: :_files'
    '--rotate-to=[show the change in specified path first]:path:_directories'
    '--skip-to=[skip the output to the specified path]:path:_directories'
    '--find-object=[look for differences that change the number of occurrences of specified object]:object:__git_blobs'
    '-R[do a reverse diff]'
    '--relative=-[exclude changes outside and output relative to given directory]:: :_directories'
    '(-a --text)'{-a,--text}'[treat all files as text]'
    '--ignore-space-at-eol[ignore changes in whitespace at end of line]'
    '--ignore-cr-at-eol[ignore carriage-return at end of line]'
    '(-b --ignore-space-change -w --ignore-all-space)'{-b,--ignore-space-change}'[ignore changes in amount of white space]'
    '(-b --ignore-space-change -w --ignore-all-space)'{-w,--ignore-all-space}'[ignore white space when comparing lines]'
    '--ignore-blank-lines[ignore changes whose lines are all blank]'
    \*{-I+,--ignore-matching-lines=}'[ignore changes whose lines all match regex]:regex'
    '--no-indent-heuristic[disable heuristic that shifts diff hunk boundaries to make patches easier to read]'
    '--inter-hunk-context=[combine hunks closer than N lines]:number of lines'
    '--output-indicator-new=[specify the character to indicate a new line]:character [+]'
    '--output-indicator-old=[specify the character to indicate a old line]:character [-]'
    '--output-indicator-context=[specify the character to indicate a context line]:character [ ]'
    '--exit-code[report exit code 1 if differences, 0 otherwise]'
    '(           --no-ext-diff)--ext-diff[allow external diff helper to be executed]'
    '(--ext-diff              )--no-ext-diff[disallow external diff helper to be executed]'
    '(--textconv --no-textconv)--textconv[allow external text conversion filters to be run when comparing binary files]'
    '(--textconv --no-textconv)--no-textconv[do not allow external text conversion filters to be run when comparing binary files]'
    '--ignore-submodules[ignore changes to submodules]:: :__git_ignore_submodules_whens'
    '(--no-prefix)--src-prefix=[use given prefix for source]:prefix'
    '(--no-prefix)--dst-prefix=[use given prefix for destination]:prefix'
    '--line-prefix=[prepend additional prefix to every line of output]:prefix'
    '(--src-prefix --dst-prefix)--no-prefix[do not show any source or destination prefix]'
    '(-c --cc)'{-c,--cc}'[combined diff format for merge commits]'
    '--output=[output to a specific file]: :_files')
}

(( $+functions[__git_setup_diff_stage_options] )) ||
__git_setup_diff_stage_options () {
  diff_stage_options=(
    '(-0 -1 -2 -3 --base --ours --theirs -c --cc --no-index)'{-1,--base}'[diff against "base" version]'
    '(-0 -1 -2 -3 --base --ours --theirs -c --cc --no-index)'{-2,--ours}'[diff against "our branch" version]'
    '(-0 -1 -2 -3 --base --ours --theirs -c --cc --no-index)'{-3,--theirs}'[diff against "their branch" version]'
    '(-0 -1 -2 -3 --base --ours --theirs -c --cc --no-index)-0[omit diff output for unmerged entries]'
  )
}

(( $+functions[__git_format_placeholders] )) ||
__git_format_placeholders() {
  local sep
  local -a disp names placeholders expl
  _describe -t formats format '( oneline:"<hash> <title>"
    short:"commit hash plus author and title headers"
    medium:"like short plus author date header and full message"
    full:"like medium with committer header instead of date"
    fuller:"like full plus author and commit date headers"
    reference:"<abbrev hash> (<title>, <short author date>)"
    email:"email patch format"
    mboxrd:"like email with From lines in message quoted with >"
    raw:"entire commit object" )' -- '( format:"specify own format" )' -S ':' && return
  compset -P 'format:'
    compset -P '(%[^acgCG]|%?[^%]|[^%])#'
    if compset -P '%C'; then
      _wanted colors expl color compadd reset red green blue
      return
    fi
    if [[ -prefix %G ]]; then
      placeholders=(
	'GG:raw verification message'
	'G?:indicate [G]ood, [B]ad, [U]ntrusted or [N]o signature'
	'GS:name of signer'
	'GK:signing key'
	'GF:fingerprint of signing key'
	'GP:fingerprint of primary key whose subkey was used to sign'
      )
      disp=( -l )
    elif [[ -prefix %g ]]; then
      placeholders=(
	gD:'reflog selector'
	gd:'short reflog selector'
	gn:'reflog identity'
	gN:'reflog identity name'
	ge:'reflog identity email'
	gE:'reflog identity email (use .mailmap)'
	gs:'reflog subject'
      )
      disp=( -l )
    elif [[ $PREFIX = (#b)%([ac]) ]]; then
      placeholders=(
	n:'name'
	N:'name (use .mailmap)'
	e:'email'
	E:'email (use .mailmap)'
	d:'date'
	D:'date, RFC2822 style'
	r:'date, relative'
	t:'date, UNIX timestamp'
	i:'date, like ISO 8601'
	I:'date, strict ISO 8601'
      )
      placeholders=( $match[1]$^placeholders )
    else
      placeholders=(
	H:commit\ hash
	h:'abbreviated commit hash'
	T:'tree hash'
	t:'abbreviated tree hash'
	P:'parent hashes'
	p:'abbreviated parent hashes'
	a:'author details'
	c:'committer details'
	d:'ref name in brackets'
	D:'ref name'
	S:'ref name used to reach commit'
	e:encoding
	s:subject
	f:'sanitized subject'
	g:reflog
	b:body
	B:'raw body'
	N:notes
	G:GPG\ details
	C:color
	m:mark
	n:newline
	%:raw\ %
	x:'hex code'
	w:'switch line wrapping'
      )
    fi
    names=( ${placeholders%%:*} )
    if zstyle -T ":completion:${curcontext}:" verbose; then
      zstyle -s ":completion:${curcontext}:" list-separator sep || sep=--
      zformat -a placeholders " $sep " $placeholders
      disp+=(-d placeholders)
    else
      disp=()
    fi
    _wanted placeholders expl placeholder \
        compadd -p % -S '' "$disp[@]" "$@" - "$names[@]"
}

(( $+functions[__git_setup_revision_options] )) ||
__git_setup_revision_options () {
  local -a diff_options
  __git_setup_diff_options

  revision_options=(
    $diff_options
    '(-v --header)'{--pretty=-,--format=-}'[pretty print commit messages]::format:__git_format_placeholders'
    '(--abbrev-commit --no-abbrev-commit)--abbrev-commit[show only partial prefixes of commit object names]'
    '(--abbrev-commit --no-abbrev-commit)--no-abbrev-commit[show the full 40-byte hexadecimal commit object name]'
    '(--abbrev --no-abbrev)--no-abbrev[show the full 40-byte hexadecimal commit object name]'
    '--oneline[shorthand for --pretty=oneline --abbrev-commit]'
    '--encoding=-[output log messages in given encoding]:: :__git_encodings'
    '(--no-notes --notes)--no-notes[do not show notes that annotate commit]'
    '(--no-notes        )*--notes=[show notes that annotate commit, with optional ref argument show this notes ref instead of the default notes ref(s)]:: :__git_notes_refs'
    '--show-signature[validate GPG signature of commit]'
    '(                --date)--relative-date[show dates relative to current time]'
    '(--relative-date       )--date=-[format of date output]: :__git_date_formats'
    '--parents[display parents of commit]'
    '--children[display children of commit]'
    '--left-right[mark which side of symmetric diff commit is reachable from]'
    '(--show-linear-break        )--graph[display graphical representation of commit history]'
    '(                    --graph)--show-linear-break=[show a barrier between commits from different branches]:barrier'
    '--count[display how many commits would have been listed]'
    '(-n --max-count)'{-n+,--max-count=}'[maximum number of commits to display]: :__git_guard_number'
    '--skip=[skip given number of commits before output]: :__git_guard_number'
    '(--max-age --since --after)'{--since=,--after=}'[show commits more recent than given date]:date'
    '(--min-age --until --before)'{--until=,--before=}'[show commits older than given date]: :__git_guard_number timestamp'
    '(          --since --after)--max-age=-[maximum age of commits to output]: :__git_guard_number timestamp'
    '(          --until --before)--min-age[minimum age of commits to output]: :__git_guard_number timestamp'
    '*--author=[limit commits to those by given author]:author'
    '*--committer=[limit commits to those by given committer]:committer'
    '*--grep=[limit commits to those with log messages matching the given pattern]:pattern'
    '--all-match[limit commits to those matching all --grep, --author, and --committer]'
    '--invert-grep[limit commits to those not matching --grep, --author and --committer]'
    '(-i --regexp-ignore-case)'{-i,--regexp-ignore-case}'[match regexps ignoring case]'
    '!(-E --extended-regexp -F --fixed-strings -P --perl-regexp)--basic-regexp'
    '(-E --extended-regexp -F --fixed-strings -P --perl-regexp)'{-E,--extended-regexp}'[use POSIX extended regexps]'
    '(-E --extended-regexp -F --fixed-strings -P --perl-regexp)'{-F,--fixed-strings}"[don't interpret patterns as regexps]"
    '(-E --extended-regexp -F --fixed-strings -P --perl-regexp)'{-P,--perl-regexp}'[use perl regular expression]'
    '--remove-empty[stop when given path disappears from tree]'
    '(--no-merges --min-parents)--merges[display only merge commits]'
    "(--merges --max-parents)--no-merges[don't display commits with more than one parent]"
    '(--min-parents --no-min-parents --merges)--min-parents=-[show only commits with at least specified number of commits]: :__git_guard_number "number of parents"'
    '(--min-parents --no-min-parents --merges)--no-min-parents[reset limit]'
    '(--max-parents --no-max-parents --no-merges)--max-parents=-[show only commits with at most specified number of commits]: :__git_guard_number "number of parents"'
    '(--max-parents --no-max-parents)--no-max-parents[reset limit]'
    '--first-parent[follow only first parent from merge commits]'
    '*--not[reverses meaning of ^ prefix for revisions that follow]'
    '--all[show all commits from refs]'
    '--branches=-[show all commits from refs/heads]::pattern'
    '--tags=-[show all commits from refs/tags]::pattern'
    '--remotes=-[show all commits from refs/remotes]::pattern'
    '--glob=[show all commits from refs matching glob]:pattern'
    '--exclude=[do not include refs matching glob]:pattern'
    '--exclude=[do not include refs matching glob]:pattern'
    '--ignore-missing[ignore invalid object an ref names on command line]'
    '--bisect[pretend as if refs/bisect/bad --not refs/bisect/good-* was given on command line]'
    '(-g --walk-reflogs --reverse)'{-g,--walk-reflogs}'[walk reflog entries from most recent to oldest]'
    '--grep-reflog=[limit commits to ones whose reflog message matches the given pattern (with -g, --walk-reflogs)]:pattern'
    '--merge[after a failed merge, show refs that touch files having a conflict]'
    '--boundary[output uninteresting commits at boundary]'
    '--simplify-by-decoration[show only commits that are referenced by a ref]'
    '(               --dense --sparse --simplify-merges --ancestry-path)--full-history[do not prune history]'
    '(--full-history         --sparse --simplify-merges --ancestry-path)--dense[only display selected commits, plus meaningful history]'
    '(--full-history --dense          --simplify-merges --ancestry-path)--sparse[when paths are given, display only commits that changes any of them]'
    '(--full-history --dense --sparse                   --ancestry-path)--simplify-merges[milder version of --full-history]'
    '(--full-history --dense --sparse --simplify-merges                )--ancestry-path[only display commits that exists directly on ancestry chains]'
    '(             --date-order --author-date-order)--topo-order[display commits in topological order]'
    '(--topo-order              --author-date-order)--date-order[display commits in date order]'
    '(--topo-order --date-order                    )--author-date-order[display commits in author date order]'
    '(-g --walk-reflogs)--reverse[display commits in reverse order]'
    '(          --objects-edge)--objects[display object ids of objects referenced by listed commits]'
    '(--objects               )--objects-edge[display object ids of objects referenced by listed and excluded commits]'
    "(          --do-walk)--no-walk=-[only display given revs, don't traverse their ancestors]::order:(sorted unsorted)"
    '(--no-walk          )--do-walk[only display given revs, traversing their ancestors]'
    '(              --cherry-pick)--cherry-mark[like --cherry-pick but mark equivalent commits instead of omitting them]'
    '(--cherry-pick              )--cherry-pick[omit any commit that introduces the same change as another commit on "the other side" of a symmetric range]'
    '(            --right-only)--left-only[list only commits on the left side of a symmetric range]'
    '(--left-only             )--right-only[list only commits on the right side of a symmetric range]'
    '(--left-only --right-only --cherry-pick --cherry-mark --no-merges --merges --max-parents)--cherry[synonym for --right-only --cherry-mark --no-merges]'
    '(-c --cc            )--full-diff[show full commit diffs when using log -p, not only those affecting the given path]'
    '--log-size[print log message size in bytes before the message]'
    --{use-,}mailmap'[use mailmap file to map author and committer names and email]'

    '--reflog[show all commits from reflogs]'
    '--single-worktree[examine the current working tree only]'
    '--stdin[additionally read commits from standard input]'
    '--default[use argument as default revision]:default revision:__git_revisions'
    # TODO: --early-output is undocumented.
    '--early-output=-[undocumented]::undocumented'
    )

  if (( words[(I)--objects(|-edge)] )); then
    revision_options+=('--unpacked[print object IDs not in packs]')
  fi
}

(( $+functions[__git_setup_merge_options] )) ||
__git_setup_merge_options () {
  merge_options=(
    '(         --no-commit)--commit[perform the merge and commit the result]'
    '(--commit            )--no-commit[perform the merge but do not commit the result]'
    '(         --no-edit -e)--edit[open an editor to change the commit message]'
    "(--edit             -e)--no-edit[don't open an editor to change the commit message]"
    '--cleanup=[specify how to strip spaces and #comments from message]:mode:_git_cleanup_modes'
    '(     --no-ff)--ff[do not generate a merge commit if the merge resolved as a fast-forward]'
    '(--ff        )--no-ff[generate a merge commit even if the merge resolved as a fast-forward]'
    '(      --no-log)--log=-[add entries from shortlog to merge commit message]::entries to add'
    '(--log         )--no-log[do not list one-line descriptions of the commits being merged in the log message]'
    '(-n --no-stat)--stat[show a diffstat at the end of the merge]'
    '(--stat -n --no-stat)'{-n,--no-stat}'[do not show diffstat at the end of the merge]'
    '(         --no-squash)--squash[merge, but do not commit]'
    '--autostash[automatically stash/stash pop before and after]'
    '--signoff[add Signed-off-by: trailer]'
    '(--squash            )--no-squash[merge and commit]'
    '--ff-only[refuse to merge unless HEAD is up to date or merge can be resolved as a fast-forward]'
    '(-S --gpg-sign --no-gpg-sign)'{-S-,--gpg-sign=-}'[GPG-sign the commit]::key id'
    "(-S --gpg-sign --no-gpg-sign)--no-gpg-sign[don't GPG-sign the commit]"
    '*'{-s+,--strategy=}'[use given merge strategy]:merge strategy:__git_merge_strategies'
    '*'{-X+,--strategy-option=}'[pass merge-strategy-specific option to merge strategy]: :_git_strategy_options'
    '(--verify-signatures)--verify-signatures[verify the commits being merged or abort]'
    '(--no-verify-signatures)--no-verify-signatures[do not verify the commits being merged]'
    '(-q --quiet -v --verbose)'{-q,--quiet}'[suppress all output]'
    '(-q --quiet -v --verbose)'{-v,--verbose}'[output additional information]'
    '--allow-unrelated-histories[allow merging unrelated histories]'
  )
}

(( $+functions[__git_setup_fetch_options] )) ||
__git_setup_fetch_options () {
  fetch_options=(
    '(: * -m --multiple)--all[fetch all remotes]'
    '(-a --append)'{-a,--append}'[append ref names and object names of fetched refs to "$GIT_DIR/FETCH_HEAD"]'
    '(-j --jobs)'{-j+,--jobs=}'[specify number of submodules fetched in parallel]:jobs'
    '--depth=[deepen the history of a shallow repository by the given number of commits]: :__git_guard_number depth'
    '--unshallow[convert a shallow clone to a complete one]'
    '--update-shallow[accept refs that update .git/shallow]'
    '--refmap=[specify refspec to map refs to remote tracking branches]:refspec'
    '(-4 --ipv4 -6 --ipv6)'{-4,--ipv4}'[use IPv4 addresses only]'
    '(-4 --ipv4 -6 --ipv6)'{-6,--ipv6}'[use IPv6 addresses only]'
    '--dry-run[show what would be done, without making any changes]'
    '(-f --force)'{-f,--force}'[force overwrite of local reference]'
    '(-k --keep)'{-k,--keep}'[keep downloaded pack]'
    '(-p --prune)'{-p,--prune}'[remove any remote tracking branches that no longer exist remotely]'
    '(--no-tags -t --tags)'{-t,--tags}'[fetch remote tags]'
    '(-u --update-head-ok)'{-u,--update-head-ok}'[allow updates of current branch head]'
    '--upload-pack=[specify path to git-upload-pack on remote side]:remote path'
    '(--no-recurse-submodules --recurse-submodules)--recurse-submodules=-[specify when to fetch commits of submodules]::recursive fetching mode:((no\:"disable recursion"
                                                                                                                                                yes\:"always recurse"
                                                                                                                                                on-demand\:"only when submodule reference in superproject is updated"))'
    '(--no-recurse-submodules --recurse-submodules)--no-recurse-submodules[disable recursive fetching of submodules]'
    '(--no-recurse-submodules)--recurse-submodules-default=-[provide internal temporary non-negative value for "--recurse-submodules"]::recursive fetching mode:((yes\:"always recurse"
                                                                                                                                                                 on-demand\:"only when submodule reference in superproject is updated"))'
    '--submodule-prefix=-[prepend <path> to paths printed in informative messages]:submodule prefix path:_files -/'
    '(-q --quiet -v --verbose --progress)'{-q,--quiet}'[suppress all output]'
    '(-q --quiet -v --verbose)'{-v,--verbose}'[output additional information]'
    '(-q --quiet)--progress[force progress reporting]'
    '--show-forced-updates[check for forced-updates on all updated branches]'
    '--set-upstream[set upstream for git pull/fetch]'
    '--shallow-since=[deepen history of shallow repository based on time]:time' \
    '*--shallow-exclude=[deepen history of shallow clone by excluding revision]:revision' \
    '--deepen[deepen history of shallow clone]:number of commits' \
    \*{-o+,--server-option=}'[send specified string to the server when using protocol version 2]:option'
    '--negotiation-tip=[only report refs reachable from specified object to the server]:commit:__git_commits' \
  )
}

(( $+functions[__git_setup_apply_options] )) ||
__git_setup_apply_options () {
  apply_options=(
    '--whitespace=[detect a new or modified line that ends with trailing whitespaces]: :__git_apply_whitespace_strategies'
    '-p-[remove N leading slashes from traditional diff paths]: :_guard  "[[\:digit\:]]#" "number of slashes to remove"'
    '-C-[ensure at least N lines of context match before and after each change]: :_guard  "[[\:digit\:]]#" "number of lines of context"'
    '--reject[apply hunks that apply and leave rejected hunks in .rej files]'
    '(--ignore-space-change --ignore-whitespace)'{--ignore-space-change,--ignore-whitespace}'[ignore changes in whitespace in context lines]'
    '--directory=[root to prepend to all filenames]:root:_directories'
    '*--exclude=[skip files matching specified pattern]:pattern'
    '*--include=[include files matching specified pattern]:pattern'
    )
}

# Git Config Helpers

(( $+functions[__git_config_get_regexp] )) ||
__git_config_get_regexp () {
  declare -A opts

  zparseopts -A opts -D b: a:
  [[ -n $opts[-b] ]] || opts[-b]='*.'
  [[ -n $opts[-a] ]] || opts[-a]='.[^.]##'
  [[ $1 == -- ]] && shift

  set -A $2 ${${${(0)"$(_call_program ${3:-$2} "git config -z --get-regexp -- ${(q)1}")"}#${~opts[-b]}}%%${~opts[-a]}$'\n'*}
}

(( $+functions[__git_config_sections] )) ||
__git_config_sections () {
  declare -a opts
  local regex tag desc
  local -a groups

  zparseopts -a opts -D b: a:
  regex=$1
  tag=$2
  desc=$3
  shift 3

  __git_config_get_regexp $opts -- $regex groups $tag
  # TODO: Should escape : with \: in groups.
  _describe -t $tag $desc groups $*
}

# __git_config_booleans [-t TAG] [-l LABEL] CURRENT DEFAULT DESCRIPTION [OTHER]...
#
# -t can be used to specify a tag to use (default: booleans).
# -l can be used to specify a label to use (default: boolean).
#
# The first argument is the current value, so that the description of the
# current value can be suffixed with " (current)".
#
# The second argument is the default value, so that the description of the
# default value can be suffixed with " (default)".
#
# The third argument is the description to use for the true and false values.
#
# The rest of the arguments can be used to provide additional "boolean" values
# that should be included.  They should be of the form that _describe expects.
(( $+functions[__git_config_booleans] )) ||
__git_config_booleans () {
  local tag label current default description
  declare -a booleans

  zparseopts -D t=tag l=label
  current=$1
  default=${2:-true}
  description=$3
  shift 3
  booleans=(
    {true,yes,on}":$description"
    {false,no,off}":do not $description"
    $*)

  __git_config_values -t ${tag:-booleans} -l ${label:-boolean} -- "$current" $default $booleans
}

# __git_config_values [-t TAG] [-l LABEL] CURRENT DEFAULT [VALUES]...
#
# -t can be used to specify a tag to use (default: values).
# -l can be used to specify a label to use (default: value).
#
# The first argument is the current value, so that the description of the
# current value can be suffixed with " (current)".
#
# The second argument is the default value, so that the description of the
# default value can be suffixed with " (default)".
#
# The rest of the arguments are values of the form VALUE:DESCRIPTION to be
# passed to _describe.
(( $+functions[__git_config_values] )) ||
__git_config_values () {
  declare -A opts
  local current default key
  declare -a values

  zparseopts -A opts -D t: l:
  [[ $1 == -- ]] && shift
  current=$1
  default=$2
  shift 2
  values=($*)
  [[ -n $current ]] && values[(r)$(__git_pattern_escape $current):*]+=' (current)'
  values[(r)$(__git_pattern_escape $default):*]+=' (default)'

  _describe -t ${opts[-t]:-values} ${opts[-l]:-value} values
}

# Git Config Sections and Types
(( $+functions[__git_browsers] )) ||
__git_browsers () {
  local expl
  declare -a userbrowsers builtinbrowsers

  __git_config_get_regexp '^browser\..+\.cmd$' userbrowsers
  builtinbrowsers=(
    firefox
    iceweasel
    seamonkey
    iceape
    google-chrome
    chrome
    chromium
    konquerer
    opera
    w3m
    elinks
    links
    lynx
    dillo
    open
    start
    cygstart
    xdg-open)

  _alternative \
    'user-browsers:user-defined browser:compadd -a - userbrowsers' \
    'builtin-browsers:builtin browser:compadd -a - builtinbrowsers'
}

__git_worktrees () {
  local -a records=( ${(ps.\n\n.)"$(_call_program directories git worktree list --porcelain)"} )
  local -a directories descriptions
  local i hash branch
  for i in $records; do
    directories+=( ${${i%%$'\n'*}#worktree } )
    hash=${${${"${(f)i}"[2]}#HEAD }[1,9]}
    branch=${${"${(f)i}"[3]}#branch refs/heads/}

    # Simulate the non-porcelain output
    if [[ $branch == detached ]]; then
      # TODO: show a ref that points at $hash here, like vcs_info does?
      branch="(detached HEAD)"
    else
      branch="[$branch]"
    fi

    descriptions+=( "${directories[-1]}"$'\t'"$hash $branch" )
  done
  _wanted directories expl 'working tree' compadd -ld descriptions -S ' ' -f -M 'r:|/=* r:|=*' -a directories
}

(( $+functions[__git_difftools] )) ||
__git_difftools () {
  __git_diff-or-merge-tools diff $*
}

(( $+functions[__git_diff-or-merge-tools] )) ||
__git_diff-or-merge-tools () {
  local type=$1; shift
  integer ret=1
  local expl
  declare -a userdifftools usermergetools builtintools builtindifftools builtinmergetools

  [[ $type == diff ]] && __git_config_get_regexp '^difftool\..+\.cmd$' userdifftools
  __git_config_get_regexp '^mergetool\..+\.cmd$' usermergetools
  builtintools=(
    araxis
    bc
    bc3
    codecompare
    deltawalker
    diffmerge
    diffuse
    ecmerge
    emerge
    examdiff
    guiffy
    gvimdiff
    gvimdiff2
    gvimdiff3
    kdiff3
    meld
    opendiff
    p4merge
    tkdiff
    tortoisemerge
    smerge
    vimdiff
    vimdiff2
    vimdiff3
    winmerge
    xxdiff)

  builtindifftools=($builtintools kompare)
  builtinmergetools=($builtintools tortoisemerge)

  case $type in
    (diff) _tags user-difftools builtin-difftools user-mergetools ;;
    (merge) _tags user-mergetools builtin-mergetools ;;
  esac

  while _tags; do
    _requested user-difftools expl 'user-defined difftool' compadd "$@" -a - userdifftools && ret=0
    _requested user-mergetools expl 'user-defined mergetool' compadd "$@" -a - usermergetools && ret=0
    _requested builtin-difftools expl 'builtin difftool' compadd "$@" -a - builtindifftools && ret=0
    _requested builtin-mergetools expl 'builtin mergetool' compadd "$@" -a - builtinmergetools && ret=0

    (( ret )) || break
  done

  return ret
}

(( $+functions[__git_mergetools] )) ||
__git_mergetools () {
  __git_diff-or-merge-tools merge $*
}

(( $+functions[__git_merge_drivers] )) ||
__git_merge_drivers () {
  __git_config_sections '^merge\..+\.name$' merge-drivers 'merge driver' $*
}

(( $+functions[__git_builtin_merge_drivers] )) ||
__git_builtin_merge_drivers () {
  local -a builtin_merge_drivers
  builtin_merge_drivers=(
    text:'normal 3-way file-level merge for text files'
    binary:'binary file merge driver'
    union:'run 3-way file-levele merge with lines from both versions')
  _describe -t builtin-merge-drivers 'builtin merge driver' builtin_merge_drivers $*
}

(( $+functions[__git_man_viewers] )) ||
__git_man_viewers () {
  # TODO: Add support for standard commands.
  __git_config_sections '^man\..+\.cmd$' man-viewers 'man viewer' $*
}

(( $+functions[__git_svn-remotes] )) ||
__git_svn-remotes () {
  __git_config_sections -a '(|)' '^svn-remote\..+$' svn-remotes 'svn remote' $*
}

(( $+functions[__git_remote-groups] )) ||
__git_remote-groups () {
  __git_config_sections -a '(|)' '^remotes\..+$' remotes-groups 'remotes group' $*
}

(( $+functions[__git_remotes_groups] )) ||
__git_remotes_groups () {
  local expl

  _wanted remotes-groups expl 'remotes group' \
    compadd $* - ${${${(0)"$(_call_program remotes-groups git config --get-regexp -z '"^remotes\..*$"')"}%%$'\n'*}#remotes.}

}

(( $+functions[__git_sendemail_identities] )) ||
__git_sendemail_identities () {
  __git_config_sections '^sendemail\..+\.[^.]+$' identities 'sendemail identity' $*
}

(( $+functions[__git_sendemail_smtpencryption_values] )) ||
__git_sendemail_smtpencryption_values () {
  __git_config_values -- "$current" "$parts[5]" \
    ssl:'use SSL' \
    tls:'use TLS'
}

(( $+functions[__git_sendemail_confirm_values] )) ||
__git_sendemail_confirm_values () {
  __git_config_values -- "$current" "$parts[5]" \
    always:'always confirm before sending' \
    never:'never confirm before sending' \
    cc:'confirm before sending to automatically added Cc-addresses' \
    compose:'confirm before sending first message when using --compose' \
    auto:'same as cc together with compose'
}

(( $+functions[__git_sendemail_suppresscc_values] )) ||
__git_sendemail_suppresscc_values () {
  __git_config_values -- "$current" "$parts[5]" \
    author:'avoid including patch author' \
    self:'avoid including sender' \
    cc:'avoid including anyone mentioned in Cc lines except for self' \
    bodycc:'avoid including anyone mentioned in Cc lines in patch body except for self' \
    sob:'avoid including anyone mentioned in Signed-off-by lines except for self' \
    cccmd:'avoid running --cc-cmd' \
    tocmd:'avoid running --to-cmd' \
    body:'equivalent to sob + bodycc' \
    misc-by:'avoid including anyone mentioned in various "-by" lines in the patch body' \
    all:'avoid all auto Cc values'
}

(( $+functions[__git_sendmail_smtpserver_values] )) ||
__git_sendmail_smtpserver_values() {
  _alternative "hosts:smtp host:_hosts" "commands: :_absolute_command_paths"
}

(( $+functions[__git_colors] )) ||
__git_colors () {
  declare -a expl

  _wanted colors expl color compadd "$@" - \
      black red green yellow blue magenta cyan white
}

(( $+functions[__git_color_attributes] )) ||
__git_color_attributes () {
  declare -a expl

  _wanted attributes expl attribute compadd "$@" - \
      bold dim ul blink reverse
}

# Now, for the main drive...
_git() {
  if (( CURRENT > 2 )); then
    local -a aliases
    local -A git_aliases
    local a k v
    local endopt='!(-)--end-of-options'
    aliases=(${(0)"$(_call_program aliases git config -z --get-regexp '\^alias\\.')"})
    for a in ${aliases}; do
        k="${${a/$'\n'*}/alias.}"
        v="${a#*$'\n'}"
        git_aliases[$k]="$v"
    done

    if (( $+git_aliases[$words[2]] && !$+commands[git-$words[2]] && !$+functions[_git-$words[2]] )); then
      local -a tmpwords expalias
      expalias=(${(z)git_aliases[$words[2]]})
      tmpwords=(${words[1]} ${expalias})
      if [[ -n "${words[3,-1]}" ]] ; then
          tmpwords+=(${words[3,-1]})
      fi
      [[ -n ${words[$CURRENT]} ]] || tmpwords+=('')
      (( CURRENT += ${#expalias} - 1 ))
      words=("${tmpwords[@]}")
      unset tmpwords expalias
    fi

    unset git_aliases aliases
  fi

  integer ret=1

  if [[ $service == git ]]; then
    local curcontext=$curcontext state line
    declare -A opt_args

    # TODO: This needs an update
    # TODO: How do we fix -c argument?
    _arguments -C \
      '(- :)--version[display version information]' \
      '(- :)--help[display help message]' \
      '-C[run as if git was started in given path]: :_directories' \
      \*{-c,--config-env=}'[pass configuration parameter to command]: :->configuration' \
      '--exec-path=-[path containing core git-programs]:: :_directories' \
      '(: -)--man-path[print the manpath for the man pages for this version of Git and exit]' \
      '(: -)--info-path[print the path where the info files are installed and exit]' \
      '(: -)--html-path[display path to HTML documentation and exit]' \
      '(-p --paginate -P --no-pager)'{-p,--paginate}'[pipe output into a pager]' \
      '(-p --paginate -P --no-pager)'{-P,--no-pager}"[don't pipe git output into a pager]" \
      '--git-dir=[path to repository]: :_directories' \
      '--work-tree=[path to working tree]: :_directories' \
      '--namespace=[set the Git namespace]:namespace' \
      '--super-prefix=[set a prefix which gives a path from above a repository down to its root]:path:_directories' \
      '--bare[use $PWD as repository]' \
      '--no-replace-objects[do not use replacement refs to replace git objects]' \
      '--literal-pathspecs[treat pathspecs literally, rather than as glob patterns]' \
      '(-): :->command' \
      '(-)*:: :->option-or-argument' && return

    case $state in
      (command)
        _git_commands && ret=0
        ;;
      (option-or-argument)
        curcontext=${curcontext%:*:*}:git-$words[1]:
        (( $+opt_args[--git-dir] )) && local -x GIT_DIR=${(Q)${~opt_args[--git-dir]}}
        (( $+opt_args[--work-tree] )) && local -x GIT_WORK_TREE=${(Q)${~opt_args[--work-tree]}}
	if ! _call_function ret _git-$words[1]; then
	  if [[ $words[1] = \!* ]]; then
	    words[1]=${words[1]##\!}
	    _normal && ret=0
	  elif zstyle -T :completion:$curcontext: use-fallback; then
	    _default && ret=0
	  else
	    _message "unknown sub-command: $words[1]"
	  fi
        fi
        ;;
      (configuration)
        if compset -P 1 '*='; then
          __git_config_value && ret=0
        else
          if compset -S '=*'; then
            __git_config_option && ret=0 # don't move cursor if we completed just the "foo." in "foo.bar.baz=value"
            compstate[to_end]=''
          else
            __git_config_option -S '=' && ret=0
          fi
        fi
        ;;
    esac
  else
    _call_function ret _$service
  fi

  return ret
}

# Load any _git-* definitions so that they may be completed as commands.
declare -gA _git_third_party_commands
_git_third_party_commands=()

local file input
for file in ${^fpath}/_git-*~(*~|*.zwc)(-.N); do
  local name=${${file:t}#_git-}
  if (( $+_git_third_party_commands[$name] )); then
    continue
  fi

  local desc=
  integer i=1
  while read input; do
    if (( i == 2 )); then
      if [[ $input == '#description '* ]]; then
        desc=:${input#\#description }
      fi
      break
    fi
    (( i++ ))
  done < $file

  _git_third_party_commands+=([$name]=$desc)
done

_git
