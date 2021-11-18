# Spitfire Audio vcpkg registry

This is a registry for vcpkg using custom ports

# Adding a custom port
1. Copy files from existing port in vcpkg
2. Make changes
3. Update port version number in vcpkg.json
4. Copy over versions JSON 
5. Add Entry to baseline.json
6. Commit changes but don't push
7. Run `git rev-parse HEAD:ports/PORT_NAME/` to get the git commit
8. Paste commit SHA in to baseline.json
9. Amend previous commit with newly updated versions/FIRST_LETTER/PORT_NAME.json