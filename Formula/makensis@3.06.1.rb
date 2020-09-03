class MakensisAT3061 < Formula
  desc "System to create Windows installers"
  homepage "https://nsis.sourceforge.io/"
  url "https://downloads.sourceforge.net/project/nsis/NSIS%203/3.06.1/nsis-3.06.1-src.tar.bz2"
  sha256 "9b5d68bf1874a7b393432410c7e8c376f174d2602179883845d2508152153ff0"

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
    url "https://downloads.sourceforge.net/project/nsis/NSIS%203/3.06.1/nsis-3.06.1.zip"
    sha256 "d463ad11aa191ab5ae64edb3a439a4a4a7a3e277fcb138254317254f7111fba7"
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

    if build.with? "debug"
      install_path = "build/udebug/makensis/makensis"
    else
      install_path = "build/urelease/makensis/makensis"
    end

    bin.install install_path
    (share/"nsis").install resource("nsis")
  end

  test do
    system "#{bin}/makensis", "-VERSION"
    system "#{bin}/makensis", "-HDRINFO"
    system "#{bin}/makensis", "#{share}/nsis/Examples/bigtest.nsi", "-XOutfile /dev/null"
  end
end
