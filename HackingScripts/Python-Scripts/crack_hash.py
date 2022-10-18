#!/usr/bin/env python

import os
import sys
import subprocess
import json
import tempfile
from name_that_hash import runner

def load_cracked_hashes():
    potfile_path = os.path.join(os.path.expanduser("~"), ".hashcat", "hashcat.potfile")
    cracked_hashes = { }
    if os.path.isfile(potfile_path):
        with open(potfile_path, "r") as f:
            for line in f:
                hash, password = line.strip().rsplit(":",1)
                cracked_hashes[hash] = password

    return cracked_hashes

if __name__ == "__main__":

    if len(sys.argv) < 2:
        print("Usage: %s <file>" % sys.argv[0])
        exit(1)

    hashes = filter(None, [line.strip() for line in open(sys.argv[1],"r").readlines()])
    potfile = load_cracked_hashes()
    if potfile:
        uncracked_hashes = []
        for hash in hashes:
            password = potfile.get(hash, potfile.get(hash.rsplit(":", 1)[0], None))
            if password:
                print(f"Potfile: {hash}: {password}")
            else:
                uncracked_hashes.append(hash)
    else:
        uncracked_hashes = hashes
        
    hashes = json.loads(runner.api_return_hashes_as_json(uncracked_hashes))
    wordlist = "/usr/share/wordlists/rockyou.txt" if len(sys.argv) < 3 else sys.argv[2]

    hash_types = { }
    for hash, types in hashes.items():
        for t in types:
            hash_id = t["hashcat"]
            if hash_id is None:
                continue

            salted = ":" in hash
            if salted != t["extended"]:
                continue
            
            if hash_id not in hash_types:
                hash_types[hash_id] = { "name": t["name"], "hashes": {hash} }
            else:
                hash_types[hash_id]["hashes"].add(hash)

    if len(hash_types) > 0:
        uncracked_types = list(hash_types.keys())
        num_types = len(uncracked_types)
        if num_types > 1:
            print("There are multiple uncracked hashes left with different hash types, choose one to proceed with hashcat:")
            print()

            i = 0
            for hash_id, hash_type in hash_types.items():
                name = (hash_type["name"] + ": ").ljust(max(len(x["name"]) for x in hash_types.values()) + 2)
                count = len(hash_type["hashes"])
                index = (f"{i}. ").ljust(len(str(num_types - 1)) + 2)
                print(f"{index}{name}{count} hashe(s)")
                i += 1

            # Ask user…
            selected = None
            while selected is None or selected < 0 or selected >= num_types:
                try:
                    selected = int(input("Your Choice: ").strip())
                    if selected >= 0 and selected < num_types:
                        break
                except Exception as e:
                    if type(e) in [EOFError, KeyboardInterrupt]:
                        print()
                        exit()

                print("Invalid input")
            selected_type = uncracked_types[selected]
        else:
            selected_type = uncracked_types[0]

        fp = tempfile.NamedTemporaryFile()
        for hash in hash_types[selected_type]["hashes"]:
            fp.write(b"%s\n" % hash.encode("UTF-8"))
        fp.flush()

        proc = subprocess.Popen(["hashcat", "-m", str(selected_type), "-a", "0", fp.name, wordlist])
        proc.wait()
        fp.close()
    else:
        print("No uncracked hashes left")