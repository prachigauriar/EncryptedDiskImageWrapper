# EncryptedDiskImageWrapper

An experiment to see how to implement a file format that uses a Mac OS X encrypted disk image to store data securely. The code is instructive if you want to see how to use Mac OS X’s CommonCrypto libraries to store usernames and (salted/hashed) passwords securely.

The code is fairly simple: PGEncryptedDiskImageWrapper basically creates a directory that contains a user table (UserTable.plist) and an encrypted disk image (EncryptedDiskImage.sparsebundle). UserTable.plist contains a list of users and some metadata necessary to decrypt the disk image.

If you want to do something like this in a real project, you should not use a property list to store user data. Instead, use something like a SQLite store to enable concurrent data access. Property lists work fine for this little prototype though. Take note that the encrypted disk image wrapper would need to be protected using file system security so that the user table data wouldn’t be accessible to prying eyes.

All code is licensed under the MIT license. Do with it as you will.
