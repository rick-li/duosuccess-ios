#!/bin/sh
if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then
  echo "This is a pull request. No deployment will be done."
  exit 0
fi
if [[ "$TRAVIS_BRANCH" != "master" ]]; then
  echo "Testing on a branch other than master. No deployment will be done."
  exit 0
fi

PROVISIONING_PROFILE="$HOME/Library/MobileDevice/Provisioning Profiles/$PROFILE_NAME.mobileprovision"
OUTPUTDIR="$PWD/build/Release-iphoneos"

xcrun -log -sdk iphoneos PackageApplication "$OUTPUTDIR/$APP_NAME.app" -o "$OUTPUTDIR/$APP_NAME.ipa" -sign "$DEVELOPER_NAME" -embed "$PROVISIONING_PROFILE"


zip -r -9 "$OUTPUTDIR/$APP_NAME.app.dSYM.zip" "$OUTPUTDIR/$APP_NAME.app.dSYM"

RELEASE_DATE=`date '+%Y-%m-%d %H:%M:%S'`
RELEASE_NOTES="Build: $TRAVIS_BUILD_NUMBER\nUploaded: $RELEASE_DATE"

#use firapp instead
curl http://bcs.duapp.com/apphost1/com.duosuccess.duosuccess.ipa?sign=MBO:08fadd5a7e397b10f4599c325ee55b9c:2tRiqUpGjY2lQP8zTnZEoATSE6k%3D \
    -T "@$OUTPUTDIR/$APP_NAME.ipa" 

curl http://firapp.duapp.com/api/finish \
    -F appid="com.duosuccess.duosuccess" \
    -F short="8eF" \
    -F version="Build $TRAVIS_BUILD_NUMBER $RELEASE_DATE"

#if [ ! -z "$TESTFLIGHT_TEAM_TOKEN" ] && [ ! -z "$TESTFLIGHT_API_TOKEN" ]; then
#  echo ""
#  echo "***************************"
#  echo "* Uploading to Testflight *"
#  echo "***************************"
#  curl http://testflightapp.com/api/builds.json \
#    -F file="@$OUTPUTDIR/$APP_NAME.ipa" \
#    -F dsym="@$OUTPUTDIR/$APP_NAME.app.dSYM.zip" \
#    -F api_token="$TESTFLIGHT_API_TOKEN" \
#    -F team_token="$TESTFLIGHT_TEAM_TOKEN" \
#    -F distribution_lists='Internal' \
#    -F notes="$RELEASE_NOTES"
#fi