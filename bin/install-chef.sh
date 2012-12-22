SELF_PATH=$(cd -P -- "$(dirname -- "$0")" && pwd -P) && SELF_PATH=$SELF_PATH/$(basename -- "$0")
echo $SELF_PATH

bin_dir=$(dirname $SELF_PATH)

remote=$1

cat $bin_dir/install-chef-script.sh | ssh root@$remote "cat | bash "
