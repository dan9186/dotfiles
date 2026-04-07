---
name: new-go-cli
description: 'Scaffolds a new Go CLI tool following the preferred personal pattern for building CLIs. Use when asked to "create a new CLI tool", "scaffold a new CLI", "start a new go cli project", "bootstrap a new CLI", or "new cli tool named X". Creates the full skeleton: cobra + viper, goreleaser, golangci-lint, GitHub Actions, Dockerfile, config and client stubs, with testable command constructors throughout.'
---

# New Go CLI Tool Skill

Scaffold a complete, ready-to-extend Go CLI tool following a preferred personal pattern for building CLIs.

## When to Use This Skill

- User asks to create, scaffold, or bootstrap a new CLI tool
- User says "new cli tool named X" or "start a go cli project called X"
- User wants a canonical starting point for a Go CLI

## Pre-Flight Questions

Before scaffolding, confirm:
1. **Tool name** (e.g. `mytool`) — if not provided, ask
2. **Org / GitHub user** (e.g. `myorg`) — used in the module path and Docker registry
3. **Module path** — default: `github.com/{org}/{toolname}`; ask if different
4. **Target directory** — default: `~/go/src/{module}`; confirm or ask
5. **Description** — what the tool does; required for the README and root command Short field.
   - If the user provided it in their request, extract and clean it up into a single concise sentence.
   - If not provided, ask before proceeding.
   - Use this as `{description}` throughout.

## Process

1. Confirm tool name, module path, and target directory
2. Detect the installed Go version:
   ```
   go version
   ```
   Parse the `X.Y` minor version from the output (e.g. `go1.24.2` → `1.24`). Use this as `{goversion}` throughout.
3. Create all files from the templates below, replacing `{toolname}` / `{TOOLNAME}` / `{org}` / `{module}` / `{goversion}` / `{description}` throughout
4. `cd` into the new directory and run:
   ```
   go mod tidy && go mod vendor
   go fmt ./... && go vet ./... && go build . && go test ./...
   ```
4. Report the tree of created files and confirm everything builds and tests pass

---

## Directory Structure

```
{toolname}/
├── .ackrc
├── .gitignore
├── .golangci.yml
├── .goreleaser.yml
├── .github/
│   └── workflows/
│       └── build.yml
├── Dockerfile
├── LICENSE.md
├── README.md
├── forge.yaml
├── go.mod
├── main.go
├── cmd/
│   ├── root.go
│   ├── version.go
│   ├── version_test.go
│   ├── completion.go
│   └── completion_test.go
├── config/
│   ├── file.go
│   └── parse.go
└── client/
    ├── client.go
    ├── clienter.go
    └── clienttest/
        └── clienttest.go
```

---

## File Templates

### `main.go`

```go
package main

import (
	"{module}/cmd"
)

func main() {
	cmd.Execute()
}
```

---

### `cmd/root.go`

```go
package cmd

import (
	"fmt"
	"os"

	"{module}/client"
	"{module}/config"
	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

var (
	clt client.Clienter
)

func init() {
	cobra.OnInitialize(initEnvs)

	rootCmd.AddCommand(NewVersionCmd(os.Stdout, Version))
	rootCmd.AddCommand(NewCompletionCmd(os.Stdout))

	rootCmd.PersistentFlags().BoolP("verbose", "v", false, "show more verbose output")

	err := viper.BindPFlag("verbose", rootCmd.PersistentFlags().Lookup("verbose"))
	if err != nil {
		fmt.Printf("error setting up: %s\n", err)
		os.Exit(1)
	}
}

func initEnvs() {
}

var rootCmd = &cobra.Command{
	Use:   "{toolname} [flags]",
	Short: "{description}",
}

// Execute adds all child commands to the root command and sets flags
// appropriately. This is called by main.main() and only needs to happen once.
func Execute() {
	if err := rootCmd.Execute(); err != nil {
		os.Exit(1)
	}
}

func setupClient(cmd *cobra.Command, args []string) {
	c, err := config.ParseFromFile()
	if err != nil {
		fmt.Printf("error: %s\n", err)
		os.Exit(1)
	}

	clt, err = client.New(c)
	if err != nil {
		fmt.Printf("error: %s\n", err)
		os.Exit(1)
	}
}
```

---

### `cmd/version.go`

