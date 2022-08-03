class Flyctl < Formula
  desc "Command-line tools for fly.io services"
  homepage "https://fly.io"
  url "https://github.com/superfly/flyctl.git",
      tag:      "v0.0.364",
      revision: "105ccd25ba73d4d2caebd8f0b11a55154be06e22"
  license "Apache-2.0"
  head "https://github.com/superfly/flyctl.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_monterey: "bb531194232191e56d84a8d103c6f7e5f018413f24b45ccac339eb86508ffa5d"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "bb531194232191e56d84a8d103c6f7e5f018413f24b45ccac339eb86508ffa5d"
    sha256 cellar: :any_skip_relocation, monterey:       "841ba60ca793217ced0fc162f06aa3ad1a7d5f7a2adb1fb650f4fec940b37ea2"
    sha256 cellar: :any_skip_relocation, big_sur:        "841ba60ca793217ced0fc162f06aa3ad1a7d5f7a2adb1fb650f4fec940b37ea2"
    sha256 cellar: :any_skip_relocation, catalina:       "841ba60ca793217ced0fc162f06aa3ad1a7d5f7a2adb1fb650f4fec940b37ea2"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "ca0c410ab9e848e522cc76d3c63cf090870bc5b86162d10afccde29a1d7121f7"
  end

  depends_on "go" => :build

  def install
    ENV["CGO_ENABLED"] = "0"
    ldflags = %W[
      -s -w
      -X github.com/superfly/flyctl/internal/buildinfo.environment=production
      -X github.com/superfly/flyctl/internal/buildinfo.buildDate=#{time.iso8601}
      -X github.com/superfly/flyctl/internal/buildinfo.version=#{version}
      -X github.com/superfly/flyctl/internal/buildinfo.commit=#{Utils.git_short_head}
    ]
    system "go", "build", *std_go_args(ldflags: ldflags)

    bin.install_symlink "flyctl" => "fly"

    bash_output = Utils.safe_popen_read("#{bin}/flyctl", "completion", "bash")
    (bash_completion/"flyctl").write bash_output
    zsh_output = Utils.safe_popen_read("#{bin}/flyctl", "completion", "zsh")
    (zsh_completion/"_flyctl").write zsh_output
    fish_output = Utils.safe_popen_read("#{bin}/flyctl", "completion", "fish")
    (fish_completion/"flyctl.fish").write fish_output
  end

  test do
    assert_match "flyctl v#{version}", shell_output("#{bin}/flyctl version")

    flyctl_status = shell_output("flyctl status 2>&1", 1)
    assert_match "Error No access token available. Please login with 'flyctl auth login'", flyctl_status
  end
end
