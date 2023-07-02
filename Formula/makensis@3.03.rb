class MakensisAT303 < Formula
  desc "System to create Windows installers"
  homepage "https://nsis.sourceforge.io/"
  url "https://downloads.sourceforge.net/project/nsis/NSIS%203/3.03/nsis-3.03-src.tar.bz2"
  sha256 "abae7f4488bc6de7a4dd760d5f0e7cd3aad7747d4d7cd85786697c8991695eaa"
  license "Zlib"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "fc4524675c0efffcdedcc5bb92d348afa0577c33fd69e1ef75a8da48cf0c6e90"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "4e9d197faa2cb6ee296902f69def0deb0dcc30db077cc6ff2943e12a5c4bdb3c"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "4656747f66941fb5b2f4adaad2c4bdd64e99a48c1938a580f91befce75700c4d"
    sha256 cellar: :any_skip_relocation, ventura:        "4532aeda1faa4cd83fe4c881f34a59dc87e4e24d69b1b6b196ac16e84ede3a21"
    sha256 cellar: :any_skip_relocation, monterey:       "e4df4ea446eaf4b905b3e9f102a133894cb36d7b33620be03b5374fa59703975"
    sha256 cellar: :any_skip_relocation, big_sur:        "21f3aa213be2e8c0a0a2d992fb117cc5e5c5cf625b3299bcf1f7506c117900f5"
    sha256 cellar: :any_skip_relocation, catalina:       "0e86809dd3b7c95a587bc467a7b12a2ab07cacf91f31ead7174fffe3cc1d7c6f"
    sha256 cellar: :any_skip_relocation, mojave:         "d2c3aeb784d8aa8192360a20a7410b5b4f617deae10d59b18535cafa2bc5809f"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "ed7437e47f43473d9a9a81652697d21373f11346401fc7a20d0a35357ca73ea8"
  end

  option "with-advanced-logging", "Enable advanced logging of all installer actions"
  option "with-large-strings", "Enable strings up to 8192 characters instead of default 1024"
  option "with-debug", "Build executables with debugging information"

  depends_on "mingw-w64" => :build
  depends_on "scons" => :build

  resource "nsis" do
    url "https://downloads.sourceforge.net/project/nsis/NSIS%203/3.03/nsis-3.03.zip"
    sha256 "b53a79078f2c6abf21f11d9fe68807f35b228393eb17a0cd3873614190116ba7"
  end

  def install
    args = [
      "CC=#{ENV.cc}",
      "CXX=#{ENV.cxx}",
      "PREFIX_DOC=#{share}/nsis/Docs",
      "SKIPUTILS=Makensisw,NSIS Menu,zip2exe",
      # Don't strip, see https://github.com/Homebrew/homebrew/issues/28718
      "STRIP=0",
      "VERSION=#{version}",
    ]

    args << "NSIS_CONFIG_LOG=yes" if build.with? "advanced-logging"
    args << "NSIS_MAX_STRLEN=8192" if build.with? "large-strings"
    args << "DEBUG=1" if build.with? "debug"
    args << "APPEND_LINKFLAGS=-Wl,-rpath,#{rpath}" if OS.linux?

    system "scons", "makensis", *args

    install_path = if build.with? "debug"
      "build/udebug/makensis/makensis"
    else
      "build/urelease/makensis/makensis"
    end

    bin.install install_path
    (share/"nsis").install resource("nsis")
  end

  test do
    # Workaround for https://sourceforge.net/p/nsis/bugs/1165/
    ENV["LANG"] = "en_GB.UTF-8"
    %w[COLLATE CTYPE MESSAGES MONETARY NUMERIC TIME].each do |lc_var|
      ENV["LC_#{lc_var}"] = "en_GB.UTF-8"
    end

    system "#{bin}/makensis", "-VERSION"
    system "#{bin}/makensis", "-HDRINFO"
    system "#{bin}/makensis", "-XUnicode false", "#{share}/nsis/Examples/bigtest.nsi", "-XOutfile /dev/null"
  end
end