```go
package cmd

import (
	"io"

	"github.com/spf13/cobra"
)

func init() {
	// Registered in root.go init() via NewVersionCmd
}

var (
	// Version is the current version of {toolname}, injected at build time via
	// ldflags: -X "{module}/cmd.Version=<version>"
	// Falls back to "dev-local" when not set.
	Version string
)

// NewVersionCmd returns a cobra command that prints the current version.
func NewVersionCmd(out io.Writer, version string) *cobra.Command {
	cmd := &cobra.Command{
		Use:   "version",
		Short: "Display the version",
		Long:  `Display the version of the {toolname} CLI.`,
		Run:   versionRun(version),
	}

	cmd.SetOut(out)

	return cmd
}

func versionRun(version string) func(*cobra.Command, []string) {
	return func(cmd *cobra.Command, args []string) {
		if version == "" {
			cmd.Printf("{TOOLNAME} version dev-local\n")
			return
		}

		cmd.Printf("{TOOLNAME} version %s\n", version)
	}
}
```

---

### `cmd/version_test.go`

```go
package cmd

import (
	"testing"

	"github.com/gomicro/penname"
	"github.com/stretchr/testify/assert"
)

func TestVersionCmd(t *testing.T) {
	t.Parallel()

	t.Run("prints the set version", func(t *testing.T) {
		t.Parallel()

		w := penname.New()
		cmd := NewVersionCmd(w, "1.2.3")

		err := cmd.Execute()
		assert.NoError(t, err)
		assert.Contains(t, string(w.Written()), "1.2.3")
	})

	t.Run("falls back to dev-local when version is empty", func(t *testing.T) {
		t.Parallel()

		w := penname.New()
		cmd := NewVersionCmd(w, "")

		err := cmd.Execute()
		assert.NoError(t, err)
		assert.Contains(t, string(w.Written()), "dev-local")
	})
}
```

---

### `cmd/completion.go`

```go
package cmd

import (
	"fmt"
	"io"
	"os"
	"strings"

	"github.com/spf13/cobra"
)

const (
	defaultShell = "zsh"
)

var (
	shell          string
	ErrUnknownShell = fmt.Errorf("unrecognized shell")
)

// NewCompletionCmd returns a cobra command that outputs shell completion scripts.
func NewCompletionCmd(out io.Writer) *cobra.Command {
	cmd := &cobra.Command{
		Use:   "completion",
		Short: "Generate completion files for the {toolname} CLI",
		RunE:  completionRun(out),
	}

	cmd.Flags().StringVar(&shell, "shell", defaultShell, "shell to generate completions for (bash, zsh, fish, powershell)")
	cmd.SetOut(out)

	return cmd
}

func completionRun(out io.Writer) func(*cobra.Command, []string) error {
	return func(cmd *cobra.Command, args []string) error {
		var err error

		switch strings.ToLower(shell) {
		case "bash":
			err = rootCmd.GenBashCompletion(out)
		case "fish":
			err = rootCmd.GenFishCompletion(out, false)
		case "ps", "powershell", "power_shell":
			err = rootCmd.GenPowerShellCompletion(out)
		case "zsh":
			err = rootCmd.GenZshCompletion(out)
		default:
			err = ErrUnknownShell
		}

		if err != nil {
			cmd.SilenceUsage = true
			return fmt.Errorf("completion: %w", err)
		}

		return nil
	}
}

func completionFunc(cmd *cobra.Command, args []string) {
	var err error
	switch strings.ToLower(shell) {
	case "bash":
		err = rootCmd.GenBashCompletion(os.Stdout)
	case "fish":
		err = rootCmd.GenFishCompletion(os.Stdout, false)
	case "ps", "powershell", "power_shell":
		err = rootCmd.GenPowerShellCompletion(os.Stdout)
	case "zsh":
		err = rootCmd.GenZshCompletion(os.Stdout)
	default:
	}

	if err != nil {
		fmt.Printf("error generating completion output: %v", err.Error())
		os.Exit(1)
	}
}
```

---

### `cmd/completion_test.go`

