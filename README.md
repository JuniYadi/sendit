## sendit.sh
### bash script for downloading sendit files

##### Download single file from sendit

```bash
./sendit.sh url
```

##### Batch-download files from URL list (url-list.txt must contain one sendit.cloud url per line)

```bash
./sendit.sh url-list.txt
```

##### Example:

```bash
./sendit.sh https://sendit.cloud/s3h8qtwpoo89
```

sendit.sh uses `wget` with the `-C` flag, which skips over completed files and attempts to resume partially downloaded files.

### Requirements: `coreutils`, `curl`, `grep`, `sed`, **`wget`**
