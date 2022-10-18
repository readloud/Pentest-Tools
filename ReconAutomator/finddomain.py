#!/usr/bin/env python3

import sys, getopt, subprocess, re, time
from itertools import product, repeat, dropwhile

tlds = ['biz', 'cat',
        'com', 'int',
        'net', 'org',
        'pro', 'tel',
        'xxx',
 
        # Country code
        'ac', 'ad', 'ae', 'af',
        'ag', 'ai', 'al', 'am',
        'an', 'ao', 'aq', 'ar',
        'as', 'at', 'au', 'aw',
        'ax', 'az', 'ba', 'bb',
        'bd', 'be', 'bf', 'bg',
        'bh', 'bi', 'bj', 'bm',
        'bn', 'bo', 'br', 'bs',
        'bt', 'bv', 'bw', 'by',
        'bz', 'ca', 'cc', 'cd',
        'cf', 'cg', 'ch', 'ci',
        'ck', 'cl', 'cm', 'cn',
        'co', 'cr', 'cs', 'cu',
        'cv', 'cx', 'cy', 'cz',
        'dd', 'de', 'dj', 'dk',
        'dm', 'do', 'dz', 'ec',
        'ee', 'eg', 'eh', 'er',
        'es', 'et', 'eu', 'fi',
        'fj', 'fk', 'fm', 'fo',
        'fr', 'ga', 'gd', 'ge',
        'gf', 'gg', 'gh', 'gi',
        'gl', 'gm', 'gn', 'gp',
        'gq', 'gr', 'gs', 'gt',
        'gu', 'gw', 'gy', 'hk',
        'hm', 'hn', 'hr', 'ht',
        'hu', 'id', 'ie', 'il',
        'im', 'in', 'io', 'iq',
        'ir', 'is', 'it', 'je',
        'jm', 'jo', 'jq', 'ke',
        'kg', 'kh', 'ki', 'km',
        'kn', 'kp', 'kr', 'kw',
        'ky', 'kz', 'la', 'lb',
        'lc', 'li', 'lk', 'lr',
        'ls', 'lt', 'lu', 'lv',
        'ly', 'ma', 'mc', 'mc',
        'md', 'me', 'mg', 'mh',
        'mk', 'ml', 'mm', 'mn',
        'mo', 'mp', 'mr', 'ms',
        'mt', 'mu', 'mv', 'mv',
        'mw', 'mx', 'my', 'mz',
        'na', 'nc', 'ne', 'nf',
        'ng', 'ni', 'nl', 'no',
        'np', 'np', 'nr', 'nu',
        'nz', 'om', 'pa', 'pe',
        'pf', 'pg', 'ph', 'pk',
        'pl', 'pm', 'pm', 'pn',
        'pr', 'ps', 'pt', 'pw',
        'py', 'qa', 're', 'ro',
        're', 'rs', 'ru', 'rw',
        'sa', 'sb', 'sc', 'sd',
        'se', 'sg', 'sh', 'si',
        'sj', 'sk', 'sl', 'sm',
        'sn', 'so', 'sr', 'ss',
        'st', 'su', 'sv', 'sx',
        'sy', 'sz', 'tc', 'td',
        'tf', 'tg', 'th', 'tj',
        'tk', 'tl', 'tm', 'tn',
        'to', 'tp', 'tr', 'tt',
        'tv', 'tw', 'ua', 'ug',
        'uk', 'us', 'uy', 'uz',
        'va', 'va', 'vc', 've',
        'vg', 'vi', 'vn', 'vu',
        'wf', 'ws', 'ye,' 'yt',
        'yu', 'za', 'zm', 'zw'  ]


def help():
    print('Usage: finddomain [OPTIONS]\nsee README.md')


def main(argv):
    global tlds
    
    try: opts, args = getopt.getopt(argv, 'hvc:t:l:b:s:', ['help', 'verbose', 'length=', 'top-level-domain=', 'letters=', 'beginning=', 'sleep='])
    except getopt.GetoptError as err:
        print(str(err))
        help()
        exit(1)

    verbose       = False
    domain_length = 4
    sleep_time    = 1
    letters       = 'abcdefghijklmnopqrstuvwxyz0123456789'
    beginning = ''.join(list(repeat('a', domain_length)))

    for opt, arg in opts:
        if opt in ('-h', '--help'):
            help()
            exit(1)
        elif opt in ('-v', '--verbose'):
            verbose = True
        elif opt in ('-c', '--length'):
            domain_length = int(arg)
            beginning = ''.join(list(repeat('a', domain_length)))
        elif opt in ('-t', '--top-level-domain'):
            tlds = arg.split(',')
            verbose = True if len(tlds) == 1 else verbose
        elif opt in ('-l', '--letters'):
            letters = arg.lower()
        elif opt in ('-b', '--beginning'):
            beginning = arg.lower()
        elif opt in ('-s', '--sleep'):
            sleep_time = float(arg)


    slds = [''.join(list(x)) for x in product(letters, repeat=domain_length)]
    try: domains = ['.'.join(list(x)) for x in product(slds[slds.index(beginning):], tlds)]
    except ValueError:
        print('Your settings does not permit you to have \'{}\' as a beginning of the search!'.format(beginning))
        exit(1)

    for domain in domains:
        try: output = str(subprocess.check_output(['whois', domain])).lower()
        except subprocess.CalledProcessError:
            if verbose:
                print('Something went wrong!')

        if re.search('no match|not found', output):
            print('{} is available!'.format(domain))
        elif verbose:
            try: expires = re.search('.*expi(res?|ry|ration).*?:\s*([-0-9a-z/: ]+)', output).group(2)
            except AttributeError: expires = 'unknown'

            print('{} is unavailable.\texpires: {}'.format(domain, expires))

        time.sleep(sleep_time)

if __name__ == '__main__':
    try: main(sys.argv[1:])
    except KeyboardInterrupt: print('\n')