```go
package cmd

import (
	"testing"

	"github.com/gomicro/penname"
	"github.com/stretchr/testify/assert"
)

func TestCompletionCmd(t *testing.T) {
	t.Parallel()

	t.Run("generates default zsh completion", func(t *testing.T) {
		t.Parallel()

		w := penname.New()
		cmd := NewCompletionCmd(w)

		err := cmd.Execute()
		assert.NoError(t, err)
		assert.NotEmpty(t, string(w.Written()))
	})

	t.Run("generates bash completion when requested", func(t *testing.T) {
		t.Parallel()

		w := penname.New()
		cmd := NewCompletionCmd(w)

		err := cmd.Flag("shell").Value.Set("bash")
		assert.NoError(t, err)

		err = cmd.Execute()
		assert.NoError(t, err)
		assert.NotEmpty(t, string(w.Written()))
	})

	t.Run("returns an error for an unknown shell", func(t *testing.T) {
		t.Parallel()

		w := penname.New()
		cmd := NewCompletionCmd(w)

		err := cmd.Flag("shell").Value.Set("nushell")
		assert.NoError(t, err)

		err = cmd.Execute()
		assert.ErrorIs(t, err, ErrUnknownShell)
	})
}
```

---

### `config/file.go`

```go
package config

import (
	"fmt"
	"os"
	"path/filepath"

	"gopkg.in/yaml.v2"
)

const (
	defaultConfigDir  = ".{toolname}"
	defaultConfigFile = "config"
)

// Config represents the configuration for {toolname}.
type Config struct {
	Github GithubConfig `yaml:"github"`
}

// GithubConfig represents GitHub-specific configuration.
type GithubConfig struct {
	Token string `yaml:"token"`
}

// WriteFile persists the config to ~/.{toolname}/config with mode 0600.
func (c *Config) WriteFile() error {
	home, err := os.UserHomeDir()
	if err != nil {
		return fmt.Errorf("writing config: %w", err)
	}

	dir := filepath.Join(home, defaultConfigDir)

	err = os.MkdirAll(dir, 0700)
	if err != nil {
		return fmt.Errorf("writing config: creating dir: %w", err)
	}

	data, err := yaml.Marshal(c)
	if err != nil {
		return fmt.Errorf("writing config: marshalling: %w", err)
	}

	file := filepath.Join(dir, defaultConfigFile)

	err = os.WriteFile(file, data, 0600)
	if err != nil {
		return fmt.Errorf("writing config: %w", err)
	}

	return nil
}
```

---

### `config/parse.go`

```go
package config

import (
	"fmt"
	"os"
	"path/filepath"

	"gopkg.in/yaml.v2"
)

// ParseFromFile reads the config from ~/.{toolname}/config.
// Returns an empty Config without error if the file does not yet exist.
func ParseFromFile() (*Config, error) {
	home, err := os.UserHomeDir()
	if err != nil {
		return nil, fmt.Errorf("parsing config: %w", err)
	}

	file := filepath.Join(home, defaultConfigDir, defaultConfigFile)

	data, err := os.ReadFile(file)
	if err != nil {
		if os.IsNotExist(err) {
			return &Config{}, nil
		}

		return nil, fmt.Errorf("parsing config: %w", err)
	}

	var c Config

	err = yaml.Unmarshal(data, &c)
	if err != nil {
		return nil, fmt.Errorf("parsing config: unmarshalling: %w", err)
	}

	return &c, nil
}
```

---

### `client/clienter.go`

```go
package client

// Clienter defines the interface for all {toolname} client operations.
// Add methods here as the tool's functionality grows.
type Clienter interface {
	// TODO: add operation methods
}
```

---

### `client/client.go`

```go
package client

import (
	"fmt"

	"{module}/config"
)

// Client implements the Clienter interface.
type Client struct {
	cfg *config.Config
}

// New creates a new Client from the provided config.
func New(c *config.Config) (*Client, error) {
	if c == nil {
		return nil, fmt.Errorf("new client: config is required")
	}

	return &Client{
		cfg: c,
	}, nil
}
```

---

### `client/clienttest/clienttest.go`

```go
package clienttest

// Client is a test double that implements the client.Clienter interface.
// Add fields here to control behavior and capture calls in tests.
type Client struct {
	// TODO: add mock fields as the Clienter interface grows
}

// New returns a new test Client.
func New() *Client {
	return &Client{}
}
```

---

### `go.mod`

```
module {module}

go {goversion}

require (
	github.com/gomicro/penname v0.0.0
	github.com/gomicro/scribe v0.0.0
	github.com/spf13/cobra v0.0.0
	github.com/spf13/viper v0.0.0
	github.com/stretchr/testify v0.0.0
	gopkg.in/yaml.v2 v0.0.0
)
```

> After creating this file, run `go mod tidy` to resolve real versions, then `go mod vendor`.

---

### `forge.yaml`

