# Dump activity of an app given its apk 
# Ref: http://stackoverflow.com/questions/6547703/list-all-activities-within-an-apk-from-the-shell
cd android-sdk-macosx/build-tools/23.0.0
aapt dump xmltree <apk-file> AndroidManifest.xml
