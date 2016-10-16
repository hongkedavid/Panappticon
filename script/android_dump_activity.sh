# Dump activity of an app given its APK
# Ref: http://stackoverflow.com/questions/6547703/list-all-activities-within-an-apk-from-the-shell
cd android-sdk-macosx/build-tools/23.0.0
./aapt dump xmltree <apk-file> AndroidManifest.xml

# Get the main activity of an app given its APK
# Ref: http://stackoverflow.com/questions/15497672/how-to-find-main-activity-in-apk-file-for-robotium-tests
./aapt dump badging <apk-file>
