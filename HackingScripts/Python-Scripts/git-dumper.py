#!/usr/bin/env python3
from contextlib import closing
import argparse
import multiprocessing
import os
import os.path
import re
import socket
import subprocess
import sys
import urllib.parse
import urllib3

import bs4
import dulwich.index
import dulwich.objects
import dulwich.pack
import requests
import socks

USER_AGENT = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36"

def printf(fmt, *args, file=sys.stdout):
    if args:
        fmt = fmt % args

    file.write(fmt)
    file.flush()


def is_html(response):
    ''' Return True if the response is a HTML webpage '''
    return '<html>' in response.text


def get_indexed_files(response):
    ''' Return all the files in the directory index webpage '''
    html = bs4.BeautifulSoup(response.text, 'html.parser')
    files = []

    for link in html.find_all('a'):
        url = urllib.parse.urlparse(link.get('href'))

        if (url.path and
                url.path != '.' and
                url.path != '..' and
                not url.path.startswith('/') and
                not url.scheme and
                not url.netloc):
            files.append(url.path)

    return files


def create_intermediate_dirs(path):
    ''' Create intermediate directories, if necessary '''

    dirname, basename = os.path.split(path)

    if dirname and not os.path.exists(dirname):
        try:
            os.makedirs(dirname)
        except FileExistsError:
            pass # race condition


def get_referenced_sha1(obj_file):
    ''' Return all the referenced SHA1 in the given object file '''
    objs = []

    if isinstance(obj_file, dulwich.objects.Commit):
        objs.append(obj_file.tree.decode())

        for parent in obj_file.parents:
            objs.append(parent.decode())
    elif isinstance(obj_file, dulwich.objects.Tree):
        for item in obj_file.iteritems():
            objs.append(item.sha.decode())
    elif isinstance(obj_file, dulwich.objects.Blob):
        pass
    else:
        printf('error: unexpected object type: %r\n' % obj_file, file=sys.stderr)
        sys.exit(1)

    return objs


class Worker(multiprocessing.Process):
    ''' Worker for process_tasks '''

    def __init__(self, pending_tasks, tasks_done, args):
        super().__init__()
        self.daemon = True
        self.pending_tasks = pending_tasks
        self.tasks_done = tasks_done
        self.args = args

    def run(self):
        # initialize process
        self.init(*self.args)

        # fetch and do tasks
        while True:
            task = self.pending_tasks.get(block=True)

            if task is None: # end signal
                return

            result = self.do_task(task, *self.args)

            assert isinstance(result, list), 'do_task() should return a list of tasks'

            self.tasks_done.put(result)

    def init(self, *args):
        raise NotImplementedError

    def do_task(self, task, *args):
        raise NotImplementedError


def process_tasks(initial_tasks, worker, jobs, args=(), tasks_done=None):
    ''' Process tasks in parallel '''

    if not initial_tasks:
        return

    tasks_seen = set(tasks_done) if tasks_done else set()
    pending_tasks = multiprocessing.Queue()
    tasks_done = multiprocessing.Queue()
    num_pending_tasks = 0

    # add all initial tasks in the queue
    for task in initial_tasks:
        assert task is not None

        if task not in tasks_seen:
            pending_tasks.put(task)
            num_pending_tasks += 1
            tasks_seen.add(task)

    # initialize processes
    processes = [worker(pending_tasks, tasks_done, args) for _ in range(jobs)]

    # launch them all
    for p in processes:
        p.start()

    # collect task results
    while num_pending_tasks > 0:
        task_result = tasks_done.get(block=True)
        num_pending_tasks -= 1

        for task in task_result:
            assert task is not None

            if task not in tasks_seen:
                pending_tasks.put(task)
                num_pending_tasks += 1
                tasks_seen.add(task)

    # send termination signal (task=None)
    for _ in range(jobs):
        pending_tasks.put(None)

    # join all
    for p in processes:
        p.join()


class DownloadWorker(Worker):
    ''' Download a list of files '''

    def init(self, url, directory, retry, timeout, module=None):
        self.session = requests.Session()
        self.session.verify = False
        self.session.mount(url, requests.adapters.HTTPAdapter(max_retries=retry))
        self.module = module

    def do_task(self, filepath, url, directory, retry, timeout, module=None):
        with closing(self.session.get('%s/%s' % (url, filepath),
                                      allow_redirects=False,
                                      stream=True,
                                      timeout=timeout,
                                      headers={"User-Agent": USER_AGENT})) as response:
            printf('[-] Fetching %s/%s [%d]\n', url, filepath, response.status_code)

            if response.status_code != 200:
                return []

            abspath = os.path.abspath(os.path.join(directory, filepath))
            create_intermediate_dirs(abspath)

            # write file
            with open(abspath, 'wb') as f:
                for chunk in response.iter_content(4096):
                    f.write(chunk)

            return []


