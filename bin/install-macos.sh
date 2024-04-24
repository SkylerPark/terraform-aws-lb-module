### MAC Install
echo "Package Install"
echo "Package pre-commit, tfenv, terraform-docs, jq, tflint, tfsec"
package_list="pre-commit tfenv terraform-docs jq tflint tfsec"

for package in $package_list; do
    check_package=`brew list | grep $package`
    if [ -z "check_package" ]; then
        echo "brew install $package"
        brew install $package
    fi
done
