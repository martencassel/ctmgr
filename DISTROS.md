# ctmgr-distros - Distro Version Discovery Tool

A companion CLI tool for `ctmgr` that helps discover available Linux distribution versions from Docker Hub and other sources.

## Features

- 🔍 Query Docker Hub for available distro versions
- 📊 Display results in table or JSON format
- 💾 Caching to reduce API calls (1-hour expiry)
- 🔎 Search across multiple distros
- 📋 List all tags for a specific distro

## Prerequisites

```bash
# Required tools
sudo apt-get install curl jq  # Debian/Ubuntu
```

## Installation

```bash
# Make executable
chmod +x ctmgr-distros

# Optional: Add to PATH
sudo ln -s $(pwd)/ctmgr-distros /usr/local/bin/
```

## Usage

### List supported distros

```bash
ctmgr-distros list
```

Output:
```
Supported Distros
=================
  - debian
  - ubuntu
  - fedora
  - alpine
  - centos
  - rockylinux
```

### List versions for a specific distro

```bash
# Table format (default)
ctmgr-distros list --distro debian

# JSON format
ctmgr-distros list --distro debian --format json
```

Example output:
```
Debian Versions (from Docker Hub)
==================================
VERSION              LAST UPDATED              SIZE (MB)
12.9                 2024-11-09T01:23:45            124
12.8                 2024-10-15T08:14:22            124
bookworm             2024-11-09T01:23:45            124
12-slim              2024-11-09T01:24:03             74
bullseye             2024-11-08T22:15:33            116
11.11                2024-11-08T22:15:33            116
```

### Search for specific versions

```bash
# Search across all distros
ctmgr-distros search bookworm

# JSON output
ctmgr-distros search "12.9" --format json
```

### List all tags for a distro

```bash
# List all available tags
ctmgr-distros tags --distro debian

# JSON format
ctmgr-distros tags --distro debian --format json

# Specify source (currently only dockerhub)
ctmgr-distros tags --distro ubuntu --source dockerhub
```

### Refresh cache

```bash
# Clear cache and force fresh data fetch
ctmgr-distros refresh
```

## Integration with ctmgr

Use `ctmgr-distros` to discover available versions, then use them with `ctmgr`:

```bash
# 1. Find available Debian versions
ctmgr-distros list --distro debian

# 2. Use a specific version in your Dockerfile
# Update dockerfiles/Dockerfile.debian to use: FROM debian:12.9

# 3. Build the pool
ctmgr pool build --pool debian --dockerfile dockerfiles/Dockerfile.debian
```

## Output Formats

### Table Format (default)

Human-readable tabular output with columns:
- VERSION: Tag/version name
- LAST UPDATED: When the image was last updated
- SIZE (MB): Image size in megabytes

### JSON Format

Machine-readable JSON output:
```json
[
  {
    "version": "12.9",
    "last_updated": "2024-11-09T01:23:45.123456Z",
    "size_mb": 124
  }
]
```

## Caching

- Cache location: `~/.ctmgr_cache/`
- Cache expiry: 1 hour
- Automatically refreshes after expiry
- Manual refresh: `ctmgr-distros refresh`

## Supported Distros

### Currently Implemented
- **Debian**: Numeric versions (12.9, 11.11) and codenames (bookworm, bullseye, buster)
- **Ubuntu**: Numeric versions (22.04, 20.04) and codenames (jammy, focal, noble)
- **Fedora**: Numeric versions (39, 40) and rawhide
- **Alpine**: Numeric versions (3.19, 3.20) and edge

### Coming Soon
- CentOS
- Rocky Linux
- Oracle Linux

## Examples

### Find the latest Debian version

```bash
ctmgr-distros list --distro debian --format json | jq '.[0].version'
```

### Find all Ubuntu LTS versions

```bash
ctmgr-distros tags --distro ubuntu | grep -E "22.04|20.04|18.04"
```

### Compare sizes across distros

```bash
for distro in debian ubuntu alpine; do
  echo "=== $distro ==="
  ctmgr-distros list --distro $distro --format json | jq '.[0] | {version, size_mb}'
done
```

### Search for slim variants

```bash
ctmgr-distros search slim
```

## Advanced Usage

### Use with ctmgr pool build

```bash
# Get latest Debian version
VERSION=$(ctmgr-distros list --distro debian --format json | jq -r '.[0].version')

# Update Dockerfile to use this version
sed -i "s/FROM debian:.*/FROM debian:$VERSION/" dockerfiles/Dockerfile.debian

# Build with custom options
ctmgr pool build --pool debian \
  --dockerfile dockerfiles/Dockerfile.debian \
  --user devops \
  --password changeme \
  --mirror http://deb.debian.org/debian
```

## API Rate Limiting

Docker Hub API has rate limits:
- Anonymous: 100 pulls per 6 hours
- Authenticated: 200 pulls per 6 hours

The tool uses caching to minimize API calls. Use `ctmgr-distros refresh` only when needed.

## Troubleshooting

### "curl: command not found"
```bash
sudo apt-get install curl
```

### "jq: command not found"
```bash
sudo apt-get install jq
```

### Cache issues
```bash
# Clear cache and try again
ctmgr-distros refresh
```

### No results for a distro
```bash
# Check if distro name is correct
ctmgr-distros list

# Try searching
ctmgr-distros search <distro-name>
```

## Contributing

To add support for a new distro:

1. Add a `get_<distro>_versions()` function
2. Update the `list_distros()` case statement
3. Update the usage and documentation

Example:
```bash
get_rockylinux_versions() {
  local format="${1:-table}"
  local tags=$(fetch_dockerhub_tags "rockylinux")
  # ... implementation
}
```
