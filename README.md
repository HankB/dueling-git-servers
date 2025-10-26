# Shell scripts for dueling Git servers

## Motivation

I developed this for my home lab where I have two Forgejo Git servers. One of those is the 
main" one and the other, "Experimental." It is my intent to keep them synchronized. IOW both have the same repos and the repos match. (It is understood that the contents of the `.../.git` directory may not be identical, but as long as both corresponding repos can pull to the same local repo and contain the same files outrside of `.../.git` all is well.)

I learned that when using multiple repos things do not always work the way I thought they worked, leading to unsynchronized repos. Some scripts could help manage that. 

## Plan

Produce scripts to help push, pull and audit results.

First will be scripts that push and pull from repos as these are the commands likely to lead to issues. Choosing names... To bad `push` and `pull` are already used. :-/ (Well, not pull but I want to keep these symmetric.)

```text
hbarta@olive:~/Programming/shell_scripts/git$ apt-file search -x "/gpush$"
hbarta@olive:~/Programming/shell_scripts/git$ apt-file search -x "/gpull$"
hbarta@olive:~/Programming/shell_scripts/git$
```

Identifying branches and repos seems easy enough.

```text
hbarta@olive:~/Programming/shell_scripts/git$ git branch
* master
hbarta@olive:~/Programming/shell_scripts/git$ git remote
origin
piserver
hbarta@olive:~/Programming/shell_scripts/git$ 
```

It's not even worth enshrining these in Bash functions to share (I think.) And they were near trivial to write.

The `gpush` and `gpull` scripts ar the result and are fairly generic (e.g. not specific to my home lab.)

Next is something to audit repos by pulling from each and using `diff -pq` to compare. That's a little more involved. First, get a list of repos. (Following is my rampling progress notes.) Google AI suggests:

```text
https://your-forgejo-instance.com/api/v1/users/{your-username}/repos
# which would be
http://oak:8080/api/v1/users/HankB/repos
```

That works to get ~3K lines of (formatted) JSON or 67412 characters raw that can then be parsed using `jq`.

```text
wget -q -O - http://oak:8080/api/v1/users/HankB/repos|jq ' .[] | .name'
```

```text
hbarta@olive:/tmp$ wget -q -O - http://oak:8080/api/v1/users/HankB/repos|jq ' .[] | .name'
"shell_scripts"
"pyqt5-tutorial"
"filededup"
...
hbarta@olive:/tmp$ 
```
That needed a little cleanup which was done using `sed` to strip off the quotes.

Next I need to construct the SSH URLs for the repos following the pattern `ssh://git@oak:10022/HankB/shell_scripts.git`.

Part way through testing it became clear that not all 48 repos were being returned. Help via Reddit <https://old.reddit.com/r/forgejo/comments/1ofw2a3/api_not_finding_new_repos/> guided me to the following URL:

```text
"http://oak:8080/api/v1/users/HankB/repos?limit=50"
```

*NB This URL will not return all repos if there are more than 50. My servers are at 48.*

Several iterations produced `audit-dueling-repos.sh` which

1. Identifies all repos for one server.
1. Iterates through all identified repos to pull them to different directories and compares the two copies.
1. Pulls both repos to the same directory to identify problems with merg/fast forward.

This script is very specific in that it:

* hard codes my user name.
* Hard codes the server names (and port numbers.)
* Hard codes the URL used to identify repos on a server. And for completeness, I need to edit it to use the other server and rerun.
* Not specific to my setup but noteworthy, it does not clean up following execution.
* Is intended to run on Linux.

## Opportunities for improvement

* Review the code and identify potential problem areas.
* Provide command line arguments or ENV vars to identify servers.
* Pull a list from both servers and combine them.
* Provide a list of repos to audit vs. auditing all. Or provide a list of repos to skip.
* cleanup of the README.
* PRs welcome.

## Errata

* `add-remote.sh` was coded long ago and I suppose is what got me into this issue to begin with.
* Scripts checked with `shellcheck`.
