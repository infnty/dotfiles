set -eu -o pipefail
umask 077

if ! [[ -f "$HOME/.dotfiles/setup.sh" ]]; then
  echo "Error: dotfiles must be installed in ~/.dotfiles"
  exit 1
fi

# Common setup vars
if [[ -f ~/.dotfiles/setup.vars ]]; then
  source ~/.dotfiles/setup.vars
fi
if [[ -f ~/.private/setup.vars ]]; then
  source ~/.private/setup.vars
fi
export SCM_NAME=${SCM_NAME:-$(whoami)}
export SCM_EMAIL=${SCM_EMAIL:-$(whoami)@$(hostname -s)}


# setup_gen [--backup] [-c|--check] <generated source file> <destination path>
#   --backup: back up destination file with .bak suffix
#   --check: check for "# Autogenerated" marker, do not overwrite if missing
setup_gen() {
  local check=0
  local backup=0
  while [[ $# > 2 ]]; do
    case "$1" in
      -c|--check) check=1;;
      --backup) backup=1;;
    esac
    shift
  done

  local dst="$2"
  local tmp="$(basename -- "$dst").tmp"
  cat "$1" >"$tmp"

  if ((check)) && [[ -s "$dst" ]] &&
     ! grep -q '^# Autogenerated' "$dst"; then
    echo "Ignoring $dst - local version"
    rm -f "$tmp"
    return
  fi

  if [[ -s "$dst" ]] && grep -q "^# Local changes" "$dst"; then
    grep -A 10000 "^# Local changes" "$dst" >>"$tmp"
  fi

  if [[ -L "$dst" ]]; then
    rm -f "$dst"
  fi

  if ! cmp --silent "$dst" "$tmp"; then
    echo "Generated $dst"
    local dstdir=$(dirname -- "$dst")
    if ! [[ -d "$dstdir" ]]; then
      mkdir -p "$dstdir"
    fi
    if ((backup)) && [[ -f "$dst" ]]; then
      echo "Backed up $dst to $dst.bak"
      mv -f "$dst" "$dst.bak"
    fi
    mv -f "$tmp" "$dst"
  else
    rm -f "$tmp"
  fi
}

ln_sr() {
  if [[ "$OSTYPE" == darwin* ]]; then
    if hash gln >/dev/null 2>&1; then
      gln -s -r "$@"
    else
      ln -s "$@"
    fi
  else
    ln -s -r "$@"
  fi
}

link_or_copy() {
  local op="$1"; shift
  if [[ "$OSTYPE" == darwin* ]]; then
    local src_path=$HOME/.dotfiles/"$1"
  else
    local src_path=$(cd ~/.dotfiles; readlink -f "$1")
  fi
  local dst_path="${2:-$HOME/.$(basename "$1")}"

  local dst_dir="$(dirname "$dst_path")"
  if ! [[ -d "$dst_dir" ]]; then
    mkdir -p -m 0700 "$dst_dir"
    echo "Created $dst_dir"
  fi

  if ! [[ -e "$src_path" ]]; then
    echo "Error: $src_path doesn't exist"
    exit 1
  fi

  if [[ "$op" == "copy" ]]; then
    if realpath -- "$dst_dir" | grep -q dotfiles; then
      echo "Error: $dst_dir is symlinking inside ~/.dotfiles/"
      exit 1
    fi

    if [[ -L "$dst_path" ]]; then
      rm -f "$dst_path"
      cp -a "$src_path" "$dst_path"
      echo "Copied $src_path over symlink $dst_path"
    elif ! [[ -f "$dst_path" ]]; then
      cp -af "$src_path" "$dst_path"
      echo "Copied $src_path to $dst_path"
    elif ! cmp --silent "$src_path" "$dst_path"; then
      cp -af "$src_path" "$dst_path"
      echo "Copied $src_path over existing file $dst_path"
    fi
    return
  fi

  if [[ "$op" == "link" ]]; then
    if [[ -e "$dst_path" ]]; then
      if [[ "$src_path" -ef "$dst_path" ]]; then
        return 0
      elif [[ -d "$dst_path" ]]; then
        rm -rf "$dst_path"
        ln_sr "$src_path" "$dst_path"
        echo "Replaced directory: $dst_path -> $src_path";
      else
        rm -f "$dst_path"
        ln_sr "$src_path" "$dst_path"
        echo "Replaced: $dst_path -> $src_path"
      fi
    elif [[ -L "$dst_path" ]]; then
      rm -f "$dst_path"
      ln_sr "$src_path" "$dst_path"
      echo "Fixed broken link: $dst_path -> $src_path"
    else
      ln_sr "$src_path" "$dst_path"
      echo "Linked: $dst_path -> $src_path"
    fi
    return
  fi
}

setup_ln() { link_or_copy link "$@"; }
setup_cp() { link_or_copy copy "$@"; }

remove_dotfiles_symlinks() {
  for f in "$@"; do
    if [[ -L "$f" ]] && (readlink -f -- "$f" | fgrep -q /.dotfiles/); then
      rm -rf "$f"
      echo "Removed obsolete symlink $f"
    fi
  done
}
