from typing import List, Union
import os
import os.path
import re


def task_pip():
    return {
        "actions": [
            "pip-compile --output-file=requirements.txt requirements.in",
            "pip-sync",
            "sed -i -e '/macfsevents/d' requirements.txt",
        ],
        "file_dep": ["requirements.in", "dodo.py"],
        "targets": ["requirements.txt"],
    }


def task_elm():
    realm_deps: List[str] = glob2(
        "realm/frontend/", r".*\.(elm|js)", recursive=True
    ) + ["dodo.py"]

    basename = "."
    proj_elms: List[str] = glob2(basename + "/frontend", r".*\.elm", recursive=True) + [
        basename + "/frontend/elm.json"
    ]
    main_elms: List[str] = [
        e.replace(basename + "/frontend/", "")
        for e in proj_elms
        if "Pages/" in e and "Test.elm" not in e
    ]
    test_elms: List[str] = [
        e.replace(basename + "/frontend/", "") for e in proj_elms if "Pages/" in e
    ]

    yield {
        "actions": [
            "cd %s/frontend && elm make"
            "  Test.elm --output=elm-stuff/t.js" % (basename,),
            "mkdir -p static/%s" % (basename,),
            "cat %s/frontend/elm-stuff/t.js realm/frontend/IframeController.js "
            "   > static/%s/test.js" % (basename, basename),
        ],
        "file_dep": proj_elms + realm_deps,
        "targets": ["static/%s/test.js" % (basename,)],
        "basename": "elm",
        "name": "test",
    }

    yield {
        "actions": [
            "cd %s/frontend && elm make"
            "   Storybook.elm"
            "   --output=elm-stuff/s.js" % (basename,),
            "mkdir -p static/%s" % (basename,),
            "cat %s/frontend/elm-stuff/s.js realm/frontend/IframeController.js "
            "   > static/%s/storybook.js" % (basename, basename),
        ],
        "file_dep": proj_elms + realm_deps,
        "targets": ["static/%s/storybook.js" % (basename,)],
        "basename": "elm",
        "name": "storybook",
    }

    elm_cmd = " ".join(
        ["cd %s/frontend && elm" % (basename,), "make", "--output=elm-stuff/i.js"]
        + test_elms
    )
    yield {
        "actions": [
            elm_cmd,
            "mkdir -p static/%s" % (basename,),
            "cat %s/frontend/elm-stuff/i.js realm/frontend/Realm.js "
            "   > static/%s/iframe.js" % (basename, basename),
        ],
        "file_dep": proj_elms + realm_deps,
        "targets": ["static/%s/iframe.js" % (basename,)],
        "basename": "elm",
        "name": "iframe",
    }

    elm_cmd = " ".join(
        ["cd %s/frontend && elm" % (basename,), "make", "--output=elm-stuff/e.js"]
        + main_elms
    )
    uglify_cmd = (
        "../node_modules/.bin/uglifyjs "
        "elm-stuff/e.js --compress "
        '"pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],'
        'pure_getters,keep_fargs=false,unsafe_comps,unsafe" '
        "| ./node_modules/.bin/uglifyjs --mangle --output=elm-stuff/e.min.js"
    )
    cmds = open("/tmp/cmds.txt", "w")
    cmds.write(elm_cmd + "\n")
    cmds.write(uglify_cmd + "\n")

    yield {
        "actions": [
            elm_cmd,
            # uglify_cmd,
            # "echo >> elm-stuff/e.min.js",
            "mkdir -p static/%s" % (basename,),
            "cat %s/frontend/elm-stuff/e.js realm/frontend/Realm.js"
            "   > static/%s/elm.js" % (basename, basename),
        ],
        "file_dep": proj_elms + realm_deps,
        "targets": ["static/%s/elm.js" % (basename,)],
        "basename": "elm",
        "name": "main",
    }


IGNORED: List[str] = ["node_modules", "elm-stuff", "builds", "tests"]
MAIN_ELM = re.compile(r"\Wmain\W")


def glob2(
    path: str,
    patterns: str,
    blacklist: Union[str, List[str]] = None,
    recursive: bool = False,
    links: bool = True,
) -> List[str]:
    if blacklist is None:
        blacklist = IGNORED

    ls = os.listdir(path)
    ls = [os.path.join(path, f1) for f1 in ls]

    if blacklist:
        if type(blacklist) is str:
            blacklist = [blacklist]
        ls = [e for e in ls if not any(re.search(p, e) for p in blacklist)]

    if type(patterns) is str:
        patterns = [patterns]

    files = [
        e
        for e in ls
        if os.path.isfile(e) and any(re.search(patt, e) for patt in patterns)
    ]

    if recursive:
        dirs = [e for e in ls if os.path.isdir(e) and (links or not os.path.islink(e))]
        for d in dirs:
            files.extend(glob2(d, patterns, blacklist, recursive, links))

    return files
