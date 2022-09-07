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
  git pull --rebase=preserve
  ```
- The 4 Areas of a Git Project:
  + Working Directory
  + Stash
  + Staging (Index)
  + Repostiory
  
### Git Branching:
- https://git-school.github.io/visualizing-git/
- [Git Flow](https://nvie.com/posts/a-successful-git-branching-model/) vs [GitHub Flow](https://guides.github.com/introduction/flow/)
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
- https://stackoverflow.com/questions/2114111/where-does-git-config-global-get-write-to
- Configure Notepad++ as Editor:
  ```
  git config --global core.editor "'C:/Program Files/Notepad++/notepad++.exe' -multiInst -notabbar -nosession -noPlugin"
  ```
- https://stackoverflow.com/questions/44549733/how-to-use-visual-studio-code-as-the-default-editor-for-git-mergetool

### Git GUI:
- [Sourcetree | Free Git GUI for Mac and Windows](https://www.sourcetreeapp.com/)
- [TortoiseGit – Windows Shell Interface to Git](https://tortoisegit.org/)
- [Git in Visual Studio](https://azuredevopslabs.com/labs/devopsserver/github/)
  + [Git settings and preferences in Visual Studio](https://docs.microsoft.com/en-us/visualstudio/version-control/git-settings?view=vs-2019)
    + [Rebase local branch when pulling](https://docs.microsoft.com/en-us/visualstudio/version-control/git-settings?view=vs-2019#rebase-local-branch-when-pulling)
      + `git pull` vs `git pull --rebase` vs `git pull --rebase=preserve`
      + https://megakemp.com/2019/03/20/the-case-for-pull-rebase/
      + https://stackoverflow.com/questions/21364636/git-pull-rebase-preserve-merges
    + [Prune remote branches during fetch](https://docs.microsoft.com/en-us/visualstudio/version-control/git-settings?view=vs-2019#prune-remote-branches-during-fetch)
- [Git in Visual Studio Code](https://code.visualstudio.com/docs/editor/versioncontrol#_git-support)
- [GitHub Desktop](https://desktop.github.com/)

### Visual Studio Code Extensions:
- [GitLens — Git supercharged](https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens)
- [Git History](https://marketplace.visualstudio.com/items?itemName=donjayamanne.githistory)

### Visual Studio Extensions:
- [GitFlow for Visual Studio 2019](https://marketplace.visualstudio.com/items?itemName=vs-publisher-57624.GitFlowforVisualStudio2019)
- [Pull Requests for Visual Studio](https://marketplace.visualstudio.com/items?itemName=VSIDEVersionControlMSFT.pr4vs&ssr=false)
- [GitHub Extension for Visual Studio](https://marketplace.visualstudio.com/items?itemName=GitHub.GitHubExtensionforVisualStudio)

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

### [Syncing a Fork](https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/syncing-a-fork)
```
git remote -v
git remote add upstream https://github.com/ORIGINAL_OWNER/ORIGINAL_REPOSITORY.git
git remote -v
git fetch upstream
git checkout main
git merge upstream/main
```

### Reorder Commits:
- [git - Reordering of commits - Stack Overflow](https://stackoverflow.com/questions/2740537/reordering-of-commits)
- [How to reorder last two commits in git? - Stack Overflow](https://stackoverflow.com/questions/33388210/how-to-reorder-last-two-commits-in-git)

### GitHub:
- Reference Issue/Pull Request in comment/ commit message: #Id

### Azure DevOps:
- Reference Work Item in comment/ commit message: #Id
- Reference Pull Request in comment/ commit message: !Id

### Git Internals:
- [Git's database internals I: packed object store | The GitHub Blog](https://github.blog/2022-08-29-gits-database-internals-i-packed-object-store/)
- [Git's database internals II: commit history queries | The GitHub Blog](https://github.blog/2022-08-30-gits-database-internals-ii-commit-history-queries/)
- [Git's database internals III: file history queries | The GitHub Blog](https://github.blog/2022-08-31-gits-database-internals-iii-file-history-queries/)
- [Git's database internals IV: distributed synchronization | The GitHub Blog](https://github.blog/2022-09-01-gits-database-internals-iv-distributed-synchronization/)
- [Git's database internals V: scalability | The GitHub Blog](https://github.blog/2022-09-02-gits-database-internals-v-scalability/)
