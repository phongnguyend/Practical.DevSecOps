### Git Basic
- Stages of a File:
  + Untracked
  + Ignored
  + Tracked
    + Staged (New file)
    + Committed
    + Modified/ Deleted
    + Staged (Modified/ Deleted)
- Commands:
  ```
  git add .
  git add <file_name>
  git status
  git status --short
  git log
  git log --oneline
  git log --graph --oneline
  git log --stat
  git commit -m "<message>"
  git push
  git pull
  git pull --rebase
  ```
- The 4 Areas of a Git Project:
  + Working Directory
  + Stash
  + Staging (Index)
  + Repostiory
  
### Git Branching:
- https://git-school.github.io/visualizing-git/
- https://nvie.com/posts/a-successful-git-branching-model/
- List:
  ```
  git branch
  ```
- Create:
  ```
  git branch <branch_name>
  ```
- Checkout:
  ```
  git checkout <branch_name/commit>
  ```
- Create & Checkout:
  ```
  git checkout -b <branch_name>
  ```
- Create from a specific Tag:
  ```
  git branch <branch_name> <tag_name>
  ```  
- Create from a specific Commit:
  ```
  git branch <branch_name> <commit>
  ```  
- Push:
  ```
  git push -u origin <branch_name>
  ```
- Rename:
  ```
  git branch -m <newname>
  git branch -m <oldname> <newname>
  
  git push origin :<oldname> <newname>
  git checkout <newname>
  git push origin -u <newname>
  ```
- Compare
  ```
  git diff
  git diff --cached
  git diff <branch/commit/HEAD> <branch/commit/HEAD>
  ```
- Merge
  ```
  // merge other commits from <branch_name> into <master>,
  // an extra commit with 2 parents will be created in <master>.
  git checkout <master>
  git merge <branch_name>
  ```
- Copy & Replay a specific commit
  ```
  git checkout master
  git cherry-pick <commit>
  ```
- Reset
  ```
  git reset --soft <branch/commit/HEAD>
  git reset --mixed <branch/commit/HEAD>
  git reset --hard <branch/commit/HEAD>
  ```
- Delete
  ```
  git branch -d <branch_name>
  ```
- Rebase
  ```
  // merge other commits from <master> into <branch_name>,
  // in that branch, replay the commits on top of <master> commits.
  git checkout <branch_name>
  git rebase <master>
  ```
- Create a Tag
  ```
  git tag <tag_name>
  ```  
- Common Practices: 
  + Create & Checkout Feature Branch
  + Commit, Commit, ...
  + Squash Commits & Rebase Master
  + Checkout Master & Merge Feature Branch
  + Delete Feature Branch. 
  
### Install Git on Windows:
- https://git-scm.com/download/win
  ```
  git --version
  git --help
  git --help config
  ```
- Push an existing Repository
  ```
  git init
  git remote add origin 'git_url'
  git push -u origin master

- Clone a remote Repository
  ```
  git clone <git_url>
  git remote -v
  ``````
- Git Configuration
  ```
  git config --list
  git config --list --show-origin
  ```
- https://stackoverflow.com/questions/44549733/how-to-use-visual-studio-code-as-the-default-editor-for-git-mergetool

### Git GUI:
- [Sourcetree | Free Git GUI for Mac and Windows](https://www.sourcetreeapp.com/)
- [TortoiseGit – Windows Shell Interface to Git](https://tortoisegit.org/)
- [Git in Visual Studio](https://azuredevopslabs.com/labs/devopsserver/github/)

### VS Code Extensions:
- [GitLens — Git supercharged](https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens)
- [Git History](https://marketplace.visualstudio.com/items?itemName=donjayamanne.githistory)

### Advanced Git Techniques
- Git Attributes
- Submodules
- Git Hooks
- Custom Git Commands
- Git Bisect

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
