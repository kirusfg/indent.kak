# Indent
# Public commands: ["set-indent", "detect-indent", "enable-detect-indent", "disable-detect-indent", "enable-auto-indent", "disable-auto-indent"]

define-command -override set-indent -params 2 -docstring 'set-indent <scope> <width>: set indent in <scope> to <width>' %{
  set-option %arg{1} tabstop %arg{2}
  set-option %arg{1} indentwidth %arg{2}
}

define-command -override detect-indent -docstring 'detect indent' %{
  try %{
    evaluate-commands -draft %{
      # Search the first indent level
      execute-keys 'gg/^\h+<ret>'

      # Tabs vs. Spaces
      # https://youtu.be/V7PLxL8jIl8
      try %{
        execute-keys '<a-k>\t<ret>'
        # Global scope
        unset-option buffer tabstop
        set-option buffer tabstop %opt{tabstop}
        set-option buffer indentwidth 0
      } catch %{
        set-option buffer tabstop %val{selection_length}
        set-option buffer indentwidth %val{selection_length}
      }
    }
  }
}

define-command -override enable-detect-indent -docstring 'enable detect indent' %{
  remove-hooks global detect-indent
  hook -group detect-indent global BufOpenFile '.*' detect-indent
  hook -group detect-indent global BufWritePost '.*' detect-indent
}

define-command -override disable-detect-indent -docstring 'disable detect indent' %{
  remove-hooks global detect-indent
  evaluate-commands -buffer '*' %{
    unset-option buffer tabstop
    unset-option buffer indentwidth
  }
}

define-command -override enable-auto-indent -docstring 'enable auto-indent' %{
  remove-hooks global auto-indent
  hook -group auto-indent global InsertChar '\n' %{
    evaluate-commands -draft -itersel %{
      # Copy previous line indent
      try %[ execute-keys -draft 'K<a-&>' ]
      # Clean previous line indent
      try %[ execute-keys -draft 'k<a-x>s^\h+$<ret>d' ]
    }
  }

  # Disable other indent hooks:
  # https://github.com/mawww/kakoune/tree/master/rc/filetype
  set-option global disabled_hooks '(?!auto)(?!detect)\K(.+)-(trim-indent|insert|indent)'

  # Mappings
  # Increase and decrease indent with Tab.
  map -docstring 'Increase indent' global insert <tab> '<a-;><a-gt>'
  map -docstring 'Decrease indent' global insert <s-tab> '<a-;><lt>'
}

define-command -override disable-auto-indent -docstring 'disable auto-indent' %{
  remove-hooks global auto-indent
  set-option global disabled_hooks ''
  unmap global insert <tab>
  unmap global insert <s-tab>
}