```yaml
project:
  name: {toolname}

steps:
  build:
    help: Build the project
    envs:
      CGO_ENABLED: 0
      GOOS: '{{.Os}}'
    cmd: >
      go build -ldflags
      "-X '{module}/cmd.Version=dev-{{.ShortSha}}'"
      -o {{.Project}} .

  clean:
    help: Clean up all generated files
    cmd: go clean

  fmt:
    help: Run gofmt
    cmd: go fmt ./...

  install:
    help: Install the binary
    envs:
      CGO_ENABLED: 0
      GOOS: '{{.Os}}'
    cmd: >
      go install -ldflags
      "-X '{module}/cmd.Version=dev-$(git rev-parse --short HEAD)'"

  lint:
    help: Run golangci-lint
    cmd: golangci-lint run

  linters:
    help: Run all linters
    steps:
      - lint
      - fmt
      - vet

  test:
    help: Run all available tests
    steps:
      - unit_test

  unit_test:
    help: Run the unit tests
    cmd: go test ./...

  vet:
    help: Run go vet
    cmd: go vet ./...
```

---

### `.goreleaser.yml`

```yaml
version: 2

builds:
  - env:
      - CGO_ENABLED=0

    ldflags:
      - -X "{module}/cmd.Version={{ .Version }}"
      - "-s -w"

    goos:
      - darwin
      - windows
      - linux

archives:
  - name_template: "{{ .ProjectName }}_{{ .Os }}_{{ .Arch }}"

dockers:
  - goos: linux
    goarch: amd64
    image_templates:
      - "ghcr.io/{org}/{toolname}:latest"
      - "ghcr.io/{org}/{toolname}:{{ .Version }}"
```

> If the tool requires secrets baked into the binary (e.g. OAuth client credentials), add additional
> ldflags entries and the corresponding `var` declarations in `cmd/`:
> ```yaml
> - -X "{module}/cmd.clientID={{ .Env.{TOOLNAME}_CLIENT_ID }}"
> - -X "{module}/cmd.clientSecret={{ .Env.{TOOLNAME}_CLIENT_SECRET }}"
> ```

---

### `.github/workflows/build.yml`

```yaml
name: Build
on: [push]

env:
  GO_VERSION: "{goversion}"

jobs:

  linting:
    name: Linting
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v6
        with:
          fetch-depth: 0

      - name: golangci-lint
        uses: golangci/golangci-lint-action@v9
        with:
          version: latest

  test:
    name: Test
    runs-on: ubuntu-latest

    steps:
      - name: Install Go
        uses: actions/setup-go@v6
        with:
          go-version: ${{ env.GO_VERSION }}

      - name: Checkout
        uses: actions/checkout@v6
        with:
          fetch-depth: 0

      - name: Test
        run: go test ./...

  deploy:
    name: Deploy
    runs-on: ubuntu-latest
    needs: [linting, test]

    env:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      # Add tool-specific secret env vars here, e.g.:
      # {TOOLNAME}_CLIENT_ID: ${{ secrets.{TOOLNAME}_CLIENT_ID }}
      # {TOOLNAME}_CLIENT_SECRET: ${{ secrets.{TOOLNAME}_CLIENT_SECRET }}

    steps:
      - name: Install Go
        uses: actions/setup-go@v6
        with:
          go-version: "${{ env.GO_VERSION }}"

      - name: Checkout
        uses: actions/checkout@v6
        with:
          fetch-depth: 0

      - name: Login to Docker Registry
        uses: docker/login-action@v4
        with:
          registry: ghcr.io
          username: ${{ github.repository_owner }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Snapshot
        uses: goreleaser/goreleaser-action@v7
        with:
          args: release --snapshot

      - name: Release
        if: startsWith(github.ref, 'refs/tags/')
        uses: goreleaser/goreleaser-action@v7
        with:
          args: release --clean
```

---

### `.golangci.yml`

```yaml
version: "2"

run:
  tests: true

linters:
  enable:
    - asciicheck
    - bidichk
    - gocheckcompilerdirectives
    - misspell
    - rowserrcheck
    - sqlclosecheck
    - forbidigo
  disable:
    - gochecknoglobals
    - prealloc
    - wsl
  exclusions:
    generated: lax
    presets:
      - comments
      - common-false-positives
      - legacy
      - std-error-handling
    paths:
      - third_party$
      - builtin$
      - examples$
    rules:
      - path: cmd
        linters:
          - forbidigo
  settings:
    forbidigo:
      forbid:
        - pattern: ^(fmt\.Print(|f|ln))$

formatters:
  enable:
    - gofmt
  exclusions:
    generated: lax
    paths:
      - third_party$
      - builtin$
      - examples$
```