class RecursiveDownloadWorker(DownloadWorker):
    ''' Download a directory recursively '''

    def do_task(self, filepath, url, directory, retry, timeout):
        with closing(self.session.get('%s/%s' % (url, filepath),
                                      allow_redirects=False,
                                      stream=True,
                                      timeout=timeout,
                                      headers={"User-Agent": USER_AGENT})) as response:
            printf('[-] Fetching %s/%s [%d]\n', url, filepath, response.status_code)

            if (response.status_code in (301, 302) and
                    'Location' in response.headers and
                    response.headers['Location'].endswith(filepath + '/')):
                return [filepath + '/']

            if response.status_code != 200:
                return []

            if filepath.endswith('/'): # directory index
                assert is_html(response)

                return [filepath + filename for filename in get_indexed_files(response)]
            else: # file
                abspath = os.path.abspath(os.path.join(directory, filepath))
                create_intermediate_dirs(abspath)

                # write file
                with open(abspath, 'wb') as f:
                    for chunk in response.iter_content(4096):
                        f.write(chunk)

                return []


class FindRefsWorker(DownloadWorker):
    ''' Find refs/ '''

    def do_task(self, filepath, url, directory, retry, timeout, module):
        response = self.session.get('%s/%s' % (url, filepath),
                                    allow_redirects=False,
                                    timeout=timeout,
                                    headers={"User-Agent": USER_AGENT})
        printf('[-] Fetching %s/%s [%d]\n', url, filepath, response.status_code)

        if response.status_code != 200:
            return []

        abspath = os.path.abspath(os.path.join(directory, filepath))
        create_intermediate_dirs(abspath)

        # write file
        with open(abspath, 'w') as f:
            f.write(response.text)

        # find refs
        tasks = []

        # module = ".git/" if not url.endswith("/modules") else ""

        for ref in re.findall(r'(refs(/[a-zA-Z0-9\-\.\_\*]+)+)', response.text):
            ref = ref[0]
            if not ref.endswith('*'):
                tasks.append(self.module + '/%s' % ref)
                tasks.append(self.module + '/logs/%s' % ref)

        return tasks


class FindObjectsWorker(DownloadWorker):
    ''' Find objects '''

    def do_task(self, obj, url, directory, retry, timeout, module):
        # module = ".git" if not url.endswith("/modules") else ""
        filepath = '%s/objects/%s/%s' % (self.module, obj[:2], obj[2:])
        response = self.session.get('%s/%s' % (url, filepath),
                                    allow_redirects=False,
                                    timeout=timeout,
                                    headers={"User-Agent": USER_AGENT})
        printf('[-] Fetching %s/%s [%d]\n', url, filepath, response.status_code)

        if response.status_code != 200:
            return []

        abspath = os.path.abspath(os.path.join(directory, filepath))
        create_intermediate_dirs(abspath)

        # write file
        with open(abspath, 'wb') as f:
            f.write(response.content)

        # parse object file to find other objects
        obj_file = dulwich.objects.ShaFile.from_path(abspath)
        return get_referenced_sha1(obj_file)


