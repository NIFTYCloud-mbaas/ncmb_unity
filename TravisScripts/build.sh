# Set project path
project_path=$(pwd)/ncmb_unity
# Log file path
log_file=$(pwd)/TravisScripts/unity_build.log

error_code=0

echo "* Building project for Mac OS."
/Applications/Unity/Unity.app/Contents/MacOS/Unity \
  -batchmode \
  -nographics \
  -silent-crashes \
  -logFile "$log_file" \
  -projectPath "$project_path" \
  -quit
if [ $? = 0 ] ; then
  echo "* Building Mac OS completed successfully."
  error_code=0
else
  echo "* Building Mac OS failed. Exited with $?."
  error_code=1
fi
echo "* Unity build log"
cat $log_file 

test_result_file=$(pwd)/TravisScripts/test_runner_result.xml
echo "* Execute Test Runner"
/Applications/Unity/Unity.app/Contents/MacOS/Unity \
-runTests \
-projectPath "$project_path" \
-testResults "$test_result_file" \
-testPlatform editmode

echo '* Test Runner result'
cat $test_result_file 

total=$(echo 'cat //test-run/@total' | xmllint --shell $test_result_file | awk -F\" 'NR % 2 == 0 { print $2 }')
passed=$(echo 'cat //test-run/@passed' | xmllint --shell $test_result_file | awk -F\" 'NR % 2 == 0 { print $2 }')
failed=$(echo 'cat //test-run/@failed' | xmllint --shell $test_result_file | awk -F\" 'NR % 2 == 0 { print $2 }')

echo "Total:$total  Passed:$passed Failed:$failed" 

if [ $failed > 0 ] ; then
  error_code=2
fi

echo "* Finishing with code $error_code"
exit $error_code


