# DANISH ARMY TMP MANAGER

## GitHub online update setup

This package keeps the existing manager features and adds **8. CHECK FOR UPDATES** at the end of the main menu.

Before publishing to your existing GitHub repository:

1. Open `danish-army-manager.sh`, `install.sh`, and `update.sh`.
2. In each file, set the GitHub owner and repository name to your existing repository.
   - In the manager script: `GITHUB_OWNER` and `GITHUB_REPO`
   - In install/update scripts: `OWNER` and `REPO`
3. Keep all three files and `VERSION` in the repository root on the `main` branch.
4. Upload the updated `danish-army-manager.sh` and `VERSION` to that same repository.
5. The `VERSION` file must match `APP_VERSION` inside the manager script (currently `1.0.1`).

## Existing users

Users who already installed the older manager do not gain the new menu option automatically. They must run the repository's updated `update.sh` once, or run the updated `install.sh` once, to install the new manager. After that, they can use **8. CHECK FOR UPDATES** for future releases.

For every future release, increase the version in both places, upload the new manager script and VERSION to the same branch, and keep the filenames unchanged.

## Notes

- The updater downloads only `danish-army-manager.sh`; it does not replace the panel/driver repositories or other user files.
- The downloaded shell script is checked with `bash -n` before installation, and the previous installed script is backed up until installation succeeds.
- The updater needs internet access and `curl`.
- Review changes to scripts before publishing or running them, especially because this manager includes root-required file operations.
