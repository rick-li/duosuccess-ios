#!/bin/sh
openssl aes-256-cbc -k "$ENCRYPTION_SECRET" -in scripts/profile/duosucessdistribute.mobileprovision.enc -d -a -out scripts/profile/duosucessdistribute.mobileprovision
openssl aes-256-cbc -k "$ENCRYPTION_SECRET" -in scripts/certs/dist.enc -d -a -out scripts/certs/dist.cer
openssl aes-256-cbc -k "$ENCRYPTION_SECRET" -in scripts/certs/dist.p12.enc -d -a -out scripts/certs/dist.p12

security create-keychain -p travis ios-build.keychain
security import ./scripts/certs/apple.cer -k ~/Library/Keychains/ios-build.keychain -T /usr/bin/codesign
security import ./scripts/certs/dist.cer -k ~/Library/Keychains/ios-build.keychain -T /usr/bin/codesign
security import ./scripts/certs/dist.p12 -k ~/Library/Keychains/ios-build.keychain -P $KEY_PASSWORD -T /usr/bin/codesign
mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
cp ./scripts/profile/$PROFILE_NAME.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/
