class MakensisAT307 < Formula
  desc "System to create Windows installers"
  homepage "https://nsis.sourceforge.io/"
  url "https://downloads.sourceforge.net/project/nsis/NSIS%203/3.07/nsis-3.07-src.tar.bz2"
  sha256 "4dfad3388589985b4cd91d20e18e1458aa31e7d139b5b8adf25c3a9c1015efba"
  license "Zlib"

  option "with-advanced-logging", "Enable advanced logging of all installer actions"
  option "with-large-strings", "Enable strings up to 8192 characters instead of default 1024"
  option "with-debug", "Build executables with debugging information"

  depends_on "mingw-w64" => :build
  depends_on "scons@4.7.0" => :build

  resource "nsis" do
    url "https://downloads.sourceforge.net/project/nsis/NSIS%203/3.07/nsis-3.07.zip"
    sha256 "04dde28896ae9ab36ea3035ff3a294e78053f00048064f6d22a6f1c02bcb6ec0"
  end

  if build.with?("large-strings")
    resource "nsis-strlen" do
      url "https://downloads.sourceforge.net/project/nsis/NSIS%203/3.07/nsis-3.07-strlen_8192.zip"
      sha256 "3201f5022811d5f0431e05bd2564314928648fd4826ed7abe53becb646204e10"
    end
  end

  def install
    args = [
      "CC=#{ENV.cc}",
      "CXX=#{ENV.cxx}",
      "PREFIX=#{prefix}",
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
    (share/"nsis").install resource("nsis-strlen") if build.with?("large-strings")
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