> The `forbidigo` rule bans bare `fmt.Print*` calls outside of `cmd/` — use `scribe` for output
> instead so verbosity is properly gated.

---

### `Dockerfile`

```dockerfile
FROM scratch

LABEL org.opencontainers.image.source=https://github.com/{org}/{toolname}
LABEL org.opencontainers.image.authors="your@email.com"

ADD {toolname} {toolname}

CMD ["/{toolname}"]
```

---

### `.gitignore`

```
# Binaries
{toolname}

# Directories
/dist
.DS_Store

# Generated Files
coverage.txt
```

---

### `.ackrc`

```
--color

--ignore-dir=.git/
--ignore-dir=.idea/
--ignore-dir=coverage/
--ignore-dir=vendor/
```

---

### `README.md`

```markdown
# {toolname}

{description}

## Installation

```bash
brew install {org}/{toolname}
```

Or via Go:

```bash
go install github.com/{org}/{toolname}@latest
```
```

---

## Conventions & Patterns

### Adding a New Subcommand

Each subcommand follows the constructor pattern for testability:

```go
// cmd/mycommand.go
package cmd

import (
	"fmt"
	"io"
	"os"

	"github.com/spf13/cobra"
)

func init() {
	rootCmd.AddCommand(NewMyCmd(os.Stdout))
}

func NewMyCmd(out io.Writer) *cobra.Command {
	cmd := &cobra.Command{
		Use:          "mycommand [args]",
		Short:        "Short description",
		Args:         cobra.ExactArgs(1),
		PersistentPreRun: setupClient,   // include when the command needs the API client
		RunE:         myRun(out),
	}

	cmd.SetOut(out)
	return cmd
}

func myRun(out io.Writer) func(*cobra.Command, []string) error {
	return func(cmd *cobra.Command, args []string) error {
		// ... implementation

		if err != nil {
			cmd.SilenceUsage = true        // suppress usage on runtime errors
			return fmt.Errorf("mycommand: %w", err)
		}

		return nil
	}
}
```

For nested subcommands (e.g. `remote add`), create a subdirectory:
```
cmd/
└── remote/
    ├── remote.go   (RemoteCmd root)
    ├── add.go
    └── remove.go
```
Register the parent in `cmd/root.go` init(), sub-commands in their own `init()` functions.

### Output — Use scribe

Use `github.com/gomicro/scribe` for all output, not bare `fmt.Print*` calls.
The `forbidigo` linter will flag `fmt.Print*` outside `cmd/` by default.
In `cmd/` files, prefer writing to the injected `io.Writer` via `cmd.Printf` / `fmt.Fprintf(out, ...)`.

### Verbose output

Gate verbose output behind `viper.GetBool("verbose")` or the scribe logger's verbose level.

### Error handling

- Use `RunE` (not `Run`) for commands that can fail
- Set `cmd.SilenceUsage = true` before returning runtime errors to prevent cobra from printing the usage message
- Wrap errors with context: `fmt.Errorf("operation name: %w", err)`

### Config file

Lives at `~/.{toolname}/config` (YAML, mode 0600).
`config.ParseFromFile()` returns an empty `Config` without error if the file doesn't exist yet.
Add new fields to `Config` and sub-structs as needed; write-back via `c.WriteFile()`.

### Client interface

Add methods to `client.Clienter` as the tool gains functionality.
The `clienttest.Client` struct must implement `Clienter` — add matching stub methods as you grow the interface.
Use `PersistentPreRun: setupClient` on any command that calls `clt`.

### Version injection

The `Version` variable in `cmd/version.go` is set at build time via ldflags:
```
-X "{module}/cmd.Version=<version>"
```
`forge.yaml` injects `dev-<short-sha>` for local builds.
goreleaser injects the tag version for releases.
Anything not injected falls back to `"dev-local"`.

### Optional: GitHub OAuth auth

If the tool authenticates with GitHub, add:
- `var clientID, clientSecret string` in `cmd/auth.go` (injected via ldflags)
- An `auth` subcommand following the OAuth device-flow pattern (see `align` or `train` in the gomicro org for reference implementations)
- Add `gomicro/trust`, `golang.org/x/oauth2`, and `google/go-github` to `go.mod`
- Update `.goreleaser.yml` to inject `clientID` / `clientSecret`
- Update `.github/workflows/build.yml` env section with the secret names