def fetch_git(url, directory, jobs, retry, timeout, module=".git"):
    ''' Dump a git repository into the output directory '''

    assert os.path.isdir(directory), '%s is not a directory' % directory

    if module == ".git":
        assert not os.listdir(directory), '%s is not empty' % directory
    assert jobs >= 1, 'invalid number of jobs'
    assert retry >= 1, 'invalid number of retries'
    assert timeout >= 1, 'invalid timeout'

    # find base url
    if not url.startswith("http://") and not url.startswith("https://"):
        url = "http://" + url

    url = url.rstrip('/')
    if url.endswith('HEAD'):
        url = url[:-4]
    url = url.rstrip('/')
    if url.endswith('.git'):
        url = url[:-4]
    url = url.rstrip('/')

    # check for /.git/HEAD
    printf('[-] Testing %s/%s/HEAD ', url, module)
    response = requests.get('%s/%s/HEAD' % (url, module), verify=False, allow_redirects=False, headers={"User-Agent": USER_AGENT})
    printf('[%d]\n', response.status_code)

    if response.status_code != 200:
        printf('error: %s/%s/HEAD does not exist\n', url, module, file=sys.stderr)
        return 1
    # elif not response.text.startswith('ref:'):
    #     printf('error: %s/.git/HEAD is not a git HEAD file\n', url, file=sys.stderr)
    #     return 1

    # check for directory listing
    printf('[-] Testing %s/%s/ ', url, module)
    response = requests.get('%s/%s/' % (url, module), verify=False, allow_redirects=False, headers={"User-Agent": USER_AGENT})
    printf('[%d]\n', response.status_code)

    if response.status_code == 200 and is_html(response) and 'HEAD' in get_indexed_files(response):
        printf('[-] Fetching .git recursively\n')
        process_tasks(['.git/', '.gitignore'],
                      RecursiveDownloadWorker,
                      jobs,
                      args=(url, directory, retry, timeout))

        printf('[-] Running git checkout .\n')
        os.chdir(directory)
        subprocess.check_call(['git', 'checkout', '.'])
        return 0

    # no directory listing
    printf('[-] Fetching common files\n')
    tasks = [
        '.gitignore',
        module + '/COMMIT_EDITMSG',
        module + '/description',
        module + '/hooks/applypatch-msg.sample',
        module + '/hooks/applypatch-msg.sample',
        module + '/hooks/applypatch-msg.sample',
        module + '/hooks/commit-msg.sample',
        module + '/hooks/post-commit.sample',
        module + '/hooks/post-receive.sample',
        module + '/hooks/post-update.sample',
        module + '/hooks/pre-applypatch.sample',
        module + '/hooks/pre-commit.sample',
        module + '/hooks/pre-push.sample',
        module + '/hooks/pre-rebase.sample',
        module + '/hooks/pre-receive.sample',
        module + '/hooks/prepare-commit-msg.sample',
        module + '/hooks/update.sample',
        module + '/index',
        module + '/info/exclude',
        module + '/objects/info/packs',
    ]

    if module == ".git":
        tasks.insert(1, '.gitmodules')

    process_tasks(tasks,
                  DownloadWorker,
                  jobs,
                  args=(url, directory, retry, timeout, module))

    if module == ".git":
        modules_path = os.path.join(directory, '.gitmodules')
        if os.path.exists(modules_path):
            module_dir = os.path.join(directory, ".git", "modules")
            os.makedirs(os.path.abspath(module_dir))
            with open(modules_path, 'r') as f:
                modules = f.read()

                for module_name in re.findall(r'\[submodule \"(.*)\"\]', modules):
                    printf("[-] Fetching module: %s\n", module_name)
                    # os.makedirs(os.path.abspath(module_dir))
                    module_url = url + "/.git/modules"
                    fetch_git(module_url, module_dir, jobs, retry, timeout, module=module_name)
                    printf("[+] Done iterating module\n")

    # find refs
    printf('[-] Finding refs/\n')
    tasks = [
        module + '/FETCH_HEAD',
        module + '/HEAD',
        module + '/ORIG_HEAD',
        module + '/config',
        module + '/info/refs',
        module + '/logs/HEAD',
        module + '/logs/refs/heads/master',
        module + '/logs/refs/remotes/origin/HEAD',
        module + '/logs/refs/remotes/origin/master',
        module + '/logs/refs/stash',
        module + '/packed-refs',
        module + '/refs/heads/master',
        module + '/refs/remotes/origin/HEAD',
        module + '/refs/remotes/origin/master',
        module + '/refs/stash',
        module + '/refs/wip/wtree/refs/heads/master', #Magit
        module + '/refs/wip/index/refs/heads/master'  #Magit
    ]

    process_tasks(tasks,
                  FindRefsWorker,
                  jobs,
                  args=(url, directory, retry, timeout, module))

    # find packs
    printf('[-] Finding packs\n')
    tasks = []

    # use .git/objects/info/packs to find packs
    info_packs_path = os.path.join(directory, 'objects', 'info', 'packs')
    if os.path.exists(info_packs_path):
        with open(info_packs_path, 'r') as f:
            info_packs = f.read()

        for sha1 in re.findall(r'pack-([a-f0-9]{40})\.pack', info_packs):
            tasks.append(module + '/objects/pack/pack-%s.idx' % sha1)
            tasks.append(module + '/objects/pack/pack-%s.pack' % sha1)

    process_tasks(tasks,
                  DownloadWorker,
                  jobs,
                  args=(url, directory, retry, timeout))

    # find objects
    printf('[-] Finding objects\n')
    objs = set()
    packed_objs = set()

    # .git/packed-refs, .git/info/refs, .git/refs/*, .git/logs/*
    files = [
        os.path.join(directory, module, 'packed-refs'),
        os.path.join(directory, module, 'info', 'refs'),
        os.path.join(directory, module, 'FETCH_HEAD'),
        os.path.join(directory, module, 'ORIG_HEAD'),
    ]

    for dirpath, _, filenames in os.walk(os.path.join(directory, module, 'refs')):
        for filename in filenames:
            files.append(os.path.join(dirpath, filename))
    for dirpath, _, filenames in os.walk(os.path.join(directory, module, 'logs')):
        for filename in filenames:
            files.append(os.path.join(dirpath, filename))

    for filepath in files:
        if not os.path.exists(filepath):
            continue

        with open(filepath, 'r') as f:
            content = f.read()

        for obj in re.findall(r'(^|\s)([a-f0-9]{40})($|\s)', content):
            obj = obj[1]
            objs.add(obj)

    # use .git/index to find objects
    index_path = os.path.join(directory, module, 'index')
    if os.path.exists(index_path):
        index = dulwich.index.Index(index_path)

        for entry in index.iterblobs():
            objs.add(entry[1].decode())

    # use packs to find more objects to fetch, and objects that are packed
    pack_file_dir = os.path.join(directory, module, 'objects', 'pack')
    if os.path.isdir(pack_file_dir):
        for filename in os.listdir(pack_file_dir):
            if filename.startswith('pack-') and filename.endswith('.pack'):
                pack_data_path = os.path.join(pack_file_dir, filename)
                pack_idx_path = os.path.join(pack_file_dir, filename[:-5] + '.idx')
                pack_data = dulwich.pack.PackData(pack_data_path)
                pack_idx = dulwich.pack.load_pack_index(pack_idx_path)
                pack = dulwich.pack.Pack.from_objects(pack_data, pack_idx)

                for obj_file in pack.iterobjects():
                    packed_objs.add(obj_file.sha().hexdigest())
                    objs |= set(get_referenced_sha1(obj_file))

    # fetch all objects
    printf('[-] Fetching objects\n')
    process_tasks(objs,
                  FindObjectsWorker,
                  jobs,
                  args=(url, directory, retry, timeout, module),
                  tasks_done=packed_objs)

    # git checkout
    if module == ".git":
        printf('[-] Running git checkout .\n')
        os.chdir(directory)

        # ignore errors
        subprocess.call(['git', 'checkout', '.'], stderr=open(os.devnull, 'wb'))

    return 0


