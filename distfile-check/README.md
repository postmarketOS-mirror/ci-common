## distfile-check

Verify that each distfile has the same hash in a directory full of APKBUILDs.
Make is used for parallelization. This CI check is not postmarketOS specific.

### Usage

```
$ sudo apk add findutils make
$ cp Makefile distfiletree.sh collisions.sh path/to/aports
$ cd path/to/aports
$ make -j999 FINDOPTS="-not -path './unmaintained/*' -not-path './scripts/*'"
```

FINDOPTS is optional and can be used to ignore certain directories.

Set the job count (`-j`) to a high number, as each job will be used to parse
one APKBUILD. This happens very fast, if you set the job count just as high as
your cpu count (as you would do when compiling code), your CPU usage is not as
efficient.

### Example output

```
make: Entering directory '/mnt/pmbootstrap-git/aports_upstream'
:: Building distfiletree...
:: Checking for collisions...

'sshuttle-0.78.5.tar.gz' has different hashes in:
- testing/py3-sshuttle/APKBUILD
- testing/sshuttle/APKBUILD

Add a target filename prefix to the source of your APKBUILD:
https://wiki.alpinelinux.org/wiki/APKBUILD_Reference#source

:: Check failed
make: *** [Makefile:23: collisions] Error 1
make: Leaving directory '/mnt/pmbootstrap-git/aports_upstream'
```

### How it works

#### Collision check

* `Makefile` finds all APKBUILDs and runs `distfiletree.sh` on each of them
* `distfiletree.sh` builds the following directory structure in a temp dir, for
  each distfile (e.g. `mysource.tar.bz`) found in `source` of the APKBUILD:

```sh
distfile-urihash/
	$distfile/
		$urihash # empty file
urihash-pkgname/
	$urihash/
		$pkgname # file contains a path like "testing/pmbootstrap/APKBUILD"
```
* Once this is done, `collisions.sh` looks for any directory in
  `distfile-urihash` that has more than one file inside and reports them as
  errors.
