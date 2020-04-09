### Git GUI:
- [Sourcetree | Free Git GUI for Mac and Windows](https://www.sourcetreeapp.com/)
- [TortoiseGit – Windows Shell Interface to Git](https://tortoisegit.org/)

### Delete Commit History in GitHub:
```
git checkout --orphan newBranch
git add -A 
git commit -m "First Commit"
git branch -D master  
git branch -m master  
git push -f origin master  
git gc --aggressive --prune=all
git branch --set-upstream-to=origin/master master
```
- [github - Make the current commit the only (initial) commit in a Git repository? - Stack Overflow](https://stackoverflow.com/questions/9683279/make-the-current-commit-the-only-initial-commit-in-a-git-repository/13102849#13102849)
- [git - how to delete all commit history in github? - Stack Overflow](https://stackoverflow.com/questions/13716658/how-to-delete-all-commit-history-in-github)
- [Steps to clear out the history of a git/github repository](https://gist.github.com/stephenhardy/5470814)
- [How to Delete Commit History in Github](https://tecadmin.net/delete-commit-history-in-github/)
