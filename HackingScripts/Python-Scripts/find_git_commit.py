#!/usr/bin/env python3

import argparse
import re
import os
import tempfile
import subprocess
import collections
import shutil
import hashlib
import datetime

PROC_ENV = { "LC_ALL": "C" }

def run_cmd(cmd, dir=None, raw=False):
    proc = subprocess.Popen(cmd, cwd=dir, env=PROC_ENV, stderr=subprocess.PIPE, stdout=subprocess.PIPE)
    out = b"".join(proc.communicate())

    if not raw:
        out = out.decode().strip()

    exit_code =  proc.returncode
    return exit_code, out


def check_git_dir(dir):
    exit_code, out = run_cmd(["git", "status"], dir)
    if "not a git repository" in out:
        print("[-] Given directory is not a git repository.")
        return False
    elif "Your branch is up to date" not in out \
         or "nothing to commit, working tree clean" not in out:
        print("[-] Git repository is not in a clean state, please reset it to HEAD")
        return False
    elif exit_code != 0:
        print("[-] Error checking given directory:", out)
        return False
    else:
        return True


def git_clone(dir, url):
    print(f"[ ] Cloning {url} to {dir}")
    exit_code, out = run_cmd(["git", "clone", url, dir, "-q"])
    if exit_code != 0:
        print("[-] Error cloing git repository:")
        print(out)
        return False
    return True


def check_input_dir(dir):
    if not os.path.isdir(dir):
        print("[-] Invalid directory:", dir)
        return False

    if os.path.isdir(os.path.join(dir, ".git")):
        print("[-] Directory to check should not be a git repository")
        return False

    valid_files = []
    real_root = os.path.realpath(dir)
    for root, subdirs, files in os.walk(dir):
        for file in files:
            full_path = os.path.realpath(os.path.join(root, file))
            file_size = os.path.getsize(full_path)
            if file_size > 0:
                relative_path = full_path[len(real_root) + 1:]
                valid_files.append(relative_path)
    
    if len(valid_files) == 0:
        print("[-] Given directory does not contain any non-empty files")
        return False

    return valid_files


def get_commits_for_file(file, git_dir):
    cmd = ["git","log","--no-color", "--pretty=format:%H %at", "--all","--", file]
    exit_code, out = run_cmd(cmd, git_dir)
    if exit_code != 0:
        print("[-] git-log failed:", out)
        return None
    else:
        lines = out.split("\n")
        commits = collections.OrderedDict()
        for line in lines:
            if line:
                data = line.split(" ")
                hash, ts = line.split(" ")
                commits[hash] = int(ts) 

        return commits
        
def hash(data, alg):
    h = hashlib.new(alg)
    h.update(data)
    return h.hexdigest()

def read_file(file):
    with open(file, "rb") as f:
        return f.read()

def find_newest_commit(git_dir, file_name, sha1hash, md5hash, commits):
    for commit_hash in reversed(commits.keys()):
        cmd = ["git", "show", f"{commit_hash}:{file_name}"]
        exit_code, out = run_cmd(cmd, git_dir, raw=True)
        if exit_code != 0:
            print("[-] git-show failed:", out)
            return None
        elif sha1hash == hash(out, "sha1") and md5hash == hash(out, "md5"):
            return commit_hash
    return None

def get_commit_message(dir, commit_hash):
    cmd = ["git","log","--no-color", "--pretty=format:%B", "-n1", commit_hash]
    exit_code, out = run_cmd(cmd, dir)
    if exit_code != 0:
        print("[-] git-log failed:", out)
        return None
    else:
        return out

def run(files, root_dir, git_dir):

    latest_commit = None
    latest_ts = None

    for f in files:
        commits = get_commits_for_file(f, git_dir)
        if commits:
            print(f"[+] {f} found in git history")
            sha1hash = hash(read_file(os.path.join(root_dir, f)), "sha1")
            md5hash  = hash(read_file(os.path.join(root_dir, f)), "md5")
            found_commit = find_newest_commit(git_dir, f, sha1hash, md5hash, commits)
            if found_commit:
                print(f"[+] Commit {found_commit} matches")
                if latest_commit is None or commits[found_commit] > latest_ts:
                    latest_commit = found_commit
                    latest_ts = commits[found_commit]
        else:
            print(f"[-] {f} not found in git history")

    if latest_commit is None:
        print("[-] No matching commit found")
    else:
        title = get_commit_message(git_dir, latest_commit)
        formatted_dt = datetime.datetime.fromtimestamp(latest_ts).strftime("%A, %d. %B %Y %I:%M%p")
        print(f"[+] Commit might be: {latest_commit}, {formatted_dt}, {title}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        dest="dir",
        help="The directory containing downloaded files"
    )
    parser.add_argument(
        dest="git",
        help="URL or path to git repository to compare to"
    )
    parser.add_argument(
        "-n",
        "--no-delete",
        dest="nodelete",
        action="store_true",
        help="Don't delete the git directory after cloning"
    )

    is_remote_git = False
    args = parser.parse_args()
    git_dir = args.git
    if re.match("^(git|https?)://.*", args.git) or \
         (len(args.git.split(":")) == 2 and "@" in args.git.split(":")[0]):
        git_dir = tempfile.TemporaryDirectory(suffix=".git").name
        is_remote_git = True
        if not git_clone(git_dir, args.git):
            exit(1)
    
    if check_git_dir(git_dir):
        valid_files = check_input_dir(args.dir)
        if valid_files != False:
            run(valid_files, args.dir, git_dir)

    if is_remote_git and not args.nodelete:
        shutil.rmtree(git_dir)
