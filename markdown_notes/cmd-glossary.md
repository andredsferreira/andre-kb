```bash
# Git 

git add -A
git commit -m "Message"
git push

git status
git log --oneline

git branch -a
git branch branch-name
git switch branch-name
git switch -c branch-name
git branch -d branch-name
git branch -D branch-name
git merge branch-name
git pull origin branch-name
git push origin branch-name
git push origin --delete branch-name

git reset --soft HEAD~1
git reset --mixed HEAD~1
git reset --hard HEAD~1

# Process control

ps aux
pgrep process_name

kill [-signal] pid
pkill process_name

# DNS

dig example.com
dig example.com any
dig example.com +trace
dig example.com +noall +answer
dig example.com +noall +auth
dig example.com any +trace
```