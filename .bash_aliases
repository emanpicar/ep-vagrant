alias gowd="cd /usr/local/src/projects"

# Delete all untagged <none> Docker images
case $OSTYPE in
  darwin*|*bsd*|*BSD*)
    alias drminone='docker images -q -f dangling=true | xargs docker rmi'
    ;;
  *)
    alias drminone='docker images -q -f dangling=true | xargs -r docker rmi'
    ;;
esac