if __name__ == '__main__':
    parser = argparse.ArgumentParser(usage='%(prog)s [options] URL DIR',
                                     description='Dump a git repository from a website.')
    parser.add_argument('url', metavar='URL',
                        help='url')
    parser.add_argument('directory', metavar='DIR',
                        help='output directory')
    parser.add_argument('--proxy',
                        help='use the specified proxy')
    parser.add_argument('-j', '--jobs', type=int, default=10,
                        help='number of simultaneous requests')
    parser.add_argument('-r', '--retry', type=int, default=3,
                        help='number of request attempts before giving up')
    parser.add_argument('-t', '--timeout', type=int, default=3,
                        help='maximum time in seconds before giving up')
    args = parser.parse_args()

    # jobs
    if args.jobs < 1:
        parser.error('invalid number of jobs')

    # retry
    if args.retry < 1:
        parser.error('invalid number of retries')

    # timeout
    if args.timeout < 1:
        parser.error('invalid timeout')

    # proxy
    if args.proxy:
        proxy_valid = False

        for pattern, proxy_type in [
                (r'^socks5:(.*):(\d+)$', socks.PROXY_TYPE_SOCKS5),
                (r'^socks4:(.*):(\d+)$', socks.PROXY_TYPE_SOCKS4),
                (r'^http://(.*):(\d+)$', socks.PROXY_TYPE_HTTP),
                (r'^(.*):(\d+)$', socks.PROXY_TYPE_SOCKS5)]:
            m = re.match(pattern, args.proxy)
            if m:
                socks.setdefaultproxy(proxy_type, m.group(1), int(m.group(2)))
                socket.socket = socks.socksocket
                proxy_valid = True
                break

        if not proxy_valid:
            parser.error('invalid proxy')

    # output directory
    if not os.path.exists(args.directory):
        os.makedirs(args.directory)

    if not os.path.isdir(args.directory):
        parser.error('%s is not a directory' % args.directory)

    if os.listdir(args.directory):
        parser.error('%s is not empty' % args.directory)

    urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

    # fetch everything
    path = os.path.realpath(args.directory)
    code = fetch_git(args.url, args.directory, args.jobs, args.retry, args.timeout)
    if not os.listdir(path):
        os.rmdir(path)

    sys.exit(code)
