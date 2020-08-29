class MakensisAT302 < Formula
  desc "System to create Windows installers"
  homepage "https://nsis.sourceforge.io/"
  url "https://downloads.sourceforge.net/project/nsis/NSIS%203/3.02/nsis-3.02-src.tar.bz2"
  sha256 "c44ad18462c56ada4b4303513997076b960f7a991993c5c43ae0edb4936dd83d"

  livecheck do
    url :stable
  end

  bottle do
    cellar :any_skip_relocation
    sha256 "889d630bf8637f68e90a9591a373ee44bde8d9d6a9395171e024fdced27f26ef" => :catalina
    sha256 "b40f5a388f0dddeb2c3d274bdc43fbba6cc0a9f613d056f0981bc60350252448" => :mojave
    sha256 "fe92934c874a27ead142b769d1c1258c6fd3baa66f2f005cad3f57ccd759734f" => :high_sierra
  end

  option "with-advanced-logging", "Enable advanced logging of all installer actions"
  option "with-large-strings", "Enable strings up to 8192 characters instead of default 1024"
  option "with-debug", "Build executables with debugging information"

  depends_on "mingw-w64" => :build
  depends_on "scons" => :build

  resource "nsis" do
    url "https://downloads.sourceforge.net/project/nsis/NSIS%203/3.02/nsis-3.02.zip"
    sha256 "b63bf7cb1e2522754ccb5628e54277f553bc6810d6229d0fe7eb1d78b3457206"
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

    system "scons", "makensis", *args
    bin.install "build/urelease/makensis/makensis"
    (share/"nsis").install resource("nsis")
  end

  test do
    system "#{bin}/makensis", "-VERSION"
    system "#{bin}/makensis", "-HDRINFO"
    system "#{bin}/makensis", "#{share}/nsis/Examples/bigtest.nsi", "-XOutfile /dev/null"
  end
end
